
local MoShenBattleBuffLayer = class ("MoShenBattleBuffLayer", UFCCSNormalLayer)
require("app.cfg.dungeon_vip_info")

function MoShenBattleBuffLayer.create( )   
    return MoShenBattleBuffLayer.new("ui_layout/vip_battleBuff.json") 
end

function MoShenBattleBuffLayer:ctor( ... )
    self.super.ctor(self, ...)
    self._buffdes1 = self:getLabelByName("Label_buffdes1")
    self._buffvalue1 = self:getLabelByName("Label_buffvalue1")
    self._buffdes2 = self:getLabelByName("Label_buffdes2")
    self._buffvalue2 = self:getLabelByName("Label_buffvalue2")
    self._buffdes3 = self:getLabelByName("Label_buffdes3")
    self._buffvalue3 = self:getLabelByName("Label_buffvalue3")
    self._bgImage = self:getImageViewByName("Image_45")
    self._totalRound = 20
    
    self._buffdes1:setVisible(false)
    self._buffvalue1:setVisible(false)
    self._bgImage:setVisible(false)
    
    self._buffdes1:setText(G_lang:get("LANG_VIP_VIPDES1"))
    self._buffvalue1:setText("0/"..self._totalRound)
    self._buffdes2:setText(G_lang:get("LANG_VIP_VIPDES2"))
    self._buffvalue2:setText(0)
    self._buffdes3:setText(G_lang:get("LANG_MOSHEN_MEDAL_DESC"))
    self._buffvalue3:setText(0)
    
end

function MoShenBattleBuffLayer:updateRound( round )
    self._buffvalue1:setText(round.."/"..self._totalRound)
end

function MoShenBattleBuffLayer:updateDamage( damage )
    self._buffvalue2:setText(G_GlobalFunc.ConvertNumToCharacter(damage))
    self._buffvalue3:setText(G_GlobalFunc.ConvertNumToCharacter(math.floor(damage / 1000)))
end

return MoShenBattleBuffLayer
