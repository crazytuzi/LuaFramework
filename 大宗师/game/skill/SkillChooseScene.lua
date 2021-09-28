
local data_item_nature = require("data.data_item_nature")
local data_kongfu_kongfu = require("data.data_kongfu_kongfu")
local Item = class("Item", function()
    return CCTableViewCell:new()
end)

function Item:getContentSize()
    return CCSizeMake(display.width * 0.93, 158)
end

function Item:create(param)
    local _viewSize = param.viewSize

    local proxy = CCBProxy:create()
    self._rootnode = {}
    local node = CCBuilderReaderLoad("bag/bag_skill_choose_item.ccbi", proxy, self._rootnode)
    node:setPosition(_viewSize.width / 2, self._rootnode["itemBg"]:getContentSize().height / 2)
    self:addChild(node)

    self:refresh(param)

    return self
end


function Item:refreshLabel(itemData)
    self._rootnode["kongfuName"]:setString(itemData.baseData.name)
    self._rootnode["kongfuName"]:setColor(NAME_COLOR[itemData.baseData.quality])
    local index = 1
--    dump(itemData)

    for i = 1, 3 do
        self._rootnode["propLabel_" .. tostring(i)]:setVisible(false)
    end

    local exp = itemData.data.curExp + data_kongfu_kongfu[itemData.data.level + 1]["sumexp"][itemData.baseData.quality] + itemData.baseData.exp

    if itemData.baseData.pos == 101 or itemData.baseData.pos == 102 then
        self._rootnode["propLabel_1"]:setVisible(true)
        self._rootnode["propLabel_1"]:setString(string.format("经验+%d", exp))
    else
        for i = 1, 4 do
            local prop = itemData.data.baseRate[i]
            local str = ""
            if prop > 0 then
                local nature = data_item_nature[BASE_PROP_MAPPPING[i]]
                str = nature.nature
                if nature.type == 1 then
                    str = string.format("%s+%d", str, prop)
                else
                    str = string.format("%s+%.2f%%", str, prop / 100)
                end

                self._rootnode["propLabel_" .. tostring(index)]:setString(str)
                self._rootnode["propLabel_" .. tostring(index)]:setVisible(true)
                index = index + 1
            end
        end
    end

    self._rootnode["expNumLabel"]:setString(tostring(exp))
    self._rootnode["lvNum"]:setString(string.format("LV.%d", itemData.data.level))
    self._rootnode["qualityLabel"]:setString(tostring(itemData.baseData.quality))
end

function Item:selected()
    self._rootnode["selectedSprite"]:setDisplayFrame(display.newSpriteFrame("item_board_selected.png"))
end

function Item:unselected()
    self._rootnode["selectedSprite"]:setDisplayFrame(display.newSpriteFrame("item_board_unselected.png"))
end

function Item:touch()
    self:selected()
end

function Item:changeState(sel)

    if sel then
        self:selected()
    else
        self:unselected()
    end
end


function Item:refresh(param)
    local _itemData = param.itemData
    local _sel      = param.sel

    self:changeState(_sel)

    ResMgr.refreshIcon({
        itemBg = self._rootnode["headIcon"],
        id = _itemData.data.resId,
        resType = ResMgr.EQUIP
    })

    self:refreshLabel(_itemData)
    if _itemData.baseData.pos == 5 or _itemData.baseData.pos == 101 then
        self._rootnode["flagSprite"]:setDisplayFrame(display.newSpriteFrame("item_board_ng.png"))
    else
        self._rootnode["flagSprite"]:setDisplayFrame(display.newSpriteFrame("item_board_wg.png"))
    end
end


local SkillChooseScene = class("SkillChooseScene", function()
    return require("game.BaseScene").new({
        contentFile = "public/window_content_scene.ccbi",
        subTopFile = "formation/formation_skill_sub_top.ccbi",
        bottomFile = "skill/skill_select_bottom.ccbi",
        bgImage    = "ui_common/common_bg.png",
        imageFromBottom = true
    })
end)


function SkillChooseScene:ctor(param)
     ResMgr.removeBefLayer()

    local _callback = param.callback
    local _sel      = param.sel or {}
    local _listData = param.listData
    game.runningScene = self

    local _sz = self._rootnode["listView"]:getContentSize()
    local _selected = {}
    for k, v in pairs(_sel) do
        _selected[k] = v
    end

    local function close()

        if _callback then
            _callback(_sel)
        end

        pop_scene()
    end

    self._rootnode["backBtn"]:addHandleOfControlEvent(function(_, sender)
        sender:setEnabled(false)
        close()
    end, CCControlEventTouchDown)
    self._rootnode["confirmBtn"]:addHandleOfControlEvent(function()
        _sel = _selected
        close()
    end, CCControlEventTouchDown)

    local function countSelected()
        local i = 0
        local exp = 0
        for k, v in pairs(_selected) do
            if v then
                i = i + 1

                exp = exp +_listData[k].data.curExp + data_kongfu_kongfu[_listData[k].data.level + 1]["sumexp"][_listData[k].baseData.quality] + _listData[k].baseData.exp
            end
        end
        return i, exp
    end

    local function refreshLabel()
        local i, exp = countSelected()
        self._rootnode["selectedLabel"]:setString(tostring(i))
        self._rootnode["expNumLabel"]:setString(tostring(exp))
    end

    local function touch(idx)

        if _selected[idx] then
            _selected[idx] = nil
        else
            local n, _ = countSelected()
            if n >= 5 then
                show_tip_label("最多只能选5个武学")
                return
            else
                _selected[idx] = true
            end
        end
        local i, exp = countSelected()

        refreshLabel()
    end

    refreshLabel()

    self._scrollItemList = require("utility.TableViewExt").new({
        size        = CCSizeMake(_sz.width, _sz.height),
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = function(idx)
            local item = Item.new()
            idx = idx + 1
            return item:create({
                viewSize = _sz,
                itemData = _listData[idx],
                idx      = idx,
                sel      = _selected[idx]
            })
        end,
        refreshFunc = function(cell, idx)
            idx = idx + 1
            cell:refresh({
                idx = idx,
                itemData = _listData[idx],
                sel = _selected[idx],
            })
        end,
        cellNum   = #_listData,
        cellSize    = Item.new():getContentSize(),
        touchFunc = function(cell)
            local idx = cell:getIdx() + 1
            touch(idx)

            cell:refresh({
                idx = idx,
                itemData = _listData[idx],
                sel = _selected[idx],
            })
        end
    })
    self._scrollItemList:setPosition(0, 0)
    self._rootnode["listView"]:addChild(self._scrollItemList)
end

function SkillChooseScene:onEnter()
    game.runningScene = self
    PostNotice(NoticeKey.UNLOCK_BOTTOM)
end

return SkillChooseScene



