/*
 * LineChartDateData.fx
 *
 * Created on 30-Apr-2010, 23:40:28
 */

package za.co.jumpingbean.calamariui.timeSeriesChartDisplay;

import javafx.scene.chart.LineChart.Data;
import java.sql.Timestamp;
import za.co.jumpingbean.calamariui.service.Utils;

/**
 * @author mark
 */

public class LineChartDateData extends Data {
        public var xDateTimeValue:Timestamp on replace{
                    var tmpDate = Utils.getDateFromTimestamp(xDateTimeValue);
                    //println("liechart--{tmpDate}");
                    xValue=tmpDate.getTime();
                    xDataValue=xValue;
        };

        public var yMeasureValue:Number on replace {
                yValue=yMeasureValue;
                yDataValue=yValue;
        };
       
        
}
