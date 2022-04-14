--- Created by Admin.
--- DateTime: 2019/12/4 11:33

IllInvestPanel = IllInvestPanel or class("IllInvestPanel", BasePanel)
local this = IllInvestPanel

function IllInvestPanel:ctor()
    self.abName = "sevenDayActive"
    self.assetName = "IllInvestPanel"
    self.layer = "UI"
    self.use_background = true
    self.is_show_money = { Constant.GoldType.Gold, Constant.GoldType.BGold, Constant.GoldType.Coin }    --是否显示钱
    self.panel_type = 2

    self.items = {}
    self.firstItem = {}
    self.events = {}
    self.redList = {}
    self.cur_type = 1
    self.money_list = {}
    self.togSelect = {}
    self.model = IllInvestModel.GetInstance()
end

function IllInvestPanel:dctor()
    destroyTab(self.items)
    self.items = nil
    destroyTab(self.firstItem)
    self.firstItem = nil
    destroyTab(self.money_list)
    self.money_list = nil

    self.togSelect = nil
    self.redList = nil

    if self.countdown_item then
        self.countdown_item:destroy()
        self.countdown_item = nil
    end

    GlobalEvent:RemoveTabListener(self.events)
    self.cur_type = 1
end

function IllInvestPanel:Open(index)
    IllInvestPanel.super.Open(self)
    self.cur_type = index or 1
end

function IllInvestPanel:OpenCallBack()
end

function IllInvestPanel:LoadCallBack()
    self.nodes = {
        "close","tog/tog1","tog/tog2","tog/tog3","tog/tog1/select1","tog/tog2/select2","tog/tog3/select3",
        "time","investBtn","investBtn/investText","investitem","investitem2","frist","other","price/price1",
        "price2","time/countdowntext","tog/tog1/red1","tog/tog2/red2","tog/tog3/red3","money_con",
    }
    self:GetChildren(self.nodes)

    self.investTex = GetText(self.investText)
    self.timeTex = GetText(self.countdowntext)
    self.price1Tex = GetText(self.price1)
    self.price2Tex = GetText(self.price2)
    self.btnImg = GetImage(self.investBtn)

    self.togSelect[1] = self.select1
    self.togSelect[2] = self.select2
    self.togSelect[3] = self.select3

    self.redList[1] = self.red1
    self.redList[2] = self.red2
    self.redList[3] = self.red3

    self:AddEvent()
    self:InitPanel()
end

function IllInvestPanel:AddEvent()
    local function call_back()
       self:TogOnClick(1)
    end
    AddClickEvent(self.tog1.gameObject ,call_back)

    local function call_back()
        self:TogOnClick(2)
    end
    AddClickEvent(self.tog2.gameObject ,call_back)

    local function call_back()
        self:TogOnClick(3)
    end
    AddClickEvent(self.tog3.gameObject ,call_back)

    local function call_back()
        if  self.is_buy then
            local count = RoleInfoModel:GetInstance():GetMainRoleData()[Constant.GoldType.Gold] or 0
            if count >= self.numCost then
                local act_id = self.model.act_id_list[self.cur_type]
                IllInvestCtr:GetInstance():RequestBuyInvest(act_id)
            else
                local function call_back2()
                    GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
                end
                Dialog.ShowTwo("Tip", "You don't have enough diamonds, top-up now?", "Confirm", call_back2, nil, "Cancel", nil, nil)
            end
        end
    end
    AddClickEvent(self.investBtn.gameObject ,call_back)

    local function call_back()
        self:Close()
    end
    AddClickEvent(self.close.gameObject, call_back)


    self.events[#self.events + 1] = GlobalEvent:AddListener(IllInvestEvent.IllInvestBuySuccess, handler(self, self.HandleBuySuccess))
    self.events[#self.events + 1] = GlobalEvent:AddListener(IllInvestEvent.IllInvestRewardSuccess, handler(self, self.HandleRewardSuccess))
    self.events[#self.events + 1] = GlobalEvent:AddListener(IllInvestEvent.IllDayInvest, handler(self, self.UpdateDayInfo))

end

function IllInvestPanel:InitPanel()
	self:UpdateView(self.cur_type)
    self:ShowTime()
    self:SetMoney()
end


function IllInvestPanel:UpdateView(index)
    local act_id = self.model.act_id_list[index]
    local is_buy = self.model:GetIsBuyByActId(act_id)
    local config = self.model:GetConfigData(act_id)

    if config then
        for i = 1, #config do
            if i == 1 then
                local tab = String2Table(config[1].rewards)
                for i = 1, #tab do
                    local item = self.firstItem[i]
                    if not item then
                        item = IllInvestItem2(self.investitem.gameObject, self.frist.transform)
                        self.firstItem[i] = item
                        SetVisible(item.transform, true)
                    end
                    item:SetDate(tab[i], is_buy)
                end

            else
                local item = self.items[i]
                if not item then
                    item = IllInvestItem(self.investitem2.gameObject, self.other.transform)
                    self.items[i] = item
                    SetVisible(item, true)
                end

                item:SetDate(config[i], act_id)
            end
        end

        local p = self.model:GetPriceByActId(act_id)
        self.price1Tex.text = p.cost
		local pay = String2Table(p.pay)
        self.numCost = pay[1][2]
        self.price2Tex.text = self.numCost

        if is_buy then
            self.is_buy = false
            ShaderManager:GetInstance():SetImageGray(self.btnImg)
            self.investTex.text = "Invested"
        else
            self.is_buy = true
            ShaderManager:GetInstance():SetImageNormal(self.btnImg)
            self.investTex.text = "Invest"
        end

        self:SetToggle(index)
		self:UpdateRed()
    end
end


function IllInvestPanel:TogOnClick(index)
    if index == self.cur_type then
        return
    end

    self.cur_type = index
    self:UpdateView(index)
end

function IllInvestPanel:SetToggle(index)
    for i = 1, 3 do
        if i == index then
            SetVisible(self.togSelect[i].transform, true)
        else
            SetVisible(self.togSelect[i].transform, false)
        end
    end
end

function IllInvestPanel:ShowTime()
    local act_etime = self.model:GetEndTimeByActId(self.model.act_id_list[self.cur_type])
    if not self.countdown_item then
        local param = {}
        param["duration"] = 0.3
        param["isChineseType"] =  true
        param["isShowDay"] = true
        param["isShowHour"] = true
        self.countdown_item = CountDownText(self.time, param)
        local function end_func()
           self.timeTex.text = "Event has ended"
        end
        self.countdown_item:StartSechudle(act_etime, end_func)
    end
end


function IllInvestPanel:HandleBuySuccess(data)
    if self.model.act_id_list[self.cur_type] == data.act_id then
        self:UpdateView(self.cur_type)
    end
end

function IllInvestPanel:HandleRewardSuccess(data)
    if self.model.act_id_list[self.cur_type] == data.act_id then
        self:UpdateView(self.cur_type)
    end
end


function IllInvestPanel:UpdateRed()
    local list = self.model:GetRedData()
    for i, v in pairs(list) do
        for j = 1, 3 do
            if self.model.act_id_list[j] == i then
                SetVisible(self.redList[j], v)
            end
        end
    end
end

function IllInvestPanel:UpdateDayInfo()
    self:UpdateView(self.cur_type)
end

function IllInvestPanel:SetMoney()
    local list = self.is_show_money
    local offx = 220
    for i = 1, #list do
        local item = MoneyItem(self.money_con, nil, list[i])
        local x = (i - #list) * offx
        local y = 0
        item:SetPosition(x, y)
        self.money_list[i] = item
    end
end

function IllInvestPanel:CloseCallBack()

end