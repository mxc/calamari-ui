/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package za.co.jumpingbean.calamariui.tabularDisplay;

import javafx.async.RunnableFuture;

/**
 *
 * @author mark
 */
public class RunnableFutureImpl implements RunnableFuture{

    private TaskCallback aggregator;

    public RunnableFutureImpl(TaskCallback aggregator){
        this.aggregator=aggregator;
    }

    @Override
    public void run() throws Exception {
        aggregator.performTask();
    }

}
