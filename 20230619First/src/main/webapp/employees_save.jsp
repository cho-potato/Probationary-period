<%@ page import="org.apache.commons.logging.*" %>

<%@ page import="com.tobesoft.xplatform.data.*" %>
<%@ page import="com.tobesoft.xplatform.tx.*" %>

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
// PlatformData 
PlatformData o_xpData = new PlatformData();
	
int nErrorCode = 0;
String strErrorMsg = "START";

// HttpPlatformRequest
HttpPlatformRequest pReq = new HttpPlatformRequest(request);
	
// XML parsing
pReq.receiveData();

// PlatformData
PlatformData i_xpData = pReq.getData();

// Get
VariableList in_vl = i_xpData.getVariableList();
String in_var2 = in_vl.getString("sVal1");
DataSet ds = i_xpData.getDataSet("in_ds");

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
	
		String SQL = "";
		int	i;
		
		//System.out.println(">>> SQL : " + ds.getRowCount());
		
		/******** Dataset(INSERT, UPDATE) ********/
		for(i=0;i<ds.getRowCount();i++)
		{
			int rowType = ds.getRowType(i);
			if( rowType == DataSet.ROW_TYPE_INSERTED )
			{
			  
				SQL = "INSERT INTO EMPLOYEES (EMPL_ID,FULL_NAME,DEPT_ID,HIRE_DATE,GENDER,MARRIED,SALARY,EMPL_MEMO) VALUES ( " +
							"'" + dsGet(ds,i,"EMPL_ID"   ) + "'," + 
							"'" + dsGet(ds,i,"FULL_NAME" ) + "'," + 
							"'" + dsGet(ds,i,"DEPT_ID"   ) + "'," +  
							"'" + dsGet(ds,i,"HIRE_DATE" ) + "'," +
							"'" + dsGet(ds,i,"GENDER"    ) + "'," +
							"'" + dsGet(ds,i,"MARRIED"   ) + "'," +
							"'" + dsGet(ds,i,"SALARY"    ) + "'," +				
							"'" + dsGet(ds,i,"EMPL_MEMO") + "' )";
							System.out.println(">>> insert : "+SQL);
			}
			else if( rowType == DataSet.ROW_TYPE_UPDATED )
			{
				String org_id = ds.getSavedData(i,"EMPL_ID").toString(); 
				SQL = "UPDATE EMPLOYEES SET " +
							"FULL_NAME      = '" + dsGet(ds,i,"FULL_NAME"  ) + "'," + 
							"DEPT_ID        = '" + dsGet(ds,i,"DEPT_ID"    ) + "'," +  
							"HIRE_DATE      = '" + dsGet(ds,i,"HIRE_DATE"  ) + "'," +
							"GENDER         = '" + dsGet(ds,i,"GENDER"     ) + "'," +
							"MARRIED        = '" + dsGet(ds,i,"MARRIED"    ) + "'," +
							"SALARY         = '" + dsGet(ds,i,"SALARY"     ) + "'," +
							"EMPL_MEMO      = '" + dsGet(ds,i,"EMPL_MEMO"  ) + "' " +
							"WHERE EMPL_ID = " + "'" + org_id + "'";
				System.out.println(">>> update : "+SQL);
			}
			rs = stmt.executeQuery(SQL);
		}
		/****** Dataset을 DELETE처리 ****/
		for( i = 0 ; i< ds.getRemovedRowCount() ; i++ )
		{
			String del_id = ds.getRemovedData(i,"EMPL_ID").toString();
			SQL = "DELETE FROM EMPLOYEES WHERE " +
					  "EMPL_ID = " + "'" + del_id + "'";
			rs = stmt.executeQuery(SQL);
		}
		
		//conn.commit();

	} catch (SQLException e) {
		// VariableList에 값을 직접 추가
		nErrorCode = -1;
		strErrorMsg = e.getMessage();
	}	
	
	/******** JDBC Close ********/
	if ( stmt != null ) try { stmt.close(); } catch (Exception e) {nErrorCode = -1; strErrorMsg = e.getMessage();}
	if ( conn != null ) try { conn.close(); } catch (Exception e) {nErrorCode = -1; strErrorMsg = e.getMessage();}
	
	nErrorCode = 0;
	strErrorMsg = "SUCC";
			
} catch (Throwable th) {
	nErrorCode = -1;
	strErrorMsg = th.getMessage();
}

// VariableList 참조
VariableList varList = o_xpData.getVariableList();
		
// VariableList에 값을 직접 추가
varList.add("ErrorCode", nErrorCode);
varList.add("ErrorMsg", strErrorMsg);

// HttpServletResponse를 이용하여 HttpPlatformResponse 생성
HttpPlatformResponse pRes = new HttpPlatformResponse(response, PlatformType.CONTENT_TYPE_XML, "UTF-8");
pRes.setData(o_xpData);

// 데이터 송신
pRes.sendData();
%>
