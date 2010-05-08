/*
 * SquidLogDetail.fx
 *
 * Created on 05 Apr 2010, 8:31:15 PM
 */

package za.co.jumpingbean.calamariui.model;

import java.sql.Timestamp;
import org.jfxtras.lang.XObject;
import java.math.BigDecimal;

/**
 * @author mark
 */

public class SquidLogRecord  extends XObject{
        public var serverInfo:String;
        public var accessDate:Timestamp;
        public var elapsed:Integer;
        public var remoteHost:String;
        public var codeStatus:String;
        public var method:String;
        public var parameters:String;
        public var rfc931:String;
        public var peerStatusPeerHost:String;
        public var contentType:String;
        public var domain:String;
        public var bytes:Integer;
        public var hits:Integer=1;
        public var bytesKB:BigDecimal;

        override function toString():String{
            return "doamin:{domain},user:{rfc931},bytes:{bytes},serverInfo:{serverInfo},accessDate:{accessDate},elapsed:{elapsed},remoteHost:{remoteHost},codeStauts:{codeStatus},method:{method},parameters:{parameters},peerStatus:{peerStatusPeerHost},contentType:{contentType}";
        }

}
