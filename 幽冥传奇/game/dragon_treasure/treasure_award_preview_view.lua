--------------------------------------------------------
-- 秘宝预览  配置 
--------------------------------------------------------

TreasureAwardPreviewView = TreasureAwardPreviewView or BaseClass(XuiBaseView)

function TreasureAwardPreviewView:__init()
	self.texture_path_list[1] = 'res/xui/dragon_treasure.png'
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.config_tab = {
		{"dragon_treasure_ui_cfg", 4, {0}},
	}
end

function TreasureAwardPreviewView:__delete()
end

--释放回调
function TreasureAwardPreviewView:ReleaseCallBack()
	if nil ~= self.cell_list then
		self.cell_list:DeleteMe()
		self.cell_list = nil
	end

end

--加载回调
function TreasureAwardPreviewView:LoadCallBack(index, loaded_times)
	self:CreateCellList()


end

function TreasureAwardPreviewView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TreasureAwardPreviewView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function TreasureAwardPreviewView:ShowIndexCallBack(index)
	self:Flush()

end

function TreasureAwardPreviewView:OnFlush(param_list)
	local index = DragonTreasureData.Instance:GetTreasureIndex(self.index) or 1
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.LZMB).config.things[index]
	if #(cfg or {}) > 16 then
		local list = {}
		for i = 1, 16 do
			list[i] = cfg[i]
		end
		cfg = list
	end
	self.cell_list:SetDataList(cfg)
end

----------视图函数----------

-- 创建"物品列表"视图
function TreasureAwardPreviewView:CreateCellList()
	local ph_item = self.ph_list["ph_cell"]
	local ph = self.ph_list["ph_cell_list"]
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 4, ph_item.h + 1, self.CellItem, ScrollDir.Vertical, false, ph_item)
	-- grid_scroll:GetView():setAnchorPoint(0, 0)
	self.node_t_list["layout_award_preview"].node:addChild(grid_scroll:GetView(), 20)
	self.cell_list = grid_scroll
end


----------end----------

function TreasureAwardPreviewView:OnOpen()

end

--------------------

----------------------------------------
-- 物品Item
----------------------------------------
TreasureAwardPreviewView.CellItem = BaseClass(BaseRender)
local CellItem = TreasureAwardPreviewView.CellItem
function CellItem:__init()
	self.item_cell = nil
end

function CellItem:__delete()
	if nil ~= self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function CellItem:CreateChild()
	BaseRender.CreateChild(self)
	local item_cell = BaseCell.New()
	item_cell:GetView():setAnchorPoint(0.5, 0.5)
	item_cell:GetView():setPosition(40, 40)
	self.view:addChild(item_cell:GetView(), 10)
	self.item_cell = item_cell
end

function CellItem:OnFlush()
	if nil == self.data then return end

	local item_cfg = ItemData.InitItemDataByCfg(self.data)
	self.item_cell:SetData(item_cfg)
end

function CellItem:CreateSelectEffect()
	return
end

function CellItem:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end
