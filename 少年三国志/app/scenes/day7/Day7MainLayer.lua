--Day7MainLayer.lua
require("app.cfg.days7_activity_info")
require("app.cfg.days7_sell_info")

local Day7MainLayer = class("Day7MainLayer", UFCCSNormalLayer)

function Day7MainLayer.create( ... )
	return Day7MainLayer.new("ui_layout/day7_MainLayer.json", nil, ...)
end

function Day7MainLayer:ctor( _, _, defaultDay, ... )
	self._dayIndex = defaultDay or 0
	self._bonusIndex = 1
	self._bonusList = nil
	self._timer = nil
	self._bonusContentList = {}
	self._bonusTypeList = {}
	self._curBonusContent = {}
	self._maxDay = 0

	self.super.ctor(self, nil, nil, defaultDay, ...)
end

function Day7MainLayer:adapterLayer( ... )
	self:adapterWidgetHeight("Panel_content", "Panel_checkboxs", "", 20, 0)
end

function Day7MainLayer:onLayerLoad( ... )
	-- init current day index by data
	--self._dayIndex = 1

	self:enableLabelStroke("Label_name", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_count", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_local_title", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_local_value", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_count", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_purchase_tip", Colors.strokeBrown, 1 )

	self:registerWidgetClickEvent("Button_1", function ( ... )
		self:_onDayBtnClick( 1 )
	end)
	self:registerWidgetClickEvent("Button_2", function ( ... )
		self:_onDayBtnClick( 2 )
	end)
	self:registerWidgetClickEvent("Button_3", function ( ... )
		self:_onDayBtnClick( 3 )
	end)
	self:registerWidgetClickEvent("Button_4", function ( ... )
		self:_onDayBtnClick( 4 )
	end)
	self:registerWidgetClickEvent("Button_5", function ( ... )
		self:_onDayBtnClick( 5 )
	end)
	self:registerWidgetClickEvent("Button_6", function ( ... )
		self:_onDayBtnClick( 6 )
	end)
	self:registerWidgetClickEvent("Button_7", function ( ... )
		self:_onDayBtnClick( 7 )
	end)

	self:enableLabelStroke("Label_fuli_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_fuben_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_strength_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_buy_check", Colors.strokeBrown, 2 )
    self:enableLabelStroke("Label_endTime_value", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_endTime", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_award_value", Colors.strokeBrown, 1 )
    self:enableLabelStroke("Label_award_endTime", Colors.strokeBrown, 1 )

	self:addCheckNodeWithStatus("CheckBox_fuli", "Label_fuli_check", true)
    self:addCheckNodeWithStatus("CheckBox_fuli", "Label_fuli_uncheck", false)

    self:addCheckNodeWithStatus("CheckBox_fuben", "Label_fuben_check", true)
    self:addCheckNodeWithStatus("CheckBox_fuben", "Label_fuben_uncheck", false)

    self:addCheckNodeWithStatus("CheckBox_strength", "Label_strength_check", true)
    self:addCheckNodeWithStatus("CheckBox_strength", "Label_strength_uncheck", false)

    self:addCheckNodeWithStatus("CheckBox_buy", "Label_buy_check", true)
    self:addCheckNodeWithStatus("CheckBox_buy", "Label_buy_uncheck", false)

	self:addCheckBoxGroupItem(1, "CheckBox_fuli")
	self:addCheckBoxGroupItem(1, "CheckBox_fuben")
	self:addCheckBoxGroupItem(1, "CheckBox_strength")
	self:addCheckBoxGroupItem(1, "CheckBox_buy")

	self:registerCheckboxEvent("CheckBox_fuli", function ( widget, type, isCheck )
		self:_onBonusBtnCheck(1)
	end)
	self:registerCheckboxEvent("CheckBox_fuben", function ( widget, type, isCheck )
		self:_onBonusBtnCheck(2)
	end)
	self:registerCheckboxEvent("CheckBox_strength", function ( widget, type, isCheck )
		self:_onBonusBtnCheck(3)
	end)
	self:registerCheckboxEvent("CheckBox_buy", function ( widget, type, isCheck )
		self:_onBonusBtnCheck(4)
	end)

	self:showWidgetByName("Panel_purchase", false)

	--蔡文姬
	local appstoreVersion = (G_Setting:get("appstore_version") == "1")
	local GlobalConst = require("app.const.GlobalConst")
	if appstoreVersion or IS_HEXIE_VERSION  then 
	    knight = knight_info.get(GlobalConst.CAI_WEN_JI_HE_XIE_ID)
	else
	    knight = knight_info.get(GlobalConst.CAI_WEN_JI_ID)
	end
	if knight then
	    local heroPanel = self:getPanelByName("Panel_caiwenji")
	    local KnightPic = require("app.scenes.common.KnightPic")
	    KnightPic.createKnightPic( knight.res_id, heroPanel, "caiwenji",true )
	    heroPanel:setScale(0.8)
	    if self._smovingEffect == nil then
	        local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
	        self._smovingEffect = EffectSingleMoving.run(heroPanel, "smoving_idle", nil, {})
	    end
	end
        
    self:registerBtnClickEvent("Button_Help",function()
    	uf_sceneManager:getCurScene():addChild(require("app.scenes.day7.Day7HelpLayer").create())
        --uf_notifyLayer:addNode(require("app.scenes.day7.Day7HelpLayer").create())
    end)
end

function Day7MainLayer:onLayerEnter( ... )
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FLUSH_ACTIVITY_INFO, self._onFlushActivityInfo, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FINISH_ACTIVITY_INFO, self._onFinishActivityInfo, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DAYS_ACTIVITY_SELL_INFO, self._onGetActivitySellInfo, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_PURCHASE_ACTIVITY_SELL, self._onPurchaseActivityInfo, self)

	if G_Me.days7ActivityData:isOnActivity()  then
		G_HandlersManager.daysActivityHandler:sendGetDaysActivityInfo()
		G_HandlersManager.daysActivityHandler:sendDaysActivitySellInfo()
	end

	self:_updateActivityFlag()
	--self:callAfterFrameCount(1, function ( ... )
	self:adapterLayer()
	if self._dayIndex > 0 and self._dayIndex < 8 then
		local curDay = self._dayIndex
		self._dayIndex = 0
		self:_onDayBtnClick(curDay)
	else
		self:_onDayBtnClick(self._maxDay > 7 and 7 or self._maxDay)
	end
		--self:_updateBtnStatus(0, self._dayIndex)
	--end)

	self:_initLeftTimeStatus()
	self:setCheckStatus(1, "CheckBox_fuli")
end

function Day7MainLayer:onLayerExit( ... )
	if self._timer then 
		G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
	end
end

function Day7MainLayer:_initLeftTimeStatus( ... )
	local activityIsOver = G_Me.days7ActivityData:isActivityOverTime()
	--self:showWidgetByName("Label_endTime_value", activityIsOver)
	--self:showWidgetByName("Label_endTime", activityIsOver)

	local _updateTime = nil
	local awardOverTime = G_Me.days7ActivityData:overTime()
	local activityOverTime = awardOverTime - 3*24*3600

	--self:showTextWithLabel("Label_endTime", G_lang:get("LANG_DAYS7_AWARD_END_TIME"))
	--self:showTextWithLabel("Label_award_endTime", G_lang:get("LANG_DAYS7_ACTIVITY_END_TIME"))
	if activityIsOver then 
		self:showTextWithLabel("Label_endTime_value", G_lang:get("LANG_DAYS7_HAVE_FNINISHED"))
	end
	_updateTime = function ( ... )
			if activityOverTime > 0 then 
				local day, hour, min, second = G_ServerTime:getLeftTimeParts(activityOverTime)
				self:showTextWithLabel("Label_endTime_value", G_lang:get("LANG_DAYS7_OVERTIME_FORMAT", {dayValue=day, hourValue=hour, minValue=min, secondValue=second}))
				if day < 1 and hour < 1 and min < 1 and second < 1 then 
					activityOverTime = 0
					self:showTextWithLabel("Label_endTime_value", G_lang:get("LANG_DAYS7_HAVE_FNINISHED"))
				end
			end
			if awardOverTime > 0 then 
				local day, hour, min, second = G_ServerTime:getLeftTimeParts(awardOverTime)
				self:showTextWithLabel("Label_award_value", G_lang:get("LANG_DAYS7_OVERTIME_FORMAT", {dayValue=day, hourValue=hour, minValue=min, secondValue=second}))
				if day < 1 and hour < 1 and min < 1 and second < 1 then 
					awardOverTime = 0
					self:showTextWithLabel("Label_award_value", G_lang:get("LANG_DAYS7_HAVE_FNINISHED"))
				end
			end
			if awardOverTime < 1 then 
				if self._timer then 
					G_GlobalFunc.removeTimer(self._timer)
        			self._timer = nil
				end
			end
		end

	self._timer = G_GlobalFunc.addTimer(1,function()
			if _updateTime then 
				_updateTime()
			end
	end)
	if _updateTime then
	    _updateTime()
	end
end

function Day7MainLayer:_updateBtnStatus( oldIndex, newIndex )
	if type(oldIndex) ~= "number" then 
		oldIndex = 0
	end

	if type(newIndex) ~= "number" then 
		return 
	end

	oldIndex = oldIndex or 0
	newIndex = newIndex or 1

	local _selecteBtn = function ( index, isSelect )
		if type(index) ~= "number" or index < 1 or index > 7 then 
			return 
		end

		isSelect = isSelect or false
		local btn = self:getButtonByName("Button_"..index)
		if btn then 
			btn:loadTextureNormal(isSelect and "ui/day7/bg_day_current.png" or "ui/day7/bg_day_normal.png", UI_TEX_TYPE_LOCAL)
		end
	end

	if oldIndex > 0 then
		_selecteBtn(oldIndex, false)
	end
	if newIndex > 0 then 
		_selecteBtn(newIndex, true)
	end
end

function Day7MainLayer:_onDayBtnClick( index )
	if type(index) ~= "number" then
		return
	end

	index = index or 0
	if index < 1 or index > 7 then 
		return
	end

	if self._dayIndex == index then 
		return 
	end

	if index > self._maxDay then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_DAYS7_ACTIVITY_LOCKED"))
	end

	local oldIndex = self._dayIndex
	self._dayIndex = index 

	--self._bonusIndex = 1
	--self:setCheckStatus(1, "CheckBox_fuli")

	-- 重新加载当前的活动内容
	self:_refreshBonusContent()
	-- 更新当前活动的3个内容标签
	self:_updateCheckBtns()
	-- 更新当前天数按钮状态
	self:_updateBtnStatus(oldIndex, index)	
	-- 重新载入列表
	self:_reloadBonusContent(true)
	-- 重新载入半价购买的物品
	self:_reloadPurchaseItem()

	self:_updateAwardActivityFLag()
end

function Day7MainLayer:_onBonusBtnCheck( bonusIndex )
	if type(bonusIndex) ~= "number" then 
		bonusIndex = 1
	end

	if bonusIndex == self._bonusIndex then 
		return 
	end

	if bonusIndex < 1 then 
		bonusIndex = 1  
	end
	if bonusIndex > 4 then 
		bonusIndex = 4  
	end

	local oldBonusIndex = self._bonusIndex
	self._bonusIndex = bonusIndex

	if oldBonusIndex < 4 and bonusIndex >= 4 then 
		if self._listview then
			self._listview:setVisible(false)
		end
		self:showWidgetByName("Panel_purchase", true)
	elseif oldBonusIndex >= 4 and bonusIndex < 4 then 
		if self._listview then
			self._listview:setVisible(true)
		end
		self:showWidgetByName("Panel_purchase", false)
	else
		self:showWidgetByName("Panel_purchase", false)
	end

	self:_reloadBonusContent(true)
end

function Day7MainLayer:_createBonusList( ... )
	if not self._bonusList then 
		local panel = self:getPanelByName("Panel_list")
		if panel == nil then
			return 
		end

		self._listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

    	self._listview:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.day7.Day7BonusItem").new(list, index)
    	end)
    	self._listview:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			cell:updateItem(self._curBonusContent[index + 1] or 0)
    		end
    	end)
    	self._listview:setSelectCellHandler(function ( cell, index )
    	end)
    	self._listview:setSpaceBorder(0, 40)
	end
end

function Day7MainLayer:_reloadBonusContent( firstTime )
	if not self._listview then 
		self:_createBonusList()
	end

	local _sortBonusContent = function ( bonus1, bonus2 )
		local bonusData1 = G_Me.days7ActivityData:getActivityInfoById(bonus1)
		local bonusData2 = G_Me.days7ActivityData:getActivityInfoById(bonus2)

		if not bonusData1 then 
			return false
		end

		if not bonusData2 then 
			return true
		end

		if bonusData1.status ~= bonusData2.status then 
			if bonusData1.status == 1 then 
				return true 
			elseif bonusData2.status == 1 then 
				return false 
			elseif bonusData1.status == 0 then 
				return true 
			elseif bonusData1.status == 2 then 
				return false 
			end
		end

		local data1 = days7_activity_info.get(bonus1)
		local data2 = days7_activity_info.get(bonus2)
		if not data1 then 
			return false
		end

		if not data2 then 
			return true
		end
		return data1.arrange < data2.arrange
	end

	if self._listview then 
		local contentIndex = self._bonusTypeList[self._bonusIndex] or 1
		self._curBonusContent = self._bonusContentList[contentIndex] or {}

		table.sort(self._curBonusContent, _sortBonusContent)
		self._listview:reloadWithLength(#self._curBonusContent, 0, firstTime and 0.2 or 0)
	end
end

function Day7MainLayer:_refreshBonusContent( ... )
	self._bonusContentList = {}

	if type(self._dayIndex) ~= "number" or self._dayIndex < 1 or self._dayIndex > 7 then 
		return 
	end

	local _addBonusContent = function ( typeIndex, bonusId )
		if type(typeIndex) ~= "number" or type(bonusId) ~= "number" then 
			return 
		end

		local typeContent = self._bonusContentList[typeIndex] or {}
		table.insert(typeContent, #typeContent + 1, bonusId)
		self._bonusContentList[typeIndex] = typeContent
	end

	for loopi = 1, days7_activity_info.getLength() do 
		local activityInfo = days7_activity_info.indexOf(loopi)
		if activityInfo and (activityInfo.limit_time_client == self._dayIndex) then 
			_addBonusContent(activityInfo.tags, activityInfo.id)
		end
	end

	self._bonusTypeList = {}
	for key, value in pairs(self._bonusContentList) do 
		table.insert(self._bonusTypeList, #self._bonusTypeList + 1, key)
	end
end

function Day7MainLayer:_updateCheckBtns( ... )
	local bonuTypeIndex = self._bonusTypeList[1] or 1
	local bonuTypeStr = G_lang:get("LANG_ACTIVITY_TITLE_"..bonuTypeIndex)
	self:showTextWithLabel("Label_fuli_check", bonuTypeStr)
	self:showTextWithLabel("Label_fuli_uncheck", bonuTypeStr)

	bonuTypeIndex = self._bonusTypeList[2] or 1
	bonuTypeStr = G_lang:get("LANG_ACTIVITY_TITLE_"..bonuTypeIndex)
	self:showTextWithLabel("Label_fuben_check", bonuTypeStr)
	self:showTextWithLabel("Label_fuben_uncheck", bonuTypeStr)

	bonuTypeIndex = self._bonusTypeList[3] or 1
	bonuTypeStr = G_lang:get("LANG_ACTIVITY_TITLE_"..bonuTypeIndex)
	self:showTextWithLabel("Label_strength_check", bonuTypeStr)
	self:showTextWithLabel("Label_strength_uncheck", bonuTypeStr)
end

function Day7MainLayer:_updateAwardActivityFLag( ... )
	if self._maxDay > 1 then 
		for loopi = 1, self._maxDay do
			self:showWidgetByName("Image_tip_"..loopi, G_Me.days7ActivityData:hasAwardActivityByDay(loopi))
		end
	end	

	if self._dayIndex > 0 then 
		for loopi = 1, 3 do 
			local flag = G_Me.days7ActivityData:hasAwardActivityByTag(self._dayIndex, self._bonusTypeList[loopi])
			self:showWidgetByName("Image_check_tip_"..loopi, flag)
		end

		self:showWidgetByName("Image_check_tip_4", G_Me.days7ActivityData:canBuySellInfoByDay(self._dayIndex))
	end
end

function Day7MainLayer:_reloadPurchaseItem( ... )
	if type(self._dayIndex) ~= "number" or self._dayIndex < 1 or self._dayIndex > 7 then 
		self:showWidgetByName("Panel_45", false)
		return 
	end

	local sellInfo = days7_sell_info.get(self._dayIndex)
	if not sellInfo then 
		self:showWidgetByName("Panel_45", false)
		return
	end

		local goodInfo = G_Goods.convert(sellInfo.type, sellInfo.value, sellInfo.size)
		if not goodInfo then 
			self:showWidgetByName("Panel_45", false)
			return
		end

		self:showWidgetByName("Image_item", true)

		local image = self:getImageViewByName("Image_icon")
		if image then 
			image:loadTexture(goodInfo.icon, UI_TEX_TYPE_LOCAL)
		end

		image = self:getImageViewByName("Image_pingji")
		if image then 
			if typeId == G_Goods.TYPE_FRAGMENT then
				image:loadTexture(G_Path.getEquipColorImage(goodInfo.quality, G_Goods.TYPE_FRAGMENT))
			else
				image:loadTexture(G_Path.getAddtionKnightColorImage(goodInfo.quality))
			end
		end
		
		image = self:getImageViewByName("Image_item_back")
		if image then 
			image:loadTexture(G_Path.getEquipIconBack(goodInfo.quality))
		end

		local name = self:getLabelByName("Label_name")
		if name ~= nil then
			name:setColor(Colors.qualityColors[goodInfo.quality])
			name:setText(goodInfo.name)		
		end

		self:showTextWithLabel("Label_count", "x"..goodInfo.size)
		self:registerWidgetClickEvent("Image_icon", function ( ... )
			require("app.scenes.common.dropinfo.DropInfo").show(sellInfo.type, sellInfo.value) 
		end)

		self:showTextWithLabel("Label_old_value", sellInfo.pre_price)
		self:showTextWithLabel("Label_local_value", sellInfo.price)

		local yuanbao1 = self:getImageViewByName("Image_yuanbao1")
		local yuanbao2 = self:getImageViewByName("Image_yuanbao2")
		if sellInfo.price_type == 1 then 
			yuanbao1:loadTexture("icon_mini_yingzi.png", UI_TEX_TYPE_PLIST)
			yuanbao2:loadTexture("icon_mini_yingzi.png", UI_TEX_TYPE_PLIST)
		elseif sellInfo.price_type == 2 then 
			yuanbao1:loadTexture("icon_mini_yuanbao.png", UI_TEX_TYPE_PLIST)
			yuanbao2:loadTexture("icon_mini_yuanbao.png", UI_TEX_TYPE_PLIST)
		end

		self:registerWidgetClickEvent("Button_buy", function ( ... )
			self:_onPurchaseItemClick(goodInfo, sellInfo.price)
		end)

		self:_updateSellInfo()
end

function Day7MainLayer:_updateSellInfo( ... )
	local sellInfo = days7_sell_info.get(self._dayIndex)
	if not sellInfo then 
		return
	end

	local curSellInfo = G_Me.days7ActivityData:getActivitySellInfoByIndex(self._dayIndex)
	if curSellInfo then
		self:showTextWithLabel("Label_purchase_tip", G_lang:get("LANG_DAYS7_ACTIVITY_SELL_COUNT", 
			{maxCount=sellInfo.num, curCount=curSellInfo.num}))

		self:showWidgetByName("Image_buy", not curSellInfo.bought)
		self:showWidgetByName("Image_hasBuy", curSellInfo.bought)
		self:enableWidgetByName("Button_buy", not curSellInfo.bought)
	else
		self:showWidgetByName("Label_purchase_tip", false)
	end
end

function Day7MainLayer:_onPurchaseItemClick( goods, price )
	-- if self._dayIndex ~= self._maxDay then 
	-- 	return G_MovingTip:showMovingTip(G_lang:get("LANG_DAYS7_SELL_BUY_OVERTIME"))
	-- end

	if not goods then 
		return 
	end

	local curSellInfo = G_Me.days7ActivityData:getActivitySellInfoByIndex(self._dayIndex)
	if not curSellInfo then 
		return 
	end

	if curSellInfo.num < 1 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_DAYS7_SELL_BUY_MAX"))
	elseif curSellInfo.bought then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_DAYS7_SELL_BUY_ALREADY"))
	end

	if G_Me.userData.gold < price then 
		return require("app.scenes.shop.GoldNotEnoughDialog").show()
	end

        -- 元宝购买提示
        local layer = require("app.scenes.common.CommonGoldConfirmLayer").create(goods, price, function(_layer)

            _layer:animationToClose()

            G_HandlersManager.daysActivityHandler:sendPurchaseActivitySell(self._dayIndex)
            
        end)

        uf_sceneManager:getCurScene():addChild(layer)
            
end

function Day7MainLayer:_onFlushActivityInfo( ... )
	self:_updateActivityFlag()
	if self._listview then 
		self._listview:refreshAllCell()
	end
end

function Day7MainLayer:_updateActivityFlag( ... )
	self._maxDay = G_Me.days7ActivityData._curDayIndex or 0
	self:_updateAwardActivityFLag()
end

function Day7MainLayer:_onFinishActivityInfo( buffer )
	-- if self._listview then 
	-- 	self._listview:refreshAllCell()
	-- end

	self:_reloadBonusContent()

	if type(buffer) == "table" and type(buffer.awards) == "table" then
		if #buffer.awards == 1 and buffer.awards[1].type == G_Goods.TYPE_KNIGHT then
			local OneKnightDrop = require("app.scenes.shop.animation.OneKnightDrop")
        	OneKnightDrop.show(3, buffer.awards[1].value)
		else
			local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(buffer.awards, function ( ... )
    		end)
    		self:addChild(_layer)
    	end 
	end
end

function Day7MainLayer:_onGetActivitySellInfo( ... )
	self:_updateSellInfo()
end

function Day7MainLayer:_onPurchaseActivityInfo( buffer )
	self:_updateSellInfo()

	self:_updateAwardActivityFLag()

	if type(buffer) == "table" and type(buffer.awards) == "table" then
		local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(buffer.awards, function ( ... )
        	if self.__EFFECT_FINISH_CALLBACK__ then 
            	self.__EFFECT_FINISH_CALLBACK__()
        	end
    	end)
    	self:addChild(_layer)
	end
end

return Day7MainLayer

