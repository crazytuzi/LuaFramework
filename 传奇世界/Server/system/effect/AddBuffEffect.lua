--AddBuffEffect.lua
--添加BUFF
local EFFECT_TYPES = {
	EffectType.Send, 
}


AddBuffEffect = class(Effect)

function AddBuffEffect:__init(config)
	self._useCnt = 0
end

function AddBuffEffect:doTest(src, target, incontext, outcontext, useCnt)
	return true
end

function AddBuffEffect:doEffect(src, target, incontext, outcontext, useCnt)
	local srcEntity = g_entityMgr:getPlayer(src)
	local tarEntity = g_entityMgr:getPlayer(target)
	if srcEntity and tarEntity then
		local effData = self:getDatas()
		local buffID = effData.buff
		local buffmgr = tarEntity:getBuffMgr()
		local eCode = 0
		for i=1, useCnt do
			local itemId = incontext.item:getProtoID()
			local buff, eCode = buffmgr:addBuff(buffID, eCode, 0, itemId)
			--eCode ==1 表示是增加持续时间的
			if not buff and eCode ~= 1 then
				if eCode ~= 0 then
					incontext.errorCode = eCode
					break
				end
			end
			self._useCnt = self._useCnt + 1
		end
		return self._useCnt
	end
	return 0
end