/*
 * ChartDisplay.fx
 *
 * Created on 18 Apr 2010, 10:28:07 AM
 */

package za.co.jumpingbean.calamariui.pieChartDisplay;

import javafx.scene.CustomNode;
import javafx.scene.Node;
import za.co.jumpingbean.calamariui.service.ChartDataListWrapper;
import javafx.scene.layout.VBox;
import javafx.geometry.HPos;
import javafx.scene.layout.Tile;
import javafx.scene.chart.PieChart3D;
import javafx.scene.paint.Color;
import javafx.scene.chart.part.Side;
import za.co.jumpingbean.calamariui.service.Utils;
import java.util.GregorianCalendar;
import javafx.animation.Timeline;
import javafx.animation.KeyFrame;
import za.co.jumpingbean.calamariui.service.DataService;
import javafx.scene.layout.HBox;
import za.co.jumpingbean.calamariui.common.Poller;
import za.co.jumpingbean.calamariui.common.DataLoadingIndicator;
import za.co.jumpingbean.calamariui.common.Logo;
import za.co.jumpingbean.calamariui.common.DateCriteriaControls;
import za.co.jumpingbean.calamariui.common.DisplaySelector;
import javafx.scene.control.Label;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import za.co.jumpingbean.calamariui.Main;
import javafx.scene.control.TextBox;

/**
 * @author mark
 */

public class PieChartDisplayWithParameters extends CustomNode,Poller{

//
def topSitesByHitsForUser = ChartDataListWrapper{};
def topSitesByBytesForUser = ChartDataListWrapper{};
def topUsersOfSiteByHits = ChartDataListWrapper{};
def topUsersOfSiteByBytes=ChartDataListWrapper{};
public var startDate:GregorianCalendar;
public var endDate:GregorianCalendar;



//def scale=1;
def count=10;
var display:VBox;
public var width:Number;
public var height:Number;
var controls:HBox;
var displaySelectorPlacement:VBox; //place to insert display selector
def dataLoadingIndicator=DataLoadingIndicator{};
def service:DataService= DataService{};
var errorLabel:Label;
var pie1:PieChart3D;
var pie2:PieChart3D;
var pie3:PieChart3D;
var pie4:PieChart3D;
var dateControl:DateCriteriaControls;

def pieChartParameters:PieChartParameters=PieChartParameters{display:this};

var username:String =bind pieChartParameters.txtUsername.text;
var domain:String= bind pieChartParameters.txtDomain.text; //on replace{ if (domain==null or domain=="") domain="All"; };


//Determines when we can stop the poller timeline object.
var pollerDone=false on replace oldvalue{
            if (pollerDone==true){
                Main.asyncTaksInProgress=false;//enable getData button
                chartPoller.stop();
                dataLoadingIndicator.stop();
                delete dataLoadingIndicator from displaySelectorPlacement.content;
                println("stoping poller...");
                pie1.title="Top Sites By Hits from {Utils.formatDatePrettyPrint(startDate)} to {Utils.formatDatePrettyPrint(endDate)} for {username}";
                pie2.title="Top Users By Hits from {Utils.formatDatePrettyPrint(startDate)} to {Utils.formatDatePrettyPrint(endDate)} of Site {domain} ";
                pie3.title="Top Sites By MBytes from {Utils.formatDatePrettyPrint(startDate)} to {Utils.formatDatePrettyPrint(endDate)} for {username}";
                pie4.title="Top Users By MBytes from {Utils.formatDatePrettyPrint(startDate)} to {Utils.formatDatePrettyPrint(endDate)} of Site {domain}";
                var errorMessage;
                if (topSitesByHitsForUser.error) errorMessage="Chart 1 : {topSitesByHitsForUser.errorMessage}";
                if (topSitesByBytesForUser.error) errorMessage="{errorMessage} Chart 2 : {topSitesByBytesForUser.errorMessage}";
                if (topUsersOfSiteByHits.error) errorMessage="{errorMessage} Chart 3 : {topUsersOfSiteByHits.errorMessage}";
                if (topUsersOfSiteByBytes.error) errorMessage="{errorMessage} Chart 4 : {topUsersOfSiteByBytes.errorMessage}";
                println("{errorMessage}");
                if (errorMessage.length()>50) errorMessage="{errorMessage.substring(0,50)}...";
                if (errorMessage!=null) insertErrorMessage(errorMessage);
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
                   if (not topSitesByHitsForUser.processing) {service.getTopSitesByHitsForUser(startDate, endDate, count,username, topSitesByHitsForUser); topSitesByHitsForUser.processing=true;}
                   if (not topSitesByBytesForUser.processing){ service.getTopSitesBySizeForUser(startDate, endDate, count,username, topSitesByBytesForUser);  topSitesByBytesForUser.processing=true;}
                   if (not topUsersOfSiteByBytes.processing){ service.getTopUsersBySizeOfSite(startDate, endDate, count,domain, topUsersOfSiteByBytes); topUsersOfSiteByBytes.processing=true;}
                   if (not topUsersOfSiteByHits.processing) {service.getTopUsersByHitsOfSite(startDate, endDate, count,domain, topUsersOfSiteByHits); topUsersOfSiteByHits.processing=true;}
                   if (topSitesByHitsForUser.done and topSitesByBytesForUser.done and topUsersOfSiteByBytes.done and topUsersOfSiteByHits.done) pollerDone = true;
                }
              }
    ]
}

//call this function whenever we need to fetch new Data for the charts. Usually when user pushes the get data button
override public function startPoller(){
                pollerDone=false;
                topSitesByBytesForUser.reset();
                topSitesByHitsForUser.reset();
                topUsersOfSiteByBytes.reset();
                topUsersOfSiteByHits.reset();
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
                                        pieChartParameters

                                ]
                                }
                    ]
                    },
                    Tile{
                          hpos:HPos.LEADING
                          nodeHPos:HPos.CENTER
                          columns: 2
                          rows: 2
                          hgap: 5 //horizontal gap between tiles in a row
                          vgap: 5 // vertical gap between rows of tiles
                          vertical: true //sets the preferred direction
                          content:[
                          pie1 = PieChart3D{
                                    data: bind topSitesByHitsForUser.list;
                                    title:"Top Sites By Hits from {Utils.formatDatePrettyPrint(startDate)} to {Utils.formatDatePrettyPrint(endDate)} for {username}";
                                    pieLabelFill:Color.BLACK;
                                    legendVisible:true;
                                    pieLabelVisible:false;
                                    legendSide:Side.TOP
                                },
                           pie2= PieChart3D{
                                    data: bind topUsersOfSiteByHits.list;
                                    title:"Top Users By Hits from {Utils.formatDatePrettyPrint(startDate)} to {Utils.formatDatePrettyPrint(endDate)} of Site {domain} ";
                                    pieLabelFill:Color.BLACK;
                                    legendVisible:true;
                                    pieLabelVisible:false;
                                    legendSide:Side.TOP
                                },
                            pie3=PieChart3D{
                                    data: bind topSitesByBytesForUser.list;
                                    title:"Top Sites By MBytes from {Utils.formatDatePrettyPrint(startDate)} to {Utils.formatDatePrettyPrint(endDate)} for {username}";
                                    pieLabelFill:Color.BLACK;
                                    pieLabelVisible:false;
                                    legendVisible:true;
                                    legendSide:Side.TOP
                               },
                               pie4=PieChart3D{
                                    data: bind topUsersOfSiteByBytes.list;
                                    title:"Top Users By MBytes from {Utils.formatDatePrettyPrint(startDate)} to {Utils.formatDatePrettyPrint(endDate)} of Site {domain}";
                                    pieLabelFill:Color.BLACK;
                                    legendVisible:true;
                                    pieLabelVisible:false;
                                    legendSide:Side.TOP
                               }
                           ]
                           }
                     ]
               }
             }

}
