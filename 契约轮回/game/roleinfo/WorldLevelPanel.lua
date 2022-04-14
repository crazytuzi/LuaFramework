---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by win 10.
--- DateTime: 2018/9/20 11:18
---

WorldLevelPanel = WorldLevelPanel or class("WorldLevelPanel", WindowPanel)
local this = WorldLevelPanel

function WorldLevelPanel:ctor(parent_node, layer)
    self.abName = "roleinfo"
    self.assetName = "WorldLevelPanel"
    self.layer = "UI"
    self.events = {};

    self.panel_type = 4;
end

function WorldLevelPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    destroyTab(self.items)
    self.items = {};
end

function WorldLevelPanel:Open()
    WindowPanel.Open(self)
end
--等级达到100级且低于世界等级一定等级即可享受杀怪经验加成福利!
--世界等级:   <color=#3CA712>巅峰422</color>
--经验加成:   <color=#3CA712>0</color>
function WorldLevelPanel:LoadCallBack()
    self.nodes = {
        "world_level", "exp_add", "des",
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, -1000);
    AddBgMask(self.gameObject);

    self:SetTileTextImage("roleinfo_image", "role_info_world_level_title");

    self:InitUI();
    self:AddEvent();
    RoleInfoController:GetInstance():RequestWorldLevel();
end

function WorldLevelPanel:AddEvent()

    local callback = function(level)
        print2(level);
        local final_lv = GetLevelShow(level)
        --local final_lv = level
        self.world_level.text = "World Level:   <color=#3CA712>" .. final_lv .. "</color>";
        local mainRoleLevel = tonumber(RoleInfoModel:GetInstance():GetMainRoleLevel());
        if mainRoleLevel < 120 then
            return ;
        end
        local dif = mainRoleLevel - tonumber(level);
        for k, v in pairs(Config.db_world_level) do
            if dif >= v.min_lv and dif <= v.max_lv then
                self.exp_add.text = "EXP Bonus:   <color=#3CA712>" .. (v.coef / 100) .. "%" .. "</color>";
            end
        end

    end
    AddEventListenerInTab(RoleInfoEvent.QUERY_WORLD_LEVEL, callback, self.events);
end

function WorldLevelPanel:InitUI()
    self.world_level = GetText(self.world_level);
    self.exp_add = GetText(self.exp_add);
    self.des = GetText(self.des);
end