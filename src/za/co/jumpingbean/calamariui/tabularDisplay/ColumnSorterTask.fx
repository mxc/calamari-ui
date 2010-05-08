/*
 * ColumnSorterTask.fx
 *
 * Created on 26-Apr-2010, 20:00:53
 */

package za.co.jumpingbean.calamariui.tabularDisplay;

import javafx.async.JavaTaskBase;
import java.lang.UnsupportedOperationException;
import javafx.async.RunnableFuture;
import za.co.jumpingbean.calamariui.Main;

/**
 * @author mark
 */

public class ColumnSorterTask extends JavaTaskBase{


    public-init var columnSorter:ColumnSorter;
    
    override protected function create () : RunnableFuture {
            new RunnableFutureImpl(columnSorter);
    }

    
    override public var onDone=function():Void{
           Main.asyncTaksInProgress=false;
    }

}
