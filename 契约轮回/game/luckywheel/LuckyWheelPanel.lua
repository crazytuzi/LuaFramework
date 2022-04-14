---
--- Created by  Administrator
--- DateTime: 2020/6/2 16:40
---
LuckyWheelPanel = LuckyWheelPanel or class("LuckyWheelPanel", BasePanel)
local this = LuckyWheelPanel

function LuckyWheelPanel:ctor()
    self.abName = "luckywheel"
    self.assetName = "LuckyWheelPanel"
    self.layer = "UI"
    self.panel_type = 2
    self.use_background = true
    self.events = {}
    self.items = {}
    self.isAni = false
    self.index = -1
    self.model = LuckyWheelModel:GetInstance()

end

function LuckyWheelPanel:dctor()
    self.model:RemoveTabListener(self.events)
    if not table.isempty(self.items) then
        for i, v in pairs(self.items) do
            v:destroy()
        end
        self.items = {}
    end
    self:StopAction()
    if self.once then
        GlobalSchedule.StopFun(self.once)
        self.once = nil
    end
end

function LuckyWheelPanel:Open()
    WindowPanel.Open(self)
end

function LuckyWheelPanel:LoadCallBack()
    self.nodes = {
        "startBtn","LuckyWheelItem","itemParent","arrow",
        "closeBtn","helpBtn","costParent/costIcon","costParent/costTex",
    }
    self:GetChildren(self.nodes)
    self.costIcon = GetImage(self.costIcon)
    self.costTex = GetText(self.costTex)

    self:InitUI()
    self:AddEvent()
    LuckyWheelController:GetInstance():RequestLuckyWheelInfo()
end

function LuckyWheelPanel:InitUI()
    local iconName = Config.db_item[enum.ITEM.ITEM_GOLD].icon
    GoodIconUtil:CreateIcon(self, self.costIcon, iconName, true)
end

function LuckyWheelPanel:AddEvent()

    local function call_back()
        if not self.cfg  then
            return
        end
        local maxRound = self.model:GetMaxRound()
        local round = self.model.round
        if round  > maxRound then
            Notify.ShowText("Attempts used up")
            return
        end
        if self.isAni  then
            Notify.ShowText("Drawing, wait please")
            return
        end
        local vipLv = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
        if  vipLv < self.vipLim then
            Notify.ShowText(string.format("Requires:vip lvl:%s",self.vipLim))
            return
        end

        if  RoleInfoModel.GetInstance():CheckGold(self.curCost) then
            if self.index ~= -1 then
                self.items[self.index]:SetShow(false)
            end

            --是否消耗%s钻石转动幸运转盘
            --本次最高可以获得%s钻石
            local str = string.format("Sure to spend %s diamonds to spin the wheel? Can get<color=#ff8942>%s diamonds</color> at most",self.curCost,self.model:GetMaxNum(self.rewardTab))
            local function ok_func()
                LuckyWheelController:GetInstance():RequestLuckyWheelTurnInfo(0)
            end
            Dialog.ShowTwo("Tip",str,"Sure",ok_func)

        end
    end
    AddButtonEvent(self.startBtn.gameObject,call_back)

    local function call_back()
        if self.isAni  then
            Notify.ShowText("Drawing, wait please")
            return
        end
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject,call_back)

    local function call_back()
        ShowHelpTip(self.model.help,true)
    end
    AddClickEvent(self.helpBtn.gameObject,call_back)


    self.events[#self.events + 1] = self.model:AddListener(LuckyWheelEvent.LuckyWheelInfo, handler(self, self.LuckyWheelInfo))
    self.events[#self.events + 1] = self.model:AddListener(LuckyWheelEvent.LuckyWheelReadyTurnInfo, handler(self, self.LuckyWheelReadyTurnInfo))
    self.events[#self.events + 1] = self.model:AddListener(LuckyWheelEvent.LuckyWheelTurnInfo, handler(self, self.LuckyWheelTurnInfo))

end

function LuckyWheelPanel:Reset()
    SetLocalRotation(self.arrow,0,0,0)
    self.items[self.index]:SetShow(false)
end

function LuckyWheelPanel:LuckyWheelInfo(data)
    self:UpdateItemsInfo()
end

function LuckyWheelPanel:UpdateItemsInfo()
    local round = self.model.round
    local maxRound = self.model:GetMaxRound()
    if round > maxRound then
        round = maxRound
    end
    --logError("当前圈数：",self.model.round)
    local key = round.."@"..self.model.act_id
    local cfg = Config.db_yunying_luckywheel[key]
    self.cfg = cfg
    if not cfg then
        logError("当前圈数没有配置：",round)
        return
    end
    local rewardTab = String2Table(cfg.reward)
    self.rewardTab = rewardTab
    for i = 1, #rewardTab do
        local item = self.items[i]
        if not item then
            item = LuckyWheelItem(self.LuckyWheelItem.gameObject,self.itemParent,"UI")
            self.items[i] = item
        end
        local x,y = GetTurnTablePos(i, self.model.maxRoundNum, 160)
        SetLocalPosition(item.transform,x,y)
        item:SetData(rewardTab[i],i)
        -- item:SetPosition(x, y)
    end
    self.vipLim = cfg.vip_limit
    local costTab = String2Table(cfg.cost)
    self.curCost = costTab[1][2]
    self.costTex.text = self.curCost
end



function LuckyWheelPanel:LuckyWheelReadyTurnInfo(data)
    self.index = data.grid
    local index = data.grid
    local rotate = GetTurnTableAngle(index, self.model.maxRoundNum)
    local function end_call_back()
        self.items[self.index]:SetShow(true)
        local function call_back()
            self.isAni = false
            LuckyWheelController:GetInstance():RequestLuckyWheelTurnInfo(1)
        end
        self.once = GlobalSchedule:StartOnce(call_back,0.7)
        --LuckyWheelController:GetInstance():RequestLuckyWheelTurnInfo(1)
    end
    self:StartAction(rotate, end_call_back)
end

function LuckyWheelPanel:LuckyWheelTurnInfo(data)
    local str = string.format("Congrats! You get <color=#ff8942>%s diamonds</color>",self.model:GetdimNum(data.grid,self.model.round - 1))
    local function btn_func2()
        self:Reset()
    end
    Dialog.ShowOne("Tip",str,"Sure",btn_func2)
    self:UpdateItemsInfo()
end

function LuckyWheelPanel:StartAction(rotate,call_back)
    self.isAni = true
    local time = self.turn_time or 2.0
    self:StopAction()
    self.is_action = true
    local extra = self.extra_rotate or -1080
    local action = cc.RotateTo(time, extra + rotate)
    action = cc.EaseInOut(action, 5)
    local function end_call_back()
        self:StopAction()
        if call_back then
            call_back()
        end
    end
    local call_action = cc.CallFunc(end_call_back)
    action = cc.Sequence(action, call_action)
    cc.ActionManager:GetInstance():addAction(action, self.arrow)
end

function LuckyWheelPanel:StopAction()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.arrow)
end

