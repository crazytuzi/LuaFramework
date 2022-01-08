--[[
******好友助战*******

	-- by quanhuan
	-- 2016/1/22
	
]]

local ZhuzhanFriendLayer = class("ZhuzhanFriendLayer",BaseLayer)

function ZhuzhanFriendLayer:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.ZhuZhan.ZhuzhanFriend")
end

function ZhuzhanFriendLayer:initUI( ui )

	self.super.initUI(self, ui)

    local provideRoleNode1 = TFDirector:getChildByPath(ui, "Panel_ZhuzhanRoleSelect1")
    provideRoleNode1:setVisible(true)
    local provideRoleNode2 = TFDirector:getChildByPath(ui, "Panel_ZhuzhanRoleSelect2")
    provideRoleNode2:setVisible(false)
    self.provideRoleLayer = require("lua.logic.assistFight.ProvideRoleLayer"):new(provideRoleNode1,self)
    self.requestRoleLayer = require("lua.logic.assistFight.requestRoleLayer"):new(provideRoleNode2,self)

    
end


function ZhuzhanFriendLayer:removeUI()
	self.super.removeUI(self)
    if self.provideRoleLayer then
        self.provideRoleLayer:removeUI()
    end
    if self.requestRoleLayer then
        self.requestRoleLayer:removeUI()
    end
end

function ZhuzhanFriendLayer:onShow()
    self.super.onShow(self)
end

function ZhuzhanFriendLayer:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)


    if self.provideRoleLayer then
        self.provideRoleLayer:registerEvents()
    end
    if self.requestRoleLayer then
        self.requestRoleLayer:registerEvents()
    end
    self.registerEventCallFlag = true 
end

function ZhuzhanFriendLayer:removeEvents()

    self.super.removeEvents(self)
    if self.provideRoleLayer then
        self.provideRoleLayer:removeEvents()
    end
    if self.requestRoleLayer then
        self.requestRoleLayer:removeEvents()
    end

    self.registerEventCallFlag = nil  
end

function ZhuzhanFriendLayer:dispose()
	self.super.dispose(self)
    if self.provideRoleLayer then
        self.provideRoleLayer:dispose()
    end
    if self.requestRoleLayer then
        self.requestRoleLayer:dispose()
    end
end

function ZhuzhanFriendLayer:onShowLayerClick( idx )
    if idx == 1 then
        self.provideRoleLayer:setVisible(true)
        self.requestRoleLayer:setVisible(false)
    else
        self.provideRoleLayer:setVisible(false)
        self.requestRoleLayer:setVisible(true)        
    end
end

function ZhuzhanFriendLayer:onChakanBtnClick()
    FriendManager:openFriendZhuzhanLayer()
end

function ZhuzhanFriendLayer:setLineUpType(LineUpType)
    self.LineUpType = LineUpType
    print('------------------LineUpType -',LineUpType)
    self:onShowLayerClick( 1 )
end
return ZhuzhanFriendLayer
