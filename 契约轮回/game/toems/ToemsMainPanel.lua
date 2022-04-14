---
--- Created by  Administrator
--- DateTime: 2020/7/23 9:39
---
ToemsMainPanel = ToemsMainPanel or class("ToemsMainPanel", WindowPanel)
local this = ToemsMainPanel

function ToemsMainPanel:ctor(parent_node, parent_panel)
    self.abName = "toems"
    self.assetName = "ToemsMainPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.panel_type = 2;
    self.model = ToemsModel:GetInstance()
    self.sidebar_data = {
        { text = "Totem", id = 1, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n",
          show_lv = GetSysOpenDataById("200@1"),
          show_task = GetSysOpenTaskById("200@1"),
          open_lv = GetSysOpenDataById("200@1"),
          open_task = GetSysOpenTaskById("200@1"),
        },

        --{ text = ConfigLanguage.Beast.OTHER, id = 2, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", },
    }
    --ToemsMainPanel.super.Load(self)
end

function ToemsMainPanel:dctor()
    self.model:RemoveTabListener(self.events)
    if self.ToemsInfoPanel then
        self.ToemsInfoPanel:destroy()
        self.ToemsInfoPanel = nil
    end
end

function ToemsMainPanel:Open(data)
    self.data = data;
    WindowPanel.Open(self)
end

function ToemsMainPanel:LoadCallBack()
    self.nodes = {

    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    self:SetTileTextImage("toems_image", "Toems_title_1");
    BagController:GetInstance():RequestBagInfo(BagModel.toems);
    self:UpdateReddot();

end

function ToemsMainPanel:UpdateReddot()
    if self.model:IsMainReddot() then
        self:SetIndexRedDotParam(1, true);
    else
        self:SetIndexRedDotParam(1, false);
    end
end

function ToemsMainPanel:InitUI()

end

function ToemsMainPanel:AddEvent()
    self.events[#self.events + 1] = self.model:AddListener(ToemsEvent.UpdateRedDot, handler(self, self.UpdateReddot))
end

function ToemsMainPanel:SwitchCallBack(index, toggle_id, update_toggle)
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    --self.currentView = nil;
    if index == 1 then
        self.ToemsInfoPanel = self.ToemsInfoPanel or ToemsPanel(self.child_transform)
        self.selectedIndex = 1;
        self:PopUpChild(self.ToemsInfoPanel);

        self.is_show_money = { Constant.GoldType.Gold, Constant.GoldType.BGold, Constant.GoldType.Coin }
        self.bg_win:SetMoney(self.is_show_money)

    end

end