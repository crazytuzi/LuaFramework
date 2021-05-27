--------------------------------------------------------
-- 钻石萌宠-开启宝箱  配置文件名:NormalItemDatas 配置函数名:openItemBoxTable
--------------------------------------------------------

DiamondPetOpenBoxView = DiamondPetOpenBoxView or BaseClass(BaseView)

function DiamondPetOpenBoxView:__init()
	self.texture_path_list[1] = 'res/xui/diamond_pet.png'
	self:SetModal(true)
	self.config_tab = {
		{"diamond_pet_ui_cfg", 2, {0}},
	}
	self.zorder = 98
	self.times = 0 -- 已开启的次数
end

function DiamondPetOpenBoxView:__delete()
end

--释放回调
function DiamondPetOpenBoxView:ReleaseCallBack()
	-- if nil ~= self.tabbar then
	-- 	self.tabbar:DeleteMe()
	-- 	self.tabbar = nil
	-- end
	self.consume_name = nil
end

--加载回调
function DiamondPetOpenBoxView:LoadCallBack(index, loaded_times)
	self:CreateCells()
	self:CreateSelectEffect()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_close"].node, BindTool.Bind(self.OnClose, self))
	XUI.AddClickEventListener(self.node_t_list["btn_open"].node, BindTool.Bind(self.OnOpen, self))
	XUI.AddClickEventListener(self.node_t_list["btn_tip"].node, BindTool.Bind(self.OnTip, self))


	-- 数据监听
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.DURABILITY_CHANGE, BindTool.Bind(self.OnItemDurabilityChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function DiamondPetOpenBoxView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function DiamondPetOpenBoxView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function DiamondPetOpenBoxView:ShowIndexCallBack(index)
	self:Flush()
end

function DiamondPetOpenBoxView:SetData(data)
	self.data = data or {}
end

----------视图函数----------

function DiamondPetOpenBoxView:OnFlush()
	local cfg = openItemBoxTable or {}
	self.cur_cfg = {}
	local item_id = self.data.item_id or 0
	for i,v in ipairs(openItemBoxTable) do
		if item_id == v.item_id then
			self.cur_cfg = v
			break
		end
	end

	self:FlushCells()
	self:FlushConsume()
	self.node_t_list["btn_open"].node:setEnabled(true)
end

function DiamondPetOpenBoxView:CreateCells()
	-- 整齐排列的坐标比例 
	local ratio_list = {
		{x = 0, y = 1}, {x = 0.5, y = 1}, {x = 1, y = 1}, 
		{x = 1, y = 0.5}, 
		{x = 1, y = 0}, {x = 0.5, y = 0}, {x = 0, y = 0}, 
		{x = 0, y = 0.5}, 
	}

	local parent = self.node_t_list["layout_open_box"].node
	local ph = self.ph_list["ph_cell_list"] or {x = 0, y = 0, w = 1, h = 1}
	self.cells = {}
	for i = 1, 8 do
		local cell = BaseCell.New()
		local anchor_point = cell:GetView():getAnchorPoint()
		local ratio = ratio_list[i] or {0, 0}
		local x = ph.x + ((ph.w - BaseCell.SIZE) * ratio.x - BaseCell.SIZE * anchor_point.x)
		local y = ph.y + ((ph.h - BaseCell.SIZE) * ratio.y - BaseCell.SIZE * anchor_point.y)
		cell:GetView():setPosition(x, y)
		parent:addChild(cell:GetView(), 20)
		self.cells[#self.cells + 1] = cell
	end
end

function DiamondPetOpenBoxView:CreateSelectEffect()
	local effect_id = 929
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
	self.quality_effect = AnimateSprite:create(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
	self.quality_effect:setVisible(false)
	self.node_t_list["layout_open_box"].node:addChild(self.quality_effect, 20)
	-- self.quality_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
end

function DiamondPetOpenBoxView:FlushCells()
	self.times = 0
	local cur_awards_cfg = self.cur_cfg.awards or {}
	local data_list = {}
	self.tag = bit:d2b(self.data.durability_max or 0)
	for i,v in ipairs(cur_awards_cfg) do
		self.cells[i]:SetData(ItemData.InitItemDataByCfg(v.award))
		local path = ResPath.GetCommon("img_gou")
		local boor = self.tag[33-i] == 1
		self.cells[i]:SetSpecilImgVisible(boor, path, 40, 40)
		self.cells[i]:MakeGray(boor)
		if i == self.reward_index then
			local select_cell = self.cells[self.reward_index]
			if select_cell then
				local x, y = select_cell:GetView():getPosition()
				self.quality_effect:setPosition(x + 40, y + 40)
				self.quality_effect:setVisible(true)
			end
		end

		if boor then
			self.times  = self.times + 1
		end
	end
end

function DiamondPetOpenBoxView:FlushConsume()
	local consume_cfg = self.cur_cfg.numCfg  and self.cur_cfg.numCfg[self.times + 1] or {}
	local cur_consume =  consume_cfg.consume and consume_cfg.consume[1]
	if nil == cur_consume then return end

	if self.consume_name then
		self.consume_name:removeFromParent()
	end
	local cur_consume_id = cur_consume.id or 0
	local cur_consume_count = cur_consume.count or 0
	local item_cfg = ItemData.Instance:GetItemConfig(cur_consume_id)
	local item_name = item_cfg.name
	local color = Str2C3b(string.format("%06x", item_cfg.color))
	local ph = self.ph_list["ph_consume_name"]
	local parent = self.node_t_list["layout_open_box"].node
	self.consume_name = RichTextUtil.CreateLinkText(item_name, 22, color)
	XUI.AddClickEventListener(self.consume_name, function()
		TipCtrl.Instance:OpenQuickBuyItem({cur_consume_id, nil, cur_consume_count})
	end)
	parent:addChild(self.consume_name, 99)

	local count = BagData.Instance:GetItemNumInBagById(cur_consume_id)
	self.can_open = count >= cur_consume_count
	local times_color = count >= cur_consume_count and COLOR3B.GREEN or COLOR3B.RED
	self.node_t_list["lbl_item_times"].node:setString(string.format(" (%d/%d)", count, cur_consume_count))
	self.node_t_list["lbl_item_times"].node:setColor(times_color)



	-- 调整lbl_item_times坐标
	self.consume_name:setPosition(ph.x, ph.y)
	local size = self.consume_name:getContentSize()
	local x = ph.x + size.width / 2
	local y = ph.y + size.height / 2
	self.node_t_list["lbl_item_times"].node:setPosition(x, y)

	local layout_size = self.node_t_list["layout_open_box"].node:getContentSize()

end
--开始抽奖动画
function DiamondPetOpenBoxView:StartRunning()
	self.select_index = self.select_index or 1
	self.runTime = 0.05
	BagData.Instance:SetDaley(true)
	self.CountDownInstance = CountDown.Instance
	self.tiner1 = self.CountDownInstance:AddCountDown(1.5, self.runTime, BindTool.Bind(self.ChangeSelect, self))
end

--改变选中的格子
function DiamondPetOpenBoxView:ChangeSelect()
	if nil == self.cells then return end
	if self.cells[self.select_index] then  
		self.cells[self.select_index]:SetSelect(false)
	end

	self.select_index = self.select_index <= #self.cells and self.select_index or 1


	-- for k, v in pairs(self.cells) do
		-- v:SetSelect(k == self.select_index)
		-- local eff_id = k == self.select_index and 929 or 0
		-- v:SetQualityEffect(eff_id)
	-- end
	local select_cell = self.cells[self.select_index]
	if select_cell then
		local x, y = select_cell:GetView():getPosition()
		self.quality_effect:setPosition(x + 40, y + 40)
		self.quality_effect:setVisible(true)
	end
	
	local time = self.CountDownInstance:GetRemainTime(self.tiner1)
	if self.runTime > 0.1 then
		if self.reward_index == 0 or self.reward_index == self.select_index then 
			self.CountDownInstance:RemoveCountDown(self.tiner1)
			time = 1
			self.is_runing = false

			----转盘完成后调用
			BagData.Instance:SetDaley(false)
    		self:Flush()
		end
	end
	self.select_index = self.select_index + 1
	if time < 0.1 then
		self.runTime = self.runTime + 0.1
		self.CountDownInstance:RemoveCountDown(self.tiner1)
		self.tiner1 = self.CountDownInstance:AddCountDown(1.5, self.runTime, BindTool.Bind(self.ChangeSelect, self))
	end
end


----------end----------

function DiamondPetOpenBoxView:OnClose()
	BagData.Instance:SetDaley(true)
	local series = self.data.series or 0
	DiamondPetCtrl.SendDeleteBoxReq(series)
	ViewManager.Instance:CloseViewByDef(ViewDef.DiamondPetOpenBox)
end

function DiamondPetOpenBoxView:OnOpen()
	if self.can_open then
		self.node_t_list["btn_open"].node:setEnabled(false)
		local series = self.data.series or 0
		BagCtrl.Instance:SendUseItem(series, 0, 1)
	else
		SysMsgCtrl.Instance:FloatingTopRightText("材料不足")
	end
end

function DiamondPetOpenBoxView:OnBagItemChange()
	self:FlushConsume()
end

function DiamondPetOpenBoxView:OnItemDurabilityChange(item)
	if not self:IsOpen() then
		return
	end

	local series = item.series or 0
	if series == self.data.series then
		local old_tag = self.tag
		self.tag = bit:d2b(item.durability_max or 0)
		for i, v in ipairs(self.tag) do
			if old_tag[i] ~= v then
				self.reward_index = 33 - i
			end
		end
		self.data = item
		self:StartRunning()
	end
end

function DiamondPetOpenBoxView:OnTip()
	DescTip.Instance:SetContent(Language.DescTip.DiamondPetOpenBoxContent, Language.DescTip.DiamondPetOpenBoxTitle)
end

--------------------
