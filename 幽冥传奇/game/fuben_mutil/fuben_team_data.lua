FubenTeamData = FubenTeamData or BaseClass()

-- team_info_list = {
-- 	[fuben_type] = {
-- 		[fuben_id] = {
-- 			{
-- 				team_id,
-- 				leader_name,
-- 				max_men_count,
-- 				menber_count,
-- 				menber_infos = {
-- 					{
-- 						id,
-- 						model_id,
-- 						weapon_id,
-- 						level,
-- 						sex,
-- 						is_ready,
-- 						name,
-- 					}
-- 				},
-- 			}
-- 		},
-- 	}
-- } 
FubenTeamData.FLUSH_MUTIL_DATA = "flush_mutil_data"
FubenTeamData.FLUSH_HHJD_DATA = "flush_hhjd_data"
FubenTeamData.FLUSH_TEAM_DATA = "flush_team_data"
FubenTeamData.FLUSH_ROLE_MODEL = "flush_role_model"
FubenTeamData.REMOVE_TEAM_DATA = "remove_team_data"
FubenTeamData.CREATE_TEAM_DATA = "create_team_data"
FubenTeamData.FLUSH_ALERT_STATE = "flush_alert_state"

function FubenTeamData:__init()
    if FubenTeamData.Instance then
		ErrorLog("[FubenTeamData]:Attempt to create singleton twice!")
	end
    FubenTeamData.Instance = self
    GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

    self.team_info_list = {}
end

function FubenTeamData:__delete()
    FubenTeamData.Instance = nil

    self.team_info_list = nil
end

function FubenTeamData:SetTeamInfos(fuben_type, info_list)
    local my_name = RoleData.Instance:GetRoleName()
    
    self.team_info_list[fuben_type] = {}
    local team_info = {}
    for _, v in pairs(info_list) do
        team_info[v.fuben_layer] = team_info[v.fuben_layer] or {}
        local info = {}
        info.team_id       = v.team_id
        info.fuben_layer   = v.fuben_layer
        info.max_men_count = v.max_men_count
        info.state         = v.state
        info.leader_name   = v.leader_name
        info.menber_count  = v.menber_count
        info.menber_infos  = {}
        if info.leader_name == my_name then
            table.insert(team_info[v.fuben_layer], 1, info)
        else
            table.insert(team_info[v.fuben_layer], info)
        end
        self.team_info_list[fuben_type][v.fuben_layer] = team_info[v.fuben_layer]
    end

    if fuben_type == FubenMutilType.Team then
        self:DispatchEvent(FubenTeamData.FLUSH_MUTIL_DATA)
    elseif fuben_type == FubenMutilType.Hhjd then
	    for _, v in pairs(info_list) do
			FubenMutilCtrl.SendGetTeamDetailInfo(FubenMutilType.Hhjd, FubenMutilId.Hhjd1, v.team_id)
	    end
        self:DispatchEvent(FubenTeamData.FLUSH_HHJD_DATA)
		-- ViewManager.Instance:FlushView(ViewName.HhjdTeam)
    end

end

function FubenTeamData:AddTeamInfo(fuben_type, fuben_id, fuben_layer, team_info)
    local team_info_list = self:CheckTeamInfo(fuben_type, fuben_layer)
    local my_name = RoleData.Instance:GetRoleName()
    local info = {}
    info.team_id       = team_info.team_id
    info.fuben_layer   = fuben_layer
    info.max_men_count = team_info.max_men_count
    info.state         = team_info.state
    info.leader_name   = team_info.leader_name
    info.menber_count  = team_info.menber_count
    info.menber_infos  = {}

    if my_name == info.leader_name then
        table.insert(team_info_list, 1, info)
    else
        table.insert(team_info_list, info)
    end
    self.team_info_list[fuben_type][fuben_layer] = team_info_list

    if fuben_type == FubenMutilType.Team then
        self:DispatchEvent(FubenTeamData.FLUSH_TEAM_DATA)
        if my_name == info.leader_name then
            self:DispatchEvent(FubenTeamData.CREATE_TEAM_DATA)
        end
	elseif fuben_type == FubenMutilType.Hhjd then
        FubenCtrl.Instance:SetTaskFollow()
        self:DispatchEvent(FubenTeamData.FLUSH_HHJD_DATA)
    	-- ViewManager.Instance:FlushView(ViewName.HhjdTeam)
    end
end

function FubenTeamData:ChangeTeamInfo(fuben_type, fuben_id, fuben_layer, new_info)
    local team_info_list = self:CheckTeamInfo(fuben_type, fuben_layer)
    for _, v in pairs(team_info_list) do
        if v.team_id == new_info.team_id then
            v.max_men_count = new_info.max_men_count
            v.leader_name   = new_info.leader_name
            v.menber_count  = new_info.menber_count
            break
        end
    end
end

function FubenTeamData:DissolveTeam(fuben_type, fuben_id, fuben_layer, team_id)
    local team_list = self:CheckTeamInfo(fuben_type, fuben_layer)
    for k, v in pairs(team_list) do
        if v.team_id == team_id then
            table.remove(team_list, k)
            break
        end
    end

    if fuben_type == FubenMutilType.Team then
        FubenMutilCtrl.Instance:CloseMenListAlert()
    elseif fuben_type == FubenMutilType.Hhjd then
        self:DispatchEvent(FubenTeamData.FLUSH_HHJD_DATA)
    	-- ViewManager.Instance:FlushView(ViewName.HhjdTeam)
    end
    self:DispatchEvent(FubenTeamData.REMOVE_TEAM_DATA)
end

function FubenTeamData:GetTeamInfoList(fuben_type, fuben_layer)
    return self:CheckTeamInfo(fuben_type, fuben_layer)
end

function FubenTeamData:GetTeamCount(fuben_type, fuben_layer)
    local count = 0
    for _, v in pairs(self:GetTeamInfoList(fuben_type, fuben_layer)) do
        count = count + 1
    end
    return count
end

function FubenTeamData:CheckTeamInfo(fuben_type, fuben_layer)
    if self.team_info_list[fuben_type] == nil then
        self.team_info_list[fuben_type] = {}
    end
    if self.team_info_list[fuben_type][fuben_layer] == nil then
        self.team_info_list[fuben_type][fuben_layer] = {}
    end
    return self.team_info_list[fuben_type][fuben_layer]
end

function FubenTeamData:SetTeamDetailInfo(fuben_type, fuben_id, fuben_layer, team_id, menber_list)
    local team_info_list = self:CheckTeamInfo(fuben_type, fuben_layer)

    for _, v in pairs(team_info_list) do
        if v.team_id == team_id then
            v.menber_infos = DeepCopy(menber_list)
        end
    end

    if fuben_type == FubenMutilType.Team then
        self:DispatchEvent(FubenTeamData.FLUSH_ROLE_MODEL)
    end
end

function FubenTeamData:GetTeamDetailInfo(fuben_type, fuben_layer, team_id)
    local team_infos = self:CheckTeamInfo(fuben_type,fuben_layer)
    for _, v in pairs(team_infos) do
        if v.team_id == team_id then
            return v.menber_infos or {}
        end
    end
    return {}
end

function FubenTeamData:DeleteMenber(fuben_type, fuben_id, fuben_layer, menber_id)
    local team_info_list = self:CheckTeamInfo(fuben_type,fuben_layer)
    for _, v in pairs(team_info_list) do
        for k1, v1 in pairs(v.menber_infos) do
            if v1.id == menber_id then
                table.remove(v.menber_infos, k1)
                v.menber_count = v.menber_count - 1
                break
            end
        end
    end

    if fuben_type == FubenMutilType.Team then
        self:DispatchEvent(FubenTeamData.FLUSH_TEAM_DATA)
    elseif fuben_type == FubenMutilType.Hhjd then
        self:DispatchEvent(FubenTeamData.FLUSH_HHJD_DATA)
		-- ViewManager.Instance:FlushView(ViewName.HhjdTeam)
    end
end

function FubenTeamData:AddMenber(fuben_type, fuben_id, fuben_layer, team_id, info)
    local team_info_list = self:CheckTeamInfo(fuben_type, fuben_layer)
    for _, v in pairs(team_info_list) do
        if v.team_id == team_id then
            local can_create = true
            for __, v2 in pairs(v.menber_infos) do
                if v2.id == info.id then
                    can_create = false -- 此队员已存在不再增加
                end
            end
            if can_create then
                table.insert(v.menber_infos, info)
                v.menber_count = #v.menber_infos
            end
            break
        end
    end

    if fuben_type == FubenMutilType.Team then
        self:DispatchEvent(FubenTeamData.FLUSH_TEAM_DATA)
    elseif fuben_type == FubenMutilType.Hhjd then
        FubenCtrl.Instance:SetTaskFollow()
        self:DispatchEvent(FubenTeamData.FLUSH_HHJD_DATA)
    	-- ViewManager.Instance:FlushView(ViewName.HhjdTeam)
    end
end

function FubenTeamData:GetMenberById(fuben_type, fuben_id, fuben_layer, menber_id)
    local team_info_list = self:CheckTeamInfo(fuben_type, fuben_layer)
    for _, v in pairs(team_info_list) do
        for __, v1 in pairs(v.menber_infos or {}) do
            if v1.id == menber_id then
                return v1
            end
        end
    end
end

function FubenTeamData:ChangeReadyState(fuben_type, fuben_id, fuben_layer, team_id, menber_id, is_ready)
    local team_info_list = self:CheckTeamInfo(fuben_type, fuben_layer)
    for _, v in pairs(team_info_list) do
        if v.team_id == team_id then
            for __, v1 in pairs(v.menber_infos) do
                if v1.id == menber_id then
                    v1.is_ready = is_ready
                    break
                end
            end
        end
    end
    self:DispatchEvent(FubenTeamData.FLUSH_TEAM_DATA)
end

-- 我是否创建了队伍
function FubenTeamData:IsMyCreatedTeam(fuben_type, fuben_layer)
    local myname = RoleData.Instance:GetRoleName()
    local team_infos = self:CheckTeamInfo(fuben_type,fuben_layer)
    for _, v in pairs(team_infos) do
        if v.leader_name == myname then
            return true
        end
    end
    return false
end

-- 我是队长
function FubenTeamData:IsLeaderForMe(fuben_type, fuben_layer, team_id)
    local team_infos = self:CheckTeamInfo(fuben_type, fuben_layer)
    local myname = RoleData.Instance:GetRoleName()
    for _, v in pairs(team_infos) do
        if v.team_id == team_id and v.leader_name == myname then
            return true
        end
    end
    return false
end

-- 是否在队伍中
function FubenTeamData:IsContainByName(name, fuben_type, fuben_id, fuben_layer, team_id)
    local team_infos = self:CheckTeamInfo(fuben_type, fuben_layer)
    for _, v in pairs(team_infos) do
        if v.team_id == team_id then
            for __, v1 in pairs(v.menber_infos or {}) do
                if v1.name == name then
                    return true
                end
            end
        end
    end
    return false
end

function FubenTeamData:GetMyTeamInfo(fuben_type, fuben_layer)
    local team_info_list = self:CheckTeamInfo(fuben_type, fuben_layer)
    local myname = RoleData.Instance:GetRoleName()
    for _, v in pairs(team_info_list) do
        if v.leader_name == myname then
            return v
        end
        for __, v1 in pairs(v.menber_infos or {}) do
            if v1.name == myname then
                return v
            end
        end
    end
end

function FubenTeamData:IsInMyTeam(fuben_type, fuben_id, fuben_layer, menber_id)
    local team_info = self:GetMyTeamInfo(fuben_type, fuben_layer) or {}
    for _, v in pairs(team_info.menber_infos or {}) do
        if v.id == menber_id then
            return true
        end
    end
    return false
end

function FubenTeamData:ChangeLeader(fuben_type, fuben_id, fuben_layer, team_id, menber_id)
    local team_list = self:CheckTeamInfo(fuben_type, fuben_layer)
    for _, v in pairs(team_list) do
        if v.team_id == team_id then
            for __, v1 in pairs(v.menber_infos or {}) do
                if v1.id == menber_id then
                    v1.is_leader = 1
                    v.leader_name = v1.name
                else
                    v1.is_leader = 0
                end
            end
        end
    end
end

function FubenTeamData:ChangeTeamState(fuben_type, fuben_layer, team_id, state)
    local team_list = self:CheckTeamInfo(fuben_type, fuben_layer)
    for _, v in pairs(team_list) do
        if v.team_id == team_id then
            v.state = state
        end
    end

    if fuben_type == FubenMutilType.Team then
        self:DispatchEvent(FubenTeamData.FLUSH_TEAM_DATA)
        self:DispatchEvent(FubenTeamData.FLUSH_ALERT_STATE, team_id)
    elseif fuben_type == FubenMutilType.Hhjd then
        self:DispatchEvent(FubenTeamData.FLUSH_HHJD_DATA)
		-- ViewManager.Instance:FlushView(ViewName.HhjdTeam)
	end
end

function FubenTeamData:IsContainMe(fuben_type, fuben_id, fuben_layer, team_id)
    local myname = RoleData.Instance:GetRoleName()
    return self:IsContainByName(myname, fuben_type, fuben_id, fuben_layer, team_id)
end

function FubenTeamData:GetReadyCount(fuben_type, fuben_id, fuben_layer, team_id)
    local team_info_list = self:CheckTeamInfo(fuben_type, fuben_layer)
    local count = 0
    for _, v in pairs(team_info_list) do
        if v.team_id == team_id then
            for __, v1 in pairs(v.menber_infos or {}) do
                if v1.is_ready == 1 then
                    count = count + 1
                end
            end
        end
    end
    return count
end

