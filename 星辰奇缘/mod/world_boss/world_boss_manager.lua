WorldBossManager = WorldBossManager or BaseClass(BaseManager)

function WorldBossManager:__init()
    if WorldBossManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    WorldBossManager.Instance = self;
    self:InitHandler()
    self.myBossData = {}
    self.model = WorldBossModel.New()

end

function WorldBossManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function WorldBossManager:InitHandler()
    self:AddNetHandler(13000, self.on13000)
    self:AddNetHandler(13001, self.on13001)
    self:AddNetHandler(13003, self.on13003)

    self:AddNetHandler(13004, self.on13004)
    self:AddNetHandler(13005, self.on13005)
    self:AddNetHandler(13006, self.on13006)
    self:AddNetHandler(13007, self.on13007)
end

function WorldBossManager:RequestInitData()
    self:request13000()
    self:request13007()
end

--协议监听
function WorldBossManager:on13000(data)
    self.model.world_boss_data = data
    self.model:update_view()
    UnitStateManager.Instance:Update(UnitStateEumn.Type.Boss, data)
end

function WorldBossManager:on13001(data)
    self.model:update_rank_view(data.kill_rank, 1)
end

function WorldBossManager:on13003(data)
    -- print("--------------------------收到13003")
    if data.result == 1 then
        self.model:CloseWorldBossRankUI()
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function WorldBossManager:on13004(data)
    -- print("--------------------------收到13004")
    self.model:update_rank_view(data.world_boss_killer,3)
end

function WorldBossManager:on13005(data)
    -- print("--------------------------收到13005")
    if data.result == 1 then
        self.model:CloseWorldBossRankUI()
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
function WorldBossManager:on13006(data)
    -- print("--------------------------收到13006")
    if data.result == 1 then
        self.model:CloseWorldBossRankUI()
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function WorldBossManager:on13007(data)
    self.myBossData[data.id] = data
    UnitStateManager.Instance:Update(UnitStateEumn.Type.Boss, data)
end

--协议请求
function WorldBossManager:request13000()
    Connection.Instance:send(13000, {})
end

function WorldBossManager:request13001(_id)
    Connection.Instance:send(13001, {id = _id})
end

function WorldBossManager:request13003(_base_id, _finished)
    -- print("----------------------------发送13003")
    Connection.Instance:send(13003, {base_id = _base_id, finished = _finished})
end


function WorldBossManager:request13004(_id)
    -- print("----------------------------发送13004")
    Connection.Instance:send(13004, {id = _id})
end

function WorldBossManager:request13005(_rid, _r_platform, _r_zone_id, _base_id)
    -- print("----------------------------发送13003")
    Connection.Instance:send(13005, {rid = _rid, r_platform = _r_platform, r_zone_id = _r_zone_id, base_id = _base_id})
end

function WorldBossManager:request13006(base_id)
    -- print("----------------------------发送13006")
    Connection.Instance:send(13006, {base_id = base_id})
end

--协议请求
function WorldBossManager:request13007()
    Connection.Instance:send(13007, {})
end