--------------------------------------------------------
-- 合服特惠  配置 CombinePreferentialGiftCfg 
--------------------------------------------------------

MergeServerDiscountView = MergeServerDiscountView or BaseClass(BaseView)

function MergeServerDiscountView:__init()
	self.texture_path_list[1] = 'res/xui/open_serve_gift.png'
	self.texture_path_list[2] = "res/xui/vip.png"
	self:SetModal(true)
	self.config_tab = {
		{"open_serve_gift_ui_cfg", 1, {0}},
		{"open_serve_gift_ui_cfg", 3, {0}},
	}

	self.index = nil
	self.type = 1
end

function MergeServerDiscountView:__delete()
end

--释放回调
function MergeServerDiscountView:ReleaseCallBack()
	if nil ~= self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	if nil ~= self.item_list then
		self.item_list:DeleteMe()
		self.item_list = nil
	end

	if nil ~= self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
		self.update_spare_timer = nil
	end
end

--加载回调
function MergeServerDiscountView:LoadCallBack(index, loaded_times)
	self.node_t_list["img_tabbar"].node:loadTexture(ResPath.GetOpenSevGift("merge_server_discount_1"))
	self.tabbar_group = OpenSerVeGiftData.Instance:GetMergeSeverList()
	self:InitTabbar()

	self.item_list = self:CreateItemList()

	RichTextUtil.ParseRichText(self.node_t_list.rich_act_desc.node, Language.MergeServer.Explain, 19)

	-- 按钮监听
	-- XUI.AddClickEventListener(self.node_t_list.layout_xunbao_10.node, BindTool.Bind(self.OnClickXunBaoHandler, self, 2), true)

	-- 数据监听
	EventProxy.New(OpenSerVeGiftData.Instance, self):AddEventListener(OpenSerVeGiftData.MERGE_SERVER_DISCOUNT_INFO_CHANGE, BindTool.Bind(self.OnMergeServerDiscountInfoChange, self))
end

function MergeServerDiscountView:OpenCallBack()
	for i = 1, #CombinePreferentialGiftCfg.giftCfg do
		OpenSerVeGiftCtrl.Instance.SendMergeServerDiscountInfo(i)
	end
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MergeServerDiscountView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if nil ~= self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
		self.update_spare_timer = nil
	end
end

--显示指数回调
function MergeServerDiscountView:ShowIndexCallBack(index)
	self:FlushLeftTime(1)
end
----------视图函数----------

function MergeServerDiscountView:InitTabbar()
	if nil == self.tabbar then
		local tabbar_group = {}
		for i, vdef in ipairs(self.tabbar_group) do
			tabbar_group[#tabbar_group + 1] = vdef.name
		end  

		self.tabbar = ScrollTabbar.New()
		self.tabbar.space_interval_V = 30
		self.tabbar:CreateWithNameList(self.node_t_list["scroll_tabbar"].node, 28, -20,
			BindTool.Bind(self.SelectTabCallback, self), tabbar_group, 
			true, ResPath.GetCommon("toggle_120"))
		-- self.tabbar:GetView():setLocalZOrder(1)
	end

end

function MergeServerDiscountView:SelectTabCallback(index)
	self.type = index
	local data = OpenSerVeGiftData.Instance:GetMergeServerDiscountInfo(self.type)
	self.item_list:SetDataList(data)
	self:FlushLeftTime(self.type)
end

-- 刷新剩余时间
function MergeServerDiscountView:FlushLeftTime(type)
	local left_time = OpenSerVeGiftData.Instance:GetMergeServerDiscountLeftTime(type)
	self.node_t_list.lbl_spare_time.node:setString(TimeUtil.FormatSecond2Str(left_time))
	if nil ~= self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
		self.update_spare_timer = nil
	end
	self.update_spare_timer = GlobalTimerQuest:AddRunQuest(function ()
		local left_time = OpenSerVeGiftData.Instance:GetMergeServerDiscountLeftTime(type)
		self.node_t_list.lbl_spare_time.node:setString(TimeUtil.FormatSecond2Str(left_time))
	end, 1)
end

function MergeServerDiscountView:CreateItemList()
	local ph = self.ph_list.ph_qg_list
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical , self.ItemRender, nil, nil, self.ph_list.ph_qg_item)
	list:SetItemsInterval(4)
	list:SetMargin(2)
	list:SetJumpDirection(ListView.Top)
	self.node_t_list.layout_qinggou.node:addChild(list:GetView(), 300)
	local data = OpenSerVeGiftData.Instance:GetMergeServerDiscountInfo(1)
	list:SetDataList(data)

	return list
end
----------end----------

function MergeServerDiscountView:OnMergeServerDiscountInfoChange()
	local data = OpenSerVeGiftData.Instance:GetMergeServerDiscountInfo(self.type)
	self.item_list:SetDataList(data)
end

----------------------------------------------------
--item render 特惠礼包列表
----------------------------------------------------
MergeServerDiscountView.ItemRender = BaseClass(BaseRender)
local ItemRender = MergeServerDiscountView.ItemRender


function ItemRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_bag_buy.node, BindTool.Bind(self.OnClickBuy, self))

	local vip_level_num = NumberBar.New()
	vip_level_num:SetGravity(NumberBarGravity.Left)
	vip_level_num:SetRootPath(ResPath.GetVipResPath("vip_tequan_num_"))
	vip_level_num:SetPosition(55, 2)
	vip_level_num:SetSpace(-1)
	self.vip_level_num = vip_level_num
	self.node_tree.layout_vip_can_buy.node:addChild(vip_level_num:GetView(), 100, 100)

	local sale_num_cap = NumberBar.New()
	sale_num_cap:SetGravity(NumberBarGravity.Left)
	sale_num_cap:SetRootPath(ResPath.GetVipResPath("vip_tequan_num_"))
	sale_num_cap:SetPosition(6, 97)
	sale_num_cap:SetSpace(7)
	self.sale_num_cap = sale_num_cap
	self.view:addChild(sale_num_cap:GetView(), 100, 100)

	local ph = self.ph_list.ph_award_list
	local list = ListView.New()
	list:Create(ph.x, ph.y+5, ph.w, ph.h + 20, ScrollDir.Horizontal, self.NameCell, nil, nil)
	list:SetItemsInterval(4)
	list:SetMargin(2)
	self.view:addChild(list:GetView(), 3)
	self.award_list = list

	self.stamp_img = XUI.CreateImageView(620, 60, ResPath.GetCommon("stamp_5"))
	self.view:addChild(self.stamp_img, 300)
	self.stamp_img:setVisible(false)
end

function ItemRender:OnClickBuy()
	OpenSerVeGiftCtrl.Instance.SendBuyMergeServerDiscount(self.data.type, self.data.index)
end

function ItemRender:OnFlush()
	if nil == self.data then return end
	self.cfg = CombinePreferentialGiftCfg.giftCfg[self.data.type].GiftLevels[self.data.index] -- 获取配置
	if nil == self.cfg then return end
	local list = {}
	for i,v in ipairs(self.cfg.award) do
		list[i] = ItemData.FormatItemData(v)
	end
	self.award_list:SetDataList(list)

	self.sale_num_cap:SetNumber(self.cfg.discount * 100)

	self.vip_level_num:SetNumber(self.cfg.vipLv)
	self.node_tree.layout_vip_can_buy.node:setVisible(self.cfg.vipLv > 0)

	local is_can_buy = OpenSerVeGiftData.Instance:GetMergeServerBuyTimes(self.data.type, self.data.index) == self.cfg.buyTms
	self.stamp_img:setVisible(is_can_buy)
	self.node_tree.btn_bag_buy.node:setVisible(not is_can_buy)
	self.node_tree.lbl_can_buy.node:setVisible(not is_can_buy)

	-- self.node_tree.img_line.node:setScale(self.data.currMoney.count > 10000 and 8 or 7)
	self.node_tree.label_sale_item_old_cost.node:setString(self.cfg.srcMoney.count)
	self.node_tree.label_sale_item_cost.node:setString(self.cfg.currMoney.count)
	self.node_tree.lbl_can_buy.node:setString("可购买次数: ".. OpenSerVeGiftData.Instance:GetMergeServerBuyTimes(self.data.type, self.data.index) .. "/" .. self.cfg.buyTms)
end

----------------------------------------------------
-- 带名字的cell
----------------------------------------------------

ItemRender.NameCell = BaseClass(BaseCell)
local NameCell = ItemRender.NameCell

function NameCell:__init()
	self.name = GRID_TYPE_BAG
end

function NameCell:__delete()
end

function NameCell:OnFlush(...)
	if BaseCell.OnFlush(self, ...) then
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
		if nil == self.item_name then
			self.item_name = XUI.CreateText(BaseCell.SIZE / 2, - 10, 0, 0, cc.TEXT_ALIGNMENT_CENTER, item_cfg.name, nil, 18)
			self.view:addChild(self.item_name, 300)
		end
		self.item_name:setString(item_cfg.name)
		self.item_name:setColor(Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))
	end

end

function NameCell:CreateSelectEffect()
end

--------------------
