--[[	
	文件名称：QUIWidgetSocietySkillManage.lua
	创建时间：2016-04-16 15:19:54
	作者：nieming
	描述：QUIWidgetSocietySkillManage
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSocietySkillManage = class("QUIWidgetSocietySkillManage", QUIWidget)
local QNotificationCenter = import("...controllers.QNotificationCenter")

--初始化
function QUIWidgetSocietySkillManage:ctor(options)
	local ccbFile = "Widget_society_skill_manage.ccbi"
	local callBacks = {
	}
	QUIWidgetSocietySkillManage.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetSocietySkillManage:_onTriggerComposite()
end

function QUIWidgetSocietySkillManage:setInfo(info,parent)
	self._parent = parent
	self._info = info
	self._ccbOwner.skillIconNode:removeAllChildren()
	local myOfficialPosition = remote.user.userConsortia.rank or SOCIETY_OFFICIAL_POSITION.MEMBER

	self._ccbOwner.tf_next_level:setString("")
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
			self._ccbOwner.cost:setString(string.format("消耗%d宗门经验",info.nextConfig.sociaty_exp_require) )
			self._ccbOwner.cost:setVisible(true)
		end
	else

		if info.curConfig then

			local sprite = CCSprite:create(info.curConfig.icon)
			if sprite then
				self._ccbOwner.skillIconNode:addChild(sprite)
			end
			-- makeNodeFromGrayToNormal(self._ccbOwner.iconNode)

			self._ccbOwner.skillName:setString(info.curConfig.skill_name)
			-- self._ccbOwner.curLevel:setString(string.format("%d/%d",info.skillMaxLevel, info.maxLevelLimit))
			self._ccbOwner.curLevel:setString(info.skillMaxLevel)
			self._ccbOwner.curProp:setString(remote.union:getUnionSkillDescribe(info.curConfig))
		else
			-- self._ccbOwner.curLevel:setString(string.format("%d/%d",info.skillMaxLevel, info.maxLevelLimit))
			self._ccbOwner.curLevel:setString(info.skillMaxLevel)
			self._ccbOwner.curProp:setString("未提升")

		end

		if info.nextConfig then
			if not info.curConfig then
				local sprite = CCSprite:create(info.nextConfig.icon)
				if sprite then
					self._ccbOwner.skillIconNode:addChild(sprite)
				end
				-- makeNodeFromGrayToNormal(self._ccbOwner.iconNode)
				self._ccbOwner.skillName:setString(info.nextConfig.skill_name)
			end
			self._ccbOwner.nextProp:setString(remote.union:getUnionSkillDescribe(info.nextConfig))
			self._ccbOwner.cost:setString(string.format("消耗%d宗门经验",info.nextConfig.sociaty_exp_require) )
			self._ccbOwner.cost:setVisible(true)

			self._ccbOwner.node_btn_up:setVisible(true)
			if  self._info.maxLevelLimit <=  self._info.skillMaxLevel  then
				self._ccbOwner.node_btn_up:setVisible(false)
				self._ccbOwner.tf_next_level:setString(string.format("%d级宗门可提升魂技等级上限",info.nextConfig.sociaty_lv_require))
			end
		else
			self._ccbOwner.nextProp:setString("已满级")
			self._ccbOwner.cost:setVisible(false)
		end

		makeNodeFromGrayToNormal(self._ccbOwner.iconNode)
		if myOfficialPosition ~= SOCIETY_OFFICIAL_POSITION.BOSS then --or remote.union.consortia.exp < self._info.nextConfig.sociaty_exp_require 
			makeNodeFromNormalToGray(self._ccbOwner.node_btn_up)
			self._ccbOwner.tf_levelUp:disableOutline()
		else
			makeNodeFromGrayToNormal(self._ccbOwner.node_btn_up)
			self._ccbOwner.tf_levelUp:enableOutline()
		end
	end
end

function QUIWidgetSocietySkillManage:_onTriggerLevelUp(  )
    app.sound:playSound("common_small")
	local myOfficialPosition = remote.user.userConsortia.rank or SOCIETY_OFFICIAL_POSITION.MEMBER

	if myOfficialPosition ~= SOCIETY_OFFICIAL_POSITION.BOSS then
		app.tip:floatTip("只有宗主才可以提升魂技上限") 
		return
	end
	
	if not self._info.isOpen then
		if self._info.nextConfig then
			app.tip:floatTip(string.format("宗门%d级开启",self._info.nextConfig.sociaty_lv_require)) 
		end
		return
	end

	if not  self._info.nextConfig then
		app.tip:floatTip("宗主，你宗门的魂技已经达到上限！") 
		return
	end

	if  self._info.maxLevelLimit <=  self._info.skillMaxLevel  then
		app.tip:floatTip("宗主，你宗门的魂技已经达到上限，提升宗门等级可以增加上限哦！") 
		return
	end
	
	if remote.union.consortia.exp < self._info.nextConfig.sociaty_exp_require then
		app.tip:floatTip("宗门经验不足！") 
		return
	end
	local skillId = self._info.nextConfig.skill_id
	local name = self._info.nextConfig.skill_name
	remote.union:unionSkillLimitLevelUpRequest( skillId,function(  )
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_WIDGET_NAME_UPDATE})
		self._parent:reloadData()
		self._parent:playSkillAnimation(name, 2)
	end)
end

function QUIWidgetSocietySkillManage:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	return size
end

return QUIWidgetSocietySkillManage
