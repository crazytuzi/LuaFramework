---
--- Created by  Administrator
--- DateTime: 2019/11/18 15:38
---
CompetePanel = CompetePanel or class("CompetePanel", BaseItem)
local this = CompetePanel

function CompetePanel:ctor(parent_node, parent_panel)
    self.abName = "compete";
    self.image_ab = "compete_image";
    self.assetName = "CompetePanel"
    self.layer = "UI"
    self.events = {}
    self.gEvent = {}
    self.model = CompeteModel:GetInstance()
    CompetePanel.super.Load(self)
end

function CompetePanel:dctor()
    self.model:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener(self.gEvent)
    self.model.isOpenCopetePanel = false
    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
        self.schedule = nil
    end

    if self.enter_red then
        self.enter_red:destroy()
        self.enter_red = nil
    end

    if self.macth_red then
        self.macth_red:destroy()
        self.macth_red = nil
    end

end

function CompetePanel:LoadCallBack()
    self.nodes = {
        "iconParent/matchIcon","iconParent/rewardIcon","period2","period3","period1","period0",
        "period1/periodSelect1","period0/periodBg0","period1/periodBg1","period3/periodSelect3",
        "period0/timeObj0/time0","period3/periodBg3","period3/timeObj3/time3","period2/timeObj2/time2","period2/periodBg2",
        "period1/timeObj1/time1","period0/periodSelect0","period2/periodSelect2",
        "moneyObj/addBtn","enrollObj/enrollTex","moneyObj/moneyTex","moneyObj/moneyIcon","enrollBtn",
        "iconParent/shopIcon","iconParent/rankIcon","enterBtn","enrollBtn/enrollBtnText",
        "period1/timeObj1","period2/timeObj2","period3/timeObj3","period0/timeObj0","wenhao",
    }
    self:GetChildren(self.nodes)
    self.enterBtnImg = GetImage(self.enterBtn)
    self.enrollBtnText = GetText(self.enrollBtnText)
    self.enrollBtnImg = GetImage(self.enrollBtn)
    self.periodBg0 = GetImage(self.periodBg0)
    self.periodBg1 = GetImage(self.periodBg1)
    self.periodBg2 = GetImage(self.periodBg2)
    self.periodBg3 = GetImage(self.periodBg3)
    self.enrollTex = GetText(self.enrollTex)

    self.time0 = GetText(self.time0)
    self.time1 = GetText(self.time1)
    self.time2 = GetText(self.time2)
    self.time3 = GetText(self.time3)

    self.moneyIcon = GetImage(self.moneyIcon)
    self.moneyTex = GetText(self.moneyTex)
    self:InitUI()
    self:AddEvent()
    self.model.isOpenCopetePanel = true
    CompeteController:GetInstance():RequstCompetePanelInfo()
    self:CheckRedPoint()

end

function CompetePanel:InitUI()
    local costTab = self.model:GetEnterCost()
    if costTab then
        self.costId = costTab[1]
       -- local num = costTab[2]
        local iconName = Config.db_item[self.costId].icon
        GoodIconUtil:CreateIcon(self, self.moneyIcon, iconName, true)
        local num =  BagModel:GetInstance():GetItemNumByItemID(self.costId)
        local color = "eb0000"
        if num >= 1 then
            color = "6CFE00"
        end
        self.moneyTex.text = string.format("<color=#%s>%s</color>",color,num)
    end
    --local money =  BagModel:GetInstance():GetItemNumByItemID(id)
    --local  tab = self.model:GetMingNum()
    --dump(tab)
end

function CompetePanel:AddEvent()

    local function call_back() --报名
        if self.curPeriod == enum.COMPETE_PERIOD.COMPETE_PERIOD_TRUCE  then --休战中
            Notify.ShowText("In truce")
            return
        end
        if self.model.isEnroll  then
            Notify.ShowText("Registration successful")
            return
        end
        CompeteController:GetInstance():RequstCompeteEnroll(self.model.actId)
    end
    AddClickEvent(self.enrollBtn.gameObject,call_back)

    local function call_back() --进入战场
        if not self.model.isEnroll  then
            Notify.ShowText("You didn't register yet~")
            return
        end
        local actCfg = Config.db_activity[self.model.actId]
        SceneControler:GetInstance():RequestSceneChange(actCfg.scene, enum.SCENE_CHANGE.SCENE_CHANGE_ACT, nil, nil, self.model.actId);
    end
    AddClickEvent(self.enterBtn.gameObject,call_back)


    local function call_back() --奖励
        lua_panelMgr:GetPanelOrCreate(CompeteRewardMainPanel):Open()
    end
    AddButtonEvent(self.rewardIcon.gameObject,call_back)


    local function call_back() --匹配界面
        lua_panelMgr:GetPanelOrCreate(CompeteMatchPanel):Open()
    end
    AddButtonEvent(self.matchIcon.gameObject,call_back)

    local function call_back() --商店
        lua_panelMgr:GetPanelOrCreate(CompeteShopPanel):Open()
    end
    AddButtonEvent(self.shopIcon.gameObject,call_back)

    local function call_back() --排行
        lua_panelMgr:GetPanelOrCreate(CompeteRankPanel):Open()
    end
    AddButtonEvent(self.rankIcon.gameObject,call_back)

    local function call_back() --去商店

        OpenLink(180,1,2,1,2127)
    end
    AddButtonEvent(self.addBtn.gameObject,call_back)

    local function call_back() --去商店
        ShowHelpTip(HelpConfig.compete.Help,true,700)
    end
    AddButtonEvent(self.wenhao.gameObject,call_back)


    self.events[#self.events + 1] = self.model:AddListener(CompeteEvent.CompetePanelInfo,handler(self,self.CompetePanelInfo))

    self.events[#self.events + 1] = self.model:AddListener(CompeteEvent.CompeteEnroll,handler(self,self.CompeteEnroll))

    self.gEvent[#self.gEvent + 1] = GlobalEvent:AddListener(CompeteEvent.CheckRedPoint,handler(self,self.CheckRedPoint))

    local function call_back(id)
        if id ~= self.costId then
            return
        end
        local num =  BagModel:GetInstance():GetItemNumByItemID(self.costId)
        local color = "eb0000"
        if num >= 1 then
            color = "6CFE00"
        end
        self.moneyTex.text = string.format("<color=#%s>%s</color>",color,num)
    end
    self.gEvent[#self.gEvent + 1]  = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)
    
    --CompetePanelInfo
end

function CompetePanel:CheckRedPoint()
    if not self.enter_red  then
        self.enter_red = RedDot(self.enterBtn, nil, RedDot.RedDotType.Nor)
        self.enter_red:SetPosition(65, 15)
    end

    if not self.macth_red then
        self.macth_red = RedDot(self.matchIcon, nil, RedDot.RedDotType.Nor)
        self.macth_red:SetPosition(23, 23)
    end
    self.macth_red:SetRedDotParam(self.model.redPoints[2])
    self.enter_red:SetRedDotParam(self.model.redPoints[1])
end

--面板信息返回
function CompetePanel:CompetePanelInfo(data)
    --self.model.isCross
    --self.model.isCross
    --self.curPeriod = data.cur_period
    --self.isEnroll = data.is_enroll
    --dump(data)
    self.data = data
    --logError("当前阶段："..self.model.curPeriod)
    self:SetBtnState()
    self:SetPeriodInfo()
end

function CompetePanel:CompeteEnroll()
    Notify.ShowText("Successfully signed up")
    self:SetBtnState()
    local num =  BagModel:GetInstance():GetItemNumByItemID(self.costId)
    local color = "eb0000"
    if num >= 1 then
        color = "6CFE00"
    end
    self.moneyTex.text = string.format("<color=#%s>%s</color>",color,num)
end

function CompetePanel:SetPeriodInfo()
    self.curPeriod = self.model.curPeriod
    if self.curPeriod == enum.COMPETE_PERIOD.COMPETE_PERIOD_OUST then
        self.curPeriod = enum.COMPETE_PERIOD.COMPETE_PERIOD_ENROLL
    end

    self.periodEndTime = 0
    self.periodStartTime = 0
    if self.curPeriod == enum.COMPETE_PERIOD.COMPETE_PERIOD_ENROLL then --报名阶段
        self.periodEndTime = self.data.enroll_etime
        self.periodStartTime = self.data.enroll_stime
    elseif self.curPeriod == enum.COMPETE_PERIOD.COMPETE_PERIOD_SELECT  then --海选
        self.periodEndTime = self.data.select_etime
        self.periodStartTime = self.data.select_stime
    elseif self.curPeriod == enum.COMPETE_PERIOD.COMPETE_PERIOD_RANK  then --争霸赛
        self.periodEndTime = self.data.rank_etime
        self.periodStartTime = self.data.rank_stime
    end

    --self.schedule = GlobalSchedule.StartFun(handler(self, self.StartCountDown), 1, -1)
    for i = 0, 3 do
        local period = i
        if self.curPeriod == period then
            SetVisible(self["periodSelect"..period],true)
            SetLocalScale(self["period"..period],1.1,1.1,1.1)
            ShaderManager.GetInstance():SetImageNormal(self["periodBg"..period])
            SetVisible(self["timeObj"..period],curPeriod ~= enum.COMPETE_PERIOD.COMPETE_PERIOD_TRUCE )

            if self.periodEndTime  ~= 0 then
                if self.schedule then
                    GlobalSchedule:Stop(self.schedule)
                    self.schedule = nil
                end
                self:StartCountDown()
                self.schedule = GlobalSchedule.StartFun(handler(self, self.StartCountDown), 1, -1)
            else
                self["time"..self.curPeriod].text = string.format("Time Left: <color=#eb0000>%s</color>","Ended")
            end

        else
            SetLocalScale(self["period"..period],1,1,1)
            SetVisible(self["periodSelect"..period],false)
            SetVisible(self["timeObj"..period],false)
            ShaderManager.GetInstance():SetImageGray(self["periodBg"..period])
            --periodBg0
        end
    end
end



function CompetePanel:SetBtnState()
    local time = os.date("%m/%d/ %H:%M", self.data.select_stime)
    local str =  string.format("<color=#eb0000>Not registered</color>, <color=#6CFE00>%s</color> starts",time)
    if self.model.isEnroll  then
        str = string.format("<color=#eb0000>Enrolled</color>,  Plz attend at <color=#6CFE00>%s</color> tonight！",time)
    end
    self.enrollTex.text = str
    if self.model.curPeriod == enum.COMPETE_PERIOD.COMPETE_PERIOD_ENROLL then --报名

        SetVisible(self.enrollBtn,true)
        SetVisible(self.enterBtn,false)
        if self.model.isEnroll then
            self.enrollBtnText.text = "Registered"
            ShaderManager.GetInstance():SetImageGray(self.enrollBtnImg)
        else
            self.enrollBtnText.text = "Tap to register"
            ShaderManager.GetInstance():SetImageNormal(self.enrollBtnImg)
        end
        -- self.enterBtnImg
    elseif self.model.curPeriod == enum.COMPETE_PERIOD.COMPETE_PERIOD_TRUCE then --休战
        SetVisible(self.enrollBtn,true)
        SetVisible(self.enterBtn,false)
        self.enrollBtnText.text = "In truce"
       -- self.enrollBtnText.text = "休战中"
   -- elseif self.model.curPeriod == enum.COMPETE_PERIOD.COMPETE_PERIOD_SELECT then --海选

    else  --
        SetVisible(self.enrollBtn,false)
        SetVisible(self.enterBtn,true)
        --if self.isEnroll then --报名了
        --    SetVisible(self.enrollBtn,false)
        --    SetVisible(self.enterBtn,true)
        --else --没报名
        --    SetVisible(self.enrollBtn,true)
        --    SetVisible(self.enterBtn,false)
        --end
    end
end

function CompetePanel:StartCountDown()
    local timeTab = TimeManager:GetLastTimeData(os.time(), self.periodEndTime);
    local timestr = "";
    local formatTime = "%02d";
    if table.isempty(timeTab) then
        if self.schedule then
            GlobalSchedule:Stop(self.schedule)
            self.schedule = nil
        end
        self["time"..self.curPeriod].text = string.format("Time Left: <color=#eb0000>%s</color>","Ended")
    else
        timeTab.min = timeTab.min or 0;
        timeTab.hour = timeTab.hour or 0;
        timeTab.day = timeTab.day or 0
        if  timeTab.day == 0  then
            if timeTab.hour then
                timestr = timestr .. string.format("%02d", timeTab.hour) .. "hr";
            end
            if timeTab.min then
                timestr = timestr .. string.format("%02d", timeTab.min) .. "min";
            end
            if timeTab.sec then
                timestr = timestr .. string.format("%02d", timeTab.sec).."sec";
            end
        else
            if timeTab.day then
                timestr = timestr .. string.format("%02d", timeTab.day) .. "Days";
            end
            if timeTab.hour then
                timestr = timestr .. string.format("%02d", timeTab.hour) .. "hr";
            end
            --if timeTab.min then
            --    timestr = timestr .. string.format("%02d", timeTab.min) .. "分";
            --end
            --if timeTab.sec then
            --    timestr = timestr .. string.format("%02d", timeTab.sec).."秒";
            --end
        end

      --  logError(timestr)
        self["time"..self.curPeriod].text = string.format("Time Left: <color=#6CFE00>%s</color>",timestr)
        --self.time.text = timestr;--"副本倒计时: " ..
    end
end