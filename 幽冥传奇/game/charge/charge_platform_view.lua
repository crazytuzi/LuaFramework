ChargePlatFormView = ChargePlatFormView or BaseClass(XuiBaseView)

function ChargePlatFormView:__init()
	-- self.view_name = ViewName.ChargePlatForm
	self.texture_path_list[1] = "res/xui/chongzhi.png"
	self.config_tab = {
						{"recharge_ui_cfg", 1, {0}},
						{"recharge_ui_cfg", 2, {0}},
					}
	self.desc_data = nil 

	self.grid_scroll_list = nil
end

function ChargePlatFormView:__delete()
	
end

function ChargePlatFormView:ReleaseCallBack()
	if self.grid_scroll_list then
		self.grid_scroll_list:DeleteMe()
		self.grid_scroll_list = nil
	end
	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil 
	end
end


function ChargePlatFormView:OnFlush(paramt,index)
	self:FlushMoney()
end

function ChargePlatFormView:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		if nil == self.grid_scroll_list then
			self.grid_scroll_list = GridScroll.New()
			local ph = self.ph_list.ph_items_list
			local grid_node = self.grid_scroll_list:Create(ph.x,ph.y,ph.w,ph.h,4,self.ph_list.ph_item_info_panel.h + 5,RechargeItemRender,ScrollDir.Vertical,true,self.ph_list.ph_item_info_panel)
			self.node_t_list.editContainer.node:addChild(grid_node, 100)
			self.grid_scroll_list:SetDataList(ChargePlatFormData.Instance:GetRechargeCfg())
			self.grid_scroll_list:JumpToTop()
			--self.node_t_list.editContainer.node:addChild(self.grid_scroll_list:GetView(), 100)
		end
		XUI.AddClickEventListener(self.node_t_list.btn_end.node, BindTool.Bind1(self.EndRechgeData, self))
		XUI.AddClickEventListener(self.node_t_list.btn_chaxun.node, BindTool.Bind1(self.RxtraceYuanbao, self))
		self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)
		RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
	end
	
end

function ChargePlatFormView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ChargePlatFormView:OpenCallBack()
	
end

function ChargePlatFormView:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_GOLD then
		self:Flush()
	end
end

function ChargePlatFormView:FlushMoney()
	local gold = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD))
	self.node_t_list.ybText.node:setString(gold)
	
end


function ChargePlatFormView:EndRechgeData()
	self:Close()
end

function ChargePlatFormView:RxtraceYuanbao()
	ChargePlatFormCtrl.Instance:CanExtractReq()
end



--------------RechargeItemRender--------------
RechargeItemRender = RechargeItemRender or BaseClass(BaseRender)
function RechargeItemRender:__init()
	self.item_cell = nil
end

function RechargeItemRender:__delete()
	if self.charge_need_yb then
		self.charge_need_yb:DeleteMe()
		self.charge_need_yb = nil
	end
end

function RechargeItemRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end

	self.yuanbao_bg = self.node_tree.yuanbao_bg.node
	self.txt_buy_cost = self.node_tree.txt_buy_cost.node
	self.txt_rebate = self.node_tree.layout_change_rebate.txt_rabate2.node
	self.txt_rebate2 = self.node_tree.layout_change_rebate.txt_rabate.node

	XUI.AddClickEventListener(self.node_tree.btn_buy.node, BindTool.Bind1(self.OnClickBuyBtn, self))
	self:CreateNumBar()
end


function RechargeItemRender:OnFlush()
	if nil == self.data then
		return
	end
	
	local rebate_data = ChargePlatFormData.Instance:GetChargeRebateCfg(self.data.id)
	self.txt_buy_cost:setString("¥ " .. self.data.rmb)
	self.yuanbao_bg:loadTexture(ResPath.GetChongzhi("yuanbao_" .. self.data.icon))
	self.charge_need_yb:SetNumber(self.data.yb)

	local reward_times = ChargePlatFormData.Instance:GetRebateNum(self.data.id)
	local open_day = OtherData.Instance:GetOpenServerDays() 		-- 开服天数
	local rebate_money = string.format(Language.Fuben.Buy_Gold, rebate_data.addyuanbao)
	local rebate_open_days = string.format(Language.Fuben.Buy_Gold, rebate_data.otheryuanbao)

	if  reward_times >= rebate_data.count then
		self.txt_rebate:setString(rebate_open_days)
		self.txt_rebate:setColor(COLOR3B.GREEN)
		self.txt_rebate2:setString(Language.Charge.ChaegeConti)
		self.txt_rebate2:setColor(COLOR3B.GREEN)
	else
		self.txt_rebate2:setString(Language.Charge.ChaegeRebate)
		self.txt_rebate:setString(rebate_money)
		self.txt_rebate:setColor(Str2C3b("ffee35"))
		self.txt_rebate2:setColor(Str2C3b("ffee35"))
	end
	
end

function RechargeItemRender:CreateSelectEffect()
	if nil == self.node_tree.img9_bg then
		self.cache_select = true
		return
	end
	local size = self.node_tree.img9_bg.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_109"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.node_tree.img9_bg.node:addChild(self.select_effect, 999)
end

function RechargeItemRender:CreateNumBar()
	local ph = self.ph_list.img_yb
	self.charge_need_yb = NumberBar.New()
	self.charge_need_yb:SetRootPath(ResPath.GetCommon("num_100_"))
	self.charge_need_yb:SetPosition(ph.x, ph.y)
	self.charge_need_yb:SetSpace(0)
	self.view:addChild(self.charge_need_yb:GetView(), 90)
	self.charge_need_yb:SetNumber(0)
	self.charge_need_yb:SetGravity(NumberBarGravity.Center)
end


function RechargeItemRender:OnClickBuyBtn()
	local role_id = GameVoManager.Instance:GetUserVo():GetNowRole()
	local role_name = GameVoManager.Instance:GetMainRoleVo().name
	local server_id = GameVoManager.Instance:GetUserVo().real_server_id
	if self.data.rmb and self.data.rmb ~= 0 and role_id and role_name and server_id then
		-- Log("Recharge:", role_name, role_id, server_id, self.data.rmb)
		AgentAdapter:Pay(role_id, role_name, self.data.rmb, server_id, callback)
	else
		SysMsgCtrl.Instance:ErrorRemind("充值操作失败！")
	end
end