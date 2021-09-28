--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-15
-- Time: 下午5:50
-- To change this template use File | Settings | File Templates.
--

local data_item_nature = require("data.data_item_nature")

local Item = class("Item", function()
    return CCTableViewCell:new()
end)

function Item:getContentSize()
    return CCSizeMake(display.width, 155)
end

function Item:ctor()

end

function Item:create(param)

    local _itemData = param.itemData
    local _viewSize = param.viewSize
    local _idx      = param.idx
    local _listener = param.listener

--    dump(_itemData.data)

    local proxy = CCBProxy:create()
    self._rootnode = {}
    local node = CCBuilderReaderLoad("spirit/spirit_item.ccbi", proxy, self._rootnode)
    node:setContentSize(CCSizeMake(_viewSize.width, CONFIG_SCREEN_HEIGHT))
    node:setPosition(_viewSize.width / 2, self._rootnode["itemBg"]:getContentSize().height / 2)
    self:addChild(node)

    resetctrbtnimage(self._rootnode["upgradeBtn"], "#item_board_zb.png")
    self._rootnode["upgradeBtn"]:addHandleOfControlEvent(function(eventName,sender)
        self._rootnode["upgradeBtn"]:setEnabled(false)
        if _listener then
            _listener(self:getIdx())
        end
    end, CCControlEventTouchUpInside)

    self:refresh(param)
--
--    self:refreshLabel(_itemData)

    return self
end

function Item:refreshLabel(itemData)
    self._rootnode["itemNameLabel"]:setString(itemData.baseData.name)
    self._rootnode["itemNameLabel"]:setColor(NAME_COLOR[itemData.baseData.quality])
    for i = 1, 2 do
        local prop = itemData.data.props[i]

        local str = ""
        if prop then
            local nature = data_item_nature[prop.idx]
            str = nature.nature
            if nature.type == 1 then
                str = str .. "+" .. tostring(prop.val)
            else
                str = str .. "+%" .. tostring(prop.val)
            end
        end
        self._rootnode["propLabel_" .. tostring(i)]:setString(str)
    end

    self._rootnode["lvLabel"]:setString(string.format("LV.%d", itemData.data.level))
    self._rootnode["qualitySprite"]:setDisplayFrame(display.newSpriteFrame(string.format("item_board_num_%d.png", itemData.baseData.quality)))
    if itemData["data"]["cid"] > 0 then
--        self._rootnode["equipHeroName"]:setString("装备于：" .. ResMgr.getCardData(itemData["data"]["cid"]).name)
        local card = ResMgr.getCardData(itemData["data"]["cid"])

        if card.id == 1 or card.id == 2 then
            self._rootnode["equipHeroName"]:setString("装备于" ..game.player:getPlayerName())
        else
            self._rootnode["equipHeroName"]:setString("装备于" ..card.name)
        end
    else
        self._rootnode["equipHeroName"]:setString("")
    end
end


function Item:refresh(param)
    local _itemData = param.itemData
    local _idx      = param.idx

    self:refreshLabel(_itemData)
    self._rootnode["iconSprite"]:removeAllChildrenWithCleanup(true)
    self._rootnode["iconSprite"]:addChild(require("game.Spirit.SpiritIcon").new({
        id = _itemData.data._id,
        resId = _itemData.data.resId,
        lv = _itemData.data.level,
        exp = _itemData.data.curExp or 0
    }))
end


local SpiritChooseScene = class("SpiritChooseScene", function()
    return require("game.BaseScene").new({
        contentFile = "public/window_content_scene.ccbi",
        subTopFile = "spirit/spirit_select_sub_top.ccbi",
        bgImage    = "ui_common/common_bg.png"
    })
end)


local data_item_item = require("data.data_item_item")
function SpiritChooseScene:ctor(param)
    local _index    = param.index
    local _subIndex = param.subIndex
    local _callback = param.callback
    local _cid      = param.cid
    local _filter   = param.filter
    local _objId  = param.objId

     ResMgr.removeBefLayer()

    dump(param)

    game.runningScene = self

    local _sz = self._rootnode["listView"]:getContentSize()

    self._rootnode["backBtn"]:addHandleOfControlEvent(function(eventName,sender)
        self._rootnode["backBtn"]:setEnabled(false)
        pop_scene()
    end, CCControlEventTouchUpInside)

    local function sortFunc(lh, rh)
        if lh.cid == 0 and rh.cid > 0 then
            return true
        elseif (lh.cid == 0 and rh.cid == 0) or (lh.cid > 0 and rh.cid > 0) then
            if data_item_item[lh.resId].quality == data_item_item[rh.resId].quality then
                return lh.level > rh.level
            else
                return data_item_item[lh.resId].quality > data_item_item[rh.resId].quality
            end
        end

        return false
    end

    local _data = {}
    for k, v in ipairs(game.player:getSpirit(sortFunc)) do
--        dump(v)

--        if _objId then
--            printf("%d, %d", _objId, v.objId)
            if data_item_item[v.resId].arr_nature == nil or _objId == v.objId then

            else
                table.insert(_data, {
                    baseData = data_item_item[v.resId],
                    data = v
                })
            end
--        else
--            if _filter[data_item_item[v.resId].pos] or data_item_item[v.resId].arr_nature == nil then
--
--            else
--                table.insert(_data, {
--                    baseData = data_item_item[v.resId],
--                    data = v
--                })
--            end
--        end
    end

    local function onEquip(cellIdx)

        if _filter[data_item_item[_data[cellIdx + 1].data.resId].pos] then
            show_tip_label("已经装备同类型真气")
            return
        end

        RequestHelper.formation.putOnSpirit({
            pos = _index,
            subpos = _subIndex,
            id = _data[cellIdx + 1].data._id,
            callback = function(data)
                if string.len(data["0"]) > 0 then
                    CCMessageBox(data["0"], "Tip")
                else
                    printf("pos = %d, ccid =%d", _index, _cid)

                    for k, v in ipairs(game.player:getSpirit()) do
                        if v.pos == _index and v.cid == _cid and v.subpos == _subIndex then
                            dump(v)

                            v.pos = 0
                            v.cid = 0
                            v.subpos = 0
                            break
                        end
                    end
                    _data[cellIdx + 1].data.pos = _index
                    _data[cellIdx + 1].data.cid = _cid
                    _data[cellIdx + 1].data.subpos = _subIndex
                    require("game.Spirit.SpiritCtrl").refresh()
                    pop_scene()
                    if _callback then
                        _callback(data)
                    end
                end
            end
        })
    end

    local function creatFunc(idx)
        local item = Item.new()
        idx = idx + 1
        return item:create({
            viewSize = _sz,
            itemData = _data[idx],
            idx      = idx,
            listener = function(cellIdx)
                onEquip(cellIdx)
            end
        })
    end

    self._scrollItemList = require("utility.TableViewExt").new({
        size        = CCSizeMake(_sz.width, _sz.height),
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = creatFunc,
        refreshFunc = function(cell, idx)
            idx = idx + 1
            cell:refresh({
                idx = idx,
                itemData = _data[idx]
            })
        end,
        cellNum   = #_data,
        cellSize  = Item.new():getContentSize(),

    })
    self._scrollItemList:setPosition(0, 0)
    self._rootnode["listView"]:addChild(self._scrollItemList)

end



function SpiritChooseScene:onEnter()
    game.runningScene = self
    self:regNotice()
    PostNotice(NoticeKey.UNLOCK_BOTTOM)
end

function SpiritChooseScene:onExit()
    self:unregNotice()
end

return SpiritChooseScene

