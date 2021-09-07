-- 公会副本
-- ljh 20170301

GuildDungeonManager = GuildDungeonManager or BaseClass(BaseManager)

function GuildDungeonManager:__init()
    if GuildDungeonManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    GuildDungeonManager.Instance = self;
    self:InitHandler()
    self.model = GuildDungeonModel.New()

    self.OnUpdate = EventLib.New()
    self.OnUpdateRank = EventLib.New()
    self.OnUpdateBoss = EventLib.New()
end

function GuildDungeonManager:__delete()
    self.model:DeleteMe()
    self.model = nil
    self.OnUpdate:DeleteMe()
    self.OnUpdate = nil
    self.OnUpdateRank:DeleteMe()
    self.OnUpdateRank = nil
    self.OnUpdateBoss:DeleteMe()
    self.OnUpdateBoss = nil
end

function GuildDungeonManager:InitHandler()
    self:AddNetHandler(19500, self.On19500)
    self:AddNetHandler(19501, self.On19501)
    self:AddNetHandler(19502, self.On19502)
    self:AddNetHandler(19503, self.On19503)
    self:AddNetHandler(19504, self.On19504)
    self:AddNetHandler(19505, self.On19505)
    self:AddNetHandler(19506, self.On19506)
    self:AddNetHandler(19507, self.On19507)
end

function GuildDungeonManager:RequestInitData()
    self.model:InitData()

    self:Send19500()
end

function GuildDungeonManager:Send19500()
    Connection.Instance:send(19500, { })
end

function GuildDungeonManager:On19500(data)
    -- BaseUtils.dump(data, "On19500")
    self.model:On19500(data)
end

function GuildDungeonManager:Send19501(chapter_id, strongpoint_id, unique)
    Connection.Instance:send(19501, { chapter_id = chapter_id, strongpoint_id = strongpoint_id, unique = unique })
end

function GuildDungeonManager:On19501(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        -- self.model:CloseWindow()
        -- self.model:CloseSoldierWindow()
        -- self.model:CloseBossWindow()
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.guilddungeonsoldierwindow)
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.guilddungeonbosswindow)
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.guilddungeonwindow)

        -- EventMgr.Instance:AddListener(event_name.end_fight, self.model._EndFight)
    end
end

function GuildDungeonManager:Send19502(chapter_id, strongpoint_id)
    Connection.Instance:send(19502, { chapter_id = chapter_id, strongpoint_id = strongpoint_id })
end

function GuildDungeonManager:On19502(data)
    self.model:On19502(data)
end

function GuildDungeonManager:Send19503(chapter_id, strongpoint_id, unique)
    Connection.Instance:send(19503, { chapter_id = chapter_id, strongpoint_id = strongpoint_id, unique = unique })
end

function GuildDungeonManager:On19503(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        -- self.model:CloseBossWindow()
        -- self.model:CloseWindow()
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.guilddungeonsoldierwindow)
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.guilddungeonbosswindow)
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.guilddungeonwindow)
    end
end

function GuildDungeonManager:Send19504(chapter_id, strongpoint_id, unique)
    -- print(string.format("Send19504 %s %s %s", chapter_id, strongpoint_id, unique))
    Connection.Instance:send(19504, { chapter_id = chapter_id, strongpoint_id = strongpoint_id, unique = unique })
end

function GuildDungeonManager:On19504(data)
    -- print("On19504")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        -- self.model:CloseWindow()
        -- self.model:CloseSoldierWindow()
        -- self.model:CloseBossWindow()
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.guilddungeonsoldierwindow)
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.guilddungeonbosswindow)
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.guilddungeonwindow)

        -- EventMgr.Instance:AddListener(event_name.end_fight, self.model._EndFight)
    end
end

function GuildDungeonManager:Send19505(chapter_id, strongpoint_id, unique)
    -- print(string.format("Send19505 %s %s %s", chapter_id, strongpoint_id, unique))
    Connection.Instance:send(19505, { chapter_id = chapter_id, strongpoint_id = strongpoint_id, unique = unique })
end

function GuildDungeonManager:On19505(data)
    -- BaseUtils.dump(data, "On19505")
    if self.model.bossMapData ~= nil then
        if data.chapter_id == self.model.bossMapData.chapter_id and data.strongpoint_id == self.model.bossMapData.strongpoint_id and data.unique == self.model.bossMapData.unique then
            self.model.bossData = data
        end
    end
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDungeonBattle and self.model.fightMapData ~= nil then
        if data.chapter_id == self.model.fightMapData.chapter_id and data.strongpoint_id == self.model.fightMapData.strongpoint_id and data.unique == self.model.fightMapData.unique then
            self.model.fightData = data
        end
    end
    GuildDungeonManager.Instance.OnUpdateBoss:Fire()
end

function GuildDungeonManager:Send19506()
    Connection.Instance:send(19506, { })
end

function GuildDungeonManager:On19506(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function GuildDungeonManager:Send19507()
    Connection.Instance:send(19507, { })
end

function GuildDungeonManager:On19507(data)
    self.model.settlementData = data
    LuaTimer.Add(2000, function() self.model:OpenGuildDungeonSettlementWindow() end)
end