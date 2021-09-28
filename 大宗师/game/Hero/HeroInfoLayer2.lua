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
-- 日期：14-10-10
--

local data_item_nature = require("data.data_item_nature")
local data_talent_talent = require("data.data_talent_talent")
local data_jiban_jiban = require("data.data_jiban_jiban")
local data_battleskill_battleskill = require("data.data_battleskill_battleskill")
local data_shentong_shentong = require("data.data_shentong_shentong")
local data_item_nature = require("data.data_item_nature")
require("utility.richtext.richText")

local ST_COLOR = {
    ccc3(255, 38, 0),
    ccc3(43, 164, 45),
    ccc3(28, 94, 171),
    ccc3(218, 129, 29)
}

local HeroInfoLayer = class("HeroInfoLayer", function()
    return require("utility.ShadeLayer").new(ccc4(100, 100, 100, 0))
end)

local DesignSize = {
    ST = CCSizeMake(display.width, 80),
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

        local infoSize
--        if string.utf8len(v.info.type) > 50 then
--            infoSize = CCSizeMake(display.width, 135)
--        else
        if string.utf8len(v.info.type) > 38 then
            infoSize = CCSizeMake(display.width, 125)
        elseif string.utf8len(v.info.type) > 18 then
            infoSize = CCSizeMake(display.width, 96)
        else
            infoSize = CCSizeMake(display.width, 80)
        end

        local infoNode = CCBuilderReaderLoad("hero/hero_shentong_info.ccbi", proxy, rootnode, display.newNode(), infoSize)
        local tmpLv = v.lv

        if k == #t then
            rootnode["lineSprite"]:setVisible(false)
        end

        rootnode["descLabel"]:setString(v.info.type)
        rootnode["upgradeBtn"]:addHandleOfControlEvent(c_func(function(btnNode, index, info)
            btnNode:setEnabled(false)
            upgradeFunc(index, info)
            btnNode:performWithDelay(function()
                btnNode:setEnabled(true)
            end, 0.5)
        end, rootnode["upgradeBtn"], k - 1, v), CCControlEventTouchDown)
--        rootnode["upgradeBtn"]:addHandleOfControlEvent(function()
--            upgradeFunc( k - 1, v)
--        end, CCControlEventTouchDown)
--        rootnode["upgradeBtn"]:addHandleOfControlEvent(c_func(upgradeFunc, k - 1, v), CCControlEventTouchDown)
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
        if t.cls == 0  or (v.lv <= #v.map.arr_point and v.map.arr_cond[v.lv + 1] > t.cls) then

            if t.cls == 0 then
                rootnode["nameItemName"]:setColor(ccc3(119, 119, 119))
                rootnode["descLabel"]:setColor(ccc3(119, 119, 119))
            else
                if v.map then
                    rootnode["nameItemName"]:setColor(ST_COLOR[v.map.type])
                end
                rootnode["descLabel"]:setColor(ccc3(86, 59, 32))
            end
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
            if v.map then
                rootnode["nameItemName"]:setColor(ST_COLOR[v.map.type])
            end
            rootnode["descLabel"]:setColor(ccc3(86, 59, 32))
            rootnode["upgradeBtn"]:setEnabled(true)
            rootnode["costLabel"]:setColor(ccc3(0, 204, 67))

            if tmpLv <= #v.map.arr_point then
                rootnode["costLabel"]:setString(tostring(v.map.arr_point[tmpLv]))
                rootnode["xiaohao_lbl"]:setVisible(true)
                rootnode["xiaohao_lbl"]:setString("消耗   点神通")
                rootnode["xiaohao_lbl"]:setColor(ccc3(193, 124, 0))
            else
                rootnode["costLabel"]:setString("")
                rootnode["upgradeBtn"]:setEnabled(false)
--                rootnode["xiaohao_lbl"]:setVisible(false)
                rootnode["xiaohao_lbl"]:setString("神通已满级")
                rootnode["xiaohao_lbl"]:setColor(ccc3(255, 38, 0))

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
                    if t.cls < 0 then
                        nodes[k]["nameItemName"]:setColor(ccc3(119, 119, 119))
                        nodes[k]["descLabel"]:setColor(ccc3(119, 119, 119))

                    end
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
--                    nodes[k]["nameItemName"]:setColor(ccc3(211, 53, 0))
                    if v.map then
                        nodes[k]["nameItemName"]:setColor(ST_COLOR[v.map.type])
                    end
                    nodes[k]["descLabel"]:setColor(ccc3(86, 59, 32))
                    nodes[k]["upgradeBtn"]:setEnabled(true)
                    nodes[k]["costLabel"]:setColor(ccc3(0, 204, 67))

                    if tmpLv <= #v.map.arr_point then
                        nodes[k]["costLabel"]:setString(tostring(v.map.arr_point[tmpLv]))
                        nodes[k]["xiaohao_lbl"]:setVisible(true)
                        nodes[k]["xiaohao_lbl"]:setString("消耗   点神通")
                        nodes[k]["xiaohao_lbl"]:setColor(ccc3(193, 124, 0))
                    else
                        nodes[k]["costLabel"]:setString("")
                        nodes[k]["upgradeBtn"]:setEnabled(false)
                        nodes[k]["xiaohao_lbl"]:setVisible(true)
                        nodes[k]["xiaohao_lbl"]:setString("神通已满级")
                        nodes[k]["xiaohao_lbl"]:setColor(ccc3(255, 38, 0))
                    end
                end

            end
        end
    end

    height = 0
    for i = #nodes, 1, -1 do
        height = nodes[i]:getContentSize().height + height + 5
        nodes[i]:setPosition(node:getContentSize().width / 2, height)
        node:addChild(nodes[i])
    end

    rootnode["resetBtn"]:addHandleOfControlEvent(function() 
        local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ShenTong, game.player:getLevel(), game.player:getVip()) 
        if not bHasOpen then 
            show_tip_label(prompt)
        else
            local bReset = false
            if t.point > 0 then
                for k, v in ipairs(t) do
                    if v.lv > 1 then
                        bReset = true
                    end
                end
            else
                for k, v in ipairs(t) do
                    if v.lv > 0 then
                        bReset = true
                    end
                end
            end

            if bReset then
                local box = require("utility.CostTipMsgBox").new({
                    tip = "重置侠客神通点数吗？",
                    listener = resetFunc,
                    cost = 50,
                })
                game.runningScene:addChild(box, 1001)
            else
                show_tip_label("您没有需要重置的神通点数!")
            end
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
        local htmlText = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#ac07bb\">%s  </font><font size=\"22\" color=\"#563b20\">%s</font>"

        local infoNode = getRichText(string.format(htmlText, v.info.name, v.info.desc), display.width * 0.9 - 30)
        table.insert(nodes, infoNode)
        infoNode.type = v.t

        height = height + infoNode:getContentSize().height + 10
    end

    local proxy = CCBProxy:create()
    local rootnode = {}
    local node = CCBuilderReaderLoad("hero/hero_skill_item.ccbi", proxy, rootnode, display.newNode(), CCSizeMake(DesignSize.JN.width, DesignSize.JN.height + height))

    height = 0
    for i = #nodes, 1, -1 do

        local icon = display.newSprite(string.format("#heroinfo_skill_%d.png", nodes[i].type or 1))
        icon:setPosition(30 + icon:getContentSize().width / 2, nodes[i]:getContentSize().height + height - 10 + icon:getContentSize().height / 2)
        node:addChild(icon)


        nodes[i]:setPosition(30 + icon:getContentSize().width, nodes[i]:getContentSize().height + height - 8)
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
                color1 = "ff6c00"
                color2 = "dd0000"
            end
        end

        local bFlag = 0
        for i = 1, 3 do
            if v[string.format("nature%d", i)] ~= 0 then
                local nature = data_item_nature[v[string.format("nature%d", i)]]
                if nature.id == 33 or nature.id == 34 then
                    bFlag = bFlag + 1
                end
            end
        end

        local tmpStr = ""
        local bSkip = false
        for i = 1, 3 do
            if v[string.format("nature%d", i)] ~= 0 then

                local nature = data_item_nature[v[string.format("nature%d", i)]]

                local val = ""
                if nature.type == 1 then
                    val = tostring(v[string.format("value%d", i)])
                else
                    val = tostring(v[string.format("value%d", i)] / 100) .. "%"
                end

                if (nature.id == 33 or nature.id == 34) and bFlag == 2 then
                    if bSkip == false then
                        tmpStr = tmpStr .. string.format("，%s+%s", "防御", val)
                        bSkip = true
                    end
                else
                    tmpStr = tmpStr .. string.format("，%s+%s", nature.nature, val)
                end
            end
        end

        local htmlText = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#%s\">%s    </font><font size=\"22\" color=\"#%s\">%s%s</font>"
        local infoNode = getRichText(string.format(htmlText, color1, v.name, color2, v.describe, tmpStr), display.width * 0.88)
        table.insert(nodes, infoNode)
        height = height + infoNode:getContentSize().height + 10
    end

    height = height - 15
    local proxy = CCBProxy:create()
    local rootnode = {}
    local node = CCBuilderReaderLoad("hero/hero_jiban_item.ccbi", proxy, rootnode, display.newNode(), CCSizeMake(DesignSize.JB.width, DesignSize.JB.height + height))

    height = 0
    for i = #nodes, 1, -1 do
        nodes[i]:setPosition(30, nodes[i]:getContentSize().height + height - 4)
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

function HeroInfoLayer:initLock()

    self._rootnode["lock_btn"]:addHandleOfControlEvent(function()

        self._rootnode["lock_btn"]:setEnabled(false)
        self._rootnode["unlock_btn"]:setEnabled(false)
        ResMgr.showMsg(13)

        self._rootnode["lock_btn"]:setVisible(false)
        self._rootnode["unlock_btn"]:setVisible(true)
        RequestHelper.lockHero({
            id = self._info.objId,
            lock = 1,
            callback = function()
                self.isLock  = true
                self._rootnode["lock_btn"]:setEnabled(true)
                self._rootnode["unlock_btn"]:setEnabled(true)
                HeroModel.totalTable[self.cellIndex].lock = 1
            end
            })
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        end, CCControlEventTouchUpInside)

    self._rootnode["unlock_btn"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        self._rootnode["lock_btn"]:setEnabled(false)
        self._rootnode["unlock_btn"]:setEnabled(false)
        ResMgr.showMsg(14)

        self._rootnode["lock_btn"]:setVisible(true)
        self._rootnode["unlock_btn"]:setVisible(false)
        RequestHelper.lockHero({
            id = self._info.objId,
            lock = 0,
            callback = function()
                self._rootnode["lock_btn"]:setEnabled(true)
                self._rootnode["unlock_btn"]:setEnabled(true)
                self.isLock  = false
                HeroModel.totalTable[self.cellIndex].lock = 0
            end
            })
        end, CCControlEventTouchUpInside)


end
--
--  infoType:
--1:formation
--2:list
--3:shop
function HeroInfoLayer:ctor(param, infoType)

    dump(param)

    self:setNodeEventEnabled(true)

    self.removeListener = param.removeListener

    self._proxy = CCBProxy:create()
    self._rootnode = {}

    local bgHeight = display.height

    local bgNode = CCBuilderReaderLoad("hero/hero_info.ccbi", self._proxy, self._rootnode, self, CCSizeMake(display.width, bgHeight - 30))
    self:addChild(bgNode, 1)
    bgNode:setPosition(display.width / 2, display.cy - bgHeight / 2)

--  屏幕高 - 广播条 - 底部按钮 - 标题栏
    local infoNode = CCBuilderReaderLoad("hero/hero_info_detail.ccbi", self._proxy, self._rootnode, self, CCSizeMake(display.width, bgHeight - 32 - 85 - 68))
    infoNode:setPosition(ccp(0, 85))
    bgNode:addChild(infoNode)

    self._rootnode["bottomMenuNode"]:setZOrder(1)
    local heroNameLabel = ui.newTTFLabelWithShadow({
        text = "",
        font = FONTS_NAME.font_haibao,
        align = ui.TEXT_ALIGN_CENTER,
        size = 28
    })
    heroNameLabel:setPosition(0, 0)
    self._rootnode["itemNameLabel"]:addChild(heroNameLabel)

    local clsLabel = ui.newTTFLabelWithShadow({
        text = "",
        font = FONTS_NAME.font_haibao,
        color = ccc3(46, 194, 49),
        size = 28
    })
    clsLabel:setPosition(heroNameLabel:getContentSize().width / 2, 0)
    self._rootnode["itemNameLabel"]:addChild(clsLabel)


    local _index = param.index
    display.addSpriteFramesWithFile("ui_zhenrong.plist", "ui_zhenrong.png")
    local pt = self._rootnode["scrollView"]:convertToWorldSpace(ccp(0, 0))
    --
--    self._rootnode["scrollView"]:setContentOffset(CCPointMake(0, -self._rootnode["contentView"]:getContentSize().height + self._rootnode["scrollView"]:getViewSize().height), false)

    local _info     = param.info["1"]
    local _changeHeroListener = param.changeHero
    local _refreshHeroListener = param.refreshHero
    local _baseInfo = ResMgr.getCardData(_info.resId)
    self._objId = _info["_id"]
    _info.objId = _info["_id"]


    if _info.resId == 1 or _info.resId == 2 then
        self._rootnode["changeBtn"]:setVisible(false)
    end

    if _info.resId == 1 or _info.resId == 2 or _info.resId == 10 then
        self._rootnode["qiangHuBtn"]:setVisible(false)
    end

    --是否从阵容进来的？如果不是阵容进来的 则屏蔽“更换侠客”按钮，且显示加锁按钮
    self.infoType = infoType
    if infoType == 2 then
        self._rootnode["changeBtn"]:setVisible(false)
        self.cellIndex = param.cellIndex
        self.createJinjieLayer = param.createJinjieLayer
        self.createQiangHuaLayer = param.createQiangHuaLayer

         -- if self.resID == 1 or self.resID == 2 then
        self._rootnode["lock_node"]:setVisible(false)
        self:initLock()
    else
        self._rootnode["changeBtn"]:setVisible(true)
        self._rootnode["lock_node"]:setVisible(false)

    end
    self._rootnode["titleLabel"]:setString("侠客信息")

    self.refresh = function(_)
        self._rootnode["contentViewNode"]:removeAllChildrenWithCleanup(true)

        local nameText = ""
        if _baseInfo.id == 1 or _baseInfo.id == 2 then
            nameText = game.player:getPlayerName()
        else
            nameText = _baseInfo.name
        end

        heroNameLabel:setString(nameText)
        heroNameLabel:setColor(NAME_COLOR[self._detailInfo.star])


        if self._detailInfo.cls > 0 then
--            local clsLabel = ui.newTTFLabelWithShadow({
--                text = string.format("+%d", self._detailInfo.cls),
--                font = FONTS_NAME.font_haibao,
--                color = ccc3(46, 194, 49),
--                size = 28
--            })
            clsLabel:setString(string.format("+%d", self._detailInfo.cls))
            clsLabel:setPosition(heroNameLabel:getContentSize().width / 2 + clsLabel:getContentSize().width / 2, 0)
--            self._rootnode["itemNameLabel"]:addChild(clsLabel)
        end

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
                                self._detailInfo.shenLvAry[k] = data["2"][k]
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
--                dump(stInfo)

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

                            self._detailInfo.shenLvAry[ind + 1] = stInfo.lv
                        end
                    end,
                    cid = _info.objId,
                    ind = ind
                })
            end
            --
            --            dump(_baseInfo.talent)
            dump(self._detailInfo)
            for k, v in ipairs(_baseInfo.talent) do
                local stData = data_shentong_shentong[v]

                if data_talent_talent[self._detailInfo.shenIDAry[k]] == nil then
                    CCMessageBox(string.format("id not int data_shentong_shentong： %d", self._detailInfo.shenIDAry[k]), "Tip")
                else
                    local t = {
                        info = data_talent_talent[self._detailInfo.shenIDAry[k]],
                        map  = stData,
                        lv   = self._detailInfo.shenLvAry[k] or 1
                    }
                    table.insert(st, t)
                end

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

        --      技能 普通技能 1 怒气技能2
        local function addJNItem()
            local t = {}
            if _baseInfo.skill[self._detailInfo.cls + 1] then
                table.insert(t, {
                    info = data_battleskill_battleskill[_baseInfo.skill[self._detailInfo.cls + 1]],
                    t    = 1
                })
            end

            if _baseInfo.angerSkill[self._detailInfo.cls + 1] then
                table.insert(t, {
                    info = data_battleskill_battleskill[_baseInfo.angerSkill[self._detailInfo.cls + 1]],
                    t = 2
                })
            end

            local item = JNItem.new(t)
            item:setPosition(self._rootnode["contentView"]:getContentSize().width / 2, -height + 40)
            --            self._rootnode["contentView"]:addChild(item)
            --            contentViewNode
            self._rootnode["contentViewNode"]:addChild(item)
            height = height + item:getContentSize().height + 2
        end

        --羁绊
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
        self:removeSelf()

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
--        pop_scene()
        if self.removeListener ~= nil then
            self.removeListener()
        end
        self:removeSelf()
    end

    local function qiangHua()
        self._rootnode["qiangHuBtn"]:setEnabled(false)
        PostNotice(NoticeKey.REMOVE_TUTOLAYER)
        if infoType == 2 then
            self.createQiangHuaLayer(
                _info.objId,
                self.cellIndex,
                function()
                    self._rootnode["qiangHuBtn"]:setEnabled(true)
                    self:requestHeroInfo()
                end)
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
                    self._rootnode["qiangHuBtn"]:setEnabled(true)
                    self:requestHeroInfo()
                end
            })
            game.runningScene:addChild(aaa, 102)
        end
    end

    local function jinJie()
        self._rootnode["jinJieBtn"]:setEnabled(false)
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
                        self._rootnode["jinJieBtn"]:setEnabled(true)
                        self:requestHeroInfo()
                    end
                })
                self:addChild(jinJieLayer, 102)
            end
        elseif infoType == 2 then 
            local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.XiaKe_JinJie, game.player:getLevel(), game.player:getVip()) 
            if not bHasOpen then 
                show_tip_label(prompt)
            else
                self.createJinjieLayer(_info.objId,self.cellIndex, function()
                    self._rootnode["jinJieBtn"]:setEnabled(true)
                    self:requestHeroInfo()
                end)
            end
        elseif infoType == 3 then
            close()
        end
    end

    resetbtn(self._rootnode["closeBtn"], bgNode, 1)

    self._rootnode["closeBtn"]:setVisible(true)
    self._rootnode["closeBtn"]:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
    self._rootnode["changeBtn"]:addHandleOfControlEvent(change, CCControlEventTouchUpInside)
    self._rootnode["qiangHuBtn"]:setEnabled(false)
    self._rootnode["qiangHuBtn"]:addHandleOfControlEvent(qiangHua, CCControlEventTouchUpInside)
    self._rootnode["jinJieBtn"]:setEnabled(false)
    self._rootnode["jinJieBtn"]:addHandleOfControlEvent(jinJie, CCControlEventTouchUpInside)


    TutoMgr.addBtn("hero_info_qianghua_btn",self._rootnode["qiangHuBtn"])

    if _baseInfo.advance == 1 then
        self._rootnode["jinJieBtn"]:setVisible(true)
    else
        self._rootnode["jinJieBtn"]:setVisible(false)
    end

    if infoType == 3 then
        self._rootnode["changeBtn"]:setVisible(false)
        self._rootnode["qiangHuBtn"]:setVisible(false)
        resetctrbtnimage( self._rootnode["jinJieBtn"], "#heroinfo_return.png")
    end

    self:refreshHeroInfo(param.info)

    if _index == 1 then
        self._rootnode["changeBtn"]:setVisible(false)
    end
    local touchMaskLayer = require("utility.TouchMaskLayer").new({
        btns = {
            self._rootnode["jinJieBtn"],
            self._rootnode["qiangHuBtn"],
            self._rootnode["changeBtn"],
            self._rootnode["closeBtn"]
        },
        contents = {
            CCRectMake(0, 81, self._rootnode["descView"]:getContentSize().width, self._rootnode["descView"]:getContentSize().height)
        }
    })
    self:addChild(touchMaskLayer, 100)
end

function HeroInfoLayer:refreshHeroInfo(data)
    self._detailInfo = data["1"]
    self._detailInfo.levelLimit = data["2"]

    self:refresh()
    local addBtn
    local label
    if self.getUpgradeBtn1 then
        addBtn = self:getUpgradeBtn1()
    end

    if self.getNumLabel then
        label = self:getNumLabel()
    end

    if self.infoType == 2 then

        if self._detailInfo.lock == 0 then
            self._rootnode["lock_btn"]:setVisible(true)
            self._rootnode["unlock_btn"]:setVisible(false)
        else
            self._rootnode["lock_btn"]:setVisible(false)
            self._rootnode["unlock_btn"]:setVisible(true)
        end

        if self._detailInfo.resId == 1 or self._detailInfo.resId == 2 then
            self._rootnode["lock_node"]:setVisible(false)
        else
            self._rootnode["lock_node"]:setVisible(true)
        end
    end
    local closeBtn = self._rootnode["closeBtn"]

    TutoMgr.addBtn("heroinfo_shentong_num",label)
    TutoMgr.addBtn("heroinfo_shentong_plus",addBtn)
    TutoMgr.addBtn("heroinfo_close_btn",closeBtn)

    TutoMgr.active()
    self._rootnode["jinJieBtn"]:setEnabled(true)
    self._rootnode["qiangHuBtn"]:setEnabled(true)
end

function HeroInfoLayer:requestHeroInfo()

--    RequestHelper.hero.info({
--        cid = self._info.objId,
--        callback = function(data)
--            if string.len(data["0"]) > 0 then
--                CCMessageBox(data["0"], "Tip")
--            else
--
--            end
--        end
--    })
    require("game.Hero.HeroCtrl").request(self._objId, handler(self, HeroInfoLayer.refreshHeroInfo))
end

function HeroInfoLayer:onExit()

   TutoMgr.removeBtn("hero_info_qianghua_btn")
   TutoMgr.removeBtn("heroinfo_shentong_num")
   TutoMgr.removeBtn("heroinfo_shentong_plus")
   TutoMgr.removeBtn("heroinfo_close_btn")
end


return HeroInfoLayer


