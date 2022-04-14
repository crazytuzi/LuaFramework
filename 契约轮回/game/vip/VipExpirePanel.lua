VipExpirePanel = VipExpirePanel or class("VipExpirePanel", BasePanel)
local VipExpirePanel = VipExpirePanel

function VipExpirePanel:ctor()
    self.abName = "vip"
    self.assetName = "VipExpirePanel"
    self.layer = "UI"

    self.panel_type = 2
    self.use_background = true
    self.change_scene_close = true
    self.mall_id = 2100

    --self.model = 2222222222222end:GetInstance()
end

function VipExpirePanel:dctor()
end

function VipExpirePanel:Open()
    VipExpirePanel.super.Open(self)
end

function VipExpirePanel:LoadCallBack()
    self.nodes = {
        "btn_close", "btn_use", "open_vip", "model", "bg", "cd_count", "title", "Sundries/Text_img", "Sundries/Text_img_2",
        "arrow",
    }
    self:GetChildren(self.nodes)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.title.transform, nil, true, nil, false, 2)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.Text_img.transform, nil, true, nil, false, 4)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.Text_img_2.transform, nil, true, nil, false, 6)

    self:AddEvent()
    SetLocalPosition(self.model, -385, 15.3, 0)
end

function VipExpirePanel:AddEvent()
    local function call_back(target, x, y)
        self:CheckQuitMention()
    end
    AddButtonEvent(self.btn_close.gameObject, call_back)

    local function call_back(target, x, y)
        local data = {}
        local mall_cf = Config.db_mall[self.mall_id]
        if not mall_cf then
            logError("VipExpirePanel: 商城配置没有2100的商品配置")
            return
        end
        local price = String2Table(mall_cf.price)
        data.curPrice = price[2]
        data.typeId = 4
        data.mallId = self.mall_id
        VipModel.GetInstance():Brocast(VipEvent.ActivateVipCard, data)
    end
    AddButtonEvent(self.btn_use.gameObject, call_back)

    local function call_back(target, x, y)
        lua_panelMgr:GetPanelOrCreate(VipDetailPanel):Open(4)
    end
    AddClickEvent(self.open_vip.gameObject, call_back)
end

function VipExpirePanel:OpenCallBack()
    self:UpdateView()
    SetLocalPosition(self.arrow, 601, -187.5, 0)
    self:PlayAni()
end

function VipExpirePanel:PlayAni()
    local action = cc.MoveTo(0.6, 574, -187.5, 0)
    action = cc.Sequence(action, cc.MoveTo(0.6, 601, -187.5, 0))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, self.arrow.transform)
end

function VipExpirePanel:UpdateView()
    if self.eft ~= nil then
        self.eft:destroy()
        self.eft = nil
    end
    self.eft = UIEffect(self.btn_use, 10121, false, self.layer)
    self.eft:SetConfig({ scale = 1.2 })

    if self.role_model then
        self.role_model:destroy()
    end
    self.role_model = UIPetCamera(self.model, nil, 20005, 8, nil, nil)
    local day_sec = TimeManager.GetInstance().DaySec
    local end_time = VipModel.GetInstance().taste_etime + day_sec
    if (not self.CDT) and end_time > os.time() then
        local day_sec = TimeManager.GetInstance().DaySec
        local out_date_stamp = RoleInfoModel.GetInstance():GetRoleValue("vipend")
        local end_time = out_date_stamp + day_sec
        local param = {}
        param.isShowMin = true
        param.isShowHour = true
        param.nodes = { "cd" }
        param.formatText = "Event countdown：<color=#3dff58>%s</color>"
        self.CDT = CountDownText(self.cd_count, param)
        local function call_back()
            SetVisible(self.CDT, false)
        end
        self.CDT:StartSechudle(end_time, call_back)
    else
        SetVisible(self.cd_count, false)
    end
end

function VipExpirePanel:CheckQuitMention()
    if VipModel.GetInstance().is_check then
        self:CloseAction()
        return
    end
    local lv = RoleInfoModel.GetInstance():GetMainRoleVipLevel()
    local cd_data = {}
    local day_sec = TimeManager.GetInstance().DaySec
    local end_time = VipModel.GetInstance().taste_etime + day_sec
    local is_not_vfour = lv < 4
    if not is_not_vfour then
        --是V4
        self:Close()
        return
    end
    if end_time > os.time() then
        cd_data.isShowMin = true
        cd_data.isShowHour = true
        cd_data.formatText = "<color=#675344>Event time left： </color><color=#eb0000>%s</color>"
    end
    local day_sec = TimeManager.GetInstance().DaySec
    local out_date_stamp = RoleInfoModel.GetInstance():GetRoleValue("vipend")
    cd_data.end_time = end_time
    local message = ConfigLanguage.Vip.VFourActivateActTip
    local function ok_fun(is_check)
        VipModel.GetInstance().is_check = is_check
        self:CloseAction()
    end
    Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, message, nil, ok_fun, nil, nil, nil, nil, ConfigLanguage.SearchT.NoAlert, false, false, nil, nil, nil, cd_data)
end

function VipExpirePanel:CloseAction()
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

function VipExpirePanel:CloseCallBack()
    if self.eft ~= nil then
        self.eft:destroy()
        self.eft = nil
    end
    if self.role_model then
        self.role_model:destroy()
    end
    if self.CDT then
        self.CDT:destroy()
    end
end