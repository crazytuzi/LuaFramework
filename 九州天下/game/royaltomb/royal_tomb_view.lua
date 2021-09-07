RoyalTombView = RoyalTombView or BaseClass(BaseView)

function RoyalTombView:__init()
	self.ui_config = {"uis/views/royaltomb","RoyalTombView"}
	self:SetMaskBg()
	self.play_audio = true
end

function RoyalTombView:__delete()

end

function RoyalTombView:ReleaseCallBack()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	

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

function RoyalTombView:LoadCallBack()
	--获取变量
	---[[--左下角描述
	self.text_left_top = self:FindVariable("TextLeftTop")
	self.text_left_bottom = self:FindVariable("TextLeftBottom")
	self.text_right_bottom = self:FindVariable("TextRightBottom")
	--]]
	self.explain = self:FindVariable("Explain")					--说明文本

	--获取组件
	self.item_list = {}
	for i = 1, 3 do
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

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
end

function RoyalTombView:OpenCallBack()
	self:Flush()
end

function RoyalTombView:ClickEnter()
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_HUANGLING)
end

function RoyalTombView:OnFlush()
	local role_level = PlayerData.Instance:GetRoleLevel()
	local fb_cfg = RoyTombData.Instance:GetEnterInfoByLevel(role_level)
	
	if fb_cfg then
	
		local reward_cfg = fb_cfg.reward_show or {}
		for i = 1, 3 do
			if reward_cfg[i - 1] then
				self.item_list[i]:SetData(reward_cfg[i - 1])
			end
		end
		local scene_config = MapData.Instance:GetMapConfig(fb_cfg.scene_id)

		 local info_cfg = RoyTombData.Instance:GetRoyTombInfoCfg()
		 if info_cfg and info_cfg.other then
		
		 	local other_cfg = info_cfg.other[1]
		 	local royaltomb_info = RoyTombData.Instance:GetHuanglingFBRoleInfo()
		 	if royaltomb_info then
		 		local content = ""
				content = fb_cfg.enter_need_level .. " - " ..  fb_cfg.enter_max_level
				local str_1 = string.format(Language.RoyalTomb.LevelRange, content)

		 		content = scene_config.name
				local str_2 = string.format(Language.RoyalTomb.Scene, content)

				content = royaltomb_info.today_kill_role_score .. " / " .. other_cfg.kill_role_score_limit
				local str_3 = string.format(Language.RoyalTomb.Score, content)
				self.explain:SetValue(str_1 .. "\n" .. str_2 .. "\n" .. str_3)
			end
		end
	end
end

function RoyalTombView:TipsClick()
 	local tips_id = 243 -- 皇陵副本说明
  	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end