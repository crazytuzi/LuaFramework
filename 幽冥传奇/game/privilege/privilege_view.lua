--特权界面
PrivilegeView = PrivilegeView or BaseClass(XuiBaseView)

function PrivilegeView:__init()
	self.texture_path_list[1] = 'res/xui/privilege.png'
	self.is_async_load = false	
	self.is_modal = true
	self.config_tab = {
		{"common_ui_cfg", 5, {0}},
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
		{"privilege_ui_cfg", 3, {0}},
	}
	self.select_index = 1
	self.alert_privilege = nil
	self.title_img_path = ResPath.GetPrivilege("btn_privilege_txt")
end

function PrivilegeView:__delete()
	
end

function PrivilegeView:ReleaseCallBack()
	if self.privilege_show_list then
		self.privilege_show_list:DeleteMe()
		self.privilege_show_list = nil 
	end

	if self.role_attr_change_fun then
		RoleData.Instance:UnNotifyAttrChange(self.role_attr_change_fun)
		self.role_attr_change_fun = nil 
	end

	if nil ~= self.alert_privilege then
		self.alert_privilege:DeleteMe()
  		self.alert_privilege = nil
	end	

	if self.draw_node then
		self.draw_node:clear()
		self.draw_node:removeFromParent()
		self.draw_node = nil
	end
	if self.discount_remind_eff then
		self.discount_remind_eff:removeFromParent()
		self.discount_remind_eff = nil
	end
end

function PrivilegeView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:PrivilegeList()
		for i=1,3 do
			XUI.AddClickEventListener(self.node_t_list["img_"..i].node, BindTool.Bind(self.OnBindGoldCTab, self,i), true)
		end
		XUI.AddClickEventListener(self.node_t_list.btn_open.node, BindTool.Bind1(self.OpenChest, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_discount.node, BindTool.Bind1(self.OpenPrivilegeOrDiscount, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_receive.node, BindTool.Bind1(self.RecevieAward, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_openpri.node, BindTool.Bind1(self.OpenPrivilegeOrDiscount, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_superbuy.node, BindTool.Bind1(self.SuperbuyBtn, self), true)
		XUI.AddClickEventListener(self.node_t_list.btn_receive_chest.node, BindTool.Bind1(self.OpenChest, self), true)
		self:CreatDrawNode()
		self.discount_remind_eff = RenderUnit.CreateEffect(11, self.node_t_list.btn_discount.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
		self.role_attr_change_fun = BindTool.Bind1(self.FlushAttrValue, self)
		RoleData.Instance:NotifyAttrChange(self.role_attr_change_fun)
		self.alert_privilege = Alert.New()
	end
	
end

function PrivilegeView:OpenCallBack()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function PrivilegeView:ShowIndexCallBack(index)
	self:Flush(index)
end

function PrivilegeView:OnBindGoldCTab(type)
	if type ~= 1 then
		if type == 2 then
			if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SUPER_VIP) <=0 then
				ViewManager.Instance:Open(ViewName.SuperMe)
			else
				ViewManager.Instance:Open(ViewName.SuperAfter)
			end
		elseif type == 3 then
			ViewManager.Instance:Open(ViewName.Vip)
		end
		self:Close()
	end
end

function PrivilegeView:CloseCallBack(is_all)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end


function PrivilegeView:OnFlush(param_t, index)
	local cur_data = PrivilegeData.Instance:GetData()
	self.privilege_show_list:SetDataList(cur_data)
	self:FlushText()
end

function PrivilegeView:FlushAttrValue(key, value)	
	if key == OBJ_ATTR.ACTOR_VIP_FLAG or 
		key == OBJ_ATTR.ACTOR_VIP_EXPIRE_TIME or
		 key == OBJ_ATTR.ACTOR_AVOIDINJURY or 
		 key == OBJ_ATTR.ACTOR_MAGIC_EQUIPID or 
		 key == OBJ_ATTR.ACTOR_MAGIC_EQUIPEXP then
		 self:Flush()
		 FuMoData.Instance:SetFumoFinishMaxCount()
	end
end


function PrivilegeView:PrivilegeList()
	if nil == self.privilege_show_list then
		self.privilege_show_list = ListView.New()
		local ph = self.ph_list.ph_privilege_list
		self.privilege_show_list:Create(ph.x+157, ph.y+242,ph.w,ph.h, nil, PrivilegeViewAttrRender, nil, nil,self.ph_list.ph_list_item)
		self.privilege_show_list:SetItemsInterval(6)
		self.node_t_list.layout_1.node:addChild(self.privilege_show_list:GetView(), 100)
		self.privilege_show_list:SetSelectCallBack(BindTool.Bind1(self.ShowDescCallBack, self))
		self.privilege_show_list:SetJumpDirection(ListView.Top)
		self.privilege_show_list:SetMargin(3)
	end
	
end

function PrivilegeView:ShowDescCallBack(item)
	self.select_index = item:GetIndex()
	self:FlushText()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function PrivilegeView:CreatDrawNode()

	self.draw_node = cc.DrawNode:create()
	self.node_t_list.layout_1.node:addChild(self.draw_node,999)
	self.draw_node:clear()
	local x, y = self.node_t_list.txt_money_4.node:getPositionX(), self.node_t_list.txt_money_4.node:getPositionY()
	local pos1 = cc.p(x - 8, y - 12)
	local pos2 = cc.p(pos1.x + 160 , pos1.y )
	self.draw_node:drawSegment(pos1, pos2, 0.8, cc.c4f(1, 0, 0, 1))
end

function PrivilegeView:FlushText()
	local true_data = PrivilegeData.Instance:GetData()
	local superbuy = PrivilegeData.Instance:GetSuperBuy()
	local money_all = PrivilegeData.Instance:GetMoneycfg()
	local is_show = PrivilegeData.IsShowRechargeEffect(self.select_index)
	self.discount_remind_eff:setVisible(is_show)
	local data = true_data[self.select_index]
	local desc= data.vipDesc
	self.node_t_list.btn_receive_chest.node:loadTexture(ResPath.GetPrivilege("chest_open_".. self.select_index))
	self.node_t_list.btn_open.node:loadTexture(ResPath.GetPrivilege("chest_close_".. self.select_index))
	RichTextUtil.ParseRichText(self.node_t_list.rich_typeinfo.node, desc, 21, COLOR3B.WHITE, x, y, w, h, ignored_link, text_attr)
	XUI.SetRichTextVerticalSpace(self.node_t_list.rich_typeinfo.node, 20)
	self.node_t_list.txt_money_now.node:setString(superbuy)
	self.node_t_list.txt_money_before.node:setString(money_all)
	local state = data.state
	if state == 0 then
		self.node_t_list.btn_openpri.node:setVisible(true)
		self.node_t_list.btn_receive.node:setVisible(false)
		self.node_t_list.btn_receive_chest.node:setVisible(false)
		self.node_t_list.btn_open.node:setVisible(true) 
		self.node_t_list.btn_discount.node:setVisible(false)
		self.node_t_list.remind_name_1.node:setVisible(false)
	else
		local fectch_state = PrivilegeData.Instance:GetPrilivegeState(self.select_index)
		if fectch_state == 0 then
			self.node_t_list.btn_openpri.node:setVisible(false)
			self.node_t_list.btn_discount.node:setVisible(false)
			self.node_t_list.btn_receive.node:setVisible(true)
			self.node_t_list.remind_name_1.node:setVisible(true)
			self.node_t_list.btn_open.node:setVisible(true) 
			self.node_t_list.btn_receive_chest.node:setVisible(false)
		else	
			self.node_t_list.btn_receive_chest.node:setVisible(true)
			self.node_t_list.btn_open.node:setVisible(false) 
			self.node_t_list.btn_openpri.node:setVisible(false)
			self.node_t_list.btn_discount.node:setVisible(true)
			self.node_t_list.btn_receive.node:setVisible(false)
			self.node_t_list.remind_name_1.node:setVisible(false)
		end
	end

end
--打开特权奖励
function PrivilegeView:OpenChest()
	local view = ViewManager.Instance:GetView(ViewName.PrivilegeAward)
	if view then
		local true_data = PrivilegeData.Instance:GetData()
		local cell = true_data[self.select_index]
		local data = {}
		for k, v in ipairs(cell.dailyVipGift) do
			table.insert(data, {item_id = v.id, num = v.count, is_bind = v.bind})
		end
		view:SetData(data,self.select_index)
		view:Flush()
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

--特权续费、开通
function PrivilegeView:OpenPrivilegeOrDiscount()
	local view = ViewManager.Instance:GetView(ViewName.PrivilegeDialog)
	if view then
		view:SetData(self.select_index)
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

--团购
function PrivilegeView:SuperbuyBtn()
	
	local superbuy = PrivilegeData.Instance:GetSuperBuy()
	self.alert_privilege:SetLableString(string.format(Language.Role.PrivilegeSuperAlert,superbuy))
	self.alert_privilege:SetShowCheckBox(false)
	self.alert_privilege:Open()
	self.alert_privilege:SetOkFunc(function ()
  		PrivilegeCtrl.SendBuyPrivilegeReq(0, 0)
  	end)
	-- 
	AudioManager.Instance:PlayClickBtnSoundEffect()
end
--特权领取奖励
function PrivilegeView:RecevieAward()
	PrivilegeCtrl.SendAwardPrivilege(self.select_index)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end




PrivilegeViewAttrRender = PrivilegeViewAttrRender or BaseClass(BaseRender)
function PrivilegeViewAttrRender:__init()
	self.count_down_time = 0
	self.timer_quest = nil
end

function PrivilegeViewAttrRender:__delete()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	if self.draw_node then
		self.draw_node:clear()
		self.draw_node:removeFromParent()
		self.draw_node = nil
	end
end

function PrivilegeViewAttrRender:CreateChild()
	BaseRender.CreateChild(self)
	-- self:CreateDrawNode()
	self.node_tree.remind_name.node:setVisible(false)
end

function PrivilegeViewAttrRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.privilege_1.node:loadTexture(ResPath.GetPrivilege("privilege_".. self.data.vipType))
	-- RichTextUtil.ParseRichText(self.node_tree.rich_txttype.node, self.data.vipName, 25, COLOR3B.G_Y)
		if self.data.state == 0 then
			self.node_tree.txt_money_1.node:setString(self.data.buyNeedYB)
			-- self.node_tree.txt_money_2.node:setVisible(false)
			-- self.draw_node:setVisible(false)
			self.node_tree.txt_countdown_2.node:setVisible(false)
		else
			-- self.draw_node:setVisible(true)
			self.node_tree.txt_countdown_2.node:setVisible(true)
			if self.data.vipType == 1 then
				self.count_down_time = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_EXPIRE_TIME)
			elseif self.data.vipType == 2 then
				self.count_down_time = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_AVOIDINJURY)
			elseif self.data.vipType == 3 then
				self.count_down_time = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_MAGIC_EQUIPID)
			else
				self.count_down_time = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_MAGIC_EQUIPEXP)
			end

			self.node_tree.txt_money_1.node:setString(self.data.renewalNeedYB)
			-- self.node_tree.txt_money_2.node:setString(self.data.buyNeedYB)
			-- self.node_tree.txt_money_2.node:setVisible(true)

		end
		if self.count_down_time > 0 then
			self.count_down_time = self.count_down_time + COMMON_CONSTS.SERVER_TIME_OFFSET
			self:SetTimerCountDown()
		else
			if self.timer_quest then
				GlobalTimerQuest:CancelQuest(self.timer_quest)
				self.timer_quest = nil
			end
		end
end
--创建横线
function PrivilegeViewAttrRender:CreateDrawNode()
	self.draw_node = cc.DrawNode:create()
	self.view:addChild(self.draw_node,999)
	self.draw_node:clear()
	local x, y = self.node_tree.txt_money_2.node:getPositionX(), 
	self.node_tree.txt_money_2.node:getPositionY()
	local pos1 = cc.p(x - 6, y - 12)
	local pos2 = cc.p(pos1.x + 43 , pos1.y)
	self.draw_node:drawSegment(pos1, pos2, 0.6, cc.c4f(1, 0, 0, 1))
end

-- 设置倒计时
function PrivilegeViewAttrRender:SetTimerCountDown()
	if nil == self.data then return end
	local cur_time = TimeCtrl.Instance:GetServerTime() or os.time()
	local format_time = os.date("*t", server_time)		--获取年月日时分秒的表
	local end_time = self.count_down_time

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	if not self.timer_quest then
		self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.SetTimerCountDown, self), 60)
	end
	local left_time = end_time - cur_time
	local time_str = ""
	if left_time <= 0 then 
		self.node_tree.txt_countdown_2.node:setString("")
		self.node_tree.txt_countdown_2.node:setVisible(false)
		if self.timer_quest then
			GlobalTimerQuest:CancelQuest(self.timer_quest)
			self.timer_quest = nil
			return 
		end
	elseif left_time > 0 and left_time < PrivilegeData.Fresh_Limit_Time then
		if left_time > 0 and left_time < PrivilegeData.Second_Time then
		self.node_tree.txt_countdown_2.node:setColor(COLOR3B.RED)
		self.node_tree.txt_countdown_2.node:setString(Language.Common.RemainTime..":"..Language.Privilege.RemindTime_txt)
		else	
		self.node_tree.txt_countdown_2.node:setColor(COLOR3B.RED)
		local time_str =TimeUtil.FormatSecond2Str(left_time, 0, true)
		self.node_tree.txt_countdown_2.node:setString(Language.Common.RemainTime..":"..time_str)
		end
	else
		self.node_tree.txt_countdown_2.node:setColor(COLOR3B.GREEN)
		local time_cur=  (TimeUtil.Format2TableDHMS(left_time)).day
		time_str = time_cur..Language.Common.TimeList.d
		self.node_tree.txt_countdown_2.node:setString(Language.Common.RemainTime..":".. time_str)
	end
	local award_achieve = PrivilegeData.Instance:GetPrilivegeState(self.index)
	if left_time > 0 and award_achieve == 0 then
		self.node_tree.remind_name.node:setVisible(true)
	else
		self.node_tree.remind_name.node:setVisible(false)
	end

end
function PrivilegeViewAttrRender:CreateSelectEffect()

	local size = self.node_tree.privilege_1.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_120"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end
