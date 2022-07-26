require"Lang"
UIGoodInfo = {}
local _touchEvent = true
local param = nil 
function UIGoodInfo.init( ... )
	local btn_close = ccui.Helper:seekNodeByName(UIGoodInfo.Widget, "btn_close")
  local ui_text_hint = ccui.Helper:seekNodeByName(UIGoodInfo.Widget, "text_hint")
  local ui_base_chip = ccui.Helper:seekNodeByName(UIGoodInfo.Widget, "image_base_chip")
  local function TouchEvent(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
      if sender == ui_text_hint or (sender == ui_base_chip and ui_text_hint:isVisible()) then 
        AudioEngine.playEffect("sound/button.mp3")
        UIManager.popScene()
       	if tonumber(param.tableTypeId) == StaticTableType.DictCardSoul then
       		local dictCardSoul = DictCardSoul[tostring(param.tableFieldId)]
					local dictData = DictCard[tostring(dictCardSoul.cardId)]
       		UICardInfo.setDictCardId(dictData.id)
					UIManager.pushScene("ui_card_info")
       	elseif tonumber(param.tableTypeId) == StaticTableType.DictChip then
       		local dictChipData = DictChip[tostring(param.tableFieldId)]
       		local dictGongFaorSkillData = DictMagic[tostring(dictChipData.skillOrKungFuId)]
					UIGongfaInfo.setDictMagicId(dictGongFaorSkillData.id)
					UIManager.pushScene("ui_gongfa_info")
       	end
      elseif sender == btn_close then 
      	AudioEngine.playEffect("sound/button.mp3")
        UIManager.popScene()
      elseif (sender == ui_text_hint or sender == ui_base_chip) and (not ui_text_hint:isVisible()) and _touchEvent then
      	_touchEvent = false
      	UIManager.popScene()
        if tonumber(param.tableTypeId) == StaticTableType.DictThing then
            local DictData = DictThing[tostring(param.tableFieldId)]
            local dictEquipId = DictData.equipmentId --装备字典ID
            if dictEquipId ~= nill and dictEquipId > 0 then
                local dictEquipData = DictEquipment[tostring(dictEquipId)]
                local suitEquipData = utils.getEquipSuit(tostring( dictEquipId ) )
                if dictEquipData.equipQualityId >= 3 and suitEquipData then
                    UIEquipmentNew.setDictEquipId(dictEquipId)
                    UIManager.pushScene("ui_equipment_new")
                else
                    UIEquipmentInfo.setDictEquipId(dictEquipId)
	                UIManager.pushScene("ui_equipment_info")
                end
            end
        elseif tonumber(param.tableTypeId) == StaticTableType.DictEquipment then
            local dictEquipData = DictEquipment[tostring(param.tableFieldId)]
            local suitEquipData = utils.getEquipSuit(tostring( param.tableFieldId ) )
            if dictEquipData.equipQualityId >= 3 and suitEquipData then
                UIEquipmentNew.setDictEquipId(param.tableFieldId)
                UIManager.pushScene("ui_equipment_new")
            else
                UIEquipmentInfo.setDictEquipId(param.tableFieldId)
	            UIManager.pushScene("ui_equipment_info")
            end
       	end
      end
    end
  end
  btn_close:setPressedActionEnabled(true)
  btn_close:addTouchEventListener(TouchEvent)
  ui_base_chip:setTouchEnabled(true)
  ui_text_hint:setTouchEnabled(true)
  ui_base_chip:addTouchEventListener(TouchEvent)
  ui_text_hint:addTouchEventListener(TouchEvent)
  UIGoodInfo.Widget:addTouchEventListener(function(sender, eventType)
  	if eventType == ccui.TouchEventType.ended and _touchEvent then
  		_touchEvent = false
  		if UIGoodInfo.Widget:getChildByName("image_di"):getChildByName("text_go"):isVisible() then
  			UIManager.popScene()
  		end
 		end
  end)
end

function UIGoodInfo.setup( ... )
	local ui_text_hint = ccui.Helper:seekNodeByName(UIGoodInfo.Widget, "text_hint")
	local uiFrame = ccui.Helper:seekNodeByName(UIGoodInfo.Widget, "image_frame_chip")
	local uiImage = ccui.Helper:seekNodeByName(UIGoodInfo.Widget, "image_chip")
	local uiName = ccui.Helper:seekNodeByName(UIGoodInfo.Widget, "text_chip_name")
	local uiNum = ccui.Helper:seekNodeByName(UIGoodInfo.Widget, "text_number")
	local uiImagePz = ccui.Helper:seekNodeByName(UIGoodInfo.Widget, "image_pz")
	local uiLabelPz = ccui.Helper:seekNodeByName(UIGoodInfo.Widget, "label_pz")
	local uiDes = ccui.Helper:seekNodeByName(UIGoodInfo.Widget, "text_gem_describe")
    if param.tableTypeId == dp.TableType.DictUnionPractice then
        ccui.Helper:seekNodeByName(UIGoodInfo.Widget, "text_preview"):setString(Lang.ui_good_info1)
        uiNum:setVisible(false)
        uiImagePz:setVisible(false)
        ui_text_hint:setVisible(false)
        local _dictData = DictUnionPractice[tostring(param.tableFieldId)]
        uiImage:loadTexture("image/" .. DictUI[tostring(_dictData.smallUiId)].fileName)
        uiName:setString(_dictData.name)
        uiDes:setString(string.format(_dictData.description, tostring(0 * _dictData.levelAdd)).."%")
        return
    end
	local thingName,thingIcon,description = utils.getDropThing(param.tableTypeId,param.tableFieldId)
	uiName:setString(thingName)
	uiDes:setString(description)
	uiImage:loadTexture(thingIcon)
	local qualityId = utils.addBorderImage(param.tableTypeId,param.tableFieldId,uiFrame)
    if tonumber(param.tableTypeId) == StaticTableType.DictMagic then 
      utils.changeNameColor(uiName,tonumber(qualityId),dp.Quality.gongFa)
    else 
      utils.changeNameColor(uiName,tonumber(qualityId))
    end
    local havaNum = 0
    local totalNum = 0
    uiNum:setVisible(false)
    ui_text_hint:setVisible(false)
    uiImagePz:setVisible(false)
	if tonumber(param.tableTypeId) == StaticTableType.DictCardSoul then
		if net.InstPlayerCardSoul then 
			for key,obj in pairs(net.InstPlayerCardSoul) do 
				if tonumber(param.tableFieldId) == obj.int["4"] then 
					havaNum = obj.int["5"]
					break 
				end
			end
		end
		local dictCardSoul = DictCardSoul[tostring(param.tableFieldId)]
		local dictData = DictCard[tostring(dictCardSoul.cardId)]
        local qualityId = dictData.qualityId
        local totalNum = DictQuality[tostring(qualityId)].soulNum
        uiNum:setVisible(true)
        ui_text_hint:setVisible(true)
        uiImagePz:setVisible(true)
        uiImagePz:loadTexture("ui/zz.png")
        uiLabelPz:setString(dictData.nickname)
        uiNum:setString(string.format(Lang.ui_good_info2,havaNum,totalNum))
	elseif tonumber(param.tableTypeId) == StaticTableType.DictCard then
		local dictData = DictCard[tostring(param.tableFieldId)]
		uiImagePz:setVisible(true)
        uiImagePz:loadTexture("ui/zz.png")
        uiLabelPz:setString(dictData.nickname)
    elseif tonumber(param.tableTypeId) == StaticTableType.DictEquipment then
    	local dictEquipData = DictEquipment[tostring(param.tableFieldId)]
		uiImagePz:setVisible(true)
        uiImagePz:loadTexture("ui/pz.png")
        uiLabelPz:setString(dictEquipData.qualityLevel)
	elseif tonumber(param.tableTypeId) == StaticTableType.DictThing then
		local dictData = DictThing[tostring(param.tableFieldId)]
		if dictData.bagTypeId == 3 then 
            if net.InstPlayerThing then 
                for key, obj in pairs(net.InstPlayerThing) do
                      if obj.int["3"] == tonumber(param.tableFieldId) then 
                        havaNum = obj.int["5"]
                        break
                      end
                end
            end
			local dictEquipData = DictEquipment[tostring(dictData.equipmentId)]
			local _equipQualityId =  dictEquipData.equipQualityId
	        totalNum = DictEquipQuality[tostring(_equipQualityId)].thingNum
	        uiNum:setVisible(true)
	        uiNum:setString(string.format(Lang.ui_good_info3,havaNum,totalNum))
			uiImagePz:setVisible(true)
	        uiImagePz:loadTexture("ui/pz.png")
	        uiLabelPz:setString(dictEquipData.qualityLevel)
	    end
	elseif tonumber(param.tableTypeId) == StaticTableType.DictChip then
		ui_text_hint:setVisible(true)
		uiImagePz:setVisible(true)
        uiImagePz:loadTexture("ui/pz.png")
        local tempData = DictChip[tostring(param.tableFieldId)]
        local dicData = DictMagic[tostring(tempData.skillOrKungFuId)]
        uiLabelPz:setString(dicData.grade)
    elseif tonumber(param.tableTypeId) == StaticTableType.DictFightSoul then
        
	end
	UIGoodInfo.Widget:getChildByName("image_di"):getChildByName("text_go"):setVisible(not ui_text_hint:isVisible())
end

function UIGoodInfo.setParam(_param)
    param = _param
end

function UIGoodInfo.free()
	param = nil
	_touchEvent = true
end

function UIGoodInfo.show(_param)
    param = _param
    UIManager.pushScene("ui_good_info")
end
