-- 影翼预览界面

WingView = WingView or BaseClass(XuiBaseView)

function WingView:InitWingPreview()
	XUI.AddClickEventListener(self.node_t_list.btn_break_hc.node, BindTool.Bind1(self.OnBreakWingHc, self), true)

	self:CreatePhantomDisplay()
	self:CreateWingEquip()
	self:WingPrivireNum()

end

function WingView:DeletPreview()
	self:StopPlay()

	if self.wing_pre_list then
		self.wing_pre_list:DeleteMe()
		self.wing_pre_list = nil
	end

	if self.wing_pre_num then
		self.wing_pre_num:DeleteMe()
		self.wing_pre_num = nil
	end
end

function WingView:OnBreakWingHc()
	self:ChangeToIndex(TabIndex.wing_wing)
	self:StopPlay()
end

function WingView:FlushPreview(param_t)
	local data = WingData.Instance:GetWingEquipData()

	local score = ItemData.Instance:GetItemScoreByData(ItemData.Instance:GetItemConfig(data[self.select_ronghun_slot].item_id))
	if self.wing_pre_num then
		self.wing_pre_num:SetNumber(score)
		self:OnClickPlay()
	end
end

-- 影翼战斗力
function WingView:WingPrivireNum()
	if self.wing_pre_num == nil then
		local ph = self.ph_list.ph_pre_num
		self.wing_pre_num = NumberBar.New()
		self.wing_pre_num:Create(ph.x, ph.y, 180, 40, ResPath.GetCommon("num_121_"))
		self.wing_pre_num:SetGravity(NumberBarGravity.Left)
		self.wing_pre_num:SetSpace(0)
		self.node_t_list.layout_preview.node:addChild(self.wing_pre_num:GetView(), 300, 300)

		local data = WingData.Instance:GetWingPreShow()
		local score = ItemData.Instance:GetItemScoreByData(ItemData.Instance:GetItemConfig(data[self.select_ronghun_slot].item_id))
		self.wing_pre_num:SetNumber(score)
		self:OnClickPlay()
	end
end

-- 创建影翼装备
function WingView:CreateWingEquip()
	if self.wing_pre_list == nil then
		local ph = self.ph_list.ph_wing_pre_list
		self.wing_pre_list = ListView.New()
		self.wing_pre_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, WingPreviewRender, nil, nil, self.ph_list.ph_wing_pre_item)
		self.wing_pre_list:GetView():setAnchorPoint(0, 0)
		self.wing_pre_list:SetItemsInterval(10)
		self.wing_pre_list:SetMargin(2)
		self.wing_pre_list:SetSelectCallBack(BindTool.Bind(self.WingPreEquipCallback, self))
		self.node_t_list.layout_preview.node:addChild(self.wing_pre_list:GetView(), 100)

		local data = WingData.Instance:GetWingPreShow()
	
		self.wing_pre_list:SetDataList(data)
	end	
end

function WingView:WingPreEquipCallback(item, index)
	self.select_ronghun_slot = index
	
	local score = ItemData.Instance:GetItemScoreByData(ItemData.Instance:GetItemConfig(item:GetData().item_id))
	self.wing_pre_num:SetNumber(score)
	-- self:FlushPreview()
	self:OnClickPlay()
end

function WingView:CreatePhantomDisplay()
	self.layout_display = XUI.CreateLayout(270, 280, 500, 500)
	self.layout_display:setClippingEnabled(true)
	self.node_t_list.layout_preview.node:addChild(self.layout_display, 10)

	-- self.btn_play = XUI.CreateButton(250, 270, 0, 0, false, ResPath.GetHallowPic("btn_play"))
	-- self.layout_display:addChild(self.btn_play, 50)
	-- XUI.AddClickEventListener(self.btn_play, BindTool.Bind(self.OnClickPlay, self))

	self.bg_display = XUI.CreateImageView(0, 270, ResPath.GetBigPainting("foot_print_scene", true), false)
	self.bg_display:setAnchorPoint(0, 0.5)
	self.bg_display:setScale(1.12)
	self.layout_display:addChild(self.bg_display)

	self.display_animate = AnimateSprite:create()
	self.display_animate:setPosition(225, 240)
	self.display_animate:addEventListener(BindTool.Bind(self.OnAnimateEvent, self))
	self.display_animate:setIsUpdateCallback(true)
	self.layout_display:addChild(self.display_animate, 20)

	self.role_display = AnimateSprite:create()
	self.role_display:setPosition(250, 240)
	self.layout_display:addChild(self.role_display, 10)
	self:OnClickPlay()
end

function WingView:OnAnimateEvent(sender, event_type, frame)
	if event_type == 2 then
		-- self:StopPlay()
	elseif event_type == 1 then
		if self.bg_display:getPositionX() < -1200 then
			self.bg_display:setPositionX(0)
		end
	end
end

function WingView:OnClickPlay()
	local res_id = self.select_ronghun_slot
	if res_id then
		-- self.btn_play:setVisible(false)
		local anim_path, anim_name = ResPath.GetPhantomAnimPath(res_id, "run", 2)
		self.display_animate:setVisible(true)
		self.display_animate:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Stand, false)

		local move = cc.MoveBy:create(0.016, cc.p(-2, 0))
		self.bg_display:setPosition(0, 270)
		self.bg_display:stopAllActions()
		self.bg_display:runAction(cc.RepeatForever:create(move))

		anim_path, anim_name = ResPath.GetRoleAnimPath(10, "run", 2)

		self.role_display:setVisible(true)
		self.role_display:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Run, false)
	end
end

function WingView:StopPlay()
	if self.btn_play then
		self.btn_play:setVisible(true)
		self.bg_display:stopAllActions()
		self.bg_display:setPosition(0, 270)
		self.role_display:setVisible(false)
		self.display_animate:setVisible(false)
	end
end

-------------------------------------
-- WingPreviewRender 【影翼装备】
-------------------------------------
WingPreviewRender = WingPreviewRender or BaseClass(BaseRender)
function WingPreviewRender:__init()
	self:AddClickEventListener()
end

function WingPreviewRender:__delete()	
	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function WingPreviewRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_equ_cell
	
	if nil == self.cell then
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x, ph.y)
		self.cell:SetIndex(i)
		self.cell:SetAnchorPoint(0.5, 0.5)
		self.view:addChild(self.cell:GetView(), 103)
		-- self.cell:SetIsShowTips(false)
		
		self.cell:SetItemTipFrom(EquipTip.FROM_NORMAL)
	end	
end

function WingPreviewRender:OnFlush()
	if not self.data then return end

	self.cell:SetData(self.data)
end

function WingPreviewRender:CreateSelectEffect()
	
end