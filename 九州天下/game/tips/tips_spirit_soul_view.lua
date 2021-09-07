TipsSpiritSoulView = TipsSpiritSoulView or BaseClass(BaseView)

function TipsSpiritSoulView:__init()
	self.ui_config = {"uis/views/tips/spiritsoultips", "SpiritSoulTip"}
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
end

function TipsSpiritSoulView:OpenCallBack()
	self:Flush()
end

function TipsSpiritSoulView:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.cur_select_index = nil
	self.soul_item:CloseCallBack()
end

function TipsSpiritSoulView:CloseView()
	self:Close()
end

function TipsSpiritSoulView:OnClickPutInBag()
	if nil == self.data then return end

	if self.from_view == ForgeData.SOUL_FROM_VIEW.SOUL_POOL then
		ForgeCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.PUT_BAG, self.data.index)
	else
		local index = ForgeData.Instance:GetSlotSoulEmptyIndex(self.cur_select_index)
		if nil == index then
			TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.NoSlotCanTakeOn)
			return
		end
		ForgeCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.TAKEON, self.cur_select_index - 1, index - 1, self.data.index)
	end
	self:Close()
end

function TipsSpiritSoulView:OnClickSale()
	if nil == self.data then return end
	local ok_func = nil
	if self.from_view == ForgeData.SOUL_FROM_VIEW.SOUL_POOL then
		ok_func = function(data)
			ForgeCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.SINGLE_CONVERT_TO_EXP, data.index, 1)
			self:Close()
		end
	else
		ok_func = function(data)
			ForgeCtrl.Instance:SendSpiritSoulOperaReq(LIEMING_HUNSHOU_OPERA_TYPE.SINGLE_CONVERT_TO_EXP, data.index)
			self:Close()
		end
	end

	TipsCtrl.Instance:ShowCommonTip(ok_func, self.data, Language.JingLing.SingleSale , nil, nil, true, false, "singlesale")
end

function TipsSpiritSoulView:SetData(data, from_view, cur_index)
	self.data = data
	self.from_view = from_view
	self.cur_select_index = cur_index
end

function TipsSpiritSoulView:OnFlush()
	if self.data then
		local attr_cfg = ForgeData.Instance:GetSoulAttrCfg(self.data.id, self.data.level or 1)
		local exp_cfg = ForgeData.Instance:GetSoulAttrCfg(self.data.id, self.data.level or 1, true)
		local lieming_cfg = ConfigManager.Instance:GetAutoConfig("lieming_auto")
		local hunshou_cfg = lieming_cfg.hunshou
		local other_cfg = lieming_cfg.other
		local soul_cfg = hunshou_cfg[self.data.id]
		if self.data.id == GameEnum.HUNSHOU_EXP_ID then
			self.soul_item:SetData(self.data.item_data)
			self.sale_exp:SetValue(other_cfg[1].exp_hunshou_exp_val)
			local str = "<color=%s>"..other_cfg[1].exp_hunshou_name.."</color>"
			self.soul_name:SetValue(string.format(str, SOUL_NAME_COLOR[1]))
			self.soul_level:SetValue(0)
		end
		if soul_cfg and attr_cfg then
			self.attr_name:SetValue(Language.Common.AttrNameNoUnderline[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]])
			self.attr_value:SetValue(attr_cfg[SOUL_ATTR_NAME_LIST[soul_cfg.hunshou_type]])
			self.sale_exp:SetValue(exp_cfg * other_cfg[1].hunshou_exp_discount_rate * 0.01)
			self.soul_item:SetData(self.data.item_data)
			local str = "<color=%s>"..soul_cfg.name.."</color>"
			self.soul_name:SetValue(string.format(str, SOUL_NAME_COLOR[soul_cfg.hunshou_color]))
			self.soul_level:SetValue(self.data.level or 1)
		end

		if self.from_view == ForgeData.SOUL_FROM_VIEW.SOUL_POOL and nil == soul_cfg then
			self.show_put_or_takeOn_btn:SetValue(false)
		else
			self.show_put_or_takeOn_btn:SetValue(true)
		end
	end
	if self.from_view == ForgeData.SOUL_FROM_VIEW.SOUL_POOL then
		self.button_text:SetValue(Language.Common.PutBag)
	else
		self.button_text:SetValue(Language.Common.Equip)
	end
end