--[[
    文件名：BDCtrlLayer
    描述：战斗场景UI界面
    创建人：严伟才
    创建时间：2015.04.28
-- ]]

local BDCtrlLayer = class("BDCtrlLayer", function()
    local layer = cc.Layer:create()
    layer:enableNodeEvents()
    return layer
end)

function BDCtrlLayer:ctor(params)
    local battleData = params.battleData
    local battleProcess = params.battleProcess

    self.battleData = battleData
    self.battleProcess = battleProcess

    self:setLocalZOrder(bd.ui_config.zOrderCtrl)

    battleProcess:on(bd.event.eCreateHeroFinish, function()
        -- 回合数
        self:createRoundLabel(battleData, battleProcess)

        -- 托管按钮
        self:createTruteeBtn(battleData, battleProcess)

        -- 跳过按钮
        self:createSkipBtn(battleData, battleProcess)

        -- 显示挑战数据
        self:createChallengeLabel(battleData, battleProcess)

        --显示宝藏奖励
        self:createCoinReward(battleData, battleProcess)
    end)
end


-- @创建托管按钮
function BDCtrlLayer:createTruteeBtn(battleData, battleProcess)
    --是否显示托管按钮
    if battleData:get_ctrl_trustee_viewable() then
        -- 根据状态获取按钮图片
        local function getBtnPicByState()
            local state = battleData:get_ctrl_trustee_state()
            return bd.ui_config.trusteeBtnPic[state]
        end

        -- 变更托管状态
        local function changeTrusteeState()
            -- 获取当前状态
            local state = battleData:get_ctrl_trustee_state()

            if bd.project == "project_huanzhu" then
                if state == bd.trusteeState.eSpeedUpAndTrustee then
                    battleData:set_ctrl_trustee_state(bd.trusteeState.eSpeedUp)
                else
                    local open = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBattleTuoGuan, true)
                    if open then
                        battleData:set_ctrl_trustee_state(bd.trusteeState.eSpeedUpAndTrustee)
                    end
                end
                return
            end

            -- 修改状态（BattleData会同时修改速度）
            if state == bd.trusteeState.eSpeedUpAndTrustee then
                battleData:set_ctrl_trustee_state(bd.trusteeState.eNormal)
            elseif state == bd.trusteeState.eSpeedUp then
                battleData:set_ctrl_trustee_state(bd.trusteeState.eSpeedUpAndTrustee)
            elseif state == bd.trusteeState.eNormal then
                battleData:set_ctrl_trustee_state(bd.trusteeState.eSpeedUp)
            end
        end

        -- 托管按钮
        local btnTrustee = bd.interface.newButton({
            normalImage = getBtnPicByState(),
            position    = bd.ui_config.trusteeBtnPos,
            scale       = bd.ui_config.MinScale,
            clickAction = function()
                local func = battleData:get_ctrl_trustee_executable()
                if not func or (func and func()) then
                    changeTrusteeState()
                end
            end,
        })
        self:addChild(btnTrustee)

        -- 监听消息
        battleData:on("ctrl_trustee_state", function()
            if not tolua.isnull(btnTrustee) then
                --更新按钮图片
                local tex = getBtnPicByState()
                btnTrustee:loadTextureNormal(tex)
                btnTrustee:loadTexturePressed(tex)
            end
        end)

        battleData:on("ctrl_trustee_display", function(show)
            if not tolua.isnull(btnTrustee) then
                btnTrustee:setVisible(show)
            end
        end)
    end
end


-- 跳过按钮
function BDCtrlLayer:createSkipBtn(battleData, battleProcess)
    local posSkipBtn = bd.ui_config.skipBtnPos

    -- 是否显示跳过按钮
    if battleData:get_ctrl_skip_viewable() then
        local check_can_skip = battleData:get_ctrl_skip_executable()

        -- 跳过按钮
        local btnSkip = bd.interface.newButton({
            normalImage = bd.ui_config.skipBtnPic,
            position    = posSkipBtn,
            scale       = bd.ui_config.MinScale,
            clickAction = function(pSender)
                if (not check_can_skip) then
                    if not battleData:get_battle_params().data.guider then
                        if battleData:get_ctrl_skip_enable() then
                            battleData:set_ctrl_skip_viewable(false)
                            battleData:set_ctrl_skip_state(true)
                        end
                    else
                        battleProcess:skipBattle()
                    end
                else
                    local stageIdx = battleData:get_battle_stageIdx()
                    if check_can_skip(battleData:get_stage_roundIdx() or 1, stageIdx) then
                        if not battleData:get_battle_params().data.guider then
                            battleData:set_ctrl_skip_viewable(false)
                            battleData:set_ctrl_skip_state(true)
                        else
                            battleProcess:skipBattle()
                        end
                    end
                end
            end,
        })
        self:addChild(btnSkip)

        -- 刷新颜色
        local function refreshColor(able)
            if able then
                btnSkip:setColor(cc.c3b(0xFF, 0xFF, 0xFF))
            else
                btnSkip:setColor(cc.c3b(0x80, 0x80, 0x80))
            end
        end
        battleData:on("ctrl_skip_enable", refreshColor)

        if bd.project == "project_huanzhu" then
            bd.refreshSkipBtn = function(...)
                if not tolua.isnull(btnSkip) then
                    refreshColor(...)
                end
            end
        end


        -- 可否点击（不可点击时按钮置暗）
        local clickable = battleData:get_ctrl_skip_clickable()
        if clickable then
            local function able(roundIdx)
                local stageIdx = battleData:get_battle_stageIdx()
                battleData:set_ctrl_skip_enable(clickable(roundIdx or 1, stageIdx))
            end
            battleData:on("stage_roundIdx", able)
            -- 初始化
            able(battleData:get_stage_roundIdx())
        end

        battleData:on("ctrl_skip_viewable", function(show)
            if not tolua.isnull(btnSkip) then
                btnSkip:setVisible(show)
            end
        end)
    end
end


-- 顶部回合数
function BDCtrlLayer:createRoundLabel(battleData, battleProcess)
    if battleData:get_battle_params().data.guider then
        return
    end
    -- 回合
    local roundSprite = bd.interface.newSprite({
        img   = bd.project == "project_shediao" and "zd_04.png" or "zd_40.png",
        scale = bd.ui_config.MinScale,
        pos   = bd.ui_config.roundLabelPos or cc.p(cc.p(bd.ui_config.cx - 50*bd.ui_config.MinScale
                , bd.ui_config.height - 38*bd.ui_config.MinScale)),
    })
    self:addChild(roundSprite)
    local roundPosY = bd.ui_config.roundLabelPos.y
    -- 回合数
    local roundLabel
    if bd.project ~= "project_shediao" then
        roundLabel = bd.interface.newLabel({
            text         = string.format("%d/%d", 1, bd.CONST.maxRound),
            size         = 37,
            x            = bd.ui_config.cx + 102*bd.ui_config.MinScale,
            y            = (bd.ui_config.height - 40*bd.ui_config.MinScale),
            outlineColor = cc.c3b(0x41, 0x27, 0x0F),
            outlineSize  = 2,
        })
    else
        roundLabel = cc.Label:createWithCharMap("zd_17.png", 22, 33, 47)
        roundLabel:setString(1)
        roundLabel:setAnchorPoint(cc.p(1, 0.5))
        roundLabel:setPosition(bd.ui_config.cx + 37 * bd.ui_config.MinScale, roundPosY or bd.ui_config.height - 28*bd.ui_config.MinScale)
        roundLabel:setScale(bd.ui_config.MinScale)

        -- 分隔斜杠
        splitLabel = cc.Label:createWithCharMap("zd_17.png", 22, 33, 48)
        splitLabel:setString("0")
        splitLabel:setPosition(bd.ui_config.cx + 45 * bd.ui_config.MinScale, roundPosY or bd.ui_config.height - 28*bd.ui_config.MinScale)
        splitLabel:setScale(bd.ui_config.MinScale)
        self:addChild(splitLabel)

        -- 最大回合数
        maxLabel = cc.Label:createWithCharMap("zd_17.png", 22, 33, 47)
        maxLabel:setString("30")
        maxLabel:setPosition(bd.ui_config.cx + 75 * bd.ui_config.MinScale, roundPosY or bd.ui_config.height - 28*bd.ui_config.MinScale)
        maxLabel:setScale(bd.ui_config.MinScale)
        self:addChild(maxLabel)
    end
    self:addChild(roundLabel)

    roundLabel:setAnchorPoint(cc.p(1, 0.5))
    battleData:on("stage_roundIdx", function(val)
        if bd.project == "project_shediao" then
            roundLabel:setString(val or 1)
        else
            roundLabel:setString(string.format("%d/%d", val or 1, bd.CONST.maxRound))
        end
    end)
end


-- @刷新回合显示
function BDCtrlLayer:refreshRoundLabel( ... )
    self.roundLabel:setString(string.format("%d/%d", BattleData.stage.round or 1 , bd.getBattleRoundMax()))
end


function BDCtrlLayer:createChallengeLabel(battleData, battleProcess)
    local challenge = battleData:get_battle_challenge()
    if challenge then
        local pos = clone(bd.ui_config.chanllengLabelPos)
        for i, c in ipairs(challenge) do
            local node = cc.Node:create()
            self:addChild(node)
            node:setPosition(pos)

            if c.Type == bd.CONST.challengeType.eHPRemain then
                pos.y = pos.y - 65 * bd.ui_config.MinScale
            else
                pos.y = pos.y - 35 * bd.ui_config.MinScale
            end

            local watchEvent = {}
            self:refreshChallenge(node, c, battleData, battleProcess)
            if c.Type == bd.CONST.challengeType.eKillAll
                or c.Type == bd.CONST.challengeType.eAliveRemain then
                battleProcess:on(bd.event.eHeroIn, function()
                    self:refreshChallenge(node, c, battleData, battleProcess)
                end)
                table.insert(watchEvent, bd.event.eHeroDead)
                table.insert(watchEvent, bd.event.eHeroReborn)
            elseif c.Type == bd.CONST.challengeType.eWinInRound then
                -- x回合内获胜
                table.insert(watchEvent, "stage_roundIdx")
            elseif c.Type == bd.CONST.challengeType.eHPRemain then
                -- 我方总生命高于x%
                table.insert(watchEvent, bd.event.eHP)
                table.insert(watchEvent, bd.event.eHeroIn)
            end

            for _, e in ipairs(watchEvent) do
                battleData:on(e, function()
                    self:refreshChallenge(node, c, battleData, battleProcess)
                end)
            end
        end
    end
end


function BDCtrlLayer:refreshChallenge(node, c, battleData, battleProcess)
    local function createMainString(string)
        if not node.challengeLabel1_ then
            node.challengeLabel1_ = bd.interface.newLabel({
                text         = string,
                size         = 23,
                x            = 0,
                y            = 0,
                font         = _FONT_PANGWA,
                align        = cc.TEXT_ALIGNMENT_RIGHT,
                valign       = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
                color        = cc.c3b(255, 255, 100),
                needShadow   = true,
                outlineSize  = 2,
                outlineColor = Enums.Color.eBlack,
            })
            node.challengeLabel1_:setScale(bd.ui_config.MinScale)
            node.challengeLabel1_:setAnchorPoint(cc.p(1, 0.5))
            node:addChild(node.challengeLabel1_)
        else
            node.challengeLabel1_:setString(string)
        end
    end

    local function createSecondaryString(string)
        if not node.challengeLabel2_ then
            node.challengeLabel2_ = bd.interface.newLabel({
                text         = string,
                size         = 23,
                x            = 0,
                y            = -28 * bd.ui_config.MinScale,
                font         = _FONT_PANGWA,
                align        = cc.TEXT_ALIGNMENT_RIGHT,
                valign       = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
                color        = cc.c3b(255, 255, 100),
                needShadow   = true,
                outlineSize  = 2,
                outlineColor = Enums.Color.eBlack,
            })
            node.challengeLabel2_:setScale(bd.ui_config.MinScale)
            node.challengeLabel2_:setAnchorPoint(cc.p(1, 0.5))
            node:addChild(node.challengeLabel2_)
        else
            node.challengeLabel2_:setString(string)
        end
    end

    if c.Type == bd.CONST.challengeType.eKillAll then
        -- 敌方全灭
        createMainString(TR("敌方全灭"))
        -- createSecondaryString(TR("敌方剩余人数：%s" , battleData:getChallengeValue(c)))
    elseif c.Type == bd.CONST.challengeType.eWinInRound then
        -- x回合内获胜
        createMainString(TR("%d回合内获胜" , c.Value))
        local value = battleData:getChallengeValue(c)
        -- createSecondaryString(TR("当前回合：%s" , value))
        if c.Value >= value  then
            -- 达标
            node.challengeLabel1_:setTextColor(cc.c3b(255, 255, 100))
        else
            node.challengeLabel1_:setTextColor(cc.c3b(255, 0, 0))
        end
    elseif c.Type == bd.CONST.challengeType.eHPRemain then
        -- 我方总生命高于x%
        createMainString(TR("我方总生命高于%s%%" , c.Value))
        local value = battleData:getChallengeValue(c)
        createSecondaryString(TR("当前总生命：%s%%" , value))
        if c.Value <= value then
            -- 达标
            node.challengeLabel2_:setTextColor(cc.c3b(255, 255, 100))
        else
            node.challengeLabel2_:setTextColor(cc.c3b(255, 0, 0))
        end
    elseif c.Type == bd.CONST.challengeType.eAliveRemain then
        -- 我方存活不少于x人
        if c.Value == 6 then
            createMainString(TR("我方存活%s人" , c.Value))
        else
            createMainString(TR("我方存活不少于%s人", c.Value))
        end
        local value = battleData:getChallengeValue(c)
        -- createSecondaryString(TR("当前存活人数：%s" , value))
        if value >= c.Value then
            --达标
            node.challengeLabel1_:setTextColor(cc.c3b(255, 255, 100))
        else
            node.challengeLabel1_:setTextColor(cc.c3b(255, 0, 0))
        end
    end
end


-- @创建宝藏挑战奖励显示
function BDCtrlLayer:createCoinReward(battleData, battleProcess)
    if not XxbzRewardBaseRelation then
        return
    end
    local treasureInfo = battleData:get_battle_treasure()
    if treasureInfo and #treasureInfo ~= 0 then
        self:refreshXXBZValue(battleData, battleProcess)
        battleData:on(bd.event.eHP, function()
            self:refreshXXBZValue(battleData, battleProcess)
        end)
    end
end


-- @刷新宝藏挑战奖励数值
function BDCtrlLayer:refreshXXBZValue(battleData, battleProcess)
    local total, reward = battleData:getCoinReward()

    -- 伤害数值
    if not self.hurtValueLabel_ then
        local pos = bd.ui_config.chanllengLabelPos

        self.hurtValueLabel_ = bd.interface.newLabel({
            text         = TR("伤害：%d", total),
            size         = 23,
            x            = pos.x,
            y            = pos.y,
            font         = _FONT_PANGWA,
            align        = cc.TEXT_ALIGNMENT_RIGHT,
            valign       = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
            color        = cc.c3b(255, 255, 100),
            needShadow   = true,
            outlineSize  = 2,
            outlineColor = Enums.Color.eBlack,
        })
        self.hurtValueLabel_:setScale(bd.ui_config.MinScale)
        self.hurtValueLabel_:setAnchorPoint(cc.p(1, 0.5))
        self:addChild(self.hurtValueLabel_)
    else
        self.hurtValueLabel_:setString(TR("伤害：%d", total))
    end

    for i , v in pairs(battleData:get_battle_treasure()) do
        -- 奖励类型名称
        local dtext = bd.interface.getXXBZType(v.RewardTypeId , v.RewardModelId)
        local text = string.format("%s：%s", dtext, reward[i])
        if not self["rewardValue"..i] then
            local pos = bd.ui_config.chanllengLabelPos
            self["rewardValue"..i] = bd.interface.newLabel({
                text         = text,
                size         = 23,
                x            = pos.x,
                y            = pos.y - 28*bd.ui_config.MinScale*i,
                font         = _FONT_PANGWA,
                align        = cc.TEXT_ALIGNMENT_RIGHT,
                valign       = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
                color        = cc.c3b(255, 255, 100),
                needShadow   = true,
                outlineSize  = 2,
                outlineColor = Enums.Color.eBlack,
            })
            self["rewardValue"..i]:setAnchorPoint(cc.p(1, 0.5))
            self["rewardValue"..i]:setScale(bd.ui_config.MinScale)
            self:addChild(self["rewardValue"..i])
        else
            self["rewardValue"..i]:setString(text)
        end
    end
end


function BDCtrlLayer:teamBattleView(data, callback)
    if bd.project == "project_shediao" then
        local stageIdx = self.battleData:get_battle_stageIdx()
        local image = "zd_18.png"
        if stageIdx == 2 then
            image = "zd_19.png"
        elseif stageIdx == 3 then
            image = "zd_20.png"
        end


        local sp = bd.interface.newSprite({
            img   = image,
            scale = bd.ui_config.MinScale,
            pos   = cc.p(bd.ui_config.width + 300 *bd.ui_config.MinScale, bd.ui_config.cy),
            parent = self,
        })
        if not sp then
            return callback()
        end

        sp:runAction(cc.Sequence:create({
            cc.EaseExponentialOut:create(cc.MoveTo:create(0.5 , cc.p(bd.ui_config.cx, bd.ui_config.cy))),
            cc.DelayTime:create(1.5),
            cc.EaseExponentialIn:create(cc.MoveTo:create(0.5 , cc.p(-300 *bd.ui_config.MinScale, bd.ui_config.cy))),
            cc.CallFunc:create(function( ... )
                sp:removeFromParent()
                return callback()
            end)
        }))

        return
    end
    --创建玩家的名字等级战斗力
    local function getPowerViewStr(power)
        local returnStr = tostring(power)

        if power >= 100000 then
            returnStr = math.floor(power / 10000)..TR("万")
        end

        return returnStr
    end

    local node = cc.Node:create()
    self:addChild(node)

    --背景
    local sprite_bg = cc.Sprite:create(bd.ui_config.teamViewBg)
    sprite_bg:setScale(1.1 * bd.ui_config.MinScale)
    node:addChild(sprite_bg)

    --人物形象
    local figure = Figure.newHero({
        figureName = bd.interface.getFigureNameByHeroId(data.HeadImageId),
        parent     = node,
        scale      = 0.24 * bd.ui_config.MinScale,
        position   = cc.p(-160 * bd.ui_config.MinScale ,-110 * bd.ui_config.MinScale),
    })

    --当前战斗场次
    local picfile = nil
    local stageIdx = self.battleData:get_battle_stageIdx()
    if stageIdx == 1 then
        picfile = bd.ui_config.teamBattle1
    elseif stageIdx == 2 then
        picfile = bd.ui_config.teamBattle2
    elseif stageIdx == 3 then
        picfile = bd.ui_config.teamBattle3
    end
    local sprite_title = cc.Sprite:create(picfile)
    sprite_title:setPosition(bd.ui_config.autoPos({midX = -220, midY = -1136/2 + 120 }))
    sprite_title:setScale(bd.ui_config.MinScale)
    node:addChild(sprite_title)

    --人物名称、等级
    local label_name = bd.interface.newLabel({
        text       = string.format("Lv.%d %s", data.Lv , data.Name),
        size       = 25 * bd.ui_config.MinScale,
        x          = 120 * bd.ui_config.MinScale,
        y          = 40 * bd.ui_config.MinScale,
        font       = _FONT_PANGWA,
        align      = cc.TEXT_ALIGNMENT_CENTER,
        valign     = cc.VERTICAL_TEXT_ALIGNMENT_LEFT,
        needShadow = true,
    })
    node:addChild(label_name)

    --家族
    local label_party = bd.interface.newLabel({
        text       = string.format("%s: %s", bd.interface.getModuleName("Guild"), data.Guild),
        size       = 25 * bd.ui_config.MinScale,
        x          = 120 * bd.ui_config.MinScale,
        y          = 0 * bd.ui_config.MinScale,
        font       = _FONT_PANGWA,
        align      = cc.TEXT_ALIGNMENT_CENTER,
        valign     = cc.VERTICAL_TEXT_ALIGNMENT_LEFT,
        needShadow = true,
    })
    node:addChild(label_party)

    --战斗力
    local label_power = bd.interface.newLabel({
        text       = string.format(TR("战斗力: %s") , getPowerViewStr(data.FAP)),
        size       = 25 * bd.ui_config.MinScale,
        x          = 120 * bd.ui_config.MinScale,
        y          = -40 * bd.ui_config.MinScale,
        font       = _FONT_PANGWA,
        align      = cc.TEXT_ALIGNMENT_CENTER,
        valign     = cc.VERTICAL_TEXT_ALIGNMENT_LEFT,
        needShadow = true,
    })
    node:addChild(label_power)

    ------------------------------------------
    local posLeft = cc.p(bd.ui_config.cx - 1000 * bd.ui_config.AutoScaleX , bd.ui_config.cy)
    local posRight = cc.p(bd.ui_config.cx + 1000 * bd.ui_config.AutoScaleX , bd.ui_config.cy)
    local posCenter = cc.p(bd.ui_config.cx, bd.ui_config.cy)

    node:setPosition(posRight)
    node:runAction(cc.Sequence:create({
        cc.EaseExponentialOut:create(cc.MoveTo:create(0.5 , posCenter)),
        cc.DelayTime:create(1.5),
        cc.EaseExponentialIn:create(cc.MoveTo:create(0.5 , posLeft)),
        cc.CallFunc:create(function( ... )
            node:removeFromParent()
            if (callback) then
                callback()
            end
        end)
    }))
end

return BDCtrlLayer
