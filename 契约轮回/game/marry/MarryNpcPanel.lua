---
--- Created by  Administrator
--- DateTime: 2019/6/10 17:56
---
MarryNpcPanel = MarryNpcPanel or class("MarryNpcPanel", BasePanel)
local this = MarryNpcPanel

function MarryNpcPanel:ctor(parent_node, parent_panel)
    self.abName = "marry"
    self.assetName = "MarryNpcPanel"
    self.layer = LayerManager.LayerNameList.UI

    self.use_background = true
    self.change_scene_close = true
    self.click_bg_close = true
    self.is_hide_other_panel = true
    self.events = {}
    self.model = MarryModel:GetInstance()
    self.role =  RoleInfoModel.GetInstance():GetMainRoleData()
end

function MarryNpcPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.npc_model then
        self.npc_model:destroy()
        self.npc_model = nil
    end
end

function MarryNpcPanel:Open(npcID)
    self.npcId = npcID
    self.db = Config.db_npc[npcID]
    MarryNpcPanel.super.Open(self)
end


function MarryNpcPanel:LoadCallBack()
    self.nodes = {
        "closeBtn","marryBtn","divorceBtn","shopBtn","guestBtn","appBtn",
    }
    self:GetChildren(self.nodes)
    self:InitUI()
    self:AddEvent()
end

function MarryNpcPanel:InitUI()

end

function MarryNpcPanel:AddEvent()
    
    local function call_back()  --离婚
        if self.role.marry == 0 then
            Notify.ShowText("You don't have a spouse")
            return
        end
        lua_panelMgr:GetPanelOrCreate(MarryDivorcePanel):Open()
        self:Close()
    end
    AddClickEvent(self.divorceBtn.gameObject,call_back)

    local function call_back()  --结婚
        lua_panelMgr:GetPanelOrCreate(MarryPropPanel):Open()
        self:Close()
    end
    AddClickEvent(self.marryBtn.gameObject,call_back)

    local function call_back()  --
       -- lua_panelMgr:GetPanelOrCreate(MarryPropPanel):Open()
        lua_panelMgr:GetPanelOrCreate(WeddingShopPanel):Open()
        self:Close()
    end
    AddClickEvent(self.shopBtn.gameObject,call_back)

    local function call_back()  --预约
        if not self.model:IsMarry() then
            Notify.ShowText("You don't have a spouse")
            return
        end
         lua_panelMgr:GetPanelOrCreate(WeddingAppointmentPanel):Open()
        self:Close()
    end

    AddClickEvent(self.appBtn.gameObject,call_back)


    
    local function call_back()  --宾客管理
        if self.model:IsAppointment() or self.model.isAppointment == true then
            lua_panelMgr:GetPanelOrCreate(WeddingInvitationPanel):Open()
            self:Close()
            --Notify.ShowText("您当前没有可邀请宾客的婚礼待举办！")
            return
        end
        Notify.ShowText("No wedding of your invited guests is being held!")
       -- lua_panelMgr:GetPanelOrCreate(WeddingInvitationPanel):Open()

    end
    AddClickEvent(self.guestBtn.gameObject,call_back)

    local function call_back()
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject,call_back)
end

