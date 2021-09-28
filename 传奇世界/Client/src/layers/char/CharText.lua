local CharText = class("CharText", function() return cc.Node:create() end)


function CharText:ctor(parent, duration, type, posoffset)

	log("[CharText:ctor] called.")

	if parent == nil then return end
	if type == nil then return end
	
	local textfilepath =
	{
		"res/text/headtext_dread.png",
		"res/text/headtext_frozen.png",
		"res/text/headtext_fury.png",
		"res/text/headtext_gravity.png",
		"res/text/headtext_immunity.png",
		"res/text/headtext_palsy.png",
		"res/text/headtext_poison_green.png",
		"res/text/headtext_poison_red.png",
		"res/text/headtext_reverseharm.png",
		"res/text/headtext_silence.png",
		"res/mainui/number/miss.png",
	}

	-----------------------------------------------------------

	local respath = textfilepath[type]
	if respath == nil then
		return
	end
    
    local commConst = require("src/config/CommDef");
    self:setTag(commConst.TAG_CHAR_TEXT);
	parent:addChild(self);

	local targetPos = posoffset

	if parent.getMainSprite then
		local mainSprite = parent:getMainSprite()
		if mainSprite then
			local mainRect = mainSprite:getTextureRect()
		--	targetPos.x = targetPos.x
			targetPos.y = targetPos.y + mainRect.height + 25
		end
	end


	local sprtText = createSprite(self, respath, targetPos, cc.p(0.5, 0.5))


	-----------------------------------------------------------

	sprtText:setVisible(false)
	local pos = targetPos
	local span_pos = cc.p(math.random(-20,20), math.random(40,60))

	sprtText:setCascadeOpacityEnabled(true)
	sprtText:setPosition(cc.p(pos.x+math.random(-2,2),pos.y+math.random(0,3)))
	local actions = {}
--	if delay then
--		actions[#actions+1] = cc.DelayTime:create(delay)
--	end
	actions[#actions+1] = cc.Show:create()
	actions[#actions+1] = cc.MoveBy:create(0.05*math.random(1,2),span_pos)
	actions[#actions+1] = cc.DelayTime:create(0.1)
	actions[#actions+1] = cc.MoveBy:create(0.05,cc.p(span_pos.x/3,span_pos.y/3))
	actions[#actions+1] = cc.DelayTime:create(0.11*math.random(1,2))

	actions[#actions+1] = cc.Spawn:create( cc.ScaleTo:create(0.3,0.8),cc.FadeOut:create(0.8))
	actions[#actions+1] = cc.CallFunc:create(function()
                        removeFromParent(self);
					end)
	sprtText:runAction(cc.Sequence:create(actions))

end


return CharText
