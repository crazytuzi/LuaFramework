---
--- Created by  Administrator
--- DateTime: 2019/7/16 21:26
---
MarryChangeHeadPanel = MarryChangeHeadPanel or class("MarryChangeHeadPanel", BasePanel)
local this = MarryChangeHeadPanel

function MarryChangeHeadPanel:ctor(parent_node, parent_panel)
    self.abName = "marry"
    self.assetName = "MarryChangeHeadPanel"
    self.layer = LayerManager.LayerNameList.UI

    self.use_background = true
    self.change_scene_close = true
    self.click_bg_close = true
    self.events = {}
    self.gevents = {}
    self.heads = {}
    self.model = MarryModel:GetInstance()

    --self.role =  RoleInfoModel.GetInstance():GetMainRoleData()
end

function MarryChangeHeadPanel:dctor()
    --if self.roleIcon then
    --    self.roleIcon:destroy()
    --    self.roleIcon = nil
    --end
    self.model:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener(self.gevents)
    for i, v in pairs(self.heads) do
        v:destroy()
    end
    self.heads = {}
    if self.event_id ~= nil then
        RoleInfoModel.GetInstance():GetMainRoleData():RemoveListener(self.event_id)
        self.event_id = nil
    end
    --if self.role_icon then
    --    self.role_icon:destroy()
    --    self.role_icon = nil
    --end
end

function MarryChangeHeadPanel:Open(roleIcon)
    -- dump(roleIcon)
    --self.roleIcon = roleIcon
    MarryChangeHeadPanel.super.Open(self)
end

function MarryChangeHeadPanel:LoadCallBack()
    self.nodes = {
        "MarryChangeHeadItem", "headParent",
        "ok_btn", "closeBtn", "up_btn",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
end

function MarryChangeHeadPanel:InitUI()
    self:InitHeadInfo()
end

function MarryChangeHeadPanel:AddEvent()

    local function call_back()
        --self.headName
        --self.roleIcon:SetLocalIcon(self.selectHead.headName)
        RoleInfoModel.GetInstance():SetLocalIcon(self.selectHead.headName)
    end
    AddButtonEvent(self.ok_btn.gameObject, call_back)

    local function call_back()
        --上传头像
        --self.roleIcon:SetIcon()
        RoleInfoModel.GetInstance():SetIcon()
    end
    AddButtonEvent(self.up_btn.gameObject, call_back)

    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject, call_back)
    local function callback()
        Notify.ShowText("Portrait changed")
        self:Close()
    end
    --self.event_id = RoleInfoModel.GetInstance():GetMainRoleData():BindData("icon", callback)
    self.gevents[#self.events + 1] = GlobalEvent:AddListener(MainEvent.UploadingIconSuccess,callback)
    self.events[#self.events + 1] = self.model:AddListener(MarryEvent.MarryClickHead, handler(self, self.MarryClickHead))
end

function MarryChangeHeadPanel:InitHeadInfo()
    local headNum = 3
    for i = 1, headNum do
        local item = self.heads[i]
        if not item then
            item = MarryChangeHeadItem(self.MarryChangeHeadItem.gameObject, self.headParent, "UI")
            self.heads[i] = item
            --  local param = {}
            --  param['is_hide_frame'] = true
            --  param['size'] = 105
            --  self.role_icon[i] = RoleIcon(self.headParent)
            --  self.role_icon[i]:SetData(param)
        end
        item:SetData(i)
    end

    self:MarryClickHead(1)
end

function MarryChangeHeadPanel:MarryClickHead(index)
    for i = 1, #self.heads do
        if index == i then
            self.selectHead = self.heads[i]
            self.heads[i]:SetSelect(true)
        else
            self.heads[i]:SetSelect(false)
        end
    end
end