SuperExchangeView = SuperExchangeView or BaseClass(ActBaseView)

function SuperExchangeView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function SuperExchangeView:__delete()
	if nil~=self.grid_sp_exc_scroll_list then
		self.grid_sp_exc_scroll_list:DeleteMe()
	end
	self.grid_sp_exc_scroll_list = nil
end

function SuperExchangeView:InitView()
	self:CreateSupExcGridScroll()
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
end

function SuperExchangeView:ShowIndexView()
	self.grid_sp_exc_scroll_list:SetDataList(ActivityBrilliantData.Instance:GetSuperExchangeList())
	self.grid_sp_exc_scroll_list:JumpToTop()
end

function SuperExchangeView:RefreshView(param_list)
	self:FlushShow()
end

function SuperExchangeView:ItemDataListChangeCallback()
	self:FlushShow()
end

--登陆奖励
function SuperExchangeView:CreateSupExcGridScroll()
	if nil == self.grid_sp_exc_scroll_list then
		local ph = self.ph_list.ph_items_list
		self.grid_sp_exc_scroll_list = GridScroll.New()
		self.grid_sp_exc_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 3, 170, SuperExchangeRender, ScrollDir.Vertical, false, self.ph_list.ph_sp_exc_list)
		self.node_t_list.layout_super_exchange.node:addChild(self.grid_sp_exc_scroll_list:GetView(), 100)
		--self.grid_sp_exc_scroll_list:JumpToTop()
	end
	
end

function SuperExchangeView:FlushShow( ... )
	local list = ActivityBrilliantData.Instance:GetSuperExchangeList()
	local consume = list[1].consume[1]
	local text1 = "当前拥有："
	if consume.type > 0 then
		local item_id = tagAwardItemIdDef[consume.type]
		local path =  RoleData.GetMoneyTypeIconByAwardType(consume.type)
		local is_show_tips = consume.type > 0 and 0 or 1
		local scale = consume.type > 0 and 1 or 0.5

		local num_s = RoleData.Instance:GetMainMoneyByType(consume.type)
		text1 = text1 .. string.format(Language.Bag.ComposeTip3, path,"20,20", scale, consume.id, 0, num_s)
	else
		local item_cfg = ItemData.Instance:GetItemConfig(consume.id)
		local path = ResPath.GetItem(item_cfg.icon)
		local num_s = BagData.Instance:GetItemNumInBagById(consume.id)
		text1 = text1 .. string.format(Language.Bag.ComposeTip3, path,"20,20", 0.5, consume.id, 1, num_s)
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_consume2_show.node, text1)
end