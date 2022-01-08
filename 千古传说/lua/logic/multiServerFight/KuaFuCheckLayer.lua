--[[
******跨服个人战-弹出信息*******

	-- by quanhuan
	-- 2016/4/20
	
]]

local KuaFuCheckLayer = class("KuaFuCheckLayer",BaseLayer)

function KuaFuCheckLayer:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.kuafuwulin.KuaFuCheck")
end

function KuaFuCheckLayer:initUI( ui )

	self.super.initUI(self, ui)

    self.txtPlayerName = TFDirector:getChildByPath(ui, 'txt_name')
    self.txtServerName = TFDirector:getChildByPath(ui, 'txt_fuwu')
    self.txtPower = TFDirector:getChildByPath(ui, 'txt_num')
    self.imgHeadIcon = TFDirector:getChildByPath(ui, 'icon_head')
    self.imgHeadFrame = TFDirector:getChildByPath(ui, 'img_di')
end

function KuaFuCheckLayer:removeUI()
	self.super.removeUI(self)
end

function KuaFuCheckLayer:onShow()
    self.super.onShow(self)
end

function KuaFuCheckLayer:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)
    
    self.registerEventCallFlag = true 
end

function KuaFuCheckLayer:removeEvents()

    self.super.removeEvents(self)

    self.registerEventCallFlag = nil  
end

function KuaFuCheckLayer:dispose()
	self.super.dispose(self)
end

function KuaFuCheckLayer:setData(data)
    print('data = ',data)
    self.txtPlayerName:setText(data.playerName)
    self.txtServerName:setText(data.serverName)
    self.txtPower:setText(data.power)
    local RoleIcon = RoleData:objectByID(data.headIcon)
    self.imgHeadIcon:setTexture(RoleIcon:getIconPath())
    Public:addFrameImg(self.imgHeadIcon,data.headFrame)
end

return KuaFuCheckLayer