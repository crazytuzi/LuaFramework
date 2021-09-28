TipsEnterArenaView = TipsEnterArenaView or BaseClass(BaseView)

function TipsEnterArenaView:__init()
	self.ui_config = {"uis/views/tips/arenatips_prefab", "EnterArenaTips"}
	self.view_layer = UiLayer.Pop
	self.uid = nil
	self.user_data = nil
end

function TipsEnterArenaView:__delete()

end

function TipsEnterArenaView:LoadCallBack()
	self.name_text = self:FindVariable("name_text")
	self.honor_text = self:FindVariable("honor_text")
	self.rank_text = self:FindVariable("rank_text")
	self.zhanli_text = self:FindVariable("zhanli_text")
	self:ListenEvent("Close", BindTool.Bind(self.ClickClose, self))
	self:ListenEvent("Enter", BindTool.Bind(self.SendEnterArenaReq, self))

	self.alert = Alert.New()
end

function TipsEnterArenaView:ReleaseCallBack()
	-- 清理变量和对象
	self.name_text = nil
	self.honor_text = nil
	self.rank_text = nil
	self.zhanli_text = nil
	self.user_data = nil
	self.uid = nil
	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end
end

function TipsEnterArenaView:OpenCallBack()
	self:Flush()
end

function TipsEnterArenaView:OnFlush()
	local tz_info = ArenaData.Instance:GetRoleTiaoZhanInfoByUid(self.uid)
	local info = ArenaData.Instance:GetUserInfo()

	if tz_info then
		self.name_text:SetValue(self.user_data.name)
		self.rank_text:SetValue(tz_info.rank)
		self.zhanli_text:SetValue(self.user_data.capability)
		if info then
			local cur_reward = ArenaData.Instance:GetCurRanJieShuanShengWangByRank(tz_info.rank_pos)
			self.honor_text:SetValue(cur_reward)
		end
	end
end

function TipsEnterArenaView:ClickClose()
	self:Close()
end

function TipsEnterArenaView:SendEnterArenaReq()
	local tz_info = ArenaData.Instance:GetRoleTiaoZhanInfoByUid(self.uid)
	if tz_info then
		local data = {}
		data.opponent_index = tz_info.index
		data.rank_pos = tz_info.rank_pos
		data.is_auto_buy = 0
		-- if ArenaData.Instance:GetResidueTiaoZhanNum() > 0 then
		-- 	data.is_auto_buy = 0
		-- 	ArenaCtrl.Instance:ResetFieldFightReq(data)
		-- else
		-- 	data.is_auto_buy = 1
		-- 	self.alert:SetContent("自动购买挑战次数")
		-- 	self.alert:SetOkFunc(BindTool.Bind2(ArenaCtrl.Instance.ResetFieldFightReq, ArenaCtrl.Instance, data))
		-- 	self.alert:Open()
		-- end
		ArenaCtrl.Instance:ResetFieldFightReq(data)
	end
end

function TipsEnterArenaView:SetData(data)
	self.user_data = data
	self.uid = self.user_data.role_id
	self:Flush()
end