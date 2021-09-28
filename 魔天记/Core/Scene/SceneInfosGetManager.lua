--[[
  场景数据管理去
]]

SceneInfosGetManager = class("SceneInfosGetManager");

function SceneInfosGetManager:New(o)
    o = o or { };
    setmetatable(o, { __index = self });
    o.cp_manager = MoTianJi.Scene.SceneInfoGetManager.New();
    return o;
end 

SceneInfosGetManager._ins = nil;

function SceneInfosGetManager.Get_ins()
    if SceneInfosGetManager._ins == nil then
        SceneInfosGetManager._ins = SceneInfosGetManager:New();
    end

    return SceneInfosGetManager._ins;
end


--  return array
function SceneInfosGetManager:GetMountLangInfos()
    local info_str = self.cp_manager:GetMountLangInfos();
    local obj = loadstring(info_str)();

    return obj;
end 

function SceneInfosGetManager:StringToArray(int_str)
    local info_str = self.cp_manager:StringToArray(int_str);
    local obj = loadstring(info_str)();
    return obj;
end

function SceneInfosGetManager:StringTonString(int_str)
    local info_str = self.cp_manager:StringTonString(int_str);
    return info_str;
end

function SceneInfosGetManager:SpildString(int_str)
    local index = 1;
    local res = { };

    for w in string.gmatch(int_str, "(%w+)") do
        res[index] = w;
        index = index + 1;
    end

    return res;

end

-- "1656_1660"
function SceneInfosGetManager:GetRandom(int_str)
    
    local arr = string.split(int_str, '_')
    local n = arr[1]+0;
    local m=arr[2]+0;
    return math.Random(n, m);
end
