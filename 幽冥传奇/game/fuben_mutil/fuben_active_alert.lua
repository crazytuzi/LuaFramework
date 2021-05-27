FubenActiveAlert = FubenActiveAlert or BaseClass(XuiBaseView)

function FubenActiveAlert:__init()
    self:SetModal(true)

    self.config_tab = {
		{"fuben_mutil_ui_cfg", 2, {0}},
	}

end

function FubenActiveAlert:ShowIndexCallBack(index)
	self:Flush(index)
end

function FubenActiveAlert:LoadCallBack(index, loaded_times)
    if loaded_times <= 1 then
        local size = self.root_node:getContentSize()

        self.node_t_list.lbl_title.node:setString(Language.FubenMutil.ProgressActivedText[1])

        local content = XUI.CreateText(size.width / 2, size.height / 2 + 70)
        content:setFontSize(24)
        content:setColor(COLOR3B.G_W)
        content:setString(Language.FubenMutil.ProgressActivedText[2])
        self.root_node:addChild(content, 10)

        self.progress = XUI.CreateLoadingBar(size.width / 2, size.height / 2 - 60, ResPath.GetCommon("prog_hp"), true, ResPath.GetCommon("prog_bg"))
        self.progress:setPercent(0)
        self.root_node:addChild(self.progress, 10)

        self.lbl_progress = XUI.CreateText(size.width / 2, size.height / 2 - 58)
        self.root_node:addChild(self.lbl_progress, 10)

        self.award_layout = XUI.CreateLayout(0, 0, 0, 0)
        self.award_layout:setAnchorPoint(0.5, 0.5)
        self.root_node:addChild(self.award_layout, 10)

        self.node_t_list.btn_enter.node:setTitleText(Language.FubenMutil.CreateTeamBtnText[3])
        XUI.AddClickEventListener(self.node_t_list.btn_enter.node, BindTool.Bind(self.OnClickEnter, self))
    end
end

function FubenActiveAlert:OpenCallBack()
    self.timer = GlobalTimerQuest:AddTimesTimer(function()
        self.node_t_list.lbl_cutdown.node:setString(string.format(Language.FubenMutil.EnterCutdownText, self.cutdown_secs))
        self.cutdown_secs = self.cutdown_secs - 1
        if self.cutdown_secs <= 0 then
            self:CancelTimer()
            local scene_id = Scene.Instance:GetSceneId()
            local team_info = FubenMutilData.Instance:GetMyTeamInfo(FubenMutilType.Team, FubenMutilLayer[FubenMutilSceneId.Team])
            if team_info and FubenMutilData.Instance:IsLeaderForMe(FubenMutilType.Team, FubenMutilLayer[FubenMutilSceneId.Team], team_info.team_id) then
                local max_kill_num = FubenMutilData.GetNeedKilledNum(FubenMutilType.Team, FubenMutilLayer[scene_id])
                local cur_kill_num = FubenMutilData.Instance:GetCurKilledNum()
                if cur_kill_num >= max_kill_num then
                    FubenMutilCtrl.SendGetFubenAwardReq(FubenMutilType.Team, FubenMutilLayer[scene_id], FubenMutilLayer[scene_id] + 1)
                end
            end
            self:Close()
        end
    end, 1, self.cutdown_secs)
end

function FubenActiveAlert:CloseCallBack()
    self:CancelTimer()
end

function FubenActiveAlert:CancelTimer()
    if self.timer then
        GlobalTimerQuest:CancelQuest(self.timer)
        self.timer = nil
    end
end

function FubenActiveAlert:SetProgress(current, max)
    self.current = current
    self.max = max
end

function FubenActiveAlert:SetCutdownSecs(secs)
    self.cutdown_secs = secs
end

function FubenActiveAlert:OnFlush(param_t, index)
    if self.current == nil or self.max ==  nil then
        return
    end

    self.progress:setPercent(self.current * 100 / self.max)
    self.lbl_progress:setString(string.format("%s/%s", self.current, self.max))

    local scene_id = Scene.Instance:GetSceneId()
    local award_list = FubenMutilData.GetFubenRealAwardList(FubenMutilType.Team, FubenMutilLayer[scene_id])
    self:FlushAwardItems(award_list)
end

function FubenActiveAlert:FlushAwardItems(award_list)
    self.award_layout:removeAllChildren()
    local count = 0
    for k, v in pairs(award_list or {}) do
        local cell = BaseCell.New()
        local id = v.id
        if v.type > 0 then
            id = ItemData.GetVirtualItemId(v.type)
        end
        cell:SetData({item_id = id, num = v.count, is_bind = v.bind})
        cell:SetPosition(count * (BaseCell.SIZE + 10), 0)
        self.award_layout:addChild(cell:GetView())
        count = count + 1
    end
    self.award_layout:setContentWH( count * BaseCell.SIZE + (count - 1) * 10, BaseCell.SIZE )
    local size = self.root_node:getContentSize()
    self.award_layout:setPosition(size.width / 2, size.height / 2)
end

function FubenActiveAlert:OnClickEnter()
    local scene_id = Scene.Instance:GetSceneId()
    local team_info = FubenMutilData.Instance:GetMyTeamInfo(FubenMutilType.Team, FubenMutilLayer[FubenMutilSceneId.Team])
    if team_info then
        if FubenMutilData.Instance:IsLeaderForMe(FubenMutilType.Team, FubenMutilLayer[FubenMutilSceneId.Team], team_info.team_id) then
            local max_kill_num = FubenMutilData.GetNeedKilledNum(FubenMutilType.Team, FubenMutilLayer[scene_id])
	        local cur_kill_num = FubenMutilData.Instance:GetCurKilledNum()
            if cur_kill_num >= max_kill_num then
                FubenMutilCtrl.SendGetFubenAwardReq(FubenMutilType.Team, FubenMutilLayer[scene_id], FubenMutilLayer[scene_id] + 1)
            end
            self:Close()
        else
            SysMsgCtrl.Instance:ErrorRemind(Language.FubenMutil.EnterFubenCond[3])
        end
    end
end
