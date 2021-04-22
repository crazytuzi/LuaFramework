-- @Author: vicentboo
-- @Date:   2019-09-05 16:22:05
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-04 21:01:40
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroGemstoneToGod = class("QUIWidgetHeroGemstoneToGod", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QColorLabel = import("...utils.QColorLabel")
local QScrollView = import("...views.QScrollView")
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetGemstoneToGodMaxLevel = import("..widgets.QUIWidgetGemstoneToGodMaxLevel")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QQuickWay = import("...utils.QQuickWay")

function QUIWidgetHeroGemstoneToGod:ctor(options)
	local ccbFile = "ccb/Widget_HeroGemstone_ToGod.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerToGod", callback = handler(self, self._onTriggerToGod)},
		{ccbCallbackName = "onTriggerSkillInfo", callback = handler(self, self._onTriggerSkillInfo)},
		{ccbCallbackName = "onPlus",callback = handler(self,self._onPlus)},
		{ccbCallbackName = "onTriggerReset", callback = handler(self, self._onTriggerReset)},
    }
    QUIWidgetHeroGemstoneToGod.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	q.setButtonEnableShadow(self._ccbOwner.btn_reset)

	local size = self._ccbOwner.sheet_layout:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, size, {bufferMode = 1})
    self._scrollView:setVerticalBounce(true)

    self._canbegodState = false
end

function QUIWidgetHeroGemstoneToGod:setInfo(actorId, gemstoneSid, gemstonePos)
    self._ccbOwner.tf_special_info:setVisible(false)

	self._actorId = actorId
	self._gemstoneSid = gemstoneSid
	self._gemstonePos = gemstonePos
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	self._gemstone = gemstone
	local itemConfig = db:getItemByID(gemstone.itemId)
	
	local level,color = remote.herosUtil:getBreakThrough(gemstone.craftLevel) 

    self._godLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST

	for ii = 1,2 do
		self._ccbOwner["tf_old_name"..ii]:setString("")
		self._ccbOwner["tf_old_value"..ii]:setString("")
		self._ccbOwner["tf_new_name"..ii]:setString("")
		self._ccbOwner["tf_new_value"..ii]:setString("")
	end

	self:showCurrentStep(self._godLevel)
end

function QUIWidgetHeroGemstoneToGod:showCurrentStep(godLevel)
	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	local oldLevelInfo = db:getGemstoneEvolutionBygodLevel(gemstone.itemId,godLevel)
    local nextLevelInfo = db:getGemstoneEvolutionBygodLevel(gemstone.itemId,godLevel+1)

    local itemConfig = db:getItemByID(gemstone.itemId)

	local maxLevel = QStaticDatabase:sharedDatabase():getConfiguration().GEMSTONE_MAX_GODLEVEL.value
	self._ccbOwner.btn_reset:setPosition(213, -87)
	self._ccbOwner.btn_reset:setVisible(true)
	if godLevel >= maxLevel then
		self._ccbOwner.client_right:setVisible(false)
		self._ccbOwner.node_godbar_status:setVisible(false)
		self._ccbOwner.node_togodbtn:setVisible(false)
		if self._maxWidget == nil then
			self._maxWidget = QUIWidgetGemstoneToGodMaxLevel.new()
			self:getView():addChild(self._maxWidget)
		end
		self._ccbOwner.btn_reset:setPosition(247, 179)
		self._maxWidget:setInfo(self._actorId, self._gemstoneSid, self._gemstonePos, "TAB_TOGOD")
		return
	elseif godLevel == remote.gemstone.GEMSTONE_TOGOD_LEVEL then
		self._ccbOwner.btn_reset:setVisible(false)
	end
	self._ccbOwner.client_right:setVisible(true)
	self._ccbOwner.node_godbar_status:setVisible(true)
	self._ccbOwner.node_togodbtn:setVisible(true)
	if self._maxWidget ~= nil then
		self._maxWidget:removeFromParent()
		self._maxWidget = nil
	end

    local oldPropVlue = {}
    for ii=1,godLevel do
    	local advancedInfo = db:getGemstoneEvolutionBygodLevel(gemstone.itemId,ii)
    	if advancedInfo.attack_value then
    		oldPropVlue.attack_value = (oldPropVlue.attack_value or 0) + advancedInfo.attack_value
    	end

    	if advancedInfo.hp_value then
    		oldPropVlue.hp_value = (oldPropVlue.hp_value or 0) + advancedInfo.hp_value
    	end
    	if advancedInfo.armor_physical then
    		oldPropVlue.armor_physical = (oldPropVlue.armor_physical or 0) + advancedInfo.armor_physical
    	end
    	if advancedInfo.armor_magic then
    		oldPropVlue.armor_magic = (oldPropVlue.armor_magic or 0) + advancedInfo.armor_magic
    	end
    end
    
    if godLevel > GEMSTONE_MAXADVANCED_LEVEL then
    	self._ccbOwner.red_animation:setVisible(true)
    	self._ccbOwner.orange_animation:setVisible(false)
    else
    	self._ccbOwner.red_animation:setVisible(false)
    	self._ccbOwner.orange_animation:setVisible(true)
    end

	if oldLevelInfo and next(oldLevelInfo) ~= nil then

		self:setOldProp(oldPropVlue.attack_value, "攻    击：","＋%d")
		self:setOldProp(oldPropVlue.hp_value, "生    命：","＋%d")
		self:setOldProp(oldPropVlue.armor_physical, "物    防：","＋%d")
		self:setOldProp(oldPropVlue.armor_magic, "法    防：","＋%d")
	else
		self._ccbOwner.tf_old_name1:setString("尚未化神")
	end

	local advancedSkillId1, godSkillId1 = db:getGemstoneEvolutionSkillIdBygodLevel(gemstone.itemId,godLevel)
	local advancedSkillId2, godSkillId2 = db:getGemstoneEvolutionSkillIdBygodLevel(gemstone.itemId,godLevel+1)
	local totalHeight = 0
	self._scrollView:clear()
	if godSkillId1 then
		local skillInfo = db:getSkillByID(godSkillId1)
		if skillInfo then
			self._ccbOwner.tf_skillName:setString("化神效果"..q.getRomanNumberalsByInt(godLevel-GEMSTONE_MAXADVANCED_LEVEL))
		    -- local skillTextinfo = skillInfo.name.."："..skillInfo.description or ""
			local text = QColorLabel:create("##e".."当前效果：".."##n"..skillInfo.description or "", 500, nil, nil, 22, GAME_COLOR_LIGHT.normal)
			text:setAnchorPoint(ccp(0, 1))
			text:setPositionY(1)
			totalHeight = totalHeight + text:getContentSize().height
			self._scrollView:addItemBox(text)
			self._scrollView:setRect(0, -totalHeight, 0, 0)		
		end	
	else
		self._ccbOwner.tf_skillName:setString("化神效果")
		local text = QColorLabel:create("##e".."当前效果：".."##n".."无", 500, nil, nil, 22, GAME_COLOR_LIGHT.normal)
		text:setAnchorPoint(ccp(0, 1))
		text:setPositionY(1)
		totalHeight = totalHeight + text:getContentSize().height
		self._scrollView:addItemBox(text)
		self._scrollView:setRect(0, -totalHeight, 0, 0)
	end

	if godSkillId2 then
		local skillInfo = db:getSkillByID(godSkillId2)
		if skillInfo then
			local text = QColorLabel:create("##e".."下一级效果：".."##c"..skillInfo.description or "", 500, nil, nil, 22, GAME_COLOR_LIGHT.normal)
			text:setAnchorPoint(ccp(0, 1))
			text:setPositionY(-totalHeight)
			totalHeight = totalHeight + text:getContentSize().height
			self._scrollView:addItemBox(text)
			self._scrollView:setRect(0, -totalHeight, 0, 0)		
		end			
	end

	if nextLevelInfo and next(nextLevelInfo) ~= nil then
		self:setNewProp(oldPropVlue.attack_value,nextLevelInfo.attack_value, "攻    击：","＋%d")
		self:setNewProp(oldPropVlue.hp_value,nextLevelInfo.hp_value, "生    命：","＋%d")
		self:setNewProp(oldPropVlue.armor_physical,nextLevelInfo.armor_physical, "物    防：","＋%d")
		self:setNewProp(oldPropVlue.armor_magic,nextLevelInfo.armor_magic, "法    防：","＋%d")

		self._costItemNum = tonumber(nextLevelInfo.evolution_consume_1)
		self._costItemid = nextLevelInfo.evolution_consume_type_1
		local haveNum = remote.items:getItemsNumByID(self._costItemid)
		self._ccbOwner.status1_tf:setString(haveNum.."/"..(self._costItemNum or 0))

		self._ccbOwner.node_icon:removeAllChildren()
    	local itemBox = QUIWidgetItemsBox.new()
        itemBox:setGoodsInfo(self._costItemid, ITEM_TYPE.ITEM, 0)
        itemBox:hideSabc()
        itemBox:hideTalentIcon()
        itemBox:setScale(0.5)
        self._ccbOwner.node_icon:addChild(itemBox)	

        if haveNum <= 0 then
            self._ccbOwner.status_bar:setScaleX(0.01)
            self:showBtnState(false)
        elseif haveNum >= self._costItemNum then 
        	self._ccbOwner.status_bar:setScaleX(1)
        	self._ccbOwner.node_tips_grade:setVisible(true)
        	self:showBtnState(true)
        else
            self._ccbOwner.status_bar:setScaleX(haveNum/self._costItemNum)
            self:showBtnState(false)
        end
	else
		self:showBtnState(false)
	end

	if self._oldGemStone == nil then
		self._oldGemStone = QUIWidgetEquipmentAvatar.new()
		self._ccbOwner.node_old_icon:addChild(self._oldGemStone)
	end
	self._oldGemStone:setGemstonInfo(itemConfig, gemstone.craftLevel, 1.0,godLevel, gemstone.mix_level)
	self._oldGemStone:hideAllColor()
	
	if self._newGemStone == nil then
		self._newGemStone = QUIWidgetEquipmentAvatar.new()
		self._ccbOwner.node_new_icon:addChild(self._newGemStone)
	end
	self._newGemStone:setGemstonInfo(itemConfig, gemstone.craftLevel, 1.0,godLevel+1, gemstone.mix_level)
	self._newGemStone:hideAllColor()
end

function QUIWidgetHeroGemstoneToGod:showBtnState(canGod)
	self._canbegodState = canGod
	if canGod then
		self._ccbOwner.node_tips_grade:setVisible(true)	
	else
		self._ccbOwner.node_tips_grade:setVisible(false)
	end
end
function QUIWidgetHeroGemstoneToGod:setOldProp(prop1,value,value1,ispercent)
	local prop = (prop1 or 0) 
	if prop ~= nil and prop > 0 then
		if ispercent == true then
			prop = prop * 100
		end
		self._ccbOwner["tf_old_name1"]:setString(value)
		self._ccbOwner["tf_old_name1"]:setVisible(true)
		self._ccbOwner["tf_old_value1"]:setString(string.format(value1, prop))
		self._ccbOwner["tf_old_value1"]:setVisible(true)
	end
end

function QUIWidgetHeroGemstoneToGod:setNewProp(prop1,prop2,value,value1,ispercent)
	local prop = (prop1 or 0) + (prop2 or 0) 
	if prop ~= nil and prop > 0 then
		if ispercent == true then
			prop = prop * 100
		end
		self._ccbOwner["tf_new_name1"]:setString(value)
		self._ccbOwner["tf_new_name1"]:setVisible(true)
		self._ccbOwner["tf_new_value1"]:setString(string.format(value1, prop))
		self._ccbOwner["tf_new_value1"]:setVisible(true)
	end
end

function QUIWidgetHeroGemstoneToGod:_onTriggerToGod(event)
   
	if q.buttonEventShadow(event, self._ccbOwner.btn_togod) == false then return end
	app.sound:playSound("common_menu")
	if not self._canbegodState then
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._costItemid, nil, nil, false)
		return
	end
	remote.gemstone:gemstoneToGodAndAdvanced(self._gemstoneSid, nil, function(data)
  		self._ccbOwner.node_bigAnimation:removeAllChildren()

		local effectName = "effects/hg_upgrade_2.ccbi"
      	local bigeffectccb = QUIWidgetAnimationPlayer.new()
      	bigeffectccb:setPosition(ccp(0,12))
      	self._ccbOwner.node_bigAnimation:addChild(bigeffectccb)
      	bigeffectccb:playAnimation(effectName,nil,function()
      		bigeffectccb:disappear()
      		remote.gemstone:dispatchEvent({name = remote.gemstone.EVENT_TOGOD, sid = self._gemstoneSid, actorId = self._actorId })
      	end)
		
	end,nil)
end

function QUIWidgetHeroGemstoneToGod:_onTriggerSkillInfo(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_check) == false then return end
    app.sound:playSound("common_menu")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGemstoneSkillInfo", 
        options={gemstone = self._gemstone}}, {isPopCurrentDialog = false})
end

function QUIWidgetHeroGemstoneToGod:_onPlus(event )
	if q.buttonEventShadow(event, self._ccbOwner.btn_plus) == false then return end
	app.sound:playSound("common_menu")
	QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._costItemid, nil, nil, false)
end
function QUIWidgetHeroGemstoneToGod:onEnter()
end

function QUIWidgetHeroGemstoneToGod:onExit()
end

function QUIWidgetHeroGemstoneToGod:getContentSize()
end

function QUIWidgetHeroGemstoneToGod:_onTriggerReset(event)
	if not self._gemstoneSid then return end

	local gemstoneSid = self._gemstoneSid
	local gemstone = remote.gemstone:getGemstoneById(gemstoneSid)
	if gemstone.godLevel <= remote.gemstone.GEMSTONE_TOGOD_LEVEL then
		app.tip:floatTip("尚未化神，无需重置～")
		return
    end

	local itemConfig = db:getItemByID(gemstone.itemId)
    local name = "神·"..itemConfig.name

	local content = string.format("##n重置##l%s##n的化神等级到神0？摘除后，返还全部养成材料。", name ) 
    local sucessCallback = function()
        remote.gemstone:gemstoneReturnGodLevelRequest(gemstoneSid, function(data)
                -- 展示奖励页面
                local awards = {}
                local tbl = string.split(data.recoverItemAndCount or "", ";")
                for _, awardStr in pairs(tbl or {}) do
                    if awardStr ~= "" then
                        local id, typeName, count = remote.rewardRecover:getItemBoxParaMetet(awardStr)
                        table.insert(awards, {id = id, count = count, typeName = typeName})
                    end
                end
                if next(awards) then
                    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEnchantResetAwardsAlert",
                        options = {awards = awards}},{isPopCurrentDialog = false} )
                    dialog:setTitle("化神重置返还以下道具")
                end
            end)
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRemoveAlert", 
	    options = {title = "重置化神", contentStr = content, 
	    	callback = function (isRemove)
	    		if isRemove then
	            	sucessCallback()
	            end
	    	end}})
end

return QUIWidgetHeroGemstoneToGod
