-- 
-- @Author: LaoY
-- @Date:   2018-07-20 14:39:08
-- 
RoleInfoPanel = RoleInfoPanel or class("RoleInfoPanel", WindowPanel)
local RoleInfoPanel = RoleInfoPanel
local ConfigLanguage = require('game.config.language.CnLanguage');
function RoleInfoPanel:ctor()
    self.abName = "roleinfo"
    self.assetName = "RoleInfoPanel"
    self.layer = "UI"

    self.events = {}
    self.show_sidebar = true        --是否显示侧边栏
    self.panel_type = 2;
    --if self.show_sidebar then
    --    -- 侧边栏配置
    --    self.sidebar_data = {
    --        { text = ConfigLanguage.Custom.Message, id = 1, icon = "roleinfo:img_message_icon_1", dark_icon = "roleinfo:img_message_icon_2", },
    --        { text = ConfigLanguage.Vision.XING_PAN, id = 2, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n", },
    --        { text = ConfigLanguage.Vision.FA_BAO, id = 3, icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n", },
    --        { text = ConfigLanguage.Vision.WEAPON, id = 4, icon = "bag:bag_icon_hs_s", dark_icon = "bag:bag_icon_hs_n", },
    --    }
    --end

    self.model = RoleInfoModel:GetInstance()
end

function RoleInfoPanel:dctor()
    for i, v in pairs(self.events) do
        GlobalEvent:RemoveListener(v)
    end

    if self.updatereddotevent then
        RemoveModelListener(self.updatereddotevent, MountModel:GetInstance());
    end
end

function RoleInfoPanel:Open(subid)
    self.default_table_index = subid or 1;
    WindowPanel.Open(self)
end

function RoleInfoPanel:LoadCallBack()
    self.nodes = {
        "role_panel", "role_info", "vision"
    }
    self:GetChildren(self.nodes)

    self:LoadRolePanel();

    self:AddEvent()

    self:UpdateRedDot()
end

function RoleInfoPanel:AddEvent()


    self.events[#self.events + 1] = GlobalEvent:AddListener(BagEvent.CloseBagPanel, handler(self, self.DealClosePanel))

    self.events[#self.events + 1] = GlobalEvent:AddListener(RoleInfoEvent.UpdateRedDot, handler(self, self.UpdateRedDot))
    self.updatereddotevent = MountModel:GetInstance():AddListener(MountEvent.UpdateRedDot, handler(self, self.UpdateRedDot));
end

function RoleInfoPanel:UpdateRedDot()
    --for i = 1, #self.model.red_dot_list do
    --
    --end
    for i, v in pairs(self.model.red_dot_list) do
        if i == 1 then
            if v then
                self:SetIndexRedDotParam(i, true)
            else
                self:SetIndexRedDotParam(i, false)
            end
        else
            if v or MountModel:GetInstance():GetReddotState(i) then
                self:SetIndexRedDotParam(i, true)
            else
                self:SetIndexRedDotParam(i, false)
            end
        end
    end
end

function RoleInfoPanel:DealClosePanel()
    self:Close()
end

function RoleInfoPanel:LoadRolePanel()
    --self.show_panel = BagRolePanel(self.role_panel,"UI")
end

function RoleInfoPanel:OpenCallBack()
    self:UpdateView()
end

function RoleInfoPanel:UpdateView()

end

function RoleInfoPanel:CloseCallBack()
    if self.show_panel then
        self.show_panel:destroy()
        self.show_panel = nil
    end

    if self.info_panel then
        self.info_panel:destroy()
        self.info_panel = nil
    end

    if self.vision_panel then
        self.vision_panel:destroy()
        self.vision_panel = nil
    end
end

function RoleInfoPanel:SwitchCallBack(index)
    -- Notify.ShowText(index)
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    if index == 1 then
        if not self.info_panel then
            self.info_panel = RoleInfoShowPanel(self.role_info)
        else
            self.info_panel:InitUI();
            --self.info_panel:InitProperty()
        end
        self:PopUpChild(self.info_panel)
        self:SetTileTextImage("roleinfo_image", "roleinfo_title");
    elseif index == 2 or index == 3 or index == 4 then
        if not self.vision_panel then
            self.vision_panel = VisionPanel(self.vision, index - 1)
        else
            self.vision_panel:SwitchCallBack(index - 1);
        end
        self:PopUpChild(self.vision_panel)
        if index == 2 then
            self:SetTileTextImage("roleinfo_image", "wing_title");
        elseif index == 3 then
            self:SetTileTextImage("roleinfo_image", "talis_title");
        elseif index == 4 then
            self:SetTileTextImage("roleinfo_image", "weapon_title");
        end
    end
end