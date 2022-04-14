---
--- Created by R2D2.
--- DateTime: 2019/4/4 11:18
---
UIPetCamera = UIPetCamera or class("UIPetCamera", UIBaseCamera)
local this = UIPetCamera

function UIPetCamera:ctor(parent_node, builtin_layer, petId, sizeId, isTouchable, layerIndex, effect_id)

    self.petId = petId
    self.sizeId = sizeId or 1
    self.layerIndex = layerIndex

    if type(isTouchable) == "boolean" then
        self.isTouchable = isTouchable
    else
        self.isTouchable = true
    end
    self.effect_id = effect_id

    UIPetCamera.super.Load(self)
end

function UIPetCamera:dctor()
    if self.UIModel ~= nil then
        self.UIModel:destroy()
        self.UIModel = nil
    end
    if self.ui_effect then
        self.ui_effect:destroy()
    end
end

function UIPetCamera:LoadCallBack()
    UIBaseCamera.LoadCallBack(self)

    self:LoadModel()
end

function UIPetCamera:LoadModel()
    if (self.petId) then
        self:LoadRoleModel(self.petId)
    end
end

function UIPetCamera:LoadRoleModel(petId)
    self.UIModel = UIPetModel(self.modelParent, petId, handler(self, self.LoadModelCallBack));
end

function UIPetCamera:LoadModelCallBack()
    local config = Config.db_ui_role[self.sizeId];
    local zPos = config and config.zPos or 410

    SetLocalPosition(self.UIModel.transform, -3000, -110, zPos);
    SetLocalPosition(self.Camera.transform, -3000, self.Camera.localPosition.y, self.Camera.localPosition.z);
    SetLocalRotation(self.UIModel.transform, 9, 180, 0);

    if self.effect_id then
        self.ui_effect = UIEffect(self.UIModel.transform, self.effect_id)
        self.ui_effect:SetConfig({ scale = 0.01 })
    end

    if self.is_need_setConfig then
        self:ApplyConfig()
    end
end

function UIPetCamera:ReLoadPet(petId)
    if self.UIModel then
        self.UIModel:destroy()
    end
    self:LoadRoleModel(petId)

    --if self.UIModel == nil then
    --    self:LoadRoleModel(petId)
    --else
    --    self.UIModel:destroy()
    --    self.UIModel:ReLoadData(petId,  handler(self, self.LoadModelCallBack))
    --end
end

---config可用参数
---config.offset = {x, y, z}
---config.pos = {x, y , z}
---config.scale = {x} or {x, y } or  {x, y , z}
---config.rotate = {x, y , z}
function UIPetCamera:SetConfig(config)
    self.config = config or self.config

    if not self.config then
        return
    end

    if self.is_loaded and self.UIModel.is_loaded then
        self.is_need_setConfig = false
        self:ApplyConfig()
    else
        self.is_need_setConfig = true
    end
end

function UIPetCamera:ApplyConfig()
    self.is_need_setConfig = false

    if self.config.offset then
        local offset = self.config.offset
        local posX, posY, posZ = GetLocalPosition(self.UIModel.transform)
        SetLocalPosition(self.UIModel.transform, posX + offset.x, posY + offset.y, posZ + offset.z);
    end

    if self.config.pos then
        local pos = self.config.pos
        SetLocalPosition(self.UIModel.transform, pos.x, pos.y, pos.z);
    end

    if self.config.scale then
        local scale = self.config.scale
        if type(scale) == "number" then
            SetLocalScale(self.UIModel.transform, scale, scale, scale)
        elseif type(scale) == "table" then
            if scale.z == nil then
                scale.z = scale.x
            end
            if scale.y == nil then
                scale.y = scale.x
            end

            SetLocalScale(self.UIModel.transform, scale.x, scale.y, scale.z)
        else
            SetLocalScale(self.UIModel.transform, 1, 1, 1)
        end
    end

    if self.config.rotate then
        local rotate = self.config.rotate
        SetLocalRotation(self.UIModel.transform, rotate.x, rotate.y, rotate.z);
    end
end