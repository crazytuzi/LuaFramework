--[[	
	文件名称：QUIDialogSocietyUnionSkill.lua
	创建时间：2016-04-25 11:40:03
	作者：nieming
	描述：QUIDialogSocietyUnionSkill
]]

local QUIDialogBaseUnion = import(".QUIDialogBaseUnion")
local QNavigationController = import("...controllers.QNavigationController")
local QUIDialogSocietyUnionSkill = class("QUIDialogSocietyUnionSkill", QUIDialogBaseUnion)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetSocietySkillLearn = import("..widgets.QUIWidgetSocietySkillLearn")
local QUIWidgetSocietySkillManage = import("..widgets.QUIWidgetSocietySkillManage")
local QListView = import("...views.QListView")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

--初始化
QUIDialogSocietyUnionSkill.Learn_Tab = "Learn_Tab"
QUIDialogSocietyUnionSkill.Manage_Tab = "Manage_Tab"
function QUIDialogSocietyUnionSkill:ctor(options)
	local ccbFile = "Dialog_society_skill.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerSkillLearn", callback = handler(self, QUIDialogSocietyUnionSkill._onTriggerSkillLearn)},
		{ccbCallbackName = "onTriggerSkillManage", callback = handler(self, QUIDialogSocietyUnionSkill._onTriggerSkillManage)},
	}
	QUIDialogSocietyUnionSkill.super.ctor(self,ccbFile,callBacks,options)
	self._ccbOwner.frame_tf_title:setString("宗门魂技")
end


function QUIDialogSocietyUnionSkill:_init( options )
	-- body
	if not options then
    	options = {}
    end
    app:getUserOperateRecord():setUnionSkillClickedTime()
    self._curSelectTab = options.selectTab or QUIDialogSocietyUnionSkill.Learn_Tab
    self:getData()
    self:render()
    self:updateData()
end

function QUIDialogSocietyUnionSkill:updateData(  )
    -- body
    remote.union:unionOpenRequest(function (  )
        -- body
        if self._appear and self._listView then
    		self:reloadData()
        end
    end)

end

function QUIDialogSocietyUnionSkill:reloadData(  )
	-- body
	self:getData()
    self._listView:refreshData()
end

function QUIDialogSocietyUnionSkill:getData( )
	-- body
	self._data = {}

	local tempConfigs = QStaticDatabase.sharedDatabase():getUnionSkillConfigs()
	local configs = {}
	for k, v in pairs(tempConfigs) do
		table.insert(configs, v)
	end
	table.sort(configs,function( a,b)
		return a[1].skill_id < b[1].skill_id
	end)

	local tempData 
	local isOpen
	if configs then
		if self._curSelectTab == QUIDialogSocietyUnionSkill.Manage_Tab then
			for _, v in pairs(configs) do
				local skillId = v[1].skill_id
				tempData = {}
				isOpen = false
				local maxLevelLimit = QStaticDatabase.sharedDatabase():getUnionSkillMaxLimitLevel(skillId, remote.union.consortia.level)
				for k1,v1 in pairs(remote.union.consortia.consortiaSkillList or {} ) do
					if tonumber(skillId) == tonumber(v1.skillId) then
						tempData.skillMaxLevel = v1.skillMaxLevel
						tempData.maxLevelLimit = maxLevelLimit
						tempData.curConfig = QStaticDatabase.sharedDatabase():getUnionSkillConfigByLevel(v1.skillId, v1.skillMaxLevel)
						tempData.nextConfig = QStaticDatabase.sharedDatabase():getUnionSkillConfigByLevel(v1.skillId, v1.skillMaxLevel + 1)
						tempData.isOpen = true
						isOpen = true
						
						break
					end
				end
				if not isOpen then
					tempData.isOpen = false
					tempData.maxLevelLimit = maxLevelLimit
					tempData.nextConfig = QStaticDatabase.sharedDatabase():getUnionSkillConfigByLevel(skillId, 1)
				end
				table.insert(self._data, tempData)
			end
		else
			local isLearn = false	
			for _, v in pairs(configs) do
				local skillId = v[1].skill_id
				tempData = {}
				isOpen = false	
				isLearn = false
				for k1,v1 in pairs(remote.user.userConsortiaSkill or {} ) do
					tempData = {}
					if tonumber(skillId) == tonumber(v1.skillId) then
						tempData.skillLevel = v1.skillLevel
						tempData.curConfig = QStaticDatabase.sharedDatabase():getUnionSkillConfigByLevel(v1.skillId, v1.skillLevel)
						tempData.nextConfig = QStaticDatabase.sharedDatabase():getUnionSkillConfigByLevel(v1.skillId, v1.skillLevel + 1)
						isLearn = true
						isOpen = true
						break
					end
				end

				for k1,v1 in pairs(remote.union.consortia.consortiaSkillList or {} ) do
					if tonumber(skillId) == tonumber(v1.skillId) then
						tempData.skillMaxLevel = v1.skillMaxLevel
						isOpen = true
						break
					end
				end
				tempData.skillMaxLevel = tempData.skillMaxLevel or 0
				tempData.skillLevel = tempData.skillLevel or 0
				tempData.isLearn = isLearn
				tempData.isOpen = isOpen
				if not isLearn then
					tempData.nextConfig = QStaticDatabase.sharedDatabase():getUnionSkillConfigByLevel(skillId, 1)
				end
				table.insert(self._data, tempData)
			end
		end
	end
	-- printTable(self._data)
end

function QUIDialogSocietyUnionSkill:render(  )
	local cfg 
	if self._curSelectTab == QUIDialogSocietyUnionSkill.Learn_Tab then
		self._ccbOwner.btn_learn:setEnabled(false)
		self._ccbOwner.tf_learn:setColor(COLORS.S)
		self._ccbOwner.btn_manage:setEnabled(true)
		self._ccbOwner.tf_manage:setColor(COLORS.T)
		cfg = {
 			renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	            local item = list:getItemFromCache()
	            local data = self._data[index]
	            if not item then
	                item = QUIWidgetSocietySkillLearn.new()
	                isCacheNode = false
	            end
	            -- 渲染代码
	            
	            --回传的参数
	            info.item = item
	            info.size = item:getContentSize()
	            item:setInfo(data,self)
	            list:registerBtnHandler(index,"btn_levelUp", "_onTriggerLevelUp", nil, true)

            	return isCacheNode
        	end,
        	enableShadow = false,
	        totalNumber = #self._data,
		}
	else
		self._ccbOwner.btn_learn:setEnabled(true)
		self._ccbOwner.tf_learn:setColor(COLORS.T)
		self._ccbOwner.btn_manage:setEnabled(false)
		self._ccbOwner.tf_manage:setColor(COLORS.S)

		cfg = {
 			renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	            local item = list:getItemFromCache()
	            local data = self._data[index]
	            if not item then
	                item = QUIWidgetSocietySkillManage.new()
	                isCacheNode = false
	            end
	            -- 渲染代码
	            
	            --回传的参数
	            info.item = item

	            info.size = item:getContentSize()
	            item:setInfo(data,self)
	           	list:registerBtnHandler(index,"btn_levelUp", "_onTriggerLevelUp", nil, true)

            	return isCacheNode
        	end,
        	enableShadow = false,
	        totalNumber = #self._data,
		}
	end

	if not self._listView then
		self._listView = QListView.new(self._ccbOwner.listView,cfg)
	else
		cfg.isCleanUp = true
		self._listView:reload(cfg)
	end 

end

function QUIDialogSocietyUnionSkill:_onTriggerSkillLearn(  )
    app.sound:playSound("common_switch")
	self._curSelectTab = QUIDialogSocietyUnionSkill.Learn_Tab
	self:getData()
	self:render()

end

function QUIDialogSocietyUnionSkill:_onTriggerSkillManage(  )
    app.sound:playSound("common_switch")
	self._curSelectTab = QUIDialogSocietyUnionSkill.Manage_Tab
	self:getData()
	self:render()
end

--describe：viewAnimationOutHandler 
function QUIDialogSocietyUnionSkill:viewAnimationOutHandler()
	--代码
end

--describe：viewDidAppear 
function QUIDialogSocietyUnionSkill:viewDidAppear()
	--代码
	QUIDialogSocietyUnionSkill.super.viewDidAppear(self)

end

--describe：viewWillDisappear 
function QUIDialogSocietyUnionSkill:viewWillDisappear()
	--代码
	QUIDialogSocietyUnionSkill.super.viewWillDisappear(self)


end

function QUIDialogSocietyUnionSkill:playSkillAnimation( name,animationType )
	-- body
	if not self._effect then
		self._effect =  QUIWidgetAnimationPlayer.new()
		self._ccbOwner.effectNode:addChild(self._effect)
	
	end
	self._effect:stopAnimation()

	self._effect:playAnimation("ccb/effects/SkillUpgarde2.ccbi", function (ccbOwner)
        
       	if animationType == 2 then
       		ccbOwner.title_skill:setString(name.."魂技上限+1")
       		ccbOwner.node_1:setVisible(false)
       	else
       		ccbOwner.title_skill:setString("魂技等级+1")
       		ccbOwner.tf_desc1:setString(name)
       	end
       
    end)
end

--describe：viewAnimationInHandler 
--function QUIDialogSocietyUnionSkill:viewAnimationInHandler()
	----代码
--end

--describe：_backClickHandler 
--function QUIDialogSocietyUnionSkill:_backClickHandler()
	----代码
--end

return QUIDialogSocietyUnionSkill
