-- @author 黄耀聪
-- @date 2017年8月31日, 星期四

ExquisiteShelfIcon = ExquisiteShelfIcon or BaseClass(BasePanel)

function ExquisiteShelfIcon:__init(parent)
    self.parent = parent
    self.name = "ExquisiteShelfIcon"

    self.resList = {
        {file = AssetConfig.exquisite_shelf_mainui, type = AssetType.Main},
        {file = AssetConfig.exquisite_shelf_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ExquisiteShelfIcon:__delete()
    self.OnHideEvent:Fire()
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    self:AssetClearAll()
end

function ExquisiteShelfIcon:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exquisite_shelf_mainui))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.text = t:Find("Text"):GetComponent(Text)
    self.text.color = Color(1, 1, 0)

    self.renderers = self.gameObject:GetComponentsInChildren(CanvasRenderer, true)
end

function ExquisiteShelfIcon:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ExquisiteShelfIcon:OnOpen()
    self:RemoveListeners()
    self.text.text = self.openArgs or ""
    self:SetAlpha(1)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function ExquisiteShelfIcon:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function ExquisiteShelfIcon:RemoveListeners()
end

function ExquisiteShelfIcon:Disappear(frame)
    if self.timerId == nil then
        self.counter = frame
        self.timerId = LuaTimer.Add(0, 44, function()
            self.counter = self.counter - 1 self:SetAlpha(self.counter / frame)
            if self.counter == 0 then
                LuaTimer.Delete(self.timerId)
                self.timerId = nil
                self:Hiden()
            end
        end)
    end
end

function ExquisiteShelfIcon:SetAlpha(alpha)
    if self.renderers ~= nil then
        for _,renderer in pairs(self.renderers) do
            renderer:SetAlpha(alpha)
        end
    end
end
