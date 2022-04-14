---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by win 10.
--- DateTime: 2018/10/10 10:53
---
DungeonMeleeEndPanel = DungeonMeleeEndPanel or class("DungeonMeleeEndPanel", BasePanel)
local this = DungeonMeleeEndPanel

function DungeonMeleeEndPanel:ctor()
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "DungeonMeleeEndPanel"
    self.layer = "UI"

    self.model = DungeonModel.GetInstance()
    self.events = {};
    self.schedules = {};


    --DungeonCtrl:GetInstance().DungeonMeleeEndPanel = self;
end

function DungeonMeleeEndPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    if self.event_id_1 then
        self.model:RemoveListener(self.event_id_1)
        self.event_id_1 = nil
    end
    self:StopAllSchedules()
    self.model = nil;
    if self.enditem then
        self.enditem:destroy();
    end
end

function DungeonMeleeEndPanel:Open(data)
    self.data = data;
    WindowPanel.Open(self)
end

function DungeonMeleeEndPanel:LoadCallBack()
    self.nodes = {
        "endCon", "awardCon", "zhandoujiangli", "jingyan", "sure/sureText", "honor", -- "sure",
        "rank_txt",

    }
    self:GetChildren(self.nodes)
    local orderIndex = LayerManager:GetInstance():GetLayerOrderByName(self.layer)
    self:SetOrderIndex(orderIndex + 5)

    SetLocalPosition(self.transform, 0, 0, 0)
    --AddBgMask(self.gameObject, 0, 0, 0, 230);
    self:Init();

    self:AddEvent();

    if AutoFightManager:GetInstance():GetAutoFightState() then
        GlobalEvent:Brocast(FightEvent.AutoFight)
    end
end

--[[
{
	["coin"]=0,
	["star"]=0,
	["floor"]=1,
	["isClear"]=false
}



--]]
function DungeonMeleeEndPanel:Init()
    self.honor = GetText(self.honor);
    self.jingyan = GetText(self.jingyan);
    self.rank_txt = GetText(self.rank_txt);
    --print2("请把下面这行复制发给李德灵>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    --print2(Table2String(self.data));
    self.data["isClear"] = true;
    self.enditem = DungeonEndItem(self.transform, self.data);
    self.enditem:StartAutoClose(50);
    if self.data then
        self.rank_txt.text = string.format("No.%s" , (self.data.rank));--ChineseNumber
        local rewards = self.data.rewards;
        local index = 1;
        destroyTab(self.items);
        self.items = {};
        local titleID = nil;
        for k, v in pairs(rewards) do
            if k ~= enum.ITEM.ITEM_HONOR and k ~= enum.ITEM.ITEM_EXP then
                local itemConfig = Config.db_item[k];
                if itemConfig and itemConfig.stype == enum.ITEM_STYPE.ITEM_STYPE_TITLE then
                    titleID = k;
                end
            end
        end
        if titleID then
            local titleItem = GoodsIconSettorTwo(self.awardCon.transform)
            local param = {}
            param["item_id"] = titleID;
            param["num"] = rewards[titleID];
            param["can_click"] = true;
            param["bind"] = true;
            param["size"] = { x = 80, y = 80 }
            titleItem:SetIcon(param);
            self.items[index] = titleItem;
            index = index + 1;
            rewards[titleID] = nil;
        end

        for k, v in pairs(rewards) do
            if k ~= enum.ITEM.ITEM_HONOR and k ~= enum.ITEM.ITEM_EXP then
                local item = GoodsIconSettorTwo(self.awardCon.transform)
                local param = {}
                param["item_id"] = k;
                param["num"] = v;
                param["can_click"] = true;
                param["bind"] = true;
                param["size"] = { x = 80, y = 80 }
                item:SetIcon(param);
                --local item = AwardItem(self.awardCon);
                --item:SetData(k, tonumber(v));
                --item:AddClickTips(self.transform);
                self.items[index] = item;
                index = index + 1;
            end
        end

        if rewards[enum.ITEM.ITEM_HONOR] then
            self.honor.text = tostring(rewards[enum.ITEM.ITEM_HONOR]);
        else
            self.honor.text = "0";
        end
        if rewards[enum.ITEM.ITEM_EXP] then
            self.jingyan.text = GetShowNumber(tonumber(rewards[enum.ITEM.ITEM_EXP]));
        end

        -- 不分成功跟失败
    end
end

local closeTime = 5;
function DungeonMeleeEndPanel:AddEvent()

    local function closeCallBack()
        self:Close();
    end
    self.enditem:SetAutoCloseCallBack(closeCallBack);

    local time = 5;
    local dungeTab = Config.db_dunge[SceneManager:GetInstance():GetSceneId()];
    if dungeTab then
        time = dungeTab.exit_cd;
    end
    time = time or 5;
    self.enditem:StartAutoClose(time);

    local function call_back()
        --self:Close()
    end

    self.enditem:SetCloseCallBack(closeCallBack);

    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.LEAVE_DUNGEON_SCENE, call_back)

    self.event_id_1 = self.model:AddListener(DungeonEvent.ResEnterDungeonInfo, call_back)
end

function DungeonMeleeEndPanel:StopAllSchedules()
    for i = 1, #self.schedules, 1 do
        GlobalSchedule:Stop(self.schedules[i]);
    end
    self.schedules = {};
end