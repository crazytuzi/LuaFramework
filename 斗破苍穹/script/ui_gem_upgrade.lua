require"Lang"
UIGemUpGrade={}
local obj = nil
local upgradedObj={}
local number = nil
local uiItem = nil
local MAXUPGRADELEVEL = 9
local tempObjNum = 0
local function netCallbackFunc(pack)
     if obj and tempObjNum > 0 and (tempObjNum - number*3) == 0 then 
        obj.int["5"]=0   ----如果消耗的个数与现有数量相等要讲此置为0 否则出现bug
    end
    UIManager.showToast(Lang.ui_gem_upgrade1.. number ..  Lang.ui_gem_upgrade2.. upgradedObj.name .."!")
    number = 0
    UIManager.flushWidget(UIBag)
    UIManager.flushWidget(UITeamInfo)
    UIManager.flushWidget(UIGemUpGrade)
   
end
local function sendLineUpData(num,Id)
    if obj then
        tempObjNum = obj.int["5"]
    end
    local  sendData = {
      header = StaticMsgRule.packGemUpgrade,
      msgdata = {
        int = {
          nextLevelGemNum  = num,
          instPlayerThingId = Id,
        }
      }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end

local function addFrameParticle(item)
  local size = item:getContentSize()
  local particle1 = cc.ParticleSystemQuad:create("particle/btn_xing_b.plist")
  local path1 = utils.MyPathFun(0,size.height,size.width,0.8,1) 
  particle1:setPosition(cc.p(0,0))
  item:addChild(particle1)
  particle1:runAction(path1)
  local particle2 = cc.ParticleSystemQuad:create("particle/btn_xing_y.plist")
  local path2 = utils.MyPathFun(0,size.height,size.width,0.8,2)
  particle2:setPosition(cc.p(size.width,size.height))
  item:addChild(particle2)
  particle2:runAction(path2)
end

function UIGemUpGrade.init()
    local ui_title = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"text_title")
    ui_title:setString(Lang.ui_gem_upgrade3)
    local ui_number_get = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"text_number")
    local btn_add = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"btn_add")
    local btn_cut = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"btn_cut")
    local btn_big = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"btn_big")
    local btn_close = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"btn_close")
    local btn_switch = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"btn_switch")
    local ui_btn_inlay = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"btn_gem_inlay")
    local ui_btn_lineup = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"btn_gem_lineup")
    local ui_btn_switch = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"btn_gem_switch")
    local ui_costSilver_number = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"text_cost_number")
    local ui_costGem_number = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"text_r")
    btn_add:setPressedActionEnabled(true)
    btn_cut:setPressedActionEnabled(true)
    btn_big:setPressedActionEnabled(true)
    btn_close:setPressedActionEnabled(true)
    btn_switch:setPressedActionEnabled(true)

    local function btnEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended  then
          AudioEngine.playEffect("sound/button.mp3")
          local cost_money = 0 
          if sender == btn_add or sender == btn_cut or sender == btn_big and obj then
            if sender == btn_add then 
                if  number < math.floor(obj.int["5"]/3) then
                    number = number + 1
                else
                    UIManager.showToast(Lang.ui_gem_upgrade4)
                end
            elseif sender == btn_cut then 
                if number > 0 then  
                  number = number - 1
                end
            elseif sender == btn_big then 
                number = math.floor(obj.int["5"]/3)
            end
            ui_number_get:setString(number)
            cost_money = number*DictSysConfig[tostring(StaticSysConfig.coreUpgradeCopper)].value
            ui_costSilver_number:setString(cost_money)
            ui_costGem_number:setString(string.format("%s×%d",DictThing[tostring(obj.int["3"])].name,number*3))
          elseif sender == btn_close then 
            UIManager.popScene()
          elseif sender == btn_switch then 
            if  not obj then 
              UIManager.showToast(Lang.ui_gem_upgrade5) 
              return
            end
            if number ~= 0 then 
                if DictThing[tostring(obj.int["3"])].level == MAXUPGRADELEVEL then
                    UIManager.showToast(Lang.ui_gem_upgrade6)
                    return
                end
                 if number*3 > obj.int["5"] then 
                    UIManager.showToast(Lang.ui_gem_upgrade7)
                    return
                 end 
                 if cost_money <= net.InstPlayer.int["5"] then 
                    sendLineUpData(number,obj.int["1"])
                    
                 else
                    UIManager.showToast(Lang.ui_gem_upgrade8)
                 end
             else
                 UIManager.showToast(Lang.ui_gem_upgrade9) 
             end
          elseif sender == ui_btn_inlay then 
            UIManager.replaceScene("ui_gem_inlay")
          elseif sender == ui_btn_switch then 
            UIGemSwitch.setData(obj,uiItem)
            UIManager.replaceScene("ui_gem_switch")
          end
        end
    end

    btn_add:addTouchEventListener(btnEvent)
    btn_cut:addTouchEventListener(btnEvent)
    btn_big:addTouchEventListener(btnEvent)
    btn_close:addTouchEventListener(btnEvent)
    btn_switch:addTouchEventListener(btnEvent)
    ui_btn_inlay:addTouchEventListener(btnEvent)
    ui_btn_switch:addTouchEventListener(btnEvent)
    local image_base_before = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"image_base_before")
    local ui_before_frame = image_base_before:getChildByName("image_frame_gem")
    addFrameParticle(ui_before_frame)
end
----添加魔核方法
local function  addGemFunc(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
        UIGemList.setData(2,uiItem)
        UIManager.pushScene("ui_gem_list")
    end
end
function UIGemUpGrade.setup()  
    local ui_btn_inlay = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"btn_gem_inlay")
    local ui_btn_lineup = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"btn_gem_lineup")
    local ui_btn_switch = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"btn_gem_switch")
    local image_base_before = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"image_base_before")
    local image_base_after = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"image_base_after")
    local image_base_switch = ccui.Helper:seekNodeByName(UIGemUpGrade.Widget,"image_base_switch")
    local ui_before_frame = image_base_before:getChildByName("image_frame_gem")
    local ui_before_image = ui_before_frame:getChildByName("image_gem")
    local ui_before_name  = ccui.Helper:seekNodeByName(image_base_before,"text_name_gem")
    local ui_before_info = ccui.Helper:seekNodeByName(image_base_before,"text_info_gem")
    local ui_before_number = ccui.Helper:seekNodeByName(image_base_before,"text_number_gem")

    local ui_after_frame = image_base_after:getChildByName("image_frame_gem")
    local ui_after_image = ui_after_frame:getChildByName("image_gem")
    local ui_after_name  = ccui.Helper:seekNodeByName(image_base_after,"text_name_gem")
    local ui_after_info = ccui.Helper:seekNodeByName(image_base_after,"text_info_gem")

    local ui_number_get = ccui.Helper:seekNodeByName(image_base_switch,"text_number")
    local ui_costGem_number = ccui.Helper:seekNodeByName(image_base_switch,"text_r")
    local ui_costSilver_number = ccui.Helper:seekNodeByName(image_base_switch,"text_cost_number")
    ui_before_image:addTouchEventListener(addGemFunc)  --添加魔核
    if uiItem == UIBag then 
        ui_btn_inlay:setVisible(false)
        ui_btn_switch:setPosition(cc.p(245,-26))
        ui_btn_lineup:setPosition(cc.p(95,-26))
    else
        ui_btn_inlay:setVisible(true)
        ui_btn_switch:setPosition(cc.p(395,-26))
        ui_btn_lineup:setPosition(cc.p(245,-26))
    end
    ui_number_get:setString(number)
    ui_costSilver_number:setString(0)
    if obj then 
        ui_after_info:setVisible(true)
        ui_after_name:setVisible(true)
        ui_before_name:setVisible(true)
        local name=DictThing[tostring(obj.int["3"])].name
        local smallUiId = DictThing[tostring(obj.int["3"])].smallUiId
        local smallImage= DictUI[tostring(smallUiId)].fileName
        local description =DictThing[tostring(obj.int["3"])].description
        ui_before_image:loadTexture("image/" .. smallImage)
        ui_before_name:setString(name)
        ui_before_info:setString(description)
        ui_before_number:setString(string.format("%d/3",obj.int["5"]))
        ui_costGem_number:setString(string.format("%s×%d",name,number*3))
        local cost_money = number*DictSysConfig[tostring(StaticSysConfig.coreUpgradeCopper)].value
        ui_costSilver_number:setString(cost_money)
        upgradedObj = nil
        for key,value in pairs(DictThing) do
            if DictThing[tostring(obj.int["3"])].level+1 == value.level and DictThing[tostring(obj.int["3"])].fightPropId == value.fightPropId 
            and DictThing[tostring(obj.int["3"])].thingTypeId == value.thingTypeId  then
                  upgradedObj = value
            end
        end
        if upgradedObj then 
            local smallImage= DictUI[tostring(upgradedObj.smallUiId)].fileName
            ui_after_image:loadTexture("image/" .. smallImage)
            ui_after_name:setString(upgradedObj.name)
            ui_after_info:setString(upgradedObj.description)
        elseif DictThing[tostring(obj.int["3"])].level == MAXUPGRADELEVEL then
            ui_after_name:setString(Lang.ui_gem_upgrade10)
            ui_after_info:setString("")
        else
            UIManager.showToast("data error！")
        end
    else 
        number = 0
        ui_after_name:setVisible(false)
        ui_after_info:setVisible(false)
        ui_after_frame:loadTexture("ui/quality_small_purple.png")
        ui_after_image:loadTexture("ui/frame_tianjia.png")
        ui_before_frame:loadTexture("ui/quality_small_purple.png")
        ui_before_image:loadTexture("ui/frame_tianjia.png")
        ui_before_name:setVisible(false)
        ui_before_info:setString(Lang.ui_gem_upgrade11)
        ui_costGem_number:setString(Lang.ui_gem_upgrade12)
        ui_before_number:setString("0/0")
    end 
end
function UIGemUpGrade.setData(_obj,_uiItem)
    if _obj ~= nil  then 
       obj = _obj
    end
    number = 1
    uiItem = _uiItem
end

function UIGemUpGrade.free()
  number = nil
  obj= nil
  upgradedObj = nil
  uiItem = nil
end
