MaFaUsediceView = MaFaUsediceView or BaseClass(XuiBaseView)

function MaFaUsediceView:__init()
	self.is_modal = false
	self.can_penetrate = true
	self.is_any_click_close = true		
	self.config_tab = {
		{"mafa_explore_ui_cfg", 3, {0}},
	}
	self.cur_number = nil
end

function MaFaUsediceView:__delete()

end

function MaFaUsediceView:ReleaseCallBack()

end

function MaFaUsediceView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		for i = 1, 6 do
			self.node_t_list["btn_select_"..i].node:addClickEventListener(BindTool.Bind(self.SelectDicesNumber, self, i))
		end
		self.node_t_list.btn_sure.node:addClickEventListener(BindTool.Bind(self.UseDicesByGold, self))
		self.node_t_list.btn_cancel.node:addClickEventListener(BindTool.Bind(self.CancelUseDices, self))
		self.node_t_list.img_bg_1.node:setVisible(false)
		self.node_t_list.img_bg_1.node:setLocalZOrder(998)
	end
end

function MaFaUsediceView:SelectDicesNumber(type)
	self.cur_number = type
	local pos = self.node_t_list["btn_select_"..type].node:getPositionX()
	self.node_t_list.img_bg_1.node:setPositionX(pos)
	self.node_t_list.img_bg_1.node:setVisible(true)
end

function MaFaUsediceView:UseDicesByGold()
	if self.cur_number == nil then
		 SysMsgCtrl.Instance:FloatingTopRightText(Language.AllDayActivity.Tips)
	else
		local data = ActivityData.Instance:GetNormalConfig()
		local circle = ActivityData.Instance:GetMyCircle()
		if circle >= MAX_CIRCLE_NUM then
			data = ActivityData.Instance:GetSpecialItemData()
		end
		local pos = ActivityData.Instance:GetCurPos()
		local reward_state, reward_pos = ActivityData.Instance:BoolGetReward() 
		local cur_data = data[pos]
		if reward_state == 2 then
			ActivityCtrl.Instance:OpenEventPanel(cur_data)
		elseif reward_state == 1 then
			if cur_data.eventType == MulphaAdventureEvent.fight or cur_data.eventType == MulphaAdventureEvent.canNotPassFight then
				ActivityCtrl.Instance:OpenReWardPanel(cur_data.awardDesc, reward_pos, data)
			else
				ActivityCtrl.Instance:OpenReWardPanel(cur_data.desc, reward_pos, data)
			end
		else
			if ActivityData.Instance:GetHadBoolRun() then
				ActivityCtrl.Instance:ReqUseDices(2, self.cur_number)
			else
				SysMsgCtrl.Instance:FloatingTopRightText(Language.AllDayActivity.DescTip_1)
			end
			self:Close()
		end
	end
end

function MaFaUsediceView:CancelUseDices()
	self:Close()
end

function MaFaUsediceView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MaFaUsediceView:ShowIndexCallBack(index)
	self:Flush(index)
end

function MaFaUsediceView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.cur_number = nil
	if self.node_t_list.img_bg_1.node ~= nil then
		self.node_t_list.img_bg_1.node:setVisible(false)
	end
end

--刷新界面
function MaFaUsediceView:OnFlush(param_t, index)
	local num = ActivityData.Instance:GetUseDicesNum()
	local gold = MulphaAdventureConfig.buyDicePointNeed + num*MulphaAdventureConfig.buyDicePointNeedAdd
	RichTextUtil.ParseRichText(self.node_t_list.rich_consume_gold.node, string.format(Language.AllDayActivity.Consume_show, gold), 22)
	XUI.RichTextSetCenter(self.node_t_list.rich_consume_gold.node)
end