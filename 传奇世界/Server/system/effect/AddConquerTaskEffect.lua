--AddConquerTaskEffect.lua
--Ã÷∑•»ŒŒÒ
local EFFECT_TYPES = {
	EffectType.AddConquerTask, 
}


AddConquerTaskEffect = class(Effect)

function AddConquerTaskEffect:__init()
	self._useCnt = 0
end

function AddConquerTaskEffect:doTest(src, target, incontext, outcontext, useCnt)
	local srcEntity = g_entityMgr:getPlayer(src)
	local tarEntity = g_entityMgr:getPlayer(target)
	if srcEntity and tarEntity then
		local itemProto = incontext.item:getProto()
		local defaultColor = itemProto.defaultColor
		self._useCnt = g_taskServlet:canOpenConquerTask(target, defaultColor, useCnt)
		if useCnt < self._useCnt then self._useCnt = useCnt end
		if self._useCnt > 0 then
			return true
		else
			return false
		end
	end
	return false
end

function AddConquerTaskEffect:doEffect(src, target, incontext, outcontext, useCnt)
	local srcEntity = g_entityMgr:getPlayer(src)
	local tarEntity = g_entityMgr:getPlayer(target)
	if srcEntity and tarEntity then
		local itemProto = incontext.item:getProto()
		local defaultColor = itemProto.defaultColor
		for i=1, self._useCnt do
			g_taskServlet:openConquerTask(target, defaultColor)
		end
		return self._useCnt
	end
	return 0
end