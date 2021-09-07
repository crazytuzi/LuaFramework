TipShenQiView = TipShenQiView or BaseClass(BaseView)

function TipShenQiView:__init()
	self.ui_config = {"uis/views/shenqiview", "TipShenBingView"}
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
end

function TipShenQiView:__delete()
end

function TipShenQiView:ReleaseCallBack()
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

function TipShenQiView:LoadCallBack()
	self.str_list = {}
	for i = 1, 3 do
		self.str_list[i] = self:FindVariable("TopStr" .. i)
	end

	self.title_str = self:FindVariable("TitleStr")
	self.img_res = self:FindVariable("ImgRes")

	self.role_model = self:FindObj("RoleDis")

	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnPreview", BindTool.Bind(self.OnPreview, self))
end

function TipShenQiView:ShowIndexCallBack()
	self:Flush()
end

function TipShenQiView:CloseCallBack()
	self.show_type = nil
	self.show_seq = nil
	if self.display ~= nil then
		self.display:RemoveHead()

		for i = 1, 6 do
			if self.display.draw_obj ~= nil then
				self.display.draw_obj:GetPart(SceneObjPart.Main):SetLayer(8 + i, 0)
			end
		end
	end
end

function TipShenQiView:SetData(show_type, seq)
	self.show_type = show_type
	self.show_seq = seq
	if not self:IsOpen() then
		self:Open()
	end
end

function TipShenQiView:OnFlush(param_t)
	if self.show_seq == nil or self.show_type == nil then
		return
	end

	local data = ShenqiData.Instance:GetShenQiEffectCfg(self.show_type, self.show_seq)
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

	function call() 
		if self.show_type == nil or self.show_seq == nil then
			return
		end

		if self.show_type == SHENQI_TIP_TYPE.SHENBING then
			local head_id = ShenqiData.Instance:GetHeadResId(self.show_seq)
			if head_id then
				local bundle, name = ResPath.GetHeadModel(head_id)
				self.display:SetHeadRes(bundle, name)
			end
		else
			if self.display ~= nil and self.display.draw_obj ~= nil then
				local show_seq = self.show_seq
				if self.show_seq >= 4 then
					show_seq = self.show_seq + 1
				end
				self.display.draw_obj:GetPart(SceneObjPart.Main):SetLayer(8 + show_seq, 1)
			end
		end
	end

	if self.display == nil then
		self.display = RoleModel.New()
		self.display:SetDisplay(self.role_model.ui3d_display)

		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		local job_cfgs = ConfigManager.Instance:GetAutoConfig("rolezhuansheng_auto").job
		local role_job = job_cfgs[role_vo.prof]
		if role_job then
			local res_id = role_job["model" .. role_vo.sex]
			if res_id then
				self.display:SetRoleResid(res_id, call)
			end
		end
	else
		call()
	end
end

function TipShenQiView:OnClickClose()
	self:Close()
end

function TipShenQiView:OnPreview()
	if self.display ~= nil then
		--if self.display.draw_obj then
			local head_id = ShenqiData.Instance:GetHeadResId(self.show_seq)
			if head_id then
				local bundle, name = ResPath.GetHeadModel(head_id)
				self.display:SetHeadRes(bundle, name)
				--self.display.draw_obj:GetPart(SceneObjPart.Head):ChangeModel(bundle, name)
			end
		--end
	end
end