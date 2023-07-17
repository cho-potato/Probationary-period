<%@ page import="org.apache.commons.logging.*" %>

<%@ page import="com.nexacro.xapi.data.*" %>
<%@ page import="com.nexacro.xapi.tx.*" %>

<%@ page import = "java.util.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.io.*" %>

<%@ page contentType="text/xml; charset=UTF-8" %>

<%! 

// Dataset value
public String  dsGet(DataSet ds, int rowno, String colid) throws Exception
{
    String value;
    value = ds.getString(rowno,colid);
    if( value == null )
        return "";
    else
        return value;
} 
%>

<%
    
int nErrorCode = 0;
String strErrorMsg = "START";

// HttpPlatformRequest
// Http ��û���κ��� ������(PlatformData)�� ���Ź޴´�.
HttpPlatformRequest pReq = new HttpPlatformRequest(request);
pReq.receiveData();
PlatformData in_PlatformData = pReq.getData();

// #1. VariableList ���� ���� ����
VariableList in_valList = in_PlatformData.getVariableList();
String in_var1 = in_valList.getString("sVal1");
System.out.println(">>> in_var1 : " + in_var1);

// #2. PlatformData ���� ���� ����
Variable varData = in_PlatformData.getVariable("sVal1");
String in_var2 = varData.getString();
System.out.println(">>> in_var2 : " + in_var2);


// #1. PlatformData ���� �����ͼ� ����
DataSet ds = in_PlatformData.getDataSet("in_ds");
System.out.println(">>> ds : " + ds.getRowCount());

// #2. DataSetList ���� �����ͼ� ����
DataSetList in_dsList = in_PlatformData.getDataSetList();
DataSet ds2 = in_dsList.get("in_ds");
System.out.println(">>> ds2 : " +  ds2.getRowCount());

try {    
    /******* JDBC Connection *******/
    Connection conn = null;
    Statement  stmt = null;
    ResultSet  rs   = null;
    
    try {
    
        // Class.forName("org.sqlite.JDBC");
        // conn = DriverManager.getConnection("jdbc:sqlite:C:\\Tomcat 7.0\\webapps\\edu\\Local_Edu.db3");
        
		Class.forName("oracle.jdbc.driver.OracleDriver");
    	conn = DriverManager.getConnection("jdbc:oracle:thin:@192.168.0.3:1521:XE", "scott", "tiger");
    
        stmt = conn.createStatement();
    
        String SQL = "";
        int    i;
        
        /******** DELETE ********/
        for( i = 0; i < ds.getRemovedRowCount(); i++ )
        {
            String del_id = ds.getRemovedData(i, "EMPL_ID").toString();
            SQL = "DELETE FROM EMPLOYEES  " +
                  "      WHERE EMPL_ID = '" + del_id + "'";
            stmt.executeUpdate(SQL);
        }

        /******** INSERT, UPDATE ********/
        for( i = 0; i < ds.getRowCount(); i++ )
        {
            int rowType = ds.getRowType(i);
            if( rowType == DataSet.ROW_TYPE_INSERTED )
            {
                SQL = "INSERT INTO EMPLOYEES(EMPL_ID,       \n" +
                      "                      FULL_NAME,     \n" +
                      "                      DEPT_ID,       \n" +
                      "                      HIRE_DATE,     \n" +
                      "                      GENDER,        \n" +
                      "                      MARRIED,       \n" +
                      "                      SALARY,        \n" +
                      "                      EMPL_MEMO)     \n" +
                      "     VALUES('" + dsGet(ds, i, "EMPL_ID"  ) + "',\n" + 
                      "            '" + dsGet(ds, i, "FULL_NAME") + "',\n" + 
                      "            '" + dsGet(ds, i, "DEPT_ID"  ) + "',\n" +  
                      "            '" + dsGet(ds, i, "HIRE_DATE") + "',\n" +
                      "            '" + dsGet(ds, i, "GENDER"   ) + "',\n" +
                      "            '" + dsGet(ds, i, "MARRIED"  ) + "',\n" +
                      "            '" + dsGet(ds, i, "SALARY"   ) + "',\n" +                
                      "            '" + dsGet(ds, i, "EMPL_MEMO") + "')  ";                  
                         
                System.out.println(">>> insert : "+SQL);
            }
            else if( rowType == DataSet.ROW_TYPE_UPDATED )
            {
                String org_id = ds.getSavedData(i, "EMPL_ID").toString(); 
                SQL = "UPDATE EMPLOYEES" +
                      "   SET FULL_NAME = '" + dsGet(ds, i, "FULL_NAME") + "',\n" + 
                      "       EMPL_ID   = '" + dsGet(ds, i, "EMPL_ID"  ) + "',\n" +  
                      "       DEPT_ID   = '" + dsGet(ds, i, "DEPT_ID"  ) + "',\n" +  
                      "       HIRE_DATE = '" + dsGet(ds, i, "HIRE_DATE") + "',\n" +
                      "       GENDER    = '" + dsGet(ds, i, "GENDER"   ) + "',\n" +
                      "       MARRIED   = '" + dsGet(ds, i, "MARRIED"  ) + "',\n" +
                      "       SALARY    = '" + dsGet(ds, i, "SALARY"   ) + "',\n" +
                      "       EMPL_MEMO = '" + dsGet(ds, i, "EMPL_MEMO") + "' \n" +
                      " WHERE EMPL_ID   = '" + org_id + "'";

              System.out.println(">>> update : "+SQL);
            }
                    
            stmt.executeUpdate(SQL);
        }

        //conn.commit();

    } catch (SQLException e) {
        nErrorCode  = -1;
        strErrorMsg = e.getMessage();
    }    
    
    /******** JDBC Close ********/
    if ( stmt != null ) try { stmt.close(); } catch (Exception e) {nErrorCode = -1; strErrorMsg = e.getMessage();}
    if ( conn != null ) try { conn.close(); } catch (Exception e) {nErrorCode = -1; strErrorMsg = e.getMessage();}
    
    nErrorCode  = 0;
    strErrorMsg = "SUCC";
            
} catch (Throwable th) {
    nErrorCode  = -1;
    strErrorMsg = th.getMessage();
}

// PlatformData 
PlatformData out_PlatformData = new PlatformData();

VariableList out_varList = out_PlatformData.getVariableList();
out_varList.add("ErrorCode", nErrorCode);
out_varList.add("ErrorMsg" , strErrorMsg);
out_varList.add("out_var"  , "abcd");


HttpPlatformResponse pRes = new HttpPlatformResponse(response, PlatformType.CONTENT_TYPE_XML, "UTF-8");
pRes.setData(out_PlatformData);

pRes.sendData();
%>
