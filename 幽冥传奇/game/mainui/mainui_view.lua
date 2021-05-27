require("scripts/game/mainui/mainui_multi_layout")

require("scripts/game/mainui/mainui_icon")
require("scripts/game/mainui/mainui_headbar")
require("scripts/game/mainui/mainui_joystick")
require("scripts/game/mainui/mainui_right_top")
require("scripts/game/mainui/mainui_chat")
require("scripts/game/mainui/mainui_skillbar")
require("scripts/game/mainui/mainui_iconbar")
require("scripts/game/mainui/mainui_near")
require("scripts/game/mainui/mainui_smallparts")
require("scripts/game/mainui/mainui_task")
require("scripts/game/mainui/mainui_small_tip")


MainuiView = MainuiView or BaseClass(BaseView)

MainuiView.LAYOUT_PART = {
	CENTER = 1,
	LEFT_TOP = 2,
	CENTER_TOP = 3,
	RIGHT_TOP = 4,
	CENTER_LEFT = 5,
	CENTER_RIGHT = 6,
	BOTTOM_LEFT = 7,
	BOTTOM_RIGHT = 8,
	BOTTOM_CENTER = 9,
}

MainuiView.LAYOUT_PART_CFG = {
	[1] = {anchor = cc.p(0.5, 0.5)},
	[2] = {anchor = cc.p(0, 1)},
	[3] = {anchor = cc.p(0.5, 1)},
	[4] = {anchor = cc.p(1, 1)},
	[5] = {anchor = cc.p(0, 0.5)},
	[6] = {anchor = cc.p(1, 0.5)},
	[7] = {anchor = cc.p(0, 0)},
	[8] = {anchor = cc.p(1, 0)},
	[9] = {anchor = cc.p(0.5, 0)},
}

function MainuiView:__init()
	self.zorder = -2
	self.can_penetrate = true
	self.texture_path_list = {
		"res/xui/mainui.png",
		"res/xui/skill.png",
		"res/xui/face.png",
		'res/xui/map.png',
		'res/xui/task_ui.png',
	}
	self.close_mode = CloseMode.CloseVisible

	self.near_view = nil
	self.mainui_part_list = {}

	self.complete_callback = nil
	self.cur_num = 0
	GlobalEventSystem:Bind(MainUIEventType.UI_SCALE_CHANGE, BindTool.Bind(self.OnUiScaleChange, self))
	GlobalEventSystem:Bind(MainUIEventType.UPDATE_BRILLIANT_ICON, BindTool.Bind(self.OnUpdateBrilliantIcon, self))
	GlobalEventSystem:Bind(MainUIEventType.UPDATE_RARETREASURE_ICON, BindTool.Bind(self.OnUpdateRareTreasureIcon, self))
	GlobalEventSystem:Bind(MainUIEventType.UPDATE_ZSTASK_ICON, BindTool.Bind(self.OnUpdateBrilliantIcon, self))

end

function MainuiView:__delete()
	for i = 1, #self.mainui_part_list do
		self.mainui_part_list[i]:DeleteMe()
	end
	self.mainui_part_list = {}
	self.near_view = nil
	self.small_part = nil
	if self.tower_level_num  then
		self.tower_level_num:DeleteMe()
		self.tower_level_num = nil
	end
	self.img = nil 
	self.layout_show = nil

	if self.rare_treasure_timer then
		GlobalTimerQuest:CancelQuest(self.rare_treasure_timer)
		self.rare_treasure_timer = nil
	end

	if self.charge_effect3 then
		self.charge_effect3:setStop()
		self.charge_effect3 = nil
	end
	if self.charge_effect1 then
		self.charge_effect1:setStop()
		self.charge_effect1 = nil
	end
	if self.charge_effect2 then
		self.charge_effect2:setStop()
		self.charge_effect2 = nil
	end

	if self.qianggou_effect1 then
		self.qianggou_effect1:setStop()
		self.qianggou_effect1 = nil
	end

	if self.charge_gift_effect1 then
		self.charge_gift_effect1:setStop()
		self.charge_gift_effect1 = nil
	end

	if self.skill_success_envent then
		GlobalEventSystem:UnBind(self.skill_success_envent)
		self.skill_success_envent = nil
	end

	if self.skill_effect then
		self.skill_effect:setStop()
		self.skill_effect = nil
	end
	self.layout_show_effect = nil
	self.arow_bg1 = nil
	self.arow_bg2 = nil 
end

function MainuiView:StartLoad(complete_callback)
	self.complete_callback = complete_callback
	self:BaseLoad()
	self:Load(0)
end

function MainuiView:LoadCallBack()
	self.screen_w, self.screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
	self.root_node:setContentSize(cc.size(self.screen_w, self.screen_h))

    --匹配齐刘海
    local design_bar_height = 0
    local bar_height =  PlatformAdapter.GetStatusBarHeight()
    print("bar_height = " .. bar_height)
    if 0 ~= bar_height then
    	local scale_x =  cc.Director:getInstance():getOpenGLView():getScaleX()
    	design_bar_height = bar_height / scale_x
        print("design_bar_height = " .. design_bar_height)
    end

	self.mt_layout_root = MainuiMultiLayout.New()
	self.mt_layout_root:CreateByParent(self.root_node)
	self.mt_layout_root:setPosition(self.screen_w / 2, self.screen_h / 2)
	self.mt_layout_root:setContentSize(cc.size(self.screen_w - design_bar_height * 2, self.screen_h)) --两边缩放
	self.layout_parts = {}
	for k, v in pairs(MainuiView.LAYOUT_PART) do
		local cfg = MainuiView.LAYOUT_PART_CFG[v]
		local anchor = cfg.anchor
		self.layout_parts[v] = MainuiMultiLayout.CreateMultiLayout((self.screen_w -design_bar_height) * anchor.x, self.screen_h * anchor.y, anchor, cc.size(self.screen_w, self.screen_h), self.mt_layout_root, 0)
	end
	self:LayoutPartsScale(MainuiData.Instance:GetMainuiScale())

	--------------------------------------------------
	-- 使用纹理 "res/xui/skill.png"
	-- 技能栏控制 
	self.skill_bar = self:CreateMainuiPart(MainuiSkillBar, MainuiView.LAYOUT_PART.BOTTOM_RIGHT)
	--------------------------------------------------

	--------------------------------------------------
	-- 使用纹理 "res/xui/mainui.png"
	-- 头象栏控制
	self.head_bar = self:CreateMainuiPart(MainuiHeadBar, MainuiView.LAYOUT_PART.LEFT_TOP)
	-- 摇杆
	self:CreateMainuiPart(MainuiJoystick, MainuiView.LAYOUT_PART.BOTTOM_LEFT)
	-- 右上部件
	self.right_top = self:CreateMainuiPart(MainuiRightTop, MainuiView.LAYOUT_PART.RIGHT_TOP)
	-- 聊天
	self.char_bar = self:CreateMainuiPart(MainuiChat, MainuiView.LAYOUT_PART.BOTTOM_CENTER)
	-- 图标栏控制
	self.icon_bar = self:CreateMainuiPart(MainUiIconbar, MainuiView.LAYOUT_PART.RIGHT_TOP)
	-- 任务栏
	-- self.task_bar = self:CreateMainuiPart(MainuiTask, MainuiView.LAYOUT_PART.BOTTOM_CENTER)
	-- 提示小图标
	self.small_tip = self:CreateMainuiPart(MainuiSmallTip, MainuiView.LAYOUT_PART.BOTTOM_CENTER)
	-- 主ui小部件
	self.small_part = self:CreateMainuiPart(MainuiSmallParts)
	self.small_part:Init()
	--------------------------------------------------
	
	-- 附近目标选择
	self.near_view = self:CreateMainuiPart(MainuiNear):Init()
	if nil ~= self.complete_callback then
		self.complete_callback()
	end
	self.change_level = 0
	self.change_num = 0
	self.qiang_gou_num = 0
	self.charge_gift_num = 0 
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	self.skill_success_envent = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_USE_SKILL, BindTool.Bind(self.OnMainRoleUseSkill, self))

end

function MainuiView:CreateMainuiPart(class, part_index)
	local part = class.New(self)
	if part_index then
		part:Init(self.layout_parts[part_index])
	end
	table.insert(self.mainui_part_list, part)
	return part
end

function MainuiView:CreateMultiLayout(x, y, anchor_point, size, parent)
	local multi_layout = MainuiMultiLayout.New()
	multi_layout:CreateByMultiLayout(parent or self.mt_layout_root)
	multi_layout:setPosition(x, y)
	multi_layout:setAnchorPoint(anchor_point)
	multi_layout:setContentSize(size)
	return multi_layout
end

function MainuiView:OnUiScaleChange(scale)
	self:LayoutPartsScale(scale)
end

function MainuiView:OnUpdateBrilliantIcon()
	self.icon_bar:UpdateBrilliantIcon()
end

function MainuiView:OnUpdateRareTreasureIcon()
	local data = ExploreData.Instance:GetRareTreasureData()
	local left_time = (data.end_time or 0) + COMMON_CONSTS.SERVER_TIME_OFFSET - os.time()
	if left_time > 0 then
		local callback = function()
			self.icon_bar:UpdateIconBottomContent(ViewDef.Explore.RareTreasure)
		end
		if self.rare_treasure_timer then
			-- 重置计时器
			GlobalTimerQuest:EndQuest(self.rare_treasure_timer)
			self.rare_treasure_timer = GlobalTimerQuest:AddTimesTimer(callback, 1, left_time)
		else
			callback()
			self.rare_treasure_timer = GlobalTimerQuest:AddTimesTimer(callback, 1, left_time)
		end
	else
		if self.rare_treasure_timer then
			GlobalTimerQuest:EndQuest(self.rare_treasure_timer)
			self.rare_treasure_timer = nil
		end
	end
end

function MainuiView:LayoutPartsScale(scale)
	for k, v in pairs(self.layout_parts) do
		v:setScale(scale)
	end
end

function MainuiView:GetRootLayout()
	return self.mt_layout_root
end

function MainuiView:GetPartLayout(index)
	return self.layout_parts[index]
end

function MainuiView:OpenNearTarget()
	if self.near_view then
		self.near_view:NearOpen()
	end
end

function MainuiView:OnFlush(param_t, index)
	--self:SetFirstChargeShow()
	-- self:SetQiangGouShow()
	--self:SetChargeGfitShow(2)
	--self:TextShow()
end

function MainuiView:GetTask()
	return self.task_bar
end

function MainuiView:GetChat()
	return self.char_bar
end

function MainuiView:GetSmallTip()
	return self.small_tip
end

function MainuiView:GetSmallPart()
	return self.small_part
end

function MainuiView:GetSkillLaout()
	return self.skill_bar
end

function MainuiView:OnGetUiNode(node_name,view_name)
	if node_name == NodeName.MainuiTaskBar then
		if self.task_bar then
			if self.task_bar.mt_layout_task:isVisible() then
				return self.task_bar.mt_layout_task, true
			end
		end
	end

	if node_name == "btn_Bag" then
		return self.small_part:GetBagIcon()
	end

	if node_name == "btn_vip" then
		return self.char_bar:GetVipIcon()
	end

	if node_name == "red_icon" then
		return self.char_bar:GetRedIcon()
	end

	if node_name == "MainuiTaskMain" then
		return self.small_part:GetMainTaskRender()
	end

	if node_name == NodeName.MainuiRoleBar then
		if self.head_bar and self.head_bar.guide_head_layout then
			return self.head_bar.guide_head_layout, true
		end
	end
	if node_name == NodeName.SpecialSkillIcon then
		if self.skill_bar and self.skill_bar.spec_skill then
			return self.skill_bar.spec_skill:GetMtView(), true
		end
	end

	if node_name == "iconbar" then
		if self.icon_bar and view_name then
			
			return self.icon_bar:OnGetUiNode(view_name)
		end
	end

	if node_name == "pk_state" then
		if self.head_bar then
			return self.head_bar:GetBtnState()
		end
	end

	if node_name == "pk_state_shan_e" then
		if self.head_bar then
			return self.head_bar:GetBtnStateShanE()
		end
	end

	if node_name == "shilian_icon" then
		if self.small_part then
			return self.small_part:GetExcIcon()
		end
	end
 
	for k, v in pairs(self.mainui_part_list) do
		if v.OnGetUiNode then
			local node, is_next = v:OnGetUiNode(node_name)
			if nil ~= node then
				return node, is_next
			end
		end
	end
end

function MainuiView:SetHeadAndRightTopVisible(vis)
	if self.head_bar then
		self.head_bar:SetMainRoleHeadVisible(vis)
	end
	if self.right_top then
		self.right_top:SetRigtTopVisble(vis)
	end
	if self.icon_bar then
		self.icon_bar:SetIconVisible(vis)
	end	
end

function MainuiView:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL then
	 	self.change_level = vo.value - vo.old_value
	 	--self.change_num = 0
	 	self:ShowPicture() 
	 	if  not ChargeRewardData.Instance:IsShouChong() and self.cur_num  == 0 and vo.value >= ClientTipXiaoMianBan.FirstChargeLevel then
	 		self.cur_num = self.cur_num + 1
	 		self.icon_bar:ChangeShowState(true)
	 		self:SetFirstChargeShow()
	 	end
	 	-- if OutOfPrintData.Instance:IsShow() and self.change_level > 0 and self.qiang_gou_num == 0 and vo.value >= ClientTipXiaoMianBan.ChaoZhiQianggou.min_level and vo.value <= ClientTipXiaoMianBan.ChaoZhiQianggou.max_level then
	 	-- 	self.qiang_gou_num = self.qiang_gou_num + 1
	 	-- 	self.icon_bar:ChangeShowState(true)
	 	-- 	self:SetQiangGouShow()
	 	-- end
	 	if self.change_level > 0 and self.charge_gift_num == 0 and vo.value == ClientTipXiaoMianBan.ChargeGiftLevel then
	 		self.charge_gift_num = self.charge_gift_num + 1
	 		self.icon_bar:ChangeShowState(true)
	 		local index = ChargeGiftData.Instance:GetGiftGrade()
	 		self:SetChargeGfitShow(index)
	 	end
	end
end

function MainuiView:ShowPicture()
	if self.change_level <= 0 then
		return
	end 	
	if nil == self.layout_show then
		self.layout_show =  XUI.CreateLayout(self.screen_w/2, self.screen_h/2 + 150, 0, 0)
		self.mt_layout_root:TextureLayout():addChild(self.layout_show, 99, 99) 
	end
	

	if self.img == nil then
		self.img = XUI.CreateImageView(0 , 0, ResPath.GetMainUiImg("up_level"), true)
		self.layout_show:addChild(self.img, 999)
	end
	

	if nil == self.tower_level_num then
		self.tower_level_num = NumberBar.New()
		self.layout_show:addChild(self.tower_level_num:GetView(), 300, 300)

		self.tower_level_num:SetRootPath(ResPath.GetMainUiImg("num_111_"))
		self.tower_level_num:SetPosition(65, -90)
		
		self.tower_level_num:SetSpace(-108)
	  	self.tower_level_num:SetGravity(NumberBarGravity.Center)
	end
	
	self.tower_level_num:SetNumber(0)

	self.layout_show:setScale(0.3)
	self.layout_show:setVisible(true)
	local scale_to = cc.ScaleTo:create(ClientUplevelTipTime.scale_time, 1.2)
	local callback = function ()
		self.layout_show:setVisible(false)
	end
	local callback1 = function ( ... )
		self.tower_level_num:SetNumber(self.change_level)
	end

	local delay_time = cc.DelayTime:create(ClientUplevelTipTime.delay_time)
	local queue = cc.Sequence:create(scale_to, cc.CallFunc:create(callback1), delay_time, cc.CallFunc:create(callback))
	self.layout_show:runAction(queue)
end


function MainuiView:ShowTip(p_index)
	if nil == self.layout_show_tip then
		self.layout_show_tip =  XUI.CreateLayout(self.screen_w/2, self.screen_h/2 - 170, 0, 0)
		self.mt_layout_root:TextureLayout():addChild(self.layout_show_tip, 99, 99) 
	end
	local path = ResPath.GetTaskPath("task_finish"..p_index)
	if self.p_img == nil then
		self.p_img = XUI.CreateImageView(0 , 0, path, false)
		self.layout_show_tip:addChild(self.p_img, 999)
	end
	self.p_img:loadTexture(path)
	self.layout_show_tip:setScale(0)

	local scaleTo = cc.ScaleTo:create(ClientTextShowTime.scale_time, 1)

	local callback = function ()
		if self.layout_show_tip then
			self.layout_show_tip:removeFromParent()
			self.layout_show_tip = nil
		end
		self.p_img = nil
	end
	local delay_time = cc.DelayTime:create(ClientTextShowTime.delay_time)
	local queue = cc.Sequence:create(scaleTo,  delay_time, cc.CallFunc:create(callback))
	self.layout_show_tip:runAction(queue)
end


function MainuiView:SetFirstChargeShow()
	local target_node2, bool =  ViewManager.Instance:GetUiNode("MainUi", "iconbar", "ChargeFirst")
	if  nil == target_node2 and bool then return end

	--local target_pos = target_node:convertToWorldSpace(cc.p(0,0))
	-- local pos1 = target_node:convertToNodeSpace(target_pos)
	local screen_w = HandleRenderUnit:GetWidth()
	if nil == self.layout_charge then
		self.layout_charge =  XUI.CreateLayout(45, -150, 0, 0)
		target_node2:EffectLayout():addChild(self.layout_charge, 99, 99) 
	end

	

	if nil == self.charge_img then
		self.charge_img = XUI.CreateImageView(0 , -38, ResPath.GetBigPainting("guide_bg_1"), false)
		self.layout_charge:addChild(self.charge_img, 99)
	end

	if nil == self.arow_bg1 then
		 self.arow_bg1 =  XUI.CreateImageView(0 , 135, ResPath.GetTaskUIPath("mianui_jiantou"), true)
		self.layout_charge:addChild(self.arow_bg1, 999, 999)
	end

	--if self.charge_effect1 == nil then
		if nil == self.charge_effect1 then	
		 	self.charge_effect1 = AnimateSprite:create()
		 	self.charge_effect1:setPosition(10, -58)
		 	self.layout_charge:addChild(self.charge_effect1, 998)
		end
		self.charge_effect1:setScale(0.5)
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(264)
		self.charge_effect1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	--end
	
	if nil == self.charge_effect2 then	
	 	self.charge_effect2 = AnimateSprite:create()
	 	self.charge_effect2:setPosition(50, -68)
	 	self.layout_charge:addChild(self.charge_effect2, 998)
	end
	self.charge_effect2:setScale(0.5)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(139)
	self.charge_effect2:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	

	if self.charge_effect3 == nil then
	 	self.charge_effect3 = AnimateSprite:create()
	 	self.charge_effect3:setPosition(50,67)
	 	self.layout_charge:addChild(self.charge_effect3, 998)
	end
	self.charge_effect3:setScale(0.5)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(212)
	self.charge_effect3:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)


	if self.layout_btn == nil then
		self.layout_btn =  XUI.CreateLayout(0, -20, 290, 370)
		self.layout_charge:addChild(self.layout_btn, 999)
	end

	XUI.AddClickEventListener(self.layout_btn, function ()

		ViewManager.Instance:OpenViewByDef(ViewDef.ChargeFirst)
		if self.layout_charge then
			self.layout_charge:removeFromParent()
			self.layout_charge = nil
		end
		self.charge_img = nil
		self.charge_effect1 = nil
		self.charge_effect2  = nil
		self.charge_effect3 = nil
		self.layout_btn = nil
		self.arow_bg1 = nil
	end)
end

function MainuiView:SetRemoveCharge(view_def)
	
	if view_def == ViewDef.ChargeFirst then
		if self.layout_charge then
			self.layout_charge:removeFromParent()
			self.layout_charge = nil
			self.charge_img = nil
			self.charge_effect1 = nil
			self.charge_effect2  = nil
			self.charge_effect3 = nil
			self.layout_btn = nil
			self.arow_bg1 = nil
		end
	elseif view_def == ViewDef.ChargeGift then
		if self.charge_gift then
			self.charge_gift:removeFromParent()
			self.charge_gift = nil
			self.charge_gift_img = nil
			self.charge_gift_effect1 = nil
			self.arow_bg2 = nil
			self.layout_btn1 = nil
		end
	end
end


function MainuiView:SetQiangGouShow()
	local target_node1, bool =  ViewManager.Instance:GetUiNode("MainUi", "iconbar", "OutOfPrint")

	--print(target_node:getPosi)
	if  nil == target_node1 and bool then return end
	
	--local target_pos = target_node:convertToWorldSpace(cc.p(0,0))
	-- local pos1 = target_node:convertToNodeSpace(target_pos)
	local screen_w = HandleRenderUnit:GetWidth()
	if nil == self.qianggou_charge then
		self.qianggou_charge =  XUI.CreateLayout(45, -150, 0, 0)
		target_node1:EffectLayout():addChild(self.qianggou_charge, 99, 99) 
	end

	if nil == arow_bg then
		arow_bg =  XUI.CreateImageView(0 , 135, ResPath.GetTaskUIPath("mianui_jiantou"), true)
		self.qianggou_charge:addChild(arow_bg, 999, 999)
	end
	if nil == self.qiangou_img then
		self.qiangou_img = XUI.CreateImageView(0 , -38, ResPath.GetBigPainting("guide_bg_2"), true)
		self.qianggou_charge:addChild(self.qiangou_img, 98)
	end

	if nil == self.qianggou_effect1 then	
	 	self.qianggou_effect1 = AnimateSprite:create()
	 	self.qianggou_effect1:setPosition(0, -38)
	 	self.qianggou_charge:addChild(self.qianggou_effect1, 98)
	end
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1164)
	self.qianggou_effect1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	

	XUI.AddClickEventListener(self.qiangou_img, function ()

		ViewManager.Instance:OpenViewByDef(ViewDef.OutOfPrint)
		if self.qianggou_charge then
			self.qianggou_charge:removeFromParent()
			self.qianggou_charge = nil
		end
		self.qiangou_img = nil
		self.qianggou_effect1 = nil
		arow_bg = nil
	end)
end


function MainuiView:SetChargeGfitShow(index)
	local target_node, bool =  ViewManager.Instance:GetUiNode("MainUi", "iconbar", "ChargeGift")

	if  nil == target_node and bool then return end
	--local pos = target_node:getPosition()

	local screen_w = HandleRenderUnit:GetWidth()
	if nil == self.charge_gift then
		self.charge_gift =  XUI.CreateLayout(45, -150, 0, 0)
		target_node:EffectLayout():addChild(self.charge_gift, 99, 99) 
	end
	if nil == self.charge_gift_img then
		self.charge_gift_img = XUI.CreateImageView(0 , -38, ResPath.GetBigPainting("guide_bg_3"), true)
		self.charge_gift:addChild(self.charge_gift_img, 99)
	end
	local path = ResPath.GetBigPainting("guide_bg_3")
	if index == 2 then
		path = ResPath.GetBigPainting("guide_bg_4")
	end
	self.charge_gift_img:loadTexture(path)

	if nil == self.arow_bg2 then
		self.arow_bg2 =  XUI.CreateImageView(0 , 128, ResPath.GetTaskUIPath("mianui_jiantou"), true)
		self.charge_gift:addChild(self.arow_bg2, 999, 999)
	end

	if nil == self.charge_gift_effect1 then	
	 	self.charge_gift_effect1 = AnimateSprite:create()
	 	self.charge_gift_effect1:setPosition(-30, -38)
	 	self.charge_gift:addChild(self.charge_gift_effect1, 100)
	end
	local effect_id = 99
	if index == 2 then
		effect_id = 1071
	end

	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
	self.charge_gift_effect1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	self.charge_gift_effect1:setScale(0.8)

	if self.layout_btn1 == nil then
		self.layout_btn1=  XUI.CreateLayout(0, -20, 290, 370)
		self.charge_gift:addChild(self.layout_btn1, 999)
	end

	XUI.AddClickEventListener(self.charge_gift_img, function ()

		ViewManager.Instance:OpenViewByDef(ViewDef.ChargeGift)
		if self.charge_gift then
			self.charge_gift:removeFromParent()
			self.charge_gift = nil
		end
		self.charge_gift_img = nil
		self.charge_gift_effect1 = nil
		self.arow_bg2 = nil
		self.layout_btn1 = nil
	end)
end


function MainuiView:TextShow()

	-- if nil == layout_show_tip then
	-- 	layout_show_tip =  XUI.CreateLayout(self.screen_w/2, self.screen_h/2 - 170, 0, 0)
	-- 	self.mt_layout_root:TextLayout():addChild(layout_show_tip, 99, 99) 
	-- end
	-- if nil == charge_gift_img then
	-- 	charge_gift_img = XUI.CreateImageView(0 , 0, ResPath.GetBigPainting("guide_bg_3"), true)
	-- 	layout_show_tip:addChild(charge_gift_img, 99)
	-- end
	


end


--使用技能成功播放特效
function MainuiView:OnMainRoleUseSkill(skill_id)
	if skill_id == 122 or skill_id == 123 or skill_id == 124 then
		local effect_id = 1188
		if skill_id  == 123 or skill_id == 124 then
			effect_id = 1189
		end
		if nil == self.layout_show_effect then
			self.layout_show_effect =  XUI.CreateLayout(self.screen_w/2, self.screen_h/2 + 100, 0, 0)
			self.mt_layout_root:TextureLayout():addChild(self.layout_show_effect, 99, 99) 
		end

		if nil == self.skill_effect then	
		 	self.skill_effect = AnimateSprite:create()
		 	self.skill_effect:setPosition(0, 0)
		 	self.layout_show_effect:addChild(self.skill_effect, 98)
		end
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
		self.skill_effect:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
	end
end