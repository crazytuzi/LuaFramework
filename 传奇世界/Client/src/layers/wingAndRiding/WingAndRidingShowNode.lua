local WingAndRidingShowNode = class("WingAndRidingShowNode", function() return cc.Node:create() end )

function WingAndRidingShowNode:ctor(type, id, scale)
	dump(id)
	local addSprite = createSprite
	local addLabel = createLabel
	
	local pathCommon = "res/wingAndRiding/common/"
	local pathWing = "res/wingAndRiding/wing/"
	local pathRiding = "res/wingAndRiding/riding/"
	local path

	self.getString = game.getStrByKey
	self.load_data = {}
	self.type = type
	
	if self.type == wingAndRidingType.WR_TYPE_WING then
		path = pathWing
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		path = pathRiding
	end 

	if self.type == wingAndRidingType.WR_TYPE_WING then
		local sprite = createSprite(self, "res/showplist/wing/"..id..".png", cc.p(0,10), cc.p(0.5, 0.5))
		sprite:setScale(scale)
		--[[
		local resPath = "res/effectsplist/wing"..id..".plist"
		if cc.FileUtils:getInstance():isFileExist(resPath) then
			--展示动画
			local animateSpr = Effects:create(false)
			local counts = {5,11,9,11,9,10,11,11,7}
			animateSpr:playActionData("wing"..id,counts[id],1.5,-1)
			self:addChild(animateSpr)
		end
		]]
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		local sprite = createSprite(self, "res/showplist/ride/"..id..".png", cc.p(0,40), cc.p(0.5, 0.5))
		sprite:setScale(scale)

		local createRideEffect = function(parent, effect_str,pos,times,mode)
			local futil = cc.FileUtils:getInstance()
			local bCurFilePopupNotify = false
			if isWindows() then
				bCurFilePopupNotify = futil:isPopupNotify()
				futil:setPopupNotify(false)
			end
			local c_effect = nil
			if futil:isFileExist("res/effectsplist/"..effect_str .. "@0.plist") then
				c_effect =  Effects:create(false)
				c_effect:setPosition(pos)
				c_effect:setScale(scale)
			    parent:addChild(c_effect)
			    c_effect:playActionData2(effect_str,times,-1,0)
			    addEffectWithMode(c_effect,mode or 2)
			end

			if isWindows() then
				futil:setPopupNotify(bCurFilePopupNotify)
			end
			return c_effect
		end

		createRideEffect(self, "ride_" .. id, cc.p(0,40), 260, 1)


		--[[
		local filePath = "show/"..id
		local animateSpr = SpriteBase:create(filePath)
		animateSpr:setType(31)
		animateSpr:initStandStatus(4,6,1.5,7)
		animateSpr:standed()
		self:addChild(animateSpr)
		animateSpr:setPosition(cc.p(0, -100)) 
		animateSpr:setScale(scale)
		]]
	end
end

function WingAndRidingShowNode:getData(key)
	log("key:"..key)
	if self.type == wingAndRidingType.WR_TYPE_WING then
		log("key:"..G_WING_INFO[key])
		return G_WING_INFO[key]
	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
		log("key:"..G_RIDING_INFO[key])
		return G_RIDING_INFO[key]
	end 
end

-- function WingAndRidingShowNode:getCfgData(key)
-- 	log("WingAndRidingShowNode:getCfgData")
-- 	local tab
--  	local id
-- 	if self.type == wingAndRidingType.WR_TYPE_WING then
-- 		tab = require("src/config/WingCfg")
-- 		id = G_WING_INFO.id
-- 	elseif self.type == wingAndRidingType.WR_TYPE_RIDING then
-- 		tab = require("src/config/RidingCfg")
-- 		id = G_RIDING_INFO.id
-- 	end 
-- 	log("id"..id)
-- 	for i=1,#tab do
-- 		if tab[i].q_ID == id then
-- 			return tab[i][key]
-- 		end
-- 	end
-- end

return WingAndRidingShowNode