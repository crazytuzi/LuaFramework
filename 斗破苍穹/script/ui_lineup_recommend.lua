UILineupRecommend = { }

local ui_scrollView = nil
local ui_svItem = nil

local function cleanScrollView(_isRelease)
    if _isRelease then
        if ui_svItem and ui_svItem:getReferenceCount() > 1 then
            ui_svItem:release()
            ui_svItem = nil
        end
        if ui_scrollView then
            ui_scrollView:removeAllChildren()
            ui_scrollView = nil
        end
    else
        if ui_svItem and ui_svItem:getReferenceCount() == 1 then
            ui_svItem:retain()
        end
        if ui_scrollView then
            ui_scrollView:removeAllChildren()
        end
    end
end

local function layoutScrollView(_listData, _initItemFunc)
    cleanScrollView()
    ui_scrollView:jumpToTop()
    local _innerHeight, SCROLLVIEW_ITEM_SPACE = 0, 20
    for key, obj in pairs(_listData) do
        local scrollViewItem = ui_svItem:clone()
        _initItemFunc(scrollViewItem, obj)
        ui_scrollView:addChild(scrollViewItem)
        _innerHeight = _innerHeight + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
    end
    _innerHeight = _innerHeight + SCROLLVIEW_ITEM_SPACE
    if _innerHeight < ui_scrollView:getContentSize().height then
        _innerHeight = ui_scrollView:getContentSize().height
    end
    ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, _innerHeight))
    local childs = ui_scrollView:getChildren()
    local prevChild = nil
    for i = 1, #childs do
        if i == 1 then
            childs[i]:setPosition((ui_scrollView:getContentSize().width - childs[i]:getContentSize().width) / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        else
            childs[i]:setPosition((ui_scrollView:getContentSize().width - childs[i]:getContentSize().width) / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        end
        prevChild = childs[i]
    end
    ActionManager.ScrollView_SplashAction(ui_scrollView)
end

function UILineupRecommend.init()
    ui_scrollView = ccui.Helper:seekNodeByName(UILineupRecommend.Widget, "view")
    ui_svItem = ui_scrollView:getChildByName("image_info"):clone()
    UILineupRecommend.Widget:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
        end
    end )
end

function UILineupRecommend.setup()
    local playerCards = {}
    if net.InstPlayerCard then
        for key, value in pairs(net.InstPlayerCard) do
            playerCards[value.int["3"]] = true
        end
    end
    layoutScrollView(require("LineupRecommend"), function(_item, _data)
        local ui_title = ccui.Helper:seekNodeByName(_item, "text_title")
        ui_title:setString(_data.name)
        local ui_level = ccui.Helper:seekNodeByName(_item, "image_lv")
        ui_level:loadTexture(string.format("ui/j_%s.png", _data.level))
        local cardIds = utils.stringSplit(_data.cardIds, ";")
        local ui_cardItem = _item:getChildByName("image_frame_card")
        ui_cardItem:setName("image_frame_card1")
        local _cardItemPosX = _item:getContentSize().width / 2
        local _cardItemSpace = 30
        if #cardIds > 0 then
            if #cardIds == 3 then
                _cardItemSpace = 30
            elseif #cardIds == 4 then
                _cardItemSpace = 10
            end
            _cardItemPosX =(_item:getContentSize().width -(ui_cardItem:getContentSize().width * #cardIds + _cardItemSpace *(#cardIds - 1))) / 2
        end
        for key, _id in pairs(cardIds) do
            local cardItem = _item:getChildByName("image_frame_card" .. key)
            if not cardItem then
                cardItem = ui_cardItem:clone()
                cardItem:setName("image_frame_card" .. key)
                _item:addChild(cardItem)
            end
            cardItem:setPositionX(_cardItemPosX + cardItem:getContentSize().width / 2)
            _cardItemPosX = cardItem:getRightBoundary() + _cardItemSpace
            local cardData = DictCard[_id]
            if cardData then
                cardItem:loadTexture(utils.getQualityImage(dp.Quality.card, cardData.qualityId, dp.QualityImageType.small))
                local ui_cardIcon = cardItem:getChildByName("image_card")
                ui_cardIcon:loadTexture("image/" .. DictUI[tostring(cardData.smallUiId)].fileName)
                cardItem:getChildByName("image_title"):setVisible(playerCards[cardData.id])
                local ui_name = cardItem:getChildByName("text_name")
                ui_name:setString(cardData.name)
                ui_name:setTextColor(utils.getQualityColor(cardData.qualityId))
                ui_cardIcon:setTouchEnabled(true)
                ui_cardIcon:addTouchEventListener( function(sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        UICardInfo.setDictCardId(cardData.id)
                        UIManager.pushScene("ui_card_info")
                    end
                end )
            end
        end
    end )
end

function UILineupRecommend.free()
    cleanScrollView(true)
end