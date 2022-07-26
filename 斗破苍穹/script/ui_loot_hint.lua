require"Lang"
UILootHint={}
UILootHint.operateType = {
  chip = 1, --抢夺
  peace = 2, --和平
}
local operateType = nil
local ui_chip_base  =nil
local ui_title = nil
local param = nil

local function netCallbackFunc(pack)
  if tonumber(pack.header) == StaticMsgRule.lootPlayer then
      UILootChoose.npc ={}
      UILootChoose.pc ={}
      if pack.msgdata.message.npc and pack.msgdata.message.npc.message then
          UILootChoose.npc = pack.msgdata.message.npc.message
      end
      if pack.msgdata.message.pc and pack.msgdata.message.pc.message then 
          UILootChoose.pc = pack.msgdata.message.pc.message
      end
      if pack.msgdata.message.ds and pack.msgdata.message.ds.int then 
          UILootChoose.ds = pack.msgdata.message.ds.int
      end
      UIManager.popScene()
      UILootChoose.setChipId(param[1])
  elseif tonumber(pack.header) == StaticMsgRule.lootPeace  then 
       UIManager.popScene()
       UILoot.countDownTime = UILoot.countDownTime + DictSysConfig[tostring(StaticSysConfig.lootPeaceTime)].value*3600
       if UILoot.ScheduleId == nil then
          UILoot.updateTime()
          UILoot.ScheduleId =cc.Director:getInstance():getScheduler():scheduleScriptFunc(UILoot.updateTime,1,false)
       end
       -- UIManager.flushWidget(UILoot)
  end
end

local function sendLootData(_chipId,callBack)
    local sendData = {
        header = StaticMsgRule.lootPlayer,
        msgdata = {
          int = {
            chipId   = _chipId ,
          },
          string = {
            step = UIGuidePeople.guideStep or ""
          }
        }
      }

    UIManager.showLoading()
    netSendPackage(sendData, callBack)
end

local function sendlootPeaceData(_type,_instPlayerLootId)
    local  sendData = {
      header = StaticMsgRule.lootPeace,
      msgdata = {
        int = {
          type   = _type  ,
          instPlayerLootId = _instPlayerLootId ,
        }
      }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end

function UILootHint.getLootData(callBack)
    cclog("chipId=" .. param[1])
    sendLootData(param[1],callBack)
end

function UILootHint.init()
   ui_chip_base  =  ccui.Helper:seekNodeByName(UILootHint.Widget,"image_base_chip")
   local ui_image_prace_brand =  ccui.Helper:seekNodeByName(UILootHint.Widget,"image_prace_brand")
   local ui_text_peace_cost =  ccui.Helper:seekNodeByName(UILootHint.Widget,"text_peace_cost")
   ui_title = ccui.Helper:seekNodeByName(UILootHint.Widget,"text_title")
   local image_brand = ccui.Helper:seekNodeByName(ui_image_prace_brand,"image_brand")
   local image_gold = ccui.Helper:seekNodeByName(UILootHint.Widget,"image_gold")
   image_brand:loadTexture("image/poster_item_small_hepingpai.png") 
   image_gold:loadTexture("image/poster_item_small_yuanbao.png")
   
   local btn_close  =  ccui.Helper:seekNodeByName(UILootHint.Widget,"btn_close")
   local btn_loot = ccui.Helper:seekNodeByName(UILootHint.Widget,"btn_loot")
   local btn_brand_buy  =  ccui.Helper:seekNodeByName(UILootHint.Widget,"btn_brand_buy")
   local btn_gold_buy = ccui.Helper:seekNodeByName(UILootHint.Widget,"btn_gold_buy")
   btn_close:setPressedActionEnabled(true)
   btn_loot:setPressedActionEnabled(true)
   btn_brand_buy:setPressedActionEnabled(true)
   btn_gold_buy:setPressedActionEnabled(true)
   local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_loot then 
                 UILootHint.getLootData(netCallbackFunc)
            elseif sender == btn_brand_buy then
                if param ~= nil then 
                    sendlootPeaceData(1,param)
                else
                    UIManager.showToast(Lang.ui_loot_hint1)
                end
            elseif sender == btn_gold_buy then 
                if param ~= nil then 
                    sendlootPeaceData(2,param)
                else
                    UIManager.showToast(Lang.ui_loot_hint2)
                end
            end
        end
   end
   btn_close:addTouchEventListener(btnTouchEvent)
   btn_loot:addTouchEventListener(btnTouchEvent)
   btn_brand_buy:addTouchEventListener(btnTouchEvent)
   btn_gold_buy:addTouchEventListener(btnTouchEvent)
   btn_gold_buy:setTitleText(string.format(Lang.ui_loot_hint3,DictSysConfig[tostring(StaticSysConfig.lootGold)].value))
   ui_text_peace_cost:setString(string.format(Lang.ui_loot_hint4,DictSysConfig[tostring(StaticSysConfig.lootGold)].value))
end
function UILootHint.setup()
   if operateType == UILootHint.operateType.chip then 
      ui_chip_base:setVisible(true)
      ccui.Helper:seekNodeByName(UILootHint.Widget,"image_prace_brand"):setVisible(false)
      ccui.Helper:seekNodeByName(UILootHint.Widget,"image_prace_gold"):setVisible(false)
      ccui.Helper:seekNodeByName(UILootHint.Widget,"text_peace_cost"):setVisible(false)
      ccui.Helper:seekNodeByName(UILootHint.Widget,"text_peace_time"):setVisible(false)
      ccui.Helper:seekNodeByName(UILootHint.Widget,"text_hint"):setVisible(true)
      ui_title:setString(Lang.ui_loot_hint5)
      local ui_name = ccui.Helper:seekNodeByName(UILootHint.Widget,"text_chip_name")
      local ui_description = ccui.Helper:seekNodeByName(UILootHint.Widget,"text_describe")
      local ui_chip = ccui.Helper:seekNodeByName(UILootHint.Widget,"image_chip")
      local chipData = DictChip[tostring(param[1])]
      local name = chipData.name
      local dictMagic = DictMagic[tostring(chipData.skillOrKungFuId)]
      local qualityId = dictMagic.magicQualityId
      local type = chipData.type
      local qualityType = DictMagicQuality[tostring(qualityId)].name
      local description  = nil
      if type == 2 then 
        description = qualityType .. Lang.ui_loot_hint6
      elseif type == 3 then 
        description = qualityType .. Lang.ui_loot_hint7
      end
      ui_name:setString(name)
      ui_description:setString(description)
      ui_chip:loadTexture(param[2])
      ui_chip:setTextureRect(cc.rect(param[3],param[4],86,86))
      UIGuidePeople.isGuide(nil,UILootHint)
      if UILoot.countDownTime > 0 then 
        ccui.Helper:seekNodeByName(UILootHint.Widget,"text_hint"):setVisible(true)
      else 
        ccui.Helper:seekNodeByName(UILootHint.Widget,"text_hint"):setVisible(false)
      end
   elseif operateType == UILootHint.operateType.peace then
      ui_title:setString(Lang.ui_loot_hint8)
      ui_chip_base:setVisible(false)
      ccui.Helper:seekNodeByName(UILootHint.Widget,"image_prace_brand"):setVisible(true)
      ccui.Helper:seekNodeByName(UILootHint.Widget,"image_prace_gold"):setVisible(true)
      ccui.Helper:seekNodeByName(UILootHint.Widget,"text_peace_cost"):setVisible(true)
      ccui.Helper:seekNodeByName(UILootHint.Widget,"text_peace_time"):setVisible(true)
      ccui.Helper:seekNodeByName(UILootHint.Widget,"text_hint"):setVisible(false)
   end 
   
end
function UILootHint.setOperateType(_operateType,_param)
    param = nil
    param =_param
    operateType = _operateType
    UIManager.pushScene("ui_loot_hint")
end
