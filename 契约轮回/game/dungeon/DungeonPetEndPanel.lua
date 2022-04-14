---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by win 10.
--- DateTime: 2018/10/10 10:53
---
DungeonPetEndPanel = DungeonPetEndPanel or class("DungeonPetEndPanel", BasePanel)
local this = DungeonPetEndPanel

function DungeonPetEndPanel:ctor()
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "DungeonPetEndPanel"
    self.layer = "UI"

    self.model = DungeonModel.GetInstance()
    self.events = {};
    self.schedules = {};
end

function DungeonPetEndPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    if self.event_id_1 then
        self.model:RemoveListener(self.event_id_1)
        self.event_id_1 = nil
    end
    self:StopAllSchedules()
    self.model = nil;

    destroyTab(self.waveItems);
    self.waveItems = nil;
    destroyTab(self.items);
    self.items = nil;

    if self.petautoschedule then
        GlobalSchedule.StopFun(self.petautoschedule);
    end

    if self.enditem then
        self.enditem:destroy();
    end

    self:OpenEntrance();

    self.exit = nil;
    self.again = nil;
    self.again_txt = nil;
    self.exit_txt = nil;
    self.guardvalue = nil;
    self.maxguardvalue = nil;
end

function DungeonPetEndPanel:Open(data)
    self.data = data;
    WindowPanel.Open(self)
end
DungeonPetEndPanel.tab123 = {
    ["reward"] = {

    },
    ["stype"] = 310,
    ["isClear"] = false,
    ["id"] = 80001
}
function DungeonPetEndPanel:LoadCallBack()
    self.nodes = {
        "win", "endCon",
        "win/guardlabel", "win/guardvalue", "win/maxguardlabel", "win/maxguardvalue", "win/fbjiangli", "win/awardCon", "win/bsawardCon", "win/bsjiangli", "win/pet_end_bg", --用于特效最后"win/endCon",
        "win/exit/exit_txt", "win/again", "win/again/again_txt", "again", "again/again_txt", "exit/exit_txt", "exit", --"win/exit",
        "lose/mountlabel", "lose/equip_1", "lose/mount", "lose/equip_label_2", "lose", "lose/equip_2", "lose/equip_label_1",

    }
    self:GetChildren(self.nodes)
    local orderIndex = LayerManager:GetInstance():GetLayerOrderByName(self.layer)
    self:SetOrderIndex(orderIndex + 5)

    --
    SetLocalPosition(self.transform, 0, 0, 0)
    self:Init();

    self:AddEvent();

    if AutoFightManager:GetInstance():GetAutoFightState() then
        GlobalEvent:Brocast(FightEvent.AutoFight)
    end

end

function DungeonPetEndPanel:Init()
    print2(Table2String(self.data));
    self.exit = GetButton(self.exit);
    self.again = GetButton(self.again);
    self.again_txt = GetText(self.again_txt);
    self.exit_txt = GetText(self.exit_txt);
    self.guardvalue = GetText(self.guardvalue);
    self.maxguardvalue = GetText(self.maxguardvalue);

    if self.data and self.data.isClear then
        AddBgMask(self.gameObject, 0, 0, 0, 160);

        SetGameObjectActive(self.lose.gameObject, false);

        local index = 1;
        local wave = self.data.wave or 0;
        self.guardvalue.text = "<color=#5BD022>" .. tostring(wave) .. "  </color>Wave";
        local maxwave = self.data.maxwave or wave;
        self.maxguardvalue.text = "<color=#5BD022>" .. tostring(maxwave) .. "  </color>Wave";
        destroyTab(self.items);
        self.items = {};
        for k, v in pairs(self.data.reward) do
            if k ~= 90010008 then
                local item = AwardItem(self.bsawardCon);
                item:SetData(k, v);
                item:AddClickTips(self.transform);
                self.items[index] = item;
                index = index + 1;
            end
        end

        self.waveItems = {};
        --local waveConfig = Config.db_dunge_wave[self.data.id .. "@" .. wave];
        --if waveConfig then
        --    local reward = String2Table(waveConfig.reward);
        --    if reward then
        --        for i = 1, #reward do
        --            local tab = reward[i];
        --            local item = AwardItem(self.awardCon);
        --            item:SetData(tab[1], tab[2]);
        --            item:AddClickTips(self.transform);
        --            table.insert(self.waveItems, item);
        --        end
        --    end
        --
        --end
        if self.data.count then
            for k, v in pairs(self.data.count) do
                local item = AwardItem(self.awardCon);
                item:SetData(k, v);
                item:AddClickTips(self.transform);
                table.insert(self.waveItems, item);
            end
        end

    else
        SetGameObjectActive(self.win.gameObject, false);
        self.enditem = DungeonEndItem(self.endCon.transform, self.data);
        self.enditem:StartAutoClose(5);
        SetGameObjectActive(self.exit, false);
    end
end

function DungeonPetEndPanel:AddEvent()
    local function closeCallBack()
        SceneControler:GetInstance():RequestSceneLeave();
        self:Close();
    end
    if self.enditem then
        self.enditem:SetAutoCloseCallBack(closeCallBack);
    else
        self:SetAutoCloseCallBack(closeCallBack);
    end

    local time = 5;
    local dungeTab = Config.db_dunge[SceneManager:GetInstance():GetSceneId()];
    if dungeTab then
        time = dungeTab.exit_cd;
    end
    time = time or 5;
    if self.enditem then
        self.enditem:StartAutoClose(time);
    else
        self:StartAutoClose(time);
    end

    local function call_back()
        SceneControler:GetInstance():RequestSceneLeave();
        self:Close()
    end
    if self.enditem then
        self.enditem:SetCloseCallBack(closeCallBack);
    else
        self:SetCloseCallBack(closeCallBack);
    end

    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.LEAVE_DUNGEON_SCENE, call_back)

    self.event_id_1 = self.model:AddListener(DungeonEvent.ResEnterDungeonInfo, call_back)

    local call_back = function()
        if self.closeBtnFun then
            self.closeBtnFun();
            self.closeBtnFun = nil;
        end
    end

    AddClickEvent(self.exit.gameObject, call_back);

    local again_call_back = function()
        SceneControler:GetInstance():RequestSceneLeave();
        self:Close()
    end

    AddClickEvent(self.again.gameObject, again_call_back);

    local call_back1 = function(target, x, y)
        GlobalEvent.BrocastEvent(MountEvent.OPEN_MOUNT_PANEL);
    end
    AddClickEvent(self.mount.gameObject, call_back1);

    local call_back2 = function(target, x, y)
        GlobalEvent.BrocastEvent(EquipEvent.ShowEquipUpPanel, 1);--Notify.ShowText("打开装备打造")--GlobalEvent.BrocastEvent(MountEvent.OPEN_MOUNT_PANEL);
    end
    AddClickEvent(self.equip_1.gameObject, call_back2);

    local call_back3 = function(target, x, y)
        GlobalEvent.BrocastEvent(CombineEvent.OpenCombinePanel, 1);--Notify.ShowText("打开装备熔炼")--
    end
    AddClickEvent(self.equip_2.gameObject, call_back3);
end

function DungeonPetEndPanel:StartAutoClose(closetime)
    closetime = closetime or 60;
    local function callBack1 (data)
        closetime = closetime - 1;
        --self.exit_txt.text = "退出副本";
        if self.exit_txt then
            self.exit_txt.text = string.format("Exit (%s)", closetime);
        end
        if closetime <= 0 then
            --SceneControler:GetInstance():RequestSceneLeave();
            if self.autoCloseFun then
                self.autoCloseFun();
                self.autoCloseFun = nil;
            end
        end
    end
    if self.petautoschedule then
        GlobalSchedule.StopFun(self.petautoschedule);
    end
    --self.exit_txt.text = "退出副本";
    if self.exit_txt then
        self.exit_txt.text = string.format("Exit (%s)", closetime);
    end
    self.petautoschedule = GlobalSchedule:Start(callBack1, 1, -1);
end

function DungeonPetEndPanel:SetCloseCallBack(fun)
    self.closeBtnFun = fun;
end

function DungeonPetEndPanel:SetAutoCloseCallBack(fun)
    self.autoCloseFun = fun;
end

function DungeonPetEndPanel:StopAllSchedules()
    for i = 1, #self.schedules, 1 do
        GlobalSchedule:Stop(self.schedules[i]);
    end
    self.schedules = {};
end
function DungeonPetEndPanel:OpenEntrance()
    local fun2 = function()
        lua_panelMgr:GetPanelOrCreate(DungeonEntrancePanel):Open(2, 2);
        if self.openschedule then
            GlobalSchedule.StopFun(self.openschedule);
        end
        self.openschedule = nil;
    end
    --说起来你可能不信,但是这段就是这么复杂
    local fun = function()
        if self.openevent then
            GlobalEvent:RemoveListener(self.openevent);
        end
        if self.openschedule then
            GlobalSchedule.StopFun(self.openschedule);
        end
        self.openevent = nil;
        GlobalSchedule.StartFunOnce(fun2, 0.5);
    end
    self.openschedule = GlobalSchedule.StartFunOnce(fun2, 5);
    self.openevent = AddModelEvent(EventName.ChangeSceneEnd, fun);
end
--{
--	["id"]=80001,
--	["isClear"]=true,
--	["count"]=
--	{
--
--	},
--	["stype"]=310,
--	["wave"]=6,
--	["reward"]=
--	{
--		[11040804]=1,
--		[11041004]=1
--	}
--}