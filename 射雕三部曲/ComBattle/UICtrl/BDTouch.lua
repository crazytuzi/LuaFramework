--[[
    filename: ComBattle.UI.BDTouch
    description: 用于显示技能释放按钮
    date: 2016.09.01

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]
local BDTouch = class("BDTouch", {})

function BDTouch:ctor(params)
    self.battleData = params.battleData
    self.battleProcess = params.battleProcess

    self.battleProcess:on(bd.event.eStageEnd, function()
        for k, v in pairs(self.skillHeader_) do
            v:removeFromParent()
        end
        self.skillHeader_ = {}
    end)

    self.castingCnt_ = 0
    self.battleData:on(bd.event.eCasting, function(posId)
        if bd.interface.isFriendly(posId) then
            self.castingCnt_ = self.castingCnt_ + 1
        end
    end)
    self.battleData:on(bd.event.eCasted, function(posId)
        if bd.interface.isFriendly(posId) then
            self.castingCnt_ = self.castingCnt_ - 1
        end
    end)

    self.skillHeader_ = {}
    self:createTouchLayer()
end

-- @创建触摸层
function BDTouch:createTouchLayer()
    local layer = self.battleData:get_battle_layer()
    local parentLayer = layer.parentLayer

    -- 创建新的触摸层
    local touchLayer = cc.Layer:create()
    touchLayer:setLocalZOrder(bd.ui_config.zOrderTouch)
    touchLayer:setTouchEnabled(true)
    parentLayer:addChild(touchLayer)
    parentLayer.touchLayer = touchLayer
    self.touchLayer = touchLayer

    local touchedList = {} -- 已点击，等待施法

    local function addtouchedList(posId)
        if bd.project == "project_shediao" then
            if self.castingCnt_ > 0
                or next(self.battleProcess.castQueue_)
                or self.battleProcess.skillingCnt_ > 0 then
                return
            end
        end
        if not touchedList[posId] then
            bd.audio.playSound("nujishifang.mp3")
            touchedList[posId] = true
            return true
        end
    end

    local function testTouchNode(pos)
        -- 珍兽行动时，不能释放技能
        if self.battleData.stage_.isZhenshouAttacking == true then
            return
        end

        for i, v in pairs(self.skillHeader_) do
            if v:isVisible() then
                local rect = v.avatar:getBoundingBox()
                if cc.rectContainsPoint(rect , v:convertToNodeSpace(pos)) then
                    if addtouchedList(v.posId) then
                        v.avatar:setColor(cc.c3b(255, 0, 0))

                        if bd.project == "project_shediao" then
                            ui.newEffect({
                                effectName = bd.ui_config.skillEffect[1],
                                animation  = "chufa",
                                parent     = v,
                                pos        = cc.p(0, 5),
                                scale      = 0.7,
                                endRelease = false,
                            })
                        end
                    end
                end
            end
        end
    end

    local beginPos
    local blankRect = cc.rect(0, display.cy - bd.ui_config.MinScale*568 + 170*bd.ui_config.MinScale
                    , bd.ui_config.width, bd.ui_config.height-200*bd.ui_config.MinScale)
    --注册触摸事件
    bd.func.registerSwallowTouch({
        node       = touchLayer ,
        allowTouch = false,
        beganEvent = function(touch, event)
            local pos = touch:getLocation()
            testTouchNode(pos)
            pos = touchLayer:convertToNodeSpace(pos)

            beginPos = pos

            return true
        end,
        movedEvent = function(touch, event)
            testTouchNode(touch:getLocation())

            if bd.project == "project_xueying" then
                return
            end

            local pos = touch:getLocation()
            if cc.rectContainsPoint(blankRect, pos) then
                -- 取消施法
                for k in pairs(touchedList) do
                    local v = self.skillHeader_[k]
                    if not tolua.isnull(v) then
                        v.avatar:setColor(cc.c3b(255, 255, 255))
                    end
                end
                touchedList = {}
            end
        end,
        endedEvent = function(touch, event)
            local pos = touch:getLocation()
            testTouchNode(touch:getLocation())

            if cc.rectContainsPoint(blankRect, pos)
                and cc.rectContainsPoint(blankRect, beginPos)
                and (cc.pGetDistance(pos, beginPos) / bd.ui_config.MinScale) < 30
              then
                -- 修改名称显示
                local viewName = self.battleData:get_battle_viewName()
                self.battleData:set_battle_viewName(not viewName)
            end

            -- 施法
            if next(touchedList) then
                for k, _ in pairs(touchedList) do
                    local node = self.battleData:getHeroNode(k)
                    if node then
                        self:hideSkillHeader(node)
                    end
                end

                if bd.project == "project_shediao" and self.battleProcess.queueCast then
                    self.battleProcess:queueCast(touchedList)
                else
                    self.battleProcess:castSkill(touchedList)
                end
                touchedList = {}
            end
        end,
    })
end

-- @刷新施法框
function BDTouch:refreshTouchEnable(posId)
    local node = self.battleData:getHeroNode(posId)
    if (not node) or (node.skillEnable_ == false) then
        return
    end

    local canSkill = self:isCanSkill(node)
    if node.canSkill ~= canSkill then
        if canSkill then
            self:showSkillHeader(node)
        else
            self:hideSkillHeader(node)
        end
    end
end


-- @判断是否可以施法
function BDTouch:isCanSkill(node)
    repeat
        if node.skillEnable_ == false then
            break
        elseif node.skillEnable_ == nil then
            if bd.interface.isEnemy(node.idx) then
                node.skillEnable_ = false
                break
            end

            if bd.project == "project_shediao" then
                -- 射雕只能释放组合技

                -- 取消限制
                -- if not ld.checkComboSkill(node.comboSkillId) then
                --     node.skillEnable_ = false
                --     break
                -- end
            end

            -- 是否可以主动施法
            if not self.battleData:get_ctrl_skill_viewable() then
                node.skillEnable_ = false
                break
            end
        end

        -- 已经死亡
        if node.isDead_ then
            break
        end

        -- 怒气不足
        if node.cRP < node.skillRP then
            break
        end

        -- 施法中
        if node.state_else_.skilling > 0 then
            break
        end

        -- 有禁技buff
        local buffList = self.battleData:getHeroBuff(node.idx)
        if buffList then
            local enum = bd.adapter.config.buffType
            if buffList[enum.eBanRA] and next(buffList[enum.eBanRA]) then -- 沉默
                break
            end
            if buffList[enum.eBanAct] and next(buffList[enum.eBanAct]) then -- 眩晕
                break
            end
            if buffList[enum.eFreeze] and next(buffList[enum.eFreeze]) then -- 冰冻
                break
            end
        end

        return true
    until true

    return false
end


-- @显示施法框
function BDTouch:showSkillHeader(node)
    node.canSkill = true

    local posId = node.idx
    local header = self.skillHeader_[posId]

    if tolua.isnull(header) then
        header       = self:createSkillHeader(node)
        header.idx   = posId
        header.posId = posId
        self.skillHeader_[posId] = header

        if not bd.ui_config.skillOnHero then
            self.touchLayer:addChild(header, bd.ui_config.zOrderTouch)
        end
    end

    if bd.ui_config.skillOnHero then
        header:setVisible(true)

        if self.battleProcess.prepareSkillFinish then
            self.battleProcess.prepareSkillFinish(header)
        end
        return
    end

    local pos = node:getPosition3D()
    header:setVisible(true)
    header:setScale(0.1 * bd.ui_config.MinScale)
    header:setPosition(pos.x, pos.y + 100 * bd.ui_config.MinScale)
    if header.avatar then
        header.avatar:setColor(cc.c3b(255, 255, 255))
    end

    -- 重新排列
    self:resortAllHeader()
end


-- @创建施法框
function BDTouch:createSkillHeader(node)
    -- 使用点击人物的方式
    if bd.ui_config.skillOnHero then
        return node.skillEffectNode
    end

    -- 使用施法框:

    local header = cc.Node:create()
    header:setScale(bd.ui_config.MinScale)

    -- mask sprite
    local maskSprite = cc.Sprite:create(bd.ui_config.skillHeaderMaskPic)
    --头像
    local clipNode
    if g_editor_mode_hero_data then
        clipNode = cc.Node:create()
    else
        clipNode = cc.ClippingNode:create(maskSprite)
        clipNode:setAlphaThreshold(0.9)
    end
    clipNode:setScale(1.2)

    local avatarPic = bd.interface.getIllusionAvatar(node.illusionModelId) or bd.interface.getFashionAvatar(node.figureName) or bd.interface.getAvatar(node.heroId)
    local advAvatarPic = bd.interface.getAvatarAdv(node.heroId, node.illusionModelId)
    header.avatar = cc.Sprite:create(avatarPic)
    if header.avatar then
        header.avatar:setScale(1.2)
        clipNode:addChild(header.avatar)
    end

    --特效
    bd.func.performWithDelay(header, function()
        header.anim = ui.newEffect({
            effectName = bd.ui_config.skillEffect[1],
            animation  = bd.ui_config.skillEffect[2],
            parent     = header,
            loop       = true,
            scale      = 0.7,
            endRelease = false,
        })

        local pp = self.battleData:getHeroPartnerPos(node.idx)

        if bd.project == "project_sanguo" then
            header.advAnim = bd.interface.newSprite({
                img    = "dl_36.png",
                parent = header,
                scale  = 1.3,
            })

            header.advAnim:runAction(cc.RepeatForever:create(
                cc.RotateBy:create(1, -30)
            ))
        end

        if header.advAnim then
            header.advAnim:setVisible(pp ~= nil)
        end
        if advAvatarPic then
            header.avatar:setTexture(pp ~= nil and advAvatarPic or avatarPic)
        end
        header.anim:setVisible(header.advAnim == nil or pp == nil)

        local watch_
        watch_ = function()
            if tolua.isnull(header) then
                self.battleData:off(bd.event.eHeroDead, watch_)
                self.battleData:off(bd.event.eHeroReborn, watch_)
                return
            end
            if pos == pp then
                local p = self.battleData:getHeroPartnerPos(node.idx)
                if header.advAnim then
                    header.advAnim:setVisible(p ~= nil)
                end
                if advAvatarPic then
                    header.avatar:setTexture(p ~= nil and advAvatarPic or avatarPic)
                end
                header.anim:setVisible(header.advAnim == nil or p == nil)
            end
        end
        self.battleData:on(bd.event.eHeroDead, watch_)
        self.battleData:on(bd.event.eHeroReborn, watch_)
    end, 0)

    header:addChild(clipNode)

    return header
end


-- @隐藏施法框
function BDTouch:hideSkillHeader(node)
    node.canSkill = false

    local header = self.skillHeader_[node.idx]
    if header then
        header:setVisible(false)
        self:resortAllHeader()
    end
end


-- @重新排序所有头像
function BDTouch:resortAllHeader()
    -- 在人物身上点击
    if bd.ui_config.skillOnHero then
        for _, v in pairs(self.skillHeader_) do
            if v:isVisible() then
                v:setPosition(params)
            end
        end
        return
    end

    local enableList = {}
    for _, v in pairs(self.skillHeader_) do
        if v:isVisible() then
            table.insert(enableList, v)
        end
    end

    -- 按位置排序
    table.sort(enableList, function(a, b)
        return a.idx < b.idx
    end)

    -- 计算位置
    local cnt = #enableList
    local middleX = display.cx
    local width = 105 * bd.ui_config.MinScale -- 间距
    local middleIndex = cnt / 2

    for i, v in ipairs(enableList) do
        local offsetIndex = i - 0.5 - middleIndex
        local x = middleX + (width * offsetIndex)
        local y = 70 * bd.ui_config.MinScale + Adapter.BottomY

        if not tolua.isnull(v.moving_action_) then
            v:stopAction(v.moving_action_)
        end


        if x ~= v:getPositionX() or y ~= v:getPositionY() then
            local action = cc.Spawn:create(
                cc.EaseBackInOut:create(cc.MoveTo:create(0.5, cc.p(x, y))),
                cc.Sequence:create({
                    cc.ScaleTo:create(0.6, bd.ui_config.MinScale),
                    cc.CallFunc:create(function( ... )
                        if self.battleProcess.prepareSkillFinish then
                            self.battleProcess.prepareSkillFinish(v)
                        end
                    end)
                })
            )
            v.moving_action_ = action
            v:runAction(action)
        end
    end
end

return BDTouch
