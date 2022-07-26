require"Lang"
UIResolve_list={}
local btnSelected=nil
local btnSelectedText=nil
local scrollView=nil
local EquipItem=nil
local CardItem =nil 
local MagicItem = nil
local addFlag =nil  -- 1 为装备 2为卡牌 3为异火 4为功法/法宝
local resolveThing={}
local number =0
local text_choose=nil
local _operateType =nil
local addEquip ={
      flag = false,  -- 判断是否有蓝色以上装备
      info = {}
  }  --  要分解的装备
local addCard={
      flag = false, -- 判断是否有蓝色以上卡牌
      info = {}
}  -- 要分解的卡牌
local addMagic={
    flag = false,
    info = {}
} --要分解的功法/法宝

local selectedItem = nil
local instPlayerCardObj = nil  ---轮回的卡牌实例id
--先比较装备的品质 其次在比较等级
local function compareEquip(value1,value2)
    local value1QualityId = (value1.int["8"] >= 1000) and DictEquipAdvancered[tostring(value1.int["8"])].equipQualityId or DictEquipment[tostring(value1.int["4"])].equipQualityId
    local value2QualityId = (value2.int["8"] >= 1000) and DictEquipAdvancered[tostring(value2.int["8"])].equipQualityId or DictEquipment[tostring(value2.int["4"])].equipQualityId
    if value1QualityId < value2QualityId then 
        return false
    elseif value1QualityId > value2QualityId then 
        return true
    else
        if value1.int["5"] <= value2.int["5"] then 
            return false
        else
            return true
        end
    end
    
end 
--先比较卡牌的品质 其次在比较等级
local function compareCard(value1,value2)
    if value1.int["4"] < value2.int["4"] then 
        return true
    elseif value1.int["4"] > value2.int["4"] then 
        return false
    else
          if  value1.int["9"] <= value2.int["9"] then 
              return true
          else
              return false
          end
    end
end

--先比较宝物的品质，其次再比较等级
local function compareMagic(obj1, obj2)
    if obj1.int["5"] > obj2.int["5"] then
        return true
    elseif obj1.int["5"] < obj2.int["5"] then
        return false
    else
        if DictMagicLevel[tostring(obj1.int["6"])].level <= DictMagicLevel[tostring(obj2.int["6"])].level then
            return true
        else
            return false
        end
    end
end

local function setScrollViewItem(flag,_Item, _obj)
       
        local checkbox = nil 
        local inlayThingId = {}
        if flag == 1 then 
          checkbox = ccui.Helper:seekNodeByName(_Item,"box_sell")
        elseif flag == 2 then 
          checkbox = ccui.Helper:seekNodeByName(_Item,"box_choose")
        elseif flag == 4 then
            checkbox = ccui.Helper:seekNodeByName(_Item,"checkbox_choose")
            checkbox:setSelected(false)
        end 
        
        local function ui_checkBoxEvent(sender,eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            if _operateType == UIResolve.operateType.resolve then
                if flag == 1 then --装备
                    for key, _thingId in pairs(inlayThingId) do
                        if _thingId ~= 0 then
                            sender:setSelected(false)
                            UIManager.showToast(Lang.ui_resolve_list1)
                            return
                        end
                    end
                end
                number = number +1
                text_choose:setString(string.format(Lang.ui_resolve_list2,number))
                if number > 5 then 
                    text_choose:setTextColor(cc.c4b(255,0,0,255))
                end
                if addFlag == 1 then 
                      table.insert(addEquip.info,resolveThing[_Item:getTag()])
                elseif addFlag == nil or addFlag ==2 then 
                      table.insert(addCard.info,resolveThing[_Item:getTag()]) 
                elseif addFlag == 4 then 
                      table.insert(addMagic.info,resolveThing[_Item:getTag()])
                end
            elseif _operateType == UIResolve.operateType.rinne  then
--                if _obj.int["4"] == StaticQuality.red then
--                    sender:setSelected(false)
--                    UIManager.showToast("红卡暂时不能轮回！")
--                    return
--                end
--                if _obj.int["6"] >= 51 then
--                    sender:setSelected(false)
--                    UIManager.showToast("斗皇暂时不能轮回！")
--                    return
--                end

                if selectedItem  ~= nil then
                    selectedItem:setSelected(false)
                end
                selectedItem =sender
                instPlayerCardObj = resolveThing[_Item:getTag()]
            end
            
        elseif eventType == ccui.CheckBoxEventType.unselected then
            if _operateType == UIResolve.operateType.resolve then
                number = number -1
                text_choose:setString(string.format(Lang.ui_resolve_list3,number))
                if number <=5 then 
                    text_choose:setTextColor(cc.c4b(255,255,255,255))
                end 
                if addFlag == 1 then 
                    for key,obj in pairs(addEquip.info) do
                          if resolveThing[_Item:getTag()].int["1"] == obj.int["1"] then 
                              table.remove(addEquip.info,key)
                          end
                    end
                elseif addFlag == nil or addFlag ==2 then 
                     for key,obj in pairs(addCard.info) do
                          if resolveThing[_Item:getTag()].int["1"] == obj.int["1"] then 
                              table.remove(addCard.info,key)
                          end
                    end
                elseif addFlag == 4 then 
                     for key,obj in pairs(addMagic.info) do
                          if resolveThing[_Item:getTag()].int["1"] == obj.int["1"] then 
                              table.remove(addMagic.info,key)
                          end
                    end
                end
            elseif _operateType == UIResolve.operateType.rinne  then
                selectedItem =  nil 
                instPlayerCardObj  = nil
            end
            
        end
    end
    
    checkbox:addEventListener(ui_checkBoxEvent)
    if flag == 1 then --装备
        local ItemProp ={}
        local image_gem = {}
        local ui_imageFrame = ccui.Helper:seekNodeByName(_Item,"image_frame_equipment")
        local ui_image = ui_imageFrame:getChildByName("image_equipment")
        local ui_name = ccui.Helper:seekNodeByName(_Item,"text_name_equipment")
        local ui_level = ccui.Helper:seekNodeByName(_Item,"text_lv")
        local ui_pz = ccui.Helper:seekNodeByName(_Item,"label_pz")
        ItemProp[1] = ccui.Helper:seekNodeByName(_Item,"text_add_attack")
        ItemProp[2] = ccui.Helper:seekNodeByName(_Item,"text_add_defense")
        for i =1 ,4 do
            image_gem[#image_gem+1] = ccui.Helper:seekNodeByName(_Item,"image_frame_gem" .. i )
        end

        local dictEquipData = DictEquipment[tostring(_obj.int["4"])] --装备字典表
        local equipAdvanceId = _obj.int["8"]
        local dictEquipAdvanceData = equipAdvanceId >= 1000 and DictEquipAdvancered[tostring(equipAdvanceId)] or DictEquipAdvance[tostring(equipAdvanceId)] --装备进阶字典表
        local smallUiId = (equipAdvanceId >= 1000) and dictEquipData.RedsmallUiId or dictEquipData.smallUiId
        local smallImage= DictUI[tostring(smallUiId)].fileName
        local qualityId = dictEquipAdvanceData and dictEquipAdvanceData.equipQualityId or dictEquipData.equipQualityId
        local qualityLevel = dictEquipData.qualityLevel
        local borderImage= utils.getQualityImage(dp.Quality.equip, qualityId, dp.QualityImageType.small)
        ui_imageFrame:loadTexture(borderImage)
        ui_image:loadTexture("image/" .. smallImage)
        ui_name:setString(dictEquipData.name)
        utils.changeNameColor(ui_name,qualityId)
        ui_level:setString(string.format(Lang.ui_resolve_list4,_obj.int["5"]))
        ui_pz:setString(string.format(Lang.ui_resolve_list5,qualityLevel))
        for i=1,#addEquip.info do
            if _obj.int["1"] == addEquip.info[i].int["1"] then 
                checkbox:setSelected(true)
                break;
            else 
                checkbox:setSelected(false)
            end
        end
        local equipPropData = {}
        local propData = utils.stringSplit(dictEquipData.propAndAdd, ";")
        for key, obj in pairs(propData) do
          equipPropData[key] = utils.stringSplit(obj, "_") --[1]:fightPropId, [2]:initValue, [3]:addValue
        end
        if #equipPropData == 1 then
          ItemProp[2]:setVisible(false)
        end
        local attribs = utils.getEquipAttribute(_obj.int["1"])
        for key, obj in pairs(equipPropData) do
            local fightPropId, initValue, addValue = tonumber(obj[1]), tonumber(obj[2]), tonumber(obj[3])
            ItemProp[key]:setString(DictFightProp[tostring(fightPropId)].name .. "：" .. attribs[fightPropId])
        end
        if net.InstEquipGem then
          for key, obj in pairs(net.InstEquipGem) do
            if _obj.int["1"] == obj.int["3"] then
              inlayThingId[obj.int["5"]] = obj.int["4"] --物品Id 0表示未镶嵌宝石
            end
          end
        end
        local dictEquipQualityData = DictEquipQuality[tostring(qualityId)] --装备品质字典表
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

          local suitEquipData = utils.getEquipSuit(tostring( _obj.int["4"] ) )
          utils.addFrameParticle( ui_image , suitEquipData )                      

         --ui_starImg:loadTexture("ui/star02.png")
          local ui_starImgs = {}
	        for i = 1, 5 do
		        ui_starImgs[i] = ccui.Helper:seekNodeByName( _Item , "image_star" .. i)
		        ui_starImgs[i]:setVisible(false)
		        if equipAdvanceId ~= 0 and dictEquipAdvanceData.starLevel >= i then
				    ui_starImgs[i]:loadTexture("ui/star01.png")
			    else
				    ui_starImgs[i]:loadTexture("ui/star02.png")
			    end
	        end
            if qualityId == StaticEquip_Quality.white or qualityId == StaticEquip_Quality.green then
		        for i = 1, 5 do
			        ui_starImgs[i]:setVisible(false)
		        end
	        else
		        for i = 1, 5 do
			        ui_starImgs[i]:setVisible(true)
			        if i > 3 and qualityId == StaticEquip_Quality.blue then
				        ui_starImgs[i]:setVisible(false)
			        end
		        end
	        end
       
    elseif flag == 2 then  -- 卡牌
        local ui_imageFrame = ccui.Helper:seekNodeByName(_Item,"image_frame_card")
        local ui_image = ui_imageFrame:getChildByName("image_card")
        local ui_name = ccui.Helper:seekNodeByName(_Item,"text_name_card")
        local ui_starlevel = ccui.Helper:seekNodeByName(_Item,"label_lv")
        local ui_level = ccui.Helper:seekNodeByName(_Item,"text_card_number")
        local ui_title_di = ccui.Helper:seekNodeByName(_Item,"image_base_title")
        local smallUiId=DictCard[tostring(_obj.int["3"])].smallUiId
        local smallImage= DictUI[tostring(smallUiId)].fileName
        local titleId = DictTitleDetail[tostring(_obj.int["6"])].titleId
        local qualityId = _obj.int["4"]
        local borderImage = utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small)
        local startLevelId = _obj.int["5"]
        local qualityName = DictQuality[tostring(qualityId)].name
        local startLevel = DictStarLevel[tostring(startLevelId)].level -- 阶数
        local starValue = DictTitleDetail[tostring(_obj.int["6"])].value -- 星数
        ui_imageFrame:loadTexture(borderImage)
        utils.changeNameColor(ui_name,qualityId)
        ui_image:loadTexture("image/" .. smallImage)
        ui_name:setString(DictCard[tostring(_obj.int["3"])].name)
        if startLevel == 0 then 
          ui_starlevel:getParent():setVisible(false)
        else 
          ui_starlevel:getParent():setVisible(true)
        end
        ui_starlevel:setString(startLevel)
        ui_level:setString(string.format(Lang.ui_resolve_list6,_obj.int["9"]))
        utils.setChengHaoImage(ui_title_di,starValue,titleId)
        if  _operateType == UIResolve.operateType.resolve then 
            for i=1,#addCard.info do
                if _obj.int["1"] == addCard.info[i].int["1"] then 
                    checkbox:setSelected(true)
                    break;
                else 
                   checkbox:setSelected(false)
                end
            end
        end
    elseif flag == 4 then --宝物
        local dictId = _obj.int["3"] --功法或法宝id
        local dicData = DictMagic[tostring(dictId)] --功法字典表
        local dictUiData = DictUI[tostring(dicData.smallUiId)] --资源字典表
        local Level = DictMagicLevel[tostring(_obj.int["6"])].level
        local qualityValue = _obj.int["5"]
        local qualityLevel = dicData.grade
        local value = {
            dicData.value1 ,
            dicData.value2 ,
            dicData.value3 
        }
        local borderImage = utils.getQualityImage(dp.Quality.gongFa, qualityValue, dp.QualityImageType.small)
        local ui_magicName = ccui.Helper:seekNodeByName(_Item, "text_name_equipment_41")
        local ui_magicFrame = ccui.Helper:seekNodeByName(_Item, "image_frame_equipment_38")
        local ui_magicIcon = ui_magicFrame:getChildByName("image_equipment_37")
        local ui_magicType = ccui.Helper:seekNodeByName(_Item, "text_gongfa_lv_43")
        local ui_magicLevel = _Item:getChildByName("text_lv")
        local ui_magicQualityLevel = _Item:getChildByName("image_pz"):getChildByName("label_pz")
        local ui_property = {
            ccui.Helper:seekNodeByName(_Item, "text_laterality_45"),
            ccui.Helper:seekNodeByName(_Item, "text_limit_47"),
            ccui.Helper:seekNodeByName(_Item, "text_gongfa_number_49"),
        }
        ui_magicName:setString(dicData.name)
        utils.changeNameColor(ui_magicName, qualityValue, dp.Quality.gongFa)
        ui_magicFrame:loadTexture(borderImage)
        ui_magicIcon:loadTexture("image/" .. dictUiData.fileName)
        ui_magicType:setString(DictMagicQuality[tostring(qualityValue)].name)
        ui_magicLevel:setString(string.format(Lang.ui_resolve_list7, Level))
        ui_magicQualityLevel:setString(qualityLevel)
        for i = 1, #addMagic.info do
            if _obj.int["1"] == addMagic.info[i].int["1"] then 
                checkbox:setSelected(true)
                break;
            else 
                checkbox:setSelected(false)
            end
        end
        for i = 1, 3 do
            if value[i] ~= "" then
                local dictValue = utils.stringSplit(value[i], "_")
                if tonumber(dictValue[1]) == 3 then
                    ui_property[i]:setString(string.format("%s+%d%s", Lang.ui_resolve_list8, dicData.exp, ""))
                else
                    local dictFightPropId = dictValue[2]
                    local value = dictValue[3] + dictValue[4] *(Level - 1)
                    local name = DictFightProp[tostring(dictFightPropId)].name
                    ui_property[i]:setString(string.format("%s+%d%s", name, value, tonumber(dictValue[1]) == 1 and "%" or ""))
                end
            else
                ui_property[i]:setVisible(false)
            end
        end
    end
end

local function selectedBtnChange(flag)
    local btn_card = ccui.Helper:seekNodeByName(UIResolve_list.Widget,"btn_card")
    local btn_equipment = ccui.Helper:seekNodeByName(UIResolve_list.Widget,"btn_equipment")
    local btn_gongfa = ccui.Helper:seekNodeByName(UIResolve_list.Widget,"btn_gongfa")
    btnSelected:loadTextureNormal("ui/yh_btn01.png")
    btnSelectedText:setTextColor(cc.c4b(255,255,255,255))
    if flag == 1 then 
        btnSelected= btn_equipment
        btnSelectedText= btn_equipment:getChildByName("text_equipment")
        btn_equipment:loadTextureNormal("ui/yh_btn02.png")
        btn_equipment:getChildByName("text_equipment"):setTextColor(cc.c4b(139,69,19,255))
    elseif  flag == nil  or flag ==  2 then
        btnSelected= btn_card
        btnSelectedText= btn_card:getChildByName("text_card")
        btn_card:loadTextureNormal("ui/yh_btn02.png")
        btn_card:getChildByName("text_card"):setTextColor(cc.c4b(139,69,19,255))
    elseif flag == 4 then 
        btnSelected= btn_gongfa
        btnSelectedText= btn_gongfa:getChildByName("text_fire")
        btn_gongfa:loadTextureNormal("ui/yh_btn02.png")
        btn_gongfa:getChildByName("text_fire"):setTextColor(cc.c4b(139,69,19,255))
    end
end


function UIResolve_list.init()
    local btn_close = ccui.Helper:seekNodeByName(UIResolve_list.Widget,"btn_close")
    local btn_OK = ccui.Helper:seekNodeByName(UIResolve_list.Widget,"btn_ensure")
    btn_OK:setPressedActionEnabled(true)
    btn_close:setPressedActionEnabled(true)
    local function closeEvent(sender,eventType)
      if eventType == ccui.TouchEventType.ended then 
          AudioEngine.playEffect("sound/button.mp3")
          if _operateType == UIResolve.operateType.resolve then
              local add_num =nil
              if addFlag == 1 then 
                  if number > 5 then 
                      add_num = #addEquip.info
                      for i=6,add_num do
                          table.remove(addEquip.info,6) -- 移除的过程中 key也相应发生变化 所以一直是6
                      end
                  end
              elseif addFlag == nil or addFlag == 2 then 
                   if addFlag == nil  then 
                      addFlag = 2
                   end
                   if number > 5 then 
                      add_num = #addCard.info
                      for i=6,add_num do
                          table.remove(addCard.info,6)
                      end
                  end
              elseif addFlag == 4 then 
                   if number > 5 then 
                   add_num = #addMagic.info
                      for i=6,add_num do
                          table.remove(addMagic.info,6)
                      end
                  end
              end
              if changeLayerFlag == true then 
                   UIResolve.manualAdd(nil,nil)
              end
          end
          UIManager:popScene()
          number =0 
          resolveThing ={}
       end
    end
    local function okEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then 
           if number > 5 then 
              text_choose:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,1.2),cc.ScaleTo:create(0.2,1)))
              return
           end
           number =0
           UIManager.popScene()
           if _operateType == UIResolve.operateType.resolve then 
                 if addFlag ==  1 then
                     
                     if next(addEquip.info) then
                       for key,value in pairs(addEquip.info) do
                          cclog("resolve:addEquip.info[" .. key.. "]=" .. addEquip.info[key].int["4"] )
                       end 
                       UIResolve.manualAdd(addFlag,addEquip.info) 
                     else
                        UIResolve.manualAdd(nil,nil)
                     end
                 elseif addFlag == nil or addFlag == 2 then 
                     if addFlag == nil  then 
                        addFlag = 2
                     end
                     if next(addCard.info) then
                        for key,value in pairs(addCard.info) do
                          cclog("resolve:addCard.info[" .. key.. "]=" .. addCard.info[key].int["3"] )
                        end 
                        UIResolve.manualAdd(addFlag,addCard.info) 
                     else
                        UIResolve.manualAdd(nil,nil)
                     end
                 elseif addFlag == 4 then 
                     if next(addMagic.info) then 
                       UIResolve.manualAdd(addFlag,addMagic.info)
                       for key,value in pairs(addMagic.info) do
                          cclog("resolve:addMagic.info[" .. key.. "]=" .. addMagic.info[key].int["3"] )
                       end
                     else
                        UIResolve.manualAdd(nil,nil)
                     end
                 end
           elseif _operateType == UIResolve.operateType.rinne then
                if addFlag == 1 then
                    UIResolve.setRinneData(instPlayerCardObj, UIResolve.RinnePreviewFlag.equip)
                else
                    UIResolve.setRinneData(instPlayerCardObj, UIResolve.RinnePreviewFlag.card)
                end
           end
       end
    end
    btn_OK:addTouchEventListener(okEvent)
    btn_close:addTouchEventListener(closeEvent)
    local btn_card = ccui.Helper:seekNodeByName(UIResolve_list.Widget,"btn_card")
    local btn_equipment = ccui.Helper:seekNodeByName(UIResolve_list.Widget,"btn_equipment")
    local btn_gongfa = ccui.Helper:seekNodeByName(UIResolve_list.Widget,"btn_gongfa")
    btn_card:setPressedActionEnabled(true)
    btn_equipment:setPressedActionEnabled(true)
    btn_gongfa:setPressedActionEnabled(true)
    btnSelected = btn_card
    btnSelectedText= btn_card:getChildByName("text_card")
    local function btnListEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then 
            if sender == btn_card then
--                if _operateType == UIResolve.operateType.resolve then
                    if addFlag == 2 then 
                       return;
                    end
                    addFlag = 2;
                    changeLayerFlag = true
                    addMagic.info ={}  
                    addCard.info = {}
                    addEquip.info ={}
                    number = 0
                    UIResolve_list.setup()
--                end
            elseif sender == btn_equipment then 
                if addFlag == 1 then 
                    return;
                end
                addFlag = 1;
                changeLayerFlag = true 
                addMagic.info ={}  
                addCard.info = {}
                addEquip.info ={}
                 number = 0
                 UIResolve_list.setup()
            elseif sender == btn_gongfa then
                if addFlag == 4 then 
                    return;
                end  
                changeLayerFlag = true
                addFlag = 4;   
                addMagic.info ={}  
                addCard.info = {}
                addEquip.info ={}
                 number = 0
                UIResolve_list.setup()
            end
        end
    end
    btn_card:addTouchEventListener(btnListEvent)
    btn_equipment:addTouchEventListener(btnListEvent)
    btn_gongfa:addTouchEventListener(btnListEvent)
    scrollView = ccui.Helper:seekNodeByName(UIResolve_list.Widget, "view_list")
    EquipItem = scrollView:getChildByName("image_base_equipment"):clone()
    CardItem = scrollView:getChildByName("image_base_card"):clone()
    MagicItem = scrollView:getChildByName("image_base_gongfa"):clone()
    text_choose = ccui.Helper:seekNodeByName(UIResolve_list.Widget, "text_choose")
    if EquipItem:getReferenceCount() == 1 then
          EquipItem:retain()
     end
     if CardItem:getReferenceCount() == 1 then
          CardItem:retain()
     end
     if MagicItem:getReferenceCount() == 1 then
          MagicItem:retain()
     end
end
function UIResolve_list.setup()
   local image_hint = UIResolve_list.Widget:getChildByName("image_basemap"):getChildByName("image_hint")
   image_hint:setVisible(false)
--   if _operateType == UIResolve.operateType.rinne then
--    image_hint:setVisible(true)
--   end
   scrollView:removeAllChildren()
    resolveThing={} 
    if _operateType == UIResolve.operateType.resolve then
        if addFlag == 1 and net.InstPlayerEquip ~= nil then
           for key, obj in pairs(net.InstPlayerEquip) do
              if obj.int["6"] == 0 then 
                  table.insert(resolveThing,obj)
              end
           end
           number = #addEquip.info
           utils.quickSort(resolveThing,compareEquip)
       elseif (addFlag == nil or addFlag == 2) and net.InstPlayerCard ~= nil  then 
           for key, obj in pairs(net.InstPlayerCard) do
              if obj.int["10"] == 0 and obj.int["15"] == 0 and obj.int["4"] >= StaticQuality.green and obj.int["4"] ~= StaticQuality.red then 
                table.insert(resolveThing,obj)
              end
           end
           utils.quickSort(resolveThing,compareCard)
           number = #addCard.info
       elseif addFlag == 4 and net.InstPlayerMagic ~= nil then 
           for key, obj in pairs(net.InstPlayerMagic) do
              if obj.int["8"] == 0 and obj.int["5"] <= StaticMagicQuality.DJ and DictMagic[tostring(obj.int["3"])].value1 ~= "3" then 
                  table.insert(resolveThing,obj)
              end
           end
           utils.quickSort(resolveThing,compareMagic)
           number = #addMagic.info
       end
       ccui.Helper:seekNodeByName(UIResolve_list.Widget,"btn_equipment"):setVisible(true)
       ccui.Helper:seekNodeByName(UIResolve_list.Widget,"btn_gongfa"):setVisible(true)
       text_choose:setVisible(true)
    elseif _operateType == UIResolve.operateType.rinne then
        if addFlag == 1 and net.InstPlayerEquip ~= nil then
            for key, obj in pairs(net.InstPlayerEquip) do
                local _equipQualityId = DictEquipment[tostring(obj.int["4"])].equipQualityId
                if obj.int["6"] == 0 and _equipQualityId >= StaticEquip_Quality.blue and (obj.int["5"] > 0 or obj.int["8"] > 0) then 
                    table.insert(resolveThing,obj)
                end
            end
            number = #addEquip.info
            utils.quickSort(resolveThing,compareEquip)
        else
             if net.InstPlayerCard  then 
               for key, obj in pairs(net.InstPlayerCard) do
                  if obj.int["10"] == 0 and obj.int["9"] >1 and obj.int["15"] == 0 and obj.int["18"] ~= 1 and obj.int["4"] > StaticQuality.green then ---未上阵 大于1级 不上锁的
                     table.insert(resolveThing,obj)
                  end
               end
               utils.quickSort(resolveThing,compareCard)
             end
             addFlag = 2
        end
         ccui.Helper:seekNodeByName(UIResolve_list.Widget,"btn_equipment"):setVisible(true)
         ccui.Helper:seekNodeByName(UIResolve_list.Widget,"btn_gongfa"):setVisible(false)
         text_choose:setVisible(false)
         selectedItem =  nil 
         instPlayerCardObj  = nil
    end
   
   selectedBtnChange(addFlag)
   if resolveThing then
      if addFlag == 1 then 
        utils.updateView(UIResolve_list,scrollView,EquipItem,resolveThing,setScrollViewItem,addFlag)
      elseif addFlag == 2 or addFlag == nil then 
        utils.updateView(UIResolve_list,scrollView,CardItem,resolveThing,setScrollViewItem,addFlag)
      elseif  addFlag == 4 then 
        utils.updateView(UIResolve_list,scrollView,MagicItem,resolveThing,setScrollViewItem,addFlag)
      end
   end
   text_choose:setString(string.format(Lang.ui_resolve_list9,number))
   text_choose:setTextColor(cc.c4b(255,255,255,255))
end
------一键添加后传过来参数-------------------------------------
function UIResolve_list.resolve(flag,addThing)
    addEquip.info ={}
    addMagic.info = {}
    addCard.info = {}
    addFlag= flag
    if next(addThing) == nil  then 
        addFlag = nil
    end
    changeLayerFlag =false
     if addFlag == 1 then 
        addEquip.info = addThing
     elseif addFlag == 2 then 
        addCard.info = addThing
     elseif addFlag ==  4 then 
        addMagic.info =  addThing
     end
end

function UIResolve_list.setOperateType(operateType)
    _operateType = operateType
end

function UIResolve_list.free()
  if EquipItem and EquipItem:getReferenceCount() >= 1 then
        EquipItem:release()
        EquipItem = nil
   end
   if CardItem and CardItem:getReferenceCount() >= 1 then
        CardItem:release()
        CardItem = nil
   end
   if MagicItem and MagicItem:getReferenceCount() >= 1 then
        MagicItem:release()
        MagicItem = nil
   end
   scrollView:removeAllChildren()
end
