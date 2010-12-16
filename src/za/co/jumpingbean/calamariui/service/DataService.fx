/*
 * DataService.fx
 *
 * Created on 05 Apr 2010, 6:44:31 PM
 */

package za.co.jumpingbean.calamariui.service;

import java.util.GregorianCalendar;
import javafx.scene.chart.PieChart;
import za.co.jumpingbean.calamariui.Main;
import za.co.jumpingbean.calamariui.tabularDisplay.TabularDisplay;
import javafx.io.http.HttpRequest;
import java.io.InputStream;
import java.io.ByteArrayOutputStream;
import java.io.OutputStream;
import javafx.io.http.HttpHeader;
import javafx.io.http.URLConverter;
import javafx.data.Pair;
import java.lang.Exception;
import za.co.jumpingbean.calamariui.timeSeriesChartDisplay.LineChartDateData;
import java.sql.Timestamp;
import javafx.scene.chart.part.TimeSeriesAxis;
import java.io.File;
import javafx.util.Properties;
import java.io.FileInputStream;
import java.io.FileOutputStream;

/**
 * @author mark
 */

public  var baseUrl:String;

public static def PieChartTypeUserHits="userhits";
public static def PieChartTypeUserBytes="userbytes";
public static def PieChartTypeDomainHits="domainhits";
public static def PieChartTypeDomainBytes="domainbytes";
public static def PieChartTypeUserSiteBytes="usersitebytes";
public static def PieChartTypeUserSiteHits="usersitehits";


public class DataService {

       var main:Main;

       /*
        Setup some initialisation parameters
       */
       postinit{
                def file = new File("calamari-ui.properties");
                file.createNewFile();
                def prop: Properties = new Properties();
                prop.load(new FileInputStream(file));
                baseUrl = prop.get("server");
                if (baseUrl=="") {
                    prop.put("server","http://127.0.0.1:8080/Calamari-1.0/resources");
                    prop.store(new FileOutputStream(file));
                    baseUrl="http://127.0.0.1:8080/Calamari-1.0/resources";
                }
           }

        public function getTopSitesByHits(startDate:GregorianCalendar,endDate:GregorianCalendar,count:Integer,data:ChartDataListWrapper){
             getChartData(startDate,endDate,count,data,"dataservice/topsitesbyhits",null,PieChartTypeDomainHits);
        }

        /*
           Main function to get Pie Chart Data
        */
        function getChartData(startDate:GregorianCalendar,endDate:GregorianCalendar,count:Integer,data:ChartDataListWrapper,url:String,parameter:String,type:String){
            def begin = Utils.formatDate(startDate);
            def end = Utils.formatDate(endDate);
            def parser = ChartDataPointParser{};
            var tmpUrl;
            if (parameter==null) tmpUrl="{baseUrl}/{url}/{begin}/{end}/{count}"
            else tmpUrl = "{baseUrl}/{url}/{begin}/{end}/{parameter}/{count}";
            println("{tmpUrl}");
             var request:UIHttpRequest=UIHttpRequest{
                location: tmpUrl;
                parser: parser;
                onException:function(ex:Exception){
                       data.error=true;
                       data.errorMessage=ex.getMessage();
                }
                onDone: function(){
                   if (data.error){
                        data.done=true;
                   }else if (sizeof parser.list>0){
                    for (point in parser.list){
                        var tmpData =PieChart.Data{
                            label:point.name.replace("http://","");
                        }
                        if(type==PieChartTypeUserHits or type==PieChartTypeDomainHits or type==PieChartTypeUserSiteHits) {
                             tmpData.value=point.hits;
                           }else{
                             tmpData.value=point.bytes/(1024*1024);
                        }
                        if (type==PieChartTypeDomainHits or type==PieChartTypeDomainBytes) {
                                tmpData.action=function(){ main.showTabularDisplay(TabularDisplay.reportDomainDetail,tmpData.label,null,startDate,endDate,true);};
                        }
                        else if (type==PieChartTypeUserHits or type==PieChartTypeUserBytes){
                                tmpData.action=function(){ main.showTabularDisplay(TabularDisplay.reportUserDetail,tmpData.label,null,startDate,endDate,true);};
                        }else if (type==PieChartTypeUserSiteHits or type==PieChartTypeUserSiteBytes){

                               if (url.indexOf("foruser")!=-1) {
                                       tmpData.action=function(){ main.showTabularDisplay(TabularDisplay.reportUserDomainDetail,parameter,tmpData.label,startDate,endDate,true);};
                               }
                               else if (url.indexOf("ofsite")!=-1){
                                   tmpData.action=function(){ main.showTabularDisplay(TabularDisplay.reportUserDomainDetail,tmpData.label,parameter,startDate,endDate,true);};
                               }
                        }

                        insert tmpData into data.list;
                    }
                    data.done=true;
                    data.error=false;
                  }else{
                    data.done=true;
                    data.error=true;
                    data.errorMessage="0 records returned"
                  }
                }
            }
            request.start();
        }

        public function getTopSitesBySize(startDate:GregorianCalendar,endDate:GregorianCalendar,count:Integer,data:ChartDataListWrapper){
             getChartData(startDate,endDate,count,data,"dataservice/topsitesbysize",null,PieChartTypeDomainBytes);
        }

        public function getTopUsersBySize(startDate:GregorianCalendar,endDate:GregorianCalendar,count:Integer,data:ChartDataListWrapper){
             getChartData(startDate,endDate,count,data,"dataservice/topusersbysize",null,PieChartTypeUserBytes);
        }

        public function getTopUsersByHits(startDate:GregorianCalendar,endDate:GregorianCalendar,count:Integer,data:ChartDataListWrapper){
             getChartData(startDate,endDate,count,data,"dataservice/topusersbyhits",null,PieChartTypeUserHits);
        }

        public function getUserDetails(startDate:GregorianCalendar,endDate:GregorianCalendar,username:String,data:SquidLogRecordListWrapper){
             getSquidLogDetailData(startDate,endDate,"dataservice/userdetails",username,data);
        }

        public function getDetails(startDate:GregorianCalendar,endDate:GregorianCalendar,data:SquidLogRecordListWrapper){
             getSquidLogDetailData(startDate,endDate,"dataservice/details",null,data);
        }

        public function getDomainDetails(startDate:GregorianCalendar,endDate:GregorianCalendar,domain:String,data:SquidLogRecordListWrapper){
             getSquidLogDetailData(startDate,endDate,"dataservice/domaindetails",domain,data);
        }

        public function getContentTypeDetails(startDate:GregorianCalendar,endDate:GregorianCalendar,contentType:String,data:SquidLogRecordListWrapper){
             getSquidLogDetailData(startDate,endDate,"dataservice/contenttypedetails",contentType,data);
        }

        public function getUserDomainDetails(startDate:GregorianCalendar,endDate:GregorianCalendar,username:String,domain:String,data:SquidLogRecordListWrapper){
               getSquidLogDetailData(startDate,endDate,"dataservice/domainuserdetails","{domain}/{username}",data);
        }



        /**
           Function to retrieve simple sring results from web service
        */
        function getStringResult(url:String,result:StringResultWrapper){
            def request:HttpRequest=HttpRequest{
                location: "{baseUrl}/{url}"
                method:HttpRequest.GET
                onException:function(ex:Exception){
                    result.result=ex.getMessage();
                    result.errorMessage=ex.getMessage();
                }
                onInput:function(is:InputStream){
                    result.result=readInputBuffer(is);
                    //println("--{result.result}");
               }
                onDone: function(){
                   println("done...");
                   if (request.error!=null){
                       //println("error---{result.result}");
                       result.error=true;
                       result.done=true;
                       //result.result=readInputBuffer(request.error);
                    }else{
                        //result.result="success";
                        result.done=true;
                    }
                    //println("result---{result.result}");
                }
            }
            request.start();
        }

        public function getImportStatus(result:StringResultWrapper){
           getStringResult("admin/importlogfilesstatus",result);
        }
        
        public function startImport(result:StringResultWrapper){
           getStringResult("admin/importlogfiles",result);
        }

        public function initDB(result:StringResultWrapper){
           getStringResult("admin/initdb",result);
        }

        public function initDBDropIfExists(result:StringResultWrapper){
                getStringResult("admin/initdb?dropifexists=true",result);
        }


        /**
            This function is used to retrieve and process detailed log records.
        */
        function getSquidLogDetailData(startDate:GregorianCalendar,endDate:GregorianCalendar,url:String,param:String,data:SquidLogRecordListWrapper){
            def begin = Utils.formatDate(startDate);
            def end = Utils.formatDate(endDate);
            def parser = SquidLogRecordParser{};
            var tmpUrl = "{baseUrl}/{url}/{begin}/{end}";
            if (param!=null and param!="") tmpUrl="{tmpUrl}/{param}";
            println("{tmpUrl}");
            var request:UIHttpRequest=UIHttpRequest{
                location: tmpUrl;
                parser: parser;
                onException:function(ex:Exception){
                       data.error=true;
                       data.errorMessage=ex.getMessage();
                }
                onDone: function(){
                   println("done");
                   if ( data.error){
                        data.done=true;
                   }else if (sizeof parser.list>0){
                    data.list=parser.list;
                    data.done=true;
                    data.error=false;
                  }else{
                    data.done=true;
                    data.error=true;
                    data.errorMessage="0 records returned"
                  }
                }
            }
            request.start();
        }

        /*
            function to save log file location to back-end server
        */
        public function saveAdminData(location:String,result:StringResultWrapper){
            def urlConverter = URLConverter{};
            def encodedMessage = urlConverter.encodeParameters(Pair{name:"path" value:location});
            var tmpUrl = "{baseUrl}/admin/settings/squidlogfolder?{encodedMessage}";
            def request:HttpRequest=HttpRequest{
                location: tmpUrl
                method:HttpRequest.POST
                headers: [
                HttpHeader {
                name: HttpHeader.CONTENT_TYPE;
                value: "text/plain";
                },
                //HttpHeader {
                //name: HttpHeader.CONTENT_LENGTH;
                //value: "{encodedMessageSize}";
                //}
                ];
                onOutput:function(os:OutputStream){
                     os.close();
                }
                onException:function(ex:Exception){
                    result.result=ex.getMessage();
                    result.errorMessage=ex.getMessage();
                }
                onInput:function(is:InputStream){
                    result.result=readInputBuffer(is);
                    //println("{tmpUrl}--{result.result}");
               }
                onDone: function(){
                   println("done...");
                   if (request.error!=null){
                       result.error=true;
                       result.done=true;
                    }else{
                        result.result="successfully save location: {location}";
                        result.done=true;
                    }
                }
            }
            request.start();
        }

        /*
            retrieve config info from backend server
        */
        public function getAdminData(url:String,param:String,data:StringResultWrapper){
            var result:String;
            var tmpUrl = "{baseUrl}/{url}";
            if (param!=null) tmpUrl="{tmpUrl}/{param}";
            var request:HttpRequest=HttpRequest{
                location: tmpUrl
                onInput:function (is:InputStream){
                    result=readInputBuffer(is);
                    data.result=result;
                    data.done=true;
                }
                onError: function(is:InputStream){
                    result=readInputBuffer(is);
                    data.result="Not initialised";
                    data.error=true;
                    data.done=true;
                }
                onDone: function(){
                   if (request.error!=null){
                       result=readInputBuffer(request.error);
                       data.result=result.substring(0,50);
                       data.error=true;
                    }
                }
            }
            request.start();
        }

        function readInputBuffer(is:InputStream){
            var byte:Integer;
            var byteArray = new ByteArrayOutputStream();
            while ((byte= is.read())!=-1){
                byteArray.write(byte);
            }
            is.close();
            return byteArray.toString();
        }

        public function getImportHistory(startDate:GregorianCalendar,endDate:GregorianCalendar,data:ImportFileListWrapper){
                getImportHistory(startDate,endDate,"admin/importhistory",data);
        }

        function getImportHistory(startDate:GregorianCalendar,endDate:GregorianCalendar,url:String,data:ImportFileListWrapper){
            def begin = Utils.formatDate(startDate);
            def end = Utils.formatDate(endDate);
            def parser = ImportFileRecordParser{};
            var tmpUrl = "{baseUrl}/{url}/{begin}/{end}";
            //println("{tmpUrl}");
            var request:UIHttpRequest=UIHttpRequest{
                location: tmpUrl;
                parser: parser;
                onException:function(ex:Exception){
                       data.error=true;
                       data.errorMessage=ex.getMessage();
                }
                onDone: function(){
                   println("done");
                   if ( data.error){
                        data.done=true;
                   }else if (sizeof parser.list>0){
                    data.list=parser.list;
                    data.done=true;
                    data.error=false;
                  }else{
                    data.done=true;
                    data.error=true;
                    data.errorMessage="0 records returned"
                  }
                }
            }
            request.start();
        }

        public function getDomainHitsTimeSeriesDataByHour(startDate:GregorianCalendar,endDate:GregorianCalendar,data:TimeSeriesDataListWrapper,domain:String){
            getTimeSeriesData(startDate,endDate,data,"dataservice/domainhitsbyhour",domain);
        }

        public function getUserHitsTimeSeriesDataByHour(startDate:GregorianCalendar,endDate:GregorianCalendar,data:TimeSeriesDataListWrapper,user:String){
            getTimeSeriesData(startDate,endDate,data,"dataservice/userhitsbyhour",user);
        }

        public function getDomainHitsTimeSeriesDataByDay(startDate:GregorianCalendar,endDate:GregorianCalendar,data:TimeSeriesDataListWrapper,domain:String){
            getTimeSeriesData(startDate,endDate,data,"dataservice/domainhitsbyday",domain);
        }

        public function getUserHitsTimeSeriesDataByDay(startDate:GregorianCalendar,endDate:GregorianCalendar,data:TimeSeriesDataListWrapper,user:String){
            getTimeSeriesData(startDate,endDate,data,"dataservice/userhitsbyday",user);
        }

        public function getDomainSizeTimeSeriesDataByHour(startDate:GregorianCalendar,endDate:GregorianCalendar,data:TimeSeriesDataListWrapper,domain:String){
            getTimeSeriesData(startDate,endDate,data,"dataservice/domainsizebyhour",domain);
        }

        public function getUserSizeTimeSeriesDataByHour(startDate:GregorianCalendar,endDate:GregorianCalendar,data:TimeSeriesDataListWrapper,user:String){
            getTimeSeriesData(startDate,endDate,data,"dataservice/usersizebyhour",user);
        }

        public function getDomainSizeTimeSeriesDataByDay(startDate:GregorianCalendar,endDate:GregorianCalendar,data:TimeSeriesDataListWrapper,domain:String){
            getTimeSeriesData(startDate,endDate,data,"dataservice/domainsizebyday",domain);
        }

        public function getUserSizeTimeSeriesDataByDay(startDate:GregorianCalendar,endDate:GregorianCalendar,data:TimeSeriesDataListWrapper,user:String){
            getTimeSeriesData(startDate,endDate,data,"dataservice/usersizebyday",user);
        }

        function getTimeSeriesData(startDate:GregorianCalendar,endDate:GregorianCalendar,data:TimeSeriesDataListWrapper,url:String,parameter:String){
            def begin = Utils.formatDate(startDate);
            def end = Utils.formatDate(endDate);
            def parser = TimeSeriesDataPointParser{};
            println("{baseUrl}/{url}/{begin}/{end}/{parameter}");
            var request:UIHttpRequest=UIHttpRequest{
                location: "{baseUrl}/{url}/{begin}/{end}/{parameter}";
                parser: parser;
                onException:function(ex:Exception){
                       data.error=true;
                       data.errorMessage=ex.getMessage();
                }
                onDone: function(){
                   if (data.error){
                        data.done=true;
                   }else if (sizeof parser.list>0){
                    var minxValue:Timestamp;
                    var maxxValue:Timestamp;
                    var minyValue:Number;
                    var maxyValue:Number;
                    var list:LineChartDateData[];
                    println("{baseUrl}/{url}/{begin}/{end}/{parameter}");
                    for (point in parser.list){
                        var tmpData =LineChartDateData{}
                        tmpData.xDateTimeValue=point.date;

                        //convert from bytes to kilobytes

                        if (url.indexOf("size")==-1) {
                            tmpData.yMeasureValue=point.value as Float
                        } else {
                            tmpData.yMeasureValue=(point.value/(1024)) as Float;
                         }
                        //get the range min max values
                        if (minyValue>tmpData.yMeasureValue) minyValue=tmpData.yMeasureValue;
                        if (maxyValue<tmpData.yMeasureValue) maxyValue=tmpData.yMeasureValue;

                        if (minxValue==null or minxValue.compareTo(tmpData.xDateTimeValue)>0) minxValue=tmpData.xDateTimeValue;
                        if (maxxValue==null or maxxValue.compareTo(tmpData.xDateTimeValue)<0) maxxValue=tmpData.xDateTimeValue;
                        var tmpStartDate = new GregorianCalendar();
                        tmpStartDate.setTimeInMillis(tmpData.xDateTimeValue.getTime());

                        if (url.indexOf("domain")!=-1){
                                tmpData.action=function(){
                                   main.showTabularDisplay(TabularDisplay.reportDomainDetail,parameter,null,tmpStartDate,tmpStartDate,true);
                            }
                        }else{
                            tmpData.action=function(){
                                main.showTabularDisplay(TabularDisplay.reportUserDetail,parameter,null,tmpStartDate,tmpStartDate,true);
                            }
                        }

                        insert tmpData into list;
                    }
                    println("done....");
                    data.minxValue=minxValue;
                    data.maxxValue=maxxValue;
                    data.minyValue=minyValue;
                    data.maxyValue=maxyValue;
                    data.name=parameter;
                    data.list=list;
                    data.done=true;
                    data.error=false;
                   }else{
                    data.done=true;
                    data.error=true;
                    data.errorMessage="0 records returned"
                  }
                }
            }
            request.start();
        }

        public function getTopSitesBySizeForUser(startDate:GregorianCalendar,endDate:GregorianCalendar,count:Integer,username:String,data:ChartDataListWrapper){
              this.getChartData(startDate,endDate,count,data,"dataservice/topsitesforuserbysize",username,PieChartTypeUserSiteBytes);
        }

        public function getTopSitesByHitsForUser(startDate:GregorianCalendar,endDate:GregorianCalendar,count:Integer,username:String,data:ChartDataListWrapper){
              this.getChartData(startDate,endDate,count,data,"dataservice/topsitesforuserbyhits",username,PieChartTypeUserSiteHits);
        }

        public function getTopUsersBySizeOfSite(startDate:GregorianCalendar,endDate:GregorianCalendar,count:Integer,domain:String,data:ChartDataListWrapper){
              this.getChartData(startDate,endDate,count,data,"dataservice/topusersofsitebysize",domain,PieChartTypeUserSiteBytes);
        }

        public function getTopUsersByHitsOfSite(startDate:GregorianCalendar,endDate:GregorianCalendar,count:Integer,domain:String,data:ChartDataListWrapper){
              this.getChartData(startDate,endDate,count,data,"dataservice/topusersofsitebyhits",domain,PieChartTypeUserSiteHits);
        }


}
