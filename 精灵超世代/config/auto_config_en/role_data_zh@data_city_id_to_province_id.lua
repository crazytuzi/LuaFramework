-- this file is generated by program!
-- don't change it manaully.
-- source file: role_data_zh.xls

Config = Config or {}
Config.RoleDataZh = Config.RoleDataZh or {}
Config.RoleDataZh.data_city_id_to_province_id_key_depth = 1
Config.RoleDataZh.data_city_id_to_province_id_length = 476
Config.RoleDataZh.data_city_id_to_province_id_lan = "en"
Config.RoleDataZh.data_city_id_to_province_id_cache = {}
Config.RoleDataZh.data_city_id_to_province_id = function(key)
	if Config.RoleDataZh.data_city_id_to_province_id_cache[key] == nil then
		local base = Config.RoleDataZh.data_city_id_to_province_id_table[key]
		if not base then return end
		Config.RoleDataZh.data_city_id_to_province_id_cache[key] = {
			city_name = base[1], --预留注释
			province_id = base[2], --预留注释
			province_name = base[3], --预留注释
		}
	end
	return Config.RoleDataZh.data_city_id_to_province_id_cache[key] 
end

Config.RoleDataZh.data_city_id_to_province_id_table = {
	[101] = {"东城", 1, "北京市"},
	[102] = {"西城", 1, "北京市"},
	[103] = {"朝阳", 1, "北京市"},
	[104] = {"丰台", 1, "北京市"},
	[105] = {"石景山", 1, "北京市"},
	[106] = {"海淀", 1, "北京市"},
	[107] = {"门头沟", 1, "北京市"},
	[108] = {"房山", 1, "北京市"},
	[109] = {"通州", 1, "北京市"},
	[110] = {"顺义", 1, "北京市"},
	[111] = {"昌平", 1, "北京市"},
	[112] = {"大兴", 1, "北京市"},
	[113] = {"怀柔", 1, "北京市"},
	[114] = {"平谷", 1, "北京市"},
	[115] = {"密云", 1, "北京市"},
	[116] = {"延庆", 1, "北京市"},
	[201] = {"河西", 2, "天津市"},
	[202] = {"和平", 2, "天津市"},
	[203] = {"河东", 2, "天津市"},
	[204] = {"南开", 2, "天津市"},
	[205] = {"河北", 2, "天津市"},
	[206] = {"红桥", 2, "天津市"},
	[207] = {"滨海新", 2, "天津市"},
	[208] = {"东丽", 2, "天津市"},
	[209] = {"西青", 2, "天津市"},
	[210] = {"津南", 2, "天津市"},
	[211] = {"北辰", 2, "天津市"},
	[212] = {"宁河", 2, "天津市"},
	[213] = {"武清", 2, "天津市"},
	[214] = {"静海", 2, "天津市"},
	[215] = {"宝坻", 2, "天津市"},
	[216] = {"蓟县", 2, "天津市"},
	[301] = {"石家庄市", 3, "河北"},
	[302] = {"唐山市", 3, "河北"},
	[303] = {"秦皇岛市", 3, "河北"},
	[304] = {"邯郸市", 3, "河北"},
	[305] = {"邢台市", 3, "河北"},
	[306] = {"保定市", 3, "河北"},
	[307] = {"张家口市", 3, "河北"},
	[308] = {"承德市", 3, "河北"},
	[309] = {"沧州市", 3, "河北"},
	[310] = {"廊坊市", 3, "河北"},
	[311] = {"衡水市", 3, "河北"},
	[401] = {"太原市", 4, "山西"},
	[402] = {"大同市", 4, "山西"},
	[403] = {"阳泉市", 4, "山西"},
	[404] = {"长治市", 4, "山西"},
	[405] = {"晋城市", 4, "山西"},
	[406] = {"朔州市", 4, "山西"},
	[407] = {"晋中市", 4, "山西"},
	[408] = {"运城市", 4, "山西"},
	[409] = {"忻州市", 4, "山西"},
	[410] = {"临汾市", 4, "山西"},
	[411] = {"吕梁市", 4, "山西"},
	[501] = {"呼和浩特市", 5, "内蒙古"},
	[502] = {"包头市", 5, "内蒙古"},
	[503] = {"乌海市", 5, "内蒙古"},
	[504] = {"赤峰市", 5, "内蒙古"},
	[505] = {"通辽市", 5, "内蒙古"},
	[506] = {"鄂尔多斯市", 5, "内蒙古"},
	[507] = {"呼伦贝尔市", 5, "内蒙古"},
	[508] = {"巴彦淖尔市", 5, "内蒙古"},
	[509] = {"乌兰察布市", 5, "内蒙古"},
	[510] = {"兴安盟", 5, "内蒙古"},
	[511] = {"锡林郭勒盟", 5, "内蒙古"},
	[512] = {"阿拉善盟", 5, "内蒙古"},
	[601] = {"沈阳市", 6, "辽宁"},
	[602] = {"大连市", 6, "辽宁"},
	[603] = {"鞍山市", 6, "辽宁"},
	[604] = {"抚顺市", 6, "辽宁"},
	[605] = {"本溪市", 6, "辽宁"},
	[606] = {"丹东市", 6, "辽宁"},
	[607] = {"锦州市", 6, "辽宁"},
	[608] = {"营口市", 6, "辽宁"},
	[609] = {"阜新市", 6, "辽宁"},
	[610] = {"辽阳市", 6, "辽宁"},
	[611] = {"盘锦市", 6, "辽宁"},
	[612] = {"铁岭市", 6, "辽宁"},
	[613] = {"朝阳市", 6, "辽宁"},
	[614] = {"葫芦岛市", 6, "辽宁"},
	[701] = {"长春市", 7, "吉林"},
	[702] = {"吉林市", 7, "吉林"},
	[703] = {"四平市", 7, "吉林"},
	[704] = {"辽源市", 7, "吉林"},
	[705] = {"通化市", 7, "吉林"},
	[706] = {"白山市", 7, "吉林"},
	[707] = {"松原市", 7, "吉林"},
	[708] = {"白城市", 7, "吉林"},
	[709] = {"延边", 7, "吉林"},
	[801] = {"哈尔滨市", 8, "黑龙江"},
	[802] = {"齐齐哈尔市", 8, "黑龙江"},
	[803] = {"鸡西市", 8, "黑龙江"},
	[804] = {"鹤岗市", 8, "黑龙江"},
	[805] = {"双鸭山市", 8, "黑龙江"},
	[806] = {"大庆市", 8, "黑龙江"},
	[807] = {"伊春市", 8, "黑龙江"},
	[808] = {"佳木斯市", 8, "黑龙江"},
	[809] = {"七台河市", 8, "黑龙江"},
	[810] = {"牡丹江市", 8, "黑龙江"},
	[811] = {"黑河市", 8, "黑龙江"},
	[812] = {"绥化市", 8, "黑龙江"},
	[813] = {"大兴安岭", 8, "黑龙江"},
	[901] = {"黄浦", 9, "上海市"},
	[902] = {"卢湾", 9, "上海市"},
	[903] = {"徐汇", 9, "上海市"},
	[904] = {"长宁", 9, "上海市"},
	[905] = {"静安", 9, "上海市"},
	[906] = {"闸北", 9, "上海市"},
	[907] = {"普陀", 9, "上海市"},
	[908] = {"虹口", 9, "上海市"},
	[909] = {"杨浦", 9, "上海市"},
	[910] = {"闵行", 9, "上海市"},
	[911] = {"宝山", 9, "上海市"},
	[912] = {"嘉定", 9, "上海市"},
	[913] = {"浦东新", 9, "上海市"},
	[914] = {"金山", 9, "上海市"},
	[915] = {"松江", 9, "上海市"},
	[916] = {"奉贤", 9, "上海市"},
	[917] = {"青浦", 9, "上海市"},
	[918] = {"崇明", 9, "上海市"},
	[1001] = {"南京市", 10, "江苏"},
	[1002] = {"无锡市", 10, "江苏"},
	[1003] = {"徐州市", 10, "江苏"},
	[1004] = {"常州市", 10, "江苏"},
	[1005] = {"苏州市", 10, "江苏"},
	[1006] = {"南通市", 10, "江苏"},
	[1007] = {"连云港市", 10, "江苏"},
	[1008] = {"淮安市", 10, "江苏"},
	[1009] = {"盐城市", 10, "江苏"},
	[1010] = {"扬州市", 10, "江苏"},
	[1011] = {"镇江市", 10, "江苏"},
	[1012] = {"泰州市", 10, "江苏"},
	[1013] = {"宿迁市", 10, "江苏"},
	[1101] = {"杭州市", 11, "浙江"},
	[1102] = {"宁波市", 11, "浙江"},
	[1103] = {"温州市", 11, "浙江"},
	[1104] = {"嘉兴市", 11, "浙江"},
	[1105] = {"湖州市", 11, "浙江"},
	[1106] = {"绍兴市", 11, "浙江"},
	[1107] = {"金华市", 11, "浙江"},
	[1108] = {"衢州市", 11, "浙江"},
	[1109] = {"舟山市", 11, "浙江"},
	[1110] = {"台州市", 11, "浙江"},
	[1111] = {"丽水市", 11, "浙江"},
	[1201] = {"合肥市", 12, "安徽"},
	[1202] = {"芜湖市", 12, "安徽"},
	[1203] = {"蚌埠市", 12, "安徽"},
	[1204] = {"淮南市", 12, "安徽"},
	[1205] = {"马鞍山市", 12, "安徽"},
	[1206] = {"淮北市", 12, "安徽"},
	[1207] = {"铜陵市", 12, "安徽"},
	[1208] = {"安庆市", 12, "安徽"},
	[1209] = {"黄山市", 12, "安徽"},
	[1210] = {"滁州市", 12, "安徽"},
	[1211] = {"阜阳市", 12, "安徽"},
	[1212] = {"宿州市", 12, "安徽"},
	[1213] = {"六安市", 12, "安徽"},
	[1214] = {"亳州市", 12, "安徽"},
	[1215] = {"池州市", 12, "安徽"},
	[1216] = {"宣城市", 12, "安徽"},
	[1301] = {"福州市", 13, "福建"},
	[1302] = {"厦门市", 13, "福建"},
	[1303] = {"莆田市", 13, "福建"},
	[1304] = {"三明市", 13, "福建"},
	[1305] = {"泉州市", 13, "福建"},
	[1306] = {"漳州市", 13, "福建"},
	[1307] = {"南平市", 13, "福建"},
	[1308] = {"龙岩市", 13, "福建"},
	[1309] = {"宁德市", 13, "福建"},
	[1401] = {"南昌市", 14, "江西"},
	[1402] = {"景德镇市", 14, "江西"},
	[1403] = {"萍乡市", 14, "江西"},
	[1404] = {"九江市", 14, "江西"},
	[1405] = {"新余市", 14, "江西"},
	[1406] = {"鹰潭市", 14, "江西"},
	[1407] = {"赣州市", 14, "江西"},
	[1408] = {"吉安市", 14, "江西"},
	[1409] = {"宜春市", 14, "江西"},
	[1410] = {"抚州市", 14, "江西"},
	[1411] = {"上饶市", 14, "江西"},
	[1501] = {"济南市", 15, "山东"},
	[1502] = {"青岛市", 15, "山东"},
	[1503] = {"淄博市", 15, "山东"},
	[1504] = {"枣庄市", 15, "山东"},
	[1505] = {"东营市", 15, "山东"},
	[1506] = {"烟台市", 15, "山东"},
	[1507] = {"潍坊市", 15, "山东"},
	[1508] = {"济宁市", 15, "山东"},
	[1509] = {"泰安市", 15, "山东"},
	[1510] = {"威海市", 15, "山东"},
	[1511] = {"日照市", 15, "山东"},
	[1512] = {"莱芜市", 15, "山东"},
	[1513] = {"临沂市", 15, "山东"},
	[1514] = {"德州市", 15, "山东"},
	[1515] = {"聊城市", 15, "山东"},
	[1516] = {"滨州市", 15, "山东"},
	[1517] = {"菏泽市", 15, "山东"},
	[1601] = {"郑州市", 16, "河南"},
	[1602] = {"开封市", 16, "河南"},
	[1603] = {"洛阳市", 16, "河南"},
	[1604] = {"平顶山市", 16, "河南"},
	[1605] = {"安阳市", 16, "河南"},
	[1606] = {"鹤壁市", 16, "河南"},
	[1607] = {"新乡市", 16, "河南"},
	[1608] = {"焦作市", 16, "河南"},
	[1609] = {"濮阳市", 16, "河南"},
	[1610] = {"许昌市", 16, "河南"},
	[1611] = {"漯河市", 16, "河南"},
	[1612] = {"三门峡市", 16, "河南"},
	[1613] = {"南阳市", 16, "河南"},
	[1614] = {"商丘市", 16, "河南"},
	[1615] = {"信阳市", 16, "河南"},
	[1616] = {"周口市", 16, "河南"},
	[1617] = {"驻马店市", 16, "河南"},
	[1618] = {"济源市", 16, "河南"},
	[1701] = {"武汉市", 17, "湖北"},
	[1702] = {"黄石市", 17, "湖北"},
	[1703] = {"十堰市", 17, "湖北"},
	[1704] = {"宜昌市", 17, "湖北"},
	[1705] = {"襄阳市", 17, "湖北"},
	[1706] = {"鄂州市", 17, "湖北"},
	[1707] = {"荆门市", 17, "湖北"},
	[1708] = {"孝感市", 17, "湖北"},
	[1709] = {"荆州市", 17, "湖北"},
	[1710] = {"黄冈市", 17, "湖北"},
	[1711] = {"咸宁市", 17, "湖北"},
	[1712] = {"随州市", 17, "湖北"},
	[1713] = {"恩施", 17, "湖北"},
	[1714] = {"仙桃市", 17, "湖北"},
	[1715] = {"潜江市", 17, "湖北"},
	[1716] = {"天门市", 17, "湖北"},
	[1717] = {"神农架", 17, "湖北"},
	[1801] = {"长沙市", 18, "湖南"},
	[1802] = {"株洲市", 18, "湖南"},
	[1803] = {"湘潭市", 18, "湖南"},
	[1804] = {"衡阳市", 18, "湖南"},
	[1805] = {"邵阳市", 18, "湖南"},
	[1806] = {"岳阳市", 18, "湖南"},
	[1807] = {"常德市", 18, "湖南"},
	[1808] = {"张家界市", 18, "湖南"},
	[1809] = {"益阳市", 18, "湖南"},
	[1810] = {"郴州市", 18, "湖南"},
	[1811] = {"永州市", 18, "湖南"},
	[1812] = {"怀化市", 18, "湖南"},
	[1813] = {"娄底市", 18, "湖南"},
	[1814] = {"湘西", 18, "湖南"},
	[1901] = {"广州市", 19, "广东"},
	[1902] = {"韶关市", 19, "广东"},
	[1903] = {"深圳市", 19, "广东"},
	[1904] = {"珠海市", 19, "广东"},
	[1905] = {"汕头市", 19, "广东"},
	[1906] = {"佛山市", 19, "广东"},
	[1907] = {"江门市", 19, "广东"},
	[1908] = {"湛江市", 19, "广东"},
	[1909] = {"茂名市", 19, "广东"},
	[1910] = {"肇庆市", 19, "广东"},
	[1911] = {"惠州市", 19, "广东"},
	[1912] = {"梅州市", 19, "广东"},
	[1913] = {"汕尾市", 19, "广东"},
	[1914] = {"河源市", 19, "广东"},
	[1915] = {"阳江市", 19, "广东"},
	[1916] = {"清远市", 19, "广东"},
	[1917] = {"东莞市", 19, "广东"},
	[1918] = {"中山市", 19, "广东"},
	[1919] = {"潮州市", 19, "广东"},
	[1920] = {"揭阳市", 19, "广东"},
	[1921] = {"云浮市", 19, "广东"},
	[2001] = {"南宁市", 20, "广西"},
	[2002] = {"柳州市", 20, "广西"},
	[2003] = {"桂林市", 20, "广西"},
	[2004] = {"梧州市", 20, "广西"},
	[2005] = {"北海市", 20, "广西"},
	[2006] = {"防城港市", 20, "广西"},
	[2007] = {"钦州市", 20, "广西"},
	[2008] = {"贵港市", 20, "广西"},
	[2009] = {"玉林市", 20, "广西"},
	[2010] = {"百色市", 20, "广西"},
	[2011] = {"贺州市", 20, "广西"},
	[2012] = {"河池市", 20, "广西"},
	[2013] = {"来宾市", 20, "广西"},
	[2014] = {"崇左市", 20, "广西"},
	[2101] = {"海口市", 21, "海南"},
	[2102] = {"三亚市", 21, "海南"},
	[2103] = {"三沙市", 21, "海南"},
	[2104] = {"儋州市", 21, "海南"},
	[2105] = {"五指山市", 21, "海南"},
	[2106] = {"琼海市", 21, "海南"},
	[2107] = {"文昌市", 21, "海南"},
	[2108] = {"万宁市", 21, "海南"},
	[2109] = {"东方市", 21, "海南"},
	[2110] = {"屯昌", 21, "海南"},
	[2111] = {"澄迈", 21, "海南"},
	[2112] = {"临高", 21, "海南"},
	[2113] = {"白沙", 21, "海南"},
	[2114] = {"昌江", 21, "海南"},
	[2115] = {"乐东", 21, "海南"},
	[2116] = {"陵水", 21, "海南"},
	[2117] = {"保亭", 21, "海南"},
	[2118] = {"琼中", 21, "海南"},
	[2201] = {"万州", 22, "重庆市"},
	[2202] = {"涪陵", 22, "重庆市"},
	[2203] = {"渝中", 22, "重庆市"},
	[2204] = {"大渡口", 22, "重庆市"},
	[2205] = {"江北", 22, "重庆市"},
	[2206] = {"沙坪坝", 22, "重庆市"},
	[2207] = {"九龙坡", 22, "重庆市"},
	[2208] = {"南岸", 22, "重庆市"},
	[2209] = {"北碚", 22, "重庆市"},
	[2210] = {"两江新", 22, "重庆市"},
	[2211] = {"万盛", 22, "重庆市"},
	[2212] = {"双桥", 22, "重庆市"},
	[2213] = {"渝北", 22, "重庆市"},
	[2214] = {"巴南", 22, "重庆市"},
	[2215] = {"长寿", 22, "重庆市"},
	[2216] = {"綦江", 22, "重庆市"},
	[2217] = {"潼南", 22, "重庆市"},
	[2218] = {"铜梁", 22, "重庆市"},
	[2219] = {"大足", 22, "重庆市"},
	[2220] = {"荣昌", 22, "重庆市"},
	[2221] = {"璧山", 22, "重庆市"},
	[2222] = {"梁平", 22, "重庆市"},
	[2223] = {"城口", 22, "重庆市"},
	[2224] = {"丰都", 22, "重庆市"},
	[2225] = {"垫江", 22, "重庆市"},
	[2226] = {"武隆", 22, "重庆市"},
	[2227] = {"忠县", 22, "重庆市"},
	[2228] = {"开县", 22, "重庆市"},
	[2229] = {"云阳", 22, "重庆市"},
	[2230] = {"奉节", 22, "重庆市"},
	[2231] = {"巫山", 22, "重庆市"},
	[2232] = {"巫溪", 22, "重庆市"},
	[2233] = {"黔江", 22, "重庆市"},
	[2234] = {"石柱", 22, "重庆市"},
	[2235] = {"秀山", 22, "重庆市"},
	[2236] = {"酉阳", 22, "重庆市"},
	[2237] = {"彭水", 22, "重庆市"},
	[2238] = {"江津", 22, "重庆市"},
	[2239] = {"合川", 22, "重庆市"},
	[2240] = {"永川", 22, "重庆市"},
	[2241] = {"南川", 22, "重庆市"},
	[2301] = {"成都市", 23, "四川"},
	[2302] = {"自贡市", 23, "四川"},
	[2303] = {"攀枝花市", 23, "四川"},
	[2304] = {"泸州市", 23, "四川"},
	[2305] = {"德阳市", 23, "四川"},
	[2306] = {"绵阳市", 23, "四川"},
	[2307] = {"广元市", 23, "四川"},
	[2308] = {"遂宁市", 23, "四川"},
	[2309] = {"内江市", 23, "四川"},
	[2310] = {"乐山市", 23, "四川"},
	[2311] = {"南充市", 23, "四川"},
	[2312] = {"眉山市", 23, "四川"},
	[2313] = {"宜宾市", 23, "四川"},
	[2314] = {"广安市", 23, "四川"},
	[2315] = {"达州市", 23, "四川"},
	[2316] = {"雅安市", 23, "四川"},
	[2317] = {"巴中市", 23, "四川"},
	[2318] = {"资阳市", 23, "四川"},
	[2319] = {"阿坝", 23, "四川"},
	[2320] = {"甘孜", 23, "四川"},
	[2321] = {"凉山", 23, "四川"},
	[2401] = {"贵阳市", 24, "贵州"},
	[2402] = {"六盘水市", 24, "贵州"},
	[2403] = {"遵义市", 24, "贵州"},
	[2404] = {"安顺市", 24, "贵州"},
	[2405] = {"铜仁市", 24, "贵州"},
	[2406] = {"黔西南", 24, "贵州"},
	[2407] = {"毕节市", 24, "贵州"},
	[2408] = {"黔东南", 24, "贵州"},
	[2409] = {"黔南", 24, "贵州"},
	[2501] = {"昆明市", 25, "云南"},
	[2502] = {"曲靖市", 25, "云南"},
	[2503] = {"玉溪市", 25, "云南"},
	[2504] = {"保山市", 25, "云南"},
	[2505] = {"昭通市", 25, "云南"},
	[2506] = {"丽江市", 25, "云南"},
	[2507] = {"普洱市", 25, "云南"},
	[2508] = {"临沧市", 25, "云南"},
	[2509] = {"楚雄", 25, "云南"},
	[2510] = {"红河", 25, "云南"},
	[2511] = {"文山", 25, "云南"},
	[2512] = {"西双版纳", 25, "云南"},
	[2513] = {"大理", 25, "云南"},
	[2514] = {"德宏", 25, "云南"},
	[2515] = {"怒江", 25, "云南"},
	[2516] = {"迪庆", 25, "云南"},
	[2601] = {"拉萨市", 26, "西藏"},
	[2602] = {"昌都市", 26, "西藏"},
	[2603] = {"山南市", 26, "西藏"},
	[2604] = {"日喀则市", 26, "西藏"},
	[2605] = {"那曲地区", 26, "西藏"},
	[2606] = {"阿里地区", 26, "西藏"},
	[2607] = {"林芝市", 26, "西藏"},
	[2701] = {"西安市", 27, "陕西"},
	[2702] = {"铜川市", 27, "陕西"},
	[2703] = {"宝鸡市", 27, "陕西"},
	[2704] = {"咸阳市", 27, "陕西"},
	[2705] = {"渭南市", 27, "陕西"},
	[2706] = {"延安市", 27, "陕西"},
	[2707] = {"汉中市", 27, "陕西"},
	[2708] = {"榆林市", 27, "陕西"},
	[2709] = {"安康市", 27, "陕西"},
	[2710] = {"商洛市", 27, "陕西"},
	[2801] = {"兰州市", 28, "甘肃"},
	[2802] = {"嘉峪关市", 28, "甘肃"},
	[2803] = {"金昌市", 28, "甘肃"},
	[2804] = {"白银市", 28, "甘肃"},
	[2805] = {"天水市", 28, "甘肃"},
	[2806] = {"武威市", 28, "甘肃"},
	[2807] = {"张掖市", 28, "甘肃"},
	[2808] = {"平凉市", 28, "甘肃"},
	[2809] = {"酒泉市", 28, "甘肃"},
	[2810] = {"庆阳市", 28, "甘肃"},
	[2811] = {"定西市", 28, "甘肃"},
	[2812] = {"陇南市", 28, "甘肃"},
	[2813] = {"临夏", 28, "甘肃"},
	[2814] = {"甘南", 28, "甘肃"},
	[2901] = {"西宁市", 29, "青海"},
	[2902] = {"海东市", 29, "青海"},
	[2903] = {"海北", 29, "青海"},
	[2904] = {"黄南", 29, "青海"},
	[2905] = {"海南", 29, "青海"},
	[2906] = {"果洛", 29, "青海"},
	[2907] = {"玉树", 29, "青海"},
	[2908] = {"海西", 29, "青海"},
	[3001] = {"银川市", 30, "宁夏"},
	[3002] = {"石嘴山市", 30, "宁夏"},
	[3003] = {"吴忠市", 30, "宁夏"},
	[3004] = {"固原市", 30, "宁夏"},
	[3005] = {"中卫市", 30, "宁夏"},
	[3101] = {"乌鲁木齐市", 31, "新疆"},
	[3102] = {"克拉玛依市", 31, "新疆"},
	[3103] = {"吐鲁番市", 31, "新疆"},
	[3104] = {"哈密市", 31, "新疆"},
	[3105] = {"昌吉", 31, "新疆"},
	[3106] = {"博尔塔拉", 31, "新疆"},
	[3107] = {"巴音郭楞", 31, "新疆"},
	[3108] = {"阿克苏", 31, "新疆"},
	[3109] = {"克孜勒苏", 31, "新疆"},
	[3110] = {"喀什", 31, "新疆"},
	[3111] = {"和田", 31, "新疆"},
	[3112] = {"伊犁", 31, "新疆"},
	[3113] = {"塔城", 31, "新疆"},
	[3114] = {"阿勒泰", 31, "新疆"},
	[3115] = {"石河子市", 31, "新疆"},
	[3116] = {"阿拉尔市", 31, "新疆"},
	[3117] = {"图木舒克市", 31, "新疆"},
	[3118] = {"五家渠市", 31, "新疆"},
	[3119] = {"北屯市", 31, "新疆"},
	[3201] = {"台北市", 32, "台湾"},
	[3202] = {"高雄市", 32, "台湾"},
	[3203] = {"基隆市", 32, "台湾"},
	[3204] = {"台中市", 32, "台湾"},
	[3205] = {"台南市", 32, "台湾"},
	[3206] = {"新北市", 32, "台湾"},
	[3207] = {"桃园市", 32, "台湾"},
	[3208] = {"新竹市", 32, "台湾"},
	[3209] = {"嘉义市", 32, "台湾"},
	[3210] = {"新北市", 32, "台湾"},
	[3211] = {"宜兰县", 32, "台湾"},
	[3212] = {"桃源县", 32, "台湾"},
	[3213] = {"新竹县", 32, "台湾"},
	[3214] = {"苗栗县", 32, "台湾"},
	[3215] = {"台中县", 32, "台湾"},
	[3216] = {"彰化县", 32, "台湾"},
	[3217] = {"南投县", 32, "台湾"},
	[3218] = {"云林县", 32, "台湾"},
	[3219] = {"嘉义县", 32, "台湾"},
	[3220] = {"台南县", 32, "台湾"},
	[3221] = {"高雄县", 32, "台湾"},
	[3222] = {"屏东县", 32, "台湾"},
	[3223] = {"台东县", 32, "台湾"},
	[3224] = {"花莲县", 32, "台湾"},
	[3225] = {"澎湖县", 32, "台湾"},
	[3301] = {"特别行政区", 33, "香港"},
	[3401] = {"特别行政区", 34, "澳门"},
}
