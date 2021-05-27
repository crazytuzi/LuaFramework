XingHunEquipTipView = XingHunEquipTipView or BaseClass(BaseView)

function XingHunEquipTipView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		--'res/xui/luxury_equip_tip.png'
	}
	self.config_tab = {
		{"horoscope_ui_cfg", 8, {0}},
	}
	
end

function XingHunEquipTipView:ReleaseCallBack()
	
end

function XingHunEquipTipView:LoadCallBack(index, loaded_times)
	
end

function XingHunEquipTipView:OpenCallBack()

end


function XingHunEquipTipView:ShowIndexCallBack( ... )
	self:Flush()
end

function XingHunEquipTipView:OnFlush( ... )
	self:FlushShow()
end

function XingHunEquipTipView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function XingHunEquipTipView:FlushShow()
	-- -- local suittype = HaoZHuangTypeListCfg[self.index]
	-- local level_data = EquipData.Instance:GetCurDataByType(suittype)
	
	local suitlevel = HoroscopeData.Instance:GetSuitId()

	local config = SuitPlusConfig[8]
	if suitlevel == #config.list then
		suitlevel = suitlevel - 1
	end
	


		
	local text = HoroscopeData.Instance:GetText(8, suitlevel, config)
	RichTextUtil.ParseRichText(self.node_t_list.rich_cur_text.node, text, 20)
	XUI.SetRichTextVerticalSpace(self.node_t_list.rich_cur_text.node,8)


	local nextSuitLevel = suitlevel == 0 and 2 or suitlevel + 1
	if nextSuitLevel > #config.list then
		nextSuitLevel = #config.list
	end
	local text2 = HoroscopeData.Instance:GetText(8, nextSuitLevel, config)
	RichTextUtil.ParseRichText(self.node_t_list.rich_next_text.node, text2, 20)
	XUI.SetRichTextVerticalSpace(self.node_t_list.rich_next_text.node,8)
end


