
local LegionNewBattleBuffLayer = class ("LegionNewBattleBuffLayer", UFCCSNormalLayer)
require("app.cfg.corps_dungeon_info")

function LegionNewBattleBuffLayer.create( )   
    return LegionNewBattleBuffLayer.new("ui_layout/legion_LegionNewBattleBuff.json") 
end

function LegionNewBattleBuffLayer:ctor( ... )
    self.super.ctor(self, ...)
    self._buffdes1 = self:getLabelByName("Label_buffdes1")
    self._buffvalue1 = self:getLabelByName("Label_buffvalue1")
    self._buffdes2 = self:getLabelByName("Label_buffdes2")
    self._buffvalue2 = self:getLabelByName("Label_buffvalue2")
    self._buffdes1:setText(G_lang:get("LANG_NEW_LEGION_BATTLE_TIPS1"))
    self._buffdes2:setText(G_lang:get("LANG_NEW_LEGION_BATTLE_TIPS2"))
end

function LegionNewBattleBuffLayer:initData( chapterData )
    local info = corps_dungeon_info.get(chapterData.id)

    self._maxHp = chapterData.max_hp
    self._minAward = info.min_award
    self._maxAward = info.max_award
    self._buffvalue1:setText(0)
    self._buffvalue2:setText(self._minAward)
end

function LegionNewBattleBuffLayer:updateDamage( damage )
    self._buffvalue1:setText(GlobalFunc.ConvertNumToCharacter4(damage))
    self:updateAward(G_Me.legionData:getNewBattleAward(damage,self._maxHp,self._minAward,self._maxAward))
end

function LegionNewBattleBuffLayer:updateAward( award )
    self._buffvalue2:setText(award)
end

return LegionNewBattleBuffLayer
