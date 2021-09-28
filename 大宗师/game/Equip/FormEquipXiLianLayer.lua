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
-- 日期：14-8-28
--
local data_baptize_baptize = require("data.data_baptize_baptize")
local data_item_nature = require("data.data_item_nature")
local data_item_item = require("data.data_item_item")

local RequestInfo = require("network.RequestInfo")
local EquipXiLianScene = class("EquipXiLianScene", function()
    return require("utility.ShadeLayer").new()
end)

local ICON_MAPS = {
    [1] = "icon_lv_silver.png",
    [2] = "icon_gold.png",
    [3] = "icon_xilianshi.png"
}

function EquipXiLianScene:ctor(param)

    self._proxy = CCBProxy:create()
    self._rootnode = {}

    local bgNode = CCBuilderReaderLoad("equip/equip_xilian_scene.ccbi", self._proxy, self._rootnode)
    bgNode:setPosition(display.cx, display.cy - bgNode:getContentSize().height / 2)
    self:addChild(bgNode, 1)

    local _info = param.info
    local _baseInfo = data_item_item[_info.resId]
    local _listener = param.listener
    local _xlType = 1    --洗练类型， 默认是初级洗练
    local _stoneNum = 0

    dump(_info)
    local _xlInfo = {}

    local nameLabel = ui.newTTFLabelWithShadow({
        text = _baseInfo.name,
        font = FONTS_NAME.font_haibao,
        size = 30,
        align = ui.TEXT_ALIGN_CENTER
    })
    self._rootnode["itemNameLabel"]:addChild(nameLabel)
    nameLabel:setColor(NAME_COLOR[_baseInfo.quality])

    self._rootnode["lvLabel"]:setString("LV." .. tostring(_info.level))
    local path = ResMgr.getLargeImage( _baseInfo.bicon, ResMgr.EQUIP )
    self._rootnode["imageSprite"]:setDisplayFrame(display.newSprite(path):getDisplayFrame())
    self._rootnode["card_left"]:setDisplayFrame(display.newSprite("#item_card_bg_" .. _info.star .. ".png"):getDisplayFrame())

    for i = 1, _info.star do
        self._rootnode[string.format("star%d", i)]:setVisible(true)
    end

    local bShowNoEquipNum = false
    local function refresh()
        self._rootnode["stoneNumLabel"]:setString(tostring(_stoneNum))
        for x = 1, 5 do
            local v = _xlInfo[x]
            if v then

                for propK, propV in ipairs(_info.base) do
                    if propV > 0 then
                        if EQUIP_BASE_PROP_MAPPPING[propK] == v.id then
                            printf("========= 属性值：%d, %d, %d", v.val + v.equip, v.val, v.equip)
                            _info.base[propK] = v.val + v.equip
                        end
                    end
                end

                local nature = data_item_nature[v.id]
                self._rootnode[string.format("stateName%d", x)]:setString(nature.nature .. "：")
                self._rootnode["propNode_" .. tostring(x)]:setVisible(true)
                local str
                if nature.type == 1 then
                    str = string.format("+%d", v.val)
                else
                    str = string.format("+%d%%", v.val / 100)
                end

                self._rootnode[string.format("curNum%d", x)]:setString(str)
                self._rootnode[string.format("addNum%d", x)]:setString(string.format("(+%d", v.equip))

                if bShowNoEquipNum then
                    self._rootnode["ti_huan_btn"]:setVisible(true)
                    if v.noequip > 0 then
                        self._rootnode[string.format("maxNum%d", x)]:setString(string.format("+%d", v.noequip))
                        self._rootnode[string.format("maxNum%d", x)]:setColor(ccc3(73, 144, 72))
                        self._rootnode[string.format("arrow_%d", x)]:setVisible(true)
                        self._rootnode[string.format("arrow_%d", x)]:setDisplayFrame(display.newSpriteFrame("equip_up_arrow.png"))
                    else
                        self._rootnode[string.format("maxNum%d", x)]:setString(string.format("%d", v.noequip))
                        if v.noequip == 0 then
                            self._rootnode[string.format("arrow_%d", x)]:setVisible(false)
                            self._rootnode[string.format("maxNum%d", x)]:setColor(ccc3(73, 144, 72))
                        else
                            self._rootnode[string.format("arrow_%d", x)]:setVisible(true)
                            self._rootnode[string.format("arrow_%d", x)]:setDisplayFrame(display.newSpriteFrame("equip_down_arrow.png"))
                            self._rootnode[string.format("maxNum%d", x)]:setColor(ccc3(255, 0, 0))
                        end
                    end
                else
                    self._rootnode["ti_huan_btn"]:setVisible(false)
                    for i, j in ipairs(_baseInfo.arr_xilian) do
                        if v.id == j then
                            --洗练属性上限=初始上限*（1+强化等级/10
                            self._rootnode[string.format("maxNum%d", x)]:setColor(ccc3(73, 144, 72))
                            self._rootnode[string.format("arrow_%d", x)]:setVisible(false)
                            self._rootnode[string.format("maxNum%d", x)]:setString("最大" .. tostring(math.floor(_baseInfo.arr_beginning[i] * (1 + _info.level / 10))))
                            break
                        end
                    end
                end
            else
                self._rootnode["propNode_" .. tostring(x)]:setVisible(false)
            end
        end
    end

    local function onXiLianType(tag)
        for i = 1, 3 do
            if i ~= tag then
                self._rootnode[string.format("tab%d", i)]:unselected()
            else
                self._rootnode[string.format("tab%d", i)]:selected()
            end
        end
        _xlType = tag
    end

    for i = 1, 3 do
        self._rootnode[string.format("tab%d", i)]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onXiLianType)
    end

--    data_baptize_baptize[self.type]["arr_silver"]
    for k, v in ipairs(data_baptize_baptize) do
        local idx = 1
        for i, j in ipairs(v.arr_silver) do
            if j > 0 then
                self._rootnode[string.format("costIcon_%d_%d", k, idx)]:setDisplayFrame(display.newSpriteFrame(ICON_MAPS[i]))
                self._rootnode[string.format("cost_%d_%d", k, idx)]:setString(tostring(j))
                idx = idx + 1
            else

            end
        end
        if idx == 2 then
            self._rootnode[string.format("costIcon_%d_2", k)]:setVisible(false)
        end
    end

    local bInit = false
    local function onXilian(data, bReplace)
        dump(data)
        _xlInfo = {}
        bShowNoEquipNum = false
        for k, v in ipairs(data["1"]) do
            table.insert(_xlInfo, {
                id = v,
                val = data["2"][k],
                equip = data["3"][k],
                noequip = data["4"][k]
            })
--            if data["4"][k] ~= 0 then


            if (bInit and data["4"][k] ~= 0) or (bInit == false) then
                bShowNoEquipNum = true
            end

            if bReplace then
                bShowNoEquipNum = false
            end

            local b = true
            for _, vv in ipairs(_info.props) do
                if vv.idx == v then
                    vv.val = data["3"][k]
                    b = false
                    break
                end
            end

            if b and data["3"][k] > 0 then
                table.insert(_info.props, {
                    idx = v,
                    val = data["3"][k]
                })
            end
        end
        PostNotice(NoticeKey.CommonUpdate_Label_Silver)
        PostNotice(NoticeKey.CommonUpdate_Label_Gold)

--
--        self._rootnode["silverLabel"]:setString(tostring(game.player:getSilver()))
--        self._rootnode["goldLabel"]:setString(tostring(game.player:getGold()))
        refresh()
    end

    onXiLianType(1)
    local req = RequestInfo.new({
        modulename = "equip",
        funcname   = "xlstate",
        param      = {
            id = _info._id
        },
        oklistener = function(data)
            bInit = true
            _stoneNum = data["5"]
            onXilian(data)
--            onXilian(data)
            bInit = false
        end
    })
    RequestHelperV2.request(req)

    local function close()
        _listener()
        self:removeSelf()
    end

    local function xilian(num)
        local xilianreq = RequestInfo.new({
            modulename = "equip",
            funcname   = "xl",
            param      = {
                id = _info._id,
                t = _xlType,
                num = num
            },
            oklistener = function(data)
                _stoneNum = data["7"]
                game.player:setSilver(data["5"])
                game.player:setGold(data["6"])
                onXilian(data)
            end
        })
        RequestHelperV2.request(xilianreq)
    end

    local function replace()
        local repreq = RequestInfo.new({
            modulename = "equip",
            funcname   = "replace",
            param      = {
                id = _info._id,
            },
            oklistener = function(data)
                game.player:setSilver(data["5"])
                game.player:setGold(data["6"])
                onXilian(data, true)

            end
        })
        RequestHelperV2.request(repreq)
    end

    self._rootnode["closeBtn"]:addHandleOfControlEvent(close, CCControlEventTouchDown)
    self._rootnode["xi_lian_btn"]:addHandleOfControlEvent(c_func(xilian, 1) , CCControlEventTouchDown)
    self._rootnode["xi_lian_10_btn"]:addHandleOfControlEvent(c_func(xilian, 10) , CCControlEventTouchDown)
    self._rootnode["ti_huan_btn"]:addHandleOfControlEvent(replace , CCControlEventTouchDown)
end

return EquipXiLianScene

