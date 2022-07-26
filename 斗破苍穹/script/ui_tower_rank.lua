require"Lang"
UITowerRank = {}

local TabBtn_FLAG_HURT = 1
local TabBtn_FLAG_AWARD = 2

local userData = nil
local ui_scrollView = nil
local ui_svHurtItem = nil
local ui_svAwardItem = nil

local function cleanScrollView(_isRelease)
    if _isRelease then
        if ui_svHurtItem and ui_svHurtItem:getReferenceCount() >= 1 then
            ui_svHurtItem:release()
            ui_svHurtItem = nil
        end
        if ui_svAwardItem and ui_svAwardItem:getReferenceCount() >= 1 then
            ui_svAwardItem:release()
            ui_svAwardItem = nil
        end
        if ui_scrollView then
            ui_scrollView:removeAllChildren()
            ui_scrollView = nil
        end
    else
        if ui_svHurtItem:getReferenceCount() == 1 then
            ui_svHurtItem:retain()
        end
        if ui_svAwardItem:getReferenceCount() == 1 then
            ui_svAwardItem:retain()
        end
        ui_scrollView:removeAllChildren()
    end
end

local function layoutScrollView(_listData, _initItemFunc, _flag)
    local SCROLLVIEW_ITEM_SPACE = 10
	cleanScrollView()
	ui_scrollView:jumpToTop()
	local _innerHeight = 0
    if not _listData then _listData = {} end
	for key, obj in pairs(_listData) do
		local scrollViewItem = (_flag == TabBtn_FLAG_AWARD) and ui_svAwardItem:clone() or ui_svHurtItem:clone()
		_initItemFunc(scrollViewItem, obj, key, _flag)
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

local function setScrollViewItem(_item, _data, _index, _tabBtnFlag)
    if _tabBtnFlag == TabBtn_FLAG_HURT then
        local _itemData = utils.stringSplit(_data, "|")
        local ui_rank = _item:getChildByName("label_ranking")
        local image_base_name = _item:getChildByName("image_base_name")
        local ui_name = ccui.Helper:seekNodeByName(image_base_name, "text_player_name")
        local ui_level = ccui.Helper:seekNodeByName(image_base_name, "label_lv")
        local ui_allianceName = ccui.Helper:seekNodeByName(image_base_name, "text_team_name")
        local ui_totalHurt = _item:getChildByName("text_hurt_number")
        local btn_lineup = _item:getChildByName("btn_lineup")
        btn_lineup:setPressedActionEnabled(true)
        ui_rank:setString(_itemData[2])
        ui_level:setString(_itemData[3])
        ui_name:setString(_itemData[4])
        if _itemData[5] ~= "" then
            ui_allianceName:setString("(" .. _itemData[5] .. ")")
        else
            ui_allianceName:setString("")
        end
        ui_totalHurt:setString(Lang.ui_tower_rank1 .. _itemData[6])
        btn_lineup:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.enemyPlayerInfo, msgdata = { int = { playerId = tonumber(_itemData[1]) } } }, function(_msgData)
                    pvp.loadGameData(_msgData)
                    UIManager.pushScene("ui_arena_check")
                end)
            end
        end)
    elseif _tabBtnFlag == TabBtn_FLAG_AWARD then
        local _itemData = utils.stringSplit(_data, "|")
        local ui_titleLabel = _item:getChildByName("image_base_ranking"):getChildByName("text_ranking")
        local ui_label = _item:getChildByName("text_name")
        local ui_thingItem = {
            {
                frame = _item:getChildByName("image_frame_money"),
                icon = _item:getChildByName("image_frame_money"):getChildByName("image_money"),
                label = _item:getChildByName("image_frame_money"):getChildByName("text_money"),
            },
            {
                frame = _item:getChildByName("image_frame_weiwang"),
                icon = _item:getChildByName("image_frame_weiwang"):getChildByName("image_weiwang"),
                label = _item:getChildByName("image_frame_weiwang"):getChildByName("text_weiwang"),
            }
        }
        local _things
        if _index == 1 and #_itemData == 2 then
            ui_titleLabel:setString(Lang.ui_tower_rank2)
            ui_label:setString(_itemData[1])
            _things = utils.stringSplit(_itemData[2], ";")
        else
            ui_titleLabel:setString(Lang.ui_tower_rank3)
            if tonumber(_itemData[1]) == tonumber(_itemData[2]) then
                ui_label:setString(string.format(Lang.ui_tower_rank4, tonumber(_itemData[2])))
            else
                ui_label:setString(string.format(Lang.ui_tower_rank5, tonumber(_itemData[1]), tonumber(_itemData[2])))
            end
            _things = utils.stringSplit(_itemData[3], ";")
        end
        ui_label:enableOutline(cc.c4b(0, 0, 0, 255), 2)
        for key, obj in pairs(ui_thingItem) do
            if _things and _things[key] then
                local itemProps = utils.getItemProp(_things[key])
                if itemProps then
                    if itemProps.frameIcon then
                        obj.frame:loadTexture(itemProps.frameIcon)
                    end
                    if itemProps.smallIcon then
                        obj.icon:loadTexture(itemProps.smallIcon)
                        utils.showThingsInfo(obj.icon, itemProps.tableTypeId, itemProps.tableFieldId)
                    end
                    if itemProps.name then
                        obj.label:setString(itemProps.name .. "×" .. itemProps.count)
                    end
                end
            else
                obj.frame:setVisible(false)
            end
        end
    end
end

function UITowerRank.init()
    local image_basemap = UITowerRank.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    local btn_sure = image_basemap:getChildByName("btn_sure")
    btn_close:setPressedActionEnabled(true)
    btn_sure:setPressedActionEnabled(true)
    local onButtonEvent = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close or sender == btn_sure then
                UIManager.popScene()
            end
        end
    end
    btn_close:addTouchEventListener(onButtonEvent)
    btn_sure:addTouchEventListener(onButtonEvent)

    ui_scrollView = image_basemap:getChildByName("view_ranking")
    ui_svHurtItem = ui_scrollView:getChildByName("image_base_player"):clone()
    ui_svAwardItem = ui_scrollView:getChildByName("image_ranking"):clone()
end

function UITowerRank.setup()
    local image_basemap = UITowerRank.Widget:getChildByName("image_basemap")
    local tabBtnHurt = image_basemap:getChildByName("btn_level")
    local tabBtnAward = image_basemap:getChildByName("btn_rank")
    local function onBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if _prevTabBtn == sender then
				return
			end
			_prevTabBtn = sender

            tabBtnHurt:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            tabBtnHurt:setTitleColor(cc.c4b(255, 255, 255, 255))
            tabBtnAward:loadTextures("ui/yh_btn01.png", "ui/yh_btn02.png")
            tabBtnAward:setTitleColor(cc.c4b(255, 255, 255, 255))
            
            sender:loadTextures("ui/yh_btn02.png", "ui/yh_btn02.png")
            sender:setTitleColor(cc.c4b(51, 25, 4, 255))
            local _dataFlag, _tempData
            if sender == tabBtnHurt then
                _dataFlag = TabBtn_FLAG_HURT
                _tempData = userData.hurtList
            elseif sender == tabBtnAward then
                _dataFlag = TabBtn_FLAG_AWARD
                _tempData = userData.awardList
            end
            layoutScrollView(_tempData, setScrollViewItem, _dataFlag)
        end
    end
    tabBtnHurt:addTouchEventListener(onBtnEvent)
    tabBtnAward:addTouchEventListener(onBtnEvent)
    tabBtnHurt:releaseUpEvent()
end

function UITowerRank.free()
    cleanScrollView(true)
    userData = nil
end

function UITowerRank.show()
    UIManager.showLoading()
	netSendPackage({header=StaticMsgRule.lookTianGuanHurtRank, msgdata={}}, function(_msgData) 
        userData = {
            --玩家实例ID|名次|玩家等级|玩家名称|玩家联盟名称|总伤害值;...
            hurtList = utils.stringSplit(_msgData.msgdata.string.hurtRank, ";"),

            --守卫名称|物品信息/上限名次|下限名次|物品信息/...
            awardList = utils.stringSplit(_msgData.msgdata.string.rewardRank, "/")
        }
        UIManager.pushScene("ui_tower_rank")
    end)
end
