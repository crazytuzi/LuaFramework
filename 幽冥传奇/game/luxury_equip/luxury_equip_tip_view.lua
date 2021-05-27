LuxuryEquipTipView = LuxuryEquipTipView or BaseClass(BaseView)

function LuxuryEquipTipView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		--'res/xui/luxury_equip_tip.png'
	}
	self.config_tab = {
		{"luxury_equip_ui_cfg", 1, {0}},
	}
	
	-- require("scripts/game/luxury_equip_tip/name").New(ViewDef.LuxuryEquipTip.name)
	self.index = 1
end

function LuxuryEquipTipView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function LuxuryEquipTipView:LoadCallBack(index, loaded_times)
	-- self.data = LuxuryEquipTipData.Instance				--数据
	-- LuxuryEquipTipData.Instance:AddEventListener(LuxuryEquipTipData.INFO_CHANGE, BindTool.Bind(self.OnDataChange, self))
	self:InitTabbar()
end

function LuxuryEquipTipView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if self.tabbar then
 		self.tabbar:SelectIndex(self.index)
	end
end


function LuxuryEquipTipView:ShowIndexCallBack( ... )
	self:Flush()
end

function LuxuryEquipTipView:OnFlush( ... )
	self:FlushShow()
end

function LuxuryEquipTipView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function LuxuryEquipTipView:OnDataChange(vo)
end

function LuxuryEquipTipView:InitTabbar()
	local ph = self.ph_list.ph_tabbar
	if nil == self.tabbar then
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.node_t_list.layout_suit_tip.node, 20, ph.y,
				function(pro) self:ChangeToIndex(pro) end,
				Language.Tip.HaoZhuangItemGroup, false, ResPath.GetCommon("toggle_121"))

		self.tabbar:SetSpaceInterval(5)
		self.tabbar:ChangeToIndex(self:GetShowIndex())
	end
end

function LuxuryEquipTipView:ChangeToIndex(index)
	self.index = index
	self:FlushShow()
end


function LuxuryEquipTipView:FlushShow()
	local suittype = HaoZHuangTypeListCfg[self.index]
	local level_data = EquipData.Instance:GetCurDataByType(suittype)
	
	local suitlevel = level_data.suitlevel or 0 --未激活状态

	local config = SuitPlusConfig[suittype]
	if suitlevel == #config.list then
		suitlevel = suitlevel - 1
	end
	
	
	local space = 8
	if self.index == 2 then
		space = 15
	elseif self.index == 3 then
		space = 18
	end

		
	local text = LuxuryEquipTipData.Instance:GetText(suittype, suitlevel, config, self.index)
	RichTextUtil.ParseRichText(self.node_t_list.rich_cur_text.node, text, 20)
	XUI.SetRichTextVerticalSpace(self.node_t_list.rich_cur_text.node,space)


	local nextSuitLevel = suitlevel == 0 and 2 or suitlevel + 1
	if nextSuitLevel > #config.list then
		nextSuitLevel = #config.list
	end
	local text2 = LuxuryEquipTipData.Instance:GetText(suittype, nextSuitLevel, config, self.index)
	RichTextUtil.ParseRichText(self.node_t_list.rich_next_text.node, text2, 20)
	XUI.SetRichTextVerticalSpace(self.node_t_list.rich_next_text.node,space)
end


