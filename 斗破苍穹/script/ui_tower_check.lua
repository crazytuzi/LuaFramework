UITowerCheck = {}

local userData = nil

function UITowerCheck.init()
    local image_basemap = UITowerCheck.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    local btn_back = image_basemap:getChildByName("btn_back")
    local btn_embattle = image_basemap:getChildByName("btn_embattle")
    btn_close:setPressedActionEnabled(true)
    btn_back:setPressedActionEnabled(true)
    btn_embattle:setPressedActionEnabled(true)
    local onButtonEvent = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close or sender == btn_back then
                UIManager.popScene()
            elseif sender == btn_embattle then
                UIManager.popScene()
                UILineupEmbattle.setUIParam(true)
                UIManager.pushScene("ui_lineup_embattle")
            end
        end
    end
    btn_close:addTouchEventListener(onButtonEvent)
    btn_back:addTouchEventListener(onButtonEvent)
    btn_embattle:addTouchEventListener(onButtonEvent)
end

function UITowerCheck.setup()
    local image_basemap = UITowerCheck.Widget:getChildByName("image_basemap")
    local _itemData = {}
    if userData and userData.lineupData then
        local _data = utils.stringSplit(userData.lineupData, ";") --卡牌ID_星级_品质_位置_类型(1主力,2替补);
        if _data then
            for key, obj in pairs(_data) do
                local _tempData = utils.stringSplit(obj, "_")
                local _cardData = {
                    cardId = tonumber(_tempData[1]),
                    starLevel = tonumber(_tempData[2]),
                    qualityId = tonumber(_tempData[3]),
                    position = tonumber(_tempData[4]),
                    type = tonumber(_tempData[5])
                }
                if _cardData.type == 2 then
                    _itemData[_cardData.position + 6] = _cardData
                else
                    _itemData[_cardData.position] = _cardData
                end
                _cardData = nil
                _tempData = nil
            end
        end
    end
    for i = 1, 9 do
        local ui_frame = image_basemap:getChildByName("image_frame_card" .. i)
        local obj = _itemData[i]
        if obj then
            local qualityImage = utils.getQualityImage(dp.Quality.card, obj.qualityId, dp.QualityImageType.small)
            ui_frame:loadTexture(qualityImage)
            local dictCardData = DictCard[tostring(obj.cardId)]
            ui_frame:getChildByName("image_card"):loadTexture("image/" .. DictUI[tostring(dictCardData.smallUiId)].fileName)
            ccui.Helper:seekNodeByName(ui_frame, "text_name"):setString(dictCardData.name)
        else
            ui_frame:getChildByName("image_card"):loadTexture("ui/mg_suo.png")
            ui_frame:getChildByName("image_base_info"):setVisible(false)
        end
    end
end

function UITowerCheck.free()
    userData = nil
end

function UITowerCheck.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_tower_check")
end