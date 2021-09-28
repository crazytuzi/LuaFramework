--MarriageDrinkEffect.lua
--婚礼会场喝酒


MarriageDrinkEffect = class(Effect)

function MarriageDrinkEffect:__init(config)
	
end

function MarriageDrinkEffect:doTest(src, target, incontext, outcontext, useCnt)
	return true
end

function MarriageDrinkEffect:doEffect(src, target, incontext, outcontext, useCnt)
	print('MarriageDrinkEffect:doEffect() srcID:',src, 'targetID:',target)
	local srcEntity = g_entityMgr:getPlayer(src)
	local tarEntity = g_entityMgr:getPlayer(target)
	if srcEntity and tarEntity then
		local venue = g_marriageMgr:getVenueBySID(srcEntity:getSerialID())
		if venue then
			if venue:guestDrink(srcEntity) then
				return 1
			end
		else
			
		end
	end
	return 0
end