BattleFuwenView = BattleFuwenView or BaseClass(BaseView)
local ZhanwenRender = ZhanwenRender or BaseClass(BaseRender)

function BattleFuwenView:__init()
	if BattleFuwenView.Instance then
		ErrorLog("BattleFuwenView.Instance is have!!!")
	end
	BattleFuwenView.Instance = self
	self.title_img_path = ResPath.GetWord("BattleFuwen")

	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		'res/xui/battle_fuwen.png'
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"battle_fuwen_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}

end

function BattleFuwenView:ReleaseCallBack()
	if self.zhanwen_item_view then
		self.zhanwen_item_view:DeleteMe()
	end
	self.zhanwen_item_view = nil

	if self.cur_attr then
		self.cur_attr:DeleteMe()
	end
	self.cur_attr = nil 

	if self.next_attr then
		self.next_attr:DeleteMe()
	end
	self.next_attr = nil 

	self.get_item_link = nil

	if self.bael_event then
		GlobalEventSystem:UnBind(self.bael_event)
		self.bael_event = nil 
	end

	if self.alert then
		self.alert:DeleteMe()
	end
	self.alert = nil 
end

function BattleFuwenView:LoadCallBack(index, loaded_times)
	self.data = BattleFuwenData.Instance:GetZhanwenInfo()		--获取数据

	XUI.AddClickEventListener(self.node_t_list.btn_equip.node, function () ViewManager.Instance:OpenViewByDef(ViewDef.ReplaceZhanwen) end)
	XUI.AddRemingTip(self.node_t_list.btn_equip.node, function ()
		return BattleFuwenData.Instance:GetCurrHaveBetter() > 0
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_replace.node, function () ViewManager.Instance:OpenViewByDef(ViewDef.ReplaceZhanwen) end)
	XUI.AddRemingTip(self.node_t_list.btn_replace.node, function ()
		return BattleFuwenData.Instance:GetCurrHaveBetter() > 0
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_change.node, function () ViewManager.Instance:OpenViewByDef(ViewDef.ExchangeZhanwen) end)
	XUI.AddRemingTip(self.node_t_list.btn_change.node, function ()
		return BattleFuwenData.Instance:GetExchageRemindNum() > 0
	end, nil, 85, 80)

	XUI.AddClickEventListener(self.node_t_list.btn_up.node, function () BattleFuwenData.Instance:SendUpLevel() end)
	XUI.AddRemingTip(self.node_t_list.btn_up.node, function ()
		return BattleFuwenData.Instance:GetCurrCanUpgrade() > 0
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_allinfo.node, function () ViewManager.Instance:OpenViewByDef(ViewDef.ShowAllZhanwen) end)

	-- EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	self.bael_event = GlobalEventSystem:Bind(BABEL_EVENET.DATA_CHANGE, BindTool.Bind1(self.OnDataChange,self))
	EventProxy.New(BattleFuwenData.Instance, self):AddEventListener(BattleFuwenData.BATTLE_FUWEN_JINGHUA_CHANGE, BindTool.Bind(self.OnDataChange, self))
	EventProxy.New(BattleFuwenData.Instance, self):AddEventListener(BattleFuwenData.BATTLE_FUWEN_ONE_INFO_CHANGE, BindTool.Bind(self.OnDataChange, self))
	EventProxy.New(BattleFuwenData.Instance, self):AddEventListener(BattleFuwenData.BATTLE_FUWEN_INFO_CHANGE, BindTool.Bind(self.OnDataChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnDataChange, self))

	----初始化UI
	-- self:LoadLinkLineBg()
	self.cur_attr = self:CreateAttrView(self.node_t_list.layout_zw_opeart.node, self.ph_list.ph_attr_left)
	self.next_attr = self:CreateAttrView(self.node_t_list.layout_zw_opeart.node, self.ph_list.ph_attr_right)
	self.next_attr:GetView():setColor(COLOR3B.GREEN)

	--创建槽位视图：符文格子；连线；
	self.zhanwen_item_view = self:CreateItemView()				
	self.zhanwen_item_view.SetSelectCallback(function (slot)
		--根据选择槽位显示当前符文属性
		self:AttrViewUpdate(slot)
		--设置选择的槽位
		BattleFuwenData.Instance:SetSelectSlot(slot)		
		--精华数量
		BattleFuwenView.FlushJinghuaNum(self.data[slot].item_data, self.node_t_list.rich_zw_jiejing_num.node)
		--提醒
		self:FlushBtnRemind()
	end)

	self.zhanwen_item_view.SelectOne(1)							--默认选择第一个
	self.zhanwen_item_view.UpdateLinkShow() 					--刷新连线
	self:AttrViewUpdate(1)

	--提醒
	self:FlushBtnRemind()

	--链接至战纹分解
	self.get_item_link = RichTextUtil.CreateLinkText("分解战纹", 20, COLOR3B.GREEN)
	self.get_item_link:setPosition(850, 18)
	self.node_t_list.layout_zhanwen.node:addChild(self.get_item_link, 50)
	self:FlushLinkRemind()

	XUI.AddClickEventListener(self.get_item_link, function () ViewManager.Instance:OpenViewByDef(ViewDef.DecomposeZhanwen) end)
end

function BattleFuwenView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BattleFuwenView:ShowIndexCallBack()
	self:OnDataChange()
end

function BattleFuwenView:CloseCallBack()
end

function BattleFuwenView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BattleFuwenView:OnDataChange(_vo)
	self.zhanwen_item_view.Update()
	vo = _vo or {}
	vo.slot = vo.slot or BattleFuwenData.Instance:GetSelectSlot()
	self:AttrViewUpdate(vo.slot)
	if vo.tag and vo.tag == "uplevel" then 
		RenderUnit.PlayEffectOnce(CLIENT_GAME_GLOBAL_CFG.upgrade_eff_id, self.node_t_list.layout_zhanwen.node, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, 460, 370, true)
	end

	BattleFuwenView.FlushJinghuaNum(self.data[vo.slot].item_data, self.node_t_list.rich_zw_jiejing_num.node)

	self:FlushBtnRemind()
	self:FlushLinkRemind()
end

function BattleFuwenView:AttrViewUpdate(slot)
	local cur_attr,next_attr = self.data[slot].get_attr()
	self.cur_attr:SetData(cur_attr)
	self.next_attr:SetData(next_attr)

	--槽位未穿戴战纹，则不显示属性及升级按钮，显示装备按钮
	self.node_t_list.layout_zw_opeart.node:setVisible(nil ~= cur_attr)
	self.node_t_list.btn_equip.node:setVisible(nil == cur_attr)
	
	--战纹名字
	self.FlushItemShow(self.data[slot].item_data, self.node_t_list.img_show_icon.node, self.node_t_list.lbl_zw_name.node)
end

function BattleFuwenView:FlushLinkRemind()
	-- 可分解神装提醒
	if BattleFuwenData.Instance:GetCanDecomposeRemindNum() then
		UiInstanceMgr.AddRectEffect({node = self.get_item_link, init_size_scale = 1.2, time = 0.5, offset_w = - 20})
		self.get_item_link.rect_effect:setColor(COLOR3B.GREEN)
	else
		UiInstanceMgr.DelRectEffect(self.get_item_link)
	end
end

function BattleFuwenView:FlushBtnRemind()
	self.node_t_list.btn_equip.node:UpdateReimd()
	self.node_t_list.btn_replace.node:UpdateReimd()
	self.node_t_list.btn_change.node:UpdateReimd()
	self.node_t_list.btn_up.node:UpdateReimd()
end

function BattleFuwenView:CreateItemView()
	local view = {}
	local item_list = {}									--展示item
	-- local link_line_view = self:CreateLinkLineView()		--item之间的连线
	local select_call_func = nil 							--点击item回调函数
	local max_slot = 18
	--顶部提示
	for slot = 1, BattleFuwenData.ZHANWEN_SLOT_NUM do
		item_list[slot] = ZhanwenRender.New()
		item_list[slot]:SetUiConfig(self.ph_list.ph_zw_item, true)
		item_list[slot]:SetData(self.data[slot])
		item_list[slot]:SetPosition(self.ph_list["ph_zw_item_" .. slot].x, self.ph_list["ph_zw_item_" .. slot].y)
		self.node_t_list.layout_zhanwen.node:addChild(item_list[slot]:GetView(), 300)
	end

	function view.Update(slot)
		if slot then
			item_list[slot]:SetData(self.data[slot])
		else
			for i = 1, BattleFuwenData.ZHANWEN_SLOT_NUM do
				item_list[i]:SetData(self.data[i])
			end
		end
		if 0 < max_slot and max_slot < 18 then
			item_list[max_slot + 1]:setOpenTip("试炼关卡" .. BattlePatternCfg.openSlot[max_slot + 1] .. "层开启")
		elseif max_slot == 0 then
			item_list[1]:setOpenTip("试炼关卡" .. BattlePatternCfg.openSlot[1] .. "层开启")
		end
	end

	function view.DeleteMe() 
		for i,v in ipairs(item_list) do
			v:DeleteMe()
		end
	end

	function view.SetSelectCallback(func)
		select_call_func = func
	end

	function view.UpdateLinkShow()
		for i,v in ipairs(item_list) do
			if self.data[i].check_is_lock() then
				max_slot = i - 1
				break
			end
		end

		if 0 < max_slot and max_slot < 18 then
			item_list[max_slot + 1]:setOpenTip("试炼关卡" .. BattlePatternCfg.openSlot[max_slot + 1] .. "层开启")
		elseif max_slot == 0 then
			item_list[1]:setOpenTip("试炼关卡" .. BattlePatternCfg.openSlot[1] .. "层开启")
		end

		-- link_line_view:removeAllChildrenExInner(true)
		-- link_line_view.UpdateLinkLine(self:CreatLIneData(max_slot).head_node)
	end

	local tips = "通关通天塔{wordcolor;1eff00;%s层}即可解锁该槽位"
	function view.SelectOne(slot)
		--点击提示
		if self.data[slot].check_is_lock() then
			-- SysMsgCtrl.Instance:ErrorRemind("槽位开启需要通过试炼关数: " ..  BattlePatternCfg.openSlot[slot])
			if self.alert == nil then
				self.alert = Alert.New()
			end
			-- self.alert:SetShowCheckBox(true)
			self.alert:SetOkString("前往通天")
			self.alert:SetLableString(string.format(tips, BattlePatternCfg.openSlot[slot]))
			self.alert:SetOkFunc(function ()	
				ViewManager.Instance:OpenViewByDef(ViewDef.Experiment.Babel)
				ViewManager.Instance:CloseViewByDef(ViewDef.BattleFuwen)
		  	end)
			self.alert:Open()
			return
		end

		for i,v in ipairs(item_list) do
			v:OnSelect(slot == i)
		end

		if select_call_func then
			select_call_func(slot)
		end
	end

	return view
end

--点之间的连线 使用九宫格精灵
local LINE_HEGIHT = 17
function BattleFuwenView:CreateLinkLineView()
	local view = XUI.CreateLayout(0, 0, 0, 0)
	self.node_t_list.layout_zhanwen.node:addChild(view, 4)

	function view.UpdateLinkLine(Node)
		BattleFuwenView.FlushLinkPos(Node, view, ResPath.GetZhanwen("img9_contact"))
	end

	return view
end

function BattleFuwenView:LoadLinkLineBg()
	local view = XUI.CreateLayout(0, 0, 0, 0)
	self.node_t_list.layout_zhanwen.node:addChild(view, 2)

	function view.UpdateLinkLine(Node)
		BattleFuwenView.FlushLinkPos(Node, view, ResPath.GetZhanwen("img_line_bg"))
	end

	view.UpdateLinkLine(self:CreatLIneData(18).head_node)
end

function BattleFuwenView.FlushLinkPos(Node, parent, path)
	if nil == Node.next_ then return end
	if nil == Node.sprite then
		Node.sprite = XUI.CreateImageViewScale9(Node.x + 63, Node.y + 50, 10, LINE_HEGIHT, path, true)
	end
	Node.sprite:setAnchorPoint(0, 0)
	-- Node.sprite:setOpacity(150)
	Node.sprite:setContentSize(cc.size(GameMath.GetDistance(Node.x, Node.y, Node.next_.x, Node.next_.y, true), LINE_HEGIHT))
	Node.sprite:setRotation(GameMath.DirAngle(cc.p(Node.x, Node.y), cc.p(Node.next_.x, Node.next_.y)))

	if Node.idx == 6 then
		Node.sprite:setPositionX(Node.x + 63 + 20)
	elseif Node.idx == 2 then
		Node.sprite:setPositionX(Node.x + 63 + 20)
	end

	if Node.idx == 3 then
		Node.sprite:setPositionY(Node.y + 50 + 15)
	elseif Node.idx == 5 then
		Node.sprite:setPositionY(Node.y + 50 + 5)
	elseif Node.idx == 7 then
		Node.sprite:setPositionY(Node.y + 50 + 15)
	end

	parent:addChild(Node.sprite, 2)
	parent.UpdateLinkLine(Node.next_)
end

function BattleFuwenView:CreateAttrView(parent_node, ph)
	local attr_view = AttrView.New(300, 25, 18)
	attr_view:SetDefTitleText("已达到最高级")
	attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
	attr_view:GetView():setPosition(ph.x, ph.y)
	attr_view:GetView():setAnchorPoint(0.5, 0.5)
	attr_view:SetContentWH(ph.w, ph.h)
	parent_node:addChild(attr_view:GetView(), 50)
	return attr_view
end

--精华数量刷新
function BattleFuwenView.FlushJinghuaNum(data, ui)
	local str = "{wordcolor;%s;%s}/%s"
	local color = BattleFuwenData.Instance:GetZhanwenJinghuaNum() >= BattleFuwenData.GetUpNeed(data) and "1eff00" or "DC143C"
	local txt = string.format(str, color, BattleFuwenData.Instance:GetZhanwenJinghuaNum(), BattleFuwenData.GetUpNeed(data)) 
	RichTextUtil.ParseRichText(ui, txt, 22, COLOR3B.OLIVE)
end

--刷新战纹item展示
function BattleFuwenView.FlushItemShow(data, icon_ui, name_ui, desc_ui)
	if nil == data then return end
	local cfg = ItemData.Instance:GetItemConfig(data.item_id)
	local txt_color = Str2C3b(string.sub(string.format("%06x", cfg.color), 1, 6))
	if name_ui then
		name_ui:setString(cfg.name .. " LV." .. data.durability) 	--符文名称
		name_ui:setColor(txt_color)
	end

	if icon_ui then
		icon_ui:loadTexture(ResPath.GetItem(cfg.icon))									--刷新符文图标
		
	end

	--属性描述
	if desc_ui then 
		local attr_cfg = BattleFuwenData.GetZhanwenAttr(data.item_id, data.durability) or {}
		RichTextUtil.ParseRichText(desc_ui, RoleData.FormatAttrContent(attr_cfg),  14, COLOR3B.OLIVE)
	end

end

--根据开放槽位 创建链表数据
function BattleFuwenView:CreatLIneData(max_slot)
	local line_list = {}
	--连线头结点
	line_list.head_node = {
		idx = 1,
		x = self.ph_list["ph_zw_item_1"].x,
		y = self.ph_list["ph_zw_item_1"].y,
		next_ = nil,
	}				

	if max_slot == 0 then
		return line_list
	end

	local function PushList(list, node)
		if nil == list.ceil_node then
			node.idx = 2 
			list.head_node.next_ = node
			list.ceil_node = list.head_node.next_
		else
			node.idx = list.ceil_node.idx + 1 
			list.ceil_node.next_ = node
			list.ceil_node = list.ceil_node.next_ 
		end
	end

	if max_slot >= 5 then
		local node = {
			x = self.ph_list["ph_zw_item_" .. (max_slot <= 5 and max_slot or 5)].x,
			y = self.ph_list["ph_zw_item_" .. (max_slot <= 5 and max_slot or 5)].y,
			next_ = nil
		}
		PushList(line_list, node)
	end

	if max_slot >= 6 then
		local node = {
			x = self.ph_list["ph_zw_item_" .. 6].x,
			y = self.ph_list["ph_zw_item_" .. 6].y,
			next_ = nil
		}
		PushList(line_list, node)
	end
	
	if max_slot >= 9 then
		local node = {
			x = self.ph_list["ph_zw_item_" .. 9].x,
			y = self.ph_list["ph_zw_item_" .. 9].y,
			next_ = nil
		}
		PushList(line_list, node)

	end

	if max_slot >= 10 then
		local node = {
			x = self.ph_list["ph_zw_item_" .. (max_slot <= 10 and max_slot or 10)].x,
			y = self.ph_list["ph_zw_item_" .. (max_slot <= 10 and max_slot or 10)].y,
			next_ = nil
		}
		PushList(line_list, node)
	end

	if max_slot >= 13 then
		local node = {
			x = self.ph_list["ph_zw_item_" .. 13].x,
			y = self.ph_list["ph_zw_item_" .. 13].y,
			next_ = nil
		}
		PushList(line_list, node)
	end

	if max_slot >= 14 then
		local node = {
			x = self.ph_list["ph_zw_item_" .. (max_slot <= 14 and max_slot or 14)].x,
			y = self.ph_list["ph_zw_item_" .. (max_slot <= 14 and max_slot or 14)].y,
			next_ = nil
		}
		PushList(line_list, node)
	end

	local end_node = {
		x = self.ph_list["ph_zw_item_" .. max_slot].x,
		y = self.ph_list["ph_zw_item_" .. max_slot].y,
		next_ = nil
	}
	PushList(line_list, end_node)
	return line_list
end

------------------------------------------------
-- 战纹item render

function ZhanwenRender:CreateChild()
	BaseRender.CreateChild(self)

	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetZhanwen("img_select_4"), true)
	self.view:addChild(self.select_effect, -1)
	self.select_effect:setVisible(false)

	XUI.AddClickEventListener(self.view, function ()
		self:OnClick()
	end)

	XUI.AddRemingTip(self.view, function ()
		return self.data.check_have_better() or self.data.check_can_upgrade()
	end, nil, 70, 75)

	self.yellow_effect = RenderUnit.CreateEffect(352, self.node_tree.img_icon.node, 99)
	self.yellow_effect:setVisible(false)
	self.orange_effect = RenderUnit.CreateEffect(353, self.node_tree.img_icon.node, 99)
	self.orange_effect:setVisible(false)
	self.red_effect = RenderUnit.CreateEffect(354, self.node_tree.img_icon.node, 99)
	self.red_effect:setVisible(false)
end

function ZhanwenRender:OnSelect(bool)
	self.select_effect:setVisible(bool)
end

function ZhanwenRender:OnClick()
	BattleFuwenView.Instance.zhanwen_item_view.SelectOne(self.data.slot)
end

function ZhanwenRender:setOpenTip(str)
	-- self.node_tree.lbl_zw_name.node:setString(str)
	-- self.node_tree.lbl_zw_name.node:setColor(COLOR3B.RED)
end

function ZhanwenRender:OnFlush()
	if nil == self.data then return end
	--判断背景显示
	local bg_path = ResPath.GetZhanwen("img_cell_2") --默认已解锁 无佩戴符文
	if self.data.check_is_lock() then
		bg_path = ResPath.GetZhanwen("img_cell_lock")
	elseif nil ~= self.data.item_data then
		bg_path = ResPath.GetZhanwen("img_cell_1")
	else
		bg_path = ResPath.GetZhanwen("img_cell_2")
	end
	self.node_tree.img_bg.node:loadTexture(bg_path)

	self.node_tree.lbl_zw_name.node:setString("")
	self.node_tree.img_icon.node:setVisible(nil ~= self.data.item_data and not self.data.check_is_lock())

	BattleFuwenView.FlushItemShow(self.data.item_data, self.node_tree.img_icon.node)

	self.view:UpdateReimd()
	self:FlushEffect()
end

function ZhanwenRender:FlushEffect()
	if self.data.item_data then
		local cfg = ItemData.Instance:GetItemConfig(self.data.item_data.item_id)
		if cfg.quality == 2 then
			self.yellow_effect:setVisible(true)
			self.orange_effect:setVisible(false)
			self.red_effect:setVisible(false)
		elseif cfg.quality == 3 then
			self.yellow_effect:setVisible(false)
			self.orange_effect:setVisible(true)
			self.red_effect:setVisible(false)
		elseif cfg.quality == 4 then
			self.yellow_effect:setVisible(false)
			self.orange_effect:setVisible(false)
			self.red_effect:setVisible(true)
		else
			self.yellow_effect:setVisible(false)
			self.orange_effect:setVisible(false)
			self.red_effect:setVisible(false)
		end
	end
end