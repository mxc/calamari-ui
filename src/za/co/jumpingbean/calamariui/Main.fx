/*
 * Main.fx
 *  http://www.jumpingbean.co.za
 * Created on 04 Apr 2010, 12:33:49 PM
 */

package za.co.jumpingbean.calamariui;

import javafx.stage.Stage;
import javafx.scene.Scene;
import java.util.GregorianCalendar;
import javafx.scene.paint.LinearGradient;
import javafx.scene.paint.Stop;
import javafx.scene.paint.Color;
import za.co.jumpingbean.calamariui.pieChartDisplay.PieChartDisplay;
import za.co.jumpingbean.calamariui.tabularDisplay.TabularDisplay;
import za.co.jumpingbean.calamariui.adminDisplay.AdminDisplay;
import za.co.jumpingbean.calamariui.common.DisplaySelector;
import za.co.jumpingbean.calamariui.service.Utils;
import za.co.jumpingbean.calamariui.timeSeriesChartDisplay.TimeSeriesChartDisplay;
import za.co.jumpingbean.calamariui.pieChartDisplay.PieChartDisplayWithParameters;

/**
 * @author mark
 */


var endDate:GregorianCalendar=Utils.getCurrentDate();
var startDate:GregorianCalendar=Utils.getFirstDayOfMonth(endDate);
var scene:Scene;

static public var asyncTaksInProgress:Boolean;

//Our eye candy gradient fill
def gradientFill:LinearGradient =  LinearGradient {
            startX: 0
            startY: 0
            endX: 1
            endY: 1
            stops: [
                       Stop {
                               offset: 0.0
                               color: Color.CORNFLOWERBLUE;
                       }

                       Stop{
                               offset: 1.0
                               color: Color.ALICEBLUE;
                       }
                    ]
 }


//Build our Pie Chart Scene
def chartControl = PieChartDisplay{
    startDate: startDate;
    endDate:endDate;
    width:bind scene.width
    height:bind scene.height
}

def chartControlWithParameters=PieChartDisplayWithParameters{
     startDate: startDate;
    endDate:endDate;
    width:bind scene.width
    height:bind scene.height
}


def tabularControl = TabularDisplay{
    startDate:startDate
    endDate:endDate
    width:bind scene.width
    height:bind scene.height
}

def displaySelector=DisplaySelector{default:DisplaySelector.chartDisplay}

def adminControl = AdminDisplay{
    width:bind scene.width
    height:bind scene.height
}

def  timeSeriesChartDisplay = TimeSeriesChartDisplay{
    startDate:startDate
    endDate:endDate
    width:bind scene.width
    height:bind scene.height
}


//Use this function to hide/show panels
public function showTabularDisplay(reportType:String,parameter:String,parameter2:String,startDate:GregorianCalendar,endDate:GregorianCalendar,flag:Boolean){
    //var runFlag:Boolean=flag;
    if (startDate!=null) tabularControl.startDate=startDate;
    if (endDate!=null) tabularControl.endDate=endDate;
    tabularControl.reportType=reportType;
    tabularControl.reportParameter=parameter;
    tabularControl.reportParameter2=parameter2;
//    if (tabularControl.reportType!=reportType) {
//            tabularControl.reportType=reportType;
//            runFlag=true;
//    }
//    if (tabularControl.reportParameter!=parameter){
//           tabularControl.reportParameter=parameter;
//           runFlag=true;
//    }
    chartControl.removeDisplaySelector(displaySelector);
    adminControl.removeDisplaySelector(displaySelector);
    timeSeriesChartDisplay.removeDisplaySelector(displaySelector);
    chartControlWithParameters.removeDisplaySelector(displaySelector);
    tabularControl.insertDisplaySelector(displaySelector);
    delete chartControl from scene.content;
    delete adminControl from scene.content;
    delete timeSeriesChartDisplay from scene.content;
    delete chartControlWithParameters from scene.content;
    insert tabularControl into scene.content;
    if (flag) tabularControl.startPoller();
}

//Use this function to hide/show panels
public function showChartDisplay(){
    adminControl.removeDisplaySelector(displaySelector);
    tabularControl.removeDisplaySelector(displaySelector);
    timeSeriesChartDisplay.removeDisplaySelector(displaySelector);
    chartControlWithParameters.removeDisplaySelector(displaySelector);
    chartControl.insertDisplaySelector(displaySelector);
    delete tabularControl from scene.content;
    delete adminControl from scene.content;
    delete timeSeriesChartDisplay from scene.content;
    delete chartControlWithParameters from scene.content;
    insert chartControl into scene.content;
}

public function showAdminDisplay(){
    tabularControl.removeDisplaySelector(displaySelector);
    chartControl.removeDisplaySelector(displaySelector);
    timeSeriesChartDisplay.removeDisplaySelector(displaySelector);
    chartControlWithParameters.removeDisplaySelector(displaySelector);
    adminControl.insertDisplaySelector(displaySelector);
    adminControl.getAdminInfo();
    delete tabularControl from scene.content;
    delete chartControl from scene.content;
    delete timeSeriesChartDisplay from scene.content;
    delete chartControlWithParameters from scene.content;
    insert adminControl into scene.content;
}

public function showTimeSeriesChartDisplay(){
    tabularControl.removeDisplaySelector(displaySelector);
    chartControl.removeDisplaySelector(displaySelector);
    adminControl.removeDisplaySelector(displaySelector);
    chartControlWithParameters.removeDisplaySelector(displaySelector);
    timeSeriesChartDisplay.insertDisplaySelector(displaySelector);
    delete tabularControl from scene.content;
    delete chartControl from scene.content;
    delete adminControl from scene.content;
    delete chartControlWithParameters from scene.content;
    insert timeSeriesChartDisplay into scene.content;
    //timeSeriesChartDisplay.startPoller();
}

public function showChartWithParametersDisplay(){
    tabularControl.removeDisplaySelector(displaySelector);
    chartControl.removeDisplaySelector(displaySelector);
    adminControl.removeDisplaySelector(displaySelector);
    timeSeriesChartDisplay.removeDisplaySelector(displaySelector);
    chartControlWithParameters.insertDisplaySelector(displaySelector);
    delete tabularControl from scene.content;
    delete chartControl from scene.content;
    delete adminControl from scene.content;
    delete timeSeriesChartDisplay from scene.content;
    insert chartControlWithParameters into scene.content;
    //timeSeriesChartDisplay.startPoller();

}



function run(){
    chartControl.insertDisplaySelector(displaySelector);//insert the display selector on startup
Stage {
    title: "Calamari - Yummy Squid"
    scene: scene = Scene {
        fill:gradientFill
        content: [
                    chartControl
                 ]
         }
    }
chartControl.startPoller();
}














