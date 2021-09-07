-- 寻灵界面
local BAG_MAX_GRID_NUM = 140			-- 最大格子数
local BAG_PAGE_NUM = 7					-- 页数
local BAG_PAGE_COUNT = 20				-- 每页个数
local BAG_ROW = 5						-- 行数
local BAG_COLUMN = 4					-- 列数

SymbolMishiView = SymbolMishiView or BaseClass(BaseRender)

local path = {
	{x = 88, y = -120},
	{x = -36.4, y = 112.4},
	{x = 0, y = -50},
	{x = -91.6, y = 68.7},
	{x = -75.3, y = -112.9},
	{x = 44.2, y = 109.5},
	{x = -137.6, y = -56},
	{x = 97.8, y = 64.4},
	{x = -109.9, y = 3.3},
	{x = -39.5, y = 5.1},
	{x = -68.2, y = -54.9},
	{x = 105.7, y = -7.2},
	{x = 43, y = 6.8},
	{x = 66.3, y = -60},
	{x = 127.6, y = -75.8},
	{x = 1.7, y = 59.1},
}

local fall_item_y = -18.7
local max_count = 16
function SymbolMishiView:__init()
	self.enough_consume1 = false
	self.enough_consume10 = false
	-- 获取控件
	self.is_moving = self:FindVariable("IsMoving")
	self.is_mask = self:FindVariable("IsMask")
	self.consume_score = self:FindVariable("ConsumeScore")
	self.cur_score = self:FindVariable("CurScore")
	self.one_sonsume = self:FindVariable("OneConsume")
	self.ten_consume = self:FindVariable("TenConsume")
	self.is_free = self:FindVariable("IsFree")

	self.mish_cell = self:FindObj("MishCell")
	local variable_table = self.mish_cell:GetComponent(typeof(UIVariableTable))
	self.fall_icon = variable_table:FindVariable("Icon")

	self.bag_list_view = self:FindObj("ListView")
	self.bag_cell = {}
	local list_delegate = self.bag_list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)
	self.bag_list_view.list_view:JumpToIndex(0)
	self.bag_list_view.list_view:Reload()

	local toggle_list = self:FindObj("PageButtons")
	self.toggle_list = {}
	for i = 1, BAG_PAGE_NUM do
		local transform = toggle_list.transform:FindHard("Toggle" .. i)
		if transform ~= nil then
			node = U3DObject(transform.gameObject, transform)
			if node then
				self.toggle_list[i] = node
			end
		end
	end

	local item_panel = self:FindObj("ItemPanel")
	self.gift_list = {}
	self.tweent_list = {}
	local res_list = SymbolData.Instance:GetItemResList()
	for i = 1, max_count do
		GameObjectPool.Instance:SpawnAsset("uis/views/symbol_prefab","MishiCell", function(obj)
				if nil == obj then
					return
				end
				obj.transform:SetParent(item_panel.transform, false)
				local variable_table = obj:GetComponent(typeof(UIVariableTable))
				local icon = variable_table:FindVariable("Icon")
				icon:SetAsset(ResPath.GetItemIcon(res_list[i] or res_list[math.random(1, #res_list)]))
				local x = path[i] and path[i].x or path[1].x
				local y = path[i] and path[i].y or path[1].y
				obj.transform:SetLocalPosition(x, y, 0)
				self.gift_list[i] = obj.transform
			end)
	end

	self:ListenEvent("OnClickOne", BindTool.Bind(self.OnClickOne, self))
	self:ListenEvent("OnClickTen", BindTool.Bind(self.OnClickTen, self))
	self:ListenEvent("OnClickClean", BindTool.Bind(self.OnClickClean, self))
	self:ListenEvent("OnClickMask", BindTool.Bind(self.OnClickMask, self))
	self:ListenEvent("OnClickConsumeScore", BindTool.Bind(self.OnClickConsumeScore, self))
	self:ListenEvent("OnClickAddScore", BindTool.Bind(self.OnClickAddScore, self))
end

function SymbolMishiView:__delete()
	if self.bag_cell then
		for k,v in pairs(self.bag_cell) do
			v:DeleteMe()
		end
		self.bag_cell = {}
	end
end

-----------------------------------
-- ListView
-----------------------------------
function SymbolMishiView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM
end

function SymbolMishiView:BagRefreshCell(index, cellObj)
	-- 构造Cell对象.
	local cell = self.bag_cell[cellObj]
	if nil == cell then
		cell = ItemCell.New(cellObj)
		cell:Reset()
		cell:SetToggleGroup(self.root_node.toggle_group)
		self.bag_cell[cellObj] = cell
	end

	local page = math.floor(index / BAG_PAGE_COUNT)
	local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
	local cur_row = math.floor(index % BAG_ROW) + 1
	local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm  + page * BAG_ROW * BAG_COLUMN


	-- 获取数据信息
	local data = SymbolData.Instance:GetAllElementItemList()[grid_index + 1] or {}

	local cell_data = {}
	cell_data.item_id = data.item_id
	cell_data.index = data.index or grid_index
	cell_data.param = data.param
	cell_data.num = data.num
	cell_data.is_bind = data.is_bind

	cell:SetIconGrayScale(false)
	cell:ShowQuality(nil ~= cell_data.item_id)

	cell:SetData(cell_data, true)
	cell:SetHighLight(false)
	cell:ListenClick(BindTool.Bind(self.HandleBagOnClick, self, cell_data, cell))
	cell:SetInteractable(true)
end


--点击格子事件
function SymbolMishiView:HandleBagOnClick(data, cell)
	local close_callback = function ()
		self.cur_index = nil
		cell:SetHighLight(false)
	end

	self.cur_index = data.index
	cell:SetHighLight(self.view_state ~= BAG_SHOW_RECYCLE)
	-- 弹出面板
	local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
	if nil ~= item_cfg1 then
		TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_BAG, nil, close_callback)
	end
end

function SymbolMishiView:OpenCallBack()
	self.is_moving:SetValue(false)
	for k,v in pairs(self.gift_list) do
		local x = path[k] and path[k].x or path[1].x
		local y = path[k] and path[k].y or path[1].y
		v:SetLocalPosition(x, y, 0)
	end
	self:Flush()
end

function SymbolMishiView:CloseCallBack()
	if self.tweent_list then
		for k,v in pairs(self.tweent_list) do
			v:Kill()
		end
		self.tweent_list = {}
	end
end

function SymbolMishiView:OnClickOne()
	if not self.enough_consume1 then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end
	self:StartTween(1)
end

function SymbolMishiView:OnClickTen()
	if not self.enough_consume10 then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end
	self:StartTween(10)
end

function SymbolMishiView:StartTween(count, index)
	if self.is_moving:GetBoolean() and nil == index then
		return
	end
	index = index or 1
	if index > 1 or self.is_mask:GetBoolean() then
		local use_score = self.consume_score:GetBoolean() and 1 or 0
		SymbolCtrl.Instance:SendChoujiangElementHeartReq(count, use_score)
		self.is_moving:SetValue(false)
		self.tweent_list = {}
		return
	end
	self.is_moving:SetValue(true)
	local random = math.random(max_count, max_count + 5)
	for k,v in ipairs(self.gift_list) do
		local path = {}
		for i = 1, random do
			if self.gift_list[k + i] then
				table.insert(path, self.gift_list[k + i].position)
			elseif (k + i - #self.gift_list) % max_count ~= 0 then
				table.insert(path, self.gift_list[(k + i - #self.gift_list) % max_count].position)
			else
				table.insert(path, self.gift_list[max_count].position)
			end
		end
		local rotate_self = v:DOLocalRotate(
		Vector3(0, 0, 360 * random), 0.5 * random, DG.Tweening.RotateMode.FastBeyond360)
		local move_center = v:DOPath(
		path,
		0.5 * random,
		DG.Tweening.PathType.Linear,			--Linear直来直往的, CatmullRom平滑的（一般是在转弯的时候）
		DG.Tweening.PathMode.TopDown2D,
		1)
		local sequence = DG.Tweening.DOTween.Sequence()
		sequence:Append(move_center)
		sequence:Insert(0, rotate_self)
		sequence:SetEase(DG.Tweening.Ease.InOutQuad)
		if k == #self.gift_list then
			sequence:AppendCallback(BindTool.Bind(self.StartTween, self, count, index + 1))
		end
		self.tweent_list[k] = sequence
	end
end

function SymbolMishiView:DoFallTween(item_id)
	if self.mish_cell.gameObject.activeSelf then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg then
		self.fall_icon:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
	end
	self.mish_cell:SetActive(true)
	self.mish_cell.transform:SetLocalScale(0.1, 0.1, 0.1)
	local pos = self.mish_cell.transform.localPosition
	self.mish_cell.transform:SetLocalPosition(pos.x, fall_item_y, pos.z)
	local rotate_self = self.mish_cell.transform:DOLocalRotate(
	Vector3(0, 0, 360), 1, DG.Tweening.RotateMode.FastBeyond360)
	local move_self = self.mish_cell.transform:DOLocalMoveY(fall_item_y - 30, 1)
	local scale_self = self.mish_cell.transform:DOScale(Vector3(1, 1, 1), 1)

	local sequence = DG.Tweening.DOTween.Sequence()
	sequence:Append(move_self)
	sequence:Insert(0, rotate_self)
	sequence:Insert(0, scale_self)
	sequence:SetEase(DG.Tweening.Ease.InOutQuad)
	sequence:AppendCallback(function ()
		self.mish_cell:SetActive(false)
	end)
end

function SymbolMishiView:OnClickClean()
	SymbolCtrl.Instance:SendCleanBagElementHeartReq(false)
end

function SymbolMishiView:OnClickMask()
	local is_mask = self.is_mask:GetBoolean()
	self.is_mask:SetValue(not is_mask)
end

function SymbolMishiView:OnClickConsumeScore()
	local consume_score = self.consume_score:GetBoolean()
	self.consume_score:SetValue(not consume_score)
	self:FlushBtnText()
end

function SymbolMishiView:OnClickAddScore()
	ActivityCtrl.Instance:ShowDetailView(ACTIVITY_TYPE.KF_FARMHUNTING)
end

function SymbolMishiView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "chou_reward" then
			self:DoFallTween(v.item_id)
		end
	end
	if nil ~= self.bag_list_view.list_view and self.bag_list_view.list_view.isActiveAndEnabled then
		self.bag_list_view.list_view:JumpToIndex(0)
		self.bag_list_view.list_view:Reload()
	end
	self:FlushBtnText()
end

function SymbolMishiView:FlushBtnText()
	if self.cur_score == nil then
		return
	end

	local score = SymbolData.Instance:GetPastureScore()
	local free_times = SymbolData.Instance:GetMishiFreeTimes()
	self.cur_score:SetValue(score)

	local other_cfg = ConfigManager.Instance:GetAutoConfig("element_heart_cfg_auto").other[1]
	local str1 = ""
	local str2 = ""
	local color = ""
	if self.consume_score:GetBoolean() then
		color = score < other_cfg.one_chou_need_score and "#ff0000" or "#ffff00"
		str1 = string.format(Language.Symbol.OneConsume, color, other_cfg.one_chou_need_score, Language.Symbol.ConsumeType[1])
		color = score < other_cfg.ten_chou_need_score and "#ff0000" or "#ffff00"
		str2 = string.format(Language.Symbol.OneConsume, color, other_cfg.ten_chou_need_score, Language.Symbol.ConsumeType[1])
		self.enough_consume1 = score >= other_cfg.one_chou_need_score
		self.enough_consume10 = score >= other_cfg.one_chou_need_score
	else
		local gold = PlayerData.Instance:GetRoleVo().gold
		color = gold < other_cfg.one_chou_need_gold and "#ff0000" or "#ffff00"
		str1 = "    " .. string.format(Language.Symbol.OneConsume, color, other_cfg.one_chou_need_gold, Language.Symbol.ConsumeType[2])
		color = gold < other_cfg.ten_chou_need_gold and "#ff0000" or "#ffff00"
		str2 = "    " .. string.format(Language.Symbol.OneConsume, color, other_cfg.ten_chou_need_gold, Language.Symbol.ConsumeType[2])
		self.enough_consume1 = gold >= other_cfg.one_chou_need_gold
		self.enough_consume10 = gold >= other_cfg.ten_chou_need_gold
	end
	self.is_free:SetValue(other_cfg.one_chou_free_chou_times - free_times > 0)
	if other_cfg.one_chou_free_chou_times - free_times > 0 then
		self.enough_consume1 = true
		str1 = string.format(Language.Symbol.FreeTimes, other_cfg.one_chou_free_chou_times - free_times)
	end
	self.one_sonsume:SetValue(str1)
	self.ten_consume:SetValue(str2)
end
