<%@ page contentType="text/html; charset=euc-kr" %>
<%@ page language="java"%>

<%@ page import="com.tobesoft.xplatform.tx.*" %>
<%@ page import="com.tobesoft.xplatform.data.*" %>
<%@ page import="com.tobesoft.xplatform.data.datatype.*" %>

<%
    System.out.println("SESSION ID = " + session.getId());

    String strCharset = "euc-kr";

    /*********************************************************
     * request-> parsing->input variable list, input dataset list
     * (XPLATFORM Data parsing)
     *********************************************************/
    PlatformRequest platformRequest = new PlatformRequest(request.getInputStream(), PlatformType.CONTENT_TYPE_XML, strCharset);
    platformRequest.receiveData();
    PlatformData inPD = platformRequest.getData();

    VariableList    inVariableList  = inPD.getVariableList();
    DataSetList     inDataSetList   = inPD.getDataSetList();

    String strUserID   = inVariableList.getString("userid");
    String strUserName = inVariableList.getString("username");
    System.out.println("input userid   = " + strUserID);
    System.out.println("input username = " + strUserName);

    /*********************************************************
     * response
     * output variable list, output dataset list
     * (make XPLATFORM Data)
     *********************************************************/
    PlatformResponse platformResponse = new PlatformResponse(response.getOutputStream(), PlatformType.CONTENT_TYPE_XML, strCharset);
    PlatformData outPD = platformRequest.getData();
    VariableList    outVariableList  = new VariableList();
    DataSetList     outDataSetList   = new DataSetList();


    try {

        // make Dataset
        DataSet outDataSet = new DataSet("output");

        // Output Dataset column
        outDataSet.addColumn("IDX",        DataTypes.STRING, 5);
        outDataSet.addColumn("ObjectName",        DataTypes.STRING, 100);
        outDataSet.addColumn("ObjectID",   DataTypes.STRING, 200);
        outDataSet.addColumn("TestType",     DataTypes.STRING, 8);
        outDataSet.addColumn("TestObject",     DataTypes.STRING, 10);
        outDataSet.addColumn("TestValue",     DataTypes.STRING, 8);
        outDataSet.addColumn("ResultValue",     DataTypes.STRING, 10);

        int nRow;

        for(int i = 0; i < 10; i++) {

            // Output Dataset 
            nRow = outDataSet.newRow();

            // Output Dataset 
            outDataSet.set(nRow, "IDX",      20);
            outDataSet.set(nRow, "ObjectName",      "NAME"+i);
            outDataSet.set(nRow, "ObjectID", "CODE_DESC"+i);
            outDataSet.set(nRow, "TestType",   "20081024");
            outDataSet.set(nRow, "TestObject",   strUserID);
            outDataSet.set(nRow, "TestValue",   "20081024");
            outDataSet.set(nRow, "ResultValue",   strUserID);
        }

        // Output Dataset->Output Dataset List
        outDataSetList.add(outDataSet);

        // Output Vairable.
        outVariableList.add("ErrorCode", 0);
        outVariableList.add("ErrorMsg",  "Success!!!");

        outVariableList.add("strOutputData", "¡ØForm Variable");

    } catch(Exception e) {

        // Output Vairable 
        outVariableList.add("ErrorCode", -1);
        outVariableList.add("ErrorMsg",  e.toString());

    } finally {

        // Send Data(Output Dataset List, Output Variable List)
        outPD.setDataSetList(outDataSetList);
        outPD.setVariableList(outVariableList);
        platformResponse.setData(outPD);
        platformResponse.sendData();
    }
%>
