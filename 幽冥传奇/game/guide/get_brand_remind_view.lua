-- 获得翻牌机会
GetBrandRemindView = GetBrandRemindView or BaseClass(BaseView)

function GetBrandRemindView:__init()
	self.texture_path_list = {
		"res/xui/penglai_fairyland.png",
	}

	self.zorder = COMMON_CONSTS.PANEL_MAX_ZORDER
	self.root_x, self.root_y = 0, 0
	self.new_skill_data = nil
end

function GetBrandRemindView:__delete()
end

function GetBrandRemindView:ReleaseCallBack()
	self.brand_bg = nil
end

function GetBrandRemindView:OpenCallBack()
end

function GetBrandRemindView:CloseCallBack(is_all)
	if self.delay_set_timer then
		GlobalTimerQuest:CancelQuest(self.delay_set_timer)
		self.delay_set_timer = nil
	end
end

local layout_w, layout_h = 0, 0
function GetBrandRemindView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()

		self.root_x, self.root_y = screen_w * 0.5, 300
		self.root_node:setPosition(self.root_x, self.root_y)
		self.root_node:setContentWH(layout_w, layout_h)

		self.brand_bg = XUI.CreateImageView(0, 25, ResPath.GetPengLaiFairyland("brand_0"), true)
		self.brand_bg:setScale(0.6)
		self.root_node:addChild(self.brand_bg, 10)
		local sprite = self.brand_bg:getRenderer()
		XUI.MakeGlow(sprite, true)

		XUI.AddClickEventListener(self.brand_bg, BindTool.Bind(self.OnClickBg, self))
	end
end

function GetBrandRemindView:ShowIndexCallBack()
	self.root_node:setPosition((HandleRenderUnit:GetWidth() - MainuiChat.width) / 2 + 200, MainuiChat.height)
	self.root_node:setOpacity(0)
	
	self:SetViewTouchEnabled(false)
	local move_to = cc.MoveTo:create(0.2, cc.p((HandleRenderUnit:GetWidth() - MainuiChat.width) / 2 + 200, MainuiChat.height + 100))
	local fade_in = cc.FadeIn:create(0.2)
	local spawn = cc.Spawn:create(move_to, fade_in)
	local sequence = cc.Sequence:create(spawn, cc.CallFunc:create(function()
		self:SetViewTouchEnabled(true)
	end))
	self.root_node:runAction(sequence)

	if self.delay_set_timer then
		GlobalTimerQuest:CancelQuest(self.delay_set_timer)
	end
	self.delay_set_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnAutoSetSkillToBar,self), 3)

	self:Flush()
end

function GetBrandRemindView:OnFlush(param_t, index)
	self.brand_bg:setVisible(true)
	if nil == self.new_skill_data then
		return
	end
end

function GetBrandRemindView:AutoOpen()
	if self.new_skill_data and self:IsOpen() then
		return
	end

	self:Open()
end

function GetBrandRemindView:OnClickBg()
	-- ViewManager.Instance:Open(ViewName.CrossBattle, TabIndex.crossbattle_brand)
	ViewManager.Instance:OpenViewByDef(ViewDef.PengLaiFairyland.LuckyFlopSub)
	self:Close()
end

function GetBrandRemindView:SetViewTouchEnabled(enabled)
	if self.brand_bg then
		self.brand_bg:setTouchEnabled(enabled)
	end
end

function GetBrandRemindView:OnAutoSetSkillToBar()
	self:FlyBrand()
	self:Close()
end

function GetBrandRemindView:Close()
	if self.delay_set_timer then
		GlobalTimerQuest:CancelQuest(self.delay_set_timer)
		self.delay_set_timer = nil
	end
	if not self:IsOpen() then
		return
	end

	self:SetViewTouchEnabled(false)
	XuiBaseView.Close(self)
end

function GetBrandRemindView:FlyBrand()
	local mainui_view = ViewManager.Instance:GetView(ViewDef.MainUi)
	-- local brand_tip = mainui_view:GetChat() -- :GetTipIcon(MAINUI_TIP_TYPE.FREE_CROSSBRAND, true)
	local brand_tip = mainui_view:GetPartLayout(MainuiView.LAYOUT_PART.BOTTOM_CENTER)
	if nil == brand_tip then
		return
	end

	local node_x, node_y = self.brand_bg:getPosition()
	local node_world_pos = self.root_node:convertToWorldSpace(cc.p(node_x, node_y))
	self.brand_bg:setVisible(false)

	local brand_bg = XUI.CreateImageView(node_world_pos.x, node_world_pos.y, ResPath.GetPengLaiFairyland("brand_0"), true)
	brand_bg:setScale(0.6)
	HandleRenderUnit:AddUi(brand_bg, layer or COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)

	-- local target_view_node = brand_tip:GetView()
	local target_view_node = brand_tip:TextureLayout()
	local target_size = target_view_node:getContentSize()
	local target_world_pos = cc.p(target_size.width / 2, target_size.height / 2)-- target_view_node:AnyLayout():convertToWorldSpace(cc.p(target_size.width / 2, target_size.height / 2))

	local move_to = cc.MoveTo:create(0.7, cc.p(target_world_pos.x, target_world_pos.y))
	local fade_out = cc.FadeOut:create(0.2)
	local callback2 = cc.CallFunc:create(function()
		if brand_bg.removeFromParent then
			brand_bg:removeFromParent()
		end
	end)
	local callback1 = cc.CallFunc:create(function()
	end)
	local action = cc.Sequence:create(cc.Spawn:create(move_to, cc.ScaleTo:create(0.7, 0.2)), callback1, fade_out, callback2)
	brand_bg:runAction(action)
end
