-- 奖励预览
AwardShowTip = AwardShowTip or BaseClass(BaseView)
function AwardShowTip:__init()
	self.is_any_click_close = true		
	self.is_modal =true
	self.config_tab = {
		{"itemtip_ui_cfg", 21, {0}}
	}
end

function AwardShowTip:__delete()

end

function AwardShowTip:ReleaseCallBack()

end

function AwardShowTip:LoadCallBack()
	self:CreateCellList()
end

function AwardShowTip:OpenCallBack()

end

function AwardShowTip:CloseCallBack()

end

function AwardShowTip:SetData(text, item_list)
	self.text = text
	self.item_list = item_list
end

function AwardShowTip:ShowIndexCallBack(index)
	self:Flush()
end

function AwardShowTip:OnFlush(param_t)
	self:FlushCellList()
	self:FlushRichText()
end

function AwardShowTip:CreateCellList()
	local ph = self.ph_list["ph_award_list"]
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.node_t_list["layout_award_show_tip"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, ActBaseCell, ScrollDir.Horizontal, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.cell_list = grid_scroll
	self:AddObj("cell_list")
end

function AwardShowTip:FlushCellList()
	local cfg = self.item_list or {}
	local awards = cfg.awards or {}
	local show_list = self.item_list
	self.cell_list:SetDataList(show_list)

	-- 居中处理
	local view = self.cell_list:GetView()
	local inner = view:getInnerContainer()
	local size = view:getContentSize()
	local inner_width =(BaseCell.SIZE + 10) * (#show_list) - 10
	local view_width = math.min(self.ph_list["ph_award_list"].w, inner_width + 20)
	view:setContentSize(cc.size(view_width, size.height))
	view:setInnerContainerSize(cc.size(inner_width, size.height))
	view:jumpToTop()
end

function AwardShowTip:FlushRichText()
	local rich = self.node_t_list["rich_show_text"].node
	local text = self.text or ""
	rich = RichTextUtil.ParseRichText(rich, text, 20, COLOR3B.WHITE)
	rich:refreshView()
end