GameObject = {}
local  lasttime = 0
local frame = 0
-- lua逻辑太多用GameObject.Instantiate接口，现暂时用这方式统一处理
function GameObject.Instantiate(prefab)
	return PrefabPool.Instance:Instantiate(prefab)
end

local mt = {}
mt.__index = function (tbl, key)
	return UnityEngine.GameObject[key]
end

setmetatable(GameObject, mt)
