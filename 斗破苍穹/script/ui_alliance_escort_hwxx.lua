require"Lang"
UIAllianceEscortHWXX = {}

local userData = nil

function UIAllianceEscortHWXX.init()
end

function UIAllianceEscortHWXX.setup()
    local image_basemap = UIAllianceEscortHWXX.Widget:getChildByName("image_basemap")
    --护卫信息  格式：玩家Id|头像Id|名字|等级|战力
    local _playerData = utils.stringSplit(userData.playerInfo, "|")
    local text_hint = image_basemap:getChildByName("image_di_hint"):getChildByName("text_hint")
    text_hint:setString(string.format(Lang.ui_alliance_escort_hwxx1, _playerData[3]))
    image_basemap:getChildByName("text_info"):setString(string.format(Lang.ui_alliance_escort_hwxx2, userData.unionName))
    image_basemap:getChildByName("text_number"):setString(string.format(Lang.ui_alliance_escort_hwxx3, userData.goldCount))
    local image_frame_card = image_basemap:getChildByName("image_frame_card")
    image_frame_card:getChildByName("image_card"):loadTexture("image/" .. DictUI[tostring(DictCard[_playerData[2]].smallUiId)].fileName)
    image_frame_card:getChildByName("text_name"):setString(_playerData[3])
    image_frame_card:getChildByName("text_lv"):setString(Lang.ui_alliance_escort_hwxx4 .. _playerData[4])
    image_frame_card:getChildByName("text_fight"):setString(Lang.ui_alliance_escort_hwxx5 .. _playerData[5])
    local btn_look = image_basemap:getChildByName("btn_look")
    btn_look:setPressedActionEnabled(true)
    btn_look:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.showLoading()
            netSendPackage( { header = StaticMsgRule.enemyPlayerInfo, msgdata = { int = { playerId = tonumber(_playerData[1]) } } }, function(_msgData)
                pvp.loadGameData(_msgData)
                UIManager.pushScene("ui_arena_check")
            end )
        end
    end)
    local btn_embattle = image_basemap:getChildByName("btn_embattle")
    btn_embattle:setPressedActionEnabled(true)
    btn_embattle:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if net.InstPlayer.int["4"] >= DictFunctionOpen[ tostring( StaticFunctionOpen.partner ) ].level then
                UILineupEmbattle.setUIParam(true)
			    UIManager.pushScene("ui_lineup_embattle")
            else
                UILineupEmbattleOld.setUIParam(true)
			    UIManager.pushScene("ui_lineup_embattle_old")
            end
        end
    end)
    image_basemap:getChildByName("text_fight"):setString(userData.leftDesc)
    local btn_die = image_basemap:getChildByName("btn_die")
    local btn_fight = image_basemap:getChildByName("btn_fight")
    btn_die:setPressedActionEnabled(true)
    btn_fight:setPressedActionEnabled(true)
    local onBtnEventFunc = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_die then
                if userData.leftBtnCallback then
                    userData.leftBtnCallback(_playerData[3])
                end
            elseif sender == btn_fight then
                if userData.rightBtnCallback then
                    userData.rightBtnCallback()
                end
            end
        end
    end
    btn_die:addTouchEventListener(onBtnEventFunc)
    btn_fight:addTouchEventListener(onBtnEventFunc)
end

function UIAllianceEscortHWXX.free()
    userData = nil
end

function UIAllianceEscortHWXX.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_alliance_escort_hwxx")
end

return UIAllianceEscortHWXX
