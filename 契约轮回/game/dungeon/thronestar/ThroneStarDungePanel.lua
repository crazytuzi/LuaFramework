---
--- Created by  Administrator
--- DateTime: 2020/4/3 15:39
---
ThroneStarDungePanel = ThroneStarDungePanel or class("ThroneStarDungePanel", BaseItem)
local this = ThroneStarDungePanel

function ThroneStarDungePanel:ctor(parent_node, bossid)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "ThroneStarDungePanel"
    self.layer = "Bottom"
    self.bossid = bossid;
    self.model = ThroneStarModel.GetInstance()
    self.mEvents = {};
    self.events = {}
    self.schedules = {};
    self.bossList = {}
    self.creepList = {}
    self.items = {};
    self.rankItems = {}
    self.btnSelects1 = {}
    self.btnSelectsTex1 = {}
    self.show = true
    self.btnSelects2 = {}
    self.btnSelectsTex2 = {}
    self.currentType = 1
    self.roleInfo = RoleInfoModel:GetInstance():GetMainRoleData()
    ThroneStarDungePanel.super.Load(self)
end

function ThroneStarDungePanel:dctor()
    self.model:RemoveTabListener(self.mEvents)
    GlobalEvent:RemoveTabListener(self.events)
    self.btnSelects1 = {}
    self.btnSelectsTex1 = {}

    self.btnSelects2 = {}
    self.btnSelectsTex2 = {}

    if not table.isempty( self.bossList) then
        for i, v in pairs( self.bossList) do
            v:destroy()
        end
    end
    self.bossList = {}

    if not table.isempty( self.rankItems) then
        for i, v in pairs( self.rankItems) do
            v:destroy()
        end
    end
    self.rankItems = {}


    if self.schedule_id then
        GlobalSchedule:Stop(self.schedule_id )
        self.schedule_id = nil
    end

    if self.timeschedules then
        GlobalSchedule:Stop(self.timeschedules);
        self.timeschedules = nil
    end

    if self.right_info then
        self.right_info:destroy()
        self.right_info = nil
    end
end

function ThroneStarDungePanel:LoadCallBack()
    self.nodes = {
        "rightObj/hurtBtn","rightObj/serRank","contents/list_item_0",
        "contents/listBtn","rightObj/scoreBtn","rightObj",
        "rightObj/ThroneStarDungeRankItem","contents/helpBtn","rightObj/scoreBtn/scoreBtnText",
        "contents/helpBtn/helpBtnSelect","contents/ScrollView/Viewport/Content","rightObj/RightScrollView/Viewport/RightContent",
        "endTime/endTitleTxt","rightObj/scoreBtn/scoreBtnSelect","rightObj/hurtBtn/hurtBtnText","rightObj/hurtBtn/hurtBtnSelect",
        "contents/listBtn/listBtnSelect","contents/listBtn/listBtnText","contents/helpBtn/helpBtnText","contents/ScrollView",
        "teleport_btn","contents/refresh_btn","contents/CreepScrollView","contents/CreepScrollView/Viewport/CreepContent",
        "contents/DesScrollView","contents/DesScrollView/Viewport/Content/des",
    }
    self:GetChildren(self.nodes)
    --logError("---2--")
    self.des = GetText(self.des)
    self.listBtnText = GetText(self.listBtnText)
    self.helpBtnText = GetText(self.helpBtnText)
    self.hurtBtnText = GetText(self.hurtBtnText)
    self.scoreBtnText = GetText(self.scoreBtnText)
    self.endTitleTxt = GetText(self.endTitleTxt)
    self.serRank = GetText(self.serRank)
    self.teleport_btnImg = GetImage(self.teleport_btn)
   -- self.teleport_btnImg
    lua_resMgr:SetImageTexture(self, self.teleport_btnImg, "main_image", "btn_main_teleport", true, nil, false)
    self.btnSelects1[1] = self.listBtnSelect
    self.btnSelects1[2] = self.helpBtnSelect


    self.btnSelectsTex1[1] = self.listBtnText
    self.btnSelectsTex1[2] = self.helpBtnText

    --self.btnSelects2[1] = self.hurtBtnSelect
    --self.btnSelects2[2] = self.scoreBtnSelect
    --
    --
    --self.btnSelectsTex2[1] = self.hurtBtnText
    --self.btnSelectsTex2[2] = self.scoreBtnText

    if not self.show then
        SetVisible(self.gameObject, false)
    end


    self:SetLeftPage(1)
    --self:SetRightPage(1)
    self:InitUI()
    self:AddEvent()
    --MainModel:GetInstance():ChangeMiddleLeftBit(MainModel.MiddleLeftBitState.Dungeon,false)
    ThroneStarController.GetInstance():RequestBossListInfo()

    ThroneStarController.GetInstance():RequestLockInfo()
    self.des.text = HelpConfig.throne.des
    self.serRank.text = " "
    --self:RequestScoreRank()
    --if not self.schedule_id then
    --    self.schedule_id = GlobalSchedule:Start(handler(self,self.RequestScoreRank), 5)
    --end
    --local  actinfo = ActivityModel:GetInstance():GetActivity(self.model.actId)
    --self.end_time = actinfo.etime
    --
    --if self.timeschedules then
    --    GlobalSchedule:Stop(self.timeschedules);
    --end
    --self.timeschedules = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);

   -- SetAlignType(self.rightObj.transform, bit.bor(AlignType.Right, AlignType.Top))
    self.right_info = ThroneStarDungeRightView(LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.UI))

    if not self.isNeedDown then
        self:DungeStart()
    end
    local sceneId = SceneManager:GetInstance():GetSceneId()
    SetVisible(self.teleport_btn,sceneId ~= self.model.sceneIds[3])
end

function ThroneStarDungePanel:EndDungeon()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%02d";
    if self.end_time then
        SetVisible(self.endTime, true)
        timeTab = TimeManager:GetLastTimeData(os.time(), self.end_time);
        if table.isempty(timeTab) then
            Notify.ShowText("The dungeon is finished and need to be cleared");
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

--function ThroneStarDungePanel:RequestScoreRank()
--    ThroneStarController.GetInstance():RequestScoreInfo()
--end
--
--function ThroneStarDungePanel:RequestDamageRank(bossId)
--    ThroneStarController.GetInstance():RequestDamageInfo(bossId)
--end

function ThroneStarDungePanel:RequestRank(index)
    if index == 1 then --伤害排行
        local isNear,bossID = self:IsNearByBoss()
        if not isNear then
            if not table.isempty(self.rankItems) then
                for i = 1, #self.rankItems do
                    self.rankItems[i]:SetVisible(false)
                end
            end

            return
        end
       -- logError("請求傷害",bossID)
        self:RequestDamageRank(tonumber(bossID))
    else  --积分排行
      --  logError("請求積分")
        self:RequestScoreRank()
    end
end

function ThroneStarDungePanel:DungeStart()
    local  actinfo = ActivityModel:GetInstance():GetActivity(self.model.actId)
    if not actinfo then
        return
    end
    self.end_time = actinfo.etime

    if self.timeschedules then
        GlobalSchedule:Stop(self.timeschedules);
    end
    self.timeschedules = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);
end


function ThroneStarDungePanel:InitUI()

end

function ThroneStarDungePanel:AddEvent()

    self.mEvents[#self.mEvents + 1] =  self.model:AddListener(ThroneStarEvent.ThroneBossListInfo,handler(self,self.ThroneBossListInfo))
    --self.mEvents[#self.mEvents + 1] =  self.model:AddListener(ThroneStarEvent.ThroneBossUpdateInfo,handler(self,self.ThroneBossUpdateInfo))
    --self.mEvents[#self.mEvents + 1] =  self.model:AddListener(ThroneStarEvent.ThroneDamageInfo,handler(self,self.ThroneDamageInfo))
    --self.mEvents[#self.mEvents + 1] =  self.model:AddListener(ThroneStarEvent.ThroneScoreInfo,handler(self,self.ThroneScoreInfo))
    self.mEvents[#self.mEvents + 1] =  self.model:AddListener(ThroneStarEvent.ThroneLockInfo,handler(self,self.ThroneLockInfo))




    local function call_back()
        self:SetLeftPage(1)
    end
    AddClickEvent(self.listBtn.gameObject,call_back)
    local function call_back()
        self:SetLeftPage(2)
    end
    AddClickEvent(self.helpBtn.gameObject,call_back)

    local function call_back()
        self:SetRightPage(1)
    end
    AddClickEvent(self.hurtBtn.gameObject,call_back)
    local function call_back()
        self:SetRightPage(2)
    end
    AddClickEvent(self.scoreBtn.gameObject,call_back)

    local function call_back()
        if SceneManager:GetInstance():GetSceneId() == self.model.sceneIds[3] then
            self:InitItems(1)
            return
        end
        if self.currentType == 1 then
            self:InitItems(2)
        else
            self:InitItems(1)
        end

    end
    AddButtonEvent(self.refresh_btn.gameObject,call_back)
    
    local function call_back()
        local sceneId = SceneManager:GetInstance():GetSceneId()
        if sceneId ~= self.model.sceneIds[3] and   self.model.isLock then
            local function call_back()
                SceneControler.GetInstance():RequestSceneChange(self.model.sceneIds[3], enum.SCENE_CHANGE.SCENE_CHANGE_ACT, nil, nil, self.model.actId)
            end
            Dialog.ShowTwo("Tip", "This server reaches the goal.Are you sure to enter Pagasus?", "Yes", call_back, nil, "Cancel");
        else
            if sceneId == self.model.sceneIds[3] then
                Notify.ShowText("Reached the top stage")
            else
                Notify.ShowText("Not enough Point")
            end

        end
    end
    AddButtonEvent(self.teleport_btn.gameObject,call_back)
    local function call_back(show,id)
        if show and self.model.actId == id then
           -- self.isNeedDown = true
            if not self.is_loaded then
                self.isNeedDown = true
                return
            end
            self:DungeStart()
        end
    end
    self.events[#self.events + 1] =  GlobalEvent:AddListener(ActivityEvent.ChangeActivity,call_back)


    local call_back = function()
        if  SceneManager:GetInstance():GetSceneId() == self.model.sceneIds[3] then
            return
        end
        --SetGameObjectActive(self.rightObj.gameObject , false);
        SetGameObjectActive(self.teleport_btn.gameObject , false);
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.ShowTopRightIcon, call_back);

    local call_back1 = function()
        if  SceneManager:GetInstance():GetSceneId() == self.model.sceneIds[3] then
            return
        end
        --SetGameObjectActive(self.rightObj.gameObject , true);
        SetGameObjectActive(self.teleport_btn.gameObject , true);
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.HideTopRightIcon, call_back1);


    local function call_back(sceneId)
        SetVisible(self.teleport_btn,sceneId ~= self.model.sceneIds[3])
        self:InitItems(1)
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)
end

function ThroneStarDungePanel:SetLeftPage(index)
    for i = 1, 2 do
        if index == i then
            SetColor(self.btnSelectsTex1[i], 133, 132, 176, 255)
            SetVisible(self.btnSelects1[i],true)
        else
            SetColor(self.btnSelectsTex1[i], 255, 255, 255, 255)
            SetVisible(self.btnSelects1[i],false)
        end
        self:SetLeftShow(index == 1)
    end
end

--function ThroneStarDungePanel:SetRightPage(index)
--    for i = 1, 2 do
--        if index == i then
--            SetColor(self.btnSelectsTex2[i], 255, 255, 255, 255)
--            SetVisible(self.btnSelects2[i],true)
--        else
--            SetColor(self.btnSelectsTex2[i], 133, 132, 176, 255)
--            SetVisible(self.btnSelects2[i],false)
--        end
--    end
--
--    if self.schedule_id then
--        GlobalSchedule:Stop(self.schedule_id)
--        self.schedule_id = nil
--    end
--    self:RequestRank(index)
--    self.schedule_id = GlobalSchedule:Start(handler(self,self.RequestRank,index), 5)
--end

function ThroneStarDungePanel:SetLeftShow(boo)
    SetVisible(self.DesScrollView,not boo)
    --SetVisible(self.ScrollView,boo)
    SetVisible(self.refresh_btn,boo)
    if boo then
        if self.currentType == 1 then
            SetVisible(self.ScrollView,true)
            SetVisible(self.CreepScrollView,false)
        else
            SetVisible(self.ScrollView,false)
            SetVisible(self.CreepScrollView,true)
        end
    else
        SetVisible(self.ScrollView,false)
        SetVisible(self.CreepScrollView,false)
    end

end

function ThroneStarDungePanel:InitItems(type)
    self.currentType = type

    SetVisible(self.CreepScrollView,self.currentType == 2)
    SetVisible(self.ScrollView,self.currentType == 1)
    if self.currentType  == 1 then
        return
    end
    
    local tab = DungeonModel.GetInstance().localBossTab[tostring(SceneManager:GetInstance():GetSceneId())];
    for i = 1, #tab, 1 do
        local bossTab = tab[i];
        local item = self.creepList[i]
        if not item then
            item = ThroneStarDungeBossItem(self.list_item_0.gameObject,self.CreepContent,"UI");
            self.creepList[i] = item
        end
        item:SetData(bossTab,2);
    end
    for i = #tab + 1,#self.creepList do
        local buyItem = self.creepList[i]
        buyItem:SetVisible(false)
    end
    self:AddCreepTogEvents()
end

function ThroneStarDungePanel:AddCreepTogEvents()
    for i = 1, #self.creepList, 1 do
        local item = self.creepList[i];
        AddClickEvent(item.gameObject, handler(self, self.HandleMoveTo));
    end
end

--1伤害排行  2积分
function ThroneStarDungePanel:UpdateRankInfo(data,type)
   --logError(Table2String(data.ranking))
    local tab = data.ranking
    local num = 0
    local myRank = 0
    for i=1, #tab do
            local item = self.rankItems[i]
            if not item then
                item = ThroneStarDungeRankItem(self.ThroneStarDungeRankItem.gameObject,self.RightContent,"UI")
                self.rankItems[i] = item
            else
                item:SetVisible(true)
            end
            item:SetData(tab[i],type)
        if tab[i].id == self.roleInfo.suid then
            myRank = tab[i].rank
        end

    end
    for i = #tab + 1,#self.rankItems do
        local buyItem = self.rankItems[i]
        buyItem:SetVisible(false)
    end
    if myRank == 0 then
        self.serRank.text = "Server Rank: None"
    else
        self.serRank.text = string.format("Server Rank: %s",myRank)
    end
end

function ThroneStarDungePanel:UpdateCreepInfo()
    
end








function ThroneStarDungePanel:ThroneBossListInfo(data)
    local tab = data.bosses
    for i = 1, #tab, 1 do
        local bossTab = tab[i];
        local item = self.bossList[i]
        if not item then
            item = ThroneStarDungeBossItem(self.list_item_0.gameObject,self.Content,"UI");
            self.bossList[i] = item
        end
        item:SetData(bossTab,1);
    end
    for i = #tab + 1,#self.bossList do
        local buyItem = self.bossList[i]
        buyItem:SetVisible(false)
    end
    self:AddTogEvents()
end


function ThroneStarDungePanel:ThroneDamageInfo(data)
    self:UpdateRankInfo(data,1)
end


function ThroneStarDungePanel:ThroneScoreInfo(data)
    self:UpdateRankInfo(data,2)
end

function ThroneStarDungePanel:ThroneLockInfo(data)
   -- self.model.isLock
    local sceneId = SceneManager:GetInstance():GetSceneId()
    SetVisible(self.teleport_btn,sceneId ~= self.model.sceneIds[3])
    if sceneId ~= self.model.sceneIds[3] and   self.model.isLock then
        local function call_back()
            SceneControler.GetInstance():RequestSceneChange(self.model.sceneIds[3], enum.SCENE_CHANGE.SCENE_CHANGE_ACT, nil, nil, self.model.actId)
        end
        Dialog.ShowTwo("Tip", "This server reaches the goal.Are you sure to enter Pagasus?", "Yes", call_back, nil, "Cancel");

        ShaderManager.GetInstance():SetImageNormal(self.teleport_btnImg)
    else
        ShaderManager.GetInstance():SetImageGray(self.teleport_btnImg)
    end


end

function ThroneStarDungePanel:AddTogEvents()
    for i = 1, #self.bossList, 1 do
        local item = self.bossList[i];
        AddClickEvent(item.gameObject, handler(self, self.HandleMoveTo));
    end
end

function ThroneStarDungePanel:HandleMoveTo(target, x, y)
    for k, v in pairs(self.bossList) do
        v:SetSelected(false);
    end
    for k, v in pairs(self.creepList) do
        v:SetSelected(false);
    end


    local call_back = function()
        if not AutoFightManager:GetInstance():GetAutoFightState() then
            GlobalEvent:Brocast(FightEvent.AutoFight)
        end
    end
    local tab = self.bossList
    if self.currentType == 2 then
        tab = self.creepList
    end
    for k, v in pairs(tab) do
        if v.gameObject == target then
            v:SetSelected(true);
            --local tab = v.data;
            --local boss_type = tab.type
            if self.currentType == 1 then
                local id = v.data.id
                local cfg = Config.db_throne_boss[id]
                if not cfg then
                    return
                end
                local posTab = String2Table(cfg.coord)
                local x = posTab[1]
                local y = posTab[2]
                local function ok_func()
                    -- local coord = String2Table(posTab.coord);
                    if #posTab == 2 then
                        local main_role = SceneManager:GetInstance():GetMainRole()
                        local main_pos = main_role:GetPosition();
                        TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
                        OperationManager:GetInstance():TryMoveToPosition(nil, main_pos, { x = x, y = y }, handler(self, self.MoveCallBack, v.data.id), self:GetRange());
                    else
                        if DungeonModel:GetInstance():IsBeastIsland(v) then
                            Notify.ShowText("You need to do it by yourself");
                        end
                    end
                end
                ok_func()
            else
                local id = v.data.id
                local cfg = Config.db_boss_local[id.."@"..SceneManager:GetInstance():GetSceneId()]
                if not cfg then
                    return
                end
                local posTab = String2Table(cfg.coord)
                local x = posTab[1]
                local y = posTab[2]
                local function ok_func()
                    -- local coord = String2Table(posTab.coord);
                    if #posTab == 2 then
                        local main_role = SceneManager:GetInstance():GetMainRole()
                        local main_pos = main_role:GetPosition();
                        TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
                        OperationManager:GetInstance():TryMoveToPosition(nil, main_pos, { x = x, y = y }, handler(self, self.MoveCallBack, v.data.id), self:GetRange());
                    else
                        if DungeonModel:GetInstance():IsBeastIsland(v) then
                            Notify.ShowText("You need to do it by yourself");
                        end
                    end
                end
                ok_func()
            end


            -- AutoFightManager:GetInstance():SetAutoPosition({ x = coord[1], y = coord[2] })
        end
    end
end

function ThroneStarDungePanel:MoveCallBack(boss_type_id)
    AutoFightManager:GetInstance():Start(true)

    local object = SceneManager:GetInstance():GetCreepByTypeId(boss_type_id)
    if object then
        object:OnClick()
    end
    local data = Config.db_throne_boss[boss_type_id];
    if data then
        local tab = data;
        local coord = String2Table(tab.coord);
        AutoFightManager:GetInstance():SetAutoPosition({ x = coord[1], y = coord[2] })
       -- self:RequestDamageRank(boss_type_id)
    end
end

function ThroneStarDungePanel:GetRange()
    if not AutoFightManager:GetInstance().def_range then
        return nil
    end
    -- return AutoFightManager:GetInstance().def_range * 0.9
    return 500
end

function ThroneStarDungePanel:ThroneBossUpdateInfo(data)
    for i, v in pairs(self.bossList) do
     --   v.data.born
        if v.data.id == data.id then
            v:StartSechudle(data.born)
        end
    end
end

function ThroneStarDungePanel:IsNearByBoss()
    local list = SceneManager.GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP) or {}
    for k, obj in pairs(list) do
        if obj.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
            local bosscfg = Config.db_throne_boss[obj.object_info.id]
            if bosscfg  then
                return true, obj.object_info.id
            end
        end
    end
    return false
end

function ThroneStarDungePanel:UpdateTeleportIconShow(scene)
    local sceneId = scene or SceneManager:GetInstance():GetSceneId()
    --if
end

function ThroneStarDungePanel:SetShow(flag)
        self.show = flag
end

