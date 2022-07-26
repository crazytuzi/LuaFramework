require"Lang"
UIPilltowerRank = {
    TYPE_DAY = 3,
    -- 单日战绩榜
    TYPE_HISTORY = 2,-- 历史战绩榜
}

local PAGE_ITEM_SIZE = 10 -- 每页显示的个数
local MAX_ITEM_SIZE = 500000 -- 最大显示条数

local userData = nil
local ui_scrollView = nil
local ui_svItem = nil
local _listData = nil
local _scrollViewItemSpace = 10
local _curListType = UIPilltowerRank.TYPE_DAY

local initScrollViewItem = nil

local function cleanScrollView(_isRelease)
    if _isRelease then
        if ui_svItem and ui_svItem:getReferenceCount() >= 1 then
            ui_svItem:release()
            ui_svItem = nil
        end
        if ui_scrollView then
            ui_scrollView:removeAllChildren()
            ui_scrollView = nil
        end
    else
        if ui_svItem:getReferenceCount() == 1 then
            ui_svItem:retain()
        end
        ui_scrollView:removeAllChildren()
    end
end

local function layoutScrollView(innerHeight)
    if innerHeight < ui_scrollView:getContentSize().height then
        innerHeight = ui_scrollView:getContentSize().height
    end
    ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, innerHeight))
    local childs = ui_scrollView:getChildren()
    local prevChild = nil
    for i = 1, #childs do
        if i == 1 then
            childs[i]:setPosition(cc.p(ui_scrollView:getContentSize().width / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - _scrollViewItemSpace))
        else
            childs[i]:setPosition(cc.p(ui_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - _scrollViewItemSpace))
        end
        prevChild = childs[i]
    end
end

local function addMoreItemToScrollView()
    local scrollViewItem = ui_svItem:clone()
    scrollViewItem:setTag(-100)
    initScrollViewItem(scrollViewItem)
    ui_scrollView:addChild(scrollViewItem)
    return scrollViewItem:getContentSize().height
end

local function showScrollView()
    cleanScrollView()
    local innerHeight = 0
    if _listData then
        for key, obj in pairs(_listData) do
            local scrollViewItem = ui_svItem:clone()
            initScrollViewItem(scrollViewItem, obj)
            ui_scrollView:addChild(scrollViewItem)
            innerHeight = innerHeight + scrollViewItem:getContentSize().height + _scrollViewItemSpace
        end
        innerHeight = innerHeight + addMoreItemToScrollView() + _scrollViewItemSpace
    end
    innerHeight = innerHeight + _scrollViewItemSpace
    layoutScrollView(innerHeight)
    ActionManager.ScrollView_SplashAction(ui_scrollView)
end

local function setListData(data)
    local msgData = data.msgdata.string.r1
    local image_basemap = UIPilltowerRank.Widget:getChildByName("image_basemap")
    image_basemap:getChildByName("text_rank"):setString(Lang.ui_pilltower_rank1 .. data.msgdata.int.r2)
    if msgData and string.len(msgData) > 0 then
        local _isShowScrollView = false
        if not _listData then
            _listData = { }
            _isShowScrollView = true
        end
        local _moreItemHeight = 0
        if not _isShowScrollView then
            local childs = ui_scrollView:getChildren()
            if childs and #childs > 0 and childs[#childs]:getTag() < 0 then
                _moreItemHeight = childs[#childs]:getContentSize().height
                childs[#childs]:removeFromParent()
                childs[#childs] = nil
            end
        end
        local _isResetinnerHeight = false
        local _index = math.floor(#_listData / PAGE_ITEM_SIZE) * 10 + 1

        local innerHeight = ui_scrollView:getInnerContainerSize().height
        if innerHeight == ui_scrollView:getContentSize().height then
            innerHeight = _scrollViewItemSpace
            _isResetinnerHeight = true
        end
        local msgLists = utils.stringSplit(msgData, "/")
        for key, obj in pairs(msgLists) do
            local _objData = utils.stringSplit(obj, "|")
            -- 名次_玩家id_玩家名_最高层数_等级_勋章数_联盟名称_头像id(卡牌字典表id)
            local _tempData = {
                rank = tonumber(_objData[1]),
                playerId = tonumber(_objData[2]),
                playerName = _objData[3],
                maxPoint = tonumber(_objData[4]),
                level = tonumber(_objData[5]),
                medalCount = tonumber(_objData[6]),
                allianceName = _objData[7],
                iconId = tonumber(utils.stringSplit(_objData[8],"_")[1]),
                isAwake = tonumber(utils.stringSplit(_objData[8],"_")[2])
            }            
            if not _isShowScrollView then
                if _listData[_index] then
                    local childs = ui_scrollView:getChildren()
                    if childs and childs[_index] then
                        initScrollViewItem(childs[_index], _tempData)
                        if _isResetinnerHeight then
                            innerHeight = innerHeight + childs[_index]:getContentSize().height + _scrollViewItemSpace
                        end
                    end
                    _listData[_index] = nil
                else
                    local scrollViewItem = ui_svItem:clone()
                    initScrollViewItem(scrollViewItem, _tempData)
                    ui_scrollView:addChild(scrollViewItem)
                    innerHeight = innerHeight + scrollViewItem:getContentSize().height + _scrollViewItemSpace
                end
            end
            _listData[_index] = _tempData
            _index = _index + 1
            _tempData = nil
        end
        if not _isShowScrollView then
            if #_listData >= MAX_ITEM_SIZE then
                innerHeight = innerHeight - _moreItemHeight - _scrollViewItemSpace
            else
                if _isResetinnerHeight then
                    innerHeight = innerHeight + addMoreItemToScrollView() + _scrollViewItemSpace
                else
                    addMoreItemToScrollView()
                end
            end
        end
        -- if _listData then
        -- utils.quickSort(_listData, function(obj1, obj2) if obj1.rank > obj2.rank then return true end end)
        -- end
        if _isShowScrollView then
            showScrollView()
        else
            layoutScrollView(innerHeight)
        end
    else
        UIManager.showToast(Lang.ui_pilltower_rank2)
    end
end

local function getListData(_page)
    UIPilltower.netSendPackage( { int = { p2 = _curListType, p3 = _page } }, setListData)
end

initScrollViewItem = function(_item, _data)
    local item_iconFrame = _item:getChildByName("image_frame_player")
    if _data then
        _item:getChildByName("text_hint"):setVisible(false)
        local item_ranking = item_iconFrame:getChildByName("text_ranking")
        local item_icon = item_iconFrame:getChildByName("image_player")
        local item_playerName = item_iconFrame:getChildByName("text_name")
        local item_playerLevel = item_iconFrame:getChildByName("text_lv")
        local item_allianceName = item_iconFrame:getChildByName("text_alliance")
        local item_maxPoint = item_iconFrame:getChildByName("text_notice")
        local item_medalNum = item_iconFrame:getChildByName("image_flag"):getChildByName("text_number")
        if _data.rank <= 3 then
            item_ranking:setVisible(false)
            _item:loadTexture(string.format("ui/ph0%d.png", _data.rank))
        else
            item_ranking:setString(_data.rank)
        end
        local dictCard = DictCard[tostring(_data.iconId)]
        if dictCard then
            if _data.isAwake == 1 then
                item_icon:loadTexture("image/" .. DictUI[tostring(dictCard.awakeSmallUiId)].fileName)
            else
                item_icon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
            end
        end
        item_playerName:setString(_data.playerName)
        item_playerLevel:setString(Lang.ui_pilltower_rank3 .. _data.level)
        if _data.allianceName and _data.allianceName ~= "" then
            item_allianceName:setString(Lang.ui_pilltower_rank4 .. _data.allianceName)
        else
            item_allianceName:setString("")
        end
        item_maxPoint:setString(string.format(Lang.ui_pilltower_rank5, _data.maxPoint))
        item_medalNum:setString("×" .. _data.medalCount)
        item_iconFrame:setTouchEnabled(true)
        item_iconFrame:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.enemyPlayerInfo, msgdata = { int = { playerId = _data.playerId } } }, function(_msgData)
                    if _msgData.msgdata.message then
                        pvp.loadGameData(_msgData)
                        UIManager.pushScene("ui_arena_check")
                    end
                end )
            end
        end )
    else
        _item:loadTexture("ui/btn_l.png")
        item_iconFrame:setVisible(false)
        local text_hint = _item:getChildByName("text_hint")
        text_hint:setPositionY(_item:getContentSize().height / 2)
        text_hint:setVisible(true)
        _item:setTouchEnabled(true)
        _item:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                getListData(math.floor(#_listData / PAGE_ITEM_SIZE) + 1)
            end
        end )
    end
end

function UIPilltowerRank.init()
    local image_basemap = UIPilltowerRank.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    btn_close:setPressedActionEnabled(true)
    local function onClickEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            end
        end
    end
    btn_close:addTouchEventListener(onClickEvent)
    ui_scrollView = image_basemap:getChildByName("view_list")
    ui_svItem = ui_scrollView:getChildByName("image_di_ranking"):clone()
end

function UIPilltowerRank.setup()
    cleanScrollView()
    local _prevUIBtn = nil
    local image_basemap = UIPilltowerRank.Widget:getChildByName("image_basemap")
    local btn_level = image_basemap:getChildByName("btn_level")
    local btn_rank = image_basemap:getChildByName("btn_rank")
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if _prevUIBtn == sender then
                return
            end
            _prevUIBtn = sender
            btn_level:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            btn_level:setTitleColor(cc.c3b(255, 255, 255))
            btn_rank:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            btn_rank:setTitleColor(cc.c3b(255, 255, 255))
            sender:loadTextures("ui/yh_btn02.png", "ui/yh_btn02.png")
            sender:setTitleColor(cc.c3b(51, 25, 4))
            if sender == btn_level then
                _curListType = UIPilltowerRank.TYPE_DAY
                _listData = nil
            elseif sender == btn_rank then
                _curListType = UIPilltowerRank.TYPE_HISTORY
                _listData = nil
            end
            getListData(1)
        end
    end
    btn_level:addTouchEventListener(onButtonEvent)
    btn_rank:addTouchEventListener(onButtonEvent)
    btn_level:releaseUpEvent()

    image_basemap:getChildByName("text_name"):setString(net.InstPlayer.string["3"])
    image_basemap:getChildByName("text_lv"):setString(Lang.ui_pilltower_rank6 .. net.InstPlayer.int["4"])
    image_basemap:getChildByName("text_rank"):setString(Lang.ui_pilltower_rank7 .. 0)
end

function UIPilltowerRank.free()
    userData = nil
    cleanScrollView(true)
    _curListType = UIPilltowerRank.TYPE_DAY
    _listData = nil
end

function UIPilltowerRank.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_pilltower_rank")
end
