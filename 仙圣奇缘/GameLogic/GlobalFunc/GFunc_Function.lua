--------------------------------------------------------------------------------------
-- 文件名:	g_function.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	陆奎安
-- 日  期:	2013-3-4 9:37
-- 版  本:	1.0
-- 描  述:	通用Game_RewardBox控件设置函数
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------
ccs.COLOR =
{
	GREY = 	1, 				--灰色
	WHITE = 2, 				--白色
	LIGHT_GREEN = 3, 		--浅绿
	LIME_GREEN = 4,			--深绿
	LIGHT_SKY_BLUE = 5,		--浅蓝
	DARK_SKY_BLUE = 6,		--深蓝
	VIOLET = 7,				--粉色
	BLUE_VIOLET = 8,		--紫色
	FUCHSIA = 9,			--洋红
	DARK_GLOD = 10,			--暗金色
	GOLD = 11,				--金色
	DARK_ORANGE = 12,		--橙色
	ORANG_RED = 13,			--橘红
	RED = 14, 				--纯红
	DEEP_PINK = 15,			--DeepPink
	WHEAT = 16,				--麦色
	PLAIN_ORANGE = 17,		--描述橙色
	PLAIN_YELLOW = 18,		--描述暗黄
	INDIA_RED = 19,			--印度红
	BRIGHT_GREEN = 20,		--亮绿--界面提示
	DEEP_GREY = 21,		--深灰
	GREEN = 22,		--绿色
}

local tbtextColor = {
	[ccs.COLOR.GREY] = ccc3(180, 180, 180), 				--灰色
	[ccs.COLOR.WHITE] = ccc3(255, 255, 255), 				--白色
	[ccs.COLOR.LIGHT_GREEN] = ccc3(144, 238, 144), 			--浅绿
	[ccs.COLOR.LIME_GREEN] = ccc3(35, 220, 55),   			--深绿
	[ccs.COLOR.LIGHT_SKY_BLUE] = ccc3(135, 206, 250), 		--浅蓝
	[ccs.COLOR.DARK_SKY_BLUE] = ccc3(0, 191, 255),   		--深蓝
	[ccs.COLOR.VIOLET] = ccc3(238, 130, 238), 				--粉色
	[ccs.COLOR.BLUE_VIOLET] = ccc3(153, 50, 204),  			--紫色
	[ccs.COLOR.FUCHSIA] = ccc3(255, 0, 255),   				--洋红
	[ccs.COLOR.DARK_GLOD] = ccc3(207, 181, 59),  			--暗金色
	[ccs.COLOR.GOLD] = ccc3(255, 241, 0),   				--金色
	[ccs.COLOR.DARK_ORANGE] = ccc3(255, 140, 0),   			--橙色
	[ccs.COLOR.ORANG_RED] = ccc3(255, 69, 0),    			--橘红
	[ccs.COLOR.RED] = ccc3(255, 0, 0),     					--纯红
	[ccs.COLOR.DEEP_PINK] = ccc3(255, 20, 147),  			--DeepPink
	[ccs.COLOR.WHEAT] = ccc3(245, 222, 179), 				--麦色
	[ccs.COLOR.PLAIN_ORANGE] = ccc3(255, 184, 17),  		--描述橙色
	[ccs.COLOR.PLAIN_YELLOW] = ccc3(181, 174, 156), 		--描述暗黄
	[ccs.COLOR.INDIA_RED] = ccc3(205, 92, 92),   			--印度红
	[ccs.COLOR.BRIGHT_GREEN] = ccc3(50, 255, 50),   		--亮绿--界面提示
	[ccs.COLOR.DEEP_GREY] = ccc3(100, 100, 100),   		--灰色
	[ccs.COLOR.GREEN] = ccc3(0, 255, 0),   		--绿色
} 

function g_getColor(nColorType)
	return tbtextColor[nColorType]
end

--[[
	设置字体颜色
	@param txt 要设置的对象
	@param nIndex 1-20分别为不同的颜色，如果为空默认为白色
	
]]

function g_setTextColor(txt,nIndex)
	if not txt then
        cclog("txt为空了 （g_setTextColor）=="..nIndex) 
        return 
    end 

	if not nIndex then 
        nIndex = ccs.COLOR.WHITE 
    end
	txt:setColor(tbtextColor[nIndex])
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

g_tbQuality = {
	_T("普通"),_T("优秀"),_T("精良"),_T("史诗"),_T("传奇")
}


--[[装备的颜色，ColorType
异兽的颜色，ColorType
其他都是，StarLevel
]]

g_TbColorType = {
	[1] = ccs.COLOR.WHITE,				-- 1星 - 白色
	[2] = ccs.COLOR.LIME_GREEN,			-- 2星 - 深绿
	[3] = ccs.COLOR.DARK_SKY_BLUE,		-- 3星 - 深蓝
	[4] = ccs.COLOR.FUCHSIA,			-- 4星 - 洋红
	[5] = ccs.COLOR.GOLD,				-- 5星 - 金色
	[6] = ccs.COLOR.RED,		-- 6星 - 红色
	[7] = ccs.COLOR.RED,			-- 7星 - 红色
	[8] = ccs.COLOR.RED,				-- 8星 - 红色
}

function g_SetWidgetColorBySLev(widget, nStarLevel, bIsWhiteToGray)
	g_setTextColor(widget,g_TbColorType[nStarLevel])
end

--根据突破等级设置名称颜色
function g_SetCardNameColorByEvoluteLev(widget, nEvoluteLevel, bIsWhiteToGray)
	local nColorType = g_GetCardColorTypeByEvoLev(nEvoluteLevel) or 1
	g_SetWidgetColorBySLev(widget, nColorType, bIsWhiteToGray)
end

--[[
	境界名称颜色设置
]]
function g_SetXianMaiNameColor(widget, nColorLevel)
	local tbColor = {
		[0] = ccs.COLOR.WHITE,	--白色
		[1] = ccs.COLOR.LIGHT_GREEN,	--深绿
		[2] = ccs.COLOR.LIME_GREEN,	--深绿
		[3] = ccs.COLOR.LIGHT_SKY_BLUE,	--浅蓝
		[4] = ccs.COLOR.DARK_SKY_BLUE,	--深蓝
		[5] = ccs.COLOR.VIOLET,	--粉色
		[6] = ccs.COLOR.BLUE_VIOLET,	--紫色
		[7] = ccs.COLOR.GOLD,	--金色
		[8] = ccs.COLOR.DARK_ORANGE,	--橙色
		[9] = ccs.COLOR.ORANG_RED,	--橘红
		[10] = ccs.COLOR.RED,	--纯红
	}
	g_setTextColor(widget,tbColor[nColorLevel])	
end

--textfield输入内容区分字母或者数字
function isNumberOrCharacter(mystring) 
    for i = 1,#mystring do 
        local account = string.sub(mystring,i,i) 
        local temp = string.byte(account) 
                 
        if 48 <= temp and temp <= 57 then                                
            cclog("这是数字") 
        elseif 65<= temp and temp <= 90 then 
            cclog("这是大写字母") 
            return false 
        elseif 97 <= temp and temp <= 122 then 
           	cclog("这是小写写字母") 
           	return false 
		elseif 32 == temp then 
           	cclog("这是空格") 
           	return false 
        else 
            cclog("输入包含非数字、字母的字符，不符合规则，请重新输入") 
            return false 
        end 
    end 
	return true	
end 

function isChinese(mystring) 
    for i = 1,#mystring do 
        local account = string.sub(mystring,i,i) 
        local temp = string.byte(account) 
		
        if (temp >= 0 and temp <= 127) then                                
        else 
            return true 
        end 
    end 
	return false	
end

--计算字数
function stringNum(mystring,maxNumber) 
	local nNum = 0
	local list = {}
    local nlen = tonumber( string.len(mystring))
    local i = 1 
	local maxString = ""
	while i <=  nlen do
		local c = string.byte(mystring, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
			nNum = nNum + 1
        else
			shift = 3
			nNum = nNum + 1
        end
      --  local char = string.sub(mystring, i, i+shift-1)
		if maxNumber and nNum >= maxNumber then
			maxString =  string.sub(mystring, 1, i+shift-1)
			return nNum,maxString
		end
		i = i + shift
    end 
	return nNum,maxString
end

--截取字段
function stringSub(mystring,startIndex,endIndex) 
	if not mystring or mystring == "" then
		return ""
	end 
	local nNum = 0
	local status = true
    local nlen = tonumber( string.len(mystring))
    local i = 1 
	local nString 
	startIndex = startIndex or 1
	endIndex = endIndex or 1
	if startIndex >  endIndex then
		cclog("=Eorro==startIndex >  endIndex===")
		return
	end
	
	while i <=  nlen do
		local c = string.byte(mystring, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
			nNum = nNum + 1
        else
			shift = 3
			nNum = nNum + 2
        end
      --  local char = string.sub(mystring, i, i+shift-1)
		if startIndex and nNum == startIndex then
			startIndex = i
		end
		if endIndex and nNum >= endIndex then
			endIndex = i
			nString =  string.sub(mystring, startIndex,endIndex+shift-1)
			return nString
		end
		if  i + shift >  nlen  then
			endIndex = i
			nString =  string.sub(mystring, startIndex,endIndex+shift-1)
			return nString
		end
		i = i + shift
    end 
	return nString
end

--设置tabel
function setLabelText(label,mystring,startIndex) 
	local nlen = tonumber( string.len(mystring))
	local startIndex = startIndex or 1
	-- local nString = stringSub(mystring, startIndex,endIndex) 
	local nString =  string.sub(mystring, startIndex,nlen)
	label:setText(nString)
	return nlen
end
--截取tabel
function subLabelText(tbLabel,mystring,mSizeLen) 

    local newstr = ""; 
	local size = 0
    local nlen = tonumber( string.len(mystring))
    local i = 1 
	local curLabelIndex = 1
	local nLabel = tbLabel[1].label

	while i <=  nlen do
		local c = string.byte(mystring, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
        else
			shift = 3
        end
        local substr = string.sub(mystring, i, i+shift-1)
        
		local text = newstr .. substr
		nLabel:setText(text)
		local size = nLabel:getSize()
		if size.width <= mSizeLen then
			newstr = newstr .. substr
		else
			nLabel:setText(newstr)
			curLabelIndex = curLabelIndex + 1
			if  curLabelIndex > #tbLabel then	
				return tbLabel,curLabelIndex-1; 
			else
				nLabel = tbLabel[curLabelIndex].label
				nLabel:setText(substr)
				newstr = substr
				tbLabel[curLabelIndex].startIndex = i
			end
		end
		i = i + shift
    end 
    return tbLabel,curLabelIndex; 
end
--设置TextField
-- chatStrMaxNum 最大字数
--[[ local tbLabel = {
			{"label" = self.Label_Input},
			{"label" = Label_Input1},
			{"label" = Label_Input2},
	}
	]]
function strSub(mString,chatStrMaxNum)
			
	local nlen = tonumber( string.len(mString))
	local count = 0
	local chineseByte = 0
	local englishByte = 0
	local allNum = 0
	for i = 1 ,nlen do
		local bt = string.byte(mString, i)
		local bytes = 1
		if bt > 0 and bt <= 127 then
			-- bytes = 1
			englishByte = englishByte + 1
		else
			bytes = 3
			chineseByte = chineseByte + 1
		end
		if englishByte+(chineseByte/3) <= chatStrMaxNum then 
			allNum = i
		end
	end
	return string.sub(mString, 1,  allNum),englishByte+(chineseByte/3)
end
	
function setTextField(TextField_Input,tbLabel,chatStrMaxNum,maxWidth,callBack) 
	if not TextField_Input or not tbLabel[1] then 
		cclog("==not TextField_Input====")
		return
	end
	for i,v in ipairs(tbLabel)do
		v.label:setText("")
		v.startIndex = 1
	end
	local InputNum = 1
	local curLabelIndex = 1
	local curLabel = tbLabel[curLabelIndex].label
	local mString = ""
	local maxString = ""
	local function textFieldEvent(sender, eventType)	
		if eventType == ccs.TextFiledEventType.insert_text  then
			-- if InputNum  == 0 then
				-- TextField_Input:setText(maxString)
				-- return
			-- end
		
			mString = TextField_Input:getStringValue()
			local str,count =  strSub(mString,chatStrMaxNum)
			TextField_Input:setText(str)
			
			tbLabel, curLabelIndex =  subLabelText(tbLabel,str,maxWidth) 
			curLabel = tbLabel[curLabelIndex].label
		elseif  eventType == ccs.TextFiledEventType.delete_backward	 then
			mString = TextField_Input:getStringValue()
			local str =   strSub(mString,chatStrMaxNum)
			TextField_Input:setText(str)
			
			local startIndex = tbLabel[curLabelIndex].startIndex
			setLabelText(curLabel,str,startIndex) 
			if  curLabelIndex <= 1 then
			else
				local text = curLabel:getStringValue()
				if  text == "" then	
					curLabelIndex = curLabelIndex - 1
					curLabel =  tbLabel[curLabelIndex].label
				end
			end
		end
		
		local str,count =  strSub(mString,chatStrMaxNum)
		-- InputNum,maxString = stringNum(str,chatStrMaxNum*2)
		-- InputNum = math.floor( InputNum / 2 )
		if count >= chatStrMaxNum then
			InputNum= 0
		else
			InputNum =  chatStrMaxNum - count
		end
		if callBack then
			callBack(InputNum)
		end
	end
	TextField_Input:setText("")
	TextField_Input:setMaxLength(300)
	TextField_Input:setTouchEnabled(true)
	TextField_Input:setAnchorPoint(ccp(0,0))
	TextField_Input:addEventListenerTextField(textFieldEvent) 
end
-----------------textfield输入内容区分字母或者数字   --------------------
function Textisblank(mystring) 
    for i = 1,#mystring do 
        local account = string.sub(mystring,i,i) 
        local temp = string.byte(account) 
                 
        if 32 == temp then 
           	cclog("这是空格") 
        else 
            return false 
        end 
    end 
	return true	
end 

--------------------判断位数------------------------------------------
function PrintDigits(nNum)
	local digits = math.ceil(math.log(nNum)/math.log(10))
	return digits 
end

--冒泡通知
--widgetParent: 父节点
--nNum: 显示的数字
--x,y: 坐标
--注意，如果当通知为0时，要传入nNum=0把冒泡通知被销毁
function g_SetBubbleNotify(widgetParent, nNum, x, y, fScale)
	local nNum = nNum or 0
	local x = x or 0
	local y = y or 0
	local fScale = fScale or 1

	local Image_Notes = widgetParent:getChildByName("Image_Notes")
	if not Image_Notes then
		Image_Notes = ImageView:create()
		Image_Notes:setName("Image_Notes")
		Image_Notes:loadTexture(getUIImg("Icon_Note"))
		Image_Notes:setPosition(ccp(x,y))
		Image_Notes:setScale(fScale)
		
		local Label_Notes = Label:create()
		Label_Notes:setAnchorPoint(ccp(0.5, 0.5))
		Label_Notes:setPosition(ccp(0, 3))
		Label_Notes:setName("Label_Notes")
		Label_Notes:setFontSize(28)
		Image_Notes:addChild(Label_Notes)
		widgetParent:addChild(Image_Notes,100)
		
		
	end
	
	-- 不要Action
	-- local arryAct = CCArray:create()
	-- local actionScaleTo1 = CCScaleTo:create(0.1, 1.3 * fScale)
	-- local actionScaleTo2 = CCScaleTo:create(0.1, 0.7 * fScale)
	-- local actionScaleTo3 = CCScaleTo:create(0.1, 1.2 * fScale)
	-- local actionScaleTo4 = CCScaleTo:create(0.1, 0.8 * fScale)
	-- local actionScaleTo5 = CCScaleTo:create(0.1, 1.1 * fScale)
	-- local actionScaleTo6 = CCScaleTo:create(0.1, 0.9 * fScale)
	-- local actionScaleTo7 = CCScaleTo:create(0.1, 1 * fScale)
	-- arryAct:addObject(actionScaleTo1)
	-- arryAct:addObject(actionScaleTo2)
	-- arryAct:addObject(actionScaleTo3)
	-- arryAct:addObject(actionScaleTo4)
	-- arryAct:addObject(actionScaleTo5)
	-- arryAct:addObject(actionScaleTo6)
	-- arryAct:addObject(actionScaleTo7)
	-- arryAct:addObject(CCDelayTime:create(2))
	-- local action = CCSequence:create(arryAct)
	-- local actionRepeat = CCRepeatForever:create(action)
	-- Image_Notes:runAction(actionRepeat)
	--[[
		按要显示 数字10,15两位数的格式 修改nNum 为99
	]]

	if nNum > 99 then
		local Label_Notes = tolua.cast(Image_Notes:getChildByName("Label_Notes"), "Label")
		Label_Notes:setText("N")
		--Label_Notes:setText(nNum)
		Label_Notes:setScale(1)
		return Image_Notes
	elseif nNum >= 10 and nNum <= 99 then
		local Label_Notes = tolua.cast(Image_Notes:getChildByName("Label_Notes"), "Label")
		Label_Notes:setText(nNum)
		Label_Notes:setScale(0.8)
		return Image_Notes
	elseif nNum >= 1 and nNum <= 9 then
		local Label_Notes = tolua.cast(Image_Notes:getChildByName("Label_Notes"), "Label")
		Label_Notes:setText(nNum)
		Label_Notes:setScale(1)
		return Image_Notes
	else
		-- Image_Notes:stopAllActions()
		Image_Notes:removeFromParentAndCleanup(true)
	end
	
	return nil
end

--异兽升级排序规则
function sortForUpgradeFate(tbDataA, tbDataB)
	local tbBaseA = tbDataA:getCardFateCsv()
	local tbBaseB = tbDataB:getCardFateCsv()
	local nColorTypeA = tbBaseA.ColorType
	local nColorTypeB = tbBaseB.ColorType
	if(nColorTypeA == nColorTypeB)then
		local nConfigIDA = tbDataA.nCsvID*10000 + tbDataA.nStarLevel
		local nConfigIDB = tbDataB.nCsvID*10000 + tbDataB.nStarLevel
		
		return nConfigIDA < nConfigIDB
	else
		return nColorTypeA < nColorTypeB
	end
end


--设置异兽的动画
function g_SetFateWidgetByFateID(CheckBox_Fate, nFateID, nTag, fScale)
	local tbFateInfo = g_Hero:getFateInfoByID(nFateID)
	if not tbFateInfo then return end
	local CSV_CardFate = tbFateInfo:getCardFateCsv()
	local fScale = fScale or 0.52
	local nTag = nTag or 0

    local Image_FateItem = CheckBox_Fate:getChildByName("Image_FateItem")
    if not Image_FateItem then
        Image_FateItem =  tolua.cast(g_WidgetModel.Image_FateItem:clone(),  "ImageView")
        Image_FateItem:setName("Image_FateItem")
		Image_FateItem:setPositionXY(0,0)
		local Panel_FateItem = tolua.cast(Image_FateItem:getChildByName("Panel_FateItem"), "Layout")
        Panel_FateItem:setClippingEnabled(true)
	    Panel_FateItem:setRadius(92)
        CheckBox_Fate:addChild(Image_FateItem, 0, nTag)
    else    
        Image_FateItem:setVisible(true)
    end
	Image_FateItem:setScale(fScale)

    local Image_FateItem = tolua.cast(CheckBox_Fate:getChildByName("Image_FateItem"), "ImageView")
    Image_FateItem:loadTexture(getFateBaseAImg(CSV_CardFate.ColorType))

    local Image_Frame = tolua.cast(Image_FateItem:getChildByName("Image_Frame"), "ImageView")
    Image_Frame:loadTexture(getFateFrameImg(CSV_CardFate.ColorType))
	
	local Panel_FateItem = tolua.cast(Image_FateItem:getChildByName("Panel_FateItem"), "Layout")
    local Image_Fate = tolua.cast(Panel_FateItem:getChildByName("Image_Fate"), "ImageView")
	Image_Fate:setPosition(ccp(96+CSV_CardFate.OffsetX, 96+CSV_CardFate.OffsetY))
    Image_Fate:loadTexture(getIconImg(CSV_CardFate.Animation))
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
			g_MsgMgr:requestBuyEnergy(nMaxEnergy)
		end
  
		g_ClientMsgTips:showConfirm(msg, BuyEnergy)
	end
end

function g_GetSoCityText(nAreaCode)
	local nProvinceIndex = math.floor(nAreaCode/100)
	local nCityIndex = nAreaCode % 100
	local tbProvinceCity = g_ProvinceCity[nProvinceIndex]
	
	if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		tbProvinceCity = g_ProvinceCity_Viet[1]
	elseif eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
		tbProvinceCity = g_ProvinceCity_Taiwan[1]
	end
	
	if not tbProvinceCity then return "-" end
	return tbProvinceCity.Title, tbProvinceCity.Option[nCityIndex]
end

function g_string_insert(mystring,insertStr,mlen)
	local b =  tonumber( string.len(insertStr))
    local newstr = ""; 
	local nNum = 0
    local nlen = tonumber( string.len(mystring))
    local i = 1 
	while i <=  nlen do
		local c = string.byte(mystring, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
			nNum = nNum + 1
        else
			shift = 3
			nNum = nNum + 1.727
        end
        local substr = string.sub(mystring, i, i+shift-1)
        i = i + shift

        local nWidth = 0
        local c = string.byte(mystring, i)
        if c and c > 0 and c <= 127 then
        	nWidth = 1
        else
        	nWidth = 1.727
        end
		if nNum + nWidth <= mlen then
			newstr = newstr .. substr
		else
			local substr1 = string.sub(mystring, i, i)
			nNum = 0
			if substr1 == "\n" then
				newstr = newstr .. substr..substr1
				i = i + 1
			else
				newstr = newstr .. substr..insertStr
			end
		end
    end 
    return newstr; 
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


--获取字符串的有效个数
function g_string_num(mystring)
	if mystring == nil or type(mystring) ~= "string" then return 0 end

	local i=1
	local nlen = string.len(mystring)
	local icount = 0

	while i <= nlen do
		local c = string.byte(mystring, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
        else
			shift = 3
        end
        i = i + shift

        icount = icount + 1
	end

	return icount
end

--境界标志啊
function g_RealmFlag(nRealmLevel)
	if nRealmLevel == 0 then
		return ""
	elseif nRealmLevel == 1 then
		return "+"
	end
	
	return "+"..(nRealmLevel-1)
end

function g_isRandomInRange(nIn, nBaseNum)
    if not nBaseNum or not nIn then
        cclog("g_isRandomInRange error")
        return false
    end

	local nRandom = math.random(1, nBaseNum)
	return nRandom <= nIn
end

--[[
使用方法
param = { nNo=,--第几个位置
nNeedNum =,--消耗数值,
widgetParent = ,
nCsvID = ,
nStarLevel = ,
nMaterialName = "",--模版名称
formulaType = ,--卷轴类别
}
g_SetMaterialBtn(param)
]]
function g_SetMaterialBtn(param)
	local nNo = param.nNo or 1
	local formulaType = param.formulaType
	local nNeedNum = param.nNeedNum or 0
	local widgetParent = param.widgetParent; if not widgetParent then cclog("widgetParent 为空") return end
	local nCsvID = param.nCsvID or 0; 
	local nStarLevel = param.nStarLevel or 0; 
	local nMaterialName = param.nMaterialName; 
	if not nMaterialName then nMaterialName = "EquipWorkMaterial" end 

	local function addImage(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			local CSV_ItemBase = g_DataMgr:getItemBaseCsv(nCsvID, nStarLevel)
			if nCsvID == 0 then 
			else
				--nType == 2 表示合成界面 nType == 3 表示掉落界面
				local nType = 2
				if formulaType then  
					nType = 3
				end
				local param = {nType= nType,itemId = nCsvID,itemStar = CSV_ItemBase.StarLevel,name = CSV_ItemBase.Name,detailType = macro_pb.ITEM_TYPE_MATERIAL}
				g_WndMgr:showWnd("Game_ItemDropGuide", param)
			end
			
		end
	end
	local btnMaterial = tolua.cast(widgetParent:getChildByName("Button_Material"..nNo),"Button")
	btnMaterial:setTouchEnabled(true)
	btnMaterial:addTouchEventListener(addImage)
	
	local Img_Material = btnMaterial:getChildByName(nMaterialName)
	if not Img_Material then
		Img_Material = g_WidgetModel[nMaterialName]:clone()
		Img_Material:setName(nMaterialName)
		btnMaterial:addChild(Img_Material)
	else
		Img_Material:setVisible(true)
	end
	
	local Image_Add = tolua.cast(btnMaterial:getChildByName("Image_Add"),"ImageView")
	Image_Add:setVisible(false)
	local CSV_ItemBase = g_DataMgr:getItemBaseCsv(nCsvID, nStarLevel)
	local nHasNum = g_Hero:getItemNumByCsv(nCsvID, nStarLevel)
	
	if nCsvID == 0 then 
		if Img_Material then Img_Material:setVisible(false) end
		Image_Add:setVisible(false)
		return
	end

	if nHasNum >= nNeedNum then 
		Image_Add:setVisible(false)
	else
		local CSV_ItemCompose = g_DataMgr:getCsvConfigByTwoKey("ItemCompose", nCsvID, nStarLevel)
		if CSV_ItemCompose.MaterialID1 > 0 then
			local nHaveFragNum = g_Hero:getItemNumByCsv(CSV_ItemCompose.MaterialID1, CSV_ItemCompose.MaterialStarLevel1)
			if nHaveFragNum >= 3 then
				Image_Add:setVisible(true)
				g_CreateScaleInOutAction(Image_Add)
			end
		else
			Image_Add:setVisible(false)
		end
	end



	local icon = getIconImg(CSV_ItemBase.Icon)
	local Image_Icon = tolua.cast(Img_Material:getChildByName("Image_Icon"),"ImageView")
	Image_Icon:loadTexture(icon)
	--卷轴类别
	if formulaType then 
		equipSacleAndRotate(Image_Icon,formulaType)
		local Image_Symbol = tolua.cast(Img_Material:getChildByName("Image_Symbol"),"ImageView")
		Image_Symbol:loadTexture(getFrameSymbolFormula(CSV_ItemBase.ColorType))
	end
	
	local Image_Frame = tolua.cast(Img_Material:getChildByName("Image_Frame"),"ImageView")
	Image_Frame:loadTexture(getIconFrame(CSV_ItemBase.ColorType))
	
	local image = tolua.cast(Img_Material,"ImageView")
	image:loadTexture(getFrameBackGround(CSV_ItemBase.ColorType))
	
	local Label_NeedNum = tolua.cast(Img_Material:getChildByName("Label_NeedNum"),"Label")
	Label_NeedNum:setText(nHasNum)
	if nHasNum < nNeedNum then 
		g_setTextColor(Label_NeedNum,ccs.COLOR.RED)
	else
		g_setTextColor(Label_NeedNum,ccs.COLOR.WHITE) 
	end
	
	local Label_NeedNumMax = tolua.cast(Img_Material:getChildByName("Label_NeedNumMax"),"Label")
	Label_NeedNumMax:setText("/"..nNeedNum)
	if nHasNum <= 0 then btnMaterial:setTouchEnabled(true) end	
	
	g_adjustWidgetsRightPosition({Label_NeedNumMax, Label_NeedNum})
	return Img_Material
end

--字符串换行加%s替换
function g_initMsgContent(text,mLen,tb_str,tb_number)
	local bNeedLF = true 
	local nIndex = 1  
	local newStr = ""
	local subStr = ""
	local strIndex = 1
	local numIndex = 1
	local is_end = true
	local index_max =  string.len(text)
	while (is_end) do  
		local temp = string.byte(text,nIndex) 
        if (temp >= 0 and temp <= 127) then 
			subStr =string.sub(text,nIndex,nIndex) 
  			if subStr =="%" then
				local nextStr =string.sub(text,nIndex+1,nIndex+1) 
				if nextStr == "s" then
					subStr = _T(tb_str[strIndex]) or ""
					strIndex = strIndex + 1
				elseif nextStr == "d" then
					subStr = tb_number[numIndex] or 0
					numIndex = numIndex + 1
				end
				
				nIndex = nIndex + 2 
			elseif subStr == "\n" then
				bNeedLF = false
				nIndex = nIndex + 1 
			else
				nIndex = nIndex + 1 
			end
        else 		
			subStr =string.sub(text,nIndex,nIndex + 2) 
			nIndex = nIndex + 3
        end  
		newStr = newStr..subStr
        if (nIndex > index_max) then  
            is_end=false  
        end
    end
    local str_chat = newStr
    if bNeedLF then 	
		str_chat = g_string_insert(newStr,"\n",mLen)
	end
	return str_chat
end

function getDatesNum(year,month)
	local Num
	local temp = os.date("*t")
	local year= year or temp.year
	local month= month or temp.month
	local day=1
	local hour=0
	local nextMonth 
	if month ~= 12 then
		nextMonth = month + 1
		local nTime = os.time{year = year, month = nextMonth, day=1, hour=0}
		nTime = nTime - 60*60
		temp = os.date("*t", nTime)
		Num = temp.day
	else
		Num = 31
	end
	return Num
 end

--[[
	打印log 
	可以无限参数 也可以打印 table
	echoj("ddd",{"11","22"})
]]
function echoj(...)
	local arr = {...}
	local str = "" 
	for i, v in ipairs(arr) do
		if not v then v = "nil" end
		if type(v) == "table" then
			str = str..tostring( lua2str(v) )
		elseif type(v) == "string" then
			str = str..v..","
		elseif type(v) == "number" then
			str = str..v..","
		elseif type(v) == "boolean" then
			str = str..type(v)..","		
		elseif type(v) == "userdata" then
			str = str..tostring(lua2str(v))..","
		else
			str = str..type(v)..","
		end
	end
	cclog(str)
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

local tbTime = {
	60, --分 60
	3600, --时 (60*60)
	86400, --天 (24*60*60)
	604800, --周 (7*24*60*60)
	2592000, --月(30*24*60*60)
	31104000, --年	(12*30*24*60*60)
}

function getStrTime(logTime,logOutTime)
	local curTime = os.time()
	local nTime = logTime or 0
	local logOutTime = logOutTime 
	
	
	local strOffLine = _T("离线")
	local srtText = ""
	local strStartText = _T("在线")
	if not logOutTime then 
		strOffLine = ""
		srtText = _T("前")
		strStartText = _T("刚刚")
	else
		if logTime > logOutTime then
			return strStartText
		end
		--使用退出游戏时的时间计算离线时长
		nTime = logOutTime or 0
	end

	local times = math.floor( (curTime - nTime) / tbTime[1])
	if times >= 1 and times < 60 then 
		return strOffLine..times.._T("分钟")..srtText
	end
	local times = math.floor( (curTime - nTime) / tbTime[2])
	if times >= 1 and times < 24 then
		return strOffLine..times.._T("小时")..srtText
	end
	local times = math.floor( (curTime - nTime) / tbTime[3])
	if times >= 1 and times < 7 then
		return strOffLine..times.._T("天")..srtText
	end
	local times = math.floor( (curTime - nTime) / tbTime[4])
	if times >= 1 and times < 5 then
		return strOffLine..times.._T("周")..srtText
	end
	local times = math.floor( (curTime - nTime) / tbTime[5])
	if times >= 1 and times < 12 then
		return strOffLine..times.._T("月")..srtText
	end
	local times = math.floor( (curTime - nTime) / tbTime[6])
	if times >= 1 then
		return strOffLine..times.._T("年")..srtText
	end
	
	return strStartText
end

--[[
装备小图标的缩放和旋转角度
1，拳套--旋转15，缩放0.50
2，剑、法杖、枪戟--旋转15，缩放0.45
3，弓--旋转10，缩放0.5
4，法袍--旋转0，缩放0.55
5，戒指、项链、奇物、鞋子----旋转0，缩放0.9
类型1拳爪 2刀剑 3弓弩 4法杖 5枪戟 6法袍 7戒指 8项链 9奇物10战靴	
]]
function equipSacleAndRotate(objIcon, subType)
	if not objIcon then return end 
	local nSubType = nSubType or 1
	
	if subType - 1 == 0 then 
		objIcon:setScale(0.5)
		objIcon:setRotation(15)
	elseif subType - 2 == 0 or subType - 4 == 0 or subType - 5 == 0 then 
		objIcon:setScale(0.45)
		objIcon:setRotation(15)
	elseif subType -3 == 0 then
		objIcon:setScale(0.5)
		objIcon:setRotation(10)
	elseif subType - 6 == 0 then 
		objIcon:setScale(0.55)
		objIcon:setRotation(0)
	else --7 8 9 10
		objIcon:setScale(0.9)
		objIcon:setRotation(0)
	end
end

--强化界面、合成界面、重铸界面的装备图标缩放
function g_SetEquipSacle(objIcon,subType)
	if not objIcon then return end
	local nSubType = nSubType or 1
	
	--拳套
	if subType == 1 then 
		objIcon:setScale(1)
	--弓
	elseif subType == 3 then 
		objIcon:setScale(0.9)
	--剑、法杖、枪戟
	elseif subType == 2 or subType == 4 or subType == 5 then 
		objIcon:setScale(0.8)
	--衣服
	elseif subType == 6 then
		objIcon:setScale(0.85)
	else
		objIcon:setScale(1)
	end
end

--装备Tip上的图标的缩放
function g_SetEquipSacleTip(objIcon,nSubType)
	if not objIcon then return end
	local nSubType = nSubType or 1
	--拳套
	if nSubType == 1 then 
		objIcon:setScale(0.65)
	--弓
	elseif nSubType == 3 then 
		objIcon:setScale(0.65)
	--剑、法杖、枪戟
	elseif nSubType == 2 or nSubType == 4 or nSubType == 5 then 
		objIcon:setScale(0.6)
	--衣服
	elseif nSubType == 6 then
		objIcon:setScale(0.6)
	else
		objIcon:setScale(1)
	end
end

function getEquipLevFont(nLevel)
    return string.format("Char/Char_EquipLevel%d.fnt", nLevel)
end

--字符+号拼接, 用于合成等级、突破等级
function getFormatSuffixLevel(strName, nLevel)
	local strName = strName or ""
	local nLevel = nLevel or 0
	
	if nLevel <= 0 then
		return strName
	else
		
		return strName.."+"..nLevel
	end
end

--遮罩层  flag 可以不传 是在调试时使用 可以看见颜色层  removeFromParentAndCleanup(false)
function creationCover(rootWidget, flag)
	if not rootWidget then return end
	local Panel_Warning = rootWidget:getChildByName("Panel_Warning")
	if not Panel_Warning then
		Panel_Warning =  Layout:create()
		rootWidget:addChild(Panel_Warning,INT_MAX)
	end
	Panel_Warning:setSize(CCSize(1280,720))
	Panel_Warning:setName("Panel_Warning")
	-- if flag then 
		-- Panel_Warning:setBackGroundColorType(2) --1 无颜色 2 单色 3渐变
		-- Panel_Warning:setBackGroundColor(ccc3(255,0,0))
		-- Panel_Warning:setBackGroundColorOpacity(128)
	-- end
	Panel_Warning:setTouchEnabled(true)
	if flag then 
		local Button_Return = tolua.cast(rootWidget:getChildAllByName("Button_Return"),"Button")
		Button_Return:setZOrder(INT_MAX)
	end
	return Panel_Warning
end

--[[
	不同颜色组合的 飘字
	左对齐的方式
	不能设置锚点
	
	--输入要显示的文字
	local tbText = {
		"成功猎到妖兽",
		"【名称】",
		"并遇到了姜子牙",
	} 
	--要输入要显示的文字的 
	--顺序输入要设置的颜色 table 要一致相互对应
	--可以不输入 默认为 白色
	local tbCCSColor = {
		ccs.COLOR.WHITE,
		ccs.COLOR.LIGHT_GREEN
	}
	--设置方法同上，设置字体大小
	local tbSize = {}
	local param = {
		widget = ,
		x = ,
		y = ,
	}
	group(param,tbText,tbCCSColor,tbSize)
]]
function g_FunctionGroupTips(param,tbText,tbCCSColor,tbSize)
	local size = 26
	if not tbText then tbText = {} end 
	if not tbCCSColor then tbCCSColor = {} end
	if not tbSize then tbSize = {} end
	local tbLable = {}
	local x,y = param.x,param.y
	local widget = param.widget
	if not x then x = 80 end
	if not y then y = 140 end
	local layout = Layout:create()
	for key,value in ipairs(tbText) do 
		local label = Label:create()
		label:setText(value)
		if tbSize[key] then 
			label:setFontSize(tbSize[key])
		else
			label:setFontSize(size)
		end
		if tbCCSColor[key] then 
			g_setTextColor(label, tbCCSColor[key])
		else
			g_setTextColor(label, ccs.COLOR.WHITE)
		end
		layout:addChild(label)
		table.insert(tbLable,label)
	end
	--多个控件对齐
	g_AdjustWidgetsPosition(tbLable)
	g_ShowServerSysTips({Label_Tips = layout,layout = widget,x = x,y = y})

end

--[[
	封装 CCSequence 与 CCArray
	param = {} 按顺序放入要执行的动画动画  效果和CCSequence 一样的
]]
function sequenceAction(param)
	local array = CCArray:create()
	if param then 
		for key,value in ipairs(param) do 
			array:addObject(value)
		end
	end
	return CCSequence:create(array)
end
--[[
	封装 CCSpawn 与 CCArray
	param = {} 按顺序放入要执行的动画动画  效果和CCSequence 一样的
]]
function spawnArray(param)
	local array = CCArray:create()
	if param then 
		for key,value in ipairs(param) do 
			array:addObject(value)
		end
	end
	return CCSpawn:create(array)
end


--[[
	按图像 空白区域遮罩
	@invertedFlag  作用区域 false  隐藏空白区域
]]
function SpriteCoverlipping(newImage,coverIamge,invertedFlag)
	-- local blendFuncDstColor = ccBlendFunc()
	-- blendFuncDstColor.src = GL_DST_COLOR
	-- blendFuncDstColor.dst = GL_ONE
	if not newImage then cclog("资源错误") return end
	if not coverIamge then cclog("资源错误") return end 
	if not invertedFlag then invertedFlag = false end
	
	local newSprite = CCSprite:create(newImage)
	-- newSprite:retain()
	-- newSprite:setBlendFunc(blendFuncDstColor)
	local spriteCover = CCSprite:create(coverIamge)
	-- spriteCover:retain()
	if newSprite == nil or spriteCover == nil then
		return nil
	end

	local clippingNode = CCClippingNode:create()
	-- clippingNode:retain()
	
	clippingNode:setStencil(spriteCover)
	clippingNode:setAlphaThreshold(0)
	clippingNode:setPosition(ccp(0,0))
	clippingNode:setInverted(invertedFlag)
	clippingNode:addChild(newSprite)
	return clippingNode
end
--------------------设置标签变红------------------------------------------
function g_SetLabelRed(widget,flag)
	if flag then
		g_setTextColor(widget,ccs.COLOR.RED)
	else
		g_setTextColor(widget,ccs.COLOR.WHITE)
	end
end

function g_NoticeNotify(tb_msg)
	local lst = tb_msg.notice_lst
	for i,v in ipairs(lst)do
		local types = v.type -- 通知类型
		local cardid = v.cardid; -- 伙伴id
		local posidx = v.posidx; -- 位置索引
		local nNum = v.num; -- 通知数量
		if types == macro_pb.NoticeType_Friend then			--好友申请
			g_Hero:setBubbleNotify("social", g_Hero:getBubbleNotify("social") + nNum)
			--g_Hero:setBubbleNotify("social",nNum)
		-- elseif types == macro_pb.NoticeType_MailNotice then			--邮件通知
		-- 	g_Hero:setBubbleNotify("mail",nNum)
		elseif types == macro_pb.NoticeType_TurnTable then			--转盘
			--g_Hero.bubbleNotify.turn = nNum
		elseif types == macro_pb.NoticeType_ChatWorld then			--世界聊天
		elseif types == macro_pb.NoticeType_ChatFriend then			--好友聊天
		elseif types == macro_pb.NoticeType_ChatLeague then			--联盟聊天
		elseif types == macro_pb.NoticeType_ChatNotice 	then	--公告聊天
        elseif types == macro_pb.NoticeType_EquipFate 	then	--灵兽
		    g_Hero:setTbNoticeForDoubleKey(types,v)
		elseif types == macro_pb.NoticeType_FreeFate then	--免费猎命次数
			g_Hero:setTbNoticeForDoubleKey(types,v)
		elseif types == macro_pb.NoticeType_XianMai then	--仙脉
			g_Hero:setTbNoticeForDoubleKey(types,v)
		elseif types == macro_pb.NoticeType_Card then		--伙伴
			g_Hero:setTbNoticeForDoubleKey(types,v)
		elseif types == macro_pb.NoticeType_Equip then	    --装备
			g_Hero:setTbNoticeForDoubleKey(types,v)
		elseif types == macro_pb.NoticeType_Qishu then	    --奇术
			g_Hero:setTbNoticeForDoubleKey(types,v)
		else
			g_Hero:setTbNotice(types,v)
		end

	end 
end

function g_SkillWndShow()
	local warning =  Layout:create()
	warning:setSize(CCSize(1280,720))
	warning:setBackGroundColorType(2) --1 无颜色 2 单色 3渐变
	warning:setBackGroundColor(ccc3(255,0,0))
	warning:setBackGroundColorOpacity(128)
	warning:setTouchEnabled(true)

	local function pickupCreate(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			warning:removeFromParentAndCleanup(false)
			g_WndMgr:closeWnd("Game_SkillEolute1")
			g_WndMgr:closeWnd("Game_Compose")
		end
	end
	warning:addTouchEventListener(pickupCreate)
	self.rootLayout:addChild(warning,INT_MAX)

	g_WndMgr:showWnd("Game_Compose")
	if g_WndMgr:getWnd("Game_Compose") then
		g_WndMgr:getWnd("Game_Compose").rootWidget:setTouchEnabled(false)
	end
	
	g_WndMgr:showWnd("Game_SkillEolute1")
	if g_WndMgr:getWnd("Game_SkillEolute1") then
		g_WndMgr:getWnd("Game_SkillEolute1").rootWidget:setTouchEnabled(false)
	end
end


function g_addUpgradeGuide(widget, tbPos, fScale, bIsShowGuide)
	local fScale = fScale or 0.8
	
	local CCNode_Guide = widget:getNodeByTag(919)
	if CCNode_Guide then
		widget:removeNodeByTag(919)
	end
		
	if bIsShowGuide then
		local armature,userAnimation = g_CreateCoCosAnimation("UpgradeEquipGuide", nil, 6)
		widget:addNode(armature, 919, 919)
		userAnimation:playWithIndex(0)    
		armature:setPosition(tbPos)
		armature:setScale(fScale)
	end
end

function g_ShowMoneyConfirm(strWarning)
	local strWarning = strWarning or _T("您的铜钱不足是否进行招财？")
	g_ClientMsgTips:showConfirm(strWarning, function() 
		g_WndMgr:showWnd("Game_ZhaoCaiFu")
	end)
end

function g_CheckMoneyConfirm(nNeedMoney, strWarning)
	if tonumber(nNeedMoney) > (g_Hero:getCoins()) then
		g_ShowMoneyConfirm(strWarning)
		return false
	end
	return true
end

function g_ShowYuanBaoConfirm(strWarning)
	local strWarning = strWarning or "您的元宝不足是否前往充值？"
	g_ClientMsgTips:showConfirm(strWarning, function() 
		g_WndMgr:showWnd("Game_ReCharge")
	end)
end

function g_CheckYuanBaoConfirm(nNeedYuanBao, strWarning)
	if tonumber(nNeedYuanBao) > (g_Hero:getYuanBao()) then
		g_ShowYuanBaoConfirm(strWarning)
		return false
	end
	return true
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

--[[
	渲染不同状态先的图案
	@param object 传入要改变的对象
	@param param = {normal="正常状态",pressed="点击下状态",disabled="禁用状态"}
]]

function g_setBtnLoadTexture(object,param)
	local normal = param.normal
	local pressed = param.pressed
	local disabled = param.disabled
	local imageType = param.imageType;--图案加载类型
	if normal then 
		--正常状态
		object:loadTextureNormal(normal)
	end
	
	if pressed then 
		--点击下状态
		object:loadTexturePressed(pressed)
	end
	
	if disabled then
		--禁用状态
		object:loadTextureDisabled(disabled)
	end
end

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
