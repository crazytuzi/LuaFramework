-- 开服排行页面
CarnivalRankPage = CarnivalRankPage or BaseClass()

function CarnivalRankPage:__init()
	self.view = nil
end

function CarnivalRankPage:__delete()
	self:RemoveEvent()
	if self.gift_info_list then
		self.gift_info_list:DeleteMe()
		self.gift_info_list = nil
	end

	if self.menu_info_list then
		self.menu_info_list:DeleteMe()
		self.menu_info_list = nil
	end

	self.view = nil
	if self.rich_private then
		self.rich_private:removeFromParent()
		self.rich_private = nil
	end
end

function CarnivalRankPage:InitPage(view)
	self.view = view
	XUI.AddClickEventListener(self.view.node_t_list.btn_signin.node, BindTool.Bind(self.OnSigninClicked, self), true)
	self:InitEvent()
	self:CreateGiftInfoList()
	self:OnSignInDataChange()
end

function CarnivalRankPage:InitEvent()
	-- self.sign_in_data_event = GlobalEventSystem:Bind(WelfareEventType.SIGN_IN_DATA_CHANGE, BindTool.Bind(self.OnSignInDataChange, self))
end

function CarnivalRankPage:RemoveEvent()
	-- if self.sign_in_data_event then
	-- 	GlobalEventSystem:UnBind(self.sign_in_data_event)
	-- 	self.sign_in_data_event = nil
	-- end
end

function CarnivalRankPage:CreateGiftInfoList()
	if not self.gift_info_list then
		local ph = self.view.ph_list.ph_gift_list
		self.gift_info_list = ListView.New()
		self.gift_info_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, CarnivalRankItem, nil, false, self.view.ph_list.ph_list_gift_info)
		self.gift_info_list:SetItemsInterval(3)
		self.gift_info_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.page7.node:addChild(self.gift_info_list:GetView(), 100)
		self.select = 1
		local data = CarnivalData.Instance:getRankMenuAward()
		for i,v in ipairs(data) do
			if self:updataTimer(i,v) then
				self.select = i -1
				break
			end			
		end
		if self.select == 0 then
			self.select = 1
		end
		self.gift_info_list:SetDataList(data[self.select].RankAward)
		self.gift_info_list:JumpToTop()		
		local str = CarnivalData.Instance:MyDecInso(self.select)
		str = data[self.select].desc.."\n"..Language.Carnival.RichRankTxtDec..str

		if self.rich_private then
			self.rich_private:removeFromParent()
			self.rich_private = nil
		end
		local ph = self.view.ph_list.ph_img_rank
		self.rich_private = XUI.CreateRichText(ph.x, ph.y ,526, 68)
		self.rich_private:setAnchorPoint(0, 0)
		self.view.node_t_list.page7.node:addChild(self.rich_private,999)
		RichTextUtil.ParseRichText(self.rich_private, str, 20, cc.c3b(0xff, 0xff, 0xff))
	end

	if not self.menu_info_list then
		local ph = self.view.ph_list.ph_child_btn_list
		self.menu_info_list = ListView.New()
		self.menu_info_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, MenuRankItem, nil, false, self.view.ph_list.ph_child_btn_item)
		self.menu_info_list:SetItemsInterval(3)
		self.menu_info_list:SetMargin(10)
		self.menu_info_list:SetJumpDirection(ListView.Left)
		self.view.node_t_list.page7.node:addChild(self.menu_info_list:GetView(), 110)
		local data = CarnivalData.Instance:getRankMenuData()
		self.menu_info_list:SetDataList(data)
		self.menu_info_list:SetSelectCallBack(BindTool.Bind(self.SelectItemCallback, self))
		self.menu_info_list:ChangeToIndex(self.select)
	end
end

--更新视图界面
function CarnivalRankPage:UpdateData(data)
	if self.menu_info_list then
		local data = CarnivalData.Instance:getRankMenuData()
		self.menu_info_list:SetDataList(data)
		self.menu_info_list:ChangeToIndex(self.select)
	end
end	

function CarnivalRankPage:SelectItemCallback(item, index)
	local data = CarnivalData.Instance:getRankMenuAward()
	local is_select =  self:updataTimer(index,data[index])
	if is_select then		
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Carnival.TxtTipNo)
		self.menu_info_list:SelectIndex(self.select)
		return
	end
	CarnivarCtrl.Instance:RecvMainRoleInfo()
	self.select = index
	if data[index] and data[index].RankAward then		
		self.gift_info_list:SetDataList(data[index].RankAward)
		self.gift_info_list:JumpToTop()				
		local str = CarnivalData.Instance:MyDecInso(self.select)
		str = data[self.select].desc.."\n"..Language.Carnival.RichRankTxtDec..str

		if self.rich_private then
			self.rich_private:removeFromParent()
			self.rich_private =nil
		end
		local ph = self.view.ph_list.ph_img_rank
		self.rich_private = XUI.CreateRichText(ph.x, ph.y ,526, 68)
		self.rich_private:setAnchorPoint(0, 0)
		self.view.node_t_list.page7.node:addChild(self.rich_private,999)
		RichTextUtil.ParseRichText(self.rich_private, str, 20, cc.c3b(0xff, 0xff, 0xff))
	
	end
end

function CarnivalRankPage:OnSigninClicked()
	ViewManager.Instance:Open(ViewName.CarnivalRank)
	ViewManager.Instance:FlushView(ViewName.CarnivalRank,0,"type",{type =self.select})
end

function CarnivalRankPage:updataTimer(index,data)
	if not index or not data then return end
	local open_days =  OtherData.Instance:GetOpenServerDays()
	if data and data.startDay and data.startDay>open_days then
		return true
	end

	if data and data.startDay and data.endDay then
		local time_util = TimeUtil.CONST_3600*TimeUtil.CONST_24
		local server_time = TimeCtrl.Instance:GetServerTime() or os.time()
		local ta_server = os.date("*t", server_time)
		server_time = server_time-(ta_server.hour*TimeUtil.CONST_3600+ta_server.min*TimeUtil.CONST_60+ta_server.sec)
		server_time = server_time-time_util*open_days
		server_time = server_time+time_util*data.startDay
		local format_time_begin = os.date("*t", server_time)

		if data.endDay > data.startDay then
			local left = data.endDay-data.startDay
			server_time= server_time+time_util*left
		end
		local format_time_end = os.date("*t", server_time)
		self.view.node_t_list.txt_time_common_rank.node:setString(format_time_begin.year.."/"..format_time_begin.month.."/"..format_time_begin.day.."-"..format_time_end.year.."/"..format_time_end.month.."/"..format_time_end.day)
	end
end

function CarnivalRankPage:OnSignInDataChange()

end

CarnivalRankItem = CarnivalRankItem or BaseClass(BaseRender)
function CarnivalRankItem:__init()
	
end

function CarnivalRankItem:__delete()
	if self.soul_cell then
		for i,v in ipairs(self.soul_cell) do
			v:DeleteMe()
		end
		self.soul_cell = nil
	end
end

function CarnivalRankItem:CreateChild()
	BaseRender.CreateChild(self)
	
	
end

function CarnivalRankItem:OnFlush()
	if self.data == nil then return end
	if  self.data.cond and next(self.data.cond) then
		if self.data.cond[1] == self.data.cond[2] then
			self.node_tree.txt_item_name.node:setString(string.format(Language.Common.RankTextStr,self.data.cond[1]))
		elseif self.data.cond[1] ~= self.data.cond[2] then
			local str = self.data.cond[1].."-"..self.data.cond[2]
			self.node_tree.txt_item_name.node:setString(string.format(Language.Common.RankTextStr,str))
		end
	end

	if not self.soul_cell then
		self.soul_cell = {}
	else
		for i,v in ipairs(self.soul_cell) do
			v:GetView():setVisible(false)
		end
	end
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local data  = {}
	for i,v in ipairs(self.data.awards) do
		if v.sex then
			if v.sex == sex and prof == v.job then
				data [#data+1] =v
			end
		else
			data[#data+1] = v
		end
	end
	local ph = self.ph_list.ph_item_cell
	for i,v in ipairs(data) do
		if self.soul_cell[i] then
			self.soul_cell[i]:GetView():setVisible(true)
			self.soul_cell[i]:SetData({item_id = v.id, num = v.count, is_bind = v.bind})
		else
			local cell = BaseCell.New()
			cell:SetPosition(ph.x+(i-1)*85, ph.y)
			cell:GetView():setAnchorPoint(0, 0)
			self.view:addChild(cell:GetView(), 103)
			cell:SetData({item_id = v.id, num = v.count, is_bind = v.bind})
			table.insert(self.soul_cell, cell)
			cell:GetView():setVisible(true)
		end
	end
end

-- 创建选中特效
function CarnivalRankItem:CreateSelectEffect()
	
end


MenuRankItem = MenuRankItem or BaseClass(BaseRender)
function MenuRankItem:__init()
	
end

function MenuRankItem:__delete()
	
end

function MenuRankItem:CreateChild()
	BaseRender.CreateChild(self)		
end

function MenuRankItem:OnFlush()
	if self.data == nil then return end
	self.node_tree.txt_child_btn_name.node:setString(self.data.name)
	self.node_tree.img_remind.node:setVisible(false)
end

-- 创建选中特效
function MenuRankItem:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width + 20,size.height+10,ResPath.GetCommon("img9_173"), true , cc.rect(20,19,21,17))
	if nil == self.select_effect then
		ErrorLog("BaseCell:CreateSelectEffect fail")
		return
	end
	self.view:addChild(self.select_effect, 999, 999)


end