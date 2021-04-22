local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDragonTotemUpgrade = class("QUIDialogDragonTotemUpgrade", QUIDialog)
local QActorProp = import("...models.QActorProp")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QQuickWay = import("...utils.QQuickWay")
local QUIViewController = import("..QUIViewController")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

function QUIDialogDragonTotemUpgrade:ctor(options)
	self._index = options.index
	-- local ccbFile = "ccb/Dialog_Weever_upgrade.ccbi"
	-- if self._index == remote.dragonTotem.TOTEM_TYPE then
	-- 	ccbFile = "ccb/Dialog_Weever_jihuo.ccbi"
	-- end
	local ccbFile = "ccb/Dialog_Dragon_Totem_Upgrade.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 				callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerUpgrade", 				callback = handler(self, self._onTriggerUpgrade)},		
		{ccbCallbackName = "onTriggerSkill", 				callback = handler(self, self._onTriggerSkill)},		
	}
	QUIDialogDragonTotemUpgrade.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	if self._index == remote.dragonTotem.TOTEM_TYPE then
		self._ccbOwner.frame_tf_title:setString("武魂之力进阶")

		self._ccbOwner.node_special_info:setVisible(true)
		self._ccbOwner.node_normal_info:setVisible(false)

		local dragonInfo = remote.dragon:getDragonInfo()
		local _dragonId = dragonInfo and dragonInfo.dragonId or 1
        local fca, name, dragonConfig = remote.dragonTotem:getDragonAvatarFcaAndNameByDragonId(_dragonId)
        if fca then
            local avatar = QUIWidgetFcaAnimation.new(fca, "actor", {backSoulShowEffect = dragonConfig.effect})
            avatar:setScaleX(-global.dragon_spine_scale)
            avatar:setScaleY(global.dragon_spine_scale)
            avatar:setPositionY(global.dragon_spine_offsetY)
            self._ccbOwner.node_avatar:addChild(avatar)
        end

        self._ccbOwner.tf_name_special:setString(name)
        self._ccbOwner.tf_upgrade:setString("进 阶")
	else
		self._ccbOwner.frame_tf_title:setString("光环强化")

		self._ccbOwner.node_special_info:setVisible(false)
		self._ccbOwner.node_normal_info:setVisible(true)

		self._ccbOwner.node_icon:removeAllChildren()
		self._ccbOwner.node_icon:setVisible(true)
		local path = remote.dragonTotem:getDragonIconById(self._index)
		local sp = CCSprite:create(path)
		if sp then
			self._ccbOwner.node_icon:addChild(sp)
		end
		self._ccbOwner.tf_upgrade:setString("升 级")
	end
	
	self:setTotemInfo()
end

function QUIDialogDragonTotemUpgrade:setTotemInfo()
	self._ccbOwner.node_consume:removeAllChildren()
	local info = nil
	if self._index == remote.dragonTotem.TOTEM_TYPE then
		info = remote.dragonTotem:getTotemInfo()
	else
		info = remote.dragonTotem:getDragonInfoById(self._index)
	end
	-- QPrintTable(info)
	self._gradeLevel = 1
	if info ~= nil then
		self._gradeLevel = info.grade or 1
	end
	local config = remote.dragonTotem:getConfigByIdAndLevel(self._index, self._gradeLevel)
	local nextConfig = remote.dragonTotem:getConfigByIdAndLevel(self._index, self._gradeLevel+1)
	self._config = config
	self._currentDesc = ""

	if config ~= nil then
		if self._index ~= remote.dragonTotem.TOTEM_TYPE then
			self._ccbOwner.tf_name_normal:setString(config.name_dragon_stone)
		end
		self._ccbOwner.tf_level:setString(self._gradeLevel)
	end

	if nextConfig ~= nil then
		self._ccbOwner.node_upgrade:setVisible(true)
		self._ccbOwner.node_max:setVisible(false)
		self._ccbOwner.tf_level_old:setString(self._gradeLevel.."级效果")
		self._ccbOwner.tf_level_new:setString((self._gradeLevel+1).."级效果")
		self._ccbOwner.tf_tips:setVisible(false)

		if self._index == remote.dragonTotem.TOTEM_TYPE then
			local minLevel = remote.dragonTotem:getMinTotemLevel()
			if minLevel <= self._gradeLevel then
				self._ccbOwner.tf_tips:setVisible(true)
				self._ccbOwner.tf_tips:setString("需所有光环达到"..(self._gradeLevel+1).."级")
				makeNodeFromNormalToGray(self._ccbOwner.node_btn_upgrade)
				-- makeNodeFromNormalToGray(self._ccbOwner.btn_upgrade)
				self._ccbOwner.tf_upgrade:disableOutline()
			else
				self:consumeHandler(nextConfig.consume)
			end
			self._currentDesc = self:getSkillStr(config)
			self._ccbOwner.tf_explain_old:setString(self._currentDesc)
			self._ccbOwner.tf_explain_new:setString(self:getSkillStr(nextConfig))
			-- self:_showTalentInfo()
		else
			self._currentDesc = remote.dragonTotem:getPropStr(config)
			self._ccbOwner.tf_explain_old:setString(self._currentDesc)
			self._ccbOwner.tf_explain_new:setString(remote.dragonTotem:getPropStr(nextConfig))
			self:consumeHandler(nextConfig.consume)
		end
	else
		self._ccbOwner.node_upgrade:setVisible(false)
		self._ccbOwner.node_max:setVisible(true)
		self._ccbOwner.tf_level_max:setString(self._gradeLevel.."级效果")
		if self._index == remote.dragonTotem.TOTEM_TYPE then
			self._ccbOwner.tf_value_max:setString(self:getSkillStr(config))
			-- self:_showTalentInfo(true)
		else
			self._ccbOwner.tf_value_max:setString(remote.dragonTotem:getPropStr(config))
		end
	end
end

function QUIDialogDragonTotemUpgrade:_showTalentInfo(isMax)
	-- if not self._gradeLevel then return end
	-- local talents = remote.dragonTotem:getDragonTotemTalent()
	-- local curIndex = 0
	-- local nextIndex = 0
	-- -- QPrintTable(talents)
	-- for index, value in ipairs(talents) do
	-- 	if value.condition <= self._gradeLevel then
	-- 		curIndex = index
	-- 	end
	-- 	if value.condition <= self._gradeLevel + 1 then
	-- 		nextIndex = index
	-- 	end
	-- end
	-- -- print(curIndex, nextIndex)
	-- if isMax then
	-- 	local propDesc = self:getTalentPropStr(talents, curIndex)
	-- 	self._ccbOwner.tf_totem_max:setString(propDesc)
	-- else
	-- 	if curIndex == 0 and nextIndex == 0 then
	-- 		self._ccbOwner.tf_totem_old:setString("无")
	-- 		self._ccbOwner.tf_totem_new:setString("无")
	-- 	elseif curIndex == 0 and nextIndex ~= 0 then
	-- 		self._ccbOwner.tf_totem_old:setString("无")
	-- 		local propDesc = self:getTalentPropStr(talents, nextIndex)
	-- 		self._ccbOwner.tf_totem_new:setString(propDesc)
	-- 	elseif curIndex ~= 0 and nextIndex == 0 then
	-- 		local propDesc = self:getTalentPropStr(talents, curIndex)
	-- 		self._ccbOwner.tf_totem_old:setString(propDesc)
	-- 		self._ccbOwner.tf_totem_new:setString("无")
	-- 	else
	-- 		local propDesc = self:getTalentPropStr(talents, curIndex)
	-- 		self._ccbOwner.tf_totem_old:setString(propDesc)
	-- 		propDesc = self:getTalentPropStr(talents, nextIndex)
	-- 		self._ccbOwner.tf_totem_new:setString(propDesc)
	-- 	end
	-- end
end

function QUIDialogDragonTotemUpgrade:getTalentPropStr(config, index)
	-- local props = {}
	-- local tbl = {}
	-- for _, v in ipairs(QActorProp._uiFields) do
	-- 	for i, c in ipairs(config) do
	-- 		if i <= index then
	-- 			if c[v.fieldName] ~= nil then
	-- 				if tbl[v.fieldName] then
	-- 					tbl[v.fieldName].value = tbl[v.fieldName].value + c[v.fieldName]
	-- 				else
	-- 					-- table.insert(props, {uiFields = v, value = c[v.fieldName]})
	-- 					tbl[v.fieldName] = {uiFields = v, value = c[v.fieldName]}
	-- 				end
	-- 			end
	-- 		else
	-- 			break
	-- 		end
	-- 	end
	-- end

	-- for _, v in pairs(tbl) do
	-- 	table.insert(props, {uiFields = v.uiFields, value = v.value})
	-- end

	-- local propDesc = ""
	-- if props ~= nil and #props > 0 then
	-- 	for i, prop in ipairs(props) do
	-- 		local value = prop.value
	-- 		if prop.uiFields.handlerFun ~= nil then
	-- 			value = prop.uiFields.handlerFun(value)
	-- 		end

	-- 		if i%2 == 0 then
	-- 			propDesc = propDesc.."  "..prop.uiFields.name.."+"..value.."\n"
	-- 		else
	-- 			propDesc = propDesc..prop.uiFields.name.."+"..value
	-- 		end
	-- 		-- table.insert(propDesc, prop.uiFields.name.."+"..value)
	-- 	end
	-- end
	-- return propDesc
end

function QUIDialogDragonTotemUpgrade:getSkillStr(config)
	local skillId = config.skill_id
	if skillId ~= nil then
		local skillData = QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(skillId, config.level)
		return skillData.description_1 or ""
	end
end

function QUIDialogDragonTotemUpgrade:consumeHandler(consume)
	self._needItem = nil
	self._isNeedItem = false
	local tbl = string.split(consume, ",")
	local count = 0
	local offsetX = 0
	for _,v in ipairs(tbl) do
		local v2 = string.split(v, ";")
		if #v2 == 2 then
			local typeName = remote.items:getItemType(v2[1])
			local isEnought = true
			if typeName == nil then
				if remote.items:getItemsNumByID(v2[1]) < tonumber(v2[2]) then
					if self._needItem == nil then
						self._needItem = v2[1]
						self._isNeedItem = true
					end
					isEnought = false
				end
			else
				if remote.user[typeName] < tonumber(v2[2]) then
					if self._needItem == nil then
						self._needItem = typeName
						self._isNeedItem = false
					end
					isEnought = false
				end
			end

			local icon = display.newSprite(remote.items:getURLForId(v2[1], "alphaIcon"))
			icon:setScale(0.6)
			self._ccbOwner.node_consume:addChild(icon)
			local width = (icon:getContentSize().width * 0.6)
			offsetX = offsetX + width/2
			icon:setPositionX(offsetX)
			offsetX = offsetX + width/2

			local tf = CCLabelTTF:create(v2[2], global.font_default, 22)
			tf:setAnchorPoint(0,0.5)
			if isEnought then
				tf:setColor(ccc3(79,25,2))
			else
				tf:setColor(UNITY_COLOR_LIGHT.red)
			end
			tf:setPositionX(offsetX)
			self._ccbOwner.node_consume:addChild(tf)
			offsetX = offsetX + tf:getContentSize().width + 20
		end
	end
	-- if self._index == remote.dragonTotem.TOTEM_TYPE then
	-- 	self._ccbOwner.node_consume:setPositionX(-offsetX/2 + 150)
	-- else
		self._ccbOwner.node_consume:setPositionX(-offsetX/2 + 15)
	-- end
end

--光环升级效果
function QUIDialogDragonTotemUpgrade:dragonUpgradeEffect()
    if self._effect == nil then
        self._effect =  QUIWidgetAnimationPlayer.new()
        self._effect:setPosition(0, 70)
        self:getView():addChild(self._effect)
    else
        self._effect:setVisible(true)
    end
    self._effect:playAnimation("ccb/effects/SkillUpgarde2.ccbi", function (ccbOwner)
        ccbOwner.title_skill:setString("等级＋1")
        ccbOwner.tf_desc1:setString(self._currentDesc)
    end, function ()
        
    end,false)
end

--图腾升级效果
function QUIDialogDragonTotemUpgrade:totemUpgradeEffect()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDragonTotemUpgradeSuccess", 
    	options={index = remote.dragonTotem.TOTEM_TYPE, callback = handler(self, self.checkTalent)}}, {isPopCurrentDialog = false})
end

function QUIDialogDragonTotemUpgrade:checkTalent()
	if self._index == remote.dragonTotem.TOTEM_TYPE then
		local config = remote.dragonTotem:getActiviteTalentByLevel(self._gradeLevel)
		if config ~= nil then
		    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDragonTotemTalentSuccess", 
		    	options={index = 7, gradeLevel = self._gradeLevel, config = config}}, {isPopCurrentDialog = false})
		end
	end
end

function QUIDialogDragonTotemUpgrade:_onTriggerUpgrade(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_upgrade) == false then return end
    app.sound:playSound("common_small")
	if self._index == remote.dragonTotem.TOTEM_TYPE then
		if self._gradeLevel >= remote.dragonTotem:getMinTotemLevel() then
			app.tip:floatTip("武魂之力的等级不能高于所有光环的等级，请先升级其他光环吧~")
			return
		end 
	end
	if self._needItem ~= nil then
		if self._isNeedItem then
    		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._needItem, nil, nil, false, "升级道具不足，请查看快捷途径~")
    	else
    		if self._needItem == ITEM_TYPE.MONEY then
    			QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY, nil, nil, nil, "升级道具不足，请查看快捷途径~")
    		end
    	end
		return
	end
	remote.dragonTotem:consortiaDragonDesignImproveRequest(self._index, function ()
		self:setTotemInfo()
		if self._index ~= remote.dragonTotem.TOTEM_TYPE then
			self:dragonUpgradeEffect()
		else
			self:totemUpgradeEffect()
		end
	end)
end

function QUIDialogDragonTotemUpgrade:_onTriggerSkill()
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDragonTotemTalent"})
end

function QUIDialogDragonTotemUpgrade:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogDragonTotemUpgrade:_backClickHandler()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogDragonTotemUpgrade