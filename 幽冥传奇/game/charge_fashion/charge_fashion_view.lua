ChargeFashionView = ChargeFashionView or BaseClass(XuiBaseView)

function ChargeFashionView:__init()
	self.config_tab = {
		{"hero_gold_ui_cfg", 3, {0}},
	}
	self.texture_path_list = {"res/xui/hero_gold.png","res/xui/charge.png"}
	-- self.title_img_path = ResPath.GetHeroGold("hero_gold_bing_title")
	self:SetModal(true)
end

function ChargeFashionView:__delete()
end

function ChargeFashionView:ReleaseCallBack()
	if self.soul_cell  then
		for k,v in ipairs(self.soul_cell) do
			v:DeleteMe()
		end
		self.soul_cell = nil
	end
	if self.achieve_evt then
		GlobalEventSystem:UnBind(self.achieve_evt)
		self.achieve_evt = nil
	end
	if self.role_cap then
		self.role_cap:DeleteMe()
		self.role_cap = nil
	end
end

function ChargeFashionView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.AddClickEventListener(self.node_t_list.btn_getFashion.node, BindTool.Bind(self.ReciveView, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_close_window.node, BindTool.Bind1(self.OnClose, self), true)
		local temp_data = {}
		for k, v in ipairs(FashionRechargeConfig.awards) do
			if v.sex then
				if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) == v.sex then
					temp_data[#temp_data +1] = v
				end
			else
				temp_data[#temp_data +1] = v
			end
		end
		if not self.soul_cell then
			self.soul_cell = {}
			local ph,ph1,ph2 = self.ph_list["ph_title_cell"],self.ph_list["ph_title2_cell"],self.ph_list["ph_title3_cell"]
			for i,v in ipairs(temp_data) do
				local cell = BaseCell.New()
				if i == 1 then
					cell:SetPosition(ph.x+(i-1)*90, ph.y)				
					self.act_eff = RenderUnit.CreateEffect(7, self.node_t_list.layot_fashion_charge.node, 201, nil, nil,  ph.x + 43,  ph.y + 40)
				elseif i >= 2 and i <= 4 then
					cell:SetPosition(ph1.x+(i-1)*90-67, ph1.y)
					self.act_eff = RenderUnit.CreateEffect(920, self.node_t_list.layot_fashion_charge.node, 201, nil, nil,  ph1.x+(i-1)*90-67+43, ph1.y+39)	
					self.act_eff:setScale(1.1)			
				elseif i >= 5 and i <= 7 then
					cell:SetPosition(ph2.x+(i-4)*90-67, ph2.y)
					self.act_eff = RenderUnit.CreateEffect(920, self.node_t_list.layot_fashion_charge.node, 201, nil, nil,  ph2.x+(i-4)*90-67+43, ph2.y+39)	
					self.act_eff:setScale(1.1)
				end
			
				cell:GetView():setAnchorPoint(0, 0)
				self.node_t_list.layot_fashion_charge.node:addChild(cell:GetView(), 103)
				table.insert(self.soul_cell, cell)
				if v.type >0 then
					local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
					cell:SetData({item_id = virtual_item_id, num = v.count, is_bind = 0,strengthen_level= v.strong})
				else
					cell:SetData({item_id = v.id, num = v.count, is_bind = 0,strengthen_level= v.strong})
				end
			end
		end
		self.node_t_list.txt_num_log.node:setVisible(false)
		local cap_x, cap_y = self.node_t_list.txt_num_log.node:getPosition()
		self.role_cap = NumberBar.New()
		self.role_cap:SetRootPath(ResPath.GetMainui("num_"))
		self.role_cap:SetPosition(cap_x, cap_y)
		self.role_cap:SetSpace(-2)
		self.node_t_list.layot_fashion_charge.node:addChild(self.role_cap:GetView(), 300, 300)
		self.role_cap:SetNumber(0)

		self.achieve_evt = GlobalEventSystem:Bind(OtherEventType.RECHARGE_FASHION, BindTool.Bind(self.UpdateData, self))
		self:UpdateData()
	end
end

function ChargeFashionView:ReciveView()
	ChargeFashionCtrl.Instance:ReqFashionReq()
end
 
function ChargeFashionView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChargeFashionView:OnClose()
	self:Close()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function ChargeFashionView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ChargeFashionView:UpdateData()
	local num,award = ChargeFashionData.Instance:getChargeInfo()
	if FashionRechargeConfig.yb >= num then
		self.role_cap:SetNumber(FashionRechargeConfig.yb-num)
	end
	local activat = 0
	if num >=FashionRechargeConfig.yb and award ==0 then
		activat =1
	end
	XUI.SetLayoutImgsGrey(self.node_t_list.btn_getFashion.node, activat <= 0, true)
end

function ChargeFashionView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChargeFashionView:OnFlush(param_t, index)

end
