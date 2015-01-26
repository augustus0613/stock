/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.stockanalyzer.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.http.HttpServletResponse;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 *
 * @author lawrence
 */
@Controller
@RequestMapping("/web")
public class WebController {

    @RequestMapping("/test.do")
    @ResponseBody
    public String test() {
        String tempContent = null;
        try {
            String roeWebURL = "http://fund.bot.com.tw/z/zk/zk5/zkparse_860_5.djhtm";// UTF-8

            URL roeWebAddress = new URL(roeWebURL);

            // 讀入網頁(字元串流)
            BufferedReader bufferedReader_1 = new BufferedReader(new InputStreamReader(roeWebAddress.openStream(), "BIG5"));

            StringBuilder allHtmlContent = new StringBuilder("");
            String readIn = "";

            while ((readIn = bufferedReader_1.readLine()) != null) {
                allHtmlContent.append(readIn);
            }

            int tempContentStartWordIndex = allHtmlContent.indexOf("<td class=zkt01>") + "<td class=zkt01>".length();
            tempContent = allHtmlContent.substring(tempContentStartWordIndex);
            int tempContentEndWordIndex = tempContent.indexOf("</table>") + "</table>".length();
            tempContent = tempContent.substring(0, tempContentEndWordIndex);

            JSONObject table = new JSONObject();
            if (tempContent.startsWith("<table")) {
                int table_starttag_end = tempContent.indexOf(">", "<table".length() + 1);
                tempContent = tempContent.replace(tempContent.substring(0, table_starttag_end + 1), "");
                tempContent = tempContent.replace("</table>", "");
            }


            StringBuilder table_sb = new StringBuilder(tempContent);
            while (table_sb.toString().trim().startsWith("<tr")) {

                table = catchTr(table, table_sb);

            }

            System.out.println("table = " + table.toString());

        } catch (IOException e) {
            e.printStackTrace();
        }
        return tempContent;

//            JSONObject table = new JSONObject();
    }

    public JSONObject catchTr(JSONObject table, StringBuilder targetContent) {

        JSONObject tr = new JSONObject();
        // 移除 tr 的開始 tag
        targetContent = targetContent.replace(0, targetContent.indexOf(">") + 1, "");

        // 移除 tr 的結束 tag
        targetContent = targetContent.replace(targetContent.indexOf("</tr>"), targetContent.indexOf("</tr>") + "</tr>".length(), "");

        // 開頭應為 <td>
        targetContent = targetContent.replace(0, targetContent.length(), targetContent.toString().trim());

        while (targetContent.toString().trim().startsWith("<td")) {
            tr = catchTdData(tr, targetContent);
        }

        table.put("tr" + table.size(), tr);
        return table;
    }

    public JSONObject catchTdData(JSONObject tr, StringBuilder targetContent) {

        int td_starttag_end = targetContent.indexOf(">", targetContent.indexOf("<td") + 1);
        int td_endtag_start = targetContent.indexOf("</td", td_starttag_end);
        String td_text = targetContent.substring(td_starttag_end + 1, td_endtag_start);

//        System.out.println("td_text = " + td_text);
//        System.out.println("xxxx = " + td_text.indexOf("\'") + 1);
//        System.out.println("yyyy = " + td_text.lastIndexOf("\'"));
        if (td_text.indexOf("'") > 0) {
            if (tr.isEmpty()) {
                td_text = td_text.substring(td_text.indexOf("\'") + 1, td_text.lastIndexOf("\'"));
            }
        }
        tr.put("td" + tr.size(), td_text);

        int td_endtag_whole = targetContent.indexOf("</td>") + "</td>".length();
        String contentAfter = targetContent.substring(td_endtag_whole);

        targetContent = targetContent.replace(0, targetContent.length(), contentAfter.trim());

        return tr;
    }

    @RequestMapping("/load/protoContent.do")
    @ResponseBody
    public String laodProtoContent(HttpServletResponse response) {

        JSONObject finalResult = new JSONObject();
        JSONArray array = new JSONArray();
        String tempContent = null;
        Map<String, String> roe_map = new HashMap<String, String>();
        try {
            String roeWebURL = "http://fund.bot.com.tw/z/zk/zk5/zkparse_860_5.djhtm";// UTF-8

            URL roeWebAddress = new URL(roeWebURL);

            // 讀入網頁(字元串流)
            BufferedReader bufferedReader_1 = new BufferedReader(new InputStreamReader(roeWebAddress.openStream(), "BIG5"));

            StringBuilder allHtmlContent = new StringBuilder("");
            String readIn = "";

            while ((readIn = bufferedReader_1.readLine()) != null) {
                allHtmlContent.append(readIn);
            }

            int tempContentStartWordIndex = allHtmlContent.indexOf("<td class=zkt01>") + "<td class=zkt01>".length();
            tempContent = allHtmlContent.substring(tempContentStartWordIndex);
            int tempContentEndWordIndex = tempContent.indexOf("</table>") + "</table>".length();
            tempContent = tempContent.substring(0, tempContentEndWordIndex);

            JSONObject table = new JSONObject();
            if (tempContent.startsWith("<table")) {
                int table_starttag_end = tempContent.indexOf(">", "<table".length() + 1);
                tempContent = tempContent.replace(tempContent.substring(0, table_starttag_end + 1), "");
                tempContent = tempContent.replace("</table>", "");
            }


            StringBuilder table_sb = new StringBuilder(tempContent);
            while (table_sb.toString().trim().startsWith("<tr")) {

                table = catchTr(table, table_sb);

            }

            for (int i = 0; i < table.size(); i++) {
                JSONObject tr = table.getJSONObject("tr" + i);

                roe_map.put((String) tr.get("td0"), (String) tr.get("td4"));

            }



// --------------------------------------------------------------------------------------------------------------------------------------------------------------------
            String web1 = "http://www.twse.com.tw/ch/trading/exchange/BWIBBU/BWIBBU_d.php"; // UTF-8

            URL url_address = new URL(web1);

            // 讀入網頁(字元串流)
            BufferedReader br = new BufferedReader(new InputStreamReader(url_address.openStream(), "BIG5"));

            StringBuilder oneLine = new StringBuilder("");
            String append = "";

            while ((append = br.readLine()) != null) {
                oneLine.append(append);
            }

            int start = oneLine.indexOf("<!------ START of 交易資訊 > 盤後資訊 > 個股日本益比、殖利率及股價淨值比 --->");
            int end = oneLine.indexOf("<!------ end of 交易資訊 > 盤後資訊 > 個股日本益比、殖利率及股價淨值比 --->");
            String result = oneLine.substring(start, end);

            String result2 = result.substring(result.indexOf("<div"), result.lastIndexOf("</div>") + "</div>".length());

//            result2 = result2.substring(result2.indexOf("1101</td>"), result2.lastIndexOf("</tbody>"));
            result2 = result2.substring(result2.indexOf("1101</td>"), result2.lastIndexOf("<thead>"));
            result2 = result2.replaceAll("\\<.*?>", ",");
            result2 = result2.replaceAll("[,]+", ",");

//            System.out.println("result2 = " + result2);

            String[] resultArray = result2.split(",");

            JSONObject json = null;
            for (int i = 0; i < resultArray.length; i++) {
                int order = i % 5;

                switch (order) {
                    case 5:
                        json = new JSONObject();
                        json.put("stockId", resultArray[i]);
                        String roe_value = roe_map.get(resultArray[i]);
                        json.put("roe", roe_value);
                        break;
                    case 0:
                        json = new JSONObject();
                        json.put("stockId", resultArray[i]);
                        String roe_value2 = roe_map.get(resultArray[i]);
                        json.put("roe", roe_value2);
                        break;
                    case 1:
                        json.put("name", resultArray[i]);
                        break;
                    case 2:
                        json.put("pe", resultArray[i]);
                        break;
                    case 3:
                        json.put("yld", resultArray[i]);
                        break;
                    case 4:
                        json.put("pb", resultArray[i]);
                        array.add(json);
                        break;
                }
            }

        } catch (MalformedURLException ex) {
            Logger.getLogger(WebController.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException e) {
            Logger.getLogger(WebController.class.getName()).log(Level.SEVERE, null, e);
        }

        finalResult.put(
                "rows", array);
        return finalResult.toString();
    }
//    public Map<String, Float> getEachRoeStockId(String tempContent, Map<String, Float> stockIdRoeMap) {
//
//        String getRoeStockId = tempContent.substring(tempContent.indexOf("javascript:Link2Stk('") + "javascript:Link2Stk('".length());
//        getRoeStockId = getRoeStockId.substring(0, tempContent.indexOf("'"));
//
//
//    }

    @RequestMapping("/load/roeData.do")
    public void loadRoeData(HttpServletResponse response, Integer roeGreaterThan) {
        try {
            System.out.println("roeGreaterThan = " + roeGreaterThan);

            String roeWebURL = "http://fund.bot.com.tw/z/zk/zk5/zkparse_860_" + roeGreaterThan + ".djhtm";// UTF-8

            URL roeWebAddress = new URL(roeWebURL);

            // 讀入網頁(字元串流)
            BufferedReader br = new BufferedReader(new InputStreamReader(roeWebAddress.openStream(), "BIG5"));


            StringBuilder allContent = new StringBuilder("");
            String append = "";

            while ((append = br.readLine()) != null) {
                allContent.append(append);
            }

            int tempContentStartWordIndex = allContent.indexOf("<td class=zkt01>") + "<td class=zkt01>".length();
            String tempContent = allContent.substring(tempContentStartWordIndex);
            int tempContentEndWordIndex = tempContent.indexOf("</table>");
            tempContent = tempContent.substring(0, tempContentEndWordIndex);


            String result = tempContent;

            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.write(result);



        } catch (MalformedURLException ex) {
            Logger.getLogger(WebController.class
                    .getName()).log(Level.SEVERE, null, ex);
        } catch (IOException e) {
            Logger.getLogger(WebController.class
                    .getName()).log(Level.SEVERE, null, e);
        }
    }
}
