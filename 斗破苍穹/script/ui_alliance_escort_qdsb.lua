require"Lang"
UIAllianceEscortQDSB = {}

local userData = nil

function UIAllianceEscortQDSB.init()
    local image_basemap = UIAllianceEscortQDSB.Widget:getChildByName("image_basemap")
    local btn_sure = image_basemap:getChildByName("btn_sure")
    btn_sure:setPressedActionEnabled(true)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
            UIManager.showScreen("ui_notice", "ui_alliance_escort")
        end
    end)
end

function UIAllianceEscortQDSB.setup()
    local image_basemap = UIAllianceEscortQDSB.Widget:getChildByName("image_basemap")
    local image_frame_good = image_basemap:getChildByName("image_frame_good")
    image_frame_good:getChildByName("image_good"):loadTexture("image/ui_small_alliance.png")
    image_frame_good:getChildByName("text_price"):setString(Lang.ui_alliance_escort_qdsb1 .. DictUnionLootConfig["1"].fightFailGetUnionOffNum)
end

function UIAllianceEscortQDSB.free()
    userData = nil
end

function UIAllianceEscortQDSB.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_alliance_escort_qdsb")
end

return UIAllianceEscortQDSB
