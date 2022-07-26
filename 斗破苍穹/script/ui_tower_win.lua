require"Lang"
UITowerWin = {}

local ui_titleName = nil
local ui_winPanel = nil
local ui_failPanel = nil

local ui_scrollView = nil
local ui_svItem = nil

local isPass = false --是否通过
local _param = nil

local function setScrollViewItem(item, data, isMystery)
	local tableTypeId, tableFieldId, num
	if isMystery then
		local dictPagodaDropData = DictPagodaDrop[tostring(data)]
		tableTypeId, tableFieldId, num = dictPagodaDropData.tableTypeId, dictPagodaDropData.tableFieldId, dictPagodaDropData.value
	else
		local _tempData = utils.stringSplit(data, "_")
		tableTypeId, tableFieldId, num = _tempData[1],  _tempData[2],  _tempData[3]
	end
	local name, icon = utils.getDropThing(tableTypeId, tableFieldId)
	local _itemIcon = item:getChildByName("image_good")
	local _itemName = _itemIcon:getChildByName("text_name")
	local _itemNum = ccui.Helper:seekNodeByName(item,"text_number")
	_itemIcon:loadTexture(icon)
	_itemName:setString(name)
	_itemNum:setString(tostring(num))
	utils.addBorderImage(tableTypeId,tableFieldId,item)
end

---@isMystery : 是否神秘层
local function initScrollView(data, isMystery)
	local dropThingData = utils.stringSplit(data, ";")
	for key, obj in pairs(dropThingData) do
		local thingItem = ui_svItem:clone()
		setScrollViewItem(thingItem, obj, isMystery)
		ui_scrollView:addChild(thingItem)
	end

	local innerHieght, space, row = 0, 5, 3
	local childs = ui_scrollView:getChildren()
	if #childs < row then
		innerHieght = ui_svItem:getContentSize().height + space
	elseif #childs % row == 0 then
		innerHieght = (#childs / row) * (ui_svItem:getContentSize().height + space) + space
	else
		innerHieght = math.ceil(#childs / row) * (ui_svItem:getContentSize().height + space) + space
	end
	innerHieght = innerHieght + space
	if innerHieght < ui_scrollView:getContentSize().height then
		innerHieght = ui_scrollView:getContentSize().height
	end
	ui_scrollView:setInnerContainerSize(cc.size(ui_scrollView:getContentSize().width, innerHieght))

	local prevChild = nil
	local _tempI, x, y = 1, 0, 0
	for i = 1, #childs do
		x = _tempI * (ui_scrollView:getContentSize().width / row) - (ui_scrollView:getContentSize().width / row) / 2
		_tempI = _tempI + 1
		if i < row then
			y = ui_scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - space
			prevChild = childs[i]
			childs[i]:setPosition(cc.p(x, y))
		elseif i % row == 0 then
			childs[i]:setPosition(cc.p(x, y))
			y = prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - ccui.Helper:seekNodeByName(childs[i],"text_name"):getContentSize().height - space
			_tempI = 1
			prevChild = childs[i]
		else
			y = prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - ccui.Helper:seekNodeByName(childs[i],"text_name"):getContentSize().height - space
			childs[i]:setPosition(cc.p(x, y))
		end
	end
end

function UITowerWin.init()
	ui_winPanel = ccui.Helper:seekNodeByName(UITowerWin.Widget, "image_get_info_win")
	ui_failPanel = ccui.Helper:seekNodeByName(UITowerWin.Widget, "image_get_info_fail")
	
	ui_scrollView = ui_winPanel:getChildByName("view_get_good")
	ui_svItem = ui_scrollView:getChildByName("image_frame_good"):clone()
	if ui_svItem:getReferenceCount() == 1 then
		ui_svItem:retain()
	end
	
	local image_base_name = ccui.Helper:seekNodeByName(UITowerWin.Widget, "image_base_name")
	ui_titleName = ccui.Helper:seekNodeByName(image_base_name, "text_fight_name")
	
	local btn_sure = ccui.Helper:seekNodeByName(UITowerWin.Widget, "btn_sure")
	
	local image_recruit = ui_failPanel:getChildByName("image_recruit") --强者修炼
	local image_lineup = ui_failPanel:getChildByName("image_lineup") --调整阵容
	local image_card = ui_failPanel:getChildByName("image_card") --强者升级
	local image_equipment = ui_failPanel:getChildByName("image_equipment") --装备强化
	
	btn_sure:setPressedActionEnabled(true)
	local function onTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
--			UIManager.popScene()
			UIManager.popAllScene()
			if sender == btn_sure then
				local dictPagodaStoreyData = DictPagodaStorey[tostring(_param[1])] --塔层字典数据
				local pagodaFormationData = DictPagodaFormation[tostring(dictPagodaStoreyData.pagodaFormationId)] --塔阵字典数据
				if _param[1] ~= pagodaFormationData.pagodaStorey6 then
					UITowerTest.isWin(isPass)
				end
				UIManager.showScreen("ui_notice", "ui_tower_test", "ui_menu")
			elseif sender == image_recruit then
				local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.state)].level
				if net.InstPlayer.int["4"] < openLv then 
					UIManager.showToast(Lang.ui_tower_win1..openLv..Lang.ui_tower_win2)
				else
					UIManager.showScreen("ui_notice", "ui_lineup", "ui_menu")
				end
			elseif sender == image_lineup then
				UIManager.showScreen("ui_notice", "ui_tower_test", "ui_menu")
				if net.InstPlayer.int["4"] >= DictFunctionOpen[ tostring( StaticFunctionOpen.partner ) ].level then
                    UIManager.pushScene("ui_lineup_embattle")
                else
                    UIManager.pushScene("ui_lineup_embattle_old")
                end
			elseif sender == image_card then
				UIManager.showScreen("ui_notice", "ui_team_info", "ui_bag_card", "ui_menu")
			elseif sender == image_equipment then
				UIManager.showScreen("ui_notice", "ui_team_info", "ui_bag_equipment", "ui_menu")
			end
		end
	end
	btn_sure:addTouchEventListener(onTouchEvent)
	image_recruit:addTouchEventListener(onTouchEvent)
	image_lineup:addTouchEventListener(onTouchEvent)
	image_card:addTouchEventListener(onTouchEvent)
	image_equipment:addTouchEventListener(onTouchEvent)
end

function UITowerWin.setup()
	ui_scrollView:removeAllChildren()

	local _dictId = _param[1] --塔层字典ID
	local _victoryValue = _param[2] --通关条件值
	local _thingId = _param[3] --神秘层掉落表的Id(DictPagodaDrop)
	local dictPagodaStoreyData = DictPagodaStorey[tostring(_param[1])] --塔层字典数据
	local pagodaFormationData = DictPagodaFormation[tostring(dictPagodaStoreyData.pagodaFormationId)] --塔阵字典数据
	
	if _dictId == pagodaFormationData.pagodaStorey6 then
		ui_titleName:setString(Lang.ui_tower_win3)
	else
		ui_titleName:setString(Lang.ui_tower_win4.._dictId..Lang.ui_tower_win5)
	end
	isPass = false
    local image_basemap = UITowerWin.Widget:getChildByName("image_basemap")
    local image_base_di = image_basemap:getChildByName("image_basedi")
    ccui.Helper:seekNodeByName(image_basemap, "label_zhan"):setString(utils.getFightValue()) --战力
	if Fight.isWin() then
		ui_failPanel:setVisible(false)
		ui_winPanel:setVisible(true)
		local armature = ActionManager.getUIAnimation(11)
        armature:setPosition(cc.p(320, 860))
        UITowerWin.Widget:addChild(armature, 100, 100)
		ccui.Helper:seekNodeByName(ui_winPanel,"text_silver_number"):setString(tostring(dictPagodaStoreyData.copper)) --银币
		ccui.Helper:seekNodeByName(ui_winPanel,"text_fire_number"):setString(tostring(dictPagodaStoreyData.culture)) --火能
		utils.GrayWidget(image_base_di, false)
		if _dictId == pagodaFormationData.pagodaStorey6 then
			if _thingId then
				initScrollView(_thingId, true)
			end
		else
			if dictPagodaStoreyData.victoryMeans == 1 then--战斗回合数不超过
				if _victoryValue <= dictPagodaStoreyData.victoryValue then
					isPass = true
				end
			elseif dictPagodaStoreyData.victoryMeans == 2 then--死亡卡牌数不超过
				if _victoryValue <= dictPagodaStoreyData.victoryValue then
					isPass = true
				end
			elseif dictPagodaStoreyData.victoryMeans == 3 then--战斗结束后血量不少于%
				if _victoryValue >= dictPagodaStoreyData.victoryValue then
					isPass = true
				end
			elseif dictPagodaStoreyData.victoryMeans == 4 then--消灭全部敌人
				if _victoryValue == 0 then
					isPass = true
				end
			end
			
			if isPass then
				if _dictId == pagodaFormationData.pagodaStorey5 then
					initScrollView(pagodaFormationData.reward)
				end
--				UIManager.showToast("通过~")
			else
--				UIManager.showToast("未通过~")
			end
		end
	else
        local armature = ActionManager.getUIAnimation(12)
        armature:setPosition(cc.p(320, 860))
        UITowerWin.Widget:addChild(armature, 100, 100)
        utils.GrayWidget(image_base_di, true)
		ui_winPanel:setVisible(false)
		ui_failPanel:setVisible(true)
        if UITowerTest._isStrong == 0 then
            UITowerTest._isStrong = 1
            cc.UserDefault:getInstance():setIntegerForKey( "isStrong", UITowerTest._isStrong )
        end
	end
end

function UITowerWin.setParam(param)
	_param = param
end

function UITowerWin.free()
	if ui_svItem and ui_svItem:getReferenceCount() >= 1 then
		ui_svItem:release()
		ui_svItem = nil
	end
	if ui_scrollView then
		ui_scrollView:removeAllChildren()
		ui_scrollView = nil
	end
end
