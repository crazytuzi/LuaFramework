require"Lang"
UICardUpgrade = { }

local ui_pageView = nil
local ui_pageViewItem = nil
local _pageIndex = nil
local _curPageViewIndex = -1
local _pvCardData = nil

local btn_card = nil -- 吞卡标签
local btn_exp = nil -- 经验丹标签
local btn_cultivation = nil -- 潜力丹标签
local btn_exit = nil -- 退出按钮
local btn_add = nil -- 一键添加按钮
local btn_upgrade = nil -- 升级按钮
local ui_cardQuality = nil -- 卡牌品阶
local ui_cardName = nil -- 卡牌名称
local ui_cardLv = nil -- 卡牌等级
local ui_cardLvUp = nil -- 吞卡后等级
local ui_cardExpBar = nil -- 卡牌经验条
local ui_cardExpLabel = nil -- 卡牌经验值
local ui_cardExpBarNew = nil
local ui_propertyPanel = nil -- 卡牌属性面板
local ui_upgradePanel = nil
local ui_expPanel = nil
local ui_totalMoney = nil -- 银币
local ui_cultivation = nil -- 潜力

local _cardImagePath = nil
local _cardIconPoint = nil
local _cardExpBarPoint = nil
local _btnExitPoint = nil
local _prevBtnLabel = nil
local _usePillNums = 0 -- 使用丹药个数
local _curInstCardId = nil -- 当前卡牌实例ID
local instCardIds = nil
local _uiItem = nil

local _uiCurUsePillNum = nil
local _curCardLevel = 0
local _curCardExp = 0
local _curTalentValue = 0
local _curTime = 0
local _price = 0
local _schedulerId = nil
local _upgradeId = nil
local _cardPropValue = nil
local _tempExp, _tempLv, _prevLv, _tempPercent, _addValue

local _index = 1
local _effects = nil
local selectedInstCardIds = { }
local setPill

local image_hint = nil -- 提示

local function cleanPageView(_isRelease)
    if _isRelease then
        if ui_pageViewItem and ui_pageViewItem:getReferenceCount() >= 1 then
            ui_pageViewItem:release()
            ui_pageViewItem = nil
        end
    else
        if ui_pageViewItem:getReferenceCount() == 1 then
            ui_pageViewItem:retain()
        end
    end
    if ui_pageView then
        ui_pageView:removeAllPages()
    end
    if ui_pageView then
        ui_pageView:removeAllChildren()
    end
    _curPageViewIndex = -1
end

local function getCardProp(dictCardData, qualityId, starLevelId, lv)
    local _level = lv
    if _level == nil then
        _level = _curCardLevel
    end
    local tempProp = { }
    tempProp[1] = { temp = 0 }
    tempProp[1].name = DictFightProp[tostring(StaticFightProp.blood)].name
    tempProp[1].value = formula.getCardBlood(_level, qualityId, starLevelId, dictCardData)

    tempProp[2] = { temp = 0 }
    tempProp[2].name = DictFightProp[tostring(StaticFightProp.wAttack)].name
    tempProp[2].value = formula.getCardGasAttack(_level, qualityId, starLevelId, dictCardData)

    tempProp[3] = { temp = 0 }
    tempProp[3].name = DictFightProp[tostring(StaticFightProp.wDefense)].name
    tempProp[3].value = formula.getCardGasDefense(_level, qualityId, starLevelId, dictCardData)

    tempProp[4] = { temp = 0 }
    tempProp[4].name = DictFightProp[tostring(StaticFightProp.fAttack)].name
    tempProp[4].value = formula.getCardSoulAttack(_level, qualityId, starLevelId, dictCardData)

    tempProp[5] = { temp = 0 }
    tempProp[5].name = DictFightProp[tostring(StaticFightProp.fDefense)].name
    tempProp[5].value = formula.getCardSoulDefense(_level, qualityId, starLevelId, dictCardData)
    --[[
	tempProp[6] = {temp=0}
	tempProp[6].name = DictFightProp[tostring(StaticFightProp.hit)].name
	tempProp[6].value = formula.getCardHit(_level, dictCardData)

	tempProp[7] = {temp=0}
	tempProp[7].name = DictFightProp[tostring(StaticFightProp.dodge)].name
	tempProp[7].value = formula.getCardDodge(_level, dictCardData)

	tempProp[8] = {temp=0}
	tempProp[8].name = DictFightProp[tostring(StaticFightProp.crit)].name
	tempProp[8].value = formula.getCardCrit(_level, dictCardData)

	tempProp[9] = {temp=0}
	tempProp[9].name = DictFightProp[tostring(StaticFightProp.flex)].name
	tempProp[9].value = formula.getCardTenacity(_level, dictCardData)
	--]]
    return tempProp
end

local function getCardTotalExp(level, curExp)
    local totalExp = 0
    if level > 1 then
        for cardLv = 1, level - 1 do
            totalExp = totalExp + DictCardExpAdd[tostring(cardLv)].exp
        end
    else
        totalExp = DictCardExpAdd[tostring(level)].exp
    end
    return totalExp + curExp
end

local function setCardProp(dictCardData, qualityId, starLevelId)
    if _cardPropValue == nil then
        _cardPropValue = { }
    end
    _cardPropValue.cur = getCardProp(dictCardData, qualityId, starLevelId)
    for key, obj in pairs(_cardPropValue.cur) do
        ui_propertyPanel:getChildByName("text_prop" .. key):setString(obj.name .. "：" .. obj.value)
    end
end

local function startUpgrade(dt)
    local isUnschedule = true
    if ui_cardExpBarNew:getPercent() == 100 then
        if _cardPropValue.new then
            for i = 1, 5 do
                _cardPropValue.cur[i].temp = _cardPropValue.cur[i].temp + _addValue
                local value = _cardPropValue.cur[i].value + _cardPropValue.cur[i].temp
                if value > _cardPropValue.new[i].value then
                    value = _cardPropValue.new[i].value
                else
                    isUnschedule = false
                end
                ui_propertyPanel:getChildByName("text_prop" .. i):setString(_cardPropValue.cur[i].name .. "：" .. value)
            end
        end
        if isUnschedule then
        end
        local _percent = ui_cardExpBar:getPercent() + _addValue
        if _percent > 100 then
            _percent = 0
            _prevLv = _prevLv + 5
            if _prevLv > _tempLv then
                _prevLv = _tempLv
                _addValue = 5
            end
            ui_cardLv:setString("LV  " .. _prevLv)
        end

        if _prevLv == _tempLv and _percent >= _tempPercent then
            _percent = _tempPercent
        else
            isUnschedule = false
        end
        ui_cardExpBar:setPercent(_percent)
    else
        local _percent = ui_cardExpBar:getPercent() + _addValue
        if _percent > ui_cardExpBarNew:getPercent() then
            _percent = ui_cardExpBarNew:getPercent()
        else
            isUnschedule = false
        end
        ui_cardExpBar:setPercent(_percent)
    end

    if _effects then
        local _tempPoint = cc.p(_cardExpBarPoint.x - ui_cardExpBar:getContentSize().width / 2 +(ui_cardExpBar:getContentSize().width *(ui_cardExpBar:getPercent() / 100)), _cardExpBarPoint.y)
        for key, obj in pairs(_effects) do
            obj:setPosition(_tempPoint)
        end
    end

    if isUnschedule then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_upgradeId)
        _upgradeId = nil

        if _effects then
            for key, obj in pairs(_effects) do
                obj:removeFromParent()
            end
        end
        _effects = nil

        UICardUpgrade.setup()
        if _uiItem == UICardInfo then
            UIManager.flushWidget(UILineup)
            UIManager.flushWidget(UICardInfo)
        elseif _uiItem == UIBagCard then
            UIManager.flushWidget(UIBagCard)
            UIManager.flushWidget(UITeamInfo)
        end
        UIGuidePeople.isGuide(nil, UICardUpgrade)

        local childs = UIManager.uiLayer:getChildren()
        for key, obj in pairs(childs) do
            obj:setEnabled(true)
        end

    end
end

local function startFade()
    if _tempLv > _curCardLevel then
        ui_cardLvUp:setString("→" .. _tempLv)
        ui_cardLvUp:setVisible(true)
        ui_cardLvUp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 100), cc.FadeTo:create(0.5, 255))))
        local instPlayerCardData = net.InstPlayerCard[tostring(_curInstCardId)]
        local dictCardData = DictCard[tostring(instPlayerCardData.int["3"])]
        local qualityId = instPlayerCardData.int["4"]
        -- 卡牌品阶ID
        local starLevelId = instPlayerCardData.int["5"]
        -- 卡牌星级ID
        _cardPropValue.new = getCardProp(dictCardData, qualityId, starLevelId, _tempLv)
        for i = 1, #_cardPropValue.new do
            if _cardPropValue.new[i].value > _cardPropValue.cur[i].value then
                local _textAdd = ui_propertyPanel:getChildByName("text_add" .. i)
                _textAdd:setVisible(true)
                _textAdd:setString("+" .. _cardPropValue.new[i].value - _cardPropValue.cur[i].value)
                _textAdd:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 100), cc.FadeTo:create(0.5, 255))))
            end
        end
        ui_cardExpBarNew:setPercent(100)
    else
        local maxExp = DictCardExp[tostring(_tempLv)].exp
        ui_cardExpBarNew:setPercent(_tempExp / maxExp * 100)
    end
    ui_cardExpBarNew:setVisible(true)
    ui_cardExpBarNew:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 100), cc.FadeTo:create(0.5, 255))))
end

local function stopFade()
    -- _tempExp, _tempLv = nil, nil
    ui_cardLvUp:stopAllActions()
    ui_cardLvUp:setVisible(false)
    ui_cardExpBarNew:stopAllActions()
    ui_cardExpBarNew:setVisible(false)
    for i = 1, 5 do
        local _textAdd = ui_propertyPanel:getChildByName("text_add" .. i)
        _textAdd:stopAllActions()
        _textAdd:setVisible(false)
        _textAdd:setOpacity(255)
    end
    ui_cardLvUp:setOpacity(255)
    ui_cardExpBarNew:setOpacity(255)
end

local function initCardInfo()
    stopFade()

    if _curInstCardId then
        local instPlayerCardData = net.InstPlayerCard[tostring(_curInstCardId)]
        local dictCardData = DictCard[tostring(instPlayerCardData.int["3"])]
        local qualityId = instPlayerCardData.int["4"]
        -- 卡牌品阶ID
        local starLevelId = instPlayerCardData.int["5"]
        -- 卡牌星级ID
        local cardLevel = instPlayerCardData.int["9"]
        -- 卡牌等级
        _curCardExp = instPlayerCardData.int["8"]
        _curCardLevel = cardLevel
        _curTalentValue = instPlayerCardData.int["14"]
        -- 潜力点
        local _isAwake = instPlayerCardData.int["18"]

        ui_cardQuality:loadTexture(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small, true))
        _cardImagePath = "image/" .. DictUI[tostring(_isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId)].fileName

        ui_cardName:setString((_isAwake == 1 and Lang.ui_card_upgrade1 or "") .. dictCardData.name)
        local maxExp = DictCardExp[tostring(cardLevel)].exp
        ui_cardExpBar:setPercent(instPlayerCardData.int["8"] / maxExp * 100)
        ui_cardExpLabel:setString(instPlayerCardData.int["8"] .. "/" .. maxExp)

        ui_cardLv:setString("LV  " .. cardLevel)

        setCardProp(dictCardData, qualityId, starLevelId)

        ccui.Helper:seekNodeByName(ui_upgradePanel, "text_gold"):setString(Lang.ui_card_upgrade2 .. net.InstPlayer.string["6"])
        -- 金币总数
        ccui.Helper:seekNodeByName(ui_upgradePanel, "text_gold_need"):setString(Lang.ui_card_upgrade3)
        -- 所需金币
        ccui.Helper:seekNodeByName(ui_upgradePanel, "text_get_exp"):setString(Lang.ui_card_upgrade4)
        -- 获得经验
    end
end

local function pageViewEvent(sender, eventType)
    if eventType == ccui.PageViewEventType.turning and _curPageViewIndex ~= sender:getCurPageIndex() then
        _curPageViewIndex = sender:getCurPageIndex()
        if _pvCardData then
            local id = sender:getPage(_curPageViewIndex):getTag()
            for key, obj in pairs(_pvCardData) do
                if id == tonumber(obj.dictId) then
                    _curInstCardId = obj.instId
                    initCardInfo()
                    if _prevBtnLabel == btn_card then
                        UICardUpgrade.setSelectedInstCardIds(selectedInstCardIds)
                    else
                        setPill()
                    end
                    break
                end
            end
        end
    end
end

local function getPropNum()
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
        local propImg = ccui.ImageView:create("ui/ui_anim2Effect" .. _index .. ".png")
        propImg:setAnchorPoint(1, 0.5)
        propImg:setPosition(0, panel:getContentSize().height / 2)
        panel:addChild(propImg)
        local num = ccui.TextAtlas:create()
        num:setProperty("0123456789", _numImg, 25, 36, "0")
        num:setAnchorPoint(0, 0.5)
        num:setString(tostring(_cardPropValue.new[_index].value - _cardPropValue.cur[_index].value))
        num:setPosition(panel:getContentSize().width, panel:getContentSize().height / 2)
        panel:addChild(num)

        local ui_cardIcon = ui_pageView:getPage(ui_pageView:getCurPageIndex()):getChildByName("image_card")
        -- panel:setPosition(ui_cardIcon:getContentSize().width / 2 + 20, ui_cardIcon:getContentSize().height / 2 - 100)
        panel:setPosition(ui_cardIcon:getContentSize().width / 2 + 20, ui_cardIcon:getContentSize().height / 2 - 200 + _index *(panel:getContentSize().height + 5))
        ui_cardIcon:addChild(panel)
        _index = _index + 1
        panel:setScale(0.8)
        -- panel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.1), cc.MoveBy:create(0.3, cc.p(0, 60)), cc.Spawn:create(cc.MoveBy:create(0.3,cc.p(0, 60)), cc.ScaleTo:create(0.3, 0.9), cc.FadeTo:create(0.3, 0)), cc.CallFunc:create(function()
        panel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.1), cc.MoveBy:create(0.3, cc.p(0, 60)), cc.Spawn:create(cc.MoveBy:create(0.8, cc.p(0, 60)), cc.FadeTo:create(0.8, 0)), cc.CallFunc:create( function()
            panel:removeAllChildren()
            panel:removeFromParent()
            if _index <= 5 then
                -- 		getPropNum()
            else
                _index = 1
            end
            --[[
			if _effects == nil then
				_effects = {}
				for i = 1, 3 do
					_effects[#_effects + 1] = cc.ParticleSystemQuad:create("particle/ui_anim2_effect.plist")
					_effects[i]:setPosition(_cardIconPoint)
					UICardUpgrade.Widget:addChild(_effects[i], 1000)
					_effects[i]:setScale(0.7)
				end
			end
			]]
        end )))
    end

    if _index > 5 then
        -- 	UICardUpgrade.setup()
        -- 	if _uiItem == UICardInfo then
        -- 		UICardInfo.setup()
        -- 		UILineup.setup()
        -- 	elseif _uiItem == UIBagCard then
        -- 		UIBagCard.setup()
        -- 		UITeamInfo.setup()
        -- 	end
        -- 	UIGuidePeople.isGuide(nil,UICardUpgrade)

        if _effects then
            for key, obj in pairs(_effects) do
                obj:removeFromParent()
            end
        end
        _effects = nil

        stopFade()
        -- _upgradeId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(startUpgrade, 0, false)
        UICardUpgrade.setup()
        if _uiItem == UICardInfo then
            UIManager.flushWidget(UILineup)
            UIManager.flushWidget(UICardInfo)
        elseif _uiItem == UIBagCard then
            UIManager.flushWidget(UIBagCard)
            UIManager.flushWidget(UITeamInfo)
        end
        UIGuidePeople.isGuide(nil, UICardUpgrade)

        local childs = UIManager.uiLayer:getChildren()
        for key, obj in pairs(childs) do
            obj:setEnabled(true)
        end

        --[[
		local _tempPoint = cc.p(_cardExpBarPoint.x - ui_cardExpBar:getContentSize().width / 2 + (ui_cardExpBar:getContentSize().width * (ui_cardExpBar:getPercent() / 100)), _cardExpBarPoint.y)

--		local effects = {}
		for i = 1, 3 do
			local _pos = cc.p(_cardIconPoint.x + utils.random(-10,10), _cardIconPoint.y + utils.random(-10,10))
--			effects[#effects + 1] = cc.ParticleSystemQuad:create("particle/ui_anim2_effect.plist")
--			effects[i]:setPosition(_cardIconPoint)
--			UICardUpgrade.Widget:addChild(effects[i], 1000)
--			effects[i]:setScale(0.7)
			if i == 3 then
				_effects[i]:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, _pos), cc.DelayTime:create(0.1 * i), cc.MoveTo:create(0.5, _tempPoint), cc.DelayTime:create(0.3), cc.CallFunc:create(function()
					for key, obj in pairs(_effects) do
						obj:removeFromParent()
					end
					_effects = nil
					stopFade()
					_upgradeId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(startUpgrade, 0, false)
				end)))
			else
				_effects[i]:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, _pos), cc.DelayTime:create(0.1 * i), cc.MoveTo:create(0.5, _tempPoint)))
			end
		end
		]]

    else
        -- ui_cardIcon:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(getPropNum)))
        getPropNum()
    end
end

local function checkImageHint()
    local result = false
    local pills = { }
    local pillType = StaticPillType.exp
    for key, obj in pairs(DictPill) do
        if obj.pillTypeId == pillType then
            pills[#pills + 1] = obj
        end
    end
    for key, dictPillData in pairs(pills) do
        local pillNum = utils.getPillCount(dictPillData.id)
        if pillNum > 0 then
            result = true
            break
        end
    end
    utils.addImageHint(result, btn_exp, 100, 18, 10)
end

local function netCallbackFunc(data)
    local code = tonumber(data.header)
    if code == StaticMsgRule.deleteCard then
        if instCardIds then
            local _ids = utils.stringSplit(instCardIds, ";")
            local effects = { }
            local childs = UIManager.uiLayer:getChildren()
            local function effectCallback()
                -- 			local _effectBg = nil
                local animation = ActionManager.getUIAnimation(2, function(armature)
                    -- 				_effectBg:removeFromParent()
                    -- 				_effectBg = nil

                    --[[
					UICardUpgrade.setup()
					if _uiItem == UICardInfo then
						UICardInfo.setup()
						UILineup.setup()
					elseif _uiItem == UIBagCard then
						UIBagCard.setup()
						UITeamInfo.setup()
					end
					UIGuidePeople.isGuide(nil,UICardUpgrade)
					]]
                    UIManager.gameLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),
                    cc.CallFunc:create( function() armature:removeFromParent() end)))
                end )
                local function onFrameEvent(bone, evt, originFrameIndex, currentFrameIndex)
                    if evt == "anim_event" then
                        -- 					_effectBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
                        -- 					UICardUpgrade.Widget:addChild(_effectBg, 999)
                        animation:getAnimation():setSpeedScale(1.2)
                        -- 					stopFade()
                        -- 					_upgradeId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(startUpgrade, 0, false)

                        --[[
						if _effects == nil then
							_effects = {}
							for i = 1, 3 do
								_effects[#_effects + 1] = cc.ParticleSystemQuad:create("particle/ui_anim2_effect.plist")
								_effects[i]:setPosition(_cardIconPoint)
								UICardUpgrade.Widget:addChild(_effects[i], 1000)
								_effects[i]:setScale(0.7)
							end
						end
						]]
                    elseif evt == "anim_event1" then
                        -- 					_effectBg:removeFromParent()
                        -- 					_effectBg = nil
                        -- 					if _upgradeId then
                        -- 						animation:getAnimation():gotoAndPlay(70)
                        -- 					else
                        if _tempLv > _curCardLevel then
                            getPropNum()
                        else
                            stopFade()
                            _upgradeId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(startUpgrade, 0, false)
                            --[[
							local _tempPoint = cc.p(_cardExpBarPoint.x - ui_cardExpBar:getContentSize().width / 2 + (ui_cardExpBar:getContentSize().width * (ui_cardExpBar:getPercent() / 100)), _cardExpBarPoint.y)
							for i = 1, 3 do
								local _pos = cc.p(_cardIconPoint.x + utils.random(-10,10), _cardIconPoint.y + utils.random(-10,10))
								if i == 3 then
									_effects[i]:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, _pos), cc.DelayTime:create(0.1 * i), cc.MoveTo:create(0.5, _tempPoint), cc.DelayTime:create(0.3), cc.CallFunc:create(function()
										stopFade()
										_upgradeId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(startUpgrade, 0, false)
									end)))
								else
									_effects[i]:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, _pos), cc.DelayTime:create(0.1 * i), cc.MoveTo:create(0.5, _tempPoint)))
								end
							end
							]]
                        end
                        animation:getAnimation():setSpeedScale(1)
                        -- 					end
                    end
                end
                animation:getAnimation():setFrameEventCallFunc(onFrameEvent)
                if _cardImagePath then
                    animation:getBone("renwu"):addDisplay(ccs.Skin:create(_cardImagePath), 0)
                    animation:getBone("renwu2"):addDisplay(ccs.Skin:create(_cardImagePath), 0)
                end
                animation:setPosition(cc.p(UIManager.screenSize.width - 85, UIManager.screenSize.height / 2 - 45))
                UICardUpgrade.Widget:addChild(animation, 1000)
                for key, obj in pairs(effects) do
                    obj:removeFromParent()
                    local btn_eat = ccui.Helper:seekNodeByName(ui_upgradePanel, "image_frame_card" .. key)
                    btn_eat:loadTexture("ui/card_small_white.png")
                    local btnImg = btn_eat:getChildByName("image_card" .. key)
                    btnImg:stopAllActions()
                    btnImg:loadTexture("ui/frame_tianjia.png")
                    btnImg:setOpacity(255)
                end
            end
            -- 		local childs = UIManager.uiLayer:getChildren()
            for key, obj in pairs(childs) do
                obj:setEnabled(false)
            end
            for i = 1, #_ids do
                local btnImg = ccui.Helper:seekNodeByName(ui_upgradePanel, "image_frame_card" .. i):getChildByName("image_card" .. i)
                local _pos = btnImg:convertToWorldSpace(cc.p(btnImg:getPositionX(), btnImg:getPositionY()))
                effects[#effects + 1] = cc.ParticleSystemQuad:create("particle/ui_anim2_effect.plist")
                effects[i]:setPosition(cc.p(_pos.x, _pos.y))
                UICardUpgrade.Widget:addChild(effects[i], 1000)
                if i == #_ids then
                    effects[i]:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, _cardIconPoint), cc.CallFunc:create(effectCallback)))
                else
                    effects[i]:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, _cardIconPoint)))
                end
                btnImg:runAction(cc.Sequence:create(cc.FadeTo:create(0.5, 0)))
            end
        end
    elseif code == StaticMsgRule.eatPill then
        initCardInfo()
        checkImageHint()
        setPill()
        UIManager.flushWidget(UICardInfo)
        UIManager.flushWidget(UILineup)
    end
end

local function eatPill(dictPillId)
    if _usePillNums > 0 then
        local instPillId = nil
        if net.InstPlayerPill then
            for key, obj in pairs(net.InstPlayerPill) do
                if obj.int["3"] == tonumber(dictPillId) then
                    instPillId = obj.int["1"]
                    break
                end
            end
        end
        if instPillId then
            local sendData = {
                header = StaticMsgRule.eatPill,
                msgdata =
                {
                    int =
                    {
                        instPlayerCardId = _curInstCardId,
                        instPlayerPillId = instPillId,
                        num = _usePillNums
                    }
                }
            }
            UIManager.showLoading()
            netSendPackage(sendData, netCallbackFunc)
        else
            cclog("ERROR: ----------->> 丹药数据出错！")
        end
    end
end

local function compareFunc(obj1, obj2)
    if obj1.id > obj2.id then
        return true
    else
        return false
    end
end

local function cardUpgrade(value)
    if _prevBtnLabel == btn_exp then
        _curCardExp = _curCardExp + value
        local maxExp = DictCardExp[tostring(_curCardLevel)].exp
        if _curCardExp >= maxExp then
            _curCardExp = _curCardExp - maxExp
            _curCardLevel = _curCardLevel + 1
            maxExp = DictCardExp[tostring(_curCardLevel)].exp
            ui_cardLv:setString(tostring(_curCardLevel))
            local instPlayerCardData = net.InstPlayerCard[tostring(_curInstCardId)]
            local dictCardData = DictCard[tostring(instPlayerCardData.int["3"])]
            local qualityId = instPlayerCardData.int["4"]
            -- 卡牌品阶ID
            local starLevelId = instPlayerCardData.int["5"]
            -- 卡牌星级ID
            setCardProp(dictCardData, qualityId, starLevelId)
        end
        if _curCardLevel >= net.InstPlayer.int["4"] then
            _curCardExp = 0
            ui_cardExpBar:setPercent(_curCardExp / maxExp * 100)
            ui_cardExpLabel:setString(_curCardExp .. "/" .. maxExp)
            return false
        else
            ui_cardExpBar:setPercent(_curCardExp / maxExp * 100)
            ui_cardExpLabel:setString(_curCardExp .. "/" .. maxExp)
            return true
        end
    elseif _prevBtnLabel == btn_cultivation then
        _curTalentValue = _curTalentValue + value
        ui_cultivation:setString(Lang.ui_card_upgrade5 .. _curTalentValue)
        return true
    end
end

function setPill()
    local pillType = nil
    if _prevBtnLabel == btn_exp then
        pillType = StaticPillType.exp
    elseif _prevBtnLabel == btn_cultivation then
        pillType = StaticPillType.potential
    end

    local pills = { }
    for key, obj in pairs(DictPill) do
        if obj.pillTypeId == pillType then
            pills[#pills + 1] = obj
        end
    end
    utils.quickSort(pills, compareFunc)

    local money = nil
    if _prevBtnLabel == btn_exp then
        money = net.InstPlayer.string["6"]
        ui_totalMoney:setString("：" .. money)
        ui_totalMoney:getParent():setVisible(true)
        ui_cultivation:setVisible(false)
    elseif _prevBtnLabel == btn_cultivation then
        local instPlayerCardData = net.InstPlayerCard[tostring(_curInstCardId)]
        ui_totalMoney:getParent():setVisible(false)
        ui_cultivation:setVisible(true)
        ui_cultivation:setString(Lang.ui_card_upgrade6 .. instPlayerCardData.int["14"])
    end

    for key, dictPillData in pairs(pills) do
        local item = ccui.Helper:seekNodeByName(ui_expPanel, "image_frame_exp" .. key)
        local icon = item:getChildByName("image_exp" .. key)
        local name = ccui.Helper:seekNodeByName(icon, "text_exp_high")
        local exp = icon:getChildByName("text_exp_number")
        local num = ccui.Helper:seekNodeByName(icon, "text_number")
        local price = icon:getChildByName("text_exp_cost")
        local priceIcon = icon:getChildByName("image_money")
        icon:loadTexture("image/" .. DictUI[tostring(dictPillData.smallUiId)].fileName)
        name:setString(dictPillData.name)
        if _prevBtnLabel == btn_exp then
            exp:setString("EXP：" .. dictPillData.value)
        elseif _prevBtnLabel == btn_cultivation then
            exp:setString(Lang.ui_card_upgrade7 .. dictPillData.value)
        end
        local pillNum = utils.getPillCount(dictPillData.id)
        num:setTag(dictPillData.id)
        num:setString(tostring(pillNum))
        if _prevBtnLabel == btn_exp then
            price:setVisible(true)
            priceIcon:setVisible(true)
            price:setString(Lang.ui_card_upgrade8 .. DictSysConfig[tostring(StaticSysConfig.eatExpCopper)].value * dictPillData.value)
        else
            price:setVisible(false)
            priceIcon:setVisible(false)
        end

        local function addExp(dt)
            if os.time() - _curTime >= 1 and pillNum > 0 then

                if money then
                    money = money - DictSysConfig[tostring(StaticSysConfig.eatExpCopper)].value * dictPillData.value
                    if money < 0 then
                        if _schedulerId then
                            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_schedulerId)
                            _schedulerId = nil
                        end
                        UIManager.showToast(Lang.ui_card_upgrade9)
                        return
                    end
                    ui_totalMoney:setString("：" .. money)
                end

                _usePillNums = _usePillNums + 1
                num:setString(tostring(pillNum - _usePillNums))
                if cardUpgrade(dictPillData.value) then
                    if _usePillNums == pillNum then
                        if _schedulerId then
                            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_schedulerId)
                            _schedulerId = nil
                        end
                        UIManager.showToast(Lang.ui_card_upgrade10)
                    end
                else
                    if _schedulerId then
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_schedulerId)
                        _schedulerId = nil
                    end
                    UIManager.showToast(Lang.ui_card_upgrade11)
                end
            end
        end

        local isCanUpgrade = true
        if _prevBtnLabel == btn_exp and _curCardLevel >= net.InstPlayer.int["4"] then
            isCanUpgrade = false
        end

        item:setTouchEnabled(true)
        local function itemEvent(sender, eventType)
            image_hint:stopAllActions()
            image_hint:setOpacity(0)
            if eventType == ccui.TouchEventType.began then
                if isCanUpgrade then
                    _usePillNums = 0
                    _curTime = os.time()
                    if _schedulerId then
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_schedulerId)
                        _schedulerId = nil
                    end
                    _schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(addExp, 0, false)
                else
                    UIManager.showToast(Lang.ui_card_upgrade12)
                end
            elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
                if isCanUpgrade then
                    if _schedulerId then
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_schedulerId)
                        _schedulerId = nil
                    end
                    _uiCurUsePillNum = num
                    if os.time() - _curTime > 0 then
                        eatPill(dictPillData.id)
                    else
                        _curTime = 0
                        addExp()
                        eatPill(dictPillData.id)
                    end
                    UIGuidePeople.isGuide(nil, UICardUpgrade)
                end
            end
        end
        item:addTouchEventListener(itemEvent)
        if key == 1 then
            local param = { }
            param[1] = itemEvent
            param[2] = item
            UIGuidePeople.isGuide(param, UICardUpgrade)

        end
    end
end

local function setTopButtonLabel(sender)
    if _prevBtnLabel ~= sender then
        _prevBtnLabel = sender
        btn_card:loadTextureNormal("ui/yh_btn01.png")
        btn_card:getChildByName("text_card"):setTextColor(cc.c4b(255, 255, 255, 255))
        btn_exp:loadTextureNormal("ui/yh_btn01.png")
        btn_exp:getChildByName("text_exp"):setTextColor(cc.c4b(255, 255, 255, 255))
        btn_cultivation:loadTextureNormal("ui/yh_btn01.png")
        btn_cultivation:getChildByName("text_cultivation"):setTextColor(cc.c4b(255, 255, 255, 255))
        sender:loadTextureNormal("ui/yh_btn02.png")
        if sender == btn_card then
            -- 吞卡
            image_hint:stopAllActions()
            image_hint:setOpacity(0)
            sender:getChildByName("text_card"):setTextColor(cc.c4b(51, 25, 4, 255))
            ui_upgradePanel:setVisible(true)
            ui_expPanel:setVisible(false)
            btn_exit:setPosition(_btnExitPoint)
            btn_add:setVisible(true)
            btn_add:setTouchEnabled(true)
            btn_upgrade:setVisible(true)
            btn_upgrade:setTouchEnabled(true)
            if instCardIds then
                startFade()
            end
        elseif sender == btn_exp or sender == btn_cultivation then
            -- 经验丹, 潜力丹
            image_hint:setOpacity(255)
            image_hint:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1), cc.DelayTime:create(0.1), cc.CallFunc:create( function()
                image_hint:setOpacity(255)
            end ))))
            stopFade()
            if sender == btn_exp then
                sender:getChildByName("text_exp"):setTextColor(cc.c4b(51, 25, 4, 255))
            elseif sender == btn_cultivation then
                sender:getChildByName("text_cultivation"):setTextColor(cc.c4b(51, 25, 4, 255))
            end
            ui_upgradePanel:setVisible(false)
            ui_expPanel:setVisible(true)
            btn_exit:setPosition(cc.p(btn_add:getPositionX(), btn_add:getPositionY()))
            btn_add:setVisible(false)
            btn_add:setTouchEnabled(false)
            btn_upgrade:setVisible(false)
            btn_upgrade:setTouchEnabled(false)
            setPill()
        end
    end
end
local function isEmpty(param)
    local totalNumber = 0
    if param then
        local _tempParam = utils.stringSplit(param, ";")
        totalNumber = #_tempParam
    end
    return totalNumber
end;
function UICardUpgrade.init()
    local cardInfoRoot = ccui.Helper:seekNodeByName(UICardUpgrade.Widget, "image_basecolour")
    ui_cardQuality = cardInfoRoot:getChildByName("image_base_name")

    ui_pageView = ccui.Helper:seekNodeByName(UICardUpgrade.Widget, "page_card")
    local ui_cardIcon = ui_pageView:getChildByName("panel_card"):getChildByName("image_card")
    ui_pageViewItem = ui_pageView:getChildByName("panel_card"):clone()

    ui_cardName = ui_cardQuality:getChildByName("text_name")
    ui_cardLv = ui_cardQuality:getChildByName("text_lv")
    ui_cardLvUp = ui_cardQuality:getChildByName("text_lv_up")
    ui_cardExpBar = ccui.Helper:seekNodeByName(cardInfoRoot, "bar_exp")
    ui_cardExpLabel = ui_cardExpBar:getChildByName("text_exp")
    ui_cardExpBarNew = ccui.Helper:seekNodeByName(cardInfoRoot, "bar_exp_new")
    ui_propertyPanel = cardInfoRoot:getChildByName("image_base_property")
    image_hint = ccui.Helper:seekNodeByName(UICardUpgrade.Widget, "image_hint")
    local btn_l = ccui.Helper:seekNodeByName(UICardUpgrade.Widget, "btn_l")
    local btn_r = ccui.Helper:seekNodeByName(UICardUpgrade.Widget, "btn_r")

    local image_base_upgrade = ccui.Helper:seekNodeByName(UICardUpgrade.Widget, "image_base_upgrade")
    ui_upgradePanel = ccui.Helper:seekNodeByName(image_base_upgrade, "image_base_cost_card")
    ui_expPanel = ccui.Helper:seekNodeByName(image_base_upgrade, "image_base_cost_exp")
    for i = 1, 5 do
        local btn_eat = ccui.Helper:seekNodeByName(ui_upgradePanel, "image_frame_card" .. i)
        btn_eat:setTag(i)
        btn_eat:setTouchEnabled(true)
        local function btn_eatEvent(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if instCardIds and isEmpty(instCardIds) >= sender:getTag() then
                    table.remove(selectedInstCardIds, sender:getTag())
                    UICardUpgrade.setSelectedInstCardIds(selectedInstCardIds)
                else
                    UIBagCardSell.setOperateType(UIBagCardSell.OperateType.CardUpgrade, _curInstCardId, instCardIds)
                    UIManager.pushScene("ui_bag_card_sell")
                end
            end
        end
        btn_eat:addTouchEventListener(btn_eatEvent)
    end

    btn_card = ccui.Helper:seekNodeByName(UICardUpgrade.Widget, "btn_card")
    btn_exp = ccui.Helper:seekNodeByName(UICardUpgrade.Widget, "btn_exp")
    btn_cultivation = ccui.Helper:seekNodeByName(UICardUpgrade.Widget, "btn_cultivation")
    local function middleBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            setTopButtonLabel(sender)
        end
    end
    btn_card:addTouchEventListener(middleBtnEvent)
    btn_exp:addTouchEventListener(middleBtnEvent)
    btn_cultivation:addTouchEventListener(middleBtnEvent)

    local btn_close = ccui.Helper:seekNodeByName(UICardUpgrade.Widget, "btn_close")
    btn_exit = ccui.Helper:seekNodeByName(UICardUpgrade.Widget, "btn_exit")
    btn_add = ccui.Helper:seekNodeByName(UICardUpgrade.Widget, "btn_add")
    btn_upgrade = ccui.Helper:seekNodeByName(UICardUpgrade.Widget, "btn_up")
    btn_close:setPressedActionEnabled(true)
    btn_exit:setPressedActionEnabled(true)
    btn_add:setPressedActionEnabled(true)
    btn_upgrade:setPressedActionEnabled(true)
    btn_l:setPressedActionEnabled(true)
    btn_r:setPressedActionEnabled(true)
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_close or sender == btn_exit then
                UIManager.popScene()
                UIManager.flushWidget(UIBagCard)
            elseif sender == btn_l then
                local index = ui_pageView:getCurPageIndex() -1
                if index < 0 then
                    index = 0
                end
                ui_pageView:scrollToPage(index)
            elseif sender == btn_r then
                local index = ui_pageView:getCurPageIndex() + 1
                if index > #ui_pageView:getPages() then
                    index = #ui_pageView:getPages()
                end
                ui_pageView:scrollToPage(index)
            elseif sender == btn_add then
                if net.InstPlayerCard then

                    if instCardIds then
                        selectedInstCardIds = utils.stringSplit(instCardIds, ";")
                    end
                    local function isContain(instCardId)
                        for key, obj in pairs(selectedInstCardIds) do
                            if instCardId == tonumber(obj) then
                                return true
                            end
                        end
                        return false
                    end
                    for key, obj in pairs(net.InstPlayerCard) do
                        local instCardId = obj.int["1"]
                        -- 卡牌实例ID
                        local qualityId = obj.int["4"]
                        -- 品阶ID
                        local isTeam = obj.int["10"]
                        -- 是否在队伍中 0-不在 1-在
                        local isLock = obj.int["15"]
                        -- 是否锁定 0-不锁 1-锁
                        if qualityId == StaticQuality.white and not isContain(instCardId) and _curInstCardId ~= instCardId and isTeam == 0 and isLock == 0 then
                            if #selectedInstCardIds >= 5 then
                                break
                            else
                                selectedInstCardIds[#selectedInstCardIds + 1] = obj.int["1"]
                            end
                        end
                    end
                    UICardUpgrade.setSelectedInstCardIds(selectedInstCardIds)
                    if selectedInstCardIds and #selectedInstCardIds == 0 then
                        UIManager.showToast(Lang.ui_card_upgrade13)
                    end
                end
                UIGuidePeople.isGuide(btn_upgrade, UICardUpgrade)
            elseif sender == btn_upgrade then
                if _curCardLevel >= net.InstPlayer.int["4"] then
                    UIManager.showToast(Lang.ui_card_upgrade14)
                    return
                end
                if instCardIds then
                    if tonumber(net.InstPlayer.string["6"]) >= _price then
                        cclog("&&&&&&&----------->>>> instCardIds = " .. instCardIds)
                        local sendData = nil
                        if UIGuidePeople.guideStep == "6B6" then
                            sendData = {
                                header = StaticMsgRule.deleteCard,
                                msgdata =
                                {
                                    int =
                                    {
                                        eatInstCardId = _curInstCardId
                                    },
                                    string =
                                    {
                                        instCardIdList = instCardIds,
                                        step = "6B7"
                                    }
                                }
                            }
                        else
                            sendData = {
                                header = StaticMsgRule.deleteCard,
                                msgdata =
                                {
                                    int =
                                    {
                                        eatInstCardId = _curInstCardId
                                    },
                                    string =
                                    {
                                        instCardIdList = instCardIds
                                    }
                                }
                            }
                        end
                        UIManager.showLoading()
                        netSendPackage(sendData, netCallbackFunc)
                    else
                        UIManager.showToast(Lang.ui_card_upgrade15)
                    end
                else
                    UIManager.showToast(Lang.ui_card_upgrade16)
                end
            end
        end
    end
    btn_close:addTouchEventListener(btnEvent)
    btn_exit:addTouchEventListener(btnEvent)
    btn_add:addTouchEventListener(btnEvent)
    btn_upgrade:addTouchEventListener(btnEvent)
    btn_l:addTouchEventListener(btnEvent)
    btn_r:addTouchEventListener(btnEvent)
    ui_totalMoney = ccui.Helper:seekNodeByName(ui_expPanel, "text_hint")
    ui_cultivation = ccui.Helper:seekNodeByName(ui_expPanel, "text_cultivation")
    local eX, eY = btn_exit:getPosition()
    _btnExitPoint = cc.p(eX, eY)
    _cardIconPoint = ui_cardIcon:getParent():convertToWorldSpace(cc.p(ui_cardIcon:getPositionX(), ui_cardIcon:getPositionY()))
    _cardExpBarPoint = ui_cardExpBar:getParent():convertToWorldSpace(cc.p(ui_cardExpBar:getPositionX(), ui_cardExpBar:getPositionY()))
end

function UICardUpgrade.setup()
    cleanPageView()

    if _curInstCardId then
        local instPlayerCardData = net.InstPlayerCard[tostring(_curInstCardId)]
        local _tempCardId = instPlayerCardData.int["3"]

        if not _pvCardData then
            _pvCardData = { { dictId = net.InstPlayerCard[tostring(_curInstCardId)].int["3"], instId = _curInstCardId } }
        end

        ccui.Helper:seekNodeByName(UICardUpgrade.Widget, "btn_l"):setVisible(#_pvCardData > 1)
        ccui.Helper:seekNodeByName(UICardUpgrade.Widget, "btn_r"):setVisible(#_pvCardData > 1)

        for key, obj in pairs(_pvCardData) do
            local pageViewItem = ui_pageViewItem:clone()
            pageViewItem:setTag(obj.dictId)
            if _tempCardId == obj.dictId then
                _pageIndex = key - 1
            end
            local dictCardData = DictCard[tostring(obj.dictId)]
            if dictCardData then
                local _isAwake = net.InstPlayerCard[tostring(obj.instId)].int["18"]
                local cardImagePath = "image/" .. DictUI[tostring(_isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId)].fileName
                pageViewItem:getChildByName("image_card"):loadTexture(cardImagePath)
            end
            ui_pageView:addPage(pageViewItem)
        end
        ui_pageView:addEventListener(pageViewEvent)

        ui_pageView:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create( function()
            ui_pageView:scrollToPage(_pageIndex)
        end )))

        initCardInfo()
    end
    setTopButtonLabel(btn_card)
    UICardUpgrade.setSelectedInstCardIds(nil)
    local param = { }
    param[1] = btn_add
    param[2] = setTopButtonLabel
    UIGuidePeople.isGuide(param, UICardUpgrade)
    checkImageHint()
end

function UICardUpgrade.setInstPlayerCardId(uiItem, id, pvCardData)
    _uiItem = uiItem
    _curInstCardId = id
    _pvCardData = pvCardData
end

function UICardUpgrade.setSelectedInstCardIds(selectedInstCardIds1)
    if not selectedInstCardIds1 then
        selectedInstCardIds = { }
    else
        selectedInstCardIds = selectedInstCardIds1
    end
    local totalExp = 0
    instCardIds = nil
    for i = 1, 5 do
        local btn_eat = ccui.Helper:seekNodeByName(ui_upgradePanel, "image_frame_card" .. i)
        btn_eat:loadTexture("ui/card_small_white.png")
        btn_eat:getChildByName("image_card" .. i):loadTexture("ui/frame_tianjia.png")
    end
    if selectedInstCardIds and #selectedInstCardIds > 0 then
        for key, id in pairs(selectedInstCardIds) do
            local btn_eat = ccui.Helper:seekNodeByName(ui_upgradePanel, "image_frame_card" .. key)
            local btnImg = btn_eat:getChildByName("image_card" .. key)
            local instCardData = net.InstPlayerCard[tostring(id)]
            local dictCardData = DictCard[tostring(instCardData.int["3"])]
            totalExp = totalExp + getCardTotalExp(instCardData.int["9"], instCardData.int["8"])
            btn_eat:loadTexture(utils.getQualityImage(dp.Quality.card, instCardData.int["4"], dp.QualityImageType.small))
            btnImg:loadTexture("image/" .. DictUI[tostring(dictCardData.smallUiId)].fileName)
            if instCardIds == nil then
                instCardIds = ""
            end
            if key == #selectedInstCardIds then
                instCardIds = instCardIds .. tostring(id)
            else
                instCardIds = instCardIds .. tostring(id) .. ";"
            end
        end
    end
    _price = DictSysConfig[tostring(StaticSysConfig.eatExpCopper)].value * totalExp
    ccui.Helper:seekNodeByName(ui_upgradePanel, "text_gold_need"):setString(Lang.ui_card_upgrade17 .. _price)
    -- 所需金币
    ccui.Helper:seekNodeByName(ui_upgradePanel, "text_get_exp"):setString(Lang.ui_card_upgrade18 .. totalExp)
    -- 获得经验

    if totalExp >= 0 then
        stopFade()
        _prevLv = _curCardLevel
        _tempExp, _tempLv = _curCardExp + totalExp, _curCardLevel
        local function onCardUpgrade()
            local maxExp = DictCardExp[tostring(_tempLv)].exp
            if _tempExp >= maxExp then
                _tempExp = _tempExp - maxExp
                _tempLv = _tempLv + 1
                onCardUpgrade()
            end
        end
        onCardUpgrade()
        startFade()
        _tempPercent = _tempExp / DictCardExp[tostring(_tempLv)].exp * 100
        if _tempLv > _prevLv then
            _addValue =(_tempLv - _prevLv) * 2 + 1
        else
            _addValue = 5
        end
    end

end

function UICardUpgrade.free()
    instCardIds = nil
    stopFade()
    _cardPropValue = nil
    UIGuidePeople.isGuide(nil, UICardUpgrade)
end
