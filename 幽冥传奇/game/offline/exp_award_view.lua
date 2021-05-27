ExpAwardView = ExpAwardView or BaseClass(BaseView)

function ExpAwardView:__init()
	-- self:SetModal(true)
	self.is_any_click_close = true
	self.config_tab = {
		{"offline_ui_cfg", 2, {0}},
	}
	
end

function ExpAwardView:ReleaseCallBack()
	if nil ~= self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
	end
end

Language.ExpAward = {
	text1 = "/小时",
	text2 = "提高经验效益",
	text3 = "当前在线时间: ",
}

function ExpAwardView:LoadCallBack(index, loaded_times)
	self.rich_link = RichTextUtil.CreateLinkText(Language.ExpAward.text2, 20, COLOR3B.GREEN, nil, true)
	self.rich_link:setPosition(535, 195)
	self.node_t_list.layout_exp_award.node:addChild(self.rich_link, 100)
	XUI.AddClickEventListener(self.rich_link,function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.ShiLian)
		self:Close()
	end)

	self.update_spare_timer = GlobalTimerQuest:AddRunQuest(function ()
		self.node_t_list.lbl_online_time.node:setString(Language.ExpAward.text3 .. TimeUtil.FormatSecond2Str(OfflineCtrl.Instance:GetOnlineTime()))
	end, 1)

	self:Flush()
end

function ExpAwardView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	OfflineCtrl.SendOfflineVipReward()
end


function ExpAwardView:ShowIndexCallBack()
	self:Flush()
end


function ExpAwardView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end


function ExpAwardView:OnFlush(param_t, index)
	local part_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	local exp_num = part_num == 0 and 0 or TrialFloorConfig.Floor[part_num].nExp * 6 * 60
	self.node_t_list.lbl_exp_num_hour_tip.node:setString(exp_num .. Language.ExpAward.text1)

	local num_wan = (param_t.all.exp_num and param_t.all.exp_num >= 10000) and math.floor(param_t.all.exp_num / 10000) .. Language.Common.Wan or param_t.all.exp_num	
	self.node_t_list.lbl_exp_num.node:setString(num_wan)

	self.node_t_list.lbl_online_time.node:setString(Language.ExpAward.text3 .. TimeUtil.FormatSecond2Str(param_t.all.online_time))
end
