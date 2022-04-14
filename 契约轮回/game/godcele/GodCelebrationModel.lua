-- @Author: lwj
-- @Date:   2019-09-06 15:28:25
-- @Last Modified time: 2019-09-06 15:28:34

GodCelebrationModel = GodCelebrationModel or class("GodCelebrationModel", BaseBagModel)
local GodCelebrationModel = GodCelebrationModel

function GodCelebrationModel:ctor()
    GodCelebrationModel.Instance = self
    self:Reset()
end

function GodCelebrationModel:Reset()
    self.redPoints = {}
    self.petRedPoints = {}
    self.isFirstOpen_rank = true
    self.isFirstOpen_buy = true

    -------
    self.dunge_panel_info = {}      --积分副本数据
    self.is_paying = false          --是否已用完免费次数
    self.is_check = false           --今日是否提示花费钻石购买次数
    self.cur_floor = 1              --当前副本的层数
    self.dunge_enter_info = {}      --结束 副本id层数
    self.dunge_info = {}            --准备时间等副本信息
    self.need_power = nil           --上榜战力
    self:GetNeedPower()
end

function GodCelebrationModel.GetInstance()
    if GodCelebrationModel.Instance == nil then
        GodCelebrationModel()
    end
    return GodCelebrationModel.Instance
end

function GodCelebrationModel:GetActIdByIdx(idx)
    return self.act_id_list[idx]
end

---配置
function GodCelebrationModel:SetThemeCf(cf)
    self.theme_cf_list[cf.id] = cf
end

function GodCelebrationModel:GetThemeCf()
    return self.theme_cf_list
end

function GodCelebrationModel:GetThemeCfById(id)
    return self.theme_cf_list[id]
end

function GodCelebrationModel:GetRewaCf()
    for act_id, info_list in pairs(self.info_list) do
        local list = {}
        for idx, task_info in pairs(info_list.tasks) do
            list[task_info.id] = OperateModel.GetInstance():GetRewardConfig(act_id, task_info.id)
        end
        self.rewa_cf_list[act_id] = list
    end
end

function GodCelebrationModel:IsSelfAct(tar_id)
    local result = false
    for _, v in pairs(self.act_id_list) do
        if tar_id == v then
            result = true
            break
        end
    end
    return result
end

---Info
function GodCelebrationModel:SetActInfo(info)
    self.info_list[info.id] = info
end

function GodCelebrationModel:SetEndTimeByActId(id, time_stamp)
    self.act_end_list[id] = time_stamp
end

function GodCelebrationModel:GetNationThemeList()
    local list = self:GetThemeCf()
    local interator = table.pairsByKey(list)
    local cf = {}
    for k, v in interator do
        local end_time = self.act_end_list[v.id]
        if end_time then
            if end_time > os.time() then
                --活动未结束
                cf[#cf + 1] = v
            end
        end
    end
    return cf
end

function GodCelebrationModel:FormatNum(num)
    return string.format("%02d", num)
end

function GodCelebrationModel:SetDungePanelInfo(data)
    self.dunge_panel_info = data
end

function GodCelebrationModel:GetDungePanelInfo()
    return self.dunge_panel_info
end

function GodCelebrationModel:IsGodScoreScene(sceneId)
    sceneId = sceneId or SceneManager:GetInstance():GetSceneId()
    local config = Config.db_scene[sceneId]
    if not config then
        return false
    end
    if config.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_TOWER then
        return true
    end
    return false
end

function GodCelebrationModel:GetNeedPower()
    local cf = Config.db_rank
    for i = 1, #cf do
        local list = cf[i]
        if list.id == 150101 then
            self.need_power = list.limen
            break
        end
    end
    self.need_power = GetShowNumber(self.need_power) or 99999
end

-------------------------------------------------------------------------------- copy

function GodCelebrationModel:GetRushBuyShopList(actId)
    local cfg = Config.db_mall
    local tab = {}
    local index = 0
    for i, v in pairs(cfg) do
        if v.activity == actId then
            index = index + 1
            local tab1 = {}
            tab1["id"] = v.id
            tab1["order"] = v.order

            tab1["times"] = 0
            tab[index] = tab1
            --tab[v.id] = v
            -- table.insert(tab,v)
        end
    end

    table.sort(tab, function(a, b)
        return a.order < b.order
    end)

    return tab
end

--function GodCelebrationModel:GetRushBuyShopList()
--    return self.shopList
--end

function GodCelebrationModel:GetRankTypeStr(eventid, rankId)
    --local str = ""
    local roledata = RoleInfoModel.GetInstance():GetMainRoleData()
    -- dump(Roledata)
    if eventid == 1 then
        -- 等级
        return roledata.level
    elseif eventid == 17 then
        --坐骑或者副手
        if rankId == 110502 then
            --坐骑
            return MountModel:GetInstance().layer .. "Stage" .. MountModel:GetInstance().level .. "Star"
        else
            return MountModel:GetInstance().offhand_layer .. "Stage" .. MountModel:GetInstance().offhand_level .. "Star"
        end
    elseif eventid == 0 then
        --魔法卡
        return 0
    elseif eventid == 16 then
        -- 充值
        return 0 --还没写
    elseif eventid == 12 then
        --战力
        return roledata.power
    end
    return 0
end

function GodCelebrationModel:GetLastRankID()

end
--升级攻略
function GodCelebrationModel:GetLevelRecTab(rankId)
    local cfg = Config.db_rank_active
    local tab = {}
    for i, v in pairs(cfg) do
        if v.id == rankId then
            table.insert(tab, v)
        end
    end
    table.sort(tab, function(a, b)
        return a.sort < b.sort
    end)
    return tab
end

function GodCelebrationModel:SwitchState(state)

    local num = 0
    if state == 1 then
        num = 1
    elseif state == 2 then
        num = 3
    else
        num = 2
    end
    return num
end
--通过ID得到坐骑阶数
function GodCelebrationModel:GetMountNumByID(id)
    local Cfg = Config.db_mount
    for i, v in pairs(Cfg) do
        if v.id == id then
            return v
        end
    end
    return nil
end

--通过ID得到副手阶数
function GodCelebrationModel:GetOffhandNumByID(id)
    local Cfg = Config.db_offhand
    for i, v in pairs(Cfg) do
        if v.id == id then
            return v
        end
    end
    return nil
end

function GodCelebrationModel:GetActType(actId)
    local cfg = OperateModel:GetInstance():GetConfig(actId)
    if not cfg then
        return
    end
    return cfg.type
end

function GodCelebrationModel:UpdateRedPoint()
    for i, v in pairs(self.redPoints) do
        OperateModel:GetInstance():UpdateIconReddot(i, v)
    end
    self:Brocast(GodCeleEvent.RedPointInfo)
end

--------------------------------------------------------------------------------