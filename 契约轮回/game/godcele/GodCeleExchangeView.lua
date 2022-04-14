-- @Author: lwj
-- @Date:   2019-09-06 17:13:51 
-- @Last Modified time: 2019-09-06 17:14:45

GodCeleExchangeView = GodCeleExchangeView or class("GodCeleExchangeView", BaseItem)
local GodCeleExchangeView = GodCeleExchangeView

function GodCeleExchangeView:ctor(parent_node, parent_panel, actID, asset)
    self.abName = "sevenDayActive"
    self.assetName = asset or "GodCeleExchangeView"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.is_set_red = false
    self.actID = actID
    --配置
    self.openData = OperateModel:GetInstance():GetAct(self.actID)
    --数据
    self.data = OperateModel:GetInstance():GetActInfo(self.actID)
    self.model = GodCelebrationModel.GetInstance()
    BaseItem.Load(self)
end

function GodCeleExchangeView:dctor()
    if self.success_exchange_event_id then
        GlobalEvent:RemoveListener(self.success_exchange_event_id)
        self.success_exchange_event_id = nil
    end
    if self.countdowntext then
        self.countdowntext:destroy()
        self.countdowntext = nil
    end
    for i, v in pairs(self.item_list) do
        if v then
            v:destroy()
        end
    end
    self.item_list = {}
    self.parentPanel = nil
end

function GodCeleExchangeView:LoadCallBack()
    self.nodes = {
        "Scroll/Viewport/item_con", "time_con", "Cur_Score/num", "Scroll/Viewport/item_con/GodExchangeItem", "Cur_Score/btn_plus",
        "end_tip", "time_con/countdowntext", "Cur_Score/icon", "time_con/ques",
    }
    self:GetChildren(self.nodes)
    self.item_obj = self.GodExchangeItem.gameObject
    self.num = GetText(self.num)
    self.time_text = GetText(self.countdowntext)
    self.score_icon = GetImage(self.icon)
    SetVisible(self.end_tip, false)

    self:AddEvent()
    self:InitPanel()
end

function GodCeleExchangeView:AddEvent()
    local function callback()
        OpenLink(160, 1, 1, 2, 1, "true")
        GlobalEvent:Brocast(GodCeleEvent.CloseGodCelePanel)
    end
    AddButtonEvent(self.btn_plus.gameObject, callback)

    local function callback(data)
        if data.act_id ~= self.actID then
            return
        end
        self:UpdateNum()
    end
    self.success_exchange_event_id = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, callback)

    local function callback()
        ShowHelpTip(HelpConfig.GodCelebration.ActDesc, true)
    end
    AddButtonEvent(self.ques.gameObject, callback)
end

function GodCeleExchangeView:InitPanel()
    self:LoadItems()
    self:InitTime()
    self:UpdateNum()

    if self.cost_item_id then
        local item_cf = Config.db_item[self.cost_item_id]
        if item_cf then
            GoodIconUtil.GetInstance():CreateIcon(self, self.score_icon, tostring(item_cf.icon), true)
        end
    end
end

function GodCeleExchangeView:LoadItems()
    local list = OperateModel:GetInstance():GetRewardConfig(self.actID)
    self.item_list = self.item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.item_list[i]
        if not item then
            item = GodExchangeItem(self.item_obj, self.item_con, self.actID)
            self.item_list[i] = item
        else
            item:SetVisible(true)
        end
        local info = self:GetTaskInfoById(list[i].id)
        item:SetData(list[i], info)
        if not self.cost_item_id then
            self.cost_item_id = String2Table(list[i].cost)[1][1]
        end
    end
    for i = len + 1, #self.item_list do
        local item = self.item_list[i]
        item:SetVisible(false)
    end
end

function GodCeleExchangeView:InitTime()
    --logError(self.actID)
    local time = OperateModel.GetInstance():GetActEndTimeByActId(self.actID)
    time = time - TimeManager.DaySec
    --local tbl = TimeManager.GetInstance():GetTimeDate(time)
    --dump(tbl, "<color=#6ce19b>InitTime   InitTime  InitTime  InitTime</color>")
    if time then
        local param = {}
        param.isShowSec = true
        param.isShowMin = true
        param.isShowHour = true
        param.isShowDay = true
        param.isChineseType = true
        local function update_cb(time_tab)
            if time_tab.day == 0 and (not self.is_set_red) then
                self.is_set_red = true
                SetColor(self.time_text, 255, 28, 28, 255)
            end
        end
        self.countdowntext = CountDownText(self.time_con, param, update_cb)
        local function call_back()
            SetVisible(self.time_text, false)
            self.countdowntext = nil
            --self.model:Brocast(GodCeleEvent.ExchangeOver)
            SetVisible(self.end_tip, true)
            Notify.ShowText(ConfigLanguage.GodCele.ExchangeAlreadyEnd)
        end
        self.countdowntext:StartSechudle(time, call_back)
    else
        logError("GodCeleExchangeView,没有兑换活动的结束时间")
    end
end

function GodCeleExchangeView:UpdateNum()
    if self.cost_item_id then
        local have_num = BagModel.GetInstance():GetItemNumByItemID(self.cost_item_id)
        self.num.text = have_num
    end
end

function GodCeleExchangeView:GetTaskInfoById(id)
    local info = nil
    if table.isempty(self.data) or table.isempty(self.data.tasks) then
        Notify.ShowText("Tasks of exchange event was found")
        return
    end
    for i = 1, #self.data.tasks do
        local data = self.data.tasks[i]
        if data.id == id then
            info = data
            break
        end
    end
    return info
end