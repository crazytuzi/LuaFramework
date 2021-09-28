
local EffectNode = require "app.common.effects.EffectNode"

local ItemConst = require("app.const.ItemConst")
local Colors = require("app.setting.Colors")
local EquipmentInfo = require("app.scenes.equipment.EquipmentInfo")
local TreasureRefineCailiaoCell = require("app.scenes.treasure.cell.TreasureRefineCailiaoCell")

local TreasureStrengthLayer = class("TreasureStrengthLayer",UFCCSNormalLayer)

require("app.cfg.treasure_advance_info")

function TreasureStrengthLayer.create(...)
    return require("app.scenes.treasure.develope.TreasureStrengthLayer").new("ui_layout/treasure_TreasureStrengthLayer.json", ...)
end


function TreasureStrengthLayer:ctor(...)  
    self._treasureStrengthTargetId = 0
    self._wearPosId = 0
    self._moveStart = false
    self._moveStartList = {0,0,0,0,0,}
    self.super.ctor(self,...)
    self._effect  =nil
    self._playing = false
    self._isPlayingAnimation = false
    self._selectedTreasures = {}
    self._removed = {0,0,0,0,0}
    self._acquireExp = 0
    self._mainKnightEffect = nil
    self._basePos = {}

    for i = 1 , 5 do 
      local position = ccp(self:getImageViewByName("ImageView_baowu"..i):getPosition())
      table.insert(self._basePos,#self._basePos+1,position)
    end
    local position = ccp(self:getImageViewByName("ImageView_baowu"):getPosition())
    table.insert(self._basePos,#self._basePos+1,position)

    self:_treasureMove("ImageView_baowu",true,self._basePos[6])

    -- for i = 1 , 5 do 
    --     local rnd = math.random(0, 1000)/1000
    --     self:_treasureMove("ImageView_baowu"..i,true,self._basePos[i],rnd)
    -- end
end

-- function TreasureStrengthLayer:onLayerEnter( ... )
--     -- uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TREASURE_STRENGTH, self._onStrengthResult, self)
-- end

-- function TreasureStrengthLayer:onLayerExit( ... )
--     uf_eventManager:removeListenerWithTarget(self)
-- end

function TreasureStrengthLayer:setEquipment(equipment)
    self._equipment = equipment 

    if equipment then 
        local inLiueupId = equipment:getWearingKnightId()
        if inLiueupId > 0 then 
            local teamId, posId = G_Me.formationData:getKnightPosInTeam(inLiueupId)
            if teamId == 1 and posId > 0 then 
                self._wearPosId = posId
                self._treasureStrengthTargetId = G_Me.formationData:getKnightTreasureTarget(true, posId)

                __Log("self._treasureStrengthTargetId:%d,", 
                    self._treasureStrengthTargetId)
            end
        end
    end
end

function TreasureStrengthLayer:onTreasureStrength( ... )
    if self._wearPosId < 1 then 
        return 
    end

    local treasureStrengthTarget, targetLevel = G_Me.formationData:getKnightTreasureTarget(true, self._wearPosId)
    if treasureStrengthTarget <= self._treasureStrengthTargetId then 
        return 
    end

    self._treasureStrengthTargetId = treasureStrengthTarget
    local desc = G_lang:get("LANG_KNIGHT_TARGET_ATTRI_CHANGE_TIP", {targetName = G_lang:get("LANG_KNIGHT_TREASURE_STRENGTH_TARGET_NAME"), targeLevel = treasureStrengthTarget})
    G_flyAttribute.doAddRichtext(desc, nil, nil, nil, nil)

    local targetRecord = team_target_info.get(2, targetLevel)
    if targetRecord then 
        if targetRecord.att_type_1 > 0 then
            local curTargetDesc = G_lang.getGrowthTypeName(
                targetRecord.att_type_1).."+"..G_lang.getGrowthValue(
                targetRecord.att_type_1, targetRecord.att_value_1)
            G_flyAttribute.addNormalText(curTargetDesc, Colors.titleGreen)
        end
        if targetRecord.att_type_2 > 0 then
            local curTargetDesc = G_lang.getGrowthTypeName(
                targetRecord.att_type_2).."+"..G_lang.getGrowthValue(
                targetRecord.att_type_2, targetRecord.att_value_2)
            G_flyAttribute.addNormalText(curTargetDesc, Colors.titleGreen)
        end
        if targetRecord.att_type_3 > 0 then
            local curTargetDesc = G_lang.getGrowthTypeName(
                targetRecord.att_type_3).."+"..G_lang.getGrowthValue(
                targetRecord.att_type_3, targetRecord.att_value_3)
            G_flyAttribute.addNormalText(curTargetDesc, Colors.titleGreen)
        end
    end
end

function TreasureStrengthLayer:onBackKeyEvent( ... )
    uf_sceneManager:popSceneWithName("app.scenes.treasure.TreasureMainScene")

    return true
end

--初始化
function TreasureStrengthLayer:onLayerLoad( )
    self:registerBtnClickEvent("Button_qianghua", function()
        self:_goqianghuaCheck()
    end)

    self:registerBtnClickEvent("Button_zidong", function()
        self:_addAuto()
    end)

    self:registerWidgetClickEvent("ImageView_baowu", function()
        self:onBackKeyEvent()
    end)

    for i = 1,5 do 
      self:regisgerWidgetTouchEvent("ImageView_baowu"..i, function ( widget, param )
          if param == TOUCH_EVENT_ENDED then -- 点击事件
              self:_onChangeHero()
          end
      end)
      self:registerBtnClickEvent("Button_jiahao"..i,function ()
            self:_onChangeHero()
      end)
      self:registerWidgetClickEvent("Image_close"..i,function ()
            self:_onRemoveTreasure(i)
      end)
    end

    -- self:adapterWidgetHeight("Panel_baowu", "Panel_return", "Panel_detail", 0, 0)

    -- self:getLabelByName("Label_baowu"):createStroke(Colors.strokeBrown,1)
    -- self:getLabelByName("Label_jindu"):createStroke(Colors.strokeBrown,1)
    self:enableLabelStroke("Label_baowu", Colors.strokeBlack, 2 )
    self:enableLabelStroke("Label_jindu", Colors.strokeBlack, 1 )

    self:_blurWidget("Button_jiahao1", true, 2.5)
    self:_blurWidget("Button_jiahao2", true, 2.5)
    self:_blurWidget("Button_jiahao3", true, 2.5)
    self:_blurWidget("Button_jiahao4", true, 2.5)
    self:_blurWidget("Button_jiahao5", true, 2.5)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TREASURE_STRENGTH, self._onStrengthResult, self)

end


--强化宝物的协议函数:         G_HandlersManager.treasureHandler:sendUpgradeTreasure(宝物ID,  消耗的材料宝物的ID LIST)


-- 更新视图
function TreasureStrengthLayer:updateView()

    local info = self._equipment:getInfo()

    self._removed = {0,0,0,0,0}

   --大图
   self:getImageViewByName("ImageView_baowu"):setVisible(true)
   self:getImageViewByName("ImageView_baowu"):loadTexture(self._equipment:getPic())

   --名字
   self:getLabelByName("Label_baowu"):setColor(Colors.getColor(info.quality))
   self:getLabelByName("Label_baowu"):setText(info.name)

   -- 宝物等级
   self:getLabelByName("Label_dengji"):setText(  self._equipment.level..G_lang:get("LANG_TREASURE_DENGJI"))
   self:getLabelByName("Label_dengjiplus"):setText(  "+"..(self:_getNextLevel() - self._equipment.level))
   -- self:getLabelByName("Label_dengji"):createStroke(Colors.strokeBrown, 1)
   -- self:getLabelByName("Label_dengjiplus"):createStroke(Colors.strokeBrown, 1)
   if self:_getNextLevel() - self._equipment.level <= 0 then
    self:getLabelByName("Label_dengjiplus"):setVisible(false)
  else
    self:getLabelByName("Label_dengjiplus"):setVisible(true)
    self:_blurTreasureAttri("Label_dengjiplus",true)
  end

    -- 宝物属性
   local attrs = self._equipment:getStrengthAttrs()
   local attrsnext = self._equipment:getStrengthAttrs(self:_getNextLevel())

   self:getLabelByName("Label_shuxing1"):setText(attrs[1].typeString)
   self:getLabelByName("Label_shuxing2"):setText(attrs[2].typeString)
   self:getLabelByName("Label_shuxingzhi1"):setText("+"..G_lang.getGrowthValue(attrs[1].type, attrs[1].value))
   self:getLabelByName("Label_shuxingzhi2"):setText("+"..G_lang.getGrowthValue(attrs[2].type, attrs[2].value))

   self:getLabelByName("Label_shuxingzhiplus1"):setText("+"..(G_lang.getGrowthValue(attrs[1].type, attrsnext[1].value-attrs[1].value)))
   self:getLabelByName("Label_shuxingzhiplus2"):setText("+"..(G_lang.getGrowthValue(attrs[2].type, attrsnext[2].value-attrs[2].value)))

   -- self:getLabelByName("Label_lv"):createStroke(Colors.strokeBrown, 1)
   -- self:getLabelByName("Label_shuxing1"):createStroke(Colors.strokeBrown, 1)
   -- self:getLabelByName("Label_shuxing2"):createStroke(Colors.strokeBrown, 1)
   -- self:getLabelByName("Label_shuxingzhi1"):createStroke(Colors.strokeBrown, 1)
   -- self:getLabelByName("Label_shuxingzhi2"):createStroke(Colors.strokeBrown, 1)
   -- self:getLabelByName("Label_shuxingzhiplus1"):createStroke(Colors.strokeBrown, 1)
   -- self:getLabelByName("Label_shuxingzhiplus2"):createStroke(Colors.strokeBrown, 1)

   if attrsnext[1].value-attrs[1].value <= 0 then 
    self:getLabelByName("Label_shuxingzhiplus1"):setVisible(false)
    else
      self:getLabelByName("Label_shuxingzhiplus1"):setVisible(true)
      self:_blurTreasureAttri("Label_shuxingzhiplus1",true)
  end
   if attrsnext[2].value-attrs[2].value <= 0 then 
    self:getLabelByName("Label_shuxingzhiplus2"):setVisible(false)
    else
      self:getLabelByName("Label_shuxingzhiplus2"):setVisible(true)
      self:_blurTreasureAttri("Label_shuxingzhiplus2",true)
  end

  -- 强化所需金钱
  if self:getNextMoney() > G_Me.userData.money then
    self:getLabelByName("Label_cost"):setColor(Colors.lightColors.TIPS_01)
  else
    self:getLabelByName("Label_cost"):setColor(Colors.lightColors.DESCRIPTION)
  end
  self:getLabelByName("Label_cost"):setText(self:getNextMoney())
  -- self:getLabelByName("Label_cost"):createStroke(Colors.strokeBrown, 1)

  -- self:getLabelByName("Label_costtext"):setText(G_lang:get("LANG_JING_LIAN_MONEY_COST"))
  
  local totalExp = self._equipment:getStrengthNextLevelExp()
  local curExp = self._equipment:getLeftStrengthExp()
  if self._equipment.level == self._equipment:getMaxStrengthLevel() then
    totalExp = self._equipment:getStrengthNextLevelExp(self._equipment.level - 1)
    curExp = totalExp
  end
  self._beforeLevel = self._equipment.level
  -- 经验进度
  self:getLabelByName("Label_jindu"):setText(curExp.."/"..totalExp)
  self:_setProgessBar()

  --这里更新素材卡片
  for i = 1, 5 do
    self:getImageViewByName("ImageView_baowu"..i):setVisible(false)
    self:getImageViewByName("ImageView_baowu"..i):setOpacity(255)
    self:getWidgetByName("Image_border_"..i):setVisible(false)
    -- self:getImageViewByName("ImageView_faguang"..i):setVisible(false)
    self:getButtonByName("Button_jiahao"..i):setVisible(true)
  end

    local widget = self:getWidgetByName("ImageView_dizuo") 
    if widget and self._mainKnightEffect == nil then
      self._mainKnightEffect = EffectNode.new("effect_dipan", 
            function(event)
            end)
      widget:addNode(self._mainKnightEffect)
      self._mainKnightEffect:stop()
      self._mainKnightEffect:setPosition(ccp(0, 8))
    end

    if #self._selectedTreasures > 0 then 
      self._mainKnightEffect:play()
    else
      self._mainKnightEffect:stop()
    end

  -- for i = 1, #self._selectedTreasures do
  --   self:getImageViewByName("ImageView_baowu"..i):setVisible(true)
  --   -- self:getImageViewByName("ImageView_faguang"..i):setVisible(true)
  --   self:getButtonByName("Button_jiahao"..i):setVisible(false)

  --   self:getImageViewByName("ImageView_baowu"..i):loadTexture(self._selectedTreasures[i]:getPic())

  --   self:_brighterTreasureLine(i)

  -- end
    self:_updateHero()
  

end

-- function TreasureStrengthLayer:_startMove( )
  -- if self._moveStart then
  --   return
  -- end
  -- print("_startMove")
  -- self._moveStart = true
  -- for i = 1 , 5 do 
  --   if i <= #self._selectedTreasures and self._moveStartList[i] == 0 then
  --     self._moveStartList[i] = 1
  --     local rnd = math.random(0, 1000)/1000
  --     self:_treasureMove("ImageView_baowu"..i,true,self._basePos[i],rnd)
  --   end
  -- end

  -- self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.0),CCCallFunc:create(function()
  --   for i = 1 , 5 do 
  --     if i <= #self._selectedTreasures then
  --       local rnd = math.random(0, 1000)/1000
  --       self:_treasureMove("ImageView_baowu"..i,true,self._basePos[i],rnd)
  --     end
  --   end
  -- end)))
-- end

-- function TreasureStrengthLayer:_endMove( )
-- print("endmove")
--   self._moveStart = false
--   for i = 1 , 5 do 
--     self:getImageViewByName("ImageView_baowu"..i):stopAllActions()
--   end
-- end

function TreasureStrengthLayer:_treasureMove( imgName, blur ,basePos,delay)
  -- print("_treasureMove "..imgName)
  delay = delay or 0
  -- delay = 0
  if not imgName then
    return 
  end
  local imgCtrl = self:getWidgetByName(imgName)
  if not imgCtrl then
    return 
  end
  if not basePos then
    basePos = ccp(imgCtrl:getPosition())
  end

  blur = blur or false

  local time = 1.0
  local offset = 10

  if blur then
    imgCtrl:setPosition(basePos)
    -- imgCtrl:stopAllActions()
    local delayAnime = nil
    if delay > 0 then
      delayAnime = CCDelayTime:create(delay)
    end
    local anime1 = CCMoveBy:create(time,ccp(0,offset))
    local anime2 = CCMoveBy:create(time,ccp(0,-offset))
    local seqAction = CCSequence:createWithTwoActions(anime1, anime2)
    seqAction = CCRepeatForever:create(seqAction)
    if delayAnime then
      imgCtrl:runAction(CCSequence:createWithTwoActions(delayAnime, CCCallFunc:create(function()
          local anime1 = CCMoveBy:create(time,ccp(0,offset))
          local anime2 = CCMoveBy:create(time,ccp(0,-offset))
          local seqAction = CCSequence:createWithTwoActions(anime1, anime2)
          seqAction = CCRepeatForever:create(seqAction)
          imgCtrl:runAction(seqAction)
        end)))
    else
      imgCtrl:runAction(seqAction)
    end
  else
    imgCtrl:setPosition(basePos)
    imgCtrl:stopAllActions()
  end
end

function TreasureStrengthLayer:_setExp(  )
   -- 宝物等级
   self:getLabelByName("Label_dengji"):setText(  self._equipment.level..G_lang:get("LANG_TREASURE_DENGJI"))
   self:getLabelByName("Label_dengjiplus"):setText(  "+"..(self:_getNextLevel() - self._equipment.level))
   -- self:getLabelByName("Label_dengji"):createStroke(Colors.strokeBrown, 1)
   -- self:getLabelByName("Label_dengjiplus"):createStroke(Colors.strokeBrown, 1)
   if self:_getNextLevel() - self._equipment.level <= 0 then
    self:getLabelByName("Label_dengjiplus"):setVisible(false)
  else
    self:getLabelByName("Label_dengjiplus"):setVisible(true)
    self:_blurTreasureAttri("Label_dengjiplus",true)
  end

    -- 宝物属性
   local attrs = self._equipment:getStrengthAttrs()
   local attrsnext = self._equipment:getStrengthAttrs(self:_getNextLevel())

   self:getLabelByName("Label_shuxing1"):setText(attrs[1].typeString)
   self:getLabelByName("Label_shuxing2"):setText(attrs[2].typeString)
   self:getLabelByName("Label_shuxingzhi1"):setText("+"..G_lang.getGrowthValue(attrs[1].type, attrs[1].value))
   self:getLabelByName("Label_shuxingzhi2"):setText("+"..G_lang.getGrowthValue(attrs[2].type, attrs[2].value))

   self:getLabelByName("Label_shuxingzhiplus1"):setText("+"..(G_lang.getGrowthValue(attrs[1].type, attrsnext[1].value-attrs[1].value)))
   self:getLabelByName("Label_shuxingzhiplus2"):setText("+"..(G_lang.getGrowthValue(attrs[2].type, attrsnext[2].value-attrs[2].value)))

   -- self:getLabelByName("Label_lv"):createStroke(Colors.strokeBrown, 1)
   -- self:getLabelByName("Label_shuxing1"):createStroke(Colors.strokeBrown, 1)
   -- self:getLabelByName("Label_shuxing2"):createStroke(Colors.strokeBrown, 1)
   -- self:getLabelByName("Label_shuxingzhi1"):createStroke(Colors.strokeBrown, 1)
   -- self:getLabelByName("Label_shuxingzhi2"):createStroke(Colors.strokeBrown, 1)
   -- self:getLabelByName("Label_shuxingzhiplus1"):createStroke(Colors.strokeBrown, 1)
   -- self:getLabelByName("Label_shuxingzhiplus2"):createStroke(Colors.strokeBrown, 1)

   if attrsnext[1].value-attrs[1].value <= 0 then 
    self:getLabelByName("Label_shuxingzhiplus1"):setVisible(false)
    else
      self:getLabelByName("Label_shuxingzhiplus1"):setVisible(true)
      self:_blurTreasureAttri("Label_shuxingzhiplus1",true)
  end
   if attrsnext[2].value-attrs[2].value <= 0 then 
    self:getLabelByName("Label_shuxingzhiplus2"):setVisible(false)
    else
      self:getLabelByName("Label_shuxingzhiplus2"):setVisible(true)
      self:_blurTreasureAttri("Label_shuxingzhiplus2",true)
  end

  -- 强化所需金钱
  if self:getNextMoney() > G_Me.userData.money then
    self:getLabelByName("Label_cost"):setColor(Colors.lightColors.TIPS_01)
  else
    self:getLabelByName("Label_cost"):setColor(Colors.lightColors.DESCRIPTION)
  end
  self:getLabelByName("Label_cost"):setText(self:getNextMoney())
  -- self:getLabelByName("Label_cost"):createStroke(Colors.strokeBrown, 1)

  -- self:getLabelByName("Label_costtext"):setText(G_lang:get("LANG_JING_LIAN_MONEY_COST"))
  
  local totalExp = self._equipment:getStrengthNextLevelExp()
  local curExp = self._equipment:getLeftStrengthExp()
  if self._equipment.level == self._equipment:getMaxStrengthLevel() then
    totalExp = self._equipment:getStrengthNextLevelExp(self._equipment.level - 1)
    curExp = totalExp
  end
  self._beforeLevel = self._equipment.level
  -- 经验进度
  self:getLabelByName("Label_jindu"):setText(curExp.."/"..totalExp)
  self:_setProgessBar()
end

function TreasureStrengthLayer:_onRemoveTreasure( index )
  index = index or 0
  if not self._selectedTreasures or #self._selectedTreasures < 1 then 
    return 
  end

  if index < 1 or index > #self._selectedTreasures then 
    return 
  end

  self._removed[index] = 1

  self._acquireExp = self._acquireExp - self._selectedTreasures[index]:getSupplyExp()
  self:_setExp()

  self:getImageViewByName("ImageView_baowu"..index):setVisible(false)
  self:getWidgetByName("Image_border_"..index):setVisible(false)
  self:getButtonByName("Button_jiahao"..index):setVisible(true)

  self:getWidgetByName("ImageView_dizuo"..index):removeAllNodes()

  local shouldStopMainKnightEffect = true
  for key, value in pairs(self._selectedTreasures) do 
    if shouldStopMainKnightEffect and self._removed[key] == 0 then 
      shouldStopMainKnightEffect = false
    end
  end

  if shouldStopMainKnightEffect and self._mainKnightEffect then 
    self._mainKnightEffect:stop()
  end

end

function TreasureStrengthLayer:_updateHero()
-- print("_updateHero")
-- self:_endMove( )
    local addTreasureToBorder = function ( treasure, index, delay, time, func )
      local callback = function ( ... )
        if func then 
          func()
        end
      end
      
      -- if not image then 
      --   return callback()
      -- end

      local backBoard = nil 
      local line = nil
      local dizuo = nil
      local image = nil
      local nameLabel = nil
      index = index or -1
      if index >= 0 then 
        backBoard = self:getWidgetByName("Image_border_"..index)
        line = self:getWidgetByName("ImageView_bufaguang"..index)
        dizuo = self:getWidgetByName("ImageView_dizuo"..index)
        image = self:getWidgetByName("ImageView_baowu"..index)
        nameLabel = self:getLabelByName("Label_name"..index)
      else
        return callback()
      end
      -- local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(knightId or 0)
      if backBoard then 
        backBoard:setVisible(false)
        backBoard:removeAllNodes()
      end
      -- panel:removeAllChildren()
      -- if dizuo then 
      --   dizuo:removeAllNodes()
      -- end

      self:showWidgetByName("Button_jiahao"..index, treasure == nil)
      if treasure == nil then 
        return callback()
      end

      local showBorderAndLineEffect = function ( border, line, di,func )
        if border then 
          border:setVisible(true)
          border:runAction(CCFadeIn:create(0.2))
        end

        if di and line then 
          local localPos = line:convertToWorldSpace(ccp(0, 0))
          localPos = di:convertToNodeSpace(localPos)
          local cao = EffectNode.new("effect_lancao")
          if cao then
            di:addNode(cao, -1, 1001)
            cao:setRotation(line:getRotation())
            cao:play()
            cao:setScaleX(0.1)
            cao:setPosition(localPos)
            cao:runAction(CCScaleTo:create(0.2, 2, 1))
          end
        end
        if func then
          border:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.2),CCCallFunc:create(function()
            func()
          end)))
        end
      end

      -- local effect0 = backBoard and backBoard:getNodeByTag(1001)
      -- if effect0 then 
      --   backBoard:removeNode(effect0)
      -- end
          local effect = EffectNode.new("effect_dipan", 
                function(event)
                end)
            backBoard:addNode(effect, 1, 1001)
            effect:play()
            effect:setPosition(ccp(0, 8))
            -- effect:setScale(dizuo:getScale()*5.5)
      -- local knightInfo = knight_info.get(baseId)
      -- local resId = knightInfo["res_id"]
      

      -- local knightBtn = knightPic.createKnightButton(resId, panel, "knight_button_"..index, self, function ( widget )
      --     self:_onChangeHero( index, widget, self._mainKnightId )
      --   end, true)
      image:loadTexture(treasure:getPic())
      local trInfo = treasure:getInfo()
      local name = trInfo.name
      if treasure.refining_level > 0 then
        name = name.." + "..treasure.refining_level
      end
      nameLabel:setText(name)
      nameLabel:setColor(Colors.qualityColors[trInfo.quality])
      nameLabel:createStroke(Colors.strokeBrown,1)
      if treasure then 
        image:setTag(1000)
        --knightBtn:setScale(0.8)
        local posx, posy = image:getPosition()
        local arr = CCArray:create()
        image:setPosition(ccp(posx, posy + 100))
        if delay > -1 then 
          image:setVisible(false)       
          arr:addObject(CCDelayTime:create(delay))
          arr:addObject(CCCallFunc:create(function ( ... )
            image:setVisible(true)
          end))
        end
        --local spawn = CCSpawn:createWithTwoActions(, CCScaleTo:create(time, 1))
        arr:addObject(CCEaseIn:create(CCMoveBy:create(time, ccp(0, -100)), time))
        arr:addObject(CCCallFunc:create(function (  )
              showBorderAndLineEffect(backBoard, line, backBoard,callback)
              -- callback()
          end))

        image:runAction(CCSequence:create(arr))
      end
    end
    
    self._isPlayingAnimation = true
    for index = 1, 5 do 
      local treasure = nil
      if index <= #self._selectedTreasures then
       treasure = self._selectedTreasures[index]
     end
      addTreasureToBorder(treasure, index, 0, 0.15, index == 5 and function ( ... )
        self._isPlayingAnimation = false
        -- local rnd = math.random(0, 1)
        -- self:_treasureMove("ImageView_baowu"..index,true,self._basePos[index],rnd)
        -- self:_startMove( )
      end or nil )
    end
    -- table.foreach(self._selectedTreasures, function ( index, panel )
    --   local treasure = self._selectedTreasures[index]
    --   addTreasureToBorder(treasure, index, (index - 1) * 0.2, 0.3, index == #self._selectedTreasures and function ( ... )
    --     self._isPlayingAnimation = false
    --   end or nil )
    -- end)
  -- self:_startMove( )
end

-- 检查强化条件
function TreasureStrengthLayer:_goqianghuaCheck()
  -- 正在播放动画
  if self._isPlayingAnimation then
    return
  end
  -- 没有选素材
  if #self._selectedTreasures == 0 then
    G_MovingTip:showMovingTip(G_lang:get("LANG_ADD_NONE"))
    return
  end
  -- 金币不足
  if self:getNextMoney() > G_Me.userData.money then
    -- G_MovingTip:showMovingTip(G_lang:get("LANG_STRENGTH_MONEY_NOTENOUGH"))
    require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_MONEY, 0,
        GlobalFunc.sceneToPack("app.scenes.treasure.TreasureDevelopeScene", {self._equipment,1}))
    return
  end

  -- 素材有稀有宝物
  local hasRarelyTreasure = false
  for key, value in pairs(self._selectedTreasures) do 
          local treasureBaseInfo = value:getInfo()
          if treasureBaseInfo and treasureBaseInfo.quality >= 4 and treasureBaseInfo.type ~= 3 then
             hasRarelyTreasure = true
          end
  end
  if hasRarelyTreasure then
      MessageBoxEx.showYesNoMessage(nil, 
                  G_lang:get("LANG_STRENGTH_HAS_HIGH_LEVEL_CAILIAO"), false, 
                  function ( ... )
                      self:_goqianghuaCheckNext()
                  end)
      return 
  end   
  self:_goqianghuaCheckNext()
end

-- 检查强化经验是否超出
function TreasureStrengthLayer:_goqianghuaCheckNext()
  if self._acquireExp > self._equipment:getStrengthLeftExp() then
      local messageBox = require("app.scenes.treasure.TreasureExpMessage")
      messageBox.showYesNoMessage(nil, self._equipment:getStrengthLeftExp() ,self._acquireExp, 
                  G_lang:get("LANG_STREAGTH_TOOMUCH"), false, 
                  function ( ... )
                      self:_goStrength()
                  end)
      return false
  end
  self:_goStrength()
end

function TreasureStrengthLayer:_goStrength()
  self._tostartLevel = self._equipment.level
  G_HandlersManager.treasureHandler:sendUpgradeTreasure(self._equipment.id,  self:_getIdList())
end

-- 检查自动添加的条件
function TreasureStrengthLayer:_autoCheck(fitList)
  if #fitList == 0 then
    G_MovingTip:showMovingTip(G_lang:get("LANG_AUTOADD_NONE"))
    return false
  end
  return true
end

-- 点击事件处理
function TreasureStrengthLayer:_onChangeHero( index, widget )
    -- 正在播放动画
    if self._isPlayingAnimation then
      return
    end

    if self._equipment.level == self._equipment:getMaxStrengthLevel() then 
      G_MovingTip:showMovingTip(G_lang:get("LANG_STRENGTH_HAS_FULL_LEVEL"))
      return
    end

    local treasureList = self:_getTreasureList()

    local addTreasure = {}
    for key, value in pairs(self._selectedTreasures) do 
      if self._removed[key] == 0 then
        table.insert(addTreasure, #addTreasure + 1, value)
      end
    end

    -- 弹出选择材料列表
    local TreasureStrengthChoose = require("app.scenes.treasure.develope.TreasureStrengthChoose")
    TreasureStrengthChoose.showTreasureChooseLayer( uf_notifyLayer:getModelNode(), treasureList, addTreasure,
     self._equipment, function ( treasures, acquireExp )
      self:_onSelectedHeros( treasures, acquireExp )
    end)
end

-- 自动添加
function TreasureStrengthLayer:_addAuto()
  -- 正在播放动画
  if self._isPlayingAnimation then
    return
  end

  if self._equipment.level == self._equipment:getMaxStrengthLevel() then 
    G_MovingTip:showMovingTip(G_lang:get("LANG_STRENGTH_HAS_FULL_LEVEL"))
    return
  end

  local treasureList = self:_getTreasureList()
  local fitList = {}
  local totalExp = 0
  for key, value in pairs(treasureList) do 
    if value and (value:getInfo().quality < 4 or value:isForStrength()) and #fitList < 5 then
      table.insert(fitList, #fitList + 1, value)
      totalExp = totalExp + value:getSupplyExp()
    end
  end

  if self:_autoCheck(fitList) then 
    -- self._selectedTreasures = fitList
    -- self._acquireExp = totalExp
    -- self:updateView()
    self:_onSelectedHeros(fitList,totalExp)
  end
end

function TreasureStrengthLayer:_dataClear()
  self._selectedTreasures = {}
  self._acquireExp = 0
  self._removed = {0,0,0,0,0}
end

function TreasureStrengthLayer:_getIdList()
  local idList = {}
  for key, value in pairs(self._selectedTreasures) do 
    if self._removed[key] == 0 then
      table.insert(idList, #idList + 1, value.id)
    end
  end
  return idList
end

--排序,品质,强化等级
local sortMergeEquipmentFunc = function(a,b)
    local infoa = a:getInfo()
    local infob = b:getInfo()

    if infoa.quality ~= infob.quality then
        return infoa.quality < infob.quality
    end

    if a.level ~= b.level then
        return a.level < b.level
    end

    return a.id < b.id
end

-- 获取宝物列表
function TreasureStrengthLayer:_getTreasureList()

  local equiplist = G_Me.bagData:getTreasureListByRefine()
    local equipWearOn = G_Me.formationData:getAllFightTreasureList()
    local noWearEquipList = {}
    for key, value in pairs(equiplist) do 
      if value and not equipWearOn[value["id"]] and value.id ~= self._equipment.id and value.refining_level == 0 then
        table.insert(noWearEquipList, #noWearEquipList + 1, value)
      end
    end
   table.sort(noWearEquipList, sortMergeEquipmentFunc)
    return noWearEquipList
end


-- 设置进度条
function TreasureStrengthLayer:_setProgessBar()

  local progress = self:getLoadingBarByName("LoadingBar_exp")
    progress:loadModificationTexture("ui/yangcheng/yangcheng_yellow.png", false, UI_TEX_TYPE_LOCAL)

    local percent1 = self._equipment:getLeftStrengthExp() * 100 / self._equipment:getStrengthNextLevelExp()
    progress:setPercent(percent1)

    local percent2 = (self._acquireExp + self._equipment:getLeftStrengthExp() ) * 100 / self._equipment:getStrengthNextLevelExp()

    if percent2 > 0 then 
      progress:setModificationVisible(true)
      progress:blurModification(true)
    else
      progress:setModificationVisible(false)
      progress:blurModification(false)
   end

    if percent2 > 100 then 
        progress:setModificationPercent(100)
    else
        progress:setModificationPercent(percent2)
    end
end

-- function TreasureStrengthLayer:_playAttributeChange()
--   local progress = self:getLoadingBarByName("LoadingBar_exp")
--   if progress then
--     progress:runToPercent(self._upgradeLevel*100 + self._upgradePercent, 1.0)
--   end
-- end

-- 选择材料列表的回调
function TreasureStrengthLayer:_onSelectedHeros( selecteTreasures, acquireExp )
  self._selectedTreasures = selecteTreasures
  self._acquireExp = acquireExp
  if self._mainKnightEffect then
    if #selecteTreasures > 0 then 
      self._mainKnightEffect:play()
    else
      self._mainKnightEffect:stop()
    end
  end
  
  self:updateView()
end

function TreasureStrengthLayer:_brighterTreasureLine( index )
  if index < 1 or index > 5 then 
    return 
  end
  do 
    return 
  end
  local line = self:getWidgetByName("ImageView_faguang"..index)
  if not line then
    return 
  end

  line:setScaleX(0.1)

  local scale = CCScaleTo:create(0.5, 1, 1)
  scale = CCEaseIn:create(scale, 0.5)
  line:runAction(scale)
end

function TreasureStrengthLayer:_blurTreasureAttri( labelName, blur )
  if not labelName then
    return 
  end
  local labelCtrl = self:getWidgetByName(labelName)
  if not labelCtrl then
    return 
  end

  blur = blur or false

  if blur then
    labelCtrl:stopAllActions()
    local fadeInAction = CCFadeIn:create(0.5)
    local fadeOutAction = CCFadeOut:create(0.5)
    local seqAction = CCSequence:createWithTwoActions(fadeInAction, fadeOutAction)
    seqAction = CCRepeatForever:create(seqAction)
    labelCtrl:runAction(seqAction)
  else
    labelCtrl:stopAllActions()
  end
end

function TreasureStrengthLayer:_levelup(levelup)
  if levelup > 0 then
    self:getLabelByName("Label_levelAdd"):setText("+"..levelup)
    self:getWidgetByName("ImageView_level"):runAction(CCSequence:createWithTwoActions(CCFadeIn:create(0.5), CCFadeOut:create(0.5)))
    self:getLabelByName("Label_levelAdd"):runAction(CCSequence:createWithTwoActions(CCFadeIn:create(0.5), CCFadeOut:create(0.5)))
  else
    self:getWidgetByName("ImageView_success"):runAction(CCSequence:createWithTwoActions(CCFadeIn:create(0.5), CCFadeOut:create(0.5)))
  end

end

function TreasureStrengthLayer:_stopEffect()

    if self._effect  ~= nil then
        self._effect:stop()
        self._effect:removeFromParentAndCleanup(true)
        self._effect = nil    
        self._isPlayingAnimation = false
    end
end

function TreasureStrengthLayer:onUncheck()
    self:_stopEffect()
    self._playing = false
end

function TreasureStrengthLayer:_getNextLevel()
    local total = self._acquireExp + self._equipment:getLeftStrengthExp() - self._equipment:getStrengthNextLevelExp()
    local level = self._equipment.level
    while total >= 0 do 
      level = level + 1
      total = total - self._equipment:getStrengthNextLevelExp(level)
      -- 防止死循环
      if level > 100000 then 
        __LogError("呵呵，哪有这么高级的宝物")
        return level
      end
    end
    return math.min( level ,  self._equipment:getMaxStrengthLevel())
end

function TreasureStrengthLayer:getNextMoney()
    return self._equipment:getStrengthMoney(self._acquireExp)
end

function TreasureStrengthLayer:onLayerUnload()
    self:onUncheck()
    uf_eventManager:removeListenerWithTarget(self)

end

----------------------------------网络接收---------------------


function TreasureStrengthLayer:_onStrengthResult(data)    

    if data.ret == NetMsg_ERROR.RET_OK then

      self:_showJiaHao(false)
      -- self:_refresh()
      self:_playStrengthenAnimation(self._equipment.level - self._tostartLevel > 0, function ( ... )
        self:_strengthAnine()
        -- self._selectedTreasures = {}
        -- self:_refreshnext()
        -- self:updateView()
        end)  
    end
end

-- function TreasureStrengthLayer:_refresh() 

--   self._effect = EffectNode.new("effect_appear", 
--       function(event, frameIndex)
--           if event == "finish" then
              
--           end
--       end
--   )
--   self._effect:play()
--   self._isPlayingAnimation = true
--   self:getImageViewByName("ImageView_baowu"):addNode(self._effect)


--   self:_strengthAnime()

-- end

-- function TreasureStrengthLayer:_strengthAnime() 
  
--   for i = 1, #self._selectedTreasures do

--     self:_treasureAnime(self:getImageViewByName("ImageView_baowu"..i))

--   end

--   local seq = CCSequence:createWithTwoActions(CCDelayTime:create(1.5),
--     CCCallFunc:create(function (  )
--       self:_refreshnext()
--       self._effect:stop()
--       self._effect:removeFromParentAndCleanup(true)
--       self._effect = nil
--       self._isPlayingAnimation = false
--      end))
--   self:getImageViewByName("ImageView_baowu"):runAction(seq)

-- end

-- function TreasureStrengthLayer:_refreshnext() 
  
--   self:_dataClear()
--   self:updateView()
--   self:_levelup(self._equipment.level - self._tostartLevel)
--   G_playAttribute.playTreasureWithLevelOffset(self._equipment.id, self._tostartLevel)

  -- self._effect = EffectNode.new("effect_particle_star", 
  --     function(event, frameIndex)
  --         if event == "forever" then
  --             self:_stopEffect()
  --             -- finishEffect = true
  --             -- self:_flyAttr(attrsNext,finish_callback)
  --         elseif event == "baoji" then
  --             -- local node = require("app.scenes.equipment.tip.EquipmentRefineLevelTip").new()
  --             -- node:setPosition(display.cx, display.cy)
  --             -- node:playWithLevel(deltaLevel)
  --             -- uf_notifyLayer:getTipNode():addChild(node)   
  --         elseif event == "tip" then
                 
  --         end
  --     end
  -- )
  -- self._effect:setScale(5)
  -- self._effect:play()
  -- self:getImageViewByName("ImageView_baowu"):addNode(self._effect)

-- end

-- 吸入动画
function TreasureStrengthLayer:_treasureAnime(treasure) 
  
  -- local beginPos = ccp(treasure:getPosition())
  local beginPos = ccp(treasure:getPosition())
  local dust = self:getImageViewByName("ImageView_baowu")
  local dustpos = dust:getParent():convertToWorldSpace(ccp(dust:getPosition()))
  local start = treasure
  local startpos = start:getParent():convertToWorldSpace(ccp(start:getPosition()))

  local percent1 = 0.2
  local percent2 = 0.6
  local opac = 0.9
  local time1 = 1.0
  local time2 = 0.3

  local dust1 =  ccpMult(ccpSub(dustpos, startpos), percent1)
  local dust2 = ccpMult(ccpSub(dustpos, startpos),percent2)

  local anime1 = CCMoveBy:create(time1,dust1)
  local anime2 = CCMoveBy:create(time2,dust2)
  local seq1 = CCSequence:createWithTwoActions(anime1, anime2)

  local fade1 = CCFadeTo:create(time1, 255*opac)
  local fade2 = CCFadeTo:create(time2, 0)
  local seq2 = CCSequence:createWithTwoActions(fade1, fade2)
  
  local anime4 = CCScaleBy:create(time1,opac)
  local anime5 = CCScaleBy:create(time2,0)
  local seq3 = CCSequence:createWithTwoActions(anime4, anime5)

  local arr = CCArray:create()
  arr:addObject(seq1)
  arr:addObject(seq2)
  arr:addObject(seq3)
  local spawn = CCSpawn:create(arr)

  local arr2 = CCArray:create()
  arr2:addObject(spawn)
  arr2:addObject(CCDelayTime:create(0.1))
  arr2:addObject(CCCallFunc:create(function()
      treasure:setPosition(beginPos)
      treasure:setVisible(false)
      treasure:setOpacity(255)
      treasure:setScale(0.32)
     end))

  local seq3 = CCSequence:create(arr2)

  treasure:runAction(seq3)

end

-- 闪烁动画
function TreasureStrengthLayer:_blurWidget( labelName, blur, offset )
  if not labelName then
    return 
  end
  local labelCtrl = self:getWidgetByName(labelName)
  if not labelCtrl then
    return 
  end

  blur = blur or false
  offset = offset or 0.1

  if blur then
    labelCtrl:stopAllActions()
    local fadeInAction = CCFadeIn:create(offset)
    local fadeOutAction = CCFadeOut:create(offset)
    local seqAction = CCSequence:createWithTwoActions(fadeInAction, fadeOutAction)
    seqAction = CCRepeatForever:create(seqAction)
    labelCtrl:runAction(seqAction)
  else
    labelCtrl:stopAllActions()
    labelCtrl:setOpacity(255)
  end
end

function TreasureStrengthLayer:_playStrengthenAnimation( hasLevelup, func )
  -- self:_endMove( )
  hasLevelup = hasLevelup or false
  local eatTreasure = function ( treasure, index, time, func )
    if not treasure then 
      return 
    end

    -- backBoard = self:getWidgetByName("Image_border_"..index)
    -- line = self:getWidgetByName("ImageView_bufaguang"..index)
    -- dizuo = self:getWidgetByName("ImageView_dizuo"..index)
    -- image = self:getWidgetByName("ImageView_baowu"..index)

    local treasureSprite = self:getWidgetByName("ImageView_baowu"..index)
    if not treasureSprite then 
      return 
    end

    local backBoard = nil 
    local dizuo = nil
    index = index or -1
    if index >= 0 then 
      backBoard = self:getWidgetByName("Image_border_"..index)
      dizuo = self:getWidgetByName("ImageView_dizuo"..index)
    end

    local mainWidget = self:getWidgetByName("ImageView_dizuo")
    local mainPos = ccp(0, 0)
    if mainWidget then 
      mainPos = mainWidget:convertToWorldSpace(mainPos)
    end
    local eatBorderAndLineEffect = function ( dizuo, func, time )
      if dizuo then 
          local effect = dizuo and dizuo:getNodeByTag(1001)
          local localPos = dizuo:convertToNodeSpace(mainPos)
          if effect then 
            local spawn = CCSpawn:createWithTwoActions(CCMoveTo:create(time, localPos),
              CCScaleTo:create(time, 0.1, 1))

            local soundConst = require("app.const.SoundConst")
              G_SoundManager:playSound(soundConst.GameSound.KNIGHT_EAT_MATERIAL)

            effect:runAction(CCSequence:createWithTwoActions(CCEaseOut:create(spawn, time), 
              CCCallFunc:create(function ( ... )
                  dizuo:removeNode(effect)
                  --effect:removeFromParentAndCleanup(true)
                  if func then 
                    func()
                  end
                end)))
          else
            if func then 
              func()
            end
          end
      else
        if func then 
          func()
        end
      end     
    end

    if treasureSprite then 
      local arr1 = CCArray:create()
      arr1:addObject(CCFadeOut:create(time))
      arr1:addObject(CCMoveBy:create(time, ccp(0, -100)))
      arr1:addObject(CCScaleBy:create(time, 0.5))

      local spawn = CCSpawn:create(arr1)
      local arr = CCArray:create()
      arr:addObject(CCDelayTime:create(0.2))
      arr:addObject(CCEaseOut:create(spawn, time))
      arr:addObject(CCCallFunc:create(function (  )
            eatBorderAndLineEffect(dizuo, func, 0.2)
            treasureSprite:setVisible(false)
            local posx, posy = treasureSprite:getPosition()
            treasureSprite:setPosition(ccp(posx, posy + 100))
            treasureSprite:setScale(treasureSprite:getScale()*2)
        end))

      local effect = nil
      effect = EffectNode.new("effect_xiaoshi", 
          function(event)
              if event == "finish" and effect then
                  effect:removeFromParentAndCleanup(true)
              end
          end)
      treasureSprite:addNode(effect)
      effect:play()
      effect:setPosition(ccp(0, -150))
      treasureSprite:runAction(CCSequence:create(arr))
      backBoard:runAction(CCFadeOut:create(time))
    end
  end

  if #self._selectedTreasures < 1 then 
    return 
  end

  local wolunEffect = nil 
  local stopWolunEffect = function ( ... )
    if wolunEffect then
      wolunEffect:removeFromParentAndCleanup(true)
    end
  end

  local fangguangEffect = function ( knightNode, func )
    if not knightNode then 
      if func then
        func()
      end
      return 
    end

    local fangguang = nil 
    fangguang = EffectNode.new("effect_faguang2", 
        function(event)
            if event == "finish" and fangguang then 
                fangguang:removeFromParentAndCleanup(true)
                if func then 
              func()
            end
            end
        end)
    fangguang:play()
    fangguang:setScale(1.5)
    fangguang:setPosition(ccp(0, 75))
      knightNode:addNode(fangguang, 10)
  end 

  local mainBorder = self:getWidgetByName("ImageView_dizuo")
  if mainBorder then 
    wolunEffect = EffectNode.new("effect_wolun", function ( event )
      if event == "finish" and wolunEffect then 
        wolunEffect:removeFromParentAndCleanup(true)
      end
    end)
    wolunEffect:play()
    local border = self:getWidgetByName("Image_border_main")
    if border then 
      wolunEffect:setPosition(ccp(border:getPosition()))
    end
    mainBorder:addNode(wolunEffect)
  end

  local levelupEffect = function ( knightNode, func )
    if not knightNode then 
      if func then
        func()
      end
      return 
    end
    local levelup = nil 
    levelup = EffectNode.new("effect_qianghua_levelup", 
        function(event)
            if event == "finish" and levelup then
                levelup:removeFromParentAndCleanup(true)
                if func then 
              func()
            end
            end
        end)
      knightNode:addNode(levelup, 10)
      levelup:setPosition(ccp(-18, 30))
      levelup:setVisible(false)
      knightNode:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.4),
        CCCallFunc:create(function ( ... )
          levelup:setVisible(true)
          levelup:play()
        -- levelup:setScale(1.5)
        end)))
  end

  if #self._selectedTreasures < 1 then 
    return 
  end

  self._isPlayingAnimation = true
  for index = 1, 5 do 
    local treasure = nil
    if index <= #self._selectedTreasures then
     treasure = self._selectedTreasures[index]
   end
   eatTreasure(treasure, index,  0.3, (index == #self._selectedTreasures) and function ( ... )
     stopWolunEffect()
     local soundConst = require("app.const.SoundConst")
           G_SoundManager:playSound(soundConst.GameSound.KNIGHT_STRENGTH_UPGRADE)

     levelupEffect(mainBorder, function ( ... )
       if func then 
         func()
       end
       -- self._isPlayingAnimation = false
     end)
     -- fangguangEffect(mainBorder, function ( ... )
     --   if hasLevelup then 
     --     local soundConst = require("app.const.SoundConst")
     --           G_SoundManager:playSound(soundConst.GameSound.KNIGHT_STRENGTH_UPGRADE)

     --     levelupEffect(mainBorder, function ( ... )
     --       if func then 
     --         func()
     --       end
     --       -- self._isPlayingAnimation = false
     --     end)
     --   else
     --     if func then 
     --       func()
     --     end
     --     -- self._isPlayingAnimation = false
     --   end
     -- end)
   end or nil)
  end
end

function TreasureStrengthLayer:_strengthAnine( )

      local refineAni = function ( )
          if self._beforeLevel < self._equipment.level then

              self._playing = true

              local nextLevel = self._equipment.level

              local attrs = self._equipment:getStrengthAttrs(self._beforeLevel )
              local attrsNext = self._equipment:getStrengthAttrs(nextLevel)

              --属性变化:
              for i=1,#attrsNext do
                  attrsNext[i].delta = attrsNext[i].value - attrs[i].value
              end

              local finishEffect  = false
              local finish_callback = function()
                  if G_SceneObserver:getSceneName() ~= "TreasureDevelopeScene" then
                      return
                  end
                  if finishEffect then
                      self:_dataClear()
                      self:updateView()
                      self._isPlayingAnimation = false
                  end

              end


              -- self._effect = EffectNode.new("effect_particle_star", 
              --     function(event, frameIndex)
              --         if event == "forever" then
              --             self:_stopEffect()
              --             finishEffect = true
              --             self:_flyAttr(attrsNext,finish_callback) 
              --         end
              --     end
              -- )
              finishEffect = true
              self:_flyAttr(attrsNext,finish_callback) 


              -- self._effect:setScale(5)
              -- self._effect:play()
              -- self:getImageViewByName("ImageView_baowu"):addNode(self._effect)
          else
              self:_flyAttr(nil,function()
                      if G_SceneObserver:getSceneName() ~= "TreasureDevelopeScene" then
                          return
                      end
                      self:_dataClear()
                      self:updateView()
                      self._isPlayingAnimation = false
                  end)

          end
      end

      refineAni()

end

function TreasureStrengthLayer:_flyAttr( attrsNext,finish_callback)

    if self._acquireExp == 0 then 
      finish_callback()
      return
    end

    if not self or not self.isRunning or not self:isRunning() then 
        return 
    end
    
    self._isPlayingAnimation = true
    local deltaLevel = self._equipment.level - self._beforeLevel

      local progress = self:getLoadingBarByName("LoadingBar_exp")
      if progress then
        progress:runToPercent(deltaLevel*100 + self._equipment:getLeftStrengthExp() * 100 / self._equipment:getStrengthNextLevelExp(), 0.5)
        progress:setModificationVisible(false)
      end

      self:onTreasureStrength()
      
    if deltaLevel < 1 then
      
      G_flyAttribute.doAddRichtext(G_lang:get("LANG_TREASURE_STRENGTH_TIP_STRENGTH_SUCCESS", {addExp=self._acquireExp}), 30, nil, nil)
      G_flyAttribute.play(function ( ... )
          finish_callback()
      end)
      return
      end 

    G_flyAttribute.addNormalText(G_lang:get("LANG_KNIGHT_STRENGTH_TIP_STRENGTH_TO_LEVEL", {levelValue = self._equipment.level}), nil, self:getLabelByName("Label_dengji"), deltaLevel)


    --属性加成
    for i, attrInfo in ipairs(attrsNext) do 
        local labelName 
        if i == 1 then
            labelName = "Label_shuxingzhi1"
        elseif i==2 then
            labelName = "Label_shuxingzhi2"
        else
            break
        end
        --print("attr" .. i .. "," .. attrInfo.typeString  .. ":" .. attrInfo.delta)
        G_flyAttribute.addAttriChange(attrInfo.typeString, attrInfo.delta, self:getLabelByName(labelName))

    end
    attrsNext = {}

    G_flyAttribute.play(function ( ... )
        finish_callback()
    end)
end

function TreasureStrengthLayer:_showJiaHao( show)
    for i = 1, 5 do
      self:getButtonByName("Button_jiahao"..i):setVisible(show)
    end
end


return TreasureStrengthLayer