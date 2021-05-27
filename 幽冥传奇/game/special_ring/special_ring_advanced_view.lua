--------------------------------------------------------
-- 特戒-进阶  配置 ItemSynthesisConfig[7] 特戒技能配置:VirtualSkillCfg
--------------------------------------------------------

local SpecialRingAdvancedView = SpecialRingAdvancedView or BaseClass(SubView)

function SpecialRingAdvancedView:__init()
	self.texture_path_list[1] = 'res/xui/special_ring.png'
	self.config_tab = {
		{"special_ring_ui_cfg", 1, {0}},
	}

	self.type = 1
	self.index = 1
	self.eff = nil
	self.special_ring_list = nil
end

function SpecialRingAdvancedView:__delete()

end

--释放回调
function SpecialRingAdvancedView:ReleaseCallBack()
	self.eff = nil
	self.type = 1
	self.index = 1
	self.select_data = nil
	self.circle = nil
	self.skill_icon = nil
end

--加载回调
function SpecialRingAdvancedView:LoadCallBack(index, loaded_times)
	self:CreateAccordionView()
	self:CreatePower()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnBtn, self), true)
	XUI.AddClickEventListener(self.node_t_list["img_special_tip2"].node, BindTool.Bind(self.OpenShowTips, self), true)

	-- 数据监听
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnFlush, self))
end

function SpecialRingAdvancedView:OpenShowTips( ... )
	DescTip.Instance:SetContent(Language.DescTip.SpecialAdvanceContent, Language.DescTip.SpecialAdvanceFashionTitle)
end

function SpecialRingAdvancedView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function SpecialRingAdvancedView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function SpecialRingAdvancedView:ShowIndexCallBack(index)
	if self.special_ring_list then
		self.special_ring_list:SetSelectChildIndex(1, 1)
	end

	-- 人物转生改变才刷新
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	if self.circle ~= circle then
		self:FlushAccordionView()
		self.circle = circle
	end
end

function SpecialRingAdvancedView:OnFlush()
	self:FlushConsume()
	self:FlusAttr()
	self:FlusEff()
	self:FlushRemind()
	self:FlushSkill()

	local score = ItemData.Instance:GetItemScoreByData(self.select_data)
	self.power:SetNumber(score)

	self.node_t_list["btn_1"].node:setTitleText(Language.SpecialRing.BtnsTitle[self.index == 1])
	self.node_t_list["img_tip_text"].node:setVisible(self.index == 1)
end
----------视图函数----------

-- 刷新特戒技能显示
function SpecialRingAdvancedView:FlushSkill()
	local cfg = VirtualSkillCfg or {}
	local item_id = self.select_data.item_id or 0
	local cur_skill = cfg[item_id] or {}
	local path = ResPath.GetItem(cur_skill.icon or 0)
	if self.skill_icon then
		self.skill_icon:loadTexture(path)
	else
		-- 创建技能图标
		local ph = self.ph_list["ph_skill_icon"]
		local x, y = ph.x, ph.y
		self.skill_icon = XUI.CreateImageView(x, y, path, XUI.IS_PLIST)
		self.node_t_list["layout_special_ring"].node:addChild(self.skill_icon, 20)
		XUI.AddClickEventListener(self.skill_icon, BindTool.Bind(self.OnSkillIcon, self), true)
	end

	local rich, text
	rich = self.node_t_list["rich_skill_name"].node
	text = cur_skill.name or ""
	rich = RichTextUtil.ParseRichText(rich, text, 20, COLOR3B.BLUE)
	rich:refreshView()

	rich = self.node_t_list["rich_skill_tip"].node
	text = cur_skill.desc or ""
	rich = RichTextUtil.ParseRichText(rich, text, 16, COLOR3B.WHITE)
	rich:refreshView()
end

function SpecialRingAdvancedView:CreateAccordionView()
	local ph = self.ph_list["ph_special_ring_list"] -- 锚点为0,0
	local tree = self.ph_list["ph_special_ring_item"] -- 锚点为0,0
	local child = self.ph_list["ph_special_ring_child"] -- 锚点为0,0

	local tree_height = tree.h + 5 --默认加高5,可不设置
	local child_height = child.h + 4 --默认下高4,可不设置
	local child_x = (tree.w - child.w) / 2 -- 默认是居中,可不设置
	local child_y_down = 4 -- 默认下调4,可不设置

	local accordion = Accordion.New()
	accordion:Create(ph.x, ph.y, ph.w, ph.h, self.SpecialRingItem, 1, 1, tree, child, tree_height, child_height, child_x, child_y_down)
	accordion:SetSelectCallBack(BindTool.Bind(self.SpecialRingChildSelect, self)) -- 设置选择子节点回调
	self.node_t_list["layout_special_ring"].node:addChild(accordion:GetView(), 50)

	self.special_ring_list = accordion
	self:AddObj("special_ring_list")
end

function SpecialRingAdvancedView:FlushAccordionView()
	local special_ring_list = SpecialRingData.Instance:GetSpecialRingList()
	-- 将表格式化为
	-- data = {
	-- 	{type, show_id, child = {{item_id, effect_id},{item_id, effect_id, consume},{item_id, effect_id, consume} ... }},
	-- 	{type, show_id, child = {{item_id, effect_id},{item_id, effect_id, consume},{item_id, effect_id, consume} ... }},
	-- }
	local data = {}
	for i,v in ipairs(special_ring_list) do
		data[i] = {}
		data[i].type = i
		data[i].child = v
	end
	self.special_ring_list:SetData(data)
	self.special_ring_list:SetExpandByIndex(0, false)
end

function SpecialRingAdvancedView:SpecialRingChildSelect(item)
	self.type = self.special_ring_list.cur_tree_index
	self.index = self.special_ring_list.select_child_index
	self.select_data = item:GetData()
	self:Flush()
end

-- 创建显示消耗的图标
function SpecialRingAdvancedView:CreateConsumeCell()
	local parent = self.node_t_list["layout_special_ring"].node
	local ph = self.ph_list["ph_consume"] or {x = 0, y = 0}
	local cell = ActBaseCell.New()
	cell:GetView():setPosition(ph.x, ph.y)
	parent:addChild(cell:GetView(), 20)
	self.consume_cell = cell
	self:AddObj("consume_cell")
end

-- 刷新消耗显示
function SpecialRingAdvancedView:FlushConsume()
	if self.index ~= 1 then
		local consume = self.select_data and self.select_data.consume or {}
		local consume_id = consume.item_id or 0
		local consume_cfg = ItemData.Instance:GetItemConfig(consume_id)
	
		local consume_cfg_num = consume.num or 0
		local consume_bag_num = BagData.Instance:GetItemNumInBagById(consume_id)
		local consume_name_color = string.format("%06x", consume_cfg.color)
		local num_color = consume_bag_num >= consume_cfg_num and COLOR3B.GREEN or COLOR3B.RED		

		if nil == self.consume_cell then
			self:CreateConsumeCell()
		else
			self.consume_cell:GetView():setVisible(true)
		end

		self.consume_cell:SetData(consume)
		
		-- 示例: "(0/2)"
		local text = string.format("(%d/%d)", consume_bag_num, consume_cfg_num)
		self.consume_cell:SetRightBottomText(text, num_color)

	else
		if self.consume_cell then
			self.consume_cell:GetView():setVisible(false)
		end
	end
end

-- 创建属性列表
function SpecialRingAdvancedView:CreateAttrList()
	local ph = self.ph_list["ph_attr"]
	local list = ListView.New()
	list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, self.AttrTextRender, nil, nil, self.ph_list["ph_attr_txt_item"])
	list:SetItemsInterval(2)
	list:SetMargin(2)
	self.node_t_list["layout_special_ring"].node:addChild(list:GetView(), 50)
	self.attr_list = list
	self:AddObj("attr_list")
end

-- 刷新属性列表
function SpecialRingAdvancedView:FlusAttr()
	if nil == self.attr_list then
		self:CreateAttrList()
	end

	local item_id = self.select_data and self.select_data.item_id or 0
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local attr = ItemData.GetStaitcAttrs(item_cfg)

	local attr_show_list = {}
	for i,v in ipairs(attr) do
		if SpecialRingData.show_attr[v.type] then
			attr_show_list[#attr_show_list + 1] = v
		end
	end

	self.attr_list:SetDataList(RoleData.FormatRoleAttrStr(attr_show_list))
end

-- 刷新特戒特效显示
function SpecialRingAdvancedView:FlusEff()
	local effect_id = self.select_data and self.select_data.effect_id or 1
	local path, name = ResPath.GetEffectUiAnimPath(effect_id)

	if nil == self.eff then
		local ph = self.ph_list["ph_eff"]
		self.eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.eff:setPosition(ph.x, ph.y)
		self.node_t_list["layout_special_ring"].node:addChild(self.eff, 50)
	else
		self.eff:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	end
end

-- 创建战力
function SpecialRingAdvancedView:CreatePower()
	local ph = self.ph_list["ph_power"]
	local number_bar = NumberBar.New()
	number_bar:Create(ph.x, ph.y, ph.w, ph.h, ResPath.GetCommon("num_133_"))
	number_bar:SetSpace(-5)
	self.node_t_list["layout_special_ring"].node:addChild(number_bar:GetView(), 50)
	self.power = number_bar
	self:AddObj("power")
end

-- 刷新红点提示
function SpecialRingAdvancedView:FlushRemind()
	local synthetic_cfg = SpecialRingData.Instance:GetSyntheticCfg()
	local list = self.special_ring_list
	local tree = {}
	-- 子节点红点提示
	for i,v in pairs(synthetic_cfg) do
		local bag_count = BagData.Instance:GetItemNumInBagById(i)
		tree[v.type] = tree[v.type] or 0
		local item = list and list.items and list.items[v.type] or {}
		local child = item.childs and item.childs[v.index]
		if child ~= nil then
			if bag_count >= v.count then
				child:SetRemind(true)
				tree[v.type] = 1
			else
				child:SetRemind(false)
			end
		end
	end

	-- 树节点红点提示
	for k,v in pairs(tree) do
		local item = list and list.items and list.items[k] and list.items[k].item
		if item ~= nil then
			item:SetRemind(v > 0)
		end
	end
end

----------end----------

function SpecialRingAdvancedView:OnBtn()
	if self.index == 1 then
		ViewManager.Instance:OpenViewByDef(ViewDef.Explore)
	else
		local consume = self.select_data and self.select_data.consume or {}
		local item_id = consume.item_id
		local special_ring_bag = SpecialRingData.Instance:GetSpecialRingBag()
		local can_advanced_num, sum = 0, 0
		for _, item_data in pairs(special_ring_bag) do
			if item_id == item_data.item_id then
				sum = sum + 1
				local can_advanced = true
				for i,v in ipairs(item_data.special_ring) do
					local _type = v.type
					if _type > 0 then
						can_advanced = false
						break
					end
				end
				if can_advanced then
					can_advanced_num = can_advanced_num + 1
				end
			end
		end
		local consume_cfg_num = consume.num or 0
		if can_advanced_num >= consume_cfg_num then
			local _type = self.select_data.compose_type
			local index = self.select_data.compose_index
			BagCtrl.SendComposeItem(7, _type, index, 0)
		else
			if sum >= consume_cfg_num then
				-- 有已融合的特戒，请先分离
				SysMsgCtrl.Instance:FloatingTopRightText(Language.SpecialRing.FloatingText[8])
			else
				local item_id = 2056
				local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
				local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
				TipCtrl.Instance:OpenBuyTip(data)
			end
		end 
	end
end

function SpecialRingAdvancedView:OnBagItemChange(event)
	event.CheckAllItemDataByFunc(function (vo)
		local item_id = vo.data.item_id
		local synthetic_cfg = SpecialRingData.Instance:GetSyntheticCfg()
		if vo.change_type == ITEM_CHANGE_TYPE.LIST or nil ~= synthetic_cfg[item_id] then
			self:FlushRemind()
		end
	end)
end

function SpecialRingAdvancedView:OnSkillIcon()
	local cfg = VirtualSkillCfg or {}
	local item_id = self.select_data.item_id or 0
	SpecialRingCtrl.Instance:OpenSkillTip(item_id)
end

--------------------

----------------------------------------
-- Accordion
----------------------------------------
SpecialRingAdvancedView.SpecialRingItem = BaseClass(AccordionItemRender)
local SpecialRingItem = SpecialRingAdvancedView.SpecialRingItem
function SpecialRingItem:__init()
	self.remind_bg_sprite = nil
end

function SpecialRingItem:__delete()
	self.remind_bg_sprite = nil
end

function SpecialRingItem:CreateChild()
	BaseRender.CreateChild(self)
end

-- 注意:树节点和子节点共用,设置节点属性前要判空.
function SpecialRingItem:OnFlush()
	if nil == self.data then return	end

	if nil ~= self.node_tree["lbl_title"] then
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
		local name = item_cfg.name or ""
		self.node_tree["lbl_title"].node:setString(name)

		local color = Str2C3b(string.format("%06x", item_cfg.color))
		self.node_tree["lbl_title"].node:setColor(color)
	end

	-- 旋转箭头
	if self.node_tree["img_arrow"] then
		local rotation = self.is_select and 0 or -90
		self.node_tree["img_arrow"].node:setRotation(rotation)
	end

	if self.node_tree["img_type"] then
		self.node_tree["img_type"].node:loadTexture(ResPath.GetSpecialRing("special_ring_type_" .. self.index))
	end
end

-- 设置item点击回调
function SpecialRingItem:SetClickCallBack(callback)
	if type(callback) == "function" then
		self.click_callback = callback
	end
end

-- 选择改变回调
function SpecialRingItem:OnSelectChange(is_select)
	if self.node_tree["img_arrow"] then
		local rotation = self.is_select and 0 or -90
		-- 旋转动作
		-- local seq_act = cc.RotateBy:create(0.2, rotation)
		-- self.node_tree["img_arrow"].node:runAction(seq_act)
		self.node_tree["img_arrow"].node:setRotation(rotation)
	end
end

function SpecialRingItem:SetRemind(vis, path, x, y)
	if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) <= RemindLimitAll then return end 
	path = path or ResPath.GetMainui("remind_flag")
	local size = self.view:getContentSize()
	x = x or size.width - 10
	y = y or size.height - 15
	if vis and nil == self.remind_bg_sprite then		
		self.remind_bg_sprite = XUI.CreateImageView(x, y, path, true)
		self.remind_bg_sprite:setScale(0.6)
		self.view:addChild(self.remind_bg_sprite, 9, 1)
	elseif self.remind_bg_sprite then
		self.remind_bg_sprite:setVisible(vis)
	end
end

-- 默认子节点会创建选择框,可用以下方法屏蔽.
function SpecialRingItem:CreateSelectEffect()
	if self:IsChild() then
		local size = self.view:getContentSize()
		self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetSpecialRing("img_select"), true)
		self.view:addChild(self.select_effect, 200, 200)
	end
end

-- 属性文本
SpecialRingAdvancedView.AttrTextRender = BaseClass(BaseRender)
local AttrTextRender = SpecialRingAdvancedView.AttrTextRender
function AttrTextRender:__init()
	
end

function AttrTextRender:__delete()

end

function AttrTextRender:CreateChild()
	BaseRender.CreateChild(self)
end

function AttrTextRender:OnFlush()
	if nil == self.data then 
		self.node_tree.lbl_attr_txt.node:setString("")
		return 
	end
	self.node_tree.lbl_attr_name.node:setString(self.data.type_str .. "：")
	self.node_tree.lbl_attr_txt.node:setString(self.data.value_str)
end

function AttrTextRender:CreateSelectEffect()
end

return SpecialRingAdvancedView