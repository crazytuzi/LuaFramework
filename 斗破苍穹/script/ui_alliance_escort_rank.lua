require"Lang"
UIAllianceEscortRank = {}

local setScrollViewItem

local userData = nil
local ui_scrollView = nil
local ui_svItem = nil
local ui_svAllianceItem = nil

local _dataType = 1 --1-夺镖 2-偷窃 3-防守 4-联盟

local function cleanScrollView(_isRelease)
    if _isRelease then
        if ui_svItem and ui_svItem:getReferenceCount() >= 1 then
            ui_svItem:release()
            ui_svItem = nil
        end
        if ui_svAllianceItem and ui_svAllianceItem:getReferenceCount() >= 1 then
            ui_svAllianceItem:release()
            ui_svAllianceItem = nil
        end
        if ui_scrollView then
            ui_scrollView:removeAllChildren()
            ui_scrollView = nil
        end
    else
        if ui_svItem:getReferenceCount() == 1 then
            ui_svItem:retain()
        end
        if ui_svAllianceItem:getReferenceCount() == 1 then
            ui_svAllianceItem:retain()
        end
        ui_scrollView:removeAllChildren()
    end
end

local function layoutScrollView(_listData, _initItemFunc)
    local SCROLLVIEW_ITEM_SPACE = 10
	cleanScrollView()
	ui_scrollView:jumpToTop()
	local _innerHeight = 0
    if not _listData then _listData = {} end
	for key, obj in pairs(_listData) do
		local scrollViewItem = nil
        if _dataType == 4 then
            scrollViewItem = ui_svAllianceItem:clone()
        else
            scrollViewItem = ui_svItem:clone()
        end
		_initItemFunc(scrollViewItem, obj, key)
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
			childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
		else
			childs[i]:setPosition(ui_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
		end
		prevChild = childs[i]
	end
	ActionManager.ScrollView_SplashAction(ui_scrollView)
end

setScrollViewItem = function(_item, _data, _index)
    if _data == nil then    
        return
    end
    if _dataType == 4 then
        --格式：排名|联盟旗帜|联盟名|联盟等级|盟主名字|当前建设度|剩余金条数/
        local _itemData = utils.stringSplit(_data, "|")
        local allianceFrame = _item:getChildByName("image_frame_alliance")
        local ui_allianceIcon = allianceFrame:getChildByName("image_alliance")
        local ui_allianceName = allianceFrame:getChildByName("text_alliance")
        local ui_allianceLv = allianceFrame:getChildByName("text_lv")
        local ui_alliancePlayerName = allianceFrame:getChildByName("text_name")
        local ui_allianceBulid = allianceFrame:getChildByName("text_bulid")
        local ui_allianceGold = allianceFrame:getChildByName("text_gold")
        local ui_rank = allianceFrame:getChildByName("text_ranking")

        ui_rank:setString(_itemData[1])
        ui_allianceIcon:loadTexture("image/" .. DictUI[tostring(DictUnionFlag[_itemData[2]].smallUiId)].fileName)
        ui_allianceName:setString(_itemData[3])
        ui_allianceLv:setString("LV " .. _itemData[4])
        ui_alliancePlayerName:setString(Lang.ui_alliance_escort_rank1 .. _itemData[5])
        ui_allianceBulid:setString(Lang.ui_alliance_escort_rank2 .. _itemData[6])
        ui_allianceGold:setString(Lang.ui_alliance_escort_rank3 .. _itemData[7])
    else
        --格式：奖励字典Id|玩家头像Id|联盟名字|积分|宝箱物品|玩家名字|玩家实例ID/
        local _itemData = utils.stringSplit(_data, "|")
        local playerFrame = _item:getChildByName("image_frame_player")
        local ui_playerIcon = playerFrame:getChildByName("image_player")
        local ui_playerName = playerFrame:getChildByName("text_name")
        local ui_allianceName = playerFrame:getChildByName("text_alliance")
        local ui_escortLv = playerFrame:getChildByName("text_lv")
        local ui_rank = playerFrame:getChildByName("text_ranking")
        local ui_box = playerFrame:getChildByName("image_box")

        ui_rank:setString(tostring(_index))
        ui_playerIcon:loadTexture("image/" .. DictUI[tostring(DictCard[_itemData[2]].smallUiId)].fileName)
        ui_playerName:setString(Lang.ui_alliance_escort_rank4 .. _itemData[6])
        ui_allianceName:setString(Lang.ui_alliance_escort_rank5 .. _itemData[3])
        ui_escortLv:setString(Lang.ui_alliance_escort_rank6 .. _itemData[4])
        ui_box:setTouchEnabled(true)
        ui_box:loadTexture("ui/fb_bx02.png")
        ui_box:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                UIAwardGet.setOperateType(UIAwardGet.operateType.dailyTaskBox, {
                    btnTitleText = "",
                    enabled = true,
                    things = _itemData[5]
                }, UIAllianceEscortRank)
                UIManager.pushScene("ui_award_get")
            end
        end)
    end
end

function UIAllianceEscortRank.init()
    local image_basemap = UIAllianceEscortRank.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    btn_close:setPressedActionEnabled(true)
    btn_close:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
        end
    end)
    ui_scrollView = image_basemap:getChildByName("view_info")
    ui_svItem = ui_scrollView:getChildByName("image_di_ranking"):clone()
    ui_svAllianceItem = ui_scrollView:getChildByName("image_di_alliance"):clone()
    image_basemap:getChildByName("text_info"):setString(Lang.ui_alliance_escort_rank7)
end

function UIAllianceEscortRank.setup()
    local _prevTabBtn = nil
    local image_basemap = UIAllianceEscortRank.Widget:getChildByName("image_basemap")
    local tabBtnGrab = image_basemap:getChildByName("btn_grab")
    local tabBtnSteal = image_basemap:getChildByName("btn_steal")
    local tabBtnDefend = image_basemap:getChildByName("btn_defend")
    local tabBtnAlliance = image_basemap:getChildByName("btn_alliance")
    local function onBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if _prevTabBtn == sender then
				return
			end
			_prevTabBtn = sender

            tabBtnGrab:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            tabBtnGrab:getChildByName("text_grab"):setTextColor(cc.c4b(255, 255, 255, 255))
            tabBtnSteal:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            tabBtnSteal:getChildByName("text_steal"):setTextColor(cc.c4b(255, 255, 255, 255))
            tabBtnDefend:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            tabBtnDefend:getChildByName("text_defend"):setTextColor(cc.c4b(255, 255, 255, 255))
            tabBtnAlliance:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            tabBtnAlliance:getChildByName("text_alliance"):setTextColor(cc.c4b(255, 255, 255, 255))

            local ui_tabBtnTitleText = nil
            sender:loadTextures("ui/yh_btn02.png", "ui/yh_btn02.png")
            if sender == tabBtnGrab then
                ui_tabBtnTitleText = sender:getChildByName("text_grab")
                _dataType = 1
            elseif sender == tabBtnSteal then
                ui_tabBtnTitleText = sender:getChildByName("text_steal")
                _dataType = 2
            elseif sender == tabBtnDefend then
                ui_tabBtnTitleText = sender:getChildByName("text_defend")
                _dataType = 3
            elseif sender == tabBtnAlliance then
                ui_tabBtnTitleText = sender:getChildByName("text_alliance")
                _dataType = 4
            end
            if ui_tabBtnTitleText then
                ui_tabBtnTitleText:setTextColor(cc.c4b(51, 25, 4, 255))
            end
            layoutScrollView({}, setScrollViewItem)
            UIManager.showLoading()
            netSendPackage( {
                header = StaticMsgRule.intoUnionLootScoreRank, msgdata = { int = { type = _dataType }}
            } , function(_msgData)
                --格式：奖励字典Id|玩家头像Id|联盟名字|积分|宝箱物品|玩家名字|玩家实例ID/
                local _messageStr = _msgData.msgdata.string["1"]
                layoutScrollView(utils.stringSplit(_messageStr, "/"), setScrollViewItem)
                local ui_textDesc = ""
                local _endTextDesc = ""
                if _dataType < 4 then
                    local _tempData = utils.stringSplit(_msgData.msgdata.string["2"], "|") --积分|排名
                    ui_textDesc = string.format(Lang.ui_alliance_escort_rank8, ui_tabBtnTitleText and ui_tabBtnTitleText:getString() or "", _tempData[1], _tempData[2])
                    if _dataType == 1 or _dataType == 2 then
                        _endTextDesc = string.format(Lang.ui_alliance_escort_rank9, ui_tabBtnTitleText and ui_tabBtnTitleText:getString() or "")
                    end
                end
                image_basemap:getChildByName("text_info"):setString(ui_textDesc .. Lang.ui_alliance_escort_rank10 .. _endTextDesc)
            end )
        end
    end
    tabBtnGrab:addTouchEventListener(onBtnEvent)
    tabBtnSteal:addTouchEventListener(onBtnEvent)
    tabBtnDefend:addTouchEventListener(onBtnEvent)
    tabBtnAlliance:addTouchEventListener(onBtnEvent)
    tabBtnGrab:releaseUpEvent()
end

function UIAllianceEscortRank.free()
    cleanScrollView(true)
    userData = nil
end

function UIAllianceEscortRank.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_alliance_escort_rank")
end
