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
-- 日期：14-10-20
--

local data_item_nature = require("data.data_item_nature")
local data_refine_refine = require("data.data_refine_refine")
local data_jiban_jiban = require("data.data_jiban_jiban")
local data_shangxiansheding_shangxiansheding = require("data.data_shangxiansheding_shangxiansheding")
local data_item_item = require("data.data_item_item")
--
local BaseSkillInfoLayer = class("BaseSkillInfoLayer", function()
    return require("utility.ShadeLayer").new(ccc4(0, 0, 0, 155))
end)

local RequestInfo = require("network.RequestInfo")
local Item = class("Item", function(heroid, data)

    local proxy = CCBProxy:create()
    local rootnode = {}
    local node = CCBuilderReaderLoad("skill/skill_jiban.ccbi", proxy, rootnode)

    rootnode["skillName"]:setString(data.name)
    local color, cls
    if heroid == 1 or heroid == 2 then
        heroid = game.player.m_gender
        color = NAME_COLOR[game.player:getStar()]
        cls = game.player:getClass()
    end


    local cardData = ResMgr.getCardData(heroid)
    color = color or NAME_COLOR[cardData.star[1]]
    if cardData then
        local name = cardData.name
        if heroid == 1 or heroid == 2 then
            name = game.player:getPlayerName()
        end

        local nameLabel = ui.newTTFLabelWithShadow({
            text = name,
            font = FONTS_NAME.font_fzcy,
            size = 20,
            color = color,
            align = ui.TEXT_ALIGN_CENTER
        })
        rootnode["heroName"]:addChild(nameLabel)

    else
        rootnode["heroName"]:setString("告诉策划没有此卡牌id：" .. tostring(heroid))
    end

    ResMgr.refreshIcon({
        itemBg = rootnode["headIcon"],
        id = heroid,
        resType = ResMgr.HERO,
        cls = cls
    })


    local nature = data_item_nature[data.nature1]
    local str = nature.nature
    if nature.type == 1 then
        str = str .. "+" .. tostring(data.value1)
    else
        str = str .. string.format("+%d%%", data.value1 / 100)
    end
    rootnode["jibanDes"]:setString(string.format("%s%s", data.describe, str))
    return node
end)

function BaseSkillInfoLayer:ctor(param)
    local _info     = param.info
    local _subIndex = param.subIndex
    local _index    = param.index
    local _listener = param.listener
    local _bEnemy   = param.bEnemy
    local _closeListener = param.closeListener
    local _baseInfo = data_item_item[_info.resId]
    local refineInfo = data_refine_refine[_info.resId]

    dump(_info)

    self._proxy = CCBProxy:create()
    self._rootnode = {}

    local winSize
    local nodePos
    local bScroll
    if refineInfo and refineInfo.arr_jiban then

        winSize = CCSizeMake(display.width, display.height - 30)
        nodePos = ccp(display.width / 2, 0)
        bScroll = true
    else

        if _bEnemy then
            winSize = CCSizeMake(display.width, 700)
        else
            winSize = CCSizeMake(display.width, 760)
        end

        nodePos = ccp(display.width / 2, display.cy - winSize.height / 2)
        bScroll = false
    end


    local bgNode = CCBuilderReaderLoad("skill/skill_info.ccbi", self._proxy, self._rootnode, self, winSize)
    self:addChild(bgNode, 1)
    bgNode:setPosition(nodePos)

    --  屏幕高 - 广播条 - 底部按钮 - 标题栏
    local infoNode
    if _bEnemy then
        infoNode = CCBuilderReaderLoad("skill/skill_detail.ccbi", self._proxy, self._rootnode, self, CCSizeMake(winSize.width, winSize.height - 2 - 20 - 68))
        infoNode:setPosition(ccp(0, 20))
        bgNode:addChild(infoNode)
        self._rootnode["bottomMenuNode"]:setVisible(false)

    else
        infoNode = CCBuilderReaderLoad("skill/skill_detail.ccbi", self._proxy, self._rootnode, self, CCSizeMake(winSize.width, winSize.height - 2 - 85 - 68))
        infoNode:setPosition(ccp(0, 85))
        bgNode:addChild(infoNode)
    end

    self._rootnode["scrollView"]:setTouchEnabled(bScroll)


    self._rootnode["titleLabel"]:setString("武学信息")
    self._rootnode["closeBtn"]:setVisible(true)
    self._rootnode["closeBtn"]:addHandleOfControlEvent(function()
        if _closeListener then
            _closeListener()
        end
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
        self:removeSelf()
    end, CCControlEventTouchUpInside)

    local heroName = ui.newTTFLabelWithShadow({
        text = _baseInfo.name,
        font = FONTS_NAME.font_haibao,
        size = 30,
        align = ui.TEXT_ALIGN_CENTER,
        color = NAME_COLOR[_info.star]
    })
    self._rootnode["itemNameLabel"]:addChild(heroName)

    self._rootnode["descLabel"]:setString(_baseInfo.describe)

    self._rootnode["cardName"]:setString(_baseInfo.name)
    --    self._rootnode["cardName"]:setColor(NAME_COLOR[1])
    local function change()
        self._rootnode["changeBtn"]:setEnabled(false)

--        CCDirector:sharedDirector():popToRootScene()
        push_scene(require("game.form.SkillChooseScene").new({
            index = _index,
            subIndex = _subIndex,
            cid      = _info.cid,
            callback = function(data)
                if data then
                    _listener(data)
                end
                self:removeSelf()
            end
        }))
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end

    local function getIndexById(id)
        for k, v in ipairs(game.player:getSkills()) do
            if v._id == id then
                return k
            end
        end
    end

    local function takeOff()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        RequestHelper.formation.putOnEquip({
            pos = _index,
            subpos = _subIndex,
            callback = function(data)
                if string.len(data["0"]) > 0 then
                    CCMessageBox(data["0"], "Tip")
                else
                    _info.pos = 0
                    _info.cid = 0
                    if _listener then
                        _listener(data)
                    end
                    self:removeSelf()
                end
            end
        })
    end

    local function refine()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        local req = RequestInfo.new({
            modulename = "skill",
            funcname   = "refine",
            param      = {
                op = 1,
                cids = _info._id
            },
            oklistener = function(data)
                data["2"]._id = _info._id
                push_scene(require("game.skill.SkillRefineScene").new({
                    info = data["2"],
                    bAllow = data["1"],
                    next = {idx = data["3"], val = data["4"]},
                    objs = data["5"],
                    cost = data["6"],
                    callback = function()

                    end
                }))
            end
        })

        RequestHelperV2.request(req)
    end

    --  星级
    for i = 1, _info.star do
        self._rootnode[string.format("star%d", i)]:setVisible(true)
    end

    self._rootnode["cardImageBg"]:setDisplayFrame(display.newSpriteFrame(string.format("item_card_bg_%d.png", _info.star)))

    --  大图标
    local path = ResMgr.getLargeImage( _baseInfo.bicon, ResMgr.EQUIP )
    self._rootnode["skillImage"]:setDisplayFrame(display.newSprite(path):getDisplayFrame())

    local function refresh()
        self._rootnode["curLvLabel"]:setString(_info.level)
        --  基本属性
        local index = 1
        for i = 1, 4 do
            local prop = _info.baseRate[i]
            local str = ""
            if prop > 0 then
                local nature = data_item_nature[BASE_PROP_MAPPPING[i]]
                if nature.type == 1 then
                    str = string.format("+%d", prop)
                else
                    str = string.format("+%.2f%%", prop / 100)
                end
                self._rootnode["basePropLabel_" .. tostring(index)]:setString(str)
                self._rootnode["stateName" .. tostring(index)]:setString(nature.nature .. tostring("："))
                index = index + 1
            end
        end

        -- --  精炼属性(暂时无功能，隐藏掉)
        -- for k, v in ipairs(_info.props) do
        --     local nature = data_item_nature[v.idx]
        --     if nature then
        --         local str = ""
        --         if v.val > 0 then
        --             if nature.type == 1 then
        --                 str = "+" .. tostring(v.val)
        --             else
        --                 str = string.format("+%d%%", v.val / 100)
        --             end
        --         else
        --             str = "0"
        --         end
        --         self._rootnode["nbPropLabel_" .. tostring(k)]:setString(nature.nature .. "：")
        --         self._rootnode["nbPropValueLabel_" .. tostring(k)]:setString(str)

        --     end
        -- end

--        local refineInfo = data_refine_refine[_info.resId]
--        if refineInfo and refineInfo.arr_nature1 then
--            for k, v in ipairs(refineInfo.arr_nature1) do
--                local proName = string.format("lockPropLabel_%d", k)
--                if _info.level >= refineInfo.arr_level[k] then
--                    self._rootnode[proName]:setColor(ccc3(255, 114, 0))
--                end
--            end
--        else
--            self._rootnode["lockPropLabel_1"]:setVisible(true)
--        end
    end

    --  解锁属性
    if refineInfo and refineInfo.arr_nature1 then
        for k, v in ipairs(refineInfo.arr_nature1) do
            local nature = data_item_nature[v]
            local str = nature.nature
            if nature.type == 1 then
                str = str .. "：+" .. tostring(refineInfo.arr_value1[k])
            else
                str = str .. string.format("：+%d%%", refineInfo.arr_value1[k] / 100)
            end


            if refineInfo.arr_level[k] <= data_shangxiansheding_shangxiansheding[8].level then
                local proName = string.format("lockPropLabel_%d", k)
                if _info.level >= refineInfo.arr_level[k] then
                    self._rootnode[proName]:setColor(ccc3(147, 5, 0))
                else
                    str = str .. string.format(" (%d级解锁)", refineInfo.arr_level[k])
                end


                self._rootnode[proName]:setString(str)
                self._rootnode[proName]:setVisible(true)
            end
        end
    else
        self._rootnode["lockPropLabel_1"]:setVisible(true)
    end

    --  羁绊
    local height = self._rootnode["jiBanNode"]:getContentSize().height + 50
    if refineInfo and refineInfo.arr_jiban ~= nil then
        for k, v in ipairs(refineInfo.arr_jiban) do
            if refineInfo.arr_card[k] then
                local item = Item.new(refineInfo.arr_card[k], data_jiban_jiban[v])
                height = height + item:getContentSize().height
                item:setPosition(self._rootnode["contentView"]:getContentSize().width / 2, -(k - 1) * item:getContentSize().height - self._rootnode["jiBanNode"]:getContentSize().height - 30)
                self._rootnode["contentView"]:addChild(item, 1)
            else
                __G__TRACKBACK__(string.format("please check arr_jiban and arr_card: sikllid = %d", _info.resId))
            end
        end

        local jbNode = CCBuilderReaderLoad("skill/skill_jiban_bg.ccbi", self._proxy, self._rootnode, self, CCSizeMake(winSize.width, height - self._rootnode["jiBanNode"]:getContentSize().height + 10))
        jbNode:setPosition(ccp(display.width / 2, - self._rootnode["jiBanNode"]:getContentSize().height + 15))
        self._rootnode["contentView"]:addChild(jbNode, 0)

    else
        self._rootnode["jiBanNode"]:setVisible(false)
    end

    local sz = CCSizeMake(self._rootnode["contentView"]:getContentSize().width, self._rootnode["contentView"]:getContentSize().height + height)
    self._rootnode["descView"]:setContentSize(sz)
    self._rootnode["contentView"]:setPosition(ccp(sz.width / 2, sz.height))
    self._rootnode["scrollView"]:updateInset()
    self._rootnode["scrollView"]:setContentOffset(CCPointMake(0, -sz.height + self._rootnode["scrollView"]:getViewSize().height), false)

    refresh()
    if _subIndex and _index then
        self._rootnode["changeBtn"]:addHandleOfControlEvent(change, CCControlEventTouchUpInside)
        self._rootnode["takeOffBtn"]:addHandleOfControlEvent(takeOff, CCControlEventTouchUpInside)
    else

        self._rootnode["changeBtn"]:setVisible(false)
        self._rootnode["takeOffBtn"]:setVisible(false)
    end

    local function qiangHu()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if _info.level >= 30 then
            show_tip_label("武学已经达到最大强化等级")
            return
        end

        local req = RequestInfo.new({
            modulename = "skill",
            funcname   = "qianghua",
            param      = {
                op = 1,
                cids = _info._id
            },
            oklistener = function(data)
                self:setVisible(false)
                data["1"]._id = _info._id
                local layer = require("game.skill.SkillQiangHuaLayer").new({
                    info = data["1"],
                    callback = function()
                        _info.baseRate = data["1"].baseRate
                        _info.level = data["1"].lv
                        refresh()

                        if _listener then
                            _listener()
                        end
                        self:removeSelf()
                    end
                })
                game.runningScene:addChild(layer, 10)
                game.player:setSilver(data["2"])
            end
        })

        RequestHelperV2.request(req)
    end

    self._rootnode["qiangHuBtn"]:addHandleOfControlEvent(qiangHu, CCControlEventTouchUpInside)

    --    if data_refine_refine[_info.resId] and data_refine_refine[_info.resId].Refine and data_refine_refine[_info.resId].Refine > 0 then
    --        self._rootnode["xiLianBtn"]:setVisible(true)
    --    else
    --        self._rootnode["xiLianBtn"]:setVisible(false)
    --    end
    self._rootnode["xiLianBtn"]:setVisible(false)

    if _baseInfo.pos >= 101 and _baseInfo.pos <= 104 then
        self._rootnode["qiangHuBtn"]:setVisible(false)
    end

    self._rootnode["xiLianBtn"]:addHandleOfControlEvent(refine, CCControlEventTouchUpInside)
end


return BaseSkillInfoLayer



