/*
 * DisplaySelector.fx
 *
 * Created on 24 Apr 2010, 5:53:43 PM
 */

package za.co.jumpingbean.calamariui.common;

import javafx.scene.CustomNode;
import javafx.scene.Node;
import org.jfxtras.scene.control.XPicker;
import org.jfxtras.scene.control.XPickerType;
import za.co.jumpingbean.calamariui.Main;
import za.co.jumpingbean.calamariui.tabularDisplay.TabularDisplay;
import javafx.scene.layout.HBox;
import javafx.scene.control.Label;
import javafx.geometry.VPos;

/**
 * @author mark
 */

public def chartDisplay:Integer=0;
public def tableDisplay:Integer=1;
public def adminDisplay:Integer=2;

public class DisplaySelector extends CustomNode {

    var main:Main;
    public var default:Integer=0;
    var picker:XPicker;

    override protected function create () : Node {
        HBox{
            nodeVPos:VPos.CENTER;
            spacing:5
            content: [
                        Label{
                            text:"go>>"
                        }
                        picker =XPicker{
                            preset:default,
                            items: ["Pie Charts","Time Series","Table Data","Admin"]
                            pickerType:XPickerType.DROP_DOWN
                            dropDownHeight:60
                            onIndexChange:function(index:Integer){
                              if (index==0) {
                                  FX.deferAction(function():Void { main.showChartDisplay()});
                              }
                              else if (index==1) {
                                  FX.deferAction(function():Void{ main.showTimeSeriesChartDisplay()});
                              }
                              else if (index==2) {
                                  FX.deferAction(function():Void{ main.showTabularDisplay(TabularDisplay.reportAll,null,null,null,false)});
                              } else{
                                FX.deferAction(function():Void { main.showAdminDisplay()});
                              }
                        }
                    }
                    ]
        }
    }
}