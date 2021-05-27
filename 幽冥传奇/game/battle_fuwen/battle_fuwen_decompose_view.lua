DecomposeZhanwenView = DecomposeZhanwenView or BaseClass(BaseView)

function DecomposeZhanwenView:__init()
	if DecomposeZhanwenView.Instance then
		ErrorLog("DecomposeZhanwenView.Instance is have!!!")
	end
	DecomposeZhanwenView.Instance = self

	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/battle_fuwen.png',
		'res/xui/bag.png'
	}
	self.config_tab = {
		{"battle_fuwen_ui_cfg", 2, {0}},
	}

end

function DecomposeZhanwenView:ReleaseCallBack()
	if self.equip_select_grid ~= nil then
		self.equip_select_grid:DeleteMe()
		self.equip_select_grid = nil
	end
	self.equip_select_grid = nil

	if self.quality_select_list ~= nil then
		self.quality_select_list:DeleteMe()
		self.quality_select_list = nil
	end
	self.quality_select_list = nil 
end

function DecomposeZhanwenView:LoadCallBack(index, loaded_times)
	self:CreateEquipSelectGrid()
	self:CreateEquipQualitySelectList()
	EventProxy.New(BattleFuwenData.Instance, self):AddEventListener(BattleFuwenData.BATTLE_FUWEN_ONE_INFO_CHANGE, BindTool.Bind(self.OnDataChange, self))
	EventProxy.New(BattleFuwenData.Instance, self):AddEventListener(BattleFuwenData.BATTLE_FUWEN_DECOMPOSE_GET_NUM_CHANGE, BindTool.Bind(self.OnDecomposeGetNumChange, self))
	XUI.AddClickEventListener(self.node_t_list.btn_decompose_quick.node, function () BattleFuwenData.Instance:SendDecompose() end)
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, function () 
		self.equip_select_grid:SetDataList(BattleFuwenData.Instance:GetBagShowBattleLineList())
		self.equip_select_grid:JumpToTop()
	end)
	RichTextUtil.ParseRichText(self.node_t_list.rich_zw_jiejing_num.node, BattleFuwenData.Instance:GetZhanwenJinghuaNum(), 22, COLOR3B.OLIVE)
	self.old_num = BattleFuwenData.Instance:GetZhanwenJinghuaNum()
end


function DecomposeZhanwenView:CreateEquipQualitySelectList()
	local ph = self.ph_list.ph_quality_select_list
	self.quality_select_list = ListView.New()
	self.quality_select_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ZhanwenQualitySelectItemRender, nil, nil, self.ph_list.ph_select_item)
	self.quality_select_list:SetItemsInterval(4)
	self.quality_select_list:SetMargin(2)
	self.node_t_list.layout_decompose.node:addChild(self.quality_select_list:GetView(), 300)

	self.quality_select_list:SetDataList{
		{name = "绿", color = COLOR3B.GREEN, quality = 1},
		{name = "蓝", color = COLOR3B.BLUE, quality = 2},
		{name = "紫", color = COLOR3B.PURPLE, quality = 3},
		{name = "橙", color = COLOR3B.ORANGE2, quality = 4},
		{name = "红", color = COLOR3B.RED, quality = 5},
	}

	self.quality_select_list:SelectIndex(1)
end

function DecomposeZhanwenView:CreateEquipSelectGrid()
	self.equip_select_grid = GridScroll.New()
	local ph_decompose_list = self.ph_list.ph_decompose_list
	local grid_node = self.equip_select_grid:Create(ph_decompose_list.x, ph_decompose_list.y, ph_decompose_list.w, ph_decompose_list.h, 4, 160, ZhanwenSelectItemRender, ScrollDir.Vertical, false, self.ph_list.ph_decompose_item)
	grid_node:setAnchorPoint(0, 0)
	self.node_t_list.layout_decompose.node:addChild(grid_node, 1)
	grid_node:setPosition(ph_decompose_list.x, ph_decompose_list.y)
	self.equip_select_grid:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
	self.equip_select_grid:SetDataList(BattleFuwenData.Instance:GetBagShowBattleLineList())
	self.equip_select_grid:JumpToTop()
end

function DecomposeZhanwenView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function DecomposeZhanwenView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	BattleFuwenData.Instance:ClearDecomseData()
	BattleFuwenData.Instance:ClearShowQuality()
end

function DecomposeZhanwenView:SelectCellCallBack()
end

function DecomposeZhanwenView:OnDecomposeGetNumChange(vo)
	local str = "%s{wordcolor;1eff00; + %s}"
	local show_num_str = vo.num > 0 and string.format(str, self.old_num, vo.num) or self.old_num
	RichTextUtil.ParseRichText(self.node_t_list.rich_zw_jiejing_num.node, show_num_str, 22, COLOR3B.OLIVE)
end

function DecomposeZhanwenView:OnDataChange(vo)
	self.equip_select_grid:SetDataList(BattleFuwenData.Instance:GetBagShowBattleLineList())
	self.equip_select_grid:JumpToTop()

	local str = "%s{wordcolor;1eff00; + %s}"
	local show_num_str = string.format(str, self.old_num, vo.num - self.old_num) 
	RichTextUtil.ParseRichText(self.node_t_list.rich_zw_jiejing_num.node, show_num_str, 22, COLOR3B.OLIVE)
	GlobalTimerQuest:AddDelayTimer(function ()
		if self.node_t_list.rich_zw_jiejing_num then
			RichTextUtil.ParseRichText(self.node_t_list.rich_zw_jiejing_num.node, vo.num, 22, COLOR3B.OLIVE)
			self.old_num = vo.num
		end
	end, 0.5)

	RenderUnit.PlayEffectOnce(CLIENT_GAME_GLOBAL_CFG.decompose_eff_id, self.node_t_list.layout_decompose.node, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, 300, 370, true)
end

----------------------------------------------------
-- 战纹分解选择itemRender
----------------------------------------------------
ZhanwenSelectItemRender = ZhanwenSelectItemRender or BaseClass(BaseRender)
function ZhanwenSelectItemRender:__init(index)
	self.index = index
	self.img_cross = nil
end

function ZhanwenSelectItemRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ZhanwenSelectItemRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.RichTextSetCenter(self.node_tree.rich_zw_tip.node)
end

function ZhanwenSelectItemRender:OnClick()
	if nil == self.data then
		return
	end
 	self.node_tree.img_hook.node:setVisible(not self.node_tree.img_hook.node:isVisible())
 	if self.node_tree.img_hook.node:isVisible() then
 		BattleFuwenData.Instance:AddDecomseData(self.data)
 	else
 		BattleFuwenData.Instance:DeleteDecomseData(self.data)
 	end
end

function ZhanwenSelectItemRender:OnFlush()
	self.node_tree.img_hook.node:setVisible(nil ~= BattleFuwenData.Instance:CheckIsInDecomposeList(self.data.series))
 	if self.node_tree.img_hook.node:isVisible() then
 		BattleFuwenData.Instance:AddDecomseData(self.data)
 	else
 		BattleFuwenData.Instance:DeleteDecomseData(self.data)
 	end
	if nil == self.data then
		self.item_cell:SetData(nil)
		self.node_tree.lbl_zw_name.node:setString("")
		RichTextUtil.ParseRichText(self.node_tree.rich_zw_tip.node, "", 22, COLOR3B.OLIVE)
		return
	end
	BattleFuwenView.FlushItemShow(self.data, self.node_tree.img_icon.node, self.node_tree.lbl_zw_name.node, self.node_tree.rich_zw_tip.node)
end

function ZhanwenSelectItemRender:CreateSelectEffect()

end

----------------------------------------------------
-- 战纹质量itemRender
----------------------------------------------------
ZhanwenQualitySelectItemRender = ZhanwenQualitySelectItemRender or BaseClass(BaseRender)
function ZhanwenQualitySelectItemRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.img_hook_bg.node, BindTool.Bind1(self.OnChoicClick, self), true)

	self.node_tree.img_hook.node:setVisible(false)
end

function ZhanwenQualitySelectItemRender:OnChoicClick()
	if nil == self.data then
		return
	end
 	self.node_tree.img_hook.node:setVisible(not self.node_tree.img_hook.node:isVisible())
 	if self.node_tree.img_hook.node:isVisible() then
 		BattleFuwenData.Instance:AddSelectBagListQuality(self.data.quality)
 	else
 		BattleFuwenData.Instance:DeleteSelectBagListQuality(self.data.quality)
 	end
 	DecomposeZhanwenView.Instance.equip_select_grid:SetDataList(BattleFuwenData.Instance:GetBagShowBattleLineList())
end

function ZhanwenQualitySelectItemRender:OnFlush()
	if nil == self.data then return end

	--默认选中第一个
	if self:GetIndex() == 1 then
		self.node_tree.img_hook.node:setVisible(true)
		BattleFuwenData.Instance:AddSelectBagListQuality(self.data.quality)
		DecomposeZhanwenView.Instance.equip_select_grid:SetDataList(BattleFuwenData.Instance:GetBagShowBattleLineList())
	end

	self.node_tree.lbl_level.node:setString(self.data.name)
	self.node_tree.lbl_level.node:setColor(self.data.color)
end

function ZhanwenQualitySelectItemRender:CreateSelectEffect()

end