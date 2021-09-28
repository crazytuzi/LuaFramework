local getRewardsLayer = class("getRewardsLayer",function() return cc.Layer:create() end )

function getRewardsLayer:ctor(rewards)
	local retSprite = cc.Sprite:create("res/common/5.png")
	local r_size  = retSprite:getContentSize()
	createLabel(retSprite,  game.getStrByKey("award"), cc.p(r_size.width/2, r_size.height -12), cc.p(0.5,1.0), 22, true)

	local func = function()
		if retSprite then
	        removeFromParent(retSprite)
	        retSprite = nil
		end
		--g_msgHandlerInst:sendNetDataByFmtExEx(DIGMINE_CS_REWARD,"i",G_ROLE_MAIN.obj_id)
	end
	if rewards then
		local icons = {}
		local Mprop = require "src/layers/bag/prop"
		for k, v in pairs(rewards) do
			icons[#icons+1] = Mprop.new(
			{
				protoId = v[1],
				num = v[2],
				cb = "tips",
			})
		end

		Mnode.addChild(
		{
			parent = retSprite,
			child = Mnode.combineNode(
			{
				nodes = icons,
				margins = 10,
			}),
			pos = cc.p(r_size.width/2, 170),
		})
	end

	local menuItem = createMenuItem(retSprite,"res/component/button/50.png",cc.p(210,45),func)
	createLabel(menuItem,game.getStrByKey("get_awards") ,getCenterPos(menuItem),nil,21,true)
	getRunScene():addChild(retSprite,199)
	retSprite:setPosition(g_scrCenter)
	SwallowTouches(self)
end

return  getRewardsLayer