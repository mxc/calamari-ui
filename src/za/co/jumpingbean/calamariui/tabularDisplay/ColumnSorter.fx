/*
 * ColumnSorter.fx
 *
 * Created on 26-Apr-2010, 19:50:10
 */

package za.co.jumpingbean.calamariui.tabularDisplay;

import javax.swing.table.TableColumnModel;
import javax.swing.table.TableColumn;
import za.co.jumpingbean.calamariui.service.Utils;
import javafx.util.Sequences;
import za.co.jumpingbean.calamariui.model.SquidLogRecord;
import java.util.Comparator;
import javafx.reflect.FXLocal;
import javafx.reflect.FXValue;
import java.math.BigDecimal;


/**
 * @author mark
 */

var sortOrderFlag:Boolean = true; // flag to change sort order of columns (asc/desc)

public class ColumnSorter extends TaskCallback {

    public-init var tableDisplay:TabularDisplay;
    public-init var X:Integer;

    override public function performTask () : Void {
        println("sorting data...");
         def colModel:TableColumnModel = tableDisplay.table.getJTable().getColumnModel();
         def columnModelIndex = colModel.getColumnIndexAtX(X);
         def column:TableColumn = colModel.getColumn(columnModelIndex);
         var sortColumn = Utils.toClassCamelCase(column.getHeaderValue().toString());
         if (sortColumn=="kiloBytes") {
                 sortColumn="bytesKB";
         }//not lekker
         else if (sortColumn=="user") sortColumn="rfc931";//also not lekker
         var data = Sequences.sort(tableDisplay.tableData,Comparator{
             override public function equals (item: Object) : Boolean {
                    if (item==null) return false;
                    if (item==this) return true;
                    return false;
             }
             //Use refelction to retrieve value.
             override public function compare (item1 : Object, item2 : Object) : Integer {
                def ctx:FXLocal.Context = FXLocal.getContext();
                def cls:FXLocal.ClassType = ctx.findClass("za.co.jumpingbean.calamariui.model.SquidLogRecord");
                def fxItem1 = new FXLocal.ObjectValue(item1,cls);
                def fxItem2 = new FXLocal.ObjectValue(item2,cls);
                def variable = cls.getVariable(Utils.toClassCamelCase(sortColumn));
                def fxVal1:FXValue = variable.getValue(fxItem1);
                def fxVal2:FXValue = variable.getValue(fxItem2);
                 if (sortColumn=="hits" or sortColumn=="bytes" or sortColumn=="elapsed"){
                            def tmpItem1 = Integer.parseInt(fxVal1.getValueString());
                            def tmpItem2 = Integer.parseInt(fxVal2.getValueString());
                            return tmpItem1.compareTo(tmpItem2);
                 } else if (sortColumn=="bytesKB"){
                            def tmpItem1 = new BigDecimal(fxVal1.getValueString());
                            def tmpItem2 = new BigDecimal(fxVal2.getValueString());
                            return tmpItem1.compareTo(tmpItem2);
                 }
                 else if (sortColumn=="accessDate"){
                            println(fxVal1.getValueString());
                            def tmpItem1 = Utils.toDate(fxVal1.getValueString());
                            def tmpItem2 = Utils.toDate(fxVal2.getValueString());
                            return tmpItem1.compareTo(tmpItem2);
                 }else{
                            def tmpItem1 = fxVal1.getValueString();
                            def tmpItem2 = fxVal2.getValueString();
                            return tmpItem1.compareTo(tmpItem2);
                 }
              }
        }) as SquidLogRecord[];
        //Bit of a hack to change sort order. User will need to click on column to twice potentially to get required order
        //asc or desc. Avoids having to track previous order for each column.
        println("determine sort order..");
        if (sortOrderFlag){
            sortOrderFlag=false;
            FX.deferAction(function():Void{tableDisplay.tableData = reverse data;});
        }else{
            sortOrderFlag=true;
            FX.deferAction(function():Void{tableDisplay.tableData = data;});
        }
        println("finshed sorting data...");
        FX.deferAction(function():Void{tableDisplay.stopIndicator();});
    }


}
