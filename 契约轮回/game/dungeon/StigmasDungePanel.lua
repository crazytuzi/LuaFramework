---
--- Created by  Administrator
--- DateTime: 2019/9/25 15:32
---
StigmasDungePanel = StigmasDungePanel or class("StigmasDungePanel", DungeonMainBasePanel)
local this = StigmasDungePanel

function StigmasDungePanel:ctor(parent_node, parent_panel)
    self.abName = "dungeon"
    self.imageAb = "dungeon_image"
    self.assetName = "StigmasDungePanel"
    self.events = {}
    self.mEvents = {}
    self.schedules = {}
    self.dropItems = {}
    self.count = 0
    self.countNums = {}
    self.dungeonType = 0 -- 1波数副本  2怪物副本
end

function StigmasDungePanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    StigmasModel.GetInstance():RemoveTabListener(self.mEvents)
    self.model.stigmasInfo = {}
    self:StopAllSchedules()
    if self.dropItems then
        for i, v in pairs(self.dropItems) do
            v:destroy()
        end
        self.dropItems = {}
    end

    if self.red then
        self.red:destroy()
    end
    self.red = nil
end

function StigmasDungePanel:LoadCallBack()
    self.nodes = {
        "iconParent/masterBtn","endTime","iconParent/bossBtn","reayObj","endTime/endTitleTxt",
        "iconParent/defBtn","iconParent/boxBtn/boxNum","startTime","startTime/time","iconParent/boxBtn",
        "con","iconParent/masterBtn/masterTimer","con/escapeNum","con/ware","con/exp","con/rNum",
        "iconParent/boxPanel","iconParent/boxPanel/boxBg","showObj",
        "iconParent/boxPanel/dorpParent","StigmasDropItem","iconParent"
    }
    self:GetChildren(self.nodes)
    self.endTitleTxt = GetText(self.endTitleTxt)
    self.time = GetText(self.time)
    self.boxNum = GetText(self.boxNum)
    self.masterTimer = GetText(self.masterTimer)
    self.escapeNum = GetText(self.escapeNum)
    self.ware = GetText(self.ware)
    self.exp = GetText(self.exp)
    self.rNum = GetText(self.rNum)
    SetVisible(self.boxPanel,false)

    self.red = RedDot(self.defBtn.transform, nil, RedDot.RedDotType.Nor)
    self.red:SetPosition(25, 28)
    self.red:SetRedDotParam(StigmasModel.GetInstance():IsStartRed())
    self:InitUI()
    self:AddEvent()
    SetAlignType(self.con.transform, bit.bor(AlignType.Left, AlignType.Top))
    SetAlignType(self.showObj.transform, bit.bor(AlignType.Left, AlignType.Null))
    DungeonCtrl:GetInstance():RequeseExpDungeonInfo()


end

function StigmasDungePanel:InitUI()
    self:InitDropItems()
end

function StigmasDungePanel:AddEvent()
    self.equipschedules = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);
   -- self:HandleData()

    local function call_back()  --刷怪
        local isRed =  StigmasModel.GetInstance():IsStartRed()
        if isRed then
            local function call_back2()
                StigmasController:GetInstance():RequstDungeSoulStart()
            end
            Dialog.ShowTwo("Tip", "   You still have stronger avatar undeployed,\nenter?", "Confirm", call_back2, nil, "Cancel", nil, nil)
        else
            StigmasController:GetInstance():RequstDungeSoulStart()
        end
    end
    AddButtonEvent(self.masterBtn.gameObject,call_back)


    local function call_back()  --召唤BOSS
        --if self.isAuto == 1 then
        --    Notify.ShowText("当前已经为自动召唤BOSS")
        --    return
        --end
        local costCfg = String2Table(Config.db_dunge_soul["summon_cost"].val) --召唤BOSS消耗
        local costNum = costCfg[1][2]
        local function call_back(isOn)
           -- logError(isOn)
           -- 0：不自动，1：自动
            local nun = isOn and 1 or 0
            StigmasController:GetInstance():RequstDungeSoulSummon(nun)
        end
        Dialog.ShowTwo("Tip", string.format("Summon a boss with better loots in this wave?\n(<color=#0C7E1B>Use %s Bound diamonds or diamonds</color>)",costNum), "Confirm", call_back, nil, "Cancel", nil,
                nil,"Auto summon in each wave",self.isAuto == 1,nil)
    end
    AddButtonEvent(self.bossBtn.gameObject,call_back)


    local function call_back() --防御
        lua_panelMgr:GetPanelOrCreate(StigmasSelectPanel):Open()
    end
    AddButtonEvent(self.defBtn.gameObject,call_back)


    local function call_back() --宝箱
        --if self.boxPanel.gameObject.activeInHierarchy then
        --
        --end
       -- logError(self.boxPanel.gameObject.activeInHierarchy)
        SetVisible(self.boxPanel,not self.boxPanel.gameObject.activeInHierarchy)
    end
    AddButtonEvent(self.boxBtn.gameObject,call_back)

    local call_back = function()
        SetVisible(self.iconParent,false)
        SetVisible(self.endTime,false)
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.ShowTopRightIcon, call_back);


    local call_back = function()
        SetVisible(self.iconParent,true)
        SetVisible(self.endTime,true)
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.HideTopRightIcon, call_back);

    local function call_back()
        self.red:SetRedDotParam(StigmasModel.GetInstance():IsStartRed())
    end
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(StigmasEvent.UpdateRedPoint, call_back);

    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_EXP_GOLD_INFO, handler(self, self.HandleDungeonInfo))
    self.events[#self.events + 1] = GlobalEvent:AddListener(StigmasEvent.DungeSoulStart, handler(self, self.HandleDungeSoulStart))
    self.mEvents[#self.mEvents + 1]  = StigmasModel.GetInstance():AddListener(StigmasEvent.DungeSoulSelect, handler(self, self.DungeSoulSelect))

    --GlobalEvent.AddEventListenerInTab(EventName.NewSceneObject, handler(self, self.HandleNewCreate), self.events);
    self:HandleDungeonInfo()
end

function StigmasDungePanel:DungeSoulSelect()
    
end


--开始刷怪
function StigmasDungePanel:HandleDungeSoulStart()
    SetVisible(self.masterBtn,false)
    SetVisible(self.defBtn,false)
end





function StigmasDungePanel:HandleDungeonInfo(tab)
    local data = self.model.stigmasInfo
    dump(data)
  --  logError("返回副本信息")
    if  not data then
        return
    end
    if data.stype ~= enum.SCENE_STYPE.SCENE_STYPE_DUNGE_SOUL then
        return
    end
    self.isAuto = data.info["auto_summon"] -- 0：不自动，1：自动
    local id = DungeonModel:GetInstance().curDungeonID
    self.dungeonCfg = Config.db_dunge[id]
    if not self.dungeonCfg then
        return
    end
    if DungeonModel.GetInstance().DungeEnter[id].ptime then
        self.prep_time = DungeonModel.GetInstance().DungeEnter[id].ptime
    end
    if DungeonModel.GetInstance().DungeEnter[id].etime then
        self.end_time = DungeonModel.GetInstance().DungeEnter[id].etime
    end

    if self.prep_time and not self.start_dungeon_time then
        if self.prep_time < os.time() then
            self.start_dungeon_time = 0;
            self.time.text = tostring(self.start_dungeon_time);
            self:StartDungeon();
        else
            local preptime = self.prep_time;
            local ostime = math.round(os.time());
            self.start_dungeon_time = preptime;
            self.time.text = tostring(self.start_dungeon_time);
            self.schedules[1] = GlobalSchedule:Start(handler(self, self.StartDungeon), 1, -1);
        end
    end
    self.ware.text = string.format("Current Wave: <color=#1AFF36>(%s/%s)</color>wave",data.info["cur_wave"],data.info["max_wave"])
    self.rNum.text = string.format("Monsters left: <color=#1AFF36>%s</color>",data.info["rest_creep"])
    self.escapeNum.text = string.format("Monsters escaped: <color=#1AFF36>%s</color>",data.info["escape_creep"])
    local number = data.drops[enum.ITEM.ITEM_EXP] or 0
    self.exp.text = string.format("EXP earned: <color=#1AFF36>%s</color>",GetShowNumber(number))

   -- data.drops[enum.ITEM.ITEM_EXP]
    --local exp = data.info["escape_creep"])
    --self.exp.text = ""string.format("获得经验：<color=#1AFF36>%s</color>",exp)

    self:UpdateDropInfo(data.drops)
end

function StigmasDungePanel:InitDropItems()
    local cfg = Config.db_soul_show
    for i = 1, #cfg do
        local item = self.dropItems[i]
        if not item then
            item = StigmasDropItem(self.StigmasDropItem.gameObject,self.dorpParent,"UI")
            self.dropItems[i] = item
        end
        item:SetData(cfg[i],0)
    end
   -- self:UpdateSizeView()
end

function StigmasDungePanel:UpdateDropInfo(tab)
    local count = 0
    local countNums = {}
    for id, num in pairs(tab) do
        local cfg = self:GetCfg(id)
        if cfg then
            if not countNums[cfg.id] then
                countNums[cfg.id] = num
            else
                countNums[cfg.id] = countNums[cfg.id] + num
            end

        end
        --if cfg then
        --    self.dropItems[cfg.id]:SetData(cfg,num)
        --end

        --local itemCfg = Config.db_item[id]
        --if itemCfg then
        --    local sType = itemCfg.stype
        --    local color = itemCfg.color
        --    if (sType == enum.ITEM_STYPE.ITEM_STYPE_SOUL) and (color == 1 or color == 3 or color == 4 or color == 5 or color ==6 ) or
        --            sType == enum.ITEM_STYPE.ITEM_STYPE_SOUL_EXP or id == 90010023 then
        --        count = count  + num
        --        local item =  self.dropItems[id]
        --        if not item  then
        --            item = StigmasDropItem(self.StigmasDropItem.gameObject,self.dorpParent,"UI")
        --            self.dropItems[id] = item
        --        end
        --        item:SetData(itemCfg,num)
        --    end
       -- end
        
    end
    local itemNums = 0
    self.len = 0
    for i = 1, #self.dropItems do
        local num = countNums[i] or 0
        itemNums = itemNums + num
        if  num ~= 0  then
            self.len = self.len + 1
        end
        self.dropItems[i]:SetData(self.dropItems[i].cfg,countNums[i] or 0)
    end
    self.boxNum.text = "x"..itemNums
    --if table.nums(self.dropItems) == self.len then
    --    return
    --end
   -- self.len = table.nums(self.dropItems)
    self:UpdateSizeView()

end

function StigmasDungePanel:UpdateSizeView()
    SetSizeDeltaY(self.boxBg, (self.len*30)+100)
end


function StigmasDungePanel:StartDungeon()
   -- local timeTab = nil;
    TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
    --停止自动寻路
    OperationManager:GetInstance():StopAStarMove();
    local timeTab = TimeManager:GetLastTimeData(os.time(), self.start_dungeon_time);
    local timestr = "";
    local formatTime = "%02d";
    if table.isempty(timeTab) then
        Notify.ShowText("Start Mobbing");
            if self.schedules[1] then
                GlobalSchedule:Stop(self.schedules[1]);
            end
        SetVisible(self.masterBtn,false)
        SetVisible(self.defBtn,false)
        SetVisible(self.reayObj,false)
        local panel = lua_panelMgr:GetPanel(StigmasSelectPanel)
        if panel then
            panel:Close()
        end
    else
        timeTab.min = timeTab.min or 0;
        timeTab.hour = timeTab.hour or 0;
        if timeTab.hour then
            timestr = timestr .. string.format("%02d", timeTab.hour) .. ":";
        end
        if timeTab.min then
            timestr = timestr .. string.format("%02d", timeTab.min) .. ":";
        end
        if timeTab.sec then
            timestr = timestr .. string.format("%02d", timeTab.sec);
        end
        self.masterTimer.text = timestr;--"副本倒计时: " ..
    end
    --self.start_dungeon_time = self.start_dungeon_time - 1;
    --self.time.text = tostring(self.start_dungeon_time);
    --if self.start_dungeon_time <= 0 then
    --    self.startTime.gameObject:SetActive(false);
    --
    --    if self.schedules[1] then
    --        GlobalSchedule:Stop(self.schedules[1]);
    --    end
    --    self.schedules[1] = nil;
    --    --防止自动战斗不打
    --    TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
    --    --停止自动寻路
    --    OperationManager:GetInstance():StopAStarMove();
    --end
end

function StigmasDungePanel:EndDungeon()
    if self.end_time and self.start_dungeon_time <= 0 then
        self.endTime.gameObject:SetActive(true);
    end
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%02d";
    --整个副本的结束时间
    if self.end_time then
        --SetGameObjectActive(self.endTime.gameObject, true);
        timeTab = TimeManager:GetLastTimeData(os.time(), self.end_time);
        if table.isempty(timeTab) then
            Notify.ShowText("The dungeon is over. It's time to clean up");
            GlobalSchedule.StopFun(self.equipschedules);
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
    DailyDungeonPanel.super.EndDungeon(self);
end

function StigmasDungePanel:GetCfg(id)
    local itemCfg = Config.db_item[id]
    local cfg = Config.db_soul_show
    if itemCfg then
        local sType = itemCfg.stype
        local color = itemCfg.color
        for i = 1, #cfg do
            if cfg[i].idd == 0 then
                if cfg[i].color == 0 then
                    if sType == cfg[i].type then
                        return cfg[i]
                    end
                else
                    if sType == cfg[i].type and color == cfg[i].color  then
                        return cfg[i]
                    end
                end
            else
                if id == cfg[i].idd then
                    return cfg[i]
                end
            end
        end
    end
    return nil
end


function  StigmasDungePanel:StopAllSchedules()
    for i = 1, #self.schedules, 1 do
        GlobalSchedule:Stop(self.schedules[i]);
    end
    self.schedules = {};
    if self.equipschedules then
        GlobalSchedule:Stop(self.equipschedules);
    end
    self.equipschedules = nil;
    self.schedules = {};
end