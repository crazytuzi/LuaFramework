---
--- Created by R2D2.
--- DateTime: 2019/5/22 11:59
---

UIModelCommonCamera = UIModelCommonCamera or class("UIModelCommonCamera", UIBaseCamera)
local this = UIModelCommonCamera

function UIModelCommonCamera:ctor(parent_node, builtin_layer, resName, sizeId, isTouchable)

    self.resName = resName
    self.sizeId = sizeId or 1
    if self.sizeId > 10000 then
		self.is_show = true
		self.is_showID = sizeId
		self.sizeId = 1
    else
        self.is_show = false
	end
	
    if type(isTouchable) == "boolean" then
        self.isTouchable = isTouchable
    else
        self.isTouchable = true
    end

    UIModelCommonCamera.super.Load(self)
end

function UIModelCommonCamera:dctor()
    if self.UIModel ~= nil then
        self.UIModel:destroy()
        self.UIModel = nil
    end
end

function UIModelCommonCamera:LoadCallBack()
    UIBaseCamera.LoadCallBack(self)
    self:LoadModel()
end

function UIModelCommonCamera:LoadModel()
	if self.is_show then
		self.UIModel = UIModelManager:GetInstance():InitModel(nil, self.resName, self.modelParent,
			handler(self, self.LoadModelCallBack), true, self.is_showID)
	else
		self.UIModel = UIModelManager:GetInstance():InitModel(nil, self.resName, self.modelParent,
			handler(self, self.LoadModelCallBack), true)
	end

end

function UIModelCommonCamera:LoadModelCallBack()
    local config = Config.db_ui_role[self.sizeId];
    local zPos = config and config.zPos or 410

    SetLocalPosition(self.UIModel.transform, -2000, -110, zPos);
    SetLocalRotation(self.UIModel.transform, 9, 180, 0);

    if self.is_need_setConfig then
        self:ApplyConfig()
    end
end

function UIModelCommonCamera:ReLoad(resName)

    if self.UIModel then
        self.UIModel:destroy()
    end

    self.resName = resName
    self:LoadModel()
end

---config可用参数
---config.pos ={x, y , z}
---config.scale = {x} or {x, y } or  {x, y , z}
---config.rotate = {x, y , z}
function UIModelCommonCamera:SetConfig(config)

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

function UIModelCommonCamera:ApplyConfig()
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
    local trans_x = self.config and self.config.trans_x
    local trans_y = self.config and self.config.trans_y
    if trans_x then
        SetSizeDeltaX(self.transform, trans_x)
    end
    if trans_y then
        SetSizeDeltaY(self.transform, trans_y)
    end
    local carmera_size = self.config and self.config.carmera_size
    if carmera_size then
        self.Camera:GetComponent("Camera").orthographicSize = carmera_size
        SetSizeDelta(self.raw_con.transform,650,650)
    end

    if self.config.trans_offset then
        if self.config.trans_offset.x then
            SetLocalPositionX(self.transform, self.config.trans_offset.x )
        end
        if self.config.trans_offset.y then
            SetLocalPositionY(self.transform, self.config.trans_offset.y )
        end
    end

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