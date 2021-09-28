
local CreateRoleLayer = class ("CreateRoleLayer", UFCCSNormalLayer)
local EffectNode = require "app.common.effects.EffectNode"
local JumpBackCard = require("app.scenes.common.JumpBackCard")
KnightPic = require("app.scenes.common.KnightPic")

require("app.cfg.rand1_place_info")
require("app.cfg.rand2_surname_info")
require("app.cfg.rand3_name_info")

--local offset = 85
local SEX = 
{
    MAN = 1,
    WOMAN = 2,
}

local roleId = {10011,10021,10031,10041}
local imgName = {"ui/text/txt/huwei.png","ui/text/txt/shenshe.png","ui/text/txt/moushi.png","ui/text/txt/yueshi.png"}

function CreateRoleLayer:_randomName1(name)
      local rand = rand1_place_info.get(math.random(1, rand1_place_info.getLength())).place
      if string.len(name) > 2 and string.byte(name,-3) == string.byte(rand,1) and string.byte(name,-2) == string.byte(rand,2) and string.byte(name,-1) == string.byte(rand,3) then
            return self:_randomName1(name)
      else
            return name..rand
      end
end

function CreateRoleLayer:_randomName2(name)
      local rand = rand2_surname_info.get(math.random(1, rand2_surname_info.getLength())).surname
      if string.len(name) > 2 and string.byte(name,-3) == string.byte(rand,1) and string.byte(name,-2) == string.byte(rand,2) and string.byte(name,-1) == string.byte(rand,3) then
            return self:_randomName2(name)
      else
            return name..rand
      end
end

function CreateRoleLayer:_randomName3(name)
      local rand3 = rand3_name_info.get(math.random(1, rand3_name_info.getLength()))
      local rand = ""
      if self:_getSex() == SEX.MAN then
        rand = rand3.name_boy
      else
        rand = rand3.name_girl
      end
      if string.len(name) > 2 and string.byte(name,-3) == string.byte(rand,1) and string.byte(name,-2) == string.byte(rand,2) and string.byte(name,-1) == string.byte(rand,3) then
            return self:_randomName3(name)
      else
            return name..rand
      end
end

function CreateRoleLayer:_randomName()
    local name = ""
    name = self:_randomName1(name)
    name = self:_randomName2(name)
    name = self:_randomName3(name)
    if string.utf8len(name) > 6 then
      return self:_randomName()
    else
      return name
    end
end

function CreateRoleLayer:_checkName(txt)
    if txt == "" then 
        G_MovingTip:showMovingTip(G_lang:get("LANG_CREATEROLE_EMPTY"))
        return false
    end
    if string.utf8len(txt) < 2 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_CREATEROLE_TOOSHORT"))
        return false
    end
    if string.utf8len(txt) > 6 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_CREATEROLE_TOOLONG"))
        return false
    end
    if self:_checkSpecial(txt) then
        G_MovingTip:showMovingTip(G_lang:get("LANG_CREATEROLE_NOTQUALIFIED"))
        return false
    end

    if G_GlobalFunc and G_GlobalFunc.matchText(txt) then 
        G_MovingTip:showMovingTip(G_lang:get("LANG_CREATEROLE_INVALID_TEXT"))
        return false
    end
    return true
end

function CreateRoleLayer:_checkSpecial(txt)
    if string.find(txt," ") then
        return true
    end
    if string.find(txt,"\'") then
        return true
    end
    if string.find(txt,"\"") then
        return true
    end
    if string.find(txt,"\\") then
        return true
    end
    if string.find(txt,"~") then
        return true
    end
    if string.find(txt,"`") then
        return true
    end
    if string.find(txt,"<") then
        return true
    end
    if string.find(txt,">") then
        return true
    end
    if string.find(txt,",") then
        return true
    end
    return false
end



function CreateRoleLayer.create( )   
    return CreateRoleLayer.new("ui_layout/createrole_CreateRoleLayer.json") 
end

function CreateRoleLayer:ctor( ... )
    self.super.ctor(self, ...)
    self._id = 1
    self._playing = false
    self:enableTab(true)
    self._init = false
    self.name = ""
    
    self._layerMoveOffset = 0
    self.heroPanel = self:getPanelByName("Panel_hero")
    self._desImg = self:getImageViewByName("Image_name")
    -- self._knight =KnightPic.createKnightPic( knight_info.get(1).res_id, self.heroPanel, "knight"..1,true )

    self._knight = EffectNode.new("effect_nan_create", 
        function(event, frameIndex)
            if event == "finish" then
         
            end
        end
    )
    self._knight:setPosition(self:getOffset(self._id))
    self._knight:play()
    self.heroPanel:addNode(self._knight) 

    self._tabs = require("app.common.tools.Tabs").new(1, self, self.onCheckCallback)
    self._tabs:add("CheckBox_male", nil,nil)
    self._tabs:add("CheckBox_female", nil,nil)
    self._tabs:checked("CheckBox_male")
    self:enableLabelStroke("Label_tips", Colors.strokeBrown, 1 )

    self._checkMale = self:getCheckBoxByName("CheckBox_male")
    self._checkFemale = self:getCheckBoxByName("CheckBox_female")
    self._nameLabel = self:getImageViewByName("Image_name")
    self._tips = self:getLabelByName("Label_tips")
    self._bot = self:getPanelByName("Panel_bot")

    self._curHeroImageM = nil
    self._curHeroImageF = nil

    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    if IS_HEXIE_VERSION or appstoreVersion then 
      self.heroPanel:setVisible(false)
      local panel = self:getWidgetByName("Panel_32")
      if panel then 
        self._curHeroImageM = ImageView:create()
        self._curHeroImageM:loadTexture("ui/createrole/male_hexie.png")
        panel:addChild(self._curHeroImageM)

        self._curHeroImageF = ImageView:create()
        self._curHeroImageF:loadTexture("ui/createrole/female_hexie.png")
        panel:addChild(self._curHeroImageF)

        local posx, posy = panel:getPosition()
        local size = panel:getSize()
        self._curHeroImageM:setPosition(ccp(posx + size.width/2, posy))
        self._curHeroImageF:setPosition(ccp(posx + size.width/2, posy))
        self._curHeroImageF:setVisible(false)
      end
    else
      self:enterAnime()
    end

    local around = nil
    around = EffectNode.new("effect_around2", 
        function(event)
    end)

    local createBtn = self:getWidgetByName("Button_create")
    if createBtn and around then 
        createBtn:addNode(around)
        around:setScale(1.8)
        around:play()
    end

     self:registerBtnClickEvent("Button_create",function()
         --确定创建角色
         if self._playing then 
           return 
         end
         --local txt = self:getLabelByName("Label_name"):getStringValue()
         local textfield = self:getTextFieldByName("Textview_name")
         local txt = ""
         if textfield then 
          txt = textfield:getStringValue()
         end
         if self:_checkName(txt) then
            G_HandlersManager.coreHandler:sendCreateRole( txt, self._id )
         end
     end)
     self:registerBtnClickEvent("Button_tuozi",function()
         --确定创建角色
         local name = self:_randomName()
         local textfield = self:getTextFieldByName("Textview_name")
         if textfield then 
            textfield:setText(name)
         end
         --self:getLabelByName("Label_name"):setText(name)
     end)
     local textfield = self:getTextFieldByName("Textview_name")
     if textfield then 
            textfield:setText(self:_randomName())
     end
 
  self:registerTextfieldEvent("Textview_name",function ( textfield, eventType )
        if self._playing then 
          return 
        end
        self:callAfterFrameCount(2, function ( ... )
          self:_onInputFieldEvent(eventType)
        end)
     end)

    local nameField = self:getTextFieldByName("Textview_name")
    if nameField then 
      nameField:setMaxLengthEnabled(true)
      nameField:setMaxLength(18)
    end
    self:getLabelByName("Label_tips"):setText(G_lang:get("LANG_CREATEROLE_TITLE_TIPS"))
end

function CreateRoleLayer:onCheckCallback(btnName)
    
    if btnName == "CheckBox_male" then
        self._id = 1
        self.name = "effect_nan_create"
    else
        self._id = 4
        self.name = "effect_nv_create"
    end

    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    if IS_HEXIE_VERSION or appstoreVersion then 
      if self._curHeroImageF then 
        self._curHeroImageF:setVisible(btnName ~= "CheckBox_male")
      end
      if self._curHeroImageM then 
        self._curHeroImageM:setVisible(btnName == "CheckBox_male")
      end
      return
    end

    if self._knight then
      self._knight:removeFromParentAndCleanup(true)
    end

    self._knight = EffectNode.new(self.name, 
        function(event, frameIndex)
            if event == "finish" then
         
            end
        end
    )
    self._knight:setPosition(self:getOffset(self._id))
    self._knight:play()
    self.heroPanel:addNode(self._knight) 

    -- self._knight = KnightPic.createKnightPic( roleId[self._id], self.heroPanel, "knight"..self._id,true )
    self._knight:setVisible(false)
    self._desImg:loadTexture(imgName[self._id])
    self:heroGo()
end

function CreateRoleLayer:popInput( param)
 -- if param == TOUCH_EVENT_ENDED then
      local maxLength = require("app.const.GlobalConst").USER_NAME_LENGTH_MAX
      local input = require("app.scenes.createrole.InputLayer").create( maxLength ,
        self:getLabelByName("Label_name"):getStringValue(),
       function ( txt )
        self:getLabelByName("Label_name"):setText(txt)
      end)   
      uf_sceneManager:getCurScene():addChild(input, 100)
  --end
end


function CreateRoleLayer:_onInputFieldEvent( eventType )
  local textfield = self:getTextFieldByName("Textview_name")
  local sharedApplication = CCApplication:sharedApplication()
  local target = sharedApplication:getTargetPlatform()

  if eventType == CCSTEXTFIELDEX_EVENT_KEYBOARD_DO_SHOW then 
    if target == kTargetIphone or target == kTargetIpad then 
      if self._layerMoveOffset < 1 and textfield then 
       -- G_keyboardShowTimes = G_keyboardShowTimes + 1
       -- self:callAfterFrameCount(G_keyboardShowTimes > 1 and 15 or 40, function ( ... )
          local textSize = textfield:getSize()
          local screenPos = textfield:convertToWorldSpace(ccp(0, 0))
          local keyboardHeight = textfield:getKeyboardHeight()
          if display.contentScaleFactor >= 2 then 
            keyboardHeight = keyboardHeight/2
          end
          if keyboardHeight > screenPos.y - 4*textSize.height then 
            self._layerMoveOffset = keyboardHeight - screenPos.y + 4*textSize.height
          end

          __Log("screenPos:(%d), keyboardHeight:%d, _layerMoveOffset:%d", screenPos.y, keyboardHeight, self._layerMoveOffset)

          if self._layerMoveOffset > 0 then 
            self:runAction(CCMoveBy:create(0.2, ccp(0, self._layerMoveOffset)))
            textfield:runAction(CCMoveBy:create(0.2, ccp(0, 0)))
          end
       -- end)
      end
    end
  elseif eventType == CCSTEXTFIELDEX_EVENT_DETACH_WITH_IME then 
    if self._layerMoveOffset > 0 then 
      self:runAction(CCMoveBy:create(0.2, ccp(0, -self._layerMoveOffset)))
      textfield:runAction(CCMoveBy:create(0.2, ccp(0, 0)))
      self._layerMoveOffset = 0
    end
  elseif eventType == CCSTEXTFIELDEX_EVENT_RETURN then 
    if textfield then
      local text = textfield:getStringValue()
      if device.platform == "wp8" or device.platform == "winrt" then
        local label = self:getLabelByName("Label_name")
        text = label:deleteInvalidChars(text)
      else
        text = FTLabelManager:getInstance():deleteInvalidChars(text)
      end
      textfield:setText(text)
    end
  end
end

function CreateRoleLayer:onLayerEnter( ... )
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.MAIN)
end

function CreateRoleLayer:onLayerExit()
    G_SoundManager:unloadSceneSoundList()
end

function CreateRoleLayer:_getSex()
    if self._id < 3 then 
      return SEX.MAN
    else 
      return SEX.WOMAN
    end

end

function CreateRoleLayer:enterAnime()
  self._playing = true
  self:enableTab(false)

  self._checkMale:setScale(0.01)
  self._checkFemale:setScale(0.01)
  local namePos = ccp(self._nameLabel:getPosition())
  self._nameLabel:setPosition(ccp(namePos.x+300,namePos.y))
  self._tips:setOpacity(0)
  local botPos = ccp(self._bot:getPosition())
  self._bot:setPosition(ccp(botPos.x,botPos.y-300))
  self._knight:setVisible(false)

  -- self._tips:runAction(CCMoveBy:create(0.7,ccp(0,-300)))
  self._tips:runAction(CCFadeTo:create(0.2,255))
  self._nameLabel:runAction(CCMoveBy:create(0.2,ccp(-300,0)))

  -- local resId = roleId[self._id]
  local resId = knight_info.get(self._id).res_id
  local knightPos = self:getOffset(self._id)
  local worldPos = self._knight:getParent():convertToWorldSpace(knightPos)
  local jumpKnight = JumpBackCard.create()
  local start = ccp(-500,0)
  self._knight:getParent():addNode(jumpKnight)

  self._knightjump = EffectNode.new(self.name, 
      function(event, frameIndex)
          if event == "finish" then
       
          end
      end
  )
  -- self._knightjump:setPosition(ccp(0,160))
  self._knightjump:play()
  jumpKnight:playWithKnight(self._knightjump, start, 0.5, worldPos, self._knight:getScale(), function() 
      jumpKnight:removeFromParentAndCleanup(true)
      self._knight:setVisible(true)
      self._playing = false
      self:enableTab(true)
      self._init = true
      G_SoundManager:playSound(knight_info.get(self._id).common_sound)
      local scaleSeq = CCSequence:createWithTwoActions(CCScaleTo:create(0.3,1.2),CCScaleTo:create(0.1,1))
      local scaleSeq2 = CCSequence:createWithTwoActions(CCScaleTo:create(0.3,1.2),CCScaleTo:create(0.1,1))
      self._checkMale:runAction(scaleSeq)
      self._checkFemale:runAction(scaleSeq2)
      self._bot:runAction(CCMoveBy:create(0.2,ccp(0,300)))
  end )
end

function CreateRoleLayer:heroGo()
  if not self._init then
    return
  end
  self:getWidgetByName("Panel_zhezhao"):setTouchEnabled(true)
  self._playing = true
  self:enableTab(false)
  G_SoundManager:stopAllSounds()
  local namePos = ccp(self._nameLabel:getPosition())
  self._nameLabel:setPosition(ccp(namePos.x+300,namePos.y))
  self._nameLabel:runAction(CCMoveBy:create(0.2,ccp(-300,0)))
  self._knight:setVisible(false)

  -- local resId = roleId[self._id]
  local resId = knight_info.get(self._id).res_id
  local knightPos = self:getOffset(self._id)
  local worldPos = self._knight:getParent():convertToWorldSpace(knightPos)
  local jumpKnight = JumpBackCard.create()
  local start = ccp(worldPos.x-500,worldPos.y)
  self._knight:getParent():addNode(jumpKnight)
  -- jumpKnight:play(resId, start, 0.5, worldPos, self._knight:getScale(), function() 
  --     jumpKnight:removeFromParentAndCleanup(true)
  --     self._knight:setVisible(true)
  --     self._playing = false
  --     self:enableTab(true)
  --     G_SoundManager:playSound(knight_info.get(self._id).common_sound)
  -- end )
  self._knightjump = EffectNode.new(self.name, 
      function(event, frameIndex)
          if event == "finish" then
       
          end
      end
  )
  -- self._knightjump:setPosition(ccp(0,160))
  self._knightjump:play()
  jumpKnight:playWithKnight(self._knightjump, start, 0.5, worldPos, self._knight:getScale(), function() 
      jumpKnight:removeFromParentAndCleanup(true)
      self:getWidgetByName("Panel_zhezhao"):setTouchEnabled(false)
      self._knight:setVisible(true)
      self._playing = false
      self:enableTab(true)
      G_SoundManager:playSound(knight_info.get(self._id).common_sound)
  end )
end

function CreateRoleLayer:getOffset(id)
    local pos = ccp(0,0)
    if id == 1 then
      pos = ccp(60,-80)
    else
      pos = ccp(-60,-80)
    end
    return pos
end

function CreateRoleLayer:enableTab(able)
  self:getPanelByName("Panel_able"):setVisible(not able)
end

return CreateRoleLayer
