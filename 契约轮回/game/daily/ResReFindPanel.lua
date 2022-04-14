-- @Author: lwj
-- @Date:   2019-07-17 16:36:06
-- @Last Modified time: 2019-07-17 16:36:09

ResReFindPanel = ResReFindPanel or class("ResReFindPanel", BaseItem)
local ResReFindPanel = ResReFindPanel

function ResReFindPanel:ctor(parent_node, layer)
    self.abName = "daily"
    self.assetName = "ResReFindPanel"
    self.layer = layer

    self.model = DailyModel.GetInstance()
    BaseItem.Load(self)

    self.item_list = {}
    self.events = {}
end

function ResReFindPanel:dctor()
    for i=1, #self.item_list do
        self.item_list[i]:destroy()
    end
    self.model:RemoveTabListener(self.events)
end

function ResReFindPanel:LoadCallBack()
    self.nodes = {
        "btn_one_key_find","Sum_Bg/sum","coin_tog","diam_tog","extra_tog","btn_ques",
        "empty","item_scroll/Viewport/item_con/ResRefindItem","empty/tip",
        "item_scroll/Viewport/item_con",
    }
    self:GetChildren(self.nodes)

    self.tip = GetText(self.tip)
    self.sum = GetText(self.sum)
    self.coin_tog_com = GetToggle(self.coin_tog)
    self.diam_tog_com = GetToggle(self.diam_tog)
    self.extra_tog_com = GetToggle(self.extra_tog)
    self:AddEvent()
    self:InitPanel()
end

function ResReFindPanel:AddEvent()
    local function call_back(target, value)
        if value then
            self.extra_tog_com.isOn = false
            self.model.findback_type = 1
            self.model.findback_total_money = 0
            self.model:Brocast(DailyEvent.UpdateMoneyType)
            self:UpdateTotalMoney()
        end
    end
    AddValueChange(self.coin_tog.gameObject, call_back)

    local function call_back(target, value)
        SetVisible(self.extra_tog, value)
        if value then
            self.model.findback_type = 2
            self.model.findback_total_money = 0
            self.model:Brocast(DailyEvent.UpdateMoneyType)
            self:UpdateTotalMoney()
        end
    end
    AddValueChange(self.diam_tog.gameObject, call_back)

    local function call_back(target, value)
        self.model.findback_total_money = 0
        self.model.findback_extra = value
        self.model:Brocast(DailyEvent.UpdateMoneyType)
        self:UpdateTotalMoney()
    end
    AddValueChange(self.extra_tog_com.gameObject, call_back)

    local function call_back(target,x,y)
        if self.model.findback_total_money == 0 then
            return Notify.ShowText("No reward is available for retrieval for now")
        end
        local gold_type = Constant.GoldType.BGold
        local message = string.format("Retrieve by spend %s bound diamond?", self.model.findback_total_money)
        if self.model.findback_type == 1 then
            gold_type = Constant.GoldType.Coin
            message = string.format("Retrieve by spend %s gold?", self.model.findback_total_money)
        end
        local function ok_func( ... )
            local bo = RoleInfoModel:GetInstance():CheckGold(self.model.findback_total_money, gold_type)
            if not bo then
                return
            end
            DailyController:GetInstance():RequestRefindbackAll(self.model.findback_type, self.extra_tog_com.isOn)
        end
        Dialog.ShowTwo("Tip",message,nil,ok_func)
    end
    AddClickEvent(self.btn_one_key_find.gameObject,call_back)

    local function call_back(target,x,y)
        ShowHelpTip(HelpConfig.Daily.Findback, false, 650)
    end
    AddClickEvent(self.btn_ques.gameObject,call_back)

    local function call_back()
        self.model.findback_total_money = 0
        self:InitPanel()
    end
    self.events[#self.events+1]=self.model:AddListener(DailyEvent.UpdateFindBackPanel, call_back)
end

function ResReFindPanel:InitPanel()
    if table.isempty(self.model.findback_info) then
        SetVisible(self.empty, true)
        SetVisible(self.item_con, false)
        self.tip.text = ConfigLanguage.Daily.RefindNoToday
    else
        SetVisible(self.empty, false)
        SetVisible(self.item_con, true)
        if #self.item_list > 0 then
            for i=1, #self.item_list do
                self.item_list[i]:UpdateInfo()
            end
        else
            for _, pfindback in pairs(self.model.findback_info) do
                local item = ResReFindItem(self.ResRefindItem.gameObject, self.item_con)
                item:SetData(pfindback)
                self.item_list[#self.item_list+1] = item
            end
        end
    end
    self:UpdateTotalMoney()
    if self.model.findback_type == 1 then
        self.coin_tog_com.isOn = true
    else
        self.diam_tog_com.isOn = true 
    end
end

function ResReFindPanel:UpdateTotalMoney()
    if self.schedule_id then
        GlobalSchedule:Stop(self.schedule_id)
        self.schedule_id = nil
    end
    local function call_back()
        self.sum.text = self.model.findback_total_money
    end
    self.schedule_id = GlobalSchedule:StartOnce(call_back, 0.1)
end

