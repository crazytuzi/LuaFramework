require"Lang"
UIShopRecruitJewel = {
    silverRecruitType = nil,
    recruitTokenNum = 0,
    Type =
    {
        SILVER = 1,
        GOLD = 2,
        JEWEL = 3,
    }
}
local flag = nil
local cardItem = nil
local recruitType = nil
function UIShopRecruitJewel.init()
    local btn_close = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "btn_close")
    local ui_image_token = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_di_token")
    local ui_image_token_ten = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_di_token_ten")
    local ui_image_one = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_di_one")
    local ui_image_ten = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_di_ten")
    local btn_token = ui_image_token:getChildByName("btn_recruit")
    local btn_token_ten = ui_image_token_ten:getChildByName("btn_recruit")
    local btn_one = ui_image_one:getChildByName("btn_recruit")
    local btn_ten = ui_image_ten:getChildByName("btn_recruit")
    local function TouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_close then
                flag = nil
            elseif sender == btn_token then
                flag = 1
            elseif sender == btn_one then
                flag = 2
            elseif sender == btn_ten then
                flag = 3
            elseif sender == btn_token_ten then
                flag = 4
            end
            UIManager.popScene()
        end
    end
    btn_close:setPressedActionEnabled(true)
    btn_token:setPressedActionEnabled(true)
    btn_one:setPressedActionEnabled(true)
    btn_ten:setPressedActionEnabled(true)
    btn_token_ten:setPressedActionEnabled(true)
    btn_close:addTouchEventListener(TouchEvent)
    btn_token:addTouchEventListener(TouchEvent)
    btn_one:addTouchEventListener(TouchEvent)
    btn_ten:addTouchEventListener(TouchEvent)
    btn_token_ten:addTouchEventListener(TouchEvent)
    local ui_panel = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "panel_card")
    cardItem = ui_panel:getChildByName("image_base_before"):clone()
    if cardItem:getReferenceCount() == 1 then
        cardItem:retain()
    end
    ui_image_token:getChildByName("image_good"):setVisible(false)
    ui_image_token:getChildByName("image_hint"):setVisible(false)
    ui_image_token:getChildByName("text_gratis_countdown"):setVisible(false)
    btn_token:setEnabled(false)
end
function UIShopRecruitJewel.setup()
    local ui_panel = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "panel_card")
    ui_panel:removeAllChildren()
    local index = 1
    local preViewThing = { }
    for key, obj in pairs(DictRecruitCard) do
        if obj.recruitTypeId == StaticRecruit_Type.diamondRecruit and StaticQuality.purple == obj.qualityId and recruitType == UIShopRecruitJewel.Type.JEWEL then
            table.insert(preViewThing, obj)
        elseif obj.recruitTypeId == StaticRecruit_Type.silverRecruit and recruitType == UIShopRecruitJewel.Type.SILVER and(StaticQuality.blue == obj.qualityId or StaticQuality.purple == obj.qualityId) then
            table.insert(preViewThing, obj)
        end
    end
    local function setItemView(item, index)
        local obj = preViewThing[index]
        local ui_image = item:getChildByName("image_warrior")
        local ui_name = item:getChildByName("image_advance_before"):getChildByName("text_product")
        local cardId = obj.cardId
        local name = DictCard[tostring(cardId)].name
        local bigImageId = DictCard[tostring(cardId)].bigUiId
        local image = "image/" .. DictUI[tostring(bigImageId)].fileName
        ui_name:setString(name)
        ui_image:loadTexture(image)
        local borderImage = utils.getQualityImage(dp.Quality.card, obj.qualityId, dp.QualityImageType.middle)
        item:loadTexture(borderImage)
    end
    local _cardItem = cardItem:clone()
    index = index + 1
    setItemView(_cardItem, index)
    _cardItem:setPosition(cc.p(ui_panel:getContentSize().width / 2, 178))
    ui_panel:addChild(_cardItem)
    local _cardItem1 = cardItem:clone()
    index = index + 1
    setItemView(_cardItem1, index)
    _cardItem1:setPosition(cc.p(ui_panel:getContentSize().width * 3 / 2, 178))
    ui_panel:addChild(_cardItem1)
    local function itemAction(sender)
        if index == #preViewThing then
            index = 1
        end
        index = index + 1
        setItemView(sender, index)
        sender:setPosition(cc.p(ui_panel:getContentSize().width * 2, 178))
        sender:runAction(cc.Sequence:create(cc.MoveBy:create(10, cc.p(- ui_panel:getContentSize().width * 2 - _cardItem1:getContentSize().width / 2 - 100, 0)), cc.CallFunc:create(itemAction)))
    end

    _cardItem:runAction(cc.Sequence:create(cc.MoveBy:create(2.5, cc.p(- ui_panel:getContentSize().width / 2 - _cardItem:getContentSize().width / 2 - 100, 0)), cc.CallFunc:create(itemAction)))
    _cardItem1:runAction(cc.Sequence:create(cc.MoveBy:create(7.5, cc.p(- ui_panel:getContentSize().width * 3 / 2 - _cardItem1:getContentSize().width / 2 - 100, 0)), cc.CallFunc:create(itemAction)))
    local ui_image_buy_again = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_buy_again")
    local ui_image_token = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_di_token")
    local ui_image_token_ten = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_di_token_ten")
    local ui_image_one = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_di_one")
    local ui_image_ten = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_di_ten")
    local ui_recruitHint = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_recruit")
    local ui_name = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "text_recruit_jewel")
    --    local ui_text_tencost = ui_image_gold:getChildByName("text_cost")
    local ui_image_silvertip = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_good_have")
    local ui_text_silver_count = ui_image_silvertip:getChildByName("text_number")
    if recruitType == UIShopRecruitJewel.Type.SILVER then
        ui_name:setString(Lang.ui_shop_recruit_jewel1)
        ui_image_one:setVisible(false)
        ui_image_ten:setVisible(false)
        ui_image_token:setVisible(true)
        ui_image_token_ten:setVisible(true)
        ui_image_buy_again:setVisible(true)
        ui_image_buy_again:loadTexture("ui/zm_zi_01.png")
        local ui_label = ui_image_buy_again:getChildByName("label_number")
        ui_label:setVisible(false)
        ui_image_silvertip:setVisible(true)
        ui_recruitHint:setVisible(false)
        local recruitTokenNum = 0
        if net.InstPlayerThing then
            for key, obj in pairs(net.InstPlayerThing) do
                if StaticThing.recruitSign == obj.int["3"] then
                    recruitTokenNum = obj.int["5"]
                    break
                end
            end
        end
        ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "image_good_have"):getChildByName("text_number"):setString("×" .. recruitTokenNum)
    elseif recruitType == UIShopRecruitJewel.Type.JEWEL then
        ui_name:setString(Lang.ui_shop_recruit_jewel2)
        ui_image_buy_again:setVisible(true)
        local ui_label = ui_image_buy_again:getChildByName("label_number")
        if UIShop.recruitPurpleTimer ~= 0 then
            ui_label:setVisible(true)
            ui_image_buy_again:loadTexture("ui/zm_zi_02.png")
            ui_label:setString(UIShop.recruitPurpleTimer)
        else
            ui_label:setVisible(false)
            ui_image_buy_again:loadTexture("ui/zm_zi_05.png")
        end
        ui_image_token:setVisible(false)
        ui_image_token_ten:setVisible(false)
        ui_image_one:setVisible(true)
        ui_image_ten:setVisible(true)

        local image_discount = ccui.Helper:seekNodeByName(ui_image_one, "image_discount")
        UIShop.refreshRecruitIcon(image_discount)
        local text_cost = ccui.Helper:seekNodeByName(ui_image_one, "text_cost")
        text_cost:setString(tostring(UIShop.recruitDiamondOnePrice))

        image_discount = ccui.Helper:seekNodeByName(ui_image_ten, "image_discount")
        UIShop.refreshRecruitIcon(image_discount)
        text_cost = ccui.Helper:seekNodeByName(ui_image_ten, "text_cost")
        text_cost:setString(tostring(UIShop.recruitTenPrice))

        ui_image_silvertip:setVisible(false)
        ui_recruitHint:setVisible(true)
        UIGuidePeople.isGuide(nil, UIShopRecruitJewel)
    end
end 
--- 白银和钻石
function UIShopRecruitJewel.setRecruitType(_recruitType)
    recruitType = _recruitType
end

function UIShopRecruitJewel.free()
    if flag == 1 then
        if UIShopRecruitJewel.silverRecruitType then
            UIShop.sendRecruitData(1, UIShopRecruitJewel.silverRecruitType)
        else
            UIManager.showToast(Lang.ui_shop_recruit_jewel3)
        end
    elseif flag == 2 then
        UIShop.sendRecruitData(3, 2)
    elseif flag == 3 then
        UIShop.sendRecruitData(3, 3)
    elseif flag == 4 then
        UIShop.sendRecruitData(1, 3)
    end
    recruitType = nil
    UIShopRecruitJewel.silverRecruitType = nil
    if cardItem and cardItem:getReferenceCount() >= 1 then
        cardItem:release()
        cardItem = nil
    end
    local ui_panel = ccui.Helper:seekNodeByName(UIShopRecruitJewel.Widget, "panel_card")
    ui_panel:removeAllChildren()
end
