-- 神力租赁页面
CarnivalGoldLeasePage = CarnivalGoldLeasePage or BaseClass()

function CarnivalGoldLeasePage:__init()
	self.view = nil
end

function CarnivalGoldLeasePage:__delete()
	self:RemoveEvent()

	self.view = nil
	if self.lease_list then
		for k,v in ipairs(self.lease_list) do
			v:DeleteMe()
		end
		self.lease_list = nil
	end
end

function CarnivalGoldLeasePage:InitPage(view)
	self.view = view
	-- XUI.AddClickEventListener(self.view.node_t_list.btn_signin.node, BindTool.Bind(self.OnSigninClicked, self), true)
	self:InitEvent()
	self:OnSignInDataChange()
	self:JobReceiveList()
end

function CarnivalGoldLeasePage:InitEvent()

end

function CarnivalGoldLeasePage:RemoveEvent()
	-- if self.sign_in_data_event then
	-- 	GlobalEventSystem:UnBind(self.sign_in_data_event)
	-- 	self.sign_in_data_event = nil
	-- end
end

function CarnivalGoldLeasePage:JobReceiveList()
	if nil == self.lease_list then
		self.lease_list = {}
		for i=1,3 do
			local ph = self.view.ph_list["ph_img_"..i]
			local cur_data 
			local temp = CarnivalData.Instance:getCarnivaGoldLease()
			if temp then
				cur_data = temp[i]
			end
			local cell = self:CreateStoneRender(ph, cur_data,i)
			table.insert(self.lease_list, cell)			
		end
	end
end

function CarnivalGoldLeasePage:CreateStoneRender(ph, cur_data,index)
	local cell = CarnivalGoldLeaseRender.New()
	local render_ph = self.view.ph_list.ph_level_reward_item
	cell:SetUiConfig(render_ph, true)
	cell:SetIndex(index)
	cell:GetView():setPosition(ph.x, ph.y)
	self.view.node_t_list.page10.node:addChild(cell:GetView(), 999)
	if cur_data then	
		cell:SetData(cur_data)
	end
	return cell
end

--更新视图界面
function CarnivalGoldLeasePage:UpdateData(data)
	local temp = CarnivalConfig.rentBuff
	if temp then
		local open_days =  OtherData.Instance:GetRoleCreatDay()
		if temp and temp.createRoleStartDay and temp.createRoleEndDay then
			local time_util = TimeUtil.CONST_3600*TimeUtil.CONST_24
			local server_time = TimeCtrl.Instance:GetServerTime() or os.time()
			local ta_server = os.date("*t", server_time)
			server_time = server_time-(ta_server.hour*TimeUtil.CONST_3600+ta_server.min*TimeUtil.CONST_60+ta_server.sec)
			server_time = server_time-time_util*open_days
			server_time = server_time+time_util*temp.createRoleStartDay
			local format_time_begin = os.date("*t", server_time)

			if temp.createRoleEndDay > temp.createRoleStartDay then
				local left = temp.createRoleEndDay-temp.createRoleStartDay
				server_time= server_time+time_util*left
			end
			local format_time_end = os.date("*t", server_time)
			self.view.node_t_list.txt_time_common_lease.node:setString(format_time_begin.year.."/"..format_time_begin.month.."/"..format_time_begin.day.."-"..format_time_end.year.."/"..format_time_end.month.."/"..format_time_end.day)
		end
	end
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_activity_common_lease.node,temp.actDesc,20,cc.c3b(0xff, 0xff, 0xff))
	local tempData = CarnivalData.Instance:getCarnivaGoldLease()
	for k,v in ipairs(self.lease_list) do
		if tempData[k] then
			v:SetData(tempData[k])
		end
	end
end	

function CarnivalGoldLeasePage:OnSigninClicked()
	
end

function CarnivalGoldLeasePage:OnSignInDataChange()

end


CarnivalGoldLeaseRender = CarnivalGoldLeaseRender or BaseClass(BaseRender)
function CarnivalGoldLeaseRender:__init()
end

function CarnivalGoldLeaseRender:__delete()

end

function CarnivalGoldLeaseRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_group_buy.node, BindTool.Bind(self.Onlease, self), true)
end

function CarnivalGoldLeaseRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.txt_1.node:setString(Language.Carnival.TxtLease1..self.data.yb)	
	self.node_tree.txt_2.node:setString(Language.Carnival.TxtLease2)
	RichTextUtil.ParseRichText(self.node_tree.txt_rich_info.node,self.data.buffDesc,20,cc.c3b(0x00, 0xff, 0x00))
	if self.data.isBuy == 1 then
		self.node_tree.btn_group_buy.node:setTitleText(Language.Common.AlreadyPurchase)
	else
		self.node_tree.btn_group_buy.node:setTitleText(Language.Common.CanPurchase)
	end
	XUI.SetLayoutImgsGrey(self.node_tree.btn_group_buy.node, self.data.isBuy == 1, true)
	XUI.RichTextSetCenter(self.node_tree.txt_rich_info.node)
	XUI.SetRichTextVerticalSpace(self.node_tree.txt_rich_info.node,8)
end

function CarnivalGoldLeaseRender:Onlease()
	if self.data and self.data.index then
		CarnivarCtrl.Instance:SendCarnivalLease(self.data.index)
	end
end


