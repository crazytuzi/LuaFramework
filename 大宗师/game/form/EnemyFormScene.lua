--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-10
-- Time: 上午11:35
-- To change this template use File | Settings | File Templates.
--


require("utility.BottomBtnEvent")
local data_jiban_jiban = require("data.data_jiban_jiban")
local data_item_item = require("data.data_item_item")

--1：头部
--2：手部
--3：项链部位
--4：衣服部位
--5：内功部位
--6：外功部位
local RequestInfo = require("network.RequestInfo")
local HeroIcon = class("HeroIcon", function()
    return CCTableViewCell:new()
end)

function HeroIcon:getContentSize()
--    local sz = display.newSprite("hero/icon/icon_hero_guojing.png"):getContentSize()
    return CCSizeMake(115, 115)
end

function HeroIcon:ctor()

end

function HeroIcon:create(param)
    local _viewSize = param.viewSize
    local _itemData  = param.itemData

    self._heroIcon = display.newSprite("#zhenrong_equip_bg.png")
    self:addChild(self._heroIcon)
    self._heroIcon:setPosition(self._heroIcon:getContentSize().width / 2, _viewSize.height / 2)

    self._actIcon = display.newSprite("#zhenrong_equip_bg.png")
    self:addChild(self._actIcon)
    self._actIcon:setPosition(self._actIcon:getContentSize().width / 2, _viewSize.height / 2)

    local label = ui.newTTFLabel({
        text = "",
        size = 20
    })
    label:setPosition(self._actIcon:getContentSize().width / 2, self._actIcon:getContentSize().height / 2)
    self._actIcon:addChild(label)
    label:setTag(1)

    local addSprite = display.newSprite("#zhenrong_add.png")
    addSprite:setPosition(self._actIcon:getContentSize().width / 2, self._actIcon:getContentSize().height / 2)
    self._actIcon:addChild(addSprite)
    addSprite:setTag(2)

    local xhbSprite = display.newSprite("#zhenrong_xiaohuoban_title.png")
    xhbSprite:setPosition(self._actIcon:getContentSize().width / 2, self._actIcon:getContentSize().height / 2)
    self._actIcon:addChild(xhbSprite)
    xhbSprite:setTag(3)

    self:refresh(param)
    return self
end

function HeroIcon:refresh(param)

    local _itemData  = param.itemData
    self._heroIcon:setVisible(false)
    self._actIcon:setVisible(false)

    if type(_itemData) == "number" then
        self._actIcon:setVisible(true)

        self._actIcon:getChildByTag(1):setVisible(false)
        self._actIcon:getChildByTag(2):setVisible(false)
        self._actIcon:getChildByTag(3):setVisible(false)

        if _itemData > 0 then
            self._actIcon:getChildByTag(1):setVisible(true)
            self._actIcon:getChildByTag(1):setString(string.format("%d级\n开放", _itemData))
        elseif _itemData == 0 then
            self._actIcon:getChildByTag(2):setVisible(true)
        else
            self._actIcon:getChildByTag(3):setVisible(true)
        end
    else
        self._heroIcon:setVisible(true)
        ResMgr.refreshIcon({itemBg = self._heroIcon, id = param.itemData.resId, resType = ResMgr.HERO})
    end
end

local function getDataOpen(sysID)
    local data_open_open = require("data.data_open_open")
    for k, v in ipairs(data_open_open) do

        if sysID == v.system then
            return v
        end
    end
end

local MOVE_OFFSET = display.width / 3

local EnemyFormScene = class("EnemyFormScene", function()
    return display.newScene("EnemyFormScene")
end)

local SHOWTYPE = {
    FORMATION = 1,
    SPIRIT    = 2
}

function EnemyFormScene:ctor(showType, enemyID)
    self._enemyID = enemyID

    local bg = display.newSprite("bg/formation_bg.jpg")
    bg:setPosition(display.cx, display.cy)
    bg:setScaleX(display.width/bg:getContentSize().width)
    bg:setScaleY((display.height - 300) / bg:getContentSize().height)
    self:addChild(bg, 0)

    game.runningScene = self
    self._index = 1
    if showType == SHOWTYPE.SPIRIT then
        self._showType = 2
    else
        self._showType = 1
    end

    self:setContentSize(CCSizeMake(display.width, display.height))

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("formation/formation_scene.ccbi", proxy, self._rootnode)
    node:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
    self:addChild(node, 1)

    local tmpY = self._rootnode["headList"]:getPositionY()

    self._rootnode["headList"]:setPosition(display.cx - self._rootnode["headList"]:getContentSize().width / 2, tmpY)

    BottomBtnEvent.registerBottomEvent(self._rootnode)

    local _level = game.player:getLevel()
    for k, v in ipairs(getDataOpen(12).level) do
        if v <= _level then
            self._rootnode["spiritLock_" .. tostring(k)]:setVisible(false)
            local spiritNodeName = "spiritNode_" .. tostring(k)
            local s = display.newSprite("#zhenrong_add.png")
            s:setPosition(self._rootnode[spiritNodeName]:getContentSize().width / 2, self._rootnode[spiritNodeName]:getContentSize().height / 2)
            self._rootnode[spiritNodeName]:addChild(s)
        end
    end

    local function refreshBtnText()
        if self._showType == SHOWTYPE.SPIRIT then
            self._rootnode["spiritAndEquipBtn"]:setTitleForState(CCString:create("装备"), CCControlStateNormal)
        else
            self._rootnode["spiritAndEquipBtn"]:setTitleForState(CCString:create("精元"), CCControlStateNormal)
        end
    end

    local function switchView(bRefresh)
        refreshBtnText()
        if self._showType == SHOWTYPE.SPIRIT then
            self._rootnode["spiritNode"]:setVisible(true)
            self._rootnode["equipNode"]:setVisible(false)
--
        else
            self._rootnode["spiritNode"]:setVisible(false)
            self._rootnode["equipNode"]:setVisible(true)
--
        end
        if bRefresh then
            self:refreshHero(self._index)
        end
    end

    self._rootnode["spiritAndEquipBtn"]:addHandleOfControlEvent(function(eventName,sender)
        if self._showType == SHOWTYPE.SPIRIT then
            self._showType = 1
        else
            self._showType = 2
        end
        switchView(true)
    end, CCControlEventTouchDown)

    self._rootnode["quickEquipBtn"]:setVisible(false)
    self._rootnode["heroSettingBtn"]:setVisible(false)

    -- 广播
    local broadcastBg = self._rootnode["broadcast_tag"]
    if broadcastBg ~= nil then
        if game.broadcast:getParent() ~= nil then 
            game.broadcast:removeFromParentAndCleanup(true)
        end
        broadcastBg:addChild(game.broadcast)
    end

--  切换视图
    switchView()
    self:request()
end


--进入界面时候的请求
function EnemyFormScene:request()

    local reqs = {}

    --请求阵容
    table.insert(reqs, RequestInfo.new({
        modulename = "fmt",
        funcname   = "list",
        param      = {acc2 = self._enemyID},
        oklistener = function(data)

            dump(data)

            self._cardList = data["1"]
            self._equip = data["2"]
            self._spirit = data["3"]

        end
    }))

    RequestHelperV2.request2(reqs, function()
        self:update()
    end)
end


function EnemyFormScene:refreshHero(index)
    printf("refreshHero")
    if self._formSettingView then
        self._formSettingView:removeSelf()
        self._rootnode["touchNode"]:setTouchEnabled(true)
        self._formSettingView = nil
    end

    if index > #self._cardList then
--        self:onPartnerView()
        return
    end
    self._rootnode["bottomInfoView"]:setVisible(true)
    self._rootnode["partnerView"]:setVisible(false)
    self._rootnode["heroInfoView"]:setVisible(true)

    local hero = self._cardList[index]

    if hero then
--名字
        self._rootnode["nameLabel"]:setString(hero.name)
        self._rootnode["nameLabel"]:setColor(NAME_COLOR[hero.star])
--图像
        local heroImg = ResMgr.getCardData(hero.resId)["arr_body"][hero.cls + 1]
        local heroPath = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getLargeImage(heroImg, ResMgr.HERO))
        self._rootnode["heroImg"]:setDisplayFrame(display.newSprite(heroPath):getDisplayFrame())
--等级
        self._rootnode["currentLevelLabel"]:setString(tostring(hero["level"]))
        self._rootnode["maxLevelLabel"]:setString(tostring(hero["levelLimit"]))
--属性
        self._rootnode["hpLabel"]:setString(tostring(hero.base[1]))
        self._rootnode["atkLabel"]:setString(tostring(hero.base[2]))
        self._rootnode["defLabel1"]:setString(tostring(hero.base[3]))
        self._rootnode["defLabel2"]:setString(tostring(hero.base[4]))
--领导力

        for k, v in ipairs(hero.lead) do
            self._rootnode[string.format("leadLabel_%d", k)]:setString(tostring(v))
        end
--羁绊
        if ResMgr.getCardData(hero.resId).fate1 then
            for k, v in ipairs(ResMgr.getCardData(hero.resId).fate1) do
                if k > 6 then
                    return
                end
                local jbKey = string.format("jbLabel_%d", k)
                self._rootnode[jbKey]:setVisible(true)
                self._rootnode[jbKey]:setString(data_jiban_jiban[v].name)
                self._rootnode[jbKey]:setColor(ccc3(119, 119, 119))
                for i, j in ipairs(hero.relation) do
                    if v == j then
                        self._rootnode[jbKey]:setColor(ccc3(255, 108, 0))
                    end
                end
            end
        end

        local function refreshSpiritIcon()
            for k = 1, #(getDataOpen(12).level) do
                local spiritNodeName = "spiritNode_" .. tostring(k)
                self._rootnode[spiritNodeName]:removeChildByTag(100, true)
            end

            for k, v in ipairs(self._spirit[index]) do
                local spiritNodeName = "spiritNode_" .. tostring(v.subpos - 6)
                local s = display.newSprite("#spirit_jy_anim.png")
                s:setPosition(self._rootnode[spiritNodeName]:getContentSize().width / 2, self._rootnode[spiritNodeName]:getContentSize().height / 2)
                self._rootnode[spiritNodeName]:addChild(s, 100, 100)

                local lvBg = display.newSprite("#spirit_jy_icon_num.png")
                lvBg:setPosition(s:getContentSize().width, lvBg:getContentSize().height / 2)
                s:addChild(lvBg)

                local label = ui.newTTFLabel({
                    text =  data_item_item[v.resId].name,
                    size = 22,
                    font = FONTS_NAME.font_fzcy,
                    color = NAME_COLOR[data_item_item[v.resId].quality]
                })
                label:setPosition(s:getContentSize().width / 2, -label:getContentSize().height / 2)
                s:addChild(label)

                label = ui.newTTFLabel({
                    text =  string.format("%d", v.level),
                    size = 22,
                    font = FONTS_NAME.font_fzcy,

                })
                label:setPosition(lvBg:getContentSize().height / 3.5, label:getContentSize().height * 0.75)
                lvBg:addChild(label)
            end
        end

        local function refreshEquipIcon()
            for k = 1, 6 do
                local equipNodeName = "equipBtn_" .. tostring(k)
                self._rootnode[equipNodeName]:removeChildByTag(100, true)
            end

            for k, v in ipairs(self._equip[index]) do
                local equipNodeName = "equipBtn_" .. tostring(v.subpos)

                local path = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getIconImage( data_item_item[v.resId].icon, ResMgr.EQUIP))
                local s = ResMgr.getIconSprite( {id = v.resId, resType = ResMgr.EQUIP, hasCorner=true})--display.newSprite(path)
                s:setPosition(self._rootnode[equipNodeName]:getContentSize().width / 2, self._rootnode[equipNodeName]:getContentSize().height / 2)
                self._rootnode[equipNodeName]:addChild(s, 100, 100)

                local label = ui.newTTFLabelWithOutline({
                    text =  data_item_item[v.resId].name,
                    size = 22,
                    font = FONTS_NAME.font_fzcy,
                    align = ui.TEXT_ALIGN_CENTER,
                    color = NAME_COLOR[data_item_item[v.resId].quality]
                })
                label:setPosition(s:getContentSize().width / 2, -label:getContentSize().height / 2)
                s:addChild(label)

                label = ui.newTTFLabel({
                    text =  string.format("%d", v.level),
                    size = 22,
                    font = FONTS_NAME.font_fzcy,
                    x = 15,
                    y = s:getContentSize().height-15
                })
                s:addChild(label)

            end
        end

        if self._showType == SHOWTYPE.SPIRIT then
            refreshSpiritIcon()
        else
            refreshEquipIcon()
        end

    end
end

function EnemyFormScene:resetHeadData()


    self._headData = {}
    --  根据数据插入数据
    for k, v in ipairs(self._cardList) do
        table.insert(self._headData, v)

    end
end

function EnemyFormScene:initHeadList()

    self:resetHeadData()

    if self._scrollItemList then
        self._scrollItemList:reloadData()
        return
    end

    self._scrollItemList = require("utility.TableViewExt").new({
        size        = CCSizeMake(self._rootnode["headList"]:getContentSize().width, self._rootnode["headList"]:getContentSize().height),
        createFunc  = function(idx)
            idx = idx + 1
            local item = HeroIcon.new()
            return item:create({
                viewSize = self._rootnode["headList"]:getContentSize(),
                itemData = self._headData[idx],
                idx      = idx,
            })

        end,
        refreshFunc = function(cell, idx)
            idx = idx + 1
            cell:refresh({
                idx = idx,
                itemData = self._headData[idx],
            })
        end,
        cellNum   = #self._headData,
        cellSize    = HeroIcon.new():getContentSize(),
        touchFunc = function(cell)
            local idx = cell:getIdx() + 1
            self._rootnode["touchNode"]:setTouchEnabled(true)


            if type(self._headData[idx]) == "table" then
                self._index = idx
                self:refreshHero(idx)
            end
        end
    })
    self._scrollItemList:setPosition(0, 0)
    self._rootnode["headList"]:addChild(self._scrollItemList)
end

function EnemyFormScene:initTouchNode()
    local touchNode = self._rootnode["touchNode"]
    touchNode:setTouchEnabled(true)

    local currentNode
    local targPosX, targPosY

    local function moveToTargetPos()
        currentNode:runAction(CCMoveTo:create(0.2, ccp(targPosX, targPosY)))
    end

    local function resetHeroImage(side)
        if side  == 1 then --左滑动
            currentNode:setPosition(display.width * 1.5, targPosY)
        elseif side == 2 then  --右滑动
            currentNode:setPosition(-display.width * 0.5, targPosY)
        end
        currentNode:runAction(CCMoveTo:create(0.2, ccp(targPosX, targPosY)))
    end

    local offsetX = 0
--    local bTouch
    local function onTouchBegan(event)

        local sz = touchNode:getContentSize()
        if (CCRectMake(0, 0, sz.width, sz.height):containsPoint(touchNode:convertToNodeSpace(ccp(event.x, event.y)))) then
            currentNode = self._rootnode["heroImg"]

            targPosX, targPosY = currentNode:getPosition()
            offsetX = event.x
--            bTouch = true
            return true
        end
        return false
    end

    local function onTouchMove(event)
        local posX, posY = currentNode:getPosition()
        currentNode:setPosition(posX + event.x - event.prevX, posY)
    end

    local function onTouchEnded(event)
        offsetX = event.x - offsetX
        if offsetX >= MOVE_OFFSET  then
            if self._index > 1 then
                self._index = self._index - 1
                self:refreshHero(self._index)
                resetHeroImage(2)
            else
                moveToTargetPos()
            end
        elseif offsetX <= -MOVE_OFFSET then
            if self._index < #self._cardList then
                self._index = self._index + 1
                self:refreshHero(self._index)
                resetHeroImage(1)
            else
                moveToTargetPos()
            end
        else
            moveToTargetPos()
        end
    end

    touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return onTouchBegan(event)
        elseif event.name == "moved" then
            onTouchMove(event)
        elseif event.name == "ended" then
            onTouchEnded(event)
        end
    end)
end

function EnemyFormScene:update()
    self:refreshHero(1)
    self:initHeadList()
    self:initTouchNode()
end

function EnemyFormScene:onEnter()
    game.runningScene = self
     -- 广播
    if self._bExit then
        local broadcastBg = self._rootnode["broadcast_tag"] 
        if game.broadcast:getParent() ~= nil then 
            game.broadcast:removeFromParentAndCleanup(true)
        end
        broadcastBg:addChild(game.broadcast)
    end
    
    if self._bExit and self._formSettingView == nil then
        self._bExit = false
        self:refreshHero(self._index)
    end

end
--
function EnemyFormScene:onExit()
    self._bExit = true
end
--
return EnemyFormScene

