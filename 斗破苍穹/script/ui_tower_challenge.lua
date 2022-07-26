UITowerChallenge = {}

local scrollView = nil
local sv_item = nil

local _dictPagodaStoreyId = nil
local _victoryValue = nil

local function netCallbackFunc(data)
	local thingId =	data.msgdata.string["2"] --dictId;dictId;dictId

	UITowerWin.setParam({_dictPagodaStoreyId, _victoryValue, thingId}) --[1]:塔层字典ID, [2]:通关条件值
	UIManager.pushScene("ui_tower_win")
end

local function setScrollViewItem(item, data)
	local itemIcon = item:getChildByName("image_good")
	local itemName = ccui.Helper:seekNodeByName(itemIcon,"text_name")
	
	local name, icon = utils.getDropThing(data.tableTypeId, data.tableFieldId)
	itemName:setString(name)
	itemIcon:loadTexture(icon)
	utils.addBorderImage(data.tableTypeId,data.tableFieldId,item)
end

function UITowerChallenge.init()
	local btn_challenge = ccui.Helper:seekNodeByName(UITowerChallenge.Widget, "btn_challenge")
	local btn_close = ccui.Helper:seekNodeByName(UITowerChallenge.Widget, "btn_close")
	btn_challenge:setPressedActionEnabled(true)
	btn_close:setPressedActionEnabled(true)
	local function btnTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			if sender == btn_challenge then
				local function callBackFunc(param)
					_victoryValue = param
					if _dictPagodaStoreyId then
						local _value = param
						if Fight.isWin() then
							_value = "1_" .. param
						else
							_value = "0_" .. param
						end
						local sendData = {
							header = StaticMsgRule.war,
							msgdata = {
								int = {
									instPlayerPagodaId = net.InstPlayerPagoda.int["1"],
									pagodaStoreyId = _dictPagodaStoreyId,
									type = 1, --0-普通层   1-神秘层
								},
								string = {
									victoryValue = _value, --胜利失败(1:胜利,0:失败)_胜利值
									coredata = GlobalLastFightCheckData
								}
							}
						}
						UIManager.showLoading()
						netSendPackage(sendData, netCallbackFunc)
					end
				end
				utils.sendFightData(_dictPagodaStoreyId,dp.FightType.FIGHT_PAGODA,callBackFunc)
				UIFightMain.loading()
			elseif sender == btn_close then
				UIManager.popScene()
			end
		end
	end
	btn_challenge:addTouchEventListener(btnTouchEvent)
	btn_close:addTouchEventListener(btnTouchEvent)
	
	scrollView = ccui.Helper:seekNodeByName(UITowerChallenge.Widget, "view_good")
	sv_item = scrollView:getChildByName("image_frame_good"):clone()
	if sv_item:getReferenceCount() == 1 then
		sv_item:retain()
	end
end

function UITowerChallenge.setup()
	scrollView:removeAllChildren()
	
	local innerWidth, space = 0, 40
	
	if _dictPagodaStoreyId then
		local storeyData = {}
		for key, obj in pairs(DictPagodaDrop) do
			if _dictPagodaStoreyId == obj.pagodaStoreyId then
				storeyData[#storeyData + 1] = obj
			end
		end
		local function compareFunc(obj1, obj2)
			if obj1.id > obj2.id then
				return true
			else
				return false
			end
		end
		utils.quickSort(storeyData, compareFunc)
		local count = 0
		for key, obj in pairs(storeyData) do
			count = count + 1
			if count > 5 then
				break
			else
				local scrollViewItem = sv_item:clone()
				innerWidth = innerWidth + scrollViewItem:getContentSize().width + space
				scrollView:addChild(scrollViewItem)
				setScrollViewItem(scrollViewItem, obj)
			end
		end
		innerWidth = innerWidth + space
	end
	
	if innerWidth < scrollView:getContentSize().width then
		innerWidth = scrollView:getContentSize().width
	end
	scrollView:setInnerContainerSize(cc.size(innerWidth, scrollView:getContentSize().height))
	local childs = scrollView:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		if i == 1 then
			childs[i]:setPosition(cc.p(childs[i]:getContentSize().width / 2 + space, childs[i]:getPositionY()))
		else
			childs[i]:setPosition(cc.p(prevChild:getRightBoundary() + childs[i]:getContentSize().width / 2 + space, childs[i]:getPositionY()))
		end
		prevChild = childs[i]
	end
end

function UITowerChallenge.setPagodaStoreyId(pagodaStoreyId)
	local _dictId = DictPagodaStorey[tostring(pagodaStoreyId)].pagodaFormationId
	_dictPagodaStoreyId = DictPagodaFormation[tostring(_dictId)].pagodaStorey6
end

function UITowerChallenge.free()
	if sv_item and sv_item:getReferenceCount() >= 1 then
		sv_item:release()
		sv_item = nil
	end
	scrollView:removeAllChildren()
end