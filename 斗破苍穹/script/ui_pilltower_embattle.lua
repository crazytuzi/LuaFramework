require"Lang"
UIPilltowerEmbattle = {}

local userData = nil
local image_basemap = nil
local touchPanel = nil

local _curTouchCard = nil
local _curTouchItem = nil --在onTouchBegan中被触摸到的卡片
local _onTouchBeganItemPosition = nil --在onTouchBegan中被触摸到的卡片在九宫格中的位置
local _isTouchBeganGrid = false
local _isTouchBeganLineup = false
local _isTouchRuning = false

--运行文本提示动画
local function runTextPromptAction()
    local image_hint = image_basemap:getChildByName("image_hint")
    local text_hint = image_hint:getChildByName("text_hint")
    image_hint:setVisible(true)
    text_hint:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1), cc.DelayTime:create(0.1), cc.CallFunc:create(function()
        text_hint:setOpacity(255)
    end))))
end
--停止文本提示动画
local function stopTextPromptAction()
    local image_hint = image_basemap:getChildByName("image_hint")
    local text_hint = image_hint:getChildByName("text_hint")
    if image_hint:isVisible() then
        text_hint:stopAllActions()
        image_hint:setVisible(false)
    end
end

--是否达到上限
local function isUpperLimit(position, _isFormLineup)
    if not _isFormLineup then
        if not _onTouchBeganItemPosition then
            return false
        end
        if _onTouchBeganItemPosition and  _onTouchBeganItemPosition <= 6 and position <= 6 then --首发位相互移动
            return false
        end
        if _onTouchBeganItemPosition and _onTouchBeganItemPosition > 6 and position > 6 then --替补位相互移动
            return false
        end
    end
    local myLineupPanel = image_basemap:getChildByName("image_me")
    local maxFirstCount = DictDantaLayer[tostring(userData.monsterId)].maxFirstCount
    local maxSubstituteCount = DictDantaLayer[tostring(userData.monsterId)].maxSubstituteCount
    local _firstCount, _substituteCount = 0, 0 --首发数，替补数
    for _k = 1, 9 do
        local cardIconItem = myLineupPanel:getChildByName("image_base_warrior".._k)
        if cardIconItem:getTag() > 0 then
            if _k <= 6 then
                _firstCount = _firstCount + 1
            else
                _substituteCount = _substituteCount + 1
            end
        end
    end
    if position <= 6 and _firstCount == maxFirstCount then
        --首发人数已达上限
        UIManager.showToast(Lang.ui_pilltower_embattle1)
        return true
    elseif position > 6 and _substituteCount == maxSubstituteCount then
        --替补人数已达上限
        UIManager.showToast(Lang.ui_pilltower_embattle2)
        return true
    end
end

local function onTouchBegan(touch, event)
    if _isTouchRuning then
        return false
    end
    local touchPoint = touchPanel:convertTouchToNodeSpaceAR(touch)
    local panelPoint = touchPanel:getParent():convertToWorldSpace(cc.p(touchPanel:getPositionX(), touchPanel:getPositionY()))
    touchPoint = cc.p(panelPoint.x + touchPoint.x, panelPoint.y + touchPoint.y)
    local childs = touchPanel:getChildren()
    for key, item in pairs(childs) do
        if item:isVisible() then
            local itemPoint = item:getParent():convertToWorldSpace(cc.p(item:getPositionX(), item:getPositionY()))
            if ccui.Helper:seekNodeByName(item, "bar_loading"):getPercent() > 0 and --死人不允许拖入
            touchPoint.x > itemPoint.x - item:getContentSize().width * item:getScale() / 2 and touchPoint.x < itemPoint.x + item:getContentSize().width * item:getScale() / 2 and
            touchPoint.y > itemPoint.y - item:getContentSize().height * item:getScale() / 2 and touchPoint.y < itemPoint.y + item:getContentSize().height * item:getScale() / 2 then
                
                _isTouchRuning = true
                _isTouchBeganLineup = true
                stopTextPromptAction()
                _curTouchCard = item:clone()
                _curTouchCard:setPosition(itemPoint)
                UIPilltowerEmbattle.Widget:addChild(_curTouchCard, 100)
                _curTouchCard:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0.45)))
                item:setVisible(false)
                _curTouchItem = item

                return true
            end
        end
    end
    local myLineupPanel = image_basemap:getChildByName("image_me")
    for i = 1, 9 do
        local item = myLineupPanel:getChildByName("image_base_warrior"..i)
        if item:getTag() > 0 then
            local itemPoint = item:getParent():convertToWorldSpace(cc.p(item:getPositionX(), item:getPositionY()))
            if touchPoint.x > itemPoint.x - item:getContentSize().width / 2 and touchPoint.x < itemPoint.x + item:getContentSize().width / 2 and
                touchPoint.y > itemPoint.y - item:getContentSize().height / 2 and touchPoint.y < itemPoint.y + item:getContentSize().height / 2 then

                _isTouchRuning = true
                _isTouchBeganGrid = true
                item:loadTexture(utils.getQualityImage(dp.Quality.card, 2, dp.QualityImageType.small))
                item:getChildByName("image_warrior"):setVisible(false)
                item:getChildByName("image_loading"):setVisible(false)

                _curTouchCard = (touchPanel:getChildren()[1]):clone()
                _curTouchCard:setTag(item:getTag())
                local lineupData = UIPilltower.UserData.myCardData[item:getTag()]
                local instCardData = net.InstPlayerCard[tostring(lineupData.instCardId)]
                local dictCard = DictCard[tostring(instCardData.int["3"])]
                _curTouchCard:loadTexture(utils.getQualityImage(dp.Quality.card, instCardData.int["4"], dp.QualityImageType.middle))
                local isAwake = instCardData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒 --isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId
                _curTouchCard:getChildByName("image_card"):loadTexture("image/" .. DictUI[tostring(isAwake == 1 and dictCard.awakeBigUiId or dictCard.bigUiId)].fileName)
                local totalBlood = math.floor(utils.getCardAttribute(lineupData.instCardId)[StaticFightProp.blood])
                local currentBlood = (lineupData.cardBlood > totalBlood) and totalBlood or lineupData.cardBlood
                local bloodBar = ccui.Helper:seekNodeByName(_curTouchCard, "bar_loading")
                bloodBar:setPercent(currentBlood / totalBlood * 100)
                ccui.Helper:seekNodeByName(_curTouchCard, "text_number"):setString(math.floor(bloodBar:getPercent()) .. "%")
                _curTouchCard:setPosition(itemPoint)
                UIPilltowerEmbattle.Widget:addChild(_curTouchCard, 100)
                _curTouchCard:setVisible(true)
                _curTouchCard:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0.45)))
                _curTouchItem = item
                _onTouchBeganItemPosition = i

                return true
            end
        end
    end
    return false
end
local function onTouchMoved(touch, event)
    if _curTouchCard then
        local touchPoint = touchPanel:convertTouchToNodeSpaceAR(touch)
        local panelPoint = touchPanel:getParent():convertToWorldSpace(cc.p(touchPanel:getPositionX(), touchPanel:getPositionY()))
        touchPoint = cc.p(panelPoint.x + touchPoint.x, panelPoint.y + touchPoint.y)
        _curTouchCard:setPosition(touchPoint)
    else
        touchPanel:stopAllActions()
    end
end
local function onTouchEnded(touch, event)
--    local touchPoint = touchPanel:convertTouchToNodeSpaceAR(touch)
--    local panelPoint = touchPanel:getParent():convertToWorldSpace(cc.p(touchPanel:getPositionX(), touchPanel:getPositionY()))
--    touchPoint = cc.p(panelPoint.x + touchPoint.x, panelPoint.y + touchPoint.y)
    if _curTouchCard then
        local _isVisible = true
        local myLineupPanel = image_basemap:getChildByName("image_me")
        for i = 1, 9 do
            local item = myLineupPanel:getChildByName("image_base_warrior"..i)
            local itemPoint = item:getParent():convertToWorldSpace(cc.p(item:getPositionX(), item:getPositionY()))
            if _curTouchCard:getPositionX() > itemPoint.x - item:getContentSize().width / 2 and _curTouchCard:getPositionX() < itemPoint.x + item:getContentSize().width / 2 and
            _curTouchCard:getPositionY() > itemPoint.y - item:getContentSize().height / 2 and _curTouchCard:getPositionY() < itemPoint.y + item:getContentSize().height / 2 then
                
                if _isTouchBeganGrid and _curTouchItem then
                    --****************** 网格中相互交换 ******************
                    if item:getTag() > 0 then
                        _curTouchItem:setTag(item:getTag())
                        local lineupData = UIPilltower.UserData.myCardData[item:getTag()]
                        local instCardData = net.InstPlayerCard[tostring(lineupData.instCardId)]
                        local dictCard = DictCard[tostring(instCardData.int["3"])]
                        _curTouchItem:loadTexture(utils.getQualityImage(dp.Quality.card, instCardData.int["4"], dp.QualityImageType.small))
                        local ui_cardIcon = _curTouchItem:getChildByName("image_warrior")
                        local isAwake = instCardData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒 --isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId
                        ui_cardIcon:loadTexture("image/" .. DictUI[tostring(isAwake == 1 and dictCard.awakeSmallUiId or dictCard.smallUiId)].fileName)
                        ui_cardIcon:setVisible(true)
                        local totalBlood = math.floor(utils.getCardAttribute(lineupData.instCardId)[StaticFightProp.blood])
                        local currentBlood = (lineupData.cardBlood > totalBlood) and totalBlood or lineupData.cardBlood
                        local bloodBar = ccui.Helper:seekNodeByName(_curTouchItem, "bar_loading")
                        bloodBar:setPercent(currentBlood / totalBlood * 100)
                        ccui.Helper:seekNodeByName(_curTouchItem, "text_number"):setString(math.floor(bloodBar:getPercent()) .. "%")
                        bloodBar:getParent():setVisible(true)
                    else
                        if isUpperLimit(i) then
                            local lineupData = UIPilltower.UserData.myCardData[_curTouchItem:getTag()]
                            local instCardData = net.InstPlayerCard[tostring(lineupData.instCardId)]
                            _curTouchItem:loadTexture(utils.getQualityImage(dp.Quality.card, instCardData.int["4"], dp.QualityImageType.small))
                            _curTouchItem:getChildByName("image_warrior"):setVisible(true)
                            _curTouchItem:getChildByName("image_loading"):setVisible(true)
                            _curTouchCard:removeFromParent()
                            _curTouchCard = nil
                            _curTouchItem = nil
                            _isTouchBeganGrid = false
                            _isTouchBeganLineup = false
                            _onTouchBeganItemPosition = nil
                            _isTouchRuning = false
                            return
                        else
                            _curTouchItem:setTag(-1)
                        end
                    end
                    --****************** 网格中相互交换 ******************
                elseif _isTouchBeganLineup and _curTouchItem and item:getTag() > 0 then
                    --****************** 从阵容中替换网格中已放入的牌 ******************
                    local childs = touchPanel:getChildren()
                    for key, lineupItem in pairs(childs) do
                        if lineupItem:getTag() == item:getTag() then
                            lineupItem:setVisible(true)
                            break
                        end
                    end
                    --****************** 从阵容中替换网格中已放入的牌 ******************
                elseif _isTouchBeganLineup and _curTouchItem and item:getTag() <= 0 then
                    if isUpperLimit(i, _isTouchBeganLineup) then
                        _curTouchCard:removeFromParent()
                        _curTouchItem:setVisible(true)
                        _curTouchCard = nil
                        _curTouchItem = nil
                        _isTouchBeganGrid = false
                        _isTouchBeganLineup = false
                        _onTouchBeganItemPosition = nil
                        _isTouchRuning = false
                        return
                    end
                end
                --****************** 从阵容中将卡牌拖入到网格中 ******************
                item:setTag(_curTouchCard:getTag())
                local lineupData = UIPilltower.UserData.myCardData[_curTouchCard:getTag()]
                local instCardData = net.InstPlayerCard[tostring(lineupData.instCardId)]
                local dictCard = DictCard[tostring(instCardData.int["3"])]
                item:loadTexture(utils.getQualityImage(dp.Quality.card, instCardData.int["4"], dp.QualityImageType.small))
                local ui_cardIcon = item:getChildByName("image_warrior")
                local isAwake = instCardData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒 --isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId
                ui_cardIcon:loadTexture("image/" .. DictUI[tostring(isAwake == 1 and dictCard.awakeSmallUiId or dictCard.smallUiId)].fileName)
                ui_cardIcon:setVisible(true)
                local totalBlood = math.floor(utils.getCardAttribute(lineupData.instCardId)[StaticFightProp.blood])
                local currentBlood = (lineupData.cardBlood > totalBlood) and totalBlood or lineupData.cardBlood
                local bloodBar = ccui.Helper:seekNodeByName(item, "bar_loading")
                bloodBar:setPercent(currentBlood / totalBlood * 100)
                ccui.Helper:seekNodeByName(item, "text_number"):setString(math.floor(bloodBar:getPercent()) .. "%")
                bloodBar:getParent():setVisible(true)
                --****************** 从阵容中将卡牌拖入到网格中 ******************
                _isVisible = false

                break
            end
        end
        local childs = touchPanel:getChildren()
        for key, item in pairs(childs) do
            if item:getTag() == _curTouchCard:getTag() then
                item:setVisible(_isVisible)
                break
            end
        end
        if _isTouchBeganGrid and _isVisible and _curTouchItem then
            _curTouchItem:setTag(-1)
        end
        _curTouchCard:removeFromParent()
        _curTouchCard = nil
    end
    _curTouchItem = nil
    _isTouchBeganGrid = false
    _isTouchBeganLineup = false
    _onTouchBeganItemPosition = nil
    _isTouchRuning = false
end

local function saveLineupLayout()
    for key = 1, 9 do
        local lineupData = UIPilltower.UserData.myCardData[key]
        if lineupData then
            lineupData.lineupPosition = nil
        end
    end
    local myLineupPanel = image_basemap:getChildByName("image_me")
    for key = 1, 9 do
        local _cardIconItem = myLineupPanel:getChildByName("image_base_warrior" .. key)
        local lineupData = UIPilltower.UserData.myCardData[_cardIconItem:getTag()]
        if lineupData then
            lineupData.lineupPosition = key
        end
    end
end

local function setTouchPanelEnabled(enabled)
    if enabled then
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
		listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
		listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
		local eventDispatcher = touchPanel:getEventDispatcher()
		if eventDispatcher then
			eventDispatcher:removeEventListenersForTarget(touchPanel)
			eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchPanel)
		end
	else
		if touchPanel then
			local eventDispatcher = touchPanel:getEventDispatcher()
			if eventDispatcher then
				eventDispatcher:removeEventListenersForTarget(touchPanel)
			end
		end
	end
end

local function initMonsterUI()
    if not userData then
        return
    end
    local enemyLineupPanel = image_basemap:getChildByName("image_other")
    local monsterIds = utils.stringSplit(DictDantaLayer[tostring(userData.monsterId)].monsters, ",")
    local enemyLineupData = {}
    for key, obj in pairs(monsterIds) do
        enemyLineupData[DictDantaMonster[obj].position] = DictDantaMonster[obj]
    end
    for i = 1, 9 do
        local _item = enemyLineupPanel:getChildByName("image_base_warrior"..i)
        local _cardIcon = _item:getChildByName("image_warrior")
        if enemyLineupData[i] then
            local dictCard = DictCard[tostring(enemyLineupData[i].cardId)]
            local qualityId = (enemyLineupData[i].qualityId > 0) and enemyLineupData[i].qualityId or dictCard.qualityId
            _item:loadTexture(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small))
            _cardIcon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
            _cardIcon:setTouchEnabled(true)
            _cardIcon:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    UICardInfo.setDictCardId(dictCard.id)
			        UIManager.pushScene("ui_card_info")
                end
            end)
        else
            _item:loadTexture(utils.getQualityImage(dp.Quality.card, 2, dp.QualityImageType.small))
            _cardIcon:loadTexture("ui/mg_suo.png")
            utils.GrayWidget(_item, true)
        end
    end
    enemyLineupData = nil

    local layerAwards = DictDantaLayer[tostring(UIPilltower.UserData.curFightPoint)].layerAwards
    local _thingData = utils.stringSplit(layerAwards, "#")[1]
--    local _thingData = utils.stringSplit(awards, ";")
    local image_preview = enemyLineupPanel:getChildByName("image_preview")
    local item_frame = image_preview:getChildByName("image_frame_good")
    local item_icon = item_frame:getChildByName("image_good")
    local item_name = item_frame:getChildByName("text_name")
    local item_get = item_frame:getChildByName("image_get")
    local itemProps = utils.getItemProp(_thingData)
    if itemProps.frameIcon then
        item_frame:loadTexture(itemProps.frameIcon)
    end
    if itemProps.smallIcon then
        item_icon:loadTexture(itemProps.smallIcon)
        utils.showThingsInfo(item_icon, itemProps.tableTypeId, itemProps.tableFieldId)
    end
    if itemProps.name then
        item_name:setString(itemProps.name .. "×" .. itemProps.count)
--        if itemProps.qualityColor then
--            item_name:setTextColor(itemProps.qualityColor)
--        end
    end
    item_get:setVisible(false)
    _thingData = nil
    UIPilltower.netSendPackage({int={p2=7,p3=UIPilltower.UserData.curFightPoint}}, function(_msgData)
        if _msgData then
            local _state = _msgData.msgdata.int.r2 --0成功,1失败
            if type(_state) == "number" and _state == 1 then
                utils.showSureDialog(_msgData.msgdata.string.r3, function()
                    UIManager.popAllScene()
                    UIPilltower.resetData(true)
                    UIPilltower.UserData.challengeNums = DictSysConfig[tostring(StaticSysConfig.DanTaNum)].value
                    UIPilltower.setup()
                end)
            else
                local _id = _msgData.msgdata.int.r1 --0:未领取，1:已领取
                if type(_id) == "number" and _id == 1 then
                    item_get:setVisible(true)
                end
            end
        end
    end)
end

function UIPilltowerEmbattle.init()
    image_basemap = UIPilltowerEmbattle.Widget:getChildByName("image_basemap")
    image_basemap:getChildByName("text_title"):setString(string.format(Lang.ui_pilltower_embattle3, UIPilltower.UserData.curFightPoint))
    local ui_medalCount = image_basemap:getChildByName("image_flag"):getChildByName("text_number")
    ui_medalCount:setString("×" .. UIPilltower.UserData.medalCount)
    local enemyLineupPanel = image_basemap:getChildByName("image_other")
    local myLineupPanel = image_basemap:getChildByName("image_me")
    local btn_close = image_basemap:getChildByName("btn_close")
    local btn_earlier = myLineupPanel:getChildByName("btn_earlier")
    local btn_blood = myLineupPanel:getChildByName("btn_blood")
    local btn_fight = image_basemap:getChildByName("btn_challange")
    local image_flag = btn_earlier:getChildByName("image_flag")
    local text_cancel = btn_earlier:getChildByName("text_cancel")
    local firstUseCount = DictSysConfig[tostring(StaticSysConfig.FirstUseStar)].value --先手消耗数量
    ccui.Helper:seekNodeByName(btn_earlier, "text_cost"):setString(tostring(firstUseCount))
    local myFirstFlag = myLineupPanel:getChildByName("image_before")
    myFirstFlag:setVisible(false)
    local enemyFirstFlag = enemyLineupPanel:getChildByName("image_before")
    btn_close:setPressedActionEnabled(true)
    btn_earlier:setPressedActionEnabled(true)
    btn_fight:setPressedActionEnabled(true)
    btn_blood:setPressedActionEnabled(true)
    local function onClickEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_earlier then
                if UIPilltower.UserData.medalCount >= firstUseCount then
                    image_flag:setVisible(not image_flag:isVisible())
                    text_cancel:setVisible(not text_cancel:isVisible())
                    myFirstFlag:setVisible(text_cancel:isVisible())
                    enemyFirstFlag:setVisible(image_flag:isVisible())
                    local _count = utils.stringSplit(ui_medalCount:getString(), "×")[2]
                    if myFirstFlag:isVisible() then
                        ui_medalCount:setString("×" .. tonumber(_count) - firstUseCount)
                    else
                        ui_medalCount:setString("×" .. tonumber(_count) + firstUseCount)
                    end
                else
                    UIManager.showToast(Lang.ui_pilltower_embattle4)
                end
            elseif sender == btn_blood then
                for i = 1, 9 do
                    local _data = UIPilltower.UserData.myCardData[i]
                    if _data then
                        local totalBlood = math.floor(utils.getCardAttribute(_data.instCardId)[StaticFightProp.blood])
                        local currentBlood = (_data.cardBlood > totalBlood) and totalBlood or _data.cardBlood
                        if currentBlood < totalBlood then
                            UIPilltowerBlood.show({isFirst=myFirstFlag:isVisible()})
                            return
                        end
                    end
                end
                UIManager.showToast(Lang.ui_pilltower_embattle5)
            elseif sender == btn_fight then
                local myData = {}
                local _isDie = false
                local _firstCount, _substituteCount = 0, 0
                for i = 1, 9 do
                    local item = myLineupPanel:getChildByName("image_base_warrior"..i)
                    if item:getTag() > 0 then
                        local lineupData = UIPilltower.UserData.myCardData[item:getTag()]
                        if lineupData then
                            myData[#myData+1] = {
                                instCardId = lineupData.instCardId,
                                position = i,
                                hpCur = lineupData.cardBlood,
                            }
                            if i <= 6 then
                                _firstCount = _firstCount + 1
                            else
                                _substituteCount = _substituteCount + 1
                            end
                        end
                        local _bloodBar = ccui.Helper:seekNodeByName(item, "bar_loading")
                        if math.floor(_bloodBar:getPercent()) <= 0 then --上阵的卡牌中有死人
                            _isDie = true
                        end
                    end
                end

                local onFight = function()
                    local fightData = {
                        myCardData = myData,
                        dntaMonsterIds = DictDantaLayer[tostring(userData.monsterId)].monsters,
                        isSelfFirst = myFirstFlag:isVisible()
                    }
                    saveLineupLayout()
                    utils.sendFightData(fightData,dp.FightType.FIGHT_PILL_TOWER,function(params)
                        if params.isWin then
                            local _medalNums = 0
                            if params.fightRound >= DictSysConfig[tostring(StaticSysConfig.MinStar3)].value and 
                                params.fightRound <= DictSysConfig[tostring(StaticSysConfig.MaxStar3)].value then
                                _medalNums = 3
                            elseif params.fightRound >= DictSysConfig[tostring(StaticSysConfig.MinStar2)].value and 
                                params.fightRound <= DictSysConfig[tostring(StaticSysConfig.MaxStar2)].value then
                                _medalNums = 2
                            elseif params.fightRound >= DictSysConfig[tostring(StaticSysConfig.MinStar1)].value and 
                                params.fightRound <= DictSysConfig[tostring(StaticSysConfig.MaxStar1)].value then
                                _medalNums = 1
                            end
                            UIPilltower.UserData.medalCount = UIPilltower.UserData.medalCount + _medalNums
                            UIPilltower.UserData.pointMedalCount[UIPilltower.UserData.curFightPoint] = _medalNums
                            for i = 1, 9 do
                                local myCardData = UIPilltower.UserData.myCardData[i]
                                if myCardData then
                                    local instCardData = net.InstPlayerCard[tostring(myCardData.instCardId)]
                                    local _blood = params.fightersHP[instCardData.int["3"]]
                                    if _blood then
                                        UIPilltower.UserData.myCardData[i].cardBlood = _blood
                                    else
                                        local totalBlood = math.floor(utils.getCardAttribute(myCardData.instCardId)[StaticFightProp.blood])
                                        local currentBlood = UIPilltower.UserData.myCardData[i].cardBlood
                                        if currentBlood > 0 and currentBlood < totalBlood then
                                            currentBlood = currentBlood + math.floor(totalBlood * DictSysConfig[tostring(StaticSysConfig.BloodUseFactor)].value)
                                            UIPilltower.UserData.myCardData[i].cardBlood = (currentBlood > totalBlood) and totalBlood or currentBlood
                                        end
                                    end
                                end
                            end
                            if UIPilltower.UserData.historyMaxPoint < UIPilltower.UserData.curFightPoint then
                                UIPilltower.UserData.historyMaxPoint = UIPilltower.UserData.curFightPoint
                            end
                            
                            UIPilltower.setFightWinCallback(function()
                                if UIPilltower.UserData.curFightPoint % 5 == 0 then
                                    UIPilltower.resetPointData()
                                end
                                UIPilltower.UserData.curFightPoint = UIPilltower.UserData.curFightPoint + 1
                            end, params.awardThings and utils.stringSplit(params.awardThings, "#")[2] or nil)
                            UITowerWinSmall.show({
                                isWin = true,
                                fightType = dp.FightType.FIGHT_PILL_TOWER,
                                curFightPoint = UIPilltower.UserData.curFightPoint,
                                awardThings = params.awardThings and utils.stringSplit(params.awardThings, "#")[1] or nil
                            })
--                            UIManager.showScreen("ui_notice", "ui_pilltower", "ui_menu")
--                            UIManager.showToast("战斗胜利！~")
                        else
                            UITowerWinSmall.show({
                                isWin = false,
                                fightType = dp.FightType.FIGHT_PILL_TOWER,
                                curFightPoint = UIPilltower.UserData.curFightPoint
                            })
--                            UIManager.showScreen("ui_notice", "ui_activity_tower", "ui_menu")
--                            UIManager.showToast("战斗失败！~")
                            UIPilltower.resetData()
                        end
                    end)
				    UIFightMain.loading()
                    if myFirstFlag:isVisible() and UIPilltower.UserData.medalCount >= firstUseCount then
                        UIPilltower.UserData.medalCount = UIPilltower.UserData.medalCount - firstUseCount
                    end
                    myData = nil
                    fightData = nil
                end
                local netSendFightPackage = function()
                    UIPilltower.netSendPackage({int={p2=5,p4=UIPilltower.UserData.curFightPoint}}, function(_msgData)
                        if _msgData then
                            local _state = _msgData.msgdata.int.r1 --0成功,1失败
                            if type(_state) == "number" and _state == 1 then
                                utils.showSureDialog(_msgData.msgdata.string.r2, function()
                                    UIManager.popAllScene()
                                    UIPilltower.resetData(true)
                                    UIPilltower.UserData.challengeNums = DictSysConfig[tostring(StaticSysConfig.DanTaNum)].value
                                    UIPilltower.setup()
                                end)
                            else
                                if UIPilltower.UserData.curFightPoint == 1 and UIPilltower.UserData.challengeNums > 0 then
                                    UIPilltower.UserData.challengeNums = UIPilltower.UserData.challengeNums - 1
                                end
                                onFight()
                            end
                        elseif UIPilltower.UserData.isDebug then
                            onFight()
                        end
                    end)
                end
                
                if #myData == 0 then
                    UIManager.showToast(Lang.ui_pilltower_embattle6)
                    myData = nil
                elseif _firstCount > DictDantaLayer[tostring(userData.monsterId)].maxFirstCount then
                    UIManager.showToast(Lang.ui_pilltower_embattle7)
                    myData = nil
                elseif _substituteCount > DictDantaLayer[tostring(userData.monsterId)].maxSubstituteCount then
                    UIManager.showToast(Lang.ui_pilltower_embattle8)
                    myData = nil
                elseif _isDie then
                    UIManager.showToast(Lang.ui_pilltower_embattle9)
                    myData = nil
                elseif _firstCount == 0 then
                    UIManager.showToast(Lang.ui_pilltower_embattle10)
                    myData = nil
                elseif #myData < DictDantaLayer[tostring(userData.monsterId)].maxSubstituteCount + DictDantaLayer[tostring(userData.monsterId)].maxFirstCount then
                    utils.showDialog(Lang.ui_pilltower_embattle11, netSendFightPackage)
                else
                    netSendFightPackage()
                end
            end
        end
    end
    btn_close:addTouchEventListener(onClickEvent)
    btn_earlier:addTouchEventListener(onClickEvent)
    btn_fight:addTouchEventListener(onClickEvent)
    btn_blood:addTouchEventListener(onClickEvent)
    
    touchPanel = image_basemap:getChildByName("base_title")

    for i = 1, 9 do
        local item = myLineupPanel:getChildByName("image_base_warrior"..i)
        item:setTag(-1)
        item:loadTexture(utils.getQualityImage(dp.Quality.card, 2, dp.QualityImageType.small))
        item:getChildByName("image_warrior"):setVisible(false)
        item:getChildByName("image_loading"):setVisible(false)
    end
    initMonsterUI()
    local dictData = DictDantaLayer[tostring(userData.monsterId)]
    myLineupPanel:getChildByName("text_hint"):setString(string.format(Lang.ui_pilltower_embattle12, dictData.maxFirstCount, dictData.maxSubstituteCount))
end

function UIPilltowerEmbattle.setup()
    runTextPromptAction()
    setTouchPanelEnabled(true)
    local myLineupPanel = image_basemap:getChildByName("image_me")
    for key = 1, 9 do
        local _cardItem = touchPanel:getChildByName("image_frame_card"..key)
        local lineupData = UIPilltower.UserData.myCardData[key]
        if lineupData then
            _cardItem:setTag(key)
            local instCardData = net.InstPlayerCard[tostring(lineupData.instCardId)]
            local dictCard = DictCard[tostring(instCardData.int["3"])]
            _cardItem:loadTexture(utils.getQualityImage(dp.Quality.card, instCardData.int["4"], dp.QualityImageType.middle))
            local ui_cardIcon = _cardItem:getChildByName("image_card")
            local isAwake = instCardData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒 --isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId
            ui_cardIcon:loadTexture("image/" .. DictUI[tostring(isAwake == 1 and dictCard.awakeBigUiId or dictCard.bigUiId)].fileName)
            local totalBlood = math.floor(utils.getCardAttribute(lineupData.instCardId)[StaticFightProp.blood])
            local currentBlood = (lineupData.cardBlood > totalBlood) and totalBlood or lineupData.cardBlood
            local bloodBar = ccui.Helper:seekNodeByName(_cardItem, "bar_loading")
            bloodBar:setPercent(currentBlood / totalBlood * 100)
            ccui.Helper:seekNodeByName(_cardItem, "text_number"):setString(math.floor(bloodBar:getPercent()) .. "%")
            if lineupData.lineupPosition then
                local _cardIconItem = myLineupPanel:getChildByName("image_base_warrior" .. lineupData.lineupPosition)
                _cardIconItem:setTag(key)
                _cardIconItem:loadTexture(utils.getQualityImage(dp.Quality.card, instCardData.int["4"], dp.QualityImageType.small))
                local _ui_cardIcon = _cardIconItem:getChildByName("image_warrior")
                _ui_cardIcon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
                _ui_cardIcon:setVisible(true)
                local _bloodBar = ccui.Helper:seekNodeByName(_cardIconItem, "bar_loading")
                _bloodBar:setPercent(currentBlood / totalBlood * 100)
                ccui.Helper:seekNodeByName(_cardIconItem, "text_number"):setString(math.floor(_bloodBar:getPercent()) .. "%")
                _bloodBar:getParent():setVisible(true)
                _cardItem:setVisible(false)
            end
        else
            _cardItem:setTag(-1)
            _cardItem:setVisible(false)
        end
    end
end

function UIPilltowerEmbattle.refreshCardBlood()
    local myLineupPanel = image_basemap:getChildByName("image_me")
    for key = 1, 9 do
        local _cardIconItem = myLineupPanel:getChildByName("image_base_warrior" .. key)
        local cardIconData = UIPilltower.UserData.myCardData[_cardIconItem:getTag()]
        if cardIconData then
            local totalBlood = math.floor(utils.getCardAttribute(cardIconData.instCardId)[StaticFightProp.blood])
            local currentBlood =(cardIconData.cardBlood > totalBlood) and totalBlood or cardIconData.cardBlood
            local _bloodBar = ccui.Helper:seekNodeByName(_cardIconItem, "bar_loading")
            _bloodBar:setPercent(currentBlood / totalBlood * 100)
            ccui.Helper:seekNodeByName(_cardIconItem, "text_number"):setString(math.floor(_bloodBar:getPercent()) .. "%")
        end

        local _cardLineupItem = touchPanel:getChildByName("image_frame_card" .. key)
        local lineupData = UIPilltower.UserData.myCardData[key]
        if lineupData and _cardLineupItem:getTag() == key then
            local totalBlood = math.floor(utils.getCardAttribute(lineupData.instCardId)[StaticFightProp.blood])
            local currentBlood =(lineupData.cardBlood > totalBlood) and totalBlood or lineupData.cardBlood
            local _bloodBar = ccui.Helper:seekNodeByName(_cardLineupItem, "bar_loading")
            _bloodBar:setPercent(currentBlood / totalBlood * 100)
            ccui.Helper:seekNodeByName(_cardLineupItem, "text_number"):setString(math.floor(_bloodBar:getPercent()) .. "%")
        end
    end
    local ui_medalCount = image_basemap:getChildByName("image_flag"):getChildByName("text_number")
    local myFirstFlag = myLineupPanel:getChildByName("image_before")
    local firstUseCount = DictSysConfig[tostring(StaticSysConfig.FirstUseStar)].value --先手消耗数量
    if myFirstFlag:isVisible() then
        ui_medalCount:setString("×" .. UIPilltower.UserData.medalCount - firstUseCount)
    else
        ui_medalCount:setString("×" .. UIPilltower.UserData.medalCount)
    end
    UIPilltower.refreshMedalCount()
end

function UIPilltowerEmbattle.free()
    userData = nil
    image_basemap = nil
    touchPanel = nil
    _curTouchCard = nil
    _curTouchItem = nil
    _onTouchBeganItemPosition = nil
    _isTouchBeganGrid = false
    _isTouchBeganLineup = false
    _isTouchRuning = false
end

function UIPilltowerEmbattle.show(_tableParams)
    userData = _tableParams
    UIManager.pushScene("ui_pilltower_embattle", nil, 1)
end
