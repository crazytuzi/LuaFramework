MapFindRewardView = MapFindRewardView or BaseClass(BaseView)

function MapFindRewardView:__init()
    self.full_screen = false-- 是否是全屏界面
    self.ui_config = {"uis/views/mapfind_prefab", "MapRewardView"}
    self.play_audio = true
end

function MapFindRewardView:__delete()
end

function MapFindRewardView:LoadCallBack()
	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow,self))
	self.cell_list = {}
	self.list = self:FindObj("List")
	self.list_simple_delegate  = self.list.list_simple_delegate
	self.list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
    self.list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function MapFindRewardView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil
	
	self.list_simple_delegate = nil

	self.list = nil
end

function MapFindRewardView:CloseWindow()
	self:Close()
end

function MapFindRewardView:GetNumberOfCells(  )
	return math.ceil(MapFindData.Instance:GetRouteNumber()/2.0)
end

function MapFindRewardView:RefreshView(cell, data_index)
	local left_cell = self.cell_list[cell]
    if left_cell == nil then
        left_cell = MapRewardGroupItem.New(cell.gameObject)
        self.cell_list[cell] = left_cell
    end
    left_cell:SetData(data_index + 1)
end


MapRewardGroupItem = MapRewardGroupItem or BaseClass(BaseRender)

function MapRewardGroupItem:__init(  )
	self.item1 = self:FindObj("item1")
	self.item2 = self:FindObj("item2")
	self.item_1 = MapRewardShowItem.New(self.item1 )
	self.item_2 = MapRewardShowItem.New(self.item2)
end

function MapRewardGroupItem:__delete(  )
	if self.item_1 then
		self.item_1:DeleteMe()
	end
	self.item_1 = nil
	if self.item_2 then
		self.item_2:DeleteMe()
	end
	self.item_2 = nil
end

function MapRewardGroupItem:SetData(index)
	
	local data = MapFindData.Instance:GetMapRewardData(index * 2 - 1)
	self.item_1:SetData(data)
	data = MapFindData.Instance:GetMapRewardData(index * 2)
	if data then
		self.item_2:SetData(data)
		self.item2.gameObject:SetActive(true)
	else
		self.item2.gameObject:SetActive(false)
	end
end

MapRewardShowItem = MapRewardShowItem or BaseClass(BaseRender)

function MapRewardShowItem:__init(  )
	self.item = self:FindObj("Item")
	self.text = self:FindVariable("text")
end

function MapRewardShowItem:__delete(  )
	if self.cell then
		self.cell:DeleteMe()
	end
end

function MapRewardShowItem:SetData(data)
	if nil == self.cell then
		self.cell = ItemCell.New()
		self.cell:SetInstanceParent(self.item)
	end
	self.cell:SetData(data.base_reward_item)
	self.text:SetValue(data.name)
end