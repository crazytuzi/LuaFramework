TipShenBingView = TipShenBingView or BaseClass(BaseView)

function TipShenBingView:__init()
	self.ui_config = {"uis/views/shenqiview", "TipShenBingView"}
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
end

function TipShenBingView:__delete()
end

function TipShenBingView:ReleaseCallBack()
	if self.display ~= nil then
		self.display:DeleteMe()
		self.display = nil
	end

	self.str_list = {}
	self.img_res = nil
	self.title_str = nil
	self.role_dis = nil
	self.role_model = nil
end

function TipShenBingView:LoadCallBack()
	self.str_list = {}
	for i = 1, 3 do
		self.str_list[i] = self:FindVariable("TopStr" .. i)
	end

	self.title_str = self:FindVariable("TitleStr")
	self.img_res = self:FindVariable("ImgRes")

	self.role_model = self:FindObj("RoleDis")
	self.display = RoleModel.New()
	self.display:SetDisplay(self.role_model.ui3d_display)

	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnPreview", BindTool.Bind(self.OnPreview, self))
end

function TipShenBingView:ShowIndexCallBack()
	self:Flush()
end

function TipShenBingView:CloseCallBack()
	self.show_seq = nil
end

function TipShenBingView:SetData(seq)
	self.show_seq = seq
	if not self:IsOpen() then
		self:Open()
	end
end

function TipShenBingView:OnFlush(param_t)
	if self.show_seq == nil then
		return
	end

	local data = ShenqiData.Instance:GetShenBingEffectCfg(self.show_seq)
	if data == nil or next(data) == nil then
		return
	end

	local str_tab = Language.Shenqi.ShenBingStr
	if self.str_list ~= nil then
		for i = 1, 3 do
			if data["str" .. i] ~= nil and self.str_list[i] ~= nil and str_tab[i] ~= nil then
				self.str_list[i]:SetValue(string.format(str_tab[i], data["str" .. i]))
			end
		end
	end

	if self.title_str ~= nil then
		self.title_str:SetValue(data.name or "")
	end

	if self.img_res ~= nil then
		local bundle, asset = ResPath.GetItemIcon(data.icon)
		self.img_res:SetAsset(bundle, asset)
	end

	if self.display ~= nil then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
		local role_job = job_cfgs[role_vo.prof]
		if role_job then
			local res_id = role_job["model" .. role_vo.sex]
			if res_id then
				self.display:SetRoleResid(res_id)
			end
		end
	end
end

function TipShenBingView:OnClickClose()
	self:Close()
end

function TipShenBingView:OnPreview()
end