--右边导航按钮
MainuiNavBtnRight = MainuiNavBtnRight or BaseClass()

function MainuiNavBtnRight:__init()
	self.nav_btn_list = {}
	
	self.toggle_handle = GlobalEventSystem:Bind(MainUIEventType.BOTTOMAREA_TOGGLE,BindTool.Bind(self.OnToggle,self))
end

function MainuiNavBtnRight:__delete()
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

function MainuiNavBtnRight:Init(mt_layout_root)
	self.mt_layout_root = mt_layout_root

	self.screen_w = HandleRenderUnit:GetWidth()
	self.global_x = self.screen_w * 0.5 + 110

	self.global_y = 25

	self.container = XUI.CreateLayout(self.global_x,self.global_y,1,105)
	self.container:setAnchorPoint(0,0)
	self.mt_layout_root:TextureLayout():addChild(self.container,-2)

	

	self.team_btn = MainuiNavBtn.New(self.container,ViewName.Team)
	self.team_btn:SetImageIcon("38","38")
	self.nav_btn_list[1] = self.team_btn

	self.friend_btn = MainuiNavBtn.New(self.container,ViewName.Society)
	self.friend_btn:SetImageIcon("03","03")
	self.nav_btn_list[2] = self.friend_btn

	self.guild_btn = MainuiNavBtn.New(self.container,ViewName.Guild)
	self.guild_btn:SetImageIcon("11","11")
	self.nav_btn_list[3] = self.guild_btn

	self.mail_btn = MainuiNavBtn.New(self.container,ViewName.Mail)
	self.mail_btn:SetImageIcon("13","13")
	self.nav_btn_list[4] = self.mail_btn

	self.setting_btn = MainuiNavBtn.New(self.container,ViewName.Setting)
	self.setting_btn:SetImageIcon("19","19")
	self.nav_btn_list[5] = self.setting_btn
	ClientCommonButtonDic[CommonButtonType.NAV_SETTING_BTN] = self.setting_btn

	
	local pre_btn = nil
	for i = 1, #self.nav_btn_list do
		local cur_btn = self.nav_btn_list[i]
		if pre_btn then
			cur_btn:GetView():setPosition(pre_btn:GetView():getPositionX() + 100,0)
		else
			cur_btn:GetView():setPosition(0,0)
		end	
		pre_btn = cur_btn

		XUI.AddClickEventListener(cur_btn:GetView(),BindTool.Bind(self.OnClickBtn,self,cur_btn),true)
	end	

	self.arrow_btn = MainUIArrowBtn.New(self.mt_layout_root:TextureLayout(),
											ResPath.GetMainui("small_arrow_1"),
											true,
											60,60,false)
	self.arrow_btn:GetView():setPosition(self.global_x - 20, self.global_y + 60)
	self.arrow_btn:GetView():setEnabled(false)
	self:OnToggle(false)

end	

function MainuiNavBtnRight:OnClickBtn(nav_btn)
	if self:IsCrossServerCanntOpen(nav_btn:GetViewName(), nav_btn:GetGroup()) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end
	if nav_btn:GetViewName() ~= nil then
		ViewManager.Instance:Open(nav_btn:GetViewName())
	end	
end	

function MainuiNavBtnRight:IsCrossServerCanntOpen(view_name, view_group)
	-- 跨服期间不能打开的界面
	local cross_server_cannt_view = {
		ViewName.Society,
		ViewName.Guild,
		ViewName.Mail,
	}
	local is_view = false
	for k, v in pairs(cross_server_cannt_view) do
		if view_name == v or view_group == v then
			is_view = true
			break
		end
	end

	return is_view and IS_ON_CROSSSERVER
end

function MainuiNavBtnRight:OnToggle(visible)
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

function MainuiNavBtnRight:NavBtnRightRemindGroupChange(group_name, num)
	

	if group_name == RemindGroupName.Guild then
		self.guild_btn:SetFlagTip(num)
	end
	
	if group_name == RemindGroupName.MailView then
		--print("3333333333333",num)
		self.mail_btn:SetFlagTip(num)
	end

end



