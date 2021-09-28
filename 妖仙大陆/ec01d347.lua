



local _M = {}
_M.__index = _M




function _M.GetWorldSpace(parent, id)
	local obj = parent:GetRootEvent():GetCacheduserdata(id)
	if not obj then return end
	return obj.position
end




function _M.WorldSpaceToLoaclSpace(parent,id,wp)
	local obj1 = parent:GetRootEvent():GetCacheduserdata(id)
	if not obj1 then return end
	return obj1:InverseTransformPoint(wp)
end




function _M.GetParent(parent,id)
	local obj = parent:GetRootEvent():GetCacheduserdata(id)
	if not obj then return end
	return parent:GetRootEvent():AddCacheduserdata(obj.parent,'UnityEngine.RectTransform')
end




function _M.IsTransform(parent, id)
	local obj,type_str = parent:GetRootEvent():GetCacheduserdata(id)
	return type_str == 'UnityEngine.RectTransform'
end

local function GetGameObject(obj)
	return obj.gameObject
end




function _M.IsValidTransform(parent,id)
	local obj,type_str = parent:GetRootEvent():GetCacheduserdata(id)
	if not obj then return end
	local ok,ret = pcall(GetGameObject,obj)
	if ok then
		return DramaHelper.CheckGameObjectRaycast(ret)
	else
		return nil 
	end
end




function _M.GetSize(parent,id)
	local obj = parent:GetRootEvent():GetCacheduserdata(id)
	if not obj then return end
	return obj.sizeDelta
end




function _M.GetPivot(parent,id)
	local obj = parent:GetRootEvent():GetCacheduserdata(id)
	if not obj then return end
	return obj.pivot
end




function _M.GetName(parent,id)
	local obj = parent:GetRootEvent():GetCacheduserdata(id)
	if not obj then return end
	return obj.name	
end




function _M.FindTransform(parent,path)
	local obj = UnityEngine.GameObject.Find(path)
	if obj then
		local rectform = obj:GetComponent(typeof(UnityEngine.RectTransform))
		if rectform then
			return parent:GetRootEvent():AddCacheduserdata(rectform,'UnityEngine.RectTransform')
		end 
	end
end

function _M.TransformActive(parent,id)
	local active = false
	local obj = UnityEngine.GameObject.Find(id)
	if obj then
		active = obj.activeSelf
	end
	return active
end

return _M
