-- --------------------------------------------------------------------
-- 断线重连的黑屏提示
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

ReconnectView = class("ReconnectView", function()
	return ccui.Layout:create()
end)

function ReconnectView:ctor()
    self.size = cc.size(SCREEN_WIDTH, SCREEN_HEIGHT)
	self:setContentSize(self.size)
    self:setPosition(self.size.width/2, self.size.height/2)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setTouchEnabled(true)

    local background = ccui.Layout:create()
    background:setAnchorPoint(cc.p(0.5, 0.5))
    background:setContentSize(self.size)
    background:setPosition(self.size.width / 2, self.size.height / 2)
    background:setScale(display.getMaxScale())
    showLayoutRect(background, 176)
    self:addChild(background) 

    self.parent = ViewManager:getInstance():getLayerByTag(ViewMgrTag.RECONNECT_TAG)
    self.parent:addChild(self)
end

-- 添加光环特效
function ReconnectView:createEffect()
	if self.effect ~= nil then return end
    self.effect = createSpineByName("E51006")
    self.effect:setAnimation(0, PlayerAction.action, true)
    self.effect:setPosition(cc.p(self.size.width/2, self.size.height/2))
    self:addChild(self.effect)
end

function ReconnectView:isOpen()
	return self.isOpenStatus
end

function ReconnectView:open()
	self.isOpenStatus = true
	self:createEffect()
end

function ReconnectView:close()
	if self.effect ~= nil then
        self.effect:removeFromParent() 
        self.effect = nil		
	end
	self:removeFromParent()
	self.isOpenStatus = nil
end

function ReconnectView:DeleteMe()
end