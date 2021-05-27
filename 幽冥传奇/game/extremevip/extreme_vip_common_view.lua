ExtremeVipCommonView = ExtremeVipCommonView or BaseClass(XuiBaseView)

function ExtremeVipCommonView:__init()
	self.config_tab = {
						{"extremevip_ui_cfg", 3, {0}}
					}

	self.index = 1
	self.input_1 = ""
	self.input_2 = ""
	self.input_3 = ""
	self.input_4 = ""
	self.lengh_1 = 0
	self.lengh_2 = 0
end

function ExtremeVipCommonView:__delete()
	
end

function ExtremeVipCommonView:ReleaseCallBack()
	if nil ~= self.input_num_view then
		self.input_num_view:DeleteMe()
		self.input_num_view = nil
	end
end

function ExtremeVipCommonView:SetDescData(data)
	self:Flush()
end

function ExtremeVipCommonView:OnFlush(paramt,index)

end

function ExtremeVipCommonView:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		self.input_num_view = NumKeypad.New()
		-- self.input_num_view:SetMaxValue(9999999999999999)
		self.input_num_view:SetOkCallBack(BindTool.Bind(self.OnOKCallBack, self))

		XUI.AddClickEventListener(self.node_t_list.btn_input.node, BindTool.Bind(self.OnOpenPopNum, self, 1))
		XUI.AddClickEventListener(self.node_t_list.btn_output.node, BindTool.Bind(self.OnOpenPopNum, self, 2))
		XUI.AddClickEventListener(self.node_t_list.btn_input_1.node, BindTool.Bind(self.OnOpenPopNum, self, 3))
		XUI.AddClickEventListener(self.node_t_list.btn_output_1.node, BindTool.Bind(self.OnOpenPopNum, self, 4))
		XUI.AddClickEventListener(self.node_t_list.btn_submit.node, BindTool.Bind(self.OnSubmit, self))
	end
end

function ExtremeVipCommonView:OnOpenPopNum(btn_id)
	self.index = btn_id
	if nil ~= self.input_num_view then
		self.input_num_view:Open()
		-- self.input_num_view:SetText(self.donate_times)
		-- local max_val = self.my_data.my_time - self.my_data.time
		-- self.input_num_view:SetMaxValue(max_val)
	end
	if self.index == 1 or self.index == 2 then
		self.input_num_view:SetMaxValue(9999999999999999)
	elseif self.index == 3 or self.index == 4 then
		self.input_num_view:SetMaxValue(99999999999)
	end
end

function ExtremeVipCommonView:OnOKCallBack(num)
	if self.index == 1 then
		self.input_1 = num
	elseif self.index == 2 then
		self.input_2 = num
	elseif self.index == 3 then
		self.lengh_1 = string.len(num)
		if self.lengh_1 ~= 11 then
			SysMsgCtrl.Instance:FloatingTopRightText(Language.SuperVip.BadTel)
		end
		self.input_3 = num
	elseif self.index == 4 then
		self.lengh_2 = string.len(num)
		if self.lengh_2 ~= 11 then
			SysMsgCtrl.Instance:FloatingTopRightText(Language.SuperVip.BadTel)
		end
		self.input_4 = num
	end
	self:FlushText()
end

function ExtremeVipCommonView:OnSubmit()
	if self.input_1 == nil and self.input_2 == nil then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.SuperVip.Nothing)
		if self.input_3 == nil and self.input_4 == nil then
			SysMsgCtrl.Instance:FloatingTopRightText(Language.SuperVip.NothingTel)
		end
	elseif self.input_1 == self.input_2 and self.input_3 == self.input_4 and self.lengh_1 == 11 and self.lengh_2 == 11 then
		AgentMs:ZZVIPRequest(0, self.input_1, self.input_3)
		local show = ExtremeVipData.Instance:IsExtremeVipIconShow()
		if show == true then
			self:Close()
			-- ViewManager.Instance:Close(ViewName.ExtremeVip)
		end
	elseif self.lengh_1 ~= 11 or self.lengh_2 ~= 11 then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.SuperVip.BadTel)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.SuperVip.Inconsistent)
	end
end

function ExtremeVipCommonView:FlushText()
	if self.input_1 ~= nil and self.input_1 ~= "" then
		self.node_t_list.txt_shuru_qq.node:setString(self.input_1)
	end
	if self.input_2 ~= nil and self.input_2 ~= "" then
		self.node_t_list.txt_shuchu_1.node:setString(self.input_2)
	end
	if self.input_3 ~= nil and self.input_3 ~= "" then
		self.node_t_list.txt_shuru_tel.node:setString(self.input_3)
	end
	if self.input_4 ~= nil and self.input_4 ~= "" then
		self.node_t_list.txt_shuchu_2.node:setString(self.input_4)
	end
end

function ExtremeVipCommonView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ExtremeVipCommonView:CloseCallBack()
	self.input_1 = nil
	self.input_2 = nil
	self.input_3 = nil
	self.input_4 = nil
	self.node_t_list.txt_shuru_qq.node:setString(Language.SuperVip.Input)
	self.node_t_list.txt_shuchu_1.node:setString(Language.SuperVip.Output)
	self.node_t_list.txt_shuru_tel.node:setString(Language.SuperVip.Input_1)
	self.node_t_list.txt_shuchu_2.node:setString(Language.SuperVip.Output)
end



