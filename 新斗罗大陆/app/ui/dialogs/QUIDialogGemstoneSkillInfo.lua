-- @Author: vicentboo
-- @Date:   2019-09-06 16:41:58
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-10-21 11:19:24
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGemstoneSkillInfo = class("QUIDialogGemstoneSkillInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetGemstoneSkillInfo = import("..widgets.QUIWidgetGemstoneSkillInfo")

function QUIDialogGemstoneSkillInfo:ctor(options)
	local ccbFile = "ccb/Dialog_mount_talent.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogGemstoneSkillInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.frame_tf_title:setString("进阶属性")
    if options then
    	self._callBack = options.callBack
    	self._gemstone = options.gemstone
    	self._gemAdvancedType = options.gemAdvancedType
    end
   	self._godLevel = self._gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST

    self._gemstoneSkillConfigs = {}
    if remote.gemstone.GEMSTONE_MIX_SUIT_SKILL == self._gemAdvancedType  then
    	self._activateMixLevel = options.activateMixLevel
    	self._suitNum = options.suitNum
    	self:setMixSuitSkill()
    else
    	self:setAdvanceOrGodSkill()
    end

	self:initListView()
end

function QUIDialogGemstoneSkillInfo:setAdvanceOrGodSkill()
    local gemstoneConfig = db:getGemstoneEvolution(self._gemstone.itemId)
    
    self._showType = remote.gemstone.GEMSTONE_ANDVANCED_STATE
    if self._gemAdvancedType == remote.gemstone.GEMSTONE_TOGOD_STATE then
    	self._ccbOwner.frame_tf_title:setString("化神技能效果")
    	self._showType = remote.gemstone.GEMSTONE_TOGOD_STATE
    elseif self._gemAdvancedType == remote.gemstone.GEMSTONE_ANDVANCED_STATE then
    	self._ccbOwner.frame_tf_title:setString("进阶技能效果")
    	self._showType = remote.gemstone.GEMSTONE_ANDVANCED_STATE
    else
	    if self._godLevel >= GEMSTONE_MAXADVANCED_LEVEL then
	    	self._ccbOwner.frame_tf_title:setString("化神技能效果")
	    	self._showType = remote.gemstone.GEMSTONE_TOGOD_STATE
	    else
	    	self._ccbOwner.frame_tf_title:setString("进阶技能效果")
	    end
	end
    for _,v in pairs(gemstoneConfig) do
    	local compareLevel = tonumber(v.evolution_level)
		if v and v.gem_evolution_skill then
			if self._showType == remote.gemstone.GEMSTONE_ANDVANCED_STATE and compareLevel <= GEMSTONE_MAXADVANCED_LEVEL then
				table.insert(self._gemstoneSkillConfigs, v)
			end
			if self._showType == remote.gemstone.GEMSTONE_TOGOD_STATE and compareLevel > GEMSTONE_MAXADVANCED_LEVEL then
				table.insert(self._gemstoneSkillConfigs, v)
			end
		end
	end
end

function QUIDialogGemstoneSkillInfo:setMixSuitSkill()
	self._ccbOwner.frame_tf_title:setString("套装技能效果")
	local mixConfig = remote.gemstone:getGemstoneMixConfigByIdAndLv(self._gemstone.itemId , 1)
	local suitSkills = remote.gemstone:getGemstoneMixSuitConfigTableById(mixConfig.gem_suit, self._suitNum )
	for k,v in pairs(suitSkills) do
		table.insert(self._gemstoneSkillConfigs, tonumber(v.level),v)
	end
end

function QUIDialogGemstoneSkillInfo:viewDidAppear()
	QUIDialogGemstoneSkillInfo.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogGemstoneSkillInfo:viewWillDisappear()
  	QUIDialogGemstoneSkillInfo.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogGemstoneSkillInfo:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        totalNumber = #self._gemstoneSkillConfigs,
	        enableShadow = false,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:refreshData()
	end
end

function QUIDialogGemstoneSkillInfo:renderFunHandler(list, index, info)
    local isCacheNode = true
    local masterConfig = self._gemstoneSkillConfigs[index]
    local item = list:getItemFromCache()

    if not item then 
    	item = QUIWidgetGemstoneSkillInfo.new()
        isCacheNode = false
    end
    info.item = item
    if remote.gemstone.GEMSTONE_MIX_SUIT_SKILL == self._gemAdvancedType  then
		item:setGemMixSuitSkillInfo(masterConfig,self._activateMixLevel)
    else
		item:setGemadvanceSkillInfo(masterConfig,self._godLevel)
    end

    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogGemstoneSkillInfo:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogGemstoneSkillInfo:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogGemstoneSkillInfo:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogGemstoneSkillInfo
