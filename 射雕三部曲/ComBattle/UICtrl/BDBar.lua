--[[
    文件名：BDBar
    描述：人物的血条
    创建人：luoyibo
    创建时间：2015.05.12
-- ]]

local BDBar = class("BDBar", function()
    return cc.Node:create()
end)

local function calcPercent(per)
    local per_bg, per_front
    if per > 50 then
        per_bg = 100
        per_front = (per - 50) * 2
    else
        per_bg = per * 2
        per_front = 0
    end

    return per_front, per_bg
end


--[[
name, quality
curHP, maxHP,
curRP, maxRP,
isBoss
isPet
--]]
function BDBar:ctor(params)
    local hp, rp
    if not params.isBoss then
        -- 判断是否宠物
        if not params.isPet then
            -- 血量
            hp = self:createHPBar(params)
            hp:setPositionY(11)
            self:addChild(hp)

            -- 怒气
            rp = self:createRPBar(params)
            self:addChild(rp)
        end

        local name = self:createNameLabel(params.name, params.quality)
        name:setPosition(0, 30)
        self.nameNode_ = name
        self:addChild(name)
    else
        hp = self:createBossHPBar(params)
        self:addChild(hp)

        rp = self:createBossRPBar(params)
        self:addChild(rp, 1)
    end

    function self.setHP(_, value, max)
        if params.isBoss then
            hp:setPercent(value)
        else
            max = max or params.maxHP
            hp:setPercent(math.min(value, max) / max)
        end
    end

    function self.setRP(_, value, max)
        max = max or params.maxRP
        rp:setPercent(math.min(value, max) / max)
    end

    function self.showName(_, show)
        return self.nameNode_ and self.nameNode_:setVisible(show)
    end

    function self.setRpVisible(_, visible)
        rp:setVisible(visible)
    end
end


-- @创建Boss血条
function BDBar:createBossHPBar(params)
    local node = cc.Node:create()

    -- 生命条
    local hpBar = bd.interface.newProgress({
        bgImage   = bd.ui_config.bossHpBarBgPic,
        barImage  = bd.ui_config.bossHpBarFrontPic,
        needLabel = true,
        currValue = params.curHP,
        maxValue  = params.maxHP,
    })
    node:addChild(hpBar, 1)
    hpBar.mProgressLabel:setPositionY(hpBar.mProgressLabel:getPositionY() + 5)

    if bd.ui_config.bossHPBarConfig and bd.ui_config.bossHPBarConfig.labelPosFix then
        local p = bd.ui_config.bossHPBarConfig.labelPosFix
        local pos = cc.p(hpBar.mProgressLabel:getPosition())
        hpBar.mProgressLabel:setPosition(pos.x + p.x, pos.y + p.y)
    end

    local curPercent = params.curHP / params.maxHP
    function node.setPercent(_, v)
        per = v / params.maxHP
        hpBar:setCurrValue(v, math.abs(curPercent - per) * 0.15)

        curPercent = per
    end
    hpBar:setCurrValue(params.curHP, 0)

    return node
end


-- @创建BOSS怒气
function BDBar:createBossRPBar(params)
    local node = cc.Node:create()

    local rpBgBar = bd.interface.newProgress({
        bgImage    = bd.ui_config.bossRpBarBgPic,
        barImage   = bd.ui_config.bossRpBarFrontPic,
        needLabel  = false,
        currValue  = 0,
        maxValue   = 100,
        needHideBg = true,
    })
    node:addChild(rpBgBar, 1)

    -- 怒气1
    local rpFrontBar = bd.interface.newProgress({
        bgImage    = bd.ui_config.bossRpBarBgPic,
        barImage   = bd.ui_config.bossRpBarFrontPic,
        needLabel  = false,
        currValue  = 0,
        maxValue   = 100,
        needHideBg = true,
    })
    rpFrontBar.mBarSprite:setColor(cc.c3b(255, 128, 120))
    node:addChild(rpFrontBar, 2)

    local curPercent = params.curRP / params.maxRP
    function node.setPercent(_, per)
        self:setValueForRPBar(per, curPercent, rpFrontBar, rpBgBar)
        curPercent = per
    end

    -- 初始化
    self:setValueForRPBar(curPercent, curPercent, rpFrontBar, rpBgBar)

    return node
end


-- @创建血条
function BDBar:createHPBar(params)
    local node = cc.Node:create()

    -- 生命2
    local hpBar2 = bd.interface.newProgress({
        bgImage    = bd.ui_config.hpBarBgPic,
        barImage   = bd.ui_config.hpBarFrontPic,
        needLabel  = false,
        needHideBg = true,
        currValue  = 0,
        maxValue   = 100,
    })
    hpBar2:setAnchorPoint(cc.p(0.5, 0.5))
    node:addChild(hpBar2, 2)

    -- 生命1
    local hpBar1 = bd.interface.newProgress({
        bgImage   = bd.ui_config.hpBarBgPic,
        barImage  = bd.ui_config.hpBarFrontPic,
        needLabel = false,
        currValue  = 0,
        maxValue   = 100,
    })
    hpBar1.mBarSprite:setColor(cc.c3b(0, 170, 0))
    hpBar1:setAnchorPoint(cc.p(0.5, 0.5))
    node:addChild(hpBar1, 1)

    local maxValue = params.maxHP
    local curPercent = params.curHP / maxValue
    function node.setPercent(_, per)
        self:setValueForHPBar(per, curPercent, hpBar2, hpBar1)
        curPercent = per
    end
    self:setValueForHPBar(curPercent, curPercent, hpBar2, hpBar1)

    return node
end

-- 创建怒气条
function BDBar:createRPBar(params)
    local node = cc.Node:create()

    -- 怒气
    local rpBar2 = bd.interface.newProgress({
        bgImage    = bd.ui_config.rpBarBgPic,
        barImage   = bd.ui_config.rpBarFrontPic,
        needLabel  = false,
        needHideBg = true,
        currValue  = 0,
        maxValue   = 100,
    })
    rpBar2:setAnchorPoint(cc.p(0.5, 0.5))
    node:addChild(rpBar2, 2)
    rpBar2.mBarSprite:setColor(cc.c3b(255, 128, 0))

    -- 怒气1
    local rpBar1 = bd.interface.newProgress({
        bgImage   = bd.ui_config.rpBarBgPic,
        barImage  = bd.ui_config.rpBarFrontPic,
        needLabel = false,
        currValue  = 0,
        maxValue   = 100,
    })
    rpBar1:setAnchorPoint(cc.p(0.5, 0.5))
    node:addChild(rpBar1, 1)

    local curPercent = params.curRP / params.maxRP
    function node.setPercent(_, per)
        self:setValueForRPBar(per, curPercent, rpBar2, rpBar1)
        curPercent = per
    end
    self:setValueForRPBar(curPercent, curPercent, rpBar2, rpBar1)

    return node
end


-- @血量效果
function BDBar:setValueForHPBar(newValue, oldValue, barFront, barBack)
    local v = newValue * 100
    if newValue < oldValue then
        barFront:setCurrValue(v, 0)
        barBack:setCurrValue(v, math.abs(newValue - oldValue) * 0.18)
    elseif newValue > oldValue then
        barBack:setCurrValue(v, 0)
        barFront:setCurrValue(v, math.abs(newValue - oldValue) * 0.18)
    else
        barBack:setCurrValue(v, 0)
        barFront:setCurrValue(v, 0)
    end
end


-- @怒气效果
function BDBar:setValueForRPBar(newPer, oldPer, barFront, barBack)
    oldPer = oldPer * 100
    newPer = newPer * 100
    local delta = newPer - oldPer
    local per_front_old, per_bg_old = calcPercent(oldPer)
    local per_front, per_bg = calcPercent(newPer)


    if delta > 0 then
        if per_bg ~= per_bg_old then
            barBack:setCurrValue(per_bg, math.abs(per_bg - per_bg_old) * 0.0018, function()
                barFront:setCurrValue(per_front, math.abs(per_front - per_front_old) * 0.0018)
            end)
        else
            barFront:setCurrValue(per_front, math.abs(per_front - per_front_old) * 0.0018)
        end
    elseif delta < 0 then
        if per_front ~= per_front_old then
            barFront:setCurrValue(per_front, math.abs(per_front - per_front_old) * 0.0018, function()
                barBack:setCurrValue(per_bg, math.abs(per_bg - per_bg_old) * 0.0018)
            end)
        else
            barBack:setCurrValue(per_bg, math.abs(per_bg - per_bg_old) * 0.0018)
        end
    else
        barFront:setCurrValue(per_front, 0)
        barBack:setCurrValue(per_bg, 0)
    end
end


-- 显示名字
function BDBar:createNameLabel(name, quality)
    local retColor = bd.interface.getQualityColor(quality, 1)

    local tempLabel = bd.interface.newLabel({
        text         = name,
        size         = 22,
        color        = retColor,
        font         = _FONT_PANGWA,
        outlineSize  = 2,
        outlineColor = Enums.Color.eBlack,
        align        = cc.TEXT_ALIGNMENT_CENTER,
        valign       = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
        x            = 0,
        y            = 0,
    })
    tempLabel:setAnchorPoint(cc.p(0.5, 0.5))

    return tempLabel
end

return BDBar
