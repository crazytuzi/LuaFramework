MijiBagView = MijiBagView or BaseClass(BaseView)
local COLUMN = 2
function MijiBagView:__init()
    self.ui_config = {"uis/views/shengeview", "MijiBagView"}
    self.play_audio = true
    self.slot_index = 0
end

function MijiBagView:__delete()
end

function MijiBagView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	-- 清理变量和对象
	self.list_view = nil
end

function MijiBagView:LoadCallBack()
	self.list_data = {}
	self.cell_list = {}

	self.list_view = self:FindObj("ListView")
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

function MijiBagView:OpenCallBack()
	self:FlushView()
end

function MijiBagView:CloseCallBack()
	
end

function MijiBagView:FlushView()
	self.list_data = ShengXiaoData.Instance:GetBagMijiList()
	self.list_view.scroller:ReloadData(0)
end

function MijiBagView:CloseWindow()
	self:Close()
end

function MijiBagView:GetCellNumber()
	return math.ceil(#self.list_data/COLUMN)
end

function MijiBagView:CellRefresh(cell, data_index)
	local group_cell = self.cell_list[cell]
	if not group_cell then
		group_cell = MijiBagGroupCell.New(cell.gameObject)
		group_cell:SetToggleGroup(self.list_view.toggle_group)
		self.cell_list[cell] = group_cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		group_cell:SetIndex(i, index)
		local data = self.list_data[index]
		group_cell:SetActive(i, data ~= nil)
		group_cell:SetData(i, data)
		group_cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
	end
end

function MijiBagView:ItemCellClick(cell)
	local data = cell:GetData()
	if not data or not next(data) then
		return
	end
	local shenxiao_index = ShengXiaoData.Instance:GetMijiShengXiaoIndex()
	local cur_miji_list = ShengXiaoData.Instance:GetZodiacMijiList(shenxiao_index)
	local click_type = ShengXiaoData.Instance:GetMijiCfgByIndex(data.cfg_index).type
	for k,v in pairs(cur_miji_list) do
		if v >= 0 then
			local one_type = ShengXiaoData.Instance:GetMijiCfgByIndex(v).type
			if one_type == click_type then
				SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.HaveMiji)
				return
			end
		end
	end
	ShengXiaoCtrl.Instance:SetSelectStudyData(data)	
	self:Close()
end

function MijiBagView:OnFlush(params_t)
	self:FlushView()
end


-------------------MijiBagGroupCell-----------------------
MijiBagGroupCell = MijiBagGroupCell or BaseClass(BaseRender)
function MijiBagGroupCell:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local bag_item = MijiBagItemCell.New(self:FindObj("Item" .. i))
		table.insert(self.item_list, bag_item)
	end
end

function MijiBagGroupCell:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function MijiBagGroupCell:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function MijiBagGroupCell:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function MijiBagGroupCell:SetToggleGroup(group)
	for k, v in ipairs(self.item_list) do
		v:SetToggleGroup(group)
	end
end

function MijiBagGroupCell:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function MijiBagGroupCell:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

-------------------MijiBagItemCell-----------------------
MijiBagItemCell = MijiBagItemCell or BaseClass(BaseCell)
function MijiBagItemCell:__init()
	self.level_des = self:FindVariable("LevelDes")
	self.attr_des_1 = self:FindVariable("AttrDes1")
	self.attr_des_2 = self:FindVariable("AttrDes2")
	self.show_repeat = self:FindVariable("ShowRepeat")
	self.image_res = self:FindVariable("ImageRes")
	self.num = self:FindVariable("num")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item"))

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function MijiBagItemCell:__delete()
	if nil ~= self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function MijiBagItemCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function MijiBagItemCell:SetHighLight(state)
	self.root_node.toggle.isOn = state
end

function MijiBagItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local miji_cfg = ShengXiaoData.Instance:GetMijiCfgByIndex(self.data.cfg_index)
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.level_des:SetValue(name_str)
	self.attr_des_1:SetValue(miji_cfg.type_name)
	self.attr_des_2:SetValue(miji_cfg.capacity)
	if miji_cfg.type < 10 then
		local data = {}
		data[SHENGXIAO_MIJI_TYPE[miji_cfg.type]] = miji_cfg.value
		self.attr_des_2:SetValue(CommonDataManager.GetCapabilityCalculation(data))
	end
	self.num:SetValue(self.data.item_num)
	self.show_repeat:SetValue(self.data.have_type == 0)

	if self.data.item_id > 0 then
		self.item_cell:SetData({item_id = self.data.item_id, num = self.data.item_num})
	end
end