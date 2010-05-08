/*
 * ReportSelectorControl.fx
 *
 * Created on 24 Apr 2010, 9:35:29 AM
 */

package za.co.jumpingbean.calamariui.tabularDisplay;

import javafx.scene.CustomNode;
import javafx.scene.Node;
import org.jfxtras.scene.control.XPicker;
import org.jfxtras.scene.control.XPickerType;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.control.Label;
import javafx.scene.control.TextBox;
import javafx.scene.control.Button;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.VBox;
import javafx.scene.layout.HBox;
import javafx.geometry.VPos;
import javafx.geometry.HPos;
import za.co.jumpingbean.calamariui.common.ExpandImage;
import javafx.util.Sequences;
import za.co.jumpingbean.calamariui.Main;

/**
 * @author mark
 */

public class ReportSelectorControl extends CustomNode {

    public var tableDisplay:TabularDisplay;
    
    override protected function create () : Node {

          def label = Label{
                text:"Username"
          }

          def label2 = Label{
                text:"Report Type"
          }
        
          def picker:XPicker = XPicker{
                  pickerType: XPickerType.DROP_DOWN
                  cyclic:false
                  dropDownHeight:80
                  
                  layoutInfo: LayoutInfo {
                      width: 80
                  }
                  items: ["User","Domain","Content Type","All"]
                  preset: 0;
                  onIndexChange:function (index:Integer){
                        if (index==0) {label.text="Username";parameter.disable=false}
                        else if (index==1) {label.text="Domain";parameter.disable=false}
                        else if (index==2) {label.text="Content Type";parameter.disable=false}
                        else if (index==3) {label.text="NA"; parameter.text=""; parameter.disable=true};
                 }
        }

        def parameter= TextBox{
            columns:35
            editable:true
        }

        def btnGetData= Button{
            text:"Get Data"
            disable:bind Main.asyncTaksInProgress;
            onMouseClicked:function(event:MouseEvent){
                    //switch aggregation off.
                    tableDisplay.showingAggregate=false;
                    if (picker.selectedIndex==0) tableDisplay.reportType=tableDisplay.reportUserDetail;
                    if (picker.selectedIndex==1) tableDisplay.reportType=tableDisplay.reportDomainDetail;
                    if (picker.selectedIndex==2) tableDisplay.reportType=tableDisplay.reportContentTypeDetail;
                    if (picker.selectedIndex==2) tableDisplay.reportType=tableDisplay.reportAll;
                    tableDisplay.reportParameter=parameter.text;
                    tableDisplay.startPoller();
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
                                      label2,
                                      picker,
                                      label,
                                      parameter
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
                        text:"Report Type"
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
