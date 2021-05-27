ReplaceZhanwenView = ReplaceZhanwenView or BaseClass(BaseView)
--用于装备 替换 战纹

function ReplaceZhanwenView:__init()
	if ReplaceZhanwenView.Instance then
		ErrorLog("ReplaceZhanwenView.Instance is have!!!")
	end
	ReplaceZhanwenView.Instance = self

	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/battle_fuwen.png'
	}
	self.config_tab = {
		{"battle_fuwen_ui_cfg", 3, {0}},
	}

end

function ReplaceZhanwenView:ReleaseCallBack()
	if self.bag_zw_list then
		self.bag_zw_list:DeleteMe()
		self.bag_zw_list = nil
	end
end

function ReplaceZhanwenView:LoadCallBack(index, loaded_times)
	self:CreateBagZWList()

 	XUI.AddClickEventListener(self.node_t_list.btn_get.node, function () ViewManager.Instance:OpenViewByDef(ViewDef.Experiment.Babel) end, true)

	-- BattleFuwenData.Instance:AddEventListener(BattleFuwenData.BATTLE_FUWEN_ONE_INFO_CHANGE, function () self:Flush() end)

    EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, function () self:Flush() end)
    
	self:Flush()
end

function ReplaceZhanwenView:ShowIndexCallBack(index)
	self:Flush()
end

function ReplaceZhanwenView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ReplaceZhanwenView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ReplaceZhanwenView:OnFlush()
	local data = BattleFuwenData.Instance:GetCurrZhanwenInfo()
	self.node_t_list.lbl_is_have_zw_tip.node:setVisible(data.item_data == nil)
	self.node_t_list.layout_curr_use_zw.node:setVisible(data.item_data ~= nil)

	--顶部已镶嵌战纹
	BattleFuwenView.FlushItemShow(data.item_data, self.node_t_list.img_icon.node, self.node_t_list.lbl_zw_name.node, self.node_t_list.rich_zw_tip.node)

	--背包战纹列表
	self.bag_zw_list:SetDataList(BattleFuwenData.Instance:GetBagBattleLineList())
	self.bag_zw_list:JumpToTop(true)
	self.bag_zw_list:SelectIndex(1)
end

function ReplaceZhanwenView:CreateBagZWList()
	local ph = self.ph_list.ph_item_list
	self.bag_zw_list = ListView.New()
	self.bag_zw_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ZhanwenReplaceRender, nil, nil, self.ph_list.ph_item)
	self.node_t_list.layout_replace.node:addChild(self.bag_zw_list:GetView(), 100)
	self.bag_zw_list:SetItemsInterval(4)
	self.bag_zw_list:SetMargin(1)
end

----------------------------------------------------
-- 商店itemRender
----------------------------------------------------
ZhanwenReplaceRender = ZhanwenReplaceRender or BaseClass(BaseRender)

function ZhanwenReplaceRender:__init()
end

function ZhanwenReplaceRender:__delete()
end

function ZhanwenReplaceRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_equipt_item.node, BindTool.Bind1(self.OnClickEquip, self))
	XUI.AddRemingTip(self.node_tree.btn_equipt_item.node, function ()
		return BattleFuwenData.Instance:CheckIsBetterSlot(self.data)
	end)
end

function ZhanwenReplaceRender:OnFlush()
	if nil == self.data then return end

	local is_conflic = BattleFuwenData.Instance:CheckIsConflictId(self.data.item_id)
	self.node_tree.lbl_is_have_typ_tip.node:setVisible(is_conflic)
	self.node_tree.btn_equipt_item.node:setVisible(not is_conflic)

	self.node_tree.btn_equipt_item.node:UpdateReimd()

	BattleFuwenView.FlushItemShow(self.data, self.node_tree.img_icon.node, self.node_tree.lbl_zw_name.node, self.node_tree.rich_zw_tip.node)
end

function ZhanwenReplaceRender:OnClickEquip()
	if nil == self.data then return end
	BattleFuwenData.Instance:SendCloth(self.data)
end

function ZhanwenReplaceRender:CreateSelectEffect()
end