require"Lang"
UIAllianceEscortTQQD = {}

local userData = nil
local _countdownTime = 0

local CountdownTimeFunc

CountdownTimeFunc = function()
    _countdownTime = _countdownTime - 1
    if _countdownTime < 0 then
        dp.removeTimerListener(CountdownTimeFunc)
        _countdownTime = 0
    end
    local minute = math.floor(_countdownTime / 60 % 60) --分
	local second = math.floor(_countdownTime % 60) --秒
    local image_basemap = UIAllianceEscortTQQD.Widget:getChildByName("image_basemap")
    local image_steal = image_basemap:getChildByName("image_steal")
    image_steal:getChildByName("text_time"):setString(string.format(Lang.ui_alliance_escort_tqqd1, minute, second))
end

local function closeDialog()
    local image_basemap = UIAllianceEscortTQQD.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    btn_close:releaseUpEvent()
end

function UIAllianceEscortTQQD.init()
    local image_basemap = UIAllianceEscortTQQD.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    btn_close:setPressedActionEnabled(true)
    btn_close:addTouchEventListener(function(sender, eventType)
        UIManager.popScene()
    end)
end

function UIAllianceEscortTQQD.setup()
    _countdownTime = userData.countdownTime
    dp.addTimerListener(CountdownTimeFunc)
    local image_basemap = UIAllianceEscortTQQD.Widget:getChildByName("image_basemap")
    image_basemap:getChildByName("text_info"):setString(string.format(Lang.ui_alliance_escort_tqqd2, userData.unionName))
    image_basemap:getChildByName("text_number"):setString(string.format(Lang.ui_alliance_escort_tqqd3, userData.goldCount))
    local image_steal = image_basemap:getChildByName("image_steal")
    local image_grab = image_basemap:getChildByName("image_grab")
    local function onEventFunc(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == image_steal then
                if userData.leftBtnCallback then
                    userData.leftBtnCallback(closeDialog)
                end
            elseif sender == image_grab then
                if userData.rightBtnCallback then
                    userData.rightBtnCallback(closeDialog)
                end
            end
        end
    end
    image_steal:addTouchEventListener(onEventFunc)
    image_grab:addTouchEventListener(onEventFunc)
    image_steal:getChildByName("text_hint"):setString(userData.leftDesc)
    image_grab:getChildByName("text_hint"):setString(userData.rightDesc)
    image_grab:getChildByName("text_time"):setString(string.format(Lang.ui_alliance_escort_tqqd4, userData.todayCount, userData.totalCount))
end

function UIAllianceEscortTQQD.free()
    dp.removeTimerListener(CountdownTimeFunc)
    _countdownTime = 0
    userData = nil
end

function UIAllianceEscortTQQD.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_alliance_escort_tqqd")
end

return UIAllianceEscortTQQD
