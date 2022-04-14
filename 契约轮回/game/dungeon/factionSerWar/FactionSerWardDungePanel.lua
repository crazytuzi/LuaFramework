---
--- Created by  Administrator
--- DateTime: 2020/5/25 19:51
---
FactionSerWardDungePanel = FactionSerWardDungePanel or class("FactionSerWardDungePanel", DungeonMainBasePanel)
local this = FactionSerWardDungePanel

function FactionSerWardDungePanel:ctor(parent_node, parent_panel)
    self.abName = "dungeon"
    self.assetName = "FactionSerWardDungePanel"
    self.events = {}
    self.gevents = {}
    self.items = {}
    self.is_hide_model_effect = false
    self.model = FactionSerWarModel:GetInstance()
    self.myGuildId = RoleInfoModel.GetInstance():GetMainRoleData().guild
end

function FactionSerWardDungePanel:dctor()
    self.model:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener(self.gevents)
    if not table.isempty(self.items) then
        for i, v in pairs(self.items) do
            v:destroy()
        end
        self.items = {}
    end
    if self.timeschedules then
        GlobalSchedule:Stop(self.timeschedules);
    end
    self.timeschedules = nil
end

function FactionSerWardDungePanel:LoadCallBack()
    self.nodes = {
        "startTime", "FactionSerWardDungePanel", "con", "FactionSerWardDungeItem", "endTime/endTitleTxt",
        "con/itemParent", "endTime", "startTime/time", "con/state1"
    }
    self:GetChildren(self.nodes)
    self.endTitleTxt = GetText(self.endTitleTxt)
    self:AddEvent()
    self:InitUI()
    self:InitScene()
    if not self.isNeedDown then
        self:DungeStart()
    end
    SetAlignType(self.con.transform, bit.bor(AlignType.Left, AlignType.Null))
end

function FactionSerWardDungePanel:InitUI()
    self:InitItems()
end

function FactionSerWardDungePanel:DungeStart()
    local actinfo = ActivityModel:GetInstance():GetActivity(12003)
    if not actinfo then
        return
    end
    self.end_time = actinfo.etime

    if self.timeschedules then
        GlobalSchedule:Stop(self.timeschedules);
    end
    self.timeschedules = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);

end

function FactionSerWardDungePanel:EndDungeon()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%02d";
    if self.end_time then
        SetVisible(self.endTime, true)
        timeTab = TimeManager:GetLastTimeData(os.time(), self.end_time);
        if table.isempty(timeTab) then
            GlobalSchedule.StopFun(self.timeschedules);
        else
            if timeTab.min then
                timestr = timestr .. string.format(formatTime, timeTab.min) .. ":";
            end
            if timeTab.sec then
                timestr = timestr .. string.format(formatTime, timeTab.sec);
            end
            self.endTitleTxt.text = timestr;--"副本倒计时: " ..
        end
    end
end

function FactionSerWardDungePanel:AddEvent()

    local function call_back(show, id)
        if show and 12003 == id then
            -- self.isNeedDown = true
            if not self.is_loaded then
                self.isNeedDown = true
                return
            end
            self:DungeStart()
        end
    end
    self.gevents[#self.gevents + 1] = GlobalEvent:AddListener(ActivityEvent.ChangeActivity, call_back)

    GlobalEvent.AddEventListenerInTab(EventName.NewSceneObject, handler(self, self.HandleNewCreate), self.gevents);

    local function call_back(isShow)
        --logError(isShow)
        self.items[3]:SetVisible(isShow)
        SetVisible(self.state1, not isShow)
        --for i = 1, #self.items do
        --
        --    if self.items[i].type == 2 then
        --        self.items[3]:SetVisible(isShow)
        --    end
        --end
    end
    self.events[#self.events + 1] = self.model:AddListener(FactionSerWarEvent.SetShowStatue, call_back)
    
    --local function call_back()
    --
    --end
    --RoleInfoModel().GetInstance():GetMainRoleData():BindData("group", call_back)
end

function FactionSerWardDungePanel:InitItems()
    local tab = { { id = 20702011, type = 1, badId = 20702014 }, { id = 20702012, type = 1, badId = 20702015 }, { id = 20702013, type = 2, badId = 0 } }
    for i = 1, #tab do
        local item = self.items[i]
        if not item then
            item = FactionSerWardDungeItem(self.FactionSerWardDungeItem.gameObject, self.itemParent, "UI")
            self.items[i] = item
        end
        item:SetData(tab[i])
    end
    if self:CheckState() == 1 then
        --self.isShowState =
        FactionSerWarModel.GetInstance():Brocast(FactionSerWarEvent.SetShowStatue, false)
    else
        FactionSerWarModel.GetInstance():Brocast(FactionSerWarEvent.SetShowStatue, true)
    end
end

function FactionSerWardDungePanel:InitScene()
    local createdMonTab = SceneManager:GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP);
    if createdMonTab then
        for k, monster in pairs(createdMonTab) do
            self:HandleNewCreate(monster);
        end
    end

end

function FactionSerWardDungePanel:HandleNewCreate(monster)
    -- dump(monster)
    if monster  then
        if monster.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
            if monster.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_COLL or monster.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_COLL2 then
                monster:ChangeMachineState(SceneConstant.ActionName.death, true)
                local role = RoleInfoModel.GetInstance():GetMainRoleData()
                if role.group == 1 then
                    monster.name_container:SetGlobalPosition(monster.name_container.position.x,monster.name_container.position.y - 5 ,monster.name_container.position.z)
                    monster.name_container:SetVisible(true)
                    monster.name_container:ShowCGS(true)
                end
            elseif monster.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_CGW_CRYSTAL then
                monster.name_container:SetGlobalPosition(monster.name_container.position.x,monster.name_container.position.y - 3,monster.name_container.position.z)
                monster:ChangeMachineState(SceneConstant.ActionName.show, true)
            elseif monster.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_CGW_STATUE then
                monster:SetRotateY(200)
            end



            -- logError(monster.object_info.id)

            local item = self:IsHaveCrystal(monster.object_info.id)
            if item then
                item:UpdataHpInfo(monster.object_info.hp, monster.object_info.hpmax)
                if self:CheckState() == 1 then
                    FactionSerWarModel.GetInstance():Brocast(FactionSerWarEvent.SetShowStatue, false)
                else
                    FactionSerWarModel.GetInstance():Brocast(FactionSerWarEvent.SetShowStatue, true)
                end
               -- logError(monster.object_info.hp, monster.object_info.id)
                local call_back1 = function(hp)
                    local value = hp / monster.object_info.hpmax
                    item:UpdataHpInfo(hp, monster.object_info.hpmax)

                    if self:CheckState() == 1 then
                        FactionSerWarModel.GetInstance():Brocast(FactionSerWarEvent.SetShowStatue, false)
                    else
                        FactionSerWarModel.GetInstance():Brocast(FactionSerWarEvent.SetShowStatue, true)
                    end
                    if monster and monster.object_info and monster.object_info.hp <= 0 then
                        --call_back();
                        --FactionSerWarModel.GetInstance():Brocast(FactionSerWarEvent.SetShowStatue,true);
                        monster.object_info:RemoveListener(self.update_blood);
                    end
                end
                self.update_blood = monster.object_info:BindData("hp", call_back1);
                
                --local function call_back1()
                --    local buffer = (monster.object_info:GetBuffByID(enum.BUFF_ID.BUFF_ID_SIEGEWAR_BOSS_SHIELD))
                --    if buffer then
                --        local cur = buffer.value
                --        local max = buffer.origin
                --        logError(cur,max)
                --    else
                --
                --    end
                --end
                --
                --self.buff_blood = monster.object_info:BindData("buffs", call_back1);
               -- 304010013
            end

        elseif monster.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE then
             local guild = monster.object_info.guild
            if guild == self.myGuildId then
                monster:SetNameColor2(Color(26, 253, 0), Color(6, 0, 1))
            else
                monster:SetNameColor2(Color(255, 5, 0), Color(6, 0, 1))
            end
            --monster:SetNameColor2()
        end

    end
end

function FactionSerWardDungePanel:CheckState()
    for i = 1, #self.items do
        if self.items[i].hp == 0 then
            return 2
        end
    end
    return 1
end

function FactionSerWardDungePanel:IsHaveCrystal(id)
    for i = 1, #self.items do
        if id == self.items[i].data.id then
            return self.items[i]
        end
    end
    return nil
end

function FactionSerWardDungePanel:IsFractureCrystal(id)
    for i = 1, #self.items do
        if id == self.items[i].data.badId then
            return self.items[i]
        end
    end
    return nil
end

function FactionSerWardDungePanel:UpdateBuff()
    
end

