--[[
    文件名：BattleProcess_guide
    描述：剧情模式战斗流程
    创建人：luoyibo
    创建时间：2016.08.12
-- ]]


--[[
    人物：
        类型：
        heroType = {
            eType1 = 0, --通过大图直接创建
            eType2 = 1, --通过配置的npc
            eType3 = 2, --通过我方上阵人物
        },
        --通过大图直接创建
        {
            type = 0,
            cs值
            figureName = "hero_biqiushou",形象
            normalId = {1001001},普攻id
            skillId = {1002001},技能id
            scale = 0,--大小（可缺省）缺省值为0
            name = "",--（可缺省）缺省值为""
            quality = 0,--品质（可缺省）缺省值为0
            heroId = 0,--头像对应的heroId
        },
        --通过配置的npc
        {
            type = 1,
            config = 10112111,(整数,BattleNodeGuidenpcRelation)
            scale = 0,--大小（可缺省）缺省值为0
            name = "",--（可缺省）缺省值为""
            quality = 0,--品质（可缺省）缺省值为0
        },
        --通过我方上阵人物
        {
            type = 2,
            formationId = 1,--我方阵容1号位
            scale = 0,--大小（可缺省）缺省值为0
            name = "",--（可缺省）缺省值为""
            quality = 0,--品质（可缺省）缺省值为0
        },
    动作：
        类型：
        actionType = {
            eMap = 0, --切换地图
            eMove = 1, --移动
            eIn = 2,    --人物出现
            eOut = 3,   --人物消失
            eChat = 4,  --人物气泡对话
            eMessage = 5, --人物外部对话
            eDelay = 6, --延时
            eFight = 7, --配置战斗
            eSkill = 8, --技能引导
            eAutoBattle = 9,--自动战斗
            eMusic = 10,     --切换bgm
            eSound = 11,     --播放音效
            eHurt = 12,      --受伤动作
            eShake = 13,     --抖动
            eEffect = 14,   --单个特效
        },
        --切换地图
        {
            type = 0,
            mapId = "地图名.jpg",
        }
        --移动
        {
            type = 1,
            from = 1,   --起始位置
            to = 1,     --结束位置
        }
        --人物出现
        {
            type = 2,
            heroId = 1,(人物id)
            posId = 2,(位置id)
            entryType = 1,移动类型bd.EntryType
        }
        --人物消失
        {
            type = 3,
            posId = 3,(位置id)
            outType = 1,移动类型bd.EntryType
        }
        --人物气泡对话
        {
            type = 4,
            chatType = 1,--(底框样式)ChatPicType
            posId = 1,--(显示位置)
            content_default = "",--(内容)
            content_female = "",--(内容) 缺省值为""
            sound_default = "",--(音效)男主。不分男女主的，放在sound。
            sound_female = "",--女主 缺省值为""
        },
        --人物外部对话
        {
            type = 5,
            messageId = 1,(特殊对话id)
        }
        --延时
        {
            type = 6,
            time = 1,(延迟时间)
        }
        --配置战斗
        {
            type = 7,
            fromPos = 1,(出手的位置)
            skillId = 123,(使用的技能id)
                        如果出手人为eType1，则是可用的技能id
                        否则（0：表示普攻，1：表示怒技）
            rage = -50,
            affect = {
                {
                    toPos = 1,(受击位置)
                    hp = -200,(生命变化)
                    rage = 23,(怒气变化)
                    effect = 2,(攻击方式，暴击，普通，格挡，闪避)
                }
            }
            dead = {
                1,2,4(死亡位置)
            },
        },
        --技能引导
        {
            type = 8,
            pos = {2,3},
            skillguide = 1,
            content = "",内容   缺省值为""
            sound = "",音效 缺省值为""
        },
        --自动战斗
        {
            type = 9,
        },
        --切换bgm
        {
            type = 10,
            file = "adsf.mp3",(音乐名称)
        }
        --播放音效
        {
            type = 11,
            file = "adsf.mp3",(音乐名称)
        }
        --受伤动作
        {
            type = 12,
            pos = {1,2,3,4}
        }
        --抖动
        {
            type = 13,
            time = 1 次数,
            directionX = 1 幅度X
            directionY = 1 幅度Y
            directionZ = 1 幅度Z
            duration = 1 间隔时间
        }
        --单个特效
        {
            type = 14,
            file = "",(动画文件)
            animation = "",(动画名称)
            pos = 1,(位置)
            scale = 1,
            zorder = 1,
            loop = 1,
            affect = {
                {
                    toPos = 1,(受击位置)
                    hp = -200,(生命变化)
                    rage = 23,(怒气变化)
                    effect = 2,(攻击方式，暴击，普通，格挡，闪避)
                }
            }
            dead = {
                1,2,4(死亡位置)
            },
        }
        --镜头动作
        camera = {
            type = 16,
            time = 1,运动时长
            scale = 1,放大比例
            posId = 1,目标位置
            offsetX = 1,x偏移量
            offsetY = 1,y偏移量
        }
        --人物动作
        {
            type = 18,
            animation = ""
            pos = 1,(位置)
        }
        --移动地图
        {
            type = 19,
            newMap = "",
            time = 1,
        }
]]

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
    eCamera     = 16, -- 设置相机
    eMessageNew = 17, -- 新外部对话
    eHeroAction = 18, -- 人物动作
    eMoveMap    = 19, -- 移动地图
    eMoveHero   = 21, -- 移动人物
    eJumpLocal  = 22, -- 原地跳动
    eHeti       = 23, -- 合体技切屏
}

local ChatPicType = {
    eType1 = 1,--圆
    eType2 = 2,--尖
}

local HeroCreateType = {
    eFigure = 0, --通过大图直接创建
    eNPC = 1, --通过配置的npc
    eFormation = 2, --通过我方上阵人物
}

local BattleProcess_guide = class("BattleProcess_guide", function()
    return bd.func.bindEvent({})
end)

function BattleProcess_guide:ctor(params)
    self.battleLayer = params.battleLayer
    self.battleData  = params.battleData
    self.battleSpdy  = params.spdy

    self.skillingCnt_ = 0
    self.castQueue_ = {}
end

-- @战斗开始
function BattleProcess_guide:battleBegin()
    self:emit(bd.event.eBattleBegin)

    local data = self.battleData:getCurrentStageData()
    if data and data.data then
        self:stageBegin(data.data)
    else
        self:battleEnd()
    end
end


-- @战斗结束
function BattleProcess_guide:battleEnd(isSkip)
    -- 隐藏托管、跳过按钮
    --self.battleData:set_ctrl_trustee_viewable(false)
    --self.battleData:set_ctrl_skip_viewable(false)
    if self.battleData:get_battle_finishValue() == nil then
        self.battleData:set_battle_finishValue(true)
    end
    self:emit(bd.event.eBattleEnd, isSkip)
end


-- @关卡开始
function BattleProcess_guide:stageBegin()
    self:emit(bd.event.eStageBegin)
    self:emit(bd.event.eCreateHeroFinish)
    self:stepNext()
end


-- @关卡结束
function BattleProcess_guide:stageEnd()
    local stageIdx = self.battleData.battle_.stageIdx + 1
    self.battleData.battle_.stageIdx = stageIdx
    self.battleData.battle_.stepIdx = 1

    local data = self.battleData:getCurrentStageData()
    if data then
        self:emit(bd.event.eStageEnd)
        self:stageBegin(data)
    else
        self:battleEnd()
    end
end

function BattleProcess_guide:skipBattle( ... )
    self.flag_skipBattle_ = true
    if self.normalBattleData then
        self.normalBattleData:set_ctrl_skip_viewable(false)
        self.normalBattleProcess.skiping_ = true
        self.normalBattleProcess.recording_.skip = true
        self.normalBattleProcess:battleEnd(true)
    end
    self:battleEnd(true)
end

-- @下一步
function BattleProcess_guide:stepNext()
    local data = self.battleData:getStepData()
    if data and not self.flag_skipBattle_ then
        self:stepBegin(data)
    else
        self:stageEnd()
    end
end

-- @步骤开始
function BattleProcess_guide:stepBegin(data)
    --删除循环动画
    if self.frameEffect then
        for i , v in pairs(self.frameEffect) do
            v:removeFromParent()
        end
        self.frameEffect = nil
    end
    -- 遍历这一步的action
    bd.func.each(data, function(cont, v)
        -- 查找action.type
        bd.func.foreachSeries(ActionType_guide, function(nt_, t, k)
            if t == v.type then
                local key = "exec_" .. k
                if self[key] then
                    -- 调用action
                    self[key](self, v, function()
                        cont(v.key)
                    end)
                else
                    bd.log.error(TR("未实现动作: %s", k))
                end

                nt_(true)
            else
                nt_(nil)
            end
        end, function(found)
            if not found then
                bd.log.error(TR("未找到动作类型: %s", v.type))
            end
        end)
    end, function()
        self:stepEnd()
    end)
end

-- @步骤结束
function BattleProcess_guide:stepEnd()
    self:stepNext()
end

--[[-------------------------------------------------------------------------
                            action executor
---------------------------------------------------------------------------]]

-- 切换地图 eMap
function BattleProcess_guide:exec_eMap(data, callback)
    -- 战斗地图/场景
    require("ComBattle.UICtrl.BDMap").new({
        mapFile     = data.mapId,
        battleLayer = self.battleLayer,
        time        = data.time,
        callback    = callback,
        x           = data.x,
        y           = data.y,
    })
end

-- 移动 eMove
function BattleProcess_guide:exec_eMove(data, callback)
    data.time = data.time or 0.3

    if self.battleData:getHeroNode(data.to) then
        bd.log.warnning(TR("目标人物已经存在人物: %s"), data.to)
        return
    end

    local node = self.battleData:getHeroNode(data.from)
    if node then
        self.battleData:unbindHeroNode(node)
        node.idx = data.to
        self.battleData:bindHeroNode(node)

        node:runAction(cc.Sequence:create({
            mq.TrackAction:create(data.time, bd.interface.getStandPos(data.to)),
            cc.CallFunc:create(callback)
        }))
    else
        bd.log.error(TR("目标不存在: %s"), data.from)
    end
end

-- 人物出现 eIn
function BattleProcess_guide:exec_eIn(data, callback)
    -- 骨骼动画
    local v = self.battleData:getHeroData(data.heroId)

    bd.assert(v, TR("找不到主将数据: %s", data.heroId))

    if v.type == HeroCreateType.eFigure then
        --通过大图创建
        return self:createHeroByScript(v, data, callback)
    elseif v.type == HeroCreateType.eNPC then
        --通过配置创建
        return self:createHeroByConfig(v, data, callback)
    elseif v.type == HeroCreateType.eFormation then
        --通过阵容创建
        return self:createHeroByFormation(v, data, callback)
    end
end

function BattleProcess_guide:createHeroByScript(data, info, callback)
    local tmp = clone(data)
    tmp.scale = (tmp.scale or 1) * bd.ui_config.MinScale
    if not tmp.heroId or tmp.heroId == 0 then
        tmp.heroId = bd.interface.getHeroIdByFigure(tmp.figureName)
    end
    return self:createHero(tmp, info, callback)
end

function BattleProcess_guide:createHeroByConfig(data, info, callback)
    require("Config.BattleNodeGuidenpcRelation")
    local item = bd.interface.getGuideNPC(data.config)

    bd.assert(item, TR("找不到NPC数据: %s", data.config))
    return self:createHero({
        idx        = info.posId,
        name       = data.name ~= "" and data.name or item.name,
        heroId     = item.heroModelID,
        figureName = item.largePic,
        quality    = data.quality or item.quality,
        cHP        = item.HP,
        mHP        = item.HP,
        cRP        = item.RP,
        skillId    = data.skillId or item.RAID,
        normalId   = data.normalId or item.NAID,
        scale      = (data.scale or 1) * bd.ui_config.MinScale,
        step       = data.step or item.step,
        origin_    = {config = data.config},
    }, info, callback)
end


function BattleProcess_guide:createHeroByFormation(data, info , callback)
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
        bd.assert(item, TR("找不到NPC数据: %s", data.config))
        return self:createHero({
            idx        = info.posId,
            name       = data.name ~= "" and data.name or item.name,
            heroId     = item.heroModelID,
            figureName = item.largePic,
            quality    = data.quality or item.quality,
            cHP        = item.HP,
            mHP        = item.HP,
            cRP        = item.RP,
            skillId    = data.skillId or item.RAID,
            normalId   = data.normalId or item.NAID,
            scale      = (data.scale or 1) * bd.ui_config.MinScale,
            step       = data.step or item.step,
            origin_    = {config = npcId},
        }, info, callback)
    else
        local formation = bd.interface.getFormationSlot(data.formationId)
        return self:createHero({
            idx        = info.posId,
            name       = data.name ~= "" and data.name,
            heroId     = formation.ModelId,
            figureName = bd.interface.getFigureNameByHeroId(formation.ModelId),
            quality    = data.quality ~= 0 and data.quality or bd.interface.getBaseQuality(formation.ModelId),
            cHP        = formation.Property.HP,
            mHP        = formation.Property.HP,
            cRP        = formation.Property.RP,
            skillId    = data.skillId or bd.interface.getRAIDByHeroId(formation.ModelId),
            normalId   = data.normalId or bd.interface.getNAIDByHeroId(formation.ModelId),
            scale      = (data.scale or 1) * bd.ui_config.MinScale,
            step       = data.step,
            origin_    = {slotId = data.formationId},
        }, info, callback)
    end
end

function BattleProcess_guide:createHero(data, info, callback)
    data.battleData = self.battleData
    data.mRP = bd.CONST.maxRP
    data.idx = info.posId

    local node = bd.interface.newFigureNode(data)
    local pos = bd.interface.getStandPos(data.idx)
    node:setPosition3D(pos)
    node:setLocalZOrder(bd.interface.getHeroZOrder(pos))
    node:action_idle() -- 待机
    self.battleData:bindHeroNode(node)
    self.battleData:get_battle_layer().heroPlant:addChild(node)

    -- 朝向
    node.figure:setRotationSkewY(bd.ui_config.posSkew[data.idx] and 180 or 0)

    -- 血条
    local bar = require("ComBattle.UICtrl.BDBar").new({
        curHP      = node.cHP,
        maxHP      = node.mHP,
        curRP      = node.cRP,
        maxRP      = node.mRP,
        battleData = self.battleData,
        isBoss     = false,
        name       = data.name or bd.interface.getHeroNodeName(node),
        quality    = node.quality ~= 0 and node.quality or bd.interface.getBaseQuality(data.HeroModelId),
    })
    node.bar = bar
    if data.IsBoss then
        self.battleData:get_battle_layer().parentLayer:addChild(bar)
        node.bar:setScale(bd.ui_config.MinScale)
        node.bar:setPosition(bd.ui_config.autoPos({midX = 0, top = 80}))

        if bd.ui_config.bossHPBarConfig then
            if bd.ui_config.bossHPBarConfig.barPos then
                node.bar:setPosition(bd.ui_config.bossHPBarConfig.barPos)
            end
        end
    else
        bd.func.performWithDelay(node.figure, function()
            local boundingBox = node.figure:getBoundingBox()
            node.boundingBoxSize = boundingBox
            bar:setPosition(0, boundingBox.height - 10)
        end, 0.01)
        node:addChild(bar)
    end

    if not data.IsBoss then
        local nameWidth = bar.nameNode_:getContentSize().width
        -- 尊，圣图片显示
        if node.step and node.step > 10 and node.step <= 15 then
            node.titleSprite = bd.interface.newSprite({image = "zd_22.png"})
        elseif node.step and node.step > 15 and node.step <= 20 then
            node.titleSprite = bd.interface.newSprite({image = "zd_21.png"})
        elseif node.step and node.step > 20 and node.step <= 25 then
            node.titleSprite = bd.interface.newSprite({image = "zd_23.png"})
        end

        if node.titleSprite then
            bd.func.performWithDelay(node.figure, function()
                local boundingBox = node.figure:getBoundingBox()
                node.titleSprite:setScale(1.5)
                node.titleSprite:setAnchorPoint(cc.p(0, 0))
                node.titleSprite:setPosition(-60-nameWidth/2, boundingBox.height - 20)
            end,0.01)
            node:addChild(node.titleSprite)
        end
    end

    require("ComBattle.Common.BDFigureEntry").exec[info.entryType]({
        isOut    = false,
        node     = node,
        callback = callback,
    })
end

-- 人物消失 eOut
function BattleProcess_guide:exec_eOut(data, callback)
    local node = self.battleData:getHeroNode(data.posId)
    if node then
        require("ComBattle.Common.BDFigureEntry").exec[data.outType]({
            isOut = true,
            node = node,
            callback = function( ... )
                node:removeFromParent()
            end
        })
        --数据置空
        self.battleData:unbindHeroNode(data.posId)

        callback()
    else
        bd.log.warnning(TR("目标位置上没有人物: %s", data.posId))
        callback()
    end
end

-- 人物气泡对话 eChat
function BattleProcess_guide:exec_eChat(data, callback)
    data.sound_default = data.sound_default ~= "" and data.sound_default or nil
    data.sound_female = data.sound_female ~= "" and data.sound_female or nil
    data.content_default = data.content_default ~= "" and data.content_default or nil
    data.content_female = data.content_female ~= "" and data.content_female or nil

    --获取试用的音频文件
    local soundfile = Utility.getBattleMusicFile(data)

    --获取音频文件长度
    local delaytime = data.time or 3
    if soundfile then
        if not string.find(soundfile , ".mp3") then
            soundfile = soundfile .. ".mp3"
        end
        local audioFile = require("Guide.Talk.AudioLength")
        delaytime = audioFile[soundfile] or delaytime
    end

    --获取对话内容
    local chatContent = nil
    if data.content_default and data.content_female then
        chatContent = (bd.interface.getPlayerSex() and data.content_default or data.content_female)
    else
        chatContent = data.content_default or data.content_female
    end

    --获取底图
    local bgPic = bd.ui_config.chatBG
    -- if data.chatType == ChatPicType.eType1 then
    --     bgPic = "xct_02.png"
    -- elseif data.chatType == ChatPicType.eType2 then
    --     bgPic = "xct_02.png"
    -- end

    --对话根节点
    local node = self.battleData:getHeroNode(data.posId)
    local chat = cc.Node:create()
    chat:runAction(cc.Sequence:create({
        cc.DelayTime:create(delaytime),
        cc.CallFunc:create(function( ... )
            chat:getParent():setLocalZOrder(chat:getParent():getLocalZOrder() - 10)
            chat:removeFromParent()
            if node then
                node:setLocalZOrder(node:getLocalZOrder() - 1000)
            end
            callback()
        end)
    }))
    if node then
        node:setLocalZOrder(node:getLocalZOrder() + 1000)
        node:addChild(chat)
    elseif (data.posId == 16) or (data.posId == 17) then --左边
        self.battleLayer.ctrlLayer_:addChild(chat)
        chat:setScale(bd.ui_config.MinScale)
    else
        bd.log.warnning(TR("没有找到目标人物: %s", data.posId))
    end
    if soundfile then
        chat.soundId = bd.adapter.audio.playSound(soundfile)
    end

    bd.func.registerSwallowTouch({
        node = chat ,
        allowTouch = false,
        beganEvent = function(touch, event)
            if chat.soundId then
                bd.audio.stopSound(chat.soundId)
                chat.soundId = nil
            end
            chat:getParent():setLocalZOrder(chat:getParent():getLocalZOrder() - 10)
            chat:removeFromParent()
            chat = nil
            if node then
                node:setLocalZOrder(node:getLocalZOrder() - 1000)
            end
            callback()
        end
    })

    --背景
    local bg = cc.Sprite:create(bgPic)
    chat.bg = bg
    chat:addChild(bg)
    --文字
    local label = bd.interface.newLabel({
        text = chatContent,
        size = 19,
        x = 5,
        y = 0,
        font = _FONT_PANGWA,
        align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        color = cc.c3b(0,0,0),
        --needShadow = true,
        --outlineColor = cc.c3b(0, 0, 0),
        dimensions = cc.size(180,0),
        parent = chat
    })

    if data.posId == 16 then
        chat:setPosition(bd.ui_config.autoPos3D({midX = 110 - 320, midY = 100, z = 0}))
        chat.bg:setRotationSkewY(180)
    elseif data.posId == 17 then
        chat:setPosition(bd.ui_config.autoPos3D({midX = 200, midY = 100, z = 0}))
    else
        local find = false
        local right = {1 , 2 , 3 , 4 , 5 , 6}
        for i , v in pairs(right) do
            if data.posId == v then
                chat:setPosition(cc.p(150 , 300))
                chat.bg:setRotationSkewY(180)
                find = true
                break
            end
        end
        if not find then
            chat:setPosition(cc.p(-150 , 300))
        end
    end
end

-- 人物外部对话 eMessage
function BattleProcess_guide:exec_eMessage(data, callback)
    local skipFlag = true
    -- if BattleData.battle.params.forceSkip then
    --     skipFlag = false
    -- end
    local layer = require("Guide.TalkView.Layer").new{
        map      = tostring(data.messageId),
        closedCB = function(isSkip)
            self.battleLayer.guider_messageLayer = nil
            callback()
        end,
        canSkip = skipFlag,
    }
    if self.battleLayer.guider_messageLayer then
        self.battleLayer.guider_messageLayer:removeFromParent()
    end
    self.battleLayer.guider_messageLayer = layer
    self.battleLayer.parentLayer:addChild(layer, 126)
end

-- 人物外部对话 eMessage
function BattleProcess_guide:exec_eMessageNew(data, callback)
    local skipFlag = true
    -- if BattleData.battle.params.forceSkip then
    --     skipFlag = false
    -- end
    local layer = require("Guide.TalkView.TalkLayer").new{
        map      = tostring(data.messageId),
        closedCB = function(isSkip)
            self.battleLayer.guider_messageLayer = nil
            callback()
        end,
        canSkip = skipFlag,
    }
    if self.battleLayer.guider_messageLayer then
        self.battleLayer.guider_messageLayer:removeFromParent()
    end
    self.battleLayer.guider_messageLayer = layer
    self.battleLayer.parentLayer:addChild(layer, 126)
end

-- 延时 eDelay
function BattleProcess_guide:exec_eDelay(data, callback)
    self.battleLayer:runAction(cc.Sequence:create({
        cc.DelayTime:create(data.time),
        cc.CallFunc:create(function( ... )
            callback()
        end)
    }))
end

-- 配置战斗 eFight
function BattleProcess_guide:exec_eFight(data, callback)
    local skill = data.skillId
    if skill == 0 then
        skill = self.battleData:getHeroNode(data.fromPos).normalId
    elseif skill == 1 then
        skill = self.battleData:getHeroNode(data.fromPos).skillId
    elseif skill == 2 then
        skill = self.battleData:getHeroNode(data.fromPos).skillId
        require("config.HeroJointModel")
        local posNode = self.battleData:getHeroNode(data.fromPos)
        if HeroModel.items[posNode.heroId].jointID ~= 0 then
            local tmp = HeroJointModel.items[HeroModel.items[posNode.heroId].jointID]
            if tmp and tmp.mainHeroID == posNode.heroId then
                skill = tmp.jointSkillID
            end
        end
    end
    -- 将数据转换为attack-atom
    local atom = {
        type    = bd.adapter.config.atomType.eATTACK,
        skillId = skill,
        from    = {posId = data.fromPos},
        to      = {},
        onExec  = {
            {
                type  = bd.adapter.config.atomType.eVALUE,
                rp    = data.rage,
                toPos = data.fromPos,
            },
        },
    }

    -- 目标
    for _, v in ipairs(data.affect) do
        table.insert(atom.to, {
            posId = v.toPos,
            value = {
                hp     = v.hp,
                rp     = v.rage,
                effect = v.effect,
                posId  = v.toPos,
            }
        })
    end

    if data.dead then
        -- 死亡数据
        for _, v in ipairs(data.dead) do
            for _, to in ipairs(atom.to) do
                if to.posId == v then
                    to.value.dead = {
                        to = v,
                        from = atom.from.posId
                    }
                    break
                end
            end
        end
    end

    bd.atom.execute({
        battleLayer = self.battleLayer,
        battleData  = self.battleData,
        atoms       = {atom},
        callback    = callback
    })
end

-- @施法切屏
function BattleProcess_guide:skillFeature(pos, skillId , cb)
    if bd.patch and bd.patch.skillFeature then
        -- increase skilling-feature count
        self.skillingCnt_ = self.skillingCnt_ or 0
        self.skillingCnt_ = self.skillingCnt_ + 1
        -- 避免其他动作结束后请求新的数据
        self.runningActionCnt_ = self.runningActionCnt_ or 0
        self.runningActionCnt_ = self.runningActionCnt_ + 1

        -- 等待其他动作结束后再播放切屏动画
        local function _try()
            if self.runningActionCnt_ ~= self.skillingCnt_ then
                bd.func.performWithDelay(_try, 0.15)
            else

                self.battleLayer.parentLayer:addChild(bd.patch.skillFeature.new({
                    pos      = {{
                        pos = pos,
                        skillId = skillId,
                    }},
                    callback = function()
                        self.runningActionCnt_ = self.runningActionCnt_ - 1

                        -- decrease skilling-feature count
                        self.skillingCnt_ = self.skillingCnt_ - 1

                        return cb and cb()
                    end,
                    battleData = self.battleData,
                }), bd.ui_config.zOrderSkill)
            end
        end
        _try()
    else
        return cb and cb()
    end
end

-- @施法蓄力提示
function BattleProcess_guide:castingTips(params)
    local node = self.battleData:getHeroNode(params.posId)
    if node and (true ~= node.isDead_) then
        self.battleData:emit(bd.event.eCastTip, node.idx)

        bd.audio.playSound("effect_c_nujichufa.mp3")
        bd.interface.newEffect({
            effectName    = bd.ui_config.castingEffect[1],
            animation     = bd.ui_config.castingEffect[2],
            loop          = false,
            endRelease    = true,
            parent        = node,
            scale         = 1.1,
            position      = cc.p(0, 100),
            zorder        = 1,
            eventListener = function(p)
                if p.event.stringValue == "start" and params.callback then
                    params.callback()
                end
            end
        })

        return -- **
    end

    return params.callback()
end

-- 技能引导 eSkill
function BattleProcess_guide:exec_eSkill(data, callback)
    local chatLayer = nil
    if bd.patch and bd.patch.skillGuideText then
        chatLayer = bd.patch.skillGuideText(data.skillguide , self.battleLayer)
    end

    local count = #data.pos
    -- 技能释放
    self.castSkill = function(_, posIdList)
        count = count - table.nums(posIdList)
        if count <= 0 then
            if chatLayer then
                chatLayer:removeFromParent()
                chatLayer = nil
            end
            if self.arrowSprite then
                self.arrowSprite:removeFromParent()
                self.arrowSprite = nil
            end

            local tmp = #data.pos
            for i , v in pairs(data.pos) do
                self:castingTips({posId = v, callback = function( ... )
                    tmp = tmp - 1
                    if tmp == 0 then
                        self.skillingCnt_ = 0
                        self.runningActionCnt_ = 0
                        bd.func.performWithDelay(self.battleLayer , function( ... )
                            --self:skillFeature(data.pos , function( ... )
                                callback()
                            --end)
                        end , 0.1)
                    end
                end})
            end
        end
    end

    local isPrepare = #data.pos
    --技能准备完成
    self.prepareSkillFinish = function(node)
        if not Guide.dtdbx then
            Guide.dtdbx = 20
        else
            Guide.dtdbx = 30
        end
        if data.skillguide == 1 then
            Guide.manager:saveGuideStep(0, Guide.dtdbx, nil, true)
            -- 点击提示光圈
            local flashCircle = ui.newEffect({
                parent     = node,
                effectName = "effect_ui_dianjitishi",
                animation  = "tidian",
                loop       = true,    -- 是否循环显示
                endRelease = false,
                position = cc.p(0 , node.posY or 0),
            })

            local arrowSprite = bd.interface.newSprite({
                parent = node,
                img    = bd.ui_config.guideFigurePic,
                scale  = 0.7,
                anchor = cc.p(0.05, 1),
                pos = cc.p(0 , node.posY or 0),
            })
            arrowSprite:runAction(cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.ScaleTo:create(0.3, 0.8),
                    cc.ScaleTo:create(0.3, 0.7)
                )
            ))
        elseif data.skillguide == 2 then
            Guide.manager:saveGuideStep(0, Guide.dtdbx, nil, true)

            isPrepare = isPrepare - 1
            if isPrepare == 0 then
                local leftPos , rightPos = nil , nil
                for i , v in pairs(self.skillTouch.skillHeader_) do
                    leftPos = leftPos or v
                    leftPos = (leftPos.idx < v.idx) and leftPos or v
                    rightPos = rightPos or v
                    rightPos = (rightPos.idx > v.idx) and rightPos or v
                end
                lpos = cc.p(leftPos:getPosition())
                lpos.y = lpos.y + (leftPos.posY or 0)
                rpos = cc.p(rightPos:getPosition())
                rpos.y = rpos.y + (rightPos.posY or 0)
                local arrowSprite = bd.interface.newSprite({
                    parent = node:getParent(),
                    pos    = lpos,
                    img    = bd.ui_config.guideFigurePic,
                    scale  = 0.7 * Adapter.MinScale,
                    anchor = cc.p(0.05, 1),
                    zorder = bd.ui_config.zOrderTouch,
                })

                arrowSprite:runAction(cc.RepeatForever:create(
                    cc.Sequence:create({
                        cc.MoveTo:create(#data.pos*0.25 , rpos),
                        cc.DelayTime:create(0.1),
                        cc.MoveTo:create(#data.pos*0.25 , lpos),
                        -- cc.CallFunc:create(function( ... )
                        --     arrowSprite:setPosition(leftPos:getPosition())
                        -- end),
                        cc.DelayTime:create(0.1),
                    })
                ))
                arrowSprite:runAction(cc.RepeatForever:create(
                    cc.Sequence:create({
                        cc.ScaleTo:create(0.3, 0.8 * Adapter.MinScale),
                        cc.ScaleTo:create(0.3, 0.7 * Adapter.MinScale)
                    })
                ))
                self.arrowSprite = arrowSprite
            end
        end
    end

    self.skillTouch = require("ComBattle.UICtrl.BDTouch").new({
        battleData    = self.battleData,
        battleProcess = self,
    })
    for i , v in pairs(data.pos) do
        self.skillTouch:showSkillHeader(self.battleData:getHeroNode(v))
    end
end

-- 自动战斗 eAutoBattle
function BattleProcess_guide:exec_eAutoBattle(data, callback)
    local heroList = {}
    for k, v in pairs(self.battleData:getHeroNodeList()) do
        if v.origin_ then
            local property
            if v.origin_.config then
                property = BattleNodeGuidenpcRelation.items[v.origin_.config]
            elseif v.origin_.slotId then
                property = bd.interface.getFormationSlot(v.origin_.slotId).Property
            end
            heroList[k] = {
                LargePic = v.figureName,
                HP       = v.cHP,
                RP       = v.cRP,
                TotalHp  = v.mHP,

                HeroModelId = v.heroId,
                NAId        = v.normalId,
                RAId        = v.skillId,

                AP  = property.AP,
                DEF = property.DEF,

                BuffList = property.BuffList or "",
                Step = property.step,         --人物突破次数

                HIT  = property.HIT,
                DOD  = property.DOD,
                CRI  = property.CRI,
                TEN  = property.TEN,
                BLO  = property.BLO,
                BOG  = property.BOG,
                CRID = property.CRID,
                TEND = property.TEND,

                DAM = property.DAM,--伤害值
                APR = property.APR, --攻击加成%
                HPR = property.HPR, --生命加成%
                DEFR = property.DEFR, --防御加成%
                CP = property.CP, --治疗值
                BCP = property.BCP, --被治疗值
                CPR = property.CPR, --治疗率%
                BCPR = property.BCPR, --被治疗率%
                DAMADD = property.DAMADD, --伤害加成
                DAMCUT = property.DAMCUT, --伤害减免
                DAMADDR = property.DAMADDR, --伤害加成%
                DAMCUTR = property.DAMCUTR, --伤害减免%
                IsBoss = property.IsBoss,
                BodyTypeR = property.BodyTypeR,--人物放大比例
            }
        end
    end

    local data = {
        Heros = heroList,
        RandNum = math.random(1, 100000),
        IsPVP = false,
        TeamData = {
            { --友方数据
                Fsp = 3, --先攻值
                Fap = 1, --战力值
            },
            { --敌方数据
                Fsp = 2, --先攻值
                Fap = 1, --战力值
            },
        }
    }
    self.battleData.ignoreSkillRefresh = false
    -- 创建一个普通战斗数据容器
    local normalBattleData = require("ComBattle.Data.BattleData").new({
        data  = {
            data     = {FightObjs = {data}},
            callback = function()
            end,
        },
        spdy  = self.battleSpdy,
        layer = self.battleLayer,
    })
    self.normalBattleData = normalBattleData
    normalBattleData:set_ctrl_trustee_state(self.battleData:get_ctrl_trustee_state())

    -- 重写emit方法
    normalBattleData.emit = function(_, ...)
        self.battleData:emit(...)
    end

    normalBattleData.stage_.nodeList = self.battleData.stage_.nodeList

    -- 创建一个普通战斗控制器
    local normalBattleProcess = require("ComBattle.Process.BattleProcess").new({
        battleLayer = self.battleLayer,
        battleData  = normalBattleData,
        spdy        = self.battleSpdy,
    })
    self.normalBattleProcess = normalBattleProcess
    normalBattleProcess.emit = function(_, ...)
        local event = ({...})[1]

        if event == bd.event.eBattleEnd then
            self.normalBattleData = nil
            self.normalBattleProcess = nil
            self.battleData.ignoreSkillRefresh = true
            if normalBattleData:get_battle_finishValue() then
                -- 战斗结束
                return callback()
            else
                self.battleData:set_battle_finishValue(normalBattleData:get_battle_finishValue())
                self:battleEnd(({...})[2])
            end
        end

        return self:emit(...)
    end

    -- 避免重复创建人物
    normalBattleProcess.createHeroNode = function(_, cb)
        return cb and cb()
    end

    self.castSkill = function(_, ...)
        normalBattleProcess:castSkill(...)
    end

    -- 开始普通战斗
    normalBattleProcess:battleBegin()

    -- 刷新施法框
    for k in pairs(data.Heros) do
        normalBattleProcess:emit(bd.event.eHeroIn, k)
    end
end

-- 切换bgm eMusic
function BattleProcess_guide:exec_eMusic(data, callback)
    --切换背景音乐
    bd.audio.playMusic(data.file, true)
    callback()
end

-- 播放音效 eSound
function BattleProcess_guide:exec_eSound(data, callback)
    bd.audio.playSound(data.file)
    callback()
end

-- 受伤动作 eHurt
function BattleProcess_guide:exec_eHurt(data, callback)
    for i, v in pairs(data.pos) do
        local node = self.battleData:getHeroNode(v)
        if node then
            node:action_hurt()
        end
    end
    callback()
end

-- 抖动 eShake
function BattleProcess_guide:exec_eShake(data, callback)
    bd.interface.shakeTimes({node = self.battleLayer,
        time      = data.time,
        direction = cc.vec3(data.directionX , data.directionY , data.directionZ),
        duration  = data.duration,
    })

    callback()
end

-- 单个特效 eEffect
function BattleProcess_guide:exec_eEffect(data, callback)
    local posNode = self.battleData:getHeroNode(data.pos)
    local zorder = nil
    if posNode then
        zorder = posNode:getLocalZOrder()
        if data.zorder == 0 then
            zorder = zorder + 100
        elseif data.zorder == 1 then
            zorder = zorder - 100
        end
    else
        zorder = -bd.interface.getStandPos(data.pos).y
    end
    local effect = bd.interface.newEffect({
        effectName       = data.file,
        animation        = data.animation,
        loop             = data.loop == 1,
        parent           = self.battleLayer.parentLayer,
        scale            = (data.scale or 1) * bd.ui_config.MinScale,
        position3D       = bd.interface.getStandPos(data.pos),
        zorder           =  zorder,
        completeListener = function(trackIndex, loopCount)
            for i , v in pairs(data.affect) do
                local node = self.battleData:getHeroNode(v.toPos)
                if not node then
                    bd.log.warnning(TR("没有找到对应人物: %s", v.toPos))
                else
                    if v.hp then
                        self.battleData:fixHP({posid = v.toPos, value = v.hp, type = v.effect})

                        if v.hp < 0 then
                            node:action_hit()
                        end
                    end

                    if v.rp then
                        self.battleData:fixRP({posid = v.toPos, value = v.rp})
                    end
                end
            end
            if data.dead then
                -- 死亡数据
                for _, v in ipairs(data.dead) do
                    local node = self.battleNode:getHeroNode(v)
                    self.battleNode:unbindHeroNode(v)

                    if node then
                        node.isDead_ = true
                        node:action_death()
                    end
                end
            end
        end,
    })
    if data.loop == 1 then
        self.frameEffect = self.frameEffect or {}
        table.insert(self.frameEffect , effect)
    end
    callback()
end

--人物动作
function BattleProcess_guide:exec_eHeroAction(data , callback)
    local node = self.battleData:getHeroNode(data.posId)
    SkeletonAnimation.action({
        skeleton   = node.figure,
        action     = data.animation,
        loop       = false ,
        trackIndex = 5,
    })
    callback()
end

-- 镜头动作
function BattleProcess_guide:exec_eCamera(data, callback)
    local scene = self.battleLayer
    --缩放
    local action = cc.EaseSineOut:create(cc.ScaleTo:create(data.time , data.scale))
    action:setTag(43451)
    scene:stopActionByTag(43451)
    scene:runAction(action)

    data.offsetX = data.offsetX or 0
    data.offsetY = data.offsetY or 0

    local function moveRandom(pos)
        --随机移动
        local tmpRandAcion = {}
        local tmp = cc.p(0 , 0)
        for i = 1 , 10 do
            local randPos = cc.p(math.random(-10,10) , math.random(-10,10))
            table.insert(tmpRandAcion , cc.EaseSineInOut:create(cc.MoveBy:create(2 ,
                cc.p((randPos.x - tmp.x) * bd.ui_config.AutoScaleX , (randPos.y - tmp.y)* bd.ui_config.AutoScaleY))))
            tmp = randPos
        end

        scene:stopActionByTag(33111)
        local action3 = cc.RepeatForever:create(cc.Sequence:create(tmpRandAcion))
        action3:setTag(33111)
        scene:runAction(action3)
    end

    --位移
    if data.posId ~= 0 then
        local nodePos = cc.p(bd.interface.getStandPos(data.posId).x , bd.interface.getStandPos(data.posId).y)
        nodePos.y = nodePos.y + 150 * bd.ui_config.MinScale
        if data.offsetY then
            nodePos.y = nodePos.y + data.offsetY * bd.ui_config.AutoScaleY
        end
        if data.offsetX then
            nodePos.x = nodePos.x + data.offsetX * bd.ui_config.AutoScaleX
        end

        local scale = data.scale
        --根据屏幕缩放比例决定的最大移动范围
        local rectView = {x = 0 , y = 0 ,
            width = math.abs((1 - scale)*bd.ui_config.width/2),
            height = math.abs((1 - scale)*bd.ui_config.height/2)
        }

        --计算释放在范围内
        local function convertToWorld(pos)
            local offset = cc.p(bd.ui_config.cx , bd.ui_config.cy)
            return cc.p( (offset.x - pos.x)*scale , (offset.y - pos.y)*scale)
        end

        local containsPoint = function(target , point)
            if (point.x >= (target.x - target.width) and point.x <= (target.x + target.width)
                and point.y >= (target.y - target.height) and point.y <= (target.y + target.height)) then
                return true
            end
            return false
        end

        local pos = convertToWorld(nodePos)
        if not containsPoint(rectView , pos) then
            if pos.x > rectView.x + rectView.width then
                pos.x = rectView.x + rectView.width
            elseif pos.x < rectView.x - rectView.width then
                pos.x = rectView.x - rectView.width
            end
            if pos.y > rectView.y + rectView.height then
                pos.y = rectView.y + rectView.height
            elseif pos.y < rectView.y - rectView.height then
                pos.y = rectView.y - rectView.height
            end
        end
        local ox , oy = scene:getPosition()
        local action2 = cc.Sequence:create({
            cc.EaseSineOut:create(cc.MoveBy:create(data.time , cc.p(pos.x - ox , pos.y - oy))),
            cc.CallFunc:create(function( ... )
                moveRandom(pos)
            end),
        })
        action2:setTag(56441)
        scene:stopActionByTag(56441)
        scene:runAction(action2)
    elseif data.posId == 0 and data.offsetX and data.offsetY then
        local pos = cc.p(data.offsetX * bd.ui_config.AutoScaleX , data.offsetY * bd.ui_config.AutoScaleY)
        local ox , oy = scene:getPosition()
        local action2 = cc.Sequence:create({
            cc.EaseSineOut:create(cc.MoveBy:create(data.time , cc.p(pos.x - ox , pos.y - oy))),
            cc.CallFunc:create(function( ... )
                if pos.x == 0 and pos.y == 0 then
                    scene:stopActionByTag(33111)
                else
                    moveRandom(pos)
                end
            end),
        })
        action2:setTag(56441)
        scene:stopActionByTag(56441)
        scene:runAction(action2)
    end
    callback()
end

-- 切换方向
function BattleProcess_guide:exec_eDirection(data, callback)
    local node = self.battleData:getHeroNode(data.posId)
    -- 朝向
    node.figure:setRotationSkewY(node.figure:getRotationSkewY() + 180)
    callback()
end

-- 移动地图
function BattleProcess_guide:exec_eMoveMap(data, callback)
    -- -- 战斗地图/场景
    -- require("ComBattle.UICtrl.BDMap").new({
    --     mapFile     = data.newMap,
    --     battleLayer = self.battleLayer,
    --     time        = data.time,
    --     callback    = callback,
    --     scroll      = true,
    -- })

    -- for k, v in pairs(self.battleData:getHeroNodeList()) do
    --     v:runAction(cc.Sequence:create({
    --         cc.JumpTo:create(data.time or 1, v:getPosition3D(), 150 * Adapter.MinScale, (data.time or 1) / 0.3),
    --         cc.CallFunc:create(function( ... )
    --         end)
    --     }))
    -- end

    self.battleLayer.mapLayer.sprite:runAction(cc.Sequence:create({
        cc.MoveTo:create(data.time , cc.p(data.x * bd.ui_config.AutoScaleX , data.y * bd.ui_config.AutoScaleY)),
        cc.CallFunc:create(function( ... )
            callback()
        end)
    }))
end

function BattleProcess_guide:exec_eMoveHero(data, callback)
    local posNode = self.battleData:getHeroNode(data.posId)
    if posNode then
        posNode:runAction(cc.Sequence:create({
            cc.MoveBy:create(data.time , cc.vec3(data.offsetX * bd.ui_config.AutoScaleX , data.offsetY * bd.ui_config.AutoScaleY , 0)),
            cc.CallFunc:create(callback),
        }))
    end
end

function BattleProcess_guide:exec_eJumpLocal(data, callback)
    local posNode = self.battleData:getHeroNode(data.posId)
    if posNode then
        require("ComBattle.Common.BDFigureEntry").exec[bd.CONST.entryType.eJumpLocal]({
            isOut    = false,
            node     = posNode,
            callback = callback,
            time     = 0.2,
            moveDistance = 60 * bd.ui_config.MinScale * math.floor(data.time / 0.2) / 1.5,
        })
    end
end

function BattleProcess_guide:exec_eHeti(data, callback)
    local posNode = self.battleData:getHeroNode(data.pos)
    if data.skillId == 0 then
        data.skillId = posNode.normalId
    elseif data.skillId == 1 then
        data.skillId = posNode.skillId
    elseif data.skillId == 2 then
        data.skillId = posNode.skillId
        require("config.HeroJointModel")
        if HeroModel.items[posNode.heroId].jointID ~= 0 then
            local tmp = HeroJointModel.items[HeroModel.items[posNode.heroId].jointID]
            if tmp and tmp.mainHeroID == posNode.heroId then
                data.skillId = tmp.jointSkillID
            end
        end
    end
    self:skillFeature(data.pos , data.skillId, callback)
end

return BattleProcess_guide
