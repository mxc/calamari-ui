/*
 * Aggregator.fx
 *
 * Created on 18 Apr 2010, 5:39:11 PM
 */

package za.co.jumpingbean.calamariui.tabularDisplay;

import java.util.HashMap;
import za.co.jumpingbean.calamariui.model.SquidLogRecord;
import javafx.reflect.FXLocal;
import javafx.reflect.FXVarMember;
import java.math.BigDecimal;
import java.math.MathContext;
import za.co.jumpingbean.calamariui.service.Utils;
import za.co.jumpingbean.calamariui.common.DataLoadingIndicator;
import java.sql.Timestamp;


/**
 * @author mark
 */

public class Aggregator extends TaskCallback {

    public def map:HashMap = new HashMap();
    public var grouping:String[];
    public-init var tableDisplay:TabularDisplay;
    public var columns:String[];//keep a list of all dimension variables to determine what
    //to show/hide later

    override public function performTask () : Void {
        println("perfoming aggregation ....");
        for (data in tableDisplay.logEntries.list){
            addRecord(data);
        }
        //display.scene
        //Hide columns that are'nt part of the aggregation.
        tableDisplay.showingAggregate=true;
        for (tmp in grouping) delete tmp from columns;
        FX.deferAction(function():Void{
                tableDisplay.tableData=getValueSequence();
                tableDisplay.stopIndicator();
                tableDisplay.hideColumns=columns;
          });
        println("aggregation finished ....");
    }

    public function getValueSequence():SquidLogRecord[]{
        def records = (map.values());
        for (record in records){
            record as SquidLogRecord;
        }
    }

    public function addRecord(record:SquidLogRecord){
        //var xmap = ReflectionCache.getVariableMap(record.getJFXClass());
        var tmpString:String="";
        //Build our hash key.
        def ctx:FXLocal.Context = FXLocal.getContext();
        def cls:FXLocal.ClassType = ctx.findClass("za.co.jumpingbean.calamariui.model.SquidLogRecord");
        def fxCurrentObj = new FXLocal.ObjectValue(record,cls);
        def newRecord = SquidLogRecord{hits:0; bytes:0, bytesKB:new BigDecimal(0,new MathContext(3))};
        def fxNewRecordObj = new FXLocal.ObjectValue(newRecord,cls);
        for (key in grouping) {
                var tmpKey=key;
                if (key=="Date"){
                    tmpKey="accessDate";
                }else if (key=="Date/Hour"){
                    tmpKey="accessDate";
                }
                def variable:FXVarMember = cls.getVariable(Utils.toClassCamelCase(tmpKey));
                def fxVal = variable.getValue(fxCurrentObj);
                var stringVal:String;
                if (key=="Date"){
                    var millisec=record.accessDate.getTime()/86400000 as Long;
                    newRecord.accessDate=new Timestamp(millisec*86400000);
                    println("Date={Utils.getDateFromTimestamp(newRecord.accessDate)}");
                    stringVal = Utils.formatDatePrettyPrint(Utils.getDateFromTimestamp(newRecord.accessDate));
                }else if (key=="Date/Time"){
                    var millisec=record.accessDate.getTime()/3600000 as Long;
                    newRecord.accessDate=new Timestamp(millisec*3600000);
                    println("Date/Time={Utils.getDateFromTimestamp(newRecord.accessDate)}");
                    stringVal = Utils.formatDatePrettyLongPrint(newRecord.accessDate);
                } else {
                        stringVal = fxVal.getValueString();
                        variable.setValue(fxNewRecordObj,fxVal);
                }

                tmpString = "{tmpString}{stringVal}";
        }

        if (map.get(tmpString)!=null){
            var tmpRecord = (map.get(tmpString) as SquidLogRecord);
            tmpRecord.bytes=tmpRecord.bytes+record.bytes;
            tmpRecord.bytesKB=tmpRecord.bytesKB.add(record.bytesKB);
            tmpRecord.hits=tmpRecord.hits+record.hits;
        }else{
            newRecord.hits=record.hits;
            newRecord.bytes=record.bytes;
            newRecord.bytesKB=record.bytesKB;
            map.put(tmpString,newRecord);
        }
    }
}

