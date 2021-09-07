-- 角色加坐骑
MixRoleRideLoader = MixRoleRideLoader or BaseClass()

function MixRoleRideLoader:__init(classes, sex, looks, callback, noWing, layer)

    self.classes = classes
    self.sex = sex
    self.looks = looks
    self.callback = callback
    self.noWing = noWing  -- 不需要翅膀
    self.layer = layer
    if self.layer == nil then self.layer = "ModelPreview" end

    self.roleTpose = nil
    self.roleAnimationData = nil
    self.headTpose = nil
    self.headAnimationData = nil
    self.rideTpose = nil
    self.rideAnimationData = nil

    self.roleLoader = MixRoleWingLoader.New(self.classes, self.sex, self.looks, function(tpose, animationData, headTpose, headAnimationData)
        self:OnRoleTposeLoaded(animationData, tpose, headAnimationData, headTpose) end, self.noWing, self.layer, true)
end

function MixRoleRideLoader:__delete()
    if self.roleLoader ~= nil then
        self.roleLoader:DeleteMe()
        self.roleLoader = nil
    end
    
    if self.rideLoader ~= nil then
        self.rideLoader:DeleteMe()
        self.rideLoader = nil
    end

    self.roleTpose = nil
    self.roleAnimationData = nil
    self.headTpose = nil
    self.headAnimationData = nil
    self.rideTpose = nil
    self.rideAnimationData = nil

    self.callback = nil
end

function MixRoleRideLoader:OnRoleTposeLoaded(animationData, tpose, headAnimationData, headTpose)
    self.roleTpose = tpose
    self.roleAnimationData = animationData
    self.headTpose = headTpose
    self.headAnimationData = headAnimationData
    self.animationData = animationData

    -- if self.callback ~= nil then
    --     self.callback(self.roleTpose, self.animationData, self.headTpose, self.headAnimationData)
    -- end
    self.roleLoader = RideTposeLoader.New(self.classes, self.sex, self.looks, function(ride, rideAnimationData, ridePoolData) 
        self:OnRideTposeLoaded(ride, rideAnimationData, ridePoolData) end)
end

function MixRoleRideLoader:OnRideTposeLoaded(ride, rideAnimationData)
    self.rideTpose = ride
    self.rideAnimationData = rideAnimationData

    local path = BaseUtils.GetChildPath(ride.transform, "bp_body")
    local bind = ride.transform:Find(path)
    if bind ~= nil then
        local t = self.roleTpose:GetComponent(Transform)
        t:SetParent(bind)
        t.localPosition = Vector3(0, 0, 0)
        t.localRotation = Quaternion.identity
        -- t:Rotate(Vector3(90, 270, 0))
        t.localScale = Vector3(1, 1, 1)
        Utils.ChangeLayersRecursively(t, "Model")

        self.tposeAnimator = self.roleTpose:GetComponent(Animator)
    end

    if self.callback ~= nil then
        self.callback(self.rideTpose, self.rideAnimationData, self.headTpose, self.headAnimationData, self.roleTpose, self.roleAnimationData)
    end
end