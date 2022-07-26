require"Lang"
UIBeauty = {
	BEAUTY_STATE_XH = -1, --未邂逅状态
	BEAUTY_STATE_ZF =  0, --未征服状态
	BEAUTY_STATE_JH =  1 --激活状态
}

local BTN_TEXT_1 = Lang.ui_beauty1
local BTN_TEXT_2 = Lang.ui_beauty2
local BTN_TEXT_3 = Lang.ui_beauty3

local TAG_ParticleEffect = -100
local TAG_AddPropEffect = -1000

local ThingData = nil
local scrollViewCloneItems = {}

local _isRefresh = false
local _curPageViewIndex = -1
local _thingItemImageView = nil

local netCallbackFunc = nil

local function playParticleEffect(_callFunc)
	local ui_pageView = ccui.Helper:seekNodeByName(UIBeauty.Widget, "page_beauty")
	local pvItem = ui_pageView:getPage(_curPageViewIndex)
	if pvItem:getChildByTag(TAG_ParticleEffect) then
		pvItem:getChildByTag(TAG_ParticleEffect):removeFromParent()
	end
	local effect = cc.ParticleSystemQuad:create("ani/ui_anim/ui_anim34/ui_anim_effect34.plist")
	effect:setPosition(pvItem:getContentSize().width / 2, pvItem:getContentSize().height / 2 - 50)
	effect:setScale(0.7)
	pvItem:addChild(effect, -1, TAG_ParticleEffect)
	local animEffect = ActionManager.getUIAnimation(34, function()
		if pvItem:getChildByTag(TAG_ParticleEffect) then
			pvItem:getChildByTag(TAG_ParticleEffect):removeFromParent()
		end
		if _callFunc then
			_callFunc()
		end
	end)
	animEffect:setPosition(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2)
	UIBeauty.Widget:addChild(animEffect, 100)
end

local function scrollViewLayout(scrollView, scrollViewData, scrollViewFunc, itemSpace)
	local svItem = nil

	if scrollViewCloneItems[scrollView:getName()] then
		svItem = scrollViewCloneItems[scrollView:getName()]
	elseif scrollView:getChildren()[1] then
		svItem = scrollView:getChildren()[1]:clone()
	end

	-- if scrollView:getChildren()[1] then
	-- 	svItem = scrollView:getChildren()[1]:clone()
	-- else
	-- 	svItem = scrollViewCloneItems[scrollView:getName()]
	-- end
	scrollViewCloneItems[scrollView:getName()] = svItem
	if svItem:getReferenceCount() == 1 then
		svItem:retain()
	end
	scrollView:removeAllChildren()
	if scrollView:getDirection() == dp.SCROLLVIEW_DIRECTION_VERTICAL then
		scrollView:jumpToTop()
	elseif scrollView:getDirection() == dp.SCROLLVIEW_DIRECTION_HORIZONTAL then
		scrollView:jumpToLeft()
	end
	local innerSize, space = 0, (itemSpace and itemSpace or 15)
	for key, obj in pairs(scrollViewData) do
		local scrollViewItem = svItem:clone()
		scrollView:addChild(scrollViewItem)
		if scrollView:getDirection() == dp.SCROLLVIEW_DIRECTION_VERTICAL then
			innerSize = innerSize + scrollViewItem:getContentSize().height + space
		elseif scrollView:getDirection() == dp.SCROLLVIEW_DIRECTION_HORIZONTAL then
			innerSize = innerSize + scrollViewItem:getContentSize().width + space
		end
	end
	innerSize = innerSize + space
	if scrollView:getDirection() == dp.SCROLLVIEW_DIRECTION_VERTICAL then
		if innerSize < scrollView:getContentSize().height then
			innerSize = scrollView:getContentSize().height
		end
		scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, innerSize))
	elseif scrollView:getDirection() == dp.SCROLLVIEW_DIRECTION_HORIZONTAL then
		if innerSize < scrollView:getContentSize().width then
			innerSize = scrollView:getContentSize().width
		end
		scrollView:setInnerContainerSize(cc.size(innerSize, scrollView:getContentSize().height))
	end
	local childs = scrollView:getChildren()
	local prevChild = nil
	for i = 1, #childs do
		if prevChild then
			if scrollView:getDirection() == dp.SCROLLVIEW_DIRECTION_VERTICAL then
				-- childs[i]:setPosition(cc.p(scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() + space + childs[i]:getContentSize().height / 2))
				childs[i]:setPositionY(prevChild:getBottomBoundary() - space - childs[i]:getContentSize().height / 2)
			elseif scrollView:getDirection() == dp.SCROLLVIEW_DIRECTION_HORIZONTAL then
				-- childs[i]:setPosition(cc.p(prevChild:getRightBoundary() + childs[i]:getContentSize().width / 2 + space, scrollView:getContentSize().height / 2))
				childs[i]:setPositionX(prevChild:getRightBoundary() + childs[i]:getContentSize().width / 2 + space)
			end
		else
			if scrollView:getDirection() == dp.SCROLLVIEW_DIRECTION_VERTICAL then
				-- childs[i]:setPosition(cc.p(scrollView:getContentSize().width / 2, scrollView:getContentSize().height - space - childs[i]:getContentSize().height / 2))
				childs[i]:setPositionY(innerSize - space - childs[i]:getContentSize().height / 2)
			elseif scrollView:getDirection() == dp.SCROLLVIEW_DIRECTION_HORIZONTAL then
				-- childs[i]:setPosition(cc.p(childs[i]:getContentSize().width / 2 + space, scrollView:getContentSize().height / 2))
				childs[i]:setPositionX(childs[i]:getContentSize().width / 2 + space)
			end
		end
		prevChild = childs[i]
	end
	for key, obj in pairs(scrollViewData) do
		local childs = scrollView:getChildren()
		scrollViewFunc(childs[key], obj)
	end
end

local function setScrollViewFocus(isJumpTo)
	local image_title = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_title")
	local ui_scrollView = image_title:getChildByName("view_warrior")
	local childs = ui_scrollView:getChildren()
	for key, obj in pairs(childs) do
		-- local ui_focus = obj:getChildByName("image_choose")
		if _curPageViewIndex + 1 == key then
			-- ui_focus:setVisible(true)
			
			local contaniner = ui_scrollView:getInnerContainer()
			local w = (contaniner:getContentSize().width - ui_scrollView:getContentSize().width)
			local dt
			if w == 0 then
				dt = 0
			else
				dt = (obj:getPositionX() + obj:getContentSize().width - ui_scrollView:getContentSize().width) / w
				if dt < 0 then
					dt = 0
				end
			end
			if isJumpTo then
				ui_scrollView:jumpToPercentHorizontal(dt * 100)
			else
				ui_scrollView:scrollToPercentHorizontal(dt * 100, 0.5, true)
			end
			
		else
			-- ui_focus:setVisible(false)
		end
	end
end

local function getBeautyState(dictBeautyCard)
	local _state, _isLock = UIBeauty.BEAUTY_STATE_XH, false
	if net.InstPlayerBeautyCard then
		for key, obj in pairs(net.InstPlayerBeautyCard) do
			if dictBeautyCard.id == obj.int["3"] then
				_isLock = true
				_state = UIBeauty.BEAUTY_STATE_JH
				break
			end
		end
	end
	if not _isLock and net.InstPlayerBarrier then
		for ipbKey, ipbObj in pairs(net.InstPlayerBarrier) do
			if ipbObj.int["3"] == dictBeautyCard.unblock then
				_state = UIBeauty.BEAUTY_STATE_ZF

				local conditions = utils.stringSplit(dictBeautyCard.conditions, "_") --[1]:tableTypeId, [2]:tableFieldId, [3]:value
				local tableTypeId, tableFieldId, value = tonumber(conditions[1]), tonumber(conditions[2]), tonumber(conditions[3])
				if tableTypeId == StaticTableType.DictPlayerBaseProp then
					if tableFieldId == StaticPlayerBaseProp.copper then
					elseif tableFieldId == StaticPlayerBaseProp.level then
						if net.InstPlayer.int["4"] >= value then
							_state = UIBeauty.BEAUTY_STATE_JH
						end
					else
						cclog("ERROR：-------->> 美人系统 tableFieldId=" .. tableFieldId)
					end
				elseif tableTypeId == StaticTableType.DictBarrier then
					if ipbObj.int["6"] >= value then
						_state = UIBeauty.BEAUTY_STATE_JH
					end
				else
					cclog("ERROR：-------->> 美人系统 tableTypeId=" .. tableTypeId)
				end

				break
			end
		end
	end
	return _state
end

local function getInstPlayerBeauty(dictBeautyId)
	if net.InstPlayerBeautyCard then
		for key, obj in pairs(net.InstPlayerBeautyCard) do
			if obj.int["3"] == dictBeautyId then
				return obj
			end
		end
	end
end

local function getBeautyFightData(_beautyCardId)
	local BeautyCardFight = {}
	for key, obj in pairs(DictBeautyCardFight) do
		if tonumber(_beautyCardId) == obj.beautyCardId then
			BeautyCardFight[#BeautyCardFight + 1] = obj
		end
	end
	utils.quickSort(BeautyCardFight, function(obj1, obj2) if obj1.beautyCardExpId > obj2.beautyCardExpId then return true end end)
	return BeautyCardFight
end

local function setIconSVData(item, data)
	item:setTag(data.id)
	local ui_icon = item:getChildByName("image_warior")
	local ui_hint = item:getChildByName("image_hint")
	ui_hint:setVisible(false)
	local iconFileName = DictUI[tostring(DictCard[tostring(data.cardId)].smallUiId)].fileName
	ui_icon:loadTexture("image/" .. iconFileName)
	item:setTouchEnabled(true)
	local function itemEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			local index = -1
			local ui_pageView = ccui.Helper:seekNodeByName(UIBeauty.Widget, "page_beauty")
			local pvChilds = ui_pageView:getChildren()
			for i = 1, #pvChilds do
				if pvChilds[i]:getTag() == data.id then
					index = i - 1
					break
				end
			end
			setScrollViewFocus()
			if index >= 0 then
				ui_pageView:scrollToPage(index)
			end
		end
	end
	item:addTouchEventListener(itemEvent)
	local _state = getBeautyState(data)
	if _state == UIBeauty.BEAUTY_STATE_XH then
		utils.GrayWidget(ui_icon, true)
		ui_icon:setTag(-1)
	elseif _state == UIBeauty.BEAUTY_STATE_ZF then
		ui_hint:setVisible(true)
		utils.GrayWidget(ui_icon, false)
		ui_icon:setTag(item:getTag())
	elseif  _state == UIBeauty.BEAUTY_STATE_JH then
		utils.GrayWidget(ui_icon, false)
		ui_icon:setTag(item:getTag())
	end
end

local function setPropSVData(item, data)
	local ui_xinNums = item:getChildByName("text_number")
	local ui_propName = item:getChildByName("text_property")
	local ui_propValue = item:getChildByName("text_add")
	ui_xinNums:setString(tostring(data.beautyCardExpId))
	ui_propName:setString(DictFightProp[tostring(data.fightPropId)].name)
	ui_propValue:setString("+" .. data.value)
	local image_di_name = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_di_name")
	local ui_nameImg = image_di_name:getChildByName("image_heart")
	local ui_level = ui_nameImg:getChildByName("text_number")
	local beautyLevel = tonumber(ui_level:getString())
	if ui_nameImg:isVisible() and beautyLevel >= data.beautyCardExpId then
		utils.GrayWidget(item, false)
		ui_xinNums:setTextColor(cc.c4b(255, 255, 0, 255))
		ui_propName:setTextColor(cc.c4b(240, 132, 134, 255))
		ui_propValue:setTextColor(cc.c4b(124, 252, 0, 255))
	else
		utils.GrayWidget(item, true)
		ui_xinNums:setTextColor(cc.c4b(128, 128, 128, 255))
		ui_propName:setTextColor(cc.c4b(128, 128, 128, 255))
		ui_propValue:setTextColor(cc.c4b(128, 128, 128, 255))
	end
end

local function setThingSVData(item, data)
	item:loadTexture(utils.getThingQualityImg(data.bkGround))
	local ui_thingIcon = item:getChildByName("image_good")
	local ui_addValue = ccui.Helper:seekNodeByName(item, "text_add")
	local ui_thingCount = item:getChildByName("Label_62")
	ui_thingIcon:loadTexture("image/" .. DictUI[tostring(data.smallUiId)].fileName)
	ui_addValue:setString(Lang.ui_beauty4 .. data.value)
	ui_thingCount:setString("×" .. data.count)
	item:setTouchEnabled(true)
	local function TouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			UIManager.showLoading()
			local ui_pageView = ccui.Helper:seekNodeByName(UIBeauty.Widget, "page_beauty")
			local id = ui_pageView:getPage(_curPageViewIndex):getTag()
			local instId = 0
			if net.InstPlayerBeautyCard then
				for key, obj in pairs(net.InstPlayerBeautyCard) do
					if obj.int["3"] == id then
						instId = obj.int["1"]
						break
					end
				end
			end
			UIBeauty.Widget:setEnabled(false)
			local _thingItemPoint = item:getParent():convertToWorldSpace(cc.p(item:getPositionX(), item:getPositionY()))
			-- _thingItemImageView = ccui.ImageView:create("image/" .. DictUI[tostring(data.smallUiId)].fileName)
			_thingItemImageView:loadTexture("image/" .. DictUI[tostring(data.smallUiId)].fileName)
			_thingItemImageView:setPosition(_thingItemPoint)
			netSendPackage({
				header = StaticMsgRule.courtship, 
				msgdata = {
					int={
						beautyCardId=id,
						instPlayerBeautyCardId=instId,
						instPlayerThingId=data.instId,
						type=2, --1-一键赠送  2-单个赠送
					}
				}}, netCallbackFunc)
		end
	end
	item:addTouchEventListener(TouchEvent)
	if UIGuidePeople.guideStep == guideInfo["1B2"].step then 
		UIGuidePeople.isGuide(item,UIBeauty)
 	end
end

local function pageViewEvent(sender, eventType)
	if eventType == ccui.PageViewEventType.turning and _curPageViewIndex ~= sender:getCurPageIndex() then
		_curPageViewIndex = sender:getCurPageIndex()
		local id = sender:getPage(_curPageViewIndex):getTag()
		local dictBeautyCardData = DictBeautyCard[tostring(id)]

		local image_di_name = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_di_name")
		image_di_name:getChildByName("text_name"):setString(DictCard[tostring(dictBeautyCardData.cardId)].name)
		local ui_nameImg = image_di_name:getChildByName("image_heart")
		local ui_level = ui_nameImg:getChildByName("text_number")

		local ui_xhFlagImg = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_close")

		local image_di_state = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_di_state")
		local ui_lockFlag = image_di_state:getChildByName("image_open")
		local ui_lockDesc = ui_lockFlag:getChildByName("text_condition")
		local ui_beautyDesc = image_di_state:getChildByName("text_info")

		local image_tab = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_tab")
		local btn_onekey = image_tab:getChildByName("btn_onekey")
		local btn_lingering = image_tab:getChildByName("btn_lingering")
		local ui_expBar = image_tab:getChildByName("bar_plan")
		local ui_expBarLabel = ui_expBar:getChildByName("Label_14")

		local beauteLevel = 1 --默认为1级
		local curBeautyCardExp = 0

		local _state = getBeautyState(dictBeautyCardData)
		if _state == UIBeauty.BEAUTY_STATE_XH then
			ui_nameImg:setVisible(false)
			ui_xhFlagImg:setVisible(true)
			ui_beautyDesc:setVisible(false)
			ui_lockFlag:setVisible(true)
			ui_lockFlag:loadTexture("ui/hy_06.png")
			ui_lockDesc:setString(Lang.ui_beauty5 .. DictBarrier[tostring(dictBeautyCardData.unblock)].name .. Lang.ui_beauty6)
			btn_onekey:setVisible(false)
			btn_lingering:setVisible(true)
			btn_lingering:setTitleText(BTN_TEXT_3)
			ui_expBar:setPercent(utils.getPercent(curBeautyCardExp, DictBeautyCardExp[tostring(beauteLevel)].exp))
			ui_expBarLabel:setString(curBeautyCardExp .. "/" .. DictBeautyCardExp[tostring(beauteLevel)].exp)
			if UIGuidePeople.guideStep == guideInfo["1B4"].step then 
				UIGuidePeople.isGuide(btn_lingering,UIBeauty)
		 	end
		elseif _state == UIBeauty.BEAUTY_STATE_ZF then
			ui_nameImg:setVisible(true)
			ui_level:setString(tostring(beauteLevel))
			ui_xhFlagImg:setVisible(false)
			ui_beautyDesc:setVisible(false)
			ui_lockFlag:setVisible(true)
			ui_lockFlag:loadTexture("ui/hy_07.png")
			btn_onekey:setVisible(false)
			btn_lingering:setVisible(false)
			local conditions = utils.stringSplit(dictBeautyCardData.conditions, "_") --[1]:tableTypeId, [2]:tableFieldId, [3]:value
			local tableTypeId, tableFieldId, value = tonumber(conditions[1]), tonumber(conditions[2]), tonumber(conditions[3])
			if tableTypeId == StaticTableType.DictPlayerBaseProp then
				if tableFieldId == StaticPlayerBaseProp.copper then
					ui_lockDesc:setString(Lang.ui_beauty7 .. value .. Lang.ui_beauty8)
					btn_lingering:setVisible(true)
					btn_lingering:setTitleText(BTN_TEXT_2)
				elseif tableFieldId == StaticPlayerBaseProp.level then
					ui_lockDesc:setString(Lang.ui_beauty9 .. value .. Lang.ui_beauty10)
				else
					cclog("ERROR：-------->> 美人系统 tableFieldId=" .. tableFieldId)
				end
			elseif tableTypeId == StaticTableType.DictBarrier then
				ui_lockDesc:setString(Lang.ui_beauty11 .. DictBarrier[tostring(tableFieldId)].name .. value .. Lang.ui_beauty12)
			else
				cclog("ERROR：-------->> 美人系统 tableTypeId=" .. tableTypeId)
			end
			ui_expBar:setPercent(utils.getPercent(curBeautyCardExp, DictBeautyCardExp[tostring(beauteLevel)].exp))
			ui_expBarLabel:setString(curBeautyCardExp .. "/" .. DictBeautyCardExp[tostring(beauteLevel)].exp)
		elseif  _state == UIBeauty.BEAUTY_STATE_JH then
			local instPlayerBeautyCard = getInstPlayerBeauty(id)
			if instPlayerBeautyCard then
				beauteLevel = instPlayerBeautyCard.int["4"]
				curBeautyCardExp = instPlayerBeautyCard.int["5"]
			end
			ui_nameImg:setVisible(true)
			ui_level:setString(tostring(beauteLevel))
			ui_xhFlagImg:setVisible(false)
			ui_beautyDesc:setVisible(true)
			ui_beautyDesc:setString(dictBeautyCardData.description)
			ui_lockFlag:setVisible(false)
			btn_onekey:setVisible(true)
			btn_lingering:setVisible(true)
			btn_lingering:setTitleText(BTN_TEXT_1)
			ui_expBar:setPercent(utils.getPercent(curBeautyCardExp, DictBeautyCardExp[tostring(beauteLevel)].exp))
			ui_expBarLabel:setString(curBeautyCardExp .. "/" .. DictBeautyCardExp[tostring(beauteLevel)].exp)
		end
		local image_property = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_property")
		local btn_show = image_property:getChildByName("btn_show")
		if btn_show:getTag() == -1 then
			scrollViewLayout(image_property:getChildByName("view_property"), getBeautyFightData(id), setPropSVData)
		end
		local ui_scrollView = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_title"):getChildByName("view_warrior")
		for key, obj in pairs(ui_scrollView:getChildren()) do
			if obj:getTag() == id then
				if _state ~= UIBeauty.BEAUTY_STATE_XH and obj:getChildByName("image_warior"):getTag() == -1 then
					utils.GrayWidget(obj:getChildByName("image_warior"), false)
					obj:getChildByName("image_warior"):setTag(obj:getTag())
					-- break
				elseif _state ~= UIBeauty.BEAUTY_STATE_ZF and obj:getChildByName("image_hint"):isVisible() then
					obj:getChildByName("image_hint"):setVisible(false)
					-- break
				end
			end
		end
		setScrollViewFocus()
		if  _state == UIBeauty.BEAUTY_STATE_JH and (not _isRefresh) then
			if not UIGuidePeople.guideFlag then 
				AudioEngine.stopAllEffects()
				AudioEngine.playEffect("sound/beauty/" .. dictBeautyCardData.sound .. ".mp3")
			end
		end
	end
end

local function initPageView(BeautyData)
	local ui_pageView = ccui.Helper:seekNodeByName(UIBeauty.Widget, "page_beauty")
	local ui_pageViewItem = ui_pageView:getChildByName("panel"):clone()
	if ui_pageViewItem:getReferenceCount() == 1 then
		ui_pageViewItem:retain()
	end
	ui_pageView:removeAllPages()
	ui_pageView:removeAllChildren()
	for key, obj in pairs(BeautyData) do
		local pvItem = ui_pageViewItem:clone()
		pvItem:setTag(obj.id)
		local dictCardData = DictCard[tostring(obj.cardId)]
		if dictCardData then
			local ui_cardImg = pvItem:getChildByName("image_beauty")
            ui_cardImg:setVisible(false)
			local cardAnim, cardAnimName
            if dictCardData.animationFiles and string.len(dictCardData.animationFiles) > 0 then
                cardAnim, cardAnimName = ActionManager.getCardAnimation(dictCardData.animationFiles)
            else
                cardAnim, cardAnimName = ActionManager.getCardBreatheAnimation("image/" .. DictUI[tostring(dictCardData.bigUiId)].fileName)
            end
			cardAnim:setScale(ui_cardImg:getScale())
			cardAnim:setPosition(cc.p(pvItem:getContentSize().width / 2, pvItem:getContentSize().height / 2))
			pvItem:addChild(cardAnim)
		end
		ui_pageView:addPage(pvItem)
	end
	ui_pageView:addEventListener(pageViewEvent)
end

local function refreshBeautyCard()
	local ui_pageView = ccui.Helper:seekNodeByName(UIBeauty.Widget, "page_beauty")
	_curPageViewIndex = -1
	pageViewEvent(ui_pageView, ccui.PageViewEventType.turning)
	_isRefresh = false
end

local function setupThingItem()
	ThingData = {}
	for key, obj in pairs(DictThing) do
		if obj.thingTypeId == StaticThing_Type.material then
			local count, instId = 0
			if net.InstPlayerThing then
				for iptKey, iptObj in pairs(net.InstPlayerThing) do
					if iptObj.int["3"] == tonumber(obj.id) then
						count = iptObj.int["5"]
						instId = iptObj.int["1"]
						break
					end
				end
			end
			if count > 0 then
				ThingData[#ThingData + 1] = obj
				ThingData[#ThingData].count = count
				ThingData[#ThingData].instId = instId
			end
		end
	end
	utils.quickSort(ThingData, function(obj1, obj2) if obj1.bkGround > obj2.bkGround then return true end end)
	local image_tab = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_tab")
	local ui_thingScrollView = image_tab:getChildByName("view_good")
	scrollViewLayout(ui_thingScrollView, ThingData, setThingSVData, 25)
end

local function getPropNum(_index, _value, _callFunc)
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
	local labelImg = ccui.ImageView:create("ui/ui_anim2Effect0.png")
	labelImg:setAnchorPoint(1, 0.5)
	labelImg:setPosition(-propImg:getContentSize().width, panel:getContentSize().height / 2)
	panel:addChild(labelImg)
	local num = ccui.TextAtlas:create()
	num:setProperty("0123456789", _numImg, 25, 36, "0")
	num:setAnchorPoint(0, 0.5)
	num:setString(tostring(_value))
	num:setPosition(panel:getContentSize().width, panel:getContentSize().height / 2)
	panel:addChild(num)

	panel:setPosition(UIManager.screenSize.width / 2 + 100, UIManager.screenSize.height / 2 + 200)
	UIBeauty.Widget:addChild(panel, 100, TAG_AddPropEffect)
	panel:setScale(0.8)
	panel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1.1), cc.MoveBy:create(0.6, cc.p(0, 60)), cc.Spawn:create(cc.MoveBy:create(0.5, cc.p(0, 60)), cc.ScaleTo:create(0.5, 0.9), cc.FadeTo:create(0.5, 0)), cc.CallFunc:create(function()
		panel:removeAllChildren()
		panel:removeFromParent()
		if _callFunc then _callFunc() end
	end)))
end


local function playUpgradePropAnim(_oldLv, _newLv, _callFunc)
	if _newLv > _oldLv then
		local ui_pageView = ccui.Helper:seekNodeByName(UIBeauty.Widget, "page_beauty")
		local curBeautyCardId = ui_pageView:getPage(_curPageViewIndex):getTag()
		local beautyFightData = getBeautyFightData(curBeautyCardId)
		for key, obj in pairs(beautyFightData) do
			if _newLv == obj.beautyCardExpId then
				local _index = 1
				if obj.fightPropId == StaticFightProp.blood then
					_index = 1
				elseif obj.fightPropId == StaticFightProp.wAttack then
					_index = 2
				elseif obj.fightPropId == StaticFightProp.wDefense then
					_index = 3
				elseif obj.fightPropId == StaticFightProp.fAttack then
					_index = 4
				elseif obj.fightPropId == StaticFightProp.fDefense then
					_index = 5
				end
				getPropNum(_index, obj.value, _callFunc)
				break
			end
		end
	end
end

netCallbackFunc = function(data)
	_isRefresh = true
	local code = tonumber(data.header)
	if code == StaticMsgRule.courtship then
		if tolua.isnull(_thingItemImageView) then
			refreshBeautyCard()
			setupThingItem()
		 	UIBeauty.Widget:setEnabled(true)
		 	if UIGuidePeople.guideStep == guideInfo["1B3"].step then 
		 		local ui_scrollView = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_title"):getChildByName("view_warrior")
				local data = ui_scrollView:getChildren()[2]
				UIGuidePeople.isGuide(data,UIBeauty)
		 	end
		else
			-- UIBeauty.Widget:addChild(_thingItemImageView, 100)
			_thingItemImageView:setScale(1)
			_thingItemImageView:stopAllActions()
			_thingItemImageView:setVisible(true)
			_thingItemImageView:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 2.5), cc.Spawn:create(cc.MoveTo:create(0.7, cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2)), cc.ScaleTo:create(0.7, 0)), cc.CallFunc:create(function()
				if not tolua.isnull(_thingItemImageView) then
					_thingItemImageView:setVisible(false)
				-- 	_thingItemImageView:removeFromParent()
				end
				playParticleEffect(function()

					local ui_nameImg = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_di_name"):getChildByName("image_heart")
					local ui_level = ui_nameImg:getChildByName("text_number")
					local beautyLevel = tonumber(ui_level:getString())
					local _oldLv = tonumber(ui_level:getString())
					refreshBeautyCard()
					playUpgradePropAnim(_oldLv, tonumber(ui_level:getString()))
					setupThingItem()
					UIBeauty.Widget:setEnabled(true)
					if UIGuidePeople.guideStep == guideInfo["1B3"].step then 
				 		local ui_scrollView = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_title"):getChildByName("view_warrior")
						local data = ui_scrollView:getChildren()[2]
						UIGuidePeople.isGuide(data,UIBeauty)
				 	end
				end)
			 	-- _thingItemImageView = nil
			end)))
		end
	elseif code == StaticMsgRule.linger then
		playParticleEffect(function()

			local ui_nameImg = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_di_name"):getChildByName("image_heart")
			local ui_level = ui_nameImg:getChildByName("text_number")
			local beautyLevel = tonumber(ui_level:getString())
			local _oldLv = tonumber(ui_level:getString())
			refreshBeautyCard()
			playUpgradePropAnim(_oldLv, tonumber(ui_level:getString()))
		end)
	elseif code == StaticMsgRule.conquer then
		refreshBeautyCard()
	end
end

function UIBeauty.init()
	local image_tab = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_tab")
	local btn_onekey = image_tab:getChildByName("btn_onekey")
	local btn_lingering = image_tab:getChildByName("btn_lingering")
	local image_property = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_property")
	local btn_show = image_property:getChildByName("btn_show")
	btn_show:setTag(0)
	btn_show:setPressedActionEnabled(true)
	btn_onekey:setPressedActionEnabled(true)
	btn_lingering:setPressedActionEnabled(true)
	local function buttonEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == btn_show then
				if sender:getTag() == 0 then
					image_property:runAction(cc.Sequence:create(cc.MoveBy:create(0.15, cc.p(-image_property:getContentSize().width, 0)), cc.CallFunc:create(function() sender:getChildByName("Image_48"):loadTexture("ui/hy_11.png") end)))
					sender:setTag(-1)
					local ui_pageView = ccui.Helper:seekNodeByName(UIBeauty.Widget, "page_beauty")
					local curBeautyCardId = ui_pageView:getPage(_curPageViewIndex):getTag()
					scrollViewLayout(image_property:getChildByName("view_property"), getBeautyFightData(curBeautyCardId), setPropSVData)
				else
					image_property:runAction(cc.Sequence:create(cc.MoveBy:create(0.15, cc.p(image_property:getContentSize().width, 0)), cc.CallFunc:create(function()
							sender:getChildByName("Image_48"):loadTexture("ui/hy_04.png")
							image_property:getChildByName("view_property"):removeAllChildren()
						end)))
					sender:setTag(0)
				end
			elseif sender == btn_onekey then
				if ThingData and #ThingData > 0 then
					UIManager.showLoading()
					local ui_pageView = ccui.Helper:seekNodeByName(UIBeauty.Widget, "page_beauty")
					local id = ui_pageView:getPage(_curPageViewIndex):getTag()
					local instId = 0
					local instObj = getInstPlayerBeauty(id)
					if instObj then
						instId = instObj.int["1"]
					end
					UIBeauty.Widget:setEnabled(false)
					local svThingItem = image_tab:getChildByName("view_good"):getChildren()[1]
					local _thingItemPoint = svThingItem:getParent():convertToWorldSpace(cc.p(svThingItem:getPositionX(), svThingItem:getPositionY()))
					-- _thingItemImageView = ccui.ImageView:create("image/" .. DictUI[tostring(ThingData[1].smallUiId)].fileName)
					_thingItemImageView:loadTexture("image/" .. DictUI[tostring(ThingData[1].smallUiId)].fileName)
					_thingItemImageView:setPosition(_thingItemPoint)
					netSendPackage({
						header = StaticMsgRule.courtship, 
						msgdata = {
							int={
								beautyCardId=id,
								instPlayerBeautyCardId=instId,
								instPlayerThingId=ThingData[1].instId,
								type=1, --1-一键赠送  2-单个赠送
							}
						}}, netCallbackFunc)
				else
					UIManager.showToast(Lang.ui_beauty13)
				end
			elseif sender == btn_lingering then
				local ui_pageView = ccui.Helper:seekNodeByName(UIBeauty.Widget, "page_beauty")
				local id = ui_pageView:getPage(_curPageViewIndex):getTag()
				if btn_lingering:getTitleText() == BTN_TEXT_1 then
					UIManager.showLoading()
					local instId = 0
					local instObj = getInstPlayerBeauty(id)
					if instObj then
						instId = instObj.int["1"]
					end
					netSendPackage({header = StaticMsgRule.linger, msgdata = {int={beautyCardId=id,instPlayerBeautyCardId=instId}}}, netCallbackFunc)
				elseif btn_lingering:getTitleText() == BTN_TEXT_2 then
					local conditions = utils.stringSplit(DictBeautyCard[tostring(id)].conditions, "_") --[1]:tableTypeId, [2]:tableFieldId, [3]:value
					local tableTypeId, tableFieldId, value = tonumber(conditions[1]), tonumber(conditions[2]), tonumber(conditions[3])
					if tonumber(net.InstPlayer.string["6"]) >= value then
						UIManager.showLoading()
						netSendPackage({header = StaticMsgRule.conquer, msgdata = {int={beautyCardId=id}}}, netCallbackFunc)
					else
						UIManager.showToast(Lang.ui_beauty14)
					end
				elseif btn_lingering:getTitleText() == BTN_TEXT_3 then
					local barrierId = 1
					if net.InstPlayerBarrier then
						for key, obj in pairs(net.InstPlayerBarrier) do
							if barrierId < obj.int["3"] then
								barrierId = obj.int["3"]
							end
						end
					end
					-- UIFightTask.showFightTaskChooseById(tonumber(barrierId + 1), false)
					local chapterId = DictBarrier[tostring(barrierId)].chapterId
					UIFightTask.setChapterId(chapterId)
            		UIManager.showScreen("ui_fight_task")
				end
			end
		end
	end
	btn_show:addTouchEventListener(buttonEvent)
	btn_onekey:addTouchEventListener(buttonEvent)
	btn_lingering:addTouchEventListener(buttonEvent)

	_thingItemImageView = ccui.ImageView:create()
	UIBeauty.Widget:addChild(_thingItemImageView, 100)

	local BeautyData = {}
	for kye, obj in pairs(DictBeautyCard) do
		BeautyData[#BeautyData + 1] = obj
	end
	utils.quickSort(BeautyData, function(obj1, obj2) if obj1.id > obj2.id then return true end end)

	local image_title = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_title")
	local ui_scrollView = image_title:getChildByName("view_warrior")
	scrollViewLayout(ui_scrollView, BeautyData, setIconSVData)

	initPageView(BeautyData)
end

function UIBeauty.setup()
	local ui_pageView = ccui.Helper:seekNodeByName(UIBeauty.Widget, "page_beauty")
	refreshBeautyCard()
	setupThingItem()
	UIBeauty.Widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
		setScrollViewFocus(true)
	end)))
	AudioEngine.playMusic("sound/beauty.mp3", true)
end

function UIBeauty.isShowHint()
	for kye, obj in pairs(DictBeautyCard) do
		if getBeautyState(obj) == UIBeauty.BEAUTY_STATE_ZF then
			return true
		end
	end
	return false
end

function UIBeauty.free()
	_isRefresh = false
	AudioEngine.stopAllEffects()
	AudioEngine.playMusic("sound/bg_music.mp3", true)
	local image_property = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_property")
	local btn_show = image_property:getChildByName("btn_show")
	if btn_show:getTag() == -1 then
		btn_show:setTag(0)
		btn_show:getChildByName("Image_48"):loadTexture("ui/hy_04.png")
		image_property:setPositionX(image_property:getPositionX() + image_property:getContentSize().width)
		image_property:getChildByName("view_property"):removeAllChildren()
	end
	local image_tab = ccui.Helper:seekNodeByName(UIBeauty.Widget, "image_tab")
	local ui_thingScrollView = image_tab:getChildByName("view_good")
	ui_thingScrollView:removeAllChildren()
	local ui_pageView = ccui.Helper:seekNodeByName(UIBeauty.Widget, "page_beauty")
	local pageViewChildren = ui_pageView:getChildren()
	for key, obj in pairs(pageViewChildren) do
		if obj:getChildByTag(TAG_ParticleEffect) then
			obj:getChildByTag(TAG_ParticleEffect):removeFromParent()
		end
	end
	if not tolua.isnull(_thingItemImageView) then
	-- 	_thingItemImageView:removeFromParent()
		_thingItemImageView:setVisible(false)
	end
	-- _thingItemImageView = nil
	if UIBeauty.Widget:getChildByTag(TAG_AddPropEffect) then
		UIBeauty.Widget:getChildByTag(TAG_AddPropEffect):removeFromParent()
	end
end
