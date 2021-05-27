--------------------------------------------------------
-- 钻石打造 配置 Diamondforge 钻石ID:3568
--------------------------------------------------------

local ExploreCreateView = BaseClass(SubView)

function ExploreCreateView:__init()
	self.texture_path_list = {'res/xui/explore.png', }
	self.config_tab = {
		{"explore_ui_cfg", 4, {0}},				--背景
		{"explore_ui_cfg", 5, {0}, false},		--默认隐藏layout_create2
	}

	self.item_cell = nil --物品单元
	self.child_index = 0 -- 当前子标签索引,0表示未处于当前窗口页面
	self.btn_effects = {} -- 打造按钮特效
	self.remind_bg_sprite = {} -- 子标签的红点提示
end

function ExploreCreateView:__delete()
end

function ExploreCreateView:ReleaseCallBack()

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.child_index = 0
	self.btn_effects = {}
	self.remind_bg_sprite = {}
end

function ExploreCreateView:LoadCallBack(index, loaded_times)
	-- 初始化子标签视图
	self.node_t_list.layout_btn_xb_1.node:setVisible(false)
	self.node_t_list.layout_btn_xb_2.node:setVisible(false)
	self.node_t_list.layout_btn_xb_3.node:setVisible(false)
	self.node_t_list.layout_btn_xb_4.node:setVisible(false)

	-- 获取材料
    self.link_stuff = RichTextUtil.CreateLinkText("获取钻石", 20, COLOR3B.GREEN)
    self.link_stuff:setPosition(836, 25)
    self.node_t_list.layout_create1.node:addChild(self.link_stuff, 99)
    XUI.AddClickEventListener(self.link_stuff, function()
        TipCtrl.Instance:OpenGetStuffTip(3568)
    end, true)

	self:CreateItemView()	-- 创建物品视图
	self:CreateBtnEffectsView()	-- 创建按钮特效

	--特效
	local path, name = ResPath.GetEffectUiAnimPath(140)
	local stove = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, 0.15, false)
	stove:setPosition(521, 388)
	self.node_t_list.layout_create1.node:addChild(stove, 6)
	stove:setVisible(true)

	--子标签点击监听
	XUI.AddClickEventListener(self.node_t_list.layout_btn_xb_1.node, BindTool.Bind(self.FlushIndexView, self, 1), true)
	XUI.AddClickEventListener(self.node_t_list.layout_btn_xb_2.node, BindTool.Bind(self.FlushIndexView, self, 2), true)
	XUI.AddClickEventListener(self.node_t_list.layout_btn_xb_3.node, BindTool.Bind(self.FlushIndexView, self, 3), true)
	XUI.AddClickEventListener(self.node_t_list.layout_btn_xb_4.node, BindTool.Bind(self.FlushIndexView, self, 4), true)
	--打造按钮点击监听
	XUI.AddClickEventListener(self.node_t_list.layout_create_1.node, BindTool.Bind(self.OnClickCreateCallBack, self, 1), true)
	XUI.AddClickEventListener(self.node_t_list.layout_create_2.node, BindTool.Bind(self.OnClickCreateCallBack, self, 1), true)
	XUI.AddClickEventListener(self.node_t_list.layout_create_3.node, BindTool.Bind(self.OnClickCreateCallBack, self, 2), true)

	--打造结果监听
	EventProxy.New(ExploreData.Instance, self):AddEventListener(ExploreData.CREATE_RESULTS_CHANGE, BindTool.Bind(self.FlushCreateResultsView, self))

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.BagItemChangeCallBack, self, 1))
end

function ExploreCreateView:ShowIndexCallBack(index)
	self:InitCreateView()	-- 初始化打造视图
	self:FlushChildTagView()-- 刷新子标签视图
end

function ExploreCreateView:CloseCallBack(is_all)
	self.child_index = 0
end

function ExploreCreateView:OnFlush(param_list)
	if param_list.bag_data_change then
		if self.child_index == 0 then return end --窗口关闭时跳出
		self:FlushBtnView(self.child_index)
		self:FlushChildTagView()
	end
end

function ExploreCreateView:InitCreateView()
	if self.child_index == 1 then return end
	self.child_index = 1

	self.node_t_list.layout_btn_1.node:setVisible(true)
	self.node_t_list.layout_btn_2.node:setVisible(false)

	self.node_t_list.img_xb_25.node:setVisible(false)
	self.node_t_list.img_xb_28.node:setVisible(false)

	self:FlushBtnView(1)
	self:FlushItemView(1)
	self:FlushBtnPromptText(1)

	self.node_t_list.layout_create2.node:setVisible(true)	--显示layout_create2
end

-- 创建物品视图
function ExploreCreateView:CreateItemView()
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(self.ph_list.ph_cell_19.x, self.ph_list.ph_cell_19.y)
	self.item_cell:SetAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_create2.node:addChild(self.item_cell:GetView(), 10)
end

-- 创建按钮特效
function ExploreCreateView:CreateBtnEffectsView()
	local path, name = nil, nil
	path, name = ResPath.GetEffectUiAnimPath(141)

	for i = 1, 3 do
		self.btn_effects[i] = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, 0.15, false)
		self.btn_effects[i]:setPosition(95, 31)
		self.node_t_list["layout_create_" .. i].node:addChild(self.btn_effects[i], 1)
		self.btn_effects[i]:setVisible(false)
	end

end

--刷新子标签索引的视图
function ExploreCreateView:FlushIndexView(index)
	if self.child_index == index and self.child_index == 0 then return end --已经显示当前子标签时跳出
	self.child_index = index

	self.node_t_list.layout_btn_1.node:setVisible(index == 1 or index == 2)
	self.node_t_list.layout_btn_2.node:setVisible(index == 3 or index == 4)
	self.node_t_list.img_xb_25.node:setVisible(index == 3)
	self.node_t_list.img_xb_28.node:setVisible(index == 4)

	self:FlushBtnView(index)
	self:FlushItemView(index)
	self:FlushBtnPromptText(index)
end

--刷新物品视图
function ExploreCreateView:FlushItemView(index)
	local data = {}
	local item_id = nil

	--获取奖池中的物品id
	for i = 1 , #Diamondforge[index].item do
		data[i] = {item_id = Diamondforge[index].item[i]}
	end

	local num = math.random(1, #data) --取随机数
	self.item_cell:SetData(data[num])	--随机显示奖池中的一个物品
	self.item_cell:SetCellBg(ResPath.GetCommon("cell_113"))
end

--刷新按钮按钮特效
function ExploreCreateView:FlushBtnView(index)
	local config = Diamondforge[index].forgeType[1].consume[1] --获取普通打造配置
	local num = BagData.Instance:GetItemNumInBagById(config.id, nil)	--获取背包的钻石数量

	self.btn_effects[1]:setVisible(num > config.count)
	self.btn_effects[2]:setVisible(num > config.count)

	self.node_t_list.lbl_consume_1.node:setColor((num > config.count) and COLOR3B.GREEN or COLOR3B.RED)
	self.node_t_list.lbl_consume_2.node:setColor((num > config.count) and COLOR3B.GREEN or COLOR3B.RED)
	if index == 3 or index == 4 then
		local config2 = Diamondforge[index].forgeType[2].consume[1] --获取精致打造配置
		self.btn_effects[3]:setVisible(num > config2.count)
		self.node_t_list.lbl_consume_3.node:setColor((num > config2.count) and COLOR3B.GREEN or COLOR3B.RED)
	end
end

-- 刷新按钮提示文本
function ExploreCreateView:FlushBtnPromptText(index)
	local config = Diamondforge[index].forgeType[1].consume[1] --获取普通打造配置
	local prob_num = Diamondforge[index].forgeType[1].SuccessProb / 100 --获取钻石打造的成功概率
	if index == 1 or index == 2 then
		--将字符串设入文本节点
		self.node_t_list.lbl_consume_1.node:setString(string.format(Language.XunBao.ConsumeText, config.count))
		self.node_t_list.lbl_prob_1.node:setString(string.format(Language.XunBao.ProbText, prob_num))
	end

	if index == 3 or index == 4 then
		self.node_t_list.lbl_consume_2.node:setString(string.format(Language.XunBao.ConsumeText, config.count))
		self.node_t_list.lbl_prob_2.node:setString(string.format(Language.XunBao.ProbText, prob_num))

		if nil == Diamondforge[index].forgeType[2] then return end	--精致打造配置为空时,跳出

		local config2 = Diamondforge[index].forgeType[2].consume[1] --获取精致打造配置
		prob_num = Diamondforge[index].forgeType[2].SuccessProb / 100 --获取精致打造的成功概率
		self.node_t_list.lbl_consume_3.node:setString(string.format(Language.XunBao.ConsumeText, config2.count))
		self.node_t_list.lbl_prob_3.node:setString(string.format(Language.XunBao.ProbText, prob_num))
	end
end

function ExploreCreateView:FlushChildTagView()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local inner_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL)
	local day = OtherData.Instance:GetOpenServerDays() -- 开服天数
	local open_type = nil
	local child_grid = 0
	local y = 0
	--满足配置中的条件才显示对应的子标签
	for i = 1, 4 do
		open_type = role_level >= Diamondforge[i].openLimit.level and day >= Diamondforge[i].openLimit.serverday
		--开服天数和等级都满足时,判断有无内功条件
		if open_type and Diamondforge[i].openLimit.innerlv then
			open_type = inner_level >= Diamondforge[i].openLimit.innerlv
		end

		if open_type then
			y = 419.45 - child_grid * 120
			local node = self.node_t_list["layout_btn_xb_" .. i].node
			node:setVisible(open_type)
			node:setPosition(57.5, y)
			child_grid = child_grid + 1

			-- 刷新子标签红点提醒
			local config = Diamondforge[i].forgeType[1].consume[1]
			local num = BagData.Instance:GetItemNumInBagById(config.id, nil)
			self:SetRemind(node, i, num > config.count)
		end
	end
end

-- 设置提醒
function ExploreCreateView:SetRemind(node, index, vis, path, x, y)
	path = path or ResPath.GetMainui("remind_flag")
	local size = node:getContentSize()
	x = x or size.width - 15
	y = y or size.height - 17
	if vis and nil == self.remind_bg_sprite[index] then		
		self.remind_bg_sprite[index] = XUI.CreateImageView(x, y, path, true)
		node:addChild(self.remind_bg_sprite[index], 1, 1)
	elseif self.remind_bg_sprite[index] then
		self.remind_bg_sprite[index]:setVisible(vis)
	end
end

-- 刷新打造结果视图
function ExploreCreateView:FlushCreateResultsView()
	local results = ExploreData.Instance:GetCreateResults()
	if results then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.XunBao.CreateSuccess)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.XunBao.CreateFail)
	end
end

--打造按钮点击回调
function ExploreCreateView:OnClickCreateCallBack(create_type)
	local item_type = self.child_index
	ExploreCtrl.Instance:SendDiamondsCreateReq(item_type, create_type)	--发送打造类型到服务端
end

--背包物品改变回调
function ExploreCreateView:BagItemChangeCallBack()
	self:Flush(0, "bag_data_change")
end

return ExploreCreateView