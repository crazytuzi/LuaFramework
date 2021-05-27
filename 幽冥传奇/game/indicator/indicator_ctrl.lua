require("scripts/game/indicator/indicator_bar_view")
require("scripts/game/indicator/indicator_view")
require("scripts/game/indicator/indicator_data")

IndicatorCtrl = IndicatorCtrl or BaseClass(BaseController)

function IndicatorCtrl:__init()
    if IndicatorCtrl.Instance then
        ErrorLog("[IndicatorCtrl]:Attempt to create singleton twice!")
    end
    IndicatorCtrl.Instance = self
    self.indicator_bar = IndicatorBar.New()
    self.data = IndicatorData.New()
    self.view = IndicatorView.New(ViewName.Indicator)

    self.role_event = BindTool.Bind(self.OnRoleDataChanged, self)
    RoleData.Instance:NotifyAttrChange(self.role_event)
    GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
end

function IndicatorCtrl:__delete( )
    IndicatorCtrl.Instance = nil

    self.indicator_bar:DeleteMe()
    self.indicator_bar = nil

    self.data:DeleteMe()
    self.data = nil

    self.view:DeleteMe()
    self.view = nil

    if self.role_event then
        RoleData.Instance:UnNotifyAttrChange(self.role_event)
        self.role_event = nil
    end

end

function IndicatorCtrl:OnRecvMainRoleInfo()
    self:CheckShowIndicatorBar(RoleData.Instance:GetAttr(OBJ_ATTR.PROP_ACTOR_ONCE_MAX_LEVEL))
end

function IndicatorCtrl:OnRoleDataChanged(key, value)
    if key == OBJ_ATTR.PROP_ACTOR_ONCE_MAX_LEVEL then
        self:CheckShowIndicatorBar(value)
    end
end

function IndicatorCtrl:CheckShowIndicatorBar(level)
    local canshow, diff_level = IndicatorData.CanShowIndicatorBar(level)
    if canshow  then
        if not self.indicator_bar:IsOpen() then
            self.indicator_bar:Open()
        end
        local cfg = IndicatorData.GetOpenCfgByLevel(level)
        if cfg then
            self.indicator_bar:Flush(0, "all", {id = cfg.id, level = diff_level, icon = cfg.icon})
        end
    else
        self.indicator_bar:Close()
    end
end