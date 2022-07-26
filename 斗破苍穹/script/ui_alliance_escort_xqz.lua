require"Lang"
UIAllianceEscortXQZ = {}

local userData = nil

function UIAllianceEscortXQZ.init()
    UITalkFly.hide()
end

function UIAllianceEscortXQZ.setup()
    local speed = 5
    local image_basemap = UIAllianceEscortXQZ.Widget:getChildByName("image_basemap")
    image_basemap:getChildByName("text_info"):setString(string.format(Lang.ui_alliance_escort_xqz1, userData.unionName))
    image_basemap:getChildByName("text_number"):setString(string.format(Lang.ui_alliance_escort_xqz2, userData.goldCount))
    local text_look = image_basemap:getChildByName("text_look")
    local bar_loading = image_basemap:getChildByName("image_loading"):getChildByName("bar_loading")
    bar_loading:setPercent(0)
    local _randomPercent = 100
    if userData.showFlag == Lang.ui_alliance_escort_xqz3 then
        text_look:setVisible(false)
        image_basemap:getChildByName("text_hint"):setString(Lang.ui_alliance_escort_xqz4)
        if userData.playerInfo then
            _randomPercent = utils.random(20, 90)
        end
    else
        local _tempData = utils.stringSplit(userData.playerInfo, "_")
        text_look:setString(string.format(Lang.ui_alliance_escort_xqz5, _tempData[2]))
        image_basemap:getChildByName("text_hint"):setString(Lang.ui_alliance_escort_xqz6)
        text_look:setVisible(true)
        if tonumber(_tempData[1]) == 0 then
            _randomPercent = utils.random(20, 90)
        end
    end
    local text_point = image_basemap:getChildByName("text_point")
    text_point:setString("")
    local _point = 1
    local _flagTimer = os.clock()
    
    bar_loading:scheduleUpdateWithPriorityLua(function(dt)
        if os.clock() - _flagTimer >= 0.2 then
            _flagTimer = os.clock()
            local _str = ""
            for i = 1, _point do
                _str = _str .. "。"
            end
            text_point:setString(_str)
            _point = _point + 1
            if _point >= 5 then
                _point = 0
            end
        end
        
        bar_loading:setPercent(bar_loading:getPercent() + (100 / speed / (1/cc.Director:getInstance():getAnimationInterval())))
        if bar_loading:getPercent() >= _randomPercent then
            bar_loading:unscheduleUpdate()

            UIAllianceEscortXQZ.Widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
                UIManager.popAllScene()
                if userData.callbackFunc then
                    userData.callbackFunc()
                end
            end)))

        end

    end, 0)
end

function UIAllianceEscortXQZ.free()
    userData = nil
    UITalkFly.fShow()
end

function UIAllianceEscortXQZ.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_alliance_escort_xqz")
end

return UIAllianceEscortXQZ
