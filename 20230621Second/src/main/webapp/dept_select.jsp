<%@ page import="org.apache.commons.logging.*" %>

<%@ page import="com.nexacro.xapi.data.*" %>
<%@ page import="com.nexacro.xapi.tx.*" %>

<%@ page import = "java.util.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.io.*" %>

<%@ page contentType="text/xml; charset=UTF-8" %>

<%!

// ResultSet 
public String rsGet(ResultSet rs, String id) throws Exception
{
	if( rs.getString(id) == null )
  {
		return "";
	} else {
		return rs.getString(id);
	}
} 

// ResultSet ==> Dataset
public DataSet Rs2Ds(ResultSet rs, String ds_id) throws Exception
{
	int i;
	int col_cnt;
	String col_name;
	
	DataSet ds = new DataSet(ds_id);
	ResultSetMetaData rsmd = rs.getMetaData();

	col_cnt = rsmd.getColumnCount();
	for( i = 1 ; i <= col_cnt ; i++ )
	{
		col_name = rsmd.getColumnName(i).toUpperCase();
		ds.addColumn(col_name, DataTypes.STRING, (short)rsmd.getColumnDisplaySize(i));
	}
	while(rs.next())
	{
		int row = ds.newRow();
		for( i = 1 ; i <= col_cnt ; i++ )
		{
			col_name = rsmd.getColumnName(i).toUpperCase();
			ds.set(row, col_name, rsGet(rs, col_name));
		}
	}

  return ds;
}
%>

<%
// PlatformData 
PlatformData out_PlatformData = new PlatformData();
	
int nErrorCode = 0;
String strErrorMsg = "START";

try {	
  	/******* JDBC Connection *******/
	Connection conn = null;
	Statement  stmt = null;
	ResultSet  rs   = null;

	Class.forName("org.sqlite.JDBC");
	conn = DriverManager.getConnection("jdbc:sqlite:C:\\Tomcat 7.0\\webapps\\edu\\Local_Edu.db3");

	stmt = conn.createStatement();

	String SQL;
    
    /******* ds_dept *************/
    SQL="SELECT * FROM DEPARTMENT"; 
    
	rs = stmt.executeQuery(SQL);
    out_PlatformData.addDataSet(Rs2Ds(rs,"ds_dept"));
   
	nErrorCode = 0;
	strErrorMsg = "SUCC";

	/******** JDBC Close ********/
	if ( stmt != null ) try { stmt.close(); } catch (Exception e) {nErrorCode = -1; strErrorMsg = e.getMessage();}
	if ( conn != null ) try { conn.close(); } catch (Exception e) {nErrorCode = -1; strErrorMsg = e.getMessage();}
			
} catch (Throwable th) {
	nErrorCode = -1;
	strErrorMsg = th.getMessage();
}

// VariableList 
VariableList varList = out_PlatformData.getVariableList();
		
// set VariableList
varList.add("ErrorCode", nErrorCode);
varList.add("ErrorMsg", strErrorMsg);

// HttpPlatformResponse
HttpPlatformResponse pRes = new HttpPlatformResponse(response, PlatformType.CONTENT_TYPE_XML, "UTF-8");
pRes.setData(out_PlatformData);

// send data
pRes.sendData();
%>
