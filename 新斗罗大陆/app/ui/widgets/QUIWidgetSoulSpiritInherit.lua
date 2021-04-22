


local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulSpiritInherit = class("QUIWidgetSoulSpiritInherit", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QActorProp = import("...models.QActorProp")
local QRichText = import("...utils.QRichText") 
local QColorLabel = import("...utils.QColorLabel")
local QScrollView = import("...views.QScrollView")
local QQuickWay = import("...utils.QQuickWay")
local QNotificationCenter = import("...controllers.QNotificationCenter")


function QUIWidgetSoulSpiritInherit:ctor(options)
	local ccbFile = "ccb/Widget_SoulSpirit_Inherit.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerAdd", callback = handler(self, self._onTriggerAdd)},
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
		{ccbCallbackName = "onTriggerReset", callback = handler(self, self._onTriggerReset)},
	}
	QUIWidgetSoulSpiritInherit.super.ctor(self,ccbFile,callBacks,options)
    q.setButtonEnableShadow(self._ccbOwner.btn_add)
    q.setButtonEnableShadow(self._ccbOwner.btn_info)
	self._oldLv = 0
	self._waitAction = false
	self._resetNeedNum = db:getConfigurationValue("soul_sprite_recover_token_consume") or 30
end

function QUIWidgetSoulSpiritInherit:onEnter()
	QUIWidgetSoulSpiritInherit.super.onEnter(self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(remote.soulSpirit.EVENT_INHERIT_SUCCESS, self.msgOnInheritSuccess, self)
    self:playCircleAction()
	self:_initScrollView()
end

function QUIWidgetSoulSpiritInherit:onExit()
	self:stopAllActions()
	QUIWidgetSoulSpiritInherit.super.onExit(self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(remote.soulSpirit.EVENT_INHERIT_SUCCESS, self.msgOnInheritSuccess, self)
end

function QUIWidgetSoulSpiritInherit:msgOnInheritSuccess(event)
  
    local soulSpiritId = self._id
    self._oldLv =  clone(self._inheritLv)
    local oldLv = self._oldLv
	self._waitAction = true
	self:updataResetBtn()
    remote.soulSpirit:soulSpiritDevourRequest(soulSpiritId,event.items, function(data)
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritDevourSuccess",
		options = {id = soulSpiritId , oldLv = oldLv, callback = function ()
		    if self:safeCheck() then
		        self:playActionByIndex()
		    end
		end}},{isPopCurrentDialog = false})
	    end, function(data)
	end)

end


function QUIWidgetSoulSpiritInherit:_initScrollView()
	if not self._scrollView then
		local itemContentSize = self._ccbOwner.sheet_layout:getContentSize()
		self._scrollView = QScrollView.new(self._ccbOwner.sheet, itemContentSize, {bufferMode = 1})
    	self._scrollView:setVerticalBounce(true)
	end
end

function QUIWidgetSoulSpiritInherit:setInfo(id, heroId)
	if not id and not heroId then
        return
    elseif id and heroId then
        self._id = id
        self._heroId = heroId
    elseif id then
        self._id = id
        self._soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
        self._heroId = self._soulSpiritInfo and self._soulSpiritInfo.heroId or 0
    elseif heroId then
        self._heroId = heroId
        local heroInfo = remote.herosUtil:getHeroByID(self._heroId)
        self._soulSpiritInfo = heroInfo.soulSpirit
        self._id = self._soulSpiritInfo and self._soulSpiritInfo.id or 0
    end
    self:updateInfo()

    if remote.soulSpirit:isInheritRedTipsById(self._id) and app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.SOUL_SPIRIT_INHERIT) then
		app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.SOUL_SPIRIT_INHERIT)
    end
end

function QUIWidgetSoulSpiritInherit:playCircleAction()
	local DELAY={360,-360}
	for i=1,2 do
		local arr = CCArray:create()
    	arr:addObject(CCRotateBy:create(30, DELAY[i]))
		self._ccbOwner["sp_fazhen"..i]:runAction(CCRepeatForever:create(CCSequence:create(arr)))
	end
end

function QUIWidgetSoulSpiritInherit:updateInfo()
	print("QUIWidgetSoulSpiritInherit:updateInfo")

	if self._waitAction then
		return
	end

	self._soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)

    if self._soulSpiritInfo == nil then
    	return
    end
    self._characterConfig = db:getCharacterByID(self._id)

    self._ccbOwner.node_avatar:removeAllChildren()
    local avatar = QUIWidgetActorDisplay.new(self._id)
    self._ccbOwner.node_avatar:addChild(avatar)
    avatar:setScale(1.1)
    self._ccbOwner.node_avatar:setScaleX(-1)
    self._inheritLv = self._soulSpiritInfo.devour_level or 0
	self._curInheritMod = remote.soulSpirit:getSoulSpiritInheritConfig(self._inheritLv ,self._id)
    self._nextInheritMod = remote.soulSpirit:getSoulSpiritInheritConfig(self._inheritLv + 1,self._id)
    if self._curInheritMod == nil then
    	return
    end
    self:updateSkillInfo()
    self:updateSkillIcon()
    self:updateSkillProp()
	self:updateSkillDesc()
	self:updataResetBtn()
end


function QUIWidgetSoulSpiritInherit:updateSkillInfo()

	local curLv = self._soulSpiritInfo.devour_level or 0
	local curNum = self._soulSpiritInfo.devour_exp or 0
	local maxNum = self._nextInheritMod and self._nextInheritMod.exp or 0
	local isMax = self._nextInheritMod == nil

	self._ccbOwner.tf_skil_name:setString("传承"..curLv.."重")


	if not isMax then
		self._ccbOwner.tf_progress:setString(curNum.."/"..maxNum)
		self._ccbOwner.sp_progress:setScaleX(math.min( curNum / maxNum, 1))
	else
		self._ccbOwner.tf_progress:setString("已到顶级")
		self._ccbOwner.sp_progress:setScaleX(1)
	end
end

function QUIWidgetSoulSpiritInherit:updateSkillIcon()
	local nextLv = self._inheritLv + 1
	self._ccbOwner.btn_add:setVisible(false)
	for i=1,6 do
		self._ccbOwner["tf_lv_"..i]:setVisible(i > nextLv)
    	self._ccbOwner["node_effect_light_"..i]:setVisible(i <= self._inheritLv)
    	self._ccbOwner["node_effect_ui_"..i]:setVisible(false)
    	-- self._ccbOwner["node_effect_ui_"..i]:setVisible(i <= self._inheritLv)
		self._ccbOwner["node_inherit_lv_effect_"..i]:removeAllChildren()

		if i < nextLv then
			local sp_fireBall = CCSprite:create(QResPath("soul_spirit_inherit_sp"))
			self._ccbOwner["node_inherit_lv_effect_"..i]:addChild(sp_fireBall)
			-- sp_fireBall:setPositionY(10)
			--加动画
		elseif i ==nextLv then
			self._ccbOwner.btn_add:setVisible(true)
			self._ccbOwner.btn_add:setPosition(self._ccbOwner["node_inherit_lv_"..i]:getPosition())

		end
	end

end

function QUIWidgetSoulSpiritInherit:updateSkillProp()
	local propDesc = remote.soulSpirit:getPropStrList(self._curInheritMod)

    local propDescIndex = {}
    table.insert(propDescIndex, {fieldName = "attack_value", name = "攻     击："})
    table.insert(propDescIndex, {fieldName = "hp_value", name = "生     命："})
    table.insert(propDescIndex, {fieldName = "attack_percent", name = "生命、攻击："})
    table.insert(propDescIndex, {fieldName = "armor_magic", name = "法     防："})
    table.insert(propDescIndex, {fieldName = "armor_physical", name = "物     防："})
    table.insert(propDescIndex, {fieldName = "armor_magic_percent", name = "物防、法防："})

	local color =  ccc3(84, 36, 6)
	if self._inheritLv == 0 then
		propDesc = remote.soulSpirit:getPropStrList(self._nextInheritMod)
		color = COLORS.n
	end
    for i,v in ipairs(propDescIndex) do
        local isVisible = false
        self._ccbOwner["tf_cur_name"..i]:setString(v.name)
        for k,prop in pairs(propDesc) do
            if prop.fieldName == v.fieldName then
                isVisible = true
                self._ccbOwner["tf_cur_value"..i]:setString("+"..prop.value)
                break
            end
        end
        self._ccbOwner["tf_cur_name"..i]:setVisible(isVisible)
        self._ccbOwner["tf_cur_value"..i]:setVisible(isVisible)
		self._ccbOwner["tf_cur_value"..i]:setColor(color)
    end



end


function QUIWidgetSoulSpiritInherit:updateSkillDesc()
	self._scrollView:clear()

	local totalHeight = 5
	local skillId1 = {}
	local rnumSkillLevel = 1
	if self._inheritLv == 0 then
		skillId1 = string.split(self._nextInheritMod.skill, ":")
	else
		skillId1 = string.split(self._curInheritMod.skill, ":")
		rnumSkillLevel = self._inheritLv
	end
	rnumSkillLevel = q.getRomanNumberalsByInt(rnumSkillLevel)
    local skillConfig1 = db:getSkillByID(tonumber(skillId1[1]))
    local describe
    if skillConfig1 ~= nil then
        describe = "##e"..skillConfig1.name..rnumSkillLevel.."：##n"..skillConfig1.description
    end

    local strArr  = string.split(describe,"\n") or {}
    for i, v in pairs(strArr) do
        local describe = QColorLabel.replaceColorSign(v or "", false)
        local richText = QRichText.new(describe, 510, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20, fontName = global.font_default})
        richText:setAnchorPoint(ccp(0, 1))
        richText:setPositionY(-totalHeight)
		self._scrollView:addItemBox(richText)
        totalHeight = totalHeight + richText:getContentSize().height
    end
	self._scrollView:setRect(0, -totalHeight, 0, 0)


end

function QUIWidgetSoulSpiritInherit:playActionByIndex()
	self._oldLv = self._oldLv or 0
	local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
	local targetLv = soulSpiritInfo.devour_level or self._inheritLv
	self._ccbOwner.btn_add:setVisible(false)



    local totalFrames = 48
    local baoIn =q.flashFrameTransferDur(5) 
    local baoEnd = q.flashFrameTransferDur(33)
    local bigAction = q.flashFrameTransferDur(10)
    local smallAction = q.flashFrameTransferDur(5)

    local delayFrame = 15
	local ccbFile = QResPath("soul_spirit_inherit_effect")


	for i = self._oldLv + 1 ,targetLv do

		local effectNode = self._ccbOwner["node_inherit_lv_effect_"..i]
		effectNode:removeAllChildren()


		local sp_fireBall = CCSprite:create(QResPath("soul_spirit_inherit_sp"))
		effectNode:addChild(sp_fireBall)
		sp_fireBall:setOpacity(0)	
		sp_fireBall:setScale(2)	
		-- sp_fireBall:setPositionY(10)	

		local array3 = CCArray:create()
		array3:addObject(CCDelayTime:create(q.flashFrameTransferDur(baoIn)))
    	array3:addObject(CCCallFunc:create(function()
			local effect = QUIWidget.new(ccbFile)
			effect:setTag(99)
			effect:setPositionY(-5)	
			-- effect:setVisible(false)
			effectNode:addChild(effect)
		end))

		local array2 = CCArray:create()
		array2:addObject(CCFadeIn:create(bigAction))
		array2:addObject(CCScaleTo:create(bigAction, 0.6))
	    array2:addObject(CCSequence:create(array3))
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(q.flashFrameTransferDur(delayFrame)))
		arr:addObject(CCSpawn:create(array2))
	    arr:addObject(CCScaleTo:create(smallAction, 1))
	    arr:addObject(CCCallFunc:create(function()
	    	-- effectNode:removeChildByTag(99)
	    	self._ccbOwner["node_effect_light_"..i]:setVisible(true)
	    	self._ccbOwner["node_effect_ui_"..i]:setVisible(false)

		end))
		arr:addObject(CCDelayTime:create(baoEnd))
	    arr:addObject(CCCallFunc:create(function()
	    	effectNode:removeChildByTag(99)
		end))

		sp_fireBall:runAction(CCSequence:create(arr))
		delayFrame = delayFrame + totalFrames
	end


	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(q.flashFrameTransferDur(delayFrame + 10 )))
    arr:addObject(CCCallFunc:create(function()
    	self._waitAction = false
    	self:updateInfo()
	end))
    self:runAction(CCSequence:create(arr))
end


function QUIWidgetSoulSpiritInherit:updataResetBtn()
	local curLv = self._soulSpiritInfo.devour_level or 0
	local curNum = self._soulSpiritInfo.devour_exp or 0
	local isShow = false

	if curLv > 0 or curNum > 0 then
		isShow = true
	end

	if isShow then
		self._ccbOwner.btn_info:setPosition(212.0, 106.0)
	else
		self._ccbOwner.btn_info:setPosition(self._ccbOwner.btn_reset:getPosition())
	end
	self._ccbOwner.btn_reset:setVisible(isShow)
end

function QUIWidgetSoulSpiritInherit:_onTriggerAdd(e)
	app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritDevour", 
        options = {id = self._id}})
end

function QUIWidgetSoulSpiritInherit:_onTriggerInfo(e)
	app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritInheritSkillInfo", 
        options = {id = self._id}})
end


function QUIWidgetSoulSpiritInherit:_onReset(e)
	remote.soulSpirit:resetSoulSpiritInheritRequest(self._id, function(data)

		self:updateInfo()

		-- 更新背包
		local wallet = {}
		wallet.money = data.money
		wallet.token = data.token
		remote.user:update( wallet )
		if data.items then remote.items:setItems(data.items) end

		-- 获取奖励
		local items = remote.soulSpirit:getDevourConsumeDicById(tonumber(self._id))
		remote.soulSpirit:resetDevourConsumeDicById(tonumber(self._id))
		local awards = {}
		if not q.isEmpty(items) then
			for key, value in pairs(items) do
				table.insert(awards, { id = key, typeName = ITEM_TYPE.ITEM, count = value })
			end
		end

		-- -- 展示奖励页面
		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEnchantResetAwardsAlert",
    		options = {awards = awards, callBack = function()
    		end}}, {isPopCurrentDialog = false} )
		dialog:setTitle("魂灵传承摘除返还以下道具")
	end)
end

function QUIWidgetSoulSpiritInherit:_onTriggerReset(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_reset) == false then return end

	local resetCallback = function(callType)
		if callType == ALERT_TYPE.CONFIRM then
			if remote.user.token < self._resetNeedNum then
				QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
			else
				self:_onReset()
			end
		end
	end

	local content = string.format("##n花费##e%d钻石##n，摘除##用于该魂灵传承的所有碎片##n？确认后，返还##e全部用于传承的魂灵碎片##n。", self._resetNeedNum)
	app:alert({content = content, title = "系统提示", callback = resetCallback, isAnimation = true, colorful = true}, true, true)
end

return QUIWidgetSoulSpiritInherit