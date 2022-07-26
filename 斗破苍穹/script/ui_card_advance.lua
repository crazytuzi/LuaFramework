require"Lang"
UICardAdvance = {}

local ui_curCardFrameBg = nil
local ui_newCardFrameBg = nil
local ui_cardPropPanel = nil
local ui_scrollView = nil
local ui_svItem = nil

local _cardImagePath = nil
local _cardQualityImagePath = nil
local _cardNextStarLv = 1
local _instCardId = nil
local _uiItem = nil
local _unJudeIndexs = "" --未达标的下标索引
local _skillOpenName = nil
local _skillNameColor = nil

local function cleanScrollView(_isRelease)
    if _isRelease then
        if ui_svItem and ui_svItem:getReferenceCount() >= 1 then
            ui_svItem:release()
            ui_svItem = nil
        end
        if ui_scrollView then
            ui_scrollView:removeAllChildren()
            ui_scrollView = nil
        end
    else
        if ui_svItem:getReferenceCount() == 1 then
            ui_svItem:retain()
        end
        ui_scrollView:removeAllChildren()
    end
end

local function layoutScrollView(_listData, _initItemFunc)
    cleanScrollView()
    ui_scrollView:jumpToTop()
    local innerHeight, _spaceH = 0, 5
    for key, obj in pairs(_listData) do
        local scrollViewItem = ui_svItem:clone()
        _initItemFunc(scrollViewItem, obj)
        ui_scrollView:addChild(scrollViewItem)
        innerHeight = innerHeight + scrollViewItem:getContentSize().height + _spaceH
    end
    innerHeight = innerHeight + _spaceH
    if innerHeight < ui_scrollView:getContentSize().height then
        innerHeight = ui_scrollView:getContentSize().height
    end
    ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, innerHeight))
    local childs = ui_scrollView:getChildren()
    local prevChild = nil
    for i = 1, #childs do
        local _anchorPoint = childs[i]:getAnchorPoint()
        if prevChild then
            childs[i]:setPosition(cc.p(ui_scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - _spaceH))
        else
            childs[i]:setPosition(cc.p(ui_scrollView:getContentSize().width / 2, ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - _spaceH))
        end
        prevChild = childs[i]
    end
end

local function netCallbackFunc(data)
	if UIGuidePeople.guideStep then
		local data = {
	    header = StaticMsgRule.guidStep,
	    msgdata = {
	      string = {
	        step  = "4B5",
	      }
	    }
	  }
	  netSendPackage(data)
	end
	local function animCallbackFunc()
		if UICardAdvance.setup() then
			UIManager.showToast(Lang.ui_card_advance1)
			UIManager.popScene()
		end
		if _uiItem == UICardInfo then
			UICardInfo.setup()
			UILineup.setup()
        else
            UIManager.flushWidget(UIBagCard)
		end
	end
	
	local _effectBg = cc.LayerColor:create(cc.c4b(0, 0, 0, 200))
	UICardAdvance.Widget:addChild(_effectBg, 999)
	local animation = ActionManager.getUIAnimation(3, animCallbackFunc)
	animation:setScale(2)
	animation:getBone("renwu"):addDisplay(ccs.Skin:create(_cardImagePath), 0)
	animation:getBone("renwu2"):addDisplay(ccs.Skin:create(_cardImagePath), 0)
	animation:getBone("kapai"):addDisplay(ccs.Skin:create(_cardQualityImagePath), 0)
	animation:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
	UIManager.uiLayer:addChild(animation, 1000)
	local function onFrameEvent(bone, evt, originFrameIndex, currentFrameIndex)
		if evt == "xingxing" and _cardNextStarLv > 0 then
			local starCount = _cardNextStarLv
			local i = 1
			local function runAction()
				local _starImg = ccui.ImageView:create("ui/pai_star.png")
				_starImg:setScale(5)
				animation:addChild(_starImg, 1000)
				local x = 0
				if starCount == 2 then
					if i == 1 then x = -30 else x = 30 end
				elseif starCount == 3 then
					if i == 1 then x = -50 elseif i == 3 then x = 50 end
				elseif starCount == 4 then
					if i == 1 then x = -85 elseif i == 2 then x = -30 elseif i == 3 then x = 30 elseif i == 4 then x = 85 end
				elseif starCount == 5 then
					if i == 1 then x = -120 elseif i == 2 then x = -60 elseif i == 4 then x = 60 elseif i == 5 then x = 120 end
				end
				_starImg:setPosition(cc.p(x, -100))
				if i == starCount then
					_starImg:runAction(cc.Sequence:create(cc.RotateBy:create(0.2, 360), cc.ScaleTo:create(0.06, 2)))
				else
					_starImg:runAction(cc.Sequence:create(cc.RotateBy:create(0.2, 360), cc.ScaleTo:create(0.06, 2), cc.CallFunc:create(runAction)))
				end
				i = i + 1
			end
			runAction()
		elseif evt == "ka" then
			_effectBg:runAction(cc.Sequence:create(cc.FadeTo:create(0.3, 0), cc.CallFunc:create(function() _effectBg:removeFromParent() end)))
		end
	end
	animation:getAnimation():setFrameEventCallFunc(onFrameEvent)

	if _skillOpenName then
		local skillLabel = ccui.Text:create(Lang.ui_card_advance2, dp.FONT, 35)
		skillLabel:setPosition(UIManager.screenSize.width / 2, 180)
		local skillName = ccui.Text:create("【" .. _skillOpenName .. "】", dp.FONT, 35)
		skillName:setTextColor(_skillNameColor)
		skillName:setAnchorPoint(0.5, 1)
		skillName:setPosition(skillLabel:getContentSize().width / 2, 0)
		skillLabel:addChild(skillName)
		UIManager.uiLayer:addChild(skillLabel, 1001)
		skillLabel:runAction(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, 30)), cc.DelayTime:create(1.5), cc.CallFunc:create(function()
				skillLabel:removeFromParent()
				_skillOpenName = nil
			end)))
	end
end

function UICardAdvance.init()
	local btn_close = ccui.Helper:seekNodeByName(UICardAdvance.Widget, "btn_close")
	local btn_exit = ccui.Helper:seekNodeByName(UICardAdvance.Widget, "btn_exit")
	local btn_break = ccui.Helper:seekNodeByName(UICardAdvance.Widget, "btn_break")
    local btn_awaken = ccui.Helper:seekNodeByName(UICardAdvance.Widget, "btn_awaken")
	btn_close:setPressedActionEnabled(true)
	btn_exit:setPressedActionEnabled(true)
	btn_break:setPressedActionEnabled(true)
	btn_awaken:setPressedActionEnabled(true)
	local function btnTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			if sender == btn_close or sender == btn_exit then
				UIManager.popScene()
				UIGuidePeople.isGuide(nil,UICardAdvance)
			elseif sender == btn_break then
				if btn_break:isBright() then
					local isJude = true
                    local childs = ui_scrollView:getChildren()
					for key, obj in pairs(childs) do
						if obj:getTag() ~= 1 then
                            local warning = obj:getChildByName("image_term_fg1")
							warning:stopAllActions()
							isJude = false
							warning:setVisible(true)
							warning:setOpacity(255)
							warning:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeTo:create(0.15, 0),
								cc.DelayTime:create(0.1), cc.FadeTo:create(0.15, 255), cc.DelayTime:create(0.3), cc.FadeTo:create(0.15, 0),
								cc.CallFunc:create(function() warning:setVisible(false) warning:setOpacity(255) end)))
						end
					end
					if isJude then
						local sendData = {
							header = StaticMsgRule.cardAdvance,
							msgdata = {
								int = {
									instPlayerCardId = _instCardId
								}
							}
						}
                        local sendData = nil
                        if UIGuidePeople.guideStep == "4B4" then
                            sendData = {
							    header = StaticMsgRule.cardAdvance,
							    msgdata = {
								    int = {
									    instPlayerCardId = _instCardId
								    },
                                    string = {
                                        step = "4B5"
                                    }
							    }
						    }
                        else
                            sendData = {
							    header = StaticMsgRule.cardAdvance,
							    msgdata = {
								    int = {
									    instPlayerCardId = _instCardId
								    }
							    }
						    }
                        end
						UIManager.showLoading()
						netSendPackage(sendData, netCallbackFunc)
					else
	--					UIManager.showToast("进阶条件尚未达标！")
					end
				else
					UIManager.showToast(Lang.ui_card_advance3)
				end
            elseif sender == btn_awaken then
                UICardAwaken.show({ InstPlayerCard_id = _instCardId })
			end
		end
	end
	btn_close:addTouchEventListener(btnTouchEvent)
	btn_exit:addTouchEventListener(btnTouchEvent)
	btn_break:addTouchEventListener(btnTouchEvent)
	btn_awaken:addTouchEventListener(btnTouchEvent)
	
	ui_curCardFrameBg = ccui.Helper:seekNodeByName(UICardAdvance.Widget, "image_base_before")
	ui_newCardFrameBg = ccui.Helper:seekNodeByName(UICardAdvance.Widget, "image_base_after")
	local image_info_l = ccui.Helper:seekNodeByName(UICardAdvance.Widget, "image_info_l")
	ui_cardPropPanel = image_info_l:getChildByName("image_info_r")
	
	local image_base_term = ccui.Helper:seekNodeByName(UICardAdvance.Widget, "image_base_term")
    ui_scrollView = ccui.Helper:seekNodeByName(image_base_term, "view_condition")
    ui_svItem = ui_scrollView:getChildByName("image_term"):clone()
end

function UICardAdvance.setup()
    cleanScrollView()
	UIGuidePeople.isGuide(nil,UICardAdvance)
    local btn_awaken = ccui.Helper:seekNodeByName(UICardAdvance.Widget, "btn_awaken")
    btn_awaken:setVisible(false)
	if net.InstPlayerCard and _instCardId then
		local instPlayerCardData = net.InstPlayerCard[tostring(_instCardId)]
		local dictCardId = instPlayerCardData.int["3"] --卡牌字典ID
		local qualityId = instPlayerCardData.int["4"] --卡牌品阶ID
        local isAwake = instPlayerCardData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒
		if qualityId > 0 then
            local dictCardData = DictCard[tostring(dictCardId)] --卡牌字典表
			local starLevelId = instPlayerCardData.int["5"] --卡牌星级ID
            if dictCardData.isCanAwake == 1 and isAwake == 0 and qualityId >= StaticQuality.gold then
                if qualityId == StaticQuality.gold then
                    if starLevelId >= 3 then --//////只有金品2阶及以上的卡牌才可觉醒
                        btn_awaken:setVisible(true)
                    end
                else
                    btn_awaken:setVisible(true)
                end
            end
			-- if qualityId == StaticQuality.purple and starLevelId == DictQuality[tostring(StaticQuality.purple)].maxStarLevel + 1 then
			-- 	cclog("==============>>>>  已经是最高品阶了！！！")
			-- 	return true
			-- end
			local cardLevel = instPlayerCardData.int["9"] --卡牌等级
			UICardAdvance.Widget:getChildByName("image_basemap"):getChildByName("image_lv"):getChildByName("text_lv"):setString(Lang.ui_card_advance4 .. cardLevel)
			local ui_curCardQualityBg = ui_curCardFrameBg:getChildByName("image_advance_before")
			ui_curCardQualityBg:loadTexture(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.middle, true))
			ui_curCardQualityBg:getChildByName("text_product"):setString(DictQuality[tostring(qualityId)].name .. DictStarLevel[tostring(starLevelId)].name)
			ui_curCardFrameBg:loadTexture(utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.middle))
			_cardImagePath = "image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId)].fileName
			ui_curCardFrameBg:getChildByName("image_warrior"):loadTexture(_cardImagePath)

			local image_arrow1 = ui_cardPropPanel:getChildByName("image_arrow1")
			local image_arrow2 = ui_cardPropPanel:getChildByName("image_arrow2")
			local image_arrow3 = ui_cardPropPanel:getChildByName("image_arrow3")
			local image_arrow4 = ui_cardPropPanel:getChildByName("image_arrow4")
			local image_arrow5 = ui_cardPropPanel:getChildByName("image_arrow5")
			image_arrow1:getChildByName("text_blood_before"):setString(tostring(formula.getCardBlood(cardLevel, qualityId, starLevelId, dictCardData)))
			image_arrow2:getChildByName("text_attack_gas_before"):setString(tostring(formula.getCardGasAttack(cardLevel, qualityId, starLevelId, dictCardData)))
			image_arrow3:getChildByName("text_defense_gas_before"):setString(tostring(formula.getCardGasDefense(cardLevel, qualityId, starLevelId, dictCardData)))
			image_arrow4:getChildByName("text_attack_soul_before"):setString(tostring(formula.getCardSoulAttack(cardLevel, qualityId, starLevelId, dictCardData)))
			image_arrow5:getChildByName("text_defense_soul_before"):setString(tostring(formula.getCardSoulDefense(cardLevel, qualityId, starLevelId, dictCardData)))
			
			local _newDictData = nil
			for key, obj in pairs(DictAdvance) do
				if dictCardData.id == obj.cardId and obj.qualityId == qualityId and obj.starLevelId == starLevelId then
					_newDictData = obj
					break
				end
			end
			
			local image_hint = UICardAdvance.Widget:getChildByName("image_basemap"):getChildByName("image_hint")
			local btn_break = UICardAdvance.Widget:getChildByName("image_basemap"):getChildByName("btn_break")
			if _newDictData then
				image_hint:setVisible(false)
				btn_break:setBright(true)
				ui_newCardFrameBg:setVisible(true)
				if qualityId < _newDictData.nextQualityId then
					-- if _newDictData.nextQualityId == StaticQuality.blue then
					-- 	_skillOpenName = SkillManager[dictCardData.skillTwo].name
					-- 	_skillNameColor = cc.c3b(148, 0, 211)
					if _newDictData.nextQualityId == StaticQuality.purple then
						_skillOpenName = SkillManager[dictCardData.skillThree].name
						_skillNameColor = cc.c3b(255, 165, 0)
					end
				end
				_cardQualityImagePath = utils.getQualityImage(dp.Quality.card, _newDictData.nextQualityId, dp.QualityImageType.middle)
				_cardNextStarLv = _newDictData.nextStarLevelId - 1
				ui_newCardFrameBg:loadTexture(_cardQualityImagePath)
				ui_newCardFrameBg:getChildByName("image_warrior"):loadTexture("image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId)].fileName)

				image_arrow1:getChildByName("text_blood_after"):setString(tostring(formula.getCardBlood(cardLevel, _newDictData.nextQualityId, _newDictData.nextStarLevelId, dictCardData)))
				image_arrow2:getChildByName("text_attack_gas_after"):setString(tostring(formula.getCardGasAttack(cardLevel, _newDictData.nextQualityId, _newDictData.nextStarLevelId, dictCardData)))
				image_arrow3:getChildByName("text_defense_gas_after"):setString(tostring(formula.getCardGasDefense(cardLevel, _newDictData.nextQualityId, _newDictData.nextStarLevelId, dictCardData)))
				image_arrow4:getChildByName("text_attack_soul_after"):setString(tostring(formula.getCardSoulAttack(cardLevel, _newDictData.nextQualityId, _newDictData.nextStarLevelId, dictCardData)))
				image_arrow5:getChildByName("text_defense_soul_after"):setString(tostring(formula.getCardSoulDefense(cardLevel, _newDictData.nextQualityId, _newDictData.nextStarLevelId, dictCardData)))

				local ui_newCardQualityBg = ui_newCardFrameBg:getChildByName("image_advance_after")
				ui_newCardQualityBg:loadTexture(utils.getQualityImage(dp.Quality.card, _newDictData.nextQualityId, dp.QualityImageType.middle, true))
				ui_newCardQualityBg:getChildByName("text_product"):setString(DictQuality[tostring(_newDictData.nextQualityId)].name .. DictStarLevel[tostring(_newDictData.nextStarLevelId)].name)
				
				ui_cardPropPanel:getChildByName("text_blood"):setString(Lang.ui_card_advance5 .. tonumber(image_arrow1:getChildByName("text_blood_after"):getString()) - tonumber(image_arrow1:getChildByName("text_blood_before"):getString()))
				ui_cardPropPanel:getChildByName("text_attack_gas"):setString(Lang.ui_card_advance6 .. tonumber(image_arrow2:getChildByName("text_attack_gas_after"):getString()) - tonumber(image_arrow2:getChildByName("text_attack_gas_before"):getString()))
				ui_cardPropPanel:getChildByName("text_defense_gas"):setString(Lang.ui_card_advance7 .. tonumber(image_arrow3:getChildByName("text_defense_gas_after"):getString()) - tonumber(image_arrow3:getChildByName("text_defense_gas_before"):getString()))
				ui_cardPropPanel:getChildByName("text_attack_soul"):setString(Lang.ui_card_advance8 .. tonumber(image_arrow4:getChildByName("text_attack_soul_after"):getString()) - tonumber(image_arrow4:getChildByName("text_attack_soul_before"):getString()))
				ui_cardPropPanel:getChildByName("text_defense_soul"):setString(Lang.ui_card_advance9 .. tonumber(image_arrow5:getChildByName("text_defense_soul_after"):getString()) - tonumber(image_arrow5:getChildByName("text_defense_soul_before"):getString()))
				
                local _listData = {}
				local conds = utils.stringSplit(_newDictData.conds, ";")
				for key, obj in pairs(conds) do
                    local _tempListData = {
                        condsDesc = "●",
                        isJude = 0, --0:未达成，1:已达成
                    }
					local data = utils.stringSplit(obj, "_")
					if tonumber(data[1]) == 1 then --卡片等级_此卡牌等级
                        _tempListData.condsDesc = _tempListData.condsDesc .. Lang.ui_card_advance10 .. data[2]
						if cardLevel >= tonumber(data[2]) then --已达标
                            _tempListData.isJude = 1
						end
					elseif tonumber(data[1]) == 2 then --卡牌开启第几个命宫_
						local _instConstellIds = instPlayerCardData.string["13"] --玩家命宫实例
						local instConstellId_table = utils.stringSplit(_instConstellIds, ";")
						for k_, id in pairs(instConstellId_table) do
							if k_ == tonumber(data[2]) then
								local instConstellData = net.InstPlayerConstell[tostring(id)] --命宫实例数据
                                _tempListData.condsDesc = _tempListData.condsDesc .. Lang.ui_card_advance11 .. DictConstell[tostring(instConstellData.int["4"])].name
								local isUse = instConstellData.string["5"] --命宫丹药状态 0-未服用 1-服用（全为1表示该命宫点亮）
								local _isUses = utils.stringSplit(isUse, ";")
								local _open = ""
								for i = 1, #_isUses do
									if i == #_isUses then
										_open = _open .. "1"
									else
										_open = _open .. "1;"
									end
								end
								if isUse == _open then --已达标
                                    _tempListData.isJude = 1
								end
								break
							end
						end
					elseif tonumber(data[1]) == 3 then --有一张或多张指定的卡牌_(品质Id_星级Id_张数)
						local inTeam = instPlayerCardData.int["10"] --是否在队伍中 0-不在 1-在
						local _dictQualityData = DictQuality[tostring(data[2])]
						local _dictStarLevelData = DictStarLevel[tostring(data[3])]
                        _tempListData.condsDesc = _tempListData.condsDesc .. Lang.ui_card_advance12 .. dictCardData.name .. "（" .. _dictQualityData.name .. _dictStarLevelData.name .. "）X" .. data[4]
						local _count, _size = 0, 0
--						if inTeam == 0 then
--							_size = _size + 1
--                        else
                            _size = tonumber(data[4])
--						end
                        if inTeam == 0 and tonumber( data[ 3 ] ) == instPlayerCardData.int["5"] then
                            _size = _size + 1
                        end
						for cardKey, cardObj in pairs(net.InstPlayerCard) do
							local _dictCardId = cardObj.int["3"]
							local _qualityId = cardObj.int["4"]
							local _starLevelId = cardObj.int["5"]
							local _inTeam = cardObj.int["10"]
							if _inTeam == 0 and _dictCardId == dictCardId and _qualityId == tonumber(data[2]) and _starLevelId == tonumber(data[3]) then
								_count = _count + 1
								if _count >= _size then --已达标
                                    _tempListData.isJude = 1
									break
								end
							end 
						end
					elseif tonumber(data[1]) == 4 then --卡牌称号达到什么阶段_详细称号字典表的Id
                        _tempListData.condsDesc = _tempListData.condsDesc .. Lang.ui_card_advance13 .. DictTitleDetail[data[2]].description
						if instPlayerCardData.int["6"] >= tonumber(data[2]) then --已达标
                            _tempListData.isJude = 1
						end
					elseif tonumber(data[1]) == 5 then --升级材料_(物品Id_材料个数)
						local _thingId = tonumber(data[2])
						local _thingNum = tonumber(data[3])
						local _haveThingNums = utils.getThingCount(_thingId)
                        _tempListData.condsDesc = _tempListData.condsDesc .. Lang.ui_card_advance14 .. DictThing[tostring(_thingId)].name .. " " .. _haveThingNums .. "/" .. _thingNum
						if _haveThingNums >= _thingNum then --已达标
                            _tempListData.isJude = 1
						end
                    elseif tonumber(data[1]) == 6 then --吞噬异火(_异火ID)
                        local _dictFireId = tonumber(data[2])
                        _tempListData.condsDesc = _tempListData.condsDesc .. Lang.ui_card_advance15 .. DictYFire[tostring(_dictFireId)].name
                        if net.InstPlayerYFire then
                            for _keyYFire, _objYFire in pairs(net.InstPlayerYFire) do
                                if _objYFire.int["3"] == _dictFireId and _objYFire.int["4"] > 0 then --已达标
                                    _tempListData.isJude = 1
                                    break
                                end
                            end
                        end
					end
                    _listData[#_listData + 1] = _tempListData
                    _tempListData = nil
				end
                utils.quickSort(_listData, function(obj1, obj2) if obj1.isJude > obj2.isJude then return true end end)
                layoutScrollView(_listData, function(_item, _data)
                    _item:setTag(_data.isJude)
                    local ui_conds = _item:getChildByName("text_term1")
                    local ui_judge = _item:getChildByName("image_judge1")
                    _item:getChildByName("image_term_fg1"):setVisible(false)
                    ui_conds:setString(_data.condsDesc)
                    if _data.isJude == 1 then
                        ui_conds:setTextColor(cc.c4b(0, 255, 0, 255))
                        ui_judge:loadTexture("ui/right.png")
                    else
                        ui_conds:setTextColor(cc.c4b(255, 0, 0, 255))
                        ui_judge:loadTexture("ui/wrong.png")
                    end
                end)
			else
				cclog("---------------ERROR:该卡牌进阶数据错误---------------")
				btn_break:setBright(false)
				ui_newCardFrameBg:setVisible(false)
				image_hint:setVisible(true)

				image_arrow1:getChildByName("text_blood_after"):setString("0")
				image_arrow2:getChildByName("text_attack_gas_after"):setString("0")
				image_arrow3:getChildByName("text_defense_gas_after"):setString("0")
				image_arrow4:getChildByName("text_attack_soul_after"):setString("0")
				image_arrow5:getChildByName("text_defense_soul_after"):setString("0")

				ui_cardPropPanel:getChildByName("text_blood"):setString(Lang.ui_card_advance16)
				ui_cardPropPanel:getChildByName("text_attack_gas"):setString(Lang.ui_card_advance17)
				ui_cardPropPanel:getChildByName("text_defense_gas"):setString(Lang.ui_card_advance18)
				ui_cardPropPanel:getChildByName("text_attack_soul"):setString(Lang.ui_card_advance19)
				ui_cardPropPanel:getChildByName("text_defense_soul"):setString(Lang.ui_card_advance20)
			end
		else
			cclog("---------------ERROR:该卡牌不能进阶---------------")
		end
	end
end

function UICardAdvance.setInstPlayerCardId(uiItem, instCardId)
	_uiItem = uiItem
	_instCardId = instCardId
end

function UICardAdvance.free()
	_skillOpenName = nil
	_skillNameColor = nil
    cleanScrollView(true)
end
