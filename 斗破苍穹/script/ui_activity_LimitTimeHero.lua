require"Lang"
UIAactivityLimitTimeHero = {}

local ui_svItemRank = nil
local ui_svItemIntegral = nil
local _countdownTime = 0
local _recruitCountdown = 0
local DictActivity = nil
local _recruitNum = nil
local _curIntegral = 0
local _curIntegralRank = 0

local netCallbackFunc = nil

local function countDowun()
    _countdownTime = _countdownTime - 1
    if _countdownTime < 0 then
        _countdownTime = 0
    end
    _recruitCountdown = _recruitCountdown - 1
    if _recruitCountdown < 0 then
        _recruitCountdown = 0
    end
    if UIAactivityLimitTimeHero.Widget then
        local day = math.floor(_countdownTime / 3600 / 24) --天
	    local hour = math.floor(_countdownTime / 3600 % 24) --小时
	    local minute = math.floor(_countdownTime / 60 % 60) --分
	    local second = math.floor(_countdownTime % 60) --秒
        local image_basemap = UIAactivityLimitTimeHero.Widget:getChildByName("image_basemap")
        local ui_countdownText = image_basemap:getChildByName("text_countdown")
        ui_countdownText:setString(string.format(Lang.ui_activity_LimitTimeHero1, day, hour, minute, second))

        local _hour = math.floor(_recruitCountdown / 3600 % 24) --小时
	    local _minute = math.floor(_recruitCountdown / 60 % 60) --分
	    local _second = math.floor(_recruitCountdown % 60) --秒
        local onePanel = image_basemap:getChildByName("image_one")
        onePanel:getChildByName("text_time"):setString(string.format(Lang.ui_activity_LimitTimeHero2, _hour, _minute, _second))
    end
end

local function layoutScrollView(ui_scrollView, ui_svItem, _listData, _initItemFunc, _space)
	if ui_svItem:getReferenceCount() == 1 then
  	    ui_svItem:retain()
    end
    ui_scrollView:removeAllChildren()
	ui_scrollView:jumpToTop()
	local _innerHeight, SCROLLVIEW_ITEM_SPACE = 0, _space
	for key, obj in pairs(_listData) do
		local scrollViewItem = ui_svItem:clone()
		_initItemFunc(scrollViewItem, obj)
		ui_scrollView:addChild(scrollViewItem)
		_innerHeight = _innerHeight + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
	end
	_innerHeight = _innerHeight - SCROLLVIEW_ITEM_SPACE
	if _innerHeight < ui_scrollView:getContentSize().height then
		_innerHeight = ui_scrollView:getContentSize().height
	end
	ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, _innerHeight))
	local childs = ui_scrollView:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		if i == 1 then
			childs[i]:setPosition((ui_scrollView:getContentSize().width - childs[i]:getContentSize().width) / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height)
		else
			childs[i]:setPosition((ui_scrollView:getContentSize().width - childs[i]:getContentSize().width) / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height - SCROLLVIEW_ITEM_SPACE)
		end
		prevChild = childs[i]
	end
end

--排名奖励
local function initRankReward(_rankListData)
    
    utils.quickSort(_rankListData, function(obj1, obj2) if obj1.startRankNum > obj2.startRankNum then return true end end)
    local image_basemap = UIAactivityLimitTimeHero.Widget:getChildByName("image_basemap")
    local image_di_system = image_basemap:getChildByName("image_di_system")
    local image_rank_di = image_di_system:getChildByName("image_rank_di")
    local ui_scrollView = image_rank_di:getChildByName("view_reward")
--    local ui_svItem = ui_scrollView:getChildByName("panel"):clone()
    if not ui_svItemRank then
        ui_svItemRank = ui_scrollView:getChildByName("panel"):clone()
    end
    layoutScrollView(ui_scrollView, ui_svItemRank, _rankListData, function(_item, _data)
        if _data.startRankNum == _data.endRankNum then
            _item:getChildByName("text_rank"):setString(string.format(Lang.ui_activity_LimitTimeHero3, _data.startRankNum))
        else
            _item:getChildByName("text_rank"):setString(string.format(Lang.ui_activity_LimitTimeHero4, _data.startRankNum, _data.endRankNum))
        end
        local _thingsData = utils.stringSplit(_data.rewards, ";")
        for i = 1, 4 do
            local _thingItem = _item:getChildByName("image_frame_good" .. i)
            if _thingsData[i] then
                local itemProps = utils.getItemProp(_thingsData[i])
                if itemProps.smallIcon then
                    _thingItem:getChildByName("image_good"):loadTexture(itemProps.smallIcon)
                    utils.showThingsInfo(_thingItem:getChildByName("image_good"), itemProps.tableTypeId, itemProps.tableFieldId)
                    utils.addThingParticle(_thingsData[i],_thingItem:getChildByName("image_good"),true)
                end
                _thingItem:getChildByName("text_number"):setString("×" .. itemProps.count)
                _thingItem:setVisible(true)
            else
                _thingItem:setVisible(false)
            end
        end
    end, 10)
end

--积分排行
local function initIntegralRank(_msgData)
    local _listData = {}
    local _tempData = utils.stringSplit(_msgData.msgdata.string["1"], "/")
    for key, obj in pairs(_tempData) do
        local _obj = utils.stringSplit(obj, "|")
        _listData[#_listData + 1] = {
            orderId = tonumber(_obj[1]),
            playerName = _obj[2],
            integral = tonumber(_obj[3])
        }
    end
    local image_basemap = UIAactivityLimitTimeHero.Widget:getChildByName("image_basemap")
    local image_di_system = image_basemap:getChildByName("image_di_system")
    local image_integral_di = image_di_system:getChildByName("image_integral_di")
    local ui_scrollViewIntegral = image_integral_di:getChildByName("view_people")
--    local ui_svItemIntegral = ui_scrollViewIntegral:getChildByName("panel_people"):clone()
    if not ui_svItemIntegral then
        ui_svItemIntegral = ui_scrollViewIntegral:getChildByName("panel_people"):clone()
    end
    layoutScrollView(ui_scrollViewIntegral, ui_svItemIntegral, _listData, function(_item, _data)
        _item:setTag(_data.orderId)
        _item:getChildByName("text_name1"):setString(_data.orderId..".".._data.playerName)
        _item:getChildByName("text_integral1"):setString(tostring(_data.integral))
    end, 0)

    local function setScrollViewFocus(isJumpTo)
	    local childs = ui_scrollViewIntegral:getChildren()
	    for key, obj in pairs(childs) do
		    if _curIntegralRank == obj:getTag() then
			    local contaniner = ui_scrollViewIntegral:getInnerContainer()
			    local h = (contaniner:getContentSize().height - ui_scrollViewIntegral:getContentSize().height)
			    local dt
			    if h == 0 then
				    dt = 0
			    else
                    dt = (contaniner:getContentSize().height - (obj:getPositionY() + obj:getContentSize().height)) / contaniner:getContentSize().height
				    if dt < 0 then
					    dt = 0
				    end
			    end
			    if isJumpTo then
                    ui_scrollViewIntegral:jumpToPercentVertical(dt * 100)
			    else
				    ui_scrollViewIntegral:scrollToPercentVertical(dt * 100, 0.5, true)
			    end
		    end
	    end
    end
    setScrollViewFocus()
end

--初始化招募信息
local function initRecruitInfo(_msgData)
    local _tempData = utils.stringSplit(_msgData.msgdata.string["4"], "|")
    local _time, _onePrice, _tenPrice = tonumber(_tempData[1]), tonumber(_tempData[2]), tonumber(_tempData[3])
    _recruitNum = tonumber(_tempData[4])
    local image_basemap = UIAactivityLimitTimeHero.Widget:getChildByName("image_basemap")
    local onePanel = image_basemap:getChildByName("image_one")
    local btn_one = onePanel:getChildByName("btn_one")
    btn_one:setPressedActionEnabled(true)
    if _time == 0 then
        btn_one:getChildByName("text_one"):setString(Lang.ui_activity_LimitTimeHero5)
        onePanel:getChildByName("text_free"):setVisible(true)
        onePanel:getChildByName("text_time"):setVisible(false)
        onePanel:getChildByName("image_jin"):setVisible(false)
    else
        _recruitCountdown = math.floor(_time / 1000)
        btn_one:getChildByName("text_one"):setString(Lang.ui_activity_LimitTimeHero6)
        onePanel:getChildByName("image_jin"):setVisible(true)
        onePanel:getChildByName("text_time"):setVisible(true)
        onePanel:getChildByName("text_free"):setVisible(false)
        onePanel:getChildByName("image_jin"):getChildByName("text_cost"):setString(string.format(Lang.ui_activity_LimitTimeHero7, _onePrice))
    end

    local tenPanel = image_basemap:getChildByName("image_ten")
    local btn_ten = tenPanel:getChildByName("btn_ten")
    btn_ten:setPressedActionEnabled(true)
    ccui.Helper:seekNodeByName(tenPanel, "text_cost"):setString(string.format(Lang.ui_activity_LimitTimeHero8, _tenPrice))

    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_one then
                if _time == 0 or (_time > 0 and UIActivityTime.checkMoney(1, _onePrice)) then
                    UIManager.showLoading()
                    local _msgData = {
                        int = {
                            recruitTypeId = 2,
                            diamondRecruitTypeId = 2
                        }
                    }
	                netSendPackage({header=StaticMsgRule.cardRecruit, msgdata=_msgData}, netCallbackFunc)
                end
            elseif sender == btn_ten then
                if UIActivityTime.checkMoney(1, _tenPrice) then
                    UIManager.showLoading()
                    local _msgData = {
                        int = {
                            recruitTypeId = 2,
                            diamondRecruitTypeId = 3
                        }
                    }
	                netSendPackage({header=StaticMsgRule.cardRecruit, msgdata=_msgData}, netCallbackFunc)
                end
            end
        end
    end
    btn_one:addTouchEventListener(onButtonEvent)
    btn_ten:addTouchEventListener(onButtonEvent)
end

local function initCardInfo(_cardId)
    if not _cardId then
        return
    end
    local dictCardData = DictCard[tostring(_cardId)]
    local image_basemap = UIAactivityLimitTimeHero.Widget:getChildByName("image_basemap")
    local ui_cardFrame = image_basemap:getChildByName("image_frame_card")
    local ui_cardIcon = ui_cardFrame:getChildByName("image_warrior")
    local ui_cardType = ui_cardFrame:getChildByName("image_style")
    local ui_cardAptitude = ccui.Helper:seekNodeByName(ui_cardFrame, "label_zz")
    local ui_cardName = ccui.Helper:seekNodeByName(ui_cardFrame, "text_name")
    ui_cardFrame:loadTexture(utils.getQualityImage(dp.Quality.card, dictCardData.qualityId, dp.QualityImageType.middle))
    ui_cardType:loadTexture(utils.getCardTypeImage(dictCardData.cardTypeId))
    ui_cardAptitude:setString(tostring(dictCardData.nickname))
    ui_cardName:setString(dictCardData.name)
    if ui_cardFrame:getChildByName("ui_card_anim") then
        ui_cardFrame:getChildByName("ui_card_anim"):removeFromParent()
    end

    ui_cardIcon:setVisible(false)
	local cardAnim, cardAnimName
    if dictCardData.animationFiles and string.len(dictCardData.animationFiles) > 0 then
        cardAnim, cardAnimName = ActionManager.getCardAnimation(dictCardData.animationFiles)
    else
        cardAnim, cardAnimName = ActionManager.getCardBreatheAnimation("image/" .. DictUI[tostring(dictCardData.bigUiId)].fileName)
    end
	cardAnim:setPosition(cc.p(ui_cardFrame:getContentSize().width / 2, ui_cardFrame:getContentSize().height / 2 + 28 * 2))
	cardAnim:setName("ui_card_anim")
    ui_cardFrame:addChild(cardAnim)

    local ui_starImgs = {}
	for i = 1, 5 do
		ui_starImgs[i] = ui_cardFrame:getChildByName("image_star" .. i)
		ui_starImgs[i]:setVisible(false)
		ui_starImgs[i]:loadTexture("ui/jj01.png")
	end
    local _startIndex, _endIndex, _curIndex = 1, 0, 0
	local maxStarLevel = DictQuality[tostring(dictCardData.qualityId)].maxStarLevel
	if maxStarLevel == 1 then
		_startIndex = 3
		_endIndex = 3
	elseif maxStarLevel == 2 then
		_startIndex = 3
		_endIndex = 4
	elseif maxStarLevel == 3 then
		_startIndex = 2
		_endIndex = 4
	elseif maxStarLevel == 4 then
		_startIndex = 2
		_endIndex = 5
	else
		_startIndex = 1
		_endIndex = 5
	end
	for i = _startIndex, _endIndex do
		_curIndex = _curIndex + 1
		if DictStarLevel[tostring(dictCardData.starLevelId)].level >= _curIndex then
			ui_starImgs[i]:loadTexture("ui/jj02.png")
		end
		ui_starImgs[i]:setVisible(true)
	end
end

netCallbackFunc = function(_msgData)
    local code = tonumber(_msgData.header)
    if code == StaticMsgRule.intoLimitTimeHero then
        _curIntegral = _msgData.msgdata.int["5"]
        _curIntegralRank = _msgData.msgdata.int["6"]
        local _rankListData, _cardId = {}, nil
        local _tempData = utils.stringSplit(_msgData.msgdata.string["3"], "/")
        for key, obj in pairs(_tempData) do
            local _obj = utils.stringSplit(obj, "|")
            if tonumber(_obj[2]) == 0 and tonumber(_obj[3]) == 0 then
                _cardId = tonumber(_obj[4])
            else
                _rankListData[#_rankListData + 1] = {
                    id = tonumber(_obj[1]),
                    startRankNum = tonumber(_obj[2]),
                    endRankNum = tonumber(_obj[3]),
                    rewards = _obj[4]
                }
            end
        end
        _tempData = nil
        initCardInfo(_cardId)
        initIntegralRank(_msgData)
        initRankReward(_rankListData)
        initRecruitInfo(_msgData)
        local image_basemap = UIAactivityLimitTimeHero.Widget:getChildByName("image_basemap")
        local image_di_system = image_basemap:getChildByName("image_di_system")
        image_di_system:getChildByName("text_integral_number"):setString(tostring(_curIntegral))
        image_di_system:getChildByName("text_rank_number"):setString(tostring(_curIntegralRank))
    elseif code == StaticMsgRule.cardRecruit then
        UIActivityTime.refreshMoney()
        UIShopRecruitTen.show({recruitData=_msgData.msgdata.string["1"],recruitNum=((_recruitCountdown <= 0) and -1 or _recruitNum)})
    end
end

function UIAactivityLimitTimeHero.onActivity(_params)
    DictActivity = _params
end

function UIAactivityLimitTimeHero.init()
    local image_basemap = UIAactivityLimitTimeHero.Widget:getChildByName("image_basemap")
    local image_di_system = image_basemap:getChildByName("image_di_system")
    local image_integral_di = image_di_system:getChildByName("image_integral_di")
    local btn_reward = image_integral_di:getChildByName("btn_reward")
    local btn_help = image_basemap:getChildByName("btn_help")
    btn_help:setPressedActionEnabled(true)
    btn_reward:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_help then
                UIAllianceHelp.show({titleName=Lang.ui_activity_LimitTimeHero9,type=1})
            elseif sender == btn_reward then
                UIActivityLimitTimeHeroPreview.show({integral=_curIntegral,rank=_curIntegralRank})
            end
        end
    end
    btn_help:addTouchEventListener(onButtonEvent)
    btn_reward:addTouchEventListener(onButtonEvent)
end

function UIAactivityLimitTimeHero.setup()
    UIManager.showLoading()
	netSendPackage({header=StaticMsgRule.intoLimitTimeHero, msgdata={}}, netCallbackFunc)
    
    local image_basemap = UIAactivityLimitTimeHero.Widget:getChildByName("image_basemap")
    local ui_timeText = image_basemap:getChildByName("text_time")
    local ui_countdownText = image_basemap:getChildByName("text_countdown")
    if DictActivity and DictActivity.string["4"] ~= "" and DictActivity.string["5"] ~= "" then
        dp.addTimerListener(countDowun)
        local _startTime = utils.changeTimeFormat(DictActivity.string["4"])
		local _endTime = utils.changeTimeFormat(DictActivity.string["5"])
        ui_timeText:setString(string.format(Lang.ui_activity_LimitTimeHero10, _startTime[2],_startTime[3],_startTime[5],_endTime[2],_endTime[3],_endTime[5]))
        _countdownTime = utils.GetTimeByDate(DictActivity.string["5"]) - utils.getCurrentTime()
    else
        ui_timeText:setString("")
        ui_countdownText:setString("")
    end
    UIHomePage.limitHeroFlag = false
end

function UIAactivityLimitTimeHero.free()
    DictActivity = nil
    _countdownTime = 0
    _curIntegral = 0
    _curIntegralRank = 0
    dp.removeTimerListener(countDowun)
end

function UIAactivityLimitTimeHero.checkImageHint()
    if not UIHomePage.limitHeroFlag then    --如果已经不需要显示限时英雄的红点，就不再去判断活动是否结束
        return UIHomePage.limitHeroFlag
    end
    local temp = false
    local dictActivity = UIActivityTime.getActivityThing()
    for key,obj in pairs(dictActivity) do
        if obj.string["9"] == "LimitTimeHero" then
            temp = true
            break
        end
    end
    --活动结束
    if not temp then
        UIHomePage.limitHeroFlag = false
    end
    return UIHomePage.limitHeroFlag
end
