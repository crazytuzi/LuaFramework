---
--- Created by  Administrator
--- DateTime: 2019/11/20 11:22
---
CompeteMatchPanel = CompeteMatchPanel or class("CompeteMatchPanel", BasePanel)
local this = CompeteMatchPanel

function CompeteMatchPanel:ctor(parent_node, parent_panel)
    self.abName = "compete";
    self.image_ab = "compete_image";
    self.assetName = "CompeteMatchPanel"
    self.use_background = false
    self.show_sidebar = false
    self.model = CompeteModel:GetInstance()
    self.events = {}
    self.typeIndex = -1 --1天榜 2地榜
    self.redPoints = {}
    self.leftItems = {}

end

function CompeteMatchPanel:dctor()
    self.model:RemoveTabListener(self.events)

    if self.leftItems then
        for i, v in pairs(self.leftItems) do
            for j, item in pairs(v) do
                item:destroy()
            end
        end
        self.leftItems = {}
    end
    if self.Champion then
        self.Champion:destroy()
    end

    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end
    self.schedules = nil
end

function CompeteMatchPanel:LoadCallBack()
    self.nodes = {
        "closeBtn","btnObj","btnObj/tog_text_1","btnObj/tog_btn","btnObj/tog_text_2","CompeteMatchRightRoleItem","CompeteMatchLeftRoleItem","bigBg",
        "leftObj/group105","leftObj/group102","leftObj/group101","leftObj/group203",
        "leftObj/group106","leftObj/group301","leftObj/group201",
        "rightObj/group108","rightObj/group103","rightObj/group202","rightObj/group107",
        "rightObj/group204","rightObj/group302","rightObj/group104",
        "middleObj/group401",
        "leftObj/leftBtnObj/guessBtn_106","leftObj/leftBtnObj/guessBtn_101","leftObj/leftBtnObj/guessBtn_203","leftObj/leftBtnObj/guessBtn_102",
        "leftObj/leftBtnObj/guessBtn_301","leftObj/leftBtnObj/guessBtn_105","leftObj/leftBtnObj/guessBtn_201",
        "rightObj/rightBtnObj/guessBtn_104","rightObj/rightBtnObj/guessBtn_107","rightObj/rightBtnObj/guessBtn_108",
        "rightObj/rightBtnObj/guessBtn_103","rightObj/rightBtnObj/guessBtn_202",
        "rightObj/rightBtnObj/guessBtn_204","rightObj/rightBtnObj/guessBtn_302","middleObj/guessBtn_401",

        "leftObj/leftWinBg/groupWin101_1","leftObj/leftWinBg/groupWin101_2","leftObj/leftWinBg/groupWin102_1",
        "leftObj/leftWinBg/groupWin105_2","leftObj/leftWinBg/groupWin201_2","leftObj/leftWinBg/groupWin301_1",
        "leftObj/leftWinBg/groupWin106_2","leftObj/leftWinBg/groupWin105_1","leftObj/leftWinBg/groupWin106_1",
        "leftObj/leftWinBg/groupWin203_1","leftObj/leftWinBg/groupWin201_1","leftObj/leftWinBg/groupWin301_2",
        "leftObj/leftWinBg/groupWin102_2","leftObj/leftWinBg/groupWin203_2",

        "rightObj/rightWinBg/groupWin103_1","rightObj/rightWinBg/groupWin103_2","rightObj/rightWinBg/groupWin104_1",
        "rightObj/rightWinBg/groupWin104_2","rightObj/rightWinBg/groupWin107_1","rightObj/rightWinBg/groupWin107_2",
        "rightObj/rightWinBg/groupWin108_1","rightObj/rightWinBg/groupWin108_2","rightObj/rightWinBg/groupWin202_1",
        "rightObj/rightWinBg/groupWin202_2","rightObj/rightWinBg/groupWin204_1",
        "rightObj/rightWinBg/groupWin204_2","rightObj/rightWinBg/groupWin302_1","rightObj/rightWinBg/groupWin302_2",
        "timeObj/time",
        "championObj/championObjParent",
    }
    self:GetChildren(self.nodes)

    self.tog_text_1 = GetText(self.tog_text_1)
    self.tog_text_2 = GetText(self.tog_text_2)
    self.bigBg = GetImage(self.bigBg)
    for i, v in pairs(CompeteModel.Pos) do
        self["guessBtn_"..i] = GetImage(self["guessBtn_"..i])
    end
    self.time = GetText(self.time)
    self.time.text = "You can bet when the event starts"
    self:InitUI()
    self:AddEvent()
    lua_resMgr:SetImageTexture(self, self.bigBg, "iconasset/icon_big_bg_compete_big_bg", "compete_big_bg", false)
   -- CompeteController:GetInstance():RequstCompeteMatchInfo(1)
    self:HandleTogBtnClick(nil,1,1,enum.COMPETE_BATTLE.COMPETE_BATTLE_RANK1)

    SetAlignType(self.closeBtn.transform, bit.bor(AlignType.Right, AlignType.Null))
end

function CompeteMatchPanel:InitUI()
    for pos, v in pairs(CompeteModel.Pos) do --左边
        --self["group"..pos]
        self.leftItems[pos] = {}
        for i = 1, 2 do
            local item = self.leftItems[pos][i]
            if not item then
                if v == 1 then --左边
                    item = CompeteMatchLeftRoleItem(self.CompeteMatchLeftRoleItem.gameObject,self["group"..pos],"UI")
                elseif v == 2 then  --右
                    item = CompeteMatchRightRoleItem(self.CompeteMatchRightRoleItem.gameObject,self["group"..pos],"UI")
                else
                    item = CompeteMatchLeftRoleItem(self.CompeteMatchRightRoleItem.gameObject,self["group"..pos],"UI")
                end

                self.leftItems[pos][i] = item
            end
            item:SetData(pos,i,v)
        end
    end

    --冠军
    if not self.Champion then
        self.Champion = CompeteMatchLeftRoleItem(self.CompeteMatchLeftRoleItem.gameObject,self.championObjParent,"UI")
        self.Champion:SetData(0,0,0)
    end

end

function CompeteMatchPanel:AddEvent()
    for i, v in pairs(CompeteModel.Pos) do
        local function call_back(go)
            local name = go.gameObject.name
            local teamTbl = string.split(name,"_")
            local pos = tonumber(teamTbl[2])
            --logError(pos)
            local groupData = self.model:GetRoleGroupData(self.curType,pos)
            if not groupData then
                return
            end
            if groupData.guess ~= '0' then
                Notify.ShowText("You already bet on this bracket")
                return
            end
            if groupData.winner ~= '0'then
                Notify.ShowText("Results have come out! You must be quick")
                return
            end
            local isNull = false
            for i = 1, 2 do
                if not groupData.vs[i] then
                    isNull = true
                end
            end

            if isNull then
                Notify.ShowText("This player is a bye for this round!")
                return
            end
            lua_panelMgr:GetPanelOrCreate(CompeteGuessPanel):Open(groupData,self.data.type)
        end
        AddClickEvent(self["guessBtn_"..i].gameObject,call_back)
    end

    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject,call_back)

    AddClickEvent(self.tog_text_1.gameObject, handler(self, self.HandleTogBtnClick, enum.COMPETE_BATTLE.COMPETE_BATTLE_RANK1));
    AddClickEvent(self.tog_text_2.gameObject, handler(self, self.HandleTogBtnClick, enum.COMPETE_BATTLE.COMPETE_BATTLE_RANK2));
    self.events[#self.events + 1] = self.model:AddListener(CompeteEvent.CompeteMatchInfo,handler(self,self.CompeteMatchInfo))
    self.events[#self.events + 1] = self.model:AddListener(CompeteEvent.CompeteGuessInfo,handler(self,self.CompeteGuessInfo))
end

function CompeteMatchPanel:CompeteMatchInfo(data)
    --logError(data.type)

    --dump(data)
    self.data = data
    self.curType = data.type
   -- logError("round:"..self.data.round)
    self.end_time = self.data.guess_etime
    self.start_time = self.data.guess_stime
    if self.model.curPeriod == enum.COMPETE_PERIOD.COMPETE_PERIOD_RANK then --争霸阶段
        if self.schedules then
            GlobalSchedule:Stop(self.schedules);
        end
        self.schedules = nil
        self:StartCountDown()
        self.schedules = GlobalSchedule:Start(handler(self, self.StartCountDown), 0.1, -1);
    else
        self.time.text = "Quiz unlocks when the event proceeds to the brawl period"
    end
    --if os.time() < self.start_time  then --未开始
    --    self.time.text = ""
    --end
    self:UpdateRoleItems(data.type)
end

function CompeteMatchPanel:StartCountDown()
    if self.end_time then
        local timeTab = nil;
        local timestr = "";
        local formatTime = "%02d";
        --SetGameObjectActive(self.endTime.gameObject, true);
        timeTab = TimeManager:GetLastTimeData(os.time(), self.end_time);
        if table.isempty(timeTab) then
            -- Notify.ShowText("副本结束了,需要做清理了");
            self.time.text = "This round of bet is over"
            if self.schedules then
                GlobalSchedule:Stop(self.schedules);
            end
            self.schedules = nil
        else
            if timeTab.min then
                timestr = timestr .. string.format(formatTime, timeTab.min) .. ":";
            end
            if timeTab.sec then
                timestr = timestr .. string.format(formatTime, timeTab.sec);
            end
           -- self.endTitleTxt.text = timestr;--"副本倒计时: " ..
            self.time.text = "Current quiz ends in:"..timestr
        end
    end
end

--竞猜成功
function CompeteMatchPanel:CompeteGuessInfo(data)
    local group = data.group
    local type = data.rank
    if self.redPoints[group]  then
        self.redPoints[group]:SetRedDotParam(false)
    end
    ShaderManager.GetInstance():SetImageGray(self["guessBtn_"..group])
    self.model:SetGuessData(type,group,data.role)

end

function CompeteMatchPanel:HandleTogBtnClick(go, x, y, index)
    if self.typeIndex == index then
        return
    end
    self.typeIndex = index
    local posX
    if index == enum.COMPETE_BATTLE.COMPETE_BATTLE_RANK1 then
        posX = -54
        --SetColor(self.tog_text_1, 0x99, 0x48, 0x29, 255);
        --SetColor(self.tog_text_2, 0xEB, 0xD3, 0x9A, 255);
    else
        posX = 55
    end
    --if self.model.curPeriod == enum.COMPETE_PERIOD.COMPETE_PERIOD_RANK then
        CompeteController:GetInstance():RequstCompeteMatchInfo(index)
   -- end
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.tog_btn.transform)
    local value_action = cc.MoveTo(0.1, posX, -1, 0)
    cc.ActionManager:GetInstance():addAction(value_action, self.tog_btn.transform)
end

--1天 2地
function CompeteMatchPanel:UpdateRoleItems(matchType)
   -- dump(self.leftItems)
    self.Champion:UpdateInfo(nil,false)
    for pos, v in pairs(self.leftItems) do
        local groupData = self.model:GetRoleGroupData(matchType,pos)
        if  groupData  then
            local isNull = false
            local winner = groupData.winner
            local isWinner = false
            for i = 1, 2 do
                local key = string.format("groupWin%s_%s",pos,i)
                if not groupData.vs[i] then
                    isNull = true
                    SetVisible(self[key],false)
                else
                    if winner == groupData.vs[i].role.id then
                        isWinner = true
                        if pos == 401 then  --最后一组
                            self.Champion:UpdateInfo(groupData.vs[i],isNull)
                        end
                        SetVisible(self[key],true)

                    else
                        SetVisible(self[key],false)
                    end
                end
                self.leftItems[pos][i]:UpdateInfo(groupData.vs[i],isNull)

            end
            if isWinner then  --已经有胜利者
                if self.redPoints[pos]  then
                    self.redPoints[pos]:SetRedDotParam(false)
                end
                local num = math.floor(pos / 100)
                if pos == 401 then
                    SetVisible(self["guessBtn_"..pos],false)
                else
                    if num == self.data.round then
                        if self.redPoints[pos]  then
                            self.redPoints[pos]:SetRedDotParam(false)
                        end
                        ShaderManager.GetInstance():SetImageGray(self["guessBtn_"..pos])
                        SetVisible(self["guessBtn_"..pos],true)
                    else
                        SetVisible(self["guessBtn_"..pos],false)
                    end
                end

            else--没有胜利者 判断竞猜状态
                if isNull then
                    if self.redPoints[pos]  then
                        self.redPoints[pos]:SetRedDotParam(false)
                    end
                    ShaderManager.GetInstance():SetImageGray(self["guessBtn_"..pos])
                    SetVisible(self["guessBtn_"..pos],true)
                else
                    if groupData.guess == "0" or groupData.guess == 0 then --为竞猜
                        if not self.redPoints[pos]  then
                            self.redPoints[pos] = RedDot(self["guessBtn_"..pos].transform, nil, RedDot.RedDotType.Nor)
                            self.redPoints[pos]:SetPosition(34, 13)
                        end
                        self.redPoints[pos]:SetRedDotParam(true)

                        ShaderManager.GetInstance():SetImageNormal(self["guessBtn_"..pos])
                    else  --已经竞猜了
                        if self.redPoints[pos]  then
                            self.redPoints[pos]:SetRedDotParam(false)
                        end
                        ShaderManager.GetInstance():SetImageGray(self["guessBtn_"..pos])
                    end

                    SetVisible(self["guessBtn_"..pos],true)
                end
            end
        else
            local isNeedHide = false
            if self.data.round ~= 0 then
                local nextRound = self.data.round + 1
                local num = math.floor(pos / 100)
                if nextRound == num then
                    isNeedHide = true
                end
            else
                local num = math.floor(pos / 100)
                if num == 2 then
                    isNeedHide = true
                end
            end

            if self.redPoints[pos]  then
                self.redPoints[pos]:SetRedDotParam(false)
            end
            SetVisible(self["guessBtn_"..pos],false)
            for i = 1, 2 do
                local key = string.format("groupWin%s_%s",pos,i)
                SetVisible(self[key],false)
                self.leftItems[pos][i]:UpdateInfo(nil,false)
                if isNeedHide  then
                    local boo = true
                   -- for j = 1, #CompeteModel.Round[pos] do
                        if  self.model:GetRoleGroupData(matchType,CompeteModel.Round[pos][i]) then
                            SetVisible(self.leftItems[pos][i],false)
                        else
                            SetVisible(self.leftItems[pos][i],true)
                        end
                  --  end
                end
            end

        end

    end
end