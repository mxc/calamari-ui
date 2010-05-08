/*
 * TimeSeriesDataPointParser.fx
 *
 * Created on 29-Apr-2010, 08:35:40
 */

package za.co.jumpingbean.calamariui.service;

import javafx.data.pull.Event;
import javafx.data.pull.PullParser;
import za.co.jumpingbean.calamariui.model.TimeSeriesDataPoint;

/**
 * @author mark
 */

public class TimeSeriesDataPointParser extends AbstractParser {

    public-read var list:TimeSeriesDataPoint[];
    var timeSeriesDataPoint:TimeSeriesDataPoint;

    override function onEvent(event:Event){
            if (event.level==1 and event.type==PullParser.START_ELEMENT){
                timeSeriesDataPoint = TimeSeriesDataPoint{};
            }else if (event.level==2 and event.type==PullParser.END_ELEMENT){
                if (event.qname.name=="name") {
                        timeSeriesDataPoint.name = event.text;
                } else if (event.qname.name=="value") {
                        timeSeriesDataPoint.value=Integer.parseInt(event.text);
                }else if (event.qname.name=="date"){
                        timeSeriesDataPoint.date=Utils.timestampFromString(event.text);
                }
            }else if (event.level==1 and event.type==PullParser.END_ELEMENT){
               // println("{timeSeriesDataPoint.name} -- {timeSeriesDataPoint.value} -- {timeSeriesDataPoint.date.toLocaleString()}");
                insert timeSeriesDataPoint into list;
            }
    }
}
