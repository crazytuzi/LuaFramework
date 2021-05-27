--左边导航按钮
MainuiNavBtnLeft = MainuiNavBtnLeft or BaseClass()

function MainuiNavBtnLeft:__init()
	self.nav_btn_list = {}
	self.toggle_handle = GlobalEventSystem:Bind(MainUIEventType.BOTTOMAREA_TOGGLE,BindTool.Bind(self.OnToggle,self))
end

function MainuiNavBtnLeft:__delete()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
	GlobalEventSystem:UnBind(self.toggle_handle)
	self.toggle_handle = nil

	for i = 1, #self.nav_btn_list do
		self.nav_btn_list[i]:DeleteMe()
	end	
	self.nav_btn_list = nil

	if self.arrow_btn then
		self.arrow_btn:DeleteMe()
		self.arrow_btn = nil
	end	
end

function MainuiNavBtnLeft:Init(mt_layout_root)
	self.mt_layout_root = mt_layout_root
	self.screen_w = HandleRenderUnit:GetWidth()
	self.global_x = self.screen_w * 0.5 - 110
	self.global_y = 25

	self.container = XUI.CreateLayout(self.global_x,self.global_y,1,105)
	self.container:setAnchorPoint(0,0)
	self.mt_layout_root:TextureLayout():addChild(self.container,-2)

	self.hero_btn = MainuiNavBtn.New(self.container,ViewName.Zhanjiang)
	self.hero_btn:SetImageIcon("05","05")
	self.nav_btn_list[1] = self.hero_btn
	ClientCommonButtonDic[CommonButtonType.NAV_ZHANSHEN_BTN] = self.hero_btn

	self.equip_boost_btn = MainuiNavBtn.New(self.container,ViewName.Equipment)
	self.equip_boost_btn:SetImageIcon("08","08")
	self.nav_btn_list[2] = self.equip_boost_btn
	ClientCommonButtonDic[CommonButtonType.NAV_EQUIPBOOST_BTN] = self.equip_boost_btn

	self.compose_btn = MainuiNavBtn.New(self.container,ViewName.Compose)
	self.compose_btn:SetImageIcon("07","07")
	self.nav_btn_list[3] = self.compose_btn
	ClientCommonButtonDic[CommonButtonType.NAV_COMPOSE_BTN] = self.compose_btn

	self.bag_btn = MainuiNavBtn.New(self.container,ViewName.Bag)
	self.bag_btn:SetImageIcon("04","04")
	self.nav_btn_list[4] = self.bag_btn
	ClientCommonButtonDic[CommonButtonType.NAV_BAG_BTN] = self.bag_btn

	self.role_btn = MainuiNavBtn.New(self.container,ViewName.Role)
	self.role_btn:SetImageIcon("01","01")
	self.nav_btn_list[5] = self.role_btn
	ClientCommonButtonDic[CommonButtonType.NAV_ROLE_BTN] = self.role_btn
	


	local pre_btn = nil
	for i = 1, #self.nav_btn_list do
		local cur_btn = self.nav_btn_list[i]
		if pre_btn then
			cur_btn:GetView():setPosition(pre_btn:GetView():getPositionX() - 100,0)
		else
			cur_btn:GetView():setPosition(-100,0)
		end	
		pre_btn = cur_btn

		XUI.AddClickEventListener(cur_btn:GetView(),BindTool.Bind(self.OnClickBtn,self,cur_btn),true)
	end	

	self.arrow_btn = MainUIArrowBtn.New(self.mt_layout_root:TextureLayout(),
											ResPath.GetMainui("small_arrow_1"),
											true,
											60,60,true)
	self.arrow_btn:GetView():setPosition(self.global_x + 20, self.global_y + 60)
	self.arrow_btn:GetView():setEnabled(false)

	self.itemdata_change_callback = BindTool.Bind(self.OnItemChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
	self:OnItemChange()
	self:OnToggle(false)
end

function MainuiNavBtnLeft:OnClickBtn(nav_btn)
	if self:IsCrossServerCanntOpen(nav_btn:GetViewName()) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end

	if nav_btn:GetViewName() ~= nil then
		ViewManager.Instance:Open(nav_btn:GetViewName())
	end	
end	

function MainuiNavBtnLeft:IsCrossServerCanntOpen(view_name)
	-- 跨服期间不能打开的界面
	local cross_server_cannt_view = {
		ViewName.Equipment,
		ViewName.Compose,
	}
	local is_view = false
	for k, v in pairs(cross_server_cannt_view) do
		if view_name == v then
			is_view = true
			break
		end
	end

	return is_view and IS_ON_CROSSSERVER
end

function MainuiNavBtnLeft:OnItemChange()
	local num = ItemData.Instance:GetEmptyNum()

	-- 背包是否满了
	if num > 0 then
		-- 没满
		if MainuiCtrl.Instance then
			MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.BAG_FULL, 0)
		end
	end

	if num == 0 then
		-- 满了 创建提醒图标
		if MainuiCtrl.Instance then
			MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.BAG_FULL, 1, function ()
				ViewManager.Instance:Open(ViewName.Bag)
			end)
		end
		num = Language.Common.Man
	elseif num > 4 then
		num = ""
	end
	self.bag_btn:SetTipText(num)
end

function MainuiNavBtnLeft:OnGetUiNode(node_name)
	if node_name == ViewName.Bag then
		return self.bag_btn:GetView(), true
	end
	return nil, nil
end

function MainuiNavBtnLeft:OnToggle(visible)
	self.arrow_btn:SetIsOn(visible)
	self.container:stopAllActions()

	if visible then
		self.container:setVisible(true)
		local queue = cc.Spawn:create(cc.FadeIn:create(0.2))
		self.container:runAction(queue)
	else
		local callback = cc.CallFunc:create(function()
			self.container:setVisible(false)
		end)
		local action = cc.Spawn:create(cc.FadeOut:create(0.2))
		local queue = cc.Sequence:create(action,callback)
		self.container:runAction(queue)
	end	
end	

function MainuiNavBtnLeft:NavBtnLeftRemindGroupChange(group_name, num)
	if group_name == RemindGroupName.MagicalStoveView then
		self.compose_btn:SetFlagTip(num)
	elseif 	group_name == RemindGroupName.RoleView then
		self.role_btn:SetFlagTip(num)
	elseif group_name == RemindGroupName.Equipment then
		self.equip_boost_btn:SetFlagTip(num)
	elseif group_name == RemindGroupName.ZhanjiangView then	
		self.hero_btn:SetFlagTip(num)
	end
end