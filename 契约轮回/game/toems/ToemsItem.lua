---
--- Created by  Administrator
--- DateTime: 2020/7/27 11:25
---
ToemsItem = ToemsItem or class("ToemsItem", BaseCloneItem)
local this = ToemsItem

function ToemsItem:ctor(obj, parent_node, parent_panel,tab)
    self.events = {}
    self.data = tab;
    ToemsItem.super.Load(self)
   -- logError(Table2String(self.data))
end

function ToemsItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.awardItem then
        self.awardItem:destroy();
    end
    self.awardItem = nil;
    if self.reddot then
        self.reddot:destroy();
    end
    self.reddot = nil;
end

function ToemsItem:LoadCallBack()
    self.nodes = {
        "selected", "base_score", "item_name", "normal", "assist", --"icon",
        "frame", "frame/icon","toemsName",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
end

function ToemsItem:InitUI()
    self.selected = GetImage(self.selected);
    self.base_score = GetText(self.base_score);
    self.item_name = GetText(self.item_name);
    self.normal = GetImage(self.normal);
    self.assist = GetImage(self.assist);
    self:SetIsSelected(false);
    self.icon_1 = GetImage(self.icon);
    self.frame = GetImage(self.frame);
    SetGameObjectActive(self.assist, false);
    if self.data then
        if self.data.name then
           local colorStr = ColorUtil.GetColor(self.data.color)
           self.item_name.text = "<color=#" .. colorStr .. ">" .. tostring(self.data.name) .. "</color>";
           -- self.item_name.text = tostring(self.data.name);
        else
            if self.toemsName then
                SetVisible(self.toemsName,true)
                self.toemsName = GetText(self.toemsName)
            end
            local tCfg = Config.db_totems[self.data.beastID]
            if tCfg then
                local tColor = tCfg.color
                local tcolorStr = ColorUtil.GetColor(tColor)
                self.toemsName.text = "<color=#" .. tcolorStr .. ">" .. tostring(tCfg.name) .. "</color>"
            end


            local itemConfig = Config.db_item[self.data.id];
            local equipConfig = Config.db_totems_equip[self.data.id];
            local colorStr = "666666";

            if itemConfig.color > 1 then
                colorStr = ColorUtil.GetColor(itemConfig.color)
            end
            self.item_name.text = "<color=#" .. colorStr .. ">" .. tostring(itemConfig.name) .. "</color>";--BeastModel.FONTCOLOR[itemConfig.color]

            local param = {}
            local operate_param = {}
            param["cfg"] = Config.db_totems_equip[self.data.id]
            param["p_item"] = self.data;
            param["can_click"] = true
            --param["out_call_back"] = callback
            param["operate_param"] = operate_param

            if self.awardItem then
                self.awardItem:destroy();
            end
            self.awardItem = GoodsIconSettorTwo(self.icon.transform);
            self.awardItem:SetIcon(param)
        end
    end
    self.reddot = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
    self.reddot:SetPosition(-46, 28);
end

function ToemsItem:Refresh()
    if self.data then
        if self.data.name then
           -- self.item_name.text = tostring(self.data.name);
            local colorStr = ColorUtil.GetColor(self.data.color)
            self.item_name.text = "<color=#" .. colorStr .. ">" .. tostring(self.data.name) .. "</color>";
        else
            local itemConfig = Config.db_item[self.data.id];
            local equipConfig = Config.db_totems_equip[self.data.id];
            local colorStr = "666666";
            if itemConfig.color > 1 then
                colorStr = ColorUtil.GetColor(itemConfig.color)
            end
            self.item_name.text = "<color=#" .. colorStr .. ">" .. tostring(itemConfig.name) .. "</color>";--BeastModel.FONTCOLOR[itemConfig.color]

            local param = {}
            local operate_param = {}
            param["cfg"] = Config.db_totems_equip[self.data.id]
            param["p_item"] = self.data;
            param["can_click"] = true
            param["operate_param"] = operate_param

            if self.awardItem then
                self.awardItem:destroy();
            end
            self.awardItem = nil;
            self.awardItem = GoodsIconSettorTwo(self.icon.transform);
            self.awardItem:SetIcon(param);
        end
    end
end

function ToemsItem:AddEvent()

end

function ToemsItem:SetIcon(iconid)
    --if self.icon then
    lua_resMgr:SetImageTexture(self, self.icon_1, "toems_image", self.data.id, true);

    --else
    --    self.iconid = iconid;
    --end

end
function ToemsItem:SetColor(color)
    if self.frame then
        lua_resMgr:SetImageTexture(self, self.frame, "common_image", "com_icon_bg_" .. color, false);
    end
end

function ToemsItem:SetScoreText(str)
    self.base_score.text = str;
    if string.isNilOrEmpty(str) then
        SetLocalPositionXY(self.item_name.transform, 60, 0);
    end
end

function ToemsItem:SetIsSelected(bool)
    bool = toBool(bool);
    if self.selected then
        SetGameObjectActive(self.selected, bool);
    end
end

function ToemsItem:SetIsAssist(bool)
    bool = toBool(bool);
    if self.assist then
        SetGameObjectActive(self.assist, bool);
    end
end
function ToemsItem:SetGray(bool)
    bool = toBool(bool);
    if bool then
        if self.data.name then
            self.item_name.text = "<color=#" .. ColorUtil.GetColor(ColorUtil.ColorType.GrayWhite) .. ">" .. tostring(self.data.name) .. "</color>";
        else
            local itemConfig = Config.db_item[self.data.id];
            self.item_name.text = "<color=#" .. ColorUtil.GetColor(ColorUtil.ColorType.GrayWhite) .. ">" .. tostring(itemConfig.name) .. "</color>";
        end
    else
        if self.data.name then
            local colorStr = ColorUtil.GetColor(self.data.color)
            self.item_name.text = "<color=#" .. colorStr .. ">" .. tostring(self.data.name) .. "</color>";
           -- self.item_name.text = tostring(self.data.name);
        else
            local itemConfig = Config.db_item[self.data.id];
            self.item_name.text = tostring(itemConfig.name);
        end
    end

    if self.awardItem then
        self.awardItem:SetIconGray(bool);
    else
        if bool then
            ShaderManager:GetInstance():SetImageGray(self.icon_1);
            ShaderManager:GetInstance():SetImageGray(self.frame);
        else
            ShaderManager:GetInstance():SetImageNormal(self.icon_1);
            ShaderManager:GetInstance():SetImageNormal(self.frame);
        end
    end
end

function ToemsItem:ShowReddot(bool)
    bool = toBool(bool);
    self.reddot:SetRedDotParam(bool);
end



