--TowerSystemMessageBoxEx.lua


local TowerSystemMessageBoxEx = class ("TowerSystemMessageBoxEx", UFCCSMessageBox)


TowerSystemMessageBoxEx.TypeMain = 1
TowerSystemMessageBoxEx.TypeTower = 2
TowerSystemMessageBoxEx.TypeShop = 3
TowerSystemMessageBoxEx.TypeLegion = 4
TowerSystemMessageBoxEx.TypeVip = 5
TowerSystemMessageBoxEx.TypeLegionCross = 6
TowerSystemMessageBoxEx.TypeTimeDungeon = 7
TowerSystemMessageBoxEx.TypeRebelBoss = 8
TowerSystemMessageBoxEx.TypeWushBoss = 9
TowerSystemMessageBoxEx.TypeCrusade = 10


local imgName = {"main","tower","shop", "legion","vip", "legion_cross", "timeDungeon", "rebelBoss", "Wush_Boss", "crusade"}
        
function TowerSystemMessageBoxEx:ctor( ... )
	self.super.ctor(self, ...)
	self:showAtCenter(true)
	self._mode = 1
	self:getPanelByName("Panel_main"):setVisible(false)
	self:getPanelByName("Panel_tower"):setVisible(false)
	self:getPanelByName("Panel_shop"):setVisible(false)
	self:getPanelByName("Panel_legion"):setVisible(false)
	self:getPanelByName("Panel_vip"):setVisible(false)
	self:getLabelByName("Label_spe"):setVisible(false)
	self:getPanelByName("Panel_legion_cross"):setVisible(false)
	self:getPanelByName("Panel_timeDungeon"):setVisible(false)
	self:getPanelByName("Panel_rebelBoss"):setVisible(false)
	self:getPanelByName("Panel_Wush_Boss"):setVisible(false)
	self:getPanelByName("Panel_crusade"):setVisible(false)

end

function TowerSystemMessageBoxEx:onLayerLoad( ... )
	self.super.onLayerLoad(self, ...)

	self:registerYesBtn("Button_yes")
	self:registerOkBtn("Button_chongzhi")
	self:registerNoBtn("Button_no")

end

function TowerSystemMessageBoxEx:onLayerEnter( ... )
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

function TowerSystemMessageBoxEx:setMode( mode )
	self._mode = mode
	self:getPanelByName("Panel_"..imgName[self._mode]):setVisible(true)

	self:showWidgetByName("Button_yes", mode == TowerSystemMessageBoxEx.TypeLegion or mode == TowerSystemMessageBoxEx.TypeLegionCross or mode == TowerSystemMessageBoxEx.TypeWushBoss) 
	self:showWidgetByName("Button_chongzhi", (mode ~= TowerSystemMessageBoxEx.TypeLegion and mode ~= TowerSystemMessageBoxEx.TypeLegionCross) )
end

function TowerSystemMessageBoxEx:setMoney( money )
	self:getLabelByName("Label_"..imgName[self._mode].."2"):setText(money)
	self:getLabelByName("Label_"..imgName[self._mode].."2"):createStroke(Colors.strokeBrown, 1)
end

function TowerSystemMessageBoxEx:setTimes( times )
	local label = self:getLabelByName("Label_"..imgName[self._mode].."5")
	if label then
		label:setText(times)
	end
	--self:getLabelByName("Label_"..imgName[self._mode].."5"):setText(times)
end

function TowerSystemMessageBoxEx:setSpecial( msg )
	self:getLabelByName("Label_spe"):setVisible(true)
	self:getLabelByName("Label_spe"):setText(msg)
end

function TowerSystemMessageBoxEx.showMessage(mode, money, times, yes_handler, no_handler,  target )
	local msgbox = require("app.scenes.tower.TowerSystemMessageBox").new("ui_layout/tower_SystemMessageBox.json", Colors.modelColor)
	msgbox:setMode(mode)
	msgbox:setMoney(money)
	msgbox:setTimes(times)
	msgbox:setYesCallback(yes_handler, target)
	msgbox:setNoCallback(no_handler, target)
	msgbox:show(false, false)
end

function TowerSystemMessageBoxEx.showSpecialMessage(msg, yes_handler, no_handler,  target )
	local msgbox = require("app.scenes.tower.TowerSystemMessageBox").new("ui_layout/tower_SystemMessageBox.json", Colors.modelColor)
	msgbox:setSpecial(msg)
	msgbox:setYesCallback(yes_handler, target)
	msgbox:setNoCallback(no_handler, target)
	msgbox:show(false, false)
end

return TowerSystemMessageBoxEx
