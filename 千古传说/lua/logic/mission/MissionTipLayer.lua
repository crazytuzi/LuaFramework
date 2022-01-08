--[[
******PVE推图-剧情对话*******

    -- by haidong.gan
    -- 2013/11/27
]]
local MissionTipLayer = class("MissionTipLayer", BaseLayer)

CREATE_SCENE_FUN(MissionTipLayer)
CREATE_PANEL_FUN(MissionTipLayer)

--战斗前，对话播放完毕
MissionTipLayer.EVENT_SHOW_BEGINTIP_COM = "MissionTipLayer.EVENT_SHOW_BEGINTIP_COM"
--战斗后，对话播放完毕
MissionTipLayer.EVENT_SHOW_ENDTIP_COM   = "MissionTipLayer.EVENT_SHOW_ENDTIP_COM"

function MissionTipLayer:ctor(data)
    self.super.ctor(self,data)

    self.tiplist      = data.tiplist
    self.stageType    = data.stageType
    self.tipIndex     = 1
    self.dispatchGlobalMessage = data.dispatchGlobalMessage
    -- self.leftImage    = -1
    -- self.rightImage    = -1

    self:init("lua.uiconfig_mango_new.mission.MissionTipLayer")
end

function MissionTipLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.bg           = TFDirector:getChildByPath(ui, "panel_bg")
    self.bg:setBackGroundColorOpacity(200)

    local panel_role_1 = TFDirector:getChildByPath(ui, 'panel_role_1')
    self.panel_role_1 = panel_role_1
    panel_role_1.mountain = TFDirector:getChildByPath(ui, 'img_di_1')
    panel_role_1.hiddenPos = ccp(-500, 0)
    panel_role_1.imageID = -1
    self.txt_name_1 =  TFDirector:getChildByPath(ui, 'txt_name_1')
    self.txt_text_1 =  TFDirector:getChildByPath(ui, 'txt_text_1')
    self.bg_name1 =  TFDirector:getChildByPath(ui, 'bg_name1')
    
    local panel_role_2 = TFDirector:getChildByPath(ui, 'panel_role_2')
    self.panel_role_2 = panel_role_2
    panel_role_2.mountain = TFDirector:getChildByPath(ui, 'img_di_2')
    panel_role_2.hiddenPos = ccp(500, 0)
    panel_role_2.imageID = -1
    self.txt_name_2 =  TFDirector:getChildByPath(ui, 'txt_name_2')
    self.txt_text_2 =  TFDirector:getChildByPath(ui, 'txt_text_2')
    self.bg_name2 =  TFDirector:getChildByPath(ui, 'bg_name2')

    -- self.bg_content =  TFDirector:getChildByPath(ui, 'bg_content')

    self:showNextTip()
end

function MissionTipLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI()
end

function MissionTipLayer:refreshBaseUI()

end


function MissionTipLayer:removeUI()
   self.super.removeUI(self)
end

function MissionTipLayer.onNextClickHandle(sender)
   local self = sender.logic
   self.tipIndex = self.tipIndex + 1
   
   if self.tipIndex > self.tiplist:length() then
    
      local stageType = self.stageType
      local dispatchGlobalMessage = self.dispatchGlobalMessage
       --对话结束
      local currentScene = Public:currentScene()
      currentScene:removeLayer(self,true)

      --add by quanhuan 2016/3/11
      if dispatchGlobalMessage then
        TFDirector:dispatchGlobalEventWith(dispatchGlobalMessage, {})
      else
        if stageType == 1 or stageType == 11  then
          TFDirector:dispatchGlobalEventWith(MissionTipLayer.EVENT_SHOW_BEGINTIP_COM, {})
        else
          TFDirector:dispatchGlobalEventWith(MissionTipLayer.EVENT_SHOW_ENDTIP_COM, {})
        end
      end
   else
       self:showNextTip()
   end
end

function MissionTipLayer:playEffect( effect )
  if self.effectHandle ~= nil then
    TFAudio.stopEffect(self.effectHandle)
  end
  self.effectHandle = TFAudio.playEffect("sound/dia/"..effect,false)
end

local hiddenColor = ccc3(100, 100, 100)
local showColor = ccc3(255, 255, 255)
function MissionTipLayer:showNextTip()
  local tip = self.tiplist:objectAt(self.tipIndex)

  -- 说话者切换动画
  local panel_role = tip.position == MissionManager.TIPLEFT and self.panel_role_1 or self.panel_role_2
  self:switchAnimation(panel_role, tip.image)

   self:showTipInfo(tip)

   if tip.sound and tip.sound~= "" then
      self:playEffect(tip.sound)
   end
end

function MissionTipLayer:switchAnimation(panel_role, tipImage)
  local hidden_panel = panel_role == self.panel_role_1 and self.panel_role_2 or panel_role
  self:hiddenRole(hidden_panel)

  panel_role.mountain:setColor(showColor)
  local armatureID = tipImage == 0 and MainPlayer:getResourceId() or tipImage
  if panel_role.imageID == armatureID then
    panel_role.model:setColor(showColor)
    return
  end

  local outModel = panel_role.model
  panel_role.imageID = armatureID
  ModelManager:addResourceFromFile(1, armatureID, 1)
  local curModel = ModelManager:createResource(1, armatureID)
  curModel:setPosition(panel_role.hiddenPos)
  local scaleX = panel_role == self.panel_role_1 and 1.0 or -1.0
  curModel:setScaleX(scaleX)
  panel_role:addChild(curModel)
  panel_role.model = curModel
  ModelManager:playWithNameAndIndex(curModel, "stand", -1, 1, -1, -1)

  
  if outModel then
    local outTween = 
    {
      target = outModel,
      {
        ease = {type=TFEaseType.EASE_IN_OUT, rate=3},
        duration = 0.4 / FightManager.fightSpeed,
        x = panel_role.hiddenPos.x,

        onComplete = function ()
          outModel:removeFromParent()
        end,
      },
    }
    TFDirector:toTween(outTween)
  end

  local inTween = 
  {
    target = curModel,
    {
      ease = {type=TFEaseType.EASE_IN_OUT, rate=3},
      duration = 0.4 / FightManager.fightSpeed,
      x = 0,
    },
  }
  TFDirector:toTween(inTween)
end

--  隐藏角色
function MissionTipLayer:hiddenRole(hidden_panel)
  local hiddenModel = hidden_panel.model
  local hiddenMountain = hidden_panel.mountain

  -- 调暗听话着颜色
  if hiddenModel then hiddenModel:setColor(hiddenColor) end
  if hiddenMountain then hiddenMountain:setColor(hiddenColor) end
end

-- 显示对话信息
function MissionTipLayer:showTipInfo(tip)
  local posType = tip.position
  local content = tip.content
  local name = tip.name
  self.txt_name_1:setVisible(posType == MissionManager.TIPLEFT)
  self.txt_name_2:setVisible(posType == MissionManager.TIPRIGTH)
  self.bg_name1:setVisible(posType == MissionManager.TIPLEFT)
  self.bg_name2:setVisible(posType == MissionManager.TIPRIGTH)
  self.txt_text_1:setVisible(posType == MissionManager.TIPLEFT)
  self.txt_text_2:setVisible(posType == MissionManager.TIPRIGTH)

  local txt_text = posType == MissionManager.TIPLEFT and self.txt_text_1 or self.txt_text_2
  content = content:gsub("XX", MainPlayer:getPlayerName())
  txt_text:setText(content)

  if tip.image == 0 then name = MainPlayer:getPlayerName() end
  local txt_name = posType == MissionManager.TIPLEFT and self.txt_name_1 or self.txt_name_2
  txt_name:setText(name)
end

--注册事件
function MissionTipLayer:registerEvents()
   self.super.registerEvents(self) 
   self.bg.logic = self
   self.bg:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onNextClickHandle))
end

return MissionTipLayer
