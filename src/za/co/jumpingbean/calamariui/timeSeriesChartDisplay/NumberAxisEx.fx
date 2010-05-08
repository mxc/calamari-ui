/*
 * NumberAxisEx.fx
 *
 * Created on 08-May-2010, 11:55:11
 */

package za.co.jumpingbean.calamariui.timeSeriesChartDisplay;

import javafx.scene.chart.part.NumberAxis;
import javafx.util.Math;

/**
 * @author mark
 */

public class NumberAxisEx extends NumberAxis {
        public var axisHeight:Number;
        override public var lowerBound on replace{this.tickUnit=Math.round(((upperBound-lowerBound)/(axisHeight/20))/10)*10 as Long};
        override public var upperBound on replace{this.tickUnit=Math.round(((upperBound-lowerBound)/(axisHeight/20))/10)*10 as Long};
        override public var tickUnit on replace {println("tickunit is {tickUnit}");}
}
