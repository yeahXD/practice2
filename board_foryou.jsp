<%@ page contentType="text/html; charset=EUC-KR" pageEncoding="EUC-KR" %>
<%@ page language="java" import="java.util.*, java.sql.*, javax.servlet.http.*" %>
<%!
	Connection DB_Connection() throws ClassNotFoundException, SQLException, Exception
	{
		Class.forName("com.mysql.jdbc.Driver");
		Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/webdb", "root", "root");
		return conn;
	} 
	
	String TO_DB( String str ) throws Exception
	{
		if( str == null ) 
			return null;
		return new String( str.getBytes( "8859_1" ), "euc-kr" );
	}
%>

<%
	Connection conn = DB_Connection();
	Statement stmt = null;
	ResultSet rs = null;

	Integer productNumber = 0;
	String productName = null;
	Integer catgryNumber = 0;
	Integer productPrice = 0;
	String productImage = null;

	String str_c_page = request.getParameter( "str_c_page" );
	if( str_c_page == null ) 
		str_c_page = "1";
	int c_page = Integer.parseInt( str_c_page );

	int total_cnt = 0;
	int foryou_num = 10;
	int start = 0;
	int t_page = 0;

	String dbsearch = request.getParameter( "dbsearch" );
	if( dbsearch == null || dbsearch.trim( ).length( ) == 0 )
		dbsearch = "%";
	
	try
	{
		String sql_n = "select count(*) from Product ";
		sql_n += "where catgryNumber like '%" + dbsearch + "%'";

		stmt = conn.createStatement();
		rs = stmt.executeQuery( sql_n );

		if( rs.next() )
			total_cnt = rs.getInt(1);

		start = total_cnt - ( c_page - 1 ) * foryou_num;
		
	%>

<html>
<head>
        <meta http-equiv="content-type" content="text/html; charset=utf-8">
        <link rel="stylesheet" type="text/css" href="../css/mainStyle.css">
        <link href='https://fonts.googleapis.com/css?family=Poiret+One' rel='stylesheet' type='text/css'>
        <title>Beauty Inside</title>
        <script src="../scripts/jquery-1.11.2.js"></script>
        	<%
        		String exist = request.getParameter("exist");
        		if(exist == null){
        			
        		} else {
        			out.println("<script>alert('already exist in it')</script>");
        		}
        		
        	%>
        <script>
        	$(document).ready(function(){
        		$('#register').on('click',function(){
        			location.href='login_register.jsp';
        		});
        		$('.cart').on('click', function(event){
        			var pNumber = $(this).val();
        			var id = '<%=session.getAttribute("id") %>';
        			
        			if(id == null || id == "null"){
        				alert("Must Login");
        			} else {
        				location.href = "cartInsert.jsp?productNumber=" + pNumber;
        			}
        		});
        	});
        </script>
        <style>
        	#content_wrapper_div {
        		padding-top:130px;
        	}
        	#content_wrapper_div a {
        		color: #2f4f4f;
        	}
        	#content_wrapper_div .category {
        		color: white;
        	}
        	#wrapper_footer_div {
        		margin-top:130px;
        	}
        </style>
    </head>
    <body>
        <div id="wrapper_div">
            <div id="header_wrapper_div">
                <div id="header_div">
                    <span class="header_main">
                        <a href="main.jsp?id=<%=session.getAttribute("id")%>">Beauty Inside</a>
                    </span>
                    <span class="header_category">
                        <a href="board_foryou">For You</a>
                    </span>
                    <span class="header_category">
                        <a href="board_list.jsp">Shop</a>
                    </span>
                    <span class="header_category">
                        <a href="orderView.jsp">Order</a>
                    </span>
                    <span class="header_category">
                        <a href="cart.jsp">Cart</a>
                    </span>
                    <span class="header_category">
                        <a href="customerCare.jsp">Q&A</a>
                    </span>
                </div>
            </div>
            <div id="content_wrapper_div">
          	<table><tr><h1 align="center" style='color:#2f4f4f'>Shop</h1></tr></table>
	<table style = "width : 100%"><tr bgcolor="#2f4f4f"> 
<%
rs = stmt.executeQuery("select * from Category;");
while(rs.next()){
	Integer catgryNumber1 = rs.getInt("catgryNumber");
	String catgryName = rs.getString("catgryName");
%>
	<td><a class="category" href="board_foryou.jsp?dbsearch=<%=catgryNumber1%>"><%=catgryName%></td>
<%
	}
%></tr></table>
	<tr><td> Total Count : <%=total_cnt%></td><td><p align=right>Page:<%=c_page%> </td></tr>
	<table><tr>
<%
String Ls = "";
String id = "aaaa";
switch(dbsearch){
	case "1":
		Ls = "ProductNumber IN(Select productNumber from topsize where productlong IN(SELECT TLong from likesize where id = '" + id + "'));";
		break;
	case "2":
		Ls = "ProductNumber IN(Select productNumber from bottomsize where productlong IN(SELECT SLong from likesize where id = '" + id + "'));";
		break;
	case "3":
		Ls = "ProductNumber IN(Select productNumber from topsize where productlong IN(SELECT DLong from likesize where id = '" + id + "'));";
		break;
	case "4":
		Ls = "ProductNumber IN(Select productNumber from bottomsize where productlong IN(SELECT PLong from likesize where id = '" + id + "'));";
		break;
	case "5":
		Ls = "ProductNumber IN(Select productNumber from topsize where productlong IN(SELECT CLong from likesize where id = '" + id + "'));";
		break;
} 
rs = stmt.executeQuery("select * from Product where catgryNumber like '%" + dbsearch + "%' && " + Ls);
int title_len = 100;
int aid = start;
int cnt = 0;

while( rs.next() )
{
	productNumber = rs.getInt("productNumber");
	productName = rs.getString("productName");
	catgryNumber = rs.getInt("catgryNumber");
	productPrice = rs.getInt("productPrice");
	productImage = rs.getString("productImage");
	aid--;
%>
	<td>
		<p align=center>
			<a href = "<%=productImage%>.jsp">
				<img src="<%=productImage%>" width="250px" height="400px"><%=productName%>
			</a>
			<button value="<%=productNumber %>" class='cart'>Go to Cart</button>
		</p>
	</td>
<% 
	
		
	}
	stmt.close();
	rs.close();
}
catch( Exception e ) 
{
	out.println( e.toString() );
}
%>	</tr></table>
	</a></td></tr>
</table>
	</div>
            <div id="wrapper_footer_div">
                <div id="footer_div">
                    <div id="side_footer_div">
                        <a href="http://facebook.com">
                            <img src="../images/facebook.png">
                        </a>
                        <a href="http://twitter.com">
                            <img src="../images/twitter.png">
                        </a>
                        <a href="http://instagram.com">
                            <img src="../images/instagram.png">
                        </a>
                        <a href="logout.jsp">
                        	<img src="../images/logout.png">
                        </a>
                    </div>
                </div>
            </div>
        </div> 
    </body>
</html>