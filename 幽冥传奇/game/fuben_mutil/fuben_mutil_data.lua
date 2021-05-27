
FubenMutilData = FubenMutilData or BaseClass()

FubenMutilType = {
    Team = 2,
    Hhjd = 4,
}

FubenMutilId = {
    Team = ZuDuiFuBenCfg[FubenMutilType.Team].fubenId,
    -- Team_2 = 2,
    Hhjd1 = ZuDuiFuBenCfg[FubenMutilType.Hhjd].fubenId,
}

FubenMutilSceneId = {
    Team = ZuDuiFuBenCfg[FubenMutilType.Team].sceneInfo[1].sceneId,
    Team_2 = ZuDuiFuBenCfg[FubenMutilType.Team].sceneInfo[2].sceneId,
    Team_3 = ZuDuiFuBenCfg[FubenMutilType.Team].sceneInfo[3].sceneId,
    Team_4 = ZuDuiFuBenCfg[FubenMutilType.Team].sceneInfo[4].sceneId,
    Team_5 = ZuDuiFuBenCfg[FubenMutilType.Team].sceneInfo[5].sceneId,
    Team_6 = ZuDuiFuBenCfg[FubenMutilType.Team].sceneInfo[6].sceneId,
    Team_7 = ZuDuiFuBenCfg[FubenMutilType.Team].sceneInfo[7].sceneId,
    Team_8 = ZuDuiFuBenCfg[FubenMutilType.Team].sceneInfo[8].sceneId,
    Team_9 = ZuDuiFuBenCfg[FubenMutilType.Team].sceneInfo[9].sceneId,
    Team_10 = ZuDuiFuBenCfg[FubenMutilType.Team].sceneInfo[10].sceneId,
    Hhjd1 = ZuDuiFuBenCfg[FubenMutilType.Hhjd].fubenId,
}

FubenMutilLayer = {
    [FubenMutilSceneId.Team] = 1,
    [FubenMutilSceneId.Team_2] = 2,
    [FubenMutilSceneId.Team_3] = 3,
    [FubenMutilSceneId.Team_4] = 4,
    [FubenMutilSceneId.Team_5] = 5,
    [FubenMutilSceneId.Team_6] = 6,
    [FubenMutilSceneId.Team_7] = 7,
    [FubenMutilSceneId.Team_8] = 8,
    [FubenMutilSceneId.Team_9] = 9,
    [FubenMutilSceneId.Team_10] = 10,
    Hhjd1 = 1,
}

FubenMutilData.LEFT_ENTER_TIMES = "left_enter_times"

function FubenMutilData:__init()
    if FubenMutilData.Instance then
		ErrorLog("[FubenMutilData]:Attempt to create singleton twice!")
	end
    FubenMutilData.Instance = self
    GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

    self.fuben_used_times = {}
    self.cur_kill_num = 0

    -- 绑定红点提示触发条件
    RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetDrfbRemindIndex), RemindName.DuoRenFuBen)
end

function FubenMutilData:__delete()
    FubenMutilData.Instance = nil

    self.fuben_used_times = nil
    self.cur_kill_num = 0
end

function FubenMutilData:SetFubenUsedTimes(fuben_type, times)
    self.fuben_used_times[fuben_type] = times
    if fuben_type == FubenMutilType.Team then
		self:DispatchEvent(FubenMutilData.LEFT_ENTER_TIMES)
        RemindManager.Instance:DoRemindDelayTime(RemindName.DuoRenFuBen)
	end
end

function FubenMutilData:GetFubenUsedTimes(fuben_type)
    return self.fuben_used_times[fuben_type] or 0
end

function FubenMutilData.GetFubenMaxEnterTimes(fuben_type)
    return ZuDuiFuBenCfg[fuben_type].sceneInfo[1].maxTimes
end

function FubenMutilData:GetTeamInfoList(fuben_type, fuben_layer, state)
    state = state or 1
    local team_info_list = FubenTeamData.Instance:GetTeamInfoList(fuben_type, fuben_layer)
    local data_list = {}
    for _, v in pairs(team_info_list) do
        if v.state == state then
            table.insert(data_list, v)
        end
    end
    return data_list
end

function FubenMutilData:GetTeamCount(fuben_type, fuben_layer)
    return FubenTeamData.Instance:GetTeamCount(fuben_type, fuben_layer)
end

function FubenMutilData:GetTeamDetailInfo(fuben_type, fuben_layer, team_id)
    return FubenTeamData.Instance:GetTeamDetailInfo(fuben_type,fuben_layer,team_id)
end

function FubenMutilData.GetFubenLimitLevel(fuben_type, fuben_layer)
    return ZuDuiFuBenCfg[fuben_type].sceneInfo[fuben_layer].limitLevel
end

-- 我是否创建了队伍
function FubenMutilData:IsMyCreatedTeam(fuben_type, fuben_layer)
    return FubenTeamData.Instance:IsMyCreatedTeam(fuben_type,fuben_layer)
end

-- 我是队长
function FubenMutilData:IsLeaderForMe(fuben_type, fuben_layer, team_id)
    return FubenTeamData.Instance:IsLeaderForMe(fuben_type,fuben_layer,team_id)
end

-- 是否在队伍中
function FubenMutilData:IsContainByName(name, fuben_type, fuben_id, fuben_layer, team_id)
    return FubenTeamData.Instance:IsContainByName(name,fuben_type,fuben_id,fuben_layer,team_id)
end

function FubenMutilData:GetMyTeamInfo(fuben_type, fuben_layer)
    return FubenTeamData.Instance:GetMyTeamInfo(fuben_type,fuben_layer)
end

function FubenMutilData:IsContainMe(fuben_type, fuben_id, fuben_layer, team_id)
    return FubenTeamData.Instance:IsContainMe(fuben_type,fuben_id,fuben_layer,team_id)
end

function FubenMutilData:GetReadyCount(fuben_type, fuben_id, fuben_layer, team_id)
    return FubenTeamData.Instance:GetReadyCount(fuben_type,fuben_id,fuben_layer,team_id)
end

function FubenMutilData:GetCurKilledNum()
    return self.cur_kill_num
end

function FubenMutilData:SetCurKilledNum(num)
    self.cur_kill_num = num
end

function FubenMutilData:IsReadyForMe()
    local team_info = FubenTeamData.Instance:GetMyTeamInfo(FubenMutilType.Team, FubenMutilLayer[133]) or {}
    local myname = RoleData.Instance:GetRoleName()
    for _, v in pairs(team_info.menber_infos or {}) do
        if v.name == myname and v.is_ready == 1 then
            return true
        end
    end
    return false
end


function FubenMutilData.GetFubenAwardList(fuben_type, fuben_layer)
    return ZuDuiFuBenCfg[fuben_type].sceneInfo[fuben_layer].showAwards
end

function FubenMutilData.GetFubenRealAwardList(fuben_type, fuben_layer)
    return ZuDuiFuBenCfg[fuben_type].sceneInfo[fuben_layer].awards
end

function FubenMutilData.GetFubenShowAwards(fuben_type, fuben_layer)
    return ZuDuiFuBenCfg[fuben_type].sceneInfo[fuben_layer].showAwards
end

function FubenMutilData.GetFubenPannelAwardList(fuben_type)
    return ZuDuiFuBenCfg[fuben_type].pannelShowAwards
end

function FubenMutilData.GetTurnsRefreshTimes(fuben_type, fuben_layer)
    -- local layer = FubenMutilData.GetLayerByCurScene()
    return ZuDuiFuBenCfg[fuben_type].sceneInfo[fuben_layer].refreshTime
end

function FubenMutilData.GetFloorRefreshTimes(fuben_type, fuben_id)
    local layer = FubenMutilData.GetLayerByCurScene()
    return ZuDuiFuBenCfg[fuben_type].sceneInfo[layer].totalTime
end

function FubenMutilData.GetNeedKilledNum(fuben_type, fuben_layer)
    if fuben_layer > 2 then 
        fuben_layer = FubenMutilData.GetLayerByCurScene()
    end
    return ZuDuiFuBenCfg[fuben_type].sceneInfo[fuben_layer].MonNum
end

function FubenMutilData.GetFubenName(fuben_type, fuben_id)
    local layer = FubenMutilData.GetLayerByCurScene()
    return ZuDuiFuBenCfg[fuben_type].sceneInfo[layer].name
end

function FubenMutilData.GetLayerByCurScene()
    local scene_id = Scene.Instance:GetSceneId()
    return FubenMutilLayer[scene_id] or 1
end

----------红点提示----------

-- 获取提醒显示索引 0不显示红点, 1显示红点
function FubenMutilData.GetDrfbRemindIndex()
    local max_times = FubenMutilData.GetFubenMaxEnterTimes(FubenMutilType.Team)
    local used_times = FubenMutilData.Instance:GetFubenUsedTimes(FubenMutilType.Team)
    local times = max_times - used_times
    local index = times > 0 and 1 or 0
    return index
end

----------end----------