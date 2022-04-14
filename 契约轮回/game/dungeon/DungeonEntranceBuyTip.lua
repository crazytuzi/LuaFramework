---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by win 10.
--- DateTime: 18/11/19 17:34
---
DungeonEntranceBuyTip = DungeonEntranceBuyTip or class("DungeonEntranceBuyTip", WindowPanel)
local this = DungeonEntranceBuyTip

function DungeonEntranceBuyTip:ctor(parent_node)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "DungeonEntranceBuyTip"
    self.layer = "UI"
    self.panel_type = 4;
    self.model = DungeonModel.GetInstance()
    self.events = {};
    self.schedules = {};
end

function DungeonEntranceBuyTip:dctor()
    self.model = nil;
    GlobalEvent:RemoveTabListener(self.events);
    self:StopAllSchedules()

    destroyTab(self.items);
    if self.currentVip then
        self.currentVip:destroy();
    end
    if self.nextvip then
        self.nextvip:destroy();
    end
    self.currentVip = nil;
    self.nextvip = nil;
end

function DungeonEntranceBuyTip:Open(data, vipid)
    self.data = data;
    self.vipid = vipid or 0;
    WindowPanel.Open(self)
end

function DungeonEntranceBuyTip:LoadCallBack()
    self.nodes = {
        "img_bg_3", "evo", "sure_btn/sure_text", "sure_btn", "content", "arrow", "vipitem_0",
    }
    self:GetChildren(self.nodes)

    SetLocalPosition(self.transform, 0, 0, 0)
    --设置标题
    self:SetTileTextImage("dungeon_image", "arena_title2", true);
    self:InitUI();

    self:AddEvent();
end

function DungeonEntranceBuyTip:InitUI()
    --self.currentVip = GetImage(self.currentVip);
    --self.nextvip = GetImage(self.nextvip);

    --lua_resMgr:SetImageTexture(self, self.currentVip, self.image_ab, "dungeon_result2_win", true);
    --lua_resMgr:SetImageTexture(self, self.nextvip, self.image_ab, "dungeon_result2_win", true);

    --设置当前VIP和下一个VIP,还要读VIP表看看能购买多少次,目前暂时写死2次

    self.currentCanBuyTime = 0;
    self.maxCanBuyTime = 0;
    local nextCanBuyTime = 0;
    local vipLevel = 0;
    local vipLevel2 = 0;
    self.MAX_BUY_TIMES = 0;
    vipLevel = RoleInfoModel:GetInstance():GetMainRoleVipLevel();
    if Config.db_vip_rights[self.vipid] then
        local vipRightTab = Config.db_vip_rights[self.vipid]

        if vipLevel == 0 then
            self.currentCanBuyTime = 0
        else
            if vipRightTab["vip" .. vipLevel] then
                self.currentCanBuyTime = tonumber(vipRightTab["vip" .. vipLevel]);
            end
        end

        for i = vipLevel, 12 do
            if vipRightTab["vip" .. i] and tonumber(vipRightTab["vip" .. i]) > self.currentCanBuyTime then
                nextCanBuyTime = vipRightTab["vip" .. i];
                vipLevel2 = i;
                break ;
            end


        end
        for i = vipLevel, 12 do
            if vipRightTab["vip" .. i] and tonumber(vipRightTab["vip" .. i]) >= self.maxCanBuyTime then
                self.maxCanBuyTime = tonumber(vipRightTab["vip" .. i])
            end
        end

        for i = 1, 12 do
            if vipRightTab["vip" .. i] and tonumber(vipRightTab["vip" .. i]) > self.MAX_BUY_TIMES then
                self.MAX_BUY_TIMES = tonumber(vipRightTab["vip" .. i]);
            end
        end
    end

    local cost = 50;
    local costType = "Diamond";
    if self.data then
        local costTab = GetDungeonCost(self.data.stype);
        if costTab then
            cost = costTab[2] or cost;
            costType = enumName.ITEM[costTab[1]] or costType;
        end
    end

    self.content = GetText(self.content);
    self.sure_text = GetText(self.sure_text);
    --设置内容
    --是否花费<color=#ffff00>50钻石</color>(优先绑钻)购买1次副本次数
    --提升到<color=#ffff00>VIP6</color>可获得额外次数！
    --是否花费<color=#D82FE4>50钻石(优先绑钻)</color>购买1次副本次数




    if self.data.buy_times < self.currentCanBuyTime then
        self.content.text = "Spend<color=#D82FE4>" .. cost .. costType .. "</color>Buy 1 dungeon attempt";
        self.sure_text.text = "Buy once"
    elseif self.data.buy_times == self.currentCanBuyTime and vipLevel ~= 0 and self.currentCanBuyTime ~= 0 then
        self.content.text = "Purchase chances used out!"
        self.sure_text.text = "Confirm";
    else
        self.content.text = "Upgrade to <color=#D82FE4>VIP" .. vipLevel2 .. "</color>Can get additional attempts"
        self.sure_text.text = "Upgrade VIP";
    end

    if vipLevel >= vipLevel2 then
        vipLevel2 = vipLevel;
        nextCanBuyTime = self.MAX_BUY_TIMES;
    end

    self:InitVip(vipLevel, vipLevel2, nextCanBuyTime);
end

function DungeonEntranceBuyTip:InitVip(viplevel1, viplevel2, nextCanBuyTime)
    self.vipitem_0.gameObject:SetActive(true);

    self.currentVip = DungeonEntranceBuyTipItem(newObject(self.vipitem_0));
    self.currentVip:SetVipLevel(viplevel1);
    self.currentVip:ShowCurrent(true);
    self.currentVip.transform:SetParent(self.evo.transform);
    local cbd = 0;
    if (self.currentCanBuyTime - self.data.buy_times) >= 0 then
        cbd = self.currentCanBuyTime - self.data.buy_times;
    end
    self.currentVip:SetBuyText("Every day you can buy<color=#4ADB6B>" .. cbd .. "/" .. self.currentCanBuyTime .. "</color>time(s)");
    SetLocalScale(self.currentVip.transform, 1, 1, 1);
    SetLocalPosition(self.currentVip.transform, 0, 0, 0);

    if self.currentCanBuyTime ~= self.maxCanBuyTime then
        self.nextvip = DungeonEntranceBuyTipItem(newObject(self.vipitem_0));
        self.nextvip:SetVipLevel(viplevel2);
        self.nextvip:ShowCurrent(false);
        self.nextvip.transform:SetParent(self.evo.transform);
        self.nextvip:SetBuyText("Every day you can buy<color=#4ADB6B>" .. nextCanBuyTime .. "</color>time(s)");
        SetLocalScale(self.nextvip.transform, 1, 1, 1);
        SetLocalPosition(self.nextvip.transform, 0, 0, 0);
    end
    self.vipitem_0.gameObject:SetActive(false);
end

function DungeonEntranceBuyTip:AddEvent()
    --AddClickEvent(self.cancel_btn.gameObject , handler(self , self.HandleCancel));
    AddClickEvent(self.sure_btn.gameObject, handler(self, self.HandleSure))
end

function DungeonEntranceBuyTip:HandleSure(target, x, y)
    --if self.data.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_EXP then
    --    if self.data.buy_times < self.currentCanBuyTime then
    --        DungeonCtrl:GetInstance():RequestBuyTimes(self.data.stype);
    --        self:Close();
    --    else
    --        Notify.ShowText("跳转到VIP界面");
    --    end
    --elseif self.data.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COIN then
    --    if self.data.buy_times < GoldEntrancePanel.MAX_BUY_TIMES then
    --        DungeonCtrl:GetInstance():RequestBuyTimes(self.data.stype);
    --        self:Close();
    --    else
    --        Notify.ShowText("跳转到VIP界面");
    --    end
    --end

    if self.data.buy_times < self.currentCanBuyTime then
        DungeonCtrl:GetInstance():RequestBuyTimes(self.data.stype);
        self:Close();
    elseif self.data.buy_times == self.MAX_BUY_TIMES then
        self:Close();
    else
        --Notify.ShowText("跳转到VIP界面");
        --OpenLink()
        lua_panelMgr:GetPanelOrCreate(VipPanel):Open();
    end

end

function DungeonEntranceBuyTip:StopAllSchedules()
    for i = 1, #self.schedules, 1 do
        GlobalSchedule:Stop(self.schedules[i]);
    end
    self.schedules = {};
end

DungeonEntranceBuyTipItem = DungeonEntranceBuyTipItem or class("DungeonEntranceBuyTipItem", Node)
local this1 = DungeonEntranceBuyTipItem

function DungeonEntranceBuyTipItem:ctor(obj, vipData)
    self.transform = obj.transform
    self.gameObject = self.transform.gameObject;
    self.transform_find = self.transform.Find;

    self.data = vipData;

    self.events = {};
    self.itemList = {};
    self:Init();
    self:AddEvents();
end

function DungeonEntranceBuyTipItem:Init()
    self.is_loaded = true;
    self.nodes = {
        "current", "bg", "viplevel", "buytime",
    }
    self:GetChildren(self.nodes);

    self:InitUI();
    self:AddEvents();
end

function DungeonEntranceBuyTipItem:InitUI()
    self.buytime = GetText(self.buytime);--每天可购买<color=#4ADB6B>2/2</color>次
    self.viplevel = GetText(self.viplevel);
    self.current = GetImage(self.current);
end

function DungeonEntranceBuyTipItem:SetBuyText(str)
    self.buytime.text = str;
end

function DungeonEntranceBuyTipItem:SetVipLevel(num)
    self.viplevel.text = tostring(num);
end

function DungeonEntranceBuyTipItem:AddEvents()

end

function DungeonEntranceBuyTipItem:ShowCurrent(bool)
    bool = toBool(bool);
    self.current.gameObject:SetActive(bool);
end

function DungeonEntranceBuyTipItem:dctor()
    GlobalEvent:RemoveTabListener(self.events);
end
