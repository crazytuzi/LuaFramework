require"Lang"
UITeam = {}

local ui_pageView = nil
local ui_pageViewItem = nil

local image_base_di_enargy = nil
local image_base_di_stamina = nil

local _energyCountdownId = nil
local _vigorCountdownId = nil
local _energyCurTime = 0
local _vigorCurTime = 0
local _isEnergyNeteding = false
local _isVigorNeteding = false

local function netCallbackFunc(data)
	local code = tonumber(data.header)
	if code == StaticMsgRule.giveName then
		local image_basecolour = ccui.Helper:seekNodeByName(UITeam.Widget, "image_basecolour")
		ccui.Helper:seekNodeByName(image_basecolour, "text_name"):setString(net.InstPlayer.string["3"])
	elseif code == StaticMsgRule.energyRecover then --体力恢复
		_energyCurTime = math.ceil(data.msgdata.message.energy.int["1"] / 1000)
		if _energyCurTime == 0 then
			_isEnergyNeteding = true
			if image_base_di_enargy then
			ccui.Helper:seekNodeByName(image_base_di_enargy, "text_recover_time"):setString(string.format("%02d:%02d:%02d", 0, 0, 0))
			ccui.Helper:seekNodeByName(image_base_di_enargy, "text_recover_time_all"):setString(string.format("%02d:%02d:%02d", 0, 0, 0))
			end
		else
			_isEnergyNeteding = false
		end
		if image_base_di_enargy then
			local playerEnergy = net.InstPlayer.int["8"]
			local playerMaxEnergy = net.InstPlayer.int["9"]
			local ui_enargyBar = ccui.Helper:seekNodeByName(image_base_di_enargy, "bar_enargy")
			if ui_enargyBar then
				ui_enargyBar:setPercent(utils.getPercent(playerEnergy, playerMaxEnergy))
				ui_enargyBar:getChildByName("text_enargy"):setString(playerEnergy .. "/" .. playerMaxEnergy)
				ui_enargyBar:getChildByName("text_enargy_up"):setString(playerEnergy .. "/" .. playerMaxEnergy)
			end
		end
	elseif code == StaticMsgRule.vigorRecover then --耐力恢复
		_vigorCurTime = math.ceil(data.msgdata.message.vigor.int["1"] / 1000)
		if _vigorCurTime == 0 then
			_isVigorNeteding = true
			if image_base_di_stamina then
			ccui.Helper:seekNodeByName(image_base_di_stamina, "text_recover_time"):setString(string.format("%02d:%02d:%02d", 0, 0, 0))
			ccui.Helper:seekNodeByName(image_base_di_stamina, "text_recover_time_all"):setString(string.format("%02d:%02d:%02d", 0, 0, 0))
			end
		else
			_isVigorNeteding = false
		end
		if image_base_di_stamina then
			local playerVigor = net.InstPlayer.int["10"]
			local playerMaxVigor = net.InstPlayer.int["11"]
			local ui_vigorBar = ccui.Helper:seekNodeByName(image_base_di_stamina, "bar_enargy")
			if ui_vigorBar then
				ui_vigorBar:setPercent(utils.getPercent(playerVigor, playerMaxVigor))
				ui_vigorBar:getChildByName("text_enargy"):setString(playerVigor .. "/" .. playerMaxVigor)
				ui_vigorBar:getChildByName("text_enargy_up"):setString(playerVigor .. "/" .. playerMaxVigor)
			end
		end
	end
	UIManager.flushWidget(UITeamInfo)
end

---返回 时：分：秒 
local function getTime(_secsNums)
	local hour = math.floor(_secsNums / 3600 % 24) --小时
	local minute = math.floor(_secsNums / 60 % 60) --分
	local second = math.floor(_secsNums % 60) --秒
	return {hour, minute, second}
end

local function energyCountdown(dt)
	if _energyCurTime == 0 and _isEnergyNeteding then
		return
	end

	_energyCurTime = _energyCurTime - 1
	if _energyCurTime <= 0 then
		_energyCurTime = 0
		-- if _energyCountdownId then
		-- 	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_energyCountdownId)
		-- end
		-- _energyCountdownId = nil
		if not _isEnergyNeteding then
			_isEnergyNeteding = true
			netSendPackage({header = StaticMsgRule.energyRecover, msgdata = {}}, netCallbackFunc)
		end
	end
	local _totalTimes = 0
	local playerEnergy = net.InstPlayer.int["8"]
	local playerMaxEnergy = net.InstPlayer.int["9"]
	if playerMaxEnergy - playerEnergy <= 0 then
		_energyCurTime = 0
		_isEnergyNeteding = true
		-- if _energyCountdownId then
		-- 	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_energyCountdownId)
		-- 	_energyCountdownId = nil
		-- end
	else
		_totalTimes = (playerMaxEnergy - playerEnergy) * DictSysConfig[tostring(StaticSysConfig.howLongRecoverEngery)].value * 60 - (DictSysConfig[tostring(StaticSysConfig.howLongRecoverEngery)].value * 60 - _energyCurTime)
	end
	local _time = getTime(_energyCurTime)
	if image_base_di_enargy then
		local text_recover_time = ccui.Helper:seekNodeByName(image_base_di_enargy, "text_recover_time")
		if text_recover_time then
			text_recover_time:setString(string.format("%02d:%02d:%02d", _time[1], _time[2], _time[3]))
		end
		_time = getTime(_totalTimes)
		local text_recover_time_all = ccui.Helper:seekNodeByName(image_base_di_enargy, "text_recover_time_all")
		if text_recover_time_all then
			text_recover_time_all:setString(string.format("%02d:%02d:%02d", _time[1], _time[2], _time[3]))
		end
	end
end

local function vigorCountdown(dt)
	if _vigorCurTime == 0 and _isVigorNeteding then
		return
	end

	_vigorCurTime = _vigorCurTime - 1
	if _vigorCurTime <= 0 then
		_vigorCurTime = 0
		-- if _vigorCountdownId then
		-- 	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_vigorCountdownId)
		-- end
		-- _vigorCountdownId = nil
		if not _isVigorNeteding then
			_isVigorNeteding = true
			netSendPackage({header = StaticMsgRule.vigorRecover, msgdata = {}}, netCallbackFunc)
		end
	end
	local _totalTimes = 0
	local playerVigor = net.InstPlayer.int["10"]
	local playerMaxVigor = net.InstPlayer.int["11"]
	if playerMaxVigor - playerVigor <= 0 then
		_vigorCurTime = 0
		_isVigorNeteding = true
		-- if _vigorCountdownId then
		-- 	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_vigorCountdownId)
		-- 	_vigorCountdownId = nil
		-- end
	else
		_totalTimes = (playerMaxVigor - playerVigor) * DictSysConfig[tostring(StaticSysConfig.howLongRecoverVigor)].value * 60 - (DictSysConfig[tostring(StaticSysConfig.howLongRecoverVigor)].value * 60 - _vigorCurTime)
	end
	local _time = getTime(_vigorCurTime)
	if image_base_di_stamina then
		local text_recover_time = ccui.Helper:seekNodeByName(image_base_di_stamina, "text_recover_time")
		if text_recover_time then
			text_recover_time:setString(string.format("%02d:%02d:%02d", _time[1], _time[2], _time[3]))
		end
		_time = getTime(_totalTimes)
		local text_recover_time_all = ccui.Helper:seekNodeByName(image_base_di_stamina, "text_recover_time_all")
		if text_recover_time_all then
			text_recover_time_all:setString(string.format("%02d:%02d:%02d", _time[1], _time[2], _time[3]))
		end
	end
end

--@_energyTimes : 体力
--@_vigorTimes : 耐力
function UITeam.initRecoverState(_energyTimes, _vigorTimes)
	if _energyTimes > 0 then
		if _energyCountdownId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_energyCountdownId)
			_energyCountdownId = nil
		end
		_energyCurTime = math.ceil(_energyTimes / 1000)
		_energyCountdownId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(energyCountdown, 1, false)
	end
	if _vigorTimes > 0 then
		if _vigorCountdownId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_vigorCountdownId)
			_vigorCountdownId = nil
		end
		_vigorCurTime = math.ceil(_vigorTimes / 1000)
		_vigorCountdownId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(vigorCountdown, 1, false)
	end
end

function UITeam.checkRecoverState()
	local playerEnergy = net.InstPlayer.int["8"]
	local playerMaxEnergy = net.InstPlayer.int["9"]
	if playerMaxEnergy - playerEnergy > 0 then
		if not _energyCountdownId then
			local t = DictSysConfig[tostring(StaticSysConfig.howLongRecoverEngery)].value * 60 * 1000
			UITeam.initRecoverState(t, 0)
		elseif _energyCurTime == 0 and _isEnergyNeteding then
			_isEnergyNeteding = false
			_energyCurTime = DictSysConfig[tostring(StaticSysConfig.howLongRecoverEngery)].value * 60
		end
	end
	local playerVigor = net.InstPlayer.int["10"]
	local playerMaxVigor = net.InstPlayer.int["11"]
	if playerMaxVigor - playerVigor > 0 then
		if not _vigorCountdownId then
			local t = DictSysConfig[tostring(StaticSysConfig.howLongRecoverVigor)].value * 60 * 1000
			UITeam.initRecoverState(0, t)
		elseif _vigorCurTime == 0 and _isVigorNeteding then
			_isVigorNeteding = false
			_vigorCurTime = DictSysConfig[tostring(StaticSysConfig.howLongRecoverVigor)].value * 60
		end
	end
end

function UITeam.stopRecoverState()
	if _energyCountdownId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_energyCountdownId)
		_energyCountdownId = nil
	end
	_energyCurTime = 0
	_isEnergyNeteding = false
	if _vigorCountdownId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_vigorCountdownId)
		_vigorCountdownId = nil
	end
	_vigorCurTime = 0
	_isVigorNeteding = false
end

local function showDialog(_callbackFunc)
	local dialog = ccui.Layout:create()
	dialog:setContentSize(UIManager.screenSize)
	dialog:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	dialog:setBackGroundColor(cc.c3b(0, 0, 0))
	dialog:setBackGroundColorOpacity(130)
	dialog:setTouchEnabled(true)
	dialog:retain()
	local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
	bg_image:setAnchorPoint(cc.p(0.5, 0.5))
	bg_image:setPreferredSize(cc.size(480, 360))
	bg_image:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
	dialog:addChild(bg_image)
	local bgSize = bg_image:getPreferredSize()
	  
	local title = ccui.Text:create()
	title:setString(Lang.ui_team1)
	title:setFontName(dp.FONT)
	title:setFontSize(30)
	title:setTextColor(cc.c4b(255, 255, 0, 255))
	title:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.83))
	bg_image:addChild(title)
	
	local editBox = cc.EditBox:create(cc.size(bgSize.width * 0.85, 55), cc.Scale9Sprite:create("image/dl_1.png"))
  editBox:setFontColor(cc.c3b(255, 0, 0))
  editBox:setPlaceHolder(Lang.ui_team2)
  editBox:setMaxLength(8)
  editBox:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.55))
  bg_image:addChild(editBox)
  editBox:setText(net.InstPlayer.string["3"])
	  
	local sureBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
	sureBtn:setTitleText(Lang.ui_team3)
	sureBtn:setTitleFontName(dp.FONT)
	sureBtn:setTitleFontSize(25)
	sureBtn:setPressedActionEnabled(true)
	sureBtn:setTouchEnabled(true)
	sureBtn:setPosition(cc.p(bgSize.width / 4, bgSize.height * 0.2))
	bg_image:addChild(sureBtn)
	local cancelBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
	cancelBtn:setTitleFontName(dp.FONT)
	cancelBtn:setTitleText(Lang.ui_team4)
	cancelBtn:setTitleFontSize(25)
	cancelBtn:setPressedActionEnabled(true)
	cancelBtn:setTouchEnabled(true)
	cancelBtn:setPosition(cc.p(bgSize.width / 4 * 3, bgSize.height * 0.2))
	bg_image:addChild(cancelBtn)
	local function btnEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == sureBtn then
				if string.len(editBox:getText()) > 0 then
					-- if string.utf8len(editBox:getText()) > 8 then
					-- 	UIManager.showToast("名字不能超过8个字符！")
					-- 	return
					-- end
					UIManager.uiLayer:removeChild(dialog, true)
					cc.release(dialog)
					if _callbackFunc and editBox:getText() ~= net.InstPlayer.string["3"] then
						_callbackFunc(editBox:getText())
					end
				else
					UIManager.showToast(Lang.ui_team5)
				end
			elseif sender == cancelBtn then
				UIManager.uiLayer:removeChild(dialog, true)
				cc.release(dialog)
			end
		end
	end
	sureBtn:addTouchEventListener(btnEvent)
	cancelBtn:addTouchEventListener(btnEvent)
	bg_image:setScale(0.1)
	UIManager.uiLayer:addChild(dialog, 10000)
	bg_image:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, 1)))
end

function UITeam.init()
 
	local image_basecolour = ccui.Helper:seekNodeByName(UITeam.Widget, "image_basecolour")
	ui_pageView = image_basecolour:getChildByName("view_card")
	ui_pageViewItem = ui_pageView:getChildByName("panel_card"):clone()
	if ui_pageViewItem:getReferenceCount() == 1 then
		ui_pageViewItem:retain()
	end

	local btn_close = ccui.Helper:seekNodeByName(UITeam.Widget, "btn_close")
	local btn_sure = ccui.Helper:seekNodeByName(UITeam.Widget, "btn_sure")
	local btn_change = image_basecolour:getChildByName("btn_change")
	local btn_arrow_l = image_basecolour:getChildByName("btn_arrow_l")
	local btn_arrow_r = image_basecolour:getChildByName("btn_arrow_r")
	btn_close:setPressedActionEnabled(true)
	btn_sure:setPressedActionEnabled(true)
	btn_change:setPressedActionEnabled(true)
	btn_arrow_l:setPressedActionEnabled(true)
	btn_arrow_r:setPressedActionEnabled(true)
	local function onButtonEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			if sender == btn_close or sender == btn_sure then
				UIManager.popScene()
				local _cardId = ui_pageView:getPage(ui_pageView:getCurPageIndex()):getTag()
				if _cardId ~= net.InstPlayer.int["32"] then
					local sendData = {
						header = StaticMsgRule.selectHeader,
						msgdata = {
							int = {
								cardId = _cardId --卡牌字典表Id
							}
						}
					}
					UIManager.showLoading()
					netSendPackage(sendData, netCallbackFunc)
				end
			elseif sender == btn_change then
				showDialog(function(param)
					local sendData = {
						header = StaticMsgRule.giveName,
						msgdata = {
							string = {
								name = param
							}
						}
					}
					UIManager.showLoading()
					netSendPackage(sendData, netCallbackFunc)
				end)
			elseif sender == btn_arrow_l then
				local index = ui_pageView:getCurPageIndex() - 1
				if index < 0 then
					index = 0
				end
				ui_pageView:scrollToPage(index)
			elseif sender == btn_arrow_r then
				local index = ui_pageView:getCurPageIndex() + 1
				if index > #ui_pageView:getPages() then
					index = #ui_pageView:getPages()
				end
				ui_pageView:scrollToPage(index)
			end
		end
	end
	btn_close:addTouchEventListener(onButtonEvent)
	btn_sure:addTouchEventListener(onButtonEvent)
    btn_change:setVisible( false )
	--btn_change:addTouchEventListener(onButtonEvent)
	btn_arrow_l:addTouchEventListener(onButtonEvent)
	btn_arrow_r:addTouchEventListener(onButtonEvent)

	image_base_di_enargy = ccui.Helper:seekNodeByName(UITeam.Widget, "image_base_di_enargy")
	image_base_di_stamina = ccui.Helper:seekNodeByName(UITeam.Widget, "image_base_di_stamina")
end

function UITeam.setup()
	ui_pageView:removeAllPages()
	ui_pageView:removeAllChildren()
    local role = dp.getUserData()
    local roleUid = dp.getAccountId()
    math.randomseed(tonumber(role.serverId) * 100000)
    cclog("accountId--------------"..roleUid)
    local uid =tostring(role.serverId)..roleUid..math.random(10000)

	local playerName = net.InstPlayer.string["3"]
	local playerLv = net.InstPlayer.int["4"]
	local playerGold = net.InstPlayer.int["5"]
	local playerCopper = net.InstPlayer.string["6"]
	local playerExp = net.InstPlayer.int["7"]
	local playerEnergy = net.InstPlayer.int["8"]
	local playerMaxEnergy = net.InstPlayer.int["9"]
	local playerVigor = net.InstPlayer.int["10"]
	local playerMaxVigor = net.InstPlayer.int["11"]
	local playerVipLv = net.InstPlayer.int["19"]
	local playerSoulSource = utils.getThingCount(StaticThing.soulSource)
	local playerHeaderId = net.InstPlayer.int["32"]
	local playerMaxExp = 0
	if DictLevelProp[tostring(playerLv)] then
		playerMaxExp = DictLevelProp[tostring(playerLv)].fleetExp
	end

	local _curPageIndex = 0
	local formation1, formation2 = {}, {}
	for key, obj in pairs(net.InstPlayerFormation) do
		if obj.int["4"] == 1 then	--主力
			formation1[#formation1 + 1] = obj
		elseif obj.int["4"] == 2 then --替补
			formation2[#formation2 + 1] = obj
		end
	end
	local function compareFunc(obj1, obj2)
		if obj1.int["1"] > obj2.int["1"] then
			return true
		end
		return false
	end
	utils.quickSort(formation1, compareFunc)
	utils.quickSort(formation2, compareFunc)
	for i = 1, (#formation1 + #formation2) do
		local obj = nil
		if formation1[i] then
			obj = formation1[i]
		elseif formation2[i - #formation1] then
			obj = formation2[i - #formation1]
		end
		if obj then
			local dictCardId = obj.int["6"] --卡牌字典ID
			local dictCardData = DictCard[tostring(dictCardId)] --卡牌字典数据
			local pageViewItem = ui_pageViewItem:clone()
            local instCardData = net.InstPlayerCard[tostring(obj.int["3"])]
            local isAwake = instCardData.int["18"]
			pageViewItem:setTag(dictCardId)
            pageViewItem:getChildByName("image_card"):loadTexture("image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId)].fileName)

			ui_pageView:addPage(pageViewItem)
			if playerHeaderId == dictCardId then
				_curPageIndex = i - 1
			end
		end
	end

	local image_basecolour = ccui.Helper:seekNodeByName(UITeam.Widget, "image_basecolour")
	ccui.Helper:seekNodeByName(image_basecolour, "label_vip_number"):setString(tostring(playerVipLv))
	ccui.Helper:seekNodeByName(image_basecolour, "text_name"):setString(playerName)
	ccui.Helper:seekNodeByName(image_basecolour, "label_lv"):setString(tostring(playerLv))
    ccui.Helper:seekNodeByName(image_basecolour, "text_uid"):setString("Uid:"..uid)

	local image_base_di = ccui.Helper:seekNodeByName(UITeam.Widget, "image_base_di")
	local ui_expBar = ccui.Helper:seekNodeByName(image_base_di, "bar_enargy")
	ui_expBar:setPercent(utils.getPercent(playerExp, playerMaxExp))
	ui_expBar:getChildByName("text_enargy"):setString(playerExp .. "/" .. playerMaxExp)
	ui_expBar:getChildByName("text_enargy_up"):setString(playerExp .. "/" .. playerMaxExp)
	ccui.Helper:seekNodeByName(image_base_di, "label_fighting_number"):setString(tostring(utils.getFightValue())) --战力（*）
	local image_info_di = image_base_di:getChildByName("image_info_di")
	ccui.Helper:seekNodeByName(image_info_di, "text_hunyuan"):setString(tostring(playerSoulSource))
	ccui.Helper:seekNodeByName(image_info_di, "text_gold"):setString(tostring(playerGold))
	ccui.Helper:seekNodeByName(image_info_di, "text_slive"):setString(tostring(playerCopper))

	local ui_enargyBar = ccui.Helper:seekNodeByName(image_base_di_enargy, "bar_enargy")
	ui_enargyBar:setPercent(utils.getPercent(playerEnergy, playerMaxEnergy))
	ui_enargyBar:getChildByName("text_enargy"):setString(playerEnergy .. "/" .. playerMaxEnergy)
	ui_enargyBar:getChildByName("text_enargy_up"):setString(playerEnergy .. "/" .. playerMaxEnergy)

	local ui_vigorBar = ccui.Helper:seekNodeByName(image_base_di_stamina, "bar_enargy")
	ui_vigorBar:setPercent(utils.getPercent(playerVigor, playerMaxVigor))
	ui_vigorBar:getChildByName("text_enargy"):setString(playerVigor .. "/" .. playerMaxVigor)
	ui_vigorBar:getChildByName("text_enargy_up"):setString(playerVigor .. "/" .. playerMaxVigor)

	ui_pageView:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
		ui_pageView:scrollToPage(_curPageIndex)
	end)))
end

function UITeam.free()
	if ui_pageViewItem and ui_pageViewItem:getReferenceCount() >= 1 then
		ui_pageViewItem:release()
		ui_pageViewItem = nil
	end
	ui_pageView:removeAllPages()
	ui_pageView:removeAllChildren()
end

function UITeam.updateTimer(interval)
	if _energyCurTime then
		_energyCurTime = _energyCurTime - interval
		if _energyCurTime < 0 then
			_energyCurTime = 1
		end
	end
	if _vigorCurTime then
		_vigorCurTime = _vigorCurTime - interval
		if _vigorCurTime < 0 then
			_vigorCurTime = 1
		end
	end
end
