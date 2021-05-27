------------------------------------------------------------
--神秘商城极品预览View
------------------------------------------------------------
ShopPreviewView = ShopPreviewView or BaseClass(BaseView)
local ShopPreviewRender = BaseClass(BaseRender)

function ShopPreviewView:__init()
	self.view_name = ViewName.Shop
	self.texture_path_list[1] = "res/xui/shangcheng.png"
	self:SetIsAnyClickClose(true)
	
	self.config_tab = {
		{"common2_ui_cfg", 1, {0}},
		{"shop_ui_cfg", 4, {0}},
		{"common2_ui_cfg", 2, {0}},
	}

end

function ShopPreviewView:__delete()
end

--释放回调
function ShopPreviewView:ReleaseCallBack()
	if self.grid_best_list then
		self.grid_best_list:DeleteMe()
		self.grid_best_list = nil
	end
end

function ShopPreviewView:LoadCallBack(index, loaded_times)
	self:UpdateGridScroll()
end

--商店打开回调
function ShopPreviewView:OpenCallBack()
	-- AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.ShopOpen))
end

function ShopPreviewView:OnFlush(param_t, index)
	self:UpdateGridScroll()
end

----------------------------------------
-- 滚动控件
function ShopPreviewView:UpdateGridScroll()
	if nil == self.node_t_list.layout_other_shop then
		local ph = self.ph_list.ph_shop_preview
		local grid_scroll = GridScroll.New()
		grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 4, 120, ShopPreviewRender, ScrollDir.Vertical, false, self.ph_list.ph_best)
		self.grid_best_list = grid_scroll
		self.node_t_list.layout_preview_window.node:addChild(grid_scroll:GetView(), 3)

		self.grid_best_list:SetDataList(ShopData.Instance.GetPreViewList())
		self.grid_best_list:JumpToTop()
	end
end

--关闭回调
function ShopPreviewView:CloseCallBack(is_all)
	-- AudioManager.Instance:StopEffect(ResPath.GetAudioEffectResPath(AudioEffect.ShopOpen))
	-- AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.ShopClose))
end

---ShopPreviewRender-----极品预览配置

function ShopPreviewRender:__init()
	self.item_cell = nil
end

function ShopPreviewRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ShopPreviewRender:CreateChild()
	BaseRender.CreateChild(self)
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(self.ph_list.ph_jp.x, self.ph_list.ph_jp.y)

	self.item_cell:SetCellBg(ResPath.GetShangCheng("shop_cell_bg"))
	self.item_cell:GetView():setAnchorPoint(cc.p(0.5, 0.5))
	self.view:addChild(self.item_cell:GetView(), 7)
end

function ShopPreviewRender:OnFlush()
	if nil == self.data then
		return
	end

	local item_config = ItemData.Instance:GetItemConfig(self.data.id)
	
	self.item_cell:SetData(ItemData.FormatItemData(self.data))
	
	self.node_tree.lbl_jp.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))
	self.node_tree.lbl_jp.node:setString(item_config.name)
end

function ShopPreviewRender:CreateSelectEffect()
	return
end

function ShopPreviewRender:OnClickBuyBtn()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function ShopPreviewRender:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end