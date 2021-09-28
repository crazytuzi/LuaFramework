--Filename:ModuleUtil.lua
--Author：bzx
--Date：2014.08.01
--Purpose:module工具集

module("ModuleUtil", package.seeall)
   
--require "script/ModulePaths.lua"

local _is_open_auto_load = false

-- 开启自动加载module
function openAutoLoadModule()
    if g_debug_mode ~= true then
        return
    end
    local mt = {}
    mt.__index = function(t, k)
        print(k)
        print("mt.__index")
        local module_path = ModulePaths.getModulePathByName(k)
        if module_path == nil then
            return nil
        end
        require(module_path)
        return _G[k]
    end
    setmetatable(_G, mt)
    _is_open_auto_load = true
end

-- 关闭自动加载module
function closeAutoLoadModule()
    if g_debug_mode ~= true then
        return
    end
    setmetatable(_G, nil)
    _is_open_auto_load = false
end

-- 删除所有已经加载的module
function cleanupAllModules()
    if g_debug_mode ~= true then
        return
    end
    if _is_open_auto_load == true then
        require "script/utils/AutoLoadModule"
        AutoLoadModule.closeAutoLoadModule()
    end
    print("删除所有module中")
    local module_paths = ModulePaths.getModulePaths()
    for k, v in pairs(module_paths) do
        local module_name = k
        local module_path = ModulePaths.getModulePathByName(module_name)
        if _G[module_name] ~= nil then
            _G[module_name] = nil
            package.loaded[module_name] = nil
            package.loaded[module_path] = nil
            print(module_name, "=", module_path)
        end
    end
    print("所有module删除完毕")
    if _is_open_auto_load == true then
        require "script/utils/AutoLoadModule"
        AutoLoadModule.openAutoLoadModule()
    end
end

-- 根据module名来删除指定的module
function cleanupModuleByName(module_name, path)
    if g_debug_mode ~= true then
        return
    end
    _G[module_name] = nil
    package.loaded[module_name] = nil
    local module_path = path

    package.loaded[module_path] = nil
    print(string.format("%s删除完毕", module_name))
end