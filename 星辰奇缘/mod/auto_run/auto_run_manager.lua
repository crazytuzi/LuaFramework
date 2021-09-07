-- ---------------------------------
-- 新手自动跑任务剧情
-- hosr
-- 前15级如果操作闲置，6s后自动点任务
-- ---------------------------------
AutoRunManager = AutoRunManager or BaseClass(BaseManager)

function AutoRunManager:__init()
	if AutoRunManager.Instance then
		return
	end
	AutoRunManager.Instance = self

	self.isOpen = true
	self.levLimit = 1
	self.timeLimit = 6000

	self.timeId = nil
	self.timeOut = function() self:AutoRun() end
	self.mainui = function() self:OnMainUILoad() end
	self.mapClick = function() self:OnMapClick() end
	self.levChange = function() self:OnLevelChange() end
	self.beginFight = function() self:OnBeginFight() end
	EventMgr.Instance:AddListener(event_name.self_loaded, self.mainui)
	self.isInit = false
	self.running = false
end

function AutoRunManager:OnTick()
	if not self.isInit then
		return
	end

	if not self.isOpen then
		return
	end

	if self.running then
		return
	end

	if self:Check() then
		self:RunTime()
	end
end

function AutoRunManager:OnMainUILoad()
	self.isInit = true
	EventMgr.Instance:RemoveListener(event_name.self_loaded, self.mainui)
	if RoleManager.Instance.RoleData.lev <= self.levLimit then
		ModuleManager.Instance.autoRunCall = function() self:OnTick() end
		EventMgr.Instance:AddListener(event_name.role_level_change, self.levChange)
		EventMgr.Instance:AddListener(event_name.map_click, self.mapClick)
		EventMgr.Instance:AddListener(event_name.begin_fight, self.beginFight)
		EventMgr.Instance:AddListener(event_name.end_fight, self.beginFight)
	end
end

function AutoRunManager:OnLevelChange()
	if RoleManager.Instance.RoleData.lev > self.levLimit then
		ModuleManager.Instance.autoRunCall = nil
		EventMgr.Instance:RemoveListener(event_name.role_level_change, self.levChange)
	end
end

function AutoRunManager:OnMapClick()
	self:ClearTime()
end

function AutoRunManager:OnBeginFight()
	self:ClearTime()
end

function AutoRunManager:ClearTime()
	self.running = false
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
end

function AutoRunManager:RunTime()
	self:ClearTime()

	self.running = true
	self.timeId = LuaTimer.Add(self.timeLimit, self.timeOut)
end

-- 跑主线或者剧情下一步
function AutoRunManager:AutoRun()
	self.running = false
	if self:Check() then
		QuestManager.Instance:DoMain()
	end
end

function AutoRunManager:Check()
	if CombatManager.Instance.isFighting then
		return false
	end

	if BaseUtils.IsVerify then
        -- 审核服不自动
        return false
	end
	
	if RoleManager.Instance.RoleData.status ~= RoleEumn.Status.Normal then
		return false
	end

	if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.None then
		return false
	end

	if RoleManager.Instance.RoleData.team_status ~= RoleEumn.TeamStatus.None then
		return false
	end

	-- 剧情中
	if RoleManager.Instance.RoleData.drama_status == RoleEumn.DramaStatus.Running then
		return false
	end

	-- 有窗口打开
	if WindowManager.Instance.currentWin ~= nil and WindowManager.Instance.currentWin.isOpen then
		return false
	end

	-- 移动中
	if SceneManager.Instance.sceneElementsModel.self_view ~= nil and #SceneManager.Instance.sceneElementsModel.self_view.TargetPositionList > 0 then
		return false
	end

	-- 对话中
	if MainUIManager.Instance.dialogModel.isOpenning then
		return false
	end

	-- 有快捷使用
	if NoticeManager.Instance:HasAuto() then
		return false
	end

	-- 在家园
    if HomeManager.Instance.isHomeCanvasShow then
        return false
    end

    return true
end
