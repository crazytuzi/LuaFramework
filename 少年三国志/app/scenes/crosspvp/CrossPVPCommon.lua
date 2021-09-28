local CrossPVPConst = require("app.const.CrossPVPConst")

local CrossPVPCommon = class("CrossPVPCommon")

function CrossPVPCommon.getBattleFieldName(nBattleFieldType)
	if type(nBattleFieldType) ~= "number" then
		return ""
	end
	if type(nBattleFieldType) == "number" and (nBattleFieldType <= 0 or nBattleFieldType > 4) then
		return ""
	end

	local tFieldNameList = {
		[4] = "LANG_CROSS_PVP_FIELD_NAME_EXTREME",
	    [3] = "LANG_CROSS_PVP_FIELD_NAME_ADVANCED",
	    [2] = "LANG_CROSS_PVP_FIELD_NAME_MIDDLE",
	    [1] = "LANG_CROSS_PVP_FIELD_NAME_PRIMARY",
	}

	return G_lang:get(tFieldNameList[nBattleFieldType])
end

-- 比赛每个阶段的名称
function CrossPVPCommon.getCourseDesc(nCourse, isShortName)
	if type(nCourse) ~= "number" then
		assert(false, "nCourse must be a number")
	end

	local szDesc = ""
	if nCourse == CrossPVPConst.COURSE_APPLY then
		szDesc = G_lang:get("LANG_CROSS_PVP_COURSE_APPLY_DESC")
	elseif nCourse == CrossPVPConst.COURSE_PROMOTE_1024 or   -- 海选（1024强晋级赛）
	    nCourse == CrossPVPConst.COURSE_PROMOTE_256  or   -- 复赛（256强晋级赛）
        nCourse == CrossPVPConst.COURSE_PROMOTE_64   or   -- 64强晋级赛
	    nCourse == CrossPVPConst.COURSE_PROMOTE_16   or   -- 16强晋级赛
 	    nCourse == CrossPVPConst.COURSE_PROMOTE_4 	 or    -- 4强晋级赛
 	    nCourse == CrossPVPConst.COURSE_FINAL 		 then	 -- 决赛

 	    local tScheduleTmpl = crosspvp_schedule_info.get(nCourse - 1)
 	    if tScheduleTmpl then
 	   	   szDesc = isShortName and tScheduleTmpl.short_name or tScheduleTmpl.name
 	    end
	end
	return szDesc
end

-- 距离报名开始的时间
function CrossPVPCommon.getLeftApplyTime()
	local applyStartTime, _ = G_Me.crossPVPData:getCourseTime(CrossPVPConst.COURSE_APPLY)
	local leftTime = CrossPVPCommon.getFormatLeftTime(applyStartTime)
	return leftTime
end

-- 计算到某个时间的剩余时间，并转换成特定的格式：
-- 如果是2天后，显示"x月x日x时x分"
-- 如果是后天，显示"后天x时x分"
-- 如果是明天，显示"明天x时x分"
-- 如果是今天，显示"今天x时x分"
-- 如果是半个小时以内，显示"x分x秒后"
function CrossPVPCommon.getFormatLeftTime(t)
	local curTime  	= G_ServerTime:getTime()
	local curDate 	= G_ServerTime:getDateObject(curTime)
	local tDate		= G_ServerTime:getDateObject(t)

	-- 今天0点的时间戳
	local todayZero	= curTime - curDate.hour*3600 - curDate.min*60 - curDate.sec

	if t - curTime <= 0 then
		return nil
	elseif t - curTime < 1800 then
		local d, h, m, s = G_ServerTime:getLeftTimeParts(t)
		local strCD = ""

		if h > 0 then
			strCD = strCD .. h .. G_lang:get("LANG_CROSS_WAR_CD_HOUR")
		end
		if m > 0 then
			strCD = strCD .. m .. G_lang:get("LANG_CROSS_WAR_CD_MINUTE")
		end
		if s > 0 then
			strCD = strCD .. s .. G_lang:get("LANG_CROSS_WAR_CD_SECOND")
		end

		return strCD .. G_lang:get("LANG_TIME_AFTER")

	elseif t - todayZero < 3600 * 24 then
		return G_lang:get("LANG_TIME_TODAY") .. tDate.hour .. G_lang:get("LANG_HOUR_2") .. tDate.min .. G_lang:get("LANG_MINUTE_2")
	elseif t - todayZero < 3600 * 24 * 2 then
		return G_lang:get("LANG_TIME_TOMORROW") .. tDate.hour .. G_lang:get("LANG_HOUR_2") .. tDate.min .. G_lang:get("LANG_MINUTE_2")
	elseif t - todayZero < 3600 * 24 * 3 then
		return G_lang:get("LANG_TIME_AFTER_TOMORROW") .. tDate.hour .. G_lang:get("LANG_HOUR_2") .. tDate.min .. G_lang:get("LANG_MINUTE_2")
	else
		return tDate.month .. G_lang:get("LANG_MONTH") .. tDate.day .. G_lang:get("LANG_DAY") ..
			   tDate.hour .. G_lang:get("LANG_HOUR_2") .. tDate.min .. G_lang:get("LANG_MINUTE_2")
	end

	if t - todayZero >= 3600 * 24 * 2 then
		return tDate.month .. G_lang:get("LANG_MONTH") .. tDate.day .. G_lang:get("LANG_DAY") ..
			   tDate.hour .. G_lang:get("LANG_HOUR_2") .. tDate.min .. G_lang:get("LANG_MINUTE_2")
	elseif t - todayZero >= 3600 * 24 then
		return G_lang:get("LANG_TIME_AFTER_TOMORROW") .. tDate.hour .. G_lang:get("LANG_HOUR_2") .. tDate.min .. G_lang:get("LANG_MINUTE_2")
	end
end

-- 决赛结束后，显示冠亚军
function CrossPVPCommon.showFinalRankDesc(nRank)
	if type(nRank) ~= "number" then
		assert(false, "nRank must a number")
	end
	local tList = {
		"LANG_CROSS_PVP_END_CHAMPION",
	    "LANG_CROSS_PVP_END_SECONE",
	    "LANG_CROSS_PVP_END_THIRD",
	    "LANG_CROSS_PVP_END_FOURTH",
	}
	return G_lang:get(tList[nRank]) or ""
end

-- 伤害加成与伤害减免
function CrossPVPCommon.getBuffRate(nType)
	local nRate = 0
	local tCrossPVPBuffTmpl = crosspvp_buff_info.get(nType)
	if not tCrossPVPBuffTmpl then
		return nRate
	end
	local tBuffTmpl = passive_skill_info.get(tCrossPVPBuffTmpl.buff_id)
	if not tBuffTmpl then
		return nRate
	end
	return tBuffTmpl.affect_value / 10
end

-- 获得鲜花鸡蛋属性加成
function CrossPVPCommon.getFlowerEggBuffAddition(nFlowerCount, nEggCount)
	-- nFlowerCount = nFlowerCount or 0
	-- nEggCount = nEggCount or 0
	-- local BUFF_UPPER_LIMIT = 20
	-- local szAddition = ""
	-- local nRate = 0.1 -- 鲜花鸡蛋数量10点差值，影响0.1%属性
	-- local nAddition = math.floor(math.abs(nFlowerCount - nEggCount) / 10)
	-- if nFlowerCount >= nEggCount then
	-- 	szAddition = string.format("+%.1f%%", math.min(nRate*nAddition, BUFF_UPPER_LIMIT))
	-- else
	-- 	szAddition = string.format("-%.1f%%", math.min(nRate*nAddition, BUFF_UPPER_LIMIT))
	-- end
	-- return szAddition


	local MAX_COUNT = 2000
	local szAddition = ""
	nFlowerCount = nFlowerCount > MAX_COUNT and MAX_COUNT or nFlowerCount
	nEggCount = nEggCount > MAX_COUNT and MAX_COUNT or nEggCount
	if nFlowerCount == MAX_COUNT and nEggCount == MAX_COUNT then
		szAddition = string.format("+%.1f%%", 0)
		return szAddition
	end
	local nRate = 0.1 -- 鲜花鸡蛋数量10点差值，影响0.1%属性
	local nAddition = math.floor(math.abs(nFlowerCount - nEggCount) / 10)
	local BUFF_UPPER_LIMIT = 20
	if nFlowerCount >= nEggCount then
		szAddition = string.format("+%.1f%%", math.min(nRate*nAddition, BUFF_UPPER_LIMIT))
	else
		szAddition = string.format("-%.1f%%", math.min(nRate*nAddition, BUFF_UPPER_LIMIT))
	end
	return szAddition
end

-- 鲜花属性加成
function CrossPVPCommon.getFlowerBuffAddition(nFlowerCount)
	local MAX_COUNT = 2000
	local szAddition = ""
	nFlowerCount = nFlowerCount > MAX_COUNT and MAX_COUNT or nFlowerCount

	local nRate = 0.1 -- 鲜花鸡蛋数量10点差值，影响0.1%属性
	local nAddition = math.floor(math.abs(nFlowerCount / 10))
	local BUFF_UPPER_LIMIT = 20
	szAddition = string.format("+%.1f%%", math.min(nRate*nAddition, BUFF_UPPER_LIMIT))

	return szAddition
end

-- 鸡蛋属性加成
function CrossPVPCommon.getEggBuffAddition(nEggCount)
	local MAX_COUNT = 2000
	local szAddition = ""
	nEggCount = nEggCount > MAX_COUNT and MAX_COUNT or nEggCount

	local nRate = 0.1 -- 鲜花鸡蛋数量10点差值，影响0.1%属性
	local nAddition = math.floor(math.abs(nEggCount / 10))
	local BUFF_UPPER_LIMIT = 20
	szAddition = string.format("-%.1f%%", math.min(nRate*nAddition, BUFF_UPPER_LIMIT))

	return szAddition
end

function CrossPVPCommon.getInspireCost(nId, nCount)
	local tList = {}
	for i=1, shop_price_info.getLength() do
		local tTmpl = shop_price_info.indexOf(i)
		if tTmpl and tTmpl.id == nId then
			table.insert(tList, #tList+1, tTmpl)
		end
	end
	--dump(tList)

	local nPrice = 0
	nCount = nCount + 1
	for i=1, #tList do
		local tTmpl = tList[i]
		local tTmplNext = tList[i+1]
		if tTmplNext then	
            if tTmpl.num <= nCount and tTmplNext.num > nCount then
            	nPrice = tTmpl.price
            	break
            end
		else
			nPrice = tTmpl.price
		end
	end
	return nPrice
end

function CrossPVPCommon.getCourseTitle(nCourse)
	local tTitleImgList = {
		[2] = "ui/text/txt/haixuansai.png",
		[3] = "ui/text/txt/fusai.png",
		[4] = "ui/text/txt/64qiangjinjisai.png",
		[5] = "ui/text/txt/16qiangjinjisai.png",
		[6] = "ui/text/txt/4qiangjinjisai.png",
		[7] = "ui/text/txt/juesai.png",
	}
	return tTitleImgList[nCourse] or tTitleImgList[1], UI_TEX_TYPE_LOCAL
end

function CrossPVPCommon.getDefaultTitle()
	return "ui/text/txt/title_juezhanchibi.png", UI_TEX_TYPE_LOCAL
end

-- 决赛第1，2，3，4名
function CrossPVPCommon.getRankDescAtFinalEnd(nRank)
	if type(nRank) ~= "number" then
		return ""
	end

	local tList = {
		"LANG_CROSS_PVP_END_CHAMPION",
		"LANG_CROSS_PVP_END_SECONE",
		"LANG_CROSS_PVP_END_THIRD",
		"LANG_CROSS_PVP_END_FOURTH",
	}
	if tList[nRank] then
		return G_lang:get(tList[nRank])
	else
		return ""
	end
end

return CrossPVPCommon