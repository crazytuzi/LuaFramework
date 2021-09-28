local ArenaHeroAnimation = class("ArenaHeroAnimation",function()  return display.newNode() end )
local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectNode = require "app.common.effects.EffectNode"

local KnightPic = require("app.scenes.common.KnightPic")


function ArenaHeroAnimation.create(attack, defense, from, callback)
	local animation = ArenaHeroAnimation.new()
	animation:init(attack, defense, from, callback)

	return animation
end

function ArenaHeroAnimation:init(attack, defense, from, callback)
	self._from = from 
	self._attack = attack
	self._defense = defense

	local moving = "moving_from_right"
	local facePos = ccp(145, 330)
	if from == "left" then
		moving= "moving_from_left"
		facePos = ccp(-140, 330)
	end

	self._node = EffectMovingNode.new(moving, function(key)
			if key == "attack" then
				local node = KnightPic.createKnightNode(self._attack, "")
				node:setScale(0.4)

				local faceWin = ImageView:create()
				faceWin:loadTexture("ui/chat/face/53.png")
				faceWin:setScale(2.5)

				faceWin:setPosition(facePos)
				node:addChild(faceWin)

				return node
			elseif  key == "defense" then
				local node = KnightPic.createKnightNode(self._defense, "")
				node:setScale(0.4)

				local faceLose = ImageView:create()
				faceLose:loadTexture("ui/chat/face/14.png")
				faceLose:setScale(2.5)

				faceLose:setPosition(facePos)
				node:addChild(faceLose)

				return node
			elseif key == "effect_card_dust" then
			    local effect   = EffectNode.new("effect_card_dust") 

			    effect:play()
			    return effect  
			end
		end,

		function(event)
			if event == "finish" then
				if callback ~= nil then
					callback()
				end
			end
		end

	)


	self._node:play()
	self:addChild(self._node)

end




return ArenaHeroAnimation