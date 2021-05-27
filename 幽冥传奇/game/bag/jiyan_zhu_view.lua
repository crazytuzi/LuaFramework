JiYanZhuView = JiYanZhuView or BaseClass(BaseView)

function JiYanZhuView:__init( ... )
	self.is_modal = true
	self.texture_path_list = {
		'res/xui/jiyan.png',
	}
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"jiyan_yu_ui_cfg", 1, {0}},
		--{"common_ui_cfg", 2, {0}, nil, 999},
	}
end


function JiYanZhuView:__delete( ... )
	-- body
end

function JiYanZhuView:LoadCallBack( ... )
	XUI.AddClickEventListener(self.node_t_list.img_tip.node, BindTool.Bind1(self.OpenTips, self), true)

	-- local ph = self.ph_list["ph_link"]
	-- self.rich_go_text = RichTextUtil.CreateLinkText(Language.Bag .TipShow5, 20, COLOR3B.GREEN)
	-- self.rich_go_text:setPosition(ph.x, ph.y)
	-- self.node_t_list.layout_jiyan_yu.node:addChild(self.rich_go_text, 90)
	-- XUI.AddClickEventListener(self.rich_go_text, function ( ... )
	-- 	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip )
	-- 	ViewManager.Instance:CloseViewByDef(ViewDef.JiYanView)
	-- end, true)

	for i = 1, 4 do 
		XUI.AddClickEventListener(self.node_t_list["btn_text"..i].node, BindTool.Bind2(self.GetReweardByIndex, self, i), true)
	end

	self:BindGlobalEvent(USE_NUM_EVENT.NUM_CHANGE, BindTool.Bind(self.Flush, self))

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function JiYanZhuView:GetReweardByIndex(index)
	local need_vip = ItemConvertExpCfg.EpxBeadCfg.multAwards[index].zslv
	if self.data then
		BagCtrl.Instance:SendUseSpecialItemReq(ItemSpecialType.ExpBead, index, self.data.series)
	end
end


function JiYanZhuView:OpenTips( ... )
	DescTip.Instance:SetContent(Language.DescTip.JIYanZhuContent, Language.DescTip.JIYanZhuTitle)
end

function JiYanZhuView:FlushConetentShow( ... )
	self:FlushShow()
	self:FlushHadNum()
end


function JiYanZhuView:ReleaseCallBack( ... )
	if self.num_change then
		GlobalEventSystem:UnBind(self.num_change)
		self.num_change = nil 
	end
end

function JiYanZhuView:OpenCallBack( ... )

end

function JiYanZhuView:CloseCallBack( ... )
	-- body
end

function JiYanZhuView:ShowIndexCallBack(index)
	self:Flush(index)
end

function JiYanZhuView:OnFlush(param_t)
	local list = {}
	local all_hp_pot = BagData.Instance:GetBagItemDataListByType(ItemData.ItemType.itHpPot)
	for k, v in pairs(all_hp_pot) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if tonumber(v.durability) >= tonumber(v.durability_max) then
			table.insert(list, v)
		end
	end
	table.sort(list, function(a, b)
		return a.item_id > b.item_id
	end)
	self.data = list[1]
	if nil == self.data or (not BagData.Instance:GetCanUseJiYanZhu()) then
		ViewManager.Instance:CloseViewByDef(ViewDef.JiYanView)
		return
	end

	self:FlushShow()
	self:FlushHadNum()
end

function JiYanZhuView:FlushShow()
	if self.data  then
		local exp = self.data.durability or 0
		for k, v in pairs(ItemConvertExpCfg.EpxBeadCfg.multAwards) do
			local had_exp = exp * (v.mult or 1)
			local mian_text = Language.Bag.TipShow7[k] or ""
			local text = string.format(Language.Bag.TipShow6, v.mult, had_exp, mian_text)
			if self.node_t_list["rich_text".. k] then
				RichTextUtil.ParseRichText(self.node_t_list["rich_text".. k].node, text)
			end

			local bool = ZsVipData.Instance:GetZsVipLv() >= v.zslv
			if self.node_t_list["btn_text"..k] then
				XUI.SetButtonEnabled(self.node_t_list["btn_text"..k].node, bool)
			end
		end

		local index = self.data.item_id - 481
		local path = ResPath.GetJingYan("name_path" .. index)
		self.node_t_list["img_name"].node:loadTexture(path)
	end
end

function JiYanZhuView:FlushHadNum()
	local had_use_time = BagData.Instance:GetSpecialUseNUm()
	local remian_num = ItemConvertExpCfg.EpxBeadCfg.maxUseTms - had_use_time > 0 and ItemConvertExpCfg.EpxBeadCfg.maxUseTms - had_use_time or 0

	local color = remian_num > 0 and "00ff00" or "ff0000"

	local text = string.format(Language.Bag.TipShow9, color, remian_num,  ItemConvertExpCfg.EpxBeadCfg.maxUseTms)
	RichTextUtil.ParseRichText(self.node_t_list.text_remain_time.node, text)
	XUI.RichTextSetCenter(self.node_t_list.text_remain_time.node)
end

function JiYanZhuView:OnBagItemChange(event)
	for i,v in ipairs(event.GetChangeDataList()) do
		if v.change_type == ITEM_CHANGE_TYPE.LIST then
			self:Flush()
			break
		elseif v.data then
			local item_type = v.data.type or -1
			if ItemData.IsJinYanZhuUseItemType(item_type) then
				self:Flush()
				break
			end
		end		
	end
end