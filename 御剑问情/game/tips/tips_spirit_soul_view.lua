TipsSpiritSoulView = TipsSpiritSoulView or BaseClass(BaseView)

function TipsSpiritSoulView:__init()
	self.ui_config = {"uis/views/tips/spiritsoultips_prefab", "SpiritSoulTip"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function TipsSpiritSoulView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("PutInBag", BindTool.Bind(self.OnClickPutInBag, self))
	self:ListenEvent("Sale", BindTool.Bind(self.OnClickSale, self))

	self.attr_name = self:FindVariable("AttrName")
	self.attr_value = self:FindVariable("AttrValue")
	self.sale_exp = self:FindVariable("SaleExp")
	self.soul_name = self:FindVariable("SoulName")
	self.soul_level = self:FindVariable("SoulLevel")

	self.show_put_or_takeOn_btn = self:FindVariable("ShowPutOrTakeOnBtn")
	self.button_text = self:FindVariable("PutOrTakeOnBtnText")
	self.special_attr_add_per = self:FindVariable("SpecialAttrAddPer")
	self.show_special_attr_add_per = self:FindVariable("ShowSpecialAttrAddPer")
	
	self.soul_item = SpiritSoulItem.New(self:FindObj("SoulItem"))
end

function TipsSpiritSoulView:ReleaseCallBack()
	if self.soul_item then
		self.soul_item:DeleteMe()
		self.soul_item = nil
	end

	-- 清理变量
	self.button_text = nil
	self.show_put_or_takeOn_btn = nil
	self.soul_level = nil
	self.soul_name = nil
	self.sale_exp = nil
	self.attr_value = nil
	self.attr_name = nil
	self.special_attr_add_per = nil
	self.show_special_attr_add_per = nil
end

function TipsSpiritSoulView:OpenCallBack()
	self:Flush()
end

function TipsSpiritSoulView:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.soul_item:CloseCallBack()
end

function TipsSpiritSoulView:CloseView()
	self:Close()
end

function TipsSpiritSoulView:OnClickPutInBag()
	if nil == self.data then return end

	if self.from_view == SOUL_FROM_VIEW.SOUL_POOL then
		SpiritCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.PUT_BAG, self.data.index)
	else
		local index = SpiritData.Instance:GetSlotSoulEmptyIndex(self.data.id)
		if index == -1 then
			TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.NoSlotCanTakeOn)
			return
		end
		SpiritCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.TAKEON, index, self.data.index)
	end
	self:Close()
end

function TipsSpiritSoulView:OnClickSale()
	if nil == self.data then return end
	local ok_func = nil
	if self.from_view == SOUL_FROM_VIEW.SOUL_POOL then
		ok_func = function(data)
			SpiritCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.SINGLE_CONVERT_TO_EXP, data.index, 1)
			self:Close()
		end
	else
		ok_func = function(data)
			SpiritCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.SINGLE_CONVERT_TO_EXP, data.index)
			self:Close()
		end
	end

	TipsCtrl.Instance:ShowCommonTip(ok_func, self.data, Language.JingLing.SingleSale , nil, nil, true, false, "singlesale")
end

function TipsSpiritSoulView:SetData(data, from_view)
	self.data = data
	self.from_view = from_view
end

function TipsSpiritSoulView:OnFlush()
	local is_show = false
	if self.data then
		local attr_cfg = SpiritData.Instance:GetSoulAttrCfg(self.data.id, self.data.level or 1)
		local exp_cfg = SpiritData.Instance:GetSoulAttrCfg(self.data.id, self.data.level or 1, true)
		local lieming_cfg = ConfigManager.Instance:GetAutoConfig("lieming_auto")
		local hunshou_cfg = lieming_cfg.hunshou
		local other_cfg = lieming_cfg.other
		local soul_cfg = hunshou_cfg[self.data.id]
		
		if self.data.id == GameEnum.HUNSHOU_EXP_ID then
			self.soul_item:SetData(self.data.item_data)
			self.sale_exp:SetValue(other_cfg[1].exp_hunshou_exp_val)
			local str = "<color=%s>"..other_cfg[1].exp_hunshou_name.."</color>"
			self.soul_name:SetValue(string.format(str, SPIRIT_SOUL_COLOR[11]))
			self.soul_level:SetValue(0)
		end
		if soul_cfg and attr_cfg then
			self.attr_name:SetValue(Language.Common.AttrNameNoUnderline[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]])
			self.attr_value:SetValue(attr_cfg[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]])
			self.sale_exp:SetValue(exp_cfg * other_cfg[1].hunshou_exp_discount_rate * 0.01)
			self.soul_item:SetData(self.data.item_data)
			local str = "<color=%s>"..soul_cfg.name.."</color>"
			local color = soul_cfg.hunshou_color == 1 and 11 or soul_cfg.hunshou_color
			self.soul_name:SetValue(string.format(str, SPIRIT_SOUL_COLOR[color]))
			self.soul_level:SetValue(self.data.level or 1)
			
			local is_pink = SpiritData.Instance:GetCurSlotSouIsPink(self.data.id)
			if is_pink then
				self.special_attr_add_per:SetValue(attr_cfg.add_base_attr_per / 100)
				is_show = true
			end
		end

		if self.from_view == SOUL_FROM_VIEW.SOUL_POOL and nil == soul_cfg then
			self.show_put_or_takeOn_btn:SetValue(false)
		else
			self.show_put_or_takeOn_btn:SetValue(true)
		end
	end
	if self.from_view == SOUL_FROM_VIEW.SOUL_POOL then
		self.button_text:SetValue(Language.Common.PutBag)
	else
		self.button_text:SetValue(Language.Common.Equip)
	end
	self.show_special_attr_add_per:SetValue(is_show)
end