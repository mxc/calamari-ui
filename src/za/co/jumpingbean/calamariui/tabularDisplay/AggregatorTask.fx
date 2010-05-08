/*
 * AggregatorBaseTask.fx
 *
 * Created on 26-Apr-2010, 18:55:37
 */

package za.co.jumpingbean.calamariui.tabularDisplay;

import javafx.async.JavaTaskBase;
import java.lang.UnsupportedOperationException;
import javafx.async.RunnableFuture;
import za.co.jumpingbean.calamariui.Main;


/**
 * @author mark
 */

public class AggregatorTask extends JavaTaskBase{

    public-init var aggregator:Aggregator;

    override protected function create () : RunnableFuture {
        new RunnableFutureImpl(aggregator);
    }

    override public var onDone=function():Void{
            Main.asyncTaksInProgress=false;
    }



  



}
