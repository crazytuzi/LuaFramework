
local UIBase = require "ui/common/UIBase"

local CCParticle = class("CCParticle", UIBase)

function CCParticle:ctor(ccNode, propConfig)----------particle是被加在了一个widget上，self不能得到particle
	CCParticle.super.ctor(self, ccNode, propConfig)
    --self.ccNode_ = ccNode:getChildren()[1]
end

function CCParticle:hide()
	if self.ccNode_._stop then
	self.ccNode_._stop()
	end
end

function CCParticle:show()
	if self.ccNode_._play then
	self.ccNode_._play()
	end
end

return CCParticle
