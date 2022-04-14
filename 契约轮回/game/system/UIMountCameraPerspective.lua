---
--- Created by R2D2.
--- DateTime: 2019/4/4 11:18
---
UIMountCameraPerspective = UIMountCameraPerspective or class("UIMountCameraPerspective", UIBaseCameraPerspective)
local this = UIMountCameraPerspective

function UIMountCameraPerspective:ctor(parent_node, builtin_layer, model_id, stype, sizeId, isTouchable, layerIndex, effect_id)

    self.model_id = model_id
    self.sizeId = sizeId or 1
    self.layerIndex = layerIndex
    self.stype = stype or enum.ITEM_STYPE.ITEM_STYPE_MOUNT_MORPH;

    if type(isTouchable) == "boolean" then
        self.isTouchable = isTouchable
    else
        self.isTouchable = true
    end
    self.effect_id = effect_id

    UIMountCameraPerspective.super.Load(self)
end

function UIMountCameraPerspective:dctor()
    if self.UIModel ~= nil then
        self.UIModel:destroy()
        self.UIModel = nil
    end
    if self.ui_effect then
        self.ui_effect:destroy()
    end
end

function UIMountCameraPerspective:LoadCallBack()
    UIBaseCamera.LoadCallBack(self)
    SetLocalPositionX(self.Camera.transform, self.cameraX or 2000);
    SetLocalPositionY(self.Camera.transform, self.cameraY or 0);
    SetLocalPositionZ(self.Camera.transform, self.cameraZ or 0);
    self:LoadModel()
end

function UIMountCameraPerspective:LoadModel()
    if (self.model_id) then
        self:LoadRoleModel(self.model_id)
    end
end

function UIMountCameraPerspective:LoadRoleModel(model_id)
    if self.stype == enum.ITEM_STYPE.ITEM_STYPE_MOUNT_MORPH then
        self.UIModel = UIMountModel(self.modelParent, model_id, handler(self, self.LoadModelCallBack));
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_WING_MORPH then
        self.UIModel = UIWingModel(self.modelParent, model_id, handler(self, self.LoadModelCallBack));
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_TALIS_MORPH then
        self.UIModel = UIFabaoModel(self.modelParent, model_id, handler(self, self.LoadModelCallBack));
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_WEAPON_MORPH then
        self.UIModel = UIWingModel(self.modelParent, model_id, handler(self, self.LoadModelCallBack), "model_weapon_", "model_weapon_r_");
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_OFFHAND_MORPH then
        self.UIModel = UIMountModel(self.modelParent, model_id, handler(self, self.LoadModelCallBack));
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_GOD_MORPH then
        self.UIModel = UIMountModel(self.modelParent, model_id, handler(self, self.LoadModelCallBack));
    else
        self.UIModel = UIMountModel(self.modelParent, model_id, handler(self, self.LoadModelCallBack));
    end

end

function UIMountCameraPerspective:LoadModelCallBack()
    local config = Config.db_ui_role[self.sizeId];
    local zPos = config and config.zPos or 410

    SetLocalPosition(self.UIModel.transform, -2000, -110, zPos);
    SetLocalRotation(self.UIModel.transform, 9, 180, 0);

    if self.effect_id then
        self.ui_effect = UIEffect(self.UIModel.transform, self.effect_id)
        self.ui_effect:SetConfig({ scale = 0.01 })
    end

    if self.is_need_setConfig then
        self:ApplyConfig()
    end

    if self.stype == enum.ITEM_STYPE.ITEM_STYPE_MOUNT_MORPH then

    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_WING_MORPH then
        self.UIModel:AddAnimation({ "show", "idle" }, false, "idle", 0)
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_TALIS_MORPH then
        self.UIModel:AddAnimation({ "show", "idle" }, false, "idle", 0)
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_WEAPON_MORPH then
        self.UIModel:AddAnimation({ "show", "idle2" }, false, "idle2", 0)
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_OFFHAND_MORPH then
        self.UIModel:AddAnimation({ "show", "idle" }, false, "idle", 0)
    elseif self.stype == enum.ITEM_STYPE.ITEM_STYPE_GOD_MORPH then
        self.UIModel:AddAnimation({ "idle" }, false, "idle", 0)
    else
    end
end

function UIMountCameraPerspective:ReLoadPet(model_id)
    if self.UIModel then
        self.UIModel:destroy()
    end
    self:LoadRoleModel(model_id)

    --if self.UIModel == nil then
    --    self:LoadRoleModel(model_id)
    --else
    --    self.UIModel:destroy()
    --    self.UIModel:ReLoadData(model_id,  handler(self, self.LoadModelCallBack))
    --end
end

---config可用参数
---config.offset = {x, y, z}
---config.pos = {x, y , z}
---config.scale = {x} or {x, y } or  {x, y , z}
---config.rotate = {x, y , z}
function UIMountCameraPerspective:SetConfig(config)
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

function UIMountCameraPerspective:ApplyConfig()
    self.is_need_setConfig = false

    if self.config.offset then
        local offset = self.config.offset
        local posX, posY, posZ = GetLocalPosition(self.UIModel.transform)
        SetLocalPosition(self.UIModel.transform, posX + offset.x, posY + offset.y, posZ-offset.z);
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

    self.cameraPos = self.config.cameraPos or {}
    self.cameraX = self.cameraPos.x or 2000;
    self.cameraY = self.cameraPos.y or 0;
    self.cameraZ = self.cameraPos.z or -155;

    SetLocalPositionX(self.Camera.transform, self.cameraX);
    SetLocalPositionY(self.Camera.transform, self.cameraY);
    SetLocalPositionZ(self.Camera.transform, self.cameraZ);

    if self.config.far then
        local camera = GetCamera(self.Camera)
        if camera then
            camera.farClipPlane = tonumber(self.config.far);
        end
    end

    if self.config.rotate then
        local rotate = self.config.rotate
        SetLocalRotation(self.UIModel.transform, rotate.x, rotate.y, rotate.z);
    end
end