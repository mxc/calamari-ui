/*
 * CriteriaControls.fx
 *
 * Created on 11-Apr-2010, 11:56:20
 */

package za.co.jumpingbean.calamariui.common;

import javafx.scene.CustomNode;
import javafx.scene.Node;
import javafx.scene.Group;
import javafx.scene.control.Label;
import javafx.scene.layout.HBox;
import javafx.scene.layout.LayoutInfo;
import java.util.Calendar;
import javafx.scene.layout.VBox;
import javafx.scene.control.Button;
import javafx.geometry.VPos;
import javafx.scene.input.MouseEvent;
import javafx.geometry.HPos;
import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;
import org.jfxtras.scene.layout.XSpacer;
import org.jfxtras.scene.layout.Priority;
import javafx.util.Sequences;
import java.util.GregorianCalendar;
import za.co.jumpingbean.calamariui.Main;


/**
 * @author mark
 */

public class DateCriteriaControls extends CustomNode {

    public var startDate:GregorianCalendar;
    public var endDate:GregorianCalendar;
    public var display:Poller;

override protected function create () : Node {


        var controls = VBox {
            hpos: HPos.LEFT
            spacing:10
            var btnGet:Button;

            nodeHPos:HPos.CENTER
            content:[
                      HBox{
                            spacing:5
                            hpos:HPos.CENTER
                            nodeVPos:VPos.CENTER
                            //width:bind main.chartData.width
                            content:[
                                    Label{text:"Start Date" font:Font.font("Verdana",FontWeight.BOLD,15) vpos:VPos.CENTER},
                                    DatePicker{date: bind startDate with inverse }
                                    Label{text:"End Date" font:Font.font("Verdana",FontWeight.BOLD,15) vpos:VPos.CENTER},
                                    DatePicker{date:bind endDate with inverse}
                                ]
                        },
                        HBox{
                                hpos:HPos.CENTER
                                //nodeVPos:VPos.CENTER
                               // width:bind main.chartData.width
                                content:[
                                   btnGet= Button{
                                        text:"Get Data"
                                        disable:bind Main.asyncTaksInProgress;
                                        onMouseClicked:function(event:MouseEvent){
                                            //endDate = endPicker.date;
                                            //startDate = startPicker.date;
                                            //println("dates udated - {startDate.getTime().toGMTString()} {endDate.getTime().toGMTString()}");
                                            println("starting poller....");
                                            Main.asyncTaksInProgress=true;
                                            display.startPoller();
                                            }
                                    }
                                ]
                        }
                    ]
        }


        var vbox:VBox;//placeholder to enable easy access to content graph

        var group = Group{
                content:[
                         vbox=VBox{
                                nodeHPos:HPos.LEFT
                                spacing:10
                                content: [
                                          ExpandImage{
                                            text:"Change Date Range"
                                            onMouseClicked:function (mouseEvent:MouseEvent){
                                            if (Sequences.indexOf(vbox.content,controls)==-1){ 
                                                mouseEvent.source.rotate=90.0;
                                                insert controls into vbox.content;
                                            }else{
                                                mouseEvent.source.rotate=0.0;
                                                delete controls from vbox.content;
                                            }
                                          }
                                          },
                                        ]
                            }
                     ]
              }
           return group;
    }
}
