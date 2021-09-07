ShenJiSkillView = ShenJiSkillView or BaseClass(BaseView)

function ShenJiSkillView:__init()
	self:SetMaskBg()
	self.ui_config = {"uis/views/roleskill","ShenJiSkillView"}
	self.play_audio = true
	self.def_index = 0
end

function ShenJiSkillView:__delete()
	
end

function ShenJiSkillView:ReleaseCallBack()
	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end

	self.value_str = nil
	self.can_click = nil
	self.jungong_str = nil
	self.button_str = nil
end

function ShenJiSkillView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))

	self.value_str = self:FindVariable("ValueStr")
	self.can_click = self:FindVariable("CanClick")
	self.jungong_str = self:FindVariable("JunGongStr")
	self.button_str = self:FindVariable("ButtonStr")

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))
end

function ShenJiSkillView:CloseView()
	self:Close()
end

function ShenJiSkillView:OpenCallBack()
	ClickOnceRemindList[RemindName.ShenJiSkill] = 0
	RoleSkillCtrl.Instance:SendShenJiSkillReq(SHEN_JI_SKILL_TYPE.REQ_INFO)
end

function ShenJiSkillView:ShowIndexCallBack()
	self:Flush()
end

function ShenJiSkillView:OnClickGet()
	RoleSkillCtrl.Instance:SendShenJiSkillReq(SHEN_JI_SKILL_TYPE.FETCH_REWARD)
end

function ShenJiSkillView:OnFlush()
	local data = RoleSkillData.Instance:GetShenJiSkillInfo()
	if data == nil or next(data) == nil then
		return
	end

	if self.value_str ~= nil and data.camp_jungong ~= nil then
		local cfg = ConfigManager.Instance:GetAutoConfig("other_config_auto")
		if cfg and cfg.other and cfg.other[1] then
			local need_jungong = cfg.other[1].shenji_skill_reward_need_day_jungong
			local reward_item = cfg.other[1].shenji_skill_reward_item

			if need_jungong then
				if self.jungong_str ~= nil then
					self.jungong_str:SetValue(string.format(Language.Common.ShenJiSkillStr, need_jungong or 0))
				end

				self.value_str:SetValue(string.format(Language.Common.ShenJiSkillNeedStr, data.camp_jungong or 0, need_jungong or 0))

				if self.can_click ~= nil and data.has_fatch_reward ~= nil then
					self.can_click:SetValue(data.has_fatch_reward == 0 and (data.camp_jungong >= need_jungong))
				end

				if self.button_str ~= nil and data.has_fatch_reward then
					local str = Language.Common.NoIsCanGet
					if data.has_fatch_reward == 0 and (data.camp_jungong >= need_jungong) then
						str = Language.Common.IsCanGet
					elseif data.has_fatch_reward == 1 then
						str = Language.Common.IsAlready
					end

					self.button_str:SetValue(str)
				end
			end

			if reward_item ~= nil and self.item ~= nil then
				self.item:SetData(reward_item)
			end
		end
	end
end