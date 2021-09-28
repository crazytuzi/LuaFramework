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
-- 日期：14-8-21
--

local data_item_nature = require("data.data_item_nature")
local data_card_card = require("data.data_card_card")
local data_item_item = require("data.data_item_item")
local data_refine_refine = require("data.data_refine_refine")

local SkillRefineLayer = class("SkillRefineLayer", function (param)
    return require("utility.ShadeLayer").new(ccc4(0, 0, 0, 155))
end)

local COLOR_GREEN = ccc3(0, 255, 0)
local Item = class("Item", function()
    return CCTableViewCell:new()
end)

function Item:getContentSize()
    return CCSizeMake(98, 91)
end

function Item:create(param)
    local _viewSize = param.viewSize

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("skill/skill_refine_icon.ccbi", proxy, self._rootnode)
    node:setPosition(node:getContentSize().width / 2, _viewSize.height / 2)
    self:addChild(node, 0)

    self.needNum = ui.newTTFLabelWithOutline({
        text = "/0",
        size = 20,
        color = COLOR_GREEN,
        outlineColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy
    })
    self._rootnode["numLabel"]:addChild(self.needNum, 10)

    self.hasNum = ui.newTTFLabelWithOutline({
        text = "0",
        size = 20,
        color = COLOR_GREEN,
        outlineColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy
    })
    self._rootnode["numLabel"]:addChild(self.hasNum, 10)


    self:refresh(param)
    return self
end


function Item:refresh(param)
    local _itemData = param.itemData

    self.needNum:setString(string.format("/%d", _itemData.n2))
    self.hasNum:setString(tostring(_itemData.n1))
--    if _itemData.n1 <= _itemData.n2 then
--        self._rootnode["numLabel"]:setColor(ccc3(0, 255, 0))
--    else
--        self._rootnode["numLabel"]:setColor(ccc3(255, 0, 0))
--    end

    self.needNum:setPosition(-self.needNum:getContentSize().width / 2, 0)
    self.hasNum:setPosition(-self.hasNum:getContentSize().width / 2 - self.needNum:getContentSize().width, 0)

    ResMgr.refreshIcon({
        id = _itemData.id,
        itemBg = self._rootnode["iconSprite"],
        resType = ResMgr.getResType( _itemData.t)})
end

local RequestInfo = require("network.RequestInfo")
function SkillRefineLayer:onEnter()
--    PostNotice(NoticeKey.UNLOCK_BOTTOM)
end
function SkillRefineLayer:ctor(param)
    self._info = param.info     --武学信息
--    self._next = param.next     --下一等级
--    self._objs = param.objs    --消耗物品
--    self._cost = param.cost     --花费银币
--    self._bAllow = param.bAllow
--    self._id   = self._info._id


    local proxy = CCBProxy:create()
    self._rootnode = {}
    local node = CCBuilderReaderLoad("skill/skill_refine_scene.ccbi", proxy, self._rootnode)
    node:setPosition(display.cx, display.cy)
    self:addChild(node, 1)

    self:setNodeEventEnabled(true)
    ResMgr.removeBefLayer()

--  屏幕适配
    if (display.widthInPixels / display.heightInPixels) > 0.67 then
        self._rootnode["infoNode"]:setScale(0.8)
        local posX, posY = self._rootnode["infoNode"]:getPosition()
        self._rootnode["infoNode"]:setPosition(posX + self._rootnode["infoNode"]:getContentSize().width * 0.1, posY)
    end

--    self._rootnode["titleLabel"]:setString("武学精炼")

    self._rootnode["returnBtn"]:addHandleOfControlEvent(function()
        self:removeSelf()

        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    end, CCControlEventTouchDown)

    self._rootnode["jinglianBtn"]:addHandleOfControlEvent(function()
        if self._bAllow == 1 then
            local req = RequestInfo.new({
                modulename = "skill",
                funcname   = "refine",
                param      = {
                    op = 2,
                    id = self._id
                },
                oklistener = function(data)
                    self._info = data["2"]
                    self._bAllow = data["1"]
                    self._next = {idx = data["3"], val = data["4"]}
                    self._objs = data["5"]
                    self._cost = data["6"]

                    self:refresh()
                end
            })
            RequestHelperV2.request(req)
        else
            show_tip_label("所需物品不足")
        end
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end, CCControlEventTouchDown)

--

    self:refresh()
end

function SkillRefineLayer:refresh()

    local baseInfo = data_item_item[self._info.resId]
    self._rootnode["cardName"]:setString(baseInfo.name)
    self._rootnode["itemNameLabel"]:setString(baseInfo.name)
    self._rootnode["card_bg"]:setDisplayFrame(display.newSprite("#item_card_bg_" .. baseInfo.quality .. ".png"):getDisplayFrame())
    local path = ResMgr.getLargeImage( baseInfo.bicon, ResMgr.EQUIP )
    self._rootnode["skillImage"]:setDisplayFrame(display.newSprite(path):getDisplayFrame())

    --  星级
    for i = 1, baseInfo.quality do
        self._rootnode[string.format("star%d", i)]:setVisible(true)
    end

    --  属性值
    local refineInfo = data_refine_refine[self._info.resId]

    local propCount = #refineInfo.arr_nature2
    local num = math.floor(self._info.num / propCount) + 1
    local index = self._info.num - (num - 1) * propCount

    printf("精炼总次数：%d, 属性数：%d, 精炼次数：%d, 位置：%d", self._info.num, propCount, num, index)
    for k, v in ipairs(refineInfo.arr_nature2) do
        local tmpNode = self._rootnode["propNode_" .. k]
        tmpNode:setVisible(true)
        tmpNode:removeChildByTag(100)
        tmpNode:removeChildByTag(200)

        local nature = data_item_nature[v]
        local value  = refineInfo.arr_value2[k]
        self._rootnode[string.format("propLabel_%d", k)]:setString(nature.nature .. "：")

        if nature.type == 2 then
            if index > k then
                self._rootnode[string.format("propValueLabel_%d", k)]:setString(string.format("%d%%", num * value * 0.01))
            elseif num > 0 then
                self._rootnode[string.format("propValueLabel_%d", k)]:setString(string.format("%d%%", (num - 1) * value * 0.01))
            else
                self._rootnode[string.format("propValueLabel_%d", k)]:setString("0")
            end
            self._rootnode[string.format("prevewValueLabel_%d", k)]:setString(string.format("+%d", value))
        else
            if index > k then
                self._rootnode[string.format("propValueLabel_%d", k)]:setString(string.format("%d", num * value))
            elseif num > 0 then
                self._rootnode[string.format("propValueLabel_%d", k)]:setString(string.format("%d", (num - 1) * value))
            else
                self._rootnode[string.format("propValueLabel_%d", k)]:setString("0")
            end
            self._rootnode[string.format("prevewValueLabel_%d", k)]:setString(string.format("+%d", value))
        end

        if k <= index then
            local diamond = display.newSprite("#kongfu_diamond.png")
            diamond:setPosition(tmpNode:getContentSize().width / 2, tmpNode:getContentSize().height / 2)
            diamond:setTag(200)
            self._rootnode["propNode_" .. k]:addChild(diamond, 1)
        end
    end
    local effect = ResMgr.createArma({
        resType = ResMgr.UI_EFFECT,
        armaName = "wuxuejinglian",
        isRetain = false,
        finishFunc = function()

        end
    })
    effect:setTag(100)

    local tmpNode = self._rootnode[string.format("propNode_%d", index)]
    effect:setPosition(tmpNode:getContentSize().width / 2, tmpNode:getContentSize().height / 2)
    tmpNode:addChild(effect, 0)

    if num > 1 then
        self._rootnode["addLv"]:setString(string.format(" +%d", num - 1))
    end

--  消耗物品个数
    local i = 0
    while true do
        if refineInfo[string.format("arr_item%d", i + 1)] then
            i = i + 1
        else
            break
        end
    end

    --  消耗物品
    if self._iconList then
        self._iconList:removeFromParentAndCleanup(true)
    end

    self._iconList = require("utility.TableViewExt").new({
        size        = self._rootnode["listView"]:getContentSize(),
        createFunc  = function(idx)
            idx = idx + 1
            return Item.new():create({
                viewSize = self._rootnode["listView"]:getContentSize(),
                itemData = self._info.items[idx]
            })
        end,
        refreshFunc = function(cell, idx)
            idx = idx + 1
            cell:refresh({
                itemData = self._info.items[idx],
            })
        end,
        cellNum   = #self._info.items,
        cellSize    = Item.new():getContentSize(),
    })
    self._iconList:setPosition(0, 0)
    self._rootnode["listView"]:addChild(self._iconList)

    --  花费
    self._rootnode["costSilverLabel"]:setString(tostring(self._info.silver))
end

return SkillRefineLayer
