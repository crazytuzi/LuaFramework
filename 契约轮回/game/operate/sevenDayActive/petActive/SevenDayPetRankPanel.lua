---
--- Created by  Administrator
--- DateTime: 2019/8/23 11:07
---
SevenDayPetRankPanel = SevenDayPetRankPanel or class("SevenDayPetRankPanel", BaseItem)
local this = SevenDayPetRankPanel

function SevenDayPetRankPanel:ctor(parent_node, parent_panel, actID, assName)

    self.abName = "sevenDayActive"
    self.assetName = assName or "SevenDayPetRankPanel"
	self.is_ill = assName
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.actID = actID
    --print2(actID)
    --print2(actID)
    --print2(actID)
    self.model = SevenDayActiveModel:GetInstance()
    self.openData = OperateModel:GetInstance():GetAct(self.actID)
    self.data = OperateModel:GetInstance():GetActInfo(self.actID)
    self.rewardItems = {}
    self.rankItems = {}
    SevenDayPetRankPanel.super.Load(self)
end

function SevenDayPetRankPanel:dctor()
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
    --
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

function SevenDayPetRankPanel:LoadCallBack()
    self.nodes = {
        "lastBtn","rankObj/myRank/myRank","SevenDayPetRankRewardItem","SevenDayPetRankItem","levelBtn",
        "rankObj/myRank/myPower","RewardObj/ScrollView/Viewport/rewardContent","time",
        "rankObj/rankScrollView/Viewport/rankContent","rTime",
        "levelActiveParent","rankObj/title/rankPowerText","modelCon","leftTex","leftzi",
        "RewardObj/ScrollView/Viewport","effParent","powerObj/powerPic",

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
   -- self:PlayAni()
    LayerManager:GetInstance():AddOrderIndexByCls(self,self.leftzi.transform,nil,true,nil,nil,4)
    LayerManager:GetInstance():AddOrderIndexByCls(self,self.modelCon,nil,true,nil,nil,3)
    --LayerManager:GetInstance():AddOrderIndexByCls(self,self.zi.transform,nil,true,nil,nil,4)
    self.schedules = GlobalSchedule:Start(handler(self, self.CountDown), 0.2, -1);

    local rankId = OperateModel:GetInstance():GetConfig(self.actID).rank
    RankController:GetInstance():RequestRankListInfo(rankId,0)
end

function SevenDayPetRankPanel:InitUI()
    --logError(self.actID)
    local rankId = OperateModel:GetInstance():GetConfig(self.actID).rank
    local cfg = RankModel:GetInstance():GetRankById(rankId)
    self.rankPowerText.text = cfg.showdata

    self:SetMask()
    self:InitRewardItem()
    self:InitActTime()
    self:InitModel()
   -- self:InitTextPic()
    self:InitEff()
end

function SevenDayPetRankPanel:AddEvent()
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
		if self.is_ill then
			local  cfg =String2Table(OperateModel:GetInstance():GetConfig(self.actID).sundries) 
            OpenLink(unpack(cfg[1][2]))
		else
			lua_panelMgr:GetPanelOrCreate(SevenDayPetRankLevelView):Open(self.actID,self.showNum)
		end
        
    end
    AddClickEvent(self.levelBtn.gameObject,call_back)

    self.events[#self.events+1] = GlobalEvent.AddEventListener(RankEvent.RankReturnList,handler(self,self.RankReturnList))
end

function SevenDayPetRankPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function SevenDayPetRankPanel:InitRewardItem()
    local rewardCfg = OperateModel:GetInstance():GetRewardConfig(self.actID)
    if rewardCfg then
        for i, v in pairs(rewardCfg) do
            self.rewardItems[v.id] = SevenDayPetRankRewardItem(self.SevenDayPetRankRewardItem.gameObject,self.rewardContent,"UI")
            self.rewardItems[v.id]:SetData(v,self.StencilId)
        end
    end
end

function SevenDayPetRankPanel:InitActTime()
    local stime = self:GetActTime(self.openData.act_stime)
    local etime = self:GetActTime(self.openData.act_etime)
    self.time.text = string.format("Event Time: %s-%s",stime,etime)
end

function SevenDayPetRankPanel:GetActTime(time)
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

function SevenDayPetRankPanel:SetMyInfo(main)
    local rankStr = ""
    self.showNum = main.sort
    if main.rank == 0 then   --没有排名
        rankStr = string.format("%s<color=#27C31F>%s</color>","Ranking:","Didn't make list")
    else
        rankStr = string.format("%s<color=#27C31F>%s</color>","Ranking:",main.rank)
    end
    self.myRank.text = rankStr
    self.myPower.text = "My:"..main.sort
    --local rankId = OperateModel:GetInstance():GetConfig(self.actID).rank
    --if rankId == 110502  then  --坐骑
    --    if main.sort ~= 0  then
    --        local cfg = self.model:GetMountNumByID(main.sort)
    --        self.myPower.text = string.format("我的：%s阶%s星",cfg.order,cfg.level)
    --    else
    --        self.myPower.text = string.format("我的：%s阶%s星",0,0)
    --    end
    --
    --elseif rankId == 110503 then
    --    if main.sort ~= 0  then
    --        local cfg = self.model:GetOffhandNumByID(main.sort)
    --        self.myPower.text = string.format("我的：%s阶%s星",cfg.order,cfg.level)
    --    else
    --        self.myPower.text = string.format("我的：%s阶%s星",0,0)
    --    end
    --else
    --    self.myPower.text = "我的："..main.sort
    --end
end

function SevenDayPetRankPanel:RankReturnList(data)
    dump(data)
    local  cfg = OperateModel:GetInstance():GetConfig(self.actID)
    local rankId = cfg.rank
    local rankCfg = RankModel:GetInstance():GetRankById(rankId)
    local size = rankCfg.size
    if data.id == rankId then
        local list = data.list
        self:SetMyInfo(data.mine)
        local ranklen = table.nums(list)
        for i = 1, size do
            self.rankItems[i] = SevenDayPetRankItem(self.SevenDayPetRankItem.gameObject,self.rankContent,"UI")
            if i <= ranklen then
                self.rankItems[i]:SetData(list[i],self.actID)
            else
                self.rankItems[i]:SetData(nil,self.actID,1,i)
            end

        end

    end
end

function SevenDayPetRankPanel:CountDown()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%d";
    timeTab = TimeManager:GetLastTimeData(os.time(), self.openData.act_etime);
    if table.isempty(timeTab) then
        Notify.ShowText("The event is over");
        -- self.rTime.text = "活动剩余：已结束"
        self.rTime.text = string.format("Event time left：<color=#%s>%s</color>%s","ff0000","Ended","Rankings (Total pet CP are over 200K) Ranking rewards will be sent via mails at 00:00")
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
        local color  = "53ff67"
        if self.is_ill then
            self.rTime.text = string.format("Event time left：<color=#%s>%s</color>%s",color,timestr,"Leaderboard<color=#eb0000>（Total atlas CP reaches 125k）</color> Ranking rewards will be sent via in-game mails next day at 00:00")
        else
            self.rTime.text = string.format("Event time left：<color=#%s>%s</color>%s",color,timestr,"Rankings (Total pet CP are over 200K) Ranking rewards will be sent via mails at 00:00")
        end

        -- self.rTime.text = "活动剩余：" .. timestr;
    end

end

function SevenDayPetRankPanel:InitEff()
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

function SevenDayPetRankPanel:InitModel()
    local cfg =   OperateModel:GetInstance():GetConfig(self.actID)
    local tab = String2Table(cfg.reqs)
    local type = tab[2]
    local id = tab[3]
    if tab[1] == "model" then --模型
        if self.monster then
            self.monster:destroy()
        end
        self.monster = UIModelCommonCamera(self.modelCon, nil, "model_pet_20002");--data.icon

        local config = {};
        --config.scale = { x = data.res_ratio, y = data.res_ratio, z = data.res_ratio};
        config.trans_x = 400
        config.trans_y = 400
        config.trans_offset = {y=-136.3}
        config.pos =  { x = -1993, y = -118.5, z = 200};
        self.monster:SetConfig(config)
    else --图标
        if self.monster then
            self.monster:destroy()
        end
        if self.is_ill then
            SetVisible(self.leftTex, true)
            local action = cc.MoveTo(1, -431, 50)
            action = cc.Sequence(action, cc.MoveTo(1, -431, 35))
            action = cc.Repeat(action, 4)
            action = cc.RepeatForever(action)
            cc.ActionManager:GetInstance():addAction(action, self.leftTex.transform)

        else
            lua_resMgr:SetImageTexture(self,self.leftTex,"iconasset/icon_Active",type, false)
        end
        end

    if self.is_ill then
        local powerTex = GetText(self.powerPic)
        powerTex.text = String2Table(cfg.sundries)[2][2]
    end
end