UIShopRecruitPreView = { }
local scrollView = nil
local listItem = nil
local btnSelected = nil
local btnSelectedText = nil
local flag = 1
local preViewThing = { }
local start_x, start_y = nil, nil

local function compare(value1, value2)
    return value1.qualityId < value2.qualityId
end

local function setScrollViewItem(_item, obj)
    local ItemName = ccui.Helper:seekNodeByName(_item, "text_name")
    local ItemImage = _item:getChildByName("image_card")
    local cardId = obj.cardId
    local name = DictCard[tostring(cardId)].name
    local smallImageId = DictCard[tostring(cardId)].smallUiId
    local image = "image/" .. DictUI[tostring(smallImageId)].fileName
    ItemName:setString(name)
    ItemImage:loadTexture(image)
    local borderImage = utils.getQualityImage(dp.Quality.card, obj.qualityId, dp.QualityImageType.small)
    _item:loadTexture(borderImage)
    utils.showThingsInfo(_item, StaticTableType.DictCard, cardId)
end

local function scrollviewUpdate()
    for key, obj in pairs(preViewThing) do
        local Item = listItem:clone()
        setScrollViewItem(Item, obj)
        scrollView:addChild(Item)
    end
end

local function selectedBtnChange(flag)
    local btn_recruit_silver = ccui.Helper:seekNodeByName(UIShopRecruitPreView.Widget, "btn_recruit_silver")
    local btn_recruit_jewel = ccui.Helper:seekNodeByName(UIShopRecruitPreView.Widget, "btn_recruit_jewel")
    btnSelected:loadTextureNormal("ui/yh_btn01.png")
    btnSelectedText:setTextColor(cc.c4b(255, 255, 255, 255))
    if flag == 1 then
        btnSelected = btn_recruit_silver
        btnSelectedText = btn_recruit_silver:getChildByName("text_recruit_silver")
        btn_recruit_silver:loadTextureNormal("ui/yh_btn02.png")
        btn_recruit_silver:getChildByName("text_recruit_silver"):setTextColor(cc.c4b(51, 25, 4, 255))
    elseif flag == 3 then
        btnSelected = btn_recruit_jewel
        btnSelectedText = btn_recruit_jewel:getChildByName("text_recruit_jewel")
        btn_recruit_jewel:loadTextureNormal("ui/yh_btn02.png")
        btn_recruit_jewel:getChildByName("text_recruit_jewel"):setTextColor(cc.c4b(51, 25, 4, 255))
    end
end

function UIShopRecruitPreView.init()
    local btn_close = ccui.Helper:seekNodeByName(UIShopRecruitPreView.Widget, "btn_close")
    local btn_recruit_silver = ccui.Helper:seekNodeByName(UIShopRecruitPreView.Widget, "btn_recruit_silver")
    local btn_recruit_jewel = ccui.Helper:seekNodeByName(UIShopRecruitPreView.Widget, "btn_recruit_jewel")
    btn_close:setPressedActionEnabled(true)
    btn_recruit_silver:setPressedActionEnabled(true)
    btn_recruit_jewel:setPressedActionEnabled(true)
    local function TouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_recruit_silver then
                if flag == 1 then
                    return;
                end
                flag = 1;
                UIShopRecruitPreView.setup()
            elseif sender == btn_recruit_jewel then
                if flag == 3 then
                    return;
                end
                flag = 3;
                UIShopRecruitPreView.setup()
            end
        end
    end
    btn_close:addTouchEventListener(TouchEvent)
    btn_recruit_silver:addTouchEventListener(TouchEvent)
    btn_recruit_jewel:addTouchEventListener(TouchEvent)
    scrollView = ccui.Helper:seekNodeByName(UIShopRecruitPreView.Widget, "view_list")
    listItem = scrollView:getChildByName("image_frame_card"):clone()
    if listItem:getReferenceCount() == 1 then
        listItem:retain()
    end
    start_x, start_y = scrollView:getChildByName("image_frame_card"):getPosition()
    btnSelected = btn_recruit_jewel
    btnSelectedText = btn_recruit_jewel:getChildByName("text_recruit_jewel")
end

function UIShopRecruitPreView.setup()
    selectedBtnChange(flag)
    scrollView:removeAllChildren()
    scrollView:jumpToTop()
    preViewThing = { }
    for key, obj in pairs(DictRecruitCard) do
        if flag == 1 and obj.recruitTypeId == StaticRecruit_Type.silverRecruit then
            table.insert(preViewThing, obj)
        elseif flag == 3 and obj.recruitTypeId == StaticRecruit_Type.diamondRecruit then
            table.insert(preViewThing, obj)
        end
    end
    utils.quickSort(preViewThing, compare)
    if next(preViewThing) then
        scrollviewUpdate()
        local innerHieght, space = 0, 40
        local childs = scrollView:getChildren()
        local line = 0

        if #childs % 4 ~= 0 then
            line = math.floor(#childs / 4) + 1
        else
            line = #childs / 4
        end
        innerHieght =(listItem:getContentSize().height + space) * line
        if innerHieght < scrollView:getContentSize().height then
            innerHieght = scrollView:getContentSize().height
        end
        scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, innerHieght))
        local preChild = nil
        local pos_x, pos_y = start_x, innerHieght - listItem:getContentSize().height / 2
        for j = 1, line do
            for k = 1, 4 do
                if (4 *(j - 1) + k) <= #childs then
                    childs[4 *(j - 1) + k]:setPosition(cc.p(pos_x, pos_y))
                    if k == 4 then
                        preChild = childs[4 *(j - 1) + k - 3]
                        pos_y = preChild:getBottomBoundary() - space - listItem:getContentSize().height / 2
                        pos_x = start_x
                    else
                        preChild = childs[4 *(j - 1) + k]
                        pos_x = preChild:getRightBoundary() + space + listItem:getContentSize().width / 2
                    end
                end
            end
        end
    end
end

function UIShopRecruitPreView.free()
    if not tolua.isnull(listItem) and listItem:getReferenceCount() >= 1 then
        listItem:release()
    end
    listItem = nil
    scrollView:removeAllChildren()
    WidgetManager.delete(UIShopRecruitPreView)
    if not UIShopRecruitPreView.Widget then
        scrollView = nil
        btnSelected = nil
        btnSelectedText = nil
        flag = 1
        preViewThing = { }
        start_x, start_y = nil, nil
    end
end