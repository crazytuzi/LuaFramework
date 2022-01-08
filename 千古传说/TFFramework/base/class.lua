--[[--

Creating a copy of an table with fully replicated properties.

**Usage:**

    -- Creating a reference of an table:
    local t1 = {a = 1, b = 2}
    local t2 = t1
    t2.b = 3    -- t1 = {a = 1, b = 3} <-- t1.b changed

    -- Createing a copy of an table:
    local t1 = {a = 1, b = 2}
    local t2 = clone(t1)
    t2.b = 3    -- t1 = {a = 1, b = 2} <-- t1.b no change


@param mixed object
@return mixed

]]
function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

local objectCount = 0
local function getObjectCount()
    objectCount = objectCount + 1
    return objectCount
end
--[[--

Create an class.

**Usage:**

    local Shape = class("Shape")

    -- base class
    function Shape:ctor(shapeName)
        self.shapeName = shapeName
        printf("Shape:ctor(%s)", self.shapeName)
    end

    function Shape:draw()
        printf("draw %s", self.shapeName)
    end

    --

    local Circle = class("Circle", Shape)

    function Circle:ctor()
        Circle.super.ctor(self, "circle")   -- call super-class method
        self.radius = 100
    end

    function Circle:setRadius(radius)
        self.radius = radius
    end

    function Circle:draw()                  -- overrideing super-class method
        printf("draw %s, raidus = %0.2f", self.shapeName, self.raidus)
    end

    --

    local Rectangle = class("Rectangle", Shape)

    function Rectangle:ctor()
        Rectangle.super.ctor(self, "rectangle")
    end

    --

    local circle = Circle.new()             -- output: Shape:ctor(circle)
    circle:setRaidus(200)
    circle:draw()                           -- output: draw circle, radius = 200.00

    local rectangle = Rectangle.new()       -- output: Shape:ctor(rectangle)
    rectangle:draw()                        -- output: draw rectangle


@param string classname
@param table|function super-class
@return table

]]
function class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
            cls.ctor = function() end
        end

        cls.__cname = classname
        cls.__ctype = 1

        function cls:new(...)
            local instance = cls.__create(...)
            instance.id = getObjectCount()
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = clone(super)
            cls.super = super
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls:new(...)
            local instance = {}
            instance.id = getObjectCount()
            instance.class = cls
            setmetatable(instance, cls)
            instance:ctor(...)
            return instance
        end
    end

    function cls:create(...)
        return cls:new(...)
    end
    
    return cls
end

function instanceOf(cls)
    if cls and type(cls) == 'table' and cls.__cname then
        return cls.__cname
    end
    return NONE_CLASS
end

function iskindof(obj, className)
    local t = type(obj)

    if t == "table" then
        local mt = getmetatable(obj)
        while mt and mt.__index do
            if mt.__index.__cname == className then
                return true
            end
            mt = mt.super
        end
        return false

    elseif t == "userdata" then

    else
        return false
    end
end


--[[
    this is a class like OO language
    
]]
function CLASS(classname, super)
    local superType = type(super)
    local cls

    if super then
        cls = setmetatable({}, {__index = super})
        cls.super = super
    else
        cls = {ctor = function() end, _define = function() end}
    end

    cls.__cname = classname

    local func               
    cls.__newindex = function(o, k, v)
        func = cls['set__' .. k]
        if func then func(o, v)
        else rawset(o, k, v) end
    end
    cls.__index = function(o, k)
        func = cls['get__' .. k]
        if func then return func(o, k) end
        if cls[k] then return cls[k] end
        return rawget(o, k)
    end

    function cls:new(...)
        local instance = setmetatable({}, cls)
        instance.id = getObjectCount()
        instance.class = cls   

        local funcs = {}
        local super = cls 
        while super do 
            if super.super == nil or super._define ~= super.super._define then super._define(instance, ...) end
            if super.super == nil or super.ctor ~= super.super.ctor then table.insert(funcs, 1, super.ctor) end
            super = super.super
        end
        for i = 1, #funcs do 
            funcs[i](instance, ...)
        end
        return instance
    end

    function cls:create(...)
        return self:new(...)
    end

    function cls:isClass(classObj)
        local cls = self.class
        while cls do 
            if cls == classObj then return true end
            cls = cls.super
        end
        return false
    end 
    return cls
end

Component = CLASS