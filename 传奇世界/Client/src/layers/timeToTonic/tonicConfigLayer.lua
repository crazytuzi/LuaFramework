local tonicConfigLayer = class("tonicConfigLayer", function() return cc.Layer:create() end)

function tonicConfigLayer:ctor(propId,npc_node)
	if propId and propId ~= 0 and (not npc_node) then
		local MPackManager = require "src/layers/bag/PackManager"
		return MPackManager:useByProtoId(propId)
	else 
		local bg = createSprite(self, "res/tuto/images/2.png", cc.p(display.width-200, display.height/2+50), cc.p(0.5, 0.5))
		local string = getConfigItemByKey("propCfg","q_id",propId,"q_name")
		createLabel(bg,string,cc.p(140,50),cc.p(0.5,0.5),30,true,nil,nil,MColor.blue)
		--createSprite(bg,"res/group/itemIcon/"..propId..".png",cc.p(bg:getContentSize().width/2-20,bg:getContentSize().height/1.5-45),cc.p(0.5,0.5))
		local Mprop = require "src/layers/bag/prop"
		local icon = Mprop.new(
			{
				protoId = propId,
				swallow = true,
				cb = "tips",
			})
			icon:setPosition(cc.p(bg:getContentSize().width/2-15,bg:getContentSize().height/1.5-40))
			bg:addChild(icon)
		local buttonFun = function()
			local function UseItemByProtoId(propId)
				local MPackManager = require "src/layers/bag/PackManager"
				return MPackManager:useByProtoId(propId)
			end
			UseItemByProtoId(propId)
			removeFromParent(self)
			if npc_node then
				--g_msgHandlerInst:sendNetDataByFmtExEx(DIGMINE_CS_DIGMINE,"is",userInfo.currRoleId,npc_node:getTag())
			end
		end
		local menuItem = createMenuItem(bg, "res/component/button/50.png", cc.p(140, 0), buttonFun)
		addLableToMenuItem(menuItem,game.getStrByKey("useNow"),25,MColor.yellow)
		createMenuItem(bg,"res/tuto/images/3.png",cc.p(238,193),function() removeFromParent(self) end)
		menuItem:blink()
	end
end

return tonicConfigLayer