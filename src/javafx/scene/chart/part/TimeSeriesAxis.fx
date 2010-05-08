/*
 * TimeSeriesAccess.fx
 *
 * Created on 01-May-2010, 09:04:36
 */

package javafx.scene.chart.part;

import java.sql.Timestamp;
import javafx.util.Sequences;
import javafx.scene.chart.LineChart;
import za.co.jumpingbean.calamariui.service.Utils;
import java.util.GregorianCalendar;
import java.util.Date;
import java.util.Calendar;

static public-read def  HOURS:Number=3600000;//number of miliseconds in an hour
static public-read def  DAYS:Number=86400000;//number miliseconds in a day

public class TimeSeriesAxis extends ValueAxis {

    public-init var tickUnit:Number;
    var range:Calendar[];
    var range2:Float[];//Dont think this is really needed. It in case there are floating point issues


    init{
        lowerBound=0;
        upperBound=0;
        //minorTickCount=24;
        //minorTickVisible=true;
     }

   function getRange():Calendar[]{
        println("Getting range....");
        if (lowerBound>0 and upperBound>0) {
            def startDate:GregorianCalendar = new GregorianCalendar();
            startDate.setTime(Utils.getDateFromTimestamp(earliest));
            def endDate:GregorianCalendar  = new GregorianCalendar();
            endDate.setTime(Utils.getDateFromTimestamp(latest));
            var dates:Calendar[];
            while (startDate.compareTo(endDate)<=0){
                var tmpStartDate:GregorianCalendar = startDate.clone() as GregorianCalendar;
                insert tmpStartDate into dates;
                def float = startDate.getTimeInMillis();
                insert  float into range2;
                println("{Utils.formatDatePrettyLongPrint(startDate)}");
                startDate.add(Calendar.DATE,1);
            }
            return dates;
        }
        var emptySequence:Calendar[]=[];
        return emptySequence;
    }


    //public var data:LineChart.Series;
    public var earliest:Timestamp on replace { this.lowerBound=earliest.getTime(); };
    public var latest:Timestamp on replace {this.upperBound=latest.getTime(); };

    public-read override var lowerBound; //on replace{println("low={lowerBound}"); variable =[lowerBound..this.upperBound step tickUnit] };
    public-read override var upperBound; //on replace{println("upper={upperBound}");variable =[lowerBound..this.upperBound step tickUnit]};



    override bound public function isValueOnAxis (obj : Object) : Boolean {
            return Sequences.indexOf(range2,obj)!=-1;
    }

    override public function getDisplayPosition (obj : Object) : Number {
            //if (obj instanceof Number) return obj as Number
            //else {
            //println ("diplay position class of {obj} is {obj.getClass()}");
            //    return obj as Integer;
           // }
           var float = obj as Float;
           var tickWidth=getDayWidth();
            for (num in range){
                //println("{float} -- {num.getTimeInMillis()}");
               if (float>=num.getTimeInMillis()) {}
               else {
                       def index =  (indexof num);//+((float-(range[num-1]*HOURS))/HOURS);
                       //println("num={num*DAYS} float={float}");
                       //println("postion is {index}");
                       return (index*tickWidth)+((float-num.getTimeInMillis())/HOURS)*(tickWidth/24);
                    }
           }
           //if we hit here then we must be at the end of the sequece
           //i.e the last day. We need to add 23:59 to the date to get it
           //to the end of day!
           
           return (((sizeof range))*tickWidth)+((float-latest.getTime())/HOURS)*(tickWidth/24);
           //return Sequences.indexOf(range,obj as Float);
    }

    function getDayWidth():Float{
       def size = sizeof range;
       if (size==0) return 0 else
       return (this.boundsInParent.width-25)/(sizeof range);
    }


    override protected function updateTickMarks () : Void {
        println("update tick marks...");
        tickMarks=[];//reset tick marks
        range=getRange();
        def tickWidth=getDayWidth();
        for (num in range){
            //var tmpTimestamp:Timestamp = new Timestamp(num);
            //println("update ticks number = {num.get(Calendar.YEAR)} --{num.get(Calendar.MONTH)} -- {num.get(Calendar.DATE)} -- {num.get(Calendar.HOUR)}  -- {num.get(Calendar.MINUTE)} ");
            //println(tmpTimestamp.toGMTString());
            var tickMark=TickMark{
                label:Utils.formatShortDatePrettyPrint(num.getTime());
                position:(indexof num)*tickWidth;
                value:(num.getTimeInMillis());
            }
            insert tickMark into tickMarks;
        }
    }

}
