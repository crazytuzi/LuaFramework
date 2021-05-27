MainuiHpMpBar = MainuiHpMpBar or BaseClass()

function MainuiHpMpBar:__init()
	self.role_data_event = BindTool.Bind1(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_event)

	self.role_init_handle = GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO,BindTool.Bind(self.OnRoleInfoInit,self))

	self.remind_icon_list = {} --要检测红点的列表

	self.remind_icon_list[RemindGroupName.RoleView] = true
	self.remind_icon_list[RemindGroupName.AllEquipment] = true
	self.remind_icon_list[RemindGroupName.ZhanjiangView] = true
	self.remind_icon_list[RemindGroupName.EquipmentComposeView] = true
end

function MainuiHpMpBar:__delete()
	ClientCommonButtonDic[CommonButtonType.NAV_HP_MP_BTN] = nil

	if self.role_data_event then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
		self.role_data_event = nil
	end	

	if self.role_init_handle then
		GlobalEventSystem:UnBind(self.role_init_handle)
		self.role_init_handle = nil
	end	

	self.remind_icon_list = nil --要检测红点的列表

	GlobalEventSystem:UnBind(self.toggle_handle)
	self.toggle_handle = nil

	if self.bing_evt then
		GlobalEventSystem:UnBind(self.bing_evt)
		self.bing_evt = nil
	end

	if self.dun_evt then
		GlobalEventSystem:UnBind(self.dun_evt)
		self.dun_evt = nil
	end

	if self.hero_attr_evt then
		GlobalEventSystem:UnBind(self.hero_attr_evt)
		self.hero_attr_evt = nil
	end
	if self.change_map_handler then
		GlobalEventSystem:UnBind(self.change_map_handler)
		self.change_map_handler = nil
	end
end

function MainuiHpMpBar:Init(mt_layout_root)
	self.screen_w = HandleRenderUnit:GetWidth()
	self.mt_layout_root = mt_layout_root

	local  winsizeWidth = cc.Director:getInstance():getOpenGLView():getFrameSize()
	print("framSize Width: "..winsizeWidth.width.."framSize Height: "..winsizeWidth.height)

	-- self.container = XUI.CreateLayout(self.screen_w * 0.5 + 45,5,1,105) --119
	-- self.container = XUI.CreateLayout(680 + 45,5,1,105)
	self.container = XUI.CreateLayout(winsizeWidth.width/2 + 55,5,1,105)
	self.container:setEnabled(true)
	self.container:setAnchorPoint(0,0)
	local p = self.mt_layout_root:TextureLayout():convertToNodeSpace(cc.p(self.screen_w*0.5, 0))
	self.container:setPosition(p.x,5)
	self.mt_layout_root:TextureLayout():addChild(self.container,-2)

	-- local bg = XUI.CreateImageView(0,0,ResPath.GetMainui("hp_mp_bg"),true)
	-- bg:setAnchorPoint(0.5,0)
	-- -- self.container:addChild(bg,-1)
	-- XUI.AddClickEventListener(bg,BindTool.Bind(self.OnToggle,self),false)

	-- ClientCommonButtonDic[CommonButtonType.NAV_HP_MP_BTN] = bg

	local hp_mp_container = XUI.CreateLayout(0,7,1,105)
	hp_mp_container:setAnchorPoint(0,0)
	self.container:addChild(hp_mp_container,4)

	local qiu_bg = XUI.CreateImageView(0,0,"res/xui/hp_qiu_bg.png",true)
	qiu_bg:setAnchorPoint(0.5,0)
	qiu_bg:setPosition(0,7)
	self.container:addChild(qiu_bg,3)
	XUI.AddClickEventListener(qiu_bg,BindTool.Bind(self.OnToggle,self),false)

	-- local qiu_bg = XUI.CreateImageView(0,7,ResPath.GetMainui("hp_qiu_bg"),true) 
	-- qiu_bg:setAnchorPoint(0.5,0)
	-- self.container:addChild(qiu_bg,3)

	local hp_bar_bg_node = XUI.CreateLayout(0,7,50,100)
	-- local hp_effect = AnimateSprite:create()
	local ani_path,ani_name = ResPath.GetEffectUiAnimPath(31)
	-- hp_effect:setAnimate(ani_path,ani_name,COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	-- hp_effect:setPosition(50,50)
	-- hp_bar_bg_node:addChild(hp_effect)

	local leftArrow = cc.Sprite:create("res/xui/leadIcon.png")
	leftArrow:setAnchorPoint(0.5,0.5)
	leftArrow:setPosition(-80,50)
	hp_mp_container:addChild(leftArrow)

	local hp_effect = cc.Sprite:create("res/xui/hp_circle.png")
	hp_effect:setAnchorPoint(0.5,0.5)
	hp_effect:setPosition(50,50)
	hp_bar_bg_node:addChild(hp_effect)

	self.hp_bar = MaskProgressBar.New(hp_mp_container,hp_bar_bg_node,
	 								XUI.CreateImageViewScale9(0,0,100,100,ResPath.GetCommon("img9_138"), true,cc.rect(5,5,10,10)),
	 								cc.size(100,100))
	self.hp_bar:getView():setPositionX(-50)
	
	local mp_bar_bg_node = XUI.CreateLayout(0,0,50,100)
	-- local mp_effect = AnimateSprite:create()
	local ani_path,ani_name = ResPath.GetEffectUiAnimPath(32)
	-- mp_effect:setAnimate(ani_path,ani_name,COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	-- mp_effect:setPosition(0,50)
	-- mp_bar_bg_node:addChild(mp_effect)

	local rightArrow = cc.Sprite:create("res/xui/rigtlead.png")
	rightArrow:setAnchorPoint(0.5,0.5)
	rightArrow:setPosition(80,50)
	hp_mp_container:addChild(rightArrow)

	local mp_effect = cc.Sprite:create("res/xui/mp_circle.png")
	mp_effect:setAnchorPoint(0.5,0.5)
	mp_effect:setPosition(0,56)
	mp_bar_bg_node:addChild(mp_effect)	

	self.mp_bar = MaskProgressBar.New(hp_mp_container,mp_bar_bg_node,
	 								XUI.CreateImageViewScale9(-20,0,100,100,ResPath.GetCommon("img9_138"), true,cc.rect(5,5,10,10)),
	 								cc.size(100,100))


	local desc = XUI.CreateImageView(0,0,ResPath.GetMainui("hp_mp_desc"),true)
	desc:setAnchorPoint(0.5,0)
	-- self.container:addChild(desc)

	self.hp_bar_text = XUI.CreateText(-35,45,50,20,cc.TEXT_ALIGNMENT_CENTER,"100%")
	self.hp_bar_text:setAnchorPoint(0,0.5)
	self.container:addChild(self.hp_bar_text,4)

	self.mp_bar_text = XUI.CreateText(-5,75,50,20,cc.TEXT_ALIGNMENT_CENTER,"100%")
	self.mp_bar_text:setAnchorPoint(0,0.5)
	self.container:addChild(self.mp_bar_text,4)


	

	self.toggle_handle = GlobalEventSystem:Bind(MainUIEventType.BOTTOMAREA_TOGGLE,BindTool.Bind(self.OnToggleEventBack,self))


	--[[self.reciveGoldBing = XUI.CreateButton(-140,70,96,70,false,ResPath.GetMainui2("main_ui_shenbing"),"","",true)
	self.container:addChild(self.reciveGoldBing)
	self.reciveGoldBing:setVisible(false)
	XUI.AddClickEventListener(self.reciveGoldBing, BindTool.Bind(self.OnReciveGoldBing, self), true)

	self.GoldBingRed= XUI.CreateImageView(55, 55, ResPath.GetMainui("remind_flag"), true)
	self.GoldBingRed:setVisible(false)
	self.reciveGoldBing:addChild(self.GoldBingRed)

	self.reciveGoldDun = XUI.CreateButton(140,70,96,70,false,ResPath.GetMainui2("main_ui_shendun"),"","",true)
	self.container:addChild(self.reciveGoldDun)
	self.reciveGoldDun:setVisible(false)
	XUI.AddClickEventListener(self.reciveGoldDun, BindTool.Bind(self.OnReciveGoldDun, self), true)

	self.GoldDunRed= XUI.CreateImageView(55, 55, ResPath.GetMainui("remind_flag"), true)
	self.reciveGoldDun:addChild(self.GoldDunRed)
	self.GoldDunRed:setVisible(false)--]]

	self.bing_evt = GlobalEventSystem:Bind(HeroGoldEvent.HeroGoldBing, BindTool.Bind(self.UpdateBing, self))
	self.hero_attr_evt = GlobalEventSystem:Bind(HeroDataEvent.HERO_ATTR_CHANGE, BindTool.Bind(self.UpdateBing, self))
	self.dun_evt = GlobalEventSystem:Bind(HeroGoldEvent.HeroGoldDun, BindTool.Bind(self.UpdateBing, self))
	self.change_map_handler = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.UpdateBing, self))
end	
function MainuiHpMpBar:OnReciveGoldBing()
	ViewManager.Instance:Open(ViewName.HeroGoldBing)
end

function MainuiHpMpBar:OnReciveGoldDun()
	ViewManager.Instance:Open(ViewName.HeroGoldDun)
end

function MainuiHpMpBar:UpdateBing()
	--[[self.reciveGoldBing:setVisible(false)
	self.reciveGoldDun:setVisible(false)
	self.GoldDunRed:setVisible(false)
	self.GoldBingRed:setVisible(false)
	if  IS_ON_CROSSSERVER then return end
	if ViewManager.Instance:CanShowUi(ViewName.Zhanjiang, nil, true) then
		if ZhanjiangData.Instance:GetAttr("hero_id") > 0 then
			local num,award = HeroGoldBingData.Instance:getChargeInfo()
			if award <=0 then
				self.reciveGoldBing:setVisible(true)
			end
			if num >=HeroGodWeaponRechargeConfig.yb and award <=0 then
				self.GoldBingRed:setVisible(true)
			end
			local activat = HeroGoldDunData.Instance:GetEquipDunState()
			if activat <=0 then
				self.reciveGoldDun:setVisible(true)
				local cfg = HeroGoldDunData.Instance:GetEquipBossCfg()
				local flag = true
				for i,v in ipairs(cfg) do
					if v.state ~= 1 then
						flag = false
					end
				end
				if flag then
					self.GoldDunRed:setVisible(true)
				end
			end 
		end
	else
		self.reciveGoldBing:setVisible(false)
		self.reciveGoldDun:setVisible(false)
		return 
	end--]]
end

function MainuiHpMpBar:OnToggle()
	MainuiCtrl.Instance:SwitchMainuiNavBtnToggle()
end	

function MainuiHpMpBar:OnToggleEventBack(visible)
	-- self.reciveGoldBing:setVisible(not visible)
	-- self.reciveGoldDun:setVisible(not visible)
	self:CheckRemindGroupChange()	
	self:UpdateBing()
end	

function MainuiHpMpBar:OnRoleInfoInit()
	local hp_percent = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_HP) / (RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_HP) == 0 and 1 or RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_HP))
	local mp_percent = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MP) / (RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_MP) == 0 and 1 or RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_MP))
	self.hp_bar_text:setString(math.floor(hp_percent * 100 ) .. "%")
	self.mp_bar_text:setString(math.floor(mp_percent * 100 ) .. "%")
	self.hp_bar:setProgressPercent(hp_percent)
	self.mp_bar:setProgressPercent(mp_percent)
end	


function MainuiHpMpBar:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.CREATURE_HP or key == OBJ_ATTR.CREATURE_MAX_HP then
		local hp_percent = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_HP) / (RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_HP) == 0 and 1 or RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_HP))
		self.hp_bar_text:setString(math.floor(hp_percent * 100 ) .. "%")
		self.hp_bar:setProgressPercent(hp_percent)
	elseif key == OBJ_ATTR.CREATURE_MP or key == OBJ_ATTR.CREATURE_MAX_MP then	
		local mp_percent = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MP) / (RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_MP) == 0 and 1 or RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_MAX_MP))
		self.mp_bar_text:setString(math.floor(mp_percent * 100 ) .. "%")
		self.mp_bar:setProgressPercent(mp_percent)
	end	
end	


function MainuiHpMpBar:RemindGroupChange(group_name, num)
	if self.remind_icon_list[group_name] then
		self:CheckRemindGroupChange()
	end	
end

function MainuiHpMpBar:CheckRemindGroupChange()
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

function MainuiHpMpBar:PlayExteriorEffect()
	if not self.effect then
		local x, y = 0,55
		self.effect = XUI.CreateImageView(x, y, ResPath.GetSkillIcon("common_exterior_effect"), true)
		self.effect:setScale(0.5)
		-- self.container:addChild(self.effect)

		local scale_to = cc.ScaleTo:create(1, 1)
		local fade_to = cc.Spawn:create(cc.FadeOut:create(1))
		local action_complete_callback = function()
			self.effect:setScale(0.5)
			self.effect:setOpacity(255)
		end

		local spawn = cc.Spawn:create(scale_to,fade_to)
		local action = cc.Sequence:create(spawn, cc.CallFunc:create(action_complete_callback))
		self.effect:runAction(cc.RepeatForever:create(action))
	end	
end

function MainuiHpMpBar:StopExteriorEffect()
	if self.effect then
		self.effect:removeFromParent()
		self.effect = nil
	end	
end	
