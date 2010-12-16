/*
 * PieChartParameters.fx
 *
 * Created on 11-May-2010, 22:31:36
 */

package za.co.jumpingbean.calamariui.pieChartDisplay;

import javafx.scene.CustomNode;
import javafx.scene.Node;
import javafx.scene.control.Label;
import javafx.scene.control.TextBox;
import javafx.scene.control.Button;
import za.co.jumpingbean.calamariui.Main;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.VBox;
import javafx.geometry.HPos;
import javafx.scene.layout.HBox;
import javafx.geometry.VPos;
import za.co.jumpingbean.calamariui.common.ExpandImage;
import javafx.util.Sequences;

/**
 * @author mark
 */

public class PieChartParameters  extends CustomNode {

    public var display:PieChartDisplayWithParameters;
    public-read def txtUsername= TextBox{
            columns:35
            editable:true
            text:"All"
        }

    public-read def txtDomain= TextBox{
            columns:35
            editable:true
            text:"All"
        }


    override protected function create () : Node {

          def lblUsername = Label{
                text:"Username"
          }

          def lblDomain = Label{
                text:"Domain"
          }

        def btnGetData= Button{
            text:"Get Data"
            disable:bind Main.asyncTaksInProgress;
            onMouseClicked:function(event:MouseEvent){
                    //display.reportParameter=parameter.text;
                    if (txtDomain.text==null or txtDomain.text=="") txtDomain.text="All";
                    if (txtUsername.text==null or txtUsername.text=="") txtUsername.text="All";
                    display.startPoller();
            }
        }

       def container=VBox{
            nodeHPos:HPos.CENTER;
            spacing:10
            content:[
                     VBox{
                     nodeHPos:HPos.CENTER;
                     content:[
                     HBox{
                            nodeVPos:VPos.CENTER;
                            spacing:10
                            content:[
                                      lblDomain,
                                      txtDomain,
                                      lblUsername,
                                      txtUsername
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
