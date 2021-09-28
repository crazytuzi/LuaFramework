
require("Config.SystemVersionNumber")

local BattleData_guide = class("BattleData_guide", function()
    return bd.func.bindProperty({
        battle_ = {
            layer       = nil, -- 主场景
            params      = nil, -- 战斗传入参数
            LogicCore   = nil, -- 战斗的计算核心
            viewName    = nil, -- 显示人物名称
            speed       = bd.CONST.speed.trustee, -- 播放速度
            stageIdx    = nil, -- 战斗场次
            stageCount  = nil,
            loadSkel    = {},
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
        },
        stage_  = {
            nodeList    = {},  -- 人物节点列表
            roundIdx    = nil, -- 当前回合数
            finishValue = nil, -- 战斗结束返回的数据
        },
        ctrl_ = {
            trustee_ = {
                viewable   = false,
                state      = bd.trusteeState.eSpeedUp,
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
                viewable = true,
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
            finishValue = false,
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
                enable = true,
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
function BattleData_guide:ctor(params)
    self.get_battle_speed = nil
    self.set_ctrl_trustee_state = nil
    self.ignoreSkillRefresh = true

    self.spdy_ = params.spdy

    -- 主将buff数据
    self.heroBuff_ = {}

    self:set_battle_layer(params.layer)
    -- 保存原始数据
    self:set_battle_params(params.data)

    self:reloadData(params.data)
end


-- @加载剧情数据
function BattleData_guide:reloadData(params)
    self:set_battle_stageIdx(1)

    self.battle_.stageData = {
        [1] = { HeroList = {}, data = params.data, PetList = {}, PetList2 = {}, PetList3 = {}, }
    }
    self.stage_.stepIdx = 1

    if params.trustee then
        if params.trustee.viewable ~= nil then
            self:set_ctrl_trustee_viewable(params.trustee.viewable)
        end
        if params.trustee.state ~= nil then
            self:set_ctrl_trustee_state(params.trustee.state)
        end
        self:set_ctrl_trustee_executable(params.trustee.executable)
    end

    if params.skip then
        if params.skip.viewable ~= nil then
            self:set_ctrl_skip_viewable(params.skip.viewable)
        end
        self:set_ctrl_skip_clickable(params.skip.clickable)
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
function BattleData_guide:set_ctrl_trustee_state(state)
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
function BattleData_guide:get_battle_speed()
    return self.battle_["speed"] or bd.CONST.speed.normal
end


-- @获取当前关卡数据
function BattleData_guide:getCurrentStageData()
    return self.battle_.stageData[self.battle_.stageIdx]
end


-- @存储heroNode
function BattleData_guide:bindHeroNode(node)
    self.stage_.nodeList[node.idx] = node
end

function BattleData_guide:unbindHeroNode(node_or_idx)
    if type(node_or_idx) ~= "number" then
        node_or_idx = node_or_idx.idx
    end

    self.stage_.nodeList[node_or_idx] = nil
end


-- @获取所有 heroNode
function BattleData_guide:getHeroNodeList()
    return self.stage_.nodeList
end

-- @获取指定位置的 heroNode
function BattleData_guide:getHeroNode(idx)
    return self.stage_.nodeList[idx]
end


function BattleData_guide:actTime(delay)
    return delay / self:get_battle_speed()
end


-- @获取当前步骤剧情
function BattleData_guide:getStepData()
    local step = self.stage_.stepIdx
    self.stage_.stepIdx = step + 1
    return self.battle_.stageData[self.battle_.stageIdx].data.action[step]
end

function BattleData_guide:getNextStepData()
    return self.battle_.stageData[self.battle_.stageIdx].data.action[self.stage_.stepIdx]
end

-- @获取主将信息
function BattleData_guide:getHeroData(i)
    return self.battle_.stageData[self.battle_.stageIdx].data.hero[i]
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
function BattleData_guide:fixHP(params)
    local node = self:getHeroNode(params.posId)
    if params.value then
        node.cHP = node.cHP + params.value

        -- 判断是否溢出
        if node.cHP > node.mHP then
            node.cHP = node.mHP
        elseif node.cHP < 0 then
            node.cHP = 0
        end

        -- 触发通知
        self:emit(bd.event.eHP, params.posId, params.value, node.cHP, params.type , params.ORGHP)
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
function BattleData_guide:fixRP(params)
    local node = self:getHeroNode(params.posId)
    if params.value then
        node.cRP = node.cRP + params.value
        -- 触发通知
        self:emit(bd.event.eRP, params.posId, params.value, node.cRP, params.type)
    end
end



-- @buff添加
function BattleData_guide:addBuff(posId, info)
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
function BattleData_guide:delBuff(posId, info)
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
            -- 删除buff
            table_remove(allbuff[buff.type], i)

            self:emit(bd.event.eBuffDel, posId, info.id, info.uid)
            break
        end
    end
end


function BattleData_guide:getHeroBuff(posId)
    return self.heroBuff_[posId]
end


function BattleData_guide:getChallengeValue()
    return
end


function BattleData_guide:getCoinReward()
    return
end


function BattleData_guide:getAliveHero()
    return
end


-- @获取组合技羁绊英雄ID
function BattleData_guide:getHeroPartnerPos(pos)
    if bd.project ~= "project_sanguo" and bd.project ~= "project_shediao" then
        return
    end

    local node = self:getHeroNode(pos)
    if node then
        local id = self.spdy_:getHeroPartner(node.heroId)
        if id then
            for pos, v in pairs(self:getHeroNodeList()) do
                if v.heroId == id then
                    if true ~= v.isDead_ then
                        return pos
                    end
                    return
                end
            end
        end
    end
end

-- @获取需要加载的spine
function BattleData_guide:getSpineFiles()
    local stageData = self.battleData.battle_.stageData

    local spines = bd.patch and bd.patch.preloadSpines and clone(bd.patch.preloadSpines) or {}
    local skillIDs = {}

    for _, v in ipairs(stageData) do
        -- 查找主将技能
        local function find_hero_skill(hero, config)
            local function _input(id)
                if type(id) == "table" then
                    for _, v in ipairs(id) do
                        skillIDs[v] = true
                    end
                else
                    skillIDs[id] = true
                end
            end

            local nID = hero.normalId or (config and config.NAID)
            if nID then
                _input(nID)
            end

            local sID = hero.skillId or (config and config.RAID)
            if sID then
                _input(sID)
            end
        end

        -- 查找动作中需要加载的资源
        for _, frame in ipairs(v.data.action) do
            for _, value in ipairs(frame) do
                -- 技能
                if value.type == ActionType_guide.eFight then
                    if value.skillId then
                        skillIDs[value.skillId] = true
                    end

                -- 特效
                elseif value.type == ActionType_guide.eEffect then
                    if value.file then
                        spines[value.file] = true
                    end
                end
            end
        end

        -- 遍历商场的人物
        for _, v in pairs(v.data.hero) do
            local heroModelID = nil
            if v.type == HeroCreateType.eFigure then
                spines[v.figureName] = true
                find_hero_skill(v)

                heroModelID = bd.interface.getHeroIdByFigure(v.figureName)
            elseif v.type == HeroCreateType.eNPC then
                require("Config.BattleNodeGuidenpcRelation")
                local item = bd.interface.getGuideNPC(v.config)
                bd.assert(item, TR("找不到NPC数据: %s", v.config))
                spines[item.largePic] = true

                find_hero_skill(v, item)

                heroModelID = v.heroModelID
            elseif v.type == HeroCreateType.eFormation then
                if g_skill_editor then
                    require("Config.BattleNodeGuidenpcRelation")
                    local npcId = nil
                    for i ,v in pairs(BattleNodeGuidenpcRelation.items) do
                        if v.heroModelID ~= 0 and bd.data_config.HeroModel.items[v.heroModelID] then
                            npcId = i
                            break
                        end
                    end
                    local item = bd.interface.getGuideNPC(npcId)
                    spines[item.largePic] = true
                else
                    local formation = bd.interface.getFormationSlot(v.formationId)
                    local largePic = bd.interface.getFigureNameByHeroId(formation.ModelId)
                    spines[largePic] = true

                    find_hero_skill(v, item)

                    heroModelID = formation.ModelId
                end
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

    if bd.patch and bd.patch.getSpineFiles then
        local files = bd.patch.getPreLoadFiles(self.battleData, self.battleSpdy)
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

--[[-------------------------------------------------------------------------

---------------------------------------------------------------------------]]
function BattleData_guide:getBuffItem(buffId)
    return self.spdy_:getBuffItem(buffId)
end

function BattleData_guide:getHeroItem(heroId)
    return self.spdy_:getHeroItem(heroId)
end

function BattleData_guide:getSkillItem(skillId)
    return self.spdy_:getHeroItem(heroId)
end


-- @获取需要加载的资源
function BattleData_guide:getPreLoadFiles()
    local pictures = {
        -- Todo: 其他图片资源(气泡、什么的)
    }
    local largePics = {}
    local audioFiles = {}

    local ActionType_guide = {
        eMap        = 0,  -- 切换地图
        eMove       = 1,  -- 移动
        eIn         = 2,  -- 人物出现
        eOut        = 3,  -- 人物消失
        eChat       = 4,  -- 人物气泡对话
        eMessage    = 5,  -- 人物外部对话
        eDelay      = 6,  -- 延时
        eFight      = 7,  -- 配置战斗
        eSkill      = 8,  -- 技能引导
        eAutoBattle = 9,  -- 自动战斗
        eMusic      = 10, -- 切换bgm
        eSound      = 11, -- 播放音效
        eHurt       = 12, -- 受伤动作
        eShake      = 13, -- 抖动
        eEffect     = 14, -- 单个特效
        eDirection  = 15, -- 切换方向
    }

    local HeroCreateType = {
        eFigure    = 0, --通过大图直接创建
        eNPC       = 1, --通过配置的npc
        eFormation = 2, --通过我方上阵人物
    }

    local stageData = self.battle_.stageData

    local skillIDs = {}

    for _, v in ipairs(stageData) do
        -- 查找主将技能资源
        local function find_hero_skill(hero, config)
            local function _input(id)
                if type(id) == "table" then
                    for _, v in ipairs(id) do
                        skillIDs[v] = true
                    end
                else
                    skillIDs[id] = true
                end
            end

            local nID = hero.normalId or (config and config.NAID)
            if nID then
                _input(nID)
            end

            local sID = hero.skillId or (config and config.RAID)
            if sID then
                _input(sID)
            end
        end

        -- 查找动作中需要加载的资源
        for _, frame in ipairs(v.data.action) do
            for _, value in ipairs(frame) do
                if value.type == ActionType_guide.eFight then
                    if value.skillId then
                        skillIDs[value.skillId] = true
                    end

                -- 音效
                elseif value.type == ActionType_guide.eSound then
                    if value.file then
                        audioFiles[value.file] = true
                    end

                -- 特效
                elseif value.type == ActionType_guide.eEffect then
                    if value.file then
                        largePics[value.file] = true
                    end

                -- 聊天
                elseif value.type == ActionType_guide.eChat then
                    pictures[bd.ui_config.chatBG] = true

                    --获取试用的音频文件
                    local soundfile = Utility.getBattleMusicFile(value)
                    if soundfile then
                        audioFiles[soundfile] = true
                    end
                end
            end
        end

        -- 遍历商场的人物
        for _, v in pairs(v.data.hero) do
            local heroModelID = nil
            if v.type == HeroCreateType.eFigure then
                largePics[v.figureName] = true
                bd.interface.cacheHeroDaijiImage(self:get_battle_layer(), v.figureName)

                find_hero_skill(v)

                heroModelID = bd.interface.getHeroIdByFigure(v.figureName)
            elseif v.type == HeroCreateType.eNPC then
                require("Config.BattleNodeGuidenpcRelation")
                local item = bd.interface.getGuideNPC(v.config)
                bd.assert(item, TR("找不到NPC数据: %s", v.config))
                largePics[item.largePic] = true
                bd.interface.cacheHeroDaijiImage(self:get_battle_layer(), item.largePic)

                find_hero_skill(v, item)

                heroModelID = v.heroModelID
            elseif v.type == HeroCreateType.eFormation then
                if g_skill_editor then
                    require("Config.BattleNodeGuidenpcRelation")
                    local npcId = nil
                    for i ,v in pairs(BattleNodeGuidenpcRelation.items) do
                        if v.heroModelID ~= 0 and bd.data_config.HeroModel.items[v.heroModelID] then
                            npcId = i
                            break
                        end
                    end
                    local item = bd.interface.getGuideNPC(npcId)
                    largePics[item.largePic] = true
                    bd.interface.cacheHeroDaijiImage(self:get_battle_layer(), item.largePic)
                else
                    local formation = bd.interface.getFormationSlot(v.formationId)
                    local largePic = bd.interface.getFigureNameByHeroId(formation.ModelId)
                    largePics[largePic] = true
                    bd.interface.cacheHeroDaijiImage(self:get_battle_layer(), largePic)

                    find_hero_skill(v, item)

                    heroModelID = formation.ModelId
                end
            end

            -- 预加载切屏资源
            if heroModelID then
                local item = self:getHeroItem(heroModelID)
                if item then
                    if item.skillPic then
                        pictures[item.skillPic] = true
                    end
                    if item.drawingPicA and item.drawingPicA ~= "" then
                        largePics[item.drawingPicA] = true
                    end
                    if item.drawingPicB and item.drawingPicB ~= "" then
                        largePics[item.drawingPicB] = true
                    end
                    if item.jointSkillSound and item.jointSkillSound ~= "" then
                        audioFiles[item.jointSkillSound .. ".mp3"] = true
                    end
                end
            end
        end
    end

    -- 通过技能ID查找技能代码，再查找资源
    for id in pairs(skillIDs) do
        local skill_config = bd.interface.getSkillById(id)

        -- 特效文件
        if skill_config.res then
            for _, f in pairs(skill_config.res) do
                largePics[f] = true
            end
        end

        if skill_config.audio then
            for _, f in pairs(skill_config.audio) do
                audioFiles[f] = true
            end
        end
    end


    return pictures, largePics, audioFiles
end


return BattleData_guide
