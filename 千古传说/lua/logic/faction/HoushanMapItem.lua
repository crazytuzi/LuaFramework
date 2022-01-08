--[[
*******后山地图*******

    -- by yao
    -- 2015/12/25
]]

local HoushanMapItem = class("HoushanMapItem", BaseLayer)

function HoushanMapItem:ctor(data)
    self.super.ctor(self,data)
    --self.generalHead = nil
    self.rulebtn = nil

    self:init("lua.uiconfig_mango_new.faction.HoushanMapItem")
end

function HoushanMapItem:initUI(ui)
	self.super.initUI(self,ui)

	--self.generalHead = CommonManager:addGeneralHead( self )
    --self.generalHead:setData(ModuleType.Faction,{HeadResType.FACTION_GX,HeadResType.COIN,HeadResType.SYCEE}) 
	--self.rulebtn = TFDirector:getChildByPath(ui,'')
end

function HoushanMapItem:removeUI()
	self.super.removeUI(self)
end


function HoushanMapItem:registerEvents()
	self.super.registerEvents(self)

	-- if self.generalHead then
 --        self.generalHead:registerEvents()
 --    end
 --    self.rulebtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onButtonClick))
end

function HoushanMapItem.onButtonClick(sender)
	-- body
end


function HoushanMapItem:removeEvents()
	-- if self.generalHead then
 --        self.generalHead:removeEvents()
 --    end

    self.super.removeEvents(self)
end

function HoushanMapItem:dispose()
    -- if self.generalHead then
    --     self.generalHead:dispose()
    --     self.generalHead = nil
    -- end

    self.super.dispose(self)
end

return HoushanMapItem
