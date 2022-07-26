require"Lang"
UILineupEmbattleOld = {}

local FLAG_MAIN = 1 --主力标识位
local FLAG_BENCH = 2 --替补标识位
local POINTS = {{x=-205,y=199},{x=0,y=199},{x=205,y=199},{x=-205,y=27},{x=0,y=27},{x=205,y=27},{x=-205,y=-199},{x=0,y=-199},{x=205,y=-199}}

local uiPanel = nil
local uiCardItem = nil
local ui_mainFlag = nil
local ui_benchFlag = nil

local _curPositionList = nil
local _curTouchCard = nil

local _isRefreshLineup = nil
local _isRuning = false

local function netCallbackFunc(data)
	if data and _isRefreshLineup then
		UIManager.flushWidget(UILineup)
	end
	UIManager.popScene()
	_isRefreshLineup = nil
end

local function onTouchBegan(touch, event)
	if _isRuning then
		return false
	end
	_isRuning = true
	local touchPoint = uiPanel:convertTouchToNodeSpace(touch)
	local childs = uiPanel:getChildren()
	for key, obj in pairs(childs) do
		local objX, objY = obj:getPosition()
		if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
		touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
			_curTouchCard = obj
			_curTouchCard:setLocalZOrder(1)
			break
		end
	end
	return true
end

local function onTouchMoved(touch, event)
	local touchPoint = uiPanel:convertTouchToNodeSpace(touch)
	if _curTouchCard then
		_curTouchCard:setPosition(touchPoint)
	end
end

local function onTouchEnded(touch, event)
	local touchPoint = uiPanel:convertTouchToNodeSpace(touch)
	if _curTouchCard then
		local tempObj = nil
		local childs = uiPanel:getChildren()
		for key, obj in pairs(childs) do
			if obj ~= _curTouchCard then
				local objX, objY = obj:getPosition()
				if _curTouchCard:getPositionX() > objX - obj:getContentSize().width / 2 and _curTouchCard:getPositionX() < objX + obj:getContentSize().width / 2 and
				_curTouchCard:getPositionY() > objY - obj:getContentSize().height / 2 and _curTouchCard:getPositionY() < objY + obj:getContentSize().height / 2 then
					local tempTag = _curTouchCard:getTag()
					_curTouchCard:setTag(obj:getTag())
					obj:setTag(tempTag)
					tempObj = obj
					break
				end
			end
		end
		if tempObj then
			tempObj:setPosition(cc.p(POINTS[tempObj:getTag()].x + uiPanel:getContentSize().width / 2, POINTS[tempObj:getTag()].y + uiPanel:getContentSize().height / 2))
		else
			local itemSize = _curTouchCard:getContentSize()
			if _curTouchCard:getTag() <= 6 then
				for i = 1, 6 do
					if i ~= _curTouchCard:getTag() then
						local pX, pY = POINTS[i].x + uiPanel:getContentSize().width / 2, POINTS[i].y + uiPanel:getContentSize().height / 2
				 		if _curTouchCard:getPositionX() > pX - itemSize.width / 2 and _curTouchCard:getPositionX() < pX + itemSize.width / 2 and
				 		_curTouchCard:getPositionY() > pY - itemSize.height / 2 and _curTouchCard:getPositionY() < pY + itemSize.height / 2 then
				 			_curTouchCard:setTag(i)
				 			break
				 		end
					end
				end
			else
				for i = 7, #POINTS do
					if i ~= _curTouchCard:getTag() then
						local pX, pY = POINTS[i].x + uiPanel:getContentSize().width / 2, POINTS[i].y + uiPanel:getContentSize().height / 2
						if _curTouchCard:getPositionX() > pX - itemSize.width / 2 and _curTouchCard:getPositionX() < pX + itemSize.width / 2 and
				 		_curTouchCard:getPositionY() > pY - itemSize.height / 2 and _curTouchCard:getPositionY() < pY + itemSize.height / 2 then
				 			_curTouchCard:setTag(i)
				 			break
				 		end
					end
				end
			end
		end
		_curTouchCard:setPosition(cc.p(POINTS[_curTouchCard:getTag()].x + uiPanel:getContentSize().width / 2, POINTS[_curTouchCard:getTag()].y + uiPanel:getContentSize().height / 2))
		_curTouchCard:setLocalZOrder(0)
		_curTouchCard = nil
	end
	_isRuning = false
end

function UILineupEmbattleOld.init()
	local image_base_name_up = ccui.Helper:seekNodeByName(UILineupEmbattleOld.Widget, "image_base_name_up")
	ui_mainFlag = ccui.Helper:seekNodeByName(image_base_name_up, "text_hint")
	local image_base_name_bench = ccui.Helper:seekNodeByName(UILineupEmbattleOld.Widget, "image_base_name_bench")
	ui_benchFlag = ccui.Helper:seekNodeByName(image_base_name_bench, "text_hint")

	local btn_close = ccui.Helper:seekNodeByName(UILineupEmbattleOld.Widget, "btn_close")
	local btn_back = ccui.Helper:seekNodeByName(UILineupEmbattleOld.Widget, "btn_back")
	btn_close:setPressedActionEnabled(true)
	btn_back:setPressedActionEnabled(true)
	local function btnEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			local positionList = ""
			local childs = uiPanel:getChildren()
			local isIdentical = true
			for key, obj in pairs(childs) do
				local instCardId = obj:getChildByName("image_frame_card"):getTag()
				local type = FLAG_MAIN
				local position = obj:getTag()
				if position > 6 then
					position = position - 6
					type = FLAG_BENCH
				end
				positionList = positionList .. instCardId .. "_" .. type .."_" .. position .. "_" .. "0;"
				if _curPositionList[obj:getTag()] ~= instCardId .. "_" .. type .. "_" .. position .. "_" .. "0" then
					isIdentical = false
				end
			end
			positionList = string.sub(positionList, 1, string.len(positionList) - 1)
			if not isIdentical then
				cclog("---------->>>  " .. positionList)
				local sendData = {
					header = StaticMsgRule.convertPosition,
					msgdata = {
						string = {
							positionList = positionList
						}
					}
				}
				UIManager.showLoading()
				netSendPackage(sendData, netCallbackFunc)
			else
				netCallbackFunc()
			end
			
		end
	end
	btn_close:addTouchEventListener(btnEvent)
	btn_back:addTouchEventListener(btnEvent)
	
	uiPanel = ccui.Helper:seekNodeByName(UILineupEmbattleOld.Widget, "image_base_card_up")
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = uiPanel:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, uiPanel)
	
	uiCardItem = uiPanel:getChildByName("image_base_card"):clone()
	if uiCardItem:getReferenceCount() == 1 then
		uiCardItem:retain()
	end
end

function UILineupEmbattleOld.setup()
	uiPanel:removeAllChildren()
	
	local _teamCount, _benchCount = 0, 0
	local panelSize = uiPanel:getContentSize()
	if net.InstPlayerFormation then
		_curPositionList = {}
		for key, obj in pairs(net.InstPlayerFormation) do
			local instCardId = obj.int["3"] --卡牌实例ID
			local type = obj.int["4"] --1:主力,2:替补
            if type == 1 or type == 2 then
			    local position = obj.int["5"] --站位
			    local dictCardId = net.InstPlayerCard[tostring(instCardId)].int["3"] --卡牌字典ID
			    local instCardData = net.InstPlayerCard[tostring(instCardId)] --卡牌实例数据
			    local dictCardData = DictCard[tostring(dictCardId)] --卡牌字典数据
			    local cardItem = uiCardItem:clone()
			    local cardName = ccui.Helper:seekNodeByName(cardItem, "text_name")
			    local cardFrame = cardItem:getChildByName("image_frame_card")
			    local cardIcon = cardFrame:getChildByName("image_card")
			    cardFrame:setTag(instCardId)
			    cardName:setString(dictCardData.name)
			    cardFrame:loadTexture(utils.getQualityImage(dp.Quality.card, instCardData.int["4"], dp.QualityImageType.middle))
			    cardIcon:loadTexture("image/" .. DictUI[tostring(dictCardData.bigUiId)].fileName)
			    local _cruPosition = instCardId .. "_" .. type .. "_" .. position .. "_" .. "0"
			    if type == FLAG_BENCH then
				    position = position + 6
				    _benchCount = _benchCount + 1
			    else
				    _teamCount = _teamCount + 1
			    end
			    cardItem:setPosition(cc.p(POINTS[position].x + panelSize.width / 2, POINTS[position].y + panelSize.height / 2))
			    uiPanel:addChild(cardItem, 0, position)
			    _curPositionList[position] = _cruPosition
            end
		end
		ui_mainFlag:setString(string.format(Lang.ui_lineup_embattle_old1, _teamCount))
		ui_benchFlag:setString(string.format(Lang.ui_lineup_embattle_old2, _benchCount))
	end
end

function UILineupEmbattleOld.free()
	_isRuning = false
	if uiCardItem and uiCardItem:getReferenceCount() >= 1 then
		uiCardItem:release()
		uiCardItem = nil
	end
	uiPanel:removeAllChildren()
end

function UILineupEmbattleOld.setUIParam(param)
	_isRefreshLineup = param
end
