-- ---------------------------------
-- 队伍招募处理
-- hosr
-- ---------------------------------
TeamMatchManager = TeamMatchManager or BaseClass()

function TeamMatchManager:__init()
	if TeamMatchManager.Instance then
		return
	end
	TeamMatchManager.Instance = self

	self.cancelCall = function() self:Cancel() end
	self.sureCall = function() self:Sure() end
	self.canNotice = true
	self.currentId = 0
	self.currentNoticeData = nil
	self.matchTab = {}
	self.timeId = nil -- 提示冷却
	self.timeId1 = nil -- 世界冷却
	self.canWorld = true
end

function TeamMatchManager:ShowMatch(data)
	for i,v in ipairs(data.add) do
		if self.matchTab[v.id] == nil then
			self.matchTab[v.id] = v
			-- 检查是否可以弹出提示
			if self:CheckNotice(v.lev_min, v.lev_max) then
				-- 冷却完
				if self.canNotice and self:CheckType(v.team_type) then
					self.currentId = v.id
					self.canNotice = false
					self:Notice(v)
				end

				-- -- 检查是否可以在世界频道上显示
				-- if self.canWorld then
				-- 	self.canWorld = false
				-- 	self:WorldShow(v)
				-- end
			end
		end
	end

	-- 暂时不需要更新
	-- for i,v in ipairs(data.update) do
	-- end

	for i,v in ipairs(data.del) do
		self.matchTab[v.id] = nil
		if self.currentId == v.id then
			self.currentId = 0
			if NoticeManager.Instance.isMatchNotice then
				self:CloseNotice()
			end
		end
	end
end

-- 检查类型是否提示
function TeamMatchManager:CheckType(id)
	local dt = DataTeam.data_match[id]
	if dt ~= nil then
		local type = dt.type
		if type == 3 or type == 4 or type == 5 or type == 9 or type == 28 or dt.tab_id == 15 or type == 60 then
			return true
		end
	end
	return false
end

-- 检查是否弹出提示框
function TeamMatchManager:CheckNotice(minLev, maxLev)
	local role = RoleManager.Instance.RoleData
	if role.event == RoleEumn.Event.None -- 不在活动中
		and role.status == RoleEumn.Status.Normal -- 非战斗中
		and role.drama_status == RoleEumn.DramaStatus.None -- 非剧情中
		and role.team_status == RoleEumn.TeamStatus.None -- 没队伍状态
		and role.lev >= minLev and role.lev <= maxLev -- 自身等级达到招募等级
		and (CanYonManager.Instance.collection == nil or (CanYonManager.Instance.collection ~= nil and CanYonManager.Instance.collection.running == false) ) --没有在峡谷之巅采集中
		and (SceneManager.Instance.sceneElementsModel.collection == nil or (SceneManager.Instance.sceneElementsModel.collection ~= nil and SceneManager.Instance.sceneElementsModel.collection.running == false)) --没有在普通采集
		then
		return true
	end
	return false
end

function TeamMatchManager:Notice(data)
	self.canNotice = false
	self.currentNoticeData = data

    local td = DataTeam.data_match[data.team_type]
    local typeName = TI18N("任务中")
    if td ~= nil then
        if td.type ~= 60 then
            typeName = td.type_name
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.cancelSecond = 10
            confirmData.sureLabel = TI18N("加入")
            confirmData.cancelLabel = TI18N("不再提示")
            confirmData.sureCallback = self.sureCall
            confirmData.cancelCallback = self.cancelCall
            confirmData.cancelNoCancel = true
            confirmData.content = string.format(TI18N("<color='#31f2f9'>%s</color>在<color='#ffff00'>%s</color>中需要你的帮助"), data.name, typeName)
            NoticeManager.Instance:ConfirmTips(confirmData)
            NoticeManager.Instance.isMatchNotice = true
            self:BeginTime(20000)
        else
         self.canNotice = true
        end
    end
    
end

function TeamMatchManager:CloseNotice()
    if NoticeManager.Instance.isMatchNotice then
    	NoticeManager.Instance:CloseConfrimTips()
    end
end

function TeamMatchManager:Sure()
	if self.currentNoticeData ~= nil then
		TeamManager.Instance:Send11724(self.currentNoticeData.rid, self.currentNoticeData.platform, self.currentNoticeData.zone_id)
		self.currentNoticeData = nil
	end
end

function TeamMatchManager:Cancel()
    self:BeginTime(600000)
end

-- 提示冷却
function TeamMatchManager:BeginTime(time)
	self:EndTime()
	self.timeId = LuaTimer.Add(time, function() self:TimeOver() end)
end

function TeamMatchManager:EndTime()
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
end

function TeamMatchManager:TimeOver()
	self:EndTime()
	self.canNotice = true
end

-- 世界冷却
function TeamMatchManager:BeginTime1()
	self:EndTime1()
	self.canWorld = false
	self.timeId1 = LuaTimer.Add(60000, function() self:TimeOver1() end)
end

function TeamMatchManager:EndTime1()
	if self.timeId1 ~= nil then
		LuaTimer.Delete(self.timeId1)
		self.timeId1 = nil
	end
end

function TeamMatchManager:TimeOver1()
	self:EndTime1()
	self.canWorld = true
end

function TeamMatchManager:WorldShow(data)
	-- 检查是否可以在世界频道上显示
	if self.canWorld then
		if RoleManager.Instance.RoleData.cross_type == 0 then
			if self:CheckType(data.type) then
				-- self.canWorld = false
				self:SendChatData(data.type)
			end
		else
			if data.type == StarChallengeManager.Instance.model:GetTeamType() or data.type == ApocalypseLordManager.Instance.model:GetTeamType() then
				self:SendChatData(data.type)
			end
		end
	end
end

function TeamMatchManager:SendChatData(type)
    ChatManager.Instance:Send10419(type)
    -- self:BeginTime1()
end