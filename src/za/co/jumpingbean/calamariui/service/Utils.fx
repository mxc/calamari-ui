/*
 * Utils.fx
 *
 * Created on 07 Apr 2010, 8:48:51 PM
 */

package za.co.jumpingbean.calamariui.service;

import java.text.SimpleDateFormat;
import java.util.GregorianCalendar;
import java.sql.Timestamp;
import java.lang.StringBuilder;
import java.util.Date;
import java.util.Calendar;
import java.lang.Exception;

/**
 * @author mark
 */

public static function timestampFromString(date:String):Timestamp{


        /*var tmpDate:String;
        if ( input.endsWith( "Z" ) ) {
            tmpDate = input.substring( 0, input.length() - 1);
            tmpDate = "{tmpDate}GMT-00:00";
        } else {
            var inset:Integer = 6;
            var string1 =input.substring( 0, input.length() - inset );
            var string2 = input.substring( input.length() - inset, input.length() );
            tmpDate = "{string1}GMT{string2}";
        }*/
        //println(date);
        var lastIndex=date.lastIndexOf(":");
        var tmpDate =date.substring(0,lastIndex);
        tmpDate+=date.substring(lastIndex+1,date.length());
        //if (date.lastIndexOf('.')>0){
        //    tmpDate = date.substring(0,date.lastIndexOf('.'));
        //}else if (date.lastIndexOf('+')>0){
        //    tmpDate = date.substring(0,date.lastIndexOf('+'));
        //}
        var tmpDate2;
        try{
            var format:SimpleDateFormat = new SimpleDateFormat( "yyyy-MM-dd'T'HH:mm:ssZ");
            tmpDate2 = format.parse(tmpDate);
         } catch(ex:Exception){
            tmpDate = tmpDate.replace(".",":");
            var format:SimpleDateFormat = new SimpleDateFormat( "yyyy-MM-dd'T'HH:mm:ss:SSSZ");
            tmpDate2 = format.parse(tmpDate);
        }

        def timestamp = new Timestamp(tmpDate2.getTime());
        timestamp.setNanos(0);
        return timestamp;
}



public static function formatDate(date:GregorianCalendar):String{
   var format:SimpleDateFormat = new SimpleDateFormat("yyyyMMdd");
   format.format(date.getTime());
}

public static function getFirstDayOfMonth(date:GregorianCalendar){
    var tmpDate = date.clone() as GregorianCalendar;
    tmpDate.set(Calendar.DATE,1);
    return tmpDate;
}

public static function getCurrentDate():GregorianCalendar{
    return new GregorianCalendar();
}

public static function formatDatePrettyLongPrint(date:GregorianCalendar):String{
   var format:SimpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
   format.format(date.getTime());
}

public static function formatDatePrettyLongPrint(timestamp:Timestamp):String{
   var format:SimpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
   format.format(timestamp);
}




public static function formatDatePrettyPrint(date:GregorianCalendar):String{
   var format:SimpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
   format.format(date.getTime());
}

public static function formatDatePrettyPrint(date:Date):String{
   var format:SimpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
   format.format(date);
}

public static function formatDatePrettyPrint(timestamp:Timestamp):String{
   var format:SimpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
   format.format(timestamp.getTime());
}

// Taken from jfxtra and modified.

public static function toClassCamelCase(s:String){
    if (s.length() == 0) return s;
    def chars = s.toCharArray();
    def result = StringBuilder{};
    var capNextChar = false;
    var counter:Integer=0;
    for (char in chars) {
        if (counter==0 and Character.isLetter(char)) {
           result.append(char.toLowerCase(char));
        } else if (Character.isLetter(char) and capNextChar) {
            result.append(Character.toUpperCase(char));
            capNextChar = false;
        } else if (char == 0x20 /* ' ' */ or char == 0x3A /* ':' */ or char == 0x5F /* '_' */ or char == 0x2F /* '/' */) {
            if (indexof char > 0) {
                capNextChar = true;
            }
        } else {
            result.append(char);
            capNextChar = false;
        }
        counter++;
    }
    return result.toString();
}

public static function getDateFromTimestamp(timestamp:Timestamp):Date{
    var ms:Long = timestamp.getTime(); //+ (timestamp.getNanos() / 1000000);
    var cal:GregorianCalendar = new GregorianCalendar();
    cal.setTimeInMillis(ms);
    return cal.getTime();
}

//Getting tired of all this date stuff
public static function toDate(date:String):Date{
         var format:SimpleDateFormat = new SimpleDateFormat( "yyyy-MM-dd HH:mm:ss");
         return format.parse(date);
}

public static function formatShortDatePrettyPrint(date:Date):String{
   var format:SimpleDateFormat = new SimpleDateFormat("MMM-dd");
   format.format(date);
}

public static function formatShortDatePrettyPrint(timestamp:Timestamp):String{
   var format:SimpleDateFormat = new SimpleDateFormat("MMM-dd");
   format.format(getDateFromTimestamp(timestamp));
}


