--
-- Author: Zippo
-- Date: 2013-12-03 12:15:12
--


local fightPauseLayer = class("fightPauseLayer", BaseLayer)

function fightPauseLayer:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.fight.FightPauseLayer")
end

function fightPauseLayer:initUI(ui)
	self.super.initUI(self,ui)
	self.ui = ui

	self.Btn_quit = TFDirector:getChildByPath(ui, 'Btn_quit')
	self.Btn_return = TFDirector:getChildByPath(ui, 'Btn_return')
	self.Btn_return.logic = self
end

function fightPauseLayer:registerEvents()	
	self.super.registerEvents(self)

	self.Btn_quit:addMEListener(TFWIDGET_CLICK, audioClickfun(self.quitClickHandle))
	self.Btn_return:addMEListener(TFWIDGET_CLICK, audioClickfun(self.returnClickHandle))
end

function fightPauseLayer:removeUI()

end

function fightPauseLayer.quitClickHandle(btn)
	FightManager:LeaveFight()
	TFDirector:resume()
end
function fightPauseLayer.returnClickHandle(btn)
	btn.logic.logic.fightPauseLayer:setVisible(false)
	TFDirector:resume()
end

return fightPauseLayer