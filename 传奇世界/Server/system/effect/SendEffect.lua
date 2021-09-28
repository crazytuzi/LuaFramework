--SendEffect.lua
--传送效果
local EFFECT_TYPES = {
	EffectType.Send, 
}


SendEffect = class(Effect)

function SendEffect:__init(config)
	
end

function SendEffect:doTest(src, target, incontext, outcontext, useCnt)
	return true
end

function SendEffect:doEffect(src, target, incontext, outcontext, useCnt)
	local srcEntity = g_entityMgr:getPlayer(src)
	local tarEntity = g_entityMgr:getPlayer(target)
	if srcEntity and tarEntity then
		if tarEntity:getCopyID() > 0 then
			incontext.errorCode = Item_OP_Result_CannotUseSendItem
			return 0
		end
		local effData = self:getDatas()
		--回城类
		if effData.effectType == EffectType.Send then
			local mapID = effData.mapID
			local xpos = effData.xPos
			local yPos = effData.yPos
			g_sceneMgr:enterPublicScene(target, mapID, xpos, yPos)
			return useCnt
		--随机卷轴
		elseif effData.effectType == EffectType.RandSend then
			local scene = tarEntity:getScene()
			local sceneSize = scene:getSize()
			local mapID = scene:getMapID()
			local i=0
			while i<=20 do
				local x = math.floor(math.rand(1,sceneSize.x))
				local y = math.floor(math.rand(1,sceneSize.y))
				if g_sceneMgr:posValidate(mapID, x, y) then
					g_sceneMgr:enterPublicScene(target, mapID, x, y)
					return useCnt
				end
				i = i+1
			end
			if i == 20 then
				print("----send error",sceneSize.x,sceneSize.y)
				return 0
			end
		end
	end
	return 0
end