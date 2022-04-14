---
--- Created by  Administrator
--- DateTime: 2019/11/20 11:29
---
CompeteRewardMainPanel = CompeteRewardMainPanel or class("CompeteRewardMainPanel", WindowPanel)
local this = CompeteRewardMainPanel

function CompeteRewardMainPanel:ctor(parent_node, parent_panel)
    self.abName = "compete"
    self.image_ab = "compete_image";
    self.assetName = "CompeteRewardMainPanel"
    self.layer = "UI"
    self.panel_type = 2;
    self.events = {};
    self.selectedIndex = 1;
    self.model = CompeteModel:GetInstance()
end

function CompeteRewardMainPanel:dctor()
    --GlobalEvent:RemoveTabListener(self.events)
    if self.rewardPanel then
        self.rewardPanel:destroy();
    end
    self.rewardPanel = nil;

end

function CompeteRewardMainPanel:Open(tabIndex, toggle_id, iscross)
    WindowPanel.Open(self)
    tabIndex = tabIndex or 1;
    self.default_table_index = tabIndex;
    self.default_toggle_index = toggle_id or 1;
    self.isCross = iscross;
end

function CompeteRewardMainPanel:LoadCallBack()
    self.nodes = {

    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()

    self:SetTileTextImage("compete_image", "compete_title3");
    self:SwitchCallBack(1, self.default_toggle_index, true);
end

function CompeteRewardMainPanel:InitUI()

end

function CompeteRewardMainPanel:AddEvent()

end

function CompeteRewardMainPanel:ShowToggleGroup(toggle_id, data)
    self:CreateToggleGroup();
    if self.toggle_group then
        self.toggle_group:SetData(data, toggle_id)
    end
end

function CompeteRewardMainPanel:SwitchCallBack(index, toggle_id, update_toggle)
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    self.view = nil
    --self:SetTabIndex(1,true);
    if index == 1 then
        if  self.model.isCross then
            if toggle_id == 2 then
                if not self.rewardPanel then
                    self.rewardPanel = CompeteRewardPanel(self.child_transform, "UI",toggle_id);
                end
                self.rewardPanel:UpdateInfo(toggle_id)
                self.view = self.rewardPanel;
            elseif toggle_id == 3 then
                if not self.rewardPanel then
                    self.rewardPanel = CompeteRewardPanel(self.child_transform, "UI",toggle_id);
                end
                self.rewardPanel:UpdateInfo(toggle_id)
                self.view = self.rewardPanel;

            elseif toggle_id == 4 then
                if not self.rewardPanel then
                    self.rewardPanel = CompeteRewardPanel(self.child_transform, "UI",toggle_id);
                end
                self.rewardPanel:UpdateInfo(toggle_id)
                self.view = self.rewardPanel;

            elseif toggle_id == 1 then
                if not self.rewardPanel then
                    self.rewardPanel = CompeteRewardPanel(self.child_transform, "UI",toggle_id);
                end
                self.rewardPanel:UpdateInfo(toggle_id, 0)
                self.view = self.rewardPanel;
            end

            if update_toggle then
                local data = {
                    { id = 1, text = "Ranking Rewards" },
                    { id = 2, text = "Heaven list victory reward" },
                    { id = 3, text = "Earth list victory reward" },
                    { id = 4, text = "Knockout stage reward" },
                }
                self:ShowToggleGroup(toggle_id, data)
            end
        else
            if toggle_id == 2 then
                if not self.rewardPanel then
                    self.rewardPanel = CompeteRewardPanel(self.child_transform, "UI",toggle_id);
                end
                self.rewardPanel:UpdateInfo(toggle_id)
                self.view = self.rewardPanel;
            elseif toggle_id == 3 then
                if not self.rewardPanel then
                    self.rewardPanel = CompeteRewardPanel(self.child_transform, "UI",toggle_id);
                end
                self.rewardPanel:UpdateInfo(toggle_id)
                self.view = self.rewardPanel;

            elseif toggle_id == 4 then
                if not self.rewardPanel then
                    self.rewardPanel = CompeteRewardPanel(self.child_transform, "UI",toggle_id);
                end
                self.rewardPanel:UpdateInfo(toggle_id)
                self.view = self.rewardPanel;
            elseif toggle_id == 1 then
                if not self.rewardPanel then
                    self.rewardPanel = CompeteRewardPanel(self.child_transform, "UI",toggle_id);
                end
                self.rewardPanel:UpdateInfo(toggle_id, 1)
                self.view = self.rewardPanel;
            end

            if update_toggle then
                local data = {
                    { id = 1, text = "Ranking Rewards" },
                    { id = 2, text = "Heaven list victory reward" },
                    { id = 3, text = "Earth list victory reward" },
                    { id = 4, text = "Knockout stage reward" },

                }
                self:ShowToggleGroup(toggle_id, data)
            end
        end

    else
        --print2(index);
    end
    self:PopUpChild(self.view)
end