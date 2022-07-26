require"Lang"
UICardJingjieN = {}

local userData = nil

local _isFlushWidget = false
local _prevTrainValues = {}

local function getAttributes(cardLv, qualityId, starLevelId, dictCardData)
	local attribute = {}
	for key, obj in pairs(DictFightProp) do
		if obj.id == StaticFightProp.blood then
			attribute[obj.id] = formula.getCardBlood(cardLv, qualityId, starLevelId, dictCardData)
		elseif obj.id == StaticFightProp.wAttack then
			attribute[obj.id] = formula.getCardGasAttack(cardLv, qualityId, starLevelId, dictCardData)
		elseif obj.id == StaticFightProp.wDefense then
			attribute[obj.id] = formula.getCardGasDefense(cardLv, qualityId, starLevelId, dictCardData)
		elseif obj.id == StaticFightProp.fAttack then
			attribute[obj.id] = formula.getCardSoulAttack(cardLv, qualityId, starLevelId, dictCardData)
		elseif obj.id == StaticFightProp.fDefense then
			attribute[obj.id] = formula.getCardSoulDefense(cardLv, qualityId, starLevelId, dictCardData)
		else
			attribute[obj.id] = 0
		end
	end
	return attribute
end

function UICardJingjieN.init()
    local image_basemap = UICardJingjieN.Widget:getChildByName("image_basemap")
    local btn_close = image_basemap:getChildByName("btn_close")
    local btn_break = image_basemap:getChildByName("btn_break")
    local btn_one = image_basemap:getChildByName("btn_one")
    local btn_ten = image_basemap:getChildByName("btn_ten")
    btn_one:getChildByName("text_one"):setString(Lang.ui_card_jingjie_n1 .. DictSysConfig[tostring(StaticSysConfig.cardTrainConsuPillNum)].value)
    btn_ten:getChildByName("text_ten"):setString(Lang.ui_card_jingjie_n2 .. DictSysConfig[tostring(StaticSysConfig.cardTrainConsuPillNum)].value * 10)
    btn_close:setPressedActionEnabled(true)
    btn_break:setPressedActionEnabled(true)
    btn_one:setPressedActionEnabled(true)
    btn_ten:setPressedActionEnabled(true)
    local onButtonEvent = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_break then
                UICardJingJie.show({ InstPlayerCard_id = userData.InstPlayerCard_id }, true)
            elseif sender == btn_one and sender:isBright() then
                local _count = utils.getThingCount(StaticThing.thing300)
                if _count >= DictSysConfig[tostring(StaticSysConfig.cardTrainConsuPillNum)].value then
                    UIManager.showLoading()
                    netSendPackage( {
                        header = StaticMsgRule.cardTrain, msgdata = { int = { 
                            instCardId = userData.InstPlayerCard_id,
                            trainTimes = 1
                        } }
                    } , function(_msgData)
                        UICardJingjieN.setup(true)
                        _isFlushWidget = true
                    end )
                else
                    UIManager.showToast(Lang.ui_card_jingjie_n3)
                end
            elseif sender == btn_ten and sender:isBright() then
                local _count = utils.getThingCount(StaticThing.thing300)
                if _count >= DictSysConfig[tostring(StaticSysConfig.cardTrainConsuPillNum)].value * 10 then
                    UIManager.showLoading()
                    netSendPackage( {
                        header = StaticMsgRule.cardTrain, msgdata = { int = { 
                            instCardId = userData.InstPlayerCard_id,
                            trainTimes = 10
                        } }
                    } , function(_msgData)
                        UICardJingjieN.setup(true)
                        _isFlushWidget = true
                    end )
                else
                    UIManager.showToast(Lang.ui_card_jingjie_n4)
                end
            end
        end
    end
    btn_close:addTouchEventListener(onButtonEvent)
    btn_break:addTouchEventListener(onButtonEvent)
    btn_one:addTouchEventListener(onButtonEvent)
    btn_ten:addTouchEventListener(onButtonEvent)
end

function UICardJingjieN.setup(_btnActionFlag)
    local image_basemap = UICardJingjieN.Widget:getChildByName("image_basemap")
    local btn_break = image_basemap:getChildByName("btn_break")
    local btn_one = image_basemap:getChildByName("btn_one")
    local btn_ten = image_basemap:getChildByName("btn_ten")
    local ui_cardIcon = image_basemap:getChildByName("image_warrior")
    local ui_qualityBgBar = ui_cardIcon:getChildByName("image_info")
    local ui_name = ui_qualityBgBar:getChildByName("text_name")
    local ui_level = ui_qualityBgBar:getChildByName("text_lv")
    local ui_titleImage = ui_cardIcon:getChildByName("image_before")
    local ui_titleName = ui_titleImage:getChildByName("text_before")

    local instPlayerCardData = net.InstPlayerCard[tostring(userData.InstPlayerCard_id)]
	local dictCardData = DictCard[tostring(instPlayerCardData.int["3"])]
	local titleDetailId = instPlayerCardData.int["6"] --详细称号ID
	local cardLv = instPlayerCardData.int["9"] --卡牌等级
	local qualityId = instPlayerCardData.int["4"] --卡牌品阶ID
	local starLevelId = instPlayerCardData.int["5"] --卡牌星级ID
	local useTalentValue = instPlayerCardData.int["11"] --卡牌当前潜力值
    local isAwake = instPlayerCardData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒
    local trainDatas = instPlayerCardData.string["20"] --培养进度  格式：属性Id_数值;
	local dictTitleDetailData = DictTitleDetail[tostring(titleDetailId)] --详细称号字典表
	local nextDictTitleDetailData = DictTitleDetail[tostring(titleDetailId + 1)] --下一阶详细称号字典表
	-- if not nextDictTitleDetailData then
	-- 	cclog("ERROR: ========>>> 已经达到了最高境界啦！~")
	-- 	return
	-- end

    ui_cardIcon:loadTexture("image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId)].fileName)
    ui_qualityBgBar:loadTexture(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small, true))
    ui_name:setString((isAwake == 1 and Lang.ui_card_jingjie_n5 or "") .. dictCardData.name)
    ui_level:setString("LV " .. cardLv)
    ui_titleImage:loadTexture(utils.getTitleQualityImage(DictTitle[tostring(dictTitleDetailData.titleId)]))
    ui_titleName:setString(dictTitleDetailData.description)

    local ui_propPanel = image_basemap:getChildByName("image_base_term")
    local ui_fightValue = ui_propPanel:getChildByName("image_fighting"):getChildByName("label_fighting_number")

    ui_fightValue:setString(tostring(utils.getFightValue()))

    local ui_bloodBg = ui_propPanel:getChildByName("bar_blood_base") --生命
    local ui_wAttackBg = ui_propPanel:getChildByName("bar_attack_gas_base") --物攻
    local ui_wDefenseBg = ui_propPanel:getChildByName("bar_defense_gas_base") --物防
    local ui_fAttackBg = ui_propPanel:getChildByName("bar_attack_soul_base") --法攻
    local ui_fDefenseBg = ui_propPanel:getChildByName("bar_defense_soul_base") --法防

    local ui_bloodBar = ui_bloodBg:getChildByName("bar_blood")
    local ui_wAttackBar = ui_wAttackBg:getChildByName("bar_attack_gas")
    local ui_wDefenseBar = ui_wDefenseBg:getChildByName("bar_defense_gas")
    local ui_fAttackBar = ui_fAttackBg:getChildByName("bar_attack_soul")
    local ui_fDefenseBar = ui_fDefenseBg:getChildByName("bar_defense_soul")

    local _curTrainValues = {}
    local attribute = getAttributes(cardLv, qualityId, starLevelId, dictCardData)
	for tddKey, tddObj in pairs(DictTitleDetail) do
		if titleDetailId >= tddObj.id then
			local _tempData = utils.stringSplit(tddObj.effects, ";")
			for key, obj in pairs(_tempData) do
				local _fightPropData = utils.stringSplit(obj, "_") --[1]:fightPropId, [2]:value
				local _fightPropId, _value = tonumber(_fightPropData[1]), tonumber(_fightPropData[2])
				attribute[_fightPropId] = attribute[_fightPropId] + _value
                _curTrainValues[_fightPropId] = 0
			end
            if titleDetailId ~= tddObj.id then
                local _tempTrainData = utils.stringSplit(tddObj.train, ";")
                for key, obj in pairs(_tempTrainData) do
                    local _fightPropData = utils.stringSplit(obj, "_") --[1]:fightPropId, [3]:value
                    local _fightPropId, _value = tonumber(_fightPropData[1]), tonumber(_fightPropData[3])
				    attribute[_fightPropId] = attribute[_fightPropId] + _value
                end
            end
        end
	end
    
    local _trainDatas = utils.stringSplit(trainDatas, ";")
    for key, obj in pairs(_trainDatas) do
        local _fightPropData = utils.stringSplit(obj, "_") --[1]:fightPropId, [2]:value
        local _fightPropId, _value = tonumber(_fightPropData[1]), tonumber(_fightPropData[2])
        attribute[_fightPropId] = attribute[_fightPropId] + _value
        _curTrainValues[_fightPropId] = _value
    end

    local _maxTrainValues = {}
    local _trains = utils.stringSplit(dictTitleDetailData.train, ";")
    for key, obj in pairs(_trains) do
        local _fightPropData = utils.stringSplit(obj, "_") --[1]:fightPropId, [3]:value
        local _fightPropId, _value = tonumber(_fightPropData[1]), tonumber(_fightPropData[3])
		_maxTrainValues[_fightPropId] = _value
    end

    ui_bloodBg:getChildByName("text_blood_before"):setString(tostring(attribute[StaticFightProp.blood]))
    ui_wAttackBg:getChildByName("text_attack_gas_before"):setString(tostring(attribute[StaticFightProp.wAttack]))
    ui_wDefenseBg:getChildByName("text_defense_gas_before"):setString(tostring(attribute[StaticFightProp.wDefense]))
    ui_fAttackBg:getChildByName("text_attack_soul_before"):setString(tostring(attribute[StaticFightProp.fAttack]))
    ui_fDefenseBg:getChildByName("text_defense_soul_before"):setString(tostring(attribute[StaticFightProp.fDefense]))

    ui_bloodBg:getChildByName("text_blood_add"):setString("")
    ui_wAttackBg:getChildByName("text_attack_gas_add"):setString("")
    ui_wDefenseBg:getChildByName("text_defense_gas_add"):setString("")
    ui_fAttackBg:getChildByName("text_attack_soul_add"):setString("")
    ui_fDefenseBg:getChildByName("text_defense_soul_add"):setString("")
    if _prevTrainValues[StaticFightProp.blood] and _curTrainValues[StaticFightProp.blood] - _prevTrainValues[StaticFightProp.blood] > 0 then
        ui_bloodBg:getChildByName("text_blood_add"):setString("+" .. _curTrainValues[StaticFightProp.blood] - _prevTrainValues[StaticFightProp.blood])
    end
    if _prevTrainValues[StaticFightProp.wAttack] and _curTrainValues[StaticFightProp.wAttack] - _prevTrainValues[StaticFightProp.wAttack] > 0 then
        ui_wAttackBg:getChildByName("text_attack_gas_add"):setString("+" .. _curTrainValues[StaticFightProp.wAttack] - _prevTrainValues[StaticFightProp.wAttack])
    end
    if _prevTrainValues[StaticFightProp.wDefense] and _curTrainValues[StaticFightProp.wDefense] - _prevTrainValues[StaticFightProp.wDefense] > 0 then
        ui_wDefenseBg:getChildByName("text_defense_gas_add"):setString("+" .. _curTrainValues[StaticFightProp.wDefense] - _prevTrainValues[StaticFightProp.wDefense])
    end
    if _prevTrainValues[StaticFightProp.fAttack] and _curTrainValues[StaticFightProp.fAttack] - _prevTrainValues[StaticFightProp.fAttack] > 0 then
        ui_fAttackBg:getChildByName("text_attack_soul_add"):setString("+" .. _curTrainValues[StaticFightProp.fAttack] - _prevTrainValues[StaticFightProp.fAttack])
    end
    if _prevTrainValues[StaticFightProp.fDefense] and _curTrainValues[StaticFightProp.fDefense] - _prevTrainValues[StaticFightProp.fDefense] > 0 then
        ui_fDefenseBg:getChildByName("text_defense_soul_add"):setString("+" .. _curTrainValues[StaticFightProp.fDefense] - _prevTrainValues[StaticFightProp.fDefense])
    end
    for key, obj in pairs(_curTrainValues) do
        _prevTrainValues[key] = obj
    end

    ui_bloodBar:setPercent(utils.getPercent(_curTrainValues[StaticFightProp.blood], _maxTrainValues[StaticFightProp.blood]))
    ui_wAttackBar:setPercent(utils.getPercent(_curTrainValues[StaticFightProp.wAttack], _maxTrainValues[StaticFightProp.wAttack]))
    ui_wDefenseBar:setPercent(utils.getPercent(_curTrainValues[StaticFightProp.wDefense], _maxTrainValues[StaticFightProp.wDefense]))
    ui_fAttackBar:setPercent(utils.getPercent(_curTrainValues[StaticFightProp.fAttack], _maxTrainValues[StaticFightProp.fAttack]))
    ui_fDefenseBar:setPercent(utils.getPercent(_curTrainValues[StaticFightProp.fDefense], _maxTrainValues[StaticFightProp.fDefense]))

    ui_bloodBar:getChildByName("text_bar_blood"):setString(_curTrainValues[StaticFightProp.blood] .. "/" .. _maxTrainValues[StaticFightProp.blood])
    ui_wAttackBar:getChildByName("text_bar_blood"):setString(_curTrainValues[StaticFightProp.wAttack] .. "/" .. _maxTrainValues[StaticFightProp.wAttack])
    ui_wDefenseBar:getChildByName("text_bar_defense_soul"):setString(_curTrainValues[StaticFightProp.wDefense] .. "/" .. _maxTrainValues[StaticFightProp.wDefense])
    ui_fAttackBar:getChildByName("text_bar_attack_soul"):setString(_curTrainValues[StaticFightProp.fAttack] .. "/" .. _maxTrainValues[StaticFightProp.fAttack])
    ui_fDefenseBar:getChildByName("text_bar_defense_soul"):setString(_curTrainValues[StaticFightProp.fDefense] .. "/" .. _maxTrainValues[StaticFightProp.fDefense])

    local setLoadingBarTexture = function(_loadingBar)
        if _loadingBar:getPercent() >= 100 then
            _loadingBar:loadTexture("ui/bb_loading_gold.png")
        else
            _loadingBar:loadTexture("ui/bb_loading_blue.png")
        end
    end
    setLoadingBarTexture(ui_bloodBar)
    setLoadingBarTexture(ui_wAttackBar)
    setLoadingBarTexture(ui_wDefenseBar)
    setLoadingBarTexture(ui_fAttackBar)
    setLoadingBarTexture(ui_fDefenseBar)

    if ui_bloodBar:getPercent() >= 100 and ui_wAttackBar:getPercent() >= 100 and ui_wDefenseBar:getPercent() >= 100 
       and ui_fAttackBar:getPercent() >= 100 and ui_fDefenseBar:getPercent() >= 100 then
        btn_break:setVisible(true)
        btn_one:setBright(false)
        btn_ten:setBright(false)
        if _btnActionFlag then
            btn_break:setScale(0)
            btn_break:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5, 1), cc.CallFunc:create(function()
                btn_break:runAction(cc.RepeatForever:create(cc.Sequence:create(
                    cc.MoveBy:create(0.2, cc.p(0, 6)),
                    cc.MoveBy:create(0.2, cc.p(0, -6)),
                    cc.MoveBy:create(0.2, cc.p(0, 6)),
                    cc.MoveBy:create(0.2, cc.p(0, -6)),
                    cc.DelayTime:create(2)
                )))
            end)))
        else
            btn_break:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.MoveBy:create(0.2, cc.p(0, 6)),
                cc.MoveBy:create(0.2, cc.p(0, -6)),
                cc.MoveBy:create(0.2, cc.p(0, 6)),
                cc.MoveBy:create(0.2, cc.p(0, -6)),
                cc.DelayTime:create(2)
            )))
        end
    else
        btn_break:setVisible(false)
        btn_one:setBright(true)
        btn_ten:setBright(true)
    end
end

function UICardJingjieN.free()
    userData = nil
    _prevTrainValues = {}
    if _isFlushWidget then
        UIManager.flushWidget(UICardInfo)
	    UIManager.flushWidget(UILineup)
    end
    _isFlushWidget = false
end

function UICardJingjieN.show(_tableParams, _isReplace)
    userData = _tableParams
    if _isReplace then
        UIManager.replaceScene("ui_card_jingjie_n")
    else
        UIManager.pushScene("ui_card_jingjie_n")
    end
end
