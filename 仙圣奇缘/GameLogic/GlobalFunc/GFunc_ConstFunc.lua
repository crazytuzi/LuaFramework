--------------------------------------------------------------------------------------
-- 文件名:	LYP_ConstFunc.lua.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-2-13 17:37
-- 版  本:	1.0
-- 描  述:	游戏通用模板函数
-- 应  用:  本例子是用类对象的方式实现

---------------------------------------------------------------------------------------

function getSubTypeNameByType(nType)
	if nType == 1 then --装备
		return _T("拳套")
	elseif nType == 2 then
		return _T("刀剑")
	elseif nType == 3 then
		return _T("弓弩")
	elseif nType == 4 then
		return _T("法杖")
	elseif nType == 5 then
		return _T("枪戟")
	elseif nType == 6 then
		return _T("法袍")
	elseif nType == 7 then
		return _T("戒指")
	elseif nType == 8 then
		return _T("项链")
	elseif nType == 9 then
		return _T("法器")
	elseif nType == 10 then
		return _T("战靴")
	end
	
	return ""
end

--设置装备信息
--addPosType=0是装备查看伙伴中的随机属性位置生成规则
--addPosType=1是装备打造中的装备材料伙伴随机属性位置生成规则
function setEquipInfo(equipItemModel, GameObj_MainEquip, addPosType)
	if(equipItemModel == nil or type(equipItemModel) ~= "userdata")then
		cclog("setEquipInfo:userdata error")
		return
	end
	
	if(GameObj_MainEquip == nil)then
		cclog("setEquipInfo:GameObj_MainEquip nil")
		return
	end
	
	local nStarLev = GameObj_MainEquip:getStarLevel()
	local CSV_Equip = g_DataMgr:getEquipCsv(GameObj_MainEquip:getCsvID(), nStarLev)
	if(CSV_Equip == nil)then
		cclog("setEquipInfo:CSV_Equip nil")
		return
	end
	
	local Label_Name = tolua.cast(equipItemModel:getChildByName("Label_Name"), "Label")
	Label_Name:setText((CSV_Equip.Name))
	g_SetWidgetColorBySLev(Label_Name, CSV_Equip.ColorType)
	
	local Label_Owner = tolua.cast(equipItemModel:getChildByName("Label_Owner"), "Label")
	if Label_Owner then
		Label_Owner:setText(GameObj_MainEquip:getOwnerName(Label_Owner))
	end

	local LabelAtlas_StarLevel = tolua.cast(equipItemModel:getChildByName("LabelAtlas_StarLevel"), "LabelAtlas")
	LabelAtlas_StarLevel:setStringValue(g_tbStarLevel[nStarLev])
	
	local Image_EquipIcon = tolua.cast(equipItemModel:getChildByName("Image_EquipIcon"), "ImageView")
	if Image_EquipIcon then
		Image_EquipIcon:loadTexture(getIconImg(CSV_Equip.Icon))
	end
	
	local Label_StrengthenLevel= tolua.cast(equipItemModel:getChildByName("Label_StrengthenLevel"), "Label")
	local nStrengthenLevel = GameObj_MainEquip:getStrengthenLev()
	local nStrengthenFatherLevel, szStrengthenSubLevel = g_getEquipAtlasNameLev(nStrengthenLevel)
	Label_StrengthenLevel:setText(g_EquipStrengthenLevName[nStrengthenFatherLevel].." "..szStrengthenSubLevel)
	
	local nType = tonumber(CSV_Equip.SubType)
	local Label_MainProp = tolua.cast(equipItemModel:getChildByName("Label_MainProp"), "Label")
	Label_MainProp:setText(g_tbEquipMainProp[nType].." "..GameObj_MainEquip:getEquipMainPropFloor())  
	
	local tbProp = GameObj_MainEquip:getEquipTbProp()
	
	local Panel_AddProp
	if addPosType == 2 then
		Panel_AddProp = tolua.cast(equipItemModel:getChildByName("Panel_AddProp"), "ImageView")
		Panel_AddProp:removeAllChildren()
	else
		Panel_AddProp = tolua.cast(equipItemModel:getChildByName("Panel_AddProp"), "Layout")
		Panel_AddProp:removeAllChildren()
	end
	
	for i = 1, #tbProp do
		local Label_AdditionalProp = Label:create()
		
		local tbSubProp = tbProp[i]
		local nType = tbSubProp.Prop_Type
		local bIsPercent, nBasePercent = g_CheckPropIsPercent(nType)
		if bIsPercent then 
			Label_AdditionalProp:setText(g_PropName[nType].." +"..string.format("%.2f", tbSubProp.Prop_Value/nBasePercent))
		else
			Label_AdditionalProp:setText(g_PropName[nType].." +"..tbSubProp.Prop_Value)
		end
		
		g_setTextColor(Label_AdditionalProp, ccs.COLOR.GOLD)
		
		Label_AdditionalProp:setAnchorPoint(ccp(0.5, 0.5))
		if addPosType == 0 then
			Label_AdditionalProp:setFontSize(21)
			Label_AdditionalProp:setPosition(ccp(0, -(i-1)*28))
		elseif	addPosType == 1 then
			Label_AdditionalProp:setFontSize(18)
			Label_AdditionalProp:setPosition(ccp(0, -(i-1)*23))
		elseif	addPosType == 2 then
			Label_AdditionalProp:setFontSize(21)
			Label_AdditionalProp:setPosition(ccp(0, -(i-1)*28))
		end
		
		Panel_AddProp:addChild(Label_AdditionalProp)
	end
end


--判断nData的nPos 是否是1，从右往左 1,2,...
function GGetDataByPos(nData, nPos)
	if(not nData or not nPos)then
		cclog("GGetDataByPos nil")
		return 0
	end 
	
	if(nPos <= 0)then
		cclog("GGetDataByPos "..nPos)
		return 0
	end
	local npow = math.pow(10, nPos)
	local temp = math.floor(math.mod(nData, npow))
	npow =  npow/10
	temp = math.floor(temp/npow)
	return temp
end

--判断nData的nPos 是否是1，从右往左 1,2,...
function GSetDataByPos(nData, nPos, nNum)
	if(not nData or not nPos or not nNum)then
		cclog("GSetDataByPos nil")
		return 0
	end 
	
	if(nPos <= 0)then
		cclog("GSetDataByPos nPos "..nPos)
		return 0
	end
	
	if(nNum <= 0)then
		cclog("GSetDataByPos nNum "..nNum)
		return 0
	end
	
	
	local nHPow = math.pow(10, nPos)
	local nLPow = nHPow/10
	local nHigh = math.floor(nData/nHPow)
	local nLow = math.floor(math.mod(nData, nLPow))
	local temp = nHigh*nHPow + nNum*nLPow + nLow
	return temp
end


function GetTableLen(tbTable)
	if(tbTable == nil or type(tbTable) ~= "table")then
		return 0
	end
	
	local nLen = 0
	for k, v in pairs(tbTable) do  
		nLen = nLen + 1
	end 
	return nLen
end

--职业名字
function g_GetAtlasName(szLev)
	local nLevel = tonumber(szLev)
	local szName = "1"
	for i = 2, nLevel do
		szName = szName.."1"
	end
	
	return szName
end

tUpdateServerTime = tUpdateServerTime or 0
tClientTime = tClientTime or 0
--服务器时间

function g_SetServerTime(tsTime)
	cclog("server time:"..tsTime)
	tUpdateServerTime = tsTime
	tClientTime = os.time()
	cclog(tUpdateServerTime.."server time:"..tsTime)
end

function g_GetServerTime()
	return tUpdateServerTime + os.time() - tClientTime;
end

function g_GetServerYear()
	local tServerTime = g_GetServerTime()
	return tonumber(os.date("%Y", tServerTime))
end

function g_GetServerMonth()
	local tServerTime = g_GetServerTime()
	return tonumber(os.date("%m", tServerTime))
end

function g_GetServerDay()
	local tServerTime = g_GetServerTime()
	return tonumber(os.date("%d", tServerTime))
end

function g_GetServerHour()
	local tServerTime = g_GetServerTime()
	return tonumber(os.date("%H", tServerTime))
end

function g_GetServerMin()
	local tServerTime = g_GetServerTime()
	return tonumber(os.date("%M", tServerTime))
end

function g_GetServerSecs()
	local tServerTime = g_GetServerTime()
	return tonumber(os.date("%S", tServerTime))
end

--获得服务器时间的星期几（0~6,星期7到星期六）
function g_GetServerWday()
	local tServerTime = g_GetServerTime()
	return tonumber(os.date("%w", tServerTime))
end

--获取当前时间与指定时间相差多少天
-- 处理时差要减8
function g_GetRemainDay(nDeadline)
	local nServerTime = g_GetServerTime()
	local tbServerTime = SecondsToTable(nServerTime)
	nServerTime = nServerTime + 16 * 3600 - tbServerTime.hour % 24 * 3600 - tbServerTime.min * 60 - tbServerTime.sec

	local tbDeadline = SecondsToTable(nDeadline)
	nDeadline = nDeadline + 16 * 3600 - tbDeadline.hour % 24 * 3600 - tbDeadline.min * 60 - tbDeadline.sec

	local nRemainDay = math.ceil((nDeadline - nServerTime) / 3600 / 24)
	return nRemainDay > 0 and nRemainDay or 0
end



-- 是否在时间段内
-- 返回：0 - 在时间段内
--		-1 - 在时间段前
--		 1 - 在时间段后
-- 容错处理，格式错误情况下，都返回0（默认为在指定时间段内）
-- 例：TimePeriodCompare("12:00", "15:24") --判断当前时间是否在[12点00分,15点24分]这一时间段内
function TimePeriodCompare(from, to)
	if #from==0 or #to==0 then return 0 end
	
	from = from .. ":"
	to = to .. ":"
	local tb_from = from:split(":")
	local tb_to = to:split(":")
	if #tb_from<2 or #tb_to<2 then return 0 end
	for i in ipairs(tb_from) do tb_from[i]=tonumber(tb_from[i]) end
	for i in ipairs(tb_to) do tb_to[i]=tonumber(tb_to[i]) end
	if tb_from[1]>tb_to[1] or (tb_from[1]==tb_to[2] and tb_from[2]>tb_to[2]) then return 0 end
	
	local n_from = tb_from[1]*100 + tb_from[2]
	local n_to = tb_to[1]*100 + tb_to[2]
	
	local tb_now = os.date("*t",g_GetServerTime())
	local n_now = tb_now.hour*100 + tb_now.min;
	if n_now>=n_from and n_now<=n_to then
		return 0
	elseif n_now>n_to then
		return 1
	else
		return -1
	end
end

-- 将sec秒转换成table{day=a, hour=b, min=c, sec=d}
function SecondsToTable(sec)
	local ret = {}
	-- ret.day = math.floor(sec/(3600*24))
	-- ret.hour = math.floor((sec%(3600*24))/3600)
	ret.hour = math.floor((sec/(3600)))
	ret.min = math.floor((sec%3600)/60)
	ret.sec = math.floor(sec%60)
	return ret
end

-- 将时间table转换成字符串
function TimeTableToStr(tb,divide,post)
	local ret = ""
	-- local d,h,m,s = "天","小时","分","秒"
	local h,m,s = "小时","分","秒"
	if divide then 
		-- d,h,m,s = divide,divide,divide,""
		h,m,s = divide,divide,""
		-- if tb.day >= 0 then 
			-- if tb.day < 10 then ret = ret.."0" end
			-- ret = ret..tb.day..d 
		-- end
		if tb.hour >= 0 and not post then
			if tb.hour < 10 then ret = ret.."0" end
			ret = ret..tb.hour..h 
		end
		if tb.min >= 0 then
			if tb.min < 10 then ret = ret.."0" end
			ret = ret..tb.min..m 
		end
		if tb.sec >= 0 then
			if tb.sec < 10 then ret = ret.."0" end
			ret =ret..tb.sec..s 
		end
		return ret
	else
		-- if tb.day > 0 then ret = ret..tb.day..d end
		if tb.hour > 0 then ret = ret..tb.hour..h end
		if tb.min > 0 then ret = ret..tb.min..m end
		if tb.sec > 0 then ret = ret..tb.sec..s end
		return ret
	end
end

-- 判断当前时间是否和指定时间同一天
-- t是时间戳
function IsSameDay(t)
	local tb_t = os.date("*t", t)
	local tb_now = os.date("*t", g_GetServerTime())
	return tb_t.year==tb_now.year and tb_t.month==tb_now.month and tb_t.day==tb_now.day
end

function GetTimeTo(deadline)
	local delta = deadline - g_GetServerTime()
	if delta<=0 then return "00:00:00",true end
	local tb = SecondsToTable(delta)
	return string.format("%.2d:%.2d:%.2d", tb.hour, tb.min, tb.sec),false
end

-- lua table to string
function lua2str(v)
    local function str(t)
        return type(t)=="string" and ('"' .. string.gsub(t,"\n","\\n") .. '"') or tostring(t)
    end

    local reg = {}
    local ret = {}
    local function _plua(k,t,tab)
        if type(t)=="table" then
            if reg[t]~=nil then
                ret[#ret+1] = reg[t] .. "\n"
            else
                reg[t] = tostring(k) .. "(" .. tostring(t) .. "),"
                ret[#ret+1] = "{\n"
                local old = tab
                tab = tab .. "    "
                for k,v in pairs(t) do
                    ret[#ret+1] = tab .. tostring(k) .. " = "
                    _plua(k,v,tab)
                end
                ret[#ret+1] = old .. "}, " .. "\n"
            end
        else
            ret[#ret+1] = str(t) .. ",\n"
        end
    end

    _plua("root", v, "")
    return "\n"..table.concat(ret)
end

-- lua table to string
function tableToString(_t)  
    local szRet = "{\n"  
    function doT2S(_i, _v)  
        if "number" == type(_i) then  
            --szRet = szRet .. "[" .. _i .. "] = "  
            if "number" == type(_v) then  
                szRet = szRet .. _v .. ","
            elseif "string" == type(_v) then  
                szRet = szRet .. '[[' .. _v .. ']]' .. ","  
            elseif "table" == type(_v) then  
                szRet = szRet .. tableToString(_v) .. ","  
            else  
                szRet = szRet .. "nil,"  
            end  
        elseif "string" == type(_i) then  
            szRet = szRet .. '["' .. _i .. '"] = '  
            if "number" == type(_v) then  
                szRet = szRet .. _v .. ","  
            elseif "string" == type(_v) then  
                szRet = szRet .. '[[' .. _v .. ']]' .. ","  
            elseif "table" == type(_v) then  
                szRet = szRet .. tableToString(_v) .. ","  
            else  
                szRet = szRet .. "nil,"  
            end  
        end
        szRet = szRet .."\n"  
    end  
    table.foreach(_t, doT2S)  
    szRet = szRet .. "}"  
    return szRet  
end  

function starLvNum2Str(nNum)
	nNum = tonumber(nNum)
	local ret = ""
	for i=1,nNum do
		ret = ret.."1"
	end
	return ret
end

--根据Icon类型克隆Icon
function getIconByType(nDropItemID, nDropItemStarLevel, nDropItemType)
	local strDropIcon = ""
	local CSV_Data = nil
	if nDropItemType then
	   if nDropItemType == macro_pb.ITEM_TYPE_CARD then  --伙伴
			CSV_Data = g_DataMgr:getCardBaseCsv(nDropItemID, nDropItemStarLevel)
			strDropIcon = getIconImg(CSV_Data.SpineAnimation)
		elseif nDropItemType == macro_pb.ITEM_TYPE_EQUIP then --装备
			CSV_Data = g_DataMgr:getEquipCsv(nDropItemID, nDropItemStarLevel)
			strDropIcon =  getIconImg(CSV_Data.Icon)
		elseif nDropItemType == macro_pb.ITEM_TYPE_ARRAYMETHOD then --阵法
			--暂无
		elseif nDropItemType == macro_pb.ITEM_TYPE_FATE then --异兽
            CSV_Data = g_DataMgr:getCardFateCsv(nDropItemID, nDropItemStarLevel)
			strDropIcon =  getIconImg(CSV_Data.Animation)
		elseif nDropItemType == macro_pb.ITEM_TYPE_CARD_GOD then --魂魄
			CSV_Data = g_DataMgr:getCardHunPoCsv(nDropItemID)
			local CSV_Card = g_DataMgr:getCardBaseCsv(nDropItemID, CSV_Data.CardStarLevel)
			strDropIcon = getIconImg(CSV_Card.SpineAnimation)
		elseif nDropItemType == macro_pb.ITEM_TYPE_MATERIAL then --材料
			CSV_Data = g_DataMgr:getItemBaseCsv(nDropItemID, nDropItemStarLevel)
			strDropIcon = getIconImg(CSV_Data.Icon)
		elseif nDropItemType == macro_pb.ITEM_TYPE_SOUL then  --元神
			CSV_Data = g_DataMgr:getCardSoulCsv(nDropItemID, nDropItemStarLevel)
			strDropIcon = getIconImg(CSV_Data.Icon)
		elseif nDropItemType == macro_pb.ITEM_TYPE_MASTER_EXP then --主角经验
			strDropIcon = getIconImg("ResourceDrop8_YueLi")
		elseif nDropItemType == macro_pb.ITEM_TYPE_MASTER_ENERGY then --体力
			strDropIcon = getIconImg("ResourceDrop9_Energy")
		elseif nDropItemType == macro_pb.ITEM_TYPE_COUPONS then --元宝
			strDropIcon = getIconImg("ResourceDrop10_YuanBao")
		elseif nDropItemType == macro_pb.ITEM_TYPE_GOLDS then --铜钱
			strDropIcon = getIconImg("ResourceDrop11_TongQian")
		elseif nDropItemType == macro_pb.ITEM_TYPE_PRESTIGE then  --声望
			strDropIcon = getIconImg("ResourceDrop12_Prestige")
		elseif nDropItemType == macro_pb.ITEM_TYPE_KNOWLEDGE then  --阅历
			strDropIcon = getIconImg("ResourceDrop13_Knowledge")
		elseif nDropItemType == macro_pb.ITEM_TYPE_INCENSE then  --香贡
			strDropIcon = getIconImg("ResourceDrop14_Incense")
		elseif nDropItemType == macro_pb.ITEM_TYPE_POWER then  --神力
			strDropIcon = getIconImg("ResourceDrop14_Incense")
		elseif nDropItemType == macro_pb.ITEM_TYPE_ARENA_TIME then  --竞技场挑战次数
			strDropIcon = getIconImg("ResourceDrop16_ArenaTimes")
		elseif nDropItemType == macro_pb.ITEM_TYPE_ESSENCE then  --元素精华、灵力
			strDropIcon = getIconImg("ResourceDrop17_Essence")
		elseif nDropItemType == macro_pb.ITEM_TYPE_FRIENDHEART then  --友情之心
			strDropIcon = getIconImg("ResourceDrop18_FriendPoints")
		elseif nDropItemType == macro_pb.ITEM_TYPE_CARDEXPINBATTLE then  --出战伙伴经验
			strDropIcon = getIconImg("ResourceDrop19_CardExp")
		elseif nDropItemType == macro_pb.ITEM_TYPE_XIAN_LING then  --仙令
			strDropIcon = getIconImg("ResourceDrop20_XianLing")
		elseif nDropItemType == macro_pb.ITEM_TYPE_DRAGON_BALL then  --神龙令
			strDropIcon = getIconImg("ResourceDrop21_ShenLongLing")
		elseif nDropItemType == macro_pb.ITEM_TYPE_XIANMAI_ONE_KEY then  --一键消除
			strDropIcon = getIconImg("ResourceItem_XiaoChu1")
		elseif nDropItemType == macro_pb.ITEM_TYPE_XIANMAI_BA_ZHE then  --霸者横栏
			strDropIcon = getIconImg("ResourceItem_XiaoChu2")
		elseif nDropItemType == macro_pb.ITEM_TYPE_XIANMAI_LIAN_SUO then  --消除连锁
			strDropIcon = getIconImg("ResourceItem_XiaoChu3")
		elseif nDropItemType == macro_pb.ITEM_TYPE_XIANMAI_DOU_ZHUAN then  --斗转星移
			strDropIcon = getIconImg("ResourceItem_XiaoChu4")
		elseif nDropItemType == macro_pb.ITEM_TYPE_XIANMAI_DIAN_DAO then  --颠倒乾坤
			strDropIcon = getIconImg("ResourceItem_XiaoChu5")
		elseif nDropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_METAL then  --金灵核
			strDropIcon = getIconImg("ResourceItem_LingHe1")
		elseif nDropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_NATURE then  --木灵核
			strDropIcon = getIconImg("ResourceItem_LingHe2")
		elseif nDropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_WATER then  --水灵核
			strDropIcon = getIconImg("ResourceItem_LingHe3")
		elseif nDropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_FIRE then  --火灵核
			strDropIcon = getIconImg("ResourceItem_LingHe4")
		elseif nDropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_EARTH then  --土灵核
			strDropIcon = getIconImg("ResourceItem_LingHe5")
		elseif nDropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_AIR then  --风灵核
			strDropIcon = getIconImg("ResourceItem_LingHe6")
		elseif nDropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_LIGHTNING then  --雷灵核
			strDropIcon = getIconImg("ResourceItem_LingHe7")
		elseif nDropItemType == macro_pb.ITEM_TYPE_SECRET_JIANGHUN then  --将魂石
			strDropIcon = getIconImg("ResourceDrop40_JiangHunShi")
		elseif nDropItemType == macro_pb.ITEM_TYPE_SECRET_REFRESH_TOKEN then  --将魂令
			strDropIcon = getIconImg("ResourceDrop41_RefreshToken")
		end
	end
	return strDropIcon, CSV_Data
end

--[[接口协议
CSV_DropItem = {
	DropItemType,
	DropItemID,
	DropItemStarLevel,
	DropItemNum,
	DropItemEvoluteLevel,
}
]]--

function g_CloneIconItemModelCard(CSV_DropItem)
	local CSV_Card = g_DataMgr:getCardBaseCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_Card then return nil end
	
	local itemModel = tolua.cast(g_WidgetModel.Image_DropCard:clone(),"ImageView")
	local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
	local Image_StarLevel = tolua.cast(itemModel:getChildByName("Image_StarLevel"),"ImageView")
	local Image_DropIcon = tolua.cast(itemModel:getChildByName("Image_DropIcon"),"ImageView")
	
	itemModel:loadTexture(getCardBackByEvoluteLev(CSV_DropItem.DropItemEvoluteLevel))
	Image_Frame:loadTexture(getCardFrameByEvoluteLev(CSV_DropItem.DropItemEvoluteLevel))
	Image_StarLevel:loadTexture(getIconStarLev(CSV_DropItem.DropItemStarLevel))
	Image_DropIcon:loadTexture(getIconImg(CSV_Card.SpineAnimation))
	
	return itemModel, CSV_Card, CSV_DropItem.DropItemStarLevel
end

function g_CloneIconItemModelEquip(CSV_DropItem)
	local CSV_Equip = g_DataMgr:getEquipCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_Equip then return nil end
	
	local itemModel = tolua.cast(g_WidgetModel.Image_DropEquip:clone(),"ImageView")
	local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
	local Image_DropIcon = tolua.cast(itemModel:getChildByName("Image_DropIcon"),"ImageView")
	
	itemModel:loadTexture(getFrameBackGround(CSV_Equip.ColorType))
	Image_Frame:loadTexture(getIconFrame(CSV_Equip.ColorType))
	Image_DropIcon:loadTexture(getIconImg(CSV_Equip.Icon))
	equipSacleAndRotate(Image_DropIcon, CSV_Equip.SubType)
	
	return itemModel, CSV_Equip, CSV_Equip.ColorType
end

function g_CloneIconItemModelFate(CSV_DropItem)
	local CSV_CardFate = g_DataMgr:getCardFateCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_CardFate then return nil end
	
	local itemModel = tolua.cast(g_WidgetModel.Image_DropFate:clone(),"ImageView")
	local Image_FateItem = tolua.cast(itemModel:getChildByName("Image_FateItem"),"ImageView")
	local Image_FrameGlass = tolua.cast(Image_FateItem:getChildByName("Image_FrameGlass"),"ImageView")
	local Panel_FateItem = tolua.cast(Image_FateItem:getChildByName("Panel_FateItem"),"Layout")
	local Image_DropIcon = tolua.cast(Panel_FateItem:getChildByName("Image_DropIcon"),"ImageView")
	local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
	
	itemModel:loadTexture(getFrameBackGround(CSV_CardFate.ColorType))
	--Image_FateItem:loadTexture(getFateBaseAImg(CSV_CardFate.ColorType))
	--Image_FrameGlass:loadTexture(getFateFrameImg(CSV_CardFate.ColorType))
	Panel_FateItem:setClippingEnabled(true)
	Panel_FateItem:setRadius(92)
	Image_DropIcon:setPosition(ccp(96+CSV_CardFate.OffsetX, 96+CSV_CardFate.OffsetY))
	Image_DropIcon:loadTexture(getIconImg(CSV_CardFate.Animation))
	Image_Frame:loadTexture(getIconFrame(CSV_CardFate.ColorType))
	
	return itemModel, CSV_CardFate, CSV_CardFate.ColorType
end

function g_CloneIconItemModelHunPo(CSV_DropItem)
	if CSV_DropItem.DropItemID > 0 then
		local CSV_CardHunPo = g_DataMgr:getCardHunPoCsv(CSV_DropItem.DropItemID)
		if not CSV_CardHunPo then return nil end
		local CSV_CardBase = g_DataMgr:getCardBaseCsv(CSV_DropItem.DropItemID, CSV_CardHunPo.CardStarLevel)
		if not CSV_CardBase then return nil end
		
		local itemModel = tolua.cast(g_WidgetModel.Image_DropHunPoItem:clone(),"ImageView")
		local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
		local Image_Cover = tolua.cast(itemModel:getChildByName("Image_Cover"),"ImageView")
		local Image_DropIcon = tolua.cast(itemModel:getChildByName("Image_DropIcon"),"ImageView")
		local Label_DropNum = tolua.cast(itemModel:getChildByName("Label_DropNum"),"Label")
		
		itemModel:loadTexture(getFrameBackGround(CSV_CardHunPo.CardStarLevel))
		Image_Frame:loadTexture(getIconFrame(CSV_CardHunPo.CardStarLevel))
		Image_Cover:loadTexture(getFrameCoverHunPo(CSV_CardHunPo.CardStarLevel))
		Image_DropIcon:loadTexture(getIconImg(CSV_CardBase.SpineAnimation))
		if CSV_DropItem.DropItemNum == "" or CSV_DropItem.DropItemNum == 0 then
			Label_DropNum:setText("")
		else
			Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
		end
		return itemModel, CSV_CardHunPo
	else
		local CSV_CardHunPo = g_DataMgr:getCardHunPoCsv(0)
		if not CSV_CardHunPo then return nil end
		
		local itemModel = tolua.cast(g_WidgetModel.Image_DropHunPoItem:clone(),"ImageView")
		local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
		local Image_Cover = tolua.cast(itemModel:getChildByName("Image_Cover"),"ImageView")
		local Image_DropIcon = tolua.cast(itemModel:getChildByName("Image_DropIcon"),"ImageView")
		local Label_DropNum = tolua.cast(itemModel:getChildByName("Label_DropNum"),"Label")
		
		itemModel:loadTexture(getFrameBackGround(3))
		Image_Frame:loadTexture(getIconFrame(3))
		Image_Cover:loadTexture(getFrameCoverHunPo(3))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop5_HunPo"))
		Label_DropNum:setText("")
		
		return itemModel, CSV_CardHunPo, CSV_CardHunPo.CardStarLevel
	end
end

local function g_CloneIconItemModelItemBaseMaterial(itemModel, CSV_DropItem, CSV_ItemBase)
	local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
	local Image_DropIcon = tolua.cast(itemModel:getChildByName("Image_DropIcon"),"ImageView")
	local Label_DropNum = tolua.cast(itemModel:getChildByName("Label_DropNum"),"Label")
	
	Image_Frame:loadTexture(getIconFrame(CSV_ItemBase.ColorType))
	Image_DropIcon:loadTexture(getIconImg(CSV_ItemBase.Icon))
	if CSV_DropItem.DropItemNum == "" or CSV_DropItem.DropItemNum == 0 then
		Label_DropNum:setText("")
	else
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	end
	
	local Image_IconTag = tolua.cast(itemModel:getChildByName("Image_IconTag"), "ImageView")
	if CSV_ItemBase.SubType == NUM_ItemBaseSubType.EquipComposeMaterial then
		Image_IconTag:setVisible(true)
		Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..CSV_ItemBase.FormulaType))
	else
		Image_IconTag:setVisible(false)
	end
end

local function g_CloneIconItemModelItemBaseSkillFrag(itemModel, CSV_DropItem, CSV_ItemBase)
	local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
	local Image_DropIcon = tolua.cast(itemModel:getChildByName("Image_DropIcon"),"ImageView")
	local Label_DropNum = tolua.cast(itemModel:getChildByName("Label_DropNum"),"Label")
	local Image_Symbol = tolua.cast(itemModel:getChildByName("Image_Symbol"),"ImageView")
	
	Image_Frame:loadTexture(getIconFrame(CSV_ItemBase.ColorType))
	Image_DropIcon:loadTexture(getIconImg(CSV_ItemBase.Icon))
	if CSV_DropItem.DropItemNum == "" or CSV_DropItem.DropItemNum == 0 then
		Label_DropNum:setText("")
	else
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	end
	Image_Symbol:loadTexture(getFrameSymbolSkillFrag(CSV_ItemBase.ColorType))
	
	local Image_IconTag = tolua.cast(itemModel:getChildByName("Image_IconTag"), "ImageView")
	if CSV_ItemBase.SubType == NUM_ItemBaseSubType.EquipComposeMaterialFrag then
		Image_IconTag:setVisible(true)
		Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..CSV_ItemBase.FormulaType))
	else
		Image_IconTag:setVisible(false)
	end
end

local function g_CloneIconItemModelItemBaseUseItem(itemModel, CSV_DropItem, CSV_ItemBase)
	local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
	local Image_DropIcon = tolua.cast(itemModel:getChildByName("Image_DropIcon"),"ImageView")
	local Label_DropNum = tolua.cast(itemModel:getChildByName("Label_DropNum"),"Label")
	
	Image_Frame:loadTexture(getIconFrame(CSV_ItemBase.ColorType))
	Image_DropIcon:loadTexture(getIconImg(CSV_ItemBase.Icon))
	if CSV_DropItem.DropItemNum == "" or CSV_DropItem.DropItemNum == 0 then
		Label_DropNum:setText("")
	else
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	end
	
	local Image_IconTag = tolua.cast(itemModel:getChildByName("Image_IconTag"), "ImageView")
	if CSV_ItemBase.SubType == NUM_ItemBaseSubType.EquipMaterialPack or CSV_ItemBase.SubType == NUM_ItemBaseSubType.EquipFormulaPack then
		Image_IconTag:setVisible(true)
		Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..CSV_ItemBase.StarLevel))
	elseif CSV_ItemBase.SubType == NUM_ItemBaseSubType.SoulMaterialPack then
		Image_IconTag:setVisible(true)
		Image_IconTag:loadTexture(getUIImg("Image_SoulTag_"..CSV_ItemBase.ColorType.."_"..CSV_ItemBase.FormulaType))
	elseif CSV_ItemBase.SubType == NUM_ItemBaseSubType.RandomPack then
		Image_IconTag:setVisible(true)
		Image_IconTag:loadTexture(getUIImg("Image_PackRandTag"..CSV_ItemBase.ColorType))
	elseif CSV_ItemBase.SubType == NUM_ItemBaseSubType.SelectedPack then
		Image_IconTag:setVisible(true)
		Image_IconTag:loadTexture(getUIImg("Image_PackSelectTag"..CSV_ItemBase.ColorType))
	else
		Image_IconTag:setVisible(false)
	end
end

local function g_CloneIconItemModelItemBaseFormula(itemModel, CSV_DropItem, CSV_ItemBase)
	local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
	local Image_DropIcon = tolua.cast(itemModel:getChildByName("Image_DropIcon"),"ImageView")
	local Label_DropNum = tolua.cast(itemModel:getChildByName("Label_DropNum"),"Label")
	local Image_Symbol = tolua.cast(itemModel:getChildByName("Image_Symbol"),"ImageView")
	
	Image_Frame:loadTexture(getIconFrame(CSV_ItemBase.ColorType))
	Image_DropIcon:loadTexture(getIconImg(CSV_ItemBase.Icon))
	equipSacleAndRotate(Image_DropIcon, CSV_ItemBase.FormulaType)
	if CSV_DropItem.DropItemNum == "" or CSV_DropItem.DropItemNum == 0 then
		Label_DropNum:setText("")
	else
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	end
	Image_Symbol:loadTexture(getFrameSymbolFormula(CSV_ItemBase.ColorType))
	
	local Image_IconTag = tolua.cast(itemModel:getChildByName("Image_IconTag"), "ImageView")
	Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..(math.mod(CSV_ItemBase.ID, 100) - 1)))
	Image_IconTag:setVisible(true)
		
end

local function g_CloneIconItemModelItemBaseEquipPack(itemModel, CSV_DropItem, CSV_ItemBase)
	local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
	local Image_DropIcon = tolua.cast(itemModel:getChildByName("Image_DropIcon"),"ImageView")
	local Label_DropNum = tolua.cast(itemModel:getChildByName("Label_DropNum"),"Label")
	local Image_Symbol = tolua.cast(itemModel:getChildByName("Image_Symbol"),"ImageView")
	
	Image_Frame:loadTexture(getIconFrame(CSV_ItemBase.ColorType))
	Image_DropIcon:loadTexture(getIconImg(CSV_ItemBase.Icon))
	equipSacleAndRotate(Image_DropIcon, CSV_ItemBase.FormulaType)
	if CSV_DropItem.DropItemNum == "" or CSV_DropItem.DropItemNum == 0 then
		Label_DropNum:setText("")
	else
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	end
	Image_Symbol:loadTexture(getIconImg("ResourceItem_MaterialPack"..CSV_ItemBase.ColorType))
	
	local Image_IconTag = tolua.cast(itemModel:getChildByName("Image_IconTag"), "ImageView")
	Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..(math.mod(CSV_ItemBase.ID, 100) - 1)))
	Image_IconTag:setVisible(true)
end

function g_CloneIconItemModelItemBase(CSV_DropItem)
	local CSV_ItemBase = g_DataMgr:getItemBaseCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_ItemBase then return nil end
	local itemModel = nil
	if CSV_ItemBase.Type == 0 then
		itemModel = tolua.cast(g_WidgetModel.Image_DropItemMaterial:clone(),"ImageView")
		g_CloneIconItemModelItemBaseMaterial(itemModel, CSV_DropItem, CSV_ItemBase)
	elseif CSV_ItemBase.Type == 1 then
		itemModel = tolua.cast(g_WidgetModel.Image_DropItemSkillFrag:clone(),"ImageView")
		g_CloneIconItemModelItemBaseSkillFrag(itemModel, CSV_DropItem, CSV_ItemBase)
	elseif CSV_ItemBase.Type == 2 or CSV_ItemBase.Type == 6 then
		itemModel = tolua.cast(g_WidgetModel.Image_DropItemUseItem:clone(),"ImageView")
		g_CloneIconItemModelItemBaseUseItem(itemModel, CSV_DropItem, CSV_ItemBase)
	elseif CSV_ItemBase.Type == 3 then
		itemModel = tolua.cast(g_WidgetModel.Image_DropItemFormula:clone(),"ImageView")
		g_CloneIconItemModelItemBaseFormula(itemModel, CSV_DropItem, CSV_ItemBase)
	elseif CSV_ItemBase.Type == 4 then
		itemModel = tolua.cast(g_WidgetModel.Image_DropItemEquipPack:clone(),"ImageView")
		g_CloneIconItemModelItemBaseEquipPack(itemModel, CSV_DropItem, CSV_ItemBase)
	else 
		itemModel = tolua.cast(g_WidgetModel.Image_DropItemUseItem:clone(),"ImageView")
		g_CloneIconItemModelItemBaseUseItem(itemModel, CSV_DropItem, CSV_ItemBase)
	end
	itemModel:loadTexture(getFrameBackGround(CSV_ItemBase.ColorType))
	
	return itemModel, CSV_ItemBase, CSV_ItemBase.ColorType
end

function g_CloneIconItemModelSoul(CSV_DropItem)
	local CSV_CardSoul = g_DataMgr:getCardSoulCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_CardSoul then return nil end
	
	local itemModel = tolua.cast(g_WidgetModel.Image_DropCardSoul:clone(),"ImageView")
	local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
	local Image_Cover = tolua.cast(itemModel:getChildByName("Image_Cover"),"ImageView")
	local Label_DropNum = tolua.cast(itemModel:getChildByName("Label_DropNum"),"Label")
	local Image_DropIcon = tolua.cast(itemModel:getChildByName("Image_DropIcon"),"ImageView")
	
	itemModel:loadTexture(getFrameBackGround(CSV_CardSoul.StarLevel))
	Image_Frame:loadTexture(getIconFrame(CSV_CardSoul.StarLevel))
	Image_Cover:loadTexture(getFrameCoverSoul(CSV_CardSoul.StarLevel))
	Image_DropIcon:loadTexture(getIconImg(CSV_CardSoul.SpineAnimation))
	if CSV_DropItem.DropItemNum == "" or CSV_DropItem.DropItemNum == 0 then
		Label_DropNum:setText("")
	else
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	end
	
	local Label_Level = tolua.cast(itemModel:getChildByName("Label_Level"), "Label")
	Label_Level:setText(_T("Lv.")..CSV_CardSoul.Level)
	
	local nStrLen = string.len(CSV_CardSoul.Name)
	local strName = string.sub(CSV_CardSoul.Name, 10, nStrLen)
	CSV_CardSoul.Desc = strName.._T("的元神，被伙伴吞噬后可为伙伴增加境界经验，从而提高伙伴的境界。")
	
	local Image_SoulType = tolua.cast(itemModel:getChildByName("Image_SoulType"), "ImageView")
	if CSV_CardSoul.Class < 5 then
		Image_SoulType:loadTexture(getUIImg("Image_SoulTag_"..CSV_CardSoul.StarLevel.."_"..CSV_CardSoul.FatherLevel))
	else
		Image_SoulType:loadTexture(getEctypeIconResource("FrameEctypeNormalChar", CSV_CardSoul.StarLevel))
	end
	
	return itemModel, CSV_CardSoul, CSV_CardSoul.StarLevel
end

function g_CloneIconItemModelResource(CSV_DropItem, strIcon)
	local itemModel = tolua.cast(g_WidgetModel.Image_DropResource:clone(),"ImageView")
	local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
	local Image_DropIcon = tolua.cast(itemModel:getChildByName("Image_DropIcon"),"ImageView")
	local Label_DropNum = tolua.cast(itemModel:getChildByName("Label_DropNum"),"Label")
	
	CSV_DropItem.DropItemStarLevel = 5
	
	itemModel:loadTexture(getFrameBackGround(CSV_DropItem.DropItemStarLevel))
	Image_Frame:loadTexture(getIconFrame(CSV_DropItem.DropItemStarLevel))
	
	local tbCsvBase = {
		Name = ""
	}

	if CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_MASTER_EXP then
		tbCsvBase.Name = _T("掌门经验")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_MASTER_ENERGY then
		tbCsvBase.Name = _T("体力")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_COUPONS then
		tbCsvBase.Name = _T("元宝")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_GOLDS then
		tbCsvBase.Name = _T("铜钱")
		Label_DropNum:setText("×"..g_ResourceValueFormat(CSV_DropItem.DropItemNum))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_PRESTIGE then
		tbCsvBase.Name = _T("声望")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_KNOWLEDGE then
		tbCsvBase.Name = _T("阅历")
		Label_DropNum:setText("×"..g_ResourceValueFormat(CSV_DropItem.DropItemNum))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_INCENSE then
		tbCsvBase.Name = _T("香贡")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_POWER then
		tbCsvBase.Name = _T("神力")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_ARENA_TIME then
		tbCsvBase.Name = _T("天榜挑战次数")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_ESSENCE then
		tbCsvBase.Name = _T("灵力")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_FRIENDHEART then
		tbCsvBase.Name = _T("友情之心")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_CARDEXPINBATTLE then
		tbCsvBase.Name = _T("伙伴经验")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIAN_LING then
		tbCsvBase.Name = _T("仙令")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_DRAGON_BALL then
		tbCsvBase.Name = _T("神龙令")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ONE_KEY then
		tbCsvBase.Name = _T("一键消除")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_BA_ZHE then
		tbCsvBase.Name = _T("霸者横栏")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_LIAN_SUO then
		tbCsvBase.Name = _T("清除连锁")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_DOU_ZHUAN then
		tbCsvBase.Name = _T("斗转星移")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_DIAN_DAO then
		tbCsvBase.Name = _T("颠倒乾坤")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_METAL then
		tbCsvBase.Name = _T("金灵核")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_NATURE then
		tbCsvBase.Name = _T("木灵核")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_WATER then
		tbCsvBase.Name = _T("水灵核")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_FIRE then
		tbCsvBase.Name = _T("火灵核")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_EARTH then
		tbCsvBase.Name = _T("土灵核")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_AIR then
		tbCsvBase.Name = _T("风灵核")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_LIGHTNING then
		tbCsvBase.Name = _T("雷灵核")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_SECRET_JIANGHUN then
		tbCsvBase.Name = _T("将魂石")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_SECRET_REFRESH_TOKEN then
		tbCsvBase.Name = _T("将魂令")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	else
		tbCsvBase.Name = _T("")
		Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	end
	Image_DropIcon:loadTexture(strIcon)
	
	return itemModel, tbCsvBase, CSV_DropItem.DropItemStarLevel
end

--[[接口协议
CSV_DropItem = {
	DropItemType,
	DropItemID,
	DropItemStarLevel,
	DropItemNum,
	DropItemEvoluteLevel,
}
]]--

function g_CloneDropItemModel(CSV_DropItem)
	if not CSV_DropItem then return nil end

	local itemModel = nil
	local tbCsvBase = nil
	local nColorType = 1
	
	if CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_CARD then	--伙伴
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelCard(CSV_DropItem)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_EQUIP then	--装备
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelEquip(CSV_DropItem)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_ARRAYMETHOD then	--阵法(暂时作废)
		itemModel, tbCsvBase, nColorType = tolua.cast(g_WidgetModel.Image_DropError:clone(),"ImageView")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_FATE then 	--异兽
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelFate(CSV_DropItem)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_CARD_GOD then	--魂魄
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelHunPo(CSV_DropItem)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_MATERIAL then	--ItemBase(道具)
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelItemBase(CSV_DropItem)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_SOUL then	--元神
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelSoul(CSV_DropItem)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_MASTER_EXP then	--主角经验
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceDrop8_YueLi"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_MASTER_ENERGY then	--体力
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceDrop9_Energy"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_COUPONS then	--点券、元宝
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceDrop10_YuanBao"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_GOLDS then	--金币、铜钱
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceDrop11_TongQian"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_PRESTIGE then	--声望
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceDrop12_Prestige"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_KNOWLEDGE then	--阅历
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceDrop13_Knowledge"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_INCENSE then	--香贡
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceDrop14_Incense"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_POWER then	--神力
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceDrop19_CardExp"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_ARENA_TIME then	--竞技场挑战次数
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceDrop16_ArenaTimes"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_ESSENCE then 	--元素精华、灵力
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceDrop17_Essence"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_FRIENDHEART then 	--友情点
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceDrop18_FriendPoints"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_CARDEXPINBATTLE then 	--卡牌经验
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceDrop19_CardExp"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIAN_LING then 	--仙令
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceDrop20_XianLing"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_DRAGON_BALL then 	--神龙令
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceDrop21_ShenLongLing"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ONE_KEY then 	--一键消除
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceItem_XiaoChu1"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_BA_ZHE then 	--霸者横栏
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceItem_XiaoChu2"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_LIAN_SUO then 	--清除连锁
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceItem_XiaoChu3"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_DOU_ZHUAN then 	--斗转星移
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceItem_XiaoChu4"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_DIAN_DAO then 	--颠倒乾坤
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceItem_XiaoChu5"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_METAL then 	--金灵核
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceItem_LingHe1"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_NATURE then 	--木灵核
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceItem_LingHe2"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_WATER then 	--水灵核
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceItem_LingHe3"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_FIRE then 	--火灵核
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceItem_LingHe4"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_EARTH then 	--土灵核
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceItem_LingHe5"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_AIR then 	--风灵核
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceItem_LingHe6"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_LIGHTNING then 	--雷灵核
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceItem_LingHe7"), CSV_DropItem.DropItemType)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_SECRET_JIANGHUN then 	--将魂石
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceDrop40_JiangHunShi"), CSV_DropItem.DropItemType)
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_SECRET_REFRESH_TOKEN then 	--将魂令
		itemModel, tbCsvBase, nColorType = g_CloneIconItemModelResource(CSV_DropItem, getIconImg("ResourceDrop41_RefreshToken"), CSV_DropItem.DropItemType)
	else	--报错的模板
		itemModel = tolua.cast(g_WidgetModel.Image_DropError:clone(),"ImageView")
	end
	
	if not itemModel then
		itemModel = tolua.cast(g_WidgetModel.Image_DropError:clone(),"ImageView")
	end
	return itemModel, tbCsvBase, nColorType
end

--[[接口协议
CSV_DropItem = {
	DropItemType,
	DropItemID,
	DropItemStarLevel,
	DropItemNum,
	DropItemEvoluteLevel,
}
]]--

function g_CloneIconRewardModelCard(CSV_DropItem)
	local CSV_CardBase = g_DataMgr:getCardBaseCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_CardBase then return nil end
	
	local itemModel = tolua.cast(g_WidgetModel.Image_RewardCard:clone(),"ImageView")
	itemModel:loadTexture(getIconImg(CSV_CardBase.SpineAnimation))
	
	local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
	Image_Frame:loadTexture(getCardCoverByEvoluteLev(CSV_DropItem.DropItemEvoluteLevel))
	
	local Image_StarLevel = tolua.cast(itemModel:getChildByName("Image_StarLevel"),"ImageView")
	Image_StarLevel:loadTexture(getIconStarLev(CSV_DropItem.DropItemStarLevel))
	
	return itemModel, CSV_CardBase
end

function g_CloneIconRewardModelEquip(CSV_DropItem)
	local CSV_Equip = g_DataMgr:getEquipCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_Equip then return nil end
	
	local itemModel = tolua.cast(g_WidgetModel.Image_RewardEquip:clone(),"ImageView")
	
	local Image_Icon = tolua.cast(itemModel:getChildByName("Image_Icon"), "ImageView")
	Image_Icon:loadTexture(getIconImg(CSV_Equip.Icon))
	equipSacleAndRotate(Image_Icon, CSV_Equip.SubType)
	
	return itemModel, CSV_Equip
end

function g_CloneIconRewardModelFate(CSV_DropItem)
	local CSV_CardFate = g_DataMgr:getCardFateCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_CardFate then return nil end
	
	local itemModel = tolua.cast(g_WidgetModel.Image_RewardFate:clone(),"ImageView")
	
	local Image_Icon = tolua.cast(itemModel:getChildByName("Image_Icon"), "ImageView")
	Image_Icon:loadTexture(getIconImg(CSV_CardFate.Animation))
	Image_Icon:setPosition(ccp(CSV_CardFate.OffsetX, CSV_CardFate.OffsetY))
	
	return itemModel, CSV_CardFate
end

function g_CloneIconRewardModelHunPo(CSV_DropItem)

	local CSV_CardHunPo = g_DataMgr:getCardHunPoCsv(CSV_DropItem.DropItemID)
	if not CSV_CardHunPo then return nil end
	local CSV_CardBase = g_DataMgr:getCardBaseCsv(CSV_DropItem.DropItemID, CSV_CardHunPo.CardStarLevel)
	if not CSV_CardBase then return nil end
	
	local itemModel = tolua.cast(g_WidgetModel.Image_RewardHunPo:clone(),"ImageView")
	itemModel:loadTexture(getUIImg("SummonHunPoBase"..CSV_CardHunPo.CardStarLevel))
	
	local CCSprite_Icon = SpriteCoverlipping(getIconImg(CSV_CardBase.SpineAnimation), getUIImg("SummonHunPoBase"..CSV_CardHunPo.CardStarLevel))
	if CCSprite_Icon ~= nil then
		CCSprite_Icon:setScale(0.98)
		itemModel:addNode(CCSprite_Icon, 1)
	end
	
	local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
	Image_Frame:loadTexture(getUIImg("SummonHunPoCoverB"..CSV_CardHunPo.CardStarLevel))
	
	return itemModel, CSV_CardHunPo
end

local function g_CloneIconRewardModelItemBaseMaterial(itemModel, CSV_DropItem, CSV_ItemBase)
	local Image_Icon = tolua.cast(itemModel:getChildByName("Image_Icon"), "ImageView")
	Image_Icon:loadTexture(getIconImg(CSV_ItemBase.Icon))
end

local function g_CloneIconRewardModelItemBaseSkillFrag(itemModel, CSV_DropItem, CSV_ItemBase)
	local Image_Symbol = tolua.cast(itemModel:getChildByName("Image_Symbol"),"ImageView")
	Image_Symbol:loadTexture(getFrameSymbolSkillFrag(CSV_DropItem.DropItemStarLevel))
	
	local Image_Icon = tolua.cast(itemModel:getChildByName("Image_Icon"), "ImageView")
	Image_Icon:loadTexture(getIconImg(CSV_ItemBase.Icon))
end

local function g_CloneIconRewardModelItemBaseUseItem(itemModel, CSV_DropItem, CSV_ItemBase)
	itemModel:loadTexture(getUIImg("FrameBack"..CSV_ItemBase.ColorType))
	
	local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
	Image_Frame:loadTexture(getUIImg("SummonFragCoverB"..CSV_ItemBase.ColorType))
	
	local Image_Icon = tolua.cast(itemModel:getChildByName("Image_Icon"), "ImageView")
	Image_Icon:loadTexture(getIconImg(CSV_ItemBase.Icon))

	local Image_IconTag = tolua.cast(itemModel:getChildByName("Image_IconTag"), "ImageView")
	if CSV_ItemBase.SubType == NUM_ItemBaseSubType.EquipMaterialPack or CSV_ItemBase.SubType == NUM_ItemBaseSubType.EquipFormulaPack then
		Image_IconTag:setVisible(true)
		Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..CSV_ItemBase.StarLevel))
	elseif CSV_ItemBase.SubType == NUM_ItemBaseSubType.SoulMaterialPack then
		Image_IconTag:setVisible(true)
		Image_IconTag:loadTexture(getUIImg("Image_SoulTag_"..CSV_ItemBase.ColorType.."_"..CSV_ItemBase.FormulaType))
	elseif CSV_ItemBase.SubType == NUM_ItemBaseSubType.RandomPack then
		Image_IconTag:setVisible(true)
		Image_IconTag:loadTexture(getUIImg("Image_PackRandTag"..CSV_ItemBase.ColorType))
	elseif CSV_ItemBase.SubType == NUM_ItemBaseSubType.SelectedPack then
		Image_IconTag:setVisible(true)
		Image_IconTag:loadTexture(getUIImg("Image_PackSelectTag"..CSV_ItemBase.ColorType))
	else
		Image_IconTag:setVisible(false)
	end
end

local function g_CloneIconRewardModelItemBaseFormula(itemModel, CSV_DropItem, CSV_ItemBase)
	local Image_Symbol = tolua.cast(itemModel:getChildByName("Image_Symbol"),"ImageView")
	Image_Symbol:loadTexture(getFrameSymbolFormula(CSV_DropItem.DropItemStarLevel))
	
	local Image_Icon = tolua.cast(itemModel:getChildByName("Image_Icon"),"ImageView")
	Image_Icon:loadTexture(getIconImg(CSV_ItemBase.Icon))
	equipSacleAndRotate(Image_Icon, CSV_ItemBase.FormulaType)
end

local function g_CloneIconRewardModelItemBaseEquipPack(itemModel, CSV_DropItem, CSV_ItemBase)
	local Image_Symbol = tolua.cast(itemModel:getChildByName("Image_Symbol"),"ImageView")
	Image_Symbol:loadTexture(getIconImg("ResourceItem_MaterialPack"..CSV_DropItem.DropItemStarLevel))
	
	local Image_Icon = tolua.cast(itemModel:getChildByName("Image_Icon"),"ImageView")
	Image_Icon:loadTexture(getIconImg(CSV_ItemBase.Icon))
	equipSacleAndRotate(Image_Icon, CSV_ItemBase.FormulaType)
end

function g_CloneIconRewardModelItemBase(CSV_DropItem)
	local CSV_ItemBase = g_DataMgr:getItemBaseCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_ItemBase then return nil end
	local itemModel = nil
	if CSV_ItemBase.Type == 0 then
		itemModel = tolua.cast(g_WidgetModel.Image_RewardMaterial:clone(),"ImageView")
		g_CloneIconRewardModelItemBaseMaterial(itemModel, CSV_DropItem, CSV_ItemBase)
	elseif CSV_ItemBase.Type == 1 then
		itemModel = tolua.cast(g_WidgetModel.Image_RewardFrag:clone(),"ImageView")
		g_CloneIconRewardModelItemBaseSkillFrag(itemModel, CSV_DropItem, CSV_ItemBase)
	elseif CSV_ItemBase.Type == 2 or CSV_ItemBase.Type == 6 then
		itemModel = tolua.cast(g_WidgetModel.Image_RewardUseItem:clone(),"ImageView")
		g_CloneIconRewardModelItemBaseUseItem(itemModel, CSV_DropItem, CSV_ItemBase)
	elseif CSV_ItemBase.Type == 3 then
		itemModel = tolua.cast(g_WidgetModel.Image_RewardFormula:clone(),"ImageView")
		g_CloneIconRewardModelItemBaseFormula(itemModel, CSV_DropItem, CSV_ItemBase)
	elseif CSV_ItemBase.Type == 4 then
		itemModel = tolua.cast(g_WidgetModel.Image_RewardEquipPack:clone(),"ImageView")
		g_CloneIconRewardModelItemBaseEquipPack(itemModel, CSV_DropItem, CSV_ItemBase)
	else 
		itemModel = tolua.cast(g_WidgetModel.Image_DropItemUseItem:clone(),"ImageView")
		g_CloneIconRewardModelItemBaseUseItem(itemModel, CSV_DropItem, CSV_ItemBase)
	end
	
	return itemModel, CSV_ItemBase
end

function g_CloneIconRewardModelSoul(CSV_DropItem)
	local CSV_CardSoul = g_DataMgr:getCardSoulCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_CardSoul then return nil end
	
	local itemModel = tolua.cast(g_WidgetModel.Image_RewardSoul:clone(),"ImageView")
	itemModel:loadTexture(getUIImg("SummonSoulBase"..CSV_DropItem.DropItemStarLevel))
	
	local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
	Image_Frame:loadTexture(getUIImg("SummonSoulCoverB"..CSV_DropItem.DropItemStarLevel))
	
	local CCSprite_Icon = SpriteCoverlipping(getIconImg(CSV_CardSoul.SpineAnimation), getUIImg("SummonSoulBase"..CSV_DropItem.DropItemStarLevel))
	if CCSprite_Icon ~= nil then
		CCSprite_Icon:setScale(0.98)
		itemModel:addNode(CCSprite_Icon, 1)
	end
	
	local Image_SoulType = tolua.cast(itemModel:getChildByName("Image_SoulType"), "ImageView")
	if CSV_CardSoul.Class < 5 then
		Image_SoulType:loadTexture(getUIImg("Image_SoulTag_"..CSV_CardSoul.StarLevel.."_"..CSV_CardSoul.FatherLevel))
	else
		Image_SoulType:loadTexture(getEctypeIconResource("FrameEctypeNormalChar", CSV_CardSoul.StarLevel))
	end
	
	return itemModel, CSV_CardSoul
end

function g_CloneIconRewardModelResource(CSV_DropItem, strIcon)
	local itemModel = tolua.cast(g_WidgetModel.Image_RewardResource:clone(),"ImageView")
	itemModel:loadTexture(strIcon)
	
	local Image_Frame = tolua.cast(itemModel:getChildByName("Image_Frame"),"ImageView")
	Image_Frame:loadTexture(getUIImg("SummonFragCoverB"..CSV_DropItem.DropItemStarLevel))

	return itemModel
end

--[[接口协议
CSV_DropItem = {
	DropItemType,
	DropItemID,
	DropItemStarLevel,
	DropItemNum,
	DropItemEvoluteLevel,
}
]]--

function g_CloneDropRewardModel(CSV_DropItem)
	if not CSV_DropItem then return nil end

	local itemModel = nil
	local tbCsvBase = nil
	
	if CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_CARD then --伙伴
		itemModel,tbCsvBase = g_CloneIconRewardModelCard(CSV_DropItem)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_EQUIP then --装备
		itemModel,tbCsvBase = g_CloneIconRewardModelEquip(CSV_DropItem)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_ARRAYMETHOD then	--阵法(暂时作废)
		itemModel = tolua.cast(g_WidgetModel.Image_RewardError:clone(),"ImageView")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_FATE then --异兽
		itemModel,tbCsvBase = g_CloneIconRewardModelFate(CSV_DropItem)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_CARD_GOD then --魂魄
		itemModel,tbCsvBase = g_CloneIconRewardModelHunPo(CSV_DropItem)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_MATERIAL then --ItemBase(道具)
		itemModel,tbCsvBase = g_CloneIconRewardModelItemBase(CSV_DropItem)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_SOUL then --元神
		itemModel,tbCsvBase = g_CloneIconRewardModelSoul(CSV_DropItem)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_MASTER_EXP then --主角经验
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceDrop8_YueLi"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("主角经验")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_MASTER_ENERGY then --体力
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceDrop9_Energy"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("体力")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_COUPONS then --点券、元宝
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceDrop10_YuanBao"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("元宝")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_GOLDS then --金币、铜钱
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceDrop11_TongQian"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("铜钱")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_PRESTIGE then --声望
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceDrop12_Prestige"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("声望")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_KNOWLEDGE then --阅历
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceDrop13_Knowledge"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("阅历")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_INCENSE then	--香贡
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceDrop14_Incense"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("香贡")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_POWER then --神力
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceDrop19_CardExp"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("神力")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_ARENA_TIME then --竞技场挑战次数
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceDrop16_ArenaTimes"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("天榜次数")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_ESSENCE then --元素精华、灵力
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceDrop17_Essence"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("灵力")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_FRIENDHEART then --友情点
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceDrop18_FriendPoints"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("友情之心")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_CARDEXPINBATTLE then --卡牌经验
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceDrop19_CardExp"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("伙伴经验")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIAN_LING then --仙令
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceDrop20_XianLing"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("仙令")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_DRAGON_BALL then --神龙令
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceDrop21_ShenLongLing"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("神龙令")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ONE_KEY then --一键消除
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceItem_XiaoChu1"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("一键消除")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_BA_ZHE then --霸者横栏
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceItem_XiaoChu2"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("霸者横栏")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_LIAN_SUO then --清除连锁
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceItem_XiaoChu3"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("清除连锁")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_DOU_ZHUAN then --斗转星移
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceItem_XiaoChu4"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("斗转星移")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_DIAN_DAO then --颠倒乾坤
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceItem_XiaoChu5"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("颠倒乾坤")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_METAL then --金灵核
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceItem_LingHe1"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("金灵核")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_NATURE then --木灵核
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceItem_LingHe2"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("木灵核")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_WATER then --水灵核
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceItem_LingHe3"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("水灵核")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_FIRE then --火灵核
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceItem_LingHe4"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("火灵核")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_EARTH then --土灵核
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceItem_LingHe5"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("土灵核")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_AIR then --风灵核
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceItem_LingHe6"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("风灵核")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_LIGHTNING then --雷灵核
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceItem_LingHe7"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("雷灵核")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_SECRET_JIANGHUN then --将魂石
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceDrop40_JiangHunShi"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("将魂石")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_SECRET_REFRESH_TOKEN then --将魂令
		itemModel = g_CloneIconRewardModelResource(CSV_DropItem, getIconImg("ResourceDrop41_RefreshToken"))
		tbCsvBase = {}
		tbCsvBase.Name = _T("将魂令")
	else --报错的模板
		itemModel = tolua.cast(g_WidgetModel.Image_RewardError:clone(),"ImageView")
	end
	
	if not itemModel then
		itemModel = tolua.cast(g_WidgetModel.Image_RewardError:clone(),"ImageView")
	end
	return itemModel, tbCsvBase
end

--注意该接口只获取第一个掉落子包
function g_GetDropSubPackClientItemDataByID(nDropSubPackClientID)
	local CSV_DropSubPackClient = g_DataMgr:getCsvConfig_SecondKeyTableData("DropSubPackClient", nDropSubPackClientID)--g_DataMgr:getCsvConfigByOneKey("DropSubPackClient", nDropSubPackClientID)
	local CSV_DropItem = nil
	if CSV_DropSubPackClient then
		for k, v in ipairs(CSV_DropSubPackClient) do
			if v then
				CSV_DropItem = v
				break
			end
		end
	else
		cclog(string.format("[DropSubPackClient] ！配置错误！不存在的id：%d", tbEctypeInfo.ShowDropPackID2))
	end
	
	return CSV_DropItem
end

function registerListViewEvent(listview, widgemodel, updateFunction, nMax, funcAdjust,  nBegin, nMinShowItem)
	local luaListView = Class_LuaListView.new()
	luaListView:setListView(listview)
	luaListView:setModel(widgemodel)
	if updateFunction then
		luaListView:setUpdateFunc(updateFunction)
	end
	if funcAdjust then
		luaListView:setAdjustFunc(funcAdjust)
	end
	if nMax then	
		luaListView:updateItems(nMax, nBegin, nMinShowItem)
	end
	return luaListView
end

function g_backToReLogin()
	local function delayToExitGame()
		g_WndMgr:reset()
		--API_CloseSocket()
        --重新加载资源
        LoadGamWndFile()
		
		g_LoadFile("LuaScripts/GameLogic/Class_Hero")
        --g_MsgMgr:resetAccount()
		local sceneGame = LYP_GetStartGameScene()
		CCDirector:sharedDirector():replaceScene(sceneGame)
	end

	g_Timer:pushTimer(1, delayToExitGame)
end

function g_exitGame()
	API_StopNetWork()

	local function delayToExitGame()
        g_HeadBar:destroy()
		g_DbMgr:closeDB()
		g_Timer:destroy()
        g_WndMgr:reset()
		g_ClientMsgTips:destroy()
		ActionManager:purge()
		g_MsgNetWorkWarning:purge()
		g_WidgetModel.root:release()
	
		GUIReader:purge()
		CCArmatureDataManager:purge()
		g_pDirector:purgeCachedData()
		g_pDirector:endToLua()
		API_ExitGame()
	end
	
	g_Timer:pushTimer(1, delayToExitGame)
end

--多个控件的左对齐
function g_AdjustWidgetsPosition(tbWidget, nOffset)
    if not tbWidget or #tbWidget <= 0 then  return end
	local nOffset = nOffset or 0
	
    local nPos = nil
    local tbSize = nil
    for i = 1, #tbWidget do
        local widget = tbWidget[i]
		local fAnchorPointY = widget:getAnchorPoint().y
        widget:setAnchorPoint(ccp(0, fAnchorPointY))
        if i == 1 then
            nPos = widget:getPositionX()
        else
            widget:setPositionX(nPos)
        end

        nPos = nPos + widget:getSize().width*widget:getScaleX() + nOffset
    end
end

--多个控件的右对齐
function g_adjustWidgetsRightPosition(tbWidget, nOffset)
    if not tbWidget or #tbWidget <= 0 then  return end
	local nOffset = nOffset or 0
	
    local nPos = nil
    local tbSize = nil
    for i = 1, #tbWidget do
        local widget = tbWidget[i]
		local fAnchorPointY = widget:getAnchorPoint().y
        widget:setAnchorPoint(ccp(1, fAnchorPointY))
        if i == 1 then
            nPos = widget:getPositionX()
        else
            widget:setPositionX(nPos)
        end

        nPos = nPos - widget:getSize().width*widget:getScaleX() - nOffset
    end
end

function g_getRealmLev(nRealmLevel)
    local nMainLev = math.ceil(nRealmLevel/8)
	local nSubLev = 0
	if nRealmLevel > 0 then
		nSubLev = (nRealmLevel-1)%8+1
	end

    return nMainLev, nSubLev
end

function g_getRealmName(nRealmLevel)
    local nMainLev = math.ceil(nRealmLevel/8)
	local szRealmName = g_tbRealmName[nMainLev]
    local szSubName  = ""
	local nSubLev = 0
	if nRealmLevel > 0 then
		nSubLev = (nRealmLevel-1)%8+1
		szRealmName = szRealmName
        szSubName = nSubLev.."/8"
	end

    return szRealmName, szSubName
end

function g_setImgShader(imageView, pszShader)
	local shader = CCGLProgram:new()
	shader:initWithVertexShaderByteArray(ccPositionTextureColor_vert, pszShader)
	imageView:setShaderProgram(shader)
	shader:autorelease()

	shader:addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position)
	shader:addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color)
	shader:addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords)

	shader:link()
	shader:updateUniforms()
end

function g_onClickOutReturn(widget, widgetCenter, funcCallBack)
    if widget then
        widget:setTouchEnabled(true)

		local function onClickOutReturn(pSender, eventType)
            if widgetCenter and not widgetCenter:isTouchEnabled() then return end

			if eventType == ccs.TouchEventType.began then
				if widgetCenter then
                    widgetCenter:setBrightStyle(BRIGHT_HIGHLIGHT)
                end
            elseif eventType == ccs.TouchEventType.canceled then
                if widgetCenter then
                    widgetCenter:setBrightStyle(BRIGHT_NORMAL)
                end
            elseif eventType == ccs.TouchEventType.ended then
                if widgetCenter then
                    widgetCenter:setBrightStyle(BRIGHT_NORMAL)
                end
              
                if funcCallBack then
                    funcCallBack()
                end
                g_playSoundEffect("Sound/ButtonClick.mp3")
			end
		end
		widget:addTouchEventListener(onClickOutReturn)
    end
end

function g_CheckPropIsPercent(nPropID) 
    if not nPropID then  return false end

    if nPropID <= 18 or nPropID == 19 or nPropID == 27 or nPropID == 28 or nPropID == 29 then
        return false, 1
    else
        return true, g_BasePercent
    end
end

function g_copyTab(st)
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = g_copyTab(v)
        end
    end
    return tab
end

function g_getAllChildren(parent)
	local tbChildren = {}
	local function getChildren(node)
		local children = node:getChildren()
		for i = 1, node:getChildrenCount() do
			local child = tolua.cast(children:objectAtIndex(i - 1), "CCNode")
			table.insert(tbChildren, child)
			getChildren(child)
		end
	end
	getChildren(parent)
	return tbChildren
end