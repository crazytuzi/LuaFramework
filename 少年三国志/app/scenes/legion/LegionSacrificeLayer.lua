--LegionSacrificeLayer.lua

require("app.cfg.corps_worship_info")
require("app.cfg.corps_info")
require("app.cfg.knight_info")

local knightPic = require("app.scenes.common.KnightPic")
local EffectNode = require "app.common.effects.EffectNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local LegionSacrificeLayer = class("LegionSacrificeLayer", UFCCSNormalLayer)

function LegionSacrificeLayer.create( ... )
	return LegionSacrificeLayer.new("ui_layout/legion_SacrificeLayer.json")
end

function LegionSacrificeLayer:ctor( ... )
	self._sacrificeId = 0
	self._sacrificeShowId = 0
	self._sacrificeShowIndex = 0
	self._sacrificeLevel = 0
	self._curAwardIndex = 0
	self._curSelectSacrificeIndex = 0
	self._originKnightPos = ccp(0, 0)
	self._originNamePos = ccp(0, 0)
	self._originOkPos = ccp(0, 0)
	self._originTipPos = ccp(0, 0)
	self._sacrificeContent = {}
	self._sacrificeContentIndex = {}
	self._sacrificePlayIndex = 0
	self._shakeEffect = nil

	self._sacrificeShowEffect = nil
	self._defaultAwardTip = nil
	self._aquireAwardIds = {}
	self._isSacrificeFlag = false
	self.super.ctor(self, ...)
end

function LegionSacrificeLayer:onLayerLoad( ... )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 2 )
	self:enableLabelStroke("Label_gongxian", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_gongxian_value", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_level", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_tip", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_progress_count", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress_count_value", Colors.strokeBrown, 1)

	self:enableLabelStroke("Label_content_1_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_content_1_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_content_1_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_content_2_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_content_2_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_content_2_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_content_3_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_content_3_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_content_3_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_price_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_price_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_price_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_content_3_4", Colors.strokeBrown, 1 )

	self:enableLabelStroke("Label_pro_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_pro_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_pro_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_pro_4", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress_title", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_progress_value", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_sure_tip", Colors.strokeBrown, 1 )

	self:enableLabelStroke("Label_knight_desc", Colors.strokeBrown, 1)

	self:registerBtnClickEvent("Button_back", handler(self, self._onBackClick))
	self:registerBtnClickEvent("Button_help", handler(self, self._onHelpClick))
	self:registerBtnClickEvent("Button_tongyi", handler(self, self._onOkClick))

	self:addCheckBoxGroupItem(1, "CheckBox_left")
    self:addCheckBoxGroupItem(1, "CheckBox_middle")
    self:addCheckBoxGroupItem(1, "CheckBox_right")
    self:enableWidgetByName("CheckBox_left", false)
    self:enableWidgetByName("CheckBox_middle", false)
    self:enableWidgetByName("CheckBox_right", false)
    self:registerCheckboxEvent("CheckBox_left", function ( ... )
    	--self:_onSacrificeCheck(1)
    end)
	self:registerCheckboxEvent("CheckBox_middle", function ( ... )
    	--self:_onSacrificeCheck(2)
    end)
	self:registerCheckboxEvent("CheckBox_right", function ( ... )
    	--self:_onSacrificeCheck(3)
    end)
    self:registerBtnClickEvent("Button_left", function ( ... )
    	self:_onSacrificeCheck(1, true)
    end)
    self:registerBtnClickEvent("Button_middle", function ( ... )
    	self:_onSacrificeCheck(2, true)
    end)
    self:registerBtnClickEvent("Button_right", function ( ... )
    	self:_onSacrificeCheck(3, true)
    end)

	-- self:registerBtnClickEvent("Button_get_1", function ( ... )
	-- 	self:_onSacrificeClick(1)
	-- end)
	-- self:registerBtnClickEvent("Button_get_2", function ( ... )
	-- 	self:_onSacrificeClick(2)
	-- end)
	-- self:registerBtnClickEvent("Button_get_3", function ( ... )
	-- 	self:_onSacrificeClick(3)
	-- end)

	self:registerBtnClickEvent("Button_box_1", function ( ... )
		self:_onAwardBoxClick(1)
	end)
	self:registerBtnClickEvent("Button_box_2", function ( ... )
		self:_onAwardBoxClick(2)
	end)
	self:registerBtnClickEvent("Button_box_3", function ( ... )
		self:_onAwardBoxClick(3)
	end)
	self:registerBtnClickEvent("Button_box_4", function ( ... )
		self:_onAwardBoxClick(4)
	end)

	self:registerBtnClickEvent("Button_levelUp", handler(self, self._onLevelUpClick))

	self:_initRichText()
	self:_initSacrificeAward()
	self:_updateCorpDetail()
	self:_onRefreshCorpWorship()

	G_HandlersManager.legionHandler:sendGetCorpWorship()

	local bg = self:getImageViewByName("Image_back")
    if bg then 
        bg:loadTexture(G_GlobalFunc.isNowDaily() and "ui/background/back_zrbt.png" or "ui/background/back_zrhy.png")
    end
	-- self._sacrificeContent = {
	-- [1] = {"_sacrificeContent1_1", "_sacrificeContent1_2"},
	-- [2] = {"_sacrificeContent2_1", "_sacrificeContent2_2"},
	-- [3] = {"_sacrificeContent3_1", "_sacrificeContent3_2"},
--}
end

function LegionSacrificeLayer:onLayerEnter( ... )
	
	if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then 
		G_GlobalFunc.showDayEffect(G_Path.DAY_NIGHT_EFFECT.KNIGHT_ARRAY, self:getWidgetByName("Image_back"))
	end

	self:showTextWithLabel("Label_tip", G_lang:get("LANG_LEGION_SACRIFICE_TIP"))
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_WORSHIP, self._onRefreshCorpWorship, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_CONTRIBUTE, self._onReceiveSacrificeResult, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_CONTRIBUTE_AWARD, self._onReceiveContributionAward, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_CORP_MEMBERLIST, self._onMemberInfoUpdate, self)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DISMISS_CORP, function ( ... )
        G_HandlersManager.legionHandler:disposeCorpDismiss(1)
    end, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NOTIFY_CORP_DISMISS, function ( obj, dismiss )
        G_HandlersManager.legionHandler:disposeCorpDismiss(dismiss)
    end, self)

    self:callAfterFrameCount(2, function ( ... )
    	local panel = self:getWidgetByName("Panel_knight_pic")
		if panel then 
			self._originKnightPos = ccp(panel:getPosition()) 
		end
		local name = self:getWidgetByName("Image_nane_back")
		if name then
			self._originNamePos = ccp(name:getPosition())
		end
		local widget = self:getWidgetByName("Button_tongyi")
		if widget then 
			self._originOkPos = ccp(widget:getPosition())
		end
		widget = self:getWidgetByName("Label_sure_tip")
		if widget then 
			self._originTipPos = ccp(widget:getPosition())
		end

		self:_generateSacrificeRetList()
    	local memCount = G_Me.legionData:getCorpMemberLength()
		if memCount > 0 then 
   			self:_startSacrificeShow(true)
   		end
	end)

	local textPanel = self:getWidgetByName("Image_text_border")
	if textPanel then 
		textPanel:setScale(0)
	end
end

function LegionSacrificeLayer:onLayerExit( ... )
	self:_doRemoveSacrificeShow()
	self:_removeTimer()
end

function LegionSacrificeLayer:_initRichText( ... )
	self:showWidgetByName("Label_text_tip", false)
	local label = self:getLabelByName("Label_text_tip")
	local size = label:getSize()
    local parent = label:getParent()
	local label1 = CCSRichText:create(size.width, size.height)
    label1:setFontName(label:getFontName())
    label1:setFontSize(label:getFontSize())
    label1:setShowTextFromTop(true)
    label1:setPosition(ccp(label:getPosition()))

    parent:addChild(label1, 5)
    
    self._richText = label1
end

function LegionSacrificeLayer:_doRemoveSacrificeShow( ... )
	if self._sacrificeShowEffect then 
		self._sacrificeShowEffect:removeFromParentAndCleanup(true)
		self._sacrificeShowEffect = nil
	end
end

function LegionSacrificeLayer:_onBackClick( ... )
    if CCDirector:sharedDirector():getSceneCount() > 1 then 
		uf_sceneManager:popScene()
	else
		uf_sceneManager:replaceScene(require("app.scenes.legion.LegionScene").new())
	end
end

function LegionSacrificeLayer:_onHelpClick( ... )
	require("app.scenes.common.CommonHelpLayer").show({{title=G_lang:get("LANG_LEGION_HELP_SACRIFICETITLE"), content=G_lang:get("LANG_LEGION_HELP_SACRIFICE")},})
	--require("app.scenes.legion.LegionHelpLayer").show(G_lang:get("LANG_LEGION_HELP_SACRIFICETITLE"), G_lang:get("LANG_LEGION_HELP_SACRIFICE"))
end

function LegionSacrificeLayer:_onOkClick( ... )
	if not G_HandlersManager.legionHandler:checkCorpDispose() then 
		return 
	end

	if self._curSelectSacrificeIndex < 1 then 
		return __LogError("[LegionSacrificeLayer:_onOkClick] wrong select sacrifice index:%d", self._curSelectSacrificeIndex)
	end

	local textPanel = self:getWidgetByName("Image_text_border")
	if textPanel then 
		textPanel:setScale(0)
	end
	self:_onSacrificeClick(self._curSelectSacrificeIndex)
end

function LegionSacrificeLayer:_cancelSacrificeCheck( ... )
	self:showWidgetByName("Panel_knight_pic", false)
	--self:showWidgetByName("Image_nane_back", false)
end


function LegionSacrificeLayer:_onLevelUpClick( ... )
	local layer = require("app.scenes.legion.LegionLevelUpLayer").create()
	uf_sceneManager:getCurScene():addChild(layer)
end

function LegionSacrificeLayer:_onSacrificeCheck( index, isClickBtn )
	if type(index) ~= "number" then 
		return 
	end
	local sacrificeData = G_Me.legionData:getWorshipData()
	local sacrificeId = sacrificeData and sacrificeData.worship_id or 0

	if sacrificeId > 0 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_SACRIFICE_OVERTIMES"))
	end
	if self._curSelectSacrificeIndex == index then 
		return 
	end
	if index == 3 and G_Me.userData.vip < 2 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_SACRIFICE_VIP_2"))
	end

	self._curSelectSacrificeIndex = index
	self:_stopSacrificeShow()

	if isClickBtn then
		self:setCheckStatus(1, self._curSelectSacrificeIndex == 1 and "CheckBox_left" or
		 (self._curSelectSacrificeIndex == 2 and "CheckBox_middle" or "CheckBox_right"))
	end

	local resId = (index == 1) and 14045 or ((index == 2) and 12026 or 13034)
	local nameId = (index == 1) and "LANG_LEGION_SACRIFICE_NAME_LEFT" or 
	((index == 2) and "LANG_LEGION_SACRIFICE_NAME_MIDDLE" or "LANG_LEGION_SACRIFICE_NAME_RIGHT")
	local clr = (index == 1) and Colors.qualityColors[2] or 
	((index == 2) and Colors.qualityColors[3] or Colors.qualityColors[4])
	local tipId = (index == 1) and "LANG_LEGION_SACRIFICE_TIP_LEFT" or 
	((index == 2) and "LANG_LEGION_SACRIFICE_TIP_MIDDLE" or "LANG_LEGION_SACRIFICE_TIP_RIGHT")
	local panel = self:getWidgetByName("Panel_knight_pic")
	if panel then
		panel:removeAllChildren()
		--local pic = knightPic.createKnightPic(resId, panel, nil, true)
		local pic = knightPic.createKnightButton(resId, panel, "knight_res", self, function ( ... )
			self:_onKnightResClick()
		end, true)
	end
	local nameLabel = self:getLabelByName("Label_knight_desc")
	if nameLabel then 
		nameLabel:setColor(clr)
		nameLabel:setText(G_lang:get(nameId))
	end
	local textPanel = self:getWidgetByName("Image_text_border")
	if textPanel then 
		textPanel:setScale(0)
	end
	-- if textPanel then 
	-- 	textPanel:setScale(0)
	-- 	textPanel:runAction(CCScaleTo:create(0.2, 1))
	-- end

	--self:showTextWithLabel("Label_text_tip", G_lang:get(tipId))
	self:showWidgetByName("Panel_knight_pic", true)
	self:showWidgetByName("Image_nane_back", true)

	local labelTip = self:getWidgetByName("Label_sure_tip")
	if labelTip then 
		labelTip:setVisible(true)
		labelTip:stopAllActions()
		labelTip:setPositionXY(self._originTipPos.x, self._originTipPos.y)
	end
	local btnTongyi = self:getWidgetByName("Button_tongyi")
	if btnTongyi then 
		btnTongyi:setVisible(true)
		btnTongyi:stopAllActions()
		btnTongyi:setPositionXY(self._originOkPos.x, self._originOkPos.y)
	end
	if self._shakeEffect then 
		self._shakeEffect:stop()
		self._shakeEffect = nil
	end
	GlobalFunc.flyIntoScreenLR({btnTongyi, labelTip }, false, 0.2, 3, 0, function ( ... )
		--if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then 
			self._shakeEffect = EffectSingleMoving.run(btnTongyi, "smoving_shake", nil, {}, 1+ math.floor(math.random()*30))
		--end
	end)

	self:_doRemoveSacrificeShow()

	self:_showKnight( panel, self._curSelectSacrificeIndex, self:getWidgetByName("Image_nane_back"), function ( ... )
		self:_switchContent(G_lang:get(tipId))
		end)
end

function LegionSacrificeLayer:_removeTimer( ... )
	if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end
end

function LegionSacrificeLayer:_stopSacrificeShow( ... )
	self:_removeTimer()
	self:_doRemoveSacrificeShow()
	local panel = self:getWidgetByName("Panel_knight_pic")
	if panel then 
		panel:removeAllChildren()
		panel:setPositionXY(self._originKnightPos.x, self._originKnightPos.y)
	end
	local name = self:getWidgetByName("Image_nane_back")
	if name then 
		name:setPositionXY(self._originNamePos.x , self._originNamePos.y)
	end

	self:showWidgetByName("Panel_knight_pic", false)
	self:showWidgetByName("Image_nane_back", false)
end

function LegionSacrificeLayer:_onTimerReach( func )
	local textPanel = self:getWidgetByName("Image_text_border")
	local content = self._sacrificeContent[self._sacrificeShowId] or {}
	if not content or #content < 1 or self._sacrificePlayIndex > #content then 
		self:_removeTimer()
		if func then 
			func()
		end
		return 
	end

	if self._sacrificePlayIndex <= #content then
		self:_switchContent(content[self._sacrificePlayIndex] or "Default content!")	
	end
	
	if #content > 1 or #self._sacrificeContentIndex > 1 then 
		self:_removeTimer()
		self._timer = G_GlobalFunc.addTimer(4, function()
		 	if self._sacrificePlayIndex >= #content then 
				if textPanel then 
					textPanel:setScale(0)
				end
				self:_removeTimer()
				if func then 
					func()
				end
			else
				self._sacrificePlayIndex = self._sacrificePlayIndex + 1
				self:_switchContent(content[self._sacrificePlayIndex] or "Default content!")
			end
		end)
	end
end

function LegionSacrificeLayer:_onKnightResClick( ... )
	self._sacrificePlayIndex = self._sacrificePlayIndex + 1
	self:_onTimerReach(function ( ... )
		self:_startSacrificeShow()
	end)
end

function LegionSacrificeLayer:_switchContent( text )
	if self._richText then 
		self._richText:clearRichElement()
    	self._richText:appendContent(text, Colors.lightColors.DESCRIPTION)
    	self._richText:reloadData()
	end
	--self:showTextWithLabel("Label_text_tip", text or "Default content!")
	local textPanel = self:getWidgetByName("Image_text_border")
	if textPanel then 
		textPanel:setScale(0)
		textPanel:runAction(CCScaleTo:create(0.2, 1))
	end
end

function LegionSacrificeLayer:_showKnight( panel, showId, name, func, static )
	if not panel or type(showId) ~= "number" then 
		return 
	end

	panel:removeAllChildren()
	panel:setPositionXY(self._originKnightPos.x, self._originKnightPos.y)
	name:setPositionXY(self._originNamePos.x , self._originNamePos.y)

	local resId = (showId == 1) and 14045 or ((showId == 2) and 12026 or 13034)
	local nameId = (showId == 1) and "LANG_LEGION_SACRIFICE_NAME_LEFT" or 
	((showId == 2) and "LANG_LEGION_SACRIFICE_NAME_MIDDLE" or "LANG_LEGION_SACRIFICE_NAME_RIGHT")
	local clr = (showId == 1) and Colors.qualityColors[2] or 
	((showId == 2) and Colors.qualityColors[3] or Colors.qualityColors[4])

	local nameLabel = self:getLabelByName("Label_knight_desc")
	if nameLabel then 
		nameLabel:setColor(clr)
		nameLabel:setText(G_lang:get(nameId))
	end

	--local pic = knightPic.createKnightPic(resId, panel, nil, true)
	local pic = knightPic.createKnightButton(resId, panel, "knight_res", self, function ( ... )
			self:_onKnightResClick()
		end, true)
	if not static then
		local posx, posy = panel:getPosition()
		GlobalFunc.flyIntoScreenLR({panel, name}, true, 0.2, 5, 50, function ( ... )
	 		if func then 
	 			func()
	 		end
		end)
	end
end

function LegionSacrificeLayer:_hideKnight( panel, name, func )
		GlobalFunc.flyOutScreenLR({panel, name}, true, 1.0, 5, 50, function ( ... )
			if func then 
				func()
			end
		end)
	end	

function LegionSacrificeLayer:_startSacrificeShow( fromStart )
	local panel = self:getWidgetByName("Panel_knight_pic")
	if not panel then 
		return 
	end
	local name = self:getWidgetByName("Image_nane_back")
	if #self._sacrificeContentIndex < 1 then 
		self._sacrificeShowId = 3
		self:_showKnight( panel, self._sacrificeShowId, name, function ( ... )
			self:_switchContent(G_lang:get("LANG_LEGION_SACRIFICE_NO_SACRIFICE_MEMBER"))
		end)
		self:showWidgetByName("Image_nane_back", true)
		self:showWidgetByName("Panel_knight_pic", true)
		return 
	end	

	if not self._sacrificeContentIndex or #self._sacrificeContentIndex < 1 then 
		self._sacrificeShowId = 1 
	else
		self._sacrificeShowIndex = (self._sacrificeShowIndex - 1)
		if self._sacrificeShowIndex < 1 then 
			self._sacrificeShowIndex = self._sacrificeShowIndex + #self._sacrificeContentIndex
		end
		--self._sacrificeShowIndex = self._sacrificeShowIndex%(#self._sacrificeContentIndex) + 1
		self._sacrificeShowId = self._sacrificeContentIndex[self._sacrificeShowIndex] or 1
	end
	
	--__Log("_sacrificeShowIndex:%d, _sacrificeShowId:%d", self._sacrificeShowIndex, self._sacrificeShowId)
	if fromStart then 
		self._sacrificeShowIndex = #self._sacrificeContentIndex
		if not self._sacrificeContentIndex or #self._sacrificeContentIndex < 1 then
			self._sacrificeShowId = 1
		else
			self._sacrificeShowId = self._sacrificeContentIndex[self._sacrificeShowIndex] or 1
		end
		self:showWidgetByName("Image_nane_back", true)
		self:showWidgetByName("Panel_knight_pic", true)
	end

	local textPanel = self:getWidgetByName("Image_text_border")
	
	local _playSacrificeContent = function ( func )
		local content = self._sacrificeContent[self._sacrificeShowId]
		if not content or #content < 1 then 
			return false
		end

		self._sacrificePlayIndex = 1
		--self:_switchContent(content[self._sacrificePlayIndex] or "Default content!")
		self:_onTimerReach(func)
		-- if #content > 1 or #self._sacrificeContentIndex > 1 then 
		-- 	self._timer = G_GlobalFunc.addTimer(4, function()
		-- 		if self._sacrificePlayIndex >= #content then 
		-- 			if textPanel then 
		-- 				textPanel:setScale(0)
		-- 			end
		-- 			self:_removeTimer()
		-- 			if func then 
		-- 				func()
		-- 			end
		-- 		else
		-- 			self._sacrificePlayIndex = self._sacrificePlayIndex + 1
		-- 			self:_switchContent(content[self._sacrificePlayIndex] or "Default content!")
		-- 		end
		-- 	end)
		-- end

		return true
	end

	if fromStart or #self._sacrificeContentIndex > 1 then 
		self:_showKnight( panel, self._sacrificeShowId, name, function ( ... )
			local ret = _playSacrificeContent(function ( ... )
				self:_startSacrificeShow()
			end)
		end)
	else
		local ret = _playSacrificeContent(function ( ... )
			self:_startSacrificeShow()
		end)
	end
end

function LegionSacrificeLayer:_playSacrificeShow( func )
	self:_doRemoveSacrificeShow()
	
	self._sacrificeShowEffect = EffectNode.new("effect_jitian",function ( event )
		if event == "finish" then 
			if func then 
				func()
			end
		elseif event == "hit" then
			local hitEffect = nil
			hitEffect = EffectNode.new("effect_jitian_hit", function ( event )
				if event == "finish" then 
					self:_onRefreshCorpWorship()
					hitEffect:removeFromParentAndCleanup(true)
					hitEffect = nil
				end
			end)
			local progressBar = self:getWidgetByName("ProgressBar_progress_sacrifice")
			if progressBar then 
				progressBar:addNode(hitEffect)
				hitEffect:play()
			end
		end
		end, nil, nil, function (sprite, png, key) 
        if string.find(key, "var_card_") == 1  then
            if sprite == nil then
            	local resId = (self._curSelectSacrificeIndex == 1) and 14045 or 
				((self._curSelectSacrificeIndex == 2) and 12026 or 13034)
                local KnightPic = require("app.scenes.common.KnightPic")
                local knight = KnightPic.createKnightNode(resId, "testknight" .. resId )
                return true, knight
            else
                return true, sprite     
            end
           
        end
        return false
    end)
    
    local panel = self:getWidgetByName("Image_back")
    if panel then 
    	panel:addNode(self._sacrificeShowEffect)
    	--self._sacrificeShowEffect:setPositionXY(0, -20)
   		self._sacrificeShowEffect:play()
   	end
end

function LegionSacrificeLayer:_onSacrificeClick( index )
	-- if 1 then 
	-- 	local sacrificeData = G_Me.legionData:getWorshipData()
	-- 	sacrificeData.worship_point = sacrificeData.worship_point + 30
	-- 	__Log("worship_point:%d -> %d", sacrificeData.worship_point - 30, sacrificeData.worship_point)
	-- 	self:_onRefreshCorpWorship()
	-- 	return 
	-- end
	if self._sacrificeId > 0 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_SACRIFICE_OVERTIMES"))
	end

	if type(index) ~= "number" or index < 1 or index > 3 then 
		return
	end

	if index == 3 and G_Me.userData.vip < 2 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_SACRIFICE_VIP_2"))
	end

	local corpsInfo = corps_worship_info.get(index)
	if not corpsInfo then 
		__LogError("wrong corps_worship_info for index:%d ", index)
		return 
	end

	if corpsInfo.price_type == 1 and G_Me.userData.money < corpsInfo.price then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_SACRIFICE_LACK_OF_MONEY"))
	elseif corpsInfo.price_type == 2 and G_Me.userData.gold < corpsInfo.price then 
		return require("app.scenes.shop.GoldNotEnoughDialog").show()
		--return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_SACRIFICE_LACK_OF_GOLD"))
	end

	if not G_Me.legionData:haveWorshipCount() then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_SACRIFICE_LACK_OF_COUNT", {maxCount=G_Me.legionData:getMaxMemberCount()}))
	end

	self:showWidgetByName("Button_tongyi", false)
	self._isSacrificeFlag = true
	G_HandlersManager.legionHandler:sendGetCorpContribute(index)
end

function LegionSacrificeLayer:_onReceiveSacrificeResult( ret, index, worship_crit, worship_exp, corp_point )
	self:showWidgetByName("Button_tongyi", ret ~= 1)
	self:showWidgetByName("Label_sure_tip", ret ~= 1)
	self._isSacrificeFlag = false
	if ret ~= 1 then 
		return 
	end

	local soundConst = require("app.const.SoundConst")
    G_SoundManager:playSound(soundConst.GameSound.KNIGHT_SPECIAL)

	self:showWidgetByName("Image_sacrifice_tip", true)
	GlobalFunc.flyDown({self:getWidgetByName("Image_sacrifice_tip")}, 0.2, 0, 3, function ( ... ) 
		end)

	self:_cancelSacrificeCheck()
	self:_playSacrificeShow(function ( ... )
		self:_updateCorpDetail()

		if worship_crit then 
			local baojiEffect = nil
			baojiEffect = EffectNode.new("effect_baoji", 
                        function(event, frameIndex)
                            if event == "finish" then
                                if baojiEffect then 
                                	baojiEffect:removeFromParentAndCleanup(true)
                                  	baojiEffect = nil
                                end
                            end
                        end,
                        nil,
                        nil,
                        function (sprite, png, key) 
                            return true, CCSprite:create(G_Path.getTextPath("zbyc_baoji.png"))
                        end
                    )
                    baojiEffect:play()

                    local widget = self:getWidgetByName("Image_back")
                    if widget then 
                    	widget:addNode(baojiEffect, 3)
	                    baojiEffect:setPositionXY(0, 100)
                    end
		end

		G_flyAttribute.addNormalText(G_lang:get("LANG_LEGION_SACRIFICE_RESULT_OK"))
		
		local corpsInfo = corps_worship_info.get(index or 0)
		if corpsInfo then 
			local _, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
			local knightInfo = knight_info.get(baseId)
			self:_switchContent(G_lang:get("LANG_LEGION_SACRIFICE_RET_FORMAT", 
				{memberName=G_Me.userData.name,
				qualityClr=Colors.getDecimalQuality(knightInfo and knightInfo.quality or 1),
				 sacrificeName=corpsInfo.name,
				 expValue=corpsInfo.worship_value, 
				 contriExp=worship_exp and worship_exp or corpsInfo.corps_exp}))

			G_flyAttribute.addNormalText(G_lang:get("LANG_LEGION_SACRIFICE_PROGRESS_OFFSET", {value = corpsInfo.worship_value}), Colors.titleGreen)
			G_flyAttribute.addNormalText(G_lang:get("LANG_LEGION_SACRIFICE_EXP_OFFSET", {value= worship_exp and worship_exp or corpsInfo.corps_exp}), Colors.titleGreen)
			G_flyAttribute.addNormalText(G_lang:get("LANG_LEGION_SACRIFICE_CONTRIBUTION_OFFSET", {value = corp_point and corp_point or corpsInfo.corps_integral}), Colors.titleGreen)
		end

		self:callAfterDelayTime(4, nil, function ( ... )
			self:_doRemoveSacrificeShow()
			self:_onMemberInfoUpdate() 
			--self:showWidgetByName("Panel_knight_pic", false)
			self:showWidgetByName("Image_sacrifice_tip", false)
		end)

		G_flyAttribute.play(function ( ... )
			end)
	end)
end

function LegionSacrificeLayer:_generateSacrificeRetList( ... )
	local memCount = G_Me.legionData:getCorpMemberLength()
	if memCount < 1 then 
		return G_HandlersManager.legionHandler:sendGetCorpMember()
	end

	self._sacrificeContent = {}
	self._sacrificeContentIndex = {}
	for loopi = 1, memCount do 
		local memInfo = G_Me.legionData:getCorpMemberByIndex(loopi)
		if memInfo and memInfo.worship_id > 0 then 
			local knightInfo = knight_info.get(memInfo.main_role)
			local corpsInfo = corps_worship_info.get(memInfo.worship_id or 0)
			local sacrificeText = G_lang:get("LANG_LEGION_SACRIFICE_RET_FORMAT", 
				{memberName=memInfo.name,
				qualityClr=Colors.getDecimalQuality(knightInfo and knightInfo.quality or 1),
				 sacrificeName=corpsInfo.name,
				 expValue = corpsInfo and corpsInfo.worship_value or 0, 
				 contriExp = memInfo.worship_point and memInfo.worship_point or corpsInfo.corps_exp})
			if not self._sacrificeContent[memInfo.worship_id] then 
				self._sacrificeContent[memInfo.worship_id] = {}
			end

			table.insert(self._sacrificeContent[memInfo.worship_id], #self._sacrificeContent[memInfo.worship_id] + 1, sacrificeText)
		end
	end

	for key, value in pairs(self._sacrificeContent) do 
		table.insert(self._sacrificeContentIndex, #self._sacrificeContentIndex + 1, key)
	end

end

function LegionSacrificeLayer:_onAwardBoxClick( index )
	if type(index) ~= "number" or index < 1 or index > 4 then 
		return 
	end

	local widget = self:getWidgetByName("Button_box_"..index)
	if widget then 
		local posx, posy = widget:convertToWorldSpaceXY(0, 0)
		require("app.scenes.legion.LegionSacrificeBoxLayer").show(self._sacrificeLevel, index, ccp(posx, posy))
	else
	--self:_onReceiveSacrificeResult(1, 1, 20, 50, 30)
		require("app.scenes.legion.LegionSacrificeBoxLayer").show(self._sacrificeLevel, index)
	end
	-- if self._curAwardIndex >= index and not self._aquireAwardIds[index] then 
	-- 	return G_HandlersManager.legionHandler:sendGetCorpContributeAward(index)
	-- end

	-- if self._curAwardIndex + 1 == index then 
	-- 	if not self._defaultAwardTip then 
	-- 		self._defaultAwardTip = self:_createAwardInfoBox(self._curAwardIndex + 1, self._sacrificeLevel)
	-- 	end

	-- 	if self._defaultAwardTip then 
	-- 		self._defaultAwardTip:playQiPao(true)
	-- 	end
	-- else
	-- 	local awardInfoBox = nil
	-- 	awardInfoBox = self:_createAwardInfoBox(index, self._sacrificeLevel, nil, function ( ... )
	-- 		if awardInfoBox then 
	-- 			awardInfoBox:removeFromParentAndCleanup(true)
	-- 		end	
	-- 	end)
	-- 	awardInfoBox:playQiPao(false)
	-- end
end

function LegionSacrificeLayer:_onReceiveContributionAward( ret, index, awards )
	if type(awards) == "table" then
		local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awards, function ( ... )
    	end)
    	self:addChild(_layer)
	end
end

function LegionSacrificeLayer:_onMemberInfoUpdate( ... )
	self:_generateSacrificeRetList()
	self:_stopSacrificeShow()
	self:_startSacrificeShow(true)
end

function LegionSacrificeLayer:_initSacrificeAward( ... )
	for loopi = 1, 3, 1 do 
		local corpsInfo = corps_worship_info.get(loopi)
		self:showTextWithLabel("Label_content_"..loopi.."_3", 
		  G_lang:get("LANG_LEGION_SACRIFICE_CONTRIBUTION_OFFSET", {value = corpsInfo and corpsInfo.corps_integral or 0}))
		  self:showTextWithLabel("Label_content_"..loopi.."_1", 
		  G_lang:get("LANG_LEGION_SACRIFICE_PROGRESS_OFFSET", {value = corpsInfo and corpsInfo.worship_value or 0}))	
		  self:showTextWithLabel("Label_content_"..loopi.."_2", 
		  G_lang:get("LANG_LEGION_SACRIFICE_EXP_OFFSET", {value = corpsInfo and corpsInfo.corps_exp or 0}))	

		self:showTextWithLabel("Label_price_"..loopi, corpsInfo and corpsInfo.price or 0)
		local moneyType = 1 
		if corpsInfo then 
			moneyType = corpsInfo.price_type
		end

		local img = self:getImageViewByName("Image_price_"..loopi)
		if img then 
			img:loadTexture(moneyType == 1 and "icon_mini_yingzi.png" or "icon_mini_yuanbao.png", UI_TEX_TYPE_PLIST)
		end
	end

	self:showWidgetByName("Label_content_3_4", G_Me.userData.vip < 2)
	self:showWidgetByName("Image_price_3", G_Me.userData.vip >= 2)
	self:showWidgetByName("Label_price_3", G_Me.userData.vip >= 2)
	local progressBar = self:getLoadingBarByName("ProgressBar_progress_sacrifice")
	if progressBar then 
		progressBar:setPercent(0)
	end	

	self:_updateSacrificeBtns()
end

function LegionSacrificeLayer:_updateSacrificeBtns( ... )
	-- self:showWidgetByName("Button_get_1", self._canSacrifice)
	-- self:showWidgetByName("Button_get_2", self._canSacrifice)
	-- self:showWidgetByName("Button_get_3", self._canSacrifice)
	--self:enableWidgetByName("CheckBox_left", self._sacrificeId < 1)
	--self:enableWidgetByName("CheckBox_middle", self._sacrificeId < 1)
	--self:enableWidgetByName("CheckBox_right", (self._sacrificeId < 1) and (G_Me.userData.vip >= 2) )
	local sacrificeData = G_Me.legionData:getWorshipData()
	local sacrificeId = sacrificeData and sacrificeData.worship_id or 0

	self:showWidgetByName("Image_tip_middle", sacrificeId == 2)
	self:showWidgetByName("Image_tip_left", sacrificeId == 1)
	self:showWidgetByName("Image_tip_right", sacrificeId == 3)
	self:showWidgetByName("CheckBox_left", sacrificeId < 1)
	self:showWidgetByName("CheckBox_middle", sacrificeId < 1)
	self:showWidgetByName("CheckBox_right", sacrificeId < 1)

	if sacrificeId > 0 then 
		self:showWidgetByName("Image_price_"..sacrificeId, false)
		self:showWidgetByName("Label_price_"..sacrificeId, false)
	end
end

function LegionSacrificeLayer:_updateCorpDetail( ... )
	local detailCorp = G_Me.legionData:getCorpDetail() or {}

	self:showTextWithLabel("Label_level", detailCorp.level or 1)
	self:showTextWithLabel("Label_name", detailCorp.name or "")
	self:showTextWithLabel("Label_gongxian_value", G_Me.userData.corp_point or 0)
	--self:showTextWithLabel("Label_gongxian", G_lang:get("LANG_LEGION_CORP_CONTRIBUTION", {contribution=G_Me.userData.corp_point or 0}) )
	self:showTextWithLabel("Label_notice_content", detailCorp.notification or "")
	local maxExp = 0
	local curExp = 0
	if detailCorp then 
		local corpsInfo = corps_info.get(detailCorp.level)
		maxExp = corpsInfo and corpsInfo.exp or 0
        curExp = detailCorp.exp
	end
	self:showTextWithLabel("Label_progress", curExp.."/"..maxExp)
	local progressBar = self:getLoadingBarByName("ProgressBar_progrss")
	if progressBar then 
		-- progressBar:runToPercent(maxExp > 0 and (curExp*100)/maxExp or 0, 0.2)
		local percent = curExp > maxExp and maxExp or curExp
		local percent = maxExp > 0 and (percent*100)/maxExp or 0
		progressBar:runToPercent(percent, 0.2)
	end	

	local info = corps_info.get(G_Me.legionData:getCorpDetail().level)
	local state1 = info.exp <= G_Me.legionData:getCorpDetail().exp
	local state2 = (corps_info.get(G_Me.legionData:getCorpDetail().level+1) ~= nil)
	local state3 = G_Me.legionData:getCorpDetail().position > 0
	self:getButtonByName("Button_levelUp"):setVisible(state1 and state2 and state3)
	if state1 and state2 and not self._tEff1 then
	    self._tEff1 = EffectNode.new("effect_jtzc_dengji", function(event, frameIndex) end)
	    self._tEff1:setScale(1)
	    self._tEff1:setPositionXY(0,0)
	    self:getImageViewByName("Image_24"):addNode(self._tEff1, 1)
	    self._tEff1:play()
	    self._tEff2 = EffectNode.new("effect_jtzc_loading", function(event, frameIndex) end)
	    self._tEff2:setScale(1)
	    self._tEff2:setPositionXY(5,-5)
	    self:getImageViewByName("Image_progress_back"):addNode(self._tEff2, 0)
	    self._tEff2:play()
	end
	if self._tEff1 and not (state1 and state2) then 
		self._tEff1:stop()
		self._tEff1:removeFromParentAndCleanUp(true)
		self._tEff1 = nil
		self._tEff2:stop()
		self._tEff2:removeFromParentAndCleanUp(true)
		self._tEff2 = nil
	end
end

function LegionSacrificeLayer:_createAwardInfoBox( awardIndex, awardLevel, awardInfoBox, fun )
	if type(awardIndex) ~= "number" or type(awardLevel) ~= "number" then 
		return nil 
	end

	local corpsAwardInfo = corps_info.get(awardLevel)
	local awardType = 0
	local awardId = 0
	local awardCount = 0
	local text = nil
	if corpsAwardInfo then 
		awardType = corpsAwardInfo["item_type_"..awardIndex]
		awardId = corpsAwardInfo["item_id_"..awardIndex]
		awardCount = corpsAwardInfo["item_size_"..awardIndex]

		local goodInfo = G_Goods.convert(awardType, awardId, awardCount)
		if goodInfo then 
			text = goodInfo.name.."x"..goodInfo.size
		end
	end

	local awardBox = self:getWidgetByName("Button_box_"..awardIndex)
	if awardBox then 
		if awardInfoBox then 
			local posx, posy = awardBox:getPosition()
			local awardSize = awardBox:getContentSize()
			awardInfoBox:setText(text)
			awardInfoBox:setPositionXY(posx - 0.26 * awardSize.width, posy + awardSize.height/2)
			return awardInfoBox
		else
			return require("app.scenes.sanguozhi.SanguozhiQiPao").add(text, awardBox, 0, fun)
		end		
	else
		return nil
	end
end

function LegionSacrificeLayer:_onRefreshCorpWorship( ... )
	self:_updateSacrificeBtns()

	if self._isSacrificeFlag then 
		return 
	end

	local oldLevel = self._sacrificeLevel 
	local sacrificeData = G_Me.legionData:getWorshipData()
	if not sacrificeData or not sacrificeData.worship_level then 
		self._sacrificeId = 0
		self._sacrificeLevel = 0
	else
		self._sacrificeId = sacrificeData.worship_id or 0
		self._sacrificeLevel = sacrificeData.worship_level
	end

	local corpsAwardInfo = corps_info.get(self._sacrificeLevel)
	-- show four award box info
	if not corpsAwardInfo then 
		self:showWidgetByName("Label_pro_4", false)
		self:showWidgetByName("Label_pro_2", false)
		self:showWidgetByName("Label_pro_3", false)
		self:showWidgetByName("Label_pro_1", false)
	else
		if (oldLevel ~= self._sacrificeLevel) or oldLevel == 0 then
			self:showWidgetByName("Label_pro_4", true)
			self:showWidgetByName("Label_pro_2", true)
			self:showWidgetByName("Label_pro_3", true)
			self:showWidgetByName("Label_pro_1", true) 

			self:showTextWithLabel("Label_pro_1", corpsAwardInfo.worship_value_1)
			self:showTextWithLabel("Label_pro_2", corpsAwardInfo.worship_value_2)
			self:showTextWithLabel("Label_pro_3", corpsAwardInfo.worship_value_3)
			self:showTextWithLabel("Label_pro_4", corpsAwardInfo.worship_value_4)
			-- self:showTextWithLabel("Label_pro_1", G_lang:get("LANG_LEGION_SACRIFICE_PROGRESS_OFFSET_TOTAL", 
			-- 	{value=corpsAwardInfo.worship_value_1}))
			-- self:showTextWithLabel("Label_pro_2", G_lang:get("LANG_LEGION_SACRIFICE_PROGRESS_OFFSET_TOTAL", 
			-- 	{value=corpsAwardInfo.worship_value_2}))
			-- self:showTextWithLabel("Label_pro_3", G_lang:get("LANG_LEGION_SACRIFICE_PROGRESS_OFFSET_TOTAL", 
			-- 	{value=corpsAwardInfo.worship_value_3}))
			-- self:showTextWithLabel("Label_pro_4", G_lang:get("LANG_LEGION_SACRIFICE_PROGRESS_OFFSET_TOTAL", 
			-- 	{value=corpsAwardInfo.worship_value_4}))
		end
	end
	
	local curWorshipPoints = sacrificeData and sacrificeData.worship_point or 0
	local maxAwardPoints = corpsAwardInfo and corpsAwardInfo.worship_value_4 or 0
	local progressBar = self:getLoadingBarByName("ProgressBar_progress_sacrifice")
	if progressBar then 
		--local progress = maxAwardPoints ~= 0 and (curWorshipPoints*100/maxAwardPoints) or 0
		local progress = self:_calcCurExpProgress(curWorshipPoints)
		progressBar:runToPercent(progress > 100 and 100 or progress, 2)
	end

	self:showTextWithLabel("Label_progress_value", curWorshipPoints)

	local maxSacrificeCount = G_Me.legionData:getMaxMemberCount()
	self:showTextWithLabel("Label_progress_count_value", 
		(maxSacrificeCount - (sacrificeData.worship_count or 0)).."/"..maxSacrificeCount)
	-- calc award box stats
	local curAwardIndex = 0

	if corpsAwardInfo then
		for loopi = 1, 4, 1 do 
			if corpsAwardInfo["worship_value_"..loopi] <= curWorshipPoints then 
				curAwardIndex = loopi
			end
		end
	end

	local oldAwardIndex = self._curAwardIndex
	-- show default award tip
	self._curAwardIndex = curAwardIndex
	-- if curAwardIndex < 4 and self._sacrificeLevel > 0 then 
	-- 	if oldAwardIndex ~= self._curAwardIndex and self._defaultAwardTip then 
	-- 		self._defaultAwardTip:removeFromParentAndCleanup(true)
	-- 		self._defaultAwardTip = nil
	-- 	end
	-- 	self._defaultAwardTip = self:_createAwardInfoBox(self._curAwardIndex + 1, self._sacrificeLevel, self._defaultAwardTip)
	-- else
	-- 	--self._curAwardIndex = 0
	-- 	if self._defaultAwardTip then 
	-- 		self._defaultAwardTip:setVisible(false)
	-- 	end
	-- end

	-- calc award get status
	self._aquireAwardIds = {}
	if sacrificeData and type(sacrificeData.worship_award) == "table" then 
		--self._aquireAwardIds[1] = sacrificeData.worship_award[1]
		--self._aquireAwardIds[2] = sacrificeData.worship_award[2]
		--self._aquireAwardIds[3] = sacrificeData.worship_award[3]
		--self._aquireAwardIds[4] = sacrificeData.worship_award[4]
		for key, value in pairs(sacrificeData.worship_award) do
			if type(value) == "number"  then 
				self._aquireAwardIds[value] = true
			end
		end
	end

	local _awardBoxRes = {
	[1] = {"ui/dungeon/baoxiangtong_guan.png", "ui/dungeon/baoxiangtong_kai.png", "ui/dungeon/baoxiangtong_kong.png",},
	[2] = {"ui/dungeon/baoxiangyin_guan.png", "ui/dungeon/baoxiangyin_kai.png", "ui/dungeon/baoxiangyin_kong.png",},
	[3] = {"ui/legion/bx_jutuan_guan.png", "ui/legion/bx_juntuan_kai.png", "ui/legion/bx_juntuan_kong.png",},
	[4] = {"ui/dungeon/baoxiangjin_guan.png", "ui/dungeon/baoxiangjin_kai.png", "ui/dungeon/baoxiangjin_kong.png",},
	}

	for loopi = 1, self._curAwardIndex do 
		local awardBtn = self:getButtonByName("Button_box_"..loopi)
		if awardBtn then 
			local res = self._aquireAwardIds[loopi] and 3 or 2
			awardBtn:loadTextureNormal(_awardBoxRes[loopi][res], UI_TEX_TYPE_LOCAL)

			awardBtn:removeAllNodes()
			if not self._aquireAwardIds[loopi] then
				local boxEffect = EffectNode.new("effect_box_light", function ( event ) end)
				awardBtn:addNode(boxEffect)
				boxEffect:play()
			end
		end
	end
end

function LegionSacrificeLayer:_calcCurExpProgress( curExp )
	if type(curExp) ~= "number" then 
		return 0
	end

	local corpsAwardInfo = corps_info.get(self._sacrificeLevel or 0)
	if not corpsAwardInfo or curExp < 1 then 
		return 0
	end

	local lastAwardIndex = 0
	local lastAwardValue = 0
	local nextAwardValue = 0
	for loopi = 1, 4, 1 do 
		if corpsAwardInfo["worship_value_"..loopi] <= curExp then 
			lastAwardIndex = loopi
			lastAwardValue = corpsAwardInfo["worship_value_"..loopi]
		elseif nextAwardValue < 1 then
			nextAwardValue = corpsAwardInfo["worship_value_"..loopi]
		end
	end
	if nextAwardValue < 1 then 
		nextAwardValue = corpsAwardInfo["worship_value_4"] + 3*(corpsAwardInfo["worship_value_4"] - corpsAwardInfo["worship_value_3"])
	end

	local progress = lastAwardIndex*21
	progress = progress + (curExp - lastAwardValue)*21/(nextAwardValue - lastAwardValue)

	return progress
end

return LegionSacrificeLayer
