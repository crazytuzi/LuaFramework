TipsMyRank = TipsMyRank or BaseClass(BaseView)

function TipsMyRank:__init()
	self.ui_config = {"uis/views/tips/roleranktip_prefab", "RoleRankTip"}
	self.play_audio = true
	self.view_layer = UiLayer.PopTop
	self.my_rank_index = 0
	self.black_mask_color_a = 0.7845
end

function TipsMyRank:__delete()
end

function TipsMyRank:LoadCallBack()
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self.display = self:FindObj("Display")
	self.show_name_text = self:FindVariable("show_name_text")
	self.show_zhanli_text = self:FindVariable("show_zhanli_text")
	self.my_rank = self:FindVariable("my_rank")
end


function TipsMyRank:ReleaseCallBack()
	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	self.display = nil
	self.my_rank = nil
	self.show_name_text = nil
	self.show_zhanli_text = nil
end

function TipsMyRank:OnFlush()

end

function TipsMyRank:GetMyRankInfo(index)
	self.my_rank_index = index or 0
end

function TipsMyRank:OpenCallBack()
	local role_info = GameVoManager.Instance:GetMainRoleVo()
	if nil == role_info then
		return
	end

	self.role_model = RoleModel.New("my_rank_panel")
	self.role_model:SetDisplay(self.display.ui3d_display)
	local main_role = Scene.Instance:GetMainRole()
	self.role_model:SetRoleResid(main_role:GetRoleResId())
	self.role_model:SetWeaponResid(main_role:GetWeaponResId())
	self.role_model:SetWeapon2Resid(main_role:GetWeapon2ResId())
	self.role_model:SetWingResid(main_role:GetWingResId())
	self.role_model:SetBool("idle_n2", true)
	self.show_name_text:SetValue(role_info.name)
	self.show_zhanli_text:SetValue(role_info.capability)
	self.my_rank:SetValue(Language.Rank.RankIndex[self.my_rank_index])

end

function TipsMyRank:OnCloseClick()
	self:Close()
end