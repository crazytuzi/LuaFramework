AttrView = AttrView or BaseClass()

function AttrView:__init(item_width, item_height, font_size, item_bg, is_scale9, cap_rect)
	self.view = XUI.CreateScrollView(0, 0, 0, 0, ScrollDir.Vertical)
	self.view:setAnchorPoint(0, 1)
	-- self.view:getInnerContainer():setBackGroundColor(COLOR3B.BLACK)
	self.item_list = {}
	self.attr_str_list = {}
	self.attr_cfg = nil
	self.plus_cfg = nil
	self.def_title = ""
	self.bg_is_scale9 = false

	-- 默认属性
	self.item_width = item_width or 0
	self.item_height = item_height or 0
	self.type_str_color = "f5f3df"			-- 属性标题颜色
	self.value_str_color = "f5f3df"			-- 属性值颜色
	self.up_str_color = "1eff00"			-- 提升属性颜色
	self.font_size = font_size
	self.item_interval = 2
	self.item_bg = item_bg
	self.is_scale9 = is_scale9
	self.cap_rect = cap_rect or cc.rect(0, 0, 0, 0)
	self.horizontal_align = RichHAlignment.HA_CENTER
	self.vertical_align = RichVAlignment.VA_CENTER
end

function AttrView:__delete()
	self.view = nil
	if self.item_list then
		for k, v in pairs(self.item_list) do
			v:DeleteMe()
		end
		self.item_list = nil
	end
	self.attr_str_list = nil
	self.attr_cfg = nil
	self.img_bg = nil
end

function AttrView:GetView()
	return self.view
end

function AttrView:SetData(attr_cfg, plus_cfg)
	self.attr_cfg = attr_cfg
	self.plus_cfg = plus_cfg
	self:Flush()
end

function AttrView:GetData()
	return self.attr_cfg, self.plus_cfg
end

function AttrView:SetContentWH(w, h)
	self.view:setContentWH(w, h)
	self.fix_size = true
end

function AttrView:SetColor(type_str_color, value_str_color, up_str_color)
	self.type_str_color = type_str_color
	self.value_str_color = value_str_color
	self.up_str_color = up_str_color
	self:Flush()
end

-- 设置view的背景
function AttrView:SetBackground(path, is_scale9, cap_rect)
	self.bg_is_scale9 = is_scale9
	if self.img_bg == nil then
		if is_scale9 then
			self.img_bg = XImage:create9Sprite(path, cap_rect or cc.rect(0, 0, 0, 0))
		else
			self.img_bg = XImage:create(path)
		end
		self.view:addChild(self.img_bg)
	end
	self.img_bg:loadTexture(path)
end

-- 设置Item间隔
function AttrView:SetItemInterval(interval)
	self.item_interval = interval
	self:Flush()
end

-- 当attr_cfg为空的时候显示
function AttrView:SetDefTitleText(title)
	self.def_title = title
end

function AttrView:SetTextAlignment(ha, va)
	self.horizontal_align = ha
	self.vertical_align = va
end

function AttrView:Flush()
	-- 格式化数据
	self.attr_str_list = {}
	if self.attr_cfg then
		local attr_data = RoleData.FormatRoleAttrStr(self.attr_cfg)
		local plus_data = self.plus_cfg and RoleData.FormatRoleAttrStr(self.plus_cfg)
		for k, v in pairs(attr_data) do
			local str = string.format( "{wordcolor;%s;%s: }{wordcolor;%s;%s}", v.type_color or self.type_str_color, v.type_str, v.value_color or self.value_str_color, v.value_str)

			if plus_data then
				for k1, v1 in pairs(plus_data) do
					if v1.type_str == v.type_str then
						str = str .. string.format( "{wordcolor;%s;↑%s}", self.up_str_color, v1.value_str )
					end
				end
			end

			table.insert( self.attr_str_list, str )
		end
	else
		table.insert( self.attr_str_list, self.def_title )
	end
	-- if self.attr_cfg and self.plus_cfg then
	--	  local plus_data = RoleData.FormatRoleAttrStr(self.plus_cfg)
	--	  for k, v in pairs(plus_data) do
			
	--			local str = self.attr_str_list[k]
	--			self.attr_str_list[k] = str .. string.format( "{wordcolor;%s;↑%s}", self.up_str_color, v.value_str )
	--	  end
	-- end
	-- 增删item
	local old_count = #self.item_list
	local new_count = #self.attr_str_list
	if old_count < new_count then
		for i = 1, new_count - old_count do
			local item_view = AttrItemView.New(self.item_width, self.item_height, self.font_size, self.item_bg, self.is_scale9, self.cap_rect)
			item_view:SetTitleTextAlignment(self.horizontal_align, self.vertical_align)
			self.view:addChild(item_view:GetView(), 50)
			table.insert(self.item_list, item_view)
		end
	elseif old_count > new_count then
		for i = 1, old_count - new_count do
			local item_view = table.remove( self.item_list, #self.item_list )
			self.view:removeChild(item_view:GetView())
		end
	end
	-- 刷新视图
	self:OnFlush()
end

function AttrView:OnFlush()
	local count = #self.item_list
	if not self.fix_size then
		self.view:setContentWH(self.item_width, self.item_height * count + (count - 1) * self.item_interval)
	end
	local size = self.view:getContentSize()
	if self.img_bg then
		self.img_bg:setPosition(size.width / 2, size.height / 2)
		if self.bg_is_scale9 then
			self.img_bg:setContentWH(size.width, size.height)
		end
	end
	self.view:setInnerContainerSize(cc.size(self.item_width, self.item_height * count + (count - 1) * self.item_interval))
	size = self.view:getInnerContainerSize()
	for i = 1, #self.attr_str_list do
		local item = self.item_list[i]
		item:SetTitleText(self.attr_str_list[i])
		local y = size.height - (self.item_interval + self.item_height) * (i - 1)
		item:GetView():setPosition(0, y)
	end
	self.view:jumpToTop()
end


-- 属性Item项
AttrItemView = AttrItemView or BaseClass()
function AttrItemView:__init(width, height, font_size, bg, is_scale9, cap_rect)
	self.view = XLayout:create()
	self.view:setAnchorPoint(0, 1)
	self.view:setContentWH(width, height)

	self.width = width
	self.height = height
	self.font_size = font_size or 20

	self:SetBackground(bg, is_scale9, cap_rect)
end

function AttrItemView:__delete()
	self.view = nil
	self.img_bg = nil
	self.title_txt = nil
end

function AttrItemView:GetView()
	return self.view
end

function AttrItemView:SetBackground(path, is_scale9, cap_rect)
	if self.img_bg == nil and path ~= nil then
		if is_scale9 then
			self.img_bg = XImage:create9Sprite(path, cap_rect or cc.rect(0, 0, 0, 0))
			self.img_bg:setContentWH(self.width, self.height)
		else
			self.img_bg = XImage:create(path)
		end
		self.img_bg:setPosition(self.width / 2, self.height / 2)
		self.view:addChild(self.img_bg)
	end
	if path then
		self.img_bg:loadTexture(path)
	end
end

function AttrItemView:SetTitleText(title)
	if self.title_txt == nil then
		self.title_txt = XRichText:create()
		self:SetTitleTextAlignment(self.horizontal_align, self.vertical_align)
		self.view:addChild(self.title_txt, 10)
	end
	RichTextUtil.ParseRichText(self.title_txt, title, self.font_size)
	self.title_txt:refreshView()
	self:FlushView()
end

function AttrItemView:SetTitleTextAlignment(horizontal, vertical)
	self.horizontal_align = horizontal
	self.vertical_align = vertical
	if self.title_txt then
		self.title_txt:setHorizontalAlignment(horizontal)
		self.title_txt:setVerticalAlignment(vertical)
		self:FlushView()
	end
end

function AttrItemView:FlushView()
	local x, y
	if self.horizontal_align == RichHAlignment.HA_LEFT then
		x = 0
	elseif self.horizontal_align == RichHAlignment.HA_CENTER then
		x = self.width / 2 
	elseif self.horizontal_align == RichHAlignment.HA_RIGHT then
		x = self.width
	end

	if self.vertical_align == RichVAlignment.VA_TOP then
		y = self.height
	elseif self.vertical_align == RichVAlignment.VA_CENTER then
		y = self.height / 2
	elseif self.vertical_align == RichVAlignment.VA_BOTTOM then
		y = 0
	end

	self.title_txt:setPosition(x, y)
end
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

AttrItemRender = AttrItemRender or BaseClass(BaseRender)

function AttrItemRender.CreateAttrList(parent, ph)
	local attr_view = ListView.New()
	attr_view:Create(ph.x, ph.y, ph.w, ph.h, nil, AttrItemRender, ListViewGravity.CenterHorizontal, nil, {w=355, h=24})
	parent:addChild(attr_view:GetView(), 100, 100)
	attr_view:SetItemsInterval(8)
	attr_view:JumpToTop(true)
	return attr_view
end

function AttrItemRender:__init()
end

function AttrItemRender:__delete()

end

function AttrItemRender:CreateChildCallBack()
	self.img_bg = XUI.CreateImageViewScale9(148, 0, 200, 24, ResPath.GetCommon("img9_200"), true, cc.rect(5, 5, 10, 5))
	self.img_bg:setAnchorPoint(0.0, 0.0)
	self.view:addChild(self.img_bg)
	self.attr_name = XUI.CreateText(0, 0, 144, 24, cc.TEXT_ALIGNMENT_LEFT, "", nil, 18, Str2C3b("9c9181"))
	self.value_name = XUI.CreateText(148, 0, 200, 24, cc.TEXT_ALIGNMENT_CENTER, "", nil, 18, Str2C3b("17c923"))
	self.attr_name:setAnchorPoint(0.0, 0.0)
	self.value_name:setAnchorPoint(0.0, 0.0)
	self.view:addChild(self.attr_name)
	self.view:addChild(self.value_name)
end


function AttrItemRender:OnFlush(param_t, index)
	if self.data == nil then return end
	--self.node_tree.lbl_attr_name.node:setString(self.data.type_str)
	--self.node_tree.lbl_this_time_poist.node:setString(self.data.value)
	self.attr_name:setString(self.data.type_str)
	self.value_name:setString(self.data.value_str) -- 读取转换后的数值
end

function AttrItemRender:CreateSelectEffect()
end


CommonBuyRender = CommonBuyRender or BaseClass(BaseRender)
function CommonBuyRender:__init()
	-- body
end

function CommonBuyRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function CommonBuyRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_item
	if nil == self.cell then
		self.cell = BaseCell.New()
		self.view:addChild(self.cell:GetView(), 999)
		self.cell:GetView():setPosition(ph.x,ph.y)
	end
	XUI.AddClickEventListener(self.node_tree.btn_buy.node, BindTool.Bind(self.OnBUYItem, self), true)
end

function CommonBuyRender:OnFlush()
	if self.data == nil then
		return
	end
	local text = self.data.is_auto_use and "购买并使用" or "购买"
	self.node_tree.btn_buy.node:setTitleText(text)
	local item_config = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.node_tree.text_name_show.node:setString(item_config.name)
	self.node_tree.text_name_show.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color or 0), 1, 6)))

	local cfg = ShopData.GetShopItemCfgByIndexAndItemId(self.data.shop_index, self.data.item_id)
	if cfg ~= nil then
		self.cell:SetData({item_id = self.data.item_id, num = cfg.buyOnceCount, is_bind = 0}) 
		local price_type = cfg.price[1].type
		self.node_tree.img_gold.node:loadTexture(ShopData.GetMoneyTypeIcon(price_type))
		self.node_tree.text_had.node:setString(cfg.price[1].price)

		if self.node_tree.text_reian_time then
			RichTextUtil.ParseRichText(self.node_tree.text_reian_time.node, "", 18)
			if cfg.dayLimit and cfg.dayLimit > 0 then
				local remain_time =  ShopData.Instance:GetShopLeftBuyTimes(cfg.id)
				local text = string.format("每日限购：{color;00ff00;%d / %d}",remain_time or 0,cfg.dayLimit)
				RichTextUtil.ParseRichText(self.node_tree.text_reian_time.node, text, 18)
				XUI.RichTextSetCenter(self.node_tree.text_reian_time.node)
			end
		end
	end
end

function CommonBuyRender:OnBUYItem()
	local cfg = ShopData.GetShopItemCfgByIndexAndItemId(self.data.shop_index, self.data.item_id)
	if cfg ~= nil then 
		ShopCtrl.BuyItemFromStore(cfg.id, 1, self.data.item_id, self.data.is_auto_use and 1 or 0)
	end
end