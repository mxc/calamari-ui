/*
 * ImportFileListWrapper.fx
 *
 * Created on 28-Apr-2010, 12:31:38
 */

package za.co.jumpingbean.calamariui.service;

import za.co.jumpingbean.calamariui.model.ImportFile;

/**
 * @author mark
 */

public class ImportFileListWrapper extends AbstractWrapper {
                public var list:ImportFile[];

        override public function reset():Void{
                super.reset();
                list=[];
        }


}
