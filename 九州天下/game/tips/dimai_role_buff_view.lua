TipsDiMaiRoleBuffView = TipsDiMaiRoleBuffView or BaseClass(BaseView)

function TipsDiMaiRoleBuffView:__init()
	self.ui_config = {"uis/views/tips/dimaitips", "RoleBuffTips"}
	self:SetMaskBg(true)
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsDiMaiRoleBuffView:__delete()
end

function TipsDiMaiRoleBuffView:ReleaseCallBack()
	self.view_data = nil
	self.open_type = nil
	self.buff_icon = nil
	self.map_name = nil
	self.attr_obj = nil
	self.name = nil
	self.capability = nil
end

function TipsDiMaiRoleBuffView:LoadCallBack()
	self.buff_icon = self:FindVariable("BuffIcon")
	self.map_name = self:FindVariable("MapName")
	self.name = self:FindVariable("Name")
	self.capability = self:FindVariable("Capability")

	self.attr_obj = self:FindObj("AttrObj")
	
	self:ListenEvent("OnClickClose",BindTool.Bind(self.OnClickClose, self))
end

function TipsDiMaiRoleBuffView:OnFlush()
	if self.view_data then
		local name_str = ""
		local bundle, asset = nil, nil
		local buff_cfg = nil

		if self.open_type == DiMaiData.DiMai_Buff_Type.Role then
			name_str = Language.QiangDiMai.RoleBuffName
			bundle, asset =	ResPath.GetDiMaiBuffIcon(self.view_data.layer)
			buff_cfg = DiMaiData.Instance:GetDiMaiRoleBuffCfg(self.view_data.layer, self.view_data.point)
		else
			name_str = Language.QiangDiMai.CampBuffName
			bundle, asset =	ResPath.GetDiMaiCampBuffIcon()
			buff_cfg = DiMaiData.Instance:GetDiMaiCampBuffCfg(self.view_data.layer, self.view_data.point)
		end

		self.name:SetValue(name_str)
		self.buff_icon:SetAsset(bundle, asset)

		if buff_cfg then
			CommonDataManager.SetRoleAttr(self.attr_obj, buff_cfg, nil)

			local cap = CommonDataManager.GetCapability(buff_cfg)
			self.capability:SetValue(cap)
		end

		local info_cfg = DiMaiData.Instance:GetDiMaiInfoCfg(self.view_data.layer, self.view_data.point)
		if info_cfg then
			self.map_name:SetValue(info_cfg and info_cfg.dimai_name)
		end
	end
end

function TipsDiMaiRoleBuffView:SetData(data, open_type)
	self.view_data = data
	self.open_type = open_type or DiMaiData.DiMai_Buff_Type.Role
	self:Flush()
end

function TipsDiMaiRoleBuffView:OnClickClose()
	self:Close()
end
