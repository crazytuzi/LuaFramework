--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-25
-- Time: 下午5:25
-- To change this template use File | Settings | File Templates.
--
local ItemChooseScene = class("ItemChooseScene", function()

    return require("game.BaseScene").new({
        contentFile = "public/window_content_scene.ccbi",
        subTopFile = "lianhualu/lianhualu_item_tab_view.ccbi",
        bottomFile = "lianhualu/lianhualu_bottom_frame.ccbi",
        bgImage    = "ui_common/common_bg.png",
        imageFromBottom = true
    })
end)

function ItemChooseScene:ctor(param)
     ResMgr.removeBefLayer()

    local _list          = param.list
    local _items         = param.items
    local _closeListener = param.closeListener
    local _splitType     = param.splitType or 1
    local _select        = param.selected or {}
    local _viewType      = param.viewType

    local _SELECTNUM
    if _viewType == 1 then
        _SELECTNUM = 4
    else
        _SELECTNUM = 1
    end
    self._rootnode["maxSelectedLabel"]:setString("/" .. tostring(_SELECTNUM))

    local _tabMap = {
        [LIAN_HUA_TYEP.HERO]      = _items[LIAN_HUA_TYEP.HERO],
        [LIAN_HUA_TYEP.EQUIP]     = _items[LIAN_HUA_TYEP.EQUIP],
        [LIAN_HUA_TYEP.SKILL]     = _items[LIAN_HUA_TYEP.SKILL],
        [LIAN_HUA_TYEP.TAOZHUANG] = _items[LIAN_HUA_TYEP.TAOZHUANG]
    }

    local function getIndexByValue(x)

        for k, v in ipairs(_tabMap[_splitType]) do
            if v == x then
                return k
            end
        end
    end

    --选择的排在最前
    local i = 1
    for k, v in pairs(_select) do
        if v then
            local idx = getIndexByValue(k)
            if idx then
                _tabMap[_splitType][i], _tabMap[_splitType][idx] = _tabMap[_splitType][idx], _tabMap[_splitType][i]
                i = i + 1
            end
        end
    end

    local _tmpSelect = {}
    for k, v in pairs(_select) do
        if v then
            _tmpSelect[k] = v
        end
    end

    local function countSelected()
        local i = 0
        for k, v in pairs(_tmpSelect) do
            if v then
                i = i + 1
            end
        end
        return i
    end

    local function onTabBtn(tag)
        if tag == LIAN_HUA_TYEP.SKILL or tag == LIAN_HUA_TYEP.TAOZHUANG then
            show_tip_label("暂未开放")
            return
        end

        for i = 1, 4 do
            if tag == i then
                self._rootnode["tab" .. i]:selected()
                self._rootnode["tab" .. i]:setZOrder(1)
            else
                self._rootnode["tab" .. i]:unselected()
                self._rootnode["tab" .. i]:setZOrder(0)
            end
        end
        _splitType = tag
        _tmpSelect = {}
        _select = {}


        table.sort(_tabMap[_splitType], function(l, r)
            return l < r
        end)
        self._itemList:resetCellNum(#_tabMap[_splitType])
        self._rootnode["selectedLabel"]:setString(tostring(countSelected()))
    end


    self._rootnode["tab" .. tostring(_splitType)]:selected()
    self._rootnode["tab" .. tostring(_splitType)]:setZOrder(1)
    self._rootnode["tab1"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)
    self._rootnode["tab2"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)
    self._rootnode["tab3"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)
    self._rootnode["tab4"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, onTabBtn)

    local _sz = self._rootnode["listView"]:getContentSize()
    local function close(sel)
        if _closeListener then
            _closeListener(_splitType, sel)
        end
        pop_scene()
    end

    local function touch(idx)

        if _tmpSelect[idx] then
            _tmpSelect[idx] = nil
        else

            if countSelected() >= _SELECTNUM then
                show_tip_label(string.format("最多只能选%d个", _SELECTNUM))
                return
            else
                _tmpSelect[idx] = true
            end
        end
        self._rootnode["selectedLabel"]:setString(tostring(countSelected()))
    end
    self._rootnode["selectedLabel"]:setString(tostring(countSelected()))
    local function onConfirmBtn(eventname, sender)
        close(_tmpSelect)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end

    self._rootnode["returnBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, close)
    self._rootnode["okBtn"]:addHandleOfControlEvent(onConfirmBtn, CCControlEventTouchDown)

    self._rootnode["returnBtn"]:addHandleOfControlEvent(function()
        close(_select)
    end, CCControlEventTouchDown)

    local function initItems()
        self._itemList = require("utility.TableViewExt").new({
            size        = _sz,
            direction   = kCCScrollViewDirectionVertical,
            createFunc  = function(idx)
                local item = require("game.SplitStove.SplitItem").new()
                idx = idx + 1
--                printf("idx = %d, " .. tostring(_tmpSelect[_tabMap[_splitType][idx]]), idx)
--                printf("_tabMap[_splitType][idx] = %d", _tabMap[_splitType][idx])

                return item:create({
                    viewSize = _sz,
                    itemData = _list[_splitType][_tabMap[_splitType][idx]],
                    idx      = idx,
                    sel = _tmpSelect[_tabMap[_splitType][idx]],
                    itemType = _splitType
                })
            end,
            refreshFunc = function(cell, idx)
                idx = idx + 1
                cell:refresh({
                    idx      = idx,
                    itemData = _list[_splitType][_tabMap[_splitType][idx]],
                    sel      = _tmpSelect[_tabMap[_splitType][idx]],
                    itemType = _splitType
                })

            end,
            cellNum   = #_tabMap[_splitType],
            cellSize  = require("game.SplitStove.SplitItem").new():getContentSize(),
            touchFunc = function(cell)
                local idx = cell:getIdx() + 1

                if _viewType == 2 then
                    if countSelected() >= 1 then
                        for k, v in pairs(_tmpSelect) do
                            if v and k ~= _tabMap[_splitType][idx]then
                                for kk, vv in ipairs(_tabMap[_splitType]) do
                                    if vv == k then
                                        _tmpSelect[k] = nil
                                        local preCell = self._itemList:cellAtIndex(kk - 1)
                                        if preCell then
                                            preCell:refresh({
                                                idx = kk,
                                                itemData = _list[_splitType][k],
                                                sel = false,
                                                itemType = _splitType
                                            })
                                        end
                                        break
                                    end
                                end
                                break
                            end
                        end
                    end
                end

                touch(_tabMap[_splitType][idx])
                cell:refresh({
                    idx = idx,
                    itemData = _list[_splitType][_tabMap[_splitType][idx]],
                    sel = _tmpSelect[_tabMap[_splitType][idx]],
--                    count = countSelected(),
                    itemType = _splitType
                })
            end
        })

        self._itemList:setPosition(0, 0)
        self._rootnode["listView"]:addChild(self._itemList, 1)
    end

    initItems()
end



return ItemChooseScene

