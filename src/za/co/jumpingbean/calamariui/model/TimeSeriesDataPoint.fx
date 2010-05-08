/*
 * TimeSeriesDataPoint.fx
 *
 * Created on 29-Apr-2010, 08:36:25
 */

package za.co.jumpingbean.calamariui.model;

import java.sql.Timestamp;

/**
 * @author mark
 */

public class TimeSeriesDataPoint {
        public var date:Timestamp;
        public var value:Integer;
        public var name:String;

        override function toString():String{
            return "name:{name},date:{date},value:{value}";
        }

}
