--[[
    文件名：BDFigureNode
    描述：人物显示对象
    创建人：luoyibo
    创建时间：2016.08.12
-- ]]

--[[
    nodeList中的对象为cc.Node
    node{
        idx     位置信息
        heroId  模型id
        figure  形象(SkeletonAnimation)
        figureName 形象名
        cHP     当前生命
        mHP     最大生命
        cRP     当前怒气
        mRP     最大怒气
        normalId普攻id
        skillId 技攻id
        reborn  转生等级
        figureScale 骨骼缩放
        scale   当前node的放大倍数
        name    人物名字（为空的取默认名字）
        step    突破次数
        shadow  人物阴影
        progressBar 人物血条
        eventFile 是否有动作配置文件
    }
--]]

--值越大优先级越高
local BattleActionTrack = {
    ACTION_IDLE = 0,        --待机
    ACTION_STUN = 0,        --晕眩
    ACTION_WIN = 0,         --胜利
    ACTION_HIT = 0,         --挨打
    ACTION_HURT = 0,
    ACTION_ATTACK = 10,      --普攻
    ACTION_SKILL = 50,       --技攻
    ACTION_DEATH = 100,       --死亡
}

local FigureNodeZorder = {
    FIGURE = 0,
    REBORN = 1,
}

local function mixAction(figure)
    --晕眩和待机混合动作
    SkeletonAnimation.mix({
        skeleton      = figure,
        fromAnimation = "daiji",
        toAnimation   = "yun",
        duration      = 1,
    })
    SkeletonAnimation.mix({
        skeleton      = figure,
        fromAnimation = "yun",
        toAnimation   = "daiji",
        duration      = 1,
    })
    --挨打到待机
    SkeletonAnimation.mix({
        skeleton      = figure,
        fromAnimation = "aida",
        toAnimation   = "daiji",
        duration      = 1,
    })
    --挨打到眩晕
    SkeletonAnimation.mix({
        skeleton      = figure,
        fromAnimation = "aida",
        toAnimation   = "yun",
        duration      = 1,
    })
    --普攻到待机
    SkeletonAnimation.mix({
        skeleton      = figure,
        fromAnimation = "pugong",
        toAnimation   = "daiji",
        duration      = 1,
    })
    --普攻到眩晕
    SkeletonAnimation.mix({
        skeleton      = figure,
        fromAnimation = "pugong",
        toAnimation   = "yun",
        duration      = 1,
    })
    --技攻到待机
    SkeletonAnimation.mix({
        skeleton      = figure,
        fromAnimation = "nuji",
        toAnimation   = "daiji",
        duration      = 1,
    })
    --技攻到眩晕
    SkeletonAnimation.mix({
        skeleton      = figure,
        fromAnimation = "nuji",
        toAnimation   = "yun",
        duration      = 1,
    })
end

require("common.SkeletonAnimation")

local BDFigureNode = class("BDFigureNode", function(params)
    local node = cc.Node:create()

    -- 阴影
    -- if params.shadow then
    if params.idx then
        local shadow = cc.Sprite:create(bd.ui_config.heroShadowPic)
        if shadow then
            if params.idx > 6 then
                shadow:setOpacity(51)
            else
                shadow:setOpacity(76)
            end

            shadow:setVisible(false)

            node:addChild(shadow)
            shadow:setLocalZOrder(-1)
            node.shadow = shadow
        end
    end
    -- end

    -- 转生等级
    if params.reborn then
        local enable = true

        if params.idx then
            if bd.interface.isFriendly(params.idx) then
                enable = params.battleData:get_ctrl_rebornNum_friendlyEnable()
            else
                enable = params.battleData:get_ctrl_rebornNum_enemyEnable()
            end
        end
        if enable then
            local sp = bd.interface.createRebornSprite(params.reborn)
            if sp then
                sp:setPosition(52, 180)
                node:addChild(sp, FigureNodeZorder.REBORN)
            end
        end
    end

    -- 判断骨骼动画是否存，不存在时尝试使用默认对象
    local figureName = params.figureName
    if not cc.FileUtils:getInstance():isFileExist(figureName .. ".skel") then
        if bd.ui_config.defaultFigureName then
            bd.log.warnning(TR("找不到骨骼(%s)，使用默认资源", figureName))
            figureName = bd.ui_config.defaultFigureName
        else
            bd.log.error(TR("找不到骨骼: %s", figureName))
        end
    end

    if params.scale then
        node:setScale(params.scale)
    end

    for i , v in pairs(params) do
        node[i] = v
    end

    --没有配置
    node.eventFile = false

    -- 计算施法所需怒气
    node.skillRP = bd.interface.getSkillRage(params.skillId)
    if bd.project == "project_shediao" then
        node.skillRP = math.min(node.skillRP, bd.interface.getSkillRage(params.comboSkillId))
    end

    -- 跟随节点
    node.followNodes_ = {}
    node:scheduleUpdate(function()
        for _, v in ipairs(node.followNodes_) do
            v[1]:setPosition3D(node:getPosition3D())
            v[1]:setLocalZOrder(node:getLocalZOrder() + v[2])
        end
    end)

    -- @buff状态
    node.state_ = {
        stun  = 0,   -- 眩晕buff数量
        banRA = 0,   -- 沉默buff数量
        banNA = 0,  -- 麻痹buff数量
        freen = 0,  -- 冰冻buff数量
    }

    -- @其他状态
    node.state_else_ = {
        skilling  = 0,   -- 施法数量
        attacking = 0,   -- 普攻数量
        hitting   = 0,   -- 挨打数量
    }

    -- @保存循环播放的buff特效(避免重复创建)
    node.state_effect_ = {}

    local done_flag_ = true
    -- 创建骨骼后调用
    local function after_create(figure)
        if done_flag_ == nil then
            return
        end
        done_flag = nil

        SkeletonAnimation.update({
            skeleton = figure,
            speed    = 1,
            skin     = "skin_01",
        })
        --开启动作混合
        mixAction(figure)

        node.figure = figure

        -- 加载外部事件
        if figure:eventLoaded() == false then
            figure:clearEvent()
            if cc.FileUtils:getInstance():isFileExist(figureName .. ".event") then
                local eventPath = cc.FileUtils:getInstance():fullPathForFilename(figureName .. ".event")
                figure:loadEvent(eventPath)
            else
                local defaultEventPath = cc.FileUtils:getInstance():fullPathForFilename("hero_default.event")
                figure:loadEvent(defaultEventPath)
            end
        end

        if params.async then
            bd.func.performWithDelay(node, function()
                params.async(node)
            end, 0)
        end
    end

    local figure = SkeletonAnimation.create({
        file     = figureName,
        position = cc.p(0 , 0),
        parent   = node,
        zorder   = FigureNodeZorder.FIGURE,
        async    = params.async and after_create,
        scale    = 0.24 * (params.figureScale or 1) * (bd.patch.nodeScale or 1),
    })

    if figure then
        after_create(figure)
    end

    return node
end)


-- @更新为战斗速度
function BDFigureNode:update_speed()
    SkeletonAnimation.update({
        skeleton = self.figure,
        speed    = self.battleData:get_battle_speed(),
    })
end


-- @更新为普通速度
function BDFigureNode:normal_speed()
    if self.state_else_.attacking + self.state_else_.skilling == 0 then
        SkeletonAnimation.update({
            skeleton = self.figure,
            speed    = bd.CONST.speed.normal,
        })
    end
end


--待机动作
function BDFigureNode:action_idle()
    if self.idx and self.battleData then
        local battleData = self.battleData

        -- 判断眩晕Buff
        local buffList = battleData:getHeroBuff(self.idx)
        if buffList then
            local enum = bd.adapter.config.buffType
            if buffList[enum.eBanAct] and next(buffList[enum.eBanAct]) then -- 眩晕
                return self:action_stun()
            end
        end

        -- 判断战斗结果
        local result = battleData:get_battle_finishValue()
        if result ~= nil then
            if result == bd.interface.isFriendly(self.idx) then
                return self:action_win()
            elseif (not result) == bd.interface.isEnemy(self.idx) then
                return self:action_win()
            end
        end
    end

    SkeletonAnimation.action({
        skeleton   = self.figure,
        action     = "daiji",
        loop       = true ,
        trackIndex = BattleActionTrack.ACTION_IDLE,
    })
end

--晕眩动作
function BDFigureNode:action_stun()
    SkeletonAnimation.action({
        skeleton   = self.figure,
        action     = "yun" ,
        loop       = true ,
        trackIndex = BattleActionTrack.ACTION_STUN,
    })
end


--胜利动作
function BDFigureNode:action_win()
    SkeletonAnimation.action({
        skeleton   = self.figure,
        action     = "win" ,
        loop       = true ,
        trackIndex = BattleActionTrack.ACTION_WIN,
    })
end

--挨打动作
function BDFigureNode:action_hit()
    SkeletonAnimation.action({
        skeleton         = self.figure,
        action           = "aida" ,
        loop             = false ,
        trackIndex       = BattleActionTrack.ACTION_HIT,
        completeListener = function( ... )
            self:action_idle()
        end
    })
end

--死亡动作
function BDFigureNode:action_death(params)
    bd.interface.newEffect({
        effectName       = bd.ui_config.heroDeadEffect[1],
        animation        = bd.ui_config.heroDeadEffect[2],
        loop             = false,
        parent           = self,
        scale            = 1,
        position         = cc.p(0 ,0),
        zorder           = 1,
        endRelease       = true,
        completeListener = function(trackIndex, loopCount)
            self:setVisible(true ~= self.isDead_)
            return params.callback and params.callback()
        end,
        eventListener = function(p)
            if p.event.stringValue == "daji" then
                self.figure:runAction(cc.Spawn:create({
                    cc.ScaleTo:create(0.5, 0.1),
                    cc.FadeTo:create(0, 0.1)
                }))

                return params.hitcallback and params.hitcallback()
            end
        end,
    })
end

--普攻动作
--[[
    params:
        event       动作处理回调
        complete
    return:
        NULL
]]
function BDFigureNode:action_attack(params)
    self.state_else_.attacking = self.state_else_.attacking + 1
    self:update_speed()

    if not self.attackTrack then
        self.attackTrack = BattleActionTrack.ACTION_ATTACK
    else
        self.attackTrack = self.attackTrack + 1
        if self.attackTrack >= BattleActionTrack.ACTION_SKILL then
            self.attackTrack = BattleActionTrack.ACTION_ATTACK
        end
    end

    SkeletonAnimation.action({
        skeleton         = self.figure,
        action           = "pugong" ,
        loop             = false ,
        trackIndex       = self.attackTrack,
        delay            = 0,
        eventListener    = params.event,
        completeListener = function(...)
            self.state_else_.attacking = self.state_else_.attacking - 1
            self:normal_speed()

            self:action_idle()
            if params.complete then
                params.complete(...)
            end
        end
    })
end

--技攻动作
--[[
    params:
        event       动作处理回调
        complete
    return:
        NULL
]]
function BDFigureNode:action_skill(params)
    self:update_speed()

    if not self.skillTrack then
        self.skillTrack = BattleActionTrack.ACTION_SKILL
    else
        self.skillTrack = self.skillTrack + 1
        if self.skillTrack >= BattleActionTrack.ACTION_DEATH then
            self.skillTrack = BattleActionTrack.ACTION_SKILL
        end
    end
    SkeletonAnimation.action({
        skeleton         = self.figure,
        action           = "nuji" ,
        loop             = false ,
        trackIndex       = self.skillTrack,
        delay            = 0,
        eventListener    = params.event,
        completeListener = function(...)
            self.state_else_.skilling = self.state_else_.skilling - 1
            self:normal_speed()

            self:action_idle()
            if params.complete then
                params.complete(...)
            end
        end,
    })
end


-- @受伤动作
function BDFigureNode:action_hurt(params)
    SkeletonAnimation.action({
        skeleton         = self.figure,
        action           = "shoushang",
        loop             = true,
        delay            = 0,
        trackIndex       = BattleActionTrack.ACTION_HURT,
        eventListener    = params.event,
        completeListener = params.complete,
    })
end


-- 移动到指定位置
function BDFigureNode:move_to(pos, cb)
    local function move()
        self.moveCB_ = cb
        local action = cc.Sequence:create(
            mq.TrackAction:create(self.battleData:actTime(0.2), pos),
            cc.CallFunc:create(function()
                self.moveCB_ = nil
                return cb and cb()
            end))
        action:setTag(bd.CONST.actionTag.eHeroMove)

        self:runAction(action)
    end

    self:stopActionByTag(bd.CONST.actionTag.eHeroMove)
    if self.moveCB_ then
        self.moveCB_()
        bd.func.performWithDelay(self, move, 0)
    else
        move()
    end
end


-- @添加跟随结点
function BDFigureNode:addFollowNode(node, zorder)
    table.insert(self.followNodes_, {node, zorder or 0})
    self.battleData:get_battle_layer().parentLayer:addChild(node)

    node:setPosition3D(self:getPosition3D())
    node:setLocalZOrder(self:getLocalZOrder() + (zorder or 0))

    node:onNodeEvent("exit", function()
        if not tolua.isnull(self) then
            self:removeFollowNode(node)
        end
    end)
end


function BDFigureNode:removeFollowNode(node)
    for k, v in pairs(self.followNodes_) do
        if v[1] == node then
            table.remove(self.followNodes_, k)
            break
        end
    end
end


-- @置会(麻痹时使用)
function BDFigureNode:setGray(isGray)
    if self.isGray_ == nil then
        self.isGray_ = false
    end
    if self.isGray_ == isGray then
        return
    end

    self.isGray_ = isGray

    if isGray then
        local oldShader = self.figure:getGLProgram()
        self.oldShader_ = oldShader

        local cache = cc.GLProgramCache:getInstance()
        local name = "MQ_ShaderPositionTextureGray"
        local shader = cache:getGLProgram(name)

        if not shader then
            shader = cc.GLProgram:createWithByteArrays(
                -- vertex shader
                [[
                attribute vec4 a_position;
                attribute vec2 a_texCoord;
                attribute vec4 a_color;

                varying vec4 v_fragmentColor;
                varying vec2 v_texCoord;

                void main()
                {
                    gl_Position = CC_PMatrix * a_position;
                    v_fragmentColor = a_color;
                    v_texCoord = a_texCoord;
                }
                ]],
                -- fragment shader
                [[
                varying vec2 v_texCoord;
                varying vec4 v_fragmentColor;

                void main()
                {
                    vec4 v_orColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);
                    float gray = dot(v_orColor.rgb, vec3(0.299, 0.587, 0.114));
                    gl_FragColor = vec4(gray, gray, gray, v_orColor.a);
                }
                ]]
            )
            cache:addGLProgram(shader, name)
        end

        -- 这里设置 shader
        self.figure:setGLProgram(shader)
        -- 这里调用了才起效果
        self.figure:getGLProgram()
    else
        if self.oldShader_ then
            -- 这里设置 shader
            self.figure:setGLProgram(self.oldShader_)
            -- 这里调用了才起效果
            self.figure:getGLProgram()
        end
    end
end


-- @添加buff特效
function BDFigureNode:addStateEffect(effect_name)
    local item = self.state_effect_[effect_name]
    if not item then
        local effect = bd.interface.newEffect({
            parent     = self,
            effectName = effect_name,
            loop       = true,
            position   = cc.p(0, 0),
            scale      = (bd.ui_config.buffEffectScale[display.effect] or 1) * (bd.patch.nodeScale or 1),
        })
        if effect_name == "effect_buff_xuanyun" then
            local boundingBox = self:getBoundingBox() or self.figure:getBoundingBox()
            effect:setPosition(-30, boundingBox.height - 10)
        end

        if effect_name == "effect_buff_siwangshanghai" then
            bd.adapter.audio.playSound("effect_buff_siwangshanghai.mp3")
        end

        -- 不死和免疫要围绕人物旋转
        if effect_name == "effect_buff_mianyishanghai" -- 免疫
            or effect_name == "effect_buff_qiangzhibusi" -- 不死
          then
            local baseNode = cc.Node:create()
            self:addChild(baseNode)

            -- 将特效添加到baseNode上
            effect:retain()
            effect:removeFromParent()
            baseNode:addChild(effect)
            effect:release()

            effect = baseNode

            baseNode:enableNodeEvents()
            local timeout = 0
            local duration = 4 -- 绕一圈所用时间
            local circle_time = duration / self.battleData:get_battle_speed()
            local radius = 85  -- 半径
            local rotationY = 0
            baseNode:onUpdate(function(delta)
                local digress = 360 * delta / circle_time
                rotationY = (rotationY + digress) % 360
                baseNode:setRotation3D(cc.vec3(0, rotationY, 0))
                -- 绕到了人物身后
                if rotationY > 90 and rotationY < 270 then
                    baseNode:setLocalZOrder(-1)
                else
                    baseNode:setLocalZOrder(1)
                end

                -- 绕到了左边
                local x = radius * math.sin(math.pi / 180 * rotationY)
                baseNode:setPositionX(x)

                -- 远处缩小
                local tmp = rotationY
                if rotationY > 180 then
                    tmp = 360 - tmp
                end
                baseNode:setScale(1 - (0.17 * (tmp / 180)))
                baseNode:setPositionY(70 * (tmp / 180))
            end)

            -- 监控速度
            local function update_speed(speed)
                circle_time = duration / speed
            end
            function baseNode.onExitTransitionStart(_)
                self.battleData:off("battle_speed", update_speed)
            end
            self.battleData:on("battle_speed", update_speed)
        end

        item = {
            node = effect,
            cnt = 0,
        }
        self.state_effect_[effect_name] = item
    end

    item.cnt = item.cnt + 1
end

-- @减少buff特效
function BDFigureNode:delStateEffect(effect_name)
    local item = self.state_effect_[effect_name]
    if item then
        item.cnt = item.cnt - 1
        if item.cnt == 0 then
            item.node:removeFromParent()
            self.state_effect_[effect_name] = nil
        end
    end
end

function BDFigureNode:getBoundingBox()
    return self.boundingBoxSize
end

return BDFigureNode
