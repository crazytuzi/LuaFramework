-- @Author: lwj
-- @Date:   2019-04-17 17:10:01
-- @Last Modified time: 2019-04-17 17:10:03

FirstPayGuidPanel = FirstPayGuidPanel or class("FirstPayGuidPanel", BasePanel)
local FirstPayGuidPanel = FirstPayGuidPanel

function FirstPayGuidPanel:ctor()
    self.abName = "firstPay"
    self.assetName = "FirstPayGuidPanel"
    self.layer = "Bottom"

    self.time = 20
    self.resid = 10003
    self.show_time = 0.2
    self.change_scene_close = true
    self.model = FirstPayModel.GetInstance()
end

function FirstPayGuidPanel:dctor()

end

function FirstPayGuidPanel:Open()
    FirstPayGuidPanel.super.Open(self)
end

function FirstPayGuidPanel:LoadCallBack()
    self.nodes = {
        "con", "con/Bg", "con/btn_go", "con/btn_close",
        "con/model_con", "con/Title", "con/Powe_Title", "con/Text",
    }
    self:GetChildren(self.nodes)
    self.con_rect = GetRectTransform(self.con)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.Title.transform, nil, true, nil, false, 3)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.Powe_Title.transform, nil, true, nil, false, 4)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.btn_close.transform, nil, true, nil, false, 5)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.Text.transform, nil, true, nil, false, 6)
    --LayerManager.GetInstance():AddOrderIndexByCls(self, self.model.transform, nil, false, nil, false, 1)

    self:AddEvent()
    self:InitPanel()
end

function FirstPayGuidPanel:AddEvent()
    AddButtonEvent(self.btn_close.gameObject, handler(self, self.Close))
    local function callback()
        lua_panelMgr:GetPanelOrCreate(FirstPayPanel):Open()
        self:Close()
    end
    AddButtonEvent(self.btn_go.gameObject, callback)
    AddClickEvent(self.Bg.gameObject, callback)

    self.close_self_event_id = self.model:AddListener(FirstPayEvent.CloseGuidePanel, handler(self, self.Close))
end

function FirstPayGuidPanel:OpenCallBack()
    local function step()
        SetVisible(self.model_con, true)
    end
    self.delay_sche = GlobalSchedule:StartOnce(step, self.show_time)
    local mainpanel = lua_panelMgr:GetPanelOrCreate(MainUIView)
    local x, y, z = mainpanel.main_top_right:GetItemGlobalPos("firstPay")
    SetGlobalPosition(self.con_rect, x, y, z)
    self:StopClock()
    self.schedule = GlobalSchedule.StartFun(handler(self, self.ClockFun), 1, -1)
end

function FirstPayGuidPanel:LoadModel()
    if not self.weapon_model then
        --self.weapon_model = UIWingModel(self. model_con, self.resid, handler(self, self.LoadModelCallBack), "model_weapon_", "model_weapon_r_", { "show", "idle2" });
        local config = {}
        config.offset = { x = 3995, y = 146, z = 150 }
        config.scale = { x = 200, y = 200, z = 200 }
        config.rotate = { x = 170, y = -15.76501, z = 180 };
        config.carmera_size = 3.5
        self.weapon_model = UIMountCamera(self.model_con.transform, nil, self.resid, enum.ITEM_STYPE.ITEM_STYPE_WEAPON_MORPH);
        self.weapon_model:SetConfig(config)
    end
end

function FirstPayGuidPanel:ClockFun()
    if self.time > 0 then
        self.time = self.time - 1
    else
        self:Close()
    end
end

function FirstPayGuidPanel:StopClock()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
        self.schedule = nil
    end
end

function FirstPayGuidPanel:InitPanel()
    SetColor(self.background_img, 0, 0, 0, 0)
    self:LoadModel()
end

function FirstPayGuidPanel:CloseCallBack()
    if self.delay_sche then
        GlobalSchedule:Stop(self.delay_sche)
        self.delay_sche = nil
    end
    self:StopClock()
    if self.close_self_event_id then
        self.model:RemoveListener(self.close_self_event_id)
        self.close_self_event_id = nil
    end
    if self.weapon_model then
        self.weapon_model:destroy()
        self.weapon_model = nil
    end
end

