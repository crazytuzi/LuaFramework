UIAllianceEscortZSCG = {}

local userData = nil

function UIAllianceEscortZSCG.init()
    local image_basemap = UIAllianceEscortZSCG.Widget:getChildByName("image_basemap")
    local btn_sure = image_basemap:getChildByName("btn_sure")
    btn_sure:setPressedActionEnabled(true)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
            UIAllianceEscort.updateEscortDyna()
        end
    end)
end

function UIAllianceEscortZSCG.setup()

end

function UIAllianceEscortZSCG.free()
    userData = nil
end

function UIAllianceEscortZSCG.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_alliance_escort_zscg")
end

return UIAllianceEscortZSCG