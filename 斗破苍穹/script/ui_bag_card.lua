require"Lang"
UIBagCard={}
local scrollView = nil
local cardItem = nil
local btn_card = nil --卡牌按钮
local btn_psyche = nil --卡牌魂魄按钮
local cardFlag = nil
local expandNum = nil --背包扩展的总数
local CompountCardName = nil
local function netCallbackFunc(pack)
  if tonumber(pack.header) == StaticMsgRule.bagExpand then
    UIManager.showToast(Lang.ui_bag_card1)
    UIManager.flushWidget(UIBagCard)
    UITeamInfo.setup()
  elseif tonumber(pack.header) == StaticMsgRule.cardSoulCall then
    UIGuidePeople.isGuide(ccui.Helper:seekNodeByName(UIMenu.Widget, "btn_troops"),UIBagCard)
    UIManager.showToast(Lang.ui_bag_card2..CompountCardName)
    UIManager.flushWidget(UIBagCard)
  end
end

---合成请求
local function sendCompountData(_instPlayerCardSoulId)
    local sendData = nil
    if UIGuidePeople.levelStep == "7_2" then
        sendData = {
            header = StaticMsgRule.cardSoulCall,
            msgdata = {
                int = {
                    instPlayerCardSoulId  = _instPlayerCardSoulId,
                    },
                string = {
                    step = "7_3"
                }
            }
        }
    else
        sendData = {
            header = StaticMsgRule.cardSoulCall,
            msgdata = {
                int = {
                    instPlayerCardSoulId  = _instPlayerCardSoulId,
                    }
            }
        }
    end
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end
--先比较卡牌的品质 其次在比较等级
local function compareCard(value1,value2)
    if value1.int["10"] == 1 and  value2.int["10"] == 0 then 
        return  false
    end 
    if value1.int["10"] == 0 and  value2.int["10"] == 1 then 
        return  true
    end 
    if value1.int["4"] > value2.int["4"] then 
        return false
    elseif value1.int["4"] < value2.int["4"] then 
        return true
    else
          if  value1.int["9"] >= value2.int["9"] then 
              return false
          else
              return true
          end
    end
end
local function compareCardSoul(value1,value2)
    local cardId1 = value1.int["3"]
    local cardId2 = value2.int["3"]
    local qualityId1 = DictCard[tostring(cardId1)].qualityId
    local qualityId2 = DictCard[tostring(cardId2)].qualityId
    local soulNum1 = DictQuality[tostring(qualityId1)].soulNum
    local soulNum2 = DictQuality[tostring(qualityId2)].soulNum
    if value1.int["5"] < soulNum1 and value2.int["5"] >= soulNum2 then
        return true
    elseif value1.int["5"] >= soulNum1 and value2.int["5"] >= soulNum2 then
        if qualityId1 < qualityId2 then
            return true
        elseif value1.int["5"] < value2.int["5"] then
            return true
        end
    elseif qualityId1 == qualityId2 then
        return value1.int["5"] < value2.int["5"]
    elseif qualityId1 ~= qualityId2 and value1.int["5"] < soulNum1 and value2.int["5"] < soulNum2 then
        return qualityId1 < qualityId2
    end
end
function UIBagCard.ExpandCallBack()
    utils.sendExpandData(StaticBag_Type.card,netCallbackFunc)
end

local function setScrollViewItem(flag,_Item, _obj)
    local image_inlay = ccui.Helper:seekNodeByName(_Item, "image_yishangzhen")
    local btn_upgrade = ccui.Helper:seekNodeByName(_Item, "btn_upgrade")
    local btn_advance = ccui.Helper:seekNodeByName(_Item, "btn_advance")
    local btn_soul = ccui.Helper:seekNodeByName( _Item , "btn_soul" )
    local ui_starlevel = ccui.Helper:seekNodeByName(_Item, "label_lv")
    local ui_text_name_card = ccui.Helper:seekNodeByName(_Item, "text_name_card")
    local ui_image_base_title = ccui.Helper:seekNodeByName(_Item, "image_base_title")
    local ui_image_frame_card = ccui.Helper:seekNodeByName(_Item, "image_frame_card")
    local ui_image_card = ccui.Helper:seekNodeByName(_Item, "image_card")
    local ui_text_card_number =  ccui.Helper:seekNodeByName(_Item, "text_number")
    local ui_level = ccui.Helper:seekNodeByName(_Item,"text_card_number")
    local ui_image_suo = _Item:getChildByName("image_suo")
    local ui_pz = ccui.Helper:seekNodeByName(_Item,"label_zz")
    local _isAwake = _obj.int["18"] --是否已觉醒 0-未觉醒 1-觉醒
    local function btnTouchEvent(sender, eventType)
       if eventType == ccui.TouchEventType.ended then
            if sender == btn_upgrade then 
                if flag == 1 then 
                  UICardUpgrade.setInstPlayerCardId(UIBagCard, _obj.int["1"]) --卡牌升级
                  UIManager.pushScene("ui_card_upgrade")
                elseif flag == 2 then  
                  local instPlayerCardSoulId = _obj.int["1"]
                  CompountCardName = DictCard[tostring(_obj.int["3"])].name
                  sendCompountData(instPlayerCardSoulId)
                end
            elseif sender == btn_advance then 
                UICardAdvance.setInstPlayerCardId(UIBagCard, _obj.int["1"]) --卡牌进阶
                UIManager.pushScene("ui_card_advance")
            elseif sender == ui_image_frame_card then 
                if flag == 1 then
                   UICardInfo.setUIParam(UIBagCard, _obj.int["1"]) --卡牌信息
                   UIManager.pushScene("ui_card_info")
                elseif flag == 2 then 
                   UICardInfo.setDictCardId(_obj.int["3"])
                   UIManager.pushScene("ui_card_info")
                end
            elseif sender == btn_soul then
                UISoulInstall.setType( UISoulInstall.type.ONE , 0 , _obj.int[ "1" ] )
                UIManager.pushScene( "ui_soul_install" )
            end
       end
    end
    if flag == 1 then 
      ui_text_card_number:setVisible(false)
      local inlay_flag = _obj.int["10"]
      if inlay_flag == 1 then 
          image_inlay:setVisible(true)
      else
          image_inlay:setVisible(false)
      end
      local dictData = DictCard[tostring(_obj.int["3"])]
      local smallUiId= _isAwake == 1 and dictData.awakeSmallUiId or dictData.smallUiId
      local smallImage= DictUI[tostring(smallUiId)].fileName
      local titleId= DictTitleDetail[tostring(_obj.int["6"])].titleId
      local qualityId = _obj.int["4"]
      local startLevelId = _obj.int["5"]
      local starValue = DictTitleDetail[tostring(_obj.int["6"])].value -- 星数
      local startLevel = DictStarLevel[tostring(startLevelId)].level
      local borderImage = utils.getQualityImage(dp.Quality.card, qualityId, dp.QualityImageType.small)
      ui_image_card:loadTexture("image/" .. smallImage)
      ui_text_name_card:setString((_isAwake == 1 and Lang.ui_bag_card3 or "") .. dictData.name)
      if startLevel == 0 then 
        ui_starlevel:getParent():setVisible(false)
      else 
        ui_starlevel:getParent():setVisible(true)
      end
      ui_starlevel:setString(startLevel)  -- 几星
      ui_image_frame_card:loadTexture(borderImage)
      ui_level:setString(string.format(Lang.ui_bag_card4,_obj.int["9"]))
      ui_pz:setString(dictData.nickname)
      utils.changeNameColor(ui_text_name_card,qualityId)
      utils.setChengHaoImage(ui_image_base_title,starValue,titleId)
      if qualityId == 1 then
          btn_advance:setVisible(false)
      else
          btn_advance:setVisible(true)
      end
      btn_soul:setVisible( true )
      if _obj.int["15"] == 0 then 
        ui_image_suo:setVisible(false)
      else 
        ui_image_suo:setVisible(true)
      end
    elseif flag == 2 then
      if UIGuidePeople.levelStep then ---引导特殊处理萧玉
        if _obj.int["4"] == 38 then 
          UIGuidePeople.isGuide(btn_upgrade,UIBagCard,guideInfo["7_1"].step)
        end
      end
      ui_image_suo:setVisible(false)
      ui_image_base_title:setVisible(false)
      image_inlay:setVisible(false)
      btn_advance:setVisible(false)
      btn_soul:setVisible( false )
      ui_text_card_number:setVisible(true)
      local dictData = DictCard[tostring(_obj.int["3"])]
      local qualityId = dictData.qualityId
      utils.addBorderImage(StaticTableType.DictCardSoul,_obj.int["4"],ui_image_frame_card)
      local smallUiId= _isAwake == 1 and dictData.awakeSmallUiId or dictData.smallUiId
      local smallImage= DictUI[tostring(smallUiId)].fileName
      local soulNum = DictQuality[tostring(qualityId)].soulNum
      local starLevelId = dictData.starLevelId
      local startLevel = DictStarLevel[tostring(starLevelId)].level
      if startLevel == 0 then 
        ui_starlevel:getParent():setVisible(false)
      else 
        ui_starlevel:getParent():setVisible(true)
      end
      ui_starlevel:setString(startLevel)  -- 几星
      ui_image_card:loadTexture("image/" .. smallImage)
      ui_text_name_card:setString(DictCardSoul[tostring(_obj.int["4"])].name)
      ui_text_card_number:setString(Lang.ui_bag_card5 .. _obj.int["5"])
      ui_level:setString(Lang.ui_bag_card6 .. soulNum .. Lang.ui_bag_card7)
      ui_pz:setString(dictData.nickname)
      utils.changeNameColor(ui_text_name_card,qualityId)
      if soulNum > _obj.int["5"] then
          btn_upgrade:setBright(false)
          btn_upgrade:setEnabled(false)
          btn_upgrade:setTitleText(Lang.ui_bag_card8)
      else
          btn_upgrade:setBright(true)
          btn_upgrade:setEnabled(true)
          btn_upgrade:setTitleText(Lang.ui_bag_card9)
      end
    end
    btn_upgrade:addTouchEventListener(btnTouchEvent)
    btn_advance:addTouchEventListener(btnTouchEvent)
    btn_upgrade:setPressedActionEnabled(true)
    btn_advance:setPressedActionEnabled(true)
    ui_image_frame_card:addTouchEventListener(btnTouchEvent)
    btn_soul:setPressedActionEnabled( true )
    btn_soul:addTouchEventListener( btnTouchEvent )
end

local function selectedBtnChange(flag) 
    if flag == 1 then 
        btn_psyche:loadTextureNormal("ui/yh_btn01.png")
        btn_psyche:getChildByName("text_psyche"):setTextColor(cc.c3b(255,255,255))
        btn_card:loadTextureNormal("ui/yh_btn02.png")
        btn_card:getChildByName("text_card"):setTextColor(cc.c3b(51,25,4))
    elseif  flag ==  2 then
        btn_card:loadTextureNormal("ui/yh_btn01.png")
        btn_card:getChildByName("text_card"):setTextColor(cc.c3b(255,255,255))
        btn_psyche:loadTextureNormal("ui/yh_btn02.png")
        btn_psyche:getChildByName("text_psyche"):setTextColor(cc.c3b(51,25,4))
    end
end

function UIBagCard.init()
    btn_card = ccui.Helper:seekNodeByName(UIBagCard.Widget, "btn_card")
    btn_psyche = ccui.Helper:seekNodeByName(UIBagCard.Widget, "btn_psyche")
    local btn_expansion = ccui.Helper:seekNodeByName(UIBagCard.Widget, "btn_expansion")
    local btn_sell = ccui.Helper:seekNodeByName(UIBagCard.Widget, "btn_sell")
    local function btnTouchEvent(sender, eventType)
       if eventType == ccui.TouchEventType.ended then
          AudioEngine.playEffect("sound/button.mp3")
          if sender == btn_card then
             if cardFlag == 1 then 
                  return
              end
              cardFlag = 1
              UIBagCard.setup()
          elseif sender == btn_psyche then
             if cardFlag == 2 then 
                  return
              end
              cardFlag = 2
              UIBagCard.setup()
          elseif sender == btn_expansion then
            if expandNum == nil then 
              expandNum = 0
            end
            local expandPrice = DictSysConfig[tostring(StaticSysConfig.expandInitGold)].value + expandNum*DictSysConfig[tostring(StaticSysConfig.bagExpandGoldGrow)].value
            local hint =nil
            if cardFlag ==1 then 
                hint = Lang.ui_bag_card10 .. expandPrice .. Lang.ui_bag_card11
            end
            utils.PromptDialog(UIBagCard.ExpandCallBack,hint)
          elseif sender == btn_sell then
                UIBagCardSell.setOperateType(UIBagCardSell.OperateType.CardSell)
                UIManager.pushScene("ui_bag_card_sell")
          end
       end
     end
      btn_card:addTouchEventListener(btnTouchEvent)
      btn_psyche:addTouchEventListener(btnTouchEvent)
      btn_expansion:addTouchEventListener(btnTouchEvent)
      btn_sell:addTouchEventListener(btnTouchEvent)
      btn_card:setPressedActionEnabled(true)
      btn_psyche:setPressedActionEnabled(true)
      btn_expansion:setPressedActionEnabled(true)
      btn_sell:setPressedActionEnabled(true)
      
      scrollView = ccui.Helper:seekNodeByName(UIBagCard.Widget, "view_list_card")
      cardItem = scrollView:getChildByName("image_base_card"):clone()
  
end
function UIBagCard.setup()
    if cardFlag == nil then 
      cardFlag = 1
    end
    local grid = 0
    if cardItem:getReferenceCount() == 1 then
      cardItem:retain()
    end
    
    scrollView:removeAllChildren()
    local cardThing={}
    if cardFlag == 1 then 
        ccui.Helper:seekNodeByName(UIBagCard.Widget, "btn_expansion"):setVisible(true)
        ccui.Helper:seekNodeByName(UIBagCard.Widget, "btn_sell"):setVisible(true)
       if net.InstPlayerBagExpand then 
            for key,obj in pairs(net.InstPlayerBagExpand) do
                if obj.int["3"] == StaticBag_Type.card and cardFlag == 1 then 
                    grid = obj.int["4"] + DictBagType[tostring(obj.int["3"])].bagUpLimit
                    expandNum = obj.int["6"]
                end
            end
        end
        if grid == 0 then 
            grid =DictBagType[tostring(StaticBag_Type.card)].bagUpLimit
        end
       for key, obj in pairs(net.InstPlayerCard) do
              table.insert(cardThing,obj)
       end
       utils.quickSort(cardThing,compareCard)
    elseif cardFlag == 2 then 
      ccui.Helper:seekNodeByName(UIBagCard.Widget, "btn_expansion"):setVisible(false)
      ccui.Helper:seekNodeByName(UIBagCard.Widget, "btn_sell"):setVisible(false)
      if net.InstPlayerCardSoul then
           for key, obj in pairs(net.InstPlayerCardSoul) do
                  table.insert(cardThing,obj)
           end
           utils.quickSort(cardThing,compareCardSoul)
       end
    end
    selectedBtnChange(cardFlag)
    if next(cardThing) then
        utils.updateView(UIBagCard,scrollView,cardItem,cardThing,setScrollViewItem,cardFlag)
    end
    local text_ceiling =  ccui.Helper:seekNodeByName(UIBagCard.Widget, "text_ceiling")
    text_ceiling:setString(string.format(Lang.ui_bag_card12,#cardThing,grid))
    if cardFlag == 1 then 
        text_ceiling:setVisible(true)
    else
        text_ceiling:setVisible(false)
    end
    utils.addImageHint(UIBagCard.checkImageHint(),btn_psyche,100,18,10)
end
function UIBagCard.setFlag(flag)
    cardFlag =flag
end

function UIBagCard.free()
    scrollView:removeAllChildren()
    expandNum =nil
    CompountCardName = nil
    cardFlag = nil
end

function UIBagCard.checkImageHint()
    local cardThing={}
    if net.InstPlayerCardSoul then
        for key, obj in pairs(net.InstPlayerCardSoul) do
            table.insert(cardThing,obj)
        end
    end
    local result = false
    for key, obj in pairs(cardThing) do
        local dictData = DictCard[tostring(obj.int["3"])]
        local qualityId = dictData.qualityId
        local soulNum = DictQuality[tostring(qualityId)].soulNum
        if soulNum <= obj.int["5"] then
            result = true
            break
        end
    end
    return result
end
