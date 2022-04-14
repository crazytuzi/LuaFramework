-- @Author: lwj
-- @Date:   2019-06-03 16:54:26
-- @Last Modified time: 2019-10-23 19:34:40

InvestPanel = InvestPanel or class("InvestPanel", BaseItem)
local InvestPanel = InvestPanel

function InvestPanel:ctor(parent_node, layer)
    self.abName = "vip"
    self.assetName = "InvestPanel"
    self.layer = layer

    self.max_tog_idx = #Config.db_vip_invest

    self.model = VipModel.GetInstance()
    BaseItem.Load(self)
end

function InvestPanel:dctor()
    if self.eft then
        self.eft:destroy()
        self.eft = nil
    end
    self:DestroyTogs()
    for i, v in pairs(self.model_event) do
        self.model:RemoveListener(v)
    end
    self.model_event = {}
    if not table.isempty(self.rewa_item_list) then
        for i, v in pairs(self.rewa_item_list) do
            if v then
                v:destroy()
            end
        end
        self.rewa_item_list = {}
    end
end

function InvestPanel:LoadCallBack()
    self.nodes = {
        "Right/Top/Toggle_Group",
        "Right/Top/Toggle_Group/InvestTogItem",
        "Right/Bottom/RightScroll/Viewport/task_icon",
        "Right/Bottom/RightScroll/Viewport/task_icon/InvsetItem",
        "Right/Top/need", "Right/Top/predi", "Right/Top/current",
        "Right/Top/btn_buy",
        "Right/Top/btn_buy/btn_text", "Right/Top/btn_buy/btn_deco/deco_txt",
        "Right/Top/btn_buy/btn_deco", "Left/nomal_show/power", "Left/nomal_show/magic_point", "Left/nomal_show/title_img",
        "Left/nomal_show", "Left/top_show",
    }
    self:GetChildren(self.nodes)
    self.tog_obj = self.InvestTogItem.gameObject
    self.invest_item_obj = self.InvsetItem.gameObject
    self.predi = GetText(self.predi)
    self.current = GetText(self.current)
    self.need = GetText(self.need)
    self.btn_img = GetImage(self.btn_buy)
    self.btn_text = GetText(self.btn_text)
    self.btn_deco_text = GetText(self.deco_txt)
    self.btn_deco_img = GetImage(self.btn_deco)

    self:AddEvent()
    self:InitLeftShow()
    self:IsHideRDOnce()
    self:InitPanel()
end

function InvestPanel:InitLeftShow()
    local is_top = self.model:IsTopInvesting()
    if not is_top then
        --巅峰投资
        self:LoadEft()
        self:PlayAni()
    end
    SetVisible(self.nomal_show, not is_top)
    SetVisible(self.top_show, is_top)
end

function InvestPanel:LoadEft()
    if self.eft ~= nil then
        self.eft:destroy()
    end
    self.eft = UIEffect(self.magic_point, 10311, true, self.layer)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.title_img.transform, nil, true, nil, false, 4)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.power.transform, nil, true, nil, false, 6)
end

function InvestPanel:IsHideRDOnce()
    if not self.model:IsInvested() and not self.model.is_had_invesrd_showed then
        self.model.is_had_invesrd_showed = true
        self.model:RemoveSideRD(5)
        self.model:Brocast(VipEvent.UpdateVipSideRD)
        if self.model:IsCanHideMainIconRD() then
            GlobalEvent:Brocast(VipEvent.ShowMainVipRD, false)
        end
    end
end

function InvestPanel:AddEvent()
    local function callback()
        if self.model:GetInvestGrade() == self.model.cur_sel_grade then
            Notify.ShowText(ConfigLanguage.Vip.AlreadyInvestTip)
            return
        end
        local money = RoleInfoModel.GetInstance():GetRoleValue(ShopModel.GetInstance():GetTypeNameById(self.need_tbl[2]))
        if money >= self.need_tbl[1] then
            self.model:Brocast(VipEvent.Invest)
        else
            local typeName = self.need_tbl[2]

            local name = Config.db_item[typeName].name
            local tips = string.format(ConfigLanguage.Shop.BalanceNotEnough, name)
            local function callback()
                GlobalEvent:Brocast(VipEvent.CloseVipPanel)
                GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
            end
            Dialog.ShowTwo("Tip", tips, "Confirm", callback, nil, "Cancel", nil, nil, nil, false, false)
        end
    end
    AddButtonEvent(self.btn_buy.gameObject, callback)

    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(VipEvent.InvestTogClick, handler(self, self.HandleTogClick))
    self.model_event[#self.model_event + 1] = self.model:AddListener(VipEvent.SuccessFetchInveRewa, handler(self, self.HandleFetchRewa))
    self.model_event[#self.model_event + 1] = self.model:AddListener(VipEvent.UpdateInvesetPanel, handler(self, self.HandleUpdatePanel))
end

function InvestPanel:InitPanel()
    self:InitTogShow()
    self:LoadTogItem()
end

function InvestPanel:PlayAni()
    local action = cc.MoveTo(1.5, -366, 0, 0)
    action = cc.Sequence(action, cc.MoveTo(1.5, -366, -45, 0))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, self.title_img.transform)
end

function InvestPanel:InitTogShow()
    if self.model:IsInvested() then
        self.model.default_tog = self.model:GetInvestGrade()
    else
        self.model.default_tog = self.model:GetCurInvestMaxGrade()
    end
end

function InvestPanel:LoadTogItem()
    local list = self.model:GetTogList()
    self:DestroyTogs()
    for i = 1, #list do
        local item = InvestTogItem(self.tog_obj, self.Toggle_Group)
        item:SetData(list[i])
        self.tog_item_list[#self.tog_item_list + 1] = item
    end
end
function InvestPanel:DestroyTogs()
    if not self.tog_item_list then
        self.tog_item_list = {}
        return
    end
    for i, v in pairs(self.tog_item_list) do
        if v then
            v:destroy()
        end
    end
    self.tog_item_list = {}
end

function InvestPanel:HandleTogClick(grade)
    self:LoadRewardItem(grade)
    self:UpdateTop(grade)
end

function InvestPanel:HandleUpdatePanel()
    self:InitTogShow()
    self:LoadTogItem()
end

function InvestPanel:HandleFetchRewa()
    self:LoadRewardItem(self.model.cur_sel_grade)
end

function InvestPanel:LoadRewardItem(grade)

    local list = self.model:GetInverstCFByGrade(grade)
    self.rewa_item_list = self.rewa_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.rewa_item_list[i]
        if not item then
            item = InvestItem(self.invest_item_obj, self.task_icon)
            self.rewa_item_list[i] = item
        else
            item:SetVisible(true)
        end
        list[i].grade = grade
        local ser_data = self.model:GetInvestRewaInfoById(list[i].id)
        item:SetData(list[i], ser_data)
    end
    for i = len + 1, #self.rewa_item_list do
        local item = self.rewa_item_list[i]
        item:SetVisible(false)
    end
end

function InvestPanel:UpdateTop(grade)
    local cf_grade = self.model:IsTopInvesting() and grade + 3 or grade
    local cf = Config.db_vip_invest[cf_grade]
    local price_tbl = String2Table(cf.price)[1]
    local pri_num = self.model:CountPreiGetNum(grade)
    local pri_name = Config.db_item[price_tbl[1]].name
    self.predi.text = pri_num .. " " .. Config.db_item[cf.reward_type].name
    local cur_grade = self.model:GetInvestGrade()
    local cur_cf_grade = self.model:GetRealGrade()
    local cur_price
    if cur_grade == 0 then
        cur_price = 0
    else
        cur_price = String2Table(Config.db_vip_invest[cur_cf_grade].price)[1][2]
    end
    self.current.text = price_tbl[2] .. " " .. pri_name

    self.need_tbl = {}
    self.need_tbl[1] = price_tbl[2] - cur_price
    self.need_tbl[2] = price_tbl[1]
    local text = self.need_tbl[1] .." " .. pri_name
    if self.need_tbl[1] <= 0 then
        text = "Invested"
    end
    self.need.text = text

    if cur_grade == 0 then
        self.model.inve_btn_state = 2
        ShaderManager:GetInstance():SetImageNormal(self.btn_img)
        ShaderManager:GetInstance():SetImageNormal(self.btn_deco_img)
        self.btn_text.text = ConfigLanguage.Vip.InvestImediatly
        self.btn_deco_text.text = self.model:IsTopInvesting() and ConfigLanguage.Vip.FifteenTimesReward or ConfigLanguage.Vip.TenTimesReward
    elseif cur_grade >= grade then
        --当前投资档位
        self.model.inve_btn_state = 1
        ShaderManager:GetInstance():SetImageGray(self.btn_img)
        ShaderManager:GetInstance():SetImageGray(self.btn_deco_img)
        self.btn_text.text = ConfigLanguage.Vip.AlreadyInvest
        self.btn_deco_text.text = self.model:IsTopInvesting() and ConfigLanguage.Vip.FifteenTimesReward or ConfigLanguage.Vip.TenTimesReward
    elseif cur_grade < grade then
        self.model.inve_btn_state = 3
        ShaderManager:GetInstance():SetImageNormal(self.btn_img)
        ShaderManager:GetInstance():SetImageNormal(self.btn_deco_img)
        self.btn_text.text = ConfigLanguage.Vip.AdditionalInvest
        self.btn_deco_text.text = ConfigLanguage.Vip.EnableToReFetch
    end
end
