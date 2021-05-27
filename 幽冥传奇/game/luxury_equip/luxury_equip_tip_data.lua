LuxuryEquipTipData = LuxuryEquipTipData or BaseClass()

function LuxuryEquipTipData:__init()
	if LuxuryEquipTipData.Instance then
		ErrorLog("[LuxuryEquipTipData] attempt to create singleton twice!")
		return
	end
	LuxuryEquipTipData.Instance = self
end

function LuxuryEquipTipData:__delete()
end

function LuxuryEquipTipData:GetRewardRemind()
	return 0
end


function LuxuryEquipTipData:GetText(suittype, suitlevel, config, index,is_k, is_show)
	local suit_level_data = EquipData.Instance:GetLevelt(suittype)
	local cur_suit_level_data = suit_level_data[suitlevel] or suit_level_data[1]
	is_show = is_show == nil and true or is_show
	local text1 = ""
	if suitlevel <= 0 then
		text1 =  string.format("{color;f4ff00;%s}",string.format(Language.HaoZhuang.desc1, 1, Language.Tip.HaoZhuangItemGroup[index], cur_suit_level_data.count, cur_suit_level_data.need_count,Language.HaoZhuang.active[1])).."\n"
	else
		local text6 = cur_suit_level_data.bool > 0 and Language.HaoZhuang.active[2] or Language.HaoZhuang.active[1]
		text1 = string.format("{color;f4ff00;%s}",string.format(Language.HaoZhuang.desc1, suitlevel, Language.Tip.HaoZhuangItemGroup[index], cur_suit_level_data.count, cur_suit_level_data.need_count,text6)).."\n"
	end

	local text2 = "" 
	local type_data = HaoZhuangSuitTypeByType[suittype]
	for k, v in pairs(type_data) do
		local name = Language.EquipTypeName[v]
		local slot = EquipData.Instance:GetEquipSlotByType(v, 0)
		local equip = EquipData.Instance:GetEquipDataBySolt(slot)
		local color = "a6a6a6"
		if equip then
			local itemm_config = ItemData.Instance:GetItemConfig(equip.item_id)
		
			if itemm_config.suitId >= suitlevel then
				color = "00ff00"
			end
		end
		text2 = text2 .. string.format(Language.HaoZhuang.active2, color, name) .. " "
	end
	local text3 = string.format(Language.HaoZhuang.active1, text2) .. "\n"

	local attr_config = config.list[suitlevel] or config.list[1]
	local attr = attr_config.attrs
	local normat_attrs, special_attr =  RoleData.Instance:GetSpecailAttr(attr)

	local bool_color = cur_suit_level_data.bool > 0 and "ffffff" or "a6a6a6"
	local bool_color1 = cur_suit_level_data.bool > 0 and "ff0000" or "a6a6a6"
	local text4 =  string.format("{color;%s;%s}", "dcb73d", "基础属性：") .. "\n" .. string.format("{color;%s;%s}", bool_color, RoleData.FormatAttrContent(normat_attrs)) .."\n"
	local text5 = ""
	if is_show then
		if (#special_attr > 0) then
			local special_content = RoleData.FormatRoleAttrStr(special_attr, nil, prof_ignore)
			local jilv = (special_content[1].value/100) .."%"
			local text7 = is_k and "\n" or ""
			text5 = string.format("{color;%s;%s}", "dcb73d", "特殊属性：") .. "\n" .. string.format("{color;%s;%s}", bool_color1, string.format(Language.HaoZhuang.desc2, jilv,  special_content[2].value,text7))
		end
	end
	local text = text1..text3..text4..text5
	return text
end