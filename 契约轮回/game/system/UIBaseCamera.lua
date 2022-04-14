---
--- Created by R2D2.
--- DateTime: 2019/4/4 14:40
---
UIBaseCamera = UIBaseCamera or class("UIBaseCamera", BaseWidget)
local this = UIBaseCamera

function UIBaseCamera:ctor(parent_node, builtin_layer)
    self.abName = "system"
    self.assetName = "UIModelCameraView"
end

function UIBaseCamera:dctor()
    self.modelParent = nil
    if self.CameraComponent then
        self.CameraComponent.targetTexture = nil
    end
    if self.rawImage then
        self.rawImage.texture = nil
        ReleseRenderTexture(self.rawTexture)
        self.rawTexture = nil
    end 
end

function UIBaseCamera:LoadCallBack()
    self.nodes = {
        "dragview", "Parent", "Parent/Camera","raw_con"
    }
    self:GetChildren(self.nodes)
    self:CheckLayerIndex()

    SetLocalPositionZ(self.Parent, ((self.layerIndex or 1) - 1) * 1000)

    self.modelParent = self.Parent
    if self.raw_con then
        self.rawImage = self.raw_con.transform:GetComponent("RawImage");
    else
        self.rawImage = self.transform:GetComponent("RawImage");
    end
    self.drag_rect = GetRectTransform(self.dragview)

    local texture = CreateRenderTexture()
    self.CameraComponent = self.Camera:GetComponent("Camera")
    self.CameraComponent.targetTexture = texture
    self.rawImage.texture = texture
    self.rawTexture = texture

    if not PlatformManager:GetInstance():IsMobile() then
        self.rawImage.material.shader = ShaderManager.GetInstance():GetShaderByName(ShaderManager.ShaderNameList.Default)
        self.rawImage.material.shader = Shader.Find("UI/Default No-Alpha")
    end

    self:InitUI()
    self:SetTouchable()

    if (self.grayValue ~= nil) then
        self:SetGray(self.grayValue)
    end
end

---检察层级
function UIBaseCamera:CheckLayerIndex()
    if (self.layerIndex == nil) then
        local _, uiOrder = self:GetParentOrderIndex()

        if (uiOrder and type(uiOrder) == "number") then
            self.layerIndex = (uiOrder % 100) / 20
        else
            self.layerIndex = 1
        end
    end
end

function UIBaseCamera:InitUI()
    self.dragImage = GetImage(self.dragview)
    self.lastX = 0

    local call_back = function(target, x, y)
        if self.lastX == 0 then
            self.lastX = x;
            return ;
        end
        local x1 = x - self.lastX;
        self.UIModel.transform:Rotate(0, -x1, 0);
        self.lastX = x;
    end
    AddDragEvent(self.dragview.gameObject, call_back)

    local call_back = function(target, x, y)
        self.lastX = 0;
    end
    AddDragEndEvent(self.dragview.gameObject, call_back)
end

function UIBaseCamera:SetGray(bool)
    if (self.is_loaded) then
        self.grayValue = nil

        if (bool) then
            ShaderManager.GetInstance():SetImageGray(self.rawImage)
        else
            ShaderManager.GetInstance():SetImageNormal(self.rawImage)
        end
    else
        self.grayValue = bool
    end
end

---设置模型尺寸ID（配置表中）
function UIBaseCamera:SetSizeId(sizeId)
    self.sizeId = sizeId or 1
    if (self.UIModel) then
        self:LoadModelCallBack()
    end
end

---设置是否可以划动
function UIBaseCamera:SetTouchable(isTouchable)
    if (isTouchable) then
        self.isTouchable = toBool(isTouchable)
    end

    self.dragImage.enabled = self.isTouchable
end

---设置拖动热区大小
function UIBaseCamera:SetDragViewSize(width, height)
    SetSizeDelta(self.drag_rect, width, height)
end

function UIBaseCamera:SetDragViewPosition(x, y)
    SetAnchoredPosition(self.drag_rect, x, y)
end

---设置模型旋转
function UIBaseCamera:SetModelRotationY(rotation)
    self.UIModel.transform:Rotate(0, rotation, 0);
end

-----更换角色
--function UIBaseCamera:ReLoadModel(roleInfoModel)
--    if self.UIModel == nil then
--        self:LoadRoleModel(roleInfoModel)
--    else
--        local res_id = 11001
--        if roleInfoModel and roleInfoModel.gender then
--            res_id = roleInfoModel.gender == 1 and 11001 or 12001
--        end
--        self.UIModel:ReLoadData({ res_id = res_id }, handler(self, self.LoadModelCallBack))
--    end
--end

