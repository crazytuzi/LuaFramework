--[[
    filename: ComBattle.BattleData.lua
    description: 一场战役的数据中心
    date: 2016.08.08

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local table_insert = table.insert
local table_remove = table.remove

require("Config.SystemVersionNumber")

local BattleData = class("BattleData", function()
    return bd.func.bindProperty({
        battle_ = {
            layer       = nil, -- 主场景
            params      = nil, -- 战斗传入参数
            LogicCore   = nil, -- 战斗的计算核心
            viewName    = nil, -- 显示人物名称
            speed       = bd.CONST.speed.trustee, -- 播放速度
            stageIdx    = nil, -- 战斗场次
            stageCount  = nil,
            finishValue = nil,
            challenge   = nil, -- 胜利条件
            treasure    = nil,
            teaminfo    = nil,
            fullinfo    = nil,
            dressID     = {},
            records     = {
                calcVer = require("ComLogic.LogicVersion"),
                sysVer  = SystemVersionNumber.items[1].systemNum,
            }, -- 战斗记录，用于传回服务器端校验
            damageRecord = {},
        },
        stage_  = {
            nodeList    = {},  -- 人物节点列表
            challenge   = nil,
            roundIdx    = nil, -- 当前回合数
            finishValue = nil, -- 战斗结束返回的数据
            isZhenshouAttacking = false, -- 标志是否有珍兽正在行动
        },
        ctrl_ = {
            trustee_ = {
                viewable   = true,
                state      = bd.trusteeState.eSpeedUpAndTrustee,
                executable = nil,
            },
            skip_    = {
                viewable   = true,
                clickable  = nil,
                executable = nil,
                state      = nil,
                enable     = true,  -- 是否可点
            },
            skill_   = {
                viewable = true,
            },
            skillFeature_ = {
                enable = true,
            },
            camera_  = {
                enable = true,
            },
            rebornNum_ = {
                enemyEnable = true,
                friendlyEnable = true,
            },
        },
    }, {
        -- 为以下属性绑定 setter/getter、事件触发
        ["battle"] = {
            layer       = false,
            params      = false,
            LogicCore   = false,
            viewName    = true,
            speed       = true,
            stageIdx    = false,
            stageCount  = false,
            finishValue = true,
            records     = false,
            challenge   = false,
            treasure    = false,
            teaminfo    = false,
            fullinfo    = false,
            dressID     = false,
        },
        ["stage"] = {
            roundIdx    = true,
            finishValue = false,
        },
        ["ctrl"] = {
            ["trustee"] = {
                viewable   = true,
                state      = true,
                executable = false,
            },
            ["skip"]    = {
                viewable   = true,
                clickable  = false,
                executable = false,
                state      = true,
                enable     = true,
            },
            ["skill"]   = {
                viewable = true,
            },
            ["skillFeature"] = {
                enable = true,
            },
            ["camera"]  = {
                enable = false,
            },
            ["rebornNum"] = {
                enemyEnable = false,
                friendlyEnable = false,
            },
        },
    })
end)

--[[
    params:
        layer
        data
    return:
        NULL
]]
function BattleData:ctor(params)
    self.get_battle_speed = nil
    self.set_ctrl_trustee_state = nil

    self.spdy_ = params.spdy

    -- 主将buff数据
    self.heroBuff_ = {}

    self:set_battle_layer(params.layer)
    -- 保存原始数据
    self:set_battle_params(params.data)
    -- 加载数据
    self:reloadData(params.data)
end


function BattleData:release()
    self.battle_ = nil
    self.stage_ = nil
end


-- @加载数据
function BattleData:reloadData(params)
    if params.challengeStr then
        local conditions = ld.split(params.challengeStr, ",")
        if conditions then
            local challenge = {}
            for _, c in ipairs(conditions) do
                local cond = ld.split(c, "|")
                if cond and #cond == 2 then
                    table_insert(challenge, {
                        Type = tonumber(cond[1]),
                        Value = tonumber(cond[2]),
                    })
                end
            end

            self:set_battle_challenge(challenge)
        end
    elseif params.data.Condition
        and params.data.Condition.Type
        and params.data.Condition.Type > 0
      then
        self:set_battle_challenge({params.data.Condition})
    end

    if params.data.TreasureInfo
        and #params.data.TreasureInfo ~= 0
      then
        self:set_battle_treasure(params.data.TreasureInfo)
    elseif params.data.TreasureId then
        local id = tonumber(params.data.TreasureId)
        if id ~= 0 then
            local item = XxbzModel.items[id]
            if item then
                self:set_battle_treasure({
                    {
                        RewardId      = id,
                        RewardTypeId  = item.rewardTypeID,
                        RewardModelId = item.rewardModelID,
                    }
                })
            else
                bd.log.error(string.format("TreasureId(%d) not found in XxbzModel", id))
            end
        end
    end

    if params.data.TeamInfo then
        self:set_battle_teaminfo(params.data.TeamInfo)
    end

    self.battle_.stageData = LoadServerData(params.data)

    self:set_battle_stageCount(#self.battle_.stageData)

    self:set_battle_stageIdx(1)

    if params.trustee then
        if params.trustee.viewable ~= nil then
            self:set_ctrl_trustee_viewable(params.trustee.viewable)
        end
        if params.trustee.state ~= nil then
            self:set_ctrl_trustee_state(params.trustee.state)
        end
        self:set_ctrl_trustee_executable(params.trustee.executable)
    end

    if bd.project == "project_huanzhu" then
        if params.trustee and params.trustee.state == bd.trusteeState.eSpeedUpAndTrustee then
            local open = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBattleTuoGuan, false)
            self:set_ctrl_trustee_state(open and bd.trusteeState.eSpeedUpAndTrustee
                or bd.trusteeState.eSpeedUp)
        else
            self:set_ctrl_trustee_state(bd.trusteeState.eSpeedUp)
        end
    end

    if params.skip then
        if params.skip.viewable ~= nil then
            self:set_ctrl_skip_viewable(params.skip.viewable)
        end
        self:set_ctrl_skip_clickable(params.skip.clickable)
        self:set_ctrl_skip_executable(params.skip.executable)
    end

    if params.skill then
        if params.skill.viewable ~= nil then
            self:set_ctrl_skill_viewable(params.skill.viewable)
        end
    end

    if params.skillFeature then
        if params.skillFeature.enable ~= nil then
            self:set_ctrl_skillFeature_enable(params.skillFeature.enable)
        end
    end

    if params.camera then
        if params.camera.enable ~= nil then
            self:set_ctrl_camera_enable(params.camera.enable)
        end
    end

    dump(params.rebornNum, "params.rebornNum")
    if params.rebornNum then
        if params.rebornNum.enemyEnable ~= nil then
            self:set_ctrl_rebornNum_enemyEnable(params.rebornNum.enemyEnable)
        end
        if params.rebornNum.friendlyEnable ~= nil then
            self:set_ctrl_rebornNum_friendlyEnable(params.rebornNum.friendlyEnable)
        end
    end
end

-- @设置托管状态
function BattleData:set_ctrl_trustee_state(state)
    -- 相同则直接返回
    if state == self:get_ctrl_trustee_state() then
        return
    end

    self.ctrl_.trustee_.state = state

    -- 速度
    local speed
    if (state == bd.trusteeState.eSpeedUpAndTrustee)
        or (state == bd.trusteeState.eSpeedUp) then
        speed = bd.CONST.speed.trustee
    else
        speed = bd.CONST.speed.normal
    end

    -- 触发通知
    self:emit("ctrl_trustee_state", state)

    -- 修改速度
    self:set_battle_speed(speed)
end


-- @获取战斗速度
function BattleData:get_battle_speed()
    return self.battle_["speed"] or bd.CONST.speed.normal
end


-- @获取当前关卡数据
function BattleData:getCurrentStageData()
    return self.battle_.stageData[self.battle_.stageIdx]
end


-- @计算动作时长
function BattleData:actTime(delay)
    return delay / self:get_battle_speed()
end

-- @存储heroNode
function BattleData:bindHeroNode(node)
    self.stage_.nodeList[node.idx] = node
end

function BattleData:unbindHeroNode(node_or_idx)
    if type(node_or_idx) ~= "number" then
        node_or_idx = node_or_idx.idx
    end

    self.stage_.nodeList[node_or_idx] = nil
end


-- @获取所有 heroNode
function BattleData:getHeroNodeList()
    return self.stage_.nodeList
end

-- @获取指定位置的 heroNode
function BattleData:getHeroNode(idx)
    return self.stage_.nodeList[idx]
end

--[[
    params:
        posId
        value   实际变化值
        type
        ORGHP   显示值
    return:
        NULL
]]
function BattleData:fixHP(params)
    local node = self:getHeroNode(params.posId)
    if params.value then
        node.cHP = node.cHP + params.value

        -- 判断是否溢出
        if node.cHP > node.mHP then
            node.cHP = node.mHP
        elseif node.cHP < 0 then
            node.cHP = 0
        end

        self:recordDamage(params.from, params.value)

        -- 触发通知
        self:emit(bd.event.eHP, params.posId, params.value, node.cHP, params.type, params.ORGHP)
    end
end

function BattleData:recordDamage(from, hp)
    if (not from) or (not hp) then
        return
    end

    local record = self.battle_.damageRecord[self.battle_.stageIdx]
    if not record then
        record = {}
        self.battle_.damageRecord[self.battle_.stageIdx] = record
    end

    local personal = record[from]
    if not personal then
        personal = {
            hp = 0, -- 治疗量
            dp = 0, -- 伤害量
        }
        record[from] = personal
    end

    if hp > 0 then
        personal.hp = personal.hp + hp
    else
        personal.dp = personal.dp - hp
    end
end

--[[
    params:
        posId
        value
        type
    return:
        NULL
]]
function BattleData:fixRP(params)
    local node = self:getHeroNode(params.posId)
    if params.value then
        node.cRP = node.cRP + params.value
        -- 触发通知
        self:emit(bd.event.eRP, params.posId, params.value, node.cRP, params.type)
    end
end


--[[-------------------------------------------------------------------------
                               BUFF
---------------------------------------------------------------------------]]
-- @buff添加
function BattleData:addBuff(posId, info)
    local buff = self.spdy_:getBuffItem(info.id)

    if not self.heroBuff_[posId] then
        self.heroBuff_[posId] = {}
    end

    local allbuff = self.heroBuff_[posId]
    if not allbuff[buff.type] then
        allbuff[buff.type] = {}
    end

    table_insert(allbuff[buff.type], info)

    self:emit(bd.event.eBuffAdd, posId, info.id, info.uid)
end

-- @buff移除
function BattleData:delBuff(posId, info)
    if not self.heroBuff_[posId] then
        return
    end

    local allbuff = self.heroBuff_[posId]
    local buff = self.spdy_:getBuffItem(info.id)
    if not allbuff[buff.type] then
        return
    end

    for i, v in ipairs(allbuff[buff.type]) do
        if v.uid == info.uid then
            -- 删除buff
            table_remove(allbuff[buff.type], i)

            self:emit(bd.event.eBuffDel, posId, info.id, info.uid)
            break
        end
    end
end


function BattleData:getHeroBuff(posId)
    return self.heroBuff_[posId]
end


function BattleData:getChallengeValue(c)
    if not c then
        local challenge = self:get_battle_challenge()
        if not challenge then
            return
        end

        c = challenge[1]
    end

    if c.Type == bd.CONST.challengeType.eKillAll then
        -- 敌方全灭
        local value = 0
        for k, node in pairs(self:getHeroNodeList()) do
            if bd.interface.isEnemy(k) and (true ~= node.isDead_) then
                value = value + 1
            end
        end
        return value    --敌方剩余人数
    elseif c.Type == bd.CONST.challengeType.eWinInRound then
        -- x回合内获胜
        return self:get_stage_roundIdx() or 1   --当前回合数
    elseif c.Type == bd.CONST.challengeType.eHPRemain then
        -- 我方总生命高于x%
        local current = 0.0
        local max = 0.0
        for k, node in pairs(self:getHeroNodeList()) do
            if k <= 12 and bd.interface.isFriendly(k) then
                max = max + node.mHP
                if node.cHP > 0 then
                    current = current + node.cHP
                end
            end
        end
        return (max == 0) and 0 or math.floor(current/max * 100)
    elseif c.Type == bd.CONST.challengeType.eAliveRemain then
        -- 我方存活不少于x人
        local value = 0
        for k, node in pairs(self:getHeroNodeList()) do
            if k <= 12 and bd.interface.isFriendly(k) and (true ~= node.isDead_) then
                value = value + 1
            end
        end
        return value
    end

    return 0
end


function BattleData:getCoinReward()
    local treasureInfo = self:get_battle_treasure()
    if treasureInfo and #treasureInfo > 0 then
        -- 当前总伤害
        local total = 0
        local fullinfo = self:get_battle_fullinfo()
        if fullinfo then
            for k, v in pairs(fullinfo.heroList) do
                if bd.interface.isEnemy(k) then
                    total = total + v.mhp - v.hp
                end
            end
        end

        local out = {}
        for i , v in pairs(treasureInfo) do
            table.insert(out , bd.interface.getXXBZValue(v.RewardId, total))
        end
        return total, out
    end
end


-- @我方剩余主将
function BattleData:getAliveHero()
    local left = 0
    for k, v in pairs(self:getHeroNodeList()) do
        if bd.interface.isFriendly(k) and v.cHP > 0 then
            left = left + 1
        end
    end

    return left
end

-- @获取需要加载的spine
function BattleData:getSpineFiles()
    local stageData = self.battle_.stageData

    local spines = bd.patch and bd.patch.preloadSpines and clone(bd.patch.preloadSpines) or {}
    local skillIDs = {}

    -- 遍历关卡数据
    for _, data in ipairs(stageData) do
        local function load_hero(list)
            for i, hero in pairs(list) do
                if next(hero) ~= nil then
                    self:setSpineByHero(spines, hero)
                    self:setSkillByHero(skillIDs, hero)

                    if bd.project == "project_xueying" then
                        -- 道法资源
                        if hero and hero.TaoId and hero.TaoId > 0 then
                            local taoEffect = bd.patch.getTaoEffect(hero.TaoId)
                            if taoEffect then
                                local skill_config = require(string.format("BattleSkillConfig.kc_%s", taoEffect))
                                for _, v in ipairs(skill_config.res) do
                                    spines[v] = true
                                end
                            end
                        end
                    end
                end
            end
        end

        -- 遍历主将
        load_hero(data.HeroList)
        if data.StorageList then
            for _, list in pairs(data.StorageList) do
                load_hero(list)
            end
        end
    end

    -- 通过技能ID查找技能代码，再查找资源
    for id in pairs(skillIDs) do
        local skill_config = bd.interface.getSkillById(id)
        -- 特效文件
        if skill_config.res then
            for _, f in pairs(skill_config.res) do
                spines[f] = true
            end
        end
    end

    if bd.patch and bd.patch.getPreLoadFiles then
        local _, files = bd.patch.getPreLoadFiles(self, self.spdy)
        for k in pairs(files) do
            spines[k] = true
        end
    end

    -- 所有BUFF特效
    for k in pairs(bd.ui_config.buffEffectPostOffset) do
        spines[k] = true
    end

    return bd.func.getKey(spines)
end

-- @查找人物骨骼文件
function BattleData:setSpineByHero(list, hero)
    local heroPic = hero.LargePic
    if (not heroPic) or (heroPic == "") then
        local item = HeroModel.items[hero.HeroModelId]
        heroPic = item and item.largePic
    end

    if heroPic then
        list[heroPic] = true
    end
end

-- @查找技能ID
function BattleData:setSkillByHero(list, hero)
    if hero.NAId then
        list[hero.NAId] = true
    end

    if hero.RAId then
        list[hero.RAId] = true
    end
end

--[[-------------------------------------------------------------------------

---------------------------------------------------------------------------]]
function BattleData:getBuffItem(buffId)
    return self.spdy_:getBuffItem(buffId)
end

function BattleData:getHeroItem(heroId)
    return self.spdy_:getHeroItem(heroId)
end

function BattleData:getSkillItem(skillId)
    return self.spdy_:getHeroItem(heroId)
end

-- @获取组合技羁绊英雄位置，（英雄未死亡时才返回值）
function BattleData:getHeroPartnerPos(pos)
    if bd.project ~= "project_sanguo" and bd.project ~= "project_shediao" then
        return
    end

    local node = self:getHeroNode(pos)
    if node then
        local typ = bd.interface.isFriendly(node.idx)
        local id = self.spdy_:getHeroPartner(node.illusionModelId and node.illusionModelId ~= 0 and node.illusionModelId or node.heroId)
        if id then
            for pos, v in pairs(self:getHeroNodeList()) do
                -- 友方
                if typ == bd.interface.isFriendly(pos) then
                    -- 普通角色合体
                    if (v.heroId == id
                        or (id == 0 and self.spdy_:getHeroItem(v.heroId).specialType == 255))
                        and v.illusionModelId == 0 then
                        if true ~= v.isDead_ then
                            return pos
                        end
                        return
                    -- 幻化角色合体
                    elseif v.illusionModelId == id and v.illusionModelId ~= 0 then
                        if true ~= v.isDead_ then
                            return pos
                        end
                        return
                    end
                end
            end
        end
    end
end

return BattleData
