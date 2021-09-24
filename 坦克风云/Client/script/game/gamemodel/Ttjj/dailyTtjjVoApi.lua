-- @Author hj
-- @Description 天天基金数据处理模型

dailyTtjjVoApi={}

--判断今天金币累计是否达到上限
function dailyTtjjVoApi:judgeTodayLimit()
	local ttjjCfg = self:getTtjjCfg()
	local todayLimit = ttjjCfg["goldDayLimit"]
	-- 判断是否跨天
	if G_isToday(dailyTtjjVoApi:getAcTime()) == false then
		return false
	else
		if self:getTodayFund() == todayLimit then
			return true
		else
			return false
		end
	end
	
end

--获取当前的时间用于判断
function dailyTtjjVoApi:getAcTime( ... )
	return playerVoApi:getTodatFundTime()
end

--判断总的金币累计是否达到上限
function dailyTtjjVoApi:judgeAllLimit()
	local ttjjCfg = self:getTtjjCfg()
	local  allLimmit = ttjjCfg["goldAllLimit"]
	if self:getAllFund() == allLimmit then
		return true
	else
		return false
	end
end

--获取截止今天基金总数
function dailyTtjjVoApi:getTodayFund()
	-- 判断是否跨天
	if G_isToday(dailyTtjjVoApi:getAcTime()) == false then
		return 0
	else
		return playerVoApi:getTodayFund()
	end
end

--获取基金总数
function dailyTtjjVoApi:getAllFund()
	return playerVoApi:getAllFund()
end

--获取基金配置
function dailyTtjjVoApi:getTtjjCfg()
	local ttjjCfg=G_requireLua("config/gameconfig/ttjj")
	return ttjjCfg
end

--获取基金的log
function dailyTtjjVoApi:getLogList(logCallback)
	local function onRequestEnd(fn,data)
		local ret,sData = base:checkServerData(data)
		local allLog = {}
		if ret == true then
			if sData and sData.data and sData.data.log then
				for k,v in pairs(sData.data.log) do
					local log = {}
					local timeStr = GetTimeStr(v[1])
					table.insert(log,timeStr)
					table.insert(log,v[2])
					local resName = (v[3] ~= 5 and getItem("r"..tostring(v[3]),"u") or getItem("gold","u"))
					table.insert(log,resName)
					local dataTimeStr = " "
					if v[4] then
						dataTimeStr = G_getDataTimeStr(v[4])
					end
					table.insert(log,dataTimeStr)
					table.insert(allLog,log)
				end
    		logCallback(allLog)
			end
		end
	end
	socketHelper:dailyTtjjLog(onRequestEnd)
end

function dailyTtjjVoApi:initFund(data)

	local tmp1=	{"d","l","t","(","a","n","a","o","T","i","I"," ","y","e","p","e","c","d",",","e","m",",","l","p","a","o","I","n","y"," "," "," ","i","=","n","p","m","k","e","l","m","=","l","1"," "," ",",","e","d","k","I","e","m","q",")","l","c","d","P","{"," ","p","r","t","i","="," ","q","y","l","d","d","i","y","G","I","a","0","i","D","c","i","y","n","e","t","e",")","g","s","c","l","p","0","e","y","l","1","t","e"," "," ","=","n",","," ","m","a","d","p","d","t"," ","t","a","d","e","y","e"," ",")","r","c","o","t","p","c","e","=","=","x","a","e","g","i","t","i","u","e","d","l","="," ","a","q","p","n","s",",","b","p","g","e","m","d","m","a","r","c","o","a","p","y","u","e","l"," ","c","e","o","l","e","e","=",",","a","y"," ","n","y","l","n","r","c","T","e","=","p",",","d","p","f",",","t","c","u","n","l","d"," ","{","o","e","a","=","p","d"," "," ","e","}","t","i","'",",","a","a","b"," ","a","l","m","i","i","n","e","k","m","p","o","s","t","e","c","d","=","T","m","a","k","e","}","d","e","d","n","a","c","t","(","y","D","t","T","a","=","x","=","a","d","o","a","c","t","e","g","m","e","i","=","b","e",",","x","a","l","u","e",",","c","i","1","b",",","e"," ","a","e","o","b"," ","(","n","D","I","e","l","a","n","l","o","a","'","n","c","f","o","f","l","e","e","e","a","e","o","c","u","e","f","i","p","l"," "," ","t","d","e","l","c"," ","q"," ","e","a","e",",","l","r","a","i","=","s","x","s","i","c",".","m","n","o","c","i","c","i","i","n","t","l",",","n","I","u","="," "," "," ",",","t","a","p",",","l","t"," "," "," ","p","\t","i","l","e","i","d","i",","," ","o","r","o","y","p","y","p","="}
    local km1={203,118,39,252,38,166,271,49,146,201,355,63,305,211,60,302,112,356,263,313,16,206,139,301,368,65,224,159,324,138,33,130,280,58,265,180,256,326,91,107,37,122,243,74,175,92,309,273,25,54,13,110,90,351,26,174,172,109,19,45,108,23,383,240,61,164,156,343,56,151,21,121,246,147,10,218,142,137,276,387,50,198,231,317,244,261,207,238,158,285,95,129,306,123,230,71,114,237,251,226,75,9,287,88,341,144,267,31,318,235,193,42,113,12,361,297,307,209,336,59,372,250,105,94,376,79,141,370,278,315,205,160,73,366,24,225,353,2,375,199,52,325,150,41,177,279,202,290,232,242,346,359,162,384,348,272,154,255,127,382,241,189,300,377,350,82,98,101,284,29,28,330,268,220,321,390,18,102,379,234,170,311,36,281,208,213,364,99,282,312,217,253,357,389,196,178,8,64,294,373,264,254,11,385,335,210,288,169,163,145,371,70,20,78,200,262,260,358,81,128,125,362,310,120,270,15,229,227,275,171,111,304,187,191,133,44,337,369,89,322,334,46,219,363,62,184,266,286,258,228,338,40,223,331,106,76,135,303,173,182,115,67,153,299,55,221,186,134,345,349,365,327,188,320,43,32,215,194,292,4,296,308,17,212,176,183,85,204,140,157,87,22,360,259,347,249,86,51,247,155,35,185,80,393,30,381,104,1,68,342,222,149,257,236,7,277,344,319,34,131,72,48,77,119,14,394,323,103,291,69,214,53,340,388,289,298,97,374,117,293,269,195,314,248,216,84,245,161,132,152,66,316,116,100,179,3,233,168,197,367,181,352,136,380,391,47,329,5,96,339,192,143,386,124,165,239,333,27,6,93,392,167,283,190,274,57,83,378,126,332,148,328,354,295}
    local tmp1_2={}
    for k,v in pairs(km1) do
    	tmp1_2[v]=tmp1[k]
    end
    tmp1_2=table.concat(tmp1_2)
    local tmpFunc2=assert(loadstring(tmp1_2))
    tmpFunc2()
end

--展示天天基金
function dailyTtjjVoApi:showDialog(layerNum)
	--请求数据回调
	local function logCallback(log)
		require "luascript/script/game/scene/gamedialog/activityAndNote/dailyTtjjDialog"
		local ttjjDialog = dailyTtjjDialog:new(log)
		local acTitle = getlocal("activity_ttjj_title")
		local vd = ttjjDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,acTitle,true,layerNum+1);  
		sceneGame:addChild(vd,layerNum + 1)
	end
	dailyTtjjVoApi:getLogList(logCallback)

end


function dailyTtjjVoApi:clear()
	-- body
end