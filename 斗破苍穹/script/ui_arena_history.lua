require"Lang"
UIArenaHistory = {
	selfItem = nil,
	enemyItem = nil
}

local _isClose = false
local _upPosY, _downPosY, _arrowPosY = 0, 0, 0

function UIArenaHistory.init()
	UIArenaHistory.Widget:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended and _isClose then
			UIManager.popScene()
		end
	end)
end

function UIArenaHistory.setup()
	ccui.Helper:seekNodeByName(UIArenaHistory.Widget, "text_up"):setVisible(false)
	ccui.Helper:seekNodeByName(UIArenaHistory.Widget, "text_get"):setVisible(false)
	local image_up = ccui.Helper:seekNodeByName(UIArenaHistory.Widget, "image_up")
	local image_down = ccui.Helper:seekNodeByName(UIArenaHistory.Widget, "image_down")
	if _upPosY == 0 then
		_upPosY = image_up:getPositionY()
	end
	if _downPosY == 0 then
		_downPosY = image_down:getPositionY()
	end
	image_up:setPositionY(_downPosY)
	image_down:setPositionY(_upPosY)
	local arrow_up = image_up:getChildByName("arrow_up")
	if _arrowPosY == 0 then
		_arrowPosY = arrow_up:getPositionY()
	end
	arrow_up:setPositionY(_arrowPosY)
	arrow_up:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, 30)), cc.MoveBy:create(0.5, cc.p(0, -30)) )))
	UIArenaHistory.selfItem:setPosition(image_up:getContentSize().width / 2, image_up:getContentSize().height / 2)
	UIArenaHistory.enemyItem:setPosition(image_down:getContentSize().width / 2, image_down:getContentSize().height / 2)
	image_up:addChild(UIArenaHistory.selfItem)
	image_down:addChild(UIArenaHistory.enemyItem)
	UIArenaHistory.enemyItem:setEnabled(false)
	ccui.Helper:seekNodeByName(UIArenaHistory.selfItem, "text_countdown"):setVisible(false)
	ccui.Helper:seekNodeByName(UIArenaHistory.enemyItem, "btn_challenge"):setVisible(false)
    ccui.Helper:seekNodeByName(UIArenaHistory.enemyItem, "btn_ten"):setVisible(false)
    ccui.Helper:seekNodeByName(UIArenaHistory.selfItem, "btn_ten"):setVisible(false)
end

function UIArenaHistory.onEnter()
	local selfRankAction, enemyRankAction
	local image_up = ccui.Helper:seekNodeByName(UIArenaHistory.Widget, "image_up")
	local image_down = ccui.Helper:seekNodeByName(UIArenaHistory.Widget, "image_down")
	image_up:setLocalZOrder(1)
	local _imgUpScale = image_up:getScale()
	image_up:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.Spawn:create(cc.MoveTo:create(0.4, cc.p(image_up:getPositionX(), _upPosY)), cc.Sequence:create(cc.ScaleTo:create(0.35, _imgUpScale + 0.1), cc.ScaleTo:create(0.05, _imgUpScale)) ), cc.CallFunc:create(function()
		selfRankAction()
	end)))
	image_down:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.MoveTo:create(0.4, cc.p(image_down:getPositionX(), _downPosY)), cc.CallFunc:create(function()
		enemyRankAction()
	end)))

	local selfRank = ccui.Helper:seekNodeByName(UIArenaHistory.selfItem, "label_ranking")
	local enemyRank = ccui.Helper:seekNodeByName(UIArenaHistory.enemyItem, "label_ranking")
	local _curEnemyRank = tonumber(selfRank:getString())
	local _curSelfRank = tonumber(enemyRank:getString())
	local _tempAdd = 100
	if _curEnemyRank - _curSelfRank >= 2000 then
		_tempAdd = 30
	elseif _curEnemyRank - _curSelfRank >= 1100 then
		_tempAdd = 20
	elseif _curEnemyRank - _curSelfRank >= 950 then
		_tempAdd = 18
	elseif _curEnemyRank - _curSelfRank >= 800 then
		_tempAdd = 16
	elseif _curEnemyRank - _curSelfRank >= 650 then
		_tempAdd = 14
	elseif _curEnemyRank - _curSelfRank >= 500 then
		_tempAdd = 12
	elseif _curEnemyRank - _curSelfRank >= 350 then
		_tempAdd = 10
	elseif _curEnemyRank - _curSelfRank >= 200 then
		_tempAdd = 8
	elseif _curEnemyRank - _curSelfRank >= 100 then
		_tempAdd = 5
	elseif _curEnemyRank - _curSelfRank >= 50 then
		_tempAdd = 3
	else
		_tempAdd = 1
	end

	selfRankAction = function()
		selfRank:setString(tonumber(selfRank:getString()) - _tempAdd)
		selfRank:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function()
				if tonumber(selfRank:getString()) > _curSelfRank then
					selfRankAction()
				else
					selfRank:setString(_curSelfRank)
					local _scale = selfRank:getScale()
					selfRank:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, _scale + 0.15), cc.ScaleTo:create(0.3, _scale),
					 cc.CallFunc:create(function()
						local text_up = ccui.Helper:seekNodeByName(UIArenaHistory.Widget, "text_up")
						text_up:setScale(2)
						text_up:setVisible(true)
						text_up:runAction(cc.ScaleTo:create(0.1, 1))
					end), cc.DelayTime:create(0.5), cc.CallFunc:create(function()
						local text_get = ccui.Helper:seekNodeByName(UIArenaHistory.Widget, "text_get")
						text_get:setScale(2)
						text_get:setVisible(true)
						text_get:runAction(cc.ScaleTo:create(0.1, 1))
						_isClose = true
					end)))
				end
			end)))
	end
	enemyRankAction = function()
		enemyRank:setString(tonumber(enemyRank:getString()) + _tempAdd)
		enemyRank:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function()
				if tonumber(enemyRank:getString()) < _curEnemyRank then
					enemyRankAction()
				else
					enemyRank:setString(_curEnemyRank)
				end
			end)))
	end
end

function UIArenaHistory.refreshUILabel(_rank, _weiwang)
	if UIArenaHistory.Widget then
		ccui.Helper:seekNodeByName(UIArenaHistory.Widget, "text_up"):setString(string.format(Lang.ui_arena_history1, _rank))
		ccui.Helper:seekNodeByName(UIArenaHistory.Widget, "text_get"):setString(string.format(Lang.ui_arena_history2, _weiwang))
	end
end

function UIArenaHistory.free()
	if not tolua.isnull(UIArenaHistory.selfItem) then
		UIArenaHistory.selfItem:removeFromParent()
		-- UIArenaHistory.selfItem:release()
		-- UIArenaHistory.selfItem = nil
	end
	if not tolua.isnull(UIArenaHistory.enemyItem) then
		UIArenaHistory.enemyItem:removeFromParent()
		UIArenaHistory.enemyItem:release()
		UIArenaHistory.enemyItem = nil
	end
	local image_up = ccui.Helper:seekNodeByName(UIArenaHistory.Widget, "image_up")
	local image_down = ccui.Helper:seekNodeByName(UIArenaHistory.Widget, "image_down")
	local arrow_up = image_up:getChildByName("arrow_up")
	arrow_up:stopAllActions()
	arrow_up:setPositionY(_arrowPosY)
	_isClose = false
end
