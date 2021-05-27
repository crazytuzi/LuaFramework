--底部导航按钮
MainuiNavBtnFloor = MainuiNavBtnFloor or BaseClass()

function MainuiNavBtnFloor:__init()
	self.nav_btn_list = {}
	self.sub_group_btns = {}
	self.remind_group_to_btn_idx = {}
	self.group_panel_list = {}
	self.leftBtn = {}
	self.rightBtn = {}
	self.toggle_handle = GlobalEventSystem:Bind(MainUIEventType.BOTTOMAREA_TOGGLE,BindTool.Bind(self.OnToggle,self))
end

function MainuiNavBtnFloor:__delete()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
	GlobalEventSystem:UnBind(self.toggle_handle)
	self.toggle_handle = nil

	for i = 1, #self.nav_btn_list do
		self.nav_btn_list[i]:DeleteMe()
	end	
	self.nav_btn_list = nil

	for k, v in pairs(self.sub_group_btns) do
		for _, v2 in pairs(v) do
			v2:DeleteMe()
		end
	end
	self.sub_group_btns = nil

	for k, v in pairs(self.group_panel_list) do
		v:DeleteMe()
	end
	self.group_panel_list = nil
	-- if self.arrow_btn then
	-- 	self.arrow_btn:DeleteMe()
	-- 	self.arrow_btn = nil
	-- end	
end

MainuiNavBtnFloor.IconsCfgList =
{
	{res = "19", area = "top1", view_name = ViewName.Setting, view_index = nil, remind_group = nil,node_name = CommonButtonType.NAV_SETTING_BTN, is_cross_hide = false,},
	{res = "10", area = "top1", view_name = ViewName.Achieve, view_index = nil, remind_group = RemindGroupName.Achieve,node_name = CommonButtonType.Achieve, is_cross_hide = true,},
	{res = "29", area = "top1", view_name = nil, view_index = nil, remind_group = nil,node_name = nil, is_cross_hide = false,
		sub_cfg = {
			{res = "03", area = "top1", view_name = ViewName.Society, view_index = nil, remind_group = nil, node_name = nil, is_cross_hide = true,},
			{res = "38", area = "top1", view_name = ViewName.Team, view_index = nil, remind_group = nil, node_name = nil, is_cross_hide = false,},
	}},
	{res = "11", area = "top1", view_name = ViewName.Guild, view_index = nil,remind_group = RemindGroupName.Guild,node_name = nil,is_cross_hide = true},	
	{res = "13", area = "top1", view_name = ViewName.Mail, view_index = nil,remind_group = RemindGroupName.MailView,node_name = nil,is_cross_hide = true},
	{res = "09", area = "top1", view_name = ViewName.RankingList, view_index = nil, remind_group = nil, node_name = CommonButtonType.NAV_RANK_BTN,is_cross_hide = true},	
	{res = "07", area = "top1", view_name = ViewName.Compose, view_index = nil, remind_group = RemindGroupName.MagicalStoveView,node_name = CommonButtonType.NAV_COMPOSE_BTN, is_cross_hide = true,},
	{res = "08", area = "top1", view_name = ViewName.Equipment, view_index = nil, remind_group = RemindGroupName.Equipment,node_name = CommonButtonType.NAV_EQUIPBOOST_BTN, is_cross_hide = true,},
	{res = "05", area = "top1", view_name = ViewName.Zhanjiang, view_index = nil, remind_group = RemindGroupName.ZhanjiangView, node_name = CommonButtonType.NAV_ZHANSHEN_BTN, is_cross_hide = false,},
	{res = "01", area = "top1", view_name = ViewName.Role, view_index = nil, remind_group = RemindGroupName.RoleView, node_name = CommonButtonType.NAV_ROLE_BTN, is_cross_hide = false,},
}

function MainuiNavBtnFloor:Init(mt_layout_root)
	self.mt_layout_root = mt_layout_root
	self.screen_w = HandleRenderUnit:GetWidth()
	-- self.global_x = self.screen_w > 960 and (self.screen_w - 360) or self.screen_w --相对技能栏布局
	self.global_x = 1150
	self.global_y = 13

	-- self.container = XUI.CreateLayout(self.global_x,self.global_y,1,105)
	local  winsizeWidth = cc.Director:getInstance():getOpenGLView():getFrameSize()

	local centerX = self.screen_w*0.5
	self.container = XUI.CreateLayout(centerX,30,1,105)
	self.container:setAnchorPoint(1,0) --设置右对齐
	self.mt_layout_root:TextureLayout():addChild(self.container,1)
	local gap = 8
	for k, v in ipairs(MainuiNavBtnFloor.IconsCfgList) do
		local btn = self:CreateNavBtn(self.container, v, k)
		if v.remind_group then
			self.remind_group_to_btn_idx[v.remind_group] = k
		end
		self.nav_btn_list[k] = btn
		if v.sub_cfg then
			self.sub_group_btns[k] = {}
			local group_panel = MainuiNavBtnGroupPanel.New(self.mt_layout_root:TextureLayout(), k)
			group_panel:SetMaskPanelTouchEnable(false)
			local group_cnt = #v.sub_cfg
			group_panel:SetSize(btn.width*group_cnt+(group_cnt - 1)*gap,86)
			self.group_panel_list[k] = group_panel
			for k_2, v_2 in ipairs(v.sub_cfg) do
				local sub_btn = self:CreateNavBtn(group_panel:GetView(), v_2, k_2)
				sub_btn:GetView():setPosition((k_2-1) * (sub_btn.width + gap), -2)
				if v_2.remind_group then
					self.remind_group_to_btn_idx[v_2.remind_group] = {k, k_2}
				end
				self.sub_group_btns[k][k_2] = sub_btn
			end
		end
	end

	local pre_btn = nil
	for i, cur_btn in ipairs(self.nav_btn_list) do
		-- pre_btn = self.nav_btn_list[i-1]
		pre_btn = self.nav_btn_list[i]
		if pre_btn then
			print("下标值是这个 : "..i)
			if i <= 5 then
				table.insert(self.leftBtn,pre_btn)
			else
				table.insert(self.rightBtn,pre_btn)
			end
		-- 	if i % 2 ~= 0 then
		-- 		cur_btn:GetView():setPosition(pre_btn:GetView():getPositionX() - 100,-6)
		-- 	else
		-- 		cur_btn:GetView():setPosition(pre_btn:GetView():getPositionX() - 90,-6)
		-- 	end
		-- else
		-- 	cur_btn:GetView():setPosition(0,-6)
		end	

		-- if cur_btn:GetData() and cur_btn:GetData().sub_cfg then
		-- 	local group_panel = self.group_panel_list[i]
		-- 	if group_panel then
		-- 		local size = cur_btn:GetView():getContentSize()
		-- 		local pos = cur_btn:GetView():convertToWorldSpace(cc.p(size.width * 0.5, size.height * 0.5))
		-- 		size = group_panel:GetSize()
		-- 		group_panel:SetPosition(pos.x, pos.y+40)
		-- 		group_panel:SetVisible(false)
		-- 	end
		-- end
	end	

	local  winsizeWidth = cc.Director:getInstance():getOpenGLView():getFrameSize()
	print("self.leftBtnArray : "..#self.leftBtn)
	-- self.rightBtn[5]:GetView():setPosition(-880,30)
	-- self.rightBtn[4]:GetView():setPosition(-780,30)
	-- self.rightBtn[3]:GetView():setPosition(-680,30)
	-- self.rightBtn[2]:GetView():setPosition(-580,30)
	-- self.rightBtn[1]:GetView():setPosition(-480,30)

	local margin = 160;
	local itemWidth = 100;
	local len = 5
	for i,v in ipairs(self.rightBtn) do
		local posx = -margin-itemWidth*(i-1)+30
		self.rightBtn[i]:GetView():setPosition(posx,0)
		cur_btn = self.rightBtn[i];
		if cur_btn:GetData() and cur_btn:GetData().sub_cfg then
			local group_panel = self.group_panel_list[cur_btn:GetIndex()]
			if group_panel then
				local size = cur_btn:GetView():getContentSize()
				local pos = cur_btn:GetView():convertToWorldSpace(cc.p(posx, size.height * 0.5))
				size = group_panel:GetSize()
				group_panel:SetPosition(pos.x-255, pos.y+40)
				group_panel:SetVisible(false)
			end
		end
	end

	for i,v in ipairs(self.leftBtn) do
		local posx = margin+itemWidth*(len-i)
		self.leftBtn[i]:GetView():setPosition(posx,0)
		cur_btn = self.leftBtn[i];
		if cur_btn:GetData() and cur_btn:GetData().sub_cfg then
			local group_panel = self.group_panel_list[cur_btn:GetIndex()]
			if group_panel then
				local size = cur_btn:GetView():getContentSize()
				local pos = cur_btn:GetView():convertToWorldSpace(cc.p(posx, size.height * 0.5))
				size = group_panel:GetSize()
				group_panel:SetPosition(pos.x-255, pos.y+40)
				group_panel:SetVisible(false)
			end
		end
	end
	-- self.rightBtn[5]:GetView():setPosition(-970,4)
	-- self.rightBtn[4]:GetView():setPosition(-870,4)
	-- self.rightBtn[3]:GetView():setPosition(-770,4)
	-- self.rightBtn[2]:GetView():setPosition(-670,4)
	-- self.rightBtn[1]:GetView():setPosition(-570,4)

	-- self.leftBtn[1]:GetView():setPosition(-970,4)
	-- self.leftBtn[2]:GetView():setPosition(-870,4)
	-- self.leftBtn[3]:GetView():setPosition(-770,4)
	-- self.leftBtn[4]:GetView():setPosition(-670,4)
	-- self.leftBtn[5]:GetView():setPosition(-570,4)
	print("self.rightBtnArray : "..#self.rightBtn)
	-- self.leftBtn[5]:GetView():setPosition(-280,30)
	-- self.leftBtn[4]:GetView():setPosition(-180,30)
	-- self.leftBtn[3]:GetView():setPosition(-80,30)
	-- self.leftBtn[2]:GetView():setPosition(20,30)
	-- self.leftBtn[1]:GetView():setPosition(120,30)

	-- self.leftBtn[5]:GetView():setPosition(-370,4)
	-- self.leftBtn[4]:GetView():setPosition(-270,4)
	-- self.leftBtn[3]:GetView():setPosition(-170,4)
	-- self.leftBtn[2]:GetView():setPosition(-70,4)
	-- self.leftBtn[1]:GetView():setPosition(30,4)
	
	-- self.rightBtn[1]:GetView():setPosition(-370,4)
	-- self.rightBtn[2]:GetView():setPosition(-270,4)
	-- self.rightBtn[3]:GetView():setPosition(-170,4)
	-- self.rightBtn[4]:GetView():setPosition(-70,4)
	-- self.rightBtn[5]:GetView():setPosition(30,4)




	-- for i,v in ipairs(self.leftBtn) do
	-- 	print(i,v)
	-- 	v:GetView():setPosition(-(150 * i),-6)
	-- end

	-- for i,v in ipairs(self.rightBtn) do
	-- 	print(i,v)
	-- 	v:GetView():setPosition(-(100 * i),-6)
	-- end

	-- local bg_width = 80-self.nav_btn_list[#self.nav_btn_list]:GetView():getPositionX()
	-- self.img9_icon_bg = XUI.CreateImageViewScale9(84, 0, bg_width, 53, ResPath.GetMainui("icon_bg_2"), true,cc.rect(11,73,22,1))
	-- self.img9_icon_bg:setAnchorPoint(1, 0)
	-- self.container:addChild(self.img9_icon_bg, -1)
	
	local offset_x = self.global_x
	local btn = nil
	local pos_x = nil
	local img = nil
	for i = 1, 5 do
		btn = self.nav_btn_list[i*2]
		if btn then
			pos_x = btn:GetView():getPositionX()
			img = XUI.CreateImageView(pos_x + 88, 0, ResPath.GetMainui("icon_bg_3"), true)
			img:setAnchorPoint(0.5, 0)
			self.container:addChild(img)
		end
	end

	self:OnToggle(false)
end

function MainuiNavBtnFloor:CreateNavBtn(parent, data, index)
	local btn = MainuiNavBtn.New(parent,data.view_name, data.remind_group, index, data)
	btn:SetImageIcon(data.res,data.res)
	btn:SetTxtImgPos(nil, 5)
	if data.node_name and data.node_name ~= "" then
		ClientCommonButtonDic[data.node_name] = btn
	end
	XUI.AddClickEventListener(btn:GetView(),BindTool.Bind(self.OnClickBtn,self,btn),true)
	return btn
end

function MainuiNavBtnFloor:OnClickBtn(nav_btn)
	if IS_ON_CROSSSERVER and nav_btn:GetData() and nav_btn:GetData().is_cross_hide then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end

	if nav_btn:GetViewName() ~= nil then
		if nav_btn:GetViewName() == ViewName.Zhanjiang then
			if ViewManager.Instance:IsTryOpen(nav_btn:GetViewName()) then
				if ZhanjiangData.Instance:GetAttr("hero_id") <= 0 then
					ViewManager.Instance:Open(ViewName.HeroProfChose)
					return
				end
			else
				return	
			end
		end	
		ViewManager.Instance:Open(nav_btn:GetViewName())
	elseif nav_btn:GetData() and nav_btn:GetData().sub_cfg then
		local group_panel = self.group_panel_list[nav_btn:GetIndex()]
		if group_panel then
			group_panel:SetVisible(not group_panel:IsVisible(), true)
		end
	end	
end	

-- function MainuiNavBtnFloor:OnItemChange()
-- 	local num = ItemData.Instance:GetEmptyNum()

-- 	-- 背包是否满了
-- 	if num > 0 then
-- 		-- 没满
-- 		if MainuiCtrl.Instance then
-- 			MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.BAG_FULL, 0)
-- 		end
-- 	end

-- 	if num == 0 then
-- 		-- 满了 创建提醒图标
-- 		if MainuiCtrl.Instance then
-- 			MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.BAG_FULL, 1, function ()
-- 				ViewManager.Instance:Open(ViewName.Bag)
-- 			end)
-- 		end
-- 		num = Language.Common.Man
-- 	elseif num > 4 then
-- 		num = ""
-- 	end
-- 	self.bag_btn:SetTipText(num)
-- end

-- function MainuiNavBtnFloor:OnGetUiNode(node_name)
-- 	if node_name == ViewName.Bag then
-- 		return self.bag_btn:GetView(), true
-- 	end
-- 	return nil, nil
-- end

function MainuiNavBtnFloor:OnToggle(visible)
	-- self.arrow_btn:SetIsOn(visible)
	self.container:stopAllActions()
	if visible then
		self.container:setVisible(true)
		local queue = cc.Spawn:create(cc.FadeIn:create(0.2))
		self.container:runAction(queue)
	else
		for k, v in pairs(self.group_panel_list) do
			if v:IsVisible() then
				v:SetVisible(false)
			end
		end
		local callback = cc.CallFunc:create(function()
			self.container:setVisible(false)
		end)
		local action = cc.Spawn:create(cc.FadeOut:create(0.2))
		local queue = cc.Sequence:create(action,callback)
		self.container:runAction(queue)
	end	
end	

function MainuiNavBtnFloor:NavBtnLeftRemindGroupChange(group_name, num)
	local index = self.remind_group_to_btn_idx[group_name]
	if index then
		if type(index) == "number" then
			if self.nav_btn_list[index] then
				self.nav_btn_list[index]:SetFlagTip(num)
			end
		elseif type(index) == "table" then
			if not self.sub_group_btns[index[1]] then return end
			if self.sub_group_btns[index[1]][index[2]] then
				self.sub_group_btns[index[1]][index[2]]:SetFlagTip(num)
			end

			if self.nav_btn_list[index[1]] then
				local vis = false
				for k, v in pairs(self.sub_group_btns[index[1]]) do
					if v:GetFlagTipVis() then
						vis = true
						break
					end
				end
				local num = vis and 1 or 0
				self.nav_btn_list[index[1]]:SetFlagTip(num)
			end
		end
	end
end