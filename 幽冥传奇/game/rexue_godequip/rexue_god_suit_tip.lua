ReXueGodEquipSuitView = ReXueGodEquipSuitView or BaseClass(BaseView)

function ReXueGodEquipSuitView:__init()
	self:SetBgOpacity(200)
	--self.is_async_load = false
	self.is_any_click_close = true
	self.is_modal = true
	self.texture_path_list = {
	}

	--new_fashion_ui_cfg
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		--{"new_fashion_ui_cfg", 1, {0}},
		{"rexue_god_equip_ui_cfg", 5, {0}, nil, 999},
	}

	self.suitType = nil 
end



function ReXueGodEquipSuitView:__delete()
end

function ReXueGodEquipSuitView:ReleaseCallBack()

end

function ReXueGodEquipSuitView:LoadCallBack(index, loaded_times)

end

function ReXueGodEquipSuitView:SetData(SuitType)
	self.suitType = SuitType
	self:Flush(index)
end



function ReXueGodEquipSuitView:OpenCallBack( ... )
	
end

function ReXueGodEquipSuitView:ShowIndexCallBack( ... )
	self:Flush(index)
end

function ReXueGodEquipSuitView:OnFlush( ... )
	if self.suitType ~= nil then
		local suitlevel = 0
		local level_data = {}
		local offest = 5
		if self.suitType == 10 then
			suitlevel =  EquipData.Instance:GetZhiZunSuitLevel()
			level_data = EquipData.Instance:GetZunZhiSuitData()
		elseif self.suitType == 11 then
			suitlevel = EquipData.Instance:GetBazheLevel()
			level_data = EquipData.Instance:GetBaZheSuitLevel()
			offest = 4
		elseif self.suitType == 12 then
			suitlevel = EquipData.Instance:GetZhanShenLevel()
			level_data = EquipData.Instance:GetZhanShenSuitLevel()
			offest = 8
		elseif self.suitType == 13 then
			suitlevel = EquipData.Instance:GetShaShenLevel()
			level_data = EquipData.Instance:GetSheShenSuitLevel()
			offest = 8
		end


		local config = SuitPlusConfig[self.suitType]
		if suitlevel == #config.list then
			suitlevel = suitlevel - 1
		end
	
		local text = ReXueGodEquipData.Instance:GetTextByTypeData(suitlevel, self.suitType, level_data)
		RichTextUtil.ParseRichText(self.node_t_list.rich_cur_text.node, text, 20)
		XUI.SetRichTextVerticalSpace(self.node_t_list.rich_cur_text.node,offest)


		local nextSuitLevel = suitlevel == 0 and 2 or suitlevel + 1
		if nextSuitLevel > #config.list then
			nextSuitLevel = #config.list
		end
		
		local text2 = ReXueGodEquipData.Instance:GetTextByTypeData(nextSuitLevel, self.suitType, level_data)
		RichTextUtil.ParseRichText(self.node_t_list.rich_next_text.node, text2, 20)
		XUI.SetRichTextVerticalSpace(self.node_t_list.rich_next_text.node,offest)
	end
end


function ReXueGodEquipSuitView:CloseCallBack( ... )
	-- body
end