/*
 * AdminDisplay.fx
 *
 * Created on 24 Apr 2010, 1:55:36 PM
 */

package za.co.jumpingbean.calamariui.adminDisplay;

import javafx.scene.CustomNode;
import javafx.scene.Node;
import javafx.scene.control.TextBox;
import javafx.scene.control.Label;
import javafx.scene.control.Button;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import za.co.jumpingbean.calamariui.service.DataService;
import za.co.jumpingbean.calamariui.common.DisplaySelector;
import za.co.jumpingbean.calamariui.common.Logo;
import za.co.jumpingbean.calamariui.service.StringResultWrapper;
import javafx.geometry.HPos;
import javafx.scene.input.MouseEvent;
import javafx.animation.Timeline;
import javafx.animation.KeyFrame;
import javafx.scene.text.Font;
import javafx.scene.paint.Color;
import org.jfxtras.ext.swing.XSwingTable;
import org.jfxtras.ext.swing.table.ObjectSequenceTableModel;
import org.jfxtras.ext.swing.table.Row;
import za.co.jumpingbean.calamariui.model.ImportFile;
import org.jfxtras.ext.swing.table.StringCell;
import org.jfxtras.ext.swing.table.IntegerCell;
import za.co.jumpingbean.calamariui.service.Utils;
import java.util.GregorianCalendar;
import za.co.jumpingbean.calamariui.service.ImportFileListWrapper;
import za.co.jumpingbean.calamariui.common.DateCriteriaControls;

/**
 * @author mark
 */

public class AdminDisplay extends CustomNode{

    //var location:String;
    def service=DataService{};
    public var displaySelector:DisplaySelector;
    var vbox:VBox;
    var squidLogFileLocationResult:StringResultWrapper=StringResultWrapper{result:""};
    public var endDate:GregorianCalendar=Utils.getCurrentDate();
    public var startDate:GregorianCalendar=Utils.getFirstDayOfMonth(endDate);
    var importFileList=ImportFileListWrapper{};
    public var width:Number;
    public var height:Number;

    var importFileResult:StringResultWrapper=StringResultWrapper{
            override var result="No import under way" on replace {
                if(result=="no import in progress")  {
                        adminPoller.stop();
                }
            };
    }
    
    var txtLogFileLocation:TextBox;

    public function insertDisplaySelector(displaySelector:DisplaySelector){
        insert displaySelector after vbox.content[2]
    }

    public function removeDisplaySelector(displaySelector:DisplaySelector){
        delete displaySelector from vbox.content
    }

    function getAdminInfo(){
        service.getAdminData("admin/settings/squidlogfolder",null,squidLogFileLocationResult);
    }

    function saveLogFileLocation(){
        service.saveAdminData(txtLogFileLocation.text,squidLogFileLocationResult)
    }

    def adminPoller = Timeline{
        repeatCount: Timeline.INDEFINITE
        keyFrames: [
          KeyFrame{
                    time: 20s
                    canSkip:true;
                    action: function(){
                       println("polling ....");
                                service.getImportStatus(importFileResult);
                       }
                    }
        ]
    }


        //this function is to avoid compile time errors related to bound functions and is called by getTableModel()
         function getModel():ObjectSequenceTableModel{
                var model = ObjectSequenceTableModel{
                           override public function transformEntry (entry : Object):Row {
                                var record = entry as ImportFile;
                                Row{
                                    cells:[
                                            StringCell { value: Utils.getDateFromTimestamp(record.importDate).toString(); editable:false},
                                            StringCell { value: record.filename editable:false},
                                            IntegerCell { value: record.checksum editable:false}
                                          ]
                                }
                                }
                                sequence: bind importFileList.list;
                                columnLabels: ["Import Date","File","Checksum"]
                            }
                return model;
        }

    override protected function create () : Node {
        getAdminInfo();//populate text box
        def lblLogFileLocation=Label{
            text:"Log File Folder"
            font:Font{size:12 name: "Arial Bold"}
            textFill:Color.DARKGREEN;
    }

        txtLogFileLocation = TextBox{
            text:bind squidLogFileLocationResult.result with inverse;
            columns:45
        }

        def btnSave = Button{
            text:"Save Folder"
            onMouseClicked:function(event:MouseEvent){
                saveLogFileLocation();
            }
        }

        def logFileControls = HBox{
            spacing:10
            content: [
                        lblLogFileLocation,
                        txtLogFileLocation,
                        btnSave
                    ]
        }

        def btnImport:Button = Button{
            text:"Import Data"
            onMouseClicked:function(event:MouseEvent){
                service.startImport(importFileResult);
                adminPoller.play();
            }
        }

        def lblImportResult=Label{ text:bind importFileResult.result font:Font{size:12 name: "Arial Bold"} textFill:Color.DARKGREEN;};


        def importControls=HBox{
            spacing:10
            content: [
                       btnImport,
                       lblImportResult
                    ]
        }

        def dateCriteriaControlImportHistory:DateCriteriaControls = DateCriteriaControls{
            startDate: bind startDate with inverse
            endDate: bind endDate with inverse
            onMouseClicked:function(event:MouseEvent){
                service.getImportHistory(startDate,endDate,importFileList);
                //adminPoller.play();
            }
        }

        def table=XSwingTable{
           width:bind width;
           //height:bind height-controls.height-100//make sure not off scene
           tableModel:getModel()
        }


        //def importFileHistoryControls=VBox{
        //    spacing:10
        //    content: [
        //               dateCriteriaControlImportHistory,
        //               table
       //             ]
        //}
        VBox{
          content:[
                HBox{
                    content:[
                                Logo{}
                                vbox =VBox{
                                    nodeHPos:HPos.CENTER;
                                    spacing:10
                                    content: [
                                                logFileControls,
                                                importControls,
                                                dateCriteriaControlImportHistory,
                                            ]
                                }
                    ]
                },
                table
                ]
        }
    }
}

