---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by win 10.
--- DateTime: 2018/10/10 14:55
---
GuwuPanel = GuwuPanel or class("GuwuPanel", WindowPanel)
local this = GuwuPanel

GuwuPanel.ONE_KEY_OPEN_DAY = 0;

function GuwuPanel:ctor(parent_node, layer)
    self.abName = "dungeon"
    self.assetName = "GuwuPanel"
    self.layer = "Bottom"
    self.events = {};

    self.panel_type = 4;
end

function GuwuPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events);
end

function GuwuPanel:Open()
    WindowPanel.Open(self)
end

function GuwuPanel:LoadCallBack()
    self.nodes = {
        "stime", "gvalue", "sbtn", "gbtn", "svalue", "gtime", "zsgw/every_diamond", "jbgw/every_gold", "gbtn/gtext", "sbtn/stext",
    }
    self:GetChildren(self.nodes)
    AddBgMask(self.gameObject);

    self:SetTileTextImage("dungeon_image", "dungeon_guwu_title");

    SetLocalPosition(self.transform, 0, 0, -1000);

    self.sbtn = GetButton(self.sbtn);
    self.stext = GetText(self.stext);
    self.gbtn = GetButton(self.gbtn);
    self.gtext = GetText(self.gtext);
    self.stime = GetText(self.stime);
    self.gtime = GetText(self.gtime);

    self.every_gold = GetToggle(self.every_gold);
    self.every_gold.isOn = DungeonModel:GetInstance().isOneKeyGuwuGold;
    self.every_diamond = GetToggle(self.every_diamond);
    self.every_diamond.isOn = DungeonModel:GetInstance().isOneKeyGuwuDiamond;

    local openDay = LoginModel:GetInstance():GetOpenTime();
    --print2("已开服天数 : " .. tostring(openDay));
    if openDay and tonumber(openDay) >= GuwuPanel.ONE_KEY_OPEN_DAY then
        self.gtext.text = "Quick inspiration";
        self.stext.text = "Quick inspiration";
    else
        SetGameObjectActive(self.every_gold.gameObject, false);
        SetGameObjectActive(self.every_diamond.gameObject, false);
    end

    if DungeonModel:GetInstance().dungeonInfo then
        local data = DungeonModel:GetInstance().dungeonInfo;
        self.stime.text = data.coin_inspire .. "/5";
        self.gtime.text = data.gold_inspire .. "/5";

        if data.coin_inspire == 0 then
            SetButtonEnable(self.sbtn, false);
        else
            SetButtonEnable(self.sbtn, true);
        end

        if data.gold_inspire == 0 then
            SetButtonEnable(self.gbtn, false);
        else
            SetButtonEnable(self.gbtn, true);
        end
    end

    self:AddEvent();
end

function GuwuPanel:AddEvent()
    local openDay = LoginModel:GetInstance():GetOpenTime();
    local call_back = function()
        if not DungeonModel:GetInstance().dungeonInfo or tonumber(DungeonModel:GetInstance().dungeonInfo.coin_inspire or 0) <= 0 then
            Notify.ShowText("Not enough attempts");
            return ;
        end
        local coin = RoleInfoModel:GetInstance():GetMainRoleData()[Constant.GoldType.Coin] or 0;
        if openDay and tonumber(openDay) >= GuwuPanel.ONE_KEY_OPEN_DAY then
            if coin < 100 then
              --  Notify.ShowText("金币不够,请充值");
                local str = string.format("Not enough gold \n Use<color=#3ab60e>%s diamonds to </color>inspire？\n(5 diamonds/once)", DungeonModel:GetInstance().dungeonInfo.coin_inspire * 5)
                Dialog.ShowTwo("Tip", str, "Confirm", handler(self, self.BuyDiamond), nil, "Cancel", nil, nil)
            else
                for i = 1, DungeonModel:GetInstance().dungeonInfo.coin_inspire do
                    if coin >= 100 then
                        DungeonCtrl:GetInstance():RequestInspire(1);
                        coin = coin - 100;
                    end
                end
            end
        else
            if coin < 100 then
               -- Notify.ShowText("金币不够,请充值");
                local str = string.format("Not enough gold \n Use<color>%s diamonds to </color>inspire？\n(5 diamonds/once)", 5)
                Dialog.ShowTwo("Tip", str, "Confirm", handler(self, self.BuyDiamond), nil, "Cancel", nil, nil)
            else
                DungeonCtrl:GetInstance():RequestInspire(1);
            end

        end
        local panel = lua_panelMgr:GetPanel(ExpDungeonPanel);
        if panel then
            panel:HideGuwuBtn();
        end
    end

    AddClickEvent(self.sbtn.gameObject, call_back);

    local call_back1 = function()
        if not DungeonModel:GetInstance().dungeonInfo or tonumber(DungeonModel:GetInstance().dungeonInfo.gold_inspire or 0) <= 0 then
            Notify.ShowText("Not enough attempts");
            return ;
        end

        local diamond = RoleInfoModel:GetInstance():GetMainRoleData()[Constant.GoldType.Gold] or 0;
        local bdiamond = RoleInfoModel:GetInstance():GetMainRoleData()[Constant.GoldType.BGold] or 0;
        local totaldiamond = diamond + bdiamond;
        if openDay and tonumber(openDay) >= GuwuPanel.ONE_KEY_OPEN_DAY then
            if totaldiamond < 10 then
                Notify.ShowText("Insufficient Diamond, please top-up");
            else
                for i = 1, DungeonModel:GetInstance().dungeonInfo.gold_inspire do
                    if totaldiamond >= 10 then
                        DungeonCtrl:GetInstance():RequestInspire(2);
                        totaldiamond = totaldiamond - 10;
                    end

                end
            end
        else
            if totaldiamond < 10 then
                Notify.ShowText("Insufficient Diamond, please top-up");
            else
                DungeonCtrl:GetInstance():RequestInspire(2);
            end
        end
        local panel = lua_panelMgr:GetPanel(ExpDungeonPanel);
        if panel then
            panel:HideGuwuBtn();
        end
    end

    AddClickEvent(self.gbtn.gameObject, call_back1);

    AddClickEvent(self.every_diamond.gameObject, handler(self, self.HandleAutoDiamond));
    AddClickEvent(self.every_gold.gameObject, handler(self, self.HandleAutoGold));
end

function GuwuPanel:HandleAutoDiamond(gameObject, x, y)
    --self.every_diamond.isOn = not self.every_diamond.isOn;
    DungeonModel:GetInstance().isOneKeyGuwuDiamond = self.every_diamond.isOn;
    CacheManager:GetInstance():SetBool("DungeonModel.isOneKeyGuwuDiamond", DungeonModel:GetInstance().isOneKeyGuwuDiamond);
end

function GuwuPanel:HandleAutoGold(gameObject, x, y)
    --self.every_gold.isOn = not self.every_gold.isOn;
    DungeonModel:GetInstance().isOneKeyGuwuGold = self.every_gold.isOn;
    CacheManager:GetInstance():SetBool("DungeonModel.isOneKeyGuwuGold", DungeonModel:GetInstance().isOneKeyGuwuGold);
end

function GuwuPanel:UpdateCount(coin_inspire, gold_inspire)
    if self.is_dctored then
        return
    end
    if self.stime then
        self.stime.text = coin_inspire .. "/5";
    end
    if self.gtime then
        self.gtime.text = gold_inspire .. "/5";
    end
    if self.sbtn and not IsGameObjectNull(self.sbtn.gameObject) then
        if coin_inspire == 0 then
            SetButtonEnable(self.sbtn, false);
        else
            SetButtonEnable(self.sbtn, true);
        end
    end

    if self.gbtn and not IsGameObjectNull(self.gbtn.gameObject) then
        if gold_inspire == 0 then
            SetButtonEnable(self.gbtn, false);
        else
            SetButtonEnable(self.gbtn, true);
        end
    end
end

function GuwuPanel:BuyDiamond()
    local openDay = LoginModel:GetInstance():GetOpenTime();
    local diamond = RoleInfoModel:GetInstance():GetMainRoleData()[Constant.GoldType.Gold] or 0;
  --  local bdiamond = RoleInfoModel:GetInstance():GetMainRoleData()[Constant.GoldType.BGold] or 0;
   -- local totaldiamond = diamond + bdiamond;
    if openDay and tonumber(openDay) >= GuwuPanel.ONE_KEY_OPEN_DAY then
        local all = DungeonModel:GetInstance().dungeonInfo.coin_inspire * 5
        if diamond < all  then
            if diamond >= 5 then
                for i = 1, DungeonModel:GetInstance().dungeonInfo.coin_inspire do
                    if diamond >= 5 then
                        DungeonCtrl:GetInstance():RequestInspire(1);
                        diamond = diamond - 5;
                    end
                end
            else
                local function call_back()
                    GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
                end
                Dialog.ShowTwo("Tip", "You don't have enough diamonds, top-up now?", "Confirm", call_back, nil, "Cancel", nil, nil)
            end
        else
            for i = 1, DungeonModel:GetInstance().dungeonInfo.coin_inspire do
                DungeonCtrl:GetInstance():RequestInspire(1);
            end
        end
    else
        if diamond < 5 then
            local function call_back()
                GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
            end
            Dialog.ShowTwo("Tip", "You don't have enough diamonds, top-up now?", "Confirm", call_back, nil, "Cancel", nil, nil)
        else
            DungeonCtrl:GetInstance():RequestInspire(1);
        end
    end
end