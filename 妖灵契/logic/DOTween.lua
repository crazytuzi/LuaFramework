local rawget = rawget

local uDOTween = DOTween
local _DOTween = {}

local _set = {}

_DOTween.__index = function(t, k)
	local var = rawget(_DOTween, k)
	
	if var then
		return var
	end

	return uDOTween.__index(uDOTween, k)
end

local DOTween = {}

function DOTween.Sequence(target)
	local seq = uDOTween.Sequence()
	seq.target = target
	return seq
end

function DOTween.Clear(destory)
	destory = (destory==nil) and false or destory
	return uDOTween.DOTween.Clear(destory)
end

function DOTween.KillAll(complete)
	complete = (complete==nil) and false or complete
	return uDOTween.DOTween.KillAll(complete)
end

function DOTween.DOKill(tOrId, complete)
	if C_api.Utils.IsObjectExist(tOrId) then
		return uDOTween.DOTween.Kill(tOrId, complete)
	else
		printerror("DOTween.DOKill obj is nil")
		return 0
	end
end

setmetatable(DOTween, _DOTween)

return DOTween