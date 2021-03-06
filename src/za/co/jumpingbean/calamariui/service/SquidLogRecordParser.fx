/*
 * SquidLogRecordParser.fx
 *
 * Created on 05 Apr 2010, 8:36:39 PM
 */

package za.co.jumpingbean.calamariui.service;


import javafx.data.pull.Event;
import za.co.jumpingbean.calamariui.model.SquidLogRecord;
import javafx.data.pull.PullParser;
import za.co.jumpingbean.calamariui.service.Utils;
import java.math.BigDecimal;
import java.math.MathContext;

/**
 * @author mark
 */

public class SquidLogRecordParser extends AbstractParser {

    public-read var list:SquidLogRecord[];
    var squidLogRecord:SquidLogRecord;

    override public function onEvent (event : Event) : Void {
            if (event.level==1 and event.type==PullParser.START_ELEMENT){
                squidLogRecord = SquidLogRecord{};
            }else if (event.level==2 and event.type==PullParser.END_ELEMENT){
                if (event.qname.name=="serverInfo") {
                        squidLogRecord.serverInfo = event.text;
                } else if (event.qname.name=="accessDate") {
                        squidLogRecord.accessDate= Utils.timestampFromString(event.text);
                } else if (event.qname.name=="bytes") {
                        squidLogRecord.bytes=Integer.parseInt(event.text);
                        squidLogRecord.bytesKB=new BigDecimal(Double.parseDouble(event.text)/1024,new MathContext(3));
                } else if (event.qname.name=="codeStatus"){
                        squidLogRecord.codeStatus=event.text;
                } else if (event.qname.name=="contentType") {
                        squidLogRecord.contentType=event.text;
                }else if (event.qname.name=="domain"){
                        squidLogRecord.domain=event.text.replace("http://","")
                } else if (event.qname.name=="elapsed") {
                        squidLogRecord.elapsed=Integer.parseInt(event.text);
                }else if (event.qname.name=="method"){
                        squidLogRecord.method=event.text;
                }else if (event.qname.name=="parameters"){
                        squidLogRecord.parameters=event.text;
                } else if (event.qname.name=="peerStatusPeerHost") {
                        squidLogRecord.peerStatusPeerHost=event.text;
                }else if (event.qname.name=="remoteHost"){
                        squidLogRecord.remoteHost=event.text;
                } else if (event.qname.name=="rfc931") {
                        squidLogRecord.rfc931=event.text;
                }
            }else if (event.level==1 and event.type==PullParser.END_ELEMENT){
                //println(squidLogRecord.toString());
                insert squidLogRecord into list;
            }
    }

}
