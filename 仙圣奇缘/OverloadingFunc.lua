--------------------------------------------------------------------------------------
-- 文件名:	
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:    重载更新不了的函数 这几个文件是不能热更
--[[
g_LoadFile("LuaScripts/GameLogic/GlobalConfig/Config_DebugCfg")
g_LoadFile("LuaScripts/GameLogic/GlobalFunc/GFunc_SpineAnimation")
g_LoadFile("LuaScripts/GameLogic/GlobalFunc/GFunc_Glittering")
g_LoadFile("LuaScripts/GameLogic/Class_DataMgr")
g_LoadFile("LuaScripts/GameLogic/GlobalFunc/GFunc_Function")

g_LoadFile("LuaScripts/FrameWork/functions")
g_LoadFile("LuaScripts/Login/LYP_Loading")
g_LoadFile("LuaScripts/json")
g_LoadFile("LuaScripts/FrameWork/ccs")
g_LoadFile("LuaScripts/GameSDK/TalkingData/TalkingData")
g_LoadFile("Config/Dialogue")
]]
---------------------------------------------------------------------------------------


function getFunctionOpenLevelCsvByStr(WidgetName)
	local WidgetName = WidgetName or "DEFAULT"
	
	if not g_DataMgr.tbFunctionOpenLevelInStrKey then
		g_DataMgr.tbFunctionOpenLevelInStrKey = {}
		for key, value in pairs(ConfigMgr.FunctionOpenLevel) do
			for k, v in pairs(value) do
				g_DataMgr.tbFunctionOpenLevelInStrKey[v.WidgetName] = {}
				g_DataMgr.tbFunctionOpenLevelInStrKey[v.WidgetName].OpenLevel = key
				g_DataMgr.tbFunctionOpenLevelInStrKey[v.WidgetName].WidgetName = v.WidgetName
				g_DataMgr.tbFunctionOpenLevelInStrKey[v.WidgetName].IsNeedOpenGuide = v.IsNeedOpenGuide
				g_DataMgr.tbFunctionOpenLevelInStrKey[v.WidgetName].IsNeedOpenAni = v.IsNeedOpenAni
				g_DataMgr.tbFunctionOpenLevelInStrKey[v.WidgetName].EndGuideID = v.EndGuideID
				g_DataMgr.tbFunctionOpenLevelInStrKey[v.WidgetName].OpenFuncIcon = v.OpenFuncIcon
				g_DataMgr.tbFunctionOpenLevelInStrKey[v.WidgetName].OpenFuncName = v.OpenFuncName
				g_DataMgr.tbFunctionOpenLevelInStrKey[v.WidgetName].OpenFuncNamePic = v.OpenFuncNamePic
				g_DataMgr.tbFunctionOpenLevelInStrKey[v.WidgetName].OpenVipLevel = v.OpenVipLevel
			end
		end
		g_DataMgr.tbFunctionOpenLevelInStrKey["DEFAULT"] = {}
		g_DataMgr.tbFunctionOpenLevelInStrKey["DEFAULT"].OpenLevel = 0
		g_DataMgr.tbFunctionOpenLevelInStrKey["DEFAULT"].WidgetName = ""
		g_DataMgr.tbFunctionOpenLevelInStrKey["DEFAULT"].IsNeedOpenGuide = 0
		g_DataMgr.tbFunctionOpenLevelInStrKey["DEFAULT"].IsNeedOpenAni = 0
		g_DataMgr.tbFunctionOpenLevelInStrKey["DEFAULT"].EndGuideID = 0
		g_DataMgr.tbFunctionOpenLevelInStrKey["DEFAULT"].OpenFuncIcon = "BtnZhuangBei"
		g_DataMgr.tbFunctionOpenLevelInStrKey["DEFAULT"].OpenFuncName = ""
		g_DataMgr.tbFunctionOpenLevelInStrKey["DEFAULT"].OpenFuncNamePic = "Char_Btn_ZhuangBei"
		g_DataMgr.tbFunctionOpenLevelInStrKey["DEFAULT"].OpenVipLevel = 0
	end
	
	local tbCsv = g_DataMgr.tbFunctionOpenLevelInStrKey[WidgetName]
	if not tbCsv then
		cclog("===Class_DataMgr:getFunctionOpenLevelCsvByStr error ==="..tostring(WidgetName))
		return g_DataMgr.tbFunctionOpenLevelInStrKey["DEFAULT"]
	end
	return g_DataMgr.tbFunctionOpenLevelInStrKey[WidgetName]
end

local function sortFunctionOpenLevel(tbItemA, tbItemB)
	return tbItemA.OpenLevel < tbItemB.OpenLevel
end
function getFunctionOpenLevelCsvNext()
	local WidgetName = WidgetName or "DEFAULT"
	
	if not g_DataMgr.tbFunctionOpenLevelInSort then
		g_DataMgr.tbFunctionOpenLevelInSort = {}
		for key, value in pairs(ConfigMgr.FunctionOpenLevel) do
			for k, v in pairs(value) do
				if k == 1 then
					table.insert(g_DataMgr.tbFunctionOpenLevelInSort, 
						{
							OpenLevel = key,
							OpenFuncIcon = v.OpenFuncIcon,
							OpenFuncName = v.OpenFuncName,
							OpenFuncNamePic = v.OpenFuncNamePic,
							OpenVipLevel = v.OpenVipLevel,
						}
					)
				end
			end
		end
		table.sort(g_DataMgr.tbFunctionOpenLevelInSort, sortFunctionOpenLevel)
	end
	
	for nIndex = 1, #g_DataMgr.tbFunctionOpenLevelInSort do
		if g_Hero:getMasterCardLevel() < g_DataMgr.tbFunctionOpenLevelInSort[nIndex].OpenLevel then
			if g_VIPBase:getVIPLevelId() >= 1 then
				if g_DataMgr.tbFunctionOpenLevelInSort[nIndex].OpenVipLevel > 0 then
					if g_VIPBase:getVIPLevelId() < g_DataMgr.tbFunctionOpenLevelInSort[nIndex].OpenVipLevel then
						if g_DataMgr.tbFunctionOpenLevelInSort[nIndex].OpenLevel < 200 then
							return g_DataMgr.tbFunctionOpenLevelInSort[nIndex]
						else
							return {
								OpenLevel = 0,
								OpenFuncIcon = "",
								OpenFuncName = "",
								OpenFuncNamePic = "",
								OpenVipLevel = 0,
							}
						end
					end
				else
					if g_DataMgr.tbFunctionOpenLevelInSort[nIndex].OpenLevel < 200 then
						return g_DataMgr.tbFunctionOpenLevelInSort[nIndex]
					else
						return {
							OpenLevel = 0,
							OpenFuncIcon = "",
							OpenFuncName = "",
							OpenFuncNamePic = "",
							OpenVipLevel = 0,
						}
					end
				end
			else
				if g_DataMgr.tbFunctionOpenLevelInSort[nIndex].OpenLevel < 200 then
					return g_DataMgr.tbFunctionOpenLevelInSort[nIndex]
				else
					return {
						OpenLevel = 0,
						OpenFuncIcon = "",
						OpenFuncName = "",
						OpenFuncNamePic = "",
						OpenVipLevel = 0,
					}
				end
			end
		end
	end
	
	return {
		OpenLevel = 0,
		OpenFuncIcon = "",
		OpenFuncName = "",
		OpenFuncNamePic = "",
		OpenVipLevel = 0,
	}
end

function g_stringSize_insert(mystring, insertStr, fontSize, mSizeLen) 
	if not mystring then mystring = "" end
	local b =  tonumber( string.len(insertStr))
    local newstr = ""; 
	local size = 0
    local nlen = tonumber( string.len(mystring))
    local i = 1 
	if not g_nlabel then
		g_nlabel = Label:create()
		g_nlabel:retain()
	end
	g_nlabel:setFontSize(fontSize)

    local spaceI = 0
    local oneWord  = ""

	while i <=  nlen do
		local c = string.byte(mystring, i)
        local shift = 1
        --0.192.224.240.248.252
        if c >= 0x00 and c < 0xc0 then 
            shift = 1
        elseif c >= 0xc0 and c < 0xe0 then 
            shift = 2
        elseif c >= 0xe0 and c < 0xf0 then
            shift = 3
        elseif c >= 0xf0 and c < 0xf8 then 
            shift = 4
        elseif c >= 0xf8 and c < 0xfc then
            shift = 5
        else 
            shift = 6
        end

        --[[if c > 0 and c <= 127 then
            shift = 1
        else
			shift = 3
        end]]

        local substr = string.sub(mystring, i, i+shift-1)
        i = i + shift

        if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_zh_CN or g_LggV.LanguageVer == eLanguageVer.LANGUAGE_cht_Taiwan or g_LggV.LanguageVer == eLanguageVer.LANGUAGE_zh_AUDIT then

		    local text = newstr .. substr.."\n"
		    g_nlabel:setText(text)
		    local size = g_nlabel:getSize()

		    if size.width <= mSizeLen then
			    newstr = newstr .. substr
		    else
			    local substr1 = string.sub(mystring, i, i)

			    if substr1 == "\n" then
				    newstr = newstr ..substr1..substr
				    i = i + 1
			    else
				    newstr = newstr .."\n".. substr
			    end
		    end
        else
            if substr == " " or i > nlen then --一个单词
            	local text = newstr .. oneWord..substr.."\n"
		        g_nlabel:setText(text)
		        local size = g_nlabel:getSize()

		        if size.width <= mSizeLen then
			        newstr = newstr .. oneWord ..substr
		        else
				   newstr = newstr .."\n".. oneWord ..substr
		        end

                oneWord = ""
            else
                oneWord = oneWord .. substr
            end    
        end
    end 
    if newstr == "" then newstr = mystring end --外文版本中出现未翻译的中文，会出现返回空字符串的情况，规避下
    return newstr; 
end

--如果文字超出显示范围，截断，并在后面加入4个点点wb
function g_stringSize_PPPP(mystring, fontSize, mSizeLen)
	if not mystring then mystring = "" end
    local newstr = ""; 
	local size = 0
    local nlen = tonumber( string.len(mystring))
    local i = 1 
	if not g_nlabel then
		g_nlabel = Label:create()
		g_nlabel:retain()
	end
	g_nlabel:setFontSize(fontSize)
    g_nlabel:setText("....")
	local PPPPsize = g_nlabel:getSize().width

    local spaceI = 0
    local oneWord  = ""

	while i <=  nlen do
		local c = string.byte(mystring, i)
        local shift = 1
        --0.192.224.240.248.252
        if c >= 0x00 and c < 0xc0 then 
            shift = 1
        elseif c >= 0xc0 and c < 0xe0 then 
            shift = 2
        elseif c >= 0xe0 and c < 0xf0 then
            shift = 3
        elseif c >= 0xf0 and c < 0xf8 then 
            shift = 4
        elseif c >= 0xf8 and c < 0xfc then
            shift = 5
        else 
            shift = 6
        end

        local substr = string.sub(mystring, i, i+shift-1)
        i = i + shift

        if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_zh_CN or g_LggV.LanguageVer == eLanguageVer.LANGUAGE_cht_Taiwan or g_LggV.LanguageVer == eLanguageVer.LANGUAGE_zh_AUDIT then 

		    local text = newstr .. substr.."\n"
		    g_nlabel:setText(text)
		    local size = g_nlabel:getSize()

		    if size.width+PPPPsize <= mSizeLen then
			    newstr = newstr .. substr
		    else
			    local substr1 = string.sub(mystring, i, i)

			    if substr1 == "\n" then
				    newstr = newstr ..substr1..substr
				    i = i + 1
			    else
				    return  newstr .. "...."
			    end
		    end
        else
            if substr == " " or i > nlen then --一个单词
            	local text = newstr .. oneWord..substr.."\n"
		        g_nlabel:setText(text)
		        local size = g_nlabel:getSize()

		        if size.width+PPPPsize <= mSizeLen then
			        newstr = newstr .. oneWord ..substr
		        else
				   return newstr .."...."
		        end

                oneWord = ""
            else
                oneWord = oneWord .. substr
            end    
        end
    end 
    if newstr == "" then newstr = mystring end --外文版本中出现未翻译的中文，会出现返回空字符串的情况，规避下
    return newstr; 
end
--购买体力
function g_buyEnergy()
	local nMaxBuyTimes = g_VIPBase:getVipValue("BuyMaxNum")
	local nBuyTimes = g_Hero:getBuyEnergyTimes()
	if nBuyTimes >= nMaxBuyTimes then
		g_ClientMsgTips:showMsgConfirm(_T("今天已达到购买次数上限\n升级VIP等级可以提升每天购买次数的上限"))
		return
	end
	
	-- local needCoupons = g_DataMgr:getGlobalCfgCsv("buy_energy_price_other")
	
	local needCoupons = g_VIPBase:getVipLevelCntGold(VipType.VipBuyOpType_BuyEnergy)
	
	if nBuyTimes == 0 then
		needCoupons = g_DataMgr:getGlobalCfgCsv("buy_energy_price_first")
	end 
	local nMaxEnergy = g_Hero:getMaxEnergy()
	if g_Hero:getYuanBao()< needCoupons then
		local msg = string.format(_T("购买%d体力需要%d元宝，您的元宝不足，是否前往充值？"), nMaxEnergy, needCoupons)
		local function goStoreWnd()
			g_WndMgr:openWnd("Game_ReCharge")
		end
		g_ClientMsgTips:showConfirm(msg, goStoreWnd)
	else
		local msg = string.format(_T("购买%d体力需要%d元宝，是否继续？"), nMaxEnergy, needCoupons)
		local function BuyEnergy()
            g_MsgMgr:ignoreCheckWaitTime(true)
			g_MsgMgr:requestBuyEnergy(nMaxEnergy)         --请求购买体力
		end
  
		g_ClientMsgTips:showConfirm(msg, BuyEnergy)
	end
end

TDPurchase_Type.TDP_BUY_ELIMINATE_COUNT = "购买感悟次数"

local tbTime = {
	60, --分 60
	3600, --时 (60*60)
	86400, --天 (24*60*60)
	604800, --周 (7*24*60*60)
	2592000, --月(30*24*60*60)
	31104000, --年	(12*30*24*60*60)
}

function getPrayTime(logTime)
	local times = math.floor( logTime / tbTime[1] )
	
	if times >= 0 and times < 60 then 
		if times <= 0 then times = 1 end
		return times.._T("分钟").._T("前")
	end
	
	local times = math.floor( logTime / tbTime[2] )
	if times >= 1 and times < 24 then
		return times.._T("小时").._T("前")
	end
	local times = math.floor( logTime / tbTime[3])
	if times >= 1 and times < 7 then
		return times.._T("天").._T("前")
	end
	local times = math.floor( logTime / tbTime[4])
	if times >= 1 and times < 5 then
		return times.._T("周").. _T("前")
	end
	local times = math.floor( logTime / tbTime[5])
	if times >= 1 and times < 12 then
		return times.._T("月").. _T("前")
	end
	local times = math.floor( logTime / tbTime[6])
	if times >= 1 then
		return times.._T("年").. _T("前")
	end
	return ""
end

function setRandomPropColor(widget, nPropValue, nPropTypeRandID)
	--nPropID参数暂时不用，因为脚本rowkey的ID不是这个
	local CSV_EquipPropRandType = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("EquipPropRandType",nPropTypeRandID, 1)

	local nIndex = ccs.COLOR.WHITE
	if nPropValue < CSV_EquipPropRandType.PropArea1 then	--白色
		nIndex = ccs.COLOR.WHITE
	elseif nPropValue < CSV_EquipPropRandType.PropArea2 then	--深绿
		nIndex = ccs.COLOR.LIME_GREEN
	elseif nPropValue < CSV_EquipPropRandType.PropArea3 then	--深蓝
		nIndex = ccs.COLOR.DARK_SKY_BLUE
	elseif nPropValue < CSV_EquipPropRandType.PropArea4 then	--洋红
		nIndex = ccs.COLOR.FUCHSIA
	elseif nPropValue < CSV_EquipPropRandType.PropArea5 then	--金色
		nIndex = ccs.COLOR.GOLD
    elseif nPropValue >= 1000 then	--红色
		nIndex = ccs.COLOR.RED
	end
	g_setTextColor(widget,nIndex)
end


function g_isRandomInRange(nIn, nBaseNum)
    if not nBaseNum or not nIn then
        cclog("g_isRandomInRange error")
        return false
    end

	local nRandom = math.random(1, nBaseNum)
	return nRandom <= nIn
end

function g_luaToJson(strTab)
   local jsonStr = "{"
   local k = 0
   for i,v in pairs(strTab) do
       if k >= 1 then
           jsonStr = jsonStr..","
       end
       jsonStr = jsonStr.."\""..i.."\""..":".."\""..v.."\""
       k = k + 1
   end
   return jsonStr.."}"
end

--设置头像 
function g_SetPlayerHead(Image_Head, tbHeadInfo, isCallBack)
	local Image_Frame = tolua.cast(Image_Head:getChildByName("Image_Frame"),"ImageView")	
	local Image_Icon = tolua.cast(Image_Head:getChildByName("Image_Icon"),"ImageView")
	local LabelBMFont_VipLevel = tolua.cast(Image_Head:getChildByName("LabelBMFont_VipLevel"),"LabelBMFont")	
	local Image_StarLevel = tolua.cast(Image_Head:getChildByName("Image_StarLevel"),"ImageView")	
	
	if tbHeadInfo.vip and LabelBMFont_VipLevel then
		LabelBMFont_VipLevel:setText(_T("VIP")..tbHeadInfo.vip)
	end
	if Image_StarLevel then
		Image_StarLevel:loadTexture(getIconStarLev(tbHeadInfo.star))
	end
	
	if tbHeadInfo.strName and tbHeadInfo.strName == _T("小语") then
		Image_Icon:loadTexture(getIconImg("XiaoYu"))
	else
		Image_Icon:loadTexture(tbHeadInfo.Image_Icon)
	end
	
	Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbHeadInfo.breachlv))
	Image_Head:loadTexture(getCardBackByEvoluteLev(tbHeadInfo.breachlv))
	
	--头像回调
	if tbHeadInfo.uin ~= g_MsgMgr:getUin() and isCallBack == true then
		Image_Icon:setTouchEnabled(true)
		Image_Icon:addTouchEventListener(function(pSender,eventType)
			if eventType ==ccs.TouchEventType.ended then
				if tbHeadInfo.strName and tbHeadInfo.strName == _T("小语") then
					g_ShowSysTips({text=_T("暂时还无法查看官方Npc哦亲")})
				else
					local tag =  pSender:getTag()
					g_MsgMgr:requestViewPlayer(tbHeadInfo.uin)
				end
			end
		end)
	end 
end

function g_ResourceValueFormat(nValue)
	if nValue > 100000000 then
		local nValue = math.floor(nValue/1000000)/100
		return nValue.._T("亿")
	elseif nValue > 10000 then
		local nValue = math.floor(nValue/1000)/10
		return nValue.._T("万")
	end
	return nValue
end