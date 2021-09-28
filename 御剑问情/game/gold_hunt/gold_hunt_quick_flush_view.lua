HuntQuickView = HuntQuickView or BaseClass(BaseView)

function HuntQuickView:__init(  )
	self.full_screen = false-- 是否是全屏界面
    self.ui_config = {"uis/views/goldhuntview_prefab", "QuickFlushView"}
    self.play_audio = true
end

function HuntQuickView:__delete(  )
	
end

function HuntQuickView:LoadCallBack(  )
	self.item = {}
	self.rush_list = self:FindObj("ListView")
	local list_delegate = self.rush_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	-- for i=1,8 do
	-- 	self.item[i] = self:FindObj("item" .. i)
	-- 	self.rush_item[i] = MapfindRushItem.New(self.item[i])
	-- 	self.rush_item[i]:SetData(i)

	-- end
	self.cfg = GoldHuntData.Instance:GetHuntInfoCfg()
	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow,self))
	self:ListenEvent("ClickStart",BindTool.Bind(self.ClickStart,self))
	GoldHuntData.Instance:ClearSelect()
end

function HuntQuickView:ReleaseCallBack()

	for k,v in pairs(self.item) do
		v:DeleteMe()
	end
	self.rush_list = nil
end

function HuntQuickView:GetNumberOfCells()
	return math.ceil(#self.cfg / 2)
end

function HuntQuickView:RefreshCell(cell, data_index)
	data_index = math.ceil(#self.cfg / 2) - data_index - 1 	--倒序
	local group = self.item[cell]

	if nil == group then
		group = HuntQuickItem.New(cell.gameObject)
		self.item[cell] = group
	end

	local hunt = {}
	for k,v in pairs(self.cfg) do
		if v.seq == data_index*2 or v.seq == data_index*2 + 1 then
			table.insert(hunt, 1, v)
		end
	end
	group:SetData(hunt)
end


function HuntQuickView:CloseWindow()
	self:Close()
end

function HuntQuickView:ClickStart()
	if not next(GoldHuntData.Instance:GetSelect()) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Gold.NoAnimal)
		return
	end
	GoldHuntCtrl.Instance:BeginRush()
	self:Close()
end

HuntQuickItem = HuntQuickItem or BaseClass(BaseRender)

function HuntQuickItem:__init(  )
	self.item = {}
	for i=1,2 do
		self.item["text"..i] = self:FindVariable("text"..i)
		self:ListenEvent("OnToggle1", BindTool.Bind(self.OnClick1,self))
		self:ListenEvent("OnToggle2", BindTool.Bind(self.OnClick2,self))
		-- self.item["item_cell"..i] = self:FindObj("ItemCell"..i)
		self.item["hunt"..i] = self:FindObj("HuntCell"..i)
		self.item["cell"..i] = ItemCell.New()
		self.item["cell"..i]:SetInstanceParent(self:FindObj("ItemCell"..i))
		self.item["animal"..i] = self:FindVariable("Animal"..i)
		self.item["show"..i] = self:FindVariable("ShowIcon"..i)
	end

end

function HuntQuickItem:__delete()
	for i=1,2 do
		if self.item["cell"..i] then
			self.item["cell"..i]:DeleteMe()
			self.item["cell"..i] = nil
		end
	end
end

function HuntQuickItem:SetData(data)
	for i=1,2 do
		if data[i] == nil then
			return
		end
		self.item["index"..i] = data[i].seq
		local name = data[i].name
		self.item["text"..i]:SetValue(name)
		self.item["cell"..i]:SetData(data[i].exchange_item)
		self.item["show"..i]:SetValue(true)
		self.item["animal"..i]:SetAsset(ResPath.GetGoldHuntModelHeadImg("head_" .. (data[i].seq + 1)))

		local cur_select_t = GoldHuntData.Instance:GetSelect()
		if cur_select_t then
			if cur_select_t[self.item["index"..i]] then
				self.item["hunt"..i].toggle.isOn = true
			else
				self.item["hunt"..i].toggle.isOn = false
			end
		end
	end
end

function HuntQuickItem:OnClick1()
	GoldHuntData.Instance:SetSelect(self.item.index1, self.item.hunt1.toggle.isOn)
end

function HuntQuickItem:OnClick2()
	GoldHuntData.Instance:SetSelect(self.item.index2, self.item.hunt2.toggle.isOn)
end