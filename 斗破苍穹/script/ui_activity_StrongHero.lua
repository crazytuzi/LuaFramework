require"Lang"
UIActivityStrongHero = {}

local _countdownTime = 0
local _rewardCountdown = 0
local DictActivity = nil
local _curIntegral = 0
local _curIntegralRank = 0

local netCallbackFunc = nil

local function countDowun()
    _countdownTime = _countdownTime - 1
    if _countdownTime < 0 then
        _countdownTime = 0
    end
    _rewardCountdown = _rewardCountdown - 1
    if _rewardCountdown < 0 then
        _rewardCountdown = 0
    end
    if UIActivityStrongHero.Widget then
        local day = math.floor(_countdownTime / 3600 / 24) --天
	    local hour = math.floor(_countdownTime / 3600 % 24) --小时
	    local minute = math.floor(_countdownTime / 60 % 60) --分
	    local second = math.floor(_countdownTime % 60) --秒
        local image_basemap = UIActivityStrongHero.Widget:getChildByName("image_basemap")
        local ui_countdownText = image_basemap:getChildByName("text_countdown")
        ui_countdownText:setString(string.format(Lang.ui_activity_StrongHero1, day, hour, minute, second))

        if _countdownTime > 0 then
            local _hour = math.floor(_rewardCountdown / 3600 % 24) --小时
	        local _minute = math.floor(_rewardCountdown / 60 % 60) --分
	        local _second = math.floor(_rewardCountdown % 60) --秒
            local ui_rewardTime = image_basemap:getChildByName("text_time_get")
            if DictActivity and DictActivity.StrongHeroFlag == 1 then
                ui_rewardTime:setString(string.format(Lang.ui_activity_StrongHero2, _hour, _minute, _second))
            else
                ui_rewardTime:setString(string.format(Lang.ui_activity_StrongHero3, _hour, _minute, _second))
            end
            local loadBarPanel = image_basemap:getChildByName("image_loading")
            local ui_timeBar = loadBarPanel:getChildByName("bar_loading")
            local _curTime = utils.getCurrentTime()
            local _tableTime = os.date("*t", _curTime)
            local _12Time = utils.GetTimeByDate(_tableTime.year .. "-" .. _tableTime.month .. "-" .. _tableTime.day .. " 12:00:00")
            local _21Time = utils.GetTimeByDate(_tableTime.year .. "-" .. _tableTime.month .. "-" .. _tableTime.day .. " 21:00:00")
            local _23Time = utils.GetTimeByDate(_tableTime.year .. "-" .. _tableTime.month .. "-" .. _tableTime.day .. " 23:00:00")
            if _curTime == _12Time then
                ui_timeBar:setPercent(10)
                _rewardCountdown = _21Time - _curTime
            elseif _curTime == _21Time then
                ui_timeBar:setPercent(50)
                _rewardCountdown = _23Time - _curTime
            elseif _curTime == _23Time then
                ui_timeBar:setPercent(100)
                _rewardCountdown = _23Time + 60*60 - _curTime + 12*60*60
            elseif _curTime > _23Time or _curTime < _12Time then
                ui_timeBar:setPercent(0)
            end
        else
            local ui_rewardTime = image_basemap:getChildByName("text_time_get")
            ui_rewardTime:setString(Lang.ui_activity_StrongHero4)
            local loadBarPanel = image_basemap:getChildByName("image_loading")
            local ui_timeBar = loadBarPanel:getChildByName("bar_loading")
            ui_timeBar:setPercent(100)
        end
    end
end

local function initThingInfo(_msgData)
    local firstNames = nil
    if DictActivity and DictActivity.StrongHeroFlag == 1 then
        if _msgData.msgdata.string and _msgData.msgdata.string.firstNames then
            firstNames = utils.stringSplit(_msgData.msgdata.string.firstNames, ";")
        end
    end
    local _thingData = utils.stringSplit(_msgData.msgdata.string["1"], "|")
    local image_basemap = UIActivityStrongHero.Widget:getChildByName("image_basemap")
    local thingPanel = {}
    thingPanel[1] = image_basemap:getChildByName("image_one")
    thingPanel[2] = image_basemap:getChildByName("image_two")
    thingPanel[3] = image_basemap:getChildByName("image_three")
    for key, obj in pairs(thingPanel) do
        local ui_frame = obj:getChildByName("image_frame_good")
        local ui_icon = ui_frame:getChildByName("image_good")
        local ui_value = ui_frame:getChildByName("text_number")
        local ui_name = ui_frame:getChildByName("text_name")
        local ui_hint = ui_frame:getChildByName("text_hint")
        ui_hint:setString(Lang.ui_activity_StrongHero5)
        utils.addFrameParticle( ui_icon , true )
        if _thingData[key] then
            local itemProps = utils.getItemProp(_thingData[key])
            if itemProps.frameIcon then
                ui_frame:loadTexture(itemProps.frameIcon)
            end
            if itemProps.smallIcon then
                ui_icon:loadTexture(itemProps.smallIcon)
                utils.showThingsInfo(ui_icon, itemProps.tableTypeId, itemProps.tableFieldId)
            end
            if itemProps.name then
                ui_name:setString(itemProps.name)
            end
            ui_value:setString("×" .. itemProps.count)
        end
        if firstNames and firstNames[key] and string.len(firstNames[key]) > 0 then
            ui_hint:setString(firstNames[key])
        end
    end
end

--初始积分排行
local function initIntegralRank(_msgData)
    _curIntegral = _msgData.msgdata.int["3"]
    _curIntegralRank = _msgData.msgdata.int["4"]
    local _rankData = {}
    local _minIndex, _maxIndex = 16, 20
    local _tempData = utils.stringSplit(_msgData.msgdata.string["2"], "/")
    if #_tempData > 2 and _curIntegralRank >= #_tempData - 2 then
        _maxIndex = #_tempData
        _minIndex = _maxIndex - 4
    elseif #_tempData > 2 and _curIntegralRank > 2 and _curIntegralRank < #_tempData - 2 then
        _maxIndex = _curIntegralRank + 2
        _minIndex = _maxIndex - 4
    elseif _curIntegralRank > 0 and _curIntegralRank <= 2 then
        _maxIndex = 5
        _minIndex = _maxIndex - 4
    end
    if _minIndex <= 0 then
        _minIndex = 1
    end
    for key, obj in pairs(_tempData) do
        local _obj = utils.stringSplit(obj, "|")
        local _rank = tonumber(_obj[1])
        if _rank >= _minIndex and _rank <= _maxIndex then
            _rankData[#_rankData + 1] = {
                orderId = _rank,
                playerName = _obj[2],
                integral = tonumber(_obj[3])
            }
        end
    end
    
    local image_basemap = UIActivityStrongHero.Widget:getChildByName("image_basemap")
    local image_di_system = image_basemap:getChildByName("image_di_system")
    local image_integral_di = image_di_system:getChildByName("image_integral_di")
    for key = 1, 5 do
        local ui_name = image_integral_di:getChildByName("text_name"..key)
        local ui_integral = image_integral_di:getChildByName("text_integral"..key)
        if _rankData[key] then
            ui_name:setString(_rankData[key].orderId .. "." .. _rankData[key].playerName)
            ui_integral:setString(tonumber(_rankData[key].integral))
        else
            ui_name:setString("")
            ui_integral:setString("")
        end
    end
    local image_rank_di = image_di_system:getChildByName("image_rank_di")
    local ui_curIntegral = image_rank_di:getChildByName("text_integral_number")
    local ui_curIntegralRank = image_rank_di:getChildByName("text_rank_number")
    ui_curIntegral:setString(tostring(_curIntegral))
    ui_curIntegralRank:setString(tostring(_curIntegralRank))
end

netCallbackFunc = function(_msgData)
    local code = tonumber(_msgData.header)
    if code == StaticMsgRule.intoStrogerHero then
        initThingInfo(_msgData)
        initIntegralRank(_msgData)
    end
end

function UIActivityStrongHero.onActivity(_params)
    DictActivity = _params
end

function UIActivityStrongHero.init()
    local image_basemap = UIActivityStrongHero.Widget:getChildByName("image_basemap")
    local image_di_system = image_basemap:getChildByName("image_di_system")
    local image_rank_di = image_di_system:getChildByName("image_rank_di")
    local btn_reward = image_rank_di:getChildByName("btn_reward")
    local btn_help = image_basemap:getChildByName("btn_help")
    btn_help:setPressedActionEnabled(true)
    btn_reward:setPressedActionEnabled(true)
    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_help then
                if DictActivity and DictActivity.StrongHeroFlag == 1 then
                    UIAllianceHelp.show({titleName=Lang.ui_activity_StrongHero6,type=11})
                else
                    UIAllianceHelp.show({titleName=Lang.ui_activity_StrongHero7,type=2})
                end
            elseif sender == btn_reward then
                UIActivityStrongHeroPreview.show({integral=_curIntegral,rank=_curIntegralRank})
            end
        end
    end
    btn_help:addTouchEventListener(onButtonEvent)
    btn_reward:addTouchEventListener(onButtonEvent)
end

function UIActivityStrongHero.setup()
    UIManager.showLoading()
	netSendPackage({header=StaticMsgRule.intoStrogerHero, msgdata={}}, netCallbackFunc)
    local image_basemap = UIActivityStrongHero.Widget:getChildByName("image_basemap")
    local ui_timeText = image_basemap:getChildByName("text_time")
    local ui_countdownText = image_basemap:getChildByName("text_countdown")
    if DictActivity and DictActivity.string["4"] ~= "" and DictActivity.string["5"] ~= "" then
        dp.addTimerListener(countDowun)
        local _startTime = utils.changeTimeFormat(DictActivity.string["4"])
		local _endTime = utils.changeTimeFormat(DictActivity.string["5"] , 1 )
        cclog("_endTime 1:".._endTime[1])
        ui_timeText:setString(string.format(Lang.ui_activity_StrongHero8, _startTime[2],_startTime[3],_startTime[5],_endTime[2],_endTime[3], _endTime[5] ))
        _countdownTime = utils.GetTimeByDate(DictActivity.string["5"] , 1 ) - utils.getCurrentTime()
    else
        ui_timeText:setString("")
        ui_countdownText:setString("")
    end
    local loadBarPanel = image_basemap:getChildByName("image_loading")
    local ui_timeBar = loadBarPanel:getChildByName("bar_loading")
    ui_timeBar:setPercent(0)
    local _curTime = utils.getCurrentTime()
    local _tableTime = os.date("*t", _curTime)
    local _12Time = utils.GetTimeByDate(_tableTime.year .. "-" .. _tableTime.month .. "-" .. _tableTime.day .. " 12:00:00")
    local _21Time = utils.GetTimeByDate(_tableTime.year .. "-" .. _tableTime.month .. "-" .. _tableTime.day .. " 21:00:00")
    local _23Time = utils.GetTimeByDate(_tableTime.year .. "-" .. _tableTime.month .. "-" .. _tableTime.day .. " 23:00:00")
    if _curTime >= _12Time and _curTime < _21Time then
        ui_timeBar:setPercent(10)
    elseif _curTime >= _21Time and _curTime < _23Time then
        ui_timeBar:setPercent(50)
    elseif _curTime == _23Time then
        ui_timeBar:setPercent(100)
    end
    if _curTime < _12Time then
        _rewardCountdown = _12Time - _curTime
    elseif _curTime < _21Time then
        _rewardCountdown = _21Time - _curTime
    elseif _curTime < _23Time then
        _rewardCountdown = _23Time - _curTime
    elseif _curTime > _23Time and _curTime < _23Time + 60*60 then
        _rewardCountdown = _23Time + 60*60 - _curTime + 12*60*60
    end
end

function UIActivityStrongHero.free()
    DictActivity = nil
    _countdownTime = 0
    _rewardCountdown = 0
    _curIntegral = 0
    _curIntegralRank = 0
    dp.removeTimerListener(countDowun)
end
