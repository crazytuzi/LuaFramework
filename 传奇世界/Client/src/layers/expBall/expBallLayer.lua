local expBallLayer = class("expBallLayer", function() return cc.Layer:create() end)
	
function expBallLayer:ctor(expBallId,countDown)
	local MPackStruct = require "src/layers/bag/PackStruct"
	local MPackManager = require "src/layers/bag/PackManager"
	self.autoActionTime = 6
	local pack = MPackManager:getPack(MPackStruct.eBag)
	local expNum = pack:countByProtoId(expBallId)
	MPackManager:organize(MPackStruct.eBag)  --整理物品
	local bg = createSprite(self, "res/tuto/images/2.png", cc.p(display.width-200, display.height/2+50), cc.p(0.5, 0.5))
	local string = getConfigItemByKey("propCfg","q_id",expBallId,"q_name")
	createLabel(bg,string,cc.p(140,50),cc.p(0.5,0.5),30,true,nil,nil,MColor.yellow)
	local Mprop = require "src/layers/bag/prop"
	local icon = Mprop.new(
	{
		protoId = expBallId,
		swallow = true,
		num = expNum,
		cb = "tips",
	})
	icon:setPosition(cc.p(bg:getContentSize().width/2-15,bg:getContentSize().height/1.5-40))
	bg:addChild(icon)
	local buttonFun = function()
		local expNum = pack:countByProtoId(expBallId)
		if expNum == 0 then
			TIPS( { type = 1 , str = "^c(yellow)"..game.getStrByKey("notInBag").."^" }  )
		else
			local function UseItemByProtoId(expBallId)
				return MPackManager:useByProtoId(expBallId,expNum)
			end
			UseItemByProtoId(expBallId)
		end
		removeFromParent(self)
	end
	local menuItem = createMenuItem(bg, "res/component/button/50.png", cc.p(140, 0), buttonFun)
	addLableToMenuItem(menuItem,game.getStrByKey("useNow"),25,MColor.yellow)
	createMenuItem(bg,"res/tuto/images/3.png",cc.p(238,193),function() removeFromParent(self) end)
	menuItem:blink()
	if countDown then
		self.countDownLabel = createLabel(menuItem, "("..self.autoActionTime..")", cc.p(menuItem:getContentSize().width-30,17), cc.p(0, 0), 18, true, 5, nil, MColor.green)
		local function countDownFunc()
			self.autoActionTime = self.autoActionTime - 1
			if self.autoActionTime <= 0 then
			buttonFun()
			else
				self.countDownLabel:setString("("..self.autoActionTime..")")
			end
		end
		startTimerAction(self, 1, true, countDownFunc)
	end
end

return expBallLayer
