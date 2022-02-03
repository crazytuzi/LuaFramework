-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      圣器数据
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
HallowsVo = HallowsVo or BaseClass(EventDispatcher) 

local table_insert = table.insert

function HallowsVo:__init()
    self.id = 0                     -- 圣器id
    self.step = 1                   -- 圣器阶数
    self.lucky = 0                  -- 当前幸运值
    self.lucky_endtime = 0          -- 幸运值清零时间
    self.power = 0                  -- 圣器战力
    self.seal = 0                   -- 当前圣印数量
    self.add_attr = {}              -- 总属性加成 attr_id attr_val 
    self.reward = {}                -- 奖励列表
    self.skill_bid = 0              -- 神器技能id
    self.skill_lev = 1              -- 神器技能等级
    self.look_id = 0                -- 幻化id（0为未幻化）
    self.refine_lev = 0             -- 精炼等级

    self.is_update = false

    self.red_status_list = {}       -- 红点状态
end

function HallowsVo:initAttributeData(data)
    self.is_update = true 
    for k, v in pairs(data) do
        if type(v) ~= "table" then
            self:updateSingleData(k, v)
        else
            if k == "add_attr" then
                self:updateAddAttr(v)
            --[[elseif k == "eqm" then
                self:updateEquip(v)--]]
            elseif k == "skill" then
                self:updateSkill(v)
            --[[elseif k == "reward" then
                self:updateRewards(v)--]]
            end
        end
    end
end

--==============================--
--desc:单个属性变化
--time:2018-09-27 03:04:02
--@key:
--@value:
--@return 
--==============================--
function HallowsVo:updateSingleData(key, value)
    if self[key] ~= value then
        self[key] = value
    end
end

--==============================--
--desc:总属性
--time:2018-09-27 03:06:30
--@value:
--@return 
--==============================--
function HallowsVo:updateAddAttr(value)
    self.add_attr = value or {}
end

--==============================--
--desc:计算红点状态
--time:2018-09-30 09:24:53
--@force:
--@return 
--==============================--
function HallowsVo:checkRedStatus(force)
    if self.is_update == true or force == true then
        self.is_update = false
        self.red_status_list = {}
        return false
        -- 旧的红点逻辑，可能加回来，暂时保留。
        --[[local is_can_upgrade = self:checkCanUpgrade()
        local is_can_trace = self:checkCanUseTrace()
        local is_can_skill = self:checkCanUpgradeSkill()

        self.red_status_list[HallowsConst.red_type.advance] = is_can_upgrade
        self.red_status_list[HallowsConst.red_type.rewards] = is_can_rewards 
        self.red_status_list[HallowsConst.red_type.trace] = is_can_trace 
        self.red_status_list[HallowsConst.red_type.skill] = is_can_skill 
        return is_can_upgrade or is_can_rewards or is_can_trace or is_can_skill--]]
    else
        for k,v in pairs(self.red_status_list) do
            if v == true then return true end
        end
    end
    return false
end

function HallowsVo:getRedStatus(type)
    return self.red_status_list[type]
end

--- 是否可以进阶(暂时屏蔽)
function HallowsVo:checkCanUpgrade()
    return false
end

-- 判断是否可以使用圣印(暂时屏蔽)
function HallowsVo:checkCanUseTrace()
    return false
    --[[if self.step < 3 then return false end   --小于三阶不可以吃圣印
    local trace_config = Config.HallowsData.data_trace_cost(getNorKey(self.id, self.step))
    if trace_config == nil then return false end
    if self.seal >= trace_config.num then return false end

    local bid = 72003
    local backpack_model = BackpackController:getInstance():getModel()
    local sum = backpack_model:getBackPackItemNumByBid(bid)
    return sum > 0--]]
end

--- 判断是否可以升技能(暂时屏蔽)
function HallowsVo:checkCanUpgradeSkill()
    return false
    --[[
    local bid = 72002
    local backpack_model = BackpackController:getInstance():getModel()
    local red_status = false
    
    return red_status--]]
end

--==============================--
--desc:更新圣技属性
--time:2018-09-27 03:09:42
--@v:
--@return 
--==============================--
function HallowsVo:updateSkill(data)
    if data[1] then -- 圣技只有一个技能，写死读取列表第一个
        self.skill_bid = data[1].skill_bid
        self.skill_lev = data[1].lev
    end
end

--==============================--
--desc:更新已经领取的进阶奖励
--time:2018-09-27 03:27:35
--@data:
--@return 
--==============================--
--[[function HallowsVo:updateRewards(data)
    self.is_update = true
    for i,v in ipairs(data) do
        self.reward[v.reward_id] = true
    end
end--]]

--==============================--
--desc:判断一个阶数奖励是否已经领取过了
--time:2018-09-27 03:29:19
--@step:
--@return 
--==============================--
function HallowsVo:checkRewardsIsOver(step)
    return self.reward[step]
end

--获取神器技能伤害值、精炼伤害值
function HallowsVo:getHallowsSkillAndRefineAtkVal(  )
    local skill_atk_val = 0
    local refine_atk_val = 0
    local hallows_skill =Config.HallowsData.data_skill_up(getNorKey(self.id, self.skill_lev))
    if hallows_skill then
        local skill_cfg = Config.SkillData.data_get_skill(hallows_skill.skill_bid)
        if skill_cfg then
            skill_atk_val = skill_cfg.hallows_atk or 0
        end
    end

    local refine_cfg = Config.HallowsRefineData.data_refine[self.id]
    if refine_cfg then
        local hallows_refine_cfg = refine_cfg[self.refine_lev]
        if hallows_refine_cfg then
            refine_atk_val = hallows_refine_cfg.add_dps or 0
        end
    end
    
    return skill_atk_val, refine_atk_val
end

function HallowsVo:__delete()
end