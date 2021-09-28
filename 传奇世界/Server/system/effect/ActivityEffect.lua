--ActivityEffect.lua
--活动使用物品(普通月卡和豪华月卡)


ActivityEffect = class(Effect)

function ActivityEffect:__init(config)
	
end

function ActivityEffect:doTest(src, target, incontext, outcontext, useCnt)
	return true
end

function ActivityEffect:doEffect(src, target, incontext, outcontext, useCnt)
	--print("---use1----")
	local srcEntity = g_entityMgr:getPlayer(src)
	local tarEntity = g_entityMgr:getPlayer(target)
	if srcEntity and tarEntity then
		local  dbid = srcEntity:getSerialID();
		local nItemId = incontext.item:getProtoID()
		local effData = self:getDatas()
		--print("---------------effData:"..serialize(effData));
		--活动物品
		if effData.effectType == EffectType.ActivityUse then
			local nActivityId = effData.act_id
			local nActivityModuleId = effData.act_module_id
			local nUseCount = g_ActivityServlet:UseItem(dbid,nItemId, nActivityModuleId, nActivityId)
			--print("---use2----"..tostring(nUseCount))
			return nUseCount
		end
	end
	return 0
end