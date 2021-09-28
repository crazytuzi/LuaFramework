--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-18
-- Time: 下午4:16
-- To change this template use File | Settings | File Templates.
--
local data_jingyuantype_jingyuantype = require("data.data_jingyuantype_jingyuantype")
local data_item_nature = require("data.data_item_nature")
local data_soul_soul = require("data.data_soul_soul")
local data_item_item = require("data.data_item_item")
local data_config_config = require("data.data_config_config")

local function count_spirit_exp(resid, lv, curexp)
    --该精元的初始精元（item表-price）+升级到当前等级吞噬掉的经验（soul-arr_sumexp）+当前经验
    local baseexp
    local eatexp
    local baseInfo = data_item_item[resid]
    if lv == 0 then
        baseexp = baseInfo.price
        eatexp = 0
    else
        baseexp = baseInfo.price
        eatexp = data_soul_soul[lv + 1].arr_sumexp[baseInfo.quality]
    end

    return baseexp + eatexp + (curexp or 0)
end

local function get_max_exp(lv, quality)
    return data_soul_soul[lv + 1].arr_exp[quality]
end

local SpiritTouchIcon = class("SpiritTouchIcon", function(param)
    return require("game.Spirit.SpiritIcon").new(param)
end)

function SpiritTouchIcon:ctor()
    self._selectedTagSprite = display.newSprite("#spirit_list_gou.png")
    self._selectedTagSprite:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
    self:addChild(self._selectedTagSprite, 1, 100)
end

function SpiritTouchIcon:setSelected(b)
    self._selectedTagSprite:setVisible(b)
end


local SpiritItem = class("SpiritShowItem", function()
    return CCTableViewCell:new()
end)

function SpiritItem:getContentSize()
    return CCSizeMake(display.width, 152)
end

function SpiritItem:create(param)
    local _itemData = param.itemData
    local _viewSize = param.viewSize

    local proxy = CCBProxy:create()
    self._rootnode = {}
    self._bg = CCBuilderReaderLoad("spirit/spirit_show_item.ccbi", proxy, self._rootnode)
    self._bg:setPosition(_viewSize.width / 2, self._bg:getContentSize().height / 2)
    self:addChild(self._bg)

    self:refresh(param)
    return self
end

function SpiritItem:refresh(param)
    local _itemData = param.itemData
    local _selected = param.selected or {}
    for i = 1, 5 do
        self._rootnode[string.format("headIcon_%d", i)]:removeAllChildrenWithCleanup(true)
        if _itemData[i] then
            local name = string.format("headIcon_%d", i)
            local icon = SpiritTouchIcon.new({
                id          = _itemData[i].data._id,
                resId       = _itemData[i].data.resId,
                lv          = _itemData[i].data.level,
                exp         = _itemData[i].data.curExp or 0,
                bShowName   = true,
                bShowNameBg = true,
                bShowLv     = true
            })
            icon:setPosition(self._rootnode[name]:getContentSize().width / 2, self._rootnode[name]:getContentSize().height / 2)
            self._rootnode[name]:addChild(icon)

            icon:setSelected(_selected[i])
        end
    end
end

function SpiritItem:touch(param)
    self:refresh(param)
    PostNotice(NoticeKey.SpiritUpgradeScene_UpdateExpBar)
end

local SpiritUpgradeScene = class("SpiritUpgradeScene", function()
    return require("game.BaseScene").new({
        contentFile = "spirit/spirit_upgrade_scene.ccbi",
        subTopFile = "spirit/spirit_upgrade_sub_top.ccbi"
    })
end)

local BAR_RECT

function SpiritUpgradeScene:ctor(index)
     ResMgr.removeBefLayer()

    local _spiritCtrl = require("game.Spirit.SpiritCtrl")
    local _spiritList = {}
    local _selected   = {}
    local _item = _spiritCtrl.get("spiritList")[index]
    local _listdata = _spiritCtrl.get("spiritList")


    _spiritCtrl.groupUpgradeSpirit(_item, _spiritList)
    display.addSpriteFramesWithFile("ui/ui_spirit_list.plist", "ui/ui_spirit_list.png")


    BAR_RECT = self._rootnode["tmpExpBar"]:getTextureRect()
    --  根据屏幕缩放部分
    local _listHeight = self:getCenterHeightWithSubTop() - self._rootnode["btnNodeView"]:getContentSize().height -
            self._rootnode["topInfoView"]:getContentSize().height
    local _sz = CCSizeMake(display.width, _listHeight)

-----------------------------------------------------------------------------------
    --  隐藏预览效果
    local function hideTmpView()
        self._rootnode["lvArrowSprite"]:setVisible(false)
        self._rootnode["propValueLabel_1"]:setVisible(false)
        self._rootnode["propValueLabel_2"]:setVisible(false)
        self._rootnode["propArrow_1"]:setVisible(false)
        self._rootnode["propArrow_2"]:setVisible(false)
        self._rootnode["nextLevelLabel"]:setVisible(false)
    end

    --  更新经验条
    local function refreshExpBar()
        self._rootnode["spiritLevelLabel"]:setString(tostring(_item.data.level))

        local curExp = _item.data.curExp
        local maxExp = get_max_exp(_item.data.level, _item.data.quality)
        self._rootnode["expBar"]:setTextureRect(CCRectMake(self._rootnode["expBar"]:getTextureRect().origin.x, self._rootnode["expBar"]:getTextureRect().origin.y,
            BAR_RECT.size.width * (curExp / maxExp), BAR_RECT.size.height))

        self._rootnode["tmpExpBar"]:setTextureRect(CCRectMake(self._rootnode["tmpExpBar"]:getTextureRect().origin.x, self._rootnode["tmpExpBar"]:getTextureRect().origin.y,
            BAR_RECT.size.width * (curExp / maxExp), BAR_RECT.size.height))

        self._rootnode["curExpLabel"]:setString(tostring(curExp))
        self._rootnode["maxExp"]:setString(tostring(maxExp))

        for k, v in ipairs(_item.data.props) do
            local l = string.format("propNameLabel_%d", k)
            self._rootnode[l]:setString(data_item_nature[v.idx].nature .. "：")
            self._rootnode[l]:setVisible(true)
            self._rootnode[l]:removeChildByTag(100)
            local valueLabel = ui.newTTFLabel({
                text = tostring(v.val),
                size = 22,
                font = FONTS_NAME.font_haibao,
                color = ccc3(224, 190, 127)
            })
            valueLabel:setAnchorPoint(0, 0.5)
            valueLabel:setPosition(self._rootnode[l]:getContentSize().width, self._rootnode[l]:getContentSize().height / 2)
            self._rootnode[l]:addChild(valueLabel)

            valueLabel:setTag(100)
        end
        hideTmpView()
        self._rootnode["iconCountLabel"]:setString(tostring(_spiritCtrl.countUpgradeSpirit(_spiritList)))
        self._rootnode["maxIconCountLabel"]:setString(tostring(_spiritCtrl.get("size").max))
    end

    --  计算真气累积经验
    local function countExp()
        local allExp = 0
        for row, rv in ipairs(_spiritList) do
            for col, cv in ipairs(rv) do
                if _selected[row] and _selected[row][col] then
                    allExp = allExp + count_spirit_exp(cv.data.resId, cv.data.level, cv.data.curExp)
                end
            end
        end
        return allExp
    end

    --  计算累积经验能增加的等级
    local function getTmpLv()
        local tmpExp = countExp() + _item.data.curExp
        local tmpLv = _item.data.level + 1
        while data_soul_soul[tmpLv]["arr_exp"][_item.baseData.quality] <= tmpExp do
            tmpExp = tmpExp - data_soul_soul[tmpLv]["arr_exp"][_item.baseData.quality]
            tmpLv = tmpLv + 1
        end
        tmpLv = tmpLv - 1
        return tmpExp, tmpLv
    end

    --  选择精元时候临时效果
    local function refreshTmpExpBar()
        local maxExp = get_max_exp(_item.data.level, _item.data.quality)
        local tmpExp, tmpLv = getTmpLv()
        local scaleX = tmpExp / maxExp
        if scaleX > 1 then
            scaleX = 1
        end
        self._rootnode["curExpLabel"]:setString(tostring(tmpExp))
        self._rootnode["tmpExpBar"]:setTextureRect(CCRectMake(self._rootnode["tmpExpBar"]:getTextureRect().origin.x, self._rootnode["tmpExpBar"]:getTextureRect().origin.y,
            BAR_RECT.size.width * scaleX, BAR_RECT.size.height))
        if tmpLv > _item.data.level then
            self._rootnode["nextLevelLabel"]:setVisible(true)
            self._rootnode["nextLevelLabel"]:setString(tostring(tmpLv))
            self._rootnode["lvArrowSprite"]:setVisible(true)
            if _item.baseData.arr_addition then
                for k, v in ipairs(_item.baseData.arr_addition) do
                    self._rootnode["propValueLabel_" .. tostring(k)]:setVisible(true)
                    self._rootnode["propValueLabel_" .. tostring(k)]:setString(tostring(_item.baseData.arr_value[k] + tmpLv * v))
                    self._rootnode["propArrow_" .. tostring(k)]:setVisible(true)
                end
            end
        else
            hideTmpView()
        end
    end

    --  基本信息
    local function initBaseInfo()
        self._rootnode["nameLabel"]:setString(_item.baseData.name)
        self._rootnode["nameLabel"]:setColor(NAME_COLOR[_item.baseData.quality])
        self._rootnode["spiritTypeLabel"]:setString(data_jingyuantype_jingyuantype[_item.baseData.pos].name)

        for i = 1, _item.baseData.quality do
            self._rootnode[string.format("star_%d_%d", (_item.baseData.quality % 2), i)]:setVisible(true)
        end

        local icon = require("game.Spirit.SpiritIcon").new({
            id = _item.data._id,
            resId = _item.data.resId,
            lv = _item.data.level,
            exp = _item.data.curExp or 0,
            bShowName = false,
            bShowLv = false
        })
        icon:setPosition(self._rootnode["iconSprite"]:getContentSize().width / 2, self._rootnode["iconSprite"]:getContentSize().height / 2)
        self._rootnode["iconSprite"]:addChild(icon)

        refreshExpBar()
    end

    --  设置区域
    local function resetContentSize()
        local s
        if display.width / self._rootnode["spiritListBg"]:getContentSize().width > _listHeight / self._rootnode["spiritListBg"]:getContentSize().height then
            s = display.width / self._rootnode["spiritListBg"]:getContentSize().width
        else
            s = _listHeight / self._rootnode["spiritListBg"]:getContentSize().height
        end

        self._rootnode["spiritListBg"]:setScale(s)

        self._rootnode["spiritListView"]:setContentSize(_sz)
        self._rootnode["touchNode"]:setContentSize(_sz)
        self._rootnode["spiritContainer"]:setPosition(_sz.width / 2, _sz.height / 2)
        _sz = CCSizeMake(_sz.width, _sz.height * 0.92)
        self._rootnode["upArrow"]:setPositionY(_sz.height)
        self._rootnode["spiritContainer"]:setContentSize(_sz)
        self._rootnode["spiritListView"]:setPosition(display.width / 2, self._rootnode["btnNodeView"]:getContentSize().height)
    end

    --  更新上下箭头
    local function updateArrow()
        self:performWithDelay(function()
            local posY = self._spiritListView:getContentOffset().y
            local maxOffsetY = self._spiritListView:maxContainerOffset().y
            local minOffsetY = self._spiritListView:minContainerOffset().y

            if maxOffsetY ~= minOffsetY then
                if posY >= maxOffsetY then
                    self._rootnode["upArrow"]:setVisible(true)
                    self._rootnode["downArrow"]:setVisible(false)
                elseif  posY <= minOffsetY then
                    self._rootnode["upArrow"]:setVisible(false)
                    self._rootnode["downArrow"]:setVisible(true)
                else
                    self._rootnode["upArrow"]:setVisible(true)
                    self._rootnode["downArrow"]:setVisible(true)
                end
            end
        end, 0.5)
    end

    --  选择精元
    local function onTouch(posX, posY, cell)
        local idx = cell:getIdx() + 1
        local pos = cell:convertToNodeSpace(ccp(posX, posY))
        local sz = cell:getContentSize()
        local i = 0
        if pos.x > sz.width * (4 / 5) and pos.x < sz.width then
            i = 5
        elseif pos.x > sz.width * (3 / 5)  then
            i = 4
        elseif pos.x > sz.width * (2 / 5)  then
            i = 3
        elseif pos.x > sz.width * (1 / 5) then
            i = 2
        elseif pos.x > 0 then
            i = 1
        end

        if i >= 1 and i <= 5 then
            local info = _spiritList[idx]
            if info and info[i] then
                if _selected[idx] and _selected[idx][i] then
                    _selected[idx][i] = false
                elseif _selected[idx] then
                    _selected[idx][i] = true
                else
                    _selected[idx] = {}
                    _selected[idx][i] = true
                end

                cell:touch({
                    idx = idx,
                    itemData = _spiritList[idx],
                    selected = _selected[idx]
                })
            end
        end
    end

    -- 精元列表
    local function initListView()
        self._rootnode["touchNode"]:setTouchEnabled(true)
        self._rootnode["touchNode"]:setZOrder(1)
        local posX = 0
        local posY = 0
        self._rootnode["touchNode"]:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
            if event.name == "began" then
                posX = event.x
                posY = event.y
                return true
            elseif event.name == "ended" then
                updateArrow()
            end
        end)
        self._rootnode["touchNode"]:setTouchSwallowEnabled(false)

        self._spiritListView = require("utility.TableViewExt").new({
            size        = _sz,
            direction   = kCCScrollViewDirectionVertical,
            createFunc  = function(idx)
                local item = SpiritItem.new()
                idx = idx + 1
                return item:create({
                    viewSize = _sz,
                    itemData = _spiritList[idx],
                    idx      = idx,
                })
            end,
            refreshFunc = function(cell, idx)
                idx = idx + 1
                cell:refresh({
                    idx = idx,
                    itemData = _spiritList[idx],
                    selected = _selected[idx]
                })
            end,
            cellNum   = #_spiritList,
            cellSize    = SpiritItem.new():getContentSize(),
            touchFunc = function(cell)
                onTouch(posX, posY, cell)
            end
        })
        self._spiritListView:setPosition(0, 0)
        self._rootnode["spiritContainer"]:addChild(self._spiritListView)
    end

    --  更新列表
    local function refreshListView()
        _selected = {}
        _spiritCtrl.groupUpgradeSpirit(_item, _spiritList)
        self._spiritListView:resetCellNum(#_spiritList)

        local maxOffsetY = self._spiritListView:maxContainerOffset().y
        local minOffsetY = self._spiritListView:minContainerOffset().y
        self._rootnode["upArrow"]:setZOrder(2)
        self._rootnode["downArrow"]:setZOrder(2)
        if maxOffsetY ~= minOffsetY then
            self._rootnode["upArrow"]:setVisible(false)
            self._rootnode["downArrow"]:setVisible(true)
        else
            self._rootnode["upArrow"]:setVisible(false)
            self._rootnode["downArrow"]:setVisible(false)
        end
    end

    --获得选择真气的ID
    local function getSelectedID()
        local allExp = 0
        local idx = {}
        for row, rv in ipairs(_spiritList) do
            for col, cv in ipairs(rv) do
                if _selected[row] and _selected[row][col] then
                    table.insert(idx, cv.data._id)
                end
            end
        end
        return idx
    end

    --  注册按钮事件
    local function onQuickSelectedFinish(param)
        for row, rv in ipairs(_spiritList) do
            for col, cv in ipairs(rv) do
                if param[cv.baseData.quality] then
                    if _selected[row] then
                        _selected[row][col] = true
                    else
                        _selected[row] = {}
                        _selected[row][col] = true
                    end
                else
                    if _selected[row] and _selected[row][col] then
                        _selected[row][col] = false
                    end
                end
            end
        end
        self._spiritListView:resetCellNum(#_spiritList)
        refreshTmpExpBar()
    end

    --  快速选择
    local function onQuickSelected()
        local layer = require("game.Spirit.SpiritQuickSelectedLayer").new(onQuickSelectedFinish)
        self:addChild(layer, 10)
    end

    --  取消选择
    local function onCancel()
        for k, v in pairs(_selected) do
            for kk, vv in pairs(v) do
                v[kk] = false
            end
        end
        self._spiritListView:resetCellNum(#_spiritList)
        refreshTmpExpBar()
    end

    --  确定
    local function onConfirm()
        local _, tmpLv = getTmpLv()

        if tmpLv > data_config_config[1].jingYuanLvLimit then
            show_tip_label("当前等级达到最大限制")
            return
        end

        local ids = getSelectedID()
        if #ids > 0 then
            _spiritCtrl.upgrade(_item.data._id, ids, function(data)
                _item.data.curExp = data["1"].curExp
                _item.data.level = data["1"].level
                _item.data.props = data["1"].props

                refreshListView()
                refreshExpBar()
            end)
        else
            show_tip_label("请选择真气")
        end
    end

    local i = 255
    local opt = 2
    local function expBarEffect()
        self._rootnode["tmpExpBar"]:setOpacity(i)
        if opt == 1 then
            i = i + 10
        else
            i = i - 10
        end

        if i <= 0 then
            opt = 1
            i = 0
        elseif i >= 255 then
            opt = 2
            i = 255
        end
    end
    self._rootnode["tmpExpBar"]:schedule(expBarEffect, 0.01)

    initBaseInfo()
    resetContentSize()
--    initListView()
--    refreshListView()

    self._rootnode["quickBtn"]:addHandleOfControlEvent(onQuickSelected, CCControlEventTouchDown)
    self._rootnode["cancelBtn"]:addHandleOfControlEvent(onCancel, CCControlEventTouchDown)
    self._rootnode["confirmBtn"]:addHandleOfControlEvent(onConfirm, CCControlEventTouchUpInside)
    self._rootnode["backBtn"]:addHandleOfControlEvent(function()
        pop_scene()
    end, CCControlEventTouchUpInside)

    self.initListView = initListView
    RegNotice(self, refreshTmpExpBar, NoticeKey.SpiritUpgradeScene_UpdateExpBar)
end

function SpiritUpgradeScene:onEnter()
    self:regNotice()
    PostNotice(NoticeKey.UNLOCK_BOTTOM)

    self:performWithDelay(function()
        self.initListView()
    end, 0.05)
end

function SpiritUpgradeScene:onExit()
    self:unregNotice()
    UnRegNotice(self, NoticeKey.SpiritUpgradeScene_UpdateExpBar)
    CCTextureCache:sharedTextureCache():removeUnusedTextures()
end


return SpiritUpgradeScene

