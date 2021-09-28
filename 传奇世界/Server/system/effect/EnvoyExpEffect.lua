--EnvoyExpEffect.lua
--炼狱体验卡


EnvoyExpEffect = class(Effect)

function EnvoyExpEffect:__init(config)
	
end

function EnvoyExpEffect:doTest(src, target, incontext, outcontext, useCnt)
	return true
end

function EnvoyExpEffect:doEffect(src, target, incontext, outcontext, useCnt)
	print('EnvoyExpEffect:doEffect() srcID:',src, 'targetID:',target)
	local srcEntity = g_entityMgr:getPlayer(src)
	local tarEntity = g_entityMgr:getPlayer(target)
	if srcEntity and tarEntity then
		if tarEntity:getCopyID() > 0  or g_EnvoyMgr:inEnvoyMap(tarEntity:getSerialID()) then
			incontext.errorCode = Item_OP_Result_CannotUseSendItem
			return 0
		end
		local effData = self:getDatas()
		--进入炼狱
		if effData.effectType == EffectType.EnvoyExpEffect then
			local mapID = effData.mapID
			local xpos = effData.xPos
			local yPos = effData.yPos
			if not g_EnvoyMgr:experienceEnvoy(target,mapID, xpos,ypos) then
				return 0
			end
			return useCnt
		end
	end
	return 0
end