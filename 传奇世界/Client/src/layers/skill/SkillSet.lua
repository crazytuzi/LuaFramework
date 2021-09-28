local SkillSet = class("SkillSet",function() return cc.Layer:create() end)

function SkillSet:ctor(parent)
	local activityID = 1

	--local bg = 	createSprite(self,"res/common/bg/bg-6.png",cc.p(480,290))
    local bg = cc.Node:create()
    bg:setPosition(cc.p(15, 23))
    bg:setContentSize(cc.size(930, 535))
    bg:setAnchorPoint(cc.p(0, 0))
    self:addChild(bg)

	self.select_layers = {}
	local layers = {require("src/layers/skill/SkillSetLayer"),require("src/layers/skill/PropSetLayer")  }
	local bg_size = cc.size(112,502)
	createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(15, 15),
        bg_size,
        5
    )

	--createSprite(bg,"res/common/bg/buttonBg6.png",cc.p(71,266))
	local menuFunc = function(tag)
		if self.select_index == tag then
			return
		end
		self.select_index = tag
		for k,v in pairs(self.select_layers) do
			--v:setVisible(tag == k)
			if tag == k then
				-- self.select_layers[tag] = layers[tag].new(bg)
				-- bg:addChild(self.select_layers[tag],125)
			elseif self.select_layers[k] then
				removeFromParent(self.select_layers[k])
				self.select_layers[k] = nil
			end
		end
		if not self.select_layers[tag] then
			self.select_layers[tag] = layers[tag].new(bg)
			bg:addChild(self.select_layers[tag],125)
		end
	end
	local str_tab = {game.getStrByKey("skills") , game.getStrByKey("goods")}
	local node = require("src/LeftSelectNode").new(bg,str_tab,cc.size(118,500),cc.p(19,11),menuFunc)
	node:setLocalZOrder(130)
	self.select_index = 0
	menuFunc( activityID )
end

return SkillSet