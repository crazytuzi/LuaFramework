-- 
WingView = WingView or BaseClass(BaseView)
function WingView:__init()
	self.title_img_path = ResPath.GetWord("word_wing")
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.def_index = 1

	self.texture_path_list[1] = "res/xui/wing.png"
	self.texture_path_list[2] = "res/xui/hallow.png"
	self.texture_path_list[3] = "res/xui/wangchengzhengba.png"
	self.texture_path_list[4] = "res/xui/zhanjiang.png"
	self.texture_path_list[5] = "res/xui/role.png"

	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
		{"wing_ui_cfg", 1, {0}},
		{"wing_ui_cfg", 2, {TabIndex.wing_wing}},
		{"wing_ui_cfg", 6, {TabIndex.wing_compound}},
		{"wing_ui_cfg", 7, {TabIndex.wing_preview}},
	}

	GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindUpChange, self))
	self.remind_temp = {}
	self.select_ronghun_slot = 1

	self.door = WindDoorModal.New()
	self.door:BindClickActBtnFunc(BindTool.Bind(self.OnClickWingActivateHandler, self))

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
    -- GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind1(self.PassDayCallBack, self))
end

function WingView:__delete()
end

function WingView:ReleaseCallBack()
	self:DeleteWingView()

	self.door:Release()

	self:DeletCompound()
	self:DeletPreview()
end

function WingView:LoadCallBack(index, loaded_times)
	self:WingEquipBtn()
	if index == TabIndex.wing_wing then
		self:InitWingView()
	elseif index == TabIndex.wing_compound then
		self:InitWingCompound()
	elseif index == TabIndex.wing_preview then
		self:InitWingPreview()
	end
end

function WingView:RemindUpChange(remind_name, num)
	if remind_name == RemindName.WingStone then
		self.remind_temp[1] = num
		self:Flush(TabIndex.wing_wing,"wingstone") 
	elseif remind_name == RemindName.WingUpgrade then
		self.remind_temp[2] = num
		self:Flush(TabIndex.wing_wing,"wingupgrade")
	end
end

function WingView:PassDayCallBack()
	self:WingEquipBtn()
end

-- 按钮显示
function WingView:WingEquipBtn()
	-- 翅膀合成按钮显示
	local open_cond = "CondId57"
	local vis = GameCondMgr.Instance:GetValue(open_cond)
	self.node_t_list.layout_shenyu.node:setVisible(vis)

	-- 翅膀装备显示
	local equ_vis = WingData.GetNewWingIsOpen()
	self.node_t_list.layout_wing_equ.node:setVisible(equ_vis)
end

function WingView:ShowIndexCallBack(index)
	self:Flush(index)
	self.node_t_list.layout_wing.node:setVisible(index == TabIndex.wing_wing)
end
	
function WingView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()

	local show_door = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_LEVEL) == 0

	self.door:SetVis(show_door, self:GetRootNode())
	if show_door then
		self.door:CloseTheDoor()
	end
end

function WingView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self:SetAutoUpWing(false)
end

function WingView:OnFlush(param_t, index)
	if index == TabIndex.wing_wing then
		self:OnFlushWingView(param_t)
	elseif index == TabIndex.wing_compound then
		self:FlushCompound(param_t)
	elseif index == TabIndex.wing_preview then
		self:FlushPreview()
		self.node_t_list.layout_wing.node:setVisible(true)
	end
	self:WingEquipBtn()
end

function WingView:ItemDataListChangeCallback(change_type, item_id, item_index, series)
	self:Flush(TabIndex.wing_wing, "baglist_change", {[item_index or 999] = {change_type = change_type, item_id = item_id, item_index = item_index, series = series}})
	if item_id == 493 or item_id == 494 or item_id == 495 then
		RemindManager.Instance:DoRemind(RemindName.WingStone)
	elseif item_id == 467 or item_id == 468 or item_id == 469 or item_id == 470 then
		RemindManager.Instance:DoRemind(RemindName.WingUpgrade)
	end
	self:Flush()
end

function WingView:OnCloseHandler()
	self:CloseHelper()
end

function WingView:ItemConfigCallback(item_config_t)
	self:Flush(self:GetShowIndex())
end

------------------------------------------------------------------------------
WindDoorModal = WindDoorModal or BaseClass(DoorModal)

function WindDoorModal:__init()
end

function WindDoorModal:__delete()
end

function WindDoorModal:Release()
	WindDoorModal.super.Release(self)

	if nil ~= self.prog_eff then
		self.prog_eff:DeleteMe()
		self.prog_eff = nil
	end
end

function WindDoorModal:CreateDoor()
	if self.is_created or nil == self.parent_node then
        return
    end
    self.is_created = true

    self.view = XUI.CreateLayout(598, 400, 936, 673)
    self.parent_node:addChild(self.view, 800)
    self.view:setClippingEnabled(true)

    local size = self.view:getContentSize()
    self.left_door = XUI.CreateImageView(0, 0, ResPath.GetBigPainting("door_left_img2", false))
    self.left_door:setTouchEnabled(true)
    self.left_door:setAnchorPoint(0, 0)
    self.left_door:setIsHittedScale(false)
    -- local wing_img = XUI.CreateImageView(size.width / 2 - 90, size.height / 2 + 30, ResPath.GetBigPainting("door_img1"))
    -- wing_img:setAnchorPoint(0, 0.5)
    -- wing_img:setScaleX(-1)
    -- self.left_door:addChild(wing_img)

    self.right_door = XUI.CreateImageView(size.width, 0, ResPath.GetBigPainting("door_right_img2", false))
    self.right_door:setTouchEnabled(true)
    self.right_door:setAnchorPoint(1, 0)
    self.right_door:setIsHittedScale(false)
    -- wing_img = XUI.CreateImageView(90, size.height / 2 + 30, ResPath.GetBigPainting("door_img1"))
    -- wing_img:setAnchorPoint(0, 0.5)
    -- wing_img:setScaleX(1)
    -- self.right_door:addChild(wing_img)

    local btn_x, btn_y = size.width / 2 + 0, size.height / 2 - 210
    self.act_btn = XUI.CreateButton(btn_x, btn_y, 0, 0, false,
		ResPath.GetCommon("btn_103"), ResPath.GetCommon("btn_103"), "", XUI.IS_PLIST)
	self.act_btn:setTitleText("激活羽翼")
	self.act_btn:setTitleFontSize(22)
	self.act_btn:setTitleFontName(COMMON_CONSTS.FONT)
	self.act_btn:setTitleColor(COLOR3B.G_W2)
    XUI.AddClickEventListener(self.act_btn, BindTool.Bind(self.OnClickAckBtn, self), true)

    self.progress_eff = XUI.CreateLayout(size.width / 2, size.height / 2 - 190, 320, 0)
    self.progress_eff:setAnchorPoint(0.5, 0)
    self.progress_eff:setClippingEnabled(true)
    RenderUnit.CreateEffect(308, self.progress_eff, 11, nil, nil, 160 + 4, 160 - 27)
    self.progress_eff.setPercent = function(obj, percent)
    	obj:setContentWH(320, percent / 100 * 320)
    end
    self.prog_eff = ProgressBar.New()
    self.prog_eff:SetView(self.progress_eff)
    self.prog_eff:SetPercent(0)
    self.prog_eff:SetUpdateCallback(BindTool.Bind(self.ProgEffUpdate, self))

    self.view:addChild(self.left_door, 10)
    self.view:addChild(self.right_door, 10)
    self.view:addChild(self.act_btn, 20)
    self.view:addChild(self.progress_eff, 11)

    self:CloseTheDoor() -- 创建好后默认进入关闭状态
end

function WindDoorModal:ProgEffUpdate()
	-- not self.act_btn:isVisible()
	if self.prog_eff:GetCurPercent() < 80 then
		return
	end

	self.prog_eff:GetView():setVisible(false)

	local size = self.view:getContentSize()
    local end_func = cc.CallFunc:create(BindTool.Bind(self.OnDoorOpenEnd, self))
    self.left_door:runAction(cc.MoveTo:create(0.8, cc.p(- size.width / 2, 0)))
    self.right_door:runAction(cc.Sequence:create(cc.MoveTo:create(0.8, cc.p(size.width + size.width / 2, 0)), end_func))

    local size = self.view:getContentSize()
    RenderUnit.PlayEffectOnce(307, self.view, 999, size.width / 2, size.height / 2 - 6, true, nil, FrameTime.Effect * 0.7)
end

-- 开门 有动作 并隐藏激活按钮
function WindDoorModal:OpenTheDoor()
    if not self.is_created then
        return
    end
    self.door_state = DoorModal.OPENING

    self.prog_eff:SetPercent(100)
end
