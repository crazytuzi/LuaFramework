require"Lang"
UICardPieces = {}

local userData = nil

function UICardPieces.init()
    local image_hint = UICardPieces.Widget:getChildByName("image_hint")
    local btn_close = image_hint:getChildByName("btn_close")
    local btn_out = image_hint:getChildByName("btn_out")
    btn_close:setPressedActionEnabled(true)
    btn_out:setPressedActionEnabled(true)
    local onBtnEvent = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close or sender == btn_out then
                UIManager.popScene()
            end
        end
    end
    btn_close:addTouchEventListener(onBtnEvent)
    btn_out:addTouchEventListener(onBtnEvent)
end

function UICardPieces.setup()
    local image_hint = UICardPieces.Widget:getChildByName("image_hint")
    local image_frame_piece = image_hint:getChildByName("image_frame_piece")
    local image_frame_card = image_hint:getChildByName("image_frame_card")
    local image_base_number = image_hint:getChildByName("image_base_number")

    local ui_iconL = image_frame_piece:getChildByName("image_piece")
    local ui_nameL = ccui.Helper:seekNodeByName(image_frame_piece, "text_name_gem")
    local ui_countL = ccui.Helper:seekNodeByName(image_frame_piece, "text_info_gem")
    local ui_iconR = image_frame_card:getChildByName("image_card")
    local ui_nameR = ccui.Helper:seekNodeByName(image_frame_card, "text_name_gem")
    local ui_countR = ccui.Helper:seekNodeByName(image_frame_card, "text_info_gem")
    local ui_bar = image_base_number:getChildByName("bar_number")
    local ui_barText = image_base_number:getChildByName("text_number")
    local btn_add = image_base_number:getChildByName("btn_add")
    local btn_cut = image_base_number:getChildByName("btn_cut")
    btn_add:setPressedActionEnabled(true)
    btn_cut:setPressedActionEnabled(true)

    local dictThing = DictThing[tostring(StaticThing.thing186)]
    image_frame_piece:loadTexture(utils.getThingQualityImg(dictThing.bkGround))
    ui_iconL:loadTexture("image/" .. DictUI[tostring(dictThing.smallUiId)].fileName)
    ui_nameL:setString(dictThing.name)
    local _thingCount = utils.getThingCount(dictThing.id)
    ui_countL:setString(Lang.ui_card_pieces1 .. _thingCount)

    local dictCard = DictCard[tostring(userData.cardId)]
    image_frame_card:loadTexture(utils.getQualityImage(dp.Quality.card, dictCard.qualityId, dp.QualityImageType.small))
    ui_iconR:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
    local dictCardSoul = nil
    for key, obj in pairs(DictCardSoul) do
        if obj.cardId == userData.cardId then
            dictCardSoul = obj
            break
        end
    end
    ui_nameR:setString(dictCardSoul.name)
    local _soulCount = 0
    if net.InstPlayerCardSoul and dictCardSoul then
        for key, obj in pairs(net.InstPlayerCardSoul) do
            if obj.int["4"] == dictCardSoul.id then
                _soulCount = obj.int["5"]
                break
            end
        end
    end
    ui_countR:setString(Lang.ui_card_pieces2 .. _soulCount)
    local soulNum = DictQuality[tostring(dictCard.qualityId)].soulNum
    ui_barText:setString(_soulCount .. "/" .. soulNum)
    ui_bar:setPercent(utils.getPercent(_soulCount, soulNum))

    local _schedulerId, _isLongPressed = nil, false
    local stopScheduler = function()
        if _schedulerId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_schedulerId)
		end
        _schedulerId = nil
    end
    local onTouchEventEnd = function(sender)
        local _curSelectedCount = tonumber(utils.stringSplit(ui_countL:getString(), "：")[2])
        if sender == btn_add then
            _curSelectedCount = _curSelectedCount - 1
            if _curSelectedCount <= 0 then
                _curSelectedCount = 0
                UIManager.showToast(Lang.ui_card_pieces3)
                stopScheduler()
            end
        elseif sender == btn_cut then
            _curSelectedCount = _curSelectedCount + 1
            if _curSelectedCount > _thingCount then
                _curSelectedCount = _thingCount
                stopScheduler()
            end
        end
        local _selectedCount = _soulCount + (_thingCount - _curSelectedCount)
        ui_barText:setString(_selectedCount .. "/" .. soulNum)
        ui_bar:setPercent(utils.getPercent(_selectedCount, soulNum))
        ui_countL:setString(Lang.ui_card_pieces4 .. _curSelectedCount)
    end
    local onBtnEvent = function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            stopScheduler()
            _isLongPressed = false
            local _curTimer = os.clock()
			_schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
                if not _isLongPressed and os.clock() - _curTimer >= 0.5 then
                    _isLongPressed = true
                end
                if _isLongPressed then
                    onTouchEventEnd(sender)
                end
            end, 0.1, false)
        elseif eventType == ccui.TouchEventType.canceled then
            stopScheduler()
        elseif eventType == ccui.TouchEventType.ended then
            stopScheduler()
            if _isLongPressed then
                return
            end
            onTouchEventEnd(sender)
        end
    end
    btn_add:addTouchEventListener(onBtnEvent)
    btn_cut:addTouchEventListener(onBtnEvent)

    local btn_sure = image_hint:getChildByName("btn_sure")
    btn_sure:setPressedActionEnabled(true)
    btn_sure:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local _chipCount = _thingCount - tonumber(utils.stringSplit(ui_countL:getString(), "：")[2])
--            cclog("_chipCount--------:".._chipCount.."    userData.cardId---------------".. userData.cardId)
            if _chipCount <= 0 then
                return UIManager.showToast(Lang.ui_card_pieces5)
            end
            UIManager.showLoading()
            netSendPackage( {
                header = StaticMsgRule.universalChipCard, msgdata = { int = { cardId = userData.cardId, chipCount = _chipCount } }
            } , function(_msgData)
                UIManager.showToast(Lang.ui_card_pieces6)
                UIManager.popScene()
            end )
        end
    end)
end

function UICardPieces.free()
    userData = nil
end

function UICardPieces.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_card_pieces")
end
