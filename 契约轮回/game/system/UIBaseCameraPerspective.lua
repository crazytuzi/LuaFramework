---
--- Created by R2D2.
--- DateTime: 2019/4/4 14:40
---
UIBaseCameraPerspective = UIBaseCameraPerspective or class("UIBaseCameraPerspective", BaseWidget)
local this = UIBaseCameraPerspective

function UIBaseCameraPerspective:ctor(parent_node, builtin_layer)
    self.abName = "system"
    self.assetName = "UIModelCameraViewPerspective"
end

function UIBaseCameraPerspective:dctor()
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

function UIBaseCameraPerspective:LoadCallBack()
    self.nodes = {
        "dragview", "Parent", "Parent/Camera"
    }
    self:GetChildren(self.nodes)
    self:CheckLayerIndex()

    SetLocalPositionZ(self.Parent, ((self.layerIndex or 1) - 1) * 1000)

    self.modelParent = self.Parent
    self.rawImage = self.transform:GetComponent("RawImage");
    self.drag_rect = GetRectTransform(self.dragview)

    local texture = CreateRenderTexture()
    self.CameraComponent = self.Camera:GetComponent("Camera")
    self.CameraComponent.targetTexture = texture
    self.rawImage.texture = texture
    self.rawTexture = texture

    self:InitUI()
    self:SetTouchable()

    if (self.grayValue ~= nil) then
        self:SetGray(self.grayValue)
    end
end

---检察层级
function UIBaseCameraPerspective:CheckLayerIndex()
    if (self.layerIndex == nil) then
        local _, uiOrder = self:GetParentOrderIndex()

        if (uiOrder and type(uiOrder) == "number") then
            self.layerIndex = (uiOrder % 100) / 20
        else
            self.layerIndex = 1
        end
    end
end

function UIBaseCameraPerspective:InitUI()
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

function UIBaseCameraPerspective:SetGray(bool)
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
function UIBaseCameraPerspective:SetSizeId(sizeId)
    self.sizeId = sizeId or 1
    if (self.UIModel) then
        self:LoadModelCallBack()
    end
end

---设置是否可以划动
function UIBaseCameraPerspective:SetTouchable(isTouchable)
    if (isTouchable) then
        self.isTouchable = toBool(isTouchable)
    end

    self.dragImage.enabled = self.isTouchable
end

---设置拖动热区大小
function UIBaseCameraPerspective:SetDragViewSize(width, height)
    SetSizeDelta(self.drag_rect, width, height)
end

function UIBaseCameraPerspective:SetDragViewPosition(x, y)
    SetAnchoredPosition(self.drag_rect, x, y)
end

---设置模型旋转
function UIBaseCameraPerspective:SetModelRotationY(rotation)
    self.UIModel.transform:Rotate(0, rotation, 0);
end

-----更换角色
--function UIBaseCameraPerspective:ReLoadModel(roleInfoModel)
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

