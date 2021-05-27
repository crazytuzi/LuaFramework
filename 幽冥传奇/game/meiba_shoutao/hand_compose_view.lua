local HandComposeView = HandComposeView or BaseClass(SubView)
local HandComsumeitemRender = HandComsumeitemRender or BaseClass(BaseRender)
local HandSuccesRender = HandSuccesRender or BaseClass(BaseRender)
local HandPreviewsRender = HandPreviewsRender or BaseClass(BaseRender)
-- HandComposeCtrl.Instance
-- HandComposeData.Instance

-- delete obj
--	if nil ~= self.obj then
--		self.obj:DeleteMe()
--	end
--	self.obj = nil
Language.Hand = Language.Hand or {}
Language.Hand.NeedTip = "材料背包"
Language.Hand.Preview = "材料购买"
Language.Hand.GoAdd = "前往增幅"
Language.Hand.ComPoseTip = "您没有放置完整所需材料"

Language.Hand.AttrDesc = "几率秒杀怪物%s血量"
Language.Hand.ProbLvDesc = {
	[1] = "打造成功几率：极高",
	[2] = "打造成功几率：高",
	[3] = "打造成功几率：中",
	[4] = "打造成功几率：低",
	[5] = "打造成功几率：极低",
}

function HandComposeView:__init()
	self.def_index = 1
	self.texture_path_list = {'res/xui/meiba_shoutao.png'}
	self.config_tab = {
		{"meiba_shoutao_ui_cfg", 2, {0}},
	}
	self.def_index = 1
end

function HandComposeView:__delete()
end

local Bag_Show = 1
local Priview_Show = 2
function HandComposeView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then	
	end

	self.root_view = self.node_t_list.layout_compose.node
	self:CreateConsumeView()
	-- self:CreateBagView()
	-- self:CreatePreviewView()
	self:CreateAnimateInfo()
	RenderUnit.CreateEffect(1106, self.root_view, 10, nil, nil, 290, 356)

	XUI.AddClickEventListener(self.node_t_list.layout_compose.btn_help.node, function ()
		DescTip.Instance:SetContent(Language.DescTip.MeiBaContent, Language.DescTip.MeiBaTitle)
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_compose.node, function ()
		local is_can, need_id = MeiBaShouTaoData.Instance:IsInputCanCompose()
		if is_can then
		-- if true then
			MeiBaShouTaoCtrl.Instance.SendHandCompose()
		else
			TipCtrl.Instance:OpenGetStuffTip(need_id or MeiBaShouTaoData.GetConsumeCfg()[1].id)
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Hand.ComPoseTip)
		end
	end, true)

	-- local defualt_right = Bag_Show
	-- local need_rich_link = RichTextUtil.CreateLinkText(Language.Hand.NeedTip, 20, COLOR3B.GREEN, nil, true)
	-- need_rich_link:setPosition(500, 50)
	-- need_rich_link:setVisible(defualt_right == Priview_Show)
	-- self.root_view:addChild(need_rich_link, 999)
	-- local pre_rich_link = RichTextUtil.CreateLinkText(Language.Hand.Preview, 20, COLOR3B.GREEN, nil, true)
	-- pre_rich_link:setPosition(500, 50)
	-- pre_rich_link:setVisible(defualt_right == Bag_Show)
	-- self.root_view:addChild(pre_rich_link, 999)


	-- local function change_right(tag)
	-- 	self.node_t_list.layout_bag.node:setVisible(tag == Bag_Show)
	-- 	self.node_t_list.layout_preview.node:setVisible(tag == Priview_Show)
	-- 	need_rich_link:setVisible(tag == Priview_Show)
	-- 	pre_rich_link:setVisible(tag == Bag_Show)
	-- end

	-- XUI.AddClickEventListener(need_rich_link, function ()
	-- 	change_right(Bag_Show)
	-- end)

	-- XUI.AddClickEventListener(pre_rich_link, function ()
	-- 	change_right(Priview_Show)
	-- end)

	-- local goadd_rich_link = RichTextUtil.CreateLinkText(Language.Hand.GoAdd, 20, COLOR3B.GREEN, nil, true)
	-- goadd_rich_link:setPosition(80, 50)
	-- self.root_view:addChild(goadd_rich_link, 999)
	-- XUI.AddClickEventListener(goadd_rich_link, function ()
	-- 	ViewManager.Instance:OpenViewByDef(ViewDef.MeiBaShouTao.HandAdd)
	-- end)

	EventProxy.New(MeiBaShouTaoData.Instance, self):AddEventListener(MeiBaShouTaoData.INPUT_CHANGE, BindTool.Bind(self.Flush, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, function ()
		self:Flush()
	end)

	EventProxy.New(MeiBaShouTaoData.Instance, self):AddEventListener(MeiBaShouTaoData.HAND_COMPOSE_CHANGE, function (data)	
		self:FlushComposing()
		self:FlushSpareTimer()
	end)
	self.cur_index = 1
	-- XUI.AddClickEventListener(self.node_t_list.btn_add.node,BindTool.Bind1(self.OnmoveRinght, self), true)
	-- XUI.AddClickEventListener(self.node_t_list.btn_del.node,BindTool.Bind1(self.OnmoveLeft, self), true)


	RenderUnit.CreateEffect(1105, self.node_t_list.layout_composing.node, 10, nil, nil, 200, 234)
	-- EventProxy.New(HandComposeData.Instance, self):AddEventListener(HandComposeData.Undefine, BindTool.Bind(self.HandComposeDataChangeCallback, self))
end


function HandComposeView:OnmoveRinght( ... )
	if self.cur_index < #ThanosGloveEquipConfig.makeCfg.quality then
		self.cur_index = self.cur_index + 1
	end
	self:FlushShouTaoShow()
end

function HandComposeView:OnmoveLeft( ... )
	if self.cur_index > 1 then
		self.cur_index = self.cur_index - 1
	end
	self:FlushShouTaoShow()
end

function HandComposeView:SpareTimerFunc()
	local time2 = MeiBaShouTaoData.Instance:GetComposeData().end_time - TimeCtrl.Instance:GetServerTime()
	if time2 <= 0 then
		self:DeleteSpareTimer()
		self:FlushComposing()

	else
		self.node_t_list.layout_composing.lbl_spare_time.node:setString("剩余时间：" .. TimeUtil.FormatSecond(time2))
	end
end

function HandComposeView:FlushSpareTimer()
	if nil == self.spare_timer and MeiBaShouTaoData.Instance:GetIsComposing() then
		self.spare_timer = GlobalTimerQuest:AddRunQuest(function ()
			self:SpareTimerFunc()
		end, 1)
		self:SpareTimerFunc()
	end
end

function HandComposeView:DeleteSpareTimer()
	if self.spare_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.spare_timer)
		self.spare_timer = nil
	end
end

function HandComposeView:FlushComposing()
	local data = MeiBaShouTaoData.Instance:GetComposeData()
	local is_composeing = MeiBaShouTaoData.Instance:GetIsComposing()
	local is_can_lingqu = not MeiBaShouTaoData.Instance:GetIsComposing() and data.q_idx ~= 0

	self.node_t_list.layout_composing.node:setVisible(is_composeing)
	self.node_t_list.layout_compose_m.node:setVisible(not is_composeing)


	-- if data.end_time == 0 and data.q_idx == 0 and data.i_idx == 0 then return end	
	if nil == self.succ_view then	
		local screen_w = HandleRenderUnit:GetWidth()
		local screen_h = HandleRenderUnit:GetHeight()
		self.succ_view = HandSuccesRender.New()
		self.succ_view:GetView():setVisible(false)
		self.succ_view:SetUiConfig(self.ph_list.ph_compose_succes, true)
		self.succ_view:SetAnchorPoint(0.5, 0.5)
		self.succ_view:SetPosition(screen_w / 2, screen_h / 2)
		HandleRenderUnit:AddUi(self.succ_view:GetView(), COMMON_CONSTS.PANEL_MAX_ZORDER, COMMON_CONSTS.PANEL_MAX_ZORDER)

		-- 确认面板可调用点击函数
	 	XUI.AddModelAndAnyClose(self.succ_view:GetView(), true, true, function ()
	 		self.succ_view:GetView():setVisible(false)
			MeiBaShouTaoData.Instance:InitItemNumData()
			MeiBaShouTaoCtrl.SendHandLingqu()
			self:Flush()
	 	end)
	end

	self.succ_view:GetView():setVisible(is_can_lingqu)
	if ThanosGloveEquipConfig.makeCfg.quality[data.q_idx] then
		self.succ_view:SetData({get_id = ThanosGloveEquipConfig.makeCfg.quality[data.q_idx].itemlist[data.i_idx].item.id})
	end

	-- GlobalTimerQuest:AddDelayTimer(function()
	-- 	self.succ_view.node_tree.layout_composing.node:setVisible(false)
	-- 	self.succ_view.node_tree.layout_calc.node:setVisible(true)
	-- 	self.succ_view.can_click = true
	-- 	RenderUnit.PlayEffectOnce(1082, self.succ_view.node_tree.layout_calc.node, 998, 340, 200, nil, nil)
	-- end, 5)

end

function HandComposeView:FlushShouTaoShow( ... )
	-- self.node_t_list.btn_add.node:setVisible(self.cur_index ~= #ThanosGloveEquipConfig.makeCfg.quality)
	-- self.node_t_list.btn_del.node:setVisible(self.cur_index ~= 1)

	local cfg = ThanosGloveEquipConfig.makeCfg.quality[self.cur_index]
	if cfg then
	
		local animate_cfg = SpecialTipsCfg[cfg.itemlist[1].item.id]
		anim_path, anim_name = ResPath.GetEffectUiAnimPath(animate_cfg.modleId)
		self.effect_animate:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)

		local text = Language.Hand.ProbLvDesc[cfg.probLv]
		-- self.node_t_list.text_jilv.node:setString(text)
	end

end

function HandComposeView:CreateAnimateInfo()
	-- if nil == self.effect_animate then
		--if nil == self.effect_animate then
		for i = 1, 7 do
			local ph = self.ph_list["ph_anmimate" .. i]
		 	local effect_animate = AnimateSprite:create()
		 	effect_animate:setPosition(ph.x - 46, ph.y)
		 	effect_animate:setScale(0.6)
		 	self.node_t_list.layout_compose.node:addChild(effect_animate, 300)
	 		local cfg = ThanosGloveEquipConfig.makeCfg.quality[i]
			if cfg then
				local animate_cfg = SpecialTipsCfg[cfg.itemlist[1].item.id]
				anim_path, anim_name = ResPath.GetEffectUiAnimPath(animate_cfg.modleId)
				effect_animate:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)

				local text = Language.Hand.ProbLvDesc[cfg.probLv]
			end

			local touch_layer = XLayout:create(100, 100)
			touch_layer:setPosition(ph.x, ph.y)
			touch_layer:setAnchorPoint(0.5, 0.5)
			-- touch_layer:setBackGroundColor(cc.c3b(0x00, 0x00, 0x00))
		 	self.node_t_list.layout_compose.node:addChild(touch_layer, 999)
			XUI.AddClickEventListener(touch_layer, function ()
				local cfg = ThanosGloveEquipConfig.makeCfg.quality[i]
				if cfg then
					local data = {item_id = cfg.itemlist[1].item.id, num = 1,is_bind = 0}
					TipCtrl.Instance:OpenItem(data,  EquipTip.FROM_MEIBA_BAG)
				end
			end, true)

		end
	 	--self.effect_animate:addClickEventListener(BindTool.Bind1(self.OpenItemShow,self))
		--XUI.AddClickEventListener(self.effect_animate, BindTool.Bind1(self.OpenItem,self),false)
	-- end
end



function HandComposeView:OpenItemShow(idx)
	local cfg = ThanosGloveEquipConfig.makeCfg.quality[idx]
	if cfg then
		local data = {item_id = cfg.itemlist[1].item.id, num = 1,is_bind = 0}
		TipCtrl.Instance:OpenItem(data,  EquipTip.FROM_MEIBA_BAG)
	end
end


function HandComposeView:OnBagItemChange(event)
	for i,v in ipairs(event.GetChangeDataList()) do
		if self.consume_cells[v.item_id] then
			self.consume_cells[v.item_id]:Flush()
		end
	end
	
end

function HandComposeView:CreateConsumeView()
	local view = {}
	self.consume_cells = {}
	local ph = self.ph_list.ph_consume_item
	for i,data in ipairs(MeiBaShouTaoData.GetConsumeCfg()) do
		local cell = HandComsumeitemRender.New()
		cell:SetUiConfig(self.ph_list.ph_consume_item, true)
		cell:SetPosition(ph.x + 108 * (i - 1), ph.y - 6)
		cell:SetAnchorPoint(0.5, 0.5)
		cell:SetIndex(i)
		cell:SetScale(1.2)
		self.node_t_list.layout_compose_m.node:addChild(cell:GetView(), 103)
		self.consume_cells[data.id] = cell
	end
end

function HandComposeView:CreateBagView()
    local ph = self.ph_list.ph_bag
    self.bag_grid = BaseGrid.New()
    local grid_node =  self.bag_grid:CreateCells({w=ph.w, h=ph.h, cell_count=110, col=4, row=6, itemRender = BaseCell,
                                                   direction = ScrollDir.Vertical})

    self.bag_grid:SetSelectCallBack(BindTool.Bind(self.OnClickBagGridHandle, self))
    self.node_t_list.layout_bag.node:addChild(grid_node, 100)

    self.bag_grid:SetDataList(BagData.Instance:GetBagHandItemList())
end

function HandComposeView:CreatePreviewView()
    local ph = self.ph_list.ph_bag1
	self.previews_list = ListView.New()
	self.previews_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, CommonBuyRender, nil, nil, self.ph_list.ph_list_item2)
	-- self.previews_list:SetSelectCallBack(BindTool.Bind(self.OnSelectPreviewItemCallback, self))
	self.previews_list:SetItemsInterval(4)
	self.previews_list:SetJumpDirection(ListView.Top)
	self.previews_list:SetMargin(2)
    self.node_t_list.layout_preview.node:addChild(self.previews_list:GetView(), 100)

   --self.previews_list:SetDataList(MeiBaShouTaoData.GetPreViewCfg())

   	local data = ClientQuickyBuylistCfg[ClientQuickyBuyType.wuxianshoutao]
	self.previews_list:SetDataList(data)
end

function HandComposeView:ReleaseCallBack()
	if self.succ_view then
		self.succ_view:DeleteMe()
	end
	self.succ_view = nil
	-- if self.previews_list then
	-- 	self.previews_list:DeleteMe()
	-- 	self.previews_list = nil
	-- end
	if self.effect_animate then
		self.effect_animate:setStop()
		self.effect_animate = nil
	end

	self:DeleteSpareTimer()
end

function HandComposeView:OpenCallBack()

end

function HandComposeView:CloseCallBack()
	MeiBaShouTaoData.Instance:ClearItemNumData()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function HandComposeView:OnClickBagGridHandle(cell)
    if nil == cell:GetData() then
        return
    end
    -- local grid_idx = HoroscopeData.Instance:GetCollectionGrid(self.select_index, cell:GetData().item_id)
    TipCtrl.Instance:OpenItem(cell:GetData(), EquipTip.FROM_MEIBA_BAG)
end

function HandComposeView:ShowIndexCallBack(index)
	MeiBaShouTaoData.Instance:InitItemNumData()
	self.cur_index = 1
	self:Flush(index)
	self:FlushComposing()
	self:FlushSpareTimer()
end

function HandComposeView:OnFlush(param_list, index)		
	for i,data in ipairs(MeiBaShouTaoData.Instance:GetInputItemData()) do	
		self.consume_cells[data.item_id]:SetData(data)
	end
	-- self:FlushShouTaoShow()
end



function HandComsumeitemRender:__init()
end

function HandComsumeitemRender:__delete()
	if self.sale_cell then
		self.sale_cell:DeleteMe()
		self.sale_cell = nil
	end
end

function HandComsumeitemRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_cell
	self.sale_cell = BaseCell.New()
	-- self.sale_cell:SetCellBgVis(false)
	self.sale_cell:SetScale(0.8)
	self.sale_cell:SetAnchorPoint(0.5, 0.5)
	self.sale_cell:SetPosition(ph.x, ph.y)
	self.view:addChild(self.sale_cell:GetView(), 50)

	self.node_tree.rich_num.node:setLocalZOrder(999)
	XUI.RichTextSetCenter(self.node_tree.rich_num.node)
end

function HandComsumeitemRender:OnFlush()
	if self.data == nil then
		return 
	end

	self.sale_cell:SetData({item_id = self.data.item_id, num = 1, is_bind = 0})
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.node_tree.lbl_name.node:setString(item_cfg.name)
	local color = Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6))
	self.node_tree.lbl_name.node:setColor(color)

	local have_num = MeiBaShouTaoData.Instance:GetInputItemNumByIdx(self:GetIndex())
	local txt_color = have_num >= self.data.need_count and "FFFFFF" or "8B0000"
	local rich = "{wordcolor;%s;%s}/%s"
	local txt = string.format(rich, txt_color, have_num, self.data.need_count)
	RichTextUtil.ParseRichText(self.node_tree.rich_num.node, txt, 20)

	self.sale_cell:MakeGray(have_num < self.data.need_count)
end


function HandSuccesRender:__init()
end

function HandSuccesRender:__delete()
	if self.sale_cell then
		self.sale_cell:DeleteMe()
		self.sale_cell = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
	end
	self.timer = nil
end

function HandSuccesRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_cell
	XUI.AddClickEventListener(self.node_tree.layout_calc.btn_close.node, function ()
		if self.view.click_func then
			self.view.click_func()
		end
	end)
	XUI.AddClickEventListener(self.node_tree.layout_calc.layout_ok.node, function ()
		if self.view.click_func then
			self.view.click_func()
		end
	end, true)
end

function HandSuccesRender:SetEffect(eff_id)
	if eff_id > 0 then
		if nil == self.eff_node then
			self.eff_node = RenderUnit.CreateEffect(eff_id, self.node_tree.layout_calc.node, 999, nil, nil, nil, nil)
		else
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
			self.eff_node:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
			self.eff_node:setVisible(true)
		end
	elseif nil ~= self.eff_node then
		self.eff_node:setStop()
		self.eff_node:setVisible(false)
	end
	return self.eff_node
end

function HandSuccesRender:OnFlush()
	if self.data == nil then
		return 
	end

	local effect_id = 0
	for i,v in ipairs(MeiBaShouTaoData.GetPreViewCfg()) do
		if v.itemlist[1].item.id == self.data.get_id then
			effect_id = v.itemlist[1].item.effectId
			break
		end
	end
	-- local ph = self.node_tree.img_plant.node
	-- self:SetEffect(effect_id):setPosition(ph:getPositionX(), ph:getPositionY())
	self:SetEffect(effect_id):setPositionX(240)

	-- if nil == self.timer then
	-- 	local time = 5
	-- 	self.timer = GlobalTimerQuest:AddRunQuest(function ()
	-- 		if time - 1 < 0 then
	-- 			self.node_tree.layout_composing.img_timer.node:loadTexture(ResPath.GetMieBa("num_" .. 5))
	-- 			GlobalTimerQuest:CancelQuest(self.timer)
	-- 			self.timer = nil
	-- 			return
	-- 		end
	-- 		time = time - 1
	-- 		self.node_tree.layout_composing.img_timer.node:loadTexture(ResPath.GetMieBa("num_" .. time))
	-- 	end, 1)
	-- end

	self.node_tree.layout_calc.img_hand_name.node:loadTexture(ResPath.GetMieBa(self.data.get_id))
end




function HandPreviewsRender:__init()
end

function HandPreviewsRender:__delete()	
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function HandPreviewsRender:CreateChild()
	BaseRender.CreateChild(self)

	local ph = self.ph_list.ph_item_cell
	self.cell = BaseCell.New()
	self.cell:GetView():setAnchorPoint(0.5, 0.5)
	self.cell:SetPosition(ph.x, ph.y)
	self.view:addChild(self.cell:GetView(), 99)	
end

function HandPreviewsRender:OnFlush()
	if self.data == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.itemlist[1].item.id)
	if nil == item_cfg then
		return
	end

	local attr_v = 0
	for k,v in pairs(item_cfg.staitcAttrs) do
		if v.type == GAME_ATTRIBUTE_TYPE.HOLY_WORDPOWER then
			attr_v = v.value
		end
	end

	self.node_tree.label_item_name.node:setString(item_cfg.name)
	self.node_tree.label_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))
	self.node_tree.label_attr.node:setString(string.format(Language.Hand.AttrDesc, RoleData.FormatValueStr(GAME_ATTRIBUTE_TYPE.HOLY_WORDPOWER, attr_v)))
	self.node_tree.label_prob_desc.node:setString(Language.Hand.ProbLvDesc[self.data.probLv])

	self.cell:SetData({item_id = self.data.itemlist[1].item.id, num = 1, is_bind = 1})
end
return HandComposeView