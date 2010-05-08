/*
 * ImportFileParser.fx
 *
 * Created on 28-Apr-2010, 12:39:20
 */

package za.co.jumpingbean.calamariui.service;

import za.co.jumpingbean.calamariui.model.ImportFile;
import javafx.data.pull.Event;
import javafx.data.pull.PullParser;

/**
 * @author mark
 */

public class ImportFileRecordParser extends AbstractParser {

    public-read var list:ImportFile[];
    var importFile:ImportFile;

    override function onEvent(event:Event){
            if (event.level==1 and event.type==PullParser.START_ELEMENT){
                importFile = ImportFile{};
            }else if (event.level==2 and event.type==PullParser.END_ELEMENT){
                if (event.qname.name=="fileName") {
                        importFile.filename = event.text;
                } else if (event.qname.name=="importDate") {
                        importFile.importDate=Utils.timestampFromString(event.text);
                }else if (event.qname.name=="checksum"){
                        importFile.checksum=Long.parseLong(event.text);
                }
            }else if (event.level==1 and event.type==PullParser.END_ELEMENT){
                insert importFile into list;
            }
    }

}