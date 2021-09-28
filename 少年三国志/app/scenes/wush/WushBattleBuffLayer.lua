
local WushBattleBuffLayer = class ("WushBattleBuffLayer", UFCCSNormalLayer)
require("app.cfg.dead_battle_info")
local BattleConst = require("app.const.BattleConst")

function WushBattleBuffLayer.create(battleField )   
    return WushBattleBuffLayer.new("ui_layout/wush_battleBuff.json", battleField) 
end

function WushBattleBuffLayer:ctor(json, battleField, ... )
    self.super.ctor(self, ...)
    self._buffdes1 = self:getLabelByName("Label_buffdes1")
    self._buffdes2 = self:getLabelByName("Label_buffdes2")
    self._buffvalue2 = self:getLabelByName("Label_buffvalue2")

if BattleConst.SHOW_HP_DETAIL == true then
    self._battleField = battleField
    self._totalHP = self._battleField:getKnightTotalHP(1)
    local label = ui.newTTFLabel({
        text = string.format("%d/%d", self._totalHP, self._totalHP),
        font = "ui/font/FZYiHei-M20S.ttf",
        size = 32,
        align = ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
    })

    self:addChild(label)
    label:setColor(Colors.uiColors.YELLOW)
    label:setAnchorPoint(ccp(0, 0))

    local alignPanel = self:getPanelByName("Panel_buff")
    local alignPosX, alignPosY = alignPanel:getPosition()
    label:setPosition(ccp(alignPosX, alignPosY + alignPanel:getContentSize().height))
    label:createStroke(Colors.strokeBrown, 2)
    self._debugHpLabel = label
end
end

function WushBattleBuffLayer:initData( floor )
   self._floor = floor
   local info = dead_battle_info.get(floor)
   self._type = info.success_type
   self._buffdes1:setText(info.success_directions)
   if self._type > 0 then
      self:getPanelByName("Panel_buff"):setVisible(true)
      self._buffdes2:setText(G_lang:get("LANG_WUSH_FIGHT"..self._type))
      self._buffvalue2:setText(0)
   else
      self:getPanelByName("Panel_buff"):setVisible(false) 
   end
   
end

function WushBattleBuffLayer:updateRound( round )
  if self._type == 1 then
    self._buffvalue2:setText(round)
  end
end

function WushBattleBuffLayer:updateSelfDead( dead )
  if self._type == 2 then
    self._buffvalue2:setText(dead)
  end
end

function WushBattleBuffLayer:updateSelfHp( hp )
  if self._type == 3 then
    self._buffvalue2:setText(hp)
  end

  if BattleConst.SHOW_HP_DETAIL == true then
      self._debugHpLabel:setString(string.format("%d/%d", self._battleField:getKnightCurrentHP(1), self._totalHP))
  end
end

function WushBattleBuffLayer:updateEnemyHp( hp )
  if self._type == 4 then
    self._buffvalue2:setText(hp)
  end
end

return WushBattleBuffLayer
