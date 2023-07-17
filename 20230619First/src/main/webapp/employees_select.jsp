<%@ page import="org.apache.commons.logging.*" %>

<%@ page import="com.tobesoft.xplatform.data.*" %>
<%@ page import="com.tobesoft.xplatform.tx.*" %>

<%@ page import = "java.util.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.io.*" %>

<%@ page contentType="text/xml; charset=UTF-8" %>

<%
// PlatformData 
PlatformData o_xpData = new PlatformData();
	
int nErrorCode = 0;
String strErrorMsg = "START";
String sTest="111";

try {	
	/******* JDBC Connection *******/
	Connection conn = null;
	Statement  stmt = null;
	ResultSet  rs   = null;
	
	try { 
		//Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
		//conn = DriverManager.getConnection("jdbc:sqlserver://61.107.23.159:1433;DatabaseName=EDU;User=edu;Password=edu123");
		
		Class.forName("oracle.jdbc.driver.OracleDriver");
    	conn = DriverManager.getConnection("jdbc:oracle:thin:@192.168.0.3:1521:XE", "scott", "tiger");
    
		stmt = conn.createStatement();
	  
		/******* SQL ************/
		String SQL="select * from employees"; 
		
		rs = stmt.executeQuery(SQL);
	  
		/********* Dataset **********/
		
		DataSet ds = new DataSet("ds_employees");
	  
	  ds.addColumn("EMPL_ID"   ,DataTypes.STRING  ,(short)10   );
	  ds.addColumn("FULL_NAME" ,DataTypes.STRING  ,(short)50   );
	  ds.addColumn("HIRE_DATE" ,DataTypes.STRING  ,(short)30   );
	  ds.addColumn("MARRIED"   ,DataTypes.STRING  ,(short)1    );
	  ds.addColumn("SALARY"    ,DataTypes.INT     ,(short)10   );
	  ds.addColumn("GENDER"    ,DataTypes.STRING  ,(short)1    );
	  ds.addColumn("DEPT_ID"   ,DataTypes.STRING  ,(short)10   );
	  ds.addColumn("EMPL_MEMO" ,DataTypes.STRING  ,(short)4000 );
	  	  
	  while(rs.next())
	  {
	  	int row = ds.newRow();

	  	ds.set(row ,"EMPL_ID"    ,rs.getString("EMPL_ID")   );
	  	ds.set(row ,"FULL_NAME"  ,rs.getString("FULL_NAME") );
	  	ds.set(row ,"HIRE_DATE"  ,rs.getString("HIRE_DATE") );
	  	ds.set(row ,"MARRIED"    ,rs.getString("MARRIED")   );
	  	ds.set(row ,"SALARY"     ,rs.getString("SALARY")    );
	  	ds.set(row ,"GENDER"     ,rs.getString("GENDER")    );
	  	ds.set(row ,"DEPT_ID"    ,rs.getString("DEPT_ID")   );
	  	ds.set(row ,"EMPL_MEMO"  ,rs.getString("EMPL_MEMO") );
	  }
	  	
		// DataSet-->PlatformData
		o_xpData.addDataSet(ds);
	 
		nErrorCode = 0;
		strErrorMsg = "SUCC";
		
	} catch (SQLException e) {
		
		nErrorCode = -1;
		strErrorMsg = e.getMessage();
		
	}	
	
	/******** JDBC Close ********/
	if ( stmt != null ) try { stmt.close(); } catch (Exception e) {nErrorCode = -1; strErrorMsg = e.getMessage();}
	if ( conn != null ) try { conn.close(); } catch (Exception e) {nErrorCode = -1; strErrorMsg = e.getMessage();}
			
} catch (Throwable th) {
	nErrorCode = -1;
	strErrorMsg = th.getMessage();

}

// VariableList 
VariableList varList = o_xpData.getVariableList();
		
strErrorMsg=sTest;
		
//Variable--> VariableList
varList.add("ErrorCode", nErrorCode);
varList.add("ErrorMsg", strErrorMsg);

// HttpPlatformResponse 
HttpPlatformResponse pRes = new HttpPlatformResponse(response, PlatformType.CONTENT_TYPE_XML, "UTF-8");
pRes.setData(o_xpData);

// Send data
pRes.sendData();
%>
