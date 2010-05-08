/*
 * DateCell.fx
 *
 * Created on 28-Apr-2010, 19:11:28
 */

package za.co.jumpingbean.calamariui.tabularDisplay;

import org.jfxtras.ext.swing.table.Cell;
import java.lang.Class;
import java.sql.Timestamp;
import za.co.jumpingbean.calamariui.service.Utils;

/**
 * @author mark
 */

public class TimestampCell extends Cell{

    public var value:Timestamp on replace {
        valueChanged();
    }

    override protected function getValue () : Object {
        return value;
    }

    override public function getColumnClass () : Class {
        return Timestamp.class;
    }

    override protected function setValue (newValue : Object) : Void {
        value = newValue as Timestamp;
    }

    override public function toString(){
      return Utils.formatDatePrettyLongPrint(value);
    }

}
