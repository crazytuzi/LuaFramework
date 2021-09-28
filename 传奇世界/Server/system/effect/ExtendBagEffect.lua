--ExtendBagEffect.lua
--升级或者增加经验
local EFFECT_TYPES = {
	EffectType.ExtendBag, 
}


ExtendBagEffect = class(Effect)

function ExtendBagEffect:__init(config)
	
end

function ExtendBagEffect:doTest(src, target, incontext, outcontext, cnt)
	local srcEntity = g_entityMgr:getPlayer(src)
	local tarEntity = g_entityMgr:getPlayer(target)
	if srcEntity and tarEntity then
		local itemMgr = tarEntity:getItemMgr()
		local errcode = 0
		local effData = self:getDatas()
		local flag, errcode = itemMgr:extendBagFree(errcode, cnt, effData.bagIdx)
		if not flag then
			incontext.errorCode = errcode
			return false
		end
		outcontext.params = strList:new() 
		outcontext.paramCnt = 1
		outcontext.params.str = tostring(cnt)
		outcontext.retCode = effData.bagIdx == 1 and Item_OP_Result_OPENBAGSLOT	or Item_OP_Result_OPENBANKSLOT
		return true
	end
	return false
end

function ExtendBagEffect:doEffect(src, target, incontext, outcontext, cnt)
	return cnt
end