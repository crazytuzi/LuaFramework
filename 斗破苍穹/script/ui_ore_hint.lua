UIOreHint = { }

local function formatTime(countdown)
    return string.format("%02d:%02d", math.floor(countdown / 3600), math.floor(countdown / 60) % 60)
end

function UIOreHint.init()
    local text4 = ccui.Helper:seekNodeByName(UIOreHint.Widget, "text4")
    local text5 = ccui.Helper:seekNodeByName(UIOreHint.Widget, "text5")
    local btn_back = ccui.Helper:seekNodeByName(UIOreHint.Widget, "btn_back")

    local startTime = formatTime(UIOre.activityTimes[1])
    local endTime = formatTime(UIOre.activityTimes[2])
    local startTime2 = formatTime(UIOre.activityTimes[3])
    local endTime2 = formatTime(UIOre.activityTimes[4])

    text4:setString(string.format("%s-%s", startTime, endTime))
    text5:setString(string.format("%s-%s", startTime2, endTime2))

    btn_back:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if UIBuySlive.isSoulFlag  then            
                UIManager.showWidget("ui_menu")
                UIManager.showWidget("ui_soul_get")
                UIManager.pushScene("ui_buy_slive")
                UIBuySlive.isSoulFlag = false
            else
                -- UIMenu.onActivity()
                UIMenu.onHomepage()
            end
        end
    end )
end
