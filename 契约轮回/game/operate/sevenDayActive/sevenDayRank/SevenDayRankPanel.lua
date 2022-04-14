---
--- Created by  Administrator
--- DateTime: 2019/4/15 16:43
---
SevenDayRankPanel = SevenDayRankPanel or class("SevenDayRankPanel", BaseItem)
local this = SevenDayRankPanel

function SevenDayRankPanel:ctor(parent_node, parent_panel,actID)

    self.abName = "sevenDayActive"
    self.assetName = "SevenDayRankPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.actID = actID
    --logError(self.assetName ,2)
    ----print2(actID)
    ----print2(actID)
    ----print2(actID)
    self.model = SevenDayActiveModel:GetInstance()
    self.openData = OperateModel:GetInstance():GetAct(self.actID)
    self.data = OperateModel:GetInstance():GetActInfo(self.actID)
    self.rewardItems = {}
    self.rankItems = {}
    --SevenDayRankPanel.super.Load(self)
    self:BeforeLoad()
end

function SevenDayRankPanel:BeforeLoad()
    SevenDayRankPanel.super.Load(self)
end


function SevenDayRankPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for _, item in pairs(self.rewardItems) do
        item:destroy()
    end
    self.rewardItems = {}
    for _, item in pairs(self.rankItems) do
        item:destroy()
    end
    self.rankItems = {}

    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end

    if self.monster then
        self.monster:destroy();
    end
    if self.effect  then
        self.effect:destroy()
        self.effect = nil
    end
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function SevenDayRankPanel:LoadCallBack()
    if   self.model.isFirstOpen_rank  == true then
        self.model.isFirstOpen_rank = false
        self.model.redPoints[self.actID] = false
        self.model:UpdateRedPoint()
    end

    self.nodes = {
        "lastBtn","rankObj/myRank/myRank","SevenDayRankRewardItem","SevenDayRankItem","levelBtn",
        "rankObj/myRank/myPower","RewardObj/ScrollView/Viewport/rewardContent","time",
        "rankObj/rankScrollView/Viewport/rankContent","rTime",
        "levelActiveParent","rankObj/title/rankPowerText","modelCon","leftTex","leftzi",
        "RewardObj/ScrollView/Viewport","effParent","zi"

    }
    self:GetChildren(self.nodes)
    self.time = GetText(self.time)
    self.rTime = GetText(self.rTime)
    self.myPower = GetText(self.myPower)
    self.myRank = GetText(self.myRank)
    self.rankPowerText = GetText(self.rankPowerText)
    self.leftTex = GetImage(self.leftTex)
    self.leftzi = GetImage(self.leftzi)
    self:InitUI()
    self:AddEvent()
    self:PlayAni()
    --UIDepth.SetOrderIndex(self.modelCon.gameObject, true, 206)
    LayerManager:GetInstance():AddOrderIndexByCls(self,self.modelCon,nil,true,nil,nil,3)
    LayerManager:GetInstance():AddOrderIndexByCls(self,self.zi.transform,nil,true,nil,nil,4)
   -- dump(self.data)
  --  dump(self.openData)
    --print2(self.actID)
    --print2(self.actID)
   -- if self.openData then
        self.schedules = GlobalSchedule:Start(handler(self, self.CountDown), 0.2, -1);
    --else
    --    self.rTime.text = string.format("活动剩余：<color=#%s>%s</color>%s","ff0000","已结束","（排行奖励次日0点通过邮件发放）")
    --end

    local rankId = OperateModel:GetInstance():GetConfig(self.actID).rank
    RankController:GetInstance():RequestRankListInfo(rankId,0)
end

function SevenDayRankPanel:InitUI()
    local rankId = OperateModel:GetInstance():GetConfig(self.actID).rank
    local cfg = RankModel:GetInstance():GetRankById(rankId)
    self.rankPowerText.text = cfg.showdata

    self:SetMask()
    self:InitRewardItem()
    self:InitActTime()
    self:InitModel()
    self:InitTextPic()
    self:InitEff()
       -- dump(OperateModel:GetInstance().act_reward_config)
end

function SevenDayRankPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function SevenDayRankPanel:InitEff()
    if not self.effect then
        self.effect = UIEffect(self.effParent, 10311, false)
        --self.effect:SetOrderIndex(101)
        local cfg = {}
        cfg.scale = 1.25
        cfg.pos = {x=-420,y=-144,z=0}
        self.effect:SetConfig(cfg)
        --self.effect:SetPosition(-411,-144)
        --self.effect:SetScale(125)
    end
end

function SevenDayRankPanel:InitTextPic()
    
    --local function call_back()
    --    LayerManager:GetInstance():AddOrderIndexByCls(self,self.leftzi.transform,nil,true,nil,nil,4)
    --end
    lua_resMgr:SetImageTexture(self,self.leftzi,"iconasset/icon_Active",self.actID, false,handler(self,self.TextureCallBack))
end

function SevenDayRankPanel:TextureCallBack(sp)
    print2("callBack")
    self.leftzi.sprite = sp
    LayerManager:GetInstance():AddOrderIndexByCls(self,self.leftzi.transform,nil,true,nil,nil,4)
end


function SevenDayRankPanel:InitModel()
   local cfg =   OperateModel:GetInstance():GetConfig(self.actID)
    local tab = String2Table(cfg.reqs)
    local type = tab[2]
    local id = tab[3]
    if tab[1] == "model" then --模型
        if self.monster then
            self.monster:destroy()
        end
        --self.monster = UIModelManager:GetInstance():InitModel(type,id,self.modelCon,handler(self, self.HandleMonsterLoaded))
       -- self.monster = UIWingModel(self.modelCon, 10005, handler(self, self.HandleMonsterLoaded), "model_equip_", "model_equip_");
        self.monster = UIModelCommonCamera(self.modelCon, nil, "model_equip_" ..id);--data.icon

        local config = {};
       --config.scale = { x = data.res_ratio, y = data.res_ratio, z = data.res_ratio};
       -- config.rotate =  { x = -10, y = -180, z = 0};
       -- self.monster:SetConfig(config)
    else --图标
        if self.monster then
            self.monster:destroy()
        end
        lua_resMgr:SetImageTexture(self,self.leftTex,"iconasset/icon_Active",type, false)
    end
    --dump(tab)
end

function SevenDayRankPanel:HandleMonsterLoaded()
    SetLocalPosition(self.monster.transform, -1994, 30, 340)
    SetLocalRotation(self.monster.transform,0,145,0)

end

function SevenDayRankPanel:PlayAni()
    local action = cc.MoveTo(1.5, -409,-5,0)
    action = cc.Sequence(action, cc.MoveTo(1.5, -409,-35,0))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, self.leftTex.transform)
end


function SevenDayRankPanel:SetMyInfo(main)

  --  dump(main)

    local rankStr = ""
    self.showNum = main.sort
    if main.rank == 0 then   --没有排名
        rankStr = string.format("%s<color=#27C31F>%s</color>","Ranking:","Not Ranked")
    else
        rankStr = string.format("%s<color=#27C31F>%s</color>","Ranking:",main.rank)
    end
    self.myRank.text = rankStr

    local rankId = OperateModel:GetInstance():GetConfig(self.actID).rank
    -- self.rankCfg =   RankModel:GetInstance():GetRankById(rankId)
    --print2(self.rankCfg.event)
    --print2(self.rankCfg.event)
    --print2(self.rankCfg.event)
   -- local des = self.model:GetRankTypeStr(self.rankCfg.event,self.rankCfg.id)

    if rankId == 110502  then  --坐骑
        if main.sort ~= 0  then
            local cfg = self.model:GetMountNumByID(main.sort)
            self.myPower.text = string.format("My: T%sS%s",cfg.order,cfg.level)
        else
            self.myPower.text = string.format("My: T%sS%s",0,0)
        end

    elseif rankId == 110503 then
        if main.sort ~= 0  then
            local cfg = self.model:GetOffhandNumByID(main.sort)
            self.myPower.text = string.format("My: T%sS%s",cfg.order,cfg.level)
        else
            self.myPower.text = string.format("My: T%sS%s",0,0)
        end
    else
        self.myPower.text = "My:"..main.sort
    end
end

function SevenDayRankPanel:InitRewardItem()
    local rewardCfg = OperateModel:GetInstance():GetRewardConfig(self.actID)
    if rewardCfg then
        --local index = 0
        --for i = 1, #rewardCfg do
        --    self.rewardItems[i] = SevenDayRankRewardItem(self.SevenDayRankRewardItem.gameObject,self.rewardContent,"UI")
        --    self.rewardItems[i]:SetData(rewardCfg[i])
        --end
        for i, v in pairs(rewardCfg) do
            self.rewardItems[v.id] = SevenDayRankRewardItem(self.SevenDayRankRewardItem.gameObject,self.rewardContent,"UI")
            self.rewardItems[v.id]:SetData(v,self.StencilId)
        end
    end
end
function SevenDayRankPanel:InitActTime()
  --  if self.openData then
        local stime = self:GetActTime(self.openData.act_stime)
        local etime = self:GetActTime(self.openData.act_etime)
        self.time.text = string.format("Event Time: %s-%s",stime,etime)
   -- else

  --  end

   -- Config.db_daily
end


function SevenDayRankPanel:AddEvent()

    local function call_back()  --上期按钮
        local rankId = OperateModel:GetInstance():GetConfig(self.actID).rank
        local cfg = RankModel:GetInstance():GetRankById(rankId)
        self.lastId =  cfg.lastid
        if self.lastId == 0 then
            Notify.ShowText("This event is on phase 1")
            return
        end
        lua_panelMgr:GetPanelOrCreate(SevenDayRankLastPanel):Open(self.lastId)
       -- RankController:GetInstance():RequestRankListInfo(self.lastId,0)
    end
    AddClickEvent(self.lastBtn.gameObject,call_back)
    
    local function call_back() --升级攻略
       -- SevenDayRankLevelView(self.levelActiveParent, self,self.actId)
        lua_panelMgr:GetPanelOrCreate(SevenDayRankLevelView):Open(self.actID,self.showNum)
    end
    AddClickEvent(self.levelBtn.gameObject,call_back)

    self.events[#self.events+1] = GlobalEvent.AddEventListener(RankEvent.RankReturnList,handler(self,self.RankReturnList))
end

function SevenDayRankPanel:GetActTime(time)
    local timeTab = TimeManager:GetTimeDate(time)
    local timestr = "";
    if timeTab.month then
        timestr = timestr .. string.format("%02d", timeTab.month) .. "M";
    end
    if timeTab.day then
        timestr = timestr .. string.format("%d", timeTab.day) .. "Sunday ";
    end
    if timeTab.hour then
        timestr = timestr .. string.format("%02d", timeTab.hour) .. ":";
    end
    if timeTab.min then
        timestr = timestr .. string.format("%02d", timeTab.min) .. "";
    end
    return timestr
end

function SevenDayRankPanel:CountDown()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%d";
    timeTab = TimeManager:GetLastTimeData(os.time(), self.openData.act_etime);
    if table.isempty(timeTab) then
        Notify.ShowText("The event is over");
       -- self.rTime.text = "活动剩余：已结束"
        self.rTime.text = string.format("Event time left：<color=#%s>%s</color>%s","ff0000","Ended","(Rewards sent by mail at 00:00)")
        GlobalSchedule.StopFun(self.schedules);
    else
        if timeTab.day then
            timestr = timestr .. string.format(formatTime, timeTab.day) .. "Days";
        end
        if timeTab.hour then
            timestr = timestr .. string.format(formatTime, timeTab.hour) .. "hr";
        end
        if timeTab.min then
            timestr = timestr .. string.format(formatTime, timeTab.min) .. "min";
        end
        --if timeTab.sec then
        --    timestr = timestr .. string.format(formatTime, timeTab.sec);
        --end
        if timeTab.sec and not timeTab.day and not timeTab.hour and not timeTab.min then
            timestr = "1 pts"
        end
        local color  = "27C31F"
        self.rTime.text = string.format("Event time left：<color=#%s>%s</color>%s",color,timestr,"(Rewards sent by mail at 00:00)")
       -- self.rTime.text = "活动剩余：" .. timestr;
    end

end

function SevenDayRankPanel:RankReturnList(data)
    local  cfg = OperateModel:GetInstance():GetConfig(self.actID)
    local rankId = cfg.rank
    local rankCfg = RankModel:GetInstance():GetRankById(rankId)
    local size = rankCfg.size
    if data.id == rankId then
        local list = data.list
        self:SetMyInfo(data.mine)
        local ranklen = table.nums(list)
        for i = 1, size do
            self.rankItems[i] = SevenDayRankItem(self.SevenDayRankItem.gameObject,self.rankContent,"UI")
            if i <= ranklen then
                self.rankItems[i]:SetData(list[i],self.actID)
            else
                self.rankItems[i]:SetData(nil,self.actID,1,i)
            end

        end

        --for i = 1, #list do
        --   -- self.rankItems[i] = SevenDayRankItem(self.SevenDayRankItem.gameObject,self.rankContent,"UI")
        --    self.rankItems[i]:SetData(list[i],self.actID)
        --end
   -- else  --上期榜单
        --Notify.ShowText("打开上一期榜单")
        --lua_panelMgr:GetPanelOrCreate(SevenDayRankLastPanel):Open(self.lastId)
    end
end