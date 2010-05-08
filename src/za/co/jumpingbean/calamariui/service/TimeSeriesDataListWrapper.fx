/*
 * TimeSeriesDataListWrapper.fx
 *
 * Created on 29-Apr-2010, 09:05:31
 */

package za.co.jumpingbean.calamariui.service;

import javafx.scene.chart.LineChart;
import java.sql.Timestamp;
import za.co.jumpingbean.calamariui.timeSeriesChartDisplay.LineChartDateData;


/**
 * @author mark
 */

public class TimeSeriesDataListWrapper extends AbstractWrapper{
        public var list:LineChartDateData[];
        public var minyValue:Number=-999;
        public var maxyValue:Number=-999;
        public var minxValue:Timestamp=null;
        public var maxxValue:Timestamp=null;
        public var name:String;

       override public function reset():Void{
            super.reset();
            //minyValue=-999;
            //maxyValue=-999;
            //minxValue=null;
            //maxxValue=null;
            list=[];
        }
}

