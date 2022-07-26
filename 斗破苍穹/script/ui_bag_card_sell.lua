require"Lang"
UIBagCardSell = {}

UIBagCardSell.OperateType = {
	CardSell = 1, --卡牌出售
	CardUpgrade = 2, --卡牌升级
}

local ui_titleText = nil
local ui_chooseNum = nil
local ui_sellNum = nil
local ui_btnSell = nil
local scrollView = nil
local sv_item = nil

local cardThing ={}
local _instCardId = nil --要升级的卡牌实例ID
local _selectedInstCardIds = nil
local _totalNumber = 0
local _operateType = nil
local _param = nil

--先比较卡牌的品质 其次在比较等级
local function compareCard(value1,value2)
--升级时 选中的先排
    if _operateType == UIBagCardSell.OperateType.CardUpgrade and _selectedInstCardIds then
        local function isContain(id)
		    for key, obj in pairs(_selectedInstCardIds) do
			    if obj == id then
				    return true
			    end
		    end
		    return false
	    end
    
	    if isContain(value1.int["1"]) then
		    return false
        elseif isContain(value2.int["1"]) then
		    return true
	    end
    end
--升级选中先排 结束
	if value1.int["10"] == 1 and  value2.int["10"] == 0 then
		return  false
	end
	if value1.int["10"] == 0 and  value2.int["10"] == 1 then
		return  true
	end
	if value1.int["4"] > value2.int["4"] then
		return true
	elseif value1.int["4"] < value2.int["4"] then
		return false
	else
		if  value1.int["9"] > value2.int["9"] then
			return true
		else
			return false
		end
	end
end

local function netCallbackFunc(pack)
  if tonumber(pack.header) == StaticMsgRule.sellCards then
    UIManager.popScene()
    UIManager.showToast(Lang.ui_bag_card_sell1 .. _totalNumber .. Lang.ui_bag_card_sell2)
    UIManager.flushWidget(UIBagCard)
    UIManager.flushWidget(UITeamInfo)
  end
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

local function sellCard(selectedInstCardIds)
    local _instCardIds = ""
    for key, id in pairs(selectedInstCardIds) do
      if key == #selectedInstCardIds then
        _instCardIds = _instCardIds .. tostring(id)
      else
        _instCardIds = _instCardIds .. tostring(id) .. ";"
      end
    end
    local  sendData = {
      header = StaticMsgRule.sellCards,
      msgdata = {
        string = {
          instCardIds  = _instCardIds,
        }
      }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end

local function setScrollViewItem(item, data)
	local instCardId = data.int["1"] --卡牌实例ID
	local dictCardId = data.int["3"] --卡牌字典ID
	local cardExp = data.int["8"] --卡牌经验
	local cardLv = data.int["9"] --卡牌等级
	local dictCardData = DictCard[tostring(dictCardId)]
	local dictTitleDetailData = DictTitleDetail[tostring(data.int["6"])] --详细称号字典表
	local useTalentValue = data.int["11"] --卡牌当前潜力值
    local isAwake = data.int["18"] --是否已觉醒 0-未觉醒 1-觉醒
	
	local ui_cardFrame = ccui.Helper:seekNodeByName(item, "image_frame_card")
	local ui_cardIcon = ui_cardFrame:getChildByName("image_card")
	local ui_cardLevel = ccui.Helper:seekNodeByName(item, "text_card_number")
	local ui_cardName = ccui.Helper:seekNodeByName(item, "text_name_card")
	local ui_cardTitle = ccui.Helper:seekNodeByName(item, "image_base_title")
	local ui_imageSilver = ccui.Helper:seekNodeByName(item, "image_silver")
	local ui_cardPrice = ui_imageSilver:getChildByName("text_silver")
	local ui_checkBox = ccui.Helper:seekNodeByName(item, "box_choose")
	local ui_starlevel = ccui.Helper:seekNodeByName(item, "label_lv")

	if _operateType == UIBagCardSell.OperateType.CardSell then
		ui_imageSilver:setVisible(true)
		ui_cardFrame:setTouchEnabled(true)
	elseif _operateType == UIBagCardSell.OperateType.CardUpgrade then
		ui_imageSilver:setVisible(true)
		ui_cardFrame:setTouchEnabled(false)
		ui_imageSilver:loadTexture("ui/yh_exp.png")
	end
	local titleId= DictTitleDetail[tostring(data.int["6"])].titleId
	local startLevel = DictStarLevel[tostring(data.int["5"])].level
	if startLevel == 0 then 
        ui_starlevel:getParent():setVisible(false)
      else 
        ui_starlevel:getParent():setVisible(true)
        ui_starlevel:setText(startLevel)
      end
	ui_cardName:setString((isAwake == 1 and Lang.ui_bag_card_sell3 or "") .. dictCardData.name)
	ui_cardIcon:loadTexture("image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId)].fileName)
	ui_cardLevel:setString(string.format(Lang.ui_bag_card_sell4,cardLv))
	utils.setChengHaoImage(ui_cardTitle,dictTitleDetailData.value,titleId)
	local qualityId = data.int["4"]
	local dictQualityData = DictQuality[tostring(qualityId)]
	local borderImage = utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small)
	ui_cardFrame:loadTexture(borderImage)
	utils.changeNameColor(ui_cardName,qualityId)
	local price= dictQualityData.sellCopper + (cardLv-1)*dictQualityData.sellCopperAdd
	if _operateType == UIBagCardSell.OperateType.CardUpgrade then
		ui_cardPrice:setString("x" .. getCardTotalExp(cardLv, cardExp))
		ui_cardPrice:setPositionX(ui_imageSilver:getContentSize().width)
	else
		ui_cardPrice:setString(price) 
	end
	local function btnTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			UICardInfo.setUIParam(UIBagCardSell,instCardId) --卡牌信息
			UIManager.pushScene("ui_card_info")
		end
  	end
  
  	ui_cardFrame:addTouchEventListener(btnTouchEvent)
	local function isContain(id)
		for key, obj in pairs(_selectedInstCardIds) do
			if obj == id then
				return true
			end
		end
		return false
	end
	if not isContain(instCardId) then
		ui_checkBox:setSelected(false)
	else 
		ui_checkBox:setSelected(true)
	end
	local function ui_checkBoxEvent(sender, eventType)
		if eventType == ccui.CheckBoxEventType.selected then
			if _operateType == UIBagCardSell.OperateType.CardSell then
				if #_selectedInstCardIds == 30 then 
					UIManager.showToast(Lang.ui_bag_card_sell5)
					ui_checkBox:setSelected(false)
					return 
				end
				cclog("---------->>>  选择")
			  	if not isContain(instCardId) then
            		_selectedInstCardIds[#_selectedInstCardIds + 1] = instCardId
          		end
          		_totalNumber = _totalNumber + price
          		ui_chooseNum:setString(Lang.ui_bag_card_sell6 .. #_selectedInstCardIds)
          		ui_sellNum:setString(Lang.ui_bag_card_sell7 .. _totalNumber)
			elseif _operateType == UIBagCardSell.OperateType.CardUpgrade then
                
				if #_selectedInstCardIds >= 5 then
					UIManager.showToast(Lang.ui_bag_card_sell8)
					ui_checkBox:setSelected(false)
				else
					if not isContain(instCardId) then
						_selectedInstCardIds[#_selectedInstCardIds + 1] = instCardId
					end
					_totalNumber = _totalNumber + getCardTotalExp(cardLv, cardExp)
					ui_chooseNum:setString(Lang.ui_bag_card_sell9 .. #_selectedInstCardIds)
					ui_sellNum:setString(Lang.ui_bag_card_sell10 .. _totalNumber)
				end
			end
		elseif eventType == ccui.CheckBoxEventType.unselected then
			if _operateType == UIBagCardSell.OperateType.CardSell then
				cclog("---------->>>  取消")
				for key, obj in pairs(_selectedInstCardIds) do
		          if obj == instCardId then
		            table.remove(_selectedInstCardIds, key)
		            break
		          end
		        end
		        _totalNumber = _totalNumber - price
		        ui_chooseNum:setString(Lang.ui_bag_card_sell11 .. #_selectedInstCardIds)
		        ui_sellNum:setString(Lang.ui_bag_card_sell12 .. _totalNumber)
		elseif _operateType == UIBagCardSell.OperateType.CardUpgrade then
				for key, obj in pairs(_selectedInstCardIds) do
					if obj == instCardId then
						table.remove(_selectedInstCardIds, key)
						break
					end
				end
				_totalNumber = _totalNumber - getCardTotalExp(cardLv, cardExp)
				ui_chooseNum:setString(Lang.ui_bag_card_sell13 .. #_selectedInstCardIds)
				ui_sellNum:setString(Lang.ui_bag_card_sell14 .. _totalNumber)
			end
		end
	end
	ui_checkBox:addEventListener(ui_checkBoxEvent)

	item:setTouchEnabled(true)
	item:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if ui_checkBox:isSelected() then
				ui_checkBox:setSelected(false)
				ui_checkBoxEvent(ui_checkBox, ccui.CheckBoxEventType.unselected)
			else
				ui_checkBox:setSelected(true)
				ui_checkBoxEvent(ui_checkBox, ccui.CheckBoxEventType.selected)
			end
		end
	end)
end
-----------------------zy--------------------------
--是否选中过
local function inSelect( instCardId )
	for key, obj in pairs(_selectedInstCardIds) do
		if obj == instCardId then
		    return true
		end
	end
	return false
end
local function selectAllGreen()
	--加入选择
	for key , obj in pairs( cardThing ) do
		if net.InstPlayerCard[tostring(obj.int["1"])].int["4"] == StaticQuality.white then
			if not inSelect( obj.int["1"] ) then --没选中过就加入表
				table.insert( _selectedInstCardIds , obj.int["1"] )
				local cardExp = obj.int["8"] --卡牌经验
				local cardLv = obj.int["9"] --卡牌等级
				local qualityId = obj.int["4"]
				local dictQualityData = DictQuality[tostring(qualityId)]
				local price= dictQualityData.sellCopper + (cardLv-1)*dictQualityData.sellCopperAdd
				if _operateType == UIBagCardSell.OperateType.CardSell then
					_totalNumber = _totalNumber + price
				elseif _operateType == UIBagCardSell.OperateType.CardUpgrade then			
					_totalNumber = _totalNumber + getCardTotalExp(cardLv, cardExp)
				end
			end
		end
	end

	if _operateType == UIBagCardSell.OperateType.CardSell then
		ui_chooseNum:setString(Lang.ui_bag_card_sell15 .. #_selectedInstCardIds)
		ui_sellNum:setString(Lang.ui_bag_card_sell16 .. _totalNumber)
	elseif _operateType == UIBagCardSell.OperateType.CardUpgrade then			
		ui_chooseNum:setString(Lang.ui_bag_card_sell17 .. #_selectedInstCardIds)
		ui_sellNum:setString(Lang.ui_bag_card_sell18 .. _totalNumber)
	end
	--刷新列表
	scrollView:removeAllChildren()

	utils.quickSort(cardThing,compareCard)

	if next(cardThing) then
		utils.updateView(UIBagCardSell,scrollView,sv_item,cardThing,setScrollViewItem)
	end
	
end
--------------------------------------------------------
function UIBagCardSell.init()
	ui_titleText = ccui.Helper:seekNodeByName(UIBagCardSell.Widget, "text_card_sell")
	local btn_close = ccui.Helper:seekNodeByName(UIBagCardSell.Widget, "btn_close")
	ui_btnSell = ccui.Helper:seekNodeByName(UIBagCardSell.Widget, "btn_sell")
    local ui_btn_choose = ccui.Helper:seekNodeByName(UIBagCardSell.Widget,"btn_choose") --zy 勾选绿卡
	btn_close:setPressedActionEnabled(true)
	ui_btnSell:setPressedActionEnabled(true)
    ui_btn_choose:setPressedActionEnabled(true)
	local function btnTouchEvent(sender, eventType)
	   if eventType == ccui.TouchEventType.ended then 
	   		AudioEngine.playEffect("sound/button.mp3")
    		if sender == btn_close then
    			UIManager.popScene()
            elseif sender == ui_btn_choose then 
                cclog("------------>>>勾选绿卡")
                selectAllGreen()            
    		elseif sender == ui_btnSell then
    			if _operateType == UIBagCardSell.OperateType.CardSell then
    				cclog("---------->>>  出售")
    				if next(_selectedInstCardIds) then 
        				for key,obj in pairs(_selectedInstCardIds) do
        				    if net.InstPlayerCard[tostring(obj)].int["4"] > StaticQuality.white then 
        				        local info = Lang.ui_bag_card_sell19
        				        utils.PromptDialog(sellCard,info,_selectedInstCardIds)
        				        return;
        				    end
        				end
        				sellCard(_selectedInstCardIds)
					else
					   UIManager.showToast(Lang.ui_bag_card_sell20)
					end
    			elseif _operateType == UIBagCardSell.OperateType.CardUpgrade then
    				UIManager.popScene()
    				UICardUpgrade.setSelectedInstCardIds(_selectedInstCardIds)
    			end
    		end
		end
	end
	btn_close:addTouchEventListener(btnTouchEvent)
	ui_btnSell:addTouchEventListener(btnTouchEvent)
    ui_btn_choose:addTouchEventListener(btnTouchEvent)
	scrollView = ccui.Helper:seekNodeByName(UIBagCardSell.Widget, "view_card")
	sv_item = scrollView:getChildByName("image_base_card")
	sv_item:removeFromParent()
	ui_chooseNum = ccui.Helper:seekNodeByName(UIBagCardSell.Widget, "text_choose_number")
	ui_sellNum = ccui.Helper:seekNodeByName(UIBagCardSell.Widget, "text_sell_number")
end

function UIBagCardSell.setup()

    local ui_btn_choose = ccui.Helper:seekNodeByName(UIBagCardSell.Widget,"btn_choose")
    if _operateType==UIBagCardSell.OperateType.CardUpgrade then
        ui_btn_choose:setVisible(false)
    end
	if sv_item:getReferenceCount() == 1 then
		sv_item:retain()
	end
	scrollView:removeAllChildren()
	_selectedInstCardIds = {}
	_totalNumber = 0
	cardThing={}
	if _operateType == UIBagCardSell.OperateType.CardSell then
		ui_titleText:setString(Lang.ui_bag_card_sell21)
		ui_chooseNum:setString(Lang.ui_bag_card_sell22)
		ui_sellNum:setString(Lang.ui_bag_card_sell23)
		ui_btnSell:setTitleText(Lang.ui_bag_card_sell24)
	elseif _operateType == UIBagCardSell.OperateType.CardUpgrade then
		ui_titleText:setString(Lang.ui_bag_card_sell25)
		ui_chooseNum:setString(Lang.ui_bag_card_sell26)
		ui_sellNum:setString(Lang.ui_bag_card_sell27)
		ui_btnSell:setTitleText(Lang.ui_bag_card_sell28)
		if _param then
			local _tempParam = utils.stringSplit(_param, ";")
			for key, obj in pairs(_tempParam) do
				_selectedInstCardIds[#_selectedInstCardIds + 1] = tonumber(obj)
				local instCardData = net.InstPlayerCard[obj]
				_totalNumber = _totalNumber + getCardTotalExp(instCardData.int["9"], instCardData.int["8"])
				ui_chooseNum:setString(Lang.ui_bag_card_sell29 .. #_selectedInstCardIds)
				ui_sellNum:setString(Lang.ui_bag_card_sell30 .. _totalNumber)
			end
		end
	end
	if net.InstPlayerCard then
		for key, obj in pairs(net.InstPlayerCard) do
			local isTeam = obj.int["10"] --是否在队伍中 0-不在 1-在
			local isLock = obj.int["15"] --是否锁定 0-不锁 1-锁
			if _instCardId ~= obj.int["1"] and isTeam == 0 and isLock == 0 then
				table.insert(cardThing,obj)
			end
		end
		utils.quickSort(cardThing,compareCard)
	end
	if next(cardThing) then
		utils.updateView(UIBagCardSell,scrollView,sv_item,cardThing,setScrollViewItem)
	end
end

function UIBagCardSell.setOperateType(operateType, instCardId, param)
	_operateType = operateType
	_instCardId = instCardId
	_param = param
end

function UIBagCardSell.free()
	if not tolua.isnull(sv_item) and sv_item:getReferenceCount() >=1 then 
      sv_item:release()
      sv_item = nil
  	end
end
