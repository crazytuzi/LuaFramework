require"Lang"
UIBossRanking = {}

local ui_scrollView = nil
local ui_svItem = nil

local _data = nil

local function netCallbackFunc(data)
	pvp.loadGameData(data)
	UIManager.pushScene("ui_arena_check")
end

local function cleanScrollView()
	ui_scrollView:removeAllChildren()
end

local function setScrollViewData(item, data)
	local ui_ranking = item:getChildByName("label_ranking")
	local ui_hurtNum = item:getChildByName("text_hurt_number")
	local ui_playerName = ccui.Helper:seekNodeByName(item, "text_player_name")
	local ui_playerLevel = ccui.Helper:seekNodeByName(item, "label_lv")
    local ui_playerTeamName = ccui.Helper:seekNodeByName(item, "text_team_name")
	local ui_lineup = item:getChildByName("btn_lineup")
	
	ui_ranking:setString(tostring(data.int["1"]))
	ui_playerName:setString(data.string["3"])
	ui_playerLevel:setString(tostring(data.int["4"]))
	ui_hurtNum:setString(Lang.ui_boss_ranking1 .. data.int["5"])
    ui_playerTeamName:setString(data.string["6"] and data.string["6"] or "")
	ui_lineup:setPressedActionEnabled(true)
	ui_lineup:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			UIManager.showLoading()
			netSendPackage({header = StaticMsgRule.enemyPlayerInfo, msgdata = {int={playerId=data.int["2"]}}}, netCallbackFunc)
		end
	end)
end

function UIBossRanking.init()
	local btn_close = ccui.Helper:seekNodeByName(UIBossRanking.Widget, "btn_close")
	local btn_sure = ccui.Helper:seekNodeByName(UIBossRanking.Widget, "btn_sure")
	btn_close:setPressedActionEnabled(true)
	btn_sure:setPressedActionEnabled(true)
	local function onTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			if sender == btn_close or sender == btn_sure then
				UIManager.popScene()
			end
		end
	end
	btn_close:addTouchEventListener(onTouchEvent)
	btn_sure:addTouchEventListener(onTouchEvent)
	
	ui_scrollView = ccui.Helper:seekNodeByName(UIBossRanking.Widget, "view_ranking")
	ui_svItem = ui_scrollView:getChildByName("image_base_player")
end

function UIBossRanking.setup()
	cleanScrollView()
	
	local innerHieght, space = 0, 10
	if _data then
		for key, obj in pairs(_data) do
			if obj.int["1"] > 0 then
				local scrollViewItem = ui_svItem:clone()
				setScrollViewData(scrollViewItem, obj)
				ui_scrollView:addChild(scrollViewItem)
				innerHieght = innerHieght + scrollViewItem:getContentSize().height + space
			end
		end
	end
	
	innerHieght = innerHieght + space
	if innerHieght < ui_scrollView:getContentSize().height then
		innerHieght = ui_scrollView:getContentSize().height
	end
	ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, innerHieght))
	local childs = ui_scrollView:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		if i == 1 then
			childs[i]:setPosition(cc.p(ui_scrollView:getContentSize().width / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - space))
		else
			childs[i]:setPosition(cc.p(ui_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - space))
		end
		prevChild = childs[i]
	end
end

function UIBossRanking.setData(data)
	_data = data
end

function UIBossRanking.free()
	cleanScrollView()
end
