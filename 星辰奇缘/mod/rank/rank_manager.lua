RankManager = RankManager or BaseClass(BaseManager)

function RankManager:__init()
    if RankManager.Instance ~= nil then
        return
    end

    RankManager.Instance = self
    self.model = RankModel.New()

    self:InitHandler()

    self.timerid = nil

    self.OnUpdateList = EventLib.New()
    self.onUpdateRankList = EventLib.New()
    self.championMap = {70, 80, 90, 101, 106, 116, 126}
end

function RankManager:__delete()
    self.OnUpdateList:DeleteMe()
    self.OnUpdateList = nil

    if self.onUpdateRankList ~= nil then
        self.onUpdateRankList:DeleteMe()
        self.onUpdateRankList = nil
    end
end

function RankManager:OpenWindow(args)
    self.model.args = args
    self.model.lastPosition = 0
    self.model.selectIndex = nil
    self.model:OpenWindow()
end

function RankManager:InitHandler()
    self:AddNetHandler(12500, self.on12500)
    self:AddNetHandler(12501, self.on12501)
    self:AddNetHandler(12502, self.on12502)
    self:AddNetHandler(12503, self.on12503)
    self:AddNetHandler(12505, self.on12505)
    self:AddNetHandler(12506, self.on12506)
    self:AddNetHandler(15015, self.on15015)
    self:AddNetHandler(18637, self.on18637)
    self:AddNetHandler(11102, self.on11102)
end

function RankManager:send12500(data)
    local model = self.model
    if data.type == model.rank_type.LoveWeekly or data.type == model.rank_type.LoveHistory then
        self:send15015(model.loveRankType[data.type])
    elseif model.childRankType[data.type] ~= nil then
        self:send18637(model.childRankType[data.type])
    elseif data.type == model.rank_type.GoodVoice then
        SingManager.Instance:Send16814(1)
    elseif data.type == model.rank_type.GoodVoice2 then
        SingManager.Instance:Send16814(2)
    elseif data.type == model.rank_type.StarChallenge then
        --BaseUtils.dump(data, "发送20209")
        StarChallengeManager.Instance:Send20209()
    elseif data.type == model.rank_type.ApocalypseLord then
        --BaseUtils.dump(data, "发送20809")
        ApocalypseLordManager.Instance:Send20809()
    elseif model:CheckChampionType(data.type) then
        --武道
        local group = self.championMap[data.type - (model.rank_type.WorldchampionElite -1)]
        if group ~= nil then
            WorldChampionManager.Instance:Require16416(2, group)
        end
    else
        BaseUtils.dump(data, "发送12500")
        Connection.Instance:send(12500, data)
    end
end

function RankManager:on12500(data)
    local model = self.model
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "接收12500")
    end
    local pos = model.rankTypeToPageIndexList[data.type]
    model:SetData(pos.main, pos.sub, data.sub_type, data)
    -- self.OnUpdateList:Fire("ReloadRankpanel")
end

function RankManager:send12501(data)
    print("发送12501")
    Connection.Instance:send(12501, data)
end

function RankManager:on12501(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "接收12501")
    end
    local model = self.model
    if model:CheckChampionType(data.type) or data.type == model.rank_type.StarChallenge or data.type == model.rank_type.ApocalypseLord then
        return
    end
    local pos = model.rankTypeToPageIndexList[data.type]
    model:SetMyData(pos.main, pos.sub, data)
    -- self.OnUpdateList:Fire("ReloadMydata")
end

function RankManager:send12502(data)
    -- BaseUtils.dump(data)
    Connection.Instance:send(12502, data)
end

-- 宠物
function RankManager:on12502(data)
    -- BaseUtils.dump(data, "on12502")
    local dat = BaseUtils.copytab(data)
    dat.hp = dat.hp_max
    dat.mp = dat.mp_max
    PetManager.Instance.model.quickshow_petdata = PetManager.Instance.model:updatepetbasedata(dat)
    PetManager.Instance.model:ProcessingSkillData(PetManager.Instance.model.quickshow_petdata)
    PetManager.Instance.model:OpenPetQuickShowWindow()
end

function RankManager:send12503(data)
    -- BaseUtils.dump(data)
    Connection.Instance:send(12503, data)
end

-- 守护
function RankManager:on12503(_dat)
    -- BaseUtils.dump(_dat, "on12503")
    local result_data = ShouhuManager.Instance.model:build_look_win_data(_dat, ShouhuManager.Instance.model.shouhu_look_lev)
    result_data.owner_name = ShouhuManager.Instance.model.shouhu_look_owner_name
    ShouhuManager.Instance.model.shouhu_look_dat = result_data
    ShouhuManager.Instance.model:OpenShouhuLookUI()
end

function RankManager:send12505(data)
    -- BaseUtils.dump(data)
    Connection.Instance:send(12505, data)
end

-- 处理跟12500一样
function RankManager:on12505(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "接收12505")
    end
    self:on12500(data)
end

function RankManager:send12506(team_id,platform,zone_id, group_id)
    --print("send12506".."  team_id = "..team_id.."  platform = "..platform.."  zone_id = "..zone_id.."  group_id = "..group_id)
    Connection.Instance:send(12506, {team_id = team_id, platform = platform, zone_id = zone_id, group_id = group_id})
end

function RankManager:on12506(data)
    --BaseUtils.dump(data,"on12506")
    if data ~= nil then
        self.model.rankTeamShowList = data
        self.model:OpenRankTeamShowPanel()
    end
end

function RankManager:send15015(type)
  -- print("发送15015 "..tostring(type))
    Connection.Instance:send(15015, {type = type})
end

function RankManager:on15015(data)
    BaseUtils.dump(data, "接收15015")
    local model = self.model
    local type = model.loveTypeToRankType[data.type]
    local pos = model.rankTypeToPageIndexList[type]
    model:SetData(pos.main, pos.sub, 1, {rank_list = data.list})
end

-- 子女
function RankManager:send18637(type)
    Connection.Instance:send(18637, {type = type})
end

function RankManager:on18637(data)
    if Application.platform == RuntimePlatform.WindowsEditor then
        BaseUtils.dump(data, "接收18637")
    end
    local model = self.model
    local type = model.childTypeToRankType[data.type]
    local pos = model.rankTypeToPageIndexList[type]
    model:SetData(pos.main, pos.sub, 1, {rank_list = data.list, type = data.type})
end

function RankManager:send11102(data)
    Connection.Instance:send(11102, data)
end

function RankManager:on11102(data)
    --self.model.guildData = data
end

