
local HardDungeonBattleBuffLayer = class ("HardDungeonBattleBuffLayer", UFCCSNormalLayer)

function HardDungeonBattleBuffLayer.create( )   
    return HardDungeonBattleBuffLayer.new("ui_layout/vip_battleBuff.json") 
end

function HardDungeonBattleBuffLayer:ctor( ... )
    self.super.ctor(self, ...)
    self._buffdes2 = self:getLabelByName("Label_buffdes2")
    self._buffvalue2 = self:getLabelByName("Label_buffvalue2")
    
    self:showWidgetByName("Label_buffdes1", false)
    self:showWidgetByName("Label_buffvalue1", false)
    self:showWidgetByName("Label_buffdes3", false)
    self:showWidgetByName("Label_buffvalue3", false)
    
    self:showWidgetByName("Image_45", false)
    self:showWidgetByName("Image_45_1", false)
    
    self._buffdes2:setText(G_lang:get("LANG_HARD_DUNGEON_BATTLE_ROUND_DESC", {round=0}))
    self._buffvalue2:setText("")
    
end

function HardDungeonBattleBuffLayer:updateRound( _round )
    self._buffdes2:setText(G_lang:get("LANG_HARD_DUNGEON_BATTLE_ROUND_DESC", {round=_round}))
end

return HardDungeonBattleBuffLayer
