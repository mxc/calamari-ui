/*
 * StopTaskControl.fx
 *
 * Created on 26-Apr-2010, 22:08:53
 */

package za.co.jumpingbean.calamariui.tabularDisplay;

import javafx.async.JavaTaskBase;
import javafx.scene.CustomNode;
import java.lang.UnsupportedOperationException;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.input.MouseEvent;

/**
 * @author mark
 */

public class StopTaskControl extends CustomNode {
        
        
    override protected function create () : Node {
            Button{
               text:"Stop Task"
               onMouseClicked:function (event:MouseEvent){
                   task.stop();
               }

            }

    }

        var task:JavaTaskBase;




}
