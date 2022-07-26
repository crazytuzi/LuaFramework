require"Lang"
UIAllianceRanking = {}

local MAX_APPLY_COUNT = 3 -- 最大申请个数
local PAGE_ITEM_SIZE = 10 -- 每页显示的个数
local MAX_ITEM_SIZE = 5000000 -- 最大显示条数
local SCROLLVIEW_ITEM_SPACE = 0

local ui_scrollView = nil
local ui_svItem = nil

local _allianceData = nil

local netCallbackFunc = nil

local function cleanScrollView()
    if ui_svItem and ui_svItem:getReferenceCount() == 1 then
        ui_svItem:retain()
    end
    if ui_scrollView then
        ui_scrollView:removeAllChildren()
    end
end

local function layoutScrollView(_innerHeight)
    if _innerHeight < ui_scrollView:getContentSize().height then
        _innerHeight = ui_scrollView:getContentSize().height
    end
    ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, _innerHeight))
    local childs = ui_scrollView:getChildren()
    local prevChild = nil
    for i = 1, #childs do
        if i == 1 then
            childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        else
            childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        end
        prevChild = childs[i]
    end
end

local function getAllianceData(_page)
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.unionRank, msgdata = { int = { pageNum = _page, instUnionMemberId = net.InstUnionMember.int["1"] } } }, netCallbackFunc)
end

local function setScrollViewItem(_item, _data)
    if _data then
--        local ui_rankImg = _item:getChildByName("image_rank")
--        local ui_rankLabel = ui_rankImg:getChildByName("text_rank")
        local ui_allianceIcon = _item:getChildByName("image_title")
        local ui_allianceName = _item:getChildByName("text_alliance_name")
        local ui_allianceLevel = _item:getChildByName("text_alliance_lv")
        local ui_allianceMainName = ccui.Helper:seekNodeByName(_item, "text_name")
        local ui_allianceMemberNum = ccui.Helper:seekNodeByName(_item, "text_member")
        local ui_allianceBuild = ccui.Helper:seekNodeByName(_item, "text_build")
        local ui_allianceOffer = ccui.Helper:seekNodeByName(_item, "text_notice")
        ui_allianceName:setString(_data.string["2"])
        ui_allianceLevel:setString("LV " .. _data.int["4"])
        ui_allianceMainName:setString(Lang.ui_alliance_ranking1 .. _data.string["15"])
        ui_allianceMemberNum:setString(string.format(Lang.ui_alliance_ranking2, _data.int["7"], _data.int["6"]))
        ui_allianceBuild:setString(Lang.ui_alliance_ranking3 .. _data.int["3"])
        ui_allianceOffer:setString(_data.string["11"])
        if _data.int["17"] <= 0 then
            ui_allianceIcon:loadTexture("image/" .. DictUI[tostring(DictUnionFlag["1"].bigUiId)].fileName)
        else
            ui_allianceIcon:loadTexture("image/" .. DictUI[tostring(DictUnionFlag[tostring(_data.int["17"])].bigUiId)].fileName)
        end
--        local _rank = _data.int["16"]
--        local _image = _rank <= 3 and string.format("ui/lm%d.png", _rank) or "ui/lm_number.png"
--        ui_rankImg:loadTexture(_image)
--        if _rank <= 3 then
--            ui_rankLabel:setVisible(false)
--        else
--            ui_rankLabel:setVisible(true)
--        end
--        ui_rankLabel:setString(tostring(_rank))
    else
        _item:setTouchEnabled(true)
        _item:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                getAllianceData(math.floor(#_allianceData / PAGE_ITEM_SIZE) + 1)
            end
        end )
    end
end

local function addMoreItemToScrollView()
    local scrollViewItem = ccui.ImageView:create("ui/btn_l.png")
    --    scrollViewItem:setContentSize(ui_svItem:getContentSize())
    local moreLabel = ccui.Text:create()
    moreLabel:setString(Lang.ui_alliance_ranking4)
    moreLabel:setFontName(dp.FONT)
    moreLabel:setFontSize(25)
    moreLabel:setPosition(cc.p(scrollViewItem:getContentSize().width / 2, scrollViewItem:getContentSize().height / 2))
    scrollViewItem:addChild(moreLabel)
    scrollViewItem:setTag(-100)
    setScrollViewItem(scrollViewItem)
    ui_scrollView:addChild(scrollViewItem)
    return scrollViewItem:getContentSize().height
end

netCallbackFunc = function(_msgData)
    local code = tonumber(_msgData.header)
    if code == StaticMsgRule.unionRank then
        local unionRank = _msgData.msgdata.message.unionRank
        if unionRank and unionRank.message then
            local _moreItemHeight = 0
            local childs = ui_scrollView:getChildren()
            if childs and #childs > 0 and childs[#childs]:getTag() < 0 then
                _moreItemHeight = childs[#childs]:getContentSize().height
                childs[#childs]:removeFromParent()
                childs[#childs] = nil
            end
            local _isResetInnerHieght = false
            local _index = math.floor(#_allianceData / PAGE_ITEM_SIZE) * 10 + 1

            local innerHieght = ui_scrollView:getInnerContainerSize().height
            if innerHieght == ui_scrollView:getContentSize().height then
                innerHieght = SCROLLVIEW_ITEM_SPACE
                _isResetInnerHieght = true
            end
            local _tempLists = { }
            if unionRank and unionRank.message then
                for key, obj in pairs(unionRank.message) do
                    _tempLists[#_tempLists + 1] = obj
                end

                -- @前八名无序排列
--                local _randomSize = (#_tempLists > 8) and 8 or #_tempLists
--                local _randoms = utils.randoms(1, _randomSize, _randomSize)
--                for key, obj in pairs(_tempLists) do
--                    if _tempLists[key].int["16"] < 8 and _randoms[key] then
--                        _tempLists[key].int["16"] = _randoms[key]
--                    end
--                end
--                _randoms = nil

                -- @排行列表排序规则
                utils.quickSort(_tempLists, function(obj1, obj2) if obj1.int["16"] > obj2.int["16"] then return true end end)
            end
            for key, obj in pairs(_tempLists) do
                if _allianceData[_index] then
                    local childs = ui_scrollView:getChildren()
                    if childs and childs[_index] then
                        setScrollViewItem(childs[_index], obj)
                        if _isResetInnerHieght then
                            innerHieght = innerHieght + childs[_index]:getContentSize().height + SCROLLVIEW_ITEM_SPACE
                        end
                    end
                    _allianceData[_index] = nil
                else
                    local scrollViewItem = ui_svItem:clone()
                    setScrollViewItem(scrollViewItem, obj)
                    ui_scrollView:addChild(scrollViewItem)
                    innerHieght = innerHieght + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
                end
                _allianceData[_index] = obj
                _index = _index + 1
            end
            _tempLists = nil
            
            if #_allianceData >= MAX_ITEM_SIZE then
                innerHieght = innerHieght - _moreItemHeight - SCROLLVIEW_ITEM_SPACE
            else
                if _isResetInnerHieght then
                    innerHieght = innerHieght + addMoreItemToScrollView() + SCROLLVIEW_ITEM_SPACE
                else
                    addMoreItemToScrollView()
                end
            end
            
            if _allianceData then
                -- @排行列表排序规则
                utils.quickSort(_allianceData, function(obj1, obj2) if obj1.int["16"] > obj2.int["16"] then return true end end)
            end
            layoutScrollView(innerHieght)
        else
            UIManager.showToast(Lang.ui_alliance_ranking5)
        end
    end
end

function UIAllianceRanking.init()
    local image_basemap = UIAllianceRanking.Widget:getChildByName("image_basemap")
    local btn_back = image_basemap:getChildByName("btn_back")
    local image_di_dowm = image_basemap:getChildByName("image_di_dowm")
    local btn_search = ccui.Helper:seekNodeByName(image_di_dowm, "btn_search")
    btn_back:setPressedActionEnabled(true)
    btn_search:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                UIAlliance.show()
            elseif sender == btn_search then
                UIManager.showToast(Lang.ui_alliance_ranking6)
            end
        end
    end
    btn_back:addTouchEventListener(onButtonEvent)
    btn_search:addTouchEventListener(onButtonEvent)

    ui_scrollView = image_basemap:getChildByName("view_alliance")
    ui_svItem = ui_scrollView:getChildByName("image_di_alliance"):clone()
end

function UIAllianceRanking.setup()
    _allianceData = { }
    cleanScrollView()
    getAllianceData(1)
    local innerHieght = 0
    if _allianceData then
        for key, obj in pairs(_allianceData) do
            local scrollViewItem = ui_svItem:clone()
            setScrollViewItem(scrollViewItem, obj)
            ui_scrollView:addChild(scrollViewItem)
            innerHieght = innerHieght + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
        end
        innerHieght = innerHieght + addMoreItemToScrollView() + SCROLLVIEW_ITEM_SPACE
    end
    innerHieght = innerHieght + SCROLLVIEW_ITEM_SPACE
    layoutScrollView(innerHieght)
    ActionManager.ScrollView_SplashAction(ui_scrollView)
end

function UIAllianceRanking.show()
    UIManager.showWidget("ui_alliance_ranking")
end

function UIAllianceRanking.free()
    cleanScrollView()
    _allianceData = nil
end
