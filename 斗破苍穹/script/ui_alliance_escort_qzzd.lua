require"Lang"
UIAllianceEscortQZZD = {}

local userData = nil

function UIAllianceEscortQZZD.init()

end

function UIAllianceEscortQZZD.setup()
    UIAllianceEscortQZZD.Widget:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
        UIManager.popScene()
        if userData.callbackFunc then
            userData.callbackFunc()
        end
    end)))
    local image_basemap = UIAllianceEscortQZZD.Widget:getChildByName("image_basemap")
    image_basemap:getChildByName("text_info"):setString(string.format(Lang.ui_alliance_escort_qzzd1, userData.unionName))
    image_basemap:getChildByName("text_number"):setString(string.format(Lang.ui_alliance_escort_qzzd2, userData.goldCount))
    image_basemap:getChildByName("text_hint"):setString(string.format(Lang.ui_alliance_escort_qzzd3, userData.playerInfo))
end

function UIAllianceEscortQZZD.free()
    userData = nil
end

function UIAllianceEscortQZZD.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_alliance_escort_qzzd")
end

return UIAllianceEscortQZZD
