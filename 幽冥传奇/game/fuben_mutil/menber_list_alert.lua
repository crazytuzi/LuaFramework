MenberListAlert = MenberListAlert or BaseClass(XuiBaseView)

MenberListAlert.OpenType = {
    LOOK_MENBER = 1,        -- 查看队员
    ENTER_FUBEN = 2,        -- 进入副本
}

function MenberListAlert:__init()
    self:SetModal(true)

    self.config_tab = {
		{"fuben_mutil_ui_cfg", 2, {0}},
	}

    self.open_type = MenberListAlert.OpenType.LOOK_MENBER
end

function MenberListAlert:ReleaseCallBack()
    if self.menber_list_view then
        self.menber_list_view:DeleteMe()
        self.menber_list_view = nil
    end
end

function MenberListAlert:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()

    if self.open_type == MenberListAlert.OpenType.ENTER_FUBEN then
        self.cutdown_timer = GlobalTimerQuest:AddTimesTimer(BindTool.Bind(self.OnTimerCallback, self), 1, 30)
        self.left_secs = 30
    end
end

function MenberListAlert:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
    self:CancelTimer()
    self.open_type = nil
    self.fuben_type = nil
    self.fuben_id = nil
    self.fuben_layer = nil
    self.team_id = nil
end

function MenberListAlert:ShowIndexCallBack(index)
	self:OnFlushData()
end

function MenberListAlert:LoadCallBack(index, loaded_times)
    if loaded_times <= 1 then
        self:CreateMenberListView()
        XUI.AddClickEventListener(self.node_t_list.btn_enter.node, BindTool.Bind(self.OnClickEnter, self))
    end

    EventProxy.New(FubenTeamData.Instance, self):AddEventListener(FubenTeamData.FLUSH_TEAM_DATA, BindTool.Bind(self.OnFlushData, self))
	EventProxy.New(FubenTeamData.Instance, self):AddEventListener(FubenTeamData.FLUSH_ROLE_MODEL, BindTool.Bind(self.OnFlushData, self))
	EventProxy.New(FubenTeamData.Instance, self):AddEventListener(FubenTeamData.FLUSH_ALERT_STATE, BindTool.Bind(self.OnFlushAlertState, self))
end

function MenberListAlert:CreateMenberListView()
    local ph = self.ph_list.ph_menber_list
    self.menber_list_view = ListView.New()
    self.menber_list_view:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, MenberItemRender, ListViewGravity.CenterHorizontal, false, self.ph_list.ph_menber_item)
    self.menber_list_view:SetItemsInterval(0)
    self.menber_list_view:SetJumpDirection(ListView.Top)
    self.node_t_list.layout_menber_alert.node:addChild(self.menber_list_view:GetView(), 10)
end

function MenberListAlert:OnFlush(param_t, index)
end

function MenberListAlert:OnFlushData()
    self.node_t_list.lbl_title.node:setString(Language.FubenMutil.MenListAlertTitles[1])
    if self.fuben_type == nil or self.fuben_id == nil or self.fuben_layer == nil or self.team_id == nil then
    return
    end
    local is_my_team = FubenMutilData.Instance:IsLeaderForMe(self.fuben_type, self.fuben_layer, self.team_id)
    self:FlushTeamData(is_my_team)
    self:FlushButtonState(is_my_team)
end

function MenberListAlert:OnFlushAlertState(team_id)
    if self.open_type == MenberListAlert.OpenType.ENTER_FUBEN and 
        team_id == self.team_id then
            self:Close()
    end
end

function MenberListAlert:FlushTeamData(is_my_team)
    local info = FubenMutilData.Instance:GetTeamDetailInfo(self.fuben_type, self.fuben_layer, self.team_id)
    local menber_infos = DeepCopy(info)
    for k, v in pairs(menber_infos) do
        v.is_my_team = is_my_team
        v.open_type  = self.open_type
        v.fuben_type = self.fuben_type
        v.fuben_id   = self.fuben_id
        v.team_id    = self.team_id
    end
    self.menber_list_view:SetDataList(menber_infos)
end

function MenberListAlert:FlushButtonState(is_my_team)
    if is_my_team and self.open_type == MenberListAlert.OpenType.ENTER_FUBEN then
        self.node_t_list.btn_enter.node:setTitleText(Language.FubenMutil.EnterBtnText[1])
    elseif self.open_type == MenberListAlert.OpenType.ENTER_FUBEN then
        self.node_t_list.btn_enter.node:setTitleText(Language.FubenMutil.EnterBtnText[2])
    elseif self.open_type == MenberListAlert.OpenType.LOOK_MENBER then
        self.node_t_list.btn_enter.node:setTitleText(Language.FubenMutil.EnterBtnText[3])
    end

    self.node_t_list.lbl_cutdown.node:setVisible(self.open_type == MenberListAlert.OpenType.ENTER_FUBEN)

    local text = self.node_t_list.btn_enter.node:getTitleText()
    if text == Language.FubenMutil.EnterBtnText[2] then
        local is_ready = FubenMutilData.Instance:IsReadyForMe()
        XUI.SetButtonEnabled(self.node_t_list.btn_enter.node, not is_ready)
    else
        XUI.SetButtonEnabled(self.node_t_list.btn_enter.node, true)
    end
end

function MenberListAlert:SetTeamInfo(fuben_type, fuben_id, fuben_layer, team_id)
    self.fuben_type = fuben_type
    self.fuben_id = fuben_id
    self.fuben_layer = fuben_layer
    self.team_id = team_id
end

function MenberListAlert:SetOpenType(type)
    self.open_type = type
end

function MenberListAlert:GetOpenType()
    return self.open_type
end

function MenberListAlert:GetTeamId()
    return self.team_id
end

function MenberListAlert:OnTimerCallback()
    self.left_secs = self.left_secs - 1
    self.node_t_list.lbl_cutdown.node:setString(string.format(Language.FubenMutil.EnterCutdownText, self.left_secs))
    if self.left_secs <= 0 then
        local count = FubenMutilData.Instance:GetReadyCount(self.fuben_type, self.fuben_id, self.fuben_layer, self.team_id)
        if count >= 2 then
            if FubenMutilData.Instance:IsLeaderForMe(self.fuben_type, self.fuben_layer, self.team_id) then
                FubenMutilCtrl.SendEnterFuben(self.fuben_type, self.fuben_layer)
            end
        else
            SysMsgCtrl.Instance:ErrorRemind(Language.FubenMutil.EnterFubenCond[2])
        end
        self:Close()
    end
end

function MenberListAlert:OnClickEnter()
    local text = self.node_t_list.btn_enter.node:getTitleText()
    if text == Language.FubenMutil.EnterBtnText[3] then
        self:Close()
    elseif text == Language.FubenMutil.EnterBtnText[2] then
        FubenMutilCtrl.SendPreEnterFuben(self.fuben_type, self.fuben_id, self.team_id, self.fuben_layer)
    elseif text == Language.FubenMutil.EnterBtnText[1] then
        if self.fuben_type ~= nil and self.fuben_id ~= nil then
            local count = FubenMutilData.Instance:GetReadyCount(self.fuben_type, self.fuben_id, self.fuben_layer, self.team_id)
            if count >= 2 and FubenMutilData.Instance:IsLeaderForMe(self.fuben_type, self.fuben_layer, self.team_id) then
                FubenMutilCtrl.SendEnterFuben(self.fuben_type, self.fuben_layer)
                self:Close()
            else
                SysMsgCtrl.Instance:ErrorRemind(Language.FubenMutil.EnterFubenCond[2])
            end
        end
    end
end

function MenberListAlert:CancelTimer()
    if self.cutdown_timer then
        GlobalTimerQuest:CancelQuest(self.cutdown_timer)
        self.cutdown_timer = nil
    end
end

MenberItemRender = MenberItemRender or BaseClass(BaseRender)
function MenberItemRender:__init()
   
end

function MenberItemRender:CreateChild()
	BaseRender.CreateChild(self)

	XUI.AddClickEventListener(self.node_tree.btn_out.node, BindTool.Bind(self.OnClickOut, self))
end

function MenberItemRender:OnFlush()
    if self.data == nil then return end

    self.node_tree.lbl_name.node:setString(self.data.name)
    self.node_tree.lbl_info.node:setString(self.data.is_leader == 1 and Language.FubenMutil.MenberTypes[1] or Language.FubenMutil.MenberTypes[2])
    self.node_tree.btn_out.node:setVisible(self.data.open_type == MenberListAlert.OpenType.LOOK_MENBER and self.data.is_my_team and self.data.is_leader == 0)
    self.node_tree.lbl_ready.node:setVisible(self.data.open_type == MenberListAlert.OpenType.ENTER_FUBEN)
    if self.data.is_ready == 1 then
        self.node_tree.lbl_ready.node:setColor(COLOR3B.GREEN)
        self.node_tree.lbl_ready.node:setString(Language.FubenMutil.MenberStateText[2])
    elseif self.data.is_ready == 0 then
        self.node_tree.lbl_ready.node:setColor(COLOR3B.RED)
        self.node_tree.lbl_ready.node:setString(Language.FubenMutil.MenberStateText[1])
    end
end

function MenberItemRender:OnClickOut()
    FubenMutilCtrl.SendOutMenberRequest(self.data.fuben_type, self.data.fuben_id, self.data.id)
end

function MenberItemRender:CreateSelectEffect()
end
