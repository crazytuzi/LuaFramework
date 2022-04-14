---
--- Created by  Administrator
--- DateTime: 2019/9/24 11:06
---
StigmasPanel = StigmasPanel or class("StigmasPanel", BaseItem)
local this = StigmasPanel

function StigmasPanel:ctor(parent_node, parent_panel)
    self.abName = "stigmas"
    self.image_ab = "stigmas_image";
    self.assetName = "StigmasPanel"
    self.layer = "UI"
    self.panel_type = 2;
    self.events = {};
    self.gEvents = {}
    self.slotsItems = {}
    self.itemicon = {}
    self.model = StigmasModel:GetInstance()
    StigmasPanel.super.Load(self);
end

function StigmasPanel:dctor()
    self.model:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener(self.gEvents)
    if self.slotsItems then
        for i, v in pairs(self.slotsItems) do
            v:destroy()
        end
    end
    self.slotsItems = {}

    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
end

function StigmasPanel:LoadCallBack()
    self.nodes = {
        "down/timesObj/times","down/sweepBtn",
        "down/timesObj/addBtn","left/des","middle/itemsParent",
        "down/enterBtn","left/iconParent",
    }
    self:GetChildren(self.nodes)
    self.times =  GetText(self.times)
    --self:InitUI()
    self.des = GetText(self.des)
    self:AddEvent()
    StigmasController:GetInstance():RequstDungeSoulPanel()
end



function StigmasPanel:AddEvent()

    local function call_back()
        --logError(self.model:IsStartRed())
        local isRed = self.model:IsStartRed()
        if isRed then
            local function call_back2()
                DungeonCtrl:GetInstance():RequestEnterDungeon(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_SOUL,nil,30501)
            end
            Dialog.ShowTwo("Tip", "   You still have stronger avatar undeployed,\nenter?", "Confirm", call_back2, nil, "Cancel", nil, nil)
        else
            DungeonCtrl:GetInstance():RequestEnterDungeon(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_SOUL,nil,30501)
        end
        --DungeonCtrl:GetInstance():RequestEnterDungeon(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_SOUL,nil,30501)
    end
    AddButtonEvent(self.enterBtn.gameObject,call_back)


    local function call_back()
        local data = {}
        data["buy_times"] = self.model.dungenInfo["buy_times"]
        data["max_times"] = self.model.dungenInfo["max_times"]
        data["rest_times"] = self.model.dungenInfo["rest_times"]
        data["id"] = self.model.dungenId
        data["stype"] = self.model.dungenStype
        lua_panelMgr:GetPanelOrCreate(DungeonEntranceBuyTip):Open(data, enum.VIP_RIGHTS.VIP_RIGHTS_DUNGE_SOUL)
    end
    AddButtonEvent(self.addBtn.gameObject,call_back)


    local function call_back() --扫荡
        local level = RoleInfoModel:GetInstance():GetMainRoleLevel()
        if level < 380 then
            Notify.ShowText("Unlock Raid: Peak Lv.10")
            return
        end
        lua_panelMgr:GetPanelOrCreate(StigmasSweepPanel):Open()
    end
    AddButtonEvent(self.sweepBtn.gameObject,call_back)


   -- lua_panelMgr:GetPanelOrCreate(DungeonEntranceBuyTip):Open(data.info, enum.VIP_RIGHTS.VIP_RIGHTS_DUNGE_EXP_BUY);
    self.events[#self.events + 1] = self.model:AddListener(StigmasEvent.DungeSoulPanel,handler(self,self.HandleDungeSoulPanel))
    self.events[#self.events + 1] = self.model:AddListener(StigmasEvent.StigmasItemClick1,handler(self,self.StigmasItemClick1))
    self.events[#self.events + 1] = self.model:AddListener(StigmasEvent.DungeSoulSelect,handler(self,self.HandleDungeSoulSelect))
    self.gEvents[#self.gEvents + 1] = GlobalEvent:AddListener(DungeonEvent.UpdateSoulTimes,handler(self,self.UpdateSoulTimes))
    self.gEvents[#self.gEvents + 1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_SWEEP_REFRESH, handler(self, self.HandleSweep))


end
function StigmasPanel:HandleSweep()
    local num = self.model.dungenInfo["rest_times"] - 1
    local maxNum = self.model.dungenInfo["max_times"]
    local color = "1CFF11"
    if num  <= 0 then
        color = "FF0A00"
    end
    self.times.text = string.format("Attempts left：<color=#%s>%s</color>/%s",color,self.model.dungenInfo["rest_times"],maxNum)
end


function StigmasPanel:UpdateSoulTimes()
    local num = self.model.dungenInfo["rest_times"]
    local maxNum = self.model.dungenInfo["max_times"]
    local color = "1CFF11"
    if num  <= 0 then
        color = "FF0A00"
    end
    self.times.text = string.format("Attempts left：<color=#%s>%s</color>/%s",color,num,maxNum)
end

function StigmasPanel:HandleDungeSoulPanel(data)
    dump(data)
    self:InitUI()
end

function StigmasPanel:InitUI()
    self:InitSlotsInfo()
    self:CreateReward()
    self.des.text = HelpConfig.stigmas.Help
end

function StigmasPanel:CreateReward()
    --30501
    local reward = String2Table(Config.db_dunge[30501].reward_show)
    for i = 1, #reward do
        local id = reward[i][1]
        local num = reward[i][2]
        local bind = reward[i][3]
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
        end
        local param = {}
        param["model"] = self.model
        param["item_id"] = id
        param["num"] = num
        param["bind"] = bind
        param["can_click"] = true
        self.itemicon[i]:SetIcon(param)
    end
end


function StigmasPanel:InitSlotsInfo()
    for i = 1, 6 do
        local item = self.slotsItems[i]
        if not item then
            item = StigmasItem(self.itemsParent,"UI")
            self.slotsItems[i] = item
            item:SetData(i,1)
        end
    end
    local num = self.model.dungenInfo["rest_times"]
    local maxNum = self.model.dungenInfo["max_times"]
    local color = "1CFF11"
    if num  <= 0 then
        color = "FF0A00"
    end
    self.times.text = string.format("Attempts left：<color=#%s>%s</color>/%s",color,num,maxNum)
end

function StigmasPanel:StigmasItemClick1(index)
    lua_panelMgr:GetPanelOrCreate(StigmasSelectPanel):Open(index)
end

function StigmasPanel:HandleDungeSoulSelect()
    --UpdateInfo
    for i, v in pairs(self.slotsItems) do
        v:UpdateInfo()
    end
end
