--[[	
	文件名称：QUIWidgetSocietySkillLearn.lua
	创建时间：2016-04-16 15:20:00
	作者：nieming
	描述：QUIWidgetSocietySkillLearn
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSocietySkillLearn = class("QUIWidgetSocietySkillLearn", QUIWidget)
local QQuickWay = import("...utils.QQuickWay")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIWidgetSocietySkillLearn:ctor(options)
	local ccbFile = "Widget_society_skill_learn.ccbi"
	local callBacks = {
	}
	QUIWidgetSocietySkillLearn.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetSocietySkillLearn:_onTriggerComposite()
end

function QUIWidgetSocietySkillLearn:setInfo(info,parent)
	self._parent = parent
	self._info = info

	self._ccbOwner.skill_tips:setVisible(false)
	self._ccbOwner.skillIconNode:removeAllChildren()
	makeNodeFromGrayToNormal(self._ccbOwner.iconNode)
	makeNodeFromGrayToNormal(self._ccbOwner.btn_levelUp)
	makeNodeFromGrayToNormal(self._ccbOwner.tf_levelUp)
	self._ccbOwner.tf_levelUp:enableOutline() 

	if not info.isOpen then
		if info.nextConfig then
			local sprite = CCSprite:create(info.nextConfig.icon)
			if sprite then
				self._ccbOwner.skillIconNode:addChild(sprite)
			end

			self._ccbOwner.skillName:setString(info.nextConfig.skill_name)
			self._ccbOwner.curLevel:setString(string.format("宗门%d级开启",info.nextConfig.sociaty_lv_require))
			self._ccbOwner.curProp:setString("未学习")
			self._ccbOwner.nextProp:setString(remote.union:getUnionSkillDescribe(info.nextConfig))
			self._ccbOwner.cost:setString(info.nextConfig.contribution_require)
			self._ccbOwner.cost:setVisible(true)
			self._ccbOwner.costIcon:setVisible(true)
		end
	else
		if info.isLearn then
			if info.curConfig then
				local sprite = CCSprite:create(info.curConfig.icon)
				if sprite then
					self._ccbOwner.skillIconNode:addChild(sprite)
				end
				-- makeNodeFromGrayToNormal(self._ccbOwner.iconNode)

				self._ccbOwner.skillName:setString(info.curConfig.skill_name)

				self._ccbOwner.curLevel:setString(string.format("%d/%d",info.skillLevel, info.skillMaxLevel))

				self._ccbOwner.curProp:setString(remote.union:getUnionSkillDescribe(info.curConfig))

				if info.skillLevel >= info.skillMaxLevel then
					makeNodeFromNormalToGray(self._ccbOwner.btn_levelUp)
					makeNodeFromNormalToGray(self._ccbOwner.tf_levelUp)
				end
			end

			if info.nextConfig then
				self._ccbOwner.nextProp:setString(remote.union:getUnionSkillDescribe(info.nextConfig))
				self._ccbOwner.cost:setString(info.nextConfig.contribution_require)
				self._ccbOwner.cost:setVisible(true)
				self._ccbOwner.costIcon:setVisible(true)

				-- set red tips 
				if info.skillLevel < info.skillMaxLevel and remote.user.consortiaMoney >= info.nextConfig.contribution_require then
					self._ccbOwner.skill_tips:setVisible(true)
				end
			else
				self._ccbOwner.nextProp:setString("已满级")
				self._ccbOwner.cost:setVisible(false)
				self._ccbOwner.costIcon:setVisible(false)
				makeNodeFromNormalToGray(self._ccbOwner.btn_levelUp)
				makeNodeFromNormalToGray(self._ccbOwner.tf_levelUp)

				self._ccbOwner.tf_levelUp:disableOutline() 
			end
		else
			if info.nextConfig then
				local sprite = CCSprite:create(info.nextConfig.icon)
				if sprite then
					self._ccbOwner.skillIconNode:addChild(sprite)
				end
				-- makeNodeFromGrayToNormal(self._ccbOwner.iconNode)

				self._ccbOwner.skillName:setString(info.nextConfig.skill_name)

				if info.skillMaxLevel == 0 then
					self._ccbOwner.curLevel:setString("宗主未升级")
				else
					self._ccbOwner.curLevel:setString(string.format("%d/%d",info.skillLevel, info.skillMaxLevel))
				end
				self._ccbOwner.curProp:setString("未学习")
				self._ccbOwner.nextProp:setString(remote.union:getUnionSkillDescribe(info.nextConfig))
				self._ccbOwner.cost:setString(info.nextConfig.contribution_require)
				
				-- set red tips 
				if info.skillLevel < info.skillMaxLevel and remote.user.consortiaMoney >= info.nextConfig.contribution_require then
					self._ccbOwner.skill_tips:setVisible(true)
				end
			end
		end
	end
end

function QUIWidgetSocietySkillLearn:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	return size
end

function QUIWidgetSocietySkillLearn:_onTriggerLevelUp()
    app.sound:playSound("common_small")
	if not self._info.isOpen then
		if self._info.nextConfig then
			app.tip:floatTip(string.format("宗门%d级开启",self._info.nextConfig.sociaty_lv_require)) 
		end
		return
	end

	if self._info.skillLevel >= self._info.skillMaxLevel then
		app.tip:floatTip("魂师大人，你的魂技已升至宗门当前魂技上限！")
		return
	end

	if not  self._info.nextConfig then
		app.tip:floatTip("魂师大人，你的魂技已升至宗门当前魂技上限！")
		return
	end

	local myOfficialPosition = remote.user.userConsortia.rank or SOCIETY_OFFICIAL_POSITION.MEMBER
	if self._info.skillMaxLevel <=  self._info.skillLevel  then
		if myOfficialPosition == SOCIETY_OFFICIAL_POSITION.BOSS then
			app.tip:floatTip("魂师大人，请提升魂技等级上限！")
		else
			app.tip:floatTip("魂师大人，请联系宗主提升魂技等级上限！")
		end
		return
	end

	local skillId = self._info.nextConfig.skill_id
	local contribution = self._info.nextConfig.contribution_require
	
	if remote.user.consortiaMoney < contribution then
    	QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.CONSORTIA_MONEY, nil, nil, false)
		return
	end
	
	local nextProp = remote.union:getUnionSkillDescribe(self._info.nextConfig)

	remote.union:unionSkillLevelUpRequest(skillId, function()
		self._parent:reloadData()
		self._parent:playSkillAnimation(nextProp, 1)
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_SKILL_CHANGE})

	end)
end


return QUIWidgetSocietySkillLearn
