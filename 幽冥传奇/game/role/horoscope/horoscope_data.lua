HoroscopeData  = HoroscopeData or BaseClass()

HoroscopeData.CONSTELLATION_DATA_CHANGE = "constellation_data_change"
HoroscopeData.SLOT_STRENGTHEN_DATA_CHANGE = "slot_strengthen_data_change"
HoroscopeData.SELECT_CELL_CHANGE = "select_cell_change"
COLLECTION_COLOR = {PURPLE = 0,
					ORANGE = 1,
					RED = 2,}
function HoroscopeData:__init()
	if HoroscopeData.Instance then
		ErrorLog("[HoroscopeData] attempt to create singleton twice!")
		return
	end
	HoroscopeData.Instance = self
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	self.constellation_list = {}
	self.slot_info_list = {}
	self.collection_list = {}

	--套装属性

	self.level_data_t = {}
	self.cur_level_suit = 0

	self.pink_list = {}
	self.or_list = {}
	self.re_list = {}
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GeCanUpRemind, self), RemindName.XingHuCan)
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.BagItemChangeCallBack, self))
end

function HoroscopeData:__delete()
	HoroscopeData.Instance = nil
	self.constellation_list = nil
	self.slot_info_list = nil
	self.collection_list = nil
end

function HoroscopeData:SetConstellationDataList(item_list)
	--for k, v in pairs(item_list) do
	--	local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
	--	if item_cfg.stype then
			self.constellation_list = item_list
	--	end
	--end
	self:SetLevelData()
end


function HoroscopeData:SetLevelData()
	local config = SuitPlusConfig[8] or {}
	self.level_data_t = {}
	for k1, v1 in pairs(config.list or {}) do
		self.level_data_t[v1.suitId] = {}
		local data, num = self:GetSuitIdData(v1.suitId, self.constellation_list, v1.count)
		self.level_data_t[v1.suitId] = {bool = data, count = num, need_count = v1.count}
		if data > 0 then
			self.cur_level_suit = v1.suitId
		end
	end
end

function HoroscopeData:GetSuitId()
	return self.cur_level_suit
end

function HoroscopeData:GetLevelSuit()
	return self.level_data_t
end

function HoroscopeData:GetSuitIdData(suitId, list, count)
	local n = 0
	local is_had = 0
	for k, v in pairs(list) do
		local config  = ItemData.Instance:GetItemConfig(v.item_id)
		if config.suitId >= suitId then
			n = n + 1
		end
	end
	if n >= count then
		is_had = 1
	end

	return is_had, n
end

--更新星魂装备数据
function HoroscopeData:UpdateConstellationDataList(slot_idx, constellation)
	if constellation then
		if self.slot_info_list[slot_idx] == nil then
			self.constellation_list[slot_idx] = {}
		end
		self.constellation_list[slot_idx] = constellation
	else
		self.constellation_list[slot_idx] = nil
	end
	self:SetLevelData()
	self:DispatchEvent(HoroscopeData.CONSTELLATION_DATA_CHANGE, {index = slot_idx})

end

function HoroscopeData:GetAllConstellationData()
	return self.constellation_list
end

function HoroscopeData:GetConstellationData(slot)
	return self.constellation_list[slot]
end

function HoroscopeData:SetSlotInfoDataList(slot_info_list)
	self.slot_info_list = slot_info_list

end

function HoroscopeData:UpdateSlotInfoDataList(slot_idx, level, exp)
	local strength_data = self:GetSlotInfoDataList(slot_idx) or {}
	local old_level = strength_data.level or 0
	if self.slot_info_list[slot_idx] == nil then
		self.slot_info_list[slot_idx] = {level = 0, exp =0}
	end
	self.slot_info_list[slot_idx].level = level
	self.slot_info_list[slot_idx].exp = exp
	self:DispatchEvent(HoroscopeData.SLOT_STRENGTHEN_DATA_CHANGE, {index = slot_idx, old = old_level, new = level})
end

function HoroscopeData:GetSlotInfoDataList(slot_idx)
	return self.slot_info_list[slot_idx]
end

function HoroscopeData:GetBestConstellationList()
	local best_constellation_list = {}
	for _, v in pairs(BagData.Instance:GetBagConstellationList()) do
		local item_conf = ItemData.Instance:GetItemConfig(v.item_id)
		if best_constellation_list[item_conf.stype] then
			local best_item_conf = ItemData.Instance:GetItemConfig(best_constellation_list[item_conf.stype].item_id)
			if best_item_conf.orderType < item_conf.orderType then
				best_constellation_list[item_conf.stype] = v
			end
		else
            if self.constellation_list[item_conf.stype] then
                local cul_item_conf = ItemData.Instance:GetItemConfig(self.constellation_list[item_conf.stype].item_id)
                if cul_item_conf.orderType < item_conf.orderType then
                    best_constellation_list[item_conf.stype] = v
                end

            else
				if item_conf.stype then
					best_constellation_list[item_conf.stype] = v
				end
            end
		end
	end
	return  best_constellation_list
end


function HoroscopeData:GetBestEquip(second_type, item_data)
	local is_best = false
	local max_best = item_data
	for k,v in pairs(BagData.Instance:GetBagConstellationList(second_type)) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg.stype == second_type then 
			if item_data == nil then
				is_best = true
				max_best = v
			else
				local item_conf1 = ItemData.Instance:GetItemConfig(item_data.item_id)
				if (item_conf1 and item_conf1.orderType or 0) < (item_cfg and item_cfg.orderType or 0) then
					is_best = true
					max_best = v
				end
			end
		end

	end
	return is_best, max_best
end

-- 已收藏的星魂
function HoroscopeData:SetCollectionDataList(collection_list)
	self.collection_list = {}
    for _, v in pairs(collection_list) do
            if not self.collection_list[v.type] then
                self.collection_list[v.type] = {}
            end
            self.collection_list[v.type][v.grid_idx] = v.item
    end
    self:SetOtherList()
end

function HoroscopeData:SetOtherList()
	
	self.pink_list = {}
	self.or_list = {}
	self.re_list = {}
	for i = 0, 11 do
		self.pink_list[i] = {}
		self.or_list[i] = {}
		self.re_list[i] = {}
		local data1, data2, data3 = self:GetShouHuData(i, self.collection_list)

		self.pink_list[i] = data1
		self.or_list[i] = data2
		self.re_list[i] = data3
	end   
	
end

function HoroscopeData:GetShouHuData(type, list)
	local data1 = {}
	local data2 = {}
	local data3 = {}
	for k, v in pairs(list) do
		if k == type then
			for k1, v1 in pairs(v) do
				if  k1 >= 0 and k1 <= 4 then
					table.insert(data1, v1)
				elseif k1 >= 5 and k1 <= 9 then
					table.insert(data2, v1)
				elseif k1 >= 10 and k1 <= 14 then
					table.insert(data3, v1)
				end
			end
		end
	end
	return data1, data2,data3
end

function HoroscopeData:UpdateCollectionDataList(type, grid_idx, item)
    if item then
        if not self.collection_list[type] then
            self.collection_list[type] = {}
        end
        self.collection_list[type][grid_idx] = item
    else
        self.collection_list[type][grid_idx] = nil
    end
     self:SetOtherList()
end

function HoroscopeData:GetCollectionDataListBySlot(slot)
    if self.collection_list and self.collection_list[slot] then
        return self.collection_list[slot]
    else
        return {}
    end
end

---星魂颜色
function HoroscopeData:GetItemColor(item_id)
    local item_cfg = ItemData.Instance:GetItemConfig(item_id)
    if 2 < item_cfg.orderType and item_cfg.orderType < 6 then
        return  COLLECTION_COLOR.PURPLE
    elseif 5 < item_cfg.orderType and item_cfg.orderType < 9 then
        return COLLECTION_COLOR.ORANGE
    elseif 8 < item_cfg.orderType and item_cfg.orderType < 12 then
        return  COLLECTION_COLOR.RED
    end
end

---星魂收藏在那个格子
function HoroscopeData:GetCollectionGrid(slot, item_id)
    local color = self:GetItemColor(item_id)
    local grid = 0
    for i = 1, 5 do
        grid = color * 5 + i - 1
        if not self.collection_list or not self.collection_list[slot] or nil == self.collection_list[slot][grid] then
            break
        end
    end
    return grid
end

---获取紫色以上的星魂
function HoroscopeData.GetSeniorConstellationList(select_type)
    local bag_constellation_list = BagData.Instance:GetBagConstellationList(select_type)
    local senior_constellation_list = {}
    for _, v in pairs(bag_constellation_list) do
        local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
        --print("sssssssss", item_cfg.orderType, item_cfg.stype, v.item_id)
        if 2 < item_cfg.orderType and item_cfg.stype == select_type then
            table.insert(senior_constellation_list,v)
        end
    end
	if not senior_constellation_list[0] and senior_constellation_list[1] then
		senior_constellation_list[0] = table.remove(senior_constellation_list, 1)
	end
    return senior_constellation_list
end

function HoroscopeData:GetCanShouHunXingHun(select_type)
	 local bag_constellation_list = BagData.Instance:GetBagConstellationList(select_type)
    local senior_constellation_list = {}
    for _, v in pairs(bag_constellation_list) do
        local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
        if 2 < item_cfg.orderType and item_cfg.stype == select_type then
            table.insert(senior_constellation_list,v)
        end
    end
    return senior_constellation_list
end


---------------------------------------读取配置-------------------------------------
function HoroscopeData.GetSlotInfoConfBySlot(slot_idx)
	return StarSoulStrongConsumes[slot_idx]
end

function HoroscopeData.GetConsumeConf(item_id)
	return StarSoulStrongExchanges[item_id]
end


function HoroscopeData.GetSlotAttrCfg(slot_idx)
	local cfg = ConfigManager.Instance:GetServerConfig(string.format("starsoul/SSStrongAttrs/Slot_%d_Attrs", slot_idx))
	return cfg and cfg[1]
end

function HoroscopeData.GetAttrTypeValueFormat(slot_idx, level)
	local cfg = HoroscopeData.GetSlotAttrCfg(slot_idx)
	if cfg[level] and cfg[level].attrs then
		return cfg[level].attrs
	end

end


--=========是否可强化-=========== 
function HoroscopeData:GetIsCanStrenth()
	for i = 0, 11 do
		local level_data = self:GetSlotInfoDataList(i)

		local level = level_data and level_data.level or 0 
		if self:GetSingleIsCanStrenth(level, i) then
			return true
		end
	end
	return false
end

--所有红点
function HoroscopeData:IsShowRed()
	if self:GetXingHunCanOpen() then
		for i = 0, 11 do

			local data = self:GetConstellationData(i)
			local is_best = self:GetBestEquip(i, data) --可替换装备红点
			if is_best then
				return true
			end
			local level_data = self:GetSlotInfoDataList(i)
			local level = level_data and level_data.level or 0
			if self:GetSingleIsCanStrenth(level, i) then -- 可强化红点
				return true
			end
			if self:GetCanShowListByType(i) then
				return true
			end
		end
	end
	return false
end


function HoroscopeData:GetSingleIsCanStrenth(level, index)
	local config = HoroscopeData.GetSlotAttrCfg(index)
	if level < #config then
		local data = BagData.Instance:GetBagConstellationList(index)
		if #data > 0 then
			return true
		end
	end
	return false
end


function HoroscopeData:GetShowPointRed()
	
	if  not ViewManager.Instance:CanOpen(ViewDef.Horoscope.Collection) then
		return false
	end
	
	for i=0,11 do
		if self:GetCanShowListByType(i) then
			return true
		end
	end
	return false
end

--星魂是否开放
function HoroscopeData:GetXingHunCanOpen( ... )
	if GameCondMgr.Instance:GetValue("CondId119") then
		return true
	end
	return false
end

--星魂守护是否开放
function HoroscopeData:GetShouHuXingHunOpen( ... )
	if GameCondMgr.Instance:GetValue("CondId122") then
		return true
	end
	return false
end

--==--守护红点----------

function HoroscopeData:GetCanShowListByType(type)
	local data = BagData.Instance:GetBagConstellationList(type)
	local list1 = self.pink_list[type] or {}
	local list2 = self.or_list[type] or {}
	local list3 = self.re_list[type] or {}
	for k, v in pairs(data) do
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		 if 3 <= (item_cfg.orderType or 0) and (item_cfg.orderType or 0) <= 5 then
		 	if  #list1 < 5 then
		 		return true
		 	end

		  elseif 6 <= (item_cfg.orderType or 0) and (item_cfg.orderType or 0) <= 8 then
		      if  #list2 < 5 then
			 		return true
			 	end
		   elseif 9 <= (item_cfg.orderType or 0) and (item_cfg.orderType or 0) < 11 then
		       if  #list3 < 5 then
			 		return true
			 	end
		   end

	end
	return false
end

function HoroscopeData:GeCanUpRemind(remind_name)
	if remind_name == RemindName.XingHuCan then
		return HoroscopeData.Instance:IsShowRed() and 1 or 0
	end
end


function HoroscopeData:BagItemChangeCallBack(event)
	local bool = false
	for i, v in pairs(event.GetChangeDataList()) do
		if v.change_type == ITEM_CHANGE_TYPE.LIST then
			bool = true
			break
		else
			local item_type = v.data.type
			if item_type == ItemData.ItemType.itConstellationItem then
				bool = true
				break
			end
		end
	end
	
	if bool then
		RemindManager.Instance:DoRemindDelayTime(RemindName.XingHuCan)
	end
end

function HoroscopeData:GetText(suittype, suitlevel, config, is_not_show_jichu)
	local suit_level_data = self:GetLevelSuit()
	local cur_suit_level_data = suit_level_data[suitlevel] or suit_level_data[1] or {}
	local text1 = ""
	if suitlevel <= 0 then
		text1 =  string.format("{color;f4ff00;%s}",string.format(Language.HaoZhuang.desc1, 1, "星魂套装", cur_suit_level_data.count or 0, cur_suit_level_data.need_count or 12, Language.HaoZhuang.active[1])).."\n"
	else
		local text6 = cur_suit_level_data.bool and cur_suit_level_data.bool > 0 and Language.HaoZhuang.active[2] or Language.HaoZhuang.active[1]
		text1 = string.format("{color;f4ff00;%s}",string.format(Language.HaoZhuang.desc1, suitlevel, "星魂套装", cur_suit_level_data.count or 0, cur_suit_level_data.need_count or 12,text6)).."\n"
	end

	local text2 = "" 
	local text21 = ""
	local type_data = XingHUnSuitTypeByType[suittype]
	for k, v in pairs(type_data) do
		local name = Language.Role.XingHunName[v]
		-- local slot = EquipData.Instance:GetEquipSlotByType(v, 0)
		local equip = self:GetConstellationData(v)
		local color = "a6a6a6"
		if equip then
			local itemm_config = ItemData.Instance:GetItemConfig(equip.item_id)
		
			if itemm_config.suitId >= suitlevel then
				color = "00ff00"
			end
		end
		if v < 6 then 
			text2 = text2 .. string.format(Language.HaoZhuang.active2, color, name) .. " "
		elseif v <= 10 then
			text21 = text21 .. string.format(Language.HaoZhuang.active2, color, name) .. " "	
		else
			text21 = text21 .. string.format(Language.HaoZhuang.active2, color, name)
		end


		
	end
	local text3 = string.format(Language.HaoZhuang.active1, text2.."\n".."   ".. text21) .. "\n"

	local attr_config = config.list[suitlevel] or config.list[1]
	local attr = attr_config.attrs
	local normat_attrs, special_attr =  RoleData.Instance:GetSpecailAttr(attr)
	local text4 = ""
	local text5 = ""
	if cur_suit_level_data.bool then
		local bool_color = cur_suit_level_data.bool > 0 and "ffffff" or "a6a6a6"
		local bool_color1 = cur_suit_level_data.bool > 0 and "ff0000" or "a6a6a6"
		local text7 = is_not_show_jichu and "" or string.format("{color;%s;%s}", "dcb73d", "基础属性：") .. "\n"
		text4 =  text7 .. string.format("{color;%s;%s}", bool_color, RoleData.FormatAttrContent(normat_attrs)) .."\n"
		if (#special_attr > 0) then
			local special_content = RoleData.FormatRoleAttrStr(special_attr, nil, prof_ignore)
			local jilv = (special_content[1].value/100) .."%"
			text5 = string.format("{color;%s;%s}", "dcb73d", "特殊属性：") .. "\n" .. string.format("{color;%s;%s}", bool_color1, string.format(Language.HaoZhuang.desc2, jilv, special_content[2].value))
		end
	else
		local text7 = is_not_show_jichu and "" or string.format("{color;%s;%s}", "dcb73d", "基础属性：") .. "\n"
		text4 =  text7 .. string.format("{color;%s;%s}", "a6a6a6", RoleData.FormatAttrContent(normat_attrs)) .."\n"
		if (#special_attr > 0) then
			local special_content = RoleData.FormatRoleAttrStr(special_attr, nil, prof_ignore)
			local jilv = (special_content[1].value/100) .."%"
			text5 = string.format("{color;%s;%s}", "dcb73d", "特殊属性：") .. "\n" .. string.format("{color;%s;%s}", "a6a6a6", string.format(Language.HaoZhuang.desc2, jilv, special_content[2].value))
		end	
	end
	local text = text1..text3..text4..text5
	return text
end


function HoroscopeData:GetCanJiHuoShuXingLevel(slot, item_id)
	local cfg = StarSoulStrongConsumes[slot]
	local item_config = ItemData.Instance:GetItemConfig(item_id)
	local max_level = 0
	for k, v in pairs(cfg) do
		if (item_config and item_config.orderType or 0) >= (v.orderType or 0) then
			max_level = v.level
		end 
	end
	return max_level
end