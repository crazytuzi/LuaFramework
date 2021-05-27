-- 会员礼包

local ZsGiftView = BaseClass(SubView)

function ZsGiftView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/zs_vip.png',
		'res/xui/vip.png',
	}
	self.config_tab = {
		{"zs_vip_ui_cfg", 6, {0}},
	}
	
	self.cy_num = 0
end

function ZsGiftView:ReleaseCallBack()

end

function ZsGiftView:LoadCallBack(index, loaded_times)
	self:CreateGiftGrid()

	XUI.AddClickEventListener(self.node_t_list.btn_onkill.node, BindTool.Bind2(self.OnBossKlii, self))
	-- XUI.AddClickEventListener(self.node_t_list.btn_ques2.node, BindTool.Bind2(self.OpenTip, self))

	XUI.AddClickEventListener(self.node_t_list.btn_turnleft.node, BindTool.Bind2(self.OnBtnLeft, self))
	XUI.AddClickEventListener(self.node_t_list.btn_turnright.node, BindTool.Bind2(self.OnBtnRight, self))
	-- self.node_t_list.img_remind_l.node:setVisible(false)
	-- self.node_t_list.img_remind_r.node:setVisible(false)

	-- EventProxy.New(ChiYouData.Instance, self):AddEventListener(ChiYouData.CHIYOU_BOSS_NUM, BindTool.Bind(self.OnChiyouNum, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.Flush, self))--监听背包变化

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	ZsVipData.Instance:AddEventListener(ZsVipData.INFO_CHANGE, function ()
		self:Flush()
	end)
	self:UpdateBtnState()
end

function ZsGiftView:OpenTip( ... )
	DescTip.Instance:SetContent(Language.DescTip.CHiYouContent, Language.DescTip.CHiYouTitle)
end

function ZsGiftView:RoleDataChangeCallback(vo)
	local key = vo.key
	if key == OBJ_ATTR.ACTOR_CUTTING_LEVEL then
		-- self.node_t_list.lbl_vip_level.node:setString(self.data:GetZsVipLv())
		self:Flush()
	elseif key == OBJ_ATTR.ACTOR_MAX_EXP_L or OBJ_ATTR.ACTOR_MAX_EXP_H then
		self:Flush()
	end
end

function ZsGiftView:CreateGiftGrid()
	local ph = self.ph_list.ph_gift_list
	local cell_num = #SVipConfig.SVipGrade
	if nil == self.gift_grid  then
		self.gift_grid = BaseGrid.New() 
		self.gift_grid:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
		local grid_node = self.gift_grid:CreateCells({w = ph.w, h = ph.h, itemRender = ZsGiftRender, ui_config = self.ph_list.ph_gift_panel, cell_count = cell_num, col = 1, row = 1})
		self.node_t_list.layout_gift.node:addChild(grid_node, 10)
		self.gift_grid:GetView():setPosition(ph.x, ph.y)
		self.gift_grid:ChangeToPage(ZsVipData.Instance:GetCanLingquPage() or 1)
	end
	self:AddObj("gift_grid")
end

function ZsGiftView:OnPageChangeCallBack()
	self:UpdateBtnState()
end

-- 左边按钮点击
function ZsGiftView:OnBtnLeft()
	local index = self.gift_grid:GetCurPageIndex() or 0
	if index > 1 then
		self.gift_grid:ChangeToPage(index - 1)
	end
	self:UpdateBtnState()
end

-- 右边按钮点击
function ZsGiftView:OnBtnRight()
	local index = self.gift_grid:GetCurPageIndex() or 0
	if index < self.gift_grid:GetPageCount() then
		self.gift_grid:ChangeToPage(index + 1)
	end
	self:UpdateBtnState()
end

function ZsGiftView:UpdateBtnState()
	self.node_t_list.btn_turnleft.node:setVisible(not (self.gift_grid:GetCurPageIndex() == 1))
	self.node_t_list.btn_turnright.node:setVisible(not (self.gift_grid:GetCurPageIndex() == self.gift_grid:GetPageCount()))

	self.node_t_list.img_remind_l.node:setVisible(ZsVipData.Instance:GetCanLingquLeft(self.gift_grid:GetCurPageIndex()))
    self.node_t_list.img_remind_r.node:setVisible(ZsVipData.Instance:GetCanLingquRight(self.gift_grid:GetCurPageIndex()))

end

function ZsGiftView:ShowIndexCallBack(index)
	self:Flush()
end

function ZsGiftView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ZsGiftView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ZsGiftView:OnFlush(param_t, index)
    local datas, index = {}, 0
    for i,v in ipairs(SVipConfig.SVipGrade) do
    	datas[index] = v
    	index = index + 1
    end
	self.gift_grid:SetDataList(datas)
end

function ZsGiftView:OnBossKlii()
	ViewManager.Instance:OpenViewByDef(ViewDef.NewlyBossView.Rare.VipBoss)
end

ZsGiftRender = ZsGiftRender or BaseClass(BaseRender)
function ZsGiftRender:__init()
	
end

function ZsGiftRender:__delete()
	self.zs_num = nil
	self.th_num = nil

	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end
end

function ZsGiftRender:CreateChild()
	BaseRender.CreateChild(self)
	
	self:CreatNum()
	self:CreateAwardList()

	XUI.AddClickEventListener(self.node_tree.btn_lingqu.node, BindTool.Bind2(self.OnBtnLingqu, self))
	XUI.AddClickEventListener(self.node_tree.btn_buy.node, BindTool.Bind2(self.OnBtnBuy, self))
end

function ZsGiftRender:CreatNum()
	local ph = self.ph_list["ph_zs_num"]
	self.zs_num = NumberBar.New()
	self.zs_num:SetRootPath(ResPath.GetCommon("num_211_"))
	self.zs_num:SetPosition(ph.x+30, ph.y+2)
	self.zs_num:SetGravity(NumberBarGravity.Center)
	self.view:addChild(self.zs_num:GetView(), 300, 300)
	-- self:AddObj("layer_num")

	ph = self.ph_list["ph_th_num"]
	self.th_num = NumberBar.New()
	self.th_num:SetRootPath(ResPath.GetCommon("num_211_"))
	self.th_num:SetPosition(ph.x+30, ph.y+1)
	self.th_num:SetGravity(NumberBarGravity.Center)
	self.view:addChild(self.th_num:GetView(), 300, 300)
	-- self:AddObj("layer_num")
end

function ZsGiftRender:CreateAwardList()
	local ph = self.ph_list["ph_zsgift_list"]
	local ph_item = {w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.view
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, BaseCell, ScrollDir.Horizontal, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.zs_award_list = grid_scroll

	ph = self.ph_list["ph_thgift_list"]
	local ph_item = {w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.view
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, BaseCell, ScrollDir.Horizontal, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.th_award_list = grid_scroll
end

function ZsGiftRender:OnFlush()
	if nil == self.data then return end

	-- self.zs_num:SetNumber(50000)
	local zs_lv = ZsVipData.Instance:GetZsVipLv()
	self.th_num:SetNumber(self.data.buyGift.valueYb)
	
	local btn_state = ZsVipData.Instance:GetIsCanFreeLingQuByLv(self.index+1)
	local is_free_lingqu = ZsVipData.Instance:GetIsFreeLingQuByLv(self.index+1)
    local is_buy = ZsVipData.Instance:GetIsBuyLingQuByLv(self.index+1)
	self.node_tree.btn_lingqu.node:setEnabled(not is_free_lingqu and not (zs_lv <= self.index))
	self.node_tree.btn_lingqu.node:setTitleText(is_free_lingqu and "已领取" or "领 取")
	self.node_tree.btn_buy.node:setEnabled(not is_buy and not (zs_lv <= self.index))
	self.node_tree.btn_buy.node:setTitleText(is_buy and "已购买" or "购 买")
	self.node_tree.img_remind_lingqu.node:setVisible(btn_state)
	self.node_tree.lbl_gold_num.node:setString(SVipConfig.SVipGrade[self.index+1].buyGift.consume[1].count)

	local show_jieshu = math.ceil((self.index+1) / ZsVipView.ENUM_JIE)
    local show_lv = (self.index+1) % ZsVipView.ENUM_JIE
    show_lv = show_lv == 0 and ZsVipView.ENUM_JIE or show_lv
    self.node_tree.img_txt.node:loadTexture(ResPath.GetZsVip("txt_" .. show_jieshu))
    self.node_tree.img_num.node:loadTexture(ResPath.GetZsVip("hz_" .. show_lv))
    self.node_tree.img_txt1.node:loadTexture(ResPath.GetZsVip("txt_" .. show_jieshu))
    self.node_tree.img_num1.node:loadTexture(ResPath.GetZsVip("hz_" .. show_lv))

    local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local item = {}
	for k, v in pairs(self.data.reward) do
		if v.sex == -1 or v.sex == sex then
			local vo = {item_id = v.id, num = v.count, is_bind = v.bind}
			table.insert(item, vo)
		end
	end
	self.zs_award_list:SetDataList(item)

	local item1 = {}
	for k1, v1 in pairs(self.data.buyGift.award) do
		if v1.sex == -1 or v1.sex == sex then
			local vo1 = {item_id = v1.id, num = v1.count, is_bind = v1.bind}
			table.insert(item1, vo1)
		end
	end
	self.th_award_list:SetDataList(item1)
end

function ZsGiftRender:OnBtnLingqu()
	ZsVipCtrl.SendZsVipGetAwardReq(1, self.index+1)
end

function ZsGiftRender:OnBtnBuy()
	if self.alert == nil then
		self.alert = Alert.New()
	end
	-- self.alert:SetShowCheckBox(true)
	self.alert:SetLableString(string.format(Language.ZsVip.Tip3, SVipConfig.SVipGrade[self.index+1].buyGift.consume[1].count))
	self.alert:SetOkFunc(function ()	
		ZsVipCtrl.SendZsVipGetAwardReq(2, self.index+1)
  	end)
	self.alert:Open()
end

function ZsGiftRender:CreateSelectEffect()
end

return ZsGiftView