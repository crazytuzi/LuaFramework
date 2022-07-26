require"Lang"
UIAllianceEscortQDCG = {}

local userData = nil

function UIAllianceEscortQDCG.init()
    local image_basemap = UIAllianceEscortQDCG.Widget:getChildByName("image_basemap")
    local btn_sure = image_basemap:getChildByName("btn_sure")
    btn_sure:setPressedActionEnabled(true)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
            UIManager.showScreen("ui_notice", "ui_alliance_escort")
        end
    end)
end

function UIAllianceEscortQDCG.setup()
    local image_basemap = UIAllianceEscortQDCG.Widget:getChildByName("image_basemap")
    image_basemap:getChildByName("text_win"):setString(Lang.ui_alliance_escort_qdcg1 .. userData.playerInfo)
    if userData.isCurUnion then
        image_basemap:getChildByName("text_hint"):setString(Lang.ui_alliance_escort_qdcg2)
    else
        image_basemap:getChildByName("text_hint"):setString(Lang.ui_alliance_escort_qdcg3)
    end
    local image_frame_good1 = image_basemap:getChildByName("image_frame_good1")
    image_frame_good1:getChildByName("image_good"):loadTexture("image/union_jintiao.png")
    image_frame_good1:getChildByName("text_price"):setString(Lang.ui_alliance_escort_qdcg4 .. DictUnionLootConfig["1"].lootGetGoldBarNum)
    local image_frame_good2 = image_basemap:getChildByName("image_frame_good2")
    image_frame_good2:getChildByName("image_good"):loadTexture("image/ui_small_alliance.png")
    image_frame_good2:getChildByName("text_price"):setString(Lang.ui_alliance_escort_qdcg5 .. DictUnionLootConfig["1"].stealGetUnionOffNum)
end

function UIAllianceEscortQDCG.free()
    userData = nil
end

function UIAllianceEscortQDCG.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_alliance_escort_qdcg")
end

return UIAllianceEscortQDCG
