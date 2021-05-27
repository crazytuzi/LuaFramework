-- 技能和系统入口切换键
MainuiNavSkillSwitchBtn = MainuiNavSkillSwitchBtn or BaseClass()

function MainuiNavSkillSwitchBtn:__init()
	self.remind_icon_list = {} --要检测红点的列表

	self.remind_icon_list[RemindGroupName.RoleView] = true
	self.remind_icon_list[RemindGroupName.ZhanjiangView] = true
	self.remind_icon_list[RemindGroupName.MagicalStoveView] = true
	self.remind_icon_list[RemindGroupName.Equipment] = true
	self.remind_icon_list[RemindGroupName.Guild] = true
	self.remind_icon_list[RemindGroupName.MailView] = true
	self.remind_icon_list[RemindGroupName.Achieve] = true


end

function MainuiNavSkillSwitchBtn:__delete()
	-- ClientCommonButtonDic[CommonButtonType.NAV_HP_MP_BTN] = nil

	self.remind_icon_list = nil --要检测红点的列表

	GlobalEventSystem:UnBind(self.toggle_handle)
	self.toggle_handle = nil
end
function MainuiNavSkillSwitchBtn:Init(mt_layout_root)
	self.screen_w = HandleRenderUnit:GetWidth()
	self.mt_layout_root = mt_layout_root
	local  winsizeWidth = cc.Director:getInstance():getOpenGLView():getFrameSize()
	-- self.container = XUI.CreateLayout(660,-10,0,0) --底部功能页签按钮
	self.container = XUI.CreateLayout(winsizeWidth.width/2 - 45,-10,0,0)
	self.container:setScale(1.7,1.7)
	self.container:setAnchorPoint(0,0)
	self.mt_layout_root:TextureLayout():addChild(self.container, 2)


	self.btn_img = XUI.CreateLayout(0,0,0,0)
	-- self.btn_img = XUI.CreateImageView(50,45,ResPath.GetMainui("style_switch_1"), is_plist)
	self.container:addChild(self.btn_img, 99)
	-- self.btn_img_1 = XUI.CreateImageView(50,45,ResPath.GetMainui("cell_bg"), is_plist)
	-- self.container:addChild(self.btn_img_1)
	-- ghf 改UI后不用这个
	-- XUI.AddClickEventListener(self.btn_img_1,BindTool.Bind(self.OnToggle,self),true)

	-- ClientCommonButtonDic[CommonButtonType.NAV_HP_MP_BTN] = self.btn_img_1

	self.toggle_handle = GlobalEventSystem:Bind(MainUIEventType.BOTTOMAREA_TOGGLE,BindTool.Bind(self.OnToggleEventBack,self))
end	

function MainuiNavSkillSwitchBtn:OnToggle()
	self.switch_on = not self.switch_on
	if self.switch_on then
		-- self.btn_img:loadTexture(ResPath.GetMainui("style_switch_2"))
	else
		-- self.btn_img:loadTexture(ResPath.GetMainui("style_switch_1"))
	end
	MainuiCtrl.Instance:SwitchMainuiNavBtnToggle()
end	

function MainuiNavSkillSwitchBtn:SwitchOriginal(is_togle)
	self.switch_on = is_togle
	if self.switch_on then
		-- self.btn_img:loadTexture(ResPath.GetMainui("style_switch_2"))
	else
		-- self.btn_img:loadTexture(ResPath.GetMainui("style_switch_1"))
	end
end

function MainuiNavSkillSwitchBtn:OnToggleEventBack()
	self:CheckRemindGroupChange()
	self:SwitchOriginal(MainuiCtrl.Instance.mainui_navbtn_is_toggle)	
end	

function MainuiNavSkillSwitchBtn:RemindGroupChange(group_name, num)
	if self.remind_icon_list[group_name] then
		self:CheckRemindGroupChange()
	end	
end

function MainuiNavSkillSwitchBtn:CheckRemindGroupChange()
	local count = 0
	for k,v in pairs(self.remind_icon_list) do
		count = count + RemindManager.Instance:GetRemindGroup(k)
	end	
	if count > 0 and not MainuiCtrl.Instance.mainui_navbtn_is_toggle then
		self:PlayExteriorEffect()
	else
		self:StopExteriorEffect()	
	end	
end	

function MainuiNavSkillSwitchBtn:PlayExteriorEffect()
	if not self.effect then
		local x, y = 76, 176
		-- self.effect = XUI.CreateImageView(x, y, ResPath.GetMainui("remind_flag"), true)
		-- self.effect:setScale(0.5)
		-- self.container:addChild(self.effect, 100)
		-- self.effect = XUI.CreateImageView(x, y, ResPath.GetSkillIcon("common_exterior_effect"), true)
		-- self.effect:setScale(0.5)
		-- self.container:addChild(self.effect)

		-- local scale_to = cc.ScaleTo:create(0.8, 0.8)
		-- local fade_to = cc.Spawn:create(cc.FadeOut:create(1))
		-- local action_complete_callback = function()
		-- 	self.effect:setScale(0.5)
		-- 	self.effect:setOpacity(255)
		-- end

		-- local spawn = cc.Spawn:create(scale_to,fade_to)
		-- local action = cc.Sequence:create(spawn, cc.CallFunc:create(action_complete_callback))
		-- self.effect:runAction(cc.RepeatForever:create(action))
	end	
end

function MainuiNavSkillSwitchBtn:GetView()
	return self.container
end

function MainuiNavSkillSwitchBtn:StopExteriorEffect()
	-- if self.effect then
	-- 	self.effect:removeFromParent()
	-- 	self.effect = nil
	-- end	
end	