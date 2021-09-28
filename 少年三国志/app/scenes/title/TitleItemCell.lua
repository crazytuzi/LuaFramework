-- 单个称号对象
require ("app.cfg.title_info")

local EffectNode = require "app.common.effects.EffectNode"

local TitleItemCell = class("TitleItemCell",function()
    return CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/title_item_cell.json")
end)

function TitleItemCell:ctor( titleInfo, rank, layer, ... )

	-- TODO:放到Colors类中？
	self._darkStrokeColor = ccc3(0x19, 0x00, 0x00)
	self._darkQualityColor = {
		ccc3(0xff, 0xff, 0xff),
		ccc3(0x4c, 0x7f, 0x19),
		ccc3(0x00, 0x6f, 0x7f),
		ccc3(0x7c, 0x29, 0x7f),
		ccc3(0x7f, 0x40, 0x12),
		ccc3(0x7f, 0x14, 0x09),
		ccc3(0x7f, 0x75, 0x00)
	}
	self._normalOpacity = 255
	self._lightOpacity = 100

	self._time = nil
	self._rank = rank
	self._preState = -1
	
	self._titleInfo = titleInfo

	self._titleBtn = UIHelper:seekWidgetByName(self, "Button_Title")
	self._titleBtn = tolua.cast(self._titleBtn, "Button")
	self._titleBtn:loadTextureNormal(self._titleInfo.picture, UI_TEX_TYPE_LOCAL)
	-- self._titleBtn:getVirtualRenderer():setColor(Colors.LightGray)	
	self._titleBtn:setName("Button_Title" .. self._titleInfo.id)
	self._originalTitleBtnPosY = self._titleBtn:getPositionY()

	self._titleNameLabel = UIHelper:seekWidgetByName(self, "Label_Title")
	self._titleNameLabel = tolua.cast(self._titleNameLabel, "Label")
	self._titleNameLabel:setText(self._titleInfo.name)

	self._titleWholeBg = UIHelper:seekWidgetByName(self, "Image_Title")
	self._titleWholeBg = tolua.cast(self._titleWholeBg, "ImageView")
	self._titleWholeBg:setName("Image_Title" .. self._titleInfo.id)

	self._titleDesLabel = UIHelper:seekWidgetByName(self, "Label_Title_Des")
	self._titleDesLabel = tolua.cast(self._titleDesLabel, "Label")
	self._titleDesLabel:setText(self._titleInfo.directions)
	self._titleDesLabel:createStroke(Colors.strokeBrown, 2)

	self._timeLabelBg = UIHelper:seekWidgetByName(self, "Image_Time_Bg")
	self._timeLabelBg = tolua.cast(self._timeLabelBg, "ImageView")

	self._timeLabel = UIHelper:seekWidgetByName(self, "Label_Time")
	self._timeLabel = tolua.cast(self._timeLabel, "Label")

	self._equipedImage = UIHelper:seekWidgetByName(self, "Image_Equiped")
	self._equipedImage = tolua.cast(self._equipedImage, "ImageView")
	self._equipedImage:setName("Image_Equiped" .. self._titleInfo.id)

	self._staticLight = UIHelper:seekWidgetByName(self, "Image_Static_Light")
	self._staticLight = tolua.cast(self._staticLight, "ImageView")

	-- 添加特效
	self._effectLight = EffectNode.new("effect_ch_deng", function ( event, frameIndex )	end)
	self._equipedImage:addNode(self._effectLight, -1)
	self._effectLight:setPosition(ccp(-2, 40))
	self._effectLight:setVisible(false)
	-- self._effectLight:play()

	-- 属性类型名称
	local increaseType1Label = UIHelper:seekWidgetByName(self, "Label_Increase_Type_1")
	increaseType1Label = tolua.cast(increaseType1Label, "Label")
	local typeAIncrease = titleInfo.strength_type_1
	increaseType1Label:setText(G_lang.getGrowthTypeName(typeAIncrease) .. "+")
	increaseType1Label:createStroke(Colors.strokeBrown, 2)

	local increaseType2Label = UIHelper:seekWidgetByName(self, "Label_Increase_Type_2")
	increaseType2Label = tolua.cast(increaseType2Label, "Label")
	local typeBIncrease = titleInfo.strength_type_2
	increaseType2Label:setText(G_lang.getGrowthTypeName(typeBIncrease) .. "+")
	increaseType2Label:createStroke(Colors.strokeBrown, 2)

	-- 属性增加值
	local increaseValue1Label = UIHelper:seekWidgetByName(self, "Label_Increase_Value_1")
	increaseValue1Label = tolua.cast(increaseValue1Label, "Label")
	local valueAIncrease = titleInfo.strength_value_1
	increaseValue1Label:setText(G_lang.getGrowthValue(typeAIncrease, valueAIncrease))
	increaseValue1Label:createStroke(Colors.strokeBrown, 2)

	local increaseValue2Label = UIHelper:seekWidgetByName(self, "Label_Increase_Value_2")
	increaseValue2Label = tolua.cast(increaseValue2Label, "Label")
	local valueBIncrease = titleInfo.strength_value_2
	increaseValue2Label:setText(G_lang.getGrowthValue(typeBIncrease, valueBIncrease))
	increaseValue2Label:createStroke(Colors.strokeBrown, 2)

	-- 去获取按钮
	self._getBtn = UIHelper:seekWidgetByName(self, "Button_Get")
	self._getBtn = tolua.cast(self._getBtn, "Button")
	self._getBtn:setName("Button_Get" .. self._titleInfo.id)

	-- 去激活按钮
	self._activateBtn = UIHelper:seekWidgetByName(self, "Button_Activate")
	self._activateBtn = tolua.cast(self._activateBtn, "Button")	
	self._activateBtn:setName("Button_Activate" .. self._titleInfo.id)
	-- 按钮光环特效
	self._btnEffect = EffectNode.new("effect_around2")     
	self._btnEffect:setScale(1.4) 
	self._activateBtn:addNode(self._btnEffect)
	-- self._btnEffect:play()

	-- 佩戴按钮
	self._equipBtn = UIHelper:seekWidgetByName(self, "Button_Equip")
	self._equipBtn = tolua.cast(self._equipBtn, "Button")
	self._equipBtn:setName("Button_Equip" .. self._titleInfo.id)

	-- 佩戴中的标志图片
	self._equipedImageText = UIHelper:seekWidgetByName(self, "Image_Equiped_Text")
	self._equipedImageText = tolua.cast(self._equipedImageText, "ImageView")

	-- 排行1、2、3称号的特殊处理
	if self._rank and self._rank < 99 then
		self._equipedImage:loadTexture("ui/title/chenghaodizuo_" .. self._rank .. ".png", UI_TEX_TYPE_LOCAL)
		self._titleBtn:setScale(0.7)
		self._rankImage = ImageView:create()
		self._rankImage:loadTexture("ui/title/chenghao_rank_" .. self._rank .. ".png", UI_TEX_TYPE_LOCAL)
		local offsetX = 0
		if self._rank == 1 then
			offsetX = -4
		elseif self._rank == 2 then
			offsetX = 1
		else
			offsetX = 0
		end

		self._rankImage:setPosition(ccp(offsetX, 4))
		self._equipedImage:addChild(self._rankImage, 0)
	end

end

-- @layer  所属layer
-- @state  称号当前状态，0为不可激活，1为可激活，2为已激活，3为佩戴中
-- @time   已激活称号对应的时间戳
function TitleItemCell:updateStatus(layer, state, time, rank )
	-- __Log("state = %d", state)
	self._time = time
	self._layer = layer
	self._state = state
	
	if state == 0 then
		self._titleNameLabel:setColor(self._darkQualityColor[self._titleInfo.quality]) 
		self._titleNameLabel:createStroke(self._darkStrokeColor, 3)
		self._titleBtn:getVirtualRenderer():setColor(Colors.LightGray)

		-- self._titleNameLabel:setColor(Colors.getColor(self._titleInfo.quality))
		-- self._titleNameLabel:createStroke(Colors.strokeBrown, 3)

		self._timeLabelBg:setVisible(false)
		-- self._equipedLabel:setVisible(false)
		self._equipedImage:setVisible(true)
		self._equipedImage:getVirtualRenderer():setColor(Colors.LightGray)
		if self._rankImage then
			self._rankImage:getVirtualRenderer():setColor(Colors.LightGray)
		end

		self._staticLight:setVisible(true)
		self._staticLight:setOpacity(self._lightOpacity)

		self._getBtn:setVisible(true)
		self._activateBtn:setVisible(false)
		self._equipBtn:setVisible(false)
		self._equipedImageText:setVisible(false)

		self._effectLight:setVisible(false)
		self._effectLight:stop()

		self:_updateTitlePosition(false)
	elseif state == 1 then
		self._titleNameLabel:setColor(self._darkQualityColor[self._titleInfo.quality]) 
		self._titleNameLabel:createStroke(self._darkStrokeColor, 3)
		self._titleBtn:getVirtualRenderer():setColor(Colors.LightGray)

		-- self._titleNameLabel:setColor(Colors.getColor(self._titleInfo.quality))
		-- self._titleNameLabel:createStroke(Colors.strokeBrown, 3)

		self._timeLabelBg:setVisible(false)

		self._staticLight:setVisible(true)
		self._staticLight:setOpacity(self._lightOpacity)

		self._equipedImage:getVirtualRenderer():setColor(Colors.LightGray)
		if self._rankImage then
			self._rankImage:getVirtualRenderer():setColor(Colors.LightGray)
		end

		self._getBtn:setVisible(false)
		self._activateBtn:setVisible(true)
		self._equipBtn:setVisible(false)
		self._equipedImageText:setVisible(false)

		self._effectLight:setVisible(false)
		self._effectLight:stop()

		self._btnEffect:play()
		-- if self._preState ~= state then
		-- 	-- 按钮光环特效
		-- 	self._btnEffect = EffectNode.new("effect_around2")     
	 --    	self._btnEffect:setScale(1.4) 
	 --    	self._activateBtn:addNode(self._btnEffect)
	 --    	self._btnEffect:play()
		-- end		

		self:_updateTitlePosition(false)		
	elseif state == 2 then
		self._titleNameLabel:setColor(Colors.getColor(self._titleInfo.quality))
		self._titleNameLabel:createStroke(Colors.strokeBrown, 3)
		self._titleBtn:getVirtualRenderer():setColor(Colors.Noraml)
		if not self._timeLabelBg:isVisible() then
			-- self._timeLabelBg:setVisible(true)
			self._timeLabel:setText("")
		end		

		self._equipedImage:setVisible(true)
		self._equipedImage:getVirtualRenderer():setColor(Colors.Noraml)
		if self._rankImage then
			self._rankImage:getVirtualRenderer():setColor(Colors.Noraml)
		end

		self._staticLight:setVisible(true)
		self._staticLight:setOpacity(self._normalOpacity)

		self._getBtn:setVisible(false)
		self._activateBtn:setVisible(false)
		self._equipBtn:setVisible(true)
		self._equipedImageText:setVisible(false)

		self._effectLight:setVisible(false)
		self._effectLight:stop()

		self:_updateTitlePosition(false)
	elseif state == 3 then
		self._titleNameLabel:setColor(Colors.getColor(self._titleInfo.quality))
		self._titleNameLabel:createStroke(Colors.strokeBrown, 3)
		self._titleBtn:getVirtualRenderer():setColor(Colors.Noraml)
		if not self._timeLabelBg:isVisible() then
			-- self._timeLabelBg:setVisible(true)
			self._timeLabel:setText("")			
		end

		self._equipedImage:setVisible(true)
		self._equipedImage:getVirtualRenderer():setColor(Colors.Noraml)
		if self._rankImage then
			self._rankImage:getVirtualRenderer():setColor(Colors.Noraml)
		end

		self._staticLight:setVisible(false)
		-- self._staticLight:setOpacity(self._normalOpacity)

		self._getBtn:setVisible(false)
		self._activateBtn:setVisible(false)
		self._equipBtn:setVisible(false)
		self._equipedImageText:setVisible(true)

		self._effectLight:setVisible(true)
		self._effectLight:play()

		self:_updateTitlePosition(true)
	end

	layer:registerWidgetClickEvent("Image_Title" .. self._titleInfo.id, function ( ... )
		self:_titleBtnClicked(self._titleInfo.id, state)
	end)

	layer:registerBtnClickEvent("Button_Activate" .. self._titleInfo.id, function ( ... )
		-- 可激活
		local dialog = require("app.scenes.title.TitleDetailDialogActivate").create(self._titleInfo.id)
		uf_sceneManager:getCurScene():addChild(dialog)
	end )

	layer:registerBtnClickEvent("Button_Get" .. self._titleInfo.id, function ( ... )
		-- 去获取
		-- 如果是活动称号
		if self._titleInfo.type1 == 4 then
			G_MovingTip:showMovingTip(G_lang:get("LANG_TITLE_ACTIVITY_DUANWU"))
		elseif self._titleInfo.type1 == 5 then
			local FunctionLevelConst = require("app.const.FunctionLevelConst")
			if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CROSS_PVP) then 
				-- self._scenePack = GlobalFunc.generateScenePack()
				-- require("app.scenes.crosspvp.CrossPVP").launch(self._scenePack)
				G_MovingTip:showMovingTip(G_lang:get("LANG_TITLE_ACTIVITY_DUANWU"))
			end
		else
			self._scenePack = GlobalFunc.generateScenePack()
			uf_sceneManager:replaceScene(require("app.scenes.crosswar.CrossWarScene").new(nil, nil, nil, nil, nil, self._scenePack))
		end
	end )

	layer:registerBtnClickEvent("Button_Equip" .. self._titleInfo.id, function ( ... )
		-- 佩戴
		G_HandlersManager.titleHandler:sendChangeTitle(self._titleInfo.id)
	end )

	self._preState = state

end

-- 称号背景图和名字随着是否佩戴而发生变化
function TitleItemCell:_updateTitlePosition( isUp )

	local currPosY = self._titleBtn:getPositionY()
	local offset = 2
	-- TODO:need refine
	if isUp then
		local moveUp = CCMoveBy:create(0.5, ccp(0, offset))
		local seqAction0 = CCSequence:createWithTwoActions(moveUp, CCCallFunc:create(function ( ... )
			self:_moveUpAndDown()
		end))

		self._titleBtn:runAction(seqAction0)
		
	else
		if currPosY ~= self._originalTitleBtnPosY then
			self._titleBtn:setPositionY(self._originalTitleBtnPosY)
			self._titleBtn:stopAllActions()
		end
	end

end

function TitleItemCell:_moveUpAndDown( ... )
	local time = 1.0
	local offset = 5
	local anime1 = CCMoveBy:create(time,ccp(0,offset))
    local anime2 = CCMoveBy:create(time,ccp(0,-offset))
    local seqAction = CCSequence:createWithTwoActions(anime1, anime2)
    seqAction = CCRepeatForever:create(seqAction)

    self._titleBtn:runAction(seqAction)
end

-- 刷新倒计时
function TitleItemCell:updateTime(  )
	if self then 
		local leftSecond = G_ServerTime:getLeftSeconds(self._time)
		if not self._timeLabelBg:isVisible() then
			self._timeLabelBg:setVisible(true)
			self._timeLabel:createStroke(Colors.strokeBrown, 1)
			local timePreLabel = UIHelper:seekWidgetByName(self, "Label_Time_Des")
			timePreLabel = tolua.cast(timePreLabel, "Label")
			timePreLabel:createStroke(Colors.strokeBrown, 1)
		end
		
		if leftSecond > 0 then
	        local time = G_ServerTime:getLeftSecondsStringWithDays(self._time)
	        local day, hour, minute, second = G_ServerTime:getLeftTimeParts(self._time)
	        if day > 0 then
	        	time = day .. G_lang:get("LANG_CROSS_WAR_CD_DAY")
	        elseif hour > 0 then
	        	time = hour .. G_lang:get("LANG_CROSS_WAR_CD_HOUR") .. minute .. G_lang:get("LANG_CROSS_WAR_CD_MINUTE") .. second .. G_lang:get("LANG_CROSS_WAR_CD_SECOND")
	        elseif minute > 0 then
	        	time = minute .. G_lang:get("LANG_CROSS_WAR_CD_MINUTE") .. second .. G_lang:get("LANG_CROSS_WAR_CD_SECOND")
	        elseif second > 0 then
	        	time = second .. G_lang:get("LANG_CROSS_WAR_CD_SECOND")
	        end
	        self._timeLabel:setText(time)
	    elseif self._layer then
	    	-- 发协议更新战力
	    	G_HandlersManager.titleHandler:sendUpdateFightValue()

	    	-- 看看是否有激活道具
	    	local activatableTitleList = self._layer:getActivatableTitleList()
	    	for i, v in pairs(activatableTitleList) do
	    		if v.id == self._titleInfo.id then
	    			self:updateStatus(self._layer, 1, self._time)
	    			return
	    		end
	    	end

	    	self:updateStatus(self._layer, 0, self._time)
	    end	
	end	
end

-- 激活之后的特效
function TitleItemCell:playActivateEffect( ... )
	self._starEffect = EffectNode.new("effect_particle_star")
	self._starEffect:setScale(0.6)
	self._titleWholeBg:addNode(self._starEffect, 2)
	-- starEffect:setTag()
	self._starEffect:setPosition(ccp(120, 100))
	self._starEffect:play()

	local animeDelay = CCDelayTime:create(2.0)
    local stopEffect = CCSequence:createWithTwoActions(animeDelay, CCCallFunc:create(function()
                   			self:_stopActivateEffect()
                   end)
                )
    self._titleWholeBg:runAction(stopEffect)

    -- 清除可激活按钮上的光环特效
    if self._btnEffect then
    	self._btnEffect:stop()
    end
end

-- 清除激活特效
function TitleItemCell:_stopActivateEffect( ... )
	if self._starEffect then
		self._starEffect:removeFromParentAndCleanup(true)
	end
end



-- @titleId 	称号索引，也是称号id
-- @titleState	称号当前状态，0为不可激活，1为可激活，2为已激活，3为佩戴中
-- @itemId 		称号激活道具的id
function TitleItemCell:_titleBtnClicked( titleId, titleState)
	__Log("title btn id = %d", titleId)
	if titleState == 0 then
		-- 不可激活，仅显示信息
		local dialog = require("app.scenes.title.TitleDetailDialogInfo").create(titleId, 0)
		uf_sceneManager:getCurScene():addChild(dialog)
	elseif titleState == 1 then
		-- 可激活
		local dialog = require("app.scenes.title.TitleDetailDialogActivate").create(titleId)
		uf_sceneManager:getCurScene():addChild(dialog)
	elseif titleState == 2 then
		-- 可装备
		local dialog = require("app.scenes.title.TitleDetailDialogInfo").create(titleId, 1)
		uf_sceneManager:getCurScene():addChild(dialog)
	elseif titleState == 3 then
		-- 可卸下
		local dialog = require("app.scenes.title.TitleDetailDialogInfo").create(titleId, 2)
		uf_sceneManager:getCurScene():addChild(dialog)
	end	
end

function TitleItemCell:getTitleId( ... )
	return self._titleInfo.id
end

return TitleItemCell