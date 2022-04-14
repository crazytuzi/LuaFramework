---
--- Created by  Administrator
--- DateTime: 2019/11/22 11:58
---
CompeteDungeReadyPanel = CompeteDungeReadyPanel or class("CompeteDungeReadyPanel", DungeonMainBasePanel)
local this = CompeteDungeReadyPanel
function CompeteDungeReadyPanel:ctor(parent_node, parent_panel)
    self.abName = "compete"
    self.imageAb = "compete_image"
    self.assetName = "CompeteDungeReadyPanel"
    self.events = {}
    self.gevents = {}
    self.rewards = {}
    self.textList = {}
    self.rankItems = {}
    self.model = CompeteModel:GetInstance()
end

function CompeteDungeReadyPanel:dctor()
    self.model:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener(self.gevents)
    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end
    self.schedules = nil

    if self.rewards then
        for i, v in pairs(self.rewards) do
            v:destroy()
        end
        self.rewards = {}
    end
    self.textList = {}

    if not table.isempty(self.rankItems) then
        for i, v in pairs(self.rankItems) do
            v:destroy()
        end
        self.rankItems = {}
    end
end

function CompeteDungeReadyPanel:LoadCallBack()
    self.nodes = {
        "con/rank/rankTex",
        "con","con/exp/expTex",
        "endTime/endTitleTxt","endTime","startTime/time","startTime",
        "con/rewardObj","con/noReward",
        "CompeteDungeReadyRewardItem", "macthIcon","TextObj",
        "TextObj/endObj","TextObj/haiXuanBattle","TextObj/haiXuanEnd","TextObj/zhengBaReady",
        "TextObj/haiXuanReady","TextObj/zhengBaEnd","TextObj/zhengBaBattel","TextObj/readyObj","TextObj/zhengBaEnd2",

        "TextObj/haiXuanEnd/haiXuanETime","TextObj/haiXuanReady/haiXuanRTime","TextObj/haiXuanBattle/haiXuanBTime",
        "TextObj/haiXuanBattle/haiXuanBRound","TextObj/zhengBaBattel/zhengBaBTime","TextObj/zhengBaBattel/zhengBaBRound1",
        "TextObj/haiXuanReady/haiXuanRRound","TextObj/zhengBaEnd/zhengBaETime","TextObj/zhengBaBattel/zhengBaBRound2",
        "TextObj/zhengBaReady/zhengBaRRound2","TextObj/endObj/battleEndTime",
        "TextObj/zhengBaReady/zhengBaRTime","TextObj/zhengBaReady/zhengBaRRound1",
        "TextObj/readyObj/readyTime","TextObj/zhengBaEnd2/zhengBaETime2",

        "TextObj/nullObj/nullTime","TextObj/nullObj","TextObj/lastObj/lastTime","TextObj/lastObj","shopIcon",
        "rewardIcon",

        "con/contents_3/mine/role_rank","con/contents_3/mine/score","con/contents_3/mine/role_name","CompeteDungeReadyRankItem",
        "con/contents_3/items","con/contents_3/close","con/contents_3","con/rankBtn",
    }
    self:GetChildren(self.nodes)
    self.role_rank = GetText(self.role_rank)
    self.score = GetText(self.score)
    self.role_name = GetText(self.role_name)
    SetAsLastSibling(self.transform)

    self.expTex = GetText(self.expTex)
    self.rankTex = GetText(self.rankTex)
    self.endTitleTxt = GetText(self.endTitleTxt)
    self.haiXuanETime = GetText(self.haiXuanETime)
    self.haiXuanRTime = GetText(self.haiXuanRTime)

    self.haiXuanBTime = GetText(self.haiXuanBTime)
    self.haiXuanBRound = GetText(self.haiXuanBRound)
    self.zhengBaBTime = GetText(self.zhengBaBTime)
    self.zhengBaBRound1 = GetText(self.zhengBaBRound1)
    self.haiXuanRRound = GetText(self.haiXuanRRound)

    self.zhengBaETime = GetText(self.zhengBaETime)
    self.zhengBaBRound2 = GetText(self.zhengBaBRound2)
    self.battleEndTime = GetText(self.battleEndTime)
    self.zhengBaRRound2 = GetText(self.zhengBaRRound2)
    self.zhengBaRTime = GetText(self.zhengBaRTime)
    self.zhengBaRRound1 = GetText(self.zhengBaRRound1)

    self.zhengBaETime2 = GetText(self.zhengBaETime2)
    self.readyTime = GetText(self.readyTime)

    self.nullTime = GetText(self.nullTime)
    self.lastTime = GetText(self.lastTime)
    
    self.textList[1] = self.readyObj
    self.textList[2] = self.haiXuanReady
    self.textList[3] = self.haiXuanBattle
    self.textList[4] = self.haiXuanEnd
    self.textList[5] = self.zhengBaReady
    self.textList[6] = self.zhengBaBattel
    self.textList[7] = self.zhengBaEnd
    self.textList[8] = self.zhengBaEnd2
    self.textList[9] = self.endObj
    self.textList[10] = self.nullObj
    self.textList[11] = self.lastObj

    SetVisible(self.noReward,false)
    SetVisible(self.rewardObj,true)
    SetVisible(self.contents_3,false)
    self:InitUI()
    self:AddEvent()
    CompeteController:GetInstance():RequstCompetePrepareInfo()
    SetAlignType(self.con.transform, bit.bor(AlignType.Left, AlignType.Null))
end

function CompeteDungeReadyPanel:InitUI()
    local tab = {[1] = 90010003 , [2] = 90010004,[3] = 90010029}
    for i = 1, #tab do
        local  item = self.rewards[tab[i]]
        if not item then
            item = CompeteDungeReadyRewardItem(self.CompeteDungeReadyRewardItem.gameObject,self.rewardObj,"UI")
            self.rewards[tab[i]] = item
        end
        item:SetData(tab[i],0)
    end
end

function CompeteDungeReadyPanel:AddEvent()
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(CompeteMatchPanel):Open()
    end
    AddButtonEvent(self.macthIcon.gameObject,call_back)
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(CompeteShopPanel):Open()
    end
    AddButtonEvent(self.shopIcon.gameObject,call_back)

    local function call_back(target,x,y)
        lua_panelMgr:GetPanelOrCreate(CompeteRewardMainPanel):Open()
    end
    AddButtonEvent(self.rewardIcon.gameObject,call_back)

    self.events[#self.events+1] = self.model:AddListener(CompeteEvent.CompetePrepareInfo,handler(self,self.CompetePrepareInfo))

    local call_back = function()
        SetGameObjectActive(self.TextObj.gameObject , false);
        self.hideByIcon = true;
    end

    self.gevents[#self.gevents + 1] = GlobalEvent.AddEventListener(MainEvent.ShowTopRightIcon, call_back);

    local call_back1 = function()
        SetGameObjectActive(self.TextObj.gameObject , true);
        self.hideByIcon = nil;
    end

    self.gevents[#self.gevents + 1] = GlobalEvent.AddEventListener(MainEvent.HideTopRightIcon, call_back1);



    local function call_back()
        SetGameObjectActive(self.contents_3.gameObject, false);
        if self.autoRequestRank then
            GlobalSchedule.StopFun(self.autoRequestRank);
            self.autoRequestRank = nil;
        end
    end
    AddClickEvent(self.close.gameObject,call_back)


    local function call_back() --排名
        SetGameObjectActive(self.contents_3.gameObject, not self.contents_3.gameObject.activeSelf);
        if self.contents_3.gameObject.activeSelf then
            self:HandleRequestRankInfo();
        end
    end
    AddClickEvent(self.rankBtn.gameObject, call_back);


    self.events[#self.events + 1] = self.model:AddListener(CompeteEvent.CompeteRankInfo, handler(self, self.RankReturnList));

    self:HandleRequestRankInfo()
    if self.autoRequestRank then
        GlobalSchedule.StopFun(self.autoRequestRank);
        self.autoRequestRank = nil;
    end
    self.autoRequestRank = GlobalSchedule.StartFun(handler(self, self.HandleRequestRankInfo), 3, -1);
end

function CompeteDungeReadyPanel:CompetePrepareInfo(data)
   -- dump(data)

   -- logError("period :"..data.period.."round :"..data.round.."phase :"..data.phase)
   -- enum.COMPETE_PHASE.COMPETE_PHASE_BATTLE
   -- if table.isempty(data.reward) then
   --     SetVisible(self.noReward,true)
   --     SetVisible(self.rewardObj,false)
   -- else  --有奖励
   --     SetVisible(self.noReward,false)
   --     SetVisible(self.rewardObj,true)
   --     self:UpdateReward(data.reward)
   --
   -- end
    self:UpdateReward(data.reward)
    self.expTex.text = GetShowNumber(data.exp)
    if data.rank == 0 then
        self.rankTex.text = "Didn't make list"
    else
        self.rankTex.text = data.rank
    end

    self.period = data.period
    self.round = data.round
    self.phase = data.phase
    self.miss = data.miss
    SetVisible(self.macthIcon,self.period == enum.COMPETE_PERIOD.COMPETE_PERIOD_RANK)
    self.timeText = self.endTitleTxt
    if self.period == enum.COMPETE_PERIOD.COMPETE_PERIOD_SELECT then --海选阶段
        if data.round == 0 then
            self:SetShow(1)
            self.timeText = self.readyTime
        else
            if self.phase == enum.COMPETE_PHASE.COMPETE_PHASE_PREPARE then --准备阶段
                --self.timeObj = self.haiXuanReady
                self:SetShow(2)
                self.haiXuanRRound.text = self.round
                self.timeText = self.haiXuanRTime
            elseif self.phase == enum.COMPETE_PHASE.COMPETE_PHASE_BATTLE then --战斗阶段
                -- self.timeObj = self.haiXuanBattle
                if self.miss  then
                    self:SetShow(10)
                    self.timeText = self.nullTime
                else
                    self:SetShow(3)
                    self.haiXuanBRound.text = self.round
                    self.timeText = self.haiXuanBTime
                end

            end
        end
    elseif self.period == enum.COMPETE_PERIOD.COMPETE_PERIOD_RANK  then --争霸
        if data.round == 0 then
            self:SetShow(4)
            self.timeText = self.haiXuanETime
        else
            if self.phase == enum.COMPETE_PHASE.COMPETE_PHASE_PREPARE then --准备阶段
                self:SetShow(5)
                self.timeText = self.zhengBaRTime
                if data.round  == 1 then
                    self.zhengBaRRound1.text = 16
                    self.zhengBaRRound2.text= 8
                elseif data.round  == 2 then
                    self.zhengBaRRound1.text = 8
                    self.zhengBaRRound2.text = 4
                elseif data.round  == 3 then
                    self.zhengBaRRound1.text = 4
                    self.zhengBaRRound2.text = 2
                elseif data.round  == 4 then
                    self:SetShow(7)
                    self.timeText = self.zhengBaETime
                end
            elseif self.phase == enum.COMPETE_PHASE.COMPETE_PHASE_BATTLE then --战斗阶段
                if self.miss then
                    self:SetShow(10)
                    self.timeText = self.nullTime
                else
                    self:SetShow(6)
                    self.timeText = self.zhengBaBTime
                    if data.round  == 1 then
                        self.zhengBaBRound1.text = 16
                        self.zhengBaBRound2.text = 8
                    elseif data.round  == 2 then
                        self.zhengBaBRound1.text = 8
                        self.zhengBaBRound2.text = 4
                    elseif data.round  == 3 then
                        self.zhengBaBRound1.text = 4
                        self.zhengBaBRound2.text = 2
                    elseif data.round  == 4 then
                        self:SetShow(8)
                        self.timeText = self.zhengBaETime2
                    end
                end

            end
        end
    elseif self.period == enum.COMPETE_PERIOD.COMPETE_PERIOD_TRUCE  then
        self:SetShow(11)
        self.timeText = self.lastTime
    end

    --logError(data.next)
    self.startTime = data.next
    self:StartNext()
    if not self.schedules then
       -- GlobalSchedule:Stop(self.schedules);
       -- if self.timeObj  then
       --     SetVisible(self.timeObj,false)
       -- end
        self.schedules = GlobalSchedule:Start(handler(self, self.StartNext), 0.2, -1);
    end
    --self.schedules = nil
   -- self.schedules = GlobalSchedule:Start(handler(self, self.StartNext), 1, -1);


end

function CompeteDungeReadyPanel:StartNext()
    if self.startTime then
        local timeTab = nil;
        local timestr = "";
        local formatTime = "%02d";
        --SetGameObjectActive(self.endTime.gameObject, true);
        timeTab = TimeManager:GetLastTimeData(os.time(), self.startTime);
        if table.isempty(timeTab) then
           -- Notify.ShowText("副本结束了,需要做清理了");
            if self.schedules then
                GlobalSchedule:Stop(self.schedules);
            end
            self.schedules = nil
           -- CompeteController:GetInstance():RequstCompetePrepareInfo()
        else
            local sce = 0
            if timeTab.min then
                timestr = timestr .. string.format(formatTime, timeTab.min) .. ":";
                sce = timeTab.min * 60
            end
            if timeTab.sec then
                timestr = timestr .. string.format(formatTime, timeTab.sec);
                sce = sce + timeTab.sec
            end

            self.timeText.text = sce;--"副本倒计时: " ..
        end
    end
end

function CompeteDungeReadyPanel:UpdateReward(tab)

    for id, num in pairs(tab) do
        if id == 90010003 or id == 90010004 or id == 90010029 then
            if self.rewards[id] then
                self.rewards[id]:SetData(id,num)
            else
                self.rewards[id] = CompeteDungeReadyRewardItem(self.CompeteDungeReadyRewardItem.gameObject,self.rewardObj,"UI")
                self.rewards[id]:SetData(id,num)
            end
        end
    end
    
    --local index = 1
    --for id, num in pairs(tab) do
    --    local  item = self.rewards[index]
    --    if not item then
    --        item = CompeteDungeReadyRewardItem(self.CompeteDungeReadyRewardItem.gameObject,self.rewardObj,"UI")
    --        self.rewards[index] = item
    --    end
    --    item:SetData(id,num)
    --    index = index + 1
    --
    --end
end

function CompeteDungeReadyPanel:SetShow(index)
    for i = 1, #self.textList do
        if index == i then
            SetVisible(self.textList[i],true)
        else
            SetVisible(self.textList[i],false)
        end
    end
end

function CompeteDungeReadyPanel:HandleRequestRankInfo()
    CompeteController:GetInstance():RequstCompeteRankInfo()
end

function CompeteDungeReadyPanel:RankReturnList(data)
    self:UpdateRankItems(data.ranking)
    self:SetMineInfo(data)
end

function CompeteDungeReadyPanel:SetMineInfo(data)
    self.role_name.text = RoleInfoModel:GetInstance():GetMainRoleData().name
    self.score.text = data.my_score
    local rank = data.my_rank
    if rank == 0 then
        local num = #data.ranking
        if num == 0 then
            num = 1
        end
        self.role_rank.text = num.."+"
    else
        self.role_rank.text  = rank
    end
end

function CompeteDungeReadyPanel:UpdateRankItems(tab)
    for i = 1, #tab do
        local item = self.rankItems[i]
        if not item then
            item = CompeteDungeReadyRankItem(self.CompeteDungeReadyRankItem.gameObject,self.items,"UI")
            self.rankItems[i] = item
        end
        item:SetData(tab[i],i)
    end
end

