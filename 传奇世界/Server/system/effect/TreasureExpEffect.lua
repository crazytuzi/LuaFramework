--TreasureExpEffect.lua
--全民宝地体验卡


TreasureExpEffect = class(Effect)

function TreasureExpEffect:__init(config)
	
end

function TreasureExpEffect:doTest(src, target, incontext, outcontext, useCnt)
	return true
end

function TreasureExpEffect:doEffect(src, target, incontext, outcontext, useCnt)
	print('TreasureExpEffect:doEffect() srcID:',src, 'targetID:',target)
	local srcEntity = g_entityMgr:getPlayer(src)
	local tarEntity = g_entityMgr:getPlayer(target)
	if srcEntity and tarEntity then
		if tarEntity:getCopyID() > 0  or g_TreasureManger:inTreasureMap(tarEntity:getSerialID()) then
			incontext.errorCode = Item_OP_Result_CannotUseSendItem
			return 0
		end
		local effData = self:getDatas()
		--全民宝地
		if effData.effectType == EffectType.TreasureExpEffect then
			local mapID = effData.mapID
			local xpos = effData.xPos
			local yPos = effData.yPos
			if not g_TreasureManger:experienceTreasure(tarEntity:getSerialID(),mapID, xpos,ypos) then
				return 0
			end
			return useCnt
		end
	end
	return 0
end