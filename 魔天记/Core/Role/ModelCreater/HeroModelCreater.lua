require "Core.Role.ModelCreater.RoleModelCreater"
HeroModelCreater = class("HeroModelCreater", RoleModelCreater);


function HeroModelCreater:New(data, parent,  asyncLoad, onLoadedSource,withRide)
    self = { };
    setmetatable(self, { __index = HeroModelCreater });

    self._withRide = true
    if (withRide ~= nil) then
        self._withRide = withRide
    end
    if (asyncLoad ~= nil) then
        self.asyncLoadSource = asyncLoad
    else
        self.asyncLoadSource = true
    end
    self.onLoadedSource = onLoadedSource
    self.hasCollider = false
    self._isWingActive = true
    self._projectorVisible = AutoFightManager.IsShowShadow()
    self.showShadow = not self._projectorVisible
    self:Init(data, parent, true);
    self:ProjectorVisible(self._projectorVisible)
    return self;
end

function HeroModelCreater:_OnUpdatePart(modelType, part)
    if modelType == ModelType.Body or modelType == ModelType.Weapon or modelType == ModelType.Wing then
        self._roleAvtar:ChangeShader(part)
    end
end
 
 
function HeroModelCreater:ProjectorVisible(val)
    self._projectorVisible = val
    if not self._projector then
        self._projector = Resourcer.Get("Prefabs/Others", "SimpleProjectorShadow")
        self._projectorBehaviour = self._projector:GetComponent("SimpleShadowProjector")
        self._projectorBehaviour.trfTarget = self._parent
        self._projectorBehaviour:SetCullingMask(LayerMask.GetMask(Layer.Hero ))
        GameObject.DontDestroyOnLoad(self._projector)
    end
    if self._projector then self._projector:SetActive(val) end
end
function HeroModelCreater:SetShadowDirction(val)
    if val and self._projectorBehaviour then
        self._projectorBehaviour.projectorAngle = Vector3(val[1], val[2], 0)
        self._projectorBehaviour:UpdateAngle()
    end
end
function HeroModelCreater:_CanPoolMode()
    return false --????????shader
end

function HeroModelCreater:_SetRideCreater(rideCreater)
    --Warning("_SetRideCreater,==" ..tostring(rideCreater) )
    if rideCreater then
        rideCreater:SetHeroShader()
    end
end


function HeroModelCreater:_Dispose()
    if self._projector then GameObject.Destroy(self._projector) end    
end