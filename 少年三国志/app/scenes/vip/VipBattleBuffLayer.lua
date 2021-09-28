
local VipBattleBuffLayer = class ("VipBattleBuffLayer", UFCCSNormalLayer)
require("app.cfg.dungeon_vip_info")

function VipBattleBuffLayer.create( )   
    return VipBattleBuffLayer.new("ui_layout/vip_battleBuff.json") 
end

function VipBattleBuffLayer:ctor( ... )
    self.super.ctor(self, ...)
    self._buffdes1 = self:getLabelByName("Label_buffdes1")
    self._buffvalue1 = self:getLabelByName("Label_buffvalue1")
    self._buffdes2 = self:getLabelByName("Label_buffdes2")
    self._buffvalue2 = self:getLabelByName("Label_buffvalue2")
    self._buffdes3 = self:getLabelByName("Label_buffdes3")
    self._buffvalue3 = self:getLabelByName("Label_buffvalue3")
    self._bgImage = self:getImageViewByName("Image_45")
    self._totalRound = 20
end

function VipBattleBuffLayer:initData( mapId )
   self._mapId = mapId
   self._type = dungeon_vip_info.get(mapId).type
   self._buffdes1:setText(G_lang:get("LANG_VIP_VIPDES1"))
   
   if self._type == 1 then
      self._buffdes1:setVisible(true)
      self._buffvalue1:setVisible(true)
      self._bgImage:setVisible(true)
      self._totalRound = 4
      self._buffdes2:setText(G_lang:get("LANG_VIP_VIPDES2"))
      self._buffvalue1:setText("0/"..self._totalRound)
      self._buffvalue2:setText(0)
   else
      self._buffdes1:setVisible(false)
      self._buffvalue1:setVisible(false)
      self._bgImage:setVisible(false)
      self._totalRound = 20
      self._buffdes2:setText(G_lang:get("LANG_VIP_VIPDES1"))
      self._buffvalue2:setText("0/"..self._totalRound)
   end

   self._buffvalue3:setText(0)
   local info = dungeon_vip_info.get(mapId)
   local g = Goods.convert(info["extra_type_1"], info["extra_value_1"])
   self._buffdes3:setText(g.name..G_lang:get("LANG_MAOHAO"))
end

function VipBattleBuffLayer:updateRound( round )
  self._buffvalue1:setText(round.."/"..self._totalRound)
  if self._type == 2 then
    self._buffvalue2:setText(round.."/"..self._totalRound)
    self._buffvalue3:setText(G_Me.vipData:getDefenceAward(self._mapId,round)*(G_Me.activityData.custom:isDailyDungeonActive() and 2 or 1))
  end
end

function VipBattleBuffLayer:updateDamage( damage )
  if self._type == 1 then
    self._buffvalue2:setText(damage)
    self._buffvalue3:setText(G_Me.vipData:getAttackAward(self._mapId,damage)*(G_Me.activityData.custom:isDailyDungeonActive() and 2 or 1))
  end
end

return VipBattleBuffLayer
