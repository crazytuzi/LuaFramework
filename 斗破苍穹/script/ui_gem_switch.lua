require"Lang"
UIGemSwitch={}
local number = 0
local obj= nil 
local uiItem =nil 
local changeCoreTable={}
local changedPropId = nil
local chooseImage =nil
local chooseImageFrame = nil 
local prompt= nil
local LongPush =false
local function netCallbackFunc(pack)
    UIManager.showToast(Lang.ui_gem_switch1)
    number = 0
    chooseImage:setVisible(false)
    chooseImageFrame =nil
    chooseImage = nil
    changedPropId = nil 
    UIManager.flushWidget(UIBag)
    UIManager.flushWidget(UITeamInfo)
    UIManager.flushWidget(UIGemSwitch)
end
---_instPlayerThingId 物品实例Id
---_fightPropId转换成哪一种类型的魔核
--num 转换的数量
local function sendSwitchData(_instPlayerThingId,_fightPropId ,num)
    local  sendData = {
      header = StaticMsgRule.coreConvert,
      msgdata = {
        int = {
          instPlayerThingId   = _instPlayerThingId,
          fightPropId  = _fightPropId,
          convNum = num
        }
      }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end
local function show(Enable,image,_description)
    if Enable then
            local visibleSize = cc.Director:getInstance():getVisibleSize()
            local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
            bg_image:setAnchorPoint(cc.p(0.5, 0.5))
            bg_image:setPreferredSize(cc.size(480, 100)) 
            bg_image:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2 - 30))
            
            local node = cc.Node:create()
            local image_di = ccui.ImageView:create("ui/quality_small_purple.png")
            local image = ccui.ImageView:create(image)
            local description = ccui.Text:create()
            description:setFontName(dp.FONT)
            description:setFontSize(20)
            description:setAnchorPoint(cc.p(0,0.5))
            description:setString(_description)
            description:setPosition(cc.p(image_di:getContentSize().width/4+10,0))
            image:setPosition(cc.p(image_di:getContentSize().width/2,image_di:getContentSize().height/2))
            image_di:addChild(image)
            image_di:setPosition(cc.p(0,0))
            image_di:setScale(0.5)
            node:addChild(image_di)
            node:addChild(description)
            node:setPosition(cc.p(image_di:getContentSize().width/2,bg_image:getPreferredSize().height/2))
            bg_image:addChild(node,3)
           
            UIGemSwitch.Widget:addChild(bg_image,100,100)
    else
        UIGemSwitch.Widget:removeChildByTag(100)
    end
end
local function expalain()
    local childs = UIManager.uiLayer:getChildren()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(480, 300)) 
    bg_image:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2 - 30))
    bg_image:retain()
    local bgSize = bg_image:getPreferredSize()
    local title = ccui.Text:create()
    title:setString(Lang.ui_gem_switch2)
    title:setFontSize(35)
    title:setAnchorPoint(cc.p(0, 0.5))
    title:setFontName(dp.FONT)
    title:setTextColor(cc.c4b(255, 255, 0, 255))
    title:setPosition(cc.p(30, bgSize.height -50))
    bg_image:addChild(title)
    local but_ok = ccui.Button:create("ui/tk_btn01.png")
    local description = ccui.Text:create()
    description:setFontSize(20)
    description:setFontName(dp.FONT)
    description:setAnchorPoint(cc.p(0.5,0.5))
    description:setTextAreaSize(cc.size(430,300))
    description:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    description:setString(Lang.ui_gem_switch3)
    description:setPosition(cc.p(bg_image:getPreferredSize().width /2,bg_image:getPreferredSize().height/2+10))
    but_ok:setPosition(cc.p(bg_image:getPreferredSize().width /2,but_ok:getContentSize().height/2+20))
    bg_image:addChild(but_ok,3)
    bg_image:addChild(description,3)
    local function btnTouchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            UIGemSwitch.Widget:removeChildByTag(100)
            cc.release(bg_image)
            for key,obj in pairs(childs) do 
              obj:setEnabled(true)
            end
        end
    end
    but_ok:setTitleColor(cc.c3b(255,255,255))
    but_ok:setTitleFontSize(25)
    but_ok:setTitleText(Lang.ui_gem_switch4)
    but_ok:setTitleFontName(dp.FONT)
    but_ok:addTouchEventListener(btnTouchEvent)
    UIGemSwitch.Widget:addChild(bg_image,100,100)
    for key,obj in pairs(childs) do 
      obj:setEnabled(false)
    end
end



function UIGemSwitch.init()
    local ui_title = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"text_title")
    ui_title:setString(Lang.ui_gem_switch5)
    local ui_number_text = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"text_number")
    local btn_add = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"btn_add")
    local btn_add_ten = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"btn_add_ten")
    local btn_cut = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"btn_cut")
    local btn_cut_ten = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"btn_cut_ten")
    local ui_btn_inlay = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"btn_gem_inlay")
    local ui_btn_lineup = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"btn_gem_lineup")
    local ui_btn_switch = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"btn_gem_switch")
    local btn_close = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"btn_close")
    local btn_switch = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"btn_switch")
    btn_close:setPressedActionEnabled(true)
    btn_switch:setPressedActionEnabled(true)
    local ui_text_cost_number = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"text_cost_number")
    local image_base_explain = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"image_base_explain")

    local function btnEvent(sender,eventType)
      if eventType == ccui.TouchEventType.ended then
          AudioEngine.playEffect("sound/button.mp3")
          local cost_money = 0
          if sender == image_base_explain then 
              expalain()
          elseif sender ==ui_btn_inlay then 
               UIManager.replaceScene("ui_gem_inlay")
          elseif sender == ui_btn_lineup then 
              UIGemUpGrade.setData(obj,uiItem)
              UIManager.replaceScene("ui_gem_upgrade")
          elseif sender == btn_close then 
              UIManager.popScene()
          elseif sender == btn_switch then 
              if not obj then 
                UIManager.showToast(Lang.ui_gem_switch6) 
                return
              end
              if chooseImage == nil then 
                    UIManager.showToast(Lang.ui_gem_switch7) 
                    return;
              end
              if number == 0 then 
                    UIManager.showToast(Lang.ui_gem_switch8) 
                    return;
              end
               if cost_money <= net.InstPlayer.int["5"] then 
                  sendSwitchData(obj.int["1"],changedPropId,number)
                  if obj.int["5"] == number then 
                      obj.int["5"]=0   ----如果消耗的个数与现有数量相等要讲此置为0 否则出现bug
                  end
               else
                  UIManager.showToast(Lang.ui_gem_switch9)
               end
          elseif sender == btn_add or sender == btn_add_ten or sender == btn_cut or sender == btn_cut_ten and obj then 
                if sender == btn_add then 
                    if  number < obj.int["5"]then
                        number = number + 1
                    else
                        UIManager.showToast(Lang.ui_gem_switch10)
                    end
                elseif sender == btn_add_ten then 
                    if  number <= obj.int["5"] - 10 then
                        number = number + 10
                    elseif number < obj.int["5"] then
                        number = obj.int["5"]
                    else
                        UIManager.showToast(Lang.ui_gem_switch11)
                    end
                elseif sender == btn_cut then
                    if number > 0 then  
                      number = number - 1
                    end
                elseif sender == btn_cut_ten then 
                    if number >10 then 
                      number = number - 10
                    elseif number > 0 then
                        number = 0 
                    end
                end
                ui_number_text:setString(number)
                cost_money = number*DictThing[tostring(obj.int["3"])].coreConvCopper
                ui_text_cost_number:setString(cost_money)
          end
      end
    end
  
    image_base_explain:setTouchEnabled(true)
    image_base_explain:addTouchEventListener(btnEvent)
    btn_switch:addTouchEventListener(btnEvent)
    btn_close:addTouchEventListener(btnEvent)
    ui_btn_inlay:addTouchEventListener(btnEvent)
    ui_btn_lineup:addTouchEventListener(btnEvent)
  
    btn_add:addTouchEventListener(btnEvent)
    btn_add_ten:addTouchEventListener(btnEvent)
    btn_cut:addTouchEventListener(btnEvent)
    btn_cut_ten:addTouchEventListener(btnEvent)
end
----添加魔核方法
local function  addGemFunc(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
        UIGemList.setData(3,uiItem)
        UIManager.pushScene("ui_gem_list")
    end
end
function UIGemSwitch.setup()
    local ui_number_text = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"text_number")
    local ui_btn_inlay = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"btn_gem_inlay")
    local ui_btn_lineup = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"btn_gem_lineup")
    local ui_btn_switch = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"btn_gem_switch")
    local image_frame_gem = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"image_frame_gem")
    local image_gem = image_frame_gem:getChildByName("image_gem")
    local text_name_gem = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"text_name_gem")
    local image_cost_silver = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"image_cost_silver")
    local ui_text_cost_number = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"text_cost_number")
    image_frame_gem:addTouchEventListener(addGemFunc)  --添加魔核
    prompt = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"text_hint")
    if uiItem == UIBag then 
        ui_btn_inlay:setVisible(false)
        ui_btn_switch:setPosition(cc.p(245,-26))
        ui_btn_lineup:setPosition(cc.p(95,-26))
    else
        ui_btn_inlay:setVisible(true)
        ui_btn_switch:setPosition(cc.p(395,-26))
        ui_btn_lineup:setPosition(cc.p(245,-26))
    end
    local cost_money = 0 
    local function showInfo()
        if obj then
            image_cost_silver:setVisible(true)
            for i = 1, 8 do
                 local  image_frame_gem = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"image_frame_gem" .. i)
                 if i > 4 then
                    image_frame_gem:setVisible(false)
                 else
                    image_frame_gem:setVisible(true)
                 end
            end
            cost_money = number*DictThing[tostring(obj.int["3"])].coreConvCopper
        else
            number = 0
            image_cost_silver:setVisible(false)
            image_gem:loadTexture("ui/frame_tianjia.png")
            text_name_gem:setString(Lang.ui_gem_switch12)
            for i = 1, 8 do
                 local  image_frame_gem = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"image_frame_gem" .. i)
                 image_frame_gem:setVisible(false)
            end
            
            
        end
    end
    showInfo()
    changeCoreTable ={}
    if obj then 
        local name_text=DictThing[tostring(obj.int["3"])].name
        local smallUiId = DictThing[tostring(obj.int["3"])].smallUiId
        local smallImage= DictUI[tostring(smallUiId)].fileName
        local description_text =DictThing[tostring(obj.int["3"])].description
        image_gem:loadTexture("image/" .. smallImage)
        text_name_gem:setString(name_text)
        for key,value in pairs(DictThing) do
          if DictThing[tostring(obj.int["3"])].level == value.level  and value.thingTypeId == StaticBag_Type.core and value.fightPropId ~= DictThing[tostring(obj.int["3"])].fightPropId then
              table.insert(changeCoreTable,value)
          end
        end
    end 
    
    for i=1,#changeCoreTable do
        local image_frame = ccui.Helper:seekNodeByName(UIGemSwitch.Widget,"image_frame_gem"..i)
        local image_gem = image_frame:getChildByName("image_gem1")
        local name = ccui.Helper:seekNodeByName(image_frame,"text_name_gem1")
        local image_choose = image_frame:getChildByName("image_choose")
        local smallUiId = changeCoreTable[i].smallUiId
        local smallImage= DictUI[tostring(smallUiId)].fileName
        image_gem:loadTexture("image/" .. smallImage )
        name:setString(DictFightProp[tostring(changeCoreTable[i].fightPropId)].name)
        local StartTime =nil
        local schedulerID =nil
        local function tick()
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)
            LongPush =true
            show(true,"image/" .. smallImage,changeCoreTable[i].description)
        end
        local function ImageEvent(sender,eventType)
             
             if eventType == ccui.TouchEventType.began then
                  StartTime = os.clock();
                  schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0.5, false)
             end
             if os.clock() - StartTime < 0.5 and  eventType == ccui.TouchEventType.ended then
                  cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)
             end
             if eventType == ccui.TouchEventType.ended and LongPush == true then
                  show(false)
                  LongPush=false
                  return
             end
             if eventType == ccui.TouchEventType.ended and LongPush == false then
                 if sender == chooseImageFrame then 
                      chooseImage:setVisible(false)
                      chooseImageFrame =nil
                      changedPropId = nil 
                      chooseImage = nil
                 else
                    if changedPropId ~= nil then 
                        changedPropId = changeCoreTable[i].fightPropId
                        image_choose:setVisible(true)
                        chooseImage:setVisible(false)
                        chooseImage = image_choose
                        chooseImageFrame=image_frame
                    else
                        changedPropId = changeCoreTable[i].fightPropId
                        image_choose:setVisible(true)
                        chooseImage = image_choose
                        chooseImageFrame = image_frame
                    end
                 end
                 if changedPropId ~= nil then 
                     local _name=  DictFightProp[tostring(changedPropId)].name
                     prompt:setString(Lang.ui_gem_switch13 .. _name)
                 else
                    prompt:setString(Lang.ui_gem_switch14)
                 end
                 
             end
        end
        image_frame:addTouchEventListener(ImageEvent)
    end
   if changedPropId ~= nil then 
       local _name=  DictFightProp[tostring(changedPropId)].name
       prompt:setString(Lang.ui_gem_switch15 .. _name)
   else
      prompt:setString(Lang.ui_gem_switch16)
   end
    ui_text_cost_number:setString(cost_money)
    ui_number_text:setString(number)
end
function UIGemSwitch.setData(_obj,_uiItem)
   if _obj ~= nil  then 
       obj = _obj
    end
   uiItem = _uiItem
   -- if chooseImage ~= nil then 
   --    chooseImage:setVisible(false)
   -- end
   changedPropId= nil
   chooseImage = nil 
   chooseImageFrame = nil
   number = 1
end

function UIGemSwitch.free()
  obj = nil 
  number = nil
  uiItem = nil
end
