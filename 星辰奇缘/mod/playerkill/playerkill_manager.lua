-- -------------------------------
-- 英雄擂台(跨服单挑)
-- hosr
-- -------------------------------
PlayerkillManager = PlayerkillManager or BaseClass(BaseManager)

function PlayerkillManager:__init()
	if PlayerkillManager.Instance then
		return
	end
	PlayerkillManager.Instance = self
	self.model = PlayerkillModel.New()

	-- 个人数据
	self.myData = nil
	-- 本次匹配的对手数据
	self.enemyData = nil
	-- 本服冠军数据
	self.serverNo1Data = nil
	-- 世界冠军数据
	self.worldNo1Data = nil
	-- 排行榜数据列表
	self.rankData = {}
	-- 匹配展示列表
	self.matchList = {}
	-- 匹配状态
	self.matchStatus = PlayerkillEumn.MatchStatus.None
	-- 活动状态
	self.status = PlayerkillEumn.Status.None
	self.end_time = 0

    -- 缓存上一次界面状态
    self.curr_lev = nil
    self.curr_star = nil
    self.currData = nil
    self.starStatus = {}

	self:InitHandler()

    self.OnStatusUpdate = EventLib.New() -- 活动状态更新
    self.OnDataUpdate = EventLib.New() -- 数据更新
    self.OnMatchShow = EventLib.New() -- 匹配展示
    self.OnMatchSuccess = EventLib.New() -- 匹配成功
    self.OnMatchCancel = EventLib.New() -- 匹配取消
    self.OnRankUpdate = EventLib.New() -- 排行数据更新

    EventMgr.Instance:AddListener(event_name.scene_load, function() self:OnSceneLoad() end)
end

function PlayerkillManager:InitHandler()
    self:AddNetHandler(19300, self.On19300)
    self:AddNetHandler(19301, self.On19301)
    self:AddNetHandler(19302, self.On19302)
    self:AddNetHandler(19303, self.On19303)
    self:AddNetHandler(19304, self.On19304)
    self:AddNetHandler(19305, self.On19305)
    self:AddNetHandler(19306, self.On19306)
    self:AddNetHandler(19307, self.On19307)
    self:AddNetHandler(19308, self.On19308)
    self:AddNetHandler(19309, self.On19309)
    self:AddNetHandler(19310, self.On19310)
end

function PlayerkillManager:RequestInitData()
	-- 个人数据
	self.myData = nil
	-- 本次匹配的对手数据
	self.enemyData = nil
	-- 本服冠军数据
	self.serverNo1Data = nil
	-- 世界冠军数据
	self.worldNo1Data = nil
	-- 排行榜数据列表
	self.rankData = {}
	-- 匹配展示列表
	self.matchList = {}

	self.status = PlayerkillEumn.Status.None
	self.end_time = 0

    self.curr_lev = nil
    self.curr_star = nil
    self.currData = nil
    self.starStatus = {}

	self:Send19308()
    self:Send19300()
	self:Send19309()
end

function PlayerkillManager:OnSceneLoad()
    self.model:CloseMainWindow()
	self.model:CloseMinimizePanel()
	if self.matchStatus == PlayerkillEumn.MatchStatus.Matching then
		self:Send19302()
	end
end

-- 获取玩家擂台信息
function PlayerkillManager:Send19300()
	self:Send(19300, {})
end

function PlayerkillManager:On19300(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
    	
    end
	self.myData = data

	if RoleManager.Instance.RoleData.event == RoleEumn.Event.PlayerkillMatching then
		self.matchStatus = PlayerkillEumn.MatchStatus.Matching
	else
		self.matchStatus = PlayerkillEumn.MatchStatus.None
	end

	self.OnDataUpdate:Fire()
end

-- 参与匹配
function PlayerkillManager:Send19301()
	self:Send(19301, {})
end

function PlayerkillManager:On19301(data)
	-- BaseUtils.dump(data, "19301111111111111111111")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.err_code == 1 then
    	self.matchList = data.rencounter_match_role
    	self.matchStatus = PlayerkillEumn.MatchStatus.Matching
        self.matchStartTime = os.time()
    	self.OnMatchShow:Fire()
    end
end

-- 取消匹配
function PlayerkillManager:Send19302()
	self:Send(19302, {})
end

function PlayerkillManager:On19302(data)
	-- BaseUtils.dump(data, "19302222222222222222222")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.err_code == 1 then
    	self.matchStatus = PlayerkillEumn.MatchStatus.None
    	self.OnMatchCancel:Fire()
    end
end

-- 查询排行信息
function PlayerkillManager:Send19303(type, subtype)
    self.currgroup = subtype
	self:Send(19303, {type = type, group_id = subtype})
end

function PlayerkillManager:On19303(data)
	-- BaseUtils.dump(data, "1930333333333333333333333333333")
    if self.currgroup ~= nil then
        if self.rankData[data.type] == nil then
            self.rankData[data.type] = {}
        end
        self.rankData[data.type][self.currgroup] = data.rencounter_role
    end

	self.OnRankUpdate:Fire()
end

-- 冠军风采
function PlayerkillManager:Send19304()
	self:Send(19304, {})
end

function PlayerkillManager:On19304(data)
	-- BaseUtils.dump(data, "1930444444444444444444444444")
	self.serverNo1Data = data.rencounter_role[1]
	self.worldNo1Data = data.rencounter_role[2]
	-- 打开冠军风采界面
    if data.rencounter_role[1].name == "" or data.rencounter_role[2].name == "" then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前尚无冠军产生"))
        return
    end
	self.model:OpenNo1Show()
end

-- 匹配成功推送
function PlayerkillManager:Send19305()
	self:Send(19305, {})
end

function PlayerkillManager:On19305(data)
	-- BaseUtils.dump(data, "193055555555555555555555555555")
	self.enemyData = data
	self.matchStatus = PlayerkillEumn.MatchStatus.MatchSuccess
	self.OnMatchSuccess:Fire()
end

-- 战斗统计
function PlayerkillManager:Send19306()
	self:Send(19306, {})
end

function PlayerkillManager:On19306(data)
	-- BaseUtils.dump(data, "1930666666666666666666666666666")
	self.model:OpenSettle({data})
end

-- 领取擂台进阶奖励
function PlayerkillManager:Send19307(rank_lev)
	self:Send(19307, {rank_lev = rank_lev})
end

function PlayerkillManager:On19307(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
	if data.err_code == 1 then
	end
end

-- 活动信息
function PlayerkillManager:Send19308()
	self:Send(19308, {})
end

function PlayerkillManager:On19308(data)
	-- BaseUtils.dump(data, "193088888888888888888888888")
    local last_status = self.status
	self.status = data.status
	self.end_time = data.end_time
    data.time = data.end_time - BaseUtils.BASE_TIME
    local cfg_data = DataSystem.data_daily_icon[206]
    if cfg_data.lev > RoleManager.Instance.RoleData.lev then
        return
    end
    MainUIManager.Instance:DelAtiveIcon(206)

    local noticefunc = function()
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("<color='#ffff00'>英雄擂台</color>活动正在进行中，是否前往参加？")
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.cancelSecond = 30
        data.sureCallback = function() self:FindNpc() end
        NoticeManager.Instance:ActiveConfirmTips(data)
    end

    if self.status == PlayerkillEumn.Status.Running then
        if data.time + Time.time <= 0 then
            MainUIManager.Instance:DelAtiveIcon(206)
            self.matchStatus = PlayerkillEumn.MatchStatus.None
            self.OnMatchCancel:Fire()
            return
        end

        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.clickCallBack = function() self:FindNpc() end
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        iconData.timestamp = data.time + Time.time
        iconData.effectId = 20256
        iconData.effectPos = Vector3(0, 32, -400)
        iconData.effectScale = Vector3(1, 1, 1)
        -- iconData.timeoutCallBack = function() self:Send19308() end
        self.icon = MainUIManager.Instance:AddAtiveIcon(iconData)
        if last_status ~= PlayerkillEumn.Status.Running then
            noticefunc()
            self:Send19300()
        end
    else
        self.matchStatus = PlayerkillEumn.MatchStatus.None
    	self.OnMatchCancel:Fire()
    end
	self.OnStatusUpdate:Fire()
end

-- 活动时间
function PlayerkillManager:Send19309()
    self:Send(19309, {})
end

function PlayerkillManager:On19309(data)
    self.timeData = data
    self.OnDataUpdate:Fire()
end

-- 推送擂台信息
function PlayerkillManager:Send19310()
    self:Send(19310, {})
end

function PlayerkillManager:On19310(data)
    if self.myData ~= nil then
        for k,v in pairs(data) do
            self.myData[k] = v
        end
    else
        self.myData = data
        self.myData.rank = 0
    end
    self.OnDataUpdate:Fire()
end

-- ------------------------------------
-- 外部数据接口
-- ------------------------------------
function PlayerkillManager:GetRankData(type, subtype)
    if self.rankData[type] ~= nil and self.rankData[type][subtype] ~= nil then
        return self.rankData[type][subtype]
    end
	self:Send19303(type, subtype)
	return {}
end

function PlayerkillManager:FindNpc()
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    SceneManager.Instance.sceneElementsModel:Self_PathToTarget("83_1")
end
