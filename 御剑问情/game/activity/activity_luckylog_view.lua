LuckyLogView = LuckyLogView or BaseClass(BaseView)
function LuckyLogView:__init()
	self.ui_config = {"uis/views/luckylog_prefab","LuckyLog"}
	self.full_screen = false
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
end

function LuckyLogView:__delete()
end

function LuckyLogView:LoadCallBack()
	self.log_item_list = {}
	self.list_view = self:FindObj("ListView")
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView,self))
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function LuckyLogView:GetNumberOfCells()
	local info = ActivityData.Instance:GetActivityLogInfo()
	if info and info.count then
		return info.count
	end

	return 0
end

function LuckyLogView:RefreshCell(cell, data_index)
	local cfg = ActivityData.Instance:GetActivityLogInfo()
	data_index = data_index + 1
	local the_cell = self.log_item_list[cell]

	if nil ~= cfg and nil ~= cfg.log_item then
		if the_cell == nil then
			the_cell = LuckyLogItem.New(cell.gameObject)
			self.log_item_list[cell] = the_cell
		end
		the_cell:SetIndex(data_index)
		the_cell:SetData(cfg.log_item[data_index])
	end
end

function LuckyLogView:OpenCallBack()
	self.list_view.scroller:ReloadData(0)
end

function LuckyLogView:OnFlush()
	self.list_view.scroller:ReloadData(0)
end

function LuckyLogView:CloseView()
	self:Close()
end

function LuckyLogView:CloseCallBack()

end

function LuckyLogView:ReleaseCallBack()
	self.list_view = nil
	if next(self.log_item_list) ~= nil then
		local x = #self.log_item_list
		for i=1,x do
			self.log_item_list[i]:DeleteMe()
		end
	end
	self.log_item_list = {}
end

--------------抽奖列表
LuckyLogItem = LuckyLogItem or BaseClass(BaseCell)
function LuckyLogItem:__init()
	self.get_time = self:FindVariable("get_time")
	self.info = self:FindVariable("Info")
	self.is_show = self:FindVariable("is_show")
	self.index = 0
end

function  LuckyLogItem:__delete()
	self.get_time = nil
	self.info = nil
	self.is_show = nil
end

function LuckyLogItem:OnFlush()
	local item_info = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_info then
		return
	end

	local log_num = #(Language.Common.LuckyLog) or 1
	local log_text = Language.Common.LuckyLog[math.random(1, log_num)]
	local item_name = ToColorStr(item_info.name, ITEM_COLOR[item_info.color])
	local time = os.date("%X", self.data.timestamp)
	self.get_time:SetValue(time)
	if self.data.item_num > 1 then
		item_name = item_name .. " * " .. self.data.item_num
	end

	self.info:SetValue(string.format(log_text, self.data.role_name, item_name))

	self.is_show:SetValue(0 == self.index % 2)
end