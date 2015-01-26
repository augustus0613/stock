<%-- 
    Document   : index
    Created on : 2013/6/25, 上午 09:07:03
    Author     : lawrence
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>股票篩選</title>
        <%-- EasyUI CSS --%>
        <link rel="stylesheet" type="text/css" href="http://www.jeasyui.com/easyui/themes/default/easyui.css">
        <link rel="stylesheet" type="text/css" href="http://www.jeasyui.com/easyui/themes/icon.css">
        <link rel="stylesheet" type="text/css" href="http://www.jeasyui.com/easyui/demo/demo.css">
        <%-- JQuery --%>
        <script type="text/javascript" src="http://code.jquery.com/jquery-1.6.min.js"></script>
        <%-- EasyUI --%>
        <script type="text/javascript" src="http://www.jeasyui.com/easyui/jquery.easyui.min.js"></script>
        <script type="text/javascript">

            // 查詢資料初始值
            var default_pe = 15;
            var default_yld = 6;
            var default_pb = 1;
            var default_roe = 5;
            var roeStockIdArray = new Array();

            $(function() {

//                $.post('<%=request.getContextPath()%>/web/test.do', {
//                }, function(data) {
//                    console.log(data);
//                },'html')


                $('#dg').datagrid({
                    method: 'post',
                    url: '<%=request.getContextPath()%>/web/load/protoContent.do'
                });
//                $.post('<%=request.getContextPath()%>/web/load/protoContent.do', {
//                }, function(data) {
//                }, 'json');


                // 本益比
                $("#inputPE").val(default_pe);
                // 殖利率
                $("#inputYLD").val(default_yld);
                // 股價淨值比
                $("#inputPB").val(default_pb);
                // 股東權益報酬率
                $("#inputROE").val(default_roe);

                loadROEData(default_roe);
                searchByCondition(default_pe, default_yld, default_pb, default_roe);


                // 點選查詢
                $("#search").bind("click", function() {

                    $('#showResult').html("");
                    // $('#tbl-containerx table tbody').find('td').css('background-color', 'white');

                    var pe = $("#inputPE").val();
                    var yld = $("#inputYLD").val();
                    var pb = $("#inputPB").val();
                    var roe = $("#inputROE").val();
                    console.log('roe:' + roe);
                    refreshRoeArray(roe);

                    // 以選擇的條件查詢
                    searchByCondition(pe, yld, pb, roe);

                });  // $("#search").bind("click", function()

            }); //  $(function() {


            // 重新讀取 iframe 頁面
            function reloadIframe(roe) {
                loadROEData(roe);
                loadProtoData();
            }


            function loadROEData(roe) {
                // 讀入股東權益報酬率
                $('#loadROEContent').load(function() {
                    var iframe = $(this);
                    var contents = iframe.contents();

                    $('#roeDataTable').html(contents.find('table').html());
                    $('#roeDataTable').trigger("create");

                    refreshRoeArray(roe);

                }); // $('#loadProtoContent').load(function() 
            }

            function refreshRoeArray(roe) {
                roeStockIdArray = new Array();
                $('#roeDataTable tr').each(function(tr, item) {
                    // console.log(tr);
                    if (tr > 1) {
                        console.log('roe: ' + roe);
                        console.log('this roe: ' + $(this).find('td').eq(4).html());
                        if (parseFloat($(this).find('td').eq(4).html()) >= roe) {
                            var aHref = $(this).find('a').attr('href');
                            var roeStockId = aHref.substring(aHref.indexOf('\'') + 1, aHref.lastIndexOf('\''));
                            console.log('roeStockId:' + roeStockId);
                            roeStockIdArray.push(roeStockId);
                        }
                    }
                });
            }

            function loadProtoData() {
                // 讀入原始資料
                $('#loadProtoContent').load(function() {
                    var iframe = $(this);
                    var contents = iframe.contents();
                    alert(contents);
                    $('#dataTable').html(contents.find('#html').val());
                    $('#dataTable').trigger("create");

                }); // $('#loadProtoContent').load(function() 
            }


            // 查詢設定調        
            function searchByCondition(pe, yld, pb, roe) {

                pe = (pe == "") || (pe == undefined) || (pe == NaN) ? 0 : parseFloat(pe);
                yld = (yld == "") || (yld == undefined) || (yld == NaN) ? 0 : parseFloat(yld);
                pb = (pb == "") || (pb == undefined) || (pb == NaN) ? 0 : parseFloat(pb);
                roe = (roe == "") || (roe == undefined) || (roe == NaN) ? 0 : parseFloat(roe);

                //console.log("pe = " + pe);
                //console.log("yld = " + yld);
                //console.log("pb = " + pb);
                //console.log("roe = " + roe);

                $('#showResult').html("");
                //$('#tbl-containerx table tbody').find('td').css('background-color', 'white');

                $('#showResult').append('<div>目前條件: <br>本益比 &lt; ' + pe + ' % <br>殖利率 &gt; ' + yld + ' % <br>股價淨值比 &lt; ' + pb + ' %<br>股價淨值比 &gt; ' + roe + ' %</div><br>');
                $('#showResult').append('<div>以下股票四項指標皆符合標準</div>');
                /*
                $('#tbl-containerx table tbody').find('tr').each(function(i, item) {
                    var stockId = $(this).find('td').eq(0).html();
                    var name = $(this).find('td').eq(1).html();

                    // 本益比
                    var price_earnings = parseFloat($(this).find('td').eq(2).html());
                    // 殖利率
                    var yield = parseFloat($(this).find('td').eq(3).html());
                    // 股價淨值比
                    var price_book_ratio = parseFloat($(this).find('td').eq(4).html());

                    console.log('price_earnings = ' + price_earnings + ', yield = ' + yield + ', price_book_ratio = ' + price_book_ratio);
                    if (roeStockIdArray.indexOf(stockId) > 0) {
                        $(this).find('td').eq(0).css('background-color', 'yellow');
                    }

                    if (price_earnings <= pe) {
                        $(this).find('td').eq(2).css('background-color', 'deepskyblue');
                    } // if (parseFloat($(this).find('td').eq(2).html())){}

                    if (yield >= yld) {
                        $(this).find('td').eq(3).css('background-color', 'deepskyblue');
                    } // if (parseFloat($(this).find('td').eq(3).html())){}

                    if (price_book_ratio <= pb) {
                        $(this).find('td').eq(4).css('background-color', 'deepskyblue');
                    } // if (parseFloat($(this).find('td').eq(3).html())){}


                    if (price_earnings <= pe && yield >= yld && price_book_ratio <= pb && roeStockIdArray.indexOf(stockId) > 0) {
                        $(this).find('td').css('background-color', 'red');
                        $('#showResult').append('<div>' + $(this).find('td').eq(0).html() + '&nbsp;&nbsp;&nbsp;' + name + '</div>');
                    }

                }); // $('#tbl-containerx table tbody').find('tr').each(function(i, item)
                */
               
                $('.datagrid-btable tbody').find('tr').each(function(i, item) {
                    var stockId = $(this).find('td').eq(0).find('div').eq(0).html();
                    var name = $(this).find('td').eq(1).find('div').eq(0).html();
                    // 本益比
                    var price_earnings = parseFloat($(this).find('td').eq(2).find('div').eq(0).html());
                    // 殖利率
                    var yield = parseFloat($(this).find('td').eq(3).find('div').eq(0).html());
                    // 股價淨值比
                    var price_book_ratio = parseFloat($(this).find('td').eq(4).find('div').eq(0).html());

                    //console.log('stockId: ' + stockId + ', name: ' + name + ', price_earnings = ' + price_earnings + ', yield = ' + yield + ', price_book_ratio = ' + price_book_ratio);
                    //console.log(roeStockIdArray);
                    
                    var conditionPassedCount = 0;
                    if (price_earnings <= pe) {
                        $(this).find('td').eq(2).css('background-color', 'deepskyblue');
                        conditionPassedCount++;
                    } // if (parseFloat($(this).find('td').eq(2).html())){}

                    if (yield >= yld) {
                        $(this).find('td').eq(3).css('background-color', 'deepskyblue');
                        conditionPassedCount++;
                    } // if (parseFloat($(this).find('td').eq(3).html())){}

                    if (price_book_ratio <= pb) {
                        $(this).find('td').eq(4).css('background-color', 'deepskyblue');
                        conditionPassedCount++;
                    } // if (parseFloat($(this).find('td').eq(3).html())){}

                    if (roeStockIdArray.indexOf(stockId) > 0) {
                        $(this).find('td').eq(5).css('background-color', 'deepskyblue');
                        conditionPassedCount++;
                    }

                    if (conditionPassedCount == 4) {
                        $(this).find('td').eq(0).css('background-color', 'yellow');
                        $('#showResult').append('<div>' + $(this).find('td').eq(0).find('div').eq(0).html() + '&nbsp;&nbsp;&nbsp;' + name + '</div>');
                    }

                }); // $('#tbl-containerx table tbody').find('tr').each(function(i, item)
               
               
            } // function searchByCondition(pe, yld, pb)

        </script>
    </head>
    <body>

        <iframe id="loadProtoContent" style="display: none;" src="<%=request.getContextPath()%>/web/load/protoContent.do"></iframe>

        <iframe id="loadROEContent" style="display: none;" src="<%=request.getContextPath()%>/web/load/roeData.do?roeGreaterThan=5"></iframe>

        <div style="width: 500px;float: left;">
            <table id="dg" title="Stock Data List"
                   fitColumns="true"
                   pagination="false" 
                   singleSelect="true"
                   height="auto">
                <thead>
                    <tr>
                        <th field="stockId">Stock ID</th>
                        <th field="name">Name</th>
                        <th field="pe">PE</th>
                        <th field="yld">YLD</th>
                        <th field="pb">PB</th>
                        <th field="roe">ROE</th>
                    </tr>
                </thead>
            </table>
        </div>


        <%-- 資料表格 --%>
        <div id="dataTable" style="float: left;"></div>

        <%-- 股東權益報酬率表格 --%>
        <div id="roeDataTable" style="display:none; float: left;"></div>


        <div id="rightArea" style="width: 200px; float: left; margin-left: 30px;">

            <div id="conditions" style="hieght: 150x;">
                本益比 &lt; <input type="text" id="inputPE" style="width: 50px;" /> <br>
                殖利率 &gt; <input type="text" id="inputYLD" style="width: 50px;" /> % <br> 
                股價淨值比 &lt; <input type="text" id="inputPB" style="width: 50px;" /> <br> 
                股東權益報酬率 &gt; <select id="inputROE" style="width: 50px;" >
                    <option value="5">5</option>
                    <option value="10">10</option>
                    <option value="12">12</option>
                    <option value="15">15</option>
                </select> <br> 
                <input type="button" id="search" value="查詢" />
            </div> <%-- conditions --%>

            <br>

            <%-- 篩選結果 --%>
            <div id="showResult"></div>

        </div> <%-- rightArea --%>

    </body>
</html>