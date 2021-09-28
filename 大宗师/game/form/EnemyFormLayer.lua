--
--                   _ooOoo_
--                  o8888888o
--                  88" . "88
--                  (| -_- |)
--                  O\  =  /O
--               ____/`---'\____
--             .'  \\|     |//  `.
--            /  \\|||  :  |||//  \
--           /  _||||| -:- |||||-  \
--           |   | \\\  -  /// |   |
--           | \_|  ''\---/''  |   |
--           \  .-\__  `-`  ___/-. /
--         ___`. .'  /--.--\  `. . __
--      ."" '<  `.___\_<|>_/___.'  >'"".
--     | | :  `- \`.;`\ _ /`;.`/ - ` : | |
--     \  \ `-.   \_ __\ /__ _/   .-` /  /
--======`-.____`-.___\_____/___.-`____.-'======
--                   `=---='
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--                 Buddha bless
--
-- 日期：14-10-1
--
--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-10
-- Time: 上午11:35
-- To change this template use File | Settings | File Templates.
--


require("utility.BottomBtnEvent")
local data_jiban_jiban = require("data.data_jiban_jiban")
local data_shentong_shentong = require("data.data_shentong_shentong")
local data_talent_talent = require("data.data_talent_talent")
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

function HeroIcon:selected()
    self._lightBoard:setVisible(true)
end

function HeroIcon:unselected()
    self._lightBoard:setVisible(false)
end

function HeroIcon:create(param)
    local _viewSize = param.viewSize
    local _itemData  = param.itemData

    self._heroIcon = display.newSprite("#zhenrong_equip_hero_bg.png")
    self:addChild(self._heroIcon)
    self._heroIcon:setPosition(self._heroIcon:getContentSize().width / 2, _viewSize.height / 2)

    self._lightBoard = display.newSprite("#zhenrong_select_board.png")
    self._lightBoard:setPosition(self._heroIcon:getContentSize().width / 2, _viewSize.height / 2)
    self:addChild(self._lightBoard)

    self._lightBoard:setVisible(false)
    self:refresh(param)
    return self
end

function HeroIcon:refresh(param)
    local _itemData  = param.itemData
    if param.idx == param.index then
        self:selected()
    else
        self:unselected()
    end

    if type(_itemData) == "number" then

    else
        self._heroIcon:setVisible(true)
        ResMgr.refreshIcon({itemBg = self._heroIcon, cls = _itemData.cls, id = param.itemData.resId, resType = ResMgr.HERO})
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

local EnemyFormLayer = class("EnemyFormLayer", function()
    return require("utility.ShadeLayer").new()
end)

local SHOWTYPE = {
    FORMATION = 1,
    SPIRIT    = 2
}

local ST_COLOR = {
    ccc3(255, 38, 0),
    ccc3(43, 164, 45),
    ccc3(28, 94, 171),
    ccc3(218, 129, 29)
}

function EnemyFormLayer:ctor(showType, enemyID, closeFunc, guidName)
    self:setNodeEventEnabled(true)
    self._enemyID = enemyID
    self._guidName = guidName
    self._index = 1
    if showType == SHOWTYPE.SPIRIT then
        self._showType = 2
    else
        self._showType = 1
    end

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("formation/formation_layer.ccbi", proxy, self._rootnode)
    node:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
    self:addChild(node, 1)

    local bgSprite = display.newSprite("bg/formation_bg.jpg")
    bgSprite:setPosition(self._rootnode["bgNode"]:getContentSize().width / 2, self._rootnode["bgNode"]:getContentSize().height / 2)
    bgSprite:setScaleX(self._rootnode["bgNode"]:getContentSize().width / bgSprite:getContentSize().width)
    bgSprite:setScaleY(self._rootnode["bgNode"]:getContentSize().height / bgSprite:getContentSize().height)
    self._rootnode["bgNode"]:addChild(bgSprite)
--
--    local tmpY = self._rootnode["headList"]:getPositionY()
--    self._rootnode["headList"]:setPosition(display.cx - self._rootnode["headList"]:getContentSize().width / 2, tmpY)
    
    -- 查看对方阵容，可以看到真气
    self._rootnode["spiritAndEquipBtn"]:setVisible(true)

    local function refreshBtnText()
        if self._showType == SHOWTYPE.SPIRIT then
            self._rootnode["spiritAndEquipBtn"]:setBackgroundSpriteForState(display.newScale9Sprite("#zhenrong_btn_equip.png"), CCControlStateNormal)
        else
            self._rootnode["spiritAndEquipBtn"]:setBackgroundSpriteForState(display.newScale9Sprite("#zhenrong_btn_zhenqi.png"), CCControlStateNormal)
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

    self._rootnode["closeBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        if closeFunc ~= nil then 
            closeFunc() 
        end 
        self:removeSelf()
    end, CCControlEventTouchDown)

    self._rootnode["spiritAndEquipBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if self._showType == SHOWTYPE.SPIRIT then
            self._showType = 1
        else
            self._showType = 2
        end
        switchView(true)
    end, CCControlEventTouchDown)

    --  切换视图
    switchView()
    self:initEquip()

    self:request()
end

function EnemyFormLayer:refreshSpiritNode()
    local _level = self._enemyInfo.level
    for k, v in ipairs(getDataOpen(12).level) do
        if v <= _level then
            self._rootnode["spiritLock_" .. tostring(k)]:setVisible(false)
            local spiritNodeName = "spiritNode_" .. tostring(k)
            local s = display.newSprite("#zhenrong_add.png")
            s:setPosition(self._rootnode[spiritNodeName]:getContentSize().width / 2, self._rootnode[spiritNodeName]:getContentSize().height / 2)
            self._rootnode[spiritNodeName]:addChild(s)
        end
    end
end


--进入界面时候的请求
function EnemyFormLayer:request()

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



            self._enemyInfo = {
                level = data["1"][1]["level"],
                cls = data["1"][1]["cls"],
                name = data["1"][1]["name"],
                group = data["4"] or ""
            }

        end
    }))

    RequestHelperV2.request2(reqs, function()
        self:update()
    end)
end


function EnemyFormLayer:refreshHero(index, bScrollHead)

    if bScrollHead then
        if (self._index - 1) * 115 < math.abs(self._scrollItemList:getContentOffset().x) then
            self._scrollItemList:setContentOffset(ccp(-(self._index - 1) * 115, 0), true)
        elseif self._index * 115 > (math.abs(self._scrollItemList:getContentOffset().x) + self._scrollItemList:getContentSize().width) then
            self._scrollItemList:setContentOffset(ccp(-(self._index) * 115 + self._scrollItemList:getContentSize().width, 0), true)
        end
    end

    self._rootnode["bottomInfoView"]:setVisible(true)
    self._rootnode["heroInfoView"]:setVisible(true)

    local hero = self._cardList[index]

    HeroSettingModel.cardIndex = index
    HeroSettingModel.setEnemyList(self._cardList,self._equip)

    if hero then
        for i = 1, 6 do
            local cell = self._scrollItemList:cellAtIndex(i - 1)
            if cell then
                if i == index then
                    cell:selected()
                else
                    cell:unselected()
                end
            end
        end

        --名字
        self._rootnode["nameLabel"]:setString(hero.name)
        self._rootnode["nameLabel"]:setColor(NAME_COLOR[hero.star])

        local card = ResMgr.getCardData(hero.resId)
        self._rootnode["jobSprite"]:setVisible(true)
        self._rootnode["jobSprite"]:setDisplayFrame(display.newSpriteFrame(string.format("zhenrong_job_%d.png", card.job)))
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

        for i = 1, 5 do
            self._rootnode["heroStar_" .. tostring(i)]:setVisible(false)

            if i <= 4 then
                self._rootnode["heroStar_2_" .. tostring(i)]:setVisible(false)
            end
        end

        for i = 1, hero.star do
            if hero.star == 4 or hero.star == 2 then
                self._rootnode["heroStar_2_" .. tostring(i)]:setVisible(true)
            else
                self._rootnode["heroStar_" .. tostring(i)]:setVisible(true)
            end
        end

        if hero.cls > 0 then
            self._rootnode["clsLabel"]:setVisible(true)
            self._rootnode["clsLabel"]:setString("+" .. tostring(hero.cls))
        else
            self._rootnode["clsLabel"]:setVisible(false)
        end
        --
        --        dump(hero.shenLvAry)
        if card.talent then
            for k, v in ipairs(card.talent) do
                local stData = data_shentong_shentong[v]
                if hero.shenLvAry[k] then

                    local tid
                    if hero.shenLvAry[k] == 0 then
                        tid = stData.arr_talent[hero.shenLvAry[k] + 1]
                    else
                        tid = stData.arr_talent[hero.shenLvAry[k]]
                    end

                    local talent = data_talent_talent[tid]
                    if talent then
--                        self._rootnode["stIconSprite_" .. tostring(k)]:setVisible(true)
--                        self._rootnode["stIconSprite_" .. tostring(k)]:setDisplayFrame(display.newSpriteFrame(string.format("zhenrong_st_%d.png", stData.type)))

                        self._rootnode["stNameLabel_" .. tostring(k)]:setString(talent.name)
                        self._rootnode["leadLabel_" .. tostring(k)]:setString(tostring(hero.shenLvAry[k]))

                        if hero.shenLvAry[k] > 0 then
                            self._rootnode["stNameLabel_" .. tostring(k)]:setColor(ST_COLOR[stData.type])
                            self._rootnode["leadLabel_" .. tostring(k)]:setColor(ST_COLOR[stData.type])
--                            self._rootnode["stIconSprite_" .. tostring(k)]:setColor(ccc3(255, 255, 255))
                        else
                            self._rootnode["stNameLabel_" .. tostring(k)]:setColor(ccc3(127, 127, 127))
                            self._rootnode["leadLabel_" .. tostring(k)]:setColor(ccc3(127, 127, 127))
--                            self._rootnode["stIconSprite_" .. tostring(k)]:setColor(ccc3(127, 127, 127))
                        end
                    else
                        show_tip_label("此神通不存在 " .. tostring(tid))
                    end

                end
            end
        end

        for i = 1, 6 do
            local jbKey = string.format("jbLabel_%d", i)
            self._rootnode[jbKey]:setVisible(false)
        end

        --羁绊
        if card.fate1 then
            for k, v in ipairs(card.fate1) do
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
                self._rootnode["spiritBtn_" .. tostring(k)]:setOpacity(255)
                self._rootnode[spiritNodeName]:removeChildByTag(100, true)
            end

            for k, v in ipairs(self._spirit[index]) do
                local spiritNodeName = "spiritNode_" .. tostring(v.subpos - 6)
                local s = require("game.Spirit.SpiritIcon").new({
                    id = v._id,
                    resId = v.resId,
                    lv = v.level,
                    exp = v.curExp or 0,
                    bShowName = true,
                    bShowLv = true,
                    offsetY = 8
                })
                s:setPosition(self._rootnode[spiritNodeName]:getContentSize().width / 2, self._rootnode[spiritNodeName]:getContentSize().height / 2 - 12)
                self._rootnode[spiritNodeName]:addChild(s, 100, 100)

                self._rootnode["spiritBtn_" .. tostring(v.subpos - 6)]:setOpacity(0)
            end
        end

        local function refreshEquipIcon()
            for k = 1, 6 do
                local equipNodeName = "equipNode_" .. tostring(k)
                self._rootnode[equipNodeName]:removeChildByTag(100, true)
            end

            for k, v in ipairs(self._equip[index]) do
                local equipNodeName = "equipNode_" .. tostring(v.subpos)
                local equipBaseInfo = data_item_item[v.resId]
                local path = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getIconImage( equipBaseInfo.icon, ResMgr.EQUIP))
                local s = ResMgr.getIconSprite( {id = v.resId, resType = ResMgr.EQUIP, hasCorner=true})--display.newSprite(path)
                s:setPosition(self._rootnode[equipNodeName]:getContentSize().width / 2, self._rootnode[equipNodeName]:getContentSize().height / 2)
                self._rootnode[equipNodeName]:addChild(s, 100, 100)

                if equipBaseInfo.Suit then
                    local quas = {"","pinzhikuangliuguang_lv","pinzhikuangliuguang_lan","pinzhikuangliuguang_zi","pinzhikuangliuguang_jin"}
                    local holoName = quas[equipBaseInfo.quality]

                    local suitArma = ResMgr.createArma({
                        resType = ResMgr.UI_EFFECT,
                        armaName = holoName,
                        isRetain = true
                    })
                    suitArma:setPosition(s:getContentSize().width / 2, s:getContentSize().height / 2)
                    s:addChild(suitArma)
                end

                local label = ui.newTTFLabelWithOutline({
                    text =  data_item_item[v.resId].name,
                    size = 22,
                    font = FONTS_NAME.font_fzcy,
                    align = ui.TEXT_ALIGN_CENTER,
                    color = NAME_COLOR[data_item_item[v.resId].quality]
                })
                label:setPosition(s:getContentSize().width / 2, -label:getContentSize().height / 2)
                s:addChild(label)

                label = ui.newTTFLabelWithOutline({
                    text =  string.format("%d",  v.level),
                    size = 22,
                    font = FONTS_NAME.font_fzcy,
                })
                s:addChild(label)
                label:setPosition(ccp(20 - label:getContentSize().width / 2, s:getContentSize().height - 14))

            end
        end

        if self._showType == SHOWTYPE.SPIRIT then
            refreshSpiritIcon()
        else
            refreshEquipIcon()
        end

    end
end

function EnemyFormLayer:resetHeadData()
    self._headData = {}
    --  根据数据插入数据
    for k, v in ipairs(self._cardList) do
        table.insert(self._headData, v)
    end
end

function EnemyFormLayer:initHeadList()

    self:resetHeadData()

    if self._scrollItemList then
        self._scrollItemList:reloadData()
        if #self._headData - self._index < self._index then
            self._scrollItemList:setContentOffset(ccp(self._scrollItemList:minContainerOffset().x, 0))
        end

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
                index    = self._index
            })

        end,
        refreshFunc = function(cell, idx)
            idx = idx + 1
            cell:refresh({
                idx = idx,
                itemData = self._headData[idx],
                index    = self._index
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
--    self._rootnode["headList"]:convertToWorldSpace(ccp(0, 0))
    self._scrollItemList:setPosition(ccp(0, 0))
    self._rootnode["headList"]:addChild(self._scrollItemList)
end

function EnemyFormLayer:initTouchNode()
    local touchNode = self._rootnode["touchNode"]
    touchNode:setTouchEnabled(true)

    local currentNode
    local targPosX, targPosY = self._rootnode["heroImg"]:getPosition()

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
--            targPosX, targPosY = currentNode:getPosition()
            offsetX = event.x
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
                self:refreshHero(self._index, true)
                resetHeroImage(2)
            else
                moveToTargetPos()
            end
        elseif offsetX <= -MOVE_OFFSET then
            if self._index < #self._cardList then
                self._index = self._index + 1
                self:refreshHero(self._index, true)
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

function EnemyFormLayer:initEquip()

    local function onIcon(tag, info)
        if tag < 5 then
            if info then
                self:setVisible(false)
                local layer = require("game.Equip.CommonEquipInfoLayer").new({
                    index = self._index,
                    subIndex = tag,
                    info = info,
                    bEnemy = true,
                    closeListener = function()
                        self:setVisible(true)
                    end
                })
                game.runningScene:addChild(layer, self:getZOrder() + 1)
            else
                printf("数据为空")
            end
        else
            if info then
                self:setVisible(false)
                local layer = require("game.skill.BaseSkillInfoLayer").new({
                    index = self._index,
                    subIndex = tag,
                    info = info,
                    bEnemy = true,
                    closeListener = function()
                        self:setVisible(true)
                    end
                })
                game.runningScene:addChild(layer, self:getZOrder() + 1)
            else
                printf("数据为空")
            end
        end
    end
    --
    local function onClick(tag)
        local bChangeScene = true
        for k, v in ipairs(self._equip[self._index]) do
            if v.subpos == tag then
                onIcon(tag, v)
                return
            end
        end
    end

    for i = 1, 6 do
        local key = "equipBtn_" .. tostring(i)
        self._rootnode[key]:setTouchEnabled(true)
        self._rootnode[key]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            if event.name == "began" then
                PostNotice(NoticeKey.REMOVE_TUTOLAYER)
                onClick(i)
            end
        end)
    end
end

function EnemyFormLayer:initSpirit()

    local function onSpiritIcon(spiritData, tag)
        local descLayer = require("game.Spirit.SpiritInfoLayer").new(4, spiritData)
        self:addChild(descLayer, 2)
    end

    local function onClick(tag)
        for k, v in ipairs(self._spirit[self._index]) do
            if v.subpos - 6 == tag then
                onSpiritIcon(v, tag)
                break
            end
        end
    end

    for i = 1, 8 do
        self._rootnode["spiritBtn_" .. tostring(i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onClick)
    end
end

function EnemyFormLayer:update()

    local teamName = ""


    if #self._enemyInfo.group > 0 then
        teamName = string.format("  [%s]", self._enemyInfo.group)
    end

    local nameLabel = ui.newTTFLabelWithOutline({
        text =  tostring(self._enemyInfo.name) .. teamName,
        size = 26,
        font = FONTS_NAME.font_haibao,
        align = ui.TEXT_ALIGN_CENTER,
        color = ccc3(255, 234, 0)
    })

    self._rootnode["titleNameLabel"]:addChild(nameLabel)
    self:refreshSpiritNode()

    self:initHeadList()
    self:refreshHero(1)

    self:initSpirit()
    self:initTouchNode()
end

function EnemyFormLayer:onEnter()

end

function EnemyFormLayer:onExit()
    HeroSettingModel.restoreHeroList()
end

--
return EnemyFormLayer



