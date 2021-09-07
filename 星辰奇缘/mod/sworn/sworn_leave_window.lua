-- @author 黄耀聪
-- @date 2016年10月22日

-- 结拜请离窗口

SwornLeaveWindow = SwornLeaveWindow or BaseClass(BaseWindow)

function SwornLeaveWindow:__init(model)
    self.model = model
    self.name = "SwornLeaveWindow"

    self.resList = {

    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SwornLeaveWindow:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SwornLeaveWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab())
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t
end

function SwornLeaveWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SwornLeaveWindow:OnOpen()
    self:RemoveListeners()
end

function SwornLeaveWindow:OnHide()
    self:RemoveListeners()
end

function SwornLeaveWindow:RemoveListeners()
end


