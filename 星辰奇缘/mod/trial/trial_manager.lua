-- ----------------------------------------------------------
-- 逻辑模块 - 极寒试炼
-- ----------------------------------------------------------
TrialManager = TrialManager or BaseClass(BaseManager)

function TrialManager:__init()
    if TrialManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	TrialManager.Instance = self

    self.model = TrialModel.New()

    self:InitHandler()
end

function TrialManager:__delete()
end

function TrialManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(13100, self.On13100)
    self:AddNetHandler(13101, self.On13101)
    self:AddNetHandler(13102, self.On13102)
    self:AddNetHandler(13103, self.On13103)
    self:AddNetHandler(13104, self.On13104)
    self:AddNetHandler(13105, self.On13105)
    self:AddNetHandler(13106, self.On13106)
    self:AddNetHandler(13107, self.On13107)
    self:AddNetHandler(13108, self.On13108)
end

-------------------------------------------
-------------------------------------------
------------- 协议处理 -----------------
-------------------------------------------
-------------------------------------------

function TrialManager:Send13100()
    -- print("Send13100")
    Connection.Instance:send(13100, { })
end

function TrialManager:On13100(data)
    -- print("On13100")
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On13100(data)
end

function TrialManager:Send13101(mode)
	Connection.Instance:Send(13101, { mode = mode })
end

function TrialManager:On13101(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On13101(data)
end

function TrialManager:Send13102()
    Connection.Instance:Send(13102, { })
end

function TrialManager:On13102(data)
    self.model:On13102(data)
end

function TrialManager:Send13103()
    Connection.Instance:Send(13103, { })
end

function TrialManager:On13103(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TrialManager:Send13104()
    Connection.Instance:Send(13104, { })
end

function TrialManager:On13104(data)
    if data.flag == 1 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.trialwindow)
        MainUIManager.Instance.mainuitracepanel:AutoShowType()
    elseif data.flag == 0 or data.flag == 2 then
       self.model:ShowReward(data)
    end
end

function TrialManager:Send13105(rid, platform, zone_id)
    -- print("Send13105")
    Connection.Instance:Send(13105, { rid = rid, platform = platform, zone_id = zone_id })
end

function TrialManager:On13105(data)
    -- print("On13105")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TrialManager:Send13106()
    -- print("Send13106")
    Connection.Instance:Send(13106, { })
end

function TrialManager:On13106(data)
    -- print("On13106")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TrialManager:Send13107(rid, platform, zone_id, type)
    -- print("Send13107")
    Connection.Instance:Send(13107, { rid = rid, platform = platform, zone_id = zone_id, type = type })
end

function TrialManager:On13107(data)
    -- print("On13107")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TrialManager:On13108(data)
    -- print("On13108")
    self.model:seekHelp(data)

    -- TrialManager.Instance:Send13107(data.rid, data.platform, data.zone_id, data.type)
end

function TrialManager:RequestInitData()
    TrialManager.Instance.model:DeleteQuest()
    self.model.mode = 0
    self.model.order = 1
    self.model.direct_order = 1
    self.model.clear_normal = false
    self.model.trial_unit = nil
    self.model.reset = 0
    self.model.round = 0
    self.model.coin = 0
    self.model.times = 0
    self.model.max_times = 0
    self.model.can_ask = 0
    self:Send13100()
end

