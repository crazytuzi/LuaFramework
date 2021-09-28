AllMijiView = AllMijiView or BaseClass(BaseView)
local COLUMN = 3
function AllMijiView:__init()
    self.ui_config = {"uis/views/shengxiaoview_prefab", "AllMijiView"}
    self.play_audio = true
    self.slot_index = 0
end

function AllMijiView:__delete()
end

function AllMijiView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	-- 清理变量和对象
	self.list_view = nil
end

function AllMijiView:LoadCallBack()
	self.list_data = {}
	self.cell_list = {}

	self.list_view = self:FindObj("ListView")
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

function AllMijiView:OpenCallBack()
	self:FlushView()
end

function AllMijiView:CloseCallBack()
	
end

function AllMijiView:FlushView()
	self.list_data = ShengXiaoData.Instance:GetAllMijiList()
	self.list_view.scroller:ReloadData(0)
end

function AllMijiView:CloseWindow()
	self:Close()
end

function AllMijiView:GetCellNumber()  						--行数
	return math.ceil(#self.list_data/COLUMN)				--总/列数
end

function AllMijiView:CellRefresh(cell, data_index)  		--cell为绑定的prefab  data_index为当前刷新的cell下标（第几行）
	local group_cell = self.cell_list[cell]
	if not group_cell then
		group_cell = AllMijiGroupCell.New(cell.gameObject)  --把cell脚本绑定给cell的prefab
		--group_cell:SetToggleGroup(self.list_view.toggle_group)
		self.cell_list[cell] = group_cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		group_cell:SetIndex(i, index) 						--i在当前行元素的下标，index所有元素的下标
		local data = self.list_data[index]
		group_cell:SetActive(i, data ~= nil)
		group_cell:SetData(i, data)
	end
end

function AllMijiView:OnFlush(params_t)
	self:FlushView()
end


-------------------AllMijiGroupCell-----------------------
AllMijiGroupCell = AllMijiGroupCell or BaseClass(BaseRender)
function AllMijiGroupCell:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local bag_item = MijiItemCell.New(self:FindObj("Item" .. i))
		table.insert(self.item_list, bag_item)
	end
end

function AllMijiGroupCell:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function AllMijiGroupCell:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function AllMijiGroupCell:SetData(i, data)
	self.item_list[i]:SetData(data)
end

-- function AllMijiGroupCell:SetToggleGroup(group)
-- 	for k, v in ipairs(self.item_list) do
-- 		v:SetToggleGroup(group)
-- 	end
-- end

function AllMijiGroupCell:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function AllMijiGroupCell:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

-------------------MijiItemCell-----------------------
MijiItemCell = MijiItemCell or BaseClass(BaseCell)
function MijiItemCell:__init()
	self.level_des = self:FindVariable("LevelDes")  --秘籍名称
	self.attr_des_1 = self:FindVariable("AttrDes1")	--秘籍效果
	self.attr_des_2 = self:FindVariable("AttrDes2") --战力
	self.image_res = self:FindVariable("ImageRes")
	self.num = self:FindVariable("num")
	--self.item_cell:ListenClick(BindTool.Bind(self.OnClick, self))

	--self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function MijiItemCell:__delete()
end

function MijiItemCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function MijiItemCell:SetHighLight(state)
	self.root_node.toggle.isOn = state
end

function MijiItemCell:OnFlush()
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

	if self.data.item_id > 0 then
		self.image_res:SetAsset(ResPath.GetItemIcon(self.data.item_id))
		--self.item_cell:SetData({item_id = self.data.item_id, num = self.data.item_num})
	end
end