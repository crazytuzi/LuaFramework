--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-22
-- Time: 下午10:33
-- To change this template use File | Settings | File Templates.
--


local FormSettingLayer = class("FormSettingLayer", function(param)
    if param.bTouchEnabled then
        return require("utility.ShadeLayer").new(ccc4(100, 100, 100, 150))
    else
        return display.newNode()
    end

end)

local function getDataOpen(sysID)
    local data_open_open = require("data.data_open_open")
    
    for k, v in ipairs(data_open_open) do

        if sysID == v.system then
            return v
        end
    end
end


local POS_MAP = {2, 5, 3, 4, 6, 1}
function FormSettingLayer:ctor(param)
    local _list = param.list
    local _sz   = param.sz
    local _closeListener = param.closeListener
    local _exchangeFunc = param.exchangeFunc
    local _zdlNum = param.zdlNum
    dump(_list)

    local function getHeroByPos(pos)
        for k, v in ipairs(_list) do
            if pos == v.pos then
                return v
            end
        end
        return nil
    end
--
    local cardlist = {}
    for i = 1, 6 do
        local h = getHeroByPos(i)
        if h then
            table.insert(cardlist, h)
        else
            table.insert(cardlist, 0)
        end
    end
    dump(cardlist)

    local proxy = CCBProxy:create()
    local rootnode = {}

    local node = CCBuilderReaderLoad("formation/formation_setting.ccbi", proxy, rootnode, self, _sz)
    if param.bTouchEnabled then
        node:setPosition(display.cx, display.cy)
    end
    self:addChild(node, 1)

    if _zdlNum then
        rootnode["zdlNode"]:setVisible(true)
        rootnode["zdlLabel"]:setString(_zdlNum)
    end

    rootnode["titleLabel"]:setString("设置阵型")
    rootnode["tag_close"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        self:removeSelf()
        if _closeListener then
            _closeListener()
        end
    end, CCControlEventTouchUpInside)

    local cards = {}
    local function reorderCard(card)
        for k, v in ipairs(getDataOpen(14).level) do
            local key = string.format("card_%d", k)
            rootnode[key]:setZOrder(0)
        end
        card:setZOrder(10)
    end

    local _x, _y
    local function touchBegan(param)
        if param.cardnode:isOpen() then
            if param.cardnode:empty() then

            else
                _x, _y = param.image:getPosition()
                reorderCard(param.cardnode:getParent())
            end
        end
    end

    local function touchMove(param)
        local posX, posY = param.image:getPosition()
        param.image:setPosition(posX + param.event.x - param.event.prevX, posY + param.event.y - param.event.prevY)
    end

    local function touchEnd(param)
        local bSwitch = false
        local index = 0
        for k, v in ipairs(cards) do
            if v:isInCard(param.event.x, param.event.y) == true and v ~= param.cardnode then
                bSwitch = v:switchWithCard(param.cardnode, param.event.x, param.event.y)
                index = v:getIndex()
                break
            end
        end
--
        if bSwitch then
            if index ~= 0 then
                if _exchangeFunc then
                    _exchangeFunc(tostring(index), cardlist[param.cardnode:getIndex()].objId)
                end

                local t = cardlist[index]
                cardlist[index] = cardlist[param.cardnode:getIndex()]
                cardlist[param.cardnode:getIndex()] = t
            end
        end

        param.image:runAction(transition.sequence({
            CCCallFunc:create(function()
                param.cardnode:setTouchEnabled(false)
            end),
            CCMoveTo:create(0.1, ccp(_x, _y)),
            CCCallFunc:create(function()
                param.cardnode:setTouchEnabled(true)
            end),
        }))
    end


    for k, v in ipairs(cardlist) do
        local key = string.format("card_%d", k)
        local cardnode = require("game.form.FormSettingCard").new({
            lv       = 0,
            data     = v,
            index    = k,
            touchBegan = touchBegan,
            touchEnd   = touchEnd,
            touchMove  = touchMove})

        rootnode[key]:addChild(cardnode)
        table.insert(cards, cardnode)
    end

end

return FormSettingLayer

