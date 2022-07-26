require"Lang"
UIBagEquipmentSell = {}

UIBagEquipmentSell.OperateType = {
	Add = 1, --添加
	Change = 2, --更换
	SellEquip = 3, --出售装备
	SellChip = 4, --出售装备碎片
}

local ui_title = nil
local scrollView = nil
local equipItem = nil
local equipChipItem = nil
local equipChangeItem = nil
local _equipType = nil
local _instCardId = nil
local _operateType = nil
local ui_text_choose_number = nil
local ui_text_sell_number =nil
local ui_btn_sell = nil
local choose_number = 0
local Price=0 --- 出售后获得的价钱
local selectedInstId = {}
local EquipThing = {}
local function netCallbackFunc(data)
	AudioEngine.playEffect("sound/putOn.mp3")
	UIManager.popAllScene()
	UILineup.setup()
end
local function netSellFunc(pack)
  UIManager.showToast(Lang.ui_bag_equipment_sell1 .. Price ..Lang.ui_bag_equipment_sell2)
  choose_number = 0
  Price=0
  selectedInstId={}
  UIManager.flushWidget(UITeamInfo)
  UIManager.flushWidget(UIBagEquipment)
  UIManager.flushWidget(UIBagEquipmentSell)
end

local function compareEquip(value1,value2)
    local value1QualityId = (value1.int["8"] >= 1000) and DictEquipAdvancered[tostring(value1.int["8"])].equipQualityId or DictEquipment[tostring(value1.int["4"])].equipQualityId
    local value2QualityId = (value2.int["8"] >= 1000) and DictEquipAdvancered[tostring(value2.int["8"])].equipQualityId or DictEquipment[tostring(value2.int["4"])].equipQualityId
    if value1QualityId > value2QualityId then
        if _operateType == UIBagEquipmentSell.OperateType.SellEquip then
        	return true 
        else 
        	return false
        end
    elseif value1QualityId < value2QualityId then
        if _operateType == UIBagEquipmentSell.OperateType.SellEquip then
        	return false 
        else 
        	return true
        end
    else
        if value1.int["5"] > value2.int["5"] then
          	if _operateType == UIBagEquipmentSell.OperateType.SellEquip then
	        	return true 
	        else 
	        	return false
	        end
        elseif value1.int["5"] < value2.int["5"] then
          	if _operateType == UIBagEquipmentSell.OperateType.SellEquip then
	        	return false 
	        else 
	        	return true
	        end
        else 
          if DictEquipment[tostring(value1.int["4"])].qualityLevel > DictEquipment[tostring(value2.int["4"])].qualityLevel then 
              	if _operateType == UIBagEquipmentSell.OperateType.SellEquip then
		        	return true 
		        else 
		        	return false
		        end
          else
             	if _operateType == UIBagEquipmentSell.OperateType.SellEquip then
		        	return false 
		        else 
		        	return true
		        end
          end
        end
    end
end

local function compareEquipChip(value1,value2)
    local DictData = DictThing[tostring(value1.int["3"])]
    local equipQualityId =  DictEquipment[tostring(DictData.equipmentId)].equipQualityId
    local qualityLevel = DictEquipment[tostring(DictData.equipmentId)].qualityLevel
    local DictData1 = DictThing[tostring(value2.int["3"])]
    local equipQualityId1 =  DictEquipment[tostring(DictData1.equipmentId)].equipQualityId
    local qualityLevel1 = DictEquipment[tostring(DictData1.equipmentId)].qualityLevel
    if equipQualityId > equipQualityId1 then
        return true
    elseif equipQualityId < equipQualityId1 then
        return false
    else
        if qualityLevel > qualityLevel1 then
          return  true
        else
          return false
        end
    end
end

local function sendSellData(_sellIds,_type)
    local  sendData = {
      header = StaticMsgRule.sell,
      msgdata = {
        int = {
          buyNum = 1,
          type = _type,
        },
        string = {
          sellIds  = _sellIds,
        }
      }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netSellFunc)
end
function UIBagEquipmentSell.init()
  
	ui_title = ccui.Helper:seekNodeByName(UIBagEquipmentSell.Widget, "text_equipment_sell")
  ui_text_choose_number = ccui.Helper:seekNodeByName(UIBagEquipmentSell.Widget,"text_choose_number")
  ui_text_sell_number =ccui.Helper:seekNodeByName(UIBagEquipmentSell.Widget,"text_sell_number")
  ui_btn_sell = ccui.Helper:seekNodeByName(UIBagEquipmentSell.Widget,"btn_sell")
	local btn_close = ccui.Helper:seekNodeByName(UIBagEquipmentSell.Widget, "btn_close")
	btn_close:setPressedActionEnabled(true)
	ui_btn_sell:setPressedActionEnabled(true)
	ui_text_choose_number:setVisible(false)
	ui_text_sell_number:setVisible(false)
	ui_btn_sell:setVisible(false)
	local function btn_Event(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			 if sender == btn_close then 
			      UIManager.popScene()
			 elseif sender == ui_btn_sell then 
			     if next(selectedInstId) then 
      			     local sellIds = ""
      			     local i = 0
      			     for key,obj in pairs(selectedInstId) do
      			         i = i + 1
      			         if i == choose_number then 
      			              sellIds = sellIds .. obj 
      			         else
      			             sellIds = sellIds .. obj .. ";"
      			         end
      			         
      			     end
      			     cclog("sellIds=" .. sellIds)
      			     sendSellData(tostring(sellIds),2)
			     else
			         UIManager.showToast(Lang.ui_bag_equipment_sell3)
			     end
			 end
		end
	end
	btn_close:addTouchEventListener(btn_Event)
	ui_btn_sell:addTouchEventListener(btn_Event)
	scrollView = ccui.Helper:seekNodeByName(UIBagEquipmentSell.Widget, "view_equipment")
	equipItem = scrollView:getChildByName("image_base_equipment")
	equipChipItem = scrollView:getChildByName("image_base_chip")
	equipChangeItem = scrollView:getChildByName("image_base_choose")
	equipItem:removeFromParent()
	equipChipItem:removeFromParent()
	equipChangeItem:removeFromParent()
end

--设置装备碎片滚动项
local function setChipScrollViewItem(item, data)
	local chipFrame = item:getChildByName("image_frame_chip")
	local chipIcon = chipFrame:getChildByName("image_chip")
	local chipName = item:getChildByName("text_chip_name")
	local chipCount = item:getChildByName("text_number")
	local chipPZ = ccui.Helper:seekNodeByName(item,"label_pz")
	local chipDescribe = ccui.Helper:seekNodeByName(item,"text_gem_describe")
	local btn_sell = item:getChildByName("btn_lineup")
	local chipPrice = ccui.Helper:seekNodeByName(item,"text_price")
	local DictData = DictThing[tostring(data.int["3"])]
	local name = DictData.name
	local image =utils.getThingImage(data.int["3"],false)
	local number = data.int["5"]
	chipIcon:loadTexture(image)
	chipName:setString(name)
	chipCount:setString(Lang.ui_bag_equipment_sell4 .. number)
	chipPrice:setString(string.format("×%d",DictThing[tostring(data.int["3"])].sellCopper))
	local _equipQualityId =  DictEquipment[tostring(DictData.equipmentId)].equipQualityId
	local qualityLevel = DictEquipment[tostring(DictData.equipmentId)].qualityLevel
	local collectNum = DictEquipQuality[tostring(_equipQualityId)].thingNum
	chipDescribe:setString(Lang.ui_bag_equipment_sell5.. collectNum .. Lang.ui_bag_equipment_sell6)
	chipPZ:setString(qualityLevel)
	utils.changeNameColor(chipName,_equipQualityId)
	utils.addBorderImage(StaticTableType.DictThing,data.int["3"],chipFrame)
	local function btn_sellEvent(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
	    UISellProp.setData(data,UIBagEquipmentSell)
	    UIManager.pushScene("ui_sell_prop")
	end
	end
	btn_sell:addTouchEventListener(btn_sellEvent)
end
--设置装备滚动项
local function setEquipScrollViewItem(item, data)
  	local box_sell = ccui.Helper:seekNodeByName(item, "box_sell")
	local instEquipId = data.int["1"] --装备实例ID
	local equipTypeId = data.int["3"] --装备类型ID
	local dictEquipId = data.int["4"] --装备字典ID
	local equipLv = data.int["5"] --装备等级
	local dictEquipData = DictEquipment[tostring(dictEquipId)] --装备字典表
    local equipAdvanceId = data.int["8"] --装备进阶字典ID
	local dictEquipAdvanceData = equipAdvanceId >= 1000 and DictEquipAdvancered[tostring(equipAdvanceId)] or DictEquipAdvance[tostring(equipAdvanceId)] --装备进阶字典表

    if dictEquipData.equipQualityId == StaticEquip_Quality.white or dictEquipData.equipQualityId == StaticEquip_Quality.green then
        for i = 1, 5 do
		    item:getChildByName("image_star"..i):setVisible(false)
        end
    else
       
        local equipAdvanceData = {}
	    for key, obj in pairs(DictEquipAdvance) do
		    if equipTypeId == obj.equipTypeId and dictEquipData.equipQualityId == obj.equipQualityId then
			    equipAdvanceData[#equipAdvanceData + 1] = obj
		    end
	    end
	    utils.quickSort(equipAdvanceData,function(obj1, obj2) if obj1.id > obj2.id then return true end end)
        if equipAdvanceId == 0 and (not dictEquipAdvanceData) then
		    dictEquipAdvanceData = equipAdvanceData[1]
	    end
        for i = 1, 5 do
		    local ui_starImg = item:getChildByName("image_star"..i)
		    if equipAdvanceId ~= 0 and dictEquipAdvanceData.starLevel >= i then
			    ui_starImg:loadTexture("ui/star01.png")
		    else
			    ui_starImg:loadTexture("ui/star02.png")
		    end
		    if i > 3 and dictEquipData.equipQualityId == StaticEquip_Quality.blue then
			    ui_starImg:setVisible(false)
		    else
			    ui_starImg:setVisible(true)
		    end
	    end
    end

	local ItemProp ={}
	local image_gem={}
	local equipName = ccui.Helper:seekNodeByName(item, "text_name_equipment")
	equipName:setString(dictEquipData.name)
	local equipFrame = ccui.Helper:seekNodeByName(item, "image_frame_equipment")
	
    if dictEquipAdvanceData then
        equipFrame:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipAdvanceData.equipQualityId, dp.QualityImageType.small))
        utils.changeNameColor(equipName,dictEquipAdvanceData.equipQualityId)
    else
        equipFrame:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipData.equipQualityId, dp.QualityImageType.small))
	    utils.changeNameColor(equipName,dictEquipData.equipQualityId)
    end
	local equipIcon = equipFrame:getChildByName("image_equipment")
	local smallFileName = (DictUI[tostring(equipAdvanceId >= 1000 and dictEquipData.RedsmallUiId or dictEquipData.smallUiId)]).fileName
	equipIcon:loadTexture("image/" .. smallFileName)
	box_sell:setTag(instEquipId)
	local equipLevel = ccui.Helper:seekNodeByName(equipFrame, "text_lv")
	equipLevel:setString(string.format(Lang.ui_bag_equipment_sell7,equipLv))
	ItemProp[1] = ccui.Helper:seekNodeByName(item, "text_add_attack")
	ItemProp[2] = ccui.Helper:seekNodeByName(item, "text_add_defense")
	for i =1 ,4 do
      image_gem[#image_gem+1] = ccui.Helper:seekNodeByName(item,"image_frame_gem" .. i )
  	end
	local equipPrice = ccui.Helper:seekNodeByName(item, "image_price")
	local text_price = equipPrice:getChildByName("text_price")
    local dictEquipStrengthen = DictEquipStrengthen[tostring(equipLv)]
    local _price = 0
	if dictEquipStrengthen then
		    if dictEquipData.equipQualityId == StaticEquip_Quality.white then
			    _price = dictEquipStrengthen.whiteCopper
		    elseif dictEquipData.equipQualityId == StaticEquip_Quality.green then
			    _price = dictEquipStrengthen.greenCopper
		    elseif dictEquipData.equipQualityId == StaticEquip_Quality.blue then
			    _price = dictEquipStrengthen.blueCopper
		    elseif dictEquipData.equipQualityId == StaticEquip_Quality.purple then
			    _price = dictEquipStrengthen.purpleCopper
		    elseif dictEquipData.equipQualityId == StaticEquip_Quality.golden then
			    _price = dictEquipStrengthen.goldenCopper
		    end
	end
	text_price:setString(dictEquipData.sellPrice + _price)
	local equipQuality  = ccui.Helper:seekNodeByName(equipFrame, "label_pz")
	equipQuality:setString(dictEquipData.qualityLevel)
	local equipPropData = {}
  	local propData = utils.stringSplit(dictEquipData.propAndAdd, ";")
 	for key, obj in pairs(propData) do
   	 equipPropData[key] = utils.stringSplit(obj, "_") --[1]:fightPropId, [2]:initValue, [3]:addValue
  	end
  	if #equipPropData == 1 then
    	ItemProp[2]:setVisible(false)
  	else 
  		ItemProp[2]:setVisible(true)
  	end
  	local attribs = utils.getEquipAttribute(data.int["1"])
	for key, obj in pairs(equipPropData) do
	      local fightPropId, initValue, addValue = tonumber(obj[1]), tonumber(obj[2]), tonumber(obj[3])
	      ItemProp[key]:setString(DictFightProp[tostring(fightPropId)].name .. "：" .. attribs[fightPropId])
	end
 	local inlayThingId = {}
 	if net.InstEquipGem then
	    for key, obj in pairs(net.InstEquipGem) do
	      if instEquipId == obj.int["3"] then
	          inlayThingId[obj.int["5"]] = obj.int["4"] --物品Id 0表示未镶嵌宝石
	      end
	    end
 	end
 	local dictEquipQualityData = DictEquipQuality[tostring(dictEquipData.equipQualityId)] --装备品质字典表
  	local holeNum = dictEquipQualityData.holeNum --拥有宝石孔数
	for key, uiItem in pairs(image_gem) do
      if key <= holeNum then
        uiItem:setVisible(true)
        local _icon = uiItem:getChildByName("image_gem" .. key)
        local _thingId = inlayThingId[key]
        if _thingId then
          if _thingId == 0 then
            --已打孔了
            _icon:loadTexture("ui/frame_tianjia.png")
          else
            --镶嵌了物品
            local dictThingData = DictThing[tostring(_thingId)]
            _icon:loadTexture("image/" .. DictUI[tostring(dictThingData.smallUiId)].fileName)
          end
        else
          --未打孔
          _icon:loadTexture("ui/mg_suo.png")
        end
      else
        uiItem:setVisible(false)
      end
	end
	local function isContain(id)
		for key, obj in pairs(selectedInstId) do
			if obj == id then
				return true
			end
		end
		return false
	end
	if not isContain(instEquipId) then
		box_sell:setSelected(false)
	else 
		box_sell:setSelected(true)
	end
	local function ui_checkBoxEvent(sender,eventType)
	    if eventType == ccui.CheckBoxEventType.selected then
	    	if choose_number == 30 then 
				UIManager.showToast(Lang.ui_bag_equipment_sell8)
				box_sell:setSelected(false)
				return 
			end
			choose_number = choose_number +1
			Price = Price + dictEquipData.sellPrice
			table.insert(selectedInstId,sender:getTag())
	    elseif eventType == ccui.CheckBoxEventType.unselected then
			choose_number =choose_number -1
			Price = Price - dictEquipData.sellPrice
			for key, obj in pairs(selectedInstId) do
				if obj == sender:getTag() then
					table.remove(selectedInstId,key)
				end
			end
	    end
	    ui_text_choose_number:setString(Lang.ui_bag_equipment_sell9 .. choose_number)
	    ui_text_sell_number:setString(Lang.ui_bag_equipment_sell10 .. Price)
	  end
	  box_sell:addEventListener(ui_checkBoxEvent)
end
----更换和装备----------
local function setChangeEquipScrollViewItem(item, data)
	local instEquipId = data.int["1"] --装备实例ID
	local equipTypeId = data.int["3"] --装备类型ID
	local dictEquipId = data.int["4"] --装备字典ID
	local equipLv = data.int["5"] --装备等级
	local dictEquipData = DictEquipment[tostring(dictEquipId)] --装备字典表

    local equipAdvanceId = data.int["8"] --装备进阶字典ID
	local dictEquipAdvanceData = equipAdvanceId >= 1000 and DictEquipAdvancered[tostring(equipAdvanceId)] or DictEquipAdvance[tostring(equipAdvanceId)] --装备进阶字典表

    if dictEquipData.equipQualityId == StaticEquip_Quality.white or dictEquipData.equipQualityId == StaticEquip_Quality.green then
        for i = 1, 5 do
		    item:getChildByName("image_star"..i):setVisible(false)
        end
    else
        

        local equipAdvanceData = {}
	    for key, obj in pairs(DictEquipAdvance) do
		    if equipTypeId == obj.equipTypeId and dictEquipData.equipQualityId == obj.equipQualityId then
			    equipAdvanceData[#equipAdvanceData + 1] = obj
		    end
	    end
	    utils.quickSort(equipAdvanceData,function(obj1, obj2) if obj1.id > obj2.id then return true end end)
        if equipAdvanceId == 0 and (not dictEquipAdvanceData) then
		    dictEquipAdvanceData = equipAdvanceData[1]
	    end
        for i = 1, 5 do
		    local ui_starImg = item:getChildByName("image_star"..i)
		    if equipAdvanceId ~= 0 and dictEquipAdvanceData.starLevel >= i then
			    ui_starImg:loadTexture("ui/star01.png")
		    else
			    ui_starImg:loadTexture("ui/star02.png")
		    end
		    if i > 3 and dictEquipData.equipQualityId == StaticEquip_Quality.blue then
			    ui_starImg:setVisible(false)
		    else
			    ui_starImg:setVisible(true)
		    end
	    end
    end

	local ItemProp ={}
	local image_gem={}
	local equipName = ccui.Helper:seekNodeByName(item, "text_name_equipment")
	equipName:setString(dictEquipData.name)
	local equipFrame = ccui.Helper:seekNodeByName(item, "image_frame_equipment")	
    if dictEquipAdvanceData then
        equipFrame:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipAdvanceData.equipQualityId, dp.QualityImageType.small))
        utils.changeNameColor(equipName,dictEquipAdvanceData.equipQualityId)
    else
        equipFrame:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipData.equipQualityId, dp.QualityImageType.small))
	    utils.changeNameColor(equipName,dictEquipData.equipQualityId)
    end
	local equipIcon = equipFrame:getChildByName("image_equipment")
	local smallFileName = (DictUI[tostring(equipAdvanceId >= 1000 and dictEquipData.RedsmallUiId or dictEquipData.smallUiId)]).fileName
	equipIcon:loadTexture("image/" .. smallFileName)

    local suitEquipData = utils.getEquipSuit(tostring( data.int["4"] ) )
    utils.addFrameParticle( equipIcon , suitEquipData )

	local equipLevel = ccui.Helper:seekNodeByName(item, "text_lv")
	equipLevel:setString(string.format(Lang.ui_bag_equipment_sell11,equipLv))
	ItemProp[1] = ccui.Helper:seekNodeByName(item, "text_add_attack")
	ItemProp[2] = ccui.Helper:seekNodeByName(item, "text_add_defense")
	for i =1 ,4 do
      image_gem[#image_gem+1] = ccui.Helper:seekNodeByName(item,"image_frame_gem" .. i )
  	end
	local btn_Equip = ccui.Helper:seekNodeByName(item,"btn_inlay")
	local equipQuality  = ccui.Helper:seekNodeByName(item, "label_pz")
	equipQuality:setString(dictEquipData.qualityLevel)
	local equipPropData = {}
  	local propData = utils.stringSplit(dictEquipData.propAndAdd, ";")
  	for key, obj in pairs(propData) do
   	 equipPropData[key] = utils.stringSplit(obj, "_") --[1]:fightPropId, [2]:initValue, [3]:addValue
  	end
  	if #equipPropData == 1 then
   	 ItemProp[2]:setVisible(false)
  	end
  	local attribs = utils.getEquipAttribute(data.int["1"])
  	for key, obj in pairs(equipPropData) do
      local fightPropId, initValue, addValue = tonumber(obj[1]), tonumber(obj[2]), tonumber(obj[3])
      ItemProp[key]:setString(DictFightProp[tostring(fightPropId)].name .. "：" .. attribs[fightPropId])
  	end
  	local inlayThingId = {}
 	if net.InstEquipGem then
    	for key, obj in pairs(net.InstEquipGem) do
      		if instEquipId == obj.int["3"] then
          		inlayThingId[obj.int["5"]] = obj.int["4"] --物品Id 0表示未镶嵌宝石
      		end
    	end
  	end
  	local dictEquipQualityData = DictEquipQuality[tostring(dictEquipData.equipQualityId)] --装备品质字典表
  	local holeNum = dictEquipQualityData.holeNum --拥有宝石孔数
  	for key, uiItem in pairs(image_gem) do
      if key <= holeNum then
        uiItem:setVisible(true)
        local _icon = uiItem:getChildByName("image_gem" .. key)
        local _thingId = inlayThingId[key]
        if _thingId then
          if _thingId == 0 then
            --已打孔了
            _icon:loadTexture("ui/frame_tianjia.png")
          else
            --镶嵌了物品
            local dictThingData = DictThing[tostring(_thingId)]
            _icon:loadTexture("image/" .. DictUI[tostring(dictThingData.smallUiId)].fileName)
          end
        else
          --未打孔
          _icon:loadTexture("ui/mg_suo.png")
        end
      else
        uiItem:setVisible(false)
      end
  	end	
	btn_Equip:setPressedActionEnabled(true)
	----装备事件
	local function btn_Event(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
				local sendData = {
					header = StaticMsgRule.addEquipment,
					msgdata = {
						int = {
							instPlayerEquipId = instEquipId,
							instPlayerCardId = _instCardId,
							equipTypeId = _equipType,
							operate = _operateType
						}
					}
				}
				UIManager.showLoading()
				netSendPackage(sendData, netCallbackFunc)
		end
	end
	btn_Equip:addTouchEventListener(btn_Event)
	if item:getTag() == 1 then 
		local param = {}
		param[1] = btn_Event
		param[2] = btn_Equip
		UIGuidePeople.isGuide(param,UIBagEquipmentSell)
	end
end

function UIBagEquipmentSell.setup()
	if equipItem:getReferenceCount() == 1 then
		equipItem:retain()
	end
	if equipChipItem:getReferenceCount() == 1 then
		equipChipItem:retain()
	end
	if equipChangeItem:getReferenceCount() == 1 then
		equipChangeItem:retain()
	end
	scrollView:removeAllChildren()
	EquipThing = {}
	if _operateType == UIBagEquipmentSell.OperateType.SellChip then
		ui_title:setString(Lang.ui_bag_equipment_sell12)
		if net.InstPlayerThing  then
			for key, obj in pairs(net.InstPlayerThing) do
				if obj.int["7"] == StaticBag_Type.equipChip then
					table.insert(EquipThing,obj)
				end
			end
		end
		utils.quickSort(EquipThing,compareEquipChip)
		ui_text_choose_number:setVisible(false)
		ui_text_sell_number:setVisible(false)
		ui_btn_sell:setVisible(false)
	else
		if _operateType == UIBagEquipmentSell.OperateType.SellEquip then
			ui_title:setString(Lang.ui_bag_equipment_sell13)
			ui_text_choose_number:setVisible(true)
			ui_text_sell_number:setVisible(true)
			ui_btn_sell:setVisible(true)
			ui_text_choose_number:setString(Lang.ui_bag_equipment_sell14 .. choose_number)
			ui_text_sell_number:setString(Lang.ui_bag_equipment_sell15 .. Price)
		else
			ui_title:setString(Lang.ui_bag_equipment_sell16)
			ui_text_choose_number:setVisible(false)
			ui_text_sell_number:setVisible(false)
			ui_btn_sell:setVisible(false)
		end
		if net.InstPlayerEquip then
			for key, obj in pairs(net.InstPlayerEquip) do
				local equipTypeId = obj.int["3"] --装备类型ID
				local instCardId = obj.int["6"] --对应的卡牌实例ID  0-未装备 否则是已装备
				if _operateType == UIBagEquipmentSell.OperateType.SellEquip then
					if instCardId == 0 then
						table.insert(EquipThing,obj)
					end
				else
					if equipTypeId == _equipType and instCardId == 0 then
						table.insert(EquipThing,obj)
					end
				end
			end
			utils.quickSort(EquipThing,compareEquip)
		end
	end
	if next(EquipThing) then
      	if _operateType == UIBagEquipmentSell.OperateType.SellChip then
			utils.updateView(UIBagEquipmentSell,scrollView,equipChipItem,EquipThing,setChipScrollViewItem)
		elseif _operateType == UIBagEquipmentSell.OperateType.SellEquip then 
			utils.updateView(UIBagEquipmentSell,scrollView,equipItem,EquipThing,setEquipScrollViewItem)
		else 
			utils.updateView(UIBagEquipmentSell,scrollView,equipChangeItem,EquipThing,setChangeEquipScrollViewItem)
		end
    end
end

function UIBagEquipmentSell.setEquipType(equipType)
	_equipType = equipType
end

function UIBagEquipmentSell.setInstCardId(instCardId)
	_instCardId = instCardId
end

function UIBagEquipmentSell.setOperateType(operateType)
	_operateType = operateType
end

function UIBagEquipmentSell.free()
	selectedInstId = {}
	choose_number = 0
    Price=0
   	if not tolua.isnull(equipChipItem) and equipChipItem:getReferenceCount() >=1 then 
      equipChipItem:release()
      equipChipItem = nil
  	end
  	if not tolua.isnull(equipItem) and equipItem:getReferenceCount() >=1 then 
      equipItem:release()
      equipItem = nil
  	end
  	if not tolua.isnull(equipChangeItem) and equipChangeItem:getReferenceCount() >=1 then 
      equipChangeItem:release()
      equipChangeItem = nil
  	end
end
