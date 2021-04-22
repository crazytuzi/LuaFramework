
--同步阵容主界面
--qinsiyang

local QUIDialog = import(".QUIDialog")
local QUIDialogSyncFormation = class("QUIDialogSyncFormation", QUIDialog)
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetSyncFormation = import("..widgets.QUIWidgetSyncFormation")
local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogSyncFormation:ctor(options)
	local ccbFile = "ccb/Dialog_SyncFormation.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerSync", callback = handler(self, self._onTriggerSync)},
		{ccbCallbackName = "onTriggerAttack", callback = handler(self, self._onTriggerAttack)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSyncFormation.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self._onlyAttack = false
  	print("self._curTeamKey ="..options.teamKey)
    self._curTeamKey = options.teamKey
    self._teamType = options.teamType
    -- QPrintTable(options)
    self._teams = options.teams
	self._callback = options.callback

	self._battleType = nil

	self._cuTeamInfo = {}
    q.setButtonEnableShadow(self._ccbOwner.btn_sync)
    self._ccbOwner.node_btn_onlyAttack:setVisible(false)
	self:refreshData()
	self:setInfo()	
	self:initListView()
end

function QUIDialogSyncFormation:viewDidAppear()
	QUIDialogSyncFormation.super.viewDidAppear(self)


end

function QUIDialogSyncFormation:viewWillDisappear()
	QUIDialogSyncFormation.super.viewWillDisappear(self)
end

function QUIDialogSyncFormation:setInfo()

	self._ccbOwner.frame_tf_title:setString("阵容同步")
	if self._cuTeamInfo and not q.isEmpty(self._cuTeamInfo) then 
		local curIcon =  QUIWidgetSyncFormation.new()
		self._ccbOwner.node_cur:addChild(curIcon)
		curIcon:setInfo(self._cuTeamInfo,0)
		curIcon:setSelectNodeVisible(false)
		curIcon:resetMainNodePosition()
	end
	self._ccbOwner.node_arrow:setVisible(true)

	-- if #self._data >= 6 then
	-- 	self._ccbOwner.node_arrow:setVisible(true)
	-- else
	-- 	self._ccbOwner.node_arrow:setVisible(false)
	-- end

end

function QUIDialogSyncFormation:refreshData()
	self._data = {}

--[[
	name -玩法名称
	resIdx -icon QRES中sync_formation_icon_idx 的 索引id
	attack_keys  攻击阵容teamIdx 数组
	defence_keys  防守阵容teamIdx 数组
	checkTime  是否需要时间检测
]]

	self._cuTeamInfo = {}
	local localData = self:_getInfoByLocalData()
	if self._teamType == 1 then
		for i,config in ipairs(remote.teamManager.teamSingleConfigs) do
			-- QPrintTable(config)
			local info = self:transferData(config,localData,i)
			if info ~= nil then
				table.insert(self._data,info)
				self:handleSelfInfo(config)
			end
		end
	elseif self._teamType == 2 then
		for i,config in ipairs(remote.teamManager.teamDoubleConfigs) do
			local info = self:transferData(config,localData,i)
			if info ~= nil then
				table.insert(self._data,info)
				self:handleSelfInfo(config)
			end
		end		

	elseif self._teamType == 3 then
		for i,config in ipairs(remote.teamManager.teamSotoConfigs) do
			-- QPrintTable(config)
			local info = self:transferData(config,localData,i)
			if info ~= nil then
				table.insert(self._data,info)
				-- QPrintTable(info)
				self:handleSelfInfo(config)
			end
		end
	end

	-- QPrintTable(self._cuTeamInfo)
end

function QUIDialogSyncFormation:handleSelfInfo(config)
	if q.isEmpty(self._cuTeamInfo) then
		for k,teamkey in pairs(config.attack_keys or {}) do
			if self._curTeamKey == teamkey then
				if config.isUnion  then
					if remote.union:checkHaveUnion() == false then
						app.tip:floatTip("您已离开工会，无法同步阵容")
				        self:_onTriggerClose()
				        return 
				    end
				end

				self._cuTeamInfo.name = config.name
				self._cuTeamInfo.icon = QResPath("sync_formation_icon_idx")[config.resIdx]
				self._cuTeamInfo.fontSize = config.fontSize and config.fontSize or 22
				self._battleType = config.battleType

				return
			end
		end
		for k,teamkey in pairs(config.defence_keys or {}) do
			if self._curTeamKey == teamkey then
				if config.isUnion  then
					if remote.union:checkHaveUnion() == false then
						app.tip:floatTip("您已离开工会，无法同步阵容")
				        self:_onTriggerClose()
				        return 
				    end
				end
				self._cuTeamInfo.name = config.name
				self._cuTeamInfo.icon = QResPath("sync_formation_icon_idx")[config.resIdx]
				self._cuTeamInfo.fontSize = config.fontSize and config.fontSize or 22
				self._battleType = config.battleType
				return
			end
		end
	end
end



function QUIDialogSyncFormation:transferData(config,localData,i)

	if config.unlock  then
	    if not app.unlock:checkLock(config.unlock, false)  then
	        return nil
	    end
	end

	if config.isUnion  then
		if remote.union:checkHaveUnion() == false then
	        return nil
	    end
	end

	local info = {}
	info.idx = i
	info.name = config.name
	info.icon = QResPath("sync_formation_icon_idx")[config.resIdx]
	local isSelect = false

	local lock = false
	if config.checkTime then
		if BattleTypeEnum.SILVES_ARENA == config.battleType then
			if not remote.silvesArena:checkCanChangeTeam() then
				lock = true
			end
		elseif BattleTypeEnum.SANCTUARY_WAR == config.battleType then
			local can = remote.sanctuary:checkCanSaveFormation()
			if not can then
				lock = true
			end
		elseif BattleTypeEnum.KUAFU_MINE == config.battleType then
			if ENABLE_PLUNDER then
				local timeStr, color, isActive, isOpen = remote.plunder:updateTime()
				if isOpen == false then
					lock = true
				end
			end
		end
	end

	if not lock then
		for k,v in pairs(localData or {}) do
			if v == config.name then
				isSelect = true
				break
			end
		end
	end
	info.isSelect = isSelect
	info.isLock = lock
	info.fontSize = config.fontSize and config.fontSize or 22
	return info
end

function QUIDialogSyncFormation:initListView(notReset)
	if self._listViewLayout and not notReset then
		self._listViewLayout:setContentSize(self._ccbOwner.sheet_content:getContentSize())
		self._listViewLayout:resetTouchRect()
	end
	if not self._listViewLayout then

		local cfg = {
			renderItemCallBack = handler(self, self._renderCallBack),
	        curOriginOffset = 0,
	        contentOffsetX = 0,
	        curOffset = 0,
	        enableShadow = true,
	      	ignoreCanDrag = true,
	      	spaceY = 0,
	      	spaceX = 0,
            leftShadow = self._ccbOwner.arrowLeft,
            rightShadow = self._ccbOwner.arrowRight,
      		shadowIsNode = true,
	      	isVertical = false,
	        totalNumber = #self._data,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_content,cfg)
	else
		self._listViewLayout:refreshData() 
	end
end


function QUIDialogSyncFormation:_renderCallBack(list, index, info )
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache()
    if not item then
		item = QUIWidgetSyncFormation.new()
		item:addEventListener(QUIWidgetSyncFormation.EVENT_CLICK_SELECT, handler(self, self._onEvent))
    	isCacheNode = false
    end
    item:setInfo(itemData,index)
    info.item = item
    info.size = item:getContentSize()
    list:registerBtnHandler(index, "btn_click", "_onTriggerClick")
    return isCacheNode
end

function QUIDialogSyncFormation:_onEvent(event)
	local index = event.index
	if self._data[index] == nil then
		return
	end

	if self._data[index].isLock then
		app.tip:floatTip("玩法未开启或当前时间段无法同步阵容")
		return
	end
	self._data[index].isSelect = not self._data[index].isSelect
	self:initListView(true)
end

function QUIDialogSyncFormation:_onTriggerSync(event)
	app.sound:playSound("common_small")
	local selecIds = {}
	for i,v in ipairs(self._data) do
		if v.isSelect then
			table.insert(selecIds,v.idx)
		end
	end
	if q.isEmpty(selecIds) then
		app.tip:floatTip("没有需要同步的阵容，请自行勾选")
		return
	end

	local battleFormationList = {}
	for i,v in ipairs(self._teams) do
		battleFormationList[i] = remote.teamManager:encodeBattleFormation(v)
	end
	--刷本地
	local configList = {}
	for i,v in ipairs(selecIds) do
		local config = {}
		if self._teamType == 1 then
			config = remote.teamManager.teamSingleConfigs[v]
			table.insert(configList,config)
		elseif self._teamType == 2 then
			config = remote.teamManager.teamDoubleConfigs[v]
			table.insert(configList,config)
		elseif self._teamType == 3 then
			config = remote.teamManager.teamSotoConfigs[v]
			table.insert(configList,config)
		end
	end
	if q.isEmpty(configList) then
		app.tip:floatTip("没有需要同步的阵容，请自行勾选")
		return		
	end
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER, nil)
	self:_saveToLocal()
 	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSyncInfoList",
   		options = {configList = configList, teams = self._teams , battleFormationList = battleFormationList , battleType = self._battleType
   		, onlyAttack = self._onlyAttack ,teamType = self._teamType }}, {isPopCurrentDialog = true})
end

function QUIDialogSyncFormation:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
	if self._callback then
		self._callback()
	end

end


function QUIDialogSyncFormation:_onTriggerAttack()
	app.sound:playSound("common_small")
	self._onlyAttack = true

	self._ccbOwner.node_btn_onlyAttack:setVisible(false)

end

-- function QUIDialogSyncFormation:_getTeamLocalKey()
-- 	local ketStr = ""
-- 	if self._teamType == 1 then
-- 		ketStr= "SINGLE_SYNC"..tostring(remote.user.userId)
-- 	else
-- 		ketStr= "DOUBLE_SYNC"..tostring(remote.user.userId)
-- 	end
-- 	return ketStr
-- end

function QUIDialogSyncFormation:_saveToLocal()
	local str = ""
	for i,v in ipairs(self._data) do
		if v.isSelect then
			str = str..v.name.."|"
		end
	end
	if self._teamType == 1 then
		app:getUserOperateRecord():setSyncFormationSingleSetting(str)
	else
		app:getUserOperateRecord():setSyncFormationDoubleSetting(str)
	end
	-- local ketStr = self:_getTeamLocalKey()
	-- app:getUserData():setUserValueForKey(ketStr, str)
end

function QUIDialogSyncFormation:_getInfoByLocalData()
	-- local ketStr = self:_getTeamLocalKey()
	-- local selecIdsStr = app:getUserData():getUserValueForKey(ketStr)
	local selecIdsStr = ""
	if self._teamType == 1 then
		selecIdsStr = app:getUserOperateRecord():getSyncFormationSingleSetting(str)
	else
		selecIdsStr = app:getUserOperateRecord():getSyncFormationDoubleSetting(str)
	end
	local arr1 = string.split(selecIdsStr, "|") or {}
	return arr1
end


return QUIDialogSyncFormation


