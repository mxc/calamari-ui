/*
 * UIHttpRequest.fx
 *
 * Created on 05 Apr 2010, 9:10:39 PM
 */

package za.co.jumpingbean.calamariui.service;

import javafx.io.http.HttpRequest;
import java.lang.Exception;
import javafx.io.http.HttpHeader;

/**
 * @author mark
 */

public class UIHttpRequest {
    
    public var location:String;
    public var parser:AbstractParser;
    public var onDone: function():Void = null;
    public var onException:function(ex:Exception):Void=null;
    public def request:HttpRequest = HttpRequest{};
    var totalMB:Long=0;

    public function start(){
            request.location=location;
            request.onDone=onDone;
            request.onException=onException;
            request.headers=[
                       // HttpHeader{
                       //         name:HttpHeader.CONTENT_ENCODING
                       //         value:HttpHeader.GZIP
                       // }
                        HttpHeader {
                        name: HttpHeader.CONTENT_TYPE;
                        value: "text/xml";
                        },
                        HttpHeader{
                                name:HttpHeader.ACCEPT_ENCODING
                                value:HttpHeader.GZIP
                        }
            ];
            request.onInput= function(is: java.io.InputStream) {
                 try {
                        parser.parse(is);
                     } finally {
                        is.close();
                    }
             };
             request.onToRead=function(bytes:Long){
                 totalMB=totalMB+(bytes/(1024*1024));

             }

             request.method=HttpRequest.GET;
            request.start();
        }
}
