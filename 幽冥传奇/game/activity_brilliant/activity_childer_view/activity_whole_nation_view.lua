WholeNationView = WholeNationView or BaseClass(ActBaseView)

function WholeNationView:__init(view, parent, act_id)
    self:LoadView(parent)
end

function WholeNationView:__delete()
   if self.whole_display then
        self.whole_display:DeleteMe()
        self.whole_display = nil 
    end
end

function WholeNationView:InitView()
    XUI.AddClickEventListener(self.node_t_list.btn_go_kill.node,BindTool.Bind(self.OnClickGoKill, self), false)

    local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(self.act_id)
    self:UpdateSpareTime(cfg.end_time)

    local modelid = BossData.GetMosterCfg(cfg.config[1].boss_id).modelid
    local ph = self.ph_list.ph_dia_boss
    if nil == self.whole_display then
        self.whole_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.node_t_list.layout_whole_nation.node, GameMath.MDirDown)
        self.whole_display:SetAnimPosition(ph.x, ph.y)
        self.whole_display:SetFrameInterval(FrameTime.RoleStand)
        self.whole_display:SetZOrder(100)
        self.whole_display:Show(modelid)
        self.whole_display:SetScale(1)
    end
end

function WholeNationView:CloseCallBack()
   
end

function WholeNationView:RefreshView(param_list)
   
end

function WholeNationView:OnClickGoKill()
    ViewManager.Instance:OpenViewByDef(ViewDef.NewlyBossView.Wild)
end

function WholeNationView:UpdateSpareTime(end_time)
    local now_time = TimeCtrl.Instance:GetServerTime()
    
    local str = Language.Chat.Wait .. TimeUtil.FormatSecond2Str(end_time - now_time)
    self.node_t_list["lbl_activity_90_time"].node:setString(str)
end