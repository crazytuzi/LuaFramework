TipsSpiritDressSoulView = TipsSpiritDressSoulView or BaseClass(BaseView)

function TipsSpiritDressSoulView:__init(instance)
	self.ui_config = {"uis/views/tips/spiritsoultips_prefab", "SpiritDressSoulTip"}
	self.view_layer = UiLayer.Pop
	self.callback = nil
	self.is_first_open = false
	self.play_audio = true
	self.can_level_up = false
end

function TipsSpiritDressSoulView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("OnClickTakeOff", BindTool.Bind(self.OnClickTakeOff, self))
	self:ListenEvent("OnClickUpLevel", BindTool.Bind(self.OnClickUpLevel, self))

	self.attr_name = self:FindVariable("AttrName")
	self.cur_attr_value = self:FindVariable("CurAttrValue")
	self.next_attr_value = self:FindVariable("NextAttrValue")
	self.soul_name = self:FindVariable("Name")
	self.soul_level = self:FindVariable("SoulLevel")
	self.cur_exp = self:FindVariable("CurExp")
	self.max_exp = self:FindVariable("MaxExp")
	self.exp_radio = self:FindVariable("ExpRadio")
	self.storage_exp = self:FindVariable("StorageExp")
	self.uplevel_need_exp = self:FindVariable("UpLevelNeedExp")
	self.show_next_attr = self:FindVariable("ShowNextAttrValue")
	self.show_had_max_level = self:FindVariable("ShowHadMaxLevel")
	self.show_red = self:FindVariable("ShowRed")
	self.cur_add_per = self:FindVariable("CurAddPer")
	self.next_add_per = self:FindVariable("NextAddPer")
	self.is_pink = self:FindVariable("IsPink")

	self.up_level_btn = self:FindObj("UpLevelButton")
end

function TipsSpiritDressSoulView:ReleaseCallBack()
	if self.soul_item then
		self.soul_item:DeleteMe()
		self.soul_item = nil
	end
	self.is_first_open = nil

	-- 清理变量
	self.attr_name = nil
	self.cur_attr_value = nil
	self.next_attr_value = nil
	self.soul_name = nil
	self.soul_level = nil
	self.cur_exp = nil
	self.max_exp = nil
	self.exp_radio = nil
	self.storage_exp = nil
	self.uplevel_need_exp = nil
	self.show_next_attr = nil
	self.show_had_max_level = nil
	self.up_level_btn = nil
	self.show_red = nil
	self.cur_add_per = nil
	self.next_add_per = nil
	self.is_pink = nil
end

function TipsSpiritDressSoulView:OpenCallBack()
	self.is_first_open = true
	self:Flush()
end

function TipsSpiritDressSoulView:CloseCallBack()
	self.data = nil
	if self.callback then
		self.callback()
	end
end

function TipsSpiritDressSoulView:CloseView()
	self:Close()
end

function TipsSpiritDressSoulView:OnClickTakeOff()
	if nil == self.data then return end
	SpiritCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.TAKEOFF, self.data.index)
	self:Close()
end

function TipsSpiritDressSoulView:OnClickUpLevel()
	if nil == self.data then return end
	SpiritCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.FUHUN_ADD_EXP, self.data.index, self.data.level + 1)
	if self.can_level_up then
		AudioService.Instance:PlayAdvancedAudio()
	end
end

function TipsSpiritDressSoulView:SetData(data)
	self.data = data
end

function TipsSpiritDressSoulView:SetCallback(callback)
	self.callback = callback
end

function TipsSpiritDressSoulView:OnFlush()
	if self.data and next(self.data) then
		local attr_cfg = SpiritData.Instance:GetSoulAttrCfg(self.data.id, self.data.level)
		local next_attr_cfg = SpiritData.Instance:GetSoulAttrCfg(self.data.id, self.data.level + 1)
		local soul_cfg = SpiritData.Instance:GetSpiritSoulCfg(self.data.id)
		local storage_exp = SpiritData.Instance:GetSpiritSoulBagInfo().hunshou_exp or 0
		if attr_cfg and soul_cfg then
			self.cur_attr_value:SetValue(attr_cfg[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]])
			self.attr_name:SetValue(Language.Common.AttrNameNoUnderline[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]])
			local color = soul_cfg.hunshou_color == 1 and 11 or soul_cfg.hunshou_color
			local str = "<color="..SPIRIT_SOUL_COLOR[color]..">"..soul_cfg.name.."</color>"
			self.soul_name:SetValue(str)
			self.soul_level:SetValue(self.data.level)
			self.cur_exp:SetValue(self.data.exp)
			self.max_exp:SetValue(attr_cfg.exp)
			self.show_red:SetValue(storage_exp >= tonumber(attr_cfg.exp - self.data.exp))
			if storage_exp < attr_cfg.exp - self.data.exp then
				storage_exp = string.format(Language.Mount.ShowRedNum, storage_exp)
				self.can_level_up = false
			else
				self.can_level_up = true
			end
			self.storage_exp:SetValue(storage_exp)
			self.uplevel_need_exp:SetValue(attr_cfg.exp - self.data.exp)
			local is_pink = SpiritData.Instance:GetCurSlotSouIsPink(self.data.id)
			self.is_pink:SetValue(is_pink)
			if is_pink then
				self.cur_add_per:SetValue(attr_cfg.add_base_attr_per / 100)
			end
		end
		self.show_next_attr:SetValue(nil ~= next_attr_cfg)
		if next_attr_cfg then
			self.next_attr_value:SetValue(next_attr_cfg[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]])
			self.up_level_btn.button.interactable = true
			self.show_had_max_level:SetValue(false)
			self.next_add_per:SetValue(next_attr_cfg.add_base_attr_per / 100)
			if self.is_first_open then
				self.exp_radio:InitValue(self.data.exp / attr_cfg.exp)
			else
				self.exp_radio:SetValue(self.data.exp / attr_cfg.exp)
			end
		else
			self.show_had_max_level:SetValue(true)
			self.up_level_btn.button.interactable = false
			self.exp_radio:InitValue(1)
		end
	end
	self.is_first_open = false
end