require"Lang"
UIBagEquipment = {}

local scrollView = nil
local equipItem = nil
local chipItem = nil

local btn_equipment = nil --装备标签按钮
local btn_chip = nil --碎片标签按钮
local btn_expansion = nil --扩充按钮
local btn_sell = nil --出售按钮
local ui_maxBagCount = nil --背包上限
local equipFlag = 1
local EquipThing ={}
local btnSelected = nil
local btnSelectedText =nil
local expandNum = 0 --背包扩展的总数
local expandPrice = 0
local CollectEquipName =nil
local function netCallbackFunc(pack)
  if tonumber(pack.header) == StaticMsgRule.bagExpand then
    UIManager.showToast(Lang.ui_bag_equipment1)
    UIBagEquipment.Widget:removeChildByTag(100)
    UIBagEquipment.Widget:setEnabled(true)
    UIMenu.Widget:setEnabled(true)
    UIManager.flushWidget(UIBagEquipment)
    UIManager.flushWidget(UITeamInfo)
  elseif tonumber(pack.header) == StaticMsgRule.equipPiece then
    UIManager.showToast(Lang.ui_bag_equipment2 .. CollectEquipName )
    UIManager.flushWidget(UIBagEquipment)
  end
end

local function sendCollectData(EquipChipId)
    local  sendData = {
      header = StaticMsgRule.equipPiece,
      msgdata = {
        int = {
          instThingId   = EquipChipId,
        }
      }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end

local function compareEquip(value1,value2)
    if value1.int["6"] ~= 0 and  value2.int["6"] == 0 then 
        return  false
    elseif value1.int["6"] == 0 and  value2.int["6"] ~= 0 then 
        return  true
    else 
        local value1QualityId = (value1.int["8"] >= 1000) and DictEquipAdvancered[tostring(value1.int["8"])].equipQualityId or DictEquipment[tostring(value1.int["4"])].equipQualityId
        local value2QualityId = (value2.int["8"] >= 1000) and DictEquipAdvancered[tostring(value2.int["8"])].equipQualityId or DictEquipment[tostring(value2.int["4"])].equipQualityId
        if value1QualityId < value2QualityId then
            return true
        elseif value1QualityId > value2QualityId then
            return false
        else
            if value1.int["5"] < value2.int["5"] then
              return  true
            elseif value1.int["5"] > value2.int["5"] then
              return false
            else 
              if DictEquipment[tostring(value1.int["4"])].qualityLevel < DictEquipment[tostring(value2.int["4"])].qualityLevel then 
                  return true
              elseif DictEquipment[tostring(value1.int["4"])].qualityLevel > DictEquipment[tostring(value2.int["4"])].qualityLevel then 
                 return false
              else 
                if DictEquipment[tostring(value1.int["4"])].id == DictEquipment[tostring(value2.int["4"])].id then 
                  return true
                else 
                  return false
                end
              end
            end
        end
    end 
end

local function compareEquipChip(value1,value2)
    local DictData = DictThing[tostring(value1.int["3"])]
    local equipQualityId =  DictEquipment[tostring(DictData.equipmentId)].equipQualityId
    local collectNum = DictEquipQuality[tostring(equipQualityId)].thingNum
    --local qualityLevel = DictEquipment[tostring(DictData.equipmentId)].qualityLevel
    local DictData1 = DictThing[tostring(value2.int["3"])]
    local equipQualityId1 =  DictEquipment[tostring(DictData1.equipmentId)].equipQualityId
    local collectNum1 = DictEquipQuality[tostring(equipQualityId1)].thingNum
    --local qualityLevel1 = DictEquipment[tostring(DictData1.equipmentId)].qualityLevel
    if value1.int["5"] < collectNum and value2.int["5"] >= collectNum1 then
        return true
    elseif value1.int["5"] >= collectNum and value2.int["5"] >= collectNum1 then
        if equipQualityId < equipQualityId1 then
            return true
        elseif equipQualityId == equipQualityId1 and value1.int["5"] < value2.int["5"] then
            return true
        else
            return false
        end
    elseif equipQualityId == equipQualityId1 then
        return value1.int["5"] < value2.int["5"]
    elseif equipQualityId ~= equipQualityId1 and value1.int["5"] < collectNum and value2.int["5"] < collectNum1 then
        return equipQualityId < equipQualityId1
    end
end

local function exitCallback()
  UIManager.showWidget("ui_team_info", "ui_bag_equipment")
end

local function ExpandCallBack()
    if expandPrice <= net.InstPlayer.int["5"] then
        if equipFlag == 1 then
            utils.sendExpandData(StaticBag_Type.equip,netCallbackFunc)
        elseif equipFlag ==2 then 
            utils.sendExpandData(StaticBag_Type.equipChip,netCallbackFunc)
        end
    else
         UIManager.showToast(Lang.ui_bag_equipment3)
    end
end
local function setScrollViewItem(flag,_Item, _obj)
    if flag == 1 then 
        local ItemProp ={}
        local image_gem = {}
        local ItemName = ccui.Helper:seekNodeByName(_Item,"text_name_equipment")
        local ItemEquipFor = ccui.Helper:seekNodeByName(_Item,"text_equipment_for")
        local ItemFrame = ccui.Helper:seekNodeByName(_Item,"image_frame_equipment")
        local ItemImage = ItemFrame:getChildByName("image_equipment")
        local ItemLevel = ccui.Helper:seekNodeByName(_Item,"text_lv")
        ItemProp[1] = ccui.Helper:seekNodeByName(_Item,"text_add_attack")
        ItemProp[2] = ccui.Helper:seekNodeByName(_Item,"text_add_defense")
        for i =1 ,4 do
            image_gem[#image_gem+1] = ccui.Helper:seekNodeByName(_Item,"image_frame_gem" .. i )
        end
        local ItemQuality = ccui.Helper:seekNodeByName(_Item,"label_pz")
        ItemLevel:setString(string.format(Lang.ui_bag_equipment4,_obj.int["5"]))
        local dictEquipData = DictEquipment[tostring(_obj.int["4"])] --装备字典表
        local equipAdvanceId = _obj.int["8"]
        local dictEquipAdvanceData = equipAdvanceId >= 1000 and DictEquipAdvancered[tostring(equipAdvanceId)] or DictEquipAdvance[tostring(equipAdvanceId)]
        local name = dictEquipData.name
        ItemName:setString(name)
        if dictEquipAdvanceData then
            utils.changeNameColor(ItemName,dictEquipAdvanceData.equipQualityId)
        else
            utils.changeNameColor(ItemName,dictEquipData.equipQualityId)
        end
        ItemImage:loadTexture("image/" .. DictUI[tostring(equipAdvanceId >= 1000 and dictEquipData.RedsmallUiId or dictEquipData.smallUiId)].fileName)
                          
                    
        local function btnTouchEventImg(sender, eventType)         
		    local dictEquipId = _obj.int["4"] --装备字典ID		  
            local suitEquipData = utils.getEquipSuit(tostring( dictEquipId ) )
		    if eventType == ccui.TouchEventType.ended then
			    if dictEquipData.equipQualityId >= 3 and suitEquipData then
                    UIEquipmentNew.setDictEquipId(dictEquipId , _obj )
                    UIManager.pushScene("ui_equipment_new")
                else
                    UIEquipmentInfo.setDictEquipId(dictEquipId , _obj )
					UIManager.pushScene("ui_equipment_info")
                end   
		    end
	    end
	    ItemImage:setTouchEnabled(true)
	    ItemImage:addTouchEventListener(btnTouchEventImg)

        local suitEquipData = utils.getEquipSuit(tostring( _obj.int["4"] ) )
        utils.addFrameParticle( ItemImage , suitEquipData )


        ItemQuality:setString(dictEquipData.qualityLevel)
        if dictEquipAdvanceData then
            ItemFrame:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipAdvanceData.equipQualityId, dp.QualityImageType.small))
        else
            ItemFrame:loadTexture(utils.getQualityImage(dp.Quality.equip, dictEquipData.equipQualityId, dp.QualityImageType.small))
        end
        if dictEquipData.equipQualityId == StaticEquip_Quality.white or dictEquipData.equipQualityId == StaticEquip_Quality.green then
          for i = 1, 5 do
            _Item:getChildByName("image_star" .. i):setVisible(false)
          end
        else
          local equipAdvanceData = {}
          for key, obj in pairs(DictEquipAdvance) do
            if _obj.int["3"] == obj.equipTypeId and dictEquipData.equipQualityId == obj.equipQualityId then
              equipAdvanceData[#equipAdvanceData + 1] = obj
            end
          end
          utils.quickSort(equipAdvanceData,function(obj1, obj2) if obj1.id > obj2.id then return true end end)
          if equipAdvanceId == 0 and (not dictEquipAdvanceData) then
            dictEquipAdvanceData = equipAdvanceData[1]
          end
          for i = 1, 5 do
            local ui_starImg = _Item:getChildByName("image_star" .. i)
            ui_starImg:setVisible(true)
            if equipAdvanceId ~= 0 and dictEquipAdvanceData.starLevel >= i then
              ui_starImg:loadTexture("ui/star01.png")
            else
              ui_starImg:loadTexture("ui/star02.png")
            end
            if i > 3 and dictEquipData.equipQualityId == StaticEquip_Quality.blue then
              ui_starImg:setVisible(false)
            end
          end
        end
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
        local attribs = utils.getEquipAttribute(_obj.int["1"])
        for key, obj in pairs(equipPropData) do
            local fightPropId, initValue, addValue = tonumber(obj[1]), tonumber(obj[2]), tonumber(obj[3])
            ItemProp[key]:setString(DictFightProp[tostring(fightPropId)].name .. "：" .. attribs[fightPropId])
        end
        local equipCardInstId = _obj.int["6"] --装备上卡牌ID
        if equipCardInstId == 0 then 
            ItemEquipFor:setVisible(false)
        else
            ItemEquipFor:setVisible(true)
            local cardName = DictCard[tostring(net.InstPlayerCard[tostring(equipCardInstId)].int["3"])].name
            ItemEquipFor:setString(Lang.ui_bag_equipment5 .. cardName)
        end
        local inlayThingId = {}
        if net.InstEquipGem then
          for key, obj in pairs(net.InstEquipGem) do
            if _obj.int["1"] == obj.int["3"] then
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
        local btn_intensify = ccui.Helper:seekNodeByName(_Item,"btn_intensify")
        local btn_clean = ccui.Helper:seekNodeByName(_Item,"btn_clean")
        local btn_inlay = ccui.Helper:seekNodeByName(_Item,"btn_inlay")
        local equipInstId = _obj.int["1"]
        local function btnTouchEvent(sender, eventType)
           if eventType == ccui.TouchEventType.ended then
                sender:retain()
                if sender == btn_intensify then --强化
                  UIEquipmentIntensify.setEquipInstId(equipInstId)
                  UIManager.pushScene("ui_equipment_intensify")
                elseif sender == btn_clean  then --进阶
                  local instEquipData = net.InstPlayerEquip[tostring(equipInstId)]
	              local equipAdvanceId = instEquipData.int["8"] --装备进阶字典ID
	              local dictEquipAdvanceData = DictEquipAdvance[tostring(equipAdvanceId)] --装备进阶字典表    
                if dictEquipData.equipQualityId == StaticEquip_Quality.white or dictEquipData.equipQualityId == StaticEquip_Quality.green then
                    UIManager.showToast((dictEquipData.equipQualityId == StaticEquip_Quality.white and Lang.ui_bag_equipment6 or Lang.ui_bag_equipment7) .. Lang.ui_bag_equipment8)
                elseif equipAdvanceId >= 1000 or (dictEquipAdvanceData and dictEquipAdvanceData.starLevel == 5 and dictEquipData.equipQualityId == StaticEquip_Quality.purple) then
                    UIEquipmentAdvance.show({ InstPlayerEquip_id = equipInstId})
                else
                    UIEquipmentClean.show({InstPlayerEquip_id = equipInstId})
                  end
                elseif sender == btn_inlay then --镶嵌
                  if net.InstPlayer.int["4"] < 16 then 
                    UIManager.showToast(Lang.ui_bag_equipment9)
                    cc.release(sender)
                    return 
                  end
                  UIGemInlay.setEquipInstId(equipInstId)
                  UIManager.pushScene("ui_gem_inlay")
                end
                cc.release(sender)
           end
        end
        btn_intensify:setPressedActionEnabled(true)
        btn_clean:setPressedActionEnabled(true)
        btn_inlay:setPressedActionEnabled(true)
        btn_intensify:addTouchEventListener(btnTouchEvent)
        btn_clean:addTouchEventListener(btnTouchEvent)
        btn_inlay:addTouchEventListener(btnTouchEvent)
        if _Item:getTag() == 1 then 
          local param = {}
          param[2] = btn_clean 
          param[3] = btn_inlay
          UIGuidePeople.isGuide(param,UIBagEquipment)
        end
    elseif flag == 2 then 
        local ItemName = ccui.Helper:seekNodeByName(_Item,"text_chip_name")
        local ItemFrame = _Item:getChildByName("image_frame_chip")
        local ItemImage = ItemFrame:getChildByName("image_chip")
        local ItemNum = ccui.Helper:seekNodeByName(_Item,"text_number")
        local ItemDescription = ccui.Helper:seekNodeByName(_Item,"text_gem_describe")
        local ItemCollect = ccui.Helper:seekNodeByName(_Item,"btn_lineup")
        local ItemQuality = ccui.Helper:seekNodeByName(_Item,"label_pz")
        local DictData = DictThing[tostring(_obj.int["3"])]
        local name = DictData.name
        local image =utils.getThingImage(_obj.int["3"],false)
        local number = _obj.int["5"]
        ItemImage:loadTexture(image)

        local function btnTouchEventImg(sender, eventType)         
		    local dictEquipId = DictData.equipmentId --装备字典ID		  
            local suitEquipData = utils.getEquipSuit(tostring( dictEquipId ) )
		    if eventType == ccui.TouchEventType.ended then
			    if suitEquipData then
                    UIEquipmentNew.setDictEquipId(dictEquipId)
                    UIManager.pushScene("ui_equipment_new")
                else
                    UIEquipmentInfo.setDictEquipId(dictEquipId)
					UIManager.pushScene("ui_equipment_info")
                end   
		    end
	    end
	    ItemImage:setTouchEnabled(true)
	    ItemImage:addTouchEventListener(btnTouchEventImg)

        

        ItemName:setString(name)
        ItemNum:setString(Lang.ui_bag_equipment10 .. number)
        local qualityLevel = DictEquipment[tostring(DictData.equipmentId)].qualityLevel
        local _equipQualityId = utils.addBorderImage(StaticTableType.DictThing,_obj.int["3"],ItemFrame)
        utils.changeNameColor(ItemName,_equipQualityId)
        local collectNum = DictEquipQuality[tostring(_equipQualityId)].thingNum
        ItemDescription:setString(Lang.ui_bag_equipment11.. collectNum .. Lang.ui_bag_equipment12)
        ItemQuality:setString(qualityLevel)
        if collectNum > number then
            ItemCollect:setBright(false)
            ItemCollect:setEnabled(false)
            ItemCollect:setTitleText(Lang.ui_bag_equipment13)
        else
            ItemCollect:setBright(true)
            ItemCollect:setEnabled(true)
            ItemCollect:setTitleText(Lang.ui_bag_equipment14)
        end
        local function CollectEvent(sender,eventType)
            if eventType  == ccui.TouchEventType.ended then
               CollectEquipName =DictEquipment[tostring(DictData.equipmentId)].name
               sendCollectData(_obj.int["1"])
            end
        end
        ItemCollect:addTouchEventListener(CollectEvent)
    end
end

local function selectedBtnChange(flag) 
    local btn_equipment = ccui.Helper:seekNodeByName(UIBagEquipment.Widget,"btn_equipment")
    local btn_chip = ccui.Helper:seekNodeByName(UIBagEquipment.Widget,"btn_chip")
    btnSelected:loadTextureNormal("ui/yh_btn01.png")
    btnSelectedText:setTextColor(cc.c4b(255,255,255,255))
    if flag == 1 then 
        btnSelected= btn_equipment
        btnSelectedText= btn_equipment:getChildByName("text_equipment")
        btn_equipment:loadTextureNormal("ui/yh_btn02.png")
        btn_equipment:getChildByName("text_equipment"):setTextColor(cc.c4b(51,25,4,255))
    elseif  flag ==  2 then
        btnSelected= btn_chip
        btnSelectedText= btn_chip:getChildByName("text_chip")
        btn_chip:loadTextureNormal("ui/yh_btn02.png")
        btn_chip:getChildByName("text_chip"):setTextColor(cc.c4b(51,25,4,255))
    end
end


function UIBagEquipment.init()
	local ui_image_base_title = ccui.Helper:seekNodeByName(UIBagEquipment.Widget, "image_base_title")
	btn_equipment = ui_image_base_title:getChildByName("btn_equipment")
	btn_chip = ui_image_base_title:getChildByName("btn_chip")
	btn_expansion = ui_image_base_title:getChildByName("btn_expansion")
	btn_sell = ui_image_base_title:getChildByName("btn_sell")
	btn_expansion:setPressedActionEnabled(true)
	btn_sell:setPressedActionEnabled(true)
	local function btnTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
      AudioEngine.playEffect("sound/button.mp3")
			if sender == btn_equipment then
				 if equipFlag == 1 then 
              return
          end
          equipFlag = 1
          UIBagEquipment.setup()
			elseif sender == btn_chip then
				 if equipFlag == 2 then 
              return
          end
          equipFlag = 2
          UIBagEquipment.setup()
			elseif sender == btn_expansion then
				cclog("------------->> 扩充")
				expandPrice = DictSysConfig[tostring(StaticSysConfig.expandInitGold)].value + expandNum*DictSysConfig[tostring(StaticSysConfig.bagExpandGoldGrow)].value
        local hint =nil
        if equipFlag ==1 then 
            hint = Lang.ui_bag_equipment15 .. expandPrice .. Lang.ui_bag_equipment16
        else
            hint = Lang.ui_bag_equipment17 .. expandPrice .. Lang.ui_bag_equipment18
        end
        utils.PromptDialog(ExpandCallBack,hint)
			elseif sender == btn_sell then
				if equipFlag == 1 then
		    		UIBagEquipmentSell.setOperateType(UIBagEquipmentSell.OperateType.SellEquip)
				else
				    UIBagEquipmentSell.setOperateType(UIBagEquipmentSell.OperateType.SellChip)
				end
				if next(EquipThing) then 
				  UIManager.pushScene("ui_bag_equipment_sell")
			  else
			     if equipFlag == 1 then 
			         UIManager.showToast(Lang.ui_bag_equipment19)
			     else
			         UIManager.showToast(Lang.ui_bag_equipment20)
			     end
			  end
			end
		end
	end
	btn_equipment:addTouchEventListener(btnTouchEvent)
	btn_chip:addTouchEventListener(btnTouchEvent)
	btn_expansion:addTouchEventListener(btnTouchEvent)
	btn_sell:addTouchEventListener(btnTouchEvent)

	scrollView = ccui.Helper:seekNodeByName(UIBagEquipment.Widget, "view_list_equipment")
	equipItem = scrollView:getChildByName("image_base_equipment"):clone()
	chipItem = scrollView:getChildByName("image_base_chip"):clone()
	
	local ui_image_base_tab = ccui.Helper:seekNodeByName(UIBagEquipment.Widget, "image_base_tab")
	ui_maxBagCount = ui_image_base_tab:getChildByName("text_ceiling")
	btnSelected= btn_equipment
  btnSelectedText= btn_equipment:getChildByName("text_equipment")
end

function UIBagEquipment.setup()
  local grid = 0
	if equipItem:getReferenceCount() == 1 then
		equipItem:retain()
	end
	if chipItem:getReferenceCount() == 1 then
		chipItem:retain()
	end
  if equipFlag == 1 then 
      grid = DictBagType[tostring(StaticBag_Type.equip)].bagUpLimit
  elseif equipFlag == 2 then 
      grid = DictBagType[tostring(StaticBag_Type.equipChip)].bagUpLimit
  end
  if net.InstPlayerBagExpand then 
      for key,obj in pairs(net.InstPlayerBagExpand) do
          if obj.int["3"] == StaticBag_Type.equip and equipFlag == 1 then 
              grid = obj.int["4"] + DictBagType[tostring(obj.int["3"])].bagUpLimit
              expandNum = obj.int["6"]
          end
          if obj.int["3"] == StaticBag_Type.equipChip and equipFlag == 2 then
              grid = obj.int["4"] + DictBagType[tostring(obj.int["3"])].bagUpLimit
              expandNum = obj.int["6"]
          end
      end
  end
    
	scrollView:removeAllChildren()
	EquipThing={}
  if equipFlag == 1 and net.InstPlayerEquip then 
     for key, obj in pairs(net.InstPlayerEquip) do
            table.insert(EquipThing,obj)
     end
     utils.quickSort(EquipThing,compareEquip)
  elseif equipFlag == 2 and net.InstPlayerThing then 
     for key, obj in pairs(net.InstPlayerThing) do
          if obj.int["7"] == StaticBag_Type.equipChip then 
            table.insert(EquipThing,obj)
          end
     end
     utils.quickSort(EquipThing,compareEquipChip)
  end
  selectedBtnChange(equipFlag)
  if next(EquipThing) then
        if equipFlag == 1 then 
           utils.updateView(UIBagEquipment,scrollView,equipItem,EquipThing,setScrollViewItem,equipFlag)
        else
           utils.updateView(UIBagEquipment,scrollView,chipItem,EquipThing,setScrollViewItem,equipFlag)
        end
    end
    local text_ceiling =  ccui.Helper:seekNodeByName(UIBagEquipment.Widget, "text_ceiling")
    text_ceiling:setString(string.format(Lang.ui_bag_equipment21,#EquipThing,grid))
    if btn_chip then
        utils.addImageHint(UIBagEquipment.checkImageHint(),btn_chip,100,18,10)
    end
end

function UIBagEquipment.setFlag(flag)
    equipFlag =flag
end

function UIBagEquipment.free( ... )
  scrollView:removeAllChildren()
end

function UIBagEquipment.checkImageHint()
    local equipment = {}
    if net.InstPlayerThing then 
     for key, obj in pairs(net.InstPlayerThing) do
          if obj.int["7"] == StaticBag_Type.equipChip then 
            table.insert(equipment,obj)
          end
     end
  end
  local result = false
  for key, obj in pairs(equipment) do
    local DictData = DictThing[tostring(obj.int["3"])]
    local equipQualityId =  DictEquipment[tostring(DictData.equipmentId)].equipQualityId
    local collectNum = DictEquipQuality[tostring(equipQualityId)].thingNum
    if obj.int["5"] >= collectNum then
        result = true
        break
    end
  end
  return result
end
