local  ReXueGodDuiHuanPanel =  BaseClass(SubView)

function ReXueGodDuiHuanPanel:__init( ... )
	self.texture_path_list = {
		'res/xui/equipbg.png',
		'res/xui/rexue.png',
	}
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"rexue_god_equip_ui_cfg", 4, {0}},
		--{"common_ui_cfg", 2, {0}, nil, 999},
	}
end


function ReXueGodDuiHuanPanel:__delete( ... )
	-- body
end

function ReXueGodDuiHuanPanel:ReleaseCallBack( ... )
	if self.exchange_grid then
		self.exchange_grid:DeleteMe()
		self.exchange_grid = nil
	end
	if self.show_cell1 then
		self.show_cell1:DeleteMe()
		self.show_cell1 = nil
	end
	if self.cur_attr_list then
		self.cur_attr_list:DeleteMe()
		self.cur_attr_list = nil
	end
	if self.num_bar then
		self.num_bar:DeleteMe()
		self.num_bar = nil
	end

	if self.consume_cell then
		self.consume_cell:DeleteMe()
		self.consume_cell = nil
	end
	self.link_stuff = nil
end

function ReXueGodDuiHuanPanel:LoadCallBack( ... )
	XUI.AddClickEventListener(self.node_t_list.btn_tips.node, BindTool.Bind1(self.OpenTips, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_duihuan.node, BindTool.Bind1(self.SendDuiHuanItem, self), true)

	self:CreateGrid()
	self.select_data = nil
	self:CreateDuiHuanRightShow()
	self:CreateLink()
	self:CreateNumBar()
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
end

function ReXueGodDuiHuanPanel:OpenTips( ... )
	DescTip.Instance:SetContent(Language.DescTip.GodEquipDuiHuanContent, Language.DescTip.GodEquipDuiHuanTitle)
end

function ReXueGodDuiHuanPanel:CreateLink( ... )
	self.link_stuff = RichTextUtil.CreateLinkText("获取碎片", 20, COLOR3B.GREEN)
	local ph = self.ph_list.ph_rich_link
	self.link_stuff:setPosition(ph.x + 50, ph.y)
	self.node_t_list.layout_left_show.node:addChild(self.link_stuff, 99)
	XUI.AddClickEventListener(self.link_stuff, BindTool.Bind1(self.ShowHuoQuTips, self), true)
end

function ReXueGodDuiHuanPanel:SendDuiHuanItem( ... )
	if self.select_data then
		local comsumes = self.select_data.comsumes[1]
		local consume_id = comsumes.id
		local had_count = BagData.Instance:GetItemNumInBagById(consume_id, nil) 
		if  had_count >= comsumes.count then
			BagCtrl.Instance:SendDuiHuanGodEquipReq(self.select_data.index)
		else
			local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[comsumes.id]
			local data = string.format("{reward;0;%d;1}", comsumes.id) .. (ways and ways or "")
			TipCtrl.Instance:OpenBuyTip(data)
		end
	end
end

function ReXueGodDuiHuanPanel:CreateGrid( ... )
	if self.exchange_grid == nil then
		local ph = self.ph_list.ph_grid_list
		local grid_scroll = GridScroll.New()
		grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 2, 120, ExchangeItemRender, ScrollDir.Vertical, false, self.ph_list.ph_grid_item)
		self.exchange_grid = grid_scroll
		self.exchange_grid:SetSelectCallBack(BindTool.Bind1(self.SelectExhangeItemCallBack, self))
		self.node_t_list.layout_duihuan.node:addChild(grid_scroll:GetView(), 2)
		self.exchange_grid:GetView():setAnchorPoint(0,0)
		self.exchange_grid:JumpToTop()
	end
end

function ReXueGodDuiHuanPanel:CreateDuiHuanRightShow( ... )
	if self.show_cell1 == nil then
		local ph = self.ph_list.ph_cell
		self.show_cell1 = BaseCell.New()
		self.show_cell1:GetView():setPosition(ph.x, ph.y)
		self.node_t_list.layout_left_show.node:addChild(self.show_cell1:GetView(), 99)
	end

	if self.consume_cell == nil then
		local ph = self.ph_list.ph_consume_cell
		self.consume_cell = BaseCell.New()
		self.consume_cell:GetView():setPosition(ph.x, ph.y)
		self.node_t_list.layout_left_show.node:addChild(self.consume_cell:GetView(), 99)
	end

	if nil == self.cur_attr_list then
		local ph = self.ph_list.ph_attr_List--获取区间列表
		self.cur_attr_list = ListView.New()
		self.cur_attr_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, ShenBinAttrItem, nil, nil, self.ph_list.ph_attr_item5)
		self.cur_attr_list:SetItemsInterval(5)--格子间距
		self.cur_attr_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_left_show.node:addChild(self.cur_attr_list:GetView(), 20)
		self.cur_attr_list:GetView():setAnchorPoint(0, 0)
	end

end

function ReXueGodDuiHuanPanel:CreateNumBar( ... )
	local ph = self.ph_list.ph_number
	if nil == self.num_bar then
	    self.num_bar = NumberBar.New()
	    self.num_bar:Create(ph.x - 20, ph.y - 10, 0, 0, ResPath.GetCommon("num_133_"))
	    self.num_bar:SetSpace(-8)
	    self.node_t_list.layout_left_show.node:addChild(self.num_bar:GetView(), 101)
	end
end

function ReXueGodDuiHuanPanel:ItemDataListChangeCallback( ... )
	self:FlushRemind()
	self:FlushRight()
end

function ReXueGodDuiHuanPanel:SelectExhangeItemCallBack(item)
	if item == nil or item:GetData() == nil then
		return 
	end
	self.select_data = item:GetData()
	self:FlushRight()
end


function ReXueGodDuiHuanPanel:FlushRight()
	self.show_cell1:SetData({item_id = self.select_data.awards[1].id,num = 1,is_bind = 0})
	local itemConfig = ItemData.Instance:GetItemConfig(self.select_data.awards[1].id)
	local name = itemConfig.name
	self.node_t_list.lbl_equip_name.node:setString(name)
	local attr = itemConfig.staitcAttrs
	local attr_list = RoleData.FormatRoleAttrStr(attr)
	self.cur_attr_list:SetDataList(attr_list)

	local comsumes = self.select_data.comsumes[1]
	local consume_id = comsumes.id
	local consume_cfg = ItemData.Instance:GetItemConfig(consume_id)
	local consume_name = consume_cfg.name
	local had_count = BagData.Instance:GetItemNumInBagById(consume_id, nil) 
	local color = had_count >= comsumes.count and COLOR3B.GREEN or COLOR3B.RED
	-- local text = string.format(Language.ReXueGodEquip.showdesc, color, consume_name, had_count, comsumes.count)
	-- RichTextUtil.ParseRichText(self.node_t_list.rich_consume_show.node, text)
	-- XUI.RichTextSetCenter(self.node_t_list.rich_consume_show.node)
	self.consume_cell:SetData({item_id = consume_id, num = 1,is_bind = 0})
	local text = had_count.."/"..(comsumes.count)
	self.consume_cell:SetRightBottomText(text, color)

	local score =  CommonDataManager.GetAttrSetScore(attr, RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF))
	self.num_bar:SetNumber(score)
end

function ReXueGodDuiHuanPanel:OpenCallBack( ... )
	-- body
end


function ReXueGodDuiHuanPanel:ShowIndexCallBack( ... )
	self:Flush(index)
end

function ReXueGodDuiHuanPanel:OnFlush( ... )

	local data = ReXueGodEquipData.Instance:GetExchangeData()
	if self.exchange_grid then
		self.exchange_grid:SetDataList(data)
		self.exchange_grid:SelectItemByIndex(1)
		self.exchange_grid:JumpToTop()
		self:FlushRemind()
	end
end


function ReXueGodDuiHuanPanel:FlushRemind()
	local data =  self.exchange_grid:GetDataList()
	local items = self.exchange_grid:GetItems()
	for k,v in pairs(items) do
		local vis = ReXueGodEquipData.Instance:GetIsCanDuiHuan(data[k])
		v:SetRemind(vis)
	end
end

function ReXueGodDuiHuanPanel:ShowHuoQuTips( ... )
	local consume = self.select_data.comsumes[1]
	local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[consume.id]
	local data = string.format("{reward;0;%d;1}", consume.id) .. (ways and ways or "")
	TipCtrl.Instance:OpenBuyTip(data)
end



function ReXueGodDuiHuanPanel:CloseCallBack( ... )
	-- body
end

ExchangeItemRender = ExchangeItemRender or BaseClass(BaseRender)
function ExchangeItemRender:__init( ... )
	-- body
end

function ExchangeItemRender:__delete( ... )
	if self.show_cell then
		self.show_cell:DeleteMe()
		self.show_cell = nil
	end
end

function ExchangeItemRender:CreateChild( ... )
	BaseRender.CreateChild(self)
	if self.show_cell == nil then
		local ph = self.ph_list.ph_item
		self.show_cell = BaseCell.New()
		self.show_cell:GetView():setPosition(ph.x, ph.y)
		self.view:addChild(self.show_cell:GetView(), 99)
	end
end

function ExchangeItemRender:OnFlush( ... )
	if self.data == nil then
		return
	end
	self.show_cell:SetData({item_id = self.data.awards[1].id, num = 1,is_bind = 0})
	local config = ItemData.Instance:GetItemConfig(self.data.awards[1].id)
	local name = config.name
	self.node_tree.text_name.node:setString(name)
	self.node_tree.text_name.node:setColor(Str2C3b(string.format("%06x", config.color)))
end


function ExchangeItemRender:SetRemind(vis)
	local path = path or ResPath.GetMainui("remind_flag")
	local size = self.view:getContentSize()
	x = size.width -20
	y = size.height - 20
	if vis and nil == self.remind_bg_sprite then		
		self.remind_bg_sprite = XUI.CreateImageView(x, y, path, true)
		self.remind_bg_sprite:setScale(0.8)
		self.view:addChild(self.remind_bg_sprite, 999, 999)
	elseif self.remind_bg_sprite then
		self.remind_bg_sprite:setVisible(vis)
	end
end



function BaseRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_285"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end


ShenBinAttrItem = ShenBinAttrItem or BaseClass(BaseRender)
function ShenBinAttrItem:__init( ... )
	-- body
end

function ShenBinAttrItem:__delete( ... )
	-- body
end

function ShenBinAttrItem:CreateChild( ... )
	BaseRender.CreateChild(self)
end

function ShenBinAttrItem:OnFlush()
	if self.data == nil then
		return 
	end
	self.node_tree.lbl_attr_name.node:setString(self.data.type_str.."：")
	self.node_tree.lbl_attr_value.node:setString(self.data.value_str)
	 local color = RoleData.Instance:GetAttrColorByType(self.data.type)
	 self.node_tree.lbl_attr_value.node:setColor(color)
	 self.node_tree.lbl_attr_name.node:setColor(color)
end

function ShenBinAttrItem:CreateSelectEffect()

end




return ReXueGodDuiHuanPanel