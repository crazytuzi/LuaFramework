require"Lang"
UIAllianceEscortTQCG = {}

local userData = nil

function UIAllianceEscortTQCG.init()
    local image_basemap = UIAllianceEscortTQCG.Widget:getChildByName("image_basemap")
    local btn_sure = image_basemap:getChildByName("btn_sure")
    btn_sure:setPressedActionEnabled(true)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            UIManager.popScene()
            UIAllianceEscort.updateEscortDyna()
        end
    end)
end

function UIAllianceEscortTQCG.setup()
    local image_basemap = UIAllianceEscortTQCG.Widget:getChildByName("image_basemap")
    if userData.isCurUnion then
        image_basemap:getChildByName("text_hint"):setString(Lang.ui_alliance_escort_tqcg1)
    else
        image_basemap:getChildByName("text_hint"):setString(Lang.ui_alliance_escort_tqcg2)
    end
    local image_frame_good1 = image_basemap:getChildByName("image_frame_good1")
    image_frame_good1:getChildByName("image_good"):loadTexture("image/union_jintiao.png")
    image_frame_good1:getChildByName("text_price"):setString(Lang.ui_alliance_escort_tqcg3 .. DictUnionLootConfig["1"].stealGetGoldBarNum)
    local image_frame_good2 = image_basemap:getChildByName("image_frame_good2")
    image_frame_good2:getChildByName("image_good"):loadTexture("image/ui_small_alliance.png")
    image_frame_good2:getChildByName("text_price"):setString(Lang.ui_alliance_escort_tqcg4 .. DictUnionLootConfig["1"].stealGetUnionOffNum)
end

function UIAllianceEscortTQCG.free()
    userData = nil
end

function UIAllianceEscortTQCG.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_alliance_escort_tqcg")
end

return UIAllianceEscortTQCG
