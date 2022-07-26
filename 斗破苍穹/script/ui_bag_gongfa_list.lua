require"Lang"
UIBagGongFaList = {}

UIBagGongFaList.OperateType = {
	gongfaSell = 1, --功法出售
	fabaoSell = 2,--法宝出售
	gongfaEquip = 3, --功法装备
	fabaoEquip = 4, --法宝装备
	magicUpgrade = 5, --法宝/功法升级
}

local scrollView = nil
local sv_item = nil
local sv_item1 = nil
local btn_ensure = nil
local _operateType = nil
local _sendMagicData = nil
local text_exp = nil
local text_selected = nil
local ui_text_selected = nil --选择的功法个数标签
local ui_text_exp = nil
local _totalNumber = 0
local selectedInstGongFaIds = nil
local _param = nil
local _instMagicId = nil

local function netCallbackFunc(pack)
	local code = tonumber(pack.header)
	if code == StaticMsgRule.sell then
		UIManager.popScene()
		UIManager.showToast(Lang.ui_bag_gongfa_list1 .. _totalNumber .. Lang.ui_bag_gongfa_list2)
		UIManager.flushWidget(UIBagGongFa)
		UIManager.flushWidget(UITeamInfo)
	elseif code == StaticMsgRule.putOn then
		UIManager.popAllScene()
		UIManager.flushWidget(UILineup)
		UIGuidePeople.isGuide(nil,UIBagGongFaList)
	end
end
---出售功法法宝协议---
local function sendSellData()
	local _sellIds = ""
	for key, id in pairs(selectedInstGongFaIds) do
		if key == #selectedInstGongFaIds then
			_sellIds = _sellIds .. tostring(id)
		else
			_sellIds = _sellIds .. tostring(id) .. ";"
		end
	end
	local  sendData = {
		header = StaticMsgRule.sell,
		msgdata = {
			int = {
				buyNum = 1,
				type = 4,
			},
			string = {
				sellIds  = _sellIds,
			}
		}
	}
	UIManager.showLoading()
	netSendPackage(sendData, netCallbackFunc)
end

local function getMagicTotoalExp(levelId, curExp, dictMagicData)
	local totalExp = 0
	local magicLv = DictMagicLevel[tostring(levelId)].level
   -- cclog("magicLv : "..magicLv)
	if magicLv > 1 then
		local magicType = DictMagicLevel[tostring(levelId)].type
		for key, obj in pairs(DictMagicLevel) do
			if magicType == obj.type and obj.level >= 1 and obj.level < magicLv then
				totalExp = totalExp + obj.exp
			end
		end
	else
		totalExp = dictMagicData.exp
	end
	return totalExp + curExp
end

local function compareMagic(value1,value2)
    local function getExp( obj )
	    local dictMagicData = DictMagic[tostring(obj.int["3"])]
	    local totalE = getMagicTotoalExp(obj.int["6"], obj.int["7"], dictMagicData)
      --  cclog("totalE : "..totalE)
        return totalE 
    end
    if DictMagic[tostring(value1.int["3"])].magicQualityId > DictMagic[tostring(value2.int["3"])].magicQualityId then
		return true
    elseif DictMagic[tostring(value1.int["3"])].magicQualityId < DictMagic[tostring(value2.int["3"])].magicQualityId then
        return false
	elseif getExp( value1 ) < getExp( value2 ) then
        return true
    elseif getExp( value1 ) > getExp( value2 ) then
        return false
	elseif DictMagic[tostring(value1.int["3"])].id > DictMagic[tostring(value2.int["3"])].id then
		return true
    else
        return false
	end
end
local function setScrollViewItem(_Item, _obj)
	local instPlayerMagicId = _obj.int["1"]
	local value = {}
	local ui_property ={}
	local ui_frame = ccui.Helper:seekNodeByName(_Item, "image_frame_equipment")
	local ui_MagicIcon = ui_frame:getChildByName("image_equipment")
	local ui_MagicName = ccui.Helper:seekNodeByName(_Item, "text_name_equipment")
	local ui_MagicType = ccui.Helper:seekNodeByName(_Item, "text_gongfa_lv")
	local ui_MagicLevel = ccui.Helper:seekNodeByName(_Item, "text_lv")
	local ui_qualityLevel = ccui.Helper:seekNodeByName(_Item, "label_pz")
	local ui_image_price =_Item:getChildByName("image_price")
	local ui_image_exp = _Item:getChildByName("text_exp")
	local ui_MagicButton = _Item:getChildByName("btn_intensify")
	ui_MagicButton:setPressedActionEnabled(true)
	ui_property[2] = ccui.Helper:seekNodeByName(_Item,"text_limit")
	ui_property[3] = ccui.Helper:seekNodeByName(_Item,"text_gongfa_number")
	ui_property[1] = ccui.Helper:seekNodeByName(_Item,"text_laterality")
	local ui_MagicCheckbox = _Item:getChildByName("checkbox_choose")
	local dictId = _obj.int["3"] --功法或法宝id
	local dicData = DictMagic[tostring(dictId)] --功法字典表
	local dictUiData = DictUI[tostring(dicData.smallUiId)] --资源字典表
	local Level = DictMagicLevel[tostring(_obj.int["6"])].level
	local qualityValue = _obj.int["5"]
	local qualityLevel = dicData.grade
	value[1] = dicData.value1
	value[2] = dicData.value2
	value[3] = dicData.value3

	local borderImage = utils.getQualityImage(dp.Quality.gongFa, qualityValue, dp.QualityImageType.small)
	ui_frame:loadTexture(borderImage)
	utils.changeNameColor(ui_MagicName,qualityValue,dp.Quality.gongFa)
	ui_MagicIcon:loadTexture("image/" .. dictUiData.fileName)
	ui_MagicName:setString(dicData.name)
	ui_MagicType:setString(DictMagicQuality[tostring(qualityValue)].name)
	ui_MagicLevel:setString(string.format(Lang.ui_bag_gongfa_list3,Level))
	ui_qualityLevel:setString(qualityLevel)
	for i=1,3 do
		if value[i] ~= "" then
			local dictValue = utils.stringSplit(value[i], "_")
			if tonumber(dictValue[1]) == 3 then
				ui_property[i]:setString(string.format("%s+%d%s",Lang.ui_bag_gongfa_list4,dicData.exp,""))
			else
				local dictFightPropId = dictValue[2]
				local value = dictValue[3]+dictValue[4]*(Level-1)
				local name = DictFightProp[tostring(dictFightPropId)].name
				ui_property[i]:setString(string.format("%s+%d%s",name,value,tonumber(dictValue[1]) == 1 and "%" or ""))
			end
		else
			ui_property[i]:setVisible(false)
		end
	end
	if _operateType == UIBagGongFaList.OperateType.gongfaSell or  _operateType == UIBagGongFaList.OperateType.fabaoSell then
		ui_image_exp:setVisible(false)
		ui_image_price:setVisible(true)
		ui_image_price:getChildByName("text_price"):setString("×" .. dicData.sellCopper)
		ui_MagicCheckbox:setVisible(true)
	elseif _operateType == UIBagGongFaList.OperateType.magicUpgrade then
		ui_image_price:setVisible(false)
		ui_image_exp:setVisible(true)
		ui_image_exp:setString(Lang.ui_bag_gongfa_list5 .. getMagicTotoalExp(_obj.int["6"], _obj.int["7"], dicData))
		ui_MagicCheckbox:setVisible(true)
	else 
		ui_MagicCheckbox:setVisible(false)
		ui_image_exp:setVisible(false)
		ui_image_price:setVisible(false)
	end
	local function isContain(id)
		for key, obj in pairs(selectedInstGongFaIds) do
			if obj == id then
				return true
			end
		end
		return false
	end
	if not isContain(instPlayerMagicId) then
		ui_MagicCheckbox:setSelected(false)
	else
		ui_MagicCheckbox:setSelected(true)
	end
	local function ui_MagicCheckboxEvent(sender, eventType)
		if eventType == ccui.CheckBoxEventType.selected then
			if _operateType == UIBagGongFaList.OperateType.gongfaSell or _operateType == UIBagGongFaList.OperateType.fabaoSell then
				if not isContain(instPlayerMagicId) then
					selectedInstGongFaIds[#selectedInstGongFaIds + 1] = instPlayerMagicId
				end
				ui_text_selected:setString(text_selected .. #selectedInstGongFaIds)
				_totalNumber = _totalNumber + dicData.sellCopper
				ui_text_exp:setString(text_exp .. _totalNumber)
			elseif _operateType == UIBagGongFaList.OperateType.magicUpgrade then
				if #selectedInstGongFaIds >= 5 then
					UIManager.showToast(Lang.ui_bag_gongfa_list6)
					ui_checkBox:setSelected(false)
				else
					if not isContain(instPlayerMagicId) then
						selectedInstGongFaIds[#selectedInstGongFaIds + 1] = instPlayerMagicId
					end
					_totalNumber = _totalNumber + getMagicTotoalExp(_obj.int["6"], _obj.int["7"], dicData)
					ui_text_selected:setString(text_selected .. #selectedInstGongFaIds)
					ui_text_exp:setString(text_exp .. _totalNumber)
				end
			end
		elseif eventType == ccui.CheckBoxEventType.unselected then
			if _operateType == UIBagGongFaList.OperateType.gongfaSell or _operateType == UIBagGongFaList.OperateType.fabaoSell then
				for key, obj in pairs(selectedInstGongFaIds) do
					if obj == instPlayerMagicId then
						table.remove(selectedInstGongFaIds, key)
						break
					end
				end
				ui_text_selected:setString(text_selected .. #selectedInstGongFaIds)
				_totalNumber = _totalNumber - dicData.sellCopper
				ui_text_exp:setString(text_exp .. _totalNumber)
			elseif _operateType == UIBagGongFaList.OperateType.magicUpgrade then
				for key, obj in pairs(selectedInstGongFaIds) do
					if obj == instPlayerMagicId then
						table.remove(selectedInstGongFaIds, key)
						break
					end
				end
				_totalNumber = _totalNumber - getMagicTotoalExp(_obj.int["6"], _obj.int["7"], dicData)
				ui_text_selected:setString(text_selected .. #selectedInstGongFaIds)
				ui_text_exp:setString(text_exp .. _totalNumber)
			end
		end
	end
	ui_MagicCheckbox:addEventListener(ui_MagicCheckboxEvent)
	if _operateType == UIBagGongFaList.OperateType.gongfaEquip or _operateType == UIBagGongFaList.OperateType.fabaoEquip then
		local function equipFunc(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				if _sendMagicData then
					_sendMagicData.msgdata.int.instPlayerMagicId = instPlayerMagicId
					UIManager.showLoading()
					netSendPackage(_sendMagicData, netCallbackFunc)
				end
			end
		end
		ui_MagicButton:addTouchEventListener(equipFunc)
		if _obj.int["3"] == 16 then 
			UIGuidePeople.isGuide(ui_MagicButton,UIBagGongFaList)
		end
		ui_MagicButton:setVisible(true)
	else 
		ui_MagicButton:setVisible(false)
	end
end

local function setScrollViewItem1(_Item, _obj)
	local instPlayerMagicId = _obj.int["1"]
	local value = {}
	local ui_property ={}
	local ui_frame = ccui.Helper:seekNodeByName(_Item, "image_frame_equipment")
	local ui_MagicIcon = ui_frame:getChildByName("image_equipment")
	local ui_MagicName = ccui.Helper:seekNodeByName(_Item, "text_name_equipment")
	local ui_MagicType = ccui.Helper:seekNodeByName(_Item, "text_gongfa_lv")
	local ui_MagicLevel = ccui.Helper:seekNodeByName(_Item, "text_lv")
	local ui_qualityLevel = ccui.Helper:seekNodeByName(_Item, "text_pz")
	ui_property[2] = ccui.Helper:seekNodeByName(_Item,"text_limit")
	ui_property[3] = ccui.Helper:seekNodeByName(_Item,"text_gongfa_number")
	ui_property[1] = ccui.Helper:seekNodeByName(_Item,"text_laterality")
	local ui_MagicButton = _Item:getChildByName("btn_intensify")
	ui_MagicButton:setPressedActionEnabled(true)
	local dictId = _obj.int["3"] --功法或法宝id
	local dicData = DictMagic[tostring(dictId)] --功法字典表
	local dictUiData = DictUI[tostring(dicData.smallUiId)] --资源字典表
	local Level = DictMagicLevel[tostring(_obj.int["6"])].level
	local qualityValue = _obj.int["5"]
	local qualityLevel = dicData.grade
	value[1] = dicData.value1
	value[2] = dicData.value2
	value[3] = dicData.value3
	local borderImage = utils.getQualityImage(dp.Quality.gongFa, qualityValue, dp.QualityImageType.small)
	utils.changeNameColor(ui_MagicName,qualityValue,dp.Quality.gongFa)
	ui_frame:loadTexture(borderImage)
	ui_MagicIcon:loadTexture("image/" .. dictUiData.fileName)
	ui_MagicName:setString(dicData.name)
	ui_MagicType:setString(DictMagicQuality[tostring(qualityValue)].name)
	ui_MagicLevel:setString(string.format(Lang.ui_bag_gongfa_list7,Level))
	ui_qualityLevel:setString(string.format(Lang.ui_bag_gongfa_list8,qualityLevel))
	for i=1,3 do
		if value[i] ~= "" then
			local dictValue = utils.stringSplit(value[i], "_")
			if tonumber(dictValue[1]) == 3 then
				ui_property[i]:setString(string.format("%s+%d%s",Lang.ui_bag_gongfa_list9,dicData.exp,""))
			else
				local dictFightPropId = dictValue[2]
				local value = dictValue[3]+dictValue[4]*(Level-1)
				local name = DictFightProp[tostring(dictFightPropId)].name
				ui_property[i]:setString(string.format("%s+%d%s",name,value,tonumber(dictValue[1]) == 1 and "%" or ""))
			end
		else
			ui_property[i]:setVisible(false)
		end
	end
	if _operateType == UIBagGongFaList.OperateType.gongfaEquip or _operateType == UIBagGongFaList.OperateType.fabaoEquip then
		local function equipFunc(sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				if _sendMagicData then
					_sendMagicData.msgdata.int.instPlayerMagicId = instPlayerMagicId
					UIManager.showLoading()
					netSendPackage(_sendMagicData, netCallbackFunc)
				end
			end
		end
		ui_MagicButton:addTouchEventListener(equipFunc)
		if _obj.int["3"] == 16 then 
			UIGuidePeople.isGuide(ui_MagicButton,UIBagGongFaList)
		end
	end
end

function UIBagGongFaList.init()

	local btn_close = ccui.Helper:seekNodeByName(UIBagGongFaList.Widget, "btn_close") --右上角关闭按钮
	btn_ensure = ccui.Helper:seekNodeByName(UIBagGongFaList.Widget, "btn_ensure") --确定按钮
	btn_close:setPressedActionEnabled(true)
	btn_ensure:setPressedActionEnabled(true)
	local function btnTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			if sender == btn_ensure then
				if _operateType == UIBagGongFaList.OperateType.gongfaSell or _operateType == UIBagGongFaList.OperateType.fabaoSell then
					if next(selectedInstGongFaIds) then
						for key,obj in pairs(selectedInstGongFaIds) do
							local instPlayerMagicData = net.InstPlayerMagic[tostring(obj)]
							if instPlayerMagicData.int["5"] == 1 then
								local info = string.format(Lang.ui_bag_gongfa_list10,_operateType == UIBagGongFaList.OperateType.gongfaSell and Lang.ui_bag_gongfa_list11 or Lang.ui_bag_gongfa_list12)
								utils.PromptDialog(sendSellData,info)
								return;
							end
						end
						sendSellData()
					else
						UIManager.popScene()
					end
				elseif _operateType == UIBagGongFaList.OperateType.magicUpgrade then
					UIGongfaIntensify.setSelectedInstMagicIds(selectedInstGongFaIds)
					UIManager.popScene()
				end
			elseif  sender == btn_close then
				UIManager.popScene()
			end

		end
	end
	btn_close:addTouchEventListener(btnTouchEvent)
	btn_ensure:addTouchEventListener(btnTouchEvent)

	scrollView = ccui.Helper:seekNodeByName(UIBagGongFaList.Widget, "view_gongfa")
	sv_item = scrollView:getChildByName("image_base_gongfa")
	sv_item:removeFromParent()
end

function UIBagGongFaList.setup()
	local ui_title = ccui.Helper:seekNodeByName(UIBagGongFaList.Widget, "text_title_eat")
	local image_basemap = UIBagGongFaList.Widget:getChildByName("image_basemap")
	ui_text_selected = image_basemap:getChildByName("text_selected")
	ui_text_exp = image_basemap:getChildByName("text_exp")
	selectedInstGongFaIds = {}
	if sv_item:getReferenceCount() == 1 then
		sv_item:retain()
	end
	scrollView:removeAllChildren()
	if _operateType == UIBagGongFaList.OperateType.gongfaSell then
		ui_title:setString(Lang.ui_bag_gongfa_list13)
		text_exp = Lang.ui_bag_gongfa_list14
		text_selected = Lang.ui_bag_gongfa_list15
		ui_text_selected:setVisible(true)
		ui_text_exp:setVisible(true)
		btn_ensure:setVisible(true)
		ui_text_selected:setString(text_selected .. 0)
		ui_text_exp:setString(text_exp .. 0)
	elseif _operateType == UIBagGongFaList.OperateType.fabaoSell then
		ui_title:setString(Lang.ui_bag_gongfa_list16)
		text_exp = Lang.ui_bag_gongfa_list17
		text_selected = Lang.ui_bag_gongfa_list18
		ui_text_selected:setVisible(true)
		ui_text_exp:setVisible(true)
		btn_ensure:setVisible(true)
		ui_text_selected:setString(text_selected .. 0)
		ui_text_exp:setString(text_exp .. 0)
	elseif _operateType == UIBagGongFaList.OperateType.gongfaEquip then
		ui_title:setString(Lang.ui_bag_gongfa_list19)
		ui_text_selected:setVisible(false)
		ui_text_exp:setVisible(false)
		btn_ensure:setVisible(false)
	elseif _operateType == UIBagGongFaList.OperateType.fabaoEquip then
		ui_title:setString(Lang.ui_bag_gongfa_list20)
		ui_text_selected:setVisible(false)
		ui_text_exp:setVisible(false)
		btn_ensure:setVisible(false)
	elseif _operateType == UIBagGongFaList.OperateType.magicUpgrade then
		if _sendMagicData == dp.MagicType.treasure then
			ui_title:setString(Lang.ui_bag_gongfa_list21)
			text_selected = Lang.ui_bag_gongfa_list22
		elseif _sendMagicData == dp.MagicType.gongfa then
			ui_title:setString(Lang.ui_bag_gongfa_list23)
			text_selected = Lang.ui_bag_gongfa_list24
		end
		text_exp = Lang.ui_bag_gongfa_list25
		ui_text_selected:setVisible(true)
		ui_text_exp:setVisible(true)
		btn_ensure:setVisible(true)
		ui_text_selected:setString(text_selected .. 0)
		ui_text_exp:setString(text_exp .. 0)

		if _param then
			local _tempParam = utils.stringSplit(_param, ";")
			for key, obj in pairs(_tempParam) do
				selectedInstGongFaIds[#selectedInstGongFaIds + 1] = tonumber(obj)
				local instMagicData = net.InstPlayerMagic[obj]
				local dictMagicData = DictMagic[tostring(instMagicData.int["3"])]
				_totalNumber = _totalNumber + getMagicTotoalExp(instMagicData.int["6"], instMagicData.int["7"], dictMagicData)
				ui_text_selected:setString(text_selected .. #selectedInstGongFaIds)
				ui_text_exp:setString(text_exp .. _totalNumber)
			end
		end

	end
	local magicThing = {}
	if net.InstPlayerMagic then
		for key, obj in pairs(net.InstPlayerMagic) do
			if _instMagicId ~= obj.int["1"] and obj.int["8"] == 0 then--是否被使用  0-未使用 1-使用
				local _magicType = obj.int["4"]
				if (_operateType == UIBagGongFaList.OperateType.gongfaEquip or _operateType == UIBagGongFaList.OperateType.fabaoEquip) and DictMagic[tostring(obj.int["3"])].value1 == "3" then
				else
					if (_operateType == UIBagGongFaList.OperateType.gongfaSell or _operateType == UIBagGongFaList.OperateType.gongfaEquip or (_operateType == UIBagGongFaList.OperateType.magicUpgrade and _sendMagicData == dp.MagicType.gongfa)) and _magicType == dp.MagicType.gongfa or
						(_operateType == UIBagGongFaList.OperateType.fabaoSell or _operateType == UIBagGongFaList.OperateType.fabaoEquip or (_operateType == UIBagGongFaList.OperateType.magicUpgrade and _sendMagicData == dp.MagicType.treasure)) and _magicType == dp.MagicType.treasure then
							table.insert(magicThing,obj)
					end
				end
			end
		end
		utils.quickSort(magicThing,compareMagic)
        if UIGuidePeople.guideStep and _operateType == UIBagGongFaList.OperateType.fabaoEquip then
            local _guideItemIndex = nil
            for key, obj in pairs(magicThing) do
                if obj.int["3"] == 16 and key ~= 1 then
                    _guideItemIndex = key
                    break
                end
            end
            if _guideItemIndex then
                local _tempObj = magicThing[1]
                magicThing[1] = magicThing[_guideItemIndex]
                magicThing[_guideItemIndex] = _tempObj
            end
        end
	end

	if next(magicThing) then
		utils.updateView(UIBagGongFaList,scrollView,sv_item,magicThing,setScrollViewItem)
	end
end

function UIBagGongFaList.setOperateType(operateType, sendMagicData, param, instMagicId)
	_operateType = operateType
	_sendMagicData = sendMagicData
	_param = param
	_instMagicId = instMagicId
end

function UIBagGongFaList.free()
	scrollView:removeAllChildren()
	ui_text_selected = nil
	ui_text_exp = nil --选择的功法总经验标签
	_totalNumber = 0
	selectedInstGongFaIds = nil
	text_exp = nil
	text_selected =nil
	_sendMagicData = nil
	_param = nil
	_instMagicId = nil
	if not tolua.isnull(sv_item) and sv_item:getReferenceCount() >=1 then 
      sv_item:release()
      sv_item = nil
  	end
end
