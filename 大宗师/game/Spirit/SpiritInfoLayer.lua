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
-- 日期：14-8-23
--
local data_jingyuantype_jingyuantype = require("data.data_jingyuantype_jingyuantype")
local data_item_nature = require("data.data_item_nature")
local data_item_item = require("data.data_item_item")

local SpiritInfoLayer = class("SpiritInfoLayer", function()
    return require("utility.ShadeLayer").new()
end)

-- 类型：1.更换   2.升级,  3升级屏蔽, 4什么都没有
function SpiritInfoLayer:ctor(optType, data, listener, closeListener)


    dump(data)

    local sz = CCSizeMake(615, 425)
--    if optType == 4 then
--        sz = CCSizeMake(615, 370)
--    end

    local proxy = CCBProxy:create()
    local rootnode = {}
    local node = CCBuilderReaderLoad("spirit/spirit_desc.ccbi", proxy, rootnode, self, sz)
    node:setPosition(display.cx, display.cy)
    self:addChild(node)

    rootnode["titleLabel"]:setString("真气信息")
    rootnode["nameLabel"]:setString(data_item_item[data.resId].name)

    local star = data_item_item[data.resId].quality
    rootnode["nameLabel"]:setColor(QUALITY_COLOR[star])
    rootnode["spiritTypeLabel"]:setString(data_jingyuantype_jingyuantype[data_item_item[data.resId].pos].name)
    rootnode["spiritLevelLabel"]:setString(tostring(data.level or 0))


    for i = 1, star do
        rootnode[string.format("star_%d_%d", star % 2, i)]:setVisible(true)
    end

    local icon = require("game.Spirit.SpiritIcon").new({
        id = data._id,
        resId = data.resId,
        lv = data.level or 0,
        exp = data.curExp or 0,
        bShowName = false,
        bShowLv = false
    })
    icon:setPosition(rootnode["iconSprite"]:getContentSize().width / 2, rootnode["iconSprite"]:getContentSize().height / 2)
    rootnode["iconSprite"]:addChild(icon)

    local arr_nature = data_item_item[data.resId].arr_nature
    if arr_nature then

        if data.props == nil then
            data.props = {}
            for k, v in ipairs(arr_nature) do
                table.insert(data.props, {
                    idx = v,
                    val = data_item_item[data.resId].arr_value[k]
                })
            end
        end

        dump(data.props)
        for k, v in ipairs(data.props) do
            local l = string.format("propNameLabel_%d", k)
            local nature = data_item_nature[v.idx]
            rootnode[l]:setString(nature.nature .. "：")
            rootnode[l]:setVisible(true)

            local str = ""
            if nature.type == 1 then
                str = str .. string.format("+%d", v.val)
            else
                str = str .. string.format("+%d%%", v.val / 100)
            end

            local valueLabel = ui.newTTFLabel({
                text = tostring(str),
                size = 28,
                font = FONTS_NAME.font_haibao,
                color= ccc3(223, 192, 132)
            })
            valueLabel:setAnchorPoint(0, 0.5)
            valueLabel:setPosition(rootnode[l]:getContentSize().width, rootnode[l]:getContentSize().height / 2)
            rootnode[l]:addChild(valueLabel)
        end
    else

        local l = string.format("propNameLabel_%d", 1)
        rootnode[l]:setVisible(true)
        rootnode[l]:setString("增加经验：")
        rootnode[l]:setVisible(true)
        local valueLabel = ui.newTTFLabel({
            text = tostring(data_item_item[data.resId].price),
            size = 28,
            font = FONTS_NAME.font_haibao,
            color= ccc3(223, 192, 132)
        })
        valueLabel:setAnchorPoint(0, 0.5)
        valueLabel:setPosition(rootnode[l]:getContentSize().width, rootnode[l]:getContentSize().height / 2)
        rootnode[l]:addChild(valueLabel)
    end

    local function close(eventName, sender)
        self:removeSelf()
        if optType == 1 then
            listener()
        end
    end

    local function upgrade(eventName, sender)
        self:removeSelf()
        if optType == 1 then
            local ctrl = require("game.Spirit.SpiritCtrl")
            local idx = ctrl.getIndexByID(data._id)
            if idx > 0 then
                listener(true)
                ctrl.pushUpgradeScene(idx)
            end
        elseif optType == 2 then
            if data_item_item[data.resId].arr_nature then
                listener()
            else
                show_tip_label("此真气为经验类型，不可以升级")
            end
        else

        end
    end

    rootnode["tag_close"]:addHandleOfControlEvent(function()
        if closeListener then
            closeListener()
        end
        self:removeSelf()
    end, CCControlEventTouchUpInside)
--    rootnode["closeBtn"]:setVisible(false)
--  1 更换
    if optType == 1 then
        resetctrbtnimage(rootnode["returnBtn"], "#psirit_desc_change.png")
    elseif optType == 2 then
        resetctrbtnimage(rootnode["returnBtn"], "#spirit_desc_close.png")
    elseif optType == 3 then
        rootnode["changeBtn"]:setEnabled(false)
    elseif optType == 4 then
        rootnode["returnBtn"]:setPositionX(sz.width / 2)
        rootnode["changeBtn"]:setVisible(false)
    end
    rootnode["returnBtn"]:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
    rootnode["changeBtn"]:addHandleOfControlEvent(upgrade, CCControlEventTouchUpInside)

end

return SpiritInfoLayer

