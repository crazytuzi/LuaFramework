--[[
    filename: ComBattle.UI.BDCtrlWatcher
    description: 将某些消息与UI绑定
    date: 2016.09.01

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local BDCtrlWatcher = class("BDCtrlWatcher", {})


function BDCtrlWatcher:ctor(params)
    self.battleData    = params.battleData
    self.battleProcess = params.battleProcess

    -- 伤害/治疗显示
    self.labelView = require("ComBattle.UICtrl.BDLabel").new({
        battleData    = self.battleData,
        battleProcess = self.battleProcess,
    })

    -- 技能释放
    self.skillTouch = require("ComBattle.UICtrl.BDTouch").new({
        battleData    = self.battleData,
        battleProcess = self.battleProcess,
    })

    -- 施法时蒙版
    self.skillMask = cc.LayerColor:create(cc.c4b(0, 0, 0, bd.project == "project_shediao" and 250 or 190))
    self.skillMask:setContentSize(bd.ui_config.width * 2, bd.ui_config.height * 2)
    self.skillMask:setIgnoreAnchorPointForPosition(false)
    self.skillMask:setPosition(bd.ui_config.cx, bd.ui_config.cy)
    self.battleData:get_battle_layer().parentLayer:addChild(self.skillMask
        , bd.ui_config.zOrderSkillMask)
    self.skillMask:setVisible(false)


    local battleData = self.battleData
    -- 战斗速度修改
    -- battleData:on("battle_speed", function(speed)
    --     for _, node in pairs(battleData:getHeroNodeList()) do
    --         SkeletonAnimation.update({
    --             skeleton = node.figure,
    --             speed    = speed,
    --         })
    --     end
    -- end)

    -- 显示/隐藏名称
    battleData:on("battle_viewName", function(show)
        for _, node in pairs(battleData:getHeroNodeList()) do
            if node.bar then
                node.bar:showName(show)
            end
        end
    end)
end


-- @开始监听消息
function BDCtrlWatcher:on()
    self.castingCnt = 0

    -- 监听伤害和治疗
    self:watchDamage()
    -- 监听怒气
    self:watchRage()
    -- 监听死亡信息
    self:watchDead()
    -- 监听buff信息
    self:watchBuff()

    -- 监控施法
    self:watchSkill()
    self:watchBeHit()

    self.battleProcess:on(bd.event.eBattleEnd, function()
        self:off()
    end)

    self.battleProcess:on(bd.event.eHeroIn, function(posId)
        self.skillTouch:refreshTouchEnable(posId)
    end)
end


-- @停止监听消息
function BDCtrlWatcher:off()
    -- battleData 上的消息
    local listeners = self.battleData.listeners_
    if not listeners then
        return
    end
    listeners["battle_speed"]     = nil
    listeners["battle_viewName"]  = nil
    listeners[bd.event.eHP]       = nil
    listeners[bd.event.eRP]       = nil
    listeners[bd.event.eBuffAdd]  = nil
    listeners[bd.event.eBuffDel]  = nil
    listeners[bd.event.eHeroDead] = nil
    listeners[bd.event.eCasting]  = nil
    listeners[bd.event.eCasted]   = nil
    listeners[bd.event.eCastTip]  = nil

    -- battleProcess 上的消息
    local listeners = self.battleProcess.listeners_
    if not listeners then
        return
    end

    listeners[bd.event.eHeroIn]    = nil
    listeners[bd.event.eBattleEnd] = nil
end


-- @监视伤害和治疗量
function BDCtrlWatcher:watchDamage()
    -- @显示伤害和治疗数值
    self.battleData:on(bd.event.eHP, function(posId, delta, value, type, orghp)
        local disp_value = orghp or delta
        if disp_value > 0 then
            self.labelView:showCureValue(posId, disp_value, type)
        else
            self.labelView:showDamageValue(posId, disp_value, type)
        end

        local node = self.battleData:getHeroNode(posId)
        if node and node.bar then
            if node.deadStatus and delta > 0 then
                return
            end
            node.bar:setHP(value)
        end
    end)
end


-- @监视怒气值
function BDCtrlWatcher:watchRage()
    self.battleData:on(bd.event.eRP, function(posId, delta, value, isKill)
        self.labelView:showRageValue(posId, delta, value, isKill)
        if not self.battleData.ignoreSkillRefresh then
            self.skillTouch:refreshTouchEnable(posId)
        end

        local node = self.battleData:getHeroNode(posId)
        if node and node.bar then
            node.bar:setRP(value)
        end
    end)
    if not self.battleData.ignoreSkillRefresh then
        local list = self.battleData:getHeroNodeList()
        for idx, v in pairs(list) do
            local node = self.battleData:getHeroNode(idx)
            if node then
                self.skillTouch:refreshTouchEnable(idx)
            end
        end
    end
end


-- @监听死亡信息
function BDCtrlWatcher:watchDead()
    self.battleData:on(bd.event.eHeroDead, function(posId)
        -- 清空血量和怒气
        local node = self.battleData:getHeroNode(posId)
        if node and node.bar then
            node.bar:setHP(0)
            node.bar:setRP(0)
        end

        self.skillTouch:refreshTouchEnable(posId)
    end)
end


-- @监听Buff变化
function BDCtrlWatcher:watchBuff()
    local function refreshTouchEnable(posId, buffId, isAdd)
        local node = self.battleData:getHeroNode(posId)
        local needRefreshIdle = false

        local buff = self.battleData:getBuffItem(buffId)
        if buff then
            if buff.type == bd.adapter.config.buffType.eBanAct then -- 眩晕
                if isAdd then
                    node.state_.stun = node.state_.stun + 1
                    if node.state_.stun == 1 then
                        -- 刷新待机状态
                        needRefreshIdle = true
                    end
                else
                    node.state_.stun = node.state_.stun - 1
                    if node.state_.stun == 0 then
                        -- 刷新待机状态
                        needRefreshIdle = true
                    end
                end
                self.skillTouch:refreshTouchEnable(posId)

            elseif buff.type == bd.adapter.config.buffType.eFreeze then -- 冰冻
                if isAdd then
                    node.state_.freen = node.state_.freen + 1
                    if node.state_.stun == 1 then
                        -- 刷新待机状态
                        needRefreshIdle = true
                    end
                else
                    node.state_.freen = node.state_.freen - 1
                    if node.state_.freen == 0 then
                        -- 刷新待机状态
                        needRefreshIdle = true
                    end
                end
                self.skillTouch:refreshTouchEnable(posId)

            -- 麻痹
            elseif buff.type == bd.adapter.config.buffType.eBanNA then
                if isAdd then
                    node.state_.banNA = node.state_.banNA + 1
                    if node.state_.banNA == 1 then
                        node:setGray(true)
                    end
                else
                    node.state_.banNA = node.state_.banNA - 1
                    if node.state_.banNA == 0 then
                        node:setGray(false)
                    end
                end

            elseif buff.type == bd.adapter.config.buffType.eBanRA then
                if isAdd then
                    node.state_.banRA = node.state_.banRA + 1
                else
                    node.state_.banRA = node.state_.banRA - 1
                end

                self.skillTouch:refreshTouchEnable(posId)
            end
        end

        if needRefreshIdle then
            node:action_idle()
        end
    end
    self.battleData:on(bd.event.eBuffAdd, function(posId, buffId)
        refreshTouchEnable(posId, buffId, true)
    end)

    self.battleData:on(bd.event.eBuffDel, function(posId, buffId)
        refreshTouchEnable(posId, buffId, false)
    end)
end


-- @监控施法
function BDCtrlWatcher:watchSkill()
    -- 开始施法时，应该刷新头像框，将头像框隐藏
    self.battleData:on(bd.event.eCastTip, function(skill_pos)
        local node = self.battleData:getHeroNode(skill_pos)
        node.state_else_.skilling = node.state_else_.skilling + 1
        self.skillTouch:refreshTouchEnable(skill_pos)
    end)

    self.battleData:on(bd.event.eCasting, function(skill_pos, to)
        if not bd.interface.isFriendly(skill_pos) and bd.project ~= "project_shediao" then
            return
        end

        self:addAttackCnt(skill_pos, to)
    end)

    self.battleData:on(bd.event.eCasted, function(skill_pos, to)
        if not bd.interface.isFriendly(skill_pos) and bd.project ~= "project_shediao" then
            return
        end

        self:decAttackCnt(skill_pos, to)
    end)
end

-- @监控挨打
function BDCtrlWatcher:watchBeHit()
    -- 攻击者和受击者高亮
    self.battleData:on(bd.event.eBeHit, function(skill_pos, to)
        self:addAttackCnt(skill_pos, to)
    end)

    self.battleData:on(bd.event.eBeHitted, function(skill_pos, to)
        self:decAttackCnt(skill_pos, to)
    end)
end

-- @施法时，攻击者和受击者高亮
-- 实现方式:
--      1.将所有主将放在蒙版下层
--      2.将攻击者和受击者放在蒙版上层
-- 已知问题:
--      1.人物移动会刷新自身zOrder,施法时上一次动作的执行者很可能在移动中，导致该人物也高亮
function BDCtrlWatcher:addAttackCnt(skill_pos, to)
    self.castingCnt = self.castingCnt + 1
    if self.castingCnt == 1 then
        if not tolua.isnull(bd.mapBuilding) then
            bd.mapBuilding:setVisible(false)
        end

        -- 显示蒙版
        self.skillMask:setVisible(true)
        self.skillMask:setOpacity(bd.project == "project_shediao" and 250 or 190)

        -- 将所有主将放到蒙版下床
        local heroList = self.battleData:getHeroNodeList()
        for k, v in pairs(heroList) do
            if v.state_else_.skilling + v.state_else_.attacking + v.state_else_.hitting == 0 then
                v:setLocalZOrder(bd.ui_config.zOrderSkillMask - 1)
            end
        end
    end

    -- 将施法者放到蒙版之上
    local node = self.battleData:getHeroNode(skill_pos)
    if node then
        if bd.project == "project_shediao" then
            local cnt = to and #to or 1
            if cnt < 1 or cnt > 6 then
                cnt = 6
            end
            local p = bd.patch.attackMoveOffset[cnt][1]
            node:setLocalZOrder(-p.y)
        else
            node:setLocalZOrder(-node:getPositionY())
        end
    end

    -- 将挨打者放到蒙版之上
    for _, v in ipairs(to) do
        local node = self.battleData:getHeroNode(v.posId)
        if node then
            node:setLocalZOrder(-node:getPositionY())
        end
    end
end

-- @施法时，攻击者和受击者高亮
-- 实现方式:
--      1.将所有主将放在蒙版下层
--      2.将攻击者和受击者放在蒙版上层
-- 已知问题:
--      1.人物移动会刷新自身zOrder,施法时上一次动作的执行者很可能在移动中，导致该人物也高亮
function BDCtrlWatcher:decAttackCnt(skill_pos, to)
    self.castingCnt = self.castingCnt - 1
    if self.castingCnt == 0 then
        bd.func.performWithDelay(function()
            if not tolua.isnull(bd.mapBuilding) then
                bd.mapBuilding:setVisible(true)
            end

            self.skillMask:runAction(cc.Sequence:create({
                cc.FadeTo:create(0.2, 0),
                cc.CallFunc:create(function( )
                    if self.castingCnt == 0 then
                        self.skillMask:setVisible(false)
                    end
                end)
            }))
        end, 0.2)

        -- 将所有主将放到蒙版之上并返回
        local heroList = self.battleData:getHeroNodeList()
        for k, v in pairs(heroList) do
            v:setLocalZOrder(-v:getPositionY())
        end
    end
end

return BDCtrlWatcher
