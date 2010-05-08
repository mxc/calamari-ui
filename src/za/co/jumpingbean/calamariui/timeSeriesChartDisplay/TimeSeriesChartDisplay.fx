/*
 * TimeSeriesChartDisplay.fx
 *
 * Created on 28-Apr-2010, 20:48:28
 */
package za.co.jumpingbean.calamariui.timeSeriesChartDisplay;

import java.util.GregorianCalendar;
import javafx.scene.CustomNode;
import za.co.jumpingbean.calamariui.common.Poller;
import javafx.scene.Node;
import za.co.jumpingbean.calamariui.Main;
import za.co.jumpingbean.calamariui.common.DataLoadingIndicator;
import javafx.scene.chart.LineChart;
import za.co.jumpingbean.calamariui.service.Utils;
import javafx.animation.Timeline;
import javafx.animation.KeyFrame;
import za.co.jumpingbean.calamariui.service.DataService;
import za.co.jumpingbean.calamariui.common.DisplaySelector;
import javafx.scene.control.Label;
import javafx.scene.paint.Color;
import javafx.scene.text.Font;
import za.co.jumpingbean.calamariui.service.TimeSeriesDataListWrapper;
import javafx.scene.layout.VBox;
import javafx.geometry.HPos;
import javafx.scene.layout.HBox;
import javafx.scene.text.FontWeight;
import za.co.jumpingbean.calamariui.common.Logo;
import za.co.jumpingbean.calamariui.common.DateCriteriaControls;
import javafx.scene.layout.Tile;
import java.sql.Timestamp;
import javafx.scene.chart.part.Side;
import javafx.scene.chart.part.TimeSeriesAxis;
import javafx.scene.chart.part.NumberAxis;
import javafx.geometry.VPos;
import javafx.scene.control.ScrollBar;
import javafx.scene.Group;
import javafx.scene.control.TextBox;
import za.co.jumpingbean.calamariui.timeSeriesChartDisplay.TimeSeriesChartPametersControl.TimeSeriesChartParametersControl;


/**
 * @author mark
 */

public class TimeSeriesChartDisplay extends CustomNode,Poller{

    def dataLoadingIndicator=DataLoadingIndicator{};
    var domainHitsTimeSeriesByHour = TimeSeriesDataListWrapper{};
    def userHitsTimeSeriesByHour = TimeSeriesDataListWrapper{};
    def domainHitsTimeSeriesByDay = TimeSeriesDataListWrapper{};
    def userHitsTimeSeriesByDay = TimeSeriesDataListWrapper{};

    var domainBytesTimeSeriesByHour = TimeSeriesDataListWrapper{};
    def userBytesTimeSeriesByHour = TimeSeriesDataListWrapper{};
    def domainBytesTimeSeriesByDay = TimeSeriesDataListWrapper{};
    def userBytesTimeSeriesByDay = TimeSeriesDataListWrapper{};

    var domainHitsSeriesChartDataByHour:LineChart.Series on replace oldvalue { delete oldvalue from domainByHour; insert domainHitsSeriesChartDataByHour into domainByHour; };
    var userHitsSeriesChartDataByHour:LineChart.Series on replace oldvalue { delete oldvalue from userByHour; insert userHitsSeriesChartDataByHour into userByHour; };
    var domainHitsSeriesChartDataByDay:LineChart.Series on replace oldvalue { delete oldvalue from domainByDay; insert domainHitsSeriesChartDataByDay into domainByDay; };
    var userHitsSeriesChartDataByDay:LineChart.Series on replace oldvalue { delete oldvalue from userByDay; insert userHitsSeriesChartDataByDay into userByDay; };
    var domainBytesSeriesChartDataByHour:LineChart.Series on replace oldvalue { delete oldvalue from domainByHour; insert domainBytesSeriesChartDataByHour into domainByHour; };
    var userBytesSeriesChartDataByHour:LineChart.Series on replace oldvalue { delete oldvalue from userByHour; insert userBytesSeriesChartDataByHour into userByHour; };
    var domainBytesSeriesChartDataByDay:LineChart.Series  on replace oldvalue { delete oldvalue from domainByDay; insert domainBytesSeriesChartDataByDay into domainByDay; };
    var userBytesSeriesChartDataByDay:LineChart.Series  on replace oldvalue { delete oldvalue from userByDay; insert userBytesSeriesChartDataByDay into userByDay; };

    //variable to hold DataSeries
    var domainByDay:LineChart.Series[]=[domainHitsSeriesChartDataByDay,domainBytesSeriesChartDataByDay];
    var domainByHour:LineChart.Series[]=[domainHitsSeriesChartDataByHour,domainBytesSeriesChartDataByHour];
    var userByDay:LineChart.Series[]=[userHitsSeriesChartDataByDay,domainBytesSeriesChartDataByDay];
    var userByHour:LineChart.Series[]=[userHitsSeriesChartDataByHour,userBytesSeriesChartDataByHour];



    public var startDate:GregorianCalendar;
    public var endDate:GregorianCalendar;
    def service:DataService=DataService{};

    var errorLabel:Label;
    var chart1:LineChart;
    var chart2:LineChart;
    var chart3:LineChart;
    var chart4:LineChart;
    var display:VBox;
    var controls:HBox;
    var displaySelectorPlacement:VBox;
    public var width:Number;
    public var height:Number;
    var dateControl:DateCriteriaControls;


    //Determines when we can stop the poller timeline object.
    var pollerDone=false on replace oldvalue{
                if (pollerDone==true){
                    Main.asyncTaksInProgress=false;//enable getData button
                    chartPoller.stop();
                    dataLoadingIndicator.stop();
                    delete dataLoadingIndicator from displaySelectorPlacement.content;
                    println("stoping poller...");
                    chart1.title="{domainHitsTimeSeriesByHour.name} By Hour From {Utils.formatDatePrettyPrint(startDate)} To {Utils.formatDatePrettyPrint(endDate)}";
                    chart2.title="{userHitsTimeSeriesByDay.name} By Day From {Utils.formatDatePrettyPrint(startDate)} To {Utils.formatDatePrettyPrint(endDate)}";
                    chart3.title="{userHitsTimeSeriesByHour.name} By Hour From {Utils.formatDatePrettyPrint(startDate)} To {Utils.formatDatePrettyPrint(endDate)}";
                    chart4.title="{domainHitsTimeSeriesByDay.name} By Day From {Utils.formatDatePrettyPrint(startDate)} to {Utils.formatDatePrettyPrint(endDate)}";

                    var errorMessage;
                    if (domainHitsTimeSeriesByHour.error) errorMessage="Chart 1 : {domainHitsTimeSeriesByHour.errorMessage}";
                    if (userHitsTimeSeriesByDay.error) errorMessage="{errorMessage} Chart 2 : {userHitsTimeSeriesByDay.errorMessage}";
                    if (userHitsTimeSeriesByHour.error) errorMessage="{errorMessage} Chart 3 : {userHitsTimeSeriesByHour.errorMessage}";
                    if (domainHitsTimeSeriesByDay.error) errorMessage="{errorMessage} Chart 4 : {domainHitsTimeSeriesByDay.errorMessage}";
                    if (domainBytesTimeSeriesByHour.error) errorMessage="Chart 1 : {domainBytesTimeSeriesByHour.errorMessage}";
                    if (userBytesTimeSeriesByDay.error) errorMessage="{errorMessage} Chart 2 : {userBytesTimeSeriesByDay.errorMessage}";
                    if (userBytesTimeSeriesByHour.error) errorMessage="{errorMessage} Chart 3 : {userBytesTimeSeriesByHour.errorMessage}";
                    if (domainBytesTimeSeriesByDay.error) errorMessage="{errorMessage} Chart 4 : {domainBytesTimeSeriesByDay.errorMessage}";

                    println("{errorMessage}");
                    if (errorMessage.length()>50) errorMessage="{errorMessage.substring(0,50)}...";
                    if (errorMessage!=null) insertErrorMessage(errorMessage)else{
                        domainHitsSeriesChartDataByHour = LineChart.Series{ data:[ domainHitsTimeSeriesByHour.list] name:"Hits"};
                        userHitsSeriesChartDataByHour=LineChart.Series{ data:[ userHitsTimeSeriesByHour.list] name:"Hits"}
                        domainHitsSeriesChartDataByDay = LineChart.Series{ data:[ domainHitsTimeSeriesByDay.list] name:"Hits"};
                        userHitsSeriesChartDataByDay=LineChart.Series{ data:[ userHitsTimeSeriesByDay.list] name:"Hits"}

                        domainBytesSeriesChartDataByHour = LineChart.Series{ data:[ domainBytesTimeSeriesByHour.list] name:"Bytes"};
                        userBytesSeriesChartDataByHour=LineChart.Series{ data:[ userBytesTimeSeriesByHour.list] name:"Bytes"}
                        domainBytesSeriesChartDataByDay = LineChart.Series{ data:[ domainBytesTimeSeriesByDay.list] name:"Bytes"};
                        userBytesSeriesChartDataByDay=LineChart.Series{ data:[ userBytesTimeSeriesByDay.list] name:"Bytes"}

                    }
                }
         };

    //This code will poll the web service every 10s until a result is received
    //To start the poller again the pollerDone variable must be set to false
    // and the poller play() function called.
    def chartPoller = Timeline{
        repeatCount: Timeline.INDEFINITE
        keyFrames: [
          KeyFrame{
                    time: 1s
                    canSkip:true;
                    action: function(){
                       println("polling ....");
                       if (not domainHitsTimeSeriesByHour.processing) {service.getDomainHitsTimeSeriesDataByHour(startDate, endDate,domainHitsTimeSeriesByHour,parameters.domain.text); domainHitsTimeSeriesByHour.processing=true;}
                       if (not userHitsTimeSeriesByHour.processing){ service.getUserHitsTimeSeriesDataByHour(startDate, endDate,userHitsTimeSeriesByHour,parameters.username.text);  userHitsTimeSeriesByHour.processing=true;}
                       if (not domainHitsTimeSeriesByDay.processing) {service.getDomainHitsTimeSeriesDataByDay(startDate, endDate,domainHitsTimeSeriesByDay,parameters.domain.text); domainHitsTimeSeriesByDay.processing=true;}
                       if (not userHitsTimeSeriesByDay.processing){ service.getUserHitsTimeSeriesDataByDay(startDate, endDate, userHitsTimeSeriesByDay,parameters.username.text);  userHitsTimeSeriesByDay.processing=true;}

                       if (not domainBytesTimeSeriesByHour.processing) {service.getDomainSizeTimeSeriesDataByHour(startDate, endDate,domainBytesTimeSeriesByHour,parameters.domain.text); domainBytesTimeSeriesByHour.processing=true;}
                       if (not userBytesTimeSeriesByHour.processing){ service.getUserSizeTimeSeriesDataByHour(startDate, endDate,userBytesTimeSeriesByHour,parameters.username.text);  userBytesTimeSeriesByHour.processing=true;}
                       if (not domainBytesTimeSeriesByDay.processing) {service.getDomainSizeTimeSeriesDataByDay(startDate, endDate,domainBytesTimeSeriesByDay,parameters.domain.text); domainBytesTimeSeriesByDay.processing=true;}
                       if (not userBytesTimeSeriesByDay.processing){ service.getUserSizeTimeSeriesDataByDay(startDate, endDate, userBytesTimeSeriesByDay,parameters.username.text);  userBytesTimeSeriesByDay.processing=true;}
                       if (domainHitsTimeSeriesByHour.done and userHitsTimeSeriesByHour.done and domainHitsTimeSeriesByDay.done and userHitsTimeSeriesByDay.done and domainBytesTimeSeriesByHour.done and userBytesTimeSeriesByHour.done and domainBytesTimeSeriesByDay.done and userBytesTimeSeriesByDay.done) pollerDone = true;
                    }
                  }
        ]
    }

    var charts:VBox;
    var parameters:TimeSeriesChartParametersControl;

    def scrollbar = ScrollBar {
            translateX: bind this.width- 600
            translateY: 300
            height: this.height
            blockIncrement: 50
            clickToPosition: true
            min: 0
            max: bind charts.height
            vertical: true
        };


    //call this function whenever we need to fetch new Data for the charts. Usually when user pushes the get data button
    override public function startPoller(){
                    pollerDone=false;
                    domainHitsTimeSeriesByHour.reset();
                    userHitsTimeSeriesByHour.reset();
                    domainHitsTimeSeriesByDay.reset();
                    userHitsTimeSeriesByDay.reset();

                    domainBytesTimeSeriesByHour.reset();
                    userBytesTimeSeriesByHour.reset();
                    domainBytesTimeSeriesByDay.reset();
                    userBytesTimeSeriesByDay.reset();

                    removeErrorMessage();
                    dataLoadingIndicator.start();
                    insert dataLoadingIndicator after displaySelectorPlacement.content[1];
                    chartPoller.play();
    }

    function insertErrorMessage(message:String){
        errorLabel=Label{text:message textFill:Color.RED font:Font.font("Verdana",FontWeight.BOLD,15)};
        insert errorLabel after displaySelectorPlacement.content[1];
    }

    function removeErrorMessage(){
        delete errorLabel from displaySelectorPlacement.content
    }


    public function insertDisplaySelector(displaySelector:DisplaySelector){
        insert displaySelector after displaySelectorPlacement.content[1]
    }

    public function removeDisplaySelector(displaySelector:DisplaySelector){
        delete displaySelector from displaySelectorPlacement.content
    }


    override protected function create () : Node {
        display = VBox{
                nodeHPos:HPos.CENTER
                spacing:30
                width:bind width
                height: bind height-controls.height-150
                content:[
                controls = HBox{
                      spacing:20
                     content: [
                                Logo{},
                                displaySelectorPlacement =VBox{
                                    nodeHPos:HPos.CENTER
                                    spacing:10
                                    content:[
                                       dateControl= DateCriteriaControls{
                                            startDate: bind startDate with inverse
                                            endDate: bind endDate with inverse
                                            display:this
                                      },
                                     parameters= TimeSeriesChartParametersControl{
                                           display:this;
                                     }
                                ]
                                }
                    ]
                    },
            scrollbar,
            charts =VBox{
                     //nodeVPos:VPos.TOP
                     nodeHPos:HPos.LEFT
                     translateX:100 //For some reason graphs offset to left
                     width:bind width-50
                     layoutY:-150
                     translateY:bind -(scrollbar.value+scrollbar.height)
                     spacing:20
                     content:[
//                       Tile{
//                          width:bind width
//                          hpos:HPos.CENTER
//                          nodeHPos:HPos.CENTER
//                          columns: 1
//                          rows: 4
//                          hgap: 5 //horizontal gap between tiles in a row
//                          vgap: 5 // vertical gap between rows of tiles
//                          vertical: true //sets the preferred direction
//                          content:[
                          chart1 = LineChart{
                                    data:bind domainByHour;
                                    width:bind width-160;
                                    title:"{domainHitsTimeSeriesByHour.name} By Hour From {Utils.formatDatePrettyPrint(startDate)} To {Utils.formatDatePrettyPrint(endDate)}";
                                    legendVisible:true;
                                    legendSide:Side.TOP
                                    showSymbols:true;
                                    titleFill:Color.BLACK;
                                    titleFont:Font{size:14 name: "Arial Bold" };
                                   xAxis: TimeSeriesAxis {
                                       tickUnit:TimeSeriesAxis.HOURS
                                       label: "Date"
                                       earliest: bind minDate(domainHitsTimeSeriesByHour.minxValue,domainBytesTimeSeriesByHour.minxValue)
                                       latest: bind maxDate(domainHitsTimeSeriesByHour.maxxValue,domainBytesTimeSeriesByHour.maxxValue)
                                       formatTickLabel:function(num:Number):String{
                                           Utils.formatDatePrettyPrint(new Timestamp(num));
                                       }
                                   }
                                   yAxis: NumberAxisEx{
                                           label: "Hits/KiloBytes"
                                           axisHeight:bind chart1.height;
                                           lowerBound: bind min(domainHitsTimeSeriesByHour.minyValue,domainBytesTimeSeriesByHour.minyValue)
                                           upperBound: bind max(domainHitsTimeSeriesByHour.maxyValue,domainBytesTimeSeriesByHour.maxyValue)
                                       }
                                },
                           chart2 = LineChart{
                                    data: bind userByDay;
                                    title:"{userHitsTimeSeriesByDay.name} By Day From {Utils.formatDatePrettyPrint(startDate)} To {Utils.formatDatePrettyPrint(endDate)}";
                                    width:bind width-160;
                                    legendVisible:true;
                                    legendSide:Side.TOP
                                    showSymbols:true;
                                    titleFill:Color.BLACK;
                                    titleFont:Font{size:14 name: "Arial Bold"};

                                   xAxis: TimeSeriesAxis {
                                       tickUnit:TimeSeriesAxis.HOURS
                                       label: "Date"
                                       //maxWidth:bind (width/2)-5
                                       //data:bind domainSeriesChartData
                                       earliest: bind minDate(userHitsTimeSeriesByDay.minxValue,userBytesTimeSeriesByDay.minxValue)
                                       latest: bind minDate(userHitsTimeSeriesByDay.maxxValue,userBytesTimeSeriesByDay.maxxValue)
                                       formatTickLabel:function(num:Number):String{
                                           Utils.formatDatePrettyPrint(new Timestamp(num));
                                       }
                                   }
                                   yAxis: NumberAxisEx{
                                           label: "Hits/KiloBytes"
                                           axisHeight:bind chart2.height;
                                           lowerBound: bind min(userHitsTimeSeriesByDay.minyValue,userBytesTimeSeriesByDay.minyValue)
                                           upperBound: bind max(userHitsTimeSeriesByDay.maxyValue,userBytesTimeSeriesByDay.maxyValue)
                                   }
                                 },
                           chart3 = LineChart{
                                    data: bind userByHour;
                                    title:"{userHitsTimeSeriesByHour.name} By Hour From {Utils.formatDatePrettyPrint(startDate)} To {Utils.formatDatePrettyPrint(endDate)}";
                                    width:bind width-160;
                                    legendVisible:true;
                                    legendSide:Side.TOP
                                    showSymbols:true;
                                    titleFill:Color.BLACK;
                                    titleFont:Font{size:14 name: "Arial Bold"};

                                   xAxis: TimeSeriesAxis {
                                       tickUnit:TimeSeriesAxis.HOURS
                                       label: "Date"
                                       //maxWidth:bind (width/2)-5
                                       //data:bind domainSeriesChartData
                                       earliest: bind minDate(userHitsTimeSeriesByHour.minxValue,userBytesTimeSeriesByHour.minxValue)
                                       latest:  bind maxDate(userHitsTimeSeriesByHour.maxxValue,userBytesTimeSeriesByHour.maxxValue)
                                       formatTickLabel:function(num:Number):String{
                                           Utils.formatDatePrettyPrint(new Timestamp(num));
                                       }
                                   }
                                   yAxis: NumberAxisEx{
                                           axisHeight:bind chart3.height;
                                           label: "Hits/KiloBytes"
                                           lowerBound: bind min(userHitsTimeSeriesByHour.minyValue,userBytesTimeSeriesByHour.minyValue)
                                           upperBound: bind max(userHitsTimeSeriesByHour.maxyValue,userBytesTimeSeriesByHour.maxyValue)
                                   }                                
                                 },
                          chart4 = LineChart{
                                    data:bind domainByDay
                                    width:bind width-160;
                                    title:"{domainHitsTimeSeriesByDay.name} By Day {Utils.formatDatePrettyPrint(startDate)} to {Utils.formatDatePrettyPrint(endDate)}";
                                    legendVisible:true;
                                    legendSide:Side.TOP
                                    showSymbols:true;
                                    titleFill:Color.BLACK;
                                    titleFont:Font{size:14 name: "Arial Bold"};

                                   xAxis: TimeSeriesAxis {
                                       tickUnit:TimeSeriesAxis.HOURS
                                       label: "Date"
                                       earliest: bind minDate(domainBytesTimeSeriesByDay.minxValue,domainHitsTimeSeriesByDay.minxValue)
                                       latest: bind maxDate(domainBytesTimeSeriesByDay.maxxValue,domainHitsTimeSeriesByDay.maxxValue)
                                       formatTickLabel:function(num:Number):String{
                                           Utils.formatDatePrettyPrint(new Timestamp(num));
                                       }
                                   }
                                   yAxis: NumberAxisEx{
                                           axisHeight:bind chart4.height;
                                           label: "Hits/KiloBytes"
                                           lowerBound: bind min(domainHitsTimeSeriesByDay.minyValue,domainBytesTimeSeriesByDay.minyValue)
                                           upperBound: bind max(domainHitsTimeSeriesByDay.maxyValue,domainBytesTimeSeriesByDay.maxyValue)
                                       }
                                }
                            //]
                           //}
                           ]
                           }
                     ]
               }
             }

            bound function minDate(series1:Timestamp,series2:Timestamp):Timestamp{
                   return minDate2(series1,series2);
               }

            function minDate2(series1:Timestamp,series2:Timestamp):Timestamp{
                       if (series1.getTime()<series2.getTime()){
                           return series1;
                       }else{
                           return series2;
                       }
            }


            bound function maxDate(series1:Timestamp,series2:Timestamp):Timestamp{
                       return maxDate2(series1,series2);
               }

             function maxDate2(series1:Timestamp,series2:Timestamp):Timestamp{
                       if (series1.getTime()< series2.getTime()){
                           return series1;
                       }else{
                           return series2;
                       }
             }


           bound function min(num1:Number,num2:Number):Number{
                return min2(num1,num2)
           }

           function min2(num1:Number,num2:Number):Number{
                   if (num1>num2) {
                        return num2
                   } else {
                      return num1;
                   }
           }

           function max2(num1:Number,num2:Number):Number{
                   if (num1>num2) {
                        return num1
                   } else {
                       return num2;
                   }
           }


           bound function max(num1:Number,num2:Number):Number{
                return max2(num1,num2);
            }

}
