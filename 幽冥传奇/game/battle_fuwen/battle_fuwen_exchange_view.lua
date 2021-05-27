ExchageZhanwenView = ExchageZhanwenView or BaseClass(BaseView)
--用于装备 替换 战纹

function ExchageZhanwenView:__init()
	if ExchageZhanwenView.Instance then
		ErrorLog("ExchageZhanwenView.Instance is have!!!")
	end
	ExchageZhanwenView.Instance = self

	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/battle_fuwen.png',
		'res/xui/bag.png'
	}
	self.config_tab = {
		{"battle_fuwen_ui_cfg", 6, {0}},
	}

end

function ExchageZhanwenView:ReleaseCallBack()
	if self.exchange_list then
		self.exchange_list:DeleteMe()
		self.exchange_list = nil
	end
end

function ExchageZhanwenView:LoadCallBack(index, loaded_times)
	self:CreateBagZWList()
	BattleFuwenData.Instance:AddEventListener(BattleFuwenData.BATTLE_FUWEN_ONE_INFO_CHANGE, function () self:Flush() end)

	--链接至试炼
    if not IS_AUDIT_VERSION then
	    self.get_item_link = RichTextUtil.CreateLinkText("获得红色战纹碎片", 20, COLOR3B.GREEN)
	    self.get_item_link:setPosition(476, 55)
	    self.node_t_list.layout_exchange.node:addChild(self.get_item_link, 50)
	    XUI.AddClickEventListener(self.get_item_link, function () ViewManager.Instance:OpenViewByDef(ViewDef.Experiment.Babel) end, true)

	    EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, function ()
		    self:Flush()
	    end)
    end
	self:Flush()
end

function ExchageZhanwenView:ShowIndexCallBack(index)
	self:Flush()
end

function ExchageZhanwenView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ExchageZhanwenView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ExchageZhanwenView:OnFlush()
	--背包战纹列表
	local data_list = ItemSynthesisConfig[ITEM_SYNTHESIS_TYPES.BATTLE_LINE].list[1].itemList
	self.exchange_list:SetDataList(data_list)
	
	self.node_t_list.lbl_red_jiejing_num.node:setString(BagData.Instance:GetItemNumInBagById(data_list[1].consume[1].id))
end

function ExchageZhanwenView:CreateBagZWList()
	local ph = self.ph_list.ph_exchange_item_list
	self.exchange_list = ListView.New()
	self.exchange_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ZhanwenExchangeRender, nil, nil, self.ph_list.ph_exchange_item)
	self.node_t_list.layout_replace.node:addChild(self.exchange_list:GetView(), 100)
	self.exchange_list:SetItemsInterval(1)
	self.exchange_list:SetMargin(1)

	--战纹兑换配置
	local cfg = ItemSynthesisConfig[ITEM_SYNTHESIS_TYPES.BATTLE_LINE].list[1].itemList
	self.exchange_list:SetDataList(cfg)
	self.exchange_list:JumpToTop(true)
	self.exchange_list:SelectIndex(1)
end

----------------------------------------------------
-- 商店itemRender
----------------------------------------------------
ZhanwenExchangeRender = ZhanwenExchangeRender or BaseClass(BaseRender)

function ZhanwenExchangeRender:__init()
end

function ZhanwenExchangeRender:__delete()
end

function ZhanwenExchangeRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_exchange_item.node, BindTool.Bind1(self.OnClickEquip, self))
	XUI.AddRemingTip(self.node_tree.btn_exchange_item.node)
	RenderUnit.CreateEffect(354, self.node_tree.img_icon.node, 99)
end

function ZhanwenExchangeRender:OnFlush()
	if nil == self.data then return end

	local item_data = {item_id = self.data.award[1].id, durability = 1}
	BattleFuwenView.FlushItemShow(item_data, self.node_tree.img_icon.node, self.node_tree.lbl_zw_name.node, self.node_tree.rich_zw_tip.node)

	local str = "{wordcolor;%s;%s}/%s"
	local red_jiejing_num = BagData.Instance:GetItemNumInBagById(self.data.consume[1].id)
	local color = red_jiejing_num >= self.data.consume[1].count and "1eff00" or "DC143C"
	self.node_tree.btn_exchange_item.node:UpdateReimd(red_jiejing_num >= self.data.consume[1].count)

	RichTextUtil.ParseRichText(self.node_tree.rich_exchange_tip.node, string.format(str, color, red_jiejing_num, self.data.consume[1].count), 22)	
end

function ZhanwenExchangeRender:OnClickEquip()
	if nil == self.data then return end
	BagCtrl.SendComposeItem(ITEM_SYNTHESIS_TYPES.BATTLE_LINE, 1, self:GetIndex(), 0)
end

function ZhanwenExchangeRender:CreateSelectEffect()
end