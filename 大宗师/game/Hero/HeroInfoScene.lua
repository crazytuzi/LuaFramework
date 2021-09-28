--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-8-1
-- Time: 下午5:08
-- To change this template use File | Settings | File Templates.
--
local data_item_nature = require("data.data_item_nature")
local data_talent_talent = require("data.data_talent_talent")
local data_jiban_jiban = require("data.data_jiban_jiban")
local data_battleskill_battleskill = require("data.data_battleskill_battleskill")
local data_shentong_shentong = require("data.data_shentong_shentong")
local data_item_nature = require("data.data_item_nature")
require("utility.richtext.richText")

local HeroInfoScene = class("HeroInfoScene", function()
    return require("game.BaseSceneExt").new({
        contentFile = "hero/hero_info.ccbi",
--        bottomFile = "hero/hero_info_bottom.ccbi",
        topFile    = "public/top_voice_frame.ccbi",
        adjustSize = CCSizeMake(6, 5)
    })
end)

local DesignSize = {
    ST = CCSizeMake(display.width, 125),
    JN = CCSizeMake(display.width, 55),
    JB = CCSizeMake(display.width, 55),
    JJ = CCSizeMake(display.width, 150)
}
--
local STItem = class("STItem", function(t, resetFunc, upgradeFunc, btnEnable)

    local height = 0
    local nodes = {}
    local rootnode = {}
    local proxy = CCBProxy:create()
--    dump(t)

    local tmpUpgradeBtn = nil
    for k, v in ipairs(t) do
        rootnode = {}
        local infoNode = CCBuilderReaderLoad("hero/hero_shentong_info.ccbi", proxy, rootnode)
        local tmpLv = v.lv

        if k == #t then
            rootnode["lineSprite"]:setVisible(false)
        end

        rootnode["descLabel"]:setString(v.info.type)
        rootnode["upgradeBtn"]:addHandleOfControlEvent(c_func(upgradeFunc, k - 1, v), CCControlEventTouchDown)
        table.insert(nodes, infoNode)
--        table.insert(nodes, rootnode)

        rootnode["upgradeBtn"]:setEnabled(btnEnable)

        infoNode.nameItemName = rootnode["nameItemName"]
        infoNode.descLabel = rootnode["descLabel"]
        infoNode.costLabel = rootnode["costLabel"]
        infoNode.upgradeBtn = rootnode["upgradeBtn"]
        infoNode.xiaohao_lbl = rootnode["xiaohao_lbl"]

        if k == 1 then
            tmpUpgradeBtn = rootnode["upgradeBtn"]
        end

        height = height + infoNode:getContentSize().height
        if t.cls < 0 or
                (v.lv <= #v.map.arr_point and v.map.arr_cond[v.lv + 1] > t.cls) then
            rootnode["nameItemName"]:setColor(ccc3(119, 119, 119))
            rootnode["descLabel"]:setColor(ccc3(119, 119, 119))
            rootnode["upgradeBtn"]:setEnabled(false)
            rootnode["xiaohao_lbl"]:setVisible(false)

            rootnode["nameItemName"]:setString(string.format("%s(%d/%d)", v.info.name, v.lv , #v.map.arr_cond))
            rootnode["costLabel"]:setColor(ccc3(119, 119, 119))
            rootnode["costLabel"]:setString(string.format("进阶+%d开启", v.map.arr_cond[v.lv + 1]))
        else
            if tmpLv == 0 then
                tmpLv = 1
            end
            rootnode["nameItemName"]:setString(string.format("%s(%d/%d)", v.info.name, tmpLv , #v.map.arr_cond))
            rootnode["nameItemName"]:setColor(ccc3(211, 53, 0))
            rootnode["descLabel"]:setColor(ccc3(130, 13, 0))
            rootnode["upgradeBtn"]:setEnabled(true)
            rootnode["costLabel"]:setColor(ccc3(0, 204, 67))

            if tmpLv <= #v.map.arr_point then
                rootnode["costLabel"]:setString(tostring(v.map.arr_point[tmpLv]))
                rootnode["xiaohao_lbl"]:setVisible(true)
            else
                rootnode["costLabel"]:setString("")
                rootnode["upgradeBtn"]:setEnabled(false)
                rootnode["xiaohao_lbl"]:setVisible(false)
            end
        end
    end

    rootnode = {}
    local node = CCBuilderReaderLoad("hero/hero_shentong_item.ccbi", proxy, rootnode, display.newNode(), CCSizeMake(DesignSize.ST.width, DesignSize.ST.height + height + 10))
    rootnode["stPointLabel"]:setString(tostring(t.point))

    node.refresh = function(_, index)
        for k, v in ipairs(t) do
            if index == nil or k == index then
                rootnode["stPointLabel"]:setString(tostring(t.point))
                nodes[k]["descLabel"]:setString(v.info.type)
                local tmpLv = v.lv
                if t.cls < 0 or (v.lv <= #v.map.arr_point and v.map.arr_cond[v.lv + 1] > t.cls) then

                    nodes[k]["nameItemName"]:setColor(ccc3(119, 119, 119))
                    nodes[k]["descLabel"]:setColor(ccc3(119, 119, 119))
                    nodes[k]["upgradeBtn"]:setEnabled(false)
                    nodes[k]["xiaohao_lbl"]:setVisible(false)

                    nodes[k]["nameItemName"]:setString(string.format("%s(%d/%d)", v.info.name, v.lv , #v.map.arr_cond))
                    nodes[k]["costLabel"]:setColor(ccc3(119, 119, 119))
                    nodes[k]["costLabel"]:setString(string.format("进阶+%d开启", v.map.arr_cond[v.lv + 1]))
                else
                    if tmpLv == 0 then
                        tmpLv = 1
                    end
                    nodes[k]["nameItemName"]:setString(string.format("%s(%d/%d)", v.info.name, tmpLv , #v.map.arr_cond))
                    nodes[k]["nameItemName"]:setColor(ccc3(211, 53, 0))
                    nodes[k]["descLabel"]:setColor(ccc3(130, 13, 0))
                    nodes[k]["upgradeBtn"]:setEnabled(true)
                    nodes[k]["costLabel"]:setColor(ccc3(0, 204, 67))

                    if tmpLv <= #v.map.arr_point then
                        nodes[k]["costLabel"]:setString(tostring(v.map.arr_point[tmpLv]))
                        nodes[k]["xiaohao_lbl"]:setVisible(true)
                    else
                        nodes[k]["costLabel"]:setString("")
                        nodes[k]["upgradeBtn"]:setEnabled(false)
                        nodes[k]["xiaohao_lbl"]:setVisible(false)
                    end
                end

            end
        end
    end

    height = 13
    for i = #nodes, 1, -1 do
        height = nodes[i]:getContentSize().height + height + 13
        nodes[i]:setPosition(node:getContentSize().width / 2, height)
        node:addChild(nodes[i])
    end

    rootnode["resetBtn"]:addHandleOfControlEvent(function() 
        local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ShenTong, game.player:getLevel(), game.player:getVip()) 
        if not bHasOpen then
            show_tip_label(prompt) 
        else
            local box = require("utility.MsgBox").new({
                size = CCSizeMake(500, 200),
                content = "确定花费元宝重置侠客神通点数吗?",
                leftBtnName = "取消",
                rightBtnName = "确定",
                leftBtnFunc = function() end,
                rightBtnFunc = resetFunc
            })
            game.runningScene:addChild(box, 101)
        end 
    end, CCControlEventTouchDown)
    rootnode["resetBtn"]:setEnabled(btnEnable)

    node.getUpgradeBtn1 = function()
        return tmpUpgradeBtn
    end

    node.getNumLabel = function()
        return rootnode["stPointLabel"]
    end


    return node
end)

local JNItem = class("JNItem", function(t)
    local height = 0
    local nodes = {}
    for k, v in ipairs(t) do
        local htmlText = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#ac07bb\">%s</font><font size=\"22\" color=\"#7e0000\">%s</font>"

        local infoNode = getRichText(string.format(htmlText, v.name, v.desc), display.width * 0.9)
        table.insert(nodes, infoNode)

        height = height + infoNode:getContentSize().height + 10
    end

    local proxy = CCBProxy:create()
    local rootnode = {}
    local node = CCBuilderReaderLoad("hero/hero_skill_item.ccbi", proxy, rootnode, display.newNode(), CCSizeMake(DesignSize.JN.width, DesignSize.JN.height + height))

    height = 0
    for i = #nodes, 1, -1 do
        nodes[i]:setPosition(30, nodes[i]:getContentSize().height + height - 8)
        node:addChild(nodes[i])
        height = nodes[i]:getContentSize().height + height + 5
    end

    return node
end)

local JBItem = class("JBItem", function(t, relation)
    local height = 0
    local nodes = {}
    for k, v in ipairs(t) do
        if k > 6 then
            return
        end
        local color1 = "777777"
        local color2 = "777777"
        for i, j in ipairs(relation) do
            if v.id == j then
                color1 = "00e430"
                color2 = "dd0000"
            end
        end

        local htmlText = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#%s\">%s  </font><font size=\"22\" color=\"#%s\">%s%s+%d%%</font>"
        local infoNode = getRichText(string.format(htmlText, color1, v.name, color2, v.describe, data_item_nature[v.nature1].nature, v.value1 / 100), display.width * 0.92)
        table.insert(nodes, infoNode)
--
--
--        if infoNode:getContentSize().height > 40 then
--            infoNode:setContentSize(CCSizeMake(infoNode:getContentSize().width, infoNode:getContentSize().height + 10))
--        end
        height = height + infoNode:getContentSize().height + 10
    end

    local proxy = CCBProxy:create()
    local rootnode = {}
    local node = CCBuilderReaderLoad("hero/hero_jiban_item.ccbi", proxy, rootnode, display.newNode(), CCSizeMake(DesignSize.JB.width, DesignSize.JB.height + height))

    height = 0
    for i = #nodes, 1, -1 do
        nodes[i]:setPosition(30, nodes[i]:getContentSize().height + height - 8)
        node:addChild(nodes[i])
        height = nodes[i]:getContentSize().height + height + 5
    end

--
--    rootnode["helpBtn"]:addHandleOfControlEvent(function()
--        show_tip_label("羁绊可以增加侠客更")
--    end, CCControlEventTouchDown)

    return node
end)

local JJItem = class("JJItem", function(str)
    local proxy = CCBProxy:create()
    local rootnode = {}

    local sz = DesignSize.JJ
    if string.utf8len(str) / 28 > 3 then
        sz = CCSizeMake(DesignSize.JJ.width, DesignSize.JJ.height + 15)
    elseif string.utf8len(str) / 28 < 2 then
        sz = CCSizeMake(DesignSize.JJ.width, DesignSize.JJ.height - 20)
    end

    local node = CCBuilderReaderLoad("hero/hero_intr_item.ccbi", proxy, rootnode, display.newNode(), sz)
    rootnode["descLabel"]:setString(str)
    return node
end)
--
--  infoType:
--1:formation
--2:list
--3:shop
function HeroInfoScene:ctor(param, infoType)
    game.runningScene = self

    local _index = param.index
--    ui_zhenrong
    display.addSpriteFramesWithFile("ui_zhenrong.plist", "ui_zhenrong.png")
    local pt = self._rootnode["scrollView"]:convertToWorldSpace(ccp(0, 0))
    local layer = require("utility.TouchMaskLayer").new({
        contents = {
            CCRectMake(pt.x, pt.y, display.width, self._rootnode["scrollView"]:getViewSize().height)
        },
        btns = {self._rootnode["closeBtn"],
            self._rootnode["changeBtn"],
            self._rootnode["qiangHuBtn"],
            self._rootnode["jinJieBtn"],
            self._rootnode["closeBtn2"]
        }
    })
    self:addChild(layer, 100)
--
    self._rootnode["scrollView"]:setContentOffset(CCPointMake(0, -self._rootnode["contentView"]:getContentSize().height + self._rootnode["scrollView"]:getViewSize().height), false)

    local _info     = param.info
    local _changeHeroListener = param.changeHero
    local _refreshHeroListener = param.refreshHero
    local _baseInfo = ResMgr.getCardData(_info.resId)

    if _info.resId == 1 or _info.resId == 2 then
        self._rootnode["changeBtn"]:setVisible(false)
    end

    if _info.resId == 1 or _info.resId == 2 or _info.resId == 10 then
        self._rootnode["qiangHuBtn"]:setVisible(false)
    end

    --是否从阵容进来的？如果不是阵容进来的 则屏蔽“更换侠客”按钮
    if infoType == 2 then
        self._rootnode["changeBtn"]:setVisible(false)
        self.cellIndex = param.cellIndex
        self.createJinjieLayer = param.createJinjieLayer
        self.createQiangHuaLayer = param.createQiangHuaLayer
    end

    self._rootnode["titleLabel"]:setString("侠客信息")

    self.refresh = function(_)
        self._rootnode["contentViewNode"]:removeAllChildrenWithCleanup(true)
        if self._detailInfo.cls > 0 then
            self._rootnode["clsLabel"]:setString(string.format("+ %d", self._detailInfo.cls))
            self._rootnode["clsLabel"]:setVisible(true)
        else
            self._rootnode["clsLabel"]:setVisible(false)
        end


        if _baseInfo.id == 1 or _baseInfo.id == 2 then
            self._rootnode["itemNameLabel"]:setString(game.player:getPlayerName())
        else
            self._rootnode["itemNameLabel"]:setString(_baseInfo.name)
        end
        self._rootnode["itemNameLabel"]:setColor(NAME_COLOR[self._detailInfo.star])

        self._rootnode["curLevalLabel"]:setString(tostring(self._detailInfo.level))
        self._rootnode["maxLevalLabel"]:setString(tostring(self._detailInfo.levelLimit or "缺少主角等级"))
        self._rootnode["cardName"]:setString(_baseInfo.name)
                
        self._rootnode["tag_card_bg"]:setDisplayFrame(display.newSprite("#card_ui_bg_" .. self._detailInfo.star .. ".png"):getDisplayFrame())
        self._rootnode["jobImage"]:setDisplayFrame(display.newSpriteFrame(string.format("zhenrong_job_%d.png", _baseInfo.job)))

        for i=1,self._detailInfo.star  do
            self._rootnode["star"..i]:setVisible(true)
        end

--      领导力
        for i = 1, 3 do
            self._rootnode[string.format("nbPropLabel_%d", i)]:setString(tostring(self._detailInfo.lead[i]))
        end

--      基本信息
        for i = 1, 4 do
            self._rootnode[string.format("basePropLabel_%d", i)]:setString(tostring(self._detailInfo.base[i]))
        end

--      图标
        local heroImg = ResMgr.getCardData(self._detailInfo.resId)["arr_body"][self._detailInfo.cls + 1]
        local heroPath = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getLargeImage(heroImg, ResMgr.HERO))
        self._rootnode["heroImage"]:setDisplayFrame(display.newSprite(heroPath):getDisplayFrame())

        local height = 0

--      神通
        local function addSTItem()
--
            local item
            local st = {}
            local function resetPt()
                RequestHelper.hero.shentongReset({
                    callback = function(data)
                        dump(data)
                        if string.len(data["0"]) > 0 then
                            CCMessageBox(data["0"], "Tip")
                        else
                            for k, v in ipairs(_baseInfo.talent) do
                                st[k].lv   = data["2"][k]
                                st[k].info = data_talent_talent[data["1"][k]]
                            end
                            self._detailInfo.shenPt = data["3"] or 0
                            st.point = data["3"]
                            item:refresh()
                        end
                    end,
                    cid = _info.objId
                })
            end
            local function onUpgrade(ind, stInfo)
                PostNotice(NoticeKey.REMOVE_TUTOLAYER)
                -- 判断等级是否达到神通开通等级 
                local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ShenTong, game.player:getLevel(), game.player:getVip()) 
                if not bHasOpen then
                    show_tip_label(prompt) 
                    return 
                end

                if stInfo.lv >= #stInfo.map.arr_talent then
                    show_tip_label("已经达到最大等级")
                    return
                end
                dump(stInfo)

                if stInfo.lv > 0 and
                    stInfo.lv <= #stInfo.map.arr_point and
                    self._detailInfo.shenPt < stInfo.map.arr_point[stInfo.lv] then
                    show_tip_label("神通点不足")
                    return
                end
                RequestHelper.hero.shentongUpgrade({
                    callback = function(data)
                        dump(data)
                        if string.len(data["0"]) > 0 then
                            CCMessageBox(data["0"], "Tip")
                        else
                            stInfo.info = data_talent_talent[data["1"]]
                            stInfo.lv = data["2"]
                            st.point  = data["3"] or 0
                            item:refresh(ind + 1)
                        end
                    end,
                    cid = _info.objId,
                    ind = ind
                })
            end
--
--            dump(_baseInfo.talent)
            dump(self._detailInfo.shenIDAry)
            for k, v in ipairs(_baseInfo.talent) do
                local stData = data_shentong_shentong[v]
--
                local t = {
                    info = data_talent_talent[self._detailInfo.shenIDAry[k]],
                    map  = stData,
                    lv   = self._detailInfo.shenLvAry[k] or 1
                }
                table.insert(st, t)
            end
            st.cls   = self._detailInfo.cls
            st.point = self._detailInfo.shenPt or 0
            if infoType == 3 then
                item = STItem.new(st, resetPt, onUpgrade, false)
            else
                item = STItem.new(st, resetPt, onUpgrade, true)
            end
            height = height + item:getContentSize().height + 2
            item:setPosition(self._rootnode["contentView"]:getContentSize().width / 2, 40)
--            self._rootnode["contentView"]:addChild(item)
            self._rootnode["contentViewNode"]:addChild(item)
            self.getUpgradeBtn1 = function()
                return item:getUpgradeBtn1()
            end

            self.getNumLabel = function()
                return item:getNumLabel()
            end
        end

--      技能
        local function addJNItem()
            local t = {}
            if _baseInfo.skill[self._detailInfo.cls + 1] then
                table.insert(t, data_battleskill_battleskill[_baseInfo.skill[self._detailInfo.cls + 1]])
            end

            if _baseInfo.angerSkill[self._detailInfo.cls + 1] then
                table.insert(t, data_battleskill_battleskill[_baseInfo.angerSkill[self._detailInfo.cls + 1]])
            end

            local item = JNItem.new(t)
            item:setPosition(self._rootnode["contentView"]:getContentSize().width / 2, -height + 40)
--            self._rootnode["contentView"]:addChild(item)
--            contentViewNode
            self._rootnode["contentViewNode"]:addChild(item)
            height = height + item:getContentSize().height + 2
        end

--      羁绊
        local function addJBItem()
            local t = {}
            if _baseInfo.fate1 then
                for k, v in ipairs(_baseInfo.fate1) do
                    table.insert(t, data_jiban_jiban[v])
                end
            end

            local item = JBItem.new(t, self._detailInfo.relation)
            item:setPosition(self._rootnode["contentView"]:getContentSize().width / 2, -height + 40)
--            self._rootnode["contentView"]:addChild(item)
            self._rootnode["contentViewNode"]:addChild(item)
            height = height + item:getContentSize().height + 2
        end

--      简介
        local function addJJItem(str)

            local item = JJItem.new(str)
            item:setPosition(self._rootnode["contentView"]:getContentSize().width / 2, -height + 40)
--            self._rootnode["contentView"]:addChild(item)
            self._rootnode["contentViewNode"]:addChild(item)

            height = height + item:getContentSize().height + 2
        end

        local function resizeContent()
            local sz = CCSizeMake(self._rootnode["contentView"]:getContentSize().width, self._rootnode["contentView"]:getContentSize().height + height - 40)

            self._rootnode["descView"]:setContentSize(sz)
            self._rootnode["contentView"]:setPosition(ccp(sz.width / 2, sz.height))
            self._rootnode["scrollView"]:updateInset()
            self._rootnode["scrollView"]:setContentOffset(CCPointMake(0, -sz.height + self._rootnode["scrollView"]:getViewSize().height), false)
        end

        if _baseInfo.talent then
            addSTItem()
        end

        addJNItem()

        if _baseInfo.fate1 then
            addJBItem()
        end
        addJJItem(_baseInfo.attribute)

        resizeContent()
    end

    local function change()
        CCDirector:sharedDirector():popToRootScene()

        push_scene(require("game.form.HeroChooseScene").new({
            index    = _index,
            callback = _changeHeroListener
        }))
    end

    local function getIndexById(id)
        for k, v in ipairs(game.player:getSkills()) do
            if v._id == id then
                return k
            end
        end
    end

    local function close()
        PostNotice(NoticeKey.REMOVE_TUTOLAYER)
        if _refreshHeroListener then
            _refreshHeroListener(self._detailInfo)
        end
        pop_scene()
    end

    local function qiangHua()
        PostNotice(NoticeKey.REMOVE_TUTOLAYER)
        if infoType == 2 then
            self.createQiangHuaLayer(_info.objId,self.cellIndex)
        elseif infoType == 1 then
            local index = 0
            for k, v in ipairs(game.player:getHero()) do
                if v._id == _info.objId then
                    index = k
                end
            end

            local aaa = require("game.Hero.HeroQiangHuaLayer").new({
                id = _info.objId,
                listData = game.player:getHero(),
                index = index,
                resetList = function()

                end,
                removeListener = function(data)
--                    if _refreshHeroListener then
--                        _refreshHeroListener(data["1"])
--                    end
--                    pop_scene()
                    self:requestHeroInfo()
                end
            })
            self:addChild(aaa, 1000)
        end
    end

    local function jinJie() 
        PostNotice(NoticeKey.REMOVE_TUTOLAYER)
        if infoType == 1 then 
            local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.XiaKe_JinJie, game.player:getLevel(), game.player:getVip()) 
            if not bHasOpen then
                show_tip_label(prompt)
            else
                local index = 0
                for k, v in ipairs(game.player:getHero()) do
                    if v._id == _info.objId then
                        index = k
                    end
                end
                local jinJieLayer = require("game.Hero.HeroJinJie").new({
                    incomeType = 2,
                    listInfo = {
                        id = _info.objId,
                        listData = game.player:getHero(),
                        cellIndex = index,
                    },
                    removeListener = function()
                        self:requestHeroInfo()
                    end
                })
                self:addChild(jinJieLayer, 1000)
            end 
        elseif infoType == 2 then 
            local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.XiaKe_JinJie, game.player:getLevel(), game.player:getVip()) 
            if not bHasOpen then
                show_tip_label(prompt) 
            else
                self.createJinjieLayer(_info.objId,self.cellIndex)
            end
        elseif infoType == 3 then
            close()
        end
    end
    self._rootnode["closeBtn"]:setVisible(true)
    self._rootnode["closeBtn"]:addHandleOfControlEvent(close, CCControlEventTouchDown)
    self._rootnode["changeBtn"]:addHandleOfControlEvent(change, CCControlEventTouchDown)
    self._rootnode["qiangHuBtn"]:addHandleOfControlEvent(qiangHua, CCControlEventTouchDown)
    self._rootnode["jinJieBtn"]:addHandleOfControlEvent(jinJie, CCControlEventTouchDown)

    TutoMgr.addBtn("hero_info_qianghua_btn",self._rootnode["qiangHuBtn"])

    if _baseInfo.advance == 1 then
        self._rootnode["jinJieBtn"]:setVisible(true)
    else
        self._rootnode["jinJieBtn"]:setVisible(false)
    end

    if infoType == 3 then
        self._rootnode["changeBtn"]:setVisible(false)
        self._rootnode["qiangHuBtn"]:setVisible(false)
        self._rootnode["jinJieBtn"]:setTitleForState(CCString:create("返回"), CCControlStateNormal)
    end

--    refresh()
--    initItem()

    self._info = _info

    self._bExit = false
end

function HeroInfoScene:requestHeroInfo(listener)

    RequestHelper.hero.info({
        cid = self._info.objId,
        callback = function(data)
            if string.len(data["0"]) > 0 then
                CCMessageBox(data["0"], "Tip")
            else

                self._detailInfo = data["1"]
                self._detailInfo.levelLimit = data["2"]

--              直接返回阵容界面

--                if listener then
--                    listener()
--                    return
--                end

                self:refresh()
                local addBtn
                local label
                if self.getUpgradeBtn1 then
                    addBtn = self:getUpgradeBtn1()
                end

                if self.getNumLabel then
                    label = self:getNumLabel()
                end

                local closeBtn = self._rootnode["closeBtn"]

                TutoMgr.addBtn("heroinfo_shentong_num",label)
                TutoMgr.addBtn("heroinfo_shentong_plus",addBtn)
                TutoMgr.addBtn("heroinfo_close_btn",closeBtn)

                TutoMgr.active()
            end
        end
    })
end

function HeroInfoScene:onEnter()
    game.runningScene = self
    -- 广播
    if self._bExit then
        self._bExit = false
        local broadcastBg = self._rootnode["broadcast_tag"] 
        if game.broadcast:getParent() ~= nil then 
            game.broadcast:removeFromParentAndCleanup(true)
        end
        broadcastBg:addChild(game.broadcast)
    end
    self:requestHeroInfo()
end

function HeroInfoScene:onExit()
    self._bExit = true
    TutoMgr.removeBtn("hero_info_qianghua_btn")
    TutoMgr.removeBtn("heroinfo_shentong_num")
    TutoMgr.removeBtn("heroinfo_shentong_plus")
    TutoMgr.removeBtn("heroinfo_close_btn")
end


return HeroInfoScene



