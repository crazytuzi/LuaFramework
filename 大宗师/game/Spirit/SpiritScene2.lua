--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-7
-- Time: 下午4:55
-- To change this template use File | Settings | File Templates.
--
local data_config_config = require("data.data_config_config")
local data_item_item = require("data.data_item_item")
local data_collect_collect = require("data.data_collect_collect")
require("data.data_error_error")

local SpiritScene2 = class("SpiritScene", function()

    return require("game.BaseScene").new({
        contentFile = "spirit/spirit_scene.ccbi",
        subTopFile = "spirit/tab_view.ccbi"
    })
end)

local RequestInfo = require("network.RequestInfo")
local TAB_TAG = {
    INFO = 1,
    LIST = 2
}

local LISTVIEW_TAG = 100

function SpiritScene2:ctor(param)
    
    ResMgr.removeBefLayer()
    game.runningScene = self

--    dump(param)
    local tag = param.tag
    self._ctrl = param.ctrl

    if tag == nil or tag < 0 or tag > 2 then
        self._currentTab = TAB_TAG.INFO
    else
        self._currentTab = tag
    end

    local s
    if display.width / self._rootnode["spiritListNode"]:getContentSize().width > (self:getCenterHeightWithSubTop() - 346) / self._rootnode["spiritListNode"]:getContentSize().height then
        s = display.width / self._rootnode["spiritListNode"]:getContentSize().width
    else
        s = (self:getCenterHeightWithSubTop() - 346) / self._rootnode["spiritListNode"]:getContentSize().height
    end

    self._rootnode["spiritListNode"]:setScale(s)
    self._rootnode["itemsBg"]:setContentSize(CCSizeMake(display.width, self:getCenterHeightWithSubTop() - 346 - 20))
    self._rootnode["touchNode"]:setContentSize(self._rootnode["itemsBg"]:getContentSize())
    self._rootnode["upArrow"]:setPositionY(self._rootnode["itemsBg"]:getContentSize().height)
    self._rootnode["numBgSprite"]:setPosition(display.width / 2, 346 + self._rootnode["numBgSprite"]:getContentSize().height / 2)
    self._rootnode["startOneCostSilverLabel"]:setString(tostring(0))
    self._rootnode["start10CostSilverLabel"]:setString(tostring(data_config_config[1]["collTenSilver"]))
    self._rootnode["costGoldLabel"]:setString(tostring(data_config_config[1]["juYuanGold"]))

    if(game.player.m_level >=50 or game.player.m_vip >= 1) then
        self._rootnode["vip_level_10"]:setVisible(false)
    end

    self._rootnode["spiritInfoBtn"]:addHandleOfControlEvent(function(eventName,sender)
        self._rootnode["spiritInfoBtn"]:setEnabled(false)
        self._rootnode["equipSpiritBtn"]:setEnabled(false)
        local spiritInfoLayer = require("game.Spirit.SpiritDescLayer").new(function()
            self._rootnode["spiritInfoBtn"]:setEnabled(true)
            self._rootnode["equipSpiritBtn"]:setEnabled(true)
        end)
        self:addChild(spiritInfoLayer, 3)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end, CCControlEventTouchDown)

    self._rootnode["equipSpiritBtn"]:addHandleOfControlEvent(
        function(eventName,sender)
            local equipSpiritScene = require("game.form.HeroSettingScene").new(2)
            display.replaceScene(equipSpiritScene)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        end, CCControlEventTouchDown)

    local function updateLabel()
        self._rootnode["iconCountLabel"]:setString(tostring(self._ctrl.get("size").num))
        self._rootnode["maxIconCountLabel"]:setString(tostring(self._ctrl.get("size").max))

        self._rootnode["goldLabel"]:setString(game.player:getGold())
        self._rootnode["silverLabel"]:setString(game.player:getSilver())
        self._rootnode["totalItemLabel"]:setString(tostring(self._ctrl.get("item")))
    end

    --    选项卡切换
    local function onTabBtn(tag)

        if TAB_TAG.INFO == tag then
            self._rootnode["infoView"]:setVisible(true)
            self._rootnode["listView"]:removeAllChildrenWithCleanup(true)
            if self._refresh then
--                self:refresh()
                self._ctrl.refresh()
                self:initListView2()
                self._refresh = false
            end
        elseif TAB_TAG.LIST == tag then
            self._rootnode["infoView"]:setVisible(false)
            local listView = require("game.Spirit.SpiritListLayer").new({
                sz = self._rootnode["listView"]:getContentSize(),
                items = self._ctrl.get("spiritList")
            })
            self._rootnode["listView"]:addChild(listView)
            listView:setTag(LISTVIEW_TAG)
        else
            assert(false, "SpiritScene onTabBtn Tag Error!")
        end
        self._currentTab = tag

        for i = 1, 2 do
            if tag == i then
                self._rootnode["tab" ..tostring(i)]:selected()
                self._rootnode["tab" ..tostring(i)]:setZOrder(2)
            else
                self._rootnode["tab" ..tostring(i)]:unselected()
                self._rootnode["tab" ..tostring(i)]:setZOrder(1)
            end
        end
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
    end

    --初始化选项卡
    local function initTab()
        for i = 1, 2 do
            self._rootnode["tab" ..tostring(i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)
        end
        if self._currentTab == TAB_TAG.INFO then 
            self._rootnode["tab1"]:selected()
        else
            self._rootnode["tab2"]:selected()
        end
    end

    initTab()
    local moveFront
    local function onStart(eventName,sender)
        local tag = sender:getTag()
        self._ctrl.onStart(tag, function(data)
            if tag == 3 then
                local tipLayer = require("game.Spirit.SpiritGetTip").new(data)
                self:addChild(tipLayer, 100)
            end
            updateLabel()
            moveFront(self._ctrl.get("level"))
            self:initListView2()
        end)
    end
    self._rootnode["startOneBtn"]:addHandleOfControlEvent(onStart, CCControlEventTouchDown)
    self._rootnode["superStartBtn"]:addHandleOfControlEvent(onStart, CCControlEventTouchDown)
    self._rootnode["start10Btn"]:addHandleOfControlEvent(function(eventName,sender)
            local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.LianShici_Zhenqi, game.player:getLevel(), game.player:getVip()) 
            if not bHasOpen then 
                show_tip_label(prompt) 
            else
                onStart(eventName,sender)
            end
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        end, CCControlEventTouchDown)

    local function getPositionByTag(tag)
        return CCPointMake(self._rootnode["pos" .. tostring(tag)]:getPosition())
    end

    local function getScaleByTag(tag)
        return self._rootnode["pos" .. tostring(tag)]:getTag() / 10
    end

    local persons = {}
    local col = {{-138}, {0}, {100}, {-188}, {255}}
    local function initPerson()
        for i = 5, 9 do
            local person = display.newSprite(string.format("#spirit_p_%s.png", i - 4))
            local k = "pos" .. tostring(i)
            person:setPosition(self._rootnode[k]:getPosition())
            self._rootnode["infoView"]:addChild(person, 9 - i)
            person:setScale(self._rootnode[k]:getTag() / 10)

            local system = CCParticleSystemQuad:new()
            system:initWithFile("Particle/spirit.plist")
            system:setPosition(person:getContentSize().width / 2, person:getContentSize().height / 2)
            person:addChild(system, 10);
            table.insert(persons, person)
        end
    end
    initPerson()

--  从左到右依次为：1, 2, 3, 4,  5,  6, 7, 8, 9
--                1， 2， 3，4， 0， 1， 2，3， 4

--  中间的为：5
    local function getIndexByPos(x, y)
        for i = 1, 9 do
            local k = "pos" .. tostring(i)
            local posX, posY = self._rootnode[k]:getPosition()
            if x == posX and y == posY then
                return i
            end
        end
    end

--  右移动为正，左移动为负
    local function countOffset(personIdx)
        local posIndex = getIndexByPos(persons[personIdx]:getPosition())
        local offset = 5 - posIndex

        return math.abs(offset), offset >= 0
    end

    moveFront = function(personIdx, delayTime)
        delayTime = delayTime or 0.5
        self._rootnode["startOneCostSilverLabel"]:setString(tostring(data_collect_collect[personIdx].price))
        local offset, dir = countOffset(personIdx)
        if offset == 0 then

        else
            self._rootnode["startOneBtn"]:setEnabled(false)
            self._rootnode["superStartBtn"]:setEnabled(false)
            self._rootnode["start10Btn"]:setEnabled(false)
            for k, v in ipairs(persons) do
                local act = {}
                local posTag = getIndexByPos(v:getPosition())
                for i = 1, offset do
                    local tag
                    if dir then
                        tag = posTag + i
                    else
                        tag = posTag - i
                    end

                    table.insert(act, CCCallFunc:create(function()
                        if tag > 5 then
                            v:setZOrder(5 - tag % 5)
                        else
                            v:setZOrder(tag)
                        end
                    end))
                    local moveTo = CCMoveTo:create(delayTime / offset, getPositionByTag(tag))
                    local scaleTo = CCScaleTo:create(delayTime / offset, getScaleByTag(tag))
                    table.insert(act, CCSpawn:createWithTwoActions(moveTo, scaleTo))

                    if tag == 5 then
                        table.insert(act, CCCallFunc:create(function()
                            self._rootnode["spiritName"]:setDisplayFrame(display.newSpriteFrame(string.format("spirit_icon_label_%d.png", k)))
                        end))
                    end
--                    table.insert(act, CCDelayTime:create(0.2 / offset))
                end
                if k == #persons then
                    table.insert(act, CCCallFunc:create(function()
                        self._rootnode["startOneBtn"]:setEnabled(true)
                        self._rootnode["superStartBtn"]:setEnabled(true)
                        self._rootnode["start10Btn"]:setEnabled(true)
                    end))
                end

                v:runAction(transition.sequence(act))
            end
        end
    end

    --
    updateLabel()
    moveFront(self._ctrl.get("level"), 0)
    if tag == TAB_TAG.LIST then
        onTabBtn(2)
    end
end

function SpiritScene2:initListView2()

    if self._spiritListView then
        self:refreshSpiritList(true)
        return
    end

    self._rootnode["touchNode"]:setTouchEnabled(true)
    self._rootnode["touchNode"]:setZOrder(1)
    local posX = 0
    local posY = 0
    self._rootnode["touchNode"]:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
        if event.name == "began" then
            posX = event.x
            posY = event.y
            return true
        elseif event.name == "ended" then
            self:refreshArrow()
        end
    end)
    self._rootnode["touchNode"]:setTouchSwallowEnabled(false)
    local showList = self._ctrl.get("showList")
    local sz = self._rootnode["itemsBg"]:getContentSize()
    local item = require("game.Spirit.SpiritShowItem")
    self._spiritListView = require("utility.TableViewExt").new({
        size        = CCSizeMake(sz.width, sz.height),
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = function(idx)
            local item = item.new()
            idx = idx + 1
            return item:create({
                viewSize = sz,
                itemData = showList[idx],
                idx      = idx,
            })
        end,
        refreshFunc = function(cell, idx)
            idx = idx + 1
            cell:refresh({
                idx = idx,
                itemData = showList[idx]
            })
        end,
        cellNum   = #showList,
        cellSize    = item.new():getContentSize(),
        touchFunc = function(cell)

            local idx = cell:getIdx() + 1
            local pos = cell:convertToNodeSpace(ccp(posX, posY))
            printf("pos.x = %d, pos.y = %d", pos.x, pos.y)
            local sz = cell:getContentSize()
            local i = 0
            if pos.x > sz.width * (4 / 5) and pos.x < sz.width then
                i = 5
            elseif pos.x > sz.width * (3 / 5)  then
                i = 4
            elseif pos.x > sz.width * (2 / 5)  then
                i = 3
            elseif pos.x > sz.width * (1 / 5) then
                i = 2
            elseif pos.x > 0 then
                i = 1
            end

            if i >= 1 and i <= 5 then
                local info = showList[idx]
                if info and info[i] then
                    self:onTouchIcon(info[i].data._id)
                end
            end
        end
    })
    self._spiritListView:setPosition(0, 0)
    self._rootnode["itemsBg"]:addChild(self._spiritListView)
    self:refreshSpiritList()
end

function SpiritScene2:refreshArrow()
    self:performWithDelay(function()
        local posY = self._spiritListView:getContentOffset().y
        local maxOffsetY = self._spiritListView:maxContainerOffset().y
        local minOffsetY = self._spiritListView:minContainerOffset().y
        if minOffsetY < 0 then
            if posY >= maxOffsetY then
                self._rootnode["upArrow"]:setVisible(true)
                self._rootnode["downArrow"]:setVisible(false)
            elseif  posY <= minOffsetY then
                self._rootnode["upArrow"]:setVisible(false)
                self._rootnode["downArrow"]:setVisible(true)
            else
                self._rootnode["upArrow"]:setVisible(true)
                self._rootnode["downArrow"]:setVisible(true)
            end
        end
    end, 0.5)
end


function SpiritScene2:resetArrow()
    self._rootnode["upArrow"]:setZOrder(3)
    self._rootnode["downArrow"]:setZOrder(3)

    local minOffsetY = self._spiritListView:minContainerOffset().y
    if minOffsetY < 0 then
        self._rootnode["upArrow"]:setVisible(false)
        self._rootnode["downArrow"]:setVisible(true)
    else
        self._rootnode["upArrow"]:setVisible(false)
        self._rootnode["downArrow"]:setVisible(false)
    end
end

function SpiritScene2:refreshSpiritList(bResetCellNum)
    local cellNum = self._spiritListView:getCellNum()
    if bResetCellNum then
        local showList = self._ctrl.get("showList")
        self._spiritListView:resetCellNum(#showList)
    end
    if self._spiritListView:minContainerOffset().y > 0 then
        self._spiritListView:setContentOffset(ccp(0, self._spiritListView:minContainerOffset().y))
    else
        if cellNum < self._spiritListView:getCellNum() and cellNum > 2 then
            self._spiritListView:setContentOffset(ccp(0, self._spiritListView:maxContainerOffset().y - require("game.Spirit.SpiritShowItem").new():getContentSize().height))
            self._spiritListView:setContentOffset(ccp(0, self._spiritListView:maxContainerOffset().y), true)
        else
            self._spiritListView:setContentOffset(ccp(0, self._spiritListView:maxContainerOffset().y))
        end
    end
    self:refreshArrow()
    self._rootnode["iconCountLabel"]:setString(tostring(#self._ctrl.get("spiritList")))
    self._ctrl.set("size", {num = #self._ctrl.get("spiritList"), max = self._ctrl.get("size").max})
end
--
function SpiritScene2:onTouchIcon(id)
    local index = self._ctrl.getIndexByID(id)
    if index > 0 then
        self:onIcon(index)
    else
        show_tip_label("数据异常，请重试")
    end
end

function SpiritScene2:onIcon(index)
    local descLayer = require("game.Spirit.SpiritInfoLayer").new(2, self._ctrl.get("spiritList")[index].data, function()
--        push_scene(require("game.Spirit.SpiritUpgradeScene").new(self._ctrl.get("spiritList")[index], self._ctrl.get("spiritList")))
        self._ctrl.pushUpgradeScene(index)
    end)
    game.runningScene:addChild(descLayer, 5)
end

function SpiritScene2:onEnter()
    self:regNotice()
    PostNotice(NoticeKey.UNLOCK_BOTTOM)
    game.runningScene = self
    if self._bExit then
        self._bExit = false
        local listView = self._rootnode["listView"]:getChildByTag(LISTVIEW_TAG)
        if self._currentTab == TAB_TAG.LIST then
            if listView then
                listView:refresh()
                self._refresh = true
            end
        elseif self._currentTab == TAB_TAG.INFO then
            self._ctrl.refresh()
            self:initListView2()
        end
    else
        self._rootnode["infoView"]:performWithDelay(function()
            self:initListView2()
            self:resetArrow()
        end, 0.05)
    end
end

function SpiritScene2:onExit()
    self._bExit = true
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
    self:unregNotice()
end

return SpiritScene2
