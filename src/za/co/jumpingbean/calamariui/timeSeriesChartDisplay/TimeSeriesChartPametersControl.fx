/*
 * ChartParametersControl.fx
 *
 * Created on 08-May-2010, 10:21:50
 */

package za.co.jumpingbean.calamariui.timeSeriesChartDisplay;

import javafx.scene.CustomNode;
import javafx.scene.Node;
import javafx.scene.control.Label;
import javafx.scene.control.Button;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.VBox;
import javafx.geometry.HPos;
import javafx.scene.layout.HBox;
import javafx.geometry.VPos;
import za.co.jumpingbean.calamariui.common.ExpandImage;
import javafx.scene.control.TextBox;
import javafx.util.Sequences;

/**
 * @author mark
 */

public class TimeSeriesChartParametersControl extends CustomNode {

       public var display:TimeSeriesChartDisplay;

       def label = Label{
            text:"Username"
      }

      def label2 = Label{
            text:"Domain"
      }

      public  def username= TextBox{
            columns:35
            editable:true
            text:"All"
        }

     public  def domain= TextBox{
            columns:35
            editable:true
            text:"All"
        }

    override protected function create () : Node {
        def btnGetData= Button{
            text:"Get Data"
            onMouseClicked:function(event:MouseEvent){
                    display.startPoller();
            }
        }

       def container=VBox{
            nodeHPos:HPos.CENTER;
            spacing:10
            content:[
                     VBox{

                     content:[
                     HBox{
                            nodeVPos:VPos.CENTER;
                            spacing:10
                            content:[
                                      label,
                                      username,
                                      label2,
                                      domain
                                   ]
                       },
                       btnGetData
                   ]
            }
       ]
       }

       def parent:VBox=VBox {
            nodeHPos:HPos.CENTER;
            spacing:10
            content:[
                      ExpandImage{
                        text:"Chart Parameters"
                        onMouseClicked:function (mouseEvent:MouseEvent){
                        if (Sequences.indexOf(parent.content,container)==-1){
                            mouseEvent.source.rotate=90.0;
                            insert container into parent.content;
                        }else{
                            mouseEvent.source.rotate=0.0;
                            delete container from parent.content;
                        }
                      }
                      }
            ]
        }
    }

}

