require "Core.Role.ModelCreater.BaseModelCreater"
ObjectModelCreater = class("ObjectModelCreater", BaseModelCreater);

function ObjectModelCreater:New(data, parent, asyncLoad, onLoadedSource)
    self = { };
    setmetatable(self, { __index = ObjectModelCreater });
    if (asyncLoad ~= nil) then
        self.asyncLoadSource = asyncLoad
    else
        self.asyncLoadSource = true
    end
    self.onLoadedSource = onLoadedSource
    self.hasCollider = true
    self.showShadow = true
    self:Init(data, parent);
    return self;
end

--
function ObjectModelCreater:_Init(data)
    self.onEnableOpen = true
    self.model_id = "Object/" .. data.model;
end
 
function ObjectModelCreater:_GetModern()
    return "Prefabs", self.model_id;
end

function ObjectModelCreater:_GetSourceDir()
    return "Npc"
end

function ObjectModelCreater:GetDefaultAction()
    return "sleep"
end

function ObjectModelCreater:_GetModelDefualt()
    return "";
end

function ObjectModelCreater:GetCheckAnimation()
    local hasAnim = self._parent.gameObject:GetComponent("Animator");
    if hasAnim then
        return true;
    else
        return false;
    end
end

