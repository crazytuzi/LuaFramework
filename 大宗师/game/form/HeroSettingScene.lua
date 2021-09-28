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
local data_item_item =  require("data.data_item_item")
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

function HeroIcon:getTutoBtn()
    return self.addSprite
end

function HeroIcon:create(param)
    local _viewSize = param.viewSize
    local _itemData  = param.itemData

    self._heroIcon = display.newSprite("#zhenrong_equip_hero_bg.png")
    self:addChild(self._heroIcon)
    self._heroIcon:setPosition(self._heroIcon:getContentSize().width / 2, _viewSize.height / 2)

    self._actIcon = display.newSprite("#zhenrong_lock_bg.png")
    self:addChild(self._actIcon)
    self._actIcon:setPosition(self._actIcon:getContentSize().width / 2, _viewSize.height / 2)

    local label = ui.newTTFLabel({
        text = "",
        size = 18,
        font = FONTS_NAME.font_fzcy,
        color = ccc3(155, 155, 155)
    })
    label:setPosition(self._actIcon:getContentSize().width / 2, self._actIcon:getContentSize().height * 0.3)
    self._actIcon:addChild(label)
    label:setTag(1)

    local addSprite = display.newSprite("#zhenrong_add.png")
    addSprite:setPosition(self._actIcon:getContentSize().width / 2, self._actIcon:getContentSize().height / 2)
    self._actIcon:addChild(addSprite)
    addSprite:setTag(2)

    self.addSprite = self._heroIcon--addSprite


    self._lightBoard = display.newSprite("#zhenrong_select_board.png")
    self._lightBoard:setPosition(self._heroIcon:getContentSize().width / 2, _viewSize.height / 2)
    self:addChild(self._lightBoard)


    self._lightBoard:setVisible(false)
    self:refresh(param)
    return self
end

function HeroIcon:selected()
    self._lightBoard:setVisible(true)
end

function HeroIcon:unselected()
    self._lightBoard:setVisible(false)
end

function HeroIcon:refresh(param)
    local _itemData  = param.itemData

    self._heroIcon:setVisible(false)
    self._actIcon:setVisible(false)

    if param.idx == param.index then
        self:selected()
    else
        self:unselected()
    end

    if type(_itemData) == "number" then
        self._actIcon:setVisible(true)

        self._actIcon:getChildByTag(1):setVisible(false)
        self._actIcon:getChildByTag(2):setVisible(false)

        if _itemData > 0 then
            self._actIcon:setDisplayFrame(display.newSpriteFrame("zhenrong_lock_bg.png"))
            self._actIcon:getChildByTag(1):setVisible(true)
            self._actIcon:getChildByTag(1):setString(string.format("%d级开放", _itemData))
        elseif _itemData == 0 then
            self._actIcon:setDisplayFrame(display.newSpriteFrame("zhenrong_equip_hero_bg.png"))
            self._actIcon:getChildByTag(2):setVisible(true)
            self._actIcon:getChildByTag(2):setPosition(self._actIcon:getContentSize().width / 2, self._actIcon:getContentSize().height / 2)
        else

        end
    else
        self._heroIcon:setVisible(true)
        ResMgr.refreshIcon({itemBg = self._heroIcon, cls = _itemData.cls, id = param.itemData.resId, resType = ResMgr.HERO})
    end
end

local MOVE_OFFSET = display.width / 3
local HeroSettingScene = class("HeroSettingScene", function()
    return display.newScene("HeroSettingScene")
end)

local SHOWTYPE = {
    FORMATION = 1,
    SPIRIT    = 2
}

local function getDataOpen(sysID)
    local data_open_open = require("data.data_open_open")
    for k, v in ipairs(data_open_open) do

        if sysID == v.system then
            return v
        end
    end
end

function HeroSettingScene:ctor(showType)
    local bg = display.newSprite("bg/formation_bg.jpg")
    bg:setPosition(display.cx, display.cy)
    bg:setScaleX(display.width/bg:getContentSize().width)
    bg:setScaleY((display.height - 295) / bg:getContentSize().height)
    self:addChild(bg, 0)

    game.runningScene = self

    self._bRequest = false


    ResMgr.createBefTutoMask(self)

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
    -- 高亮选择中的底部按钮
    local items = {"mainSceneBtn", "formSettingBtn", "battleBtn", "activityBtn", "bagBtn", "shopBtn"}
    for k,v in pairs(G_BOTTOM_BTN) do
        if(GameStateManager.currentState == v and GameStateManager.currentState > 2) then            
            self._rootnode[items[k]]:selected()
            break
        end
    end

    self.namebgY = self._rootnode["hero_name_bg"]:getPositionY()
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

    self._rootnode["spiritAndEquipBtn"]:addHandleOfControlEvent(function(eventName,sender)

        if self._showType == SHOWTYPE.SPIRIT then
            self._showType = 1
        else
            self._showType = 2
        end
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        switchView(true)
    end, CCControlEventTouchDown)

    self._rootnode["quickEquipBtn"]:addHandleOfControlEvent(function(eventName, sender)
        -- if game.player:getLevel() < 11 then
        --     show_tip_label("此功能11级开放")
        --     return
        -- end

        local t
        if self._showType == SHOWTYPE.SPIRIT then
            t = 1
        else
            t = 0
        end

        RequestHelper.formation.quickEquip({
            pos = self._index,
            cardId = self._cardList[self._index].resId,
            type = t,
            errback = function() 
                PostNotice(NoticeKey.REMOVE_TUTOLAYER)
            end, 
            callback = function(data)

                self:resetFormData(data)
                self:refreshHero(self._index)
                PostNotice(NoticeKey.REMOVE_TUTOLAYER)
                if t == 1 then

                    for k, v in ipairs(game.player:getSpirit()) do
                        if v.pos == self._index or v.cid == self._cardList[self._index].resId then
                            v.pos = 0
                            v.cid = 0
                        end
                    end

                    for k, v in ipairs(self._spirit[self._index]) do

                        local spirit = self:getSpiritByID(v.objId)
                        if spirit then
                            spirit.pos = v.pos
                            spirit.cid = self._cardList[self._index].resId
                        end
                    end
                else
                    for k, v in ipairs(game.player:getEquipments()) do

                        if v.pos == self._index then
                            v.pos = 0
                            v.cid = 0
                        end
                    end

                    for k, v in ipairs(game.player:getSkills()) do
                        dump(v)
                        if v.pos == self._index then
                            v.pos = 0
                            v.cid = 0
                        end
                    end

                    for k, v in ipairs(self._equip[self._index]) do
                        local equip
                        if v.subpos == 5 or v.subpos == 6 then
                            equip = self:getSkillByID(v.objId)
                        else
                            equip = self:getEquipByID(v.objId)
                        end

                        if equip then
                            equip.pos = v.pos
                            equip.cid = self._cardList[self._index].resId
                        end
                    end
                end
            end
        })

        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end, CCControlEventTouchDown)

    self._rootnode["heroSettingBtn"]:addHandleOfControlEvent(function(eventName, sender)
        self:setForm()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end, CCControlEventTouchDown)

    self._rootnode["changeHeroBtn"]:addHandleOfControlEvent(function()
        self:performWithDelay(function()
            push_scene(require("game.form.HeroChooseScene").new({
                index = self._index,
                callback = function(data)
                    self:resetFormData(data)
                    self:initHeadList()
                end
            }))
        end, 0.12)

    end, CCControlEventTouchUpInside)

    -- 广播
    local broadcastBg = self._rootnode["broadcast_tag"]
    if broadcastBg ~= nil then
        if game.broadcast:getParent() ~= nil then 
            game.broadcast:removeFromParentAndCleanup(true)
        end
        broadcastBg:addChild(game.broadcast)
    end

    if self._rootnode["nowTimeLabel"] then
        self._rootnode["nowTimeLabel"]:setString(GetSystemTime())
        self._rootnode["nowTimeLabel"]:schedule(function()
            self._rootnode["nowTimeLabel"]:setString(GetSystemTime())
        end, 60)
    end

    self:initTouchNode()
    self:initSpirit()
    self:initEquip()

--  切换视图
    switchView()
    addbackevent(self)
end

--设置阵法界面
function HeroSettingScene:setForm()

    if  self._formSettingView then
        return
    end

    self._rootnode["heroInfoView"]:setVisible(false)
    self._rootnode["bottomInfoView"]:setVisible(false)
    self._rootnode["touchNode"]:setTouchEnabled(false)

    local formCtrl = require("game.form.FormCtrl")
    self._formSettingView = formCtrl.createFormSettingLayer({
        parentNode   = self,
        touchEnabled = false,
        list         = self._cardList,
        sz           = CCSizeMake(display.width * 0.9, display.height - 297),
        pos          = ccp(display.cx, display.cy - 20),
        closeListener = function()
            self:refreshHero(self._index)
            self._rootnode["touchNode"]:setTouchEnabled(true)
            self._formSettingView = nil
        end,
        callback     = handler(self, HeroSettingScene.resetFormData)
    })

end

function HeroSettingScene:regLockNotice()
    -- print("talbldexxonenter")
        RegNotice(self,
        function()
            -- print("llllooooockkktable")
            -- self:setTouchEnabled(false)   
            self:setHeroScrollDisabled(true)   
        end,
        NoticeKey.LOCK_TABLEVIEW)

        RegNotice(self,
        function()
            -- print("unnnnnlllooockkktable")
            -- self:setTouchEnabled(true)   
            self:setHeroScrollDisabled(false)      
        end,
        NoticeKey.UNLOCK_TABLEVIEW)


end

function HeroSettingScene:setBottomBtnEnabled(bEnabled)
    ResMgr.isBottomEnabled = bEnabled
    BottomBtnEvent.setTouchEnabled(bEnabled) 
end

function HeroSettingScene:unLockNotice()
    UnRegNotice(self,NoticeKey.LOCK_TABLEVIEW)
    UnRegNotice(self,NoticeKey.UNLOCK_TABLEVIEW)
end

--进入界面时候的请求
function HeroSettingScene:request()
    local reqs = {}

    
    --请求装备
    table.insert(reqs, RequestInfo.new({
        modulename = "equip",
        funcname   = "list",
        param      = {},
        oklistener = function(data)
                    -- dump(data)
            game.player:setEquipments(data["1"])
        end
    }))
--
--    --请求精元
--    table.insert(reqs, RequestInfo.new({
--        modulename = "spirit",
--        funcname   = "list",
--        param      = {},
--        oklistener = function(data)
----            dump(data)
--            game.player:setSpirit(data["1"])
--            game.player:setSpiritBagMax(data["3"])
--        end
--    }))

    --请求英雄
    table.insert(reqs, RequestInfo.new({
        modulename = "hero",
        funcname   = "list",
        param      = {},
        oklistener = function(data)
--            dump(data["1"])
            game.player:setHero(data["1"])
        end
    }))

    --请求内外功
    table.insert(reqs, RequestInfo.new({
        modulename = "skill",
        funcname = "list",
        param = {},
        oklistener = function(data)
--            dump(data["1"])
            game.player:setSkills(data["1"])
        end
    }))

    RequestHelperV2.request2(reqs, function()
        --
        require("game.Spirit.SpiritCtrl").request()
--        self:update()
    end)

    dump(game.player.m_formation["3"])
    self._cardList = game.player.m_formation["1"]
    self._equip = game.player.m_formation["2"]
    self._spirit = game.player.m_formation["3"]

    self:update()
end

function HeroSettingScene:onAddHero()
    self._onAddHero = true
    self._rootnode["nameLabel"]:setString("")
    self._rootnode["jobSprite"]:setVisible(false)
    for i = 1, 5 do
        self._rootnode["heroStar_" .. tostring(i)]:setVisible(false)
    end

    --图像
    self._rootnode["heroImg"]:setDisplayFrame(display.newSpriteFrame("zhenrong_hero.png"))

    if self._rootnode["heroImg"]:getChildByTag(100) == nil then
        local heroNode = display.newSprite("#zhenrong_hero.png")
        heroNode:setPosition(self._rootnode["heroImg"]:getContentSize().width / 2, self._rootnode["heroImg"]:getContentSize().height / 2)
        self._rootnode["heroImg"]:addChild(heroNode)

        -- local label = display.newSprite("#zhenrong_select_label.png")
        -- label:setPosition(self._rootnode["heroImg"]:getContentSize().width / 2, self._rootnode["heroImg"]:getContentSize().height / 2)
        -- heroNode:addChild(label)

        heroNode:setTag(100)
        TutoMgr.addBtn("zhenrong_anniu_yinying",heroNode)
        TutoMgr.active()
        heroNode:setTouchEnabled(true)
        heroNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            if event.name == "began" then
                heroNode:setTouchEnabled(false)

                PostNotice(NoticeKey.REMOVE_TUTOLAYER)
                push_scene(require("game.form.HeroChooseScene").new({
                    callback = function(data)
                        self._onAddHero = false
                        if self._formSettingView then
                            self._formSettingView:removeSelf()
                            self._formSettingView = nil
                        end

                        if #self._cardList < #data["1"] then
                            self._index = #data["1"]
                        end

                        self:resetFormData(data)
                        self:initHeadList()
                    end,
                    closelistener = function()
                       self:onAddHero()
                    end
                }))
            end
        end)
    end

    --等级
    self._rootnode["currentLevelLabel"]:setString("0")
    self._rootnode["maxLevelLabel"]:setString("0")
    --属性
    self._rootnode["hpLabel"]:setString("")
    self._rootnode["atkLabel"]:setString("")
    self._rootnode["defLabel1"]:setString("")
    self._rootnode["defLabel2"]:setString("")
    self._rootnode["clsLabel"]:setString("")
    self._rootnode["levelNode"]:setVisible(false)
    --领导力

    for i = 1, 3 do
        self._rootnode[string.format("leadLabel_%d", i)]:setString("0")
    end
    --羁绊

    for i = 1, 6 do
        self._rootnode[string.format("jbLabel_%d", i)]:setString("")
    end

    for k = 1, 6 do
        local equipNodeName = "equipNode_" .. tostring(k)
        self._rootnode[equipNodeName]:removeChildByTag(100, true)
    end

    for k = 1, #(getDataOpen(12).level) do
        local spiritNodeName = "spiritNode_" .. tostring(k)
        self._rootnode[spiritNodeName]:removeChildByTag(100, true)
        self._rootnode["spiritBtn_" .. tostring(k)]:setOpacity(255)
    end

    for i = 1, 5 do
        self._rootnode["heroStar_" .. tostring(i)]:setVisible(false)

        if i <= 4 then
            self._rootnode["heroStar_2_" .. tostring(i)]:setVisible(false)
        end
    end
    self._rootnode["changeHeroBtn"]:setVisible(false)
    self:setBtnEnable(false)
end

function HeroSettingScene:setBtnEnable(b)
    self._rootnode["spiritAndEquipBtn"]:setEnabled(b)

--    self._rootnode["heroSettingBtn"]:setEnabled(b)
    for i = 1, 8 do
        self._rootnode["spiritBtn_" .. tostring(i)]:setEnabled(b)
    end
    for i = 1, 6 do
        local key = "equipBtn_" .. tostring(i)
        self._rootnode[key]:setTouchEnabled(b)
    end

    self._rootnode["touchNode"]:setTouchEnabled(b)
end

local ST_COLOR = {
    ccc3(255, 38, 0),
    ccc3(43, 164, 45),
    ccc3(28, 94, 171),
    ccc3(218, 129, 29)
}

function HeroSettingScene:refreshProp(hero)

    if false then
        local anim = {}
        if checknumber(self._rootnode["hpLabel"]:getString()) ~= hero.base[1] then
            local offset = hero.base[1] - checknumber(self._rootnode["hpLabel"]:getString())
            local str
            if offset > 0 then
                str = string.format("生命 +%d", offset)
            else
                str = string.format("生命 %d", offset)
            end
            table.insert(anim, str)
        end

        if checknumber(self._rootnode["atkLabel"]:getString()) ~= hero.base[2] then
            local offset = hero.base[2] - checknumber(self._rootnode["atkLabel"]:getString())
            local str
            if offset > 0 then
                str = string.format("攻击 +%d", offset)
            else
                str = string.format("攻击 %d", offset)
            end
            table.insert(anim, str)
        end

        if checknumber(self._rootnode["defLabel1"]:getString()) ~= hero.base[3] then
            local offset = hero.base[3] - checknumber(self._rootnode["defLabel1"]:getString())
            local str
            if offset > 0 then
                str = string.format("物防 +%d", offset)
            else
                str = string.format("物防 %d", offset)
            end
            table.insert(anim, str)
        end

        if checknumber(self._rootnode["defLabel2"]:getString()) ~= hero.base[4] then
            local offset = hero.base[4] - checknumber(self._rootnode["defLabel2"]:getString())
            local str
            if offset > 0 then
                str = string.format("法防 +%d", offset)
            else
                str = string.format("法防 %d", offset)
            end
            table.insert(anim, str)
        end
        if #anim > 0 then
            local act = {}
            for k, v in ipairs(anim) do
                table.insert(act, CCCallFunc:create(function()
                    show_tip_label(v)
                end))
                table.insert(act, CCDelayTime:create(1))
            end
            self:runAction(transition.sequence(act))
        end
        self._bInit = false
    end
    self._rootnode["hpLabel"]:setString(tostring(hero.base[1]))
    self._rootnode["atkLabel"]:setString(tostring(hero.base[2]))
    self._rootnode["defLabel1"]:setString(tostring(hero.base[3]))
    self._rootnode["defLabel2"]:setString(tostring(hero.base[4]))
end

function HeroSettingScene:isExistEquipByPos(pos)
    for k, v in ipairs(game.player:getEquipments()) do
        if pos == data_item_item[v.resId].pos then
            return true
        end
    end
    return false
end

function HeroSettingScene:refreshHero(index, bScrollHead)

    if bScrollHead then
        if (self._index - 1) * 115 < math.abs(self._scrollItemList:getContentOffset().x) then
            self._scrollItemList:setContentOffset(ccp(-(self._index - 1) * 115, 0), true)
        elseif self._index * 115 > (math.abs(self._scrollItemList:getContentOffset().x) + self._scrollItemList:getContentSize().width) then
            self._scrollItemList:setContentOffset(ccp(-(self._index) * 115 + self._scrollItemList:getContentSize().width, 0), true)
        end
    end

    self:setBtnEnable(true)
    self._rootnode["levelNode"]:setVisible(true)
    self._onAddHero = false
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
    self._rootnode["heroInfoView"]:setVisible(true)

    local hero = self._cardList[index]

    if hero then
        if index > 1 then
            self._rootnode["changeHeroBtn"]:setVisible(true)
        else
            self._rootnode["changeHeroBtn"]:setVisible(false)
        end
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
        local card = ResMgr.getCardData(hero.resId)
        self._rootnode["nameLabel"]:setString(hero.name)
        self._rootnode["nameLabel"]:setColor(NAME_COLOR[hero.star])
        self._rootnode["jobSprite"]:setVisible(true)
        self._rootnode["jobSprite"]:setDisplayFrame(display.newSpriteFrame(string.format("zhenrong_job_%d.png", card.job)))

        if hero.cls > 0 then
            self._rootnode["clsLabel"]:setVisible(true)
            self._rootnode["clsLabel"]:setString("+" .. tostring(hero.cls))
        else
            self._rootnode["clsLabel"]:setVisible(false)
        end

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

--图像
        local heroImg = card["arr_body"][hero.cls + 1]
        local heroPath = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getLargeImage(heroImg, ResMgr.HERO))
        self._rootnode["heroImg"]:setDisplayFrame(display.newSprite(heroPath):getDisplayFrame())

        if (display.widthInPixels / display.heightInPixels) > 0.67 then
            self._rootnode["heroImg"]:setScale(0.85)
            self._rootnode["hero_name_bg"]:setPosition(self._rootnode["hero_name_bg"]:getPositionX(),self.namebgY + self._rootnode["hero_name_bg"]:getContentSize().height/2)

            for i = 1, 8 do
                self._rootnode["equipNode_"..i]:setScale(0.85)
                self._rootnode["spiritNode_" .. i]:setScale(0.85)
                self._rootnode["equipBtn_" .. i]:setScale(0.85)
            end

        end

        local l = self._rootnode["heroImg"]:getChildByTag(100)
        if l then
            l:removeSelf()
        end
--等级
        self._rootnode["currentLevelLabel"]:setString(tostring(hero["level"]))
        self._rootnode["maxLevelLabel"]:setString(tostring(hero["levelLimit"]))
--属性

        self:refreshProp(hero)
--神通
        for i = 1, 3 do
            self._rootnode["stNameLabel_" .. tostring(i)]:setString("")
            self._rootnode["leadLabel_" .. tostring(i)]:setString("")
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
                        self._rootnode["stNameLabel_" .. tostring(k)]:setString(talent.name)
                        self._rootnode["leadLabel_" .. tostring(k)]:setString(tostring(hero.shenLvAry[k]))

                        if hero.shenLvAry[k] > 0 then
                            self._rootnode["stNameLabel_" .. tostring(k)]:setColor(ST_COLOR[stData.type])
                            self._rootnode["leadLabel_" .. tostring(k)]:setColor(ST_COLOR[stData.type])
                        else
                            self._rootnode["stNameLabel_" .. tostring(k)]:setColor(ccc3(127, 127, 127))
                            self._rootnode["leadLabel_" .. tostring(k)]:setColor(ccc3(127, 127, 127))
                        end
                    else
                        show_tip_label("此神通不存在 " .. tostring(tid))
                    end
                end
            end
        end
--羁绊
        for i = 1, 6 do
            local jbKey = string.format("jbLabel_%d", i)
            self._rootnode[jbKey]:setVisible(false)
        end
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
                printf("=====================")
                local equipNodeName = "equipNode_" .. tostring(k)
                self._rootnode[equipNodeName]:removeChildByTag(100, true)
            end
            --获得当前侠客的列表
            HeroSettingModel.cardIndex = index

            -- HeroSettingModel.equipList = self._equip[index]

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
                label:setPosition(s:getContentSize().width / 2, -label:getContentSize().height * 0.7)
                s:addChild(label)

                local obj
                if v.subpos == 5 or v.subpos == 6 then
                    obj = self:getSkillByID(v.objId) or {}
                else
                    obj = self:getEquipByID(v.objId) or {}
                end
                label = ui.newTTFLabelWithOutline({
                    text =  string.format("%d",  v.level or obj.level),
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

function HeroSettingScene:resetHeadData()
    local posOpen = getDataOpen(14)

    self._headData = self._headData or {}
    local index = 1
    for k, v in ipairs(posOpen.level) do
        if game.player:getLevel() >= v then
            if self._headData[index] then
                self._headData[index] = 0
            else
                table.insert(self._headData, 0)
            end
            index = index + 1
        end
    end

    --  插入下一级开放按钮
    if #self._headData < #posOpen.level then
        if self._headData[index] then
            self._headData[index] = posOpen.level[index]
        else
            table.insert(self._headData, posOpen.level[#self._headData + 1])
        end
    end

    --  插入小伙伴
    --    table.insert(self._headData, -1)

    --  根据数据插入数据
    for k, v in ipairs(self._cardList) do
        if 0 == self._headData[k] then
            self._headData[k] = v
        end
    end
end

function HeroSettingScene:initHeadList()

    self:resetHeadData()

    if self._scrollItemList then
        self._scrollItemList:reloadData()
        if #self._headData - self._index < self._index then
--            printf("============== min = %d, max = %d", self._scrollItemList:minContainerOffset().x, self._scrollItemList:maxContainerOffset().x)

            if self._scrollItemList:minContainerOffset().x > 0 then
                self._scrollItemList:setContentOffset(ccp(0, 0))
            else
                self._scrollItemList:setContentOffset(ccp(self._scrollItemList:minContainerOffset().x, 0))
            end

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
            PostNotice(NoticeKey.REMOVE_TUTOLAYER)
            local idx = cell:getIdx() + 1
            self._rootnode["touchNode"]:setTouchEnabled(true)

            if type(self._headData[idx]) == "table" then
                self._index = idx
                self:refreshHero(idx)
            else
--                if -1 == self._headData[idx] then
--                    self:onPartnerView()
--                else
                if 0 == self._headData[idx] then
                    self:onAddHero()
                else
                    show_tip_label(string.format("亲，%d级开放", self._headData[idx]))
                end
            end
        end
    })
    self._scrollItemList:setPosition(0, 0)
    self._rootnode["headList"]:addChild(self._scrollItemList)

    local cell
    -- for k,v in ipairs(self._headData) do
    --     if v == 0 then
            cell = self._scrollItemList:cellAtIndex(#self._headData - 2)
    --     end
    -- end

    if cell ~= nil then
        local btn = cell:getTutoBtn()
        TutoMgr.addBtn("zhenrongzhujiemian_btn_erhaowei", btn)
    end
    -- TutoMgr.active()
end

function HeroSettingScene:onPartnerView()
    self._rootnode["bottomInfoView"]:setVisible(false)
    self._rootnode["heroInfoView"]:setVisible(false)
end

function HeroSettingScene:initTouchNode()
    local touchNode = self._rootnode["touchNode"]
    touchNode:setTouchEnabled(true)

    local currentNode
    local targPosX, targPosY = self._rootnode["heroImg"]:getPosition()

    local function moveToTargetPos()
        currentNode:runAction(transition.sequence({
            CCMoveTo:create(0.2, ccp(targPosX, targPosY))
        }))
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
    local bTouch
    local function onTouchBegan(event)

        local sz = touchNode:getContentSize()
        if (CCRectMake(0, 0, sz.width, sz.height):containsPoint(touchNode:convertToNodeSpace(ccp(event.x, event.y)))) then
            currentNode = self._rootnode["heroImg"]
            offsetX = event.x
            bTouch = true
            return true
        end
        return false
    end

    local function onTouchMove(event)
        if self._bHeroScrollDisabled ~= true then
            local posX, posY = currentNode:getPosition()
            currentNode:setPosition(posX + event.x - event.prevX, posY)
        end

        if math.abs(event.x - event.prevX) > 8 then
            bTouch = false
        end

    end

    local function onTouchEnded(event)
        if self._bHeroScrollDisabled ~= true then
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
--
        if bTouch then
            PostNotice(NoticeKey.REMOVE_TUTOLAYER)

            require("game.Hero.HeroCtrl").createInfoLayer(self._cardList[self._index].objId, self._index, function(data)
                if data.shenIDAry then

                    for k, v in ipairs(data.shenIDAry) do
                        self._cardList[self._index].shenIDAry[k] = v
                        self._cardList[self._index].shenLvAry[k] = data.shenLvAry[k]
                    end
                end

                for k, v in ipairs(data["base"]) do
                    self._cardList[self._index].base[k] = v
                end
                self._cardList[self._index].level = data.level or data.lv or self._cardList[self._index].level
                self._cardList[self._index].cls = data.cls

                self:refreshHero(self._index)
            end,
            function(data)
                self:resetFormData(data)
                self:initHeadList()
            end)
--            local layer = require("game.Hero.HeroInfoLayer").new({
--                info = self._cardList[self._index],
--                index = self._index,
--                refreshHero = function(data)
--                    if data.shenIDAry then
--
--                        for k, v in ipairs(data.shenIDAry) do
--                            self._cardList[self._index].shenIDAry[k] = v
--                            self._cardList[self._index].shenLvAry[k] = data.shenLvAry[k]
--                        end
--                    end
--
--                    for k, v in ipairs(data["base"]) do
--                        self._cardList[self._index].base[k] = v
--                    end
--                    self._cardList[self._index].level = data.level or data.lv or self._cardList[self._index].level
--                    self._cardList[self._index].cls = data.cls
--
--                    self:refreshHero(self._index)
--                end,
--                changeHero = function(data)
--                    self:resetFormData(data)
--                    self:initHeadList()
--                end
--            }, 1)
--
--            self:addChild(layer, 100)
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

function HeroSettingScene:setHeroScrollDisabled(b)
    self._bHeroScrollDisabled = b
end
--
--function HeroSettingScene:setHero(pos, id)
--    RequestHelper.formation.set({
--        callback = function(data)
--            dump(data)
--            if #data["0"] > 0 then
--                -- dump(data)
--                show_tip_label(data["0"])
--            else
--                self:resetFormData(data)
--            end
--        end,
--        pos = pos,
--        id  = id
--    })
--end

function HeroSettingScene:resetFormData(data)
    -- dump(data)
    if(data ~= nil) then
        game.player.m_formation = data
        self._cardList = data["1"]
        self._equip = data["2"]
        self._spirit = data["3"]

        self._bInit = true
    end
end

function HeroSettingScene:initSpirit()

    local function showChooseScene(tag, filter, objId)

        push_scene(require("game.form.SpiritChooseScene").new({
            index = self._index,
            subIndex = tag + 6,
            cid      = self._cardList[self._index].resId,
            callback = handler(self, HeroSettingScene.resetFormData),
            filter   = filter,
            objId  = objId
        }))
    end

    local function onSpiritIcon(spiritData, tag, filter)

        local descLayer = require("game.Spirit.SpiritInfoLayer").new(1, spiritData, function(bUpgrade)
--            升级精元后需要在onEnter更新数据
            self._rootnode["spiritBtn_" .. tostring(tag)]:setEnabled(true)
            if bUpgrade then
                self._bUpgrade = true
            else
                showChooseScene(tag, filter, spiritData.objId)
            end
        end, function()
            self._rootnode["spiritBtn_" .. tostring(tag)]:setEnabled(true)
        end)
        self:addChild(descLayer, 2)
    end

    local function onClick(tag)
        self._rootnode["spiritBtn_" .. tostring(tag)]:setEnabled(false)
        local _level = game.player:getLevel()
        if getDataOpen(12).level[tag] > _level then
            show_tip_label(string.format("此位置%d级开放", getDataOpen(12).level[tag]))
            return
        end

        local filter = {}
        for k, v in ipairs(self._spirit[self._index]) do
            filter[data_item_item[v.resId].pos] = true
        end

        local bChangeScene = true
        for k, v in ipairs(self._spirit[self._index]) do
            if v.subpos - 6 == tag then
                bChangeScene = false
                filter[data_item_item[v.resId].pos] = false
                onSpiritIcon(v, tag, filter)
                break
            end
        end

        if bChangeScene then
            showChooseScene(tag, filter)
        end
    end

    for i = 1, 8 do
        self._rootnode["spiritBtn_" .. tostring(i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onClick)
    end
end

function HeroSettingScene:getEquipByID(id)
    for k, v in ipairs(game.player:getEquipments()) do
        if v._id == id then
            return v
        end
    end
    return nil
end

function HeroSettingScene:getSkillByID(id)
    for k, v in ipairs(game.player:getSkills()) do
        if v._id == id then
            return v
        end
    end
    return nil
end

function HeroSettingScene:getSpiritByID(id)
    for k, v in ipairs(game.player:getSpirit()) do
        if v._id == id then
            return v
        end
    end
    return nil
end

function HeroSettingScene:initEquip()

    local function onIcon(tag, info)
        if tag < 5 then
            local d = self:getEquipByID(info.objId)
            if d then
                self._rootnode["equipBtn_" .. tostring(tag)]:setTouchEnabled(false)
                local layer = require("game.Equip.CommonEquipInfoLayer").new({
                    index = self._index,
                    subIndex = tag,
                    info = d,
                    closeListener = function()
                        self._rootnode["equipBtn_" .. tostring(tag)]:setTouchEnabled(true)
                    end,
                    listener = function()

                        RequestHelperV2.request(RequestInfo.new({
                            modulename = "fmt",
                            funcname   = "list",
                            param      = {},
                            oklistener = function(data)

                                self:resetFormData(data)
                                self:refreshHero(self._index)
                            end
                        }))
                    end

                })
                self:addChild(layer, 10)
            else
                printf("数据为空")
            end
        else
            local d = self:getSkillByID(info.objId)
            if d then
                self._rootnode["equipBtn_" .. tostring(tag)]:setTouchEnabled(false)
                local layer = require("game.skill.BaseSkillInfoLayer").new({
                    index = self._index,
                    subIndex = tag,
                    info = d,
                    closeListener = function()
                        self._rootnode["equipBtn_" .. tostring(tag)]:setTouchEnabled(true)
                    end,
                    listener = function(data)

                        if data then
                            self:resetFormData(data)
                            self:refreshHero(self._index)
                        else
                            RequestHelperV2.request(RequestInfo.new({
                                modulename = "fmt",
                                funcname   = "list",
                                param      = {},
                                oklistener = function(data)
                                    self:resetFormData(data)
                                    self:refreshHero(self._index)
                                end
                            }))
                        end
                    end
                })
                self:addChild(layer, 10)
            else
                printf("数据为空")
            end
        end
    end
--
    local function onClick(tag)
        -- if tag <= 4 then
        --     if game.player:getLevel() < 9 then
        --         show_tip_label("装备功能9级开放")
        --         return 
        --     end
        -- else
        if tag > 4 then
            if game.player:getLevel() < 10 then
                show_tip_label("武学功能10级开放")
                return            
            end
        end

        local bChangeScene = true
        for k, v in ipairs(self._equip[self._index]) do
            if v.subpos == tag then
                bChangeScene = false
                onIcon(tag, v)
                return
            end
        end

        if bChangeScene then
            if tag < 5 then
                self._rootnode["equipBtn_" .. tostring(tag)]:setTouchEnabled(false)
                push_scene(require("game.form.EquipChooseScene").new({
                    index = self._index,
                    subIndex = tag,
                    cid      = self._cardList[self._index].resId,
                    callback = function(data)
                        if data then
                            self:resetFormData(data)
                        end
                    end
                }))
            else
                self._rootnode["equipBtn_" .. tostring(tag)]:setTouchEnabled(false)
                push_scene(require("game.form.SkillChooseScene").new({
                    index = self._index,
                    subIndex = tag,
                    cid      = self._cardList[self._index].resId,
                    callback = function(data)
                        if data then
                            self:resetFormData(data)
                        end
                    end
                }))
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

function HeroSettingScene:addHero(heroData)
    table.insert(self._cardList, heroData)

    for k, v in ipairs(self._headData) do

        if type(v) == "number" then
            if v == 0 then
                self._headData[k] = heroData

                self._scrollItemList:reloadCell(k - 1, {
                    itemData = heroData
                })
                break
            end
        end
    end
end

function HeroSettingScene:update()

    self:initHeadList()
    self:refreshHero(1)
    TutoMgr.addBtn("zhenrong_hero_image",self._rootnode["heroImg"])
    TutoMgr.active()
end

function HeroSettingScene:refreshChoukaNotice()
    local choukaNotice = self._rootnode["chouka_notice"]
    if choukaNotice ~= nil then
        if game.player:getChoukaNum() > 0 then 
            choukaNotice:setVisible(true)
        else 
            choukaNotice:setVisible(false)
        end
    end
end

function HeroSettingScene:onEnter()
   -- show_tip_label("HeroSettingScene")
    game.runningScene = self

    RegNotice(self,
    function()
        self:setBottomBtnEnabled(false)
    end,
    NoticeKey.LOCK_BOTTOM)

    RegNotice(self,
    function()
        self:setBottomBtnEnabled(true)
    end,
    NoticeKey.UNLOCK_BOTTOM)

    -- 向服务器请求数据
    self:request()

    self:regLockNotice()


    self:refreshChoukaNotice()

    if self._bUpgrade then
        self._bUpgrade = false
--        show_tip_label("hello")
        self:requestForRefreshForm()
    end
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
        if self._onAddHero then
            self:onAddHero()
        else
            self:refreshHero(self._index)
        end
    end

    local tuBtn = self._rootnode["battleBtn"]
    -- self._
    TutoMgr.addBtn("zhenrong_btn_fuben",tuBtn)
    TutoMgr.addBtn("zhujiemian_btn_huodong",self._rootnode["activityBtn"])

    TutoMgr.addBtn("equip_waigong_btn",self._rootnode["equipBtn_5"])
    TutoMgr.addBtn("equip_weapon_btn",self._rootnode["equipBtn_2"])
    
    TutoMgr.addBtn("quickEquipBtn",self._rootnode["quickEquipBtn"])

    TutoMgr.active()
end

function HeroSettingScene:btnEnabled()

end

function HeroSettingScene:requestForRefreshForm()
    RequestHelperV2.request(RequestInfo.new({
        modulename = "fmt",
        funcname   = "list",
        param      = {},
        oklistener = function(data)
            self:resetFormData(data)
            self:refreshHero(self._index)
        end
    }))
end

function HeroSettingScene:onExit()

    -- HeroSettingModel.equipList = {}
    HeroSettingModel.cardIndex = 0
    UnRegNotice(self, NoticeKey.LOCK_BOTTOM)
    UnRegNotice(self, NoticeKey.UNLOCK_BOTTOM)
    self._bExit = true
    TutoMgr.removeBtn("zhenrong_btn_fuben")
    TutoMgr.removeBtn("zhenrongzhujiemian_btn_erhaowei")
    TutoMgr.removeBtn("equip_waigong_btn")
    TutoMgr.removeBtn("zhenrong_anniu_yinying")
    TutoMgr.removeBtn("zhujiemian_btn_huodong")
    TutoMgr.removeBtn("equip_weapon_btn")
    TutoMgr.removeBtn("quickEquipBtn")
    
    self:unLockNotice()
    
--
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

function HeroSettingScene:onEnterTransitionFinish()
    -- if self._bRequest then

    -- else
    --     self._bRequest = true
    --     self:request()
    -- end

end
return HeroSettingScene

