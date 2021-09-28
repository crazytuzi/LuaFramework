--CommandBookEffect.lua
--√‹¡ÓæÌ÷·


CommandBookEffect = class(Effect)

function CommandBookEffect:__init(config)
	
end

function CommandBookEffect:doTest(src, target, incontext, outcontext, useCnt)
	return true
end

function CommandBookEffect:doEffect(src, target, incontext, outcontext, useCnt)
	local srcEntity = g_entityMgr:getPlayer(src)
	local tarEntity = g_entityMgr:getPlayer(target)
	if srcEntity and tarEntity then
		local dbid = srcEntity:getSerialID()
		local itemID = incontext.item:getProtoID()
		if g_taskMgr:openBranchList(dbid, itemID) then
			return 1
		end
	end
	return 0
end