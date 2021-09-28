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
--                Buddha bless
--

--
local data_refine_refine = require("data.data_refine_refine")
local data_item_nature = require("data.data_item_nature")
local data_kongfu_kongfu = require("data.data_kongfu_kongfu")
local data_item_item = require("data.data_item_item")
local data_shangxiansheding_shangxiansheding = require("data.data_shangxiansheding_shangxiansheding")
require("data.data_error_error")

local SkillQiangHuaLayer = class("SkillQiangHuaLayer", function (param)
    return require("utility.ShadeLayer").new(ccc4(0, 0, 0, 155))
end)

function SkillQiangHuaLayer:onEnter()
    -- body
end

function SkillQiangHuaLayer:onExit()
    -- body
    ResMgr.ReleaseUIArmature("u_gongfaqianghua1")
    ResMgr.ReleaseUIArmature("u_gongfaqianghua2_diceng")
    ResMgr.ReleaseUIArmature("u_gongfaqianghua2_dingceng")
end


local BAR_SIZE
function SkillQiangHuaLayer:ctor(param)
    self._proxy = CCBProxy:create()
    self._rootnode = {}

    local bgNode = CCBuilderReaderLoad("skill/skill_qianghua.ccbi", self._proxy, self._rootnode)
    bgNode:setPosition(display.cx, display.cy)
    self:addChild(bgNode)

    self._info = param.info
    self._selected = {}
    local _callback = param.callback
    dump(self._info)

    local _pos = data_item_item[self._info.resId].pos
    self._listData = {}
    for k, v in ipairs(game.player:getSkills()) do

        if self._info._id ~= v._id and v.cid == 0 then
            if (data_item_item[v.resId].pos == (96 + _pos)) or
                    (_pos == data_item_item[v.resId].pos and data_item_item[v.resId].lysis and data_item_item[v.resId].lysis == 1) then
                table.insert(self._listData, {
                    baseData = data_item_item[v.resId],
                    data = v
                })
            end
        end
    end

    local function onChooseLayer(tag, sender)

        if self._info.lv >= data_shangxiansheding_shangxiansheding[4].level then
            show_tip_label(data_error_error[1000002].prompt)
            return
        end

        sender:setEnabled(false)
        push_scene(require("game.skill.SkillChooseScene").new({
            pos = data_item_item[self._info.resId].pos,
            id  = self._info._id,
            sel = self._selected,
            listData = self._listData,
            callback = function(selected)
                sender:setEnabled(true)
                self._selected = selected
                self:refreshIcon()
            end
        }))

    end

    --点击任何一个槽，都会弹出同一个列表，玩家可以通过列表 选择要吃掉的武学，更改武学table
    for i = 1, 5 do
        self._rootnode["btn"..i]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onChooseLayer)
    end

    self._rootnode["backBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        _callback()
        self:removeSelf()
    end,
    CCControlEventTouchUpInside)


    self._rootnode["qianghuaBtn"]:addHandleOfControlEvent(function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        if checkint(self._rootnode["costNum"]:getString()) > game.player:getSilver() then
            show_tip_label("您的银币不足")
            return
        end

        if get_table_len(self._selected) > 0 then
            self:runAnim()
            self:request(2)
        else
            show_tip_label("请选择要消耗的武学")
        end

    end, CCControlEventTouchUpInside)

    self._rootnode["autoBtn"]:addHandleOfControlEvent(function(eventName,sender)
        self:autoSelected()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end,
    CCControlEventTouchUpInside)

    BAR_SIZE = self._rootnode["blueBar"]:getTextureRect()

    self:initBaseInfo()
    self:refreshSkillInfo()

    self._bExit = false
end

function SkillQiangHuaLayer:runAnim()

    local len = get_table_len(self._selected)
    for i = 1, len do
        local effect = ResMgr.createArma({
            resType = ResMgr.UI_EFFECT,
            armaName = "u_gongfaqianghua1",
            isRetain = false,
            finishFunc = function()

            end
        })
        local tmpNode = self._rootnode["iconSprite"..i]
        local worldPos = tmpNode:convertToWorldSpace(ccp(tmpNode:getContentSize().width / 2, tmpNode:getContentSize().height / 2))
        worldPos = self._rootnode["card_bg"]:convertToNodeSpace(worldPos)
        effect:setPosition(worldPos)
        self._rootnode["card_bg"]:addChild(effect)

        local func
        if i == len then
            func = CCCallFunc:create(function()
                local effect = ResMgr.createArma({
                    resType = ResMgr.UI_EFFECT,
                    armaName = "u_gongfaqianghua2_diceng",
                    isRetain = false,
                    finishFunc = function()

                    end
                })
                effect:setPosition(self._rootnode["card_bg"]:getContentSize().width / 2, self._rootnode["card_bg"]:getContentSize().height / 2)
                self._rootnode["card_bg"]:addChild(effect)
                effect:setZOrder(0)

                effect = ResMgr.createArma({
                    resType = ResMgr.UI_EFFECT,
                    armaName = "u_gongfaqianghua2_dingceng",
                    isRetain = false,
                    finishFunc = function()

                    end
                })
                effect:setPosition(self._rootnode["image"]:getContentSize().width / 2, self._rootnode["image"]:getContentSize().height / 2)
                self._rootnode["image"]:addChild(effect)
            end)
        end
        effect:runAction(transition.sequence({
            CCMoveTo:create(0.2, ccp(self._rootnode["card_bg"]:getContentSize().width / 2, self._rootnode["card_bg"]:getContentSize().height / 2)),
            func
        }))
    end
end

function SkillQiangHuaLayer:clearIcon()
    for i = 1, 5 do
        self._rootnode["iconSprite" .. tostring(i)]:removeAllChildrenWithCleanup(true)
    end
end

function SkillQiangHuaLayer:autoSelected()
    local function count()
        local i = 0
        for k, v in pairs(self._selected) do
            if v then
                i = i + 1
            end
        end
        return i
    end

    local bAuto = false
    for k, v in ipairs(self._listData) do
        if count() >= 5 then
            break
        end

        if self._selected[k] ~= true then
            if v.baseData.autoadd == 1 then
                self._selected[k] = true
            else
                bAuto = true
            end
        end

    end

    if count() == 0 then
        if bAuto then
            show_tip_label("您没有满足自动添加条件的武学")
        else
            show_tip_label("武学数量不足")
        end

    end

    self:refreshIcon()
end

function SkillQiangHuaLayer:getIdsStr()
    local ids = {}
    table.insert(ids, self._info._id)

    for k, v in pairs(self._selected) do
        if v  then
            table.insert(ids, self._listData[k].data._id)
        end
    end

    local str = ""
    for k, v in ipairs(ids) do
        if k == #ids then
            str = str .. v
        else
            str = str .. v .. ","
        end

    end
    return str
end

function SkillQiangHuaLayer:updateList()
    local ids = {}
    for k, v in pairs(self._selected) do
        if v then
            table.insert(ids, self._listData[k].data._id)
        end
    end

    for _, id in ipairs(ids) do
        for k, v in ipairs(self._listData) do
            if v.data._id == id then
                table.remove(self._listData, k)
                break
            end
        end

        local skills = game.player:getSkills()
        for k, v in ipairs(skills) do
            if v._id == id then
                table.remove(skills, k)
                break
            end
        end
    end


end


function SkillQiangHuaLayer:request(opt)

    RequestHelper.sendKongFuQiangHuaRes({
        callback = function(data)
            dump(data)

            if #data["0"] > 0 then
                CCMessageBox(data["0"], "Tip")
            else
                if opt == 2 then
                    self:clearIcon()
                end
                data._id = self._info._id
--                self._info = data["1"]
--
                self._info.add = data["1"].add
                self._info.baseRate = data["1"].baseRate
                self._info.lv = data["1"].lv
                self._info.limit = data["1"].limit
                self._info.cost = data["1"].cost
                self._info.exp = data["1"].exp

                GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_qianghua))

                game.player:setSilver(data["2"])
                self:refreshSkillInfo()
                self:updateList()
                self._selected = {}

                PostNotice(NoticeKey.CommonUpdate_Label_Silver)
            end
        end,
        op = opt,
        cids = self:getIdsStr()
    })
end


--基础的信息
function SkillQiangHuaLayer:initBaseInfo()
    local baseData = data_item_item[self._info.resId]

    local pngName = baseData["bicon"]
    local pathName = ResMgr.getLargeImage(pngName, ResMgr.EQUIP)

    self._rootnode["card_bg"]:setDisplayFrame(display.newSprite("#item_card_bg_" .. self._info.star .. ".png"):getDisplayFrame())
    --名字
    self._rootnode["leftName"]:setString(baseData["name"])

    --中间的图像
    self._rootnode["image"]:setZOrder(10)
    self._rootnode["image"]:setDisplayFrame(display.newSprite(pathName):getDisplayFrame())

    local heroName = ui.newTTFLabelWithShadow({
        text = baseData["name"],
        font = FONTS_NAME.font_haibao,
        size = 30,
        align = ui.TEXT_ALIGN_CENTER,
        color = NAME_COLOR[self._info.star]
    })
    self._rootnode["itemNameLabel"]:addChild(heroName)


    --星级
    for i = 1, self._info.star do
        self._rootnode["star"..i]:setVisible(true)
    end
end

function SkillQiangHuaLayer:refreshSkillInfo()
    --bar
    local percent = 0
    if self._info["limit"] ~= 0 then
        percent = self._info["exp"] / self._info["limit"]
        if percent > 1 then
            percent = 1
        end
    end
    -- self._rootnode["blueBar"]:setScaleX(percent)
    local bar = self._rootnode["blueBar"]
    bar:setTextureRect(CCRectMake(bar:getTextureRect().origin.x, bar:getTextureRect().origin.y, BAR_SIZE.size.width * percent, BAR_SIZE.size.height))


    bar = self._rootnode["greenBar"]
    bar:setTextureRect(CCRectMake(bar:getTextureRect().origin.x, bar:getTextureRect().origin.y, BAR_SIZE.size.width * percent, BAR_SIZE.size.height))

--
    local baseNameStrs = {"生命：","攻击：","物防：","法防："}
    local baseState = self._info["baseRate"] or 0
    local addState = self._info["add"]
    local index  = 1
    for i  =1 ,4 do
        if  baseState[i] ~= 0 then
            self._rootnode["stateName".. index]:setVisible(true)
            self._rootnode["baseState".. index]:setVisible(true)
            self._rootnode["addState".. index]:setVisible(false)

            self._rootnode["stateName" .. index]:setString(baseNameStrs[i]) --设置名字
            self._rootnode["baseState" .. index]:setString(string.format("+%.2f%%", baseState[i] / 100))
--            if addState[i] ~= 0 then
--                self._rootnode["addState" .. index]:setString("+".. addState[i] / 100 .."%")
--            else
--                self._rootnode["addState" .. index]:setVisible(false)
--            end
            index = index + 1
        end
    end
    --额外解锁的属性
    local unlockStates = data_refine_refine[self._info["resId"]]
--    if unlockStates and unlockStates.Refine then
    if unlockStates and unlockStates.arr_nature1 then
        for k, v in ipairs(unlockStates.arr_level) do
            local extraState =  self._rootnode["extraState"..tostring(k)]
            extraState:setVisible(true)
            local nature = data_item_nature[unlockStates["arr_nature1"][k]]

            local nutureValue =  unlockStates["arr_value1"][k]
            local str = ""
            if nature["type"] == 1 then
                str = tostring(nature["nature"] .. " +"..nutureValue)
            elseif nature["type"] == 2 then
                str = tostring(nature["nature"] .. " +".. tostring(nutureValue / 100) .."%")
            end

            if v <= data_shangxiansheding_shangxiansheding[8].level then
                if self._info.lv < v then
                    str = str.."("..v.."级解锁)"
                    extraState:setColor(ccc3(137, 137, 137))
                else
                    extraState:setColor(ccc3(147, 5, 0))
                end
                extraState:setString(str)
            end
        end
    end

    --cur级别
    self._rootnode["curLevalLabel"]:setString(string.format("LV.%d", self._info.lv))
    --消耗银币和获得经验

    self._rootnode["costNum"]:setString("0")
    self._rootnode["expNum"]:setString("0")
    self._rootnode["expLabel"]:setString(string.format("%d/%d", self._info["exp"], self._info["limit"]))
    self:clearIcon()

end

function SkillQiangHuaLayer:refreshIcon()
    self:clearIcon()
    local i = 0
    local cost = 0
    for k, v in pairs(self._selected) do
        if v then
            i = i + 1
            local icon = ResMgr.getIconSprite({
                id = self._listData[k].data.resId,
                resType = ResMgr.EQUIP,
            })
            icon:setPosition(self._rootnode["iconSprite"..i]:getContentSize().width / 2, self._rootnode["iconSprite"..i]:getContentSize().height / 2)
            self._rootnode["iconSprite"..i]:addChild(icon)

            cost = cost + self._listData[k].data.curExp +
                    data_kongfu_kongfu[self._listData[k].data.level + 1]["sumexp"][self._listData[k].baseData.quality] +
                    self._listData[k].baseData.exp
        end
    end

    self._rootnode["expNum"]:setString(tostring(cost))
    local percent = 0
    if self._info["limit"] ~= 0 then
        percent = (self._info["exp"] + cost) / self._info["limit"]
        if percent > 1 then
            percent = 1
        end
    end

    local tmpExp = cost + self._info["exp"]
    local tmpLv = self._info.lv
    while data_kongfu_kongfu[tmpLv  + 1]["exp"][data_item_item[self._info.resId].quality] <= tmpExp do
        tmpExp = tmpExp - data_kongfu_kongfu[tmpLv + 1]["exp"][data_item_item[self._info.resId].quality]
        tmpLv = tmpLv + 1
    end
    printf("lv = %d, exp = %d", tmpLv, tmpExp)

    self._rootnode["curLevalLabel"]:setString(string.format("LV.%d", tmpLv))

--    self._rootnode["lvNum"]:setString(tostring(tmpLv))

    for k, v in ipairs(data_item_item[self._info.resId].arr_addition) do
        if tmpLv - 1 > self._info.lv then
            self._rootnode["addState" .. k]:setString(string.format("+%.2f%%", v * (tmpLv - self._info.lv) / 100))
            self._rootnode["addState" .. k]:setVisible(true)
        else
            self._rootnode["addState" .. k]:setVisible(false)
        end
    end

    self._rootnode["expLabel"]:setString(string.format("%d/%d", self._info["exp"] + cost, self._info["limit"]))

    local bar = self._rootnode["greenBar"]
    bar:setTextureRect(CCRectMake(bar:getTextureRect().origin.x, bar:getTextureRect().origin.y, BAR_SIZE.size.width * percent, BAR_SIZE.size.height))

--    本次提升的经验值*（内外功品质-1）*5
    self._rootnode["costNum"]:setString(cost * (data_item_item[self._info.resId].quality - 1) * 5)
end


return SkillQiangHuaLayer