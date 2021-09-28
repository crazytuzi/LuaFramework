
local UIBase = require "ui/common/UIBase"

local UISprite3D=class("UISprite3D", UIBase)

function UISprite3D:ctor(ccNode, propConfig)
    UISprite3D.super.ctor(self, ccNode, propConfig)
	self._pos = nil
end

function UISprite3D:setName(name)
	self.ccNode_:setName(name)
end

function UISprite3D:setSprite(spr)
	self.ccNode_:loadSpr(spr)
end

function UISprite3D:setSprSize(size)
	self.ccNode_:setSprSize(size, size);
end

function UISprite3D:setSkin(skin, name)
	self.ccNode_:attachSkin(skin, name);
end

function UISprite3D:playAction(act, times)
	self.ccNode_:playAct(act, times or -1);
end

function UISprite3D:pushActionList(act, times)
	self.ccNode_:pushActList(act, times or -1);
end

function UISprite3D:playActionList()
	self.ccNode_:playActList();
end

function UISprite3D:setRotation(y, x,z)
	self.rotationY = y
	self.ccNode_:setRotation(x or 0, y, z or 0)
end

function UISprite3D:getRotation()
	local rotation = {x = 0, y = self.rotationY or math.pi/2, z = 0}
	return i3k_clone(rotation)
end

function UISprite3D:setCameraAngle(x, y, z)
	self.ccNode_:setCameraAngle(x, y, z);
end

function UISprite3D:linkChild(path, name, cs, hs, offsetY, scale)
	return self.ccNode_:linkChild(path, name, cs, hs, offsetY, scale);
end

function UISprite3D:unlinkChild(cid)
	self.ccNode_:uninkChild(cid);
end

function UISprite3D:setColor(color)
	self.ccNode_:setColor(color);
end

function UISprite3D:setLinkedChildColor(cid, color)
	self.ccNode_:setLinkedChildColor(cid, color);
end

return UISprite3D
