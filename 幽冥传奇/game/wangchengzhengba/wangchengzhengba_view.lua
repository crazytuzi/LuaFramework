WangChengZhengBaView = WangChengZhengBaView or BaseClass(BaseView)

function WangChengZhengBaView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.def_index = TabIndex.wangchengzhengba_gcz
	self.texture_path_list[1] = 'res/xui/wangchengzhengba.png'
	self.config_tab = {
		{"wangchengzhengba_ui_cfg", 1, {0}},
		{"wangchengzhengba_ui_cfg", 6, {0}},
	}
end

function WangChengZhengBaView:__delete()
end

function WangChengZhengBaView:ReleaseCallBack()
end

function WangChengZhengBaView:LoadCallBack(index, loaded_times)
	-- 按钮回调
	self.node_t_list.btn_empire_glory.node:addClickEventListener(BindTool.Bind(self.OnClickChangePage, self, 1))
	self.node_t_list.btn_siege_rule.node:addClickEventListener(BindTool.Bind(self.OnClickChangePage, self, 2))
	self.node_t_list.btn_apply_siege.node:addClickEventListener(BindTool.Bind(self.OnClickChangePage, self, 3))
	self.node_t_list.btn_siege_rewards.node:addClickEventListener(BindTool.Bind(self.OnClickChangePage, self, 4))
	self.node_t_list.btn_goto_shabak.node:addClickEventListener(BindTool.Bind(self.OnClickGotoShabak, self))
	self.node_t_list.img_bg.node:loadTexture(ResPath.GetBigPainting("royalcity_warcraft_bg1"))
	-- self.node_t_list.btn_siege_rewards.remind_eff = RenderUnit.CreateEffect(23, self.node_t_list.btn_siege_rewards.node, 1)
	-- self.node_t_list.btn_siege_rewards.remind_eff:setVisible(false)
	-- local pos = self.ph_list.ph_title_pos
	-- RenderUnit.CreateEffect(303, self.root_node, zorder, 0.35, loops, pos.x, pos.y)
	self.node_t_list.layout_bottom_button.node:setLocalZOrder(999)
	EventProxy.New(WangChengZhengBaData.Instance, self):AddEventListener(WangChengZhengBaData.SbkWarStateDataChangeEvent, BindTool.Bind(self.OnFlushGotoShabakBtn, self))
end

function WangChengZhengBaView:OnClickChangePage(index)
	if 1 == index then
		self.node_t_list.img_bg.node:loadTexture(ResPath.GetBigPainting("royalcity_warcraft_bg1"))
		ViewManager.Instance:OpenViewByDef(ViewDef.WangChengZhengBa.EmpireGlory)
	elseif 2 == index then
		self.node_t_list.img_bg.node:loadTexture(ResPath.GetBigPainting("royalcity_warcraft_bg2"))
		ViewManager.Instance:OpenViewByDef(ViewDef.WangChengZhengBa.SiegeRule)
	elseif 3 == index then
		self.node_t_list.img_bg.node:loadTexture(ResPath.GetBigPainting("royalcity_warcraft_bg2"))
		ViewManager.Instance:OpenViewByDef(ViewDef.WangChengZhengBa.ApplySiege)
	elseif 4 == index then
		self.node_t_list.img_bg.node:loadTexture(ResPath.GetBigPainting("royalcity_warcraft_bg3"))
		ViewManager.Instance:OpenViewByDef(ViewDef.WangChengZhengBa.SiegeRewards)
	end
end

function WangChengZhengBaView:OnClickGotoShabak()
	Scene.SendQuicklyTransportReq(10)
end

function WangChengZhengBaView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	WangChengZhengBaCtrl.SendGetGongChengGuildRewardMsg()
	WangChengZhengBaCtrl.SendGetSbkMag()
end

function WangChengZhengBaView:ShowIndexCallBack(index)
	self:OnFlushGotoShabakBtn()
end

function WangChengZhengBaView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function WangChengZhengBaView:OnFlushGotoShabakBtn()
	if nil == self.node_t_list.btn_goto_shabak.node then return end
	self.node_t_list.btn_goto_shabak.node:setEnabled(WangChengZhengBaData.Instance.sbk_war_state == 1 or WangChengZhengBaData.Instance.sbk_war_state == 2)
end

function WangChengZhengBaView:OnFlush(param_t, index)
end

function WangChengZhengBaView:OnFlushRemind(is_show_remind)
	-- if self.node_t_list and self.node_t_list.btn_siege_rewards then
	-- 	self.node_t_list.btn_siege_rewards.remind_eff:setVisible(is_show_remind)
	-- end
end