--
-- Author: LaoY
-- Date: 2018-06-30 15:27:32
-- 模拟面向对象 原型来自cocos2dx

require "Common/ClassCacheManager"

--by cocos LuaFramework
--类的数量
class_count = class_count or 0
--key class_count 
class_map = class_map or {}

--实例对象
obj_count = obj_count or 0
--key obj_count
obj_map = obj_map or {}
--key class
obj_v_map = obj_v_map or {}

--每个类作为父类的引用次数 key 是class
super_v_map = super_v_map or {}

setmetatable(class_map, {__mode = "v"})
setmetatable(obj_v_map, {__mode = "k"})
setmetatable(obj_map, {__mode = "k"})
-- setmetatable(super_v_map, {__mode = "k"})

local class_count = class_count
local class_map = class_map
local obj_v_map = obj_v_map
local obj_map = obj_map
local super_v_map = super_v_map

local setmetatable = setmetatable
local debug_getinfo = debug.getinfo

-- BaseMessage 用的和这里一样的
--构造函数
local function ctor(cls, obj, ...)
    if cls.super then
        ctor(cls.super, obj, ...)
    end
    if rawget(cls,"ctor") then
        cls.ctor(obj, ...)
    end
end

--析构函数（假的），得手动调用
local function dctor(this)
    if this.is_dctored then
        return
    end
    this.is_dctored = true
    local cls = this._class_type 
    while cls ~= nil do
        if rawget(cls,"dctor") then
            cls.dctor(this)
        end
        cls = cls.super
    end
end

--[[
    @author LaoY
    @des    模拟面向对象 不支持多继承
    /*生成对象的方法说明*/
    @func   new     生成对象    自动方法
    @func   ctor    构造函数    手动实现
    @func   destroy 销毁对象    自动方法
    @func   dctor   析构函数    手动方法
    /*以下为缓存机制*/
    @param  __cache_count 缓存对象的数量 不为空且大于0 触发缓存机制 &&需手动配置
                          *注意，父类的缓存数量会影响派生类
    @func   __clear 添加进缓存调用函数      手动方法
    @func   __reset 获取缓存对象调用函数    手动方法 带的参数和new一样
--]]
function class(classname, super)
    local cls = {}
    cls.__cname = classname
    class_count = class_count + 1
    class_map[class_count] = cls

    local cls_obj_ins_map = {}
    obj_v_map[cls] = cls_obj_ins_map
    setmetatable(cls_obj_ins_map, {__mode = "v"})

    obj_map[cls] = 0
    -- cls._source = debug_getinfo(2, "Sl").source
    cls.super = super

    if super then
        if super_v_map[super.__cname] == nil then
            super_v_map[super.__cname] = 0
        end
        super_v_map[super.__cname] = super_v_map[super.__cname] + 1
        -- super_v_map[super] = super_v_map[super] or {}
        -- super_v_map[super][#super_v_map[super] + 1] = cls.__cname
    end

    function cls.new(self,...)
        if cls.__cache_count and cls.__cache_count > 0 then
            local cache_obj = ClassCacheManager:GetInstance():GetClassCache(cls.__cname)
            if cache_obj then
                if cache_obj.__reset then
                    cache_obj:__reset(...)
                end
                return cache_obj
            end
        end
        obj_count = obj_count + 1
        local obj = {}
         if type(self) == "table" and self ~= cls then
            obj = self
        end
        if cls.initDefault then
            obj = cls:initDefault()
        end
        setmetatable(obj, {__index = cls})
        obj._class_type = cls
        obj._id = obj_count
        obj.is_dctored = false
        cls_obj_ins_map[obj_count] = obj
        obj_map[cls] = obj_map[cls] + 1

        obj.destroy = function(this)
            if this.is_dctored or this.__is_clear then
                return
            end
            if cls.__cache_count and cls.__cache_count > 0 then
                if not ClassCacheManager:GetInstance():IsHasCacheInfo(this.__cname) then
                    ClassCacheManager:GetInstance():AddClassCacheInfo(this.__cname,this.__cache_count)
                end
                if not ClassCacheManager:GetInstance():AddClassCache(this) then
                    cls_obj_ins_map[this._id] = nil
                    dctor(this)
                end
            else
                cls_obj_ins_map[this._id] = nil
                dctor(this)
            end
        end
        ctor(cls, obj, ...)
        return obj
    end

    if super then
        -- 优化__index -- 待测试
        local function indexFunc(t, k)
            local ret = super[k]
            cls[k] = ret
            return ret
        end
        setmetatable(cls, {__index = indexFunc,__call = cls.new})
        -- setmetatable(cls, {__index = super,__call = cls.new})
    else
        setmetatable(cls, {__call = cls.new})
    end
    cls.__index = cls

    if TestDestroy then
        if iskindof(cls,"Node") then
            TestDestroyClassList[#TestDestroyClassList+1] = cls.__cname
        end
    end
    return cls
end

--[[--
如果对象是指定类或其子类的实例，返回 true，否则返回 false
local Animal = class("Animal")
local Duck = class("Duck", Animal)
print(iskindof(Duck.new(), "Animal")) -- 输出 true
~~~
@param mixed obj 要检查的对象
@param string classname 类名
@return boolean
]]
function iskindof(obj, classname)
    -- local t = type(obj)
    --local mt = getmetatable(obj)
	local mt = obj
    while mt do
        if mt.__cname == classname then
            return true
        end
        mt = mt.super
    end
    return false
end

--[[
    @author LaoY
    @des    是否为class生成的类
    @param1 obj
--]]
function isClass(obj)
    if type(obj) == "userdata" then
        return false
    else
        return obj.__cname ~= nil
    end
end
--[[
    @author LaoY
    @des    重置类
    @param1 cls class类
--]]
function ResetClass(cls)
    if not cls.initDefault then
        return
    end
    for k,v in pairs(cls:initDefault()) do
        cls[k] = v
    end
    return
end

function sortClassFunc(class1,class2)
    return class1._id < class2._id
end