require"Lang"
UICardJingJie = {}

local userData = nil

local _attribute = nil
local _nextAttribute = nil
local _isUpgrade = nil
local _isCanJinJie = nil

local function numberActionN(_item , _callback )
   _item:runAction( cc.Sequence:create( cc.ScaleTo:create(0.2 , 1.4 ) , cc.ScaleTo:create( 0.2 , 1.0 ) , cc.CallFunc:create(function()
            
			    if _callback and type(_callback) == "function" then
				    _callback()
			    end
            end)) ) 
end
local function numberAction(_item,_tempAdd,_value,_callback)
	_item:setString(tonumber(_item:getString()) + _tempAdd)
	_item:runAction(cc.Sequence:create(cc.DelayTime:create(0.01) , cc.CallFunc:create(function()
		if tonumber(_item:getString()) < _value then
			numberAction(_item,_tempAdd,_value,_callback)
		else
            _item:setString(_value)

          --  _item:runAction( cc.Sequence:create( cc.ScaleTo:create(0.1 , 1.2 ) , cc.ScaleTo:create( 0.1 , 1.0 ) , cc.CallFunc:create(function()
            
			    if _callback and type(_callback) == "function" then
				    _callback()
			    end
           -- end)) ) 
			
		end
	end)))
end

local function getPropNum(_index, ui_cardIcon, _propValues)
	if _index <= 5 then
		local _panelImg, _numImg = "ui/ui_anim2Effect10.png", "ui/ui_anim2Effect8.png"
		if _index == 1 then
			_panelImg = "ui/ui_anim2Effect10.png"
			_numImg = "ui/ui_anim2Effect8.png"
		elseif _index >= 2 and _index <= 3 then
			_panelImg = "ui/ui_anim2Effect11.png"
			_numImg = "ui/ui_anim2Effect6.png"
		else
			_panelImg = "ui/ui_anim2Effect9.png"
			_numImg = "ui/ui_anim2Effect7.png"
		end
		local panel = ccui.ImageView:create(_panelImg)
		local propImg = ccui.ImageView:create("ui/ui_anim2Effect".._index..".png")
		propImg:setAnchorPoint(1, 0.5)
		propImg:setPosition(0, panel:getContentSize().height / 2)
		panel:addChild(propImg)
		local num = ccui.TextAtlas:create()
		num:setProperty("0123456789", _numImg, 25, 36, "0")
		num:setAnchorPoint(0, 0.5)
		num:setString(tostring(_propValues[_index]))
		num:setPosition(panel:getContentSize().width, panel:getContentSize().height / 2)
		panel:addChild(num)

		-- panel:setPosition(ui_cardIcon:getContentSize().width / 2 + 20, ui_cardIcon:getContentSize().height / 2 - 100)
		panel:setPosition(ui_cardIcon:getContentSize().width / 2 + 20, ui_cardIcon:getContentSize().height / 2 - 200 + _index * (panel:getContentSize().height + 5))
		ui_cardIcon:addChild(panel)
		-- _index = _index + 1
		panel:setScale(0.8)
		-- panel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.1), cc.MoveBy:create(0.3, cc.p(0, 60)), cc.Spawn:create(cc.MoveBy:create(0.3,cc.p(0, 60)), cc.ScaleTo:create(0.3, 0.9), cc.FadeTo:create(0.3, 0)), cc.CallFunc:create(function()
		panel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.1), cc.MoveBy:create(0.3, cc.p(0, 60)), cc.Spawn:create(cc.MoveBy:create(0.8,cc.p(0, 60)), cc.FadeTo:create(0.8, 0)), cc.CallFunc:create(function()
			panel:removeAllChildren()
			panel:removeFromParent()
			if _index <= 5 then
			--			getPropNum(_index + 1, ui_cardIcon, _propValues)
			else
				_index = 1
			end
		end)))
	end

	if _index > 5 then
		
	else
		getPropNum(_index + 1, ui_cardIcon, _propValues)
	end
end

local function netCallbackFunc(msgData)
	local childs = UIManager.uiLayer:getChildren()
	for key, obj in pairs(childs) do
		if (not tolua.isnull(obj)) and obj:isEnabled() then
			obj:setEnabled(false)
		end
	end
	local _imageArrow1,_imageArrow2,_imageArrow3,_imageArrow4,_imageArrow5
	local image_basemap = UICardJingJie.Widget:getChildByName("image_basemap")
	local image_base_term = image_basemap:getChildByName("image_base_term")
	local image_info_l_up = image_base_term:getChildByName("image_info_l_up")
	local _tempAddAtts = {}
	for key, obj in pairs(_attribute) do
		_tempAddAtts[key] = (_nextAttribute[key] - obj > 100) and (math.ceil((_nextAttribute[key] - obj) / 100) + 8) or (math.floor((_nextAttribute[key] - obj) / 100) + 3)
	end
	local image_arrow1 = ccui.Helper:seekNodeByName(image_info_l_up, "image_arrow1") --生命
	numberAction(image_arrow1:getChildByName("text_blood_before"), _tempAddAtts[StaticFightProp.blood], _nextAttribute[StaticFightProp.blood], 
		function() _imageArrow1 = true end)
	local image_arrow2 = ccui.Helper:seekNodeByName(image_info_l_up, "image_arrow2") --物攻
	numberAction(image_arrow2:getChildByName("text_attack_gas_before"), _tempAddAtts[StaticFightProp.wAttack], _nextAttribute[StaticFightProp.wAttack], 
		function() _imageArrow2 = true end)
	local image_arrow3 = ccui.Helper:seekNodeByName(image_info_l_up, "image_arrow3") --物防
	numberAction(image_arrow3:getChildByName("text_defense_gas_before"), _tempAddAtts[StaticFightProp.wDefense], _nextAttribute[StaticFightProp.wDefense], 
		function() _imageArrow3 = true end)
	local image_arrow4 = ccui.Helper:seekNodeByName(image_info_l_up, "image_arrow4") --法攻
	numberAction(image_arrow4:getChildByName("text_attack_soul_before"), _tempAddAtts[StaticFightProp.fAttack], _nextAttribute[StaticFightProp.fAttack], 
		function() _imageArrow4 = true end)
	local image_arrow5 = ccui.Helper:seekNodeByName(image_info_l_up, "image_arrow5") --法防
	numberAction(image_arrow5:getChildByName("text_defense_soul_before"), _tempAddAtts[StaticFightProp.fDefense], _nextAttribute[StaticFightProp.fDefense], 
		function() _imageArrow5 = true end)
	local update = nil
	update = function()
		if (_imageArrow1 and _imageArrow2 and _imageArrow3 and _imageArrow4 and _imageArrow5) then

           

			function cacaFunc()
			   local ui_cardIcon = image_base_term:getChildByName("image_warrior")
			local ui_curTitleBgImg = ui_cardIcon:getChildByName("image_before")
			local ui_newTitleBgImg = ui_cardIcon:getChildByName("image_after")
			local ui_tempTitleBgImg = ui_newTitleBgImg:clone()
			local ui_curTitle = ui_curTitleBgImg:getChildByName("text_before")
			local ui_newTitle = ui_newTitleBgImg:getChildByName("text_after")
			ui_tempTitleBgImg:getChildByName("text_after"):setString(ui_curTitle:getString())
			ui_tempTitleBgImg:getChildByName("text_after"):enableOutline(cc.c4b(85,52,19,255),2)
			ui_tempTitleBgImg:setPosition(ui_curTitleBgImg:getPosition())
			ui_curTitleBgImg:getParent():addChild(ui_tempTitleBgImg)
			ui_curTitleBgImg:setPositionY(ui_curTitleBgImg:getPositionY() - ui_curTitleBgImg:getContentSize().height)
			ui_curTitleBgImg:setOpacity(0)
			ui_curTitle:setString(ui_newTitle:getString())
			-- local posY = ui_tempTitleBgImg:getPositionY()
			ui_tempTitleBgImg:runAction(cc.Sequence:create(
				cc.Spawn:create(
					cc.MoveBy:create(0.3, cc.p(0, ui_tempTitleBgImg:getContentSize().height)),
					cc.FadeTo:create(0.3, 0)
				)
				))
            ui_tempTitleBgImg:getChildByName("text_after"):runAction(cc.Sequence:create(cc.FadeTo:create(0.3, 0)))
			ui_curTitleBgImg:runAction(cc.Sequence:create(
				cc.Spawn:create(
				cc.MoveBy:create(0.3, cc.p(0, ui_curTitleBgImg:getContentSize().height)),
				cc.FadeTo:create(0.3, 255)
				), cc.CallFunc:create(function()
				local childs = UIManager.uiLayer:getChildren()
				for key, obj in pairs(childs) do
					if (not tolua.isnull(obj)) and (not obj:isEnabled()) then
						obj:setEnabled(true)
					end
				end
				ui_tempTitleBgImg:removeFromParent()
				ui_tempTitleBgImg = nil
                if not _isUpgrade then
				    UIManager.showToast(Lang.ui_card_jingjie1)
                end
                --如果称号大于等于斗尊
                if net.InstPlayerCard[tostring(userData.InstPlayerCard_id)].int["6"] >= 71 then
                    UICardJingjieN.show({ InstPlayerCard_id = userData.InstPlayerCard_id }, true)
                else
				    UICardJingJie.setup()
                end
				UIManager.flushWidget(UICardInfo)
				UIManager.flushWidget(UILineup)
			end)))
            end
                 numberActionN(image_arrow1:getChildByName("text_blood_before") , cacaFunc )
                 numberActionN(image_arrow2:getChildByName("text_attack_gas_before"))
                 numberActionN(image_arrow3:getChildByName("text_defense_gas_before"))
                 numberActionN(image_arrow4:getChildByName("text_attack_soul_before"))
                 numberActionN(image_arrow5:getChildByName("text_defense_soul_before"))
			
		else
			UICardJingJie.Widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(update)))
		end
	end
	update()
	if _isUpgrade then
        function callBack()
            local _tempAtts = {}
		    _tempAtts[1] = _nextAttribute[StaticFightProp.blood] - _attribute[StaticFightProp.blood]
		    _tempAtts[2] = _nextAttribute[StaticFightProp.wAttack] - _attribute[StaticFightProp.wAttack]
		    _tempAtts[3] = _nextAttribute[StaticFightProp.wDefense] - _attribute[StaticFightProp.wDefense]
		    _tempAtts[4] = _nextAttribute[StaticFightProp.fAttack] - _attribute[StaticFightProp.fAttack]
		    _tempAtts[5] = _nextAttribute[StaticFightProp.fDefense] - _attribute[StaticFightProp.fDefense]
		    getPropNum(1, image_base_term:getChildByName("image_warrior"), _tempAtts)
        end
		
         utils.playArmature(  1 , "ui_anim1_1" , UICardJingJie.Widget , 0 , -160 , callBack )
       
	end
    
	-- UIManager.showToast("突破成功！")
	-- UICardJingJie.setup()
	-- UIManager.flushWidget(UICardInfo)
	-- UIManager.flushWidget(UILineup)
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

function UICardJingJie.init()
	local image_basemap = UICardJingJie.Widget:getChildByName("image_basemap")
	local btn_close = image_basemap:getChildByName("btn_close")
	local btn_break = image_basemap:getChildByName("btn_break")
	btn_close:setPressedActionEnabled(true)
	btn_break:setPressedActionEnabled(true)
	local function onButtonEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == btn_close then
				UIManager.popScene()
                UIManager.flushWidget( UIWingInfo )
			elseif sender == btn_break then
				if btn_break:isBright() then
					if _isCanJinJie then
						UIManager.showLoading()
                        local sendData = nil
                        if UIGuidePeople.levelStep == "8_4" then
                            sendData = {
							    header = StaticMsgRule.realm,
							    msgdata = {
								    int = {
									    instPlayerCardId = userData.InstPlayerCard_id
								    },
                                    string = {
                                        step = "8_5"
                                    }
							    }
						    }
                        else
                            sendData = {
							    header = StaticMsgRule.realm,
							    msgdata = {
								    int = {
									    instPlayerCardId = userData.InstPlayerCard_id
								    }
							    }
						    }
                        end
						netSendPackage(sendData, netCallbackFunc)
					else
						UIManager.showToast(Lang.ui_card_jingjie2)
					end
				else
					UIManager.showToast(Lang.ui_card_jingjie3)
				end
			end
		end
	end
	btn_close:addTouchEventListener(onButtonEvent)
	btn_break:addTouchEventListener(onButtonEvent)

   
end

function UICardJingJie.setup()
    UIGuidePeople.isGuide(nil,UICardJingJie)
	_isUpgrade = nil
    _isCanJinJie = nil
	local image_basemap = UICardJingJie.Widget:getChildByName("image_basemap")
	local image_base_term = image_basemap:getChildByName("image_base_term")
	local btn_break = image_basemap:getChildByName("btn_break")
	btn_break:setBright(true)

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

	local ui_cardIcon = image_base_term:getChildByName("image_warrior")
	ui_cardIcon:loadTexture("image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId)].fileName)
	local ui_cardQuality = ui_cardIcon:getChildByName("image_info")
	ui_cardQuality:loadTexture(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small, true))
	local ui_cardName = ui_cardQuality:getChildByName("text_name")
	ui_cardName:setString((isAwake == 1 and Lang.ui_card_jingjie4 or "") .. dictCardData.name)
	local ui_cardLevel = ui_cardQuality:getChildByName("text_lv")
	ui_cardLevel:setString("LV " .. cardLv)
	local ui_curTitleBgImg = ui_cardIcon:getChildByName("image_before")
	ui_curTitleBgImg:loadTexture(utils.getTitleQualityImage(DictTitle[tostring(dictTitleDetailData.titleId)]))
	local ui_cardCurTitle = ui_curTitleBgImg:getChildByName("text_before")
	ui_cardCurTitle:setString(dictTitleDetailData.description)
	ui_cardCurTitle:enableOutline(cc.c4b(85,52,19,255),2)
	local ui_newTitleBgImg = ui_cardIcon:getChildByName("image_after")
	local ui_image_hint = image_base_term:getChildByName("image_hint")
	if nextDictTitleDetailData then
		if nextDictTitleDetailData.value == 0 then
			_isUpgrade = true
		end
		ui_newTitleBgImg:setVisible(true)
		ui_image_hint:setVisible(false)
		ui_newTitleBgImg:loadTexture(utils.getTitleQualityImage(DictTitle[tostring(nextDictTitleDetailData.titleId)]))
		local ui_cardNewTitle = ui_newTitleBgImg:getChildByName("text_after")
		ui_cardNewTitle:setString(nextDictTitleDetailData.description)
		ui_cardNewTitle:enableOutline(cc.c4b(85,52,19,255),2)
	else
		ui_image_hint:setVisible(true)
		ui_newTitleBgImg:setVisible(false)
	end

	local attribute = getAttributes(cardLv, qualityId, starLevelId, dictCardData)
	for tddKey, tddObj in pairs(DictTitleDetail) do
		if titleDetailId >= tddObj.id then
			local _tempData = utils.stringSplit(tddObj.effects, ";")
			for key, obj in pairs(_tempData) do
				local _fightPropData = utils.stringSplit(obj, "_") --[1]:fightPropId, [2]:value
				local _fightPropId, _value = tonumber(_fightPropData[1]), tonumber(_fightPropData[2])
				attribute[_fightPropId] = attribute[_fightPropId] + _value
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
    end

	local image_info_l_up = image_base_term:getChildByName("image_info_l_up")
	local image_arrow1 = ccui.Helper:seekNodeByName(image_info_l_up, "image_arrow1") --生命
	image_arrow1:getChildByName("text_blood"):setString(DictFightProp[tostring(StaticFightProp.blood)].name .. "：")
	image_arrow1:getChildByName("text_blood_before"):setString(attribute[StaticFightProp.blood])
	local image_arrow2 = ccui.Helper:seekNodeByName(image_info_l_up, "image_arrow2") --物攻
	image_arrow2:getChildByName("text_attack_gas"):setString(DictFightProp[tostring(StaticFightProp.wAttack)].name .. "：")
	image_arrow2:getChildByName("text_attack_gas_before"):setString(attribute[StaticFightProp.wAttack])
	local image_arrow3 = ccui.Helper:seekNodeByName(image_info_l_up, "image_arrow3") --物防
	image_arrow3:getChildByName("text_defense_gas"):setString(DictFightProp[tostring(StaticFightProp.wDefense)].name .. "：")
	image_arrow3:getChildByName("text_defense_gas_before"):setString(attribute[StaticFightProp.wDefense])
	local image_arrow4 = ccui.Helper:seekNodeByName(image_info_l_up, "image_arrow4") --法攻
	image_arrow4:getChildByName("text_attack_soul"):setString(DictFightProp[tostring(StaticFightProp.fAttack)].name .. "：")
	image_arrow4:getChildByName("text_attack_soul_before"):setString(attribute[StaticFightProp.fAttack])
	local image_arrow5 = ccui.Helper:seekNodeByName(image_info_l_up, "image_arrow5") --法防
	image_arrow5:getChildByName("text_defense_soul"):setString(DictFightProp[tostring(StaticFightProp.fDefense)].name .. "：")
	image_arrow5:getChildByName("text_defense_soul_before"):setString(attribute[StaticFightProp.fDefense])
	if nextDictTitleDetailData then
		local nextAttribute = {}
		_attribute = {}
		_nextAttribute = {}
		for key, obj in pairs(attribute) do
			nextAttribute[key] = obj
			_attribute[key] = obj
			_nextAttribute[key] = obj
		end
		local _tempData = utils.stringSplit(nextDictTitleDetailData.effects, ";")
		for key, obj in pairs(_tempData) do
			local _fightPropData = utils.stringSplit(obj, "_") --[1]:fightPropId, [2]:value
			local _fightPropId, _value = tonumber(_fightPropData[1]), tonumber(_fightPropData[2])
			nextAttribute[_fightPropId] = nextAttribute[_fightPropId] + _value
			_nextAttribute[_fightPropId] = _nextAttribute[_fightPropId] + _value
		end
		image_arrow1:getChildByName("text_blood_after"):setString(nextAttribute[StaticFightProp.blood])
		image_arrow2:getChildByName("text_attack_gas_after"):setString(nextAttribute[StaticFightProp.wAttack])
		image_arrow3:getChildByName("text_defense_gas_after"):setString(nextAttribute[StaticFightProp.wDefense])
		image_arrow4:getChildByName("text_attack_soul_after"):setString(nextAttribute[StaticFightProp.fAttack])
		image_arrow5:getChildByName("text_defense_soul_after"):setString(nextAttribute[StaticFightProp.fDefense])
		nextAttribute = nil
	else
		btn_break:setBright(false)
	end

	local image_info_l_down = image_base_term:getChildByName("image_info_l_down")
	local _dictTitleData = DictTitle[tostring(tonumber(dictTitleDetailData.titleId) + 1)]
	if _dictTitleData and nextDictTitleDetailData then
		image_info_l_down:setVisible(true)
		local ui_text_title = ccui.Helper:seekNodeByName(image_info_l_down, "text_title")
		ui_text_title:setString(_dictTitleData.name)
		local image_arrow1 = ccui.Helper:seekNodeByName(image_info_l_down, "image_arrow1")
		image_arrow1:getChildByName("text_before"):setString(DictTitle[tostring(dictTitleDetailData.titleId)].linden .. "%")
		image_arrow1:getChildByName("text_after"):setString(_dictTitleData.linden .. "%")
        local image_arrow2 = ccui.Helper:seekNodeByName(image_info_l_down, "image_arrow2")
        if string.len(DictTitle[tostring(dictTitleDetailData.titleId)].description) > 0 then
            image_arrow2:getChildByName("text_before"):setString(DictTitle[tostring(dictTitleDetailData.titleId)].description .. "%")
		    image_arrow2:getChildByName("text_after"):setString(_dictTitleData.description .. "%")
            image_arrow2:setVisible(true)
        else
            image_arrow2:setVisible(false)
        end
	else
		image_info_l_down:setVisible(false)
		cclog("ERROR: --------------->>>  伤害加成已经达到最高称号了")
	end

    local ui_stone = image_base_term:getChildByName("image_stone")
    local ui_jingjiedan = image_base_term:getChildByName("image_jingjiedan")
    local ui_weiwang = image_base_term:getChildByName("image_weiwang")
    local ui_super = image_base_term:getChildByName("image_super")
    local ui_fire = image_base_term:getChildByName("image_fire")
    local ui_quality = image_base_term:getChildByName("text_quality")
    ui_stone:setVisible(false)
    ui_jingjiedan:setVisible(false)
    ui_weiwang:setVisible(false)
    ui_super:setVisible(false)
    ui_fire:setVisible(false)
    ui_quality:setVisible(false)
    if dictTitleDetailData then
        local _condsPass = {}
        local conds = utils.stringSplit(dictTitleDetailData.cost, ";")
        for key, obj in pairs(conds) do
            local data = utils.stringSplit(obj, "_")
            if tonumber(data[1]) == 1 then --境界丹（1_境界丹数量）
                local _textNumColor = cc.c4b(255, 0, 0, 255)
                local _count = utils.getThingCount(StaticThing.realmPill)
	            if _count >= tonumber(data[2]) then --达标
                    _textNumColor = cc.c4b(0, 255, 255, 255) --默认达标色
                    _condsPass[#_condsPass + 1] = 1
                end
                if #conds == 1 then
                    local text_number = ui_stone:getChildByName("text_number")
                    text_number:setString(_count .. "/" .. tonumber(data[2]))
                    text_number:setTextColor(_textNumColor)
                    ui_stone:setVisible(true)
                else
                    local text_number = ui_jingjiedan:getChildByName("text_number")
                    text_number:setString(_count .. "/" .. tonumber(data[2]))
                    text_number:setTextColor(_textNumColor)
                    ui_jingjiedan:setVisible(true)
                end
            elseif tonumber(data[1]) == 2 then --超级境界丹（2_超级境界丹数量）
                local _textNumColor = cc.c4b(255, 0, 0, 255)
                local _count = utils.getThingCount(StaticThing.thing300)
                if _count >= tonumber(data[2]) then --达标
                    _textNumColor = cc.c4b(235, 101, 235, 255) --默认达标色
                    _condsPass[#_condsPass + 1] = 1
                end
                local text_number = ui_super:getChildByName("text_number")
                text_number:setString(_count .. "/" .. tonumber(data[2]))
                text_number:setTextColor(_textNumColor)
                ui_super:setVisible(true)
            elseif tonumber(data[1]) == 3 then --威望（3_威望数量）
                local _textNumColor = cc.c4b(255, 0, 0, 255)
                local _count = (net.InstPlayer and net.InstPlayer.int["39"] or 0)
                if _count >= tonumber(data[2]) then --达标
                    _textNumColor = cc.c4b(255, 255, 0, 255) --默认达标色
                    _condsPass[#_condsPass + 1] = 1
                end
                local text_number = ui_weiwang:getChildByName("text_number")
                text_number:setString(_count .. "/" .. tonumber(data[2]))
                text_number:setTextColor(_textNumColor)
                ui_weiwang:setVisible(true)
            elseif tonumber(data[1]) == 4 then --异火火种（4_火种ID_火种数量）
                if #conds > 3 then
                    ui_fire:setPositionX(ui_super:getPositionX())
                else
                    ui_fire:setPositionX(ui_super:getPositionX() - 150)
                end
                local _textNumColor = cc.c4b(255, 0, 0, 255)
                local _count = 0
                if net.InstPlayerYFire then
                    for _keyYFire, _objYFire in pairs(net.InstPlayerYFire) do
                        if _objYFire.int["3"] == tonumber(data[2]) then
                            _count = _objYFire.int["9"]
                            break
                        end
                    end
                end
                if _count >= tonumber(data[3]) then --达标
                    _textNumColor = cc.c4b(166, 162, 162, 255) --默认达标色
                    _condsPass[#_condsPass + 1] = 1
                end
                ui_fire:getChildByName("text_name"):setString(DictYFireChip[data[2]].name)
                ui_fire:loadTexture("image/fireImage/" .. DictUI[tostring(DictYFire[data[2]].smallUiId)].fileName)
                local text_number = ui_fire:getChildByName("text_number")
                text_number:setString(_count .. "/" .. tonumber(data[3]))
                text_number:setTextColor(_textNumColor)
                ui_fire:setVisible(true)
            elseif tonumber(data[1]) == 5 then --品阶（5_品质ID_星级ID）
                local _condition = 0 --0.未达成, 1.达成
                if qualityId >= tonumber(data[2]) then
                    if qualityId == tonumber(data[2]) then
                        if starLevelId >= tonumber(data[3]) then
                            _condition = 1
                        end
                    else
                        _condition = 1
                    end
                end
                local _textNumColor = cc.c4b(255, 0, 0, 255)
                if _condition == 1 then --达标
                    _textNumColor = cc.c4b(255, 165, 0, 255) --默认达标色
                    _condsPass[#_condsPass + 1] = 1
                end
                ui_quality:setString(Lang.ui_card_jingjie5 .. DictQuality[data[2]].name .. DictStarLevel[data[3]].name)
                ui_quality:setTextColor(_textNumColor)
                ui_quality:setVisible(true)
                if not ui_jingjiedan:isVisible() and #conds == 3 then
                    ui_quality:setPositionY(ui_jingjiedan:getPositionY() - 5)
                else
                    ui_quality:setPositionY(24.05)
                end
            elseif tonumber(data[1]) >= 6 or tonumber(data[1]) <= 9 then --物品（6_物品id_数量）
                local _textNumColor = cc.c4b(255, 0, 0, 255)
                local _count = utils.getThingCount(tonumber(data[2]))
	            if _count >= tonumber(data[3]) then --达标
                    _textNumColor = cc.c4b(0, 255, 255, 255) --默认达标色
                    _condsPass[#_condsPass + 1] = 1
                end
                local imgTab = {ui_jingjiedan , ui_super , ui_weiwang , ui_fire}
                local img = imgTab[tonumber(data[1]) - 5]

                local text_number = img:getChildByName("text_number")
                text_number:setString(_count .. "/" .. tonumber(data[3]))
                text_number:setTextColor(_textNumColor)
                img:setVisible(true)
                local dictData = DictThing[tostring(data[2])]
                img:loadTexture("image/" .. DictUI[tostring(dictData.smallUiId)].fileName)
                local text_name = img:getChildByName("text_name")
                text_name:setString(dictData.name)
            end
        end
        if #_condsPass == #conds then
            _isCanJinJie = true
        end
        _condsPass = nil
        conds = nil
    end
end

function UICardJingJie.free()
	userData = nil
	_attribute = nil
	_nextAttribute = nil
	_isUpgrade = nil
    _isCanJinJie = nil
end

function UICardJingJie.show(_tableParams, _isReplace)
	userData = _tableParams
	if userData and userData.InstPlayerCard_id then
        if _isReplace then
            UIManager.replaceScene("ui_card_jingjie")
        else
		    UIManager.pushScene("ui_card_jingjie")
        end
	else
		UIManager.showToast(Lang.ui_card_jingjie6)
	end
end
