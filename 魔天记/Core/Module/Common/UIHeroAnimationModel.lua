require "Core.Role.ModelCreater.UIRoleModelCreater"

UIHeroAnimationModel = class("UIHeroAnimationModel")

--自动处理英雄换装消息
function UIHeroAnimationModel:New(data, parent,actionName)
    self = { };
    setmetatable(self, { __index = UIHeroAnimationModel });
    self:Init(data, parent,actionName);
    return self;
end

function UIHeroAnimationModel:Init(data, parent,actionName)
    self._actionName = actionName
    self._roleCreater = UIRoleModelCreater:New(data, parent, false,true,function(ctor)
                    self:_onLoadedRole(ctor, roleId);
                end );
    self._roleCreater:SetLayer(Layer.UIModel)
    self:SyncParticleSystemScale()
    MessageManager.AddListener(PlayerManager, PlayerManager.SelfDressChange, UIHeroAnimationModel.ChangeDress, self)
end

function UIHeroAnimationModel:_onLoadedRole(ctor, roleId)
    if (self._roleCreater and self._actionName) then
        self._roleCreater:Play(self._actionName);
    end
end
function UIHeroAnimationModel:SyncParticleSystemScale()
    if self._roleCreater then self._roleCreater:SyncParticleSystemScale()end
end

function UIHeroAnimationModel:Play(name)
    if (name) then self._actionName = name end
    if (self._roleCreater and self._actionName) then
        self._roleCreater:Play(self._actionName);
    end
end

function UIHeroAnimationModel:Dispose()
    MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfDressChange, UIHeroAnimationModel.ChangeDress)
    self._roleCreater:Dispose()
    self._roleCreater = nil
end

function UIHeroAnimationModel:ChangeDress(data)
    if (self._roleCreater ~= nil) then
        if (data ~= nil) then
            if (data.a ~= self._roleCreater.dress.a) then
                self._roleCreater.dress.a = data.a
                self._roleCreater:ChangeWeapon()
            end

            if (data.b ~= self._roleCreater.dress.b) then
                self._roleCreater.dress.b = data.b
                self._roleCreater:ChangeBody(true)
            end

            if (data.w ~= self._roleCreater.dress.w) then
                self._roleCreater.dress.w = data.w
                self._roleCreater:ChangeWing()
            end
        end
    end

    self._roleCreater:SetLayer(Layer.UIModel)
end