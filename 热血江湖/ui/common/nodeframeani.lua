local UIDefault = require "ui/common/DefaultValue"

local NodeFrameAni = {}

function NodeFrameAni.createNode(prop)
	local nodeCreate = ccui.RefContainer:create()
	if prop.rotation or prop.rotationX or prop.rotationY then
		nodeCreate:setRotation3D(cc.vec3(prop.rotationX or 0, prop.rotationY or 0, prop.rotation or 0))
	end
	if prop.frameName and not nodeCreate._ani then
		local delay = prop.delay or UIDefault.DefFrameAni.delay
		local frameStart = prop.frameStart or UIDefault.DefFrameAni.frameStart
		local frameEnd = prop.frameEnd or UIDefault.DefFrameAni.frameEnd
		local frameWidth = prop.frameWidth or UIDefault.DefFrameAni.frameWidth
		local frameHeight = prop.frameHeight or UIDefault.DefFrameAni.frameHeight
		local baseFrameX = prop.baseFrameX or UIDefault.DefFrameAni.baseFrameX
		local baseFrameY = prop.baseFrameY or UIDefault.DefFrameAni.baseFrameY
		local column = prop.column or UIDefault.DefFrameAni.column
		local repeatLast = prop.repeatLastFrame or UIDefault.DefFrameAni.repeatLastFrame
		--TODO
		--cc.SpriteFrameCache:getInstance():addSpriteFrames(prop.packFile)

		local animation = cc.Animation:create()
		animation:setDelayPerUnit(delay)
		nodeCreate._aniTime = 0
		for k = frameStart, frameEnd + repeatLast do
			local r = 0
			local c = k - 1
			if c > frameEnd - 1 then
				c = frameEnd - 1
			end
			if column > 0 then
				r = (c - c % column) / column
				c = c % column
			end
			local sf = cc.SpriteFrame:create(prop.frameName, 
				cc.rect(
					baseFrameX + c * frameWidth, 
					baseFrameY + r * frameHeight, 
					frameWidth, 
					frameHeight
				)
				)
			if sf then
				animation:addSpriteFrame(sf)
				if k > frameStart then
					nodeCreate._aniTime = nodeCreate._aniTime + delay
				end
			end
		end
		nodeCreate._ani = cc.Animate:create(animation)
		nodeCreate._sprite = cc.Sprite:create()
		if prop.blendFunc and prop.blendFunc == 1 then
			nodeCreate._sprite:setBlendFunc({src=770,dst=1})
			nodeCreate._sprite:disableAutosetBlendFunc()
		end
		nodeCreate:addChild(nodeCreate._sprite)
		nodeCreate._sprite:setNormalizedPosition(cc.p(0.5, 0.5))
		if prop.sizeXAB then
			nodeCreate._sprite:setScale(prop.sizeXAB/frameWidth, prop.sizeYAB/frameHeight)
		end
		if prop.playOnInit == nil or prop.playOnInit == true then
			local times = prop.playTimes or -1
			if times ~= 0 then
				local action = times < 0 and cc.RepeatForever:create(nodeCreate._ani) or cc.Repeat:create(nodeCreate._ani, times)
				nodeCreate._sprite:runAction(action)
			end
		end
		nodeCreate:insertRefItem(nodeCreate._ani)
		
	end
	return nodeCreate
end

return NodeFrameAni