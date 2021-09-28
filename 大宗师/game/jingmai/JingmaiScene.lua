--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-8-4
-- Time: 下午4:36
-- To change this template use File | Settings | File Templates.
--
local data_jingmai_jingmai = require("data.data_jingmai_jingmai")
local data_item_nature = require("data.data_item_nature")
local JingmaiScene = class("JingmaiScene", function()
    return require("game.BaseSceneExt").new({
        -- topFile    = "public/top_frame.ccbi",
        contentFile = "jingmai/jingmai_scene.ccbi"
    })
end)

-- tp:  经脉【1-3】
-- pos: 当前穴位【1-8】
local function getChannel(tp, pos)
    for _, v in ipairs(data_jingmai_jingmai) do
        if v.type == tp then
            if v.order == pos then
                return v
            end
        end
    end
end

local function getValue(t, l)
    local ret = 0
    for k, v in ipairs(t.arr_value) do
        if k <= l then
            ret = ret + v
        else
            break
        end
    end
    return ret
end


local NAME_MAPPING = {"强控", "坚守", "急攻"}
function JingmaiScene:ctor()
    game.runningScene = self
    ResMgr.createBefTutoMask(self)

--    local _bg = display.newSprite("ui_common/jingmai_gx_bg.jpg")
--    local _bg = display.newSprite("ui_common/jingmai_sw_bg.jpg")

--    _bg:setScaleX(display.width / _bg:getContentSize().width)
--    _bg:setScaleY(self:getContentHeight() / _bg:getContentSize().height)

    local proxy = CCBProxy:create()
    self._animNode = CCBuilderReaderLoad("jingmai/jingmai_open_anim.ccbi", proxy, self._rootnode)
    self._animNode:retain()
--    animNode:setPosition(display.cx, display.cy)
--    self:addChild(animNode, 100)
    self:setNodeEventEnabled(true)

    self.top = require("game.scenes.TopLayer").new()
    self:addChild(self.top,1)
    if (display.widthInPixels / display.heightInPixels) == 0.75 then
        self._rootnode["tag_hero_pos"]:setScale(0.9)
        -- self._rootnode["tag_hero_pos"]:setPositionY(self._rootnode["tag_hero_pos"]:getPositionY()+45)
    elseif(display.widthInPixels / display.heightInPixels) > 0.66 then
        -- self._rootnode["tag_hero_pos"]:setScale(0.85)       
        -- self._rootnode["tag_hero_pos"]:setPositionY(self._rootnode["tag_hero_pos"]:getPositionY()+150)    
    else -- 
        self._rootnode["tag_hero_pos"]:setScale(1.2)  
        self._rootnode["tag_hero_pos"]:setPositionY(self._rootnode["tag_hero_pos"]:getPositionY()+70)    
    end
    

    if(game.player.m_gender == 2) then
        self._rootnode["jingmai_bg_male"]:setVisible(false)
        self._rootnode["jingmai_bg_female"]:setVisible(true)
    end

    self._rootnode["backBtn"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        GameStateManager:ChangeState(GAME_STATE.STATE_MAIN_MENU)
    end, CCControlEventTouchDown)

    self._rootnode["upgradeBgn"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if self._info.level == 0 and self._info.order == 0 then
            show_tip_label("已经达到最大等级")
            return
        end

        if self._info.type ~= 0 and self._index ~= self._info.type then
            show_tip_label(string.format("请切换到【%s】界面", NAME_MAPPING[self._info.type]))
            return
        end

        if checknumber(self._rootnode["needStarLabel"]:getString()) > self._starNum then
--            show_tip_label("副本星数不足，通关新关卡可获得更多副本星数")
            show_tip_label(data_error_error[2200005].prompt)
            return
        end

        if checknumber(self._rootnode["needSilverLabel"]:getString()) > game.player:getSilver() then
            show_tip_label("当前银币不足")
            return
        end

        local t
        if self._info.type == 0 then
            t = self._index
        else
            t = nil
        end
        RequestHelper.channel.upgrade({
            callback = function(data)
                dump(data)
                if string.len(data["0"]) > 0 then
                    CCMessageBox(data["0"], "Tip")
                else

                    self:runAnim(self._info.order - 1, self._info.order)

                    self._starNum = data["1"]        --副本星数
                    game.player:setSilver(data["2"]) --银币数
                    self._info.type = self._index
                    self._info.order = data["4"]           --穴位
                    self._info.level = data["3"]           --等级

                    self:refresh()
                end
            end,
            t = t
        })
--        self:runAnim(1, 6)
    end, CCControlEventTouchDown)

    local function reset()
        RequestHelper.channel.reset({
            callback = function(data)
                if string.len(data["0"]) > 0 then
                    CCMessageBox(data["0"], "Tip")
                else
                    dump(data)
                    self._rootnode["previewSprite"]:setVisible(true)
                    self._rootnode["upgradeBgn"]:setVisible(true)

                    self._starNum = data["1"]        --副本星数
                    game.player:setGold(data["2"])   --金币数
                    self._itemNum = data["3"]        --道具数

                    self._info = {
                        type  = 0,           --类型
                        order = 1,           --穴位
                        level = 1            --等级
                    }
                    self:refresh()
                end

            end})
    end

--  洗经伐脉
    self._rootnode["resetBtn"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if 50 > game.player:getGold() then
            show_tip_label("元宝不足")
            return
        end

        if self._info.type == 0 then
            show_tip_label("当前没有可重置的经脉")
            return
        end

        local layer = require("utility.MsgBox").new({
            size = CCSizeMake(500, 200),
            leftBtnName = "取消",
            rightBtnName = "确定",
            content = "确定花费50元宝重置经脉吗？",
            leftBtnFunc = function()

            end,
            rightBtnFunc = function()
                reset()
            end
        })
        self:addChild(layer, 100)
    end, CCControlEventTouchDown)

    local function onChangeView(_, sender)
        self._index = sender:getTag()
        self:refreshBg()
        self:refresh()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end

    for i = 1, 3 do
        self._rootnode["jingmaiBtn_" .. tostring(i)]:addHandleOfControlEvent(onChangeView, CCControlEventTouchDown)
    end

    self._index = 1
    self:refreshBg()
    self:request()
end

function JingmaiScene:refreshBg()
    for i = 1, 3 do
        self._rootnode[string.format("type_%d", i)]:setVisible(self._index == i)

        if (display.widthInPixels / display.heightInPixels) > 0.67 then
            self._rootnode[string.format("type_%d", i)]:setScale(0.9)
        end
    end


    if self._bg then
        self._bg:removeSelf()
    end

    self._bg = display.newScale9Sprite(string.format("#jingmai_hero_bg_%d.png", self._index), 0,0,CCSize(display.width, self:getContentHeight()),  CCRectMake(10, 10, 20, 20))
    self._bg:setPosition(display.width / 2, self:getBottomHeight() + self:getContentHeight() / 2)
    self:addChild(self._bg)
end

-- pos1: 原始点
-- pos2: 目标点
function JingmaiScene:runAnim(pos1, pos2)

    local anim = {}
    for i = pos1, pos2 do
        if i > 0 and i < pos2 then
            printf("============ %d", i)
            --角度 位置
            local angle = self._rootnode[string.format("line_%d_%d", self._index, i)]:getTag()
            local pos = self._rootnode[string.format("board_%d_%d", self._index, i + 1)]:convertToWorldSpace(ccp(42.5, 42.5))

            table.insert(anim, CCRotateTo:create(0, angle))
            table.insert(anim, CCMoveTo:create(0.1, pos))
        end
    end

    table.insert(anim, CCCallFunc:create(function()
        local proxy = CCBProxy:create()
        local node = CCBuilderReaderLoad("jingmai/jingmai_upgrade_anim.ccbi", proxy, {})
        node:runAction(transition.sequence({
            CCDelayTime:create(0.5),
            CCRemoveSelf:create()
        }))
        node:setPosition(self._rootnode[string.format("board_%d_%d", self._index, pos2)]:convertToWorldSpace(ccp(42.5, 42.5)))
        self:addChild(node, 101)
    end))
    table.insert(anim, CCFadeOut:create(0))
    table.insert(anim, CCDelayTime:create(0.1))
    table.insert(anim, CCRemoveSelf:create())

    local sprite = display.newSprite("#jingmai_anim_1.png")
    if pos1 < 1 then
        pos1 = 1
    end
    sprite:setPosition(self._rootnode[string.format("board_%d_%d", self._index, pos1)]:convertToWorldSpace(ccp(42.5, 42.5)))
    self:addChild(sprite, 100)
    sprite:runAction(transition.sequence(anim))
end

function JingmaiScene:onFullLevel()
    self._rootnode["previewSprite"]:setVisible(false)
    self._rootnode["upgradeBgn"]:setVisible(false)

    show_tip_label("经脉已修炼至顶级，无法提升")


    for i = 1, 8 do
        if i < 8 then
            local key1 = string.format("line_%d_%d", self._index, i)
            self._rootnode[key1]:setDisplayFrame(display.newSpriteFrame(string.format("jingmai_line_%d.png", self._index)))
        end

        local key2 = string.format("board_%d_%d", self._index, i)
        self._rootnode[string.format("lvLabel_%d_%d", self._index, i)]:setString(string.format("Lv%d", #data_jingmai_jingmai[1].arr_value))
        self._rootnode[key2]:setDisplayFrame(display.newSpriteFrame("jingmai_icon_board_1.png"))
        self._rootnode[key2]:getChildByTag(1):setDisplayFrame(display.newSpriteFrame("jingmai_xuedao_3.png"))
    end

    self._animNode:removeFromParentAndCleanup(false)
    self:setPropValue(10, 9)
end

local function getValueStr(t, value)
    local str
    local pre

    if value > 0 then
        pre = "+"
    else
        pre = ""
    end

    if t == 2 then
        if value > 0 then
            str = string.format("%s%.1f%%", pre, value / 100)
        else
            str = "0"
        end
    else
        str = string.format("%s%d", pre, value)
    end
    return str
end

function JingmaiScene:setPropValue(lv, _order)
    --  设置属性
    for _, v in ipairs(data_jingmai_jingmai) do
        if v.type == self._index then
            local nat = data_item_nature[v.nature]
            self._rootnode[string.format("propNameLabel_%d", v.order)]:setString(string.format("%s：", nat.nature))
            local str
            if v.order < _order then
                str = getValueStr(nat.type, getValue(v, lv))
            else
                str = getValueStr(nat.type, getValue(v, lv - 1))
            end
            self._rootnode[string.format("propValueLabel_%d", v.order)]:setString(str)
        end
    end
end

--更新界面
function JingmaiScene:refresh()

--  获得穴位
    local _level = 1
    local _order = 1
    local item
    if self._info.type == self._index then
        _level = self._info.level
        _order = self._info.order

        if _level == 0 and _order == 0 then
            self:onFullLevel()
            return
        end
    end

    item = getChannel(self._index,_order)
    local nature = data_item_nature[item.nature]

    -- self._rootnode["silverLabel"]:setString(tostring(game.player:getSilver()))         --银子
    -- self._rootnode["goldLabel"]:setString(tostring(game.player:getGold()))
    self.top:setGodNum(game.player:getGold())
    self.top:setSilver(game.player:getSilver())

    local str
    if nature.type == 2 then
        str = string.format("%s +%.1f%%", item.describe, item.arr_value[_level] / 100)
    else
        str = string.format("%s +%d", item.describe, item.arr_value[_level])
    end

    self._rootnode["effectValueLabel"]:setString(str) --描述
    self._rootnode["needStarLabel"]:setString(tostring(item.arr_star[_level]))                                 --需要星数
    self._rootnode["needSilverLabel"]:setString(tostring(item.arr_coin[_level]))                               --需要银子

    self._rootnode["starCountLabel"]:setString("x" .. tostring(self._starNum))                                 --星数
    self._rootnode["totalItemLabel"]:setString(tostring(self._itemNum))                                        --总共需要物品

    self:setPropValue(_level, _order)

--  设置穴位
    for i = 1, 8 do
        local key = string.format("board_%d_%d", self._index, i)

        if i < _order or (_level > 1 and _order == 1)then
            self._rootnode[key]:setDisplayFrame(display.newSpriteFrame("jingmai_icon_board_1.png"))
            self._rootnode[key]:getChildByTag(1):setDisplayFrame(display.newSpriteFrame("jingmai_xuedao_2.png"))

            if _level > 1 and _order == 1 then
                self._rootnode[string.format("lvLabel_%d_%d", self._index, i)]:setString(string.format("Lv%d", _level - 1))

                if i == 1 then
                    self._animNode:setPosition(self._rootnode[key]:getContentSize().width / 2, self._rootnode[key]:getContentSize().height / 2)
                    self._animNode:removeFromParentAndCleanup(false)
                    self._rootnode[key]:addChild(self._animNode)
                end

            else
                self._rootnode[string.format("lvLabel_%d_%d", self._index, i)]:setString(string.format("Lv%d", _level))
                printf("3")
            end
        elseif i == _order then
            self._rootnode[key]:setDisplayFrame(display.newSpriteFrame("jingmai_icon_board_2.png"))
            self._rootnode[key]:getChildByTag(1):setDisplayFrame(display.newSpriteFrame("jingmai_xuedao_1.png"))
            self._rootnode[string.format("lvLabel_%d_%d", self._index, i)]:setString(string.format("Lv%d", _level - 1))

            self._animNode:setPosition(self._rootnode[key]:getContentSize().width / 2, self._rootnode[key]:getContentSize().height / 2)
            self._animNode:removeFromParentAndCleanup(false)
            self._rootnode[key]:addChild(self._animNode)
        else
            self._rootnode[key]:setDisplayFrame(display.newSpriteFrame("jingmai_icon_board_2.png"))
            self._rootnode[key]:getChildByTag(1):setDisplayFrame(display.newSpriteFrame("jingmai_xuedao_0.png"))
            self._rootnode[string.format("lvLabel_%d_%d", self._index, i)]:setString(string.format("Lv%d", _level - 1))

        end

        if _level > 1 then
            self._rootnode[key]:setDisplayFrame(display.newSpriteFrame("jingmai_icon_board_1.png"))
            if _level == 10 and i < _order then
                self._rootnode[key]:getChildByTag(1):setDisplayFrame(display.newSpriteFrame("jingmai_xuedao_3.png"))
            else
                self._rootnode[key]:getChildByTag(1):setDisplayFrame(display.newSpriteFrame("jingmai_xuedao_2.png"))
            end
        end
    end

--  设置线条
    for i = 1, 7 do
        local key = string.format("line_%d_%d", self._index, i)
        if i < _order - 1 then
            self._rootnode[key]:setDisplayFrame(display.newSpriteFrame(string.format("jingmai_line_%d.png", self._index)))
        else
            self._rootnode[key]:setDisplayFrame(display.newSpriteFrame("jingmai_line_hui.png"))
        end

        if _level > 1 then
            self._rootnode[key]:setDisplayFrame(display.newSpriteFrame(string.format("jingmai_line_%d.png", self._index)))
        end
    end

    if self._info.type == 0 then
        self._rootnode["resetBtn"]:setEnabled(false)
    else
        self._rootnode["resetBtn"]:setEnabled(true)
    end

    if self._info.type == 0 or self._info.type == self._index then
        self._rootnode["infoNode"]:setVisible(true)
    else
        self._rootnode["infoNode"]:setVisible(false)
    end

end
--
function JingmaiScene:request()
--    1:副本星数
--    2:下个升级穴位	[0-8]
--    3:金币数
--    4:银币数
--    5:升级后等级 [0-10]
--    6:经脉类型  	0-无 1-神武 2-太乙 3-归墟
--    7:道具数
    RequestHelper.channel.info({
        callback = function(data)
            dump(data)
            if string.len(data["0"])  > 0 then
                CCMessageBox(data["0"], "Error")
            else
                self._starNum = data["1"]        --副本星数
                game.player:setGold(data["3"])   --金币数
                game.player:setSilver(data["4"]) --银币数

                self._info = {
                    type  = data["6"],   --类型

                    order = data["2"],   --穴位 穴位和等级都为0时候，满级
                    level = data["5"]    --等级
                }
                self._itemNum = data["7"]        --道具数

                self:refresh()
            end
        end
    })
end

function JingmaiScene:onEnter()
    local tisheng_btn = self._rootnode["upgradeBgn"]
    TutoMgr.addBtn("tisheng_btn",tisheng_btn)
    TutoMgr.active()
end

function JingmaiScene:onExit()
    TutoMgr.removeBtn("tisheng_btn")
    self._animNode:release()
end

return JingmaiScene

