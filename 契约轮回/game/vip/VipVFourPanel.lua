-- @Author: lwj
-- @Date:   2019-07-11 17:28:47 
-- @Last Modified time: 2019-11-06 21:01:04

VipVFourPanel = VipVFourPanel or class("VipVFourPanel", BasePanel)
local VipVFourPanel = VipVFourPanel

function VipVFourPanel:ctor()
    self.abName = "vip"
    self.assetName = "VipVFourPanel"
    self.layer = "UI"

    self.panel_type = 2
    self.use_background = true
    self.pet_id = 40500501
    self.pet_model_id = Config.db_pet[self.pet_id].model
    self.mall_id = 2100
    self.model = VipModel.GetInstance()
    self.btn_mode = 1          --1:未激活    2:返利未到     3：返利时间到   4：已领取返利
    self.is_skip_load_model = false
end

function VipVFourPanel:dctor()

end

function VipVFourPanel:Open()
    VipVFourPanel.super.Open(self)
end

function VipVFourPanel:OpenCallBack()
end

function VipVFourPanel:LoadCallBack()
    self.nodes = {
        "model_con", "detail", "btn_buy", "btn_close", "cd_count", "Sudries/Title", "Sundries_2/Text_Img", "Sundries_2/Text_Img_2",
        "btn_buy/fetch_con", "btn_buy/buy_con", "btn_buy/red_con",
    }
    self:GetChildren(self.nodes)
    self.buy_img = GetImage(self.btn_buy)
    self.fetch_t = GetText(self.fetch_con)
    self.fetch_outline = GetOutLine(self.fetch_con)

    SetLocalPosition(self.model_con, -385, 15.3, 0)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.Title.transform, nil, true, nil, false, 2)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.Text_Img.transform, nil, true, nil, false, 4)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.Text_Img_2.transform, nil, true, nil, false, 6)

    self:AddEvent()
    self:InitPanel()
end

function VipVFourPanel:AddEvent()
    local function callback()
        self:CheckQuitMention()
    end
    AddButtonEvent(self.btn_close.gameObject, callback)

    AddClickEvent(self.detail.gameObject, handler(self, self.HandleLinkClick))

    local function callback()
        if self.btn_mode == 1 then
            local data = {}
            local mall_cf = Config.db_mall[self.mall_id]
            if not mall_cf then
                logError("VipVFourPanel: 商城配置没有2100的商品配置")
                return
            end
            local price = String2Table(mall_cf.price)
            data.curPrice = price[2]
            data.typeId = 4
            data.mallId = self.mall_id
            self.model:Brocast(VipEvent.ActivateVipCard, data)
        elseif self.btn_mode == 2 then
            Notify.ShowText("Not rebate time yet")
        elseif self.btn_mode == 3 then
            self.is_skip_load_model = true
            VipController.GetInstance():RequestFetchRebate()
        else
            Notify.ShowText("Claimed")
        end
    end
    AddButtonEvent(self.btn_buy.gameObject, callback)

    self.success_activate_event_id = self.model:AddListener(VipEvent.SucessActivate, handler(self, self.Close))
    self.success_fetch_event_id = GlobalEvent:AddListener(VipEvent.SuccessFetchRebate, handler(self, self.InitPanel))
end

function VipVFourPanel:DestroyEFT()
    if self.eft ~= nil then
        self.eft:destroy()
        self.eft = nil
    end
end

function VipVFourPanel:InitPanel()
    self:DestroyEFT()
    self.eft = UIEffect(self.btn_buy, 10121, false, self.layer)
    self.eft:SetConfig({ scale = 1.2 })

    if not self.is_skip_load_model then
        self:LoadModel()
    end
    self.is_skip_load_model = false
    local lv = RoleInfoModel.GetInstance():GetMainRoleVipLevel(true)
    local day_sec = TimeManager.GetInstance().DaySec
    local end_time = self.model.taste_etime + day_sec
    local rebate_time = self.model:GetRebateEndTime()
    local is_show_rebate = false
    --已激活V4，返利时间未到
    if lv >= 4 and rebate_time > os.time() then
        end_time = rebate_time + 1
        is_show_rebate = true
    end
    SetVisible(self.cd_count, end_time > os.time())

    local is_show_rd = false
    
    if self.model:IsFetchedRebate() then
        --V4
        --已领取
        self:DestroyEFT()
        self.btn_mode = 4
        ShaderManager:GetInstance():SetImageGray(self.buy_img)
        SetVisible(self.buy_con, false)
        SetVisible(self.fetch_con, true)
        SetOutLineColor(self.fetch_outline, 94, 94, 94)
        self.fetch_t.text = "Claimed"
    elseif lv < 4 or rebate_time == 0 then
        --不是V4
        self.btn_mode = 1
        ShaderManager:GetInstance():SetImageNormal(self.buy_img)
        SetVisible(self.buy_con, true)
        SetVisible(self.fetch_con, false)
    elseif lv < 4 or rebate_time == 0 then
        --不是V4
        self.btn_mode = 1
        ShaderManager:GetInstance():SetImageNormal(self.buy_img)
        SetVisible(self.buy_con, true)
        SetVisible(self.fetch_con, false)
    else
        --未领取
        --返利时间未到
        if end_time ~= 0 and end_time > os.time() then
            self:DestroyEFT()
            self.btn_mode = 2
            ShaderManager:GetInstance():SetImageGray(self.buy_img)
            SetVisible(self.buy_con, false)
            SetVisible(self.fetch_con, true)
            self.fetch_t.text = "Claim"
            SetOutLineColor(self.fetch_outline, 94, 94, 94)
        else
            --返利时间到
            self.btn_mode = 3
            ShaderManager:GetInstance():SetImageNormal(self.buy_img)
            SetVisible(self.buy_con, false)
            SetVisible(self.fetch_con, true)
            self.fetch_t.text = "Claim"
            SetOutLineColor(self.fetch_outline, 193, 94, 45)
            is_show_rd = true
        end
    end
    self:SetRedDot(is_show_rd)
    if self.btn_mode == 3 or self.btn_mode == 5 then
        return
    end
    local param = {}
    param.isShowMin = true
    param.isShowHour = true
    if is_show_rebate then
        param.isShowDay = true
    end
    param.nodes = { "cd" }
    param.formatText = is_show_rebate and "Claim countdown：<color=#3dff58>%s</color>" or "Event countdown：<color=#3dff58>%s</color>"
    local function call_back()
        self.CDT:StopSchedule()
        SetVisible(self.CDT, false)
        if is_show_rebate then
            self:InitPanel()
            local is_can_fetch = self.model:IsCanFetchRebate()
            logError("VIpCOntroller  is_canfetch  ", is_can_fetch)
            GlobalEvent:Brocast(VipEvent.ChangeVFourRD, is_can_fetch)
        end
    end
    if not self.CDT then
        self.CDT = CountDownText(self.cd_count, param)
    else
        self.CDT:StopSchedule()
    end
    self.CDT:StartSechudle(end_time, call_back)
end

function VipVFourPanel:LoadModel()
    if self.pet_model then
        self.pet_model:destroy()
        self.pet_model = nil
    end
    self.pet_model = UIPetCamera(self.model_con, nil, self.pet_model_id, 8, nil, nil)
end

function VipVFourPanel:HandleLinkClick()
    lua_panelMgr:GetPanelOrCreate(VipDetailPanel):Open(4)
end

function VipVFourPanel:CheckQuitMention()
    if self.model:IsFetchedRebate() then
        self:Close()
        return
    end
    if VipModel.GetInstance().is_check then
        self:CloseAction()
        return
    end
    local lv = RoleInfoModel.GetInstance():GetMainRoleVipLevel()
    local cd_data = {}
    if lv < 4 then
        cd_data.isShowMin = true
        cd_data.isShowHour = true
        cd_data.formatText = "<color=#675344>Event time left： </color><color=#eb0000>%s</color>"
    else
        self:Close()
        return
    end
    local day_sec = TimeManager.GetInstance().DaySec
    local end_time = self.model.taste_etime+ day_sec
    cd_data.end_time = end_time
    --cd_data.end_time = os.time() + 10
    local message = ConfigLanguage.Vip.VFourActivateActTip
    local function ok_fun(is_check)
        VipModel.GetInstance().is_check = is_check
        self:CloseAction()
    end
    Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, message, nil, ok_fun, nil, nil, nil, nil, ConfigLanguage.SearchT.NoAlert, false, false, nil, nil, nil, cd_data)
end

function VipVFourPanel:CloseAction()
    local bottom = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.Bottom)
    SetVisible(bottom, true)
    SetVisible(self.background, false)
    self:StopAction()
    local action
    local scal_action = cc.ScaleTo(0.4, 0)
    local move_action = cc.MoveTo(0.4, -279.6, 320, 0)
    action = cc.Spawn(scal_action, move_action)
    action = cc.Sequence(action, cc.CallFunc(handler(self, self.Close)))
    cc.ActionManager:GetInstance():addAction(action, self.transform)
end

function VipVFourPanel:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end

function VipVFourPanel:CloseCallBack()
    if self.eft ~= nil then
        self.eft:destroy()
        self.eft = nil
    end
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    if self.success_fetch_event_id then
        GlobalEvent:RemoveListener(self.success_fetch_event_id)
        self.success_fetch_event_id = nil
    end
    if self.success_activate_event_id then
        self.model:RemoveListener(self.success_activate_event_id)
        self.success_activate_event_id = nil
    end
    if self.pet_model then
        self.pet_model:destroy()
        self.pet_model = nil
    end
    if self.CDT then
        self.CDT:StopSchedule()
        self.CDT:destroy()
        self.CDT = nil
    end
end