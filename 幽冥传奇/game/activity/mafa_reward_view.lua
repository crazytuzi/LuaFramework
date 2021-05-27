MaFaRewardView = MaFaRewardView or BaseClass(XuiBaseView)

function MaFaRewardView:__init()
	self.is_modal = false
	self.can_penetrate = false
	self.config_tab = {
		{"mafa_explore_ui_cfg", 4, {0}},
	}
	self.desc = ""
	self.reward_pos = 0
	self.data = {} 
end

function MaFaRewardView:__delete()

end

function MaFaRewardView:ReleaseCallBack()

end

function MaFaRewardView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		self.node_t_list.btn_getreward.node:addClickEventListener(BindTool.Bind(self.GetReaward, self))

	end
end

function MaFaRewardView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MaFaRewardView:ShowIndexCallBack(index)
	self:Flush(index)
end

function MaFaRewardView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MaFaRewardView:SetData(desc, reward_pos, data)
	self.desc = desc
	self.data = data
	self.reward_pos = reward_pos
	self:Flush()
end

--刷新界面
function MaFaRewardView:OnFlush(param_t, index)
	if self.data.eventType == MulphaAdventureEvent.startPoint then
		RichTextUtil.ParseRichText(self.node_t_list.rich_text_desc.node, self.desc, 22)
	elseif self.data.eventType == MulphaAdventureEvent.rest then
		RichTextUtil.ParseRichText(self.node_t_list.rich_text_desc.node, self.desc, 22)
	elseif self.data.eventType == MulphaAdventureEvent.awards then	
		local id = self.data.awards[1].id 
		local count = self.data.awards[1].count
		local config = ItemData.Instance:GetItemConfig(id)
		local txt = string.format(self.desc, count, config.name)
		RichTextUtil.ParseRichText(self.node_t_list.rich_text_desc.node, txt, 22)
	elseif self.data.eventType == MulphaAdventureEvent.randomEvent then
		local data = self.data.randomEvent[self.reward_pos] or {}
		local reward_type = data.subType or 1
		local reward_num = data.awardNum or 1
		local txt = string.format(Language.AllDayActivity.Show_Reward[reward_type], reward_num)
		local desc = string.format(self.desc, txt)
		RichTextUtil.ParseRichText(self.node_t_list.rich_text_desc.node, desc, 22)
	elseif self.data.eventType ==  MulphaAdventureEvent.fight or  self.data.eventType ==  MulphaAdventureEvent.canNotPassFight then
		local moster_id = self.data.boss[1].monsterId
		local boss_cfg = BossData.GetMosterCfg(moster_id)
		local name = boss_cfg.name

		local data = self.data.randomReward[self.reward_pos] or {}
		local reward_type = data.subType or 1
		local reward_num = data.awardNum or 1
		local txt = string.format(Language.AllDayActivity.Show_Reward[reward_type], reward_num)
		local desc = string.format(self.desc, name, txt)
		RichTextUtil.ParseRichText(self.node_t_list.rich_text_desc.node, desc, 22)
	end
end

function MaFaRewardView:GetReaward()
	if self.data.eventType == MulphaAdventureEvent.rest or self.data.eventType == MulphaAdventureEvent.startPoint then
		self:Close()
	else
		ActivityCtrl.Instance:ReqCustomsOprate(1)
		--self:Close()
	end
end
