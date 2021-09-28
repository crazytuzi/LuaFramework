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

local SkillRefineScene = class("SkillRefineScene", function (param)
    return require("game.BaseScene").new({
        contentFile = "skill/skill_refine_scene.ccbi",
        adjustSize = CCSizeMake(8, 3)
    })
end)


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

    self:refresh(param)
    return self
end


function Item:refresh(param)
    local _itemData = param.itemData
    self._rootnode["numLabel"]:setString(string.format("%d/%d", _itemData.n1, _itemData.n2))
    if _itemData.n1 <= _itemData.n2 then
        self._rootnode["numLabel"]:setColor(ccc3(0, 255, 0))
    else
        self._rootnode["numLabel"]:setColor(ccc3(255, 0, 0))
    end
end

local RequestInfo = require("network.RequestInfo")
function SkillRefineScene:onEnter()
    PostNotice(NoticeKey.UNLOCK_BOTTOM)
end
function SkillRefineScene:ctor(param)
    self._info = param.info     --武学信息
    self._next = param.next     --下一等级
    self._objs = param.objs    --消耗物品
    self._cost = param.cost     --花费银币
    self._bAllow = param.bAllow
    self._id   = self._info._id
    self:setNodeEventEnabled(true)
     ResMgr.removeBefLayer()
    dump(param)
--  屏幕适配
    if (display.widthInPixels / display.heightInPixels) > 0.67 then
        self._rootnode["infoNode"]:setScale(0.8)
        local posX, posY = self._rootnode["infoNode"]:getPosition()
        self._rootnode["infoNode"]:setPosition(posX + self._rootnode["infoNode"]:getContentSize().width * 0.1, posY)
    end

    self._rootnode["titleLabel"]:setString("武学精炼")

    self._rootnode["returnBtn"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
        pop_scene()
    end, CCControlEventTouchDown)

    self._rootnode["jinglianBtn"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
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
    end, CCControlEventTouchDown)

    self._rootnode["card_bg"]:setDisplayFrame(display.newSprite("#item_card_bg_" .. self._info.star .. ".png"):getDisplayFrame())

    self:refresh()
end

function SkillRefineScene:refresh()

    local baseInfo = data_item_item[self._info.resId]
    self._rootnode["cardName"]:setString(baseInfo.name)
    self._rootnode["itemNameLabel"]:setString(baseInfo.name)

    local path = ResMgr.getLargeImage( baseInfo.bicon, ResMgr.EQUIP )
    self._rootnode["skillImage"]:setDisplayFrame(display.newSprite(path):getDisplayFrame())

    --  星级
    for i = 1, baseInfo.quality do
        self._rootnode[string.format("star%d", i)]:setVisible(true)
    end

    --  属性值
    for k, v in ipairs(self._info.prop) do
        local nature = data_item_nature[v.idx]
        self._rootnode[string.format("propLabel_%d", k)]:setString(nature.nature .. "：")
        self._rootnode[string.format("propValueLabel_%d", k)]:setString(tostring(v.val))
    end

    --  下一等级
    for i = 1, 5 do
        if i == (self._next.idx + 1) then
            self._rootnode["prevewValueLabel_" .. tostring(i)]:setString("+ " .. tostring(self._next.val))
        else
            self._rootnode["prevewValueLabel_" .. tostring(i)]:setString("")
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
                itemData = self._objs[idx]
            })
        end,
        refreshFunc = function(cell, idx)
            idx = idx + 1
            cell:refresh({
                itemData = self._objs[idx],
            })
        end,
        cellNum   = #self._objs,
        cellSize    = Item.new():getContentSize(),
    })
    self._iconList:setPosition(0, 0)
    self._rootnode["listView"]:addChild(self._iconList)


    --  花费
    self._rootnode["costSilverLabel"]:setString(tostring(self._cost))
end

return SkillRefineScene
