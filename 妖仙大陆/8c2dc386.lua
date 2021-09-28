



local _M = {}
_M.__index = _M



function _M.FindTransform(parent, path)
	local obj = UnityEngine.GameObject.Find(path)
	return parent:GetRootEvent():AddCacheduserdata(obj.transform,typeof(obj))
end



function _M.GetWorldSpace(parent, id)
	local obj = parent:GetRootEvent():GetCacheduserdata(id)
	return obj.position
end

function _M.GameObjectVisible(self,val)
	
end

return _M
