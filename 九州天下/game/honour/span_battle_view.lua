SpanBattleView = SpanBattleView or BaseClass(BaseView)

function SpanBattleView:__init()
	self.ui_config = {"uis/views/honourview","SpanBattleView"}
	self:SetMaskBg()
	self.play_audio = true
end

function SpanBattleView:__delete()

end

function SpanBattleView:ReleaseCallBack()
	if self.item_list ~= nil then
		for k, v in ipairs(self.item_list) do
			v:DeleteMe()
		end
		self.item_list = {}
	end
	

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	-- 清理变量和对象
	self.text_left_top = nil
	self.text_left_bottom = nil
	self.text_right_bottom = nil
	self.explain = nil
end

function SpanBattleView:LoadCallBack()
	--获取变量
	---[[--左下角描述
	self.text_left_top = self:FindVariable("TextLeftTop")
	self.text_left_bottom = self:FindVariable("TextLeftBottom")
	self.text_right_bottom = self:FindVariable("TextRightBottom")
	--]]
	self.explain = self:FindVariable("Explain")					--说明文本

	--获取组件
	self.item_list = {}
	for i = 1, 4 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item" .. i))
		item:SetData(nil)
		-- item:ListenClick(BindTool.Bind(self.ItemClick, self, i))
		table.insert(self.item_list, item)
	end

	--绑定事件
	self:ListenEvent("CloseWindow", BindTool.Bind(self.Close, self))
	self:ListenEvent("ClickEnter", BindTool.Bind(self.ClickEnter, self))
	self:ListenEvent("TipsClick", BindTool.Bind(self.TipsClick, self))

	--self.money_bar = MoneyBar.New()
	--self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
end

function SpanBattleView:OpenCallBack()
	self:Flush()
end

function SpanBattleView:ClickEnter()
	--FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_HUANGLING)
	CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_BATTLE)
end

function SpanBattleView:OnFlush()
	local role_level = PlayerData.Instance:GetRoleLevel()
	local fb_cfg = HonourData.Instance:GetEnterInfoByLevel(role_level)
	
	local reward_cfg = HonourData.Instance:GetShowRewardCfg() or {}
	for i = 1, 4 do
		if reward_cfg[1].first_item[i - 1] then
			self.item_list[i]:SetData(reward_cfg[1].first_item[i - 1])
		end
	end

	if fb_cfg then
		local content = ""
		content = fb_cfg.enter_level .. " - " ..  fb_cfg.max_level
		local str_1 = string.format(Language.Honour.LevelRange, content)

		content = fb_cfg.scene_name
		local str_2 = string.format(Language.Honour.Scene, content)

		--content = royaltomb_info.today_kill_role_score .. " / " .. other_cfg.kill_role_score_limit
		content = HonourData.Instance:GetHonourInfo().honour
		local str_3 = string.format(Language.Honour.HonourScore, content)
		if self.explain then
			self.explain:SetValue(str_1 .. "\n" .. str_2 .. "\n" .. str_3)
		end
	end
end

function SpanBattleView:TipsClick()
 	local tips_id = 252 
  	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end