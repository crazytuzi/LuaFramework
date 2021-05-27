MailView = MailView or BaseClass(BaseView)

--邮件事件类型
MailEventType = {
	mailRecvFlower = 1,				--	 接收鲜花
	mailRebackRedPacket = 2,		--	 返还红包
	mailActorKilled = 3,			--	 死亡记录
	mailGuildFunds = 4,				--	 行会资金
	mailServiceActivity = 5,		--	 全服活动或公告
	mailConsignItem = 6,            -- 	 寄售商品
	mailChallengeAward = 7,			--	 闯关奖励
	mailDartFaild = 8,				--	 押镖失败
	mailGuildDelete = 9,			-- 	 行会解散
	mailPayNotice = 10,				-- 	 充值通知
	mailSysRewardMail = 11,			--	 系统奖励
	mailSysSendEveryOne = 12,		-- 全服公告(后台发送)
	mailSysSendOnline = 13,			-- 全服在线公告(后台发送)
	mailCrossServerReturn = 16,		-- 跨服返回物品
	mailNewCrossRetBagItem  = 19,	-- 跨服返回物品
	mailGuildBosskillAward  = 20,	-- 行会BOSS尾刀奖
	mailGuildBossJionAward  = 21,	-- 行会BOSS参与奖
	mailGuildBossFirstAward1  = 22,	-- 行会BOSS第一名管理层奖励
	mailGuildBossFirstAward2  = 23,	-- 行会BOSS第一名普通成员奖励
	mailBoomerangDartAwards   = 24,	-- 劫镖奖励
	mailFullSvrLuckDraw = 25,		-- 全服抽奖
	mailCuttingAwardsNotice = 26,	-- 切割效果奖励通知
}
function MailView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list[1] = 'res/xui/mail.png'
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"mail_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}
	self.mail_list = nil
	self.mail_id_list = {}
	self.current_index = 1
	self.read_mail_id = 0
end

function MailView:__delete()
end

function MailView:ReleaseCallBack()
	if self.mail_item_list then
		self.mail_item_list:DeleteMe()
		self.mail_item_list = nil
	end

	if self.reward_list then
		self.reward_list:DeleteMe()
		self.reward_list = nil
	end
	self.read_mail_id = 0

	if self.mail_alert then
		self.mail_alert:DeleteMe()
	end
	self.mail_alert = nil

	self.scroll_rich = nil
end

function MailView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.AddClickEventListener(self.node_t_list.btn_delete.node, BindTool.Bind(self.OnClickDeleteMailHandler, self, 1))
		XUI.AddClickEventListener(self.node_t_list.btn_delete_simple.node, BindTool.Bind(self.OnClickDeleteMailHandler, self, 2))
		self.node_t_list.btn_tiqu.node:addClickEventListener(BindTool.Bind1(self.OnClickTiQUGoodsHandler, self))
		self.node_t_list.btn_all_tiqu.node:addClickEventListener(BindTool.Bind1(self.OnClickTiQuAllGoodsHandler, self))
		self:UpdateMailList()
		self:ShowRewardCell()
	end
end

function MailView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.current_index = 1
end

function MailView:ShowIndexCallBack(index)
	self.node_t_list.img_flag_mail.node:setVisible(false)
	self:Flush(index)
end

function MailView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end


function MailView:OnFlush(param_t, index)
	local mail_list = MailData.Instance:GetMailContent()
	self:FlushMail(mail_list)
	self:FlushRemindList(mail_list)
	if not mail_list then return end
	self.current_index = self:GetCurIndexByMailId(self.read_mail_id) or self.current_index
	self.mail_item_list:ChangeToIndex(self.current_index)

	local cur_cout = #mail_list
	local max_count = GlobalConfig.wSendMailMaxCount
	local color = cur_cout >= max_count and COLOR3B.RED or COLOR3B.WHITE
	self.node_t_list["lbl_mail_count"].node:setString(cur_cout .. "/" .. max_count)
	self.node_t_list["lbl_mail_count"].node:setColor(color)

	for k,v in pairs(mail_list) do
		if k == self.current_index then
			self:ShowContent(v)
			self:FlushRewardCell(v)
			break
		else
			self:ShowContent(v)
			self:FlushRewardCell(v)
		end
	end

end

function MailView:OnClickDeleteMailHandler(btn_type)
	local mail_list = MailData.Instance:GetMailContent()
	self.mail_id_list = {}
	for i,v in ipairs(mail_list) do
		if btn_type == 1 then --一键删除
			if v.mail_type == MailEventType.mailActorKilled 
			or v.mail_type == MailEventType.mailGuildFunds 
			or v.mail_type == MailEventType.mailServiceActivity 
			or v.mail_type == MailEventType.mailPayNotice
			or (v.mail_type == MailEventType.mailSysSendEveryOne and #v.tab == 0)
			or (v.mail_type == MailEventType.mailSysSendOnline and #v.tab == 0)
			or v.mail_type == MailEventType.mailGuildDelete then  --死亡记录与全服公告
				if v.is_read == 1 then
					table.insert(self.mail_id_list, v.mail_id)
				end
			elseif v.mail_type == MailEventType.mailConsignItem then
				if v.reward_item == 0 then
					if v.is_read == 1 then
						table.insert(self.mail_id_list, v.mail_id)
					end
				else
					if v.is_read == 1 and v.is_get_reward == 1 then 
						table.insert(self.mail_id_list, v.mail_id)
					end
				end
			else
				if v.is_read == 1 and v.is_get_reward == 1 then -- 其他需要领取物品才可删除
					table.insert(self.mail_id_list, v.mail_id)
				end 
			end
		else
			if self.current_index == i then  --当前选择的序列与邮件列表的序列相同时
				if v.mail_type == MailEventType.mailActorKilled 
				or v.mail_type == MailEventType.mailGuildFunds 
				or v.mail_type == MailEventType.mailServiceActivity 
				or v.mail_type == MailEventType.mailPayNotice
				or (v.mail_type == MailEventType.mailSysSendEveryOne and #v.tab == 0)
				or (v.mail_type == MailEventType.mailSysSendOnline and #v.tab == 0)
				or v.mail_type == MailEventType.mailGuildDelete then  --死亡记录与全服公告
					if v.is_read == 1 then
						table.insert(self.mail_id_list, v.mail_id)
					end
				elseif v.mail_type == MailEventType.mailConsignItem then -- 寄售
					if v.reward_item == 0 then -- 数量为0
						if v.is_read == 1 then
							table.insert(self.mail_id_list, v.mail_id)
						end
					else 						--数量不为0 时
						if v.is_read == 1 and v.is_get_reward == 1 then 
							table.insert(self.mail_id_list, v.mail_id)
						end
					end
				else
					if v.is_read == 1 and v.is_get_reward == 1 then -- 其他需要领取物品才可删除
						table.insert(self.mail_id_list, v.mail_id)
						v.is_read = 0
						self:ShowContent(v) 
					elseif v.is_read == 1 and v.is_get_reward ~= 1 then
						if self.mail_alert == nil then
							self.mail_alert = Alert.New()
						end
						self.mail_alert:SetLableString("奖励未被领取,是否确定删除")
						self.mail_alert:SetOkFunc(function ()
							v.is_read = 0
							self:ShowContent(v)
							self:FlushRewardCell(v)
							self.node_t_list.img_flag_mail.node:setVisible(false)
							MailCtrl.Instance:SendDeleteMailReq({v.mail_id})
						end)
						self.mail_alert:Open()
					end
				end
			end 
		end	
	end
	MailCtrl.Instance:SendDeleteMailReq(self.mail_id_list)
end

--提取奖励
function MailView:OnClickTiQUGoodsHandler()
	local mail_list = MailData.Instance:GetMailContent()
	for i,v in ipairs(mail_list) do
		if v.mail_type ~= MailEventType.mailActorKilled 
		and v.mail_type ~= MailEventType.mailGuildFunds 
		and v.mail_type ~= MailEventType.mailServiceActivity 
		and v.mail_type ~= MailEventType.mailPayNotice
		and (v.mail_type ~= MailEventType.mailSysSendEveryOne or #v.tab > 0)
		and (v.mail_type ~= MailEventType.mailSysSendOnline or #v.tab > 0)  
		and v.mail_type ~= MailEventType.mailGuildDelete then  -- 3为死亡记录
			if i == self.current_index then
				MailCtrl.Instance:SendMailGetRewardReq(v.mail_id)
				v.is_read = 1
				self:ShowContent(v)
				self.node_t_list.img_flag_mail.node:setVisible(false)
			end
		end
	end
end

--提取所有奖励
function MailView:OnClickTiQuAllGoodsHandler()
	MailCtrl.Instance:SendAllMailAcceptReq()
	local mail_list = MailData.Instance:GetMailContent()
	for i,v in ipairs(mail_list) do
		if v.mail_type ~= MailEventType.mailActorKilled 
		and v.mail_type ~= MailEventType.mailGuildFunds 
		and v.mail_type ~= MailEventType.mailServiceActivity 
		and v.mail_type ~= MailEventType.mailPayNotice 
		and (v.mail_type ~= MailEventType.mailSysSendEveryOne or #v.tab > 0)
		and (v.mail_type ~= MailEventType.mailSysSendOnline and #v.tab > 0)
		and v.mail_type ~= MailEventType.mailGuildDelete then  --死亡记录无提取
			v.is_read = 1
			if self.current_index == i then
				self:ShowContent(v)
			end
		end
	end
	self.mail_item_list:ChangeToIndex(1)
	self.node_t_list.img_flag_mail.node:setVisible(false)
end

local MailItemCell = BaseClass(BaseCell)
function MailItemCell:SetItemNumTxt()
	if ItemData.GetIsTransferStone(self.data.item_id) and self.data.durability and self.data.durability / 1000 > self.hide_num_if_less_numx then
		self:SetRightBottomText(tostring(self.data.durability / 1000))
	elseif self.data.num and self.data.num > self.hide_num_if_less_numx then
		self:SetRightBottomText(tostring(self.data.num))
	else
		self:SetRightBottomText("")
		self:SetRightBottomImageNumText(0)
	end
end

function MailView:ShowRewardCell()
	if self.reward_list == nil then
		local ph = self.ph_list["ph_item_bg_1"]
		self.reward_list = ListView.New()
		self.reward_list:Create(ph.x, ph.y, (ph.w + 10) * 4, ph.h + 10, ScrollDir.Horizontal, MailItemCell, nil, nil, self.ph_list.ph_quick_buy_item)
		self.reward_list:SetItemsInterval(10)
		self.reward_list:SetMargin(2)
		self.reward_list:GetView():setAnchorPoint(0, 0.5)
		self.node_t_list.layout_unread_mail.node:addChild(self.reward_list:GetView(), 203)
	end	
end

--刷新奖励物品
function MailView:FlushRewardCell(mail)
	XUI.SetButtonEnabled(self.node_t_list.btn_tiqu.node, true)
	XUI.SetButtonEnabled(self.node_t_list.btn_all_tiqu.node, true)
	local list = {}
	if mail.is_read == 1 then 			-- 已读
		if mail.is_get_reward == 0 then -- 未领取
			if mail.mail_type == MailEventType.mailConsignItem then
				if mail.reward_item == 0 then
					 XUI.SetButtonEnabled(self.node_t_list.btn_tiqu.node, false)
					 XUI.SetButtonEnabled(self.node_t_list.btn_all_tiqu.node, false)
				else
					local item_id = MoneyTypeDef[mail.reward_type] or 0
					table.insert(list, {item_id = item_id, num = mail.reward_item, is_bind = 0}) --奖励金币
					 XUI.SetButtonEnabled(self.node_t_list.btn_tiqu.node, true)
					 XUI.SetButtonEnabled(self.node_t_list.btn_all_tiqu.node, true)
				end
			elseif mail.mail_type == MailEventType.mailRebackRedPacket then
				table.insert(list, {item_id = 813, num = mail.reward_item, is_bind = 0}) --奖励金币
			elseif mail.mail_type == MailEventType.mailRecvFlower or mail.mail_type == MailEventType.mailChallengeAward then
				-- if k == 1 then
				-- 	table.insert(list, {item_id = mail.reward_id, num = mail.reward_num, is_bind = 0}) --奖励鲜花/或闯关奖励
				-- else
				-- 	table.insert(list, {item_id = 0, num = 0, is_bind = 0})
				-- end
				for k1,v1 in pairs(mail.tab) do
					local item_type = tonumber(v1.item_type)
					local count = tonumber(v1.count)
					local is_bind = tonumber(v1.is_bind)
					if v1.item_type == tagAwardType.qatEquipment or item_type == tagAwardType.qatEquipment then
						table.insert(list, {["item_id"] = tonumber(v1.id), ["num"] = count, is_bind = is_bind})
						is_setdata = true
					else
						local virtual_item_id = ItemData.GetVirtualItemId(item_type)
						if count > 0 then
							if virtual_item_id then
								table.insert(list, {["item_id"] = virtual_item_id, ["num"] = count, is_bind = 0})
								is_setdata = true
							end
						end
					end
				end
			elseif mail.mail_type == MailEventType.mailDartFaild
				or (mail.mail_type == MailEventType.mailSysSendEveryOne and #mail.tab > 0)
				or (mail.mail_type == MailEventType.mailSysSendOnline and #mail.tab > 0)
				or mail.mail_type == MailEventType.mailGuildBosskillAward
				or mail.mail_type == MailEventType.mailGuildBossJionAward
				or mail.mail_type == MailEventType.mailGuildBossFirstAward1
				or mail.mail_type == MailEventType.mailGuildBossFirstAward2
				or mail.mail_type == MailEventType.mailBoomerangDartAwards
				or mail.mail_type == MailEventType.mailFullSvrLuckDraw
				or mail.mail_type == MailEventType.mailCuttingAwardsNotice
				or mail.mail_type == MailEventType.mailSysRewardMail then
				local is_setdata = false
				for k1, v1 in pairs(mail.tab) do
					local item_type = tonumber(v1.item_type)
					local count = tonumber(v1.count)
					local is_bind = tonumber(v1.is_bind)
					if v1.item_type == tagAwardType.qatEquipment or item_type == tagAwardType.qatEquipment then
						table.insert(list, {["item_id"] = tonumber(v1.id), ["num"] = count, is_bind = is_bind})
						is_setdata = true
					else
						local virtual_item_id = ItemData.GetVirtualItemId(item_type)
						if count > 0 then
							if virtual_item_id then
								table.insert(list, {["item_id"] = virtual_item_id, ["num"] = count, is_bind = 0})
								is_setdata = true
							end
						end
					end	
				end
			elseif mail.mail_type == MailEventType.mailCrossServerReturn then
				for _, item in pairs(mail.tab) do
					table.insert(list, ItemData.FormatItemData(item))
				end
			elseif mail.mail_type == MailEventType.mailNewCrossRetBagItem then
				table.insert(list, mail.item_data)
			end
		end
	end
	self.reward_list:SetDataList(list)
end

function MailView:UpdateMailList()
	if nil == self.mail_item_list then
		local ph = self.ph_list.ph_mail_item_list
		self.mail_item_list = ListView.New()
		self.mail_item_list:Create(ph.x, ph.y, ph.w, ph.h, nil, MailRender, nil, true, self.ph_list.ph_mail_item)
		self.mail_item_list:GetView():setAnchorPoint(0, 0)
		self.mail_item_list:SetItemsInterval(5)
		self.mail_item_list:SetJumpDirection(ListView.Top)
		self.mail_item_list:SetSelectCallBack(BindTool.Bind(self.SelectMailCallback, self))  --按钮回调
		self.node_t_list.layout_unread_mail.node:addChild(self.mail_item_list:GetView(), 100)
	end
end

function MailView:FlushMail(mail_list)
	self.mail_item_list:SetDataList(mail_list or {})
end

function MailView:SelectMailCallback(cur_select_item, index)
	self.current_index = index
	local mail_list = MailData.Instance:GetMailContent()
	if mail_list == nil then return end

	local data = cur_select_item:GetData()
	if not data then return end
	self.read_mail_id = data.mail_id

	MailCtrl.Instance:SendReadMailReq(data.mail_id)
	data.is_read = 1
	self:ShowContent(data)
	self:FlushRewardCell(data)
	local num = nil
	if data.mail_type == MailEventType.mailConsignItem or data.mail_type == MailEventType.mailRebackRedPacket then
		num = data.is_get_reward
	elseif data.mail_type == MailEventType.mailRecvFlower or data.mail_type == MailEventType.mailChallengeAward then
		num = data.is_get_reward
	elseif data.mail_type == MailEventType.mailDartFaild
	or (data.mail_type == MailEventType.mailSysSendEveryOne and #data.tab > 0)
	or (data.mail_type == MailEventType.mailSysSendOnline and #data.tab > 0)
	or data.mail_type == MailEventType.mailGuildBosskillAward
	or data.mail_type == MailEventType.mailGuildBossJionAward
	or data.mail_type == MailEventType.mailGuildBossFirstAward1
	or data.mail_type == MailEventType.mailGuildBossFirstAward2
	or data.mail_type == MailEventType.mailBoomerangDartAwards
	 or data.mail_type == MailEventType.mailSysRewardMail then	
		num = data.is_get_reward
	else
		num = 1
	end
	self.node_t_list.img_flag_mail.node:setVisible(num == 0)
end

function MailView:GetCurIndexByMailId(mail_id)
	local mail_list = MailData.Instance:GetMailContent()
	if not mail_id or not mail_list then return end
	for k,v in pairs(mail_list) do
		if v.mail_id == mail_id then return k end
	end
end

function MailView:ShowContent(mail_tab)
	self.node_t_list.txt_sender_name.node:setString(Language.Mail.Sender_Name)
	self.node_t_list.txt_theme_content.node:setString(mail_tab.title)

	local rich_node = self.node_t_list.rich_mail_content.node
	local x, y = rich_node:getPosition()
	local size = rich_node:getContentSize()
	if nil == self.scroll_rich then
		rich_node:retain()
		rich_node:removeFromParent(false)
		self.scroll_rich = XUI.CreateScrollView(x, y, size.width, size.height + 1, ScrollDir.Vertical)
		self.node_t_list.layout_unread_mail.node:addChild(self.scroll_rich, 10)
		self.scroll_rich:setAnchorPoint(0, 1)
		self.scroll_rich:addChild(rich_node)
	end

	RichTextUtil.ParseRichText(rich_node, mail_tab.content_desc)
	rich_node:refreshView()
	rich_node:setVerticalSpace(8)
	local inner_size = rich_node:getInnerContainerSize()
	local inner_heigh = math.max(inner_size.height, size.height)
	rich_node:setPosition(0, inner_heigh)
	self.scroll_rich:setInnerContainerSize(cc.size(inner_size.width, inner_heigh))
	self.scroll_rich:jumpToTop()

	local time = os.date("%Y/%m/%d %H:%M", mail_tab.send_time)
	self.node_t_list.txt_time.node:setString(time)
	self.node_t_list.txt_time.node:setVisible(mail_tab.is_read == 1)
	self.node_t_list.txt_sender_name.node:setVisible(mail_tab.is_read == 1)
	self.node_t_list.txt_theme_content.node:setVisible(mail_tab.is_read == 1)
	self.node_t_list.rich_mail_content.node:setVisible(mail_tab.is_read == 1)
end

function MailView:FlushRemindList(mail_list)
	for k,v in pairs(mail_list) do
		if v.mail_type ~= MailEventType.mailActorKilled 
			and v.mail_type ~= MailEventType.mailGuildFunds
			and v.mail_type ~= MailEventType.mailPayNotice
			and v.mail_type ~= MailEventType.mailServiceActivity 
			and #v.tab > 0 
			and v.is_get_reward == 0 then
			v.need_remind = 0
		else
			v.need_remind = 1
		end
	end
end

MailRender = MailRender or BaseClass(BaseRender)
function MailRender:__init()
end

function MailRender:__delete()
end

function MailRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.txt_mail_remiantime.node:setVisible(false)
	self.node_tree.txt_mail_title.node:setString(self.data.title)
	if self.data.sender_id == 0 then
		self.node_tree.txt_name.node:setString(Language.Mail.Sender_Name)
	end
	if self.data.is_read == 0 then
		self.node_tree.img_mail.node:loadTexture(ResPath.GetMail("mail_unread"))
	else
		self.node_tree.img_mail.node:loadTexture(ResPath.GetMail("mail_readed"))
	end
	if self.data.need_remind == 0 then
		self.node_tree.img_flag_mail_2.node:setVisible(true)
	else
		self.node_tree.img_flag_mail_2.node:setVisible(false)
	end

	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end
end

-- function MailRender:CreateSelectEffect() 
	-- if nil == self.node_tree.img_open_content then
	-- 	self.cache_select = true
	-- 	return
	-- end
	-- local item_size = self.node_tree.img_open_content.node:getContentSize()
	-- self.select_effect = XUI.CreateImageViewScale9(item_size.width / 2, item_size.height / 2, 0, 0, ResPath.GetMail("outline_bg"), true)
	-- self.select_effect:setContentSize(item_size)
	-- if nil == self.select_effect then
	-- 	ErrorLog("BaseRender:CreateSelectEffect fail")
	-- 	return
	-- end
	-- self.node_tree.img_open_content.node:addChild(self.select_effect,999)
-- end

function MailRender:CreateSelectEffect()
	-- if nil == self.node_tree.img_open_content then
	-- 	self.cache_select = true
	-- 	return
	-- end
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_285"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end

