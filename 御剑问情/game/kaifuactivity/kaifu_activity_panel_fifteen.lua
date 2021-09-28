KaifuActivityPanelFifteen = KaifuActivityPanelFifteen or BaseClass(BaseRender)
local  type_seq = {
    [0] = "boss",
    [1] = "active",
    [2] = "competition",
}
function KaifuActivityPanelFifteen:__init()
    self.target_list_obj = {}
    self.target_list = {}
    self.toggle_objs = {}
    for i = 1, 7 do
        self.target_list_obj[i] = self:FindObj("Target" .. i)
        self.target_list[i] = TargetCell.New(self.target_list_obj[i],i)
    end
    for i=0,2 do
        self.toggle_objs[i] = self:FindObj("Toggle" .. i)
    end
    self.button_obj = self:FindObj("Button")
    for i = 1, 3 do
        self:ListenEvent("OnClickTab" .. i, BindTool.Bind(self.OnClickTab, self, i - 1))
    end
    self:ListenEvent("OnClickButton", BindTool.Bind(self.OnClickButton, self))
    self:ListenEvent("OnClickBoss", BindTool.Bind(self.OnClickBoss,self))
    self:ListenEvent("OnClickActive", BindTool.Bind(self.OnClickActive,self))
    self.invest_num_value = self:FindVariable("InvestNum")
    self.reward_gold_num_value = self:FindVariable("RewardGoldNum")
    self.button_text_value = self:FindVariable("ButtonText")
    self.active_text_value = self:FindVariable("ActiveText")
    self.least_time_value = self:FindVariable("LeastTime")
    self.show_time = self:FindVariable("ShowTime")
    self.show_button = self:FindVariable("ShowButton")
    self.remind_text_value = self:FindVariable("RemindText")
    self.show_remind_text = self:FindVariable("ShowRemindText")
    self.show_boss = self:FindVariable("ShowBoss")
    self.show_active = self:FindVariable("ShowActive")
    self.show_reds = {}
    for i=1,3 do
        self.show_reds[i] = self:FindVariable("ShowRed" .. i)
    end
    self.tab_index = KAIFU_INVEST_TYPE.ACTIVE
    for k, v in pairs(self.toggle_objs) do
        if k == 1 then
            v.toggle.isOn = true
        else
            v.toggle.isOn = false
        end
    end
end

function KaifuActivityPanelFifteen:__delete()
    for k, v in pairs(self.target_list) do
        v:DeleteMe()
    end
    if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
    self.target_list = nil
    self.invest_num_value = nil
    self.reward_gold_num_value = nil
end

function KaifuActivityPanelFifteen:LoadCallBack()
end

function KaifuActivityPanelFifteen:ReleaseCallBack()
end

function KaifuActivityPanelFifteen:OpenCallBack()
    self:ChooseTab()
    self:Flush()
end

function KaifuActivityPanelFifteen:CloseCallBack()
    if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function KaifuActivityPanelFifteen:InitData()

    self.state = KaifuActivityData.Instance:GetInvestStateByType(self.tab_index)
    local cfg = KaifuActivityData.Instance:GetInvestCfgByType(self.tab_index)
    local data = KaifuActivityData.Instance:GetInvestData()
    local target_info = KaifuActivityData.Instance:GetInvestTargetInfoByType(self.tab_index)
    self.consume = cfg.consume
    self.reward_gold_num = cfg.reward_gold_bind
    self.active_text = cfg.active_reward_limit
    self.reward_item = target_info
    self.finish_num = KaifuActivityData.Instance:GetFinishNum(self.tab_index)
    self.recive_num = KaifuActivityData.Instance:GetReciveNum()[type_seq[self.tab_index]]
    if self.state == INVEST_STATE.complete then
        self.button_text = "已领取"
    elseif self.state == INVEST_STATE.outtime or self.state == INVEST_STATE.no_invest then
        self.button_text = "马上投资"
    else
        self.button_text = "领取"
    end
    self.remind_text = string.format(Language.KaiFuInvestRemind[self.tab_index],KaifuActivityData.Instance:GetParam(self.tab_index))
    if self.state == INVEST_STATE.no_invest then
        local least_time = KaifuActivityData.Instance:GetLeastTime(self.tab_index + 1)
        if self.least_time_timer then
            CountDown.Instance:RemoveCountDown(self.least_time_timer)
            self.least_time_timer = nil
        end
        self.least_time_timer = CountDown.Instance:AddCountDown(least_time, 1, function ()
            least_time = least_time - 1
            local time_tab = TimeUtil.Format2TableDHMS(least_time)
            self.day = time_tab.day
            self.hour = self:TimeDispose(time_tab.hour)
            self.min = self:TimeDispose(time_tab.min)
            self.s = self:TimeDispose(time_tab.s)
            self:SetTime()
        end)
    end
end

function KaifuActivityPanelFifteen:ChooseTab()
    for i=0,2 do
        if KaifuActivityData.Instance:ShowInvestTypeRedPoint(i) then
            self.tab_index = i
            for k,v in pairs(self.toggle_objs) do
                if k == i then
                    v.toggle.isOn = true
                else
                    v.toggle.isOn = false
                end
            end
            return
        end
    end
end

function KaifuActivityPanelFifteen:TimeDispose(time)
    if time < 10 then
        time = "0" .. time
        return time
    end
    return time
end

function KaifuActivityPanelFifteen:OnFlush()
    self:InitData()
    self:SetDataView()
    self:ShowView()
end

function KaifuActivityPanelFifteen:SetDataView()
    self.invest_num_value:SetValue(self.consume)
    self.reward_gold_num_value:SetValue(self.reward_gold_num)
    for k, v in pairs(self.target_list) do
        v:SetData(self.reward_item[k].reward_item[0], self.reward_item[k].param, self.tab_index, self.recive_num + 1)
    end
    self.active_text_value:SetValue(self.active_text)
    self.button_text_value:SetValue(self.button_text)
    if self.state == INVEST_STATE.outtime then
        self.least_time_value:SetValue("已过投资时间")
    end
    self.remind_text_value:SetValue(self.remind_text)
end

function KaifuActivityPanelFifteen:SetTime()
    if self.least_time_value then
            local time_str = ""
            local left_time = self.day * 3600 * 24 + self.hour * 3600 + self.min * 60 + self.s
            if self.day > 0 then
                time_str = TimeUtil.FormatSecond(left_time, 8)
            else
                time_str = TimeUtil.FormatSecond(left_time)
            end
             self.least_time_value:SetValue(
                    "剩余时间：" .. ToColorStr(time_str, TEXT_COLOR.GREEN2))
    end
end

function KaifuActivityPanelFifteen:ShowView()
    self.show_time:SetValue(false)
    if self.state == INVEST_STATE.no_invest or self.state == INVEST_STATE.finish then
        self.button_obj.button.interactable = true
        self.show_button:SetValue(true)
    else
        self.button_obj.button.interactable = false
        self.show_button:SetValue(false)
    end
    for i=1,3 do
        self.show_reds[i]:SetValue(KaifuActivityData.Instance:ShowInvestTypeRedPoint(i - 1))
    end
    for i=1,self.recive_num do
        self.target_list[i]:ShowGet()
    end
    if self.state == INVEST_STATE.finish or self.state == INVEST_STATE.no_finish then
        if self.tab_index == 0 then
            self.show_boss:SetValue(true)
            self.show_active:SetValue(false)
        elseif self.tab_index == 1 then
            self.show_active:SetValue(true)
            self.show_boss:SetValue(false)
        else
            self.show_boss:SetValue(false)
            self.show_active:SetValue(false)
        end
        self.show_remind_text:SetValue(true)
    else
        self.show_remind_text:SetValue(false)
        self.show_boss:SetValue(false)
        self.show_active:SetValue(false)
    end

    if self.state == INVEST_STATE.no_invest or self.state == INVEST_STATE.outtime then
        self.show_time:SetValue(true)
    end
end

function KaifuActivityPanelFifteen:OnClickTab(tab_index)
    if tab_index == self.tab_index then return end
    self.tab_index = tab_index
    self:Flush()
end

function KaifuActivityPanelFifteen:OnClickButton()
    if self.state == INVEST_STATE.no_invest then
        KaifuActivityCtrl.Instance:SendRandActivityOperaReq(2176, 1, self.tab_index, 0)
    elseif self.state == INVEST_STATE.finish then
        KaifuActivityCtrl.Instance:SendRandActivityOperaReq(2176, 2, self.tab_index, self.recive_num)
    end
end

function KaifuActivityPanelFifteen:OnClickBoss()
    ViewManager.Instance:Close(ViewName.KaifuActivityView)
    ViewManager.Instance:Open(ViewName.Boss, TabIndex.miku_boss)
end

function KaifuActivityPanelFifteen:OnClickActive()
    ViewManager.Instance:Close(ViewName.KaifuActivityView)
    ViewManager.Instance:Open(ViewName.BaoJu, TabIndex.baoju_zhibao_active)
end

TargetCell = TargetCell or BaseClass(BaseRender)

function TargetCell:__init(instance,i)
    self.text = self:FindVariable("TargetText")
    self.item_obj = self:FindObj("Item")
    self.show_get = self:FindVariable("HasGet")
    self.show_highlight = self:FindVariable("ShowHighLight")
    self.item = ItemCell.New()
    self.item:SetInstanceParent(self.item_obj)
    self.target_types = {}
    for i=1,3 do
        self.target_types[i] = self:FindVariable("TargetType" .. i)
    end
    self.num = self:FindVariable("Num")
    self.index = i
end

function TargetCell:__delete()
    if self.item then
        self.item:DeleteMe()
        self.item = nil
    end
    self.item_obj = nil
    self.text = nil
end

function TargetCell:SetData(data, text, index, next_recive_num)
    self.item:SetData(data)
    self.text:SetValue(Language.KaiFuInvest[index])
    for k,v in pairs(self.target_types) do
        if k == index + 1 then
            v:SetValue(true)
        else
            v:SetValue(false)
        end
    end
    self.num:SetValue(text)
    self.show_get:SetValue(false)
    if self.index == next_recive_num then
        self.show_highlight:SetValue(true)
    else
        self.show_highlight:SetValue(false)
    end
end

function TargetCell:ShowGet()
    self.show_get:SetValue(true)
end