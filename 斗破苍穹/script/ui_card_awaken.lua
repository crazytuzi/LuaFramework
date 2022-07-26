require"Lang"
UICardAwaken = {}

local userData = nil

function UICardAwaken.init()
    local image_basemap = UICardAwaken.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    local btn_awaken = image_basemap:getChildByName("btn_awaken")
    local btn_help = image_basemap:getChildByName("btn_help")
    btn_close:setPressedActionEnabled(true)
    btn_awaken:setPressedActionEnabled(true)
    btn_help:setPressedActionEnabled(true)
    local onBtnEvent = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_help then
                UIAllianceHelp.show( { type = 36 , titleName = Lang.ui_card_awaken1 } )
            elseif sender == btn_awaken then
                local instPlayerCardData = net.InstPlayerCard[tostring(userData.InstPlayerCard_id)]
	            local dictCardData = DictCard[tostring(instPlayerCardData.int["3"])]
                local qualityId = instPlayerCardData.int["4"] --卡牌品阶ID
                local things = utils.stringSplit(dictCardData.awakeNeedThings, ";")
                for key, obj in pairs(things) do
                    local _tempData = utils.stringSplit(obj, "_")
                    local _tableTypeId = tonumber(_tempData[2])
                    local _tableFieldId = tonumber(_tempData[3])
                    local _value = tonumber(_tempData[4])
                    local _count = 0
                    if _tableTypeId == StaticTableType.DictThing then
                        _count = utils.getThingCount(_tableFieldId)
                    elseif _tableTypeId == StaticTableType.DictCard then
                        for key, obj in pairs(net.InstPlayerCard) do
                            if obj.int["3"] == _tableFieldId and obj.int["10"] == 0 and obj.int["15"] ~= 1 then
                                _count = _count + 1
                            end
                        end
                    elseif _tableTypeId == StaticTableType.DictMagic then
                        for key, obj in pairs(net.InstPlayerMagic) do
                            if obj.int["3"] == _tableFieldId and obj.int["8"] == 0 then
                                _count = _count + 1
                            end
                        end
                    end
                    if _count < _value then
                        return UIManager.showToast(Lang.ui_card_awaken2)
                    end
                end

                UIManager.showLoading()
                netSendPackage( {
                    header = StaticMsgRule.cardAwake, msgdata = { int = { 
                        instCardId = userData.InstPlayerCard_id
                    } }
                } , function(_msgData)
                    local animation = ActionManager.getUIAnimation(80, function()
                        UIManager.popScene()
                        UIManager.flushWidget(UICardAdvance)
                        UIManager.flushWidget(UICardInfo)
                        UIManager.flushWidget(UILineup)
                        UIManager.flushWidget(UIBagCard)
                    end)
                    animation:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
                    animation:getBone("j01"):addDisplay(ccs.Skin:create("image/" .. DictUI[tostring(dictCardData.awakeBigUiId)].fileName), 0)
                    animation:getBone("j02"):addDisplay(ccs.Skin:create(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.middle, true)), 0)
                    animation:getBone("jin"):addDisplay(ccs.Skin:create(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.middle)), 0)
                    local _name = ccui.Text:create()
                    _name:setFontName(dp.FONT)
                    _name:setString(Lang.ui_card_awaken3 .. dictCardData.name)
                    _name:setFontSize(30)
                    _name:setTextColor(utils.getQualityColor(qualityId))
                    _name:enableOutline(cc.c4b(255, 255, 255, 255), 2)
                    animation:getBone("Layer40"):addDisplay(_name, 0)
                    UIManager.uiLayer:addChild(animation, 1000)
                end )
            end
        end
    end
    btn_close:addTouchEventListener(onBtnEvent)
    btn_awaken:addTouchEventListener(onBtnEvent)
    btn_help:addTouchEventListener(onBtnEvent)
end

function UICardAwaken.setup()
    local image_basemap = UICardAwaken.Widget:getChildByName("image_basemap")
    local ui_cardLevelLabel = image_basemap:getChildByName("image_lv"):getChildByName("text_lv")
    local ui_leftCardBg = image_basemap:getChildByName("image_base_before")
    local ui_leftCardIcon = ui_leftCardBg:getChildByName("image_warrior")
    local ui_leftCardQualityImage = ui_leftCardBg:getChildByName("image_advance_before")
    local ui_leftCardQualityName = ui_leftCardQualityImage:getChildByName("text_product")
    local ui_rightCardBg = image_basemap:getChildByName("image_base_after")
    local ui_rightCardIcon = ui_rightCardBg:getChildByName("image_warrior")
    local ui_rightCardQualityImage = ui_rightCardBg:getChildByName("image_advance_after")
    local ui_rightCardName = ui_rightCardQualityImage:getChildByName("text_product")
    local ui_newSkillLabelBg = image_basemap:getChildByName("image_skill")
    local ui_newSkillLabel = ui_newSkillLabelBg:getChildByName("text_skill")

    local instPlayerCardData = net.InstPlayerCard[tostring(userData.InstPlayerCard_id)]
	local dictCardData = DictCard[tostring(instPlayerCardData.int["3"])]
	local cardLv = instPlayerCardData.int["9"] --卡牌等级
	local qualityId = instPlayerCardData.int["4"] --卡牌品阶ID
	local starLevelId = instPlayerCardData.int["5"] --卡牌星级ID
    local things = utils.stringSplit(dictCardData.awakeNeedThings, ";") --卡牌觉醒需要的材料 格式：位置_tableTypeId_tableFieldId_value;
    local awakeNeedThings = {}
    for key, obj in pairs(things) do
        local _tempData = utils.stringSplit(obj, "_")
        awakeNeedThings[tonumber(_tempData[1])] = string.sub(obj, 3, string.len(obj))
    end

    ui_cardLevelLabel:setString(Lang.ui_card_awaken4 .. cardLv)
    ui_leftCardBg:loadTexture(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.middle))
    ui_leftCardIcon:loadTexture("image/" .. DictUI[tostring(dictCardData.bigUiId)].fileName)
    ui_leftCardQualityImage:loadTexture(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.middle, true))
    ui_leftCardQualityName:setString(dictCardData.name)
    ui_rightCardBg:loadTexture(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.middle))
    ui_rightCardIcon:loadTexture("image/" .. DictUI[tostring(dictCardData.awakeBigUiId)].fileName)
    ui_rightCardQualityImage:loadTexture(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.middle, true))
    ui_rightCardName:setString(Lang.ui_card_awaken5 .. dictCardData.name)
    ui_newSkillLabel:setString(Lang.ui_card_awaken6 .. SkillManager[dictCardData.awakeSkill].name)
    for i = 1, 5 do
        if awakeNeedThings[i] then
            local ui_item = ui_newSkillLabelBg:getChildByName("image_material_" .. i)
            local ui_itemIcon = ui_item:getChildByName("image_material_" .. i)
            local ui_itemName = ccui.Helper:seekNodeByName(ui_item, "text_material_name_" .. i)
            local ui_itemCount = ccui.Helper:seekNodeByName(ui_item, "text_material_name_" .. i .. "_now")
            local itemProps = utils.getItemProp(awakeNeedThings[i])
            if itemProps.frameIcon then
                ui_item:loadTexture(itemProps.frameIcon)
            end
            if itemProps.smallIcon then
                ui_itemIcon:loadTexture(itemProps.smallIcon)
            end
            if itemProps.name then
                ui_itemName:setString(itemProps.name .. "x" .. itemProps.count)
            end
            local _count = 0
            if itemProps.tableTypeId == StaticTableType.DictThing then
                _count = utils.getThingCount(itemProps.tableFieldId)
            elseif itemProps.tableTypeId == StaticTableType.DictCard then
                for key, obj in pairs(net.InstPlayerCard) do
                    if obj.int["3"] == itemProps.tableFieldId and obj.int["10"] == 0 and obj.int["15"] ~= 1 then
                        _count = _count + 1
                    end
                end
            elseif itemProps.tableTypeId == StaticTableType.DictMagic then
                for key, obj in pairs(net.InstPlayerMagic) do
                    if obj.int["3"] == itemProps.tableFieldId and obj.int["8"] == 0 then
                        _count = _count + 1
                    end
                end
            end
            ui_itemCount:setString(Lang.ui_card_awaken7 .. _count)
        end
    end
end

function UICardAwaken.free()
    userData = nil
end

function UICardAwaken.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_card_awaken")
end
