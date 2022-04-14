--
-- @Author: CHK
-- @Date:   2018-09-20 11:35:34
--
UIRoleCamera = UIRoleCamera or class("UIRoleCamera", BaseWidget)
local this = UIRoleCamera

---config 可用參數
---{
--- res_id,
--- is_show_wing,
--- is_show_leftHand,
--- is_show_weapon,
--- is_show_head
--- tran_scale
---is_show_before_unloaded   還未加載完頭髮的時候也顯示出來（不會有一個刷新的樣式，但是加載慢的時候，會禿頭）
---is_show_magic    是否显示角色身上的魔法阵
------}
function UIRoleCamera:ctor(parent_node, builtin_layer, roleData, sizeId, isTouchable, roleIndex, config, layerIndex)
    self.abName = "system"
    self.assetName = "UIModelCameraView"

    self.roleData = roleData
    self.sizeId = sizeId or 1
    self.layerIndex = layerIndex
    self.roleIndex = roleIndex
    self.config = config
    if self.config then
        self.y_rotate = config.y_rotate or 180
    else
        self.y_rotate = 180
    end

    if type(isTouchable) == "boolean" then
        self.isTouchable = isTouchable
    else
        self.isTouchable = true
    end

    UIRoleCamera.super.Load(self)
end

function UIRoleCamera:dctor()
    if self.magic_eft then
        self.magic_eft:destroy()
        self.magic_eft = nil
    end
    if self.UIRole ~= nil then
        self.UIRole:destroy()
        self.UIRole = nil
    end
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

function UIRoleCamera:LoadCallBack()
    self.nodes = {
        "dragview",
        "Parent",
        "Parent/Camera",
        "eft_con",
        "raw_con",
    }
    self:GetChildren(self.nodes)
    SetRotation(self.eft_con.transform, 17.35, 0, 0)
    SetLocalPosition(self.eft_con.transform, 13, -232, 0)

    self:CheckLayerIndex()
    self:InitUI()
    self:SetCameraPos()
    self:SetTouchable()
    self:LoadRoleModel()
end

---檢察層級
function UIRoleCamera:CheckLayerIndex()
    if (self.layerIndex == nil) then
        local _, uiOrder = self:GetParentOrderIndex()

        if (uiOrder and type(uiOrder) == "number") then
            self.layerIndex = (uiOrder % 100) / 20
        else
            self.layerIndex = 1
        end
    end
end

function UIRoleCamera:InitUI()
    SetLocalPositionZ(self.Parent, ((self.layerIndex or 1) - 1) * 1000)
    self.modelParent = self.Parent

    local texture = CreateRenderTexture()
    self.rawImage = self.raw_con.transform:GetComponent("RawImage")
    self.CameraComponent = self.Camera:GetComponent("Camera")
    self.CameraComponent.targetTexture = texture
    self.rawImage.texture = texture
    self.rawTexture = texture

    if not PlatformManager:GetInstance():IsMobile() then
        self.rawImage.material.shader = ShaderManager.GetInstance():GetShaderByName(ShaderManager.ShaderNameList.Default)
        self.rawImage.material.shader = Shader.Find("UI/Default No-Alpha")
    end

    self.dragImage = GetImage(self.dragview)
    self.drag_rect = GetRectTransform(self.dragview)

    self.lastX = 0

    local call_back = function(target, x, y)
        if self.lastX == 0 then
            self.lastX = x
            return
        end
        local x1 = x - self.lastX
        self.UIRole.transform:Rotate(0, -x1, 0)
        self.lastX = x
    end
    AddDragEvent(self.dragview.gameObject, call_back)

    local call_back = function(target, x, y)
        self.lastX = 0
    end
    AddDragEndEvent(self.dragview.gameObject, call_back)
end

function UIRoleCamera:AddEvent()
end

function UIRoleCamera:AddLoadCallBack(call_back)
    self.call_back = call_back
end

function UIRoleCamera:LoadRoleModel()
    self.UIRole = UIRoleModel(self.modelParent, handler(self, self.LoadModelCallBack), self.roleData, self.config)
end

function UIRoleCamera:SetCameraPos()
    local offset = self.roleIndex or 1
    SetLocalPosition(self.Camera, -2000 * offset, 0, 0)
end

function UIRoleCamera:LoadModelCallBack()
    local config = Config.db_ui_role[self.sizeId]
    local zPos = config and config.zPos or 410
    local yPos = self.config and self.config.yPos or -110
    local xPos = self.config and self.config.xPos or 0
    local offset = self.roleIndex or 1
    local trans_x = self.config and self.config.trans_x
    local trans_y = self.config and self.config.trans_y

    if self.config and self.config.trans_offset then
        if self.config.trans_offset.x then
            SetLocalPositionX(self.raw_con.transform, self.config.trans_offset.x)
        end
        if self.config.trans_offset.y then
            SetLocalPositionY(self.raw_con.transform, self.config.trans_offset.y)
        end
    end

    SetLocalPosition(self.UIRole.transform, -2000 * offset + xPos, yPos, zPos)
    SetLocalRotation(self.UIRole.transform, 9, self.y_rotate, 0)
    if trans_x then
        SetSizeDeltaX(self.raw_con.transform, trans_x)
    end
    if trans_y then
        SetSizeDeltaY(self.raw_con.transform, trans_y)
    end

    if (self.isWingVisible) then
        self.UIRole:SetWingVisible(self.isWingVisible)
        self.isWingVisible = nil
    end

    ---加载仙女阵
    if self.config and self.config.is_show_magic then
        if self.magic_eft then
            self.magic_eft:destroy()
            self.magic_eft = nil
        end
        if self.roleData.figure then
            local magic_data = self.roleData.figure.fashion_footprint or nil
            if magic_data then
                local model = magic_data.model
                self.magic_eft = UIEffect(self.eft_con, model, false, "UI")
                self.magic_eft:SetConfig({ is_loop = true })
                if not self.is_setted_layer then
                    local _, parent_order_index = self:GetParentOrderIndex()
                    LayerManager.GetInstance():AddOrderIndexByCls(self, self.raw_con.transform, nil, true, parent_order_index + 2)
                    self.is_setted_layer = true
                end
            end
        end
    end
    if self.call_back then
        self.call_back()
    end
    self.call_back = nil
end

---設置模型尺寸ID（配置表中）
function UIRoleCamera:SetSizeId(sizeId)
    self.sizeId = sizeId or 1
    if (self.UIRole) then
        self:LoadModelCallBack()
    end
end

---設置是否可以劃動
function UIRoleCamera:SetTouchable(isTouchable)
    if (isTouchable) then
        self.isTouchable = toBool(isTouchable)
    end

    self.dragImage.enabled = self.isTouchable
end

---設置拖動熱區大小
function UIRoleCamera:SetDragViewSize(width, height)
    SetSizeDelta(self.drag_rect, width, height)
end

function UIRoleCamera:SetDragViewPosition(x, y)
    SetAnchoredPosition(self.drag_rect, x, y)
end

---更換角色
function UIRoleCamera:ReLoadModel(roleData)
    self.roleData = roleData

    if self.UIRole == nil then
        self:LoadRoleModel()
    else
        self.UIRole:ReLoadData(self.roleData, handler(self, self.LoadModelCallBack), self.config)
    end
end

function UIRoleCamera:SetWingVisible(flag)
    if (self.UIRole) then
        self.UIRole:SetWingVisible(flag)
    else
        self.isWingVisible = flag
    end
end

---設置模型旋轉
function UIRoleCamera:SetModelRotationY(rotation)
    self.UIRole.transform:Rotate(0, rotation, 0)
end

function UIRoleCamera:SetAnimation(ani_list, is_loop, defa_ani, delay)
    self.UIRole:AddAnimation(ani_list, is_loop, defa_ani, delay)
end
