

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroGemstoneMixSuccess = class("QUIDialogHeroGemstoneMixSuccess", QUIDialog)
local QHeroModel = import("...models.QHeroModel")
local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")
local QUIWidgetHeroHeadVibrate = import("..widgets.QUIWidgetHeroHeadVibrate")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
function QUIDialogHeroGemstoneMixSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_Baoshi_MixSuccess.ccbi"
	local callBacks = {}
	QUIDialogHeroGemstoneMixSuccess.super.ctor(self,ccbFile,callBacks,options)

    self.isAnimation = true --是否动画显示
	app.sound:playSound("hero_breakthrough")
	self._isEnd = false
	
	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	if options then
		self._callback = options.callback
		self._sid = options.sid
	end
	self._iconTbl ={}
	local gemstone = remote.gemstone:getGemstoneById(self._sid)
	local itemConfig = db:getItemByID(gemstone.itemId)
	local mixLevel = gemstone.mix_level or 1

	local curMixConfig,nextMixConfig = remote.gemstone:getGemstoneMixConfigAndNextByIdAndLv(gemstone.itemId,mixLevel - 1)
	if not gemstone  or not itemConfig then return end

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))

	if curMixConfig == nil then
		self:setGemstoneMixPropInfo(nextMixConfig,nextMixConfig,true )
	else
		self:setGemstoneMixPropInfo(curMixConfig,nextMixConfig,false )
	end
	self:setGemstoneMixIcon("old" , itemConfig , gemstone,mixLevel - 1)
	self:setGemstoneMixIcon("new" , itemConfig , gemstone,mixLevel)

	self._ccbOwner.tf_skill_name:setString("")
	self._ccbOwner.tf_skill_desc:setString("")
	self._ccbOwner.node_skill:setCascadeOpacityEnabled(true)
	self._ccbOwner.node_skill:setOpacity(0)
	self._skillProcess = 0
	self._skillIndex = 0
end


function QUIDialogHeroGemstoneMixSuccess:setGemstoneMixPropInfo(curMixConfig , nextMixConfig , isZero )

	local propDesc =remote.gemstone:setPropInfo(curMixConfig ,true,true,true)	
	for i,v in ipairs(propDesc) do
		local descText = self._ccbOwner["name_"..i]
		local propText = self._ccbOwner["old_prop_"..i]
		if descText and propText then
			descText:setString(v.name)
			if isZero then
				propText:setString("0")
			else
				propText:setString(v.value)
			end
		end
	end
	propDesc =remote.gemstone:setPropInfo(nextMixConfig ,true,true,true)
	for i,v in ipairs(propDesc) do
		local propText = self._ccbOwner["new_prop_"..i]
		if propText then
			propText:setString(v.value)
		end
	end
	local propNum = #propDesc

	if propNum  < 3 then
		for i=propNum+ 1,3 do
			local propNode = self._ccbOwner["prop_node_"..i]
			if propNode then
				propNode:setVisible(false)
			end
		end
	end
end


function QUIDialogHeroGemstoneMixSuccess:setGemstoneMixIcon(typeStr , itemConfig , gemstoneData , mixLevel)
	local nodeIcon = self._ccbOwner[typeStr.."_head"]

	if not nodeIcon or not itemConfig or not gemstoneData then return end

	if self._iconTbl[typeStr] == nil then
		self._iconTbl[typeStr] = QUIWidgetEquipmentAvatar.new()
		nodeIcon:addChild(self._iconTbl[typeStr])
	end
	self._iconTbl[typeStr]:setGemstonInfo(itemConfig, gemstoneData.craftLevel , 1.0 , gemstoneData.godLevel,mixLevel)
	self._iconTbl[typeStr]:hideAllColor()
	if mixLevel > 0 then
		self._ccbOwner["tf_"..typeStr.."_name"]:setString("SS+"..itemConfig.name)
	else
		local godLevel = gemstoneData.godLevel or 0 
		if godLevel > GEMSTONE_MAXADVANCED_LEVEL then
			self._ccbOwner["tf_"..typeStr.."_name"]:setString("SS"..itemConfig.name)
		else
			self._ccbOwner["tf_"..typeStr.."_name"]:setString(itemConfig.name)
		end
	end
	
	self._ccbOwner["tf_"..typeStr.."_name"]:setColor(BREAKTHROUGH_COLOR_LIGHT.red)
end

function QUIDialogHeroGemstoneMixSuccess:animationEndHandler(name)
	self._animationStage = name
end

function QUIDialogHeroGemstoneMixSuccess:_onTriggerClose()
	if self._isEnd == true then
		if self._callback ~= nil then
			self._callback()
		end
		if self._scheduler then
			scheduler.unscheduleGlobal(self._scheduler)
			self._scheduler = nil
		end
		self:playEffectOut()
	else
		if self._animationStage == nil then
			self._animationStage = "1"
			self._animationManager:runAnimationsForSequenceNamed("2")
		elseif self._animationStage == "1" then
			return
		else
			self._isEnd = true
			if self._callback ~= nil then
				self._callback()
			end
			if self._scheduler then
				scheduler.unscheduleGlobal(self._scheduler)
				self._scheduler = nil
			end
			self:playEffectOut()
			-- scheduler.performWithDelayGlobal(function()
			-- 		self._isEnd = true
			-- 	end, 1)								
		end
	end
end

function QUIDialogHeroGemstoneMixSuccess:_backClickHandler()
	self:_onTriggerClose()
end

return QUIDialogHeroGemstoneMixSuccess