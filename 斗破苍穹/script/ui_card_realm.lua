require"Lang"
UICardRealm = {}

local btn_bottomLeft = nil --底部左边按钮
local btn_bottomRight = nil --底部右边按钮

local ui_practiceProperty = nil --修炼属性
local ui_fightValue = nil --战斗力值
local ui_cardQuality = nil
local ui_cardName = nil
local ui_cardIcon = nil
local ui_cardLevel = nil
local ui_cardLabel1, ui_cardLabel2, ui_cardLabel3 = nil, nil, nil
local ui_practiceInfo = nil --修炼信息
local ui_checkbox1, ui_checkbox2, ui_checkbox3, ui_checkbox4 = nil, nil, nil, nil

local _propPanelPosX = nil --属性面板的Y坐标
local _isReset = true
local _param = nil
local _curSelectedTrainPropId = nil
local _curTimes = nil
local _curSelectedTrainType = 0 --当前选择的修炼类型  1-普通修炼，2-天墓修炼
local _needMedicineCount = 0 --当前修炼所需的菩提子个数
local _generalGoldCount = 0 --普通修炼所需的元宝个数
local _advancedGoldCount = 0 --天墓修炼所需的元宝个数
local _advancedPotentialCount = 0 --天墓修炼所消耗的潜力点数
local _curPotentialCount = 0 --当前可分配潜力点
local _curMedicineCount = 0 --当前菩提子

local _curState = 0 -- 0:退出、修炼状态, 1:放弃、保留状态

local function netCallbackFunc(data)
	local protoCode = tonumber(data.header)
	if protoCode == StaticMsgRule.train then
		_curState = 1
		local image_base_title = ui_practiceProperty:getChildByName("image_base_title")
		local text_blood_add_info = image_base_title:getChildByName("text_blood_add_info")
		local text_attack_gas_add_info = image_base_title:getChildByName("text_attack_gas_add_info")
		local text_defense_gas_add_info = image_base_title:getChildByName("text_defense_gas_add_info")
		local text_attack_soul_add_info = image_base_title:getChildByName("text_attack_soul_add_info")
		local text_defense_soul_add_info = image_base_title:getChildByName("text_defense_soul_add_info")
		
		local talentValue = 0
		local msgData = data.msgdata.message
		for key, obj in pairs(msgData) do
			local fightPropId = obj.int["1"]
			local value = obj.int["2"]
			local _color = (value >= 0 and cc.c3b(0, 255, 0) or cc.c3b(255, 0, 0))
			-- local addText = (value >= 0 and "+" or "") .. value
			local addText_info = string.format("%s", (value >= 0 and "+" or "") .. value * utils.FightValueFactor[fightPropId])
			if fightPropId == StaticFightProp.blood then --生命
				text_blood_add_info:setVisible(true)
				text_blood_add_info:setString(addText_info)
				text_blood_add_info:setTextColor(_color)
			elseif fightPropId == StaticFightProp.wAttack then --斗气攻击
				text_attack_gas_add_info:setVisible(true)
				text_attack_gas_add_info:setString(addText_info)
				text_attack_gas_add_info:setTextColor(_color)
			elseif fightPropId == StaticFightProp.fAttack then --灵魂攻击
				text_attack_soul_add_info:setVisible(true)
				text_attack_soul_add_info:setString(addText_info)
				text_attack_soul_add_info:setTextColor(_color)
			elseif fightPropId == StaticFightProp.wDefense then --斗气防御
				text_defense_gas_add_info:setVisible(true)
				text_defense_gas_add_info:setString(addText_info)
				text_defense_gas_add_info:setTextColor(_color)
			elseif fightPropId == StaticFightProp.fDefense then --灵魂防御
				text_defense_soul_add_info:setVisible(true)
				text_defense_soul_add_info:setString(addText_info)
				text_defense_soul_add_info:setTextColor(_color)
			end
			talentValue = talentValue + value
		end
        --[[  隐藏战斗力增值
        local _addFightValue = _advancedPotentialCount * _curTimes
        if _curPotentialCount < _addFightValue then
            _addFightValue = _curPotentialCount
        end
        ui_fightValue:getParent():getChildByName("text_zhan"):setString("+".._addFightValue)
        --]]
		btn_bottomLeft:setTitleText(Lang.ui_card_realm1)
		btn_bottomRight:setTitleText(Lang.ui_card_realm2)
		_curMedicineCount = utils.getThingCount(StaticThing.linden)
		ccui.Helper:seekNodeByName(ui_practiceInfo, "text_medicine"):setString(Lang.ui_card_realm3 .. _curMedicineCount)
		
--		ui_checkbox1:setTouchEnabled(false)
--		ui_checkbox2:setTouchEnabled(false)
		ui_checkbox3:setTouchEnabled(false)
		ui_checkbox4:setTouchEnabled(false)
		
		if _isReset then
		ui_practiceProperty:getChildByName("image_prop_effect"):setVisible(true)
		ui_practiceProperty:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(ui_practiceProperty:getPositionX() + ui_practiceProperty:getContentSize().width - 30, ui_practiceProperty:getPositionY()))))
--		image_base_title:setPositionX(image_base_title:getPositionX() - image_base_title:getContentSize().width / 2)
		image_base_title:runAction(cc.Sequence:create(cc.MoveTo:create(0.3, cc.p(image_base_title:getPositionX() - image_base_title:getContentSize().width / 2, image_base_title:getPositionY()))))
		ui_cardIcon:runAction(cc.Sequence:create(cc.TintTo:create(0.3,120,120,120)))
		ui_cardQuality:runAction(cc.Sequence:create(cc.TintTo:create(0.3,120,120,120)))
		end
		_isReset = false
		UIGuidePeople.isGuide(nil,UICardRealm)
	elseif protoCode == StaticMsgRule.trainAccept then
		_isReset = false
		UICardRealm.setup()
		UIManager.flushWidget(UICardInfo)
		UIManager.flushWidget(UILineup)
	end
end

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

local function getFightPropsStr()
    local fightPropsStr = ""
    local image_base_title = ui_practiceProperty:getChildByName("image_base_title")
    fightPropsStr = fightPropsStr .. StaticFightProp.blood .. "_" .. utils.stringSplit(image_base_title:getChildByName("text_blood"):getString(), "：")[2] .. ";"
    fightPropsStr = fightPropsStr .. StaticFightProp.wAttack .. "_" .. utils.stringSplit(image_base_title:getChildByName("text_attack_gas"):getString(), "：")[2] .. ";"
    fightPropsStr = fightPropsStr .. StaticFightProp.wDefense .. "_" .. utils.stringSplit(image_base_title:getChildByName("text_defense_gas"):getString(), "：")[2] .. ";"
    fightPropsStr = fightPropsStr .. StaticFightProp.fAttack .. "_" .. utils.stringSplit(image_base_title:getChildByName("text_attack_soul"):getString(), "：")[2] .. ";"
    fightPropsStr = fightPropsStr .. StaticFightProp.fDefense .. "_" .. utils.stringSplit(image_base_title:getChildByName("text_defense_soul"):getString(), "：")[2]
    return fightPropsStr
end

local function initPracticeInfo()
	local instPlayerCardData = nil
	local dictCardData, dictTitleDetailData = nil, nil
	local useTalentValue, qualityId, starLevelId, cardLv = 0, 0, 0, 0
	if _param then
		instPlayerCardData = net.InstPlayerCard[tostring(_param)]
		dictCardData = DictCard[tostring(instPlayerCardData.int["3"])]
		local titleDetailId = instPlayerCardData.int["6"] --详细称号ID
		cardLv = instPlayerCardData.int["9"] --卡牌等级
		qualityId = instPlayerCardData.int["4"] --卡牌品阶ID
		starLevelId = instPlayerCardData.int["5"] --卡牌星级ID
		useTalentValue = instPlayerCardData.int["11"] --卡牌当前潜力值
		dictTitleDetailData = DictTitleDetail[tostring(titleDetailId)] --详细称号字典表
		_curPotentialCount = instPlayerCardData.int["14"] --卡牌潜力点
        local _isAwake = instPlayerCardData.int["18"]
		ui_cardQuality:loadTexture(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small, true))
		ui_cardIcon:loadTexture("image/" .. DictUI[tostring(_isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId)].fileName)
		ui_cardName:setString((_isAwake == 1 and Lang.ui_card_realm4 or "") .. dictCardData.name)
		ui_cardLevel:setString("LV  " .. cardLv)
		ui_cardLabel1:setString(DictCardType[tostring(dictCardData.cardTypeId)].name)
		ui_cardLabel2:setString(DictFightType[tostring(dictCardData.fightTypeId)].name)
		if string.len(dictCardData.nickname) > 0 then
			ui_cardLabel3:setString(Lang.ui_card_realm5..dictCardData.nickname)
			ui_cardLabel3:getParent():setVisible(true)
		else
			ui_cardLabel3:getParent():setVisible(false)
		end
		
		_needMedicineCount = DictSysConfig[tostring(StaticSysConfig.trainLinden)].value
--		ccui.Helper:seekNodeByName(ui_checkbox1, "textnumber"):setString(tostring(_needMedicineCount))--修炼
--		ccui.Helper:seekNodeByName(ui_checkbox2, "text_number"):setString(tostring(_needMedicineCount * 10))--修炼十次
		ccui.Helper:seekNodeByName(ui_checkbox3, "text_number"):setString(tostring(_needMedicineCount))--天墓修炼菩提子
		ccui.Helper:seekNodeByName(ui_checkbox4, "text_number"):setString(tostring(_needMedicineCount * 10))--天墓修炼十次菩提子
	end
	if instPlayerCardData then
		--卡牌称号
		local image_base_title = ui_practiceProperty:getChildByName("image_base_title")
		local ui_cardTitle = image_base_title:getChildByName("text_title")
		ui_cardTitle:setAnchorPoint(cc.p(0.5, 0.5))
		ui_cardTitle:setString(dictTitleDetailData.description)
		-- ui_cardTitle:setPositionX(image_base_title:getChildByName("image_realm"):getRightBoundary() + ui_cardTitle:getContentSize().width / 2)
		
		local attribute = getAttributes(cardLv, qualityId, starLevelId, dictCardData)
		for tddKey, tddObj in pairs(DictTitleDetail) do
			if dictTitleDetailData.id >= tddObj.id then
				local _tempData = utils.stringSplit(tddObj.effects, ";")
				for key, obj in pairs(_tempData) do
					local _fightPropData = utils.stringSplit(obj, "_") --[1]:fightPropId, [2]:value
					local _fightPropId, _value = tonumber(_fightPropData[1]), tonumber(_fightPropData[2])
					attribute[_fightPropId] = attribute[_fightPropId] + _value
				end
			end
		end
		-- for key, obj in pairs(DictFightProp) do
		-- 	if dp.DictFightProp[obj.id] then
		-- 		attribute[obj.id] = attribute[obj.id] / dp.DictFightProp[obj.id].value
		-- 	end
		-- end
		if net.InstPlayerTrain then
			for trainKey, trainObj in pairs(net.InstPlayerTrain) do
				if instPlayerCardData.int["1"] == trainObj.int["3"] then
					local _fightPropId = trainObj.int["4"]
					local _value = trainObj.int["5"]
					attribute[_fightPropId] = attribute[_fightPropId] + _value * utils.FightValueFactor[_fightPropId]
				end
			end
		end
        ui_fightValue:getParent():getChildByName("text_zhan"):setString("")
        ui_fightValue:setString(tostring(utils.getFightValue()))
		image_base_title:getChildByName("text_blood"):setString(DictFightProp[tostring(StaticFightProp.blood)].name .. "：" .. math.floor(attribute[StaticFightProp.blood]))
		image_base_title:getChildByName("text_attack_gas"):setString(DictFightProp[tostring(StaticFightProp.wAttack)].name .. "：" .. math.floor(attribute[StaticFightProp.wAttack]))
		image_base_title:getChildByName("text_defense_gas"):setString(DictFightProp[tostring(StaticFightProp.wDefense)].name .. "：" .. math.floor(attribute[StaticFightProp.wDefense]))
		image_base_title:getChildByName("text_attack_soul"):setString(DictFightProp[tostring(StaticFightProp.fAttack)].name .. "：" .. math.floor(attribute[StaticFightProp.fAttack]))
		image_base_title:getChildByName("text_defense_soul"):setString(DictFightProp[tostring(StaticFightProp.fDefense)].name .. "：" .. math.floor(attribute[StaticFightProp.fDefense]))
		
		image_base_title:getChildByName("text_blood_add_info"):setVisible(false)
		image_base_title:getChildByName("text_attack_gas_add_info"):setVisible(false)
		image_base_title:getChildByName("text_defense_gas_add_info"):setVisible(false)
		image_base_title:getChildByName("text_attack_soul_add_info"):setVisible(false)
		image_base_title:getChildByName("text_defense_soul_add_info"):setVisible(false)
		
		ccui.Helper:seekNodeByName(ui_practiceInfo, "text_potential"):setString(Lang.ui_card_realm6 .. _curPotentialCount)
		_curMedicineCount = utils.getThingCount(StaticThing.linden)
		ccui.Helper:seekNodeByName(ui_practiceInfo, "text_medicine"):setString(Lang.ui_card_realm7 .. _curMedicineCount)
		
--		ui_checkbox1:setSelected(false)
--		ui_checkbox2:setSelected(false)
		ui_checkbox3:setSelected(false)
		ui_checkbox4:setSelected(false)
		if _curSelectedTrainType == 1 then
--			if _curTimes == 1 then
--				ui_checkbox1:setSelected(true)
--			elseif _curTimes == 10 then
--				ui_checkbox2:setSelected(true)
--			end
		elseif _curSelectedTrainType == 2 then
			if _curTimes == 1 then
				ui_checkbox3:setSelected(true)
			elseif _curTimes == 10 then
				ui_checkbox4:setSelected(true)
			end
		end
	end
end

local function onPracticeEvent()
	if not ui_cardIcon:isVisible() then
		UIManager.showToast(Lang.ui_card_realm8)
		return
	end

	if _curSelectedTrainPropId == nil or _curTimes == nil then
		UIManager.showToast(Lang.ui_card_realm9)
		return
	end
	
	if _curSelectedTrainPropId == -1 then
		--UIManager.showToast("DictTrainProp字典数据出错！")
		cclog("ERROR: ------------>>>  DictTrainProp字典数据出错！")
	else
		local sendData = nil
		if _curState == 0 then
			if _curSelectedTrainType == 1 then
				if net.InstPlayer.int["5"] < _generalGoldCount * _curTimes then
					UIManager.showToast(Lang.ui_card_realm10)
					return
				end
				if _curMedicineCount < _needMedicineCount * _curTimes then
					UIManager.showToast(Lang.ui_card_realm11)
					return
				end
			elseif _curSelectedTrainType == 2 then
--				if net.InstPlayer.int["5"] < _advancedGoldCount * _curTimes then
--					UIManager.showToast("元宝不足！")
--					return
--				end
				if _curMedicineCount < _needMedicineCount * _curTimes then
					cclog("~~~~~~~~~~~putizibuzu")
					UIManager.showToast(Lang.ui_card_realm12)
					return
				end
			end
		
            if UIGuidePeople.levelStep == "18_4" then
                sendData = {
				    header = StaticMsgRule.train,
				    msgdata = {
					    int = {
						    instPlayerCardId = _param,
						    trainPropId = _curSelectedTrainPropId,
						    times = _curTimes
					    },
                        string = {
                            fightProps = getFightPropsStr(),
                            step = "18_5"
                        }
				    }
			    }
            elseif UIGuidePeople.levelStep == "18_7" then
                sendData = {
				    header = StaticMsgRule.train,
				    msgdata = {
					    int = {
						    instPlayerCardId = _param,
						    trainPropId = _curSelectedTrainPropId,
						    times = _curTimes
					    },
                        string = {
                            fightProps = getFightPropsStr(),
                            step = "18_8"
                        }
				    }
			    }
            else 
                sendData = {
				    header = StaticMsgRule.train,
				    msgdata = {
					    int = {
						    instPlayerCardId = _param,
						    trainPropId = _curSelectedTrainPropId,
						    times = _curTimes
					    },
                        string = {
                            fightProps = getFightPropsStr(),
                        }
				    }
			    }
            end
		else
            if UIGuidePeople.levelStep == "20_5" then
                sendData = {
				    header = StaticMsgRule.trainAccept,
				    msgdata = {
					    int = {
						    instPlayerCardId = _param,
					    },
                        string = {
                            step = "20_6"
                        }
				    }
			    }
--            elseif UIGuidePeople.levelStep =="18_8" then
--                sendData = {
--				    header = StaticMsgRule.trainAccept,
--				    msgdata = {
--					    int = {
--						    instPlayerCardId = _param,
--					    },
--                        string = {
--                            step = "18_9"
--                        }
--				    }
--			    }
            else
                sendData = {
				    header = StaticMsgRule.trainAccept,
				    msgdata = {
					    int = {
						    instPlayerCardId = _param,
					    }
				    }
			    }
            end
		end
		UIManager.showLoading()
		netSendPackage(sendData, netCallbackFunc)
	end
end

function UICardRealm.init()
	local btn_close = ccui.Helper:seekNodeByName(UICardRealm.Widget, "btn_close")
	btn_bottomLeft = ccui.Helper:seekNodeByName(UICardRealm.Widget, "btn_exit")
	btn_bottomRight = ccui.Helper:seekNodeByName(UICardRealm.Widget, "btn_practice")
	
	local cardInfoRoot = ccui.Helper:seekNodeByName(UICardRealm.Widget, "image_basecolour")
	ui_practiceProperty = cardInfoRoot:getChildByName("image_base_property")
	ui_cardQuality = cardInfoRoot:getChildByName("image_base_name")
	ui_cardName = ui_cardQuality:getChildByName("text_name")
	ui_cardLevel = ui_cardQuality:getChildByName("text_lv")
	ui_cardIcon = cardInfoRoot:getChildByName("panel_card"):getChildByName("image_card")
	ui_cardLabel1 = cardInfoRoot:getChildByName("image_tag1"):getChildByName("text_tag1")
	ui_cardLabel2 = cardInfoRoot:getChildByName("image_tag2"):getChildByName("text_tag2")
	ui_cardLabel3 = cardInfoRoot:getChildByName("image_tag3"):getChildByName("text_tag3")
    local btn_help = cardInfoRoot:getChildByName("btn_help")
	
	_propPanelPosX = ui_practiceProperty:getPositionX()
	
	ui_practiceInfo = ccui.Helper:seekNodeByName(UICardRealm.Widget, "image_base_di")
	ui_fightValue = ccui.Helper:seekNodeByName(ui_practiceInfo, "label_zhan")

	btn_close:setPressedActionEnabled(true)
	btn_bottomLeft:setPressedActionEnabled(true)
	btn_bottomRight:setPressedActionEnabled(true)
	btn_help:setPressedActionEnabled(true)
	
	local function onTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			if sender == btn_close then
				UIManager.popScene()
			elseif sender == btn_bottomLeft then
				if _curState == 1 then
					_isReset = false
					UICardRealm.setup()
				else
					if UIGuidePeople.levelStep then 
						UIManager.popAllScene()
					else 
						UIManager.popScene()
					end
				end
			elseif sender == btn_bottomRight then
				onPracticeEvent()
            elseif sender == btn_help then
                UIAllianceHelp.show({titleName=Lang.ui_card_realm13,type=7})
			end
		end
	end
	btn_close:addTouchEventListener(onTouchEvent)
	btn_bottomLeft:addTouchEventListener(onTouchEvent)
	btn_bottomRight:addTouchEventListener(onTouchEvent)
	btn_help:addTouchEventListener(onTouchEvent)
	
--	ui_checkbox1 = ccui.Helper:seekNodeByName(ui_practiceInfo, "checkbox_practice")
--	ui_checkbox2 = ccui.Helper:seekNodeByName(ui_practiceInfo, "checkbox_practice_ten")
	ui_checkbox3 = ccui.Helper:seekNodeByName(ui_practiceInfo, "checkbox_practice_tianmu")
	ui_checkbox4 = ccui.Helper:seekNodeByName(ui_practiceInfo, "checkbox_practice_tianmu_ten")
--	ui_checkbox1:setTag(-1)
--	ui_checkbox2:setTag(-1)
	ui_checkbox3:setTag(-1)
	ui_checkbox4:setTag(-1)
	local function checkboxEvent(sender, eventType)
		if eventType == ccui.CheckBoxEventType.selected then
--			ui_checkbox1:setSelected(false)
--			ui_checkbox2:setSelected(false)
			ui_checkbox3:setSelected(false)
			ui_checkbox4:setSelected(false)
			sender:setSelected(true)
			_curSelectedTrainPropId = sender:getTag()
			if sender == ui_checkbox1 then
				_curTimes = 1
				_curSelectedTrainType = 1 
			elseif sender == ui_checkbox3 then
				_curTimes = 1
				_curSelectedTrainType = 2
			elseif sender == ui_checkbox2 then 
				_curTimes = 10
				_curSelectedTrainType = 1
			elseif sender == ui_checkbox4 then
				_curTimes = 10
				_curSelectedTrainType = 2
				UIGuidePeople.isGuide(nil,UICardRealm)
			end
		elseif eventType == ccui.CheckBoxEventType.unselected then
			_curSelectedTrainPropId = nil
			_curTimes = nil
		end
	end
--	ui_checkbox1:addEventListener(checkboxEvent)
--	ui_checkbox2:addEventListener(checkboxEvent)
	ui_checkbox3:addEventListener(checkboxEvent)
	ui_checkbox4:addEventListener(checkboxEvent)
	
	for key, obj in pairs(DictTrainProp) do
		if obj.trainType == 1 then --普通修炼
--			_generalGoldCount = 0
--			ui_checkbox1:setTag(obj.id)
--			ui_checkbox2:setTag(obj.id)
		elseif obj.trainType == 2 then --天幕修炼
			_advancedGoldCount = obj.gold
            _advancedPotentialCount = obj.trainUpLimit
--			local ui_text2 = ccui.Helper:seekNodeByName(ui_checkbox3, "text_number_gold") --天墓修炼元宝
--			ui_text2:setString(tostring(_advancedGoldCount))
--			local ui_text4 = ccui.Helper:seekNodeByName(ui_checkbox4, "text_number_gold") --天墓修炼十次元宝
--			ui_text4:setString(tostring(_advancedGoldCount * 10))
			ui_checkbox3:setTag(obj.id)
			ui_checkbox4:setTag(obj.id)
		end
	end
	_curSelectedTrainPropId = ui_checkbox3:getTag()
	_curTimes = 1
	_curSelectedTrainType = 2
end

function UICardRealm.setup()
	UIGuidePeople.isGuide(nil,UICardRealm)
	_curState = 0
	ui_practiceInfo:setPositionX(UIManager.screenSize.width / 2)
	if _isReset then
	ui_cardIcon:setColor(cc.c3b(255,255,255))
	ui_cardQuality:setColor(cc.c3b(255,255,255))
	ui_practiceProperty:getChildByName("image_prop_effect"):setVisible(false)
	ui_practiceProperty:getChildByName("image_base_title"):setPositionX(ui_practiceProperty:getContentSize().width / 2)
	ui_practiceProperty:setPositionX(_propPanelPosX)
	end
	ui_practiceProperty:setVisible(true)
	btn_bottomLeft:setTitleText(Lang.ui_card_realm14)
	btn_bottomRight:setTitleText(Lang.ui_card_realm15)
--	ui_checkbox1:setTouchEnabled(true)
--	ui_checkbox2:setTouchEnabled(true)
	ui_checkbox3:setTouchEnabled(true)
	ui_checkbox4:setTouchEnabled(true)
	initPracticeInfo()
end

function UICardRealm.setUIParam(param)
	_param = param
end

function UICardRealm.free()
	UIGuidePeople.isGuide(nil,UICardRealm)
	_param = nil
	_curSelectedTrainPropId = ui_checkbox3:getTag()
	_curTimes = 1
	_curSelectedTrainType = 2
	_isReset = true
end
