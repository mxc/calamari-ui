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
import java.io.File;
import javafx.util.Properties;
import java.io.FileOutputStream;
import javafx.scene.control.CheckBox;

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

    //Hold the result of any currently running import on the server
    def importFileResult:StringResultWrapper=StringResultWrapper{
            override var result="No import under way" on replace {
                if(result=="no import in progress")  {
                        adminPoller.stop();
                }
            };
    }

    //Holds the response to a call to the initdb service.
    def initDBResult:StringResultWrapper=StringResultWrapper{
            override var result="" on replace {
                    lblMessage.text=result;
                    btnDBInit.disable=false;
                    chkDrop.selected=false;
             }
     }

    var btnDBInit:Button;
    var txtLogFileLocation:TextBox;//textbox for current value of variable retrieved form web service
    var txtServerAddress:TextBox;//textbox for current value of variable retrieved form web service
    var lblMessage:Label; //message box for init db - to get status from web call
    var chkDrop:CheckBox;

    public function insertDisplaySelector(displaySelector:DisplaySelector){
        insert displaySelector after vbox.content[4]
    }

    public function removeDisplaySelector(displaySelector:DisplaySelector){
        delete displaySelector from vbox.content
    }

    public function getAdminInfo(){
        service.getAdminData("admin/settings/squidlogfolder",null,squidLogFileLocationResult);
    }

    function saveLogFileLocation(){
        service.saveAdminData(txtLogFileLocation.text,squidLogFileLocationResult)
    }

    function saveServerAddress(server:String){
        def file = new File("calamari-ui.properties");
        file.createNewFile();
        def prop: Properties = new Properties();
        prop.put("server",server);
        prop.store(new FileOutputStream(file));
        DataService.baseUrl=server;
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


        //this function is to avoid compile time errors related to bound functions and is called by getTableModel(). i.e called from bound
        //function
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

        //
        //Controls to setup log file location
        //
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

        //
        //Set of controls for Server address
        //
        def lblServerAddress=Label{
            text:"Backend Server Address"
            font:Font{size:12 name: "Arial Bold"}
            textFill:Color.DARKGREEN;
        }

        txtServerAddress = TextBox{
            text:DataService.baseUrl;
            columns:45
        }

        def btnSaveServerAddress=Button{
            text:"Save Server Address"
            onMouseClicked:function(event:MouseEvent){
                saveServerAddress(txtServerAddress.text);
            }
        }

        def serverAddressControls = HBox{
            spacing:10
            content: [
                        lblServerAddress,
                        txtServerAddress,
                        btnSaveServerAddress
                    ]
        }


        //
        //Import data controls
        //
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

        //
        //Controls for import history
        //
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
           tableModel:getModel()
        }

        //
        //Controls for DB Init
        //


        chkDrop=CheckBox{
            text:"Drop Existing Database"
            font:Font{size:12 name: "Arial Bold"}
            selected:false
        }

        btnDBInit=Button{
            text:"Initialise Database"
            onMouseClicked:function(event:MouseEvent){
                if (chkDrop.selected)  service.initDBDropIfExists(initDBResult)
                else  service.initDB(initDBResult);
                btnDBInit.disable=true;
            }
        }

        lblMessage=Label{
            text:""
            font:Font{size:12 name: "Arial Bold"}
            textFill:Color.DARKGREEN;
        }

        def initDBControls = HBox{
            spacing:10
            content: [
                        //lblDBCreate,
                        btnDBInit,
                        chkDrop,
                        lblMessage
                    ]
        }


        //
        //Grouping of controls for display
        //
        VBox{
          content:[
                HBox{
                    spacing:15
                    content:[
                                Logo{}
                                vbox = VBox{
                                       nodeHPos:HPos.LEFT;
                                       spacing:10
                                       content: [
                                                initDBControls,
                                                logFileControls,
                                                serverAddressControls,
                                                importControls,
                                                dateCriteriaControlImportHistory
                                       ]
                                }
                    ]
                },
                table
                ]
        }
    }
}

