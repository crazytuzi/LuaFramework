DungeonData = DungeonData or BaseClass()
    
DUNGEONDATA_LIANYU_OPRATE_TYPE = {
    fight = 0, --挑战副本
    sweep =1, -- 扫荡副本
    buy = 2, --购买次数
    get = 3, -- 获取奖励
}
-- 事件监听
DungeonData.LuckyInfoChange = "lucky_info_change"

function DungeonData:__init()
    -- body
    if DungeonData.Instance ~= nil then
        ErrorLog("[WingShenyuData] Attemp to create a singleton twice !")
    end
    GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
    DungeonData.Instance = self

    GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
    EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
    RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRewardRemind, self), RemindName.CaiLiaoFBReward)

    self.record_str_t = {}
    self.luck_turnble_info = {}
    self.cl_fube_info = {}

    self.check_box_status_list = {false, false, false, false, false}

    self.exp_fuben_show_list = self:InitExpShowList()
end

function DungeonData:OnRecvMainRoleInfo()
    RemindManager.Instance:DoRemindDelayTime(RemindName.CaiLiaoFBReward)
end

function DungeonData:RoleAttrChange(vo)
    if vo.key == OBJ_ATTR.CREATURE_LEVEL then 
        RemindManager.Instance:DoRemindDelayTime(RemindName.CaiLiaoFBReward)
    end
end

function DungeonData:UpdateCailiaoData(cl_fube_info)
    if nil == cl_fube_info then return end
    self.cl_fube_info = cl_fube_info
    RemindManager.Instance:DoRemindDelayTime(RemindName.CaiLiaoFBReward)
end

--获取副本信息
function DungeonData:SetLuckData(info)
    self.luck_turnble_info = info
    for i,v in ipairs(self.luck_turnble_info) do
        self:UpdateRecordStr(v.extend_str, i,v.ope_type)
    end
    self:DispatchEvent(DungeonData.LuckyInfoChange)
end


function DungeonData:GetRemindFunc()
    self.get_remind_func = self.get_remind_func or {}
    --材料副本
    self.get_remind_func[1] = function ()
        for k,v in pairs(self:GetFubenCLList()) do
            if v.static_id ~= 5 and self.cl_fube_info[v.static_id]  then
                if self.cl_fube_info[v.static_id].challge_count > 0 then
                   return true
               else
                    if self:GetLuckTurnbleDrawNum(v.static_id) > 0 then
                        return true
                    end
                end
            end
        end 
        return false
    end
    --经验副本
    local cfg = FubenZongGuanCfg.fubens[5] 
    self.get_remind_func[2] = function ()
        -- for k,v in pairs(DungeonData.Instance.cl_fube_info) do
        --     if v.static_id == 5 
        --      and RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= cfg.lv then
        --         if v.challge_count > 0 then
        --             return true
        --         else
        --             if v.sweep_count > 0 then
        --                 return true
        --             end
        --         end  
        --     end
        -- end 
        return false
    end
    return self.get_remind_func
end

function DungeonData:GetRewardRemind()
    for k,v in pairs(self:GetRemindFunc()) do
        if v() then return 1 end
    end
    return 0
end

--获取副本信息
function DungeonData:GetFubenCLList()
    local list = {}
    local cfg = FubenZongGuanCfg.fubens
    local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)

    for i,v in ipairs(cfg) do
        --经验副本 使用新切页
        if v.fbid ~= 31 then
            table.insert(list, v)
        end
    end

    -- table.sort(list, function (a, b)
    --     local info = self:GetFubenInfo(a.static_id)
    --     local info2 = self:GetFubenInfo(b.static_id)
    --     if nil == info or nil == info then return false end
    --     return info.challge_count > info2.challge_count
    -- end )

    return list
end

--获取副本信息
function DungeonData:GetFubenInfo(static_id)
    if not self.cl_fube_info then return nil end
    for __,v in pairs(self.cl_fube_info) do
        if v.static_id == static_id then
            return v
        end
    end
    return nil
end

function DungeonData:__delete()
    -- body
    DungeonData.Instance = nil
end



local RECORD_LEGTH_LIMIT = 30 -- 记录长度限制
function DungeonData:UpdateRecordStr(record_str, id,type)
    self.record_str_t[id] = self.record_str_t[id] or {}
    --叠加记录
    if record_str then
        if nil == next(self.record_str_t[id]) then
            self.record_str_t[id] = Split(record_str, ";")
        else
            if type == 2 then
                table.insert(self.record_str_t[id], record_str)
                if #self.record_str_t[id] > RECORD_LEGTH_LIMIT then
                    for i = 1, #self.record_str_t[id] - 30 do
                        table.remove(self.record_str_t[id], i)
                    end
                end
            end
        end
    end
end

function DungeonData:GetLuckTurnbleDrawNum(id)
    return self.luck_turnble_info[id] and self.luck_turnble_info[id].count or 0
end

function DungeonData:GetLuckTurnbleArwardIdx(id)
    return self.luck_turnble_info[id].index
end

function DungeonData:GetLuckTurnbleArwardList(id)
    return self.luck_turnble_info[id].sever_award_list
end

function DungeonData:GetLuckTurnbleGlodNum(id)
    return self.luck_turnble_info[id].pool_yb
end
function DungeonData:GetLuckTurnbleArwardCfgType(id)
    return self.luck_turnble_info[id].award_cfg_type
end

function DungeonData:GetLuckTurnbleRecord(id)
    local list = {}
    for k, v in pairs(self.record_str_t[id]) do
        if v then
            local str_t = Split(v, "#")
            --名字#奖励索引#个数
            local vo = {
                name = str_t[1],
                award_cfg_type = tonumber(str_t[2]),
                idx = tonumber(str_t[3]),
                num = tonumber(str_t[4]),
            }

            if str_t[4] and str_t[3] and not string.find(str_t[3], ";") then
                table.insert(list, vo)
            end
        end
    end

    return list
end

function DungeonData:InitExpShowList()
    local data = {}
    for i,v in ipairs(expFubenConfig.level) do
            data[i] = {
            conditions = v.condition,
            showAwards = v.scoreAwards[4], --展示难度4的奖励
            level = i,
        }
    end
    return data
end

function DungeonData:GetListInfo()
    return self.exp_fuben_show_list
end

--根据波数以及难度获得评分
function DungeonData:GetScore(level, had_skill_num)
    local score = 1
    local cfg = expFubenConfig.level[level]
    if cfg then
        local cur_cfg = cfg.MonsterWaveNum[had_skill_num]
        if cur_cfg then
            return cur_cfg.scorelv
        end
    end
    return score
end

--根据难度和评分获得奖励
function DungeonData:GetRewardDataByScoreAndlevel(level, score)
   local cfg = expFubenConfig.level[level]
   if cfg then
        local reward = cfg.scoreAwards[score]
        if reward then
            return reward
        end
   end
   return {}
end

--得到当前难度是否开启
function DungeonData:GetIsOpen(conditions, cur_level)
    local is_max_level  = FubenData.Instance:GetCurMaxLevel()
    local is_max_score = FubenData.Instance:GetHadMaxBo()
    local score = DungeonData.Instance:GetScore(is_max_level, is_max_score)
    local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
    local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)

    if is_max_level > cur_level then
        if circle >= conditions.circle and role_level >= conditions.level  then
            return true
        end
    elseif is_max_level == cur_level then
        if circle >= conditions.circle and role_level >= conditions.level  then
            return true
        end
    elseif cur_level == 1 then
         if circle >= conditions.circle and role_level >= conditions.level  then
            return true
        end
    elseif cur_level == (is_max_level + 1) then
         if circle >= conditions.circle and role_level >= conditions.level and score >= conditions.scoreLv then
            return true
        end
    end
 
    return false
end

function DungeonData:GetSaoDangIsOpen(cur_level)
    local is_max_level  = FubenData.Instance:GetCurMaxLevel()
    if is_max_level > cur_level then
        return true
    end
    return false
end

-- 得到当前条件
function DungeonData:GetCurConditionByLevel( cur_level)
    local config = expFubenConfig.level[cur_level]
    if config then
        return config.condition
    end
    return expFubenConfig.level[1].condition 
end

function DungeonData:GetHadMonsterLevel(level)
   local config = expFubenConfig.level[level]
   if config then
        return #config.MonsterWaveNum
   end
   return 15
end


--炼狱副本 --根据波数得到怪我数量
function DungeonData:GetMonsterNumByBo(bo_num)
    local cfg = PurgatoryFubenConfig.MonsterWaveNum[bo_num] or {}
    local monster_list = cfg.refreshList or {}
    local num = 0
    for k, v in pairs(monster_list) do
        num = num + v.count
    end
    return cfg.award, num
end