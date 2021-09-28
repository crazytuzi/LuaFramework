WorkshopHelper = {
	ItemList = {
		{
			type = 0, empty_string=2709, BaseEffectIDs = {
				knight.gsp.attr.EffectType.MAGIC_DEF_ABL,
				knight.gsp.attr.EffectType.HIT_RATE_ABL,
				knight.gsp.attr.EffectType.DAMAGE_ABL,
				knight.gsp.attr.EffectType.DEFEND_ABL,
				knight.gsp.attr.EffectType.MAX_HP_ABL,
				knight.gsp.attr.EffectType.MAX_MP_ABL,
				knight.gsp.attr.EffectType.DODGE_RATE_ABL,
				knight.gsp.attr.EffectType.SPEED_ABL,
				knight.gsp.attr.EffectType.MAGIC_ATTACK_ABL,
				knight.gsp.attr.EffectType.SEAL_LEVEL_ABL,
				knight.gsp.attr.EffectType.ANTI_SEAL_LEVEL_ABL
			}
		},  -- weapon
		{
			type = 3, empty_string=2710, BaseEffectIDs = {
				knight.gsp.attr.EffectType.MAGIC_DEF_ABL,
				knight.gsp.attr.EffectType.HIT_RATE_ABL,
				knight.gsp.attr.EffectType.DAMAGE_ABL,
				knight.gsp.attr.EffectType.DEFEND_ABL,
				knight.gsp.attr.EffectType.MAX_HP_ABL,
				knight.gsp.attr.EffectType.MAX_MP_ABL,
				knight.gsp.attr.EffectType.DODGE_RATE_ABL,
				knight.gsp.attr.EffectType.SPEED_ABL,
				knight.gsp.attr.EffectType.MAGIC_ATTACK_ABL,
				knight.gsp.attr.EffectType.SEAL_LEVEL_ABL,
				knight.gsp.attr.EffectType.ANTI_SEAL_LEVEL_ABL
			}
		}, -- cloth
		{
			type = 1, empty_string=2711, BaseEffectIDs = {
				knight.gsp.attr.EffectType.MAGIC_DEF_ABL,
				knight.gsp.attr.EffectType.HIT_RATE_ABL,
				knight.gsp.attr.EffectType.DAMAGE_ABL,
				knight.gsp.attr.EffectType.DEFEND_ABL,
				knight.gsp.attr.EffectType.MAX_HP_ABL,
				knight.gsp.attr.EffectType.MAX_MP_ABL,
				knight.gsp.attr.EffectType.DODGE_RATE_ABL,
				knight.gsp.attr.EffectType.SPEED_ABL,
				knight.gsp.attr.EffectType.MAGIC_ATTACK_ABL,
				knight.gsp.attr.EffectType.SEAL_LEVEL_ABL,
				knight.gsp.attr.EffectType.ANTI_SEAL_LEVEL_ABL
			}
		}, -- hu wan
		{
			type = 2, empty_string=2712, BaseEffectIDs = {
				knight.gsp.attr.EffectType.MAGIC_DEF_ABL,
				knight.gsp.attr.EffectType.HIT_RATE_ABL,
				knight.gsp.attr.EffectType.DAMAGE_ABL,
				knight.gsp.attr.EffectType.DEFEND_ABL,
				knight.gsp.attr.EffectType.MAX_HP_ABL,
				knight.gsp.attr.EffectType.MAX_MP_ABL,
				knight.gsp.attr.EffectType.DODGE_RATE_ABL,
				knight.gsp.attr.EffectType.SPEED_ABL,
				knight.gsp.attr.EffectType.MAGIC_ATTACK_ABL,
				knight.gsp.attr.EffectType.SEAL_LEVEL_ABL,
				knight.gsp.attr.EffectType.ANTI_SEAL_LEVEL_ABL
			}
		}, -- necklace
		{
			type = 4, empty_string=2713, BaseEffectIDs = {
				knight.gsp.attr.EffectType.MAGIC_DEF_ABL,
				knight.gsp.attr.EffectType.HIT_RATE_ABL,
				knight.gsp.attr.EffectType.DAMAGE_ABL,
				knight.gsp.attr.EffectType.DEFEND_ABL,
				knight.gsp.attr.EffectType.MAX_HP_ABL,
				knight.gsp.attr.EffectType.MAX_MP_ABL,
				knight.gsp.attr.EffectType.DODGE_RATE_ABL,
				knight.gsp.attr.EffectType.SPEED_ABL,
				knight.gsp.attr.EffectType.MAGIC_ATTACK_ABL,
				knight.gsp.attr.EffectType.SEAL_LEVEL_ABL,
				knight.gsp.attr.EffectType.ANTI_SEAL_LEVEL_ABL
			}
		}, -- belt
		{
			type = 5, empty_string=2714, BaseEffectIDs = {
				knight.gsp.attr.EffectType.MAGIC_DEF_ABL,
				knight.gsp.attr.EffectType.HIT_RATE_ABL,
				knight.gsp.attr.EffectType.DAMAGE_ABL,
				knight.gsp.attr.EffectType.DEFEND_ABL,
				knight.gsp.attr.EffectType.MAX_HP_ABL,
				knight.gsp.attr.EffectType.MAX_MP_ABL,
				knight.gsp.attr.EffectType.DODGE_RATE_ABL,
				knight.gsp.attr.EffectType.SPEED_ABL,
				knight.gsp.attr.EffectType.MAGIC_ATTACK_ABL,
				knight.gsp.attr.EffectType.SEAL_LEVEL_ABL,
				knight.gsp.attr.EffectType.ANTI_SEAL_LEVEL_ABL
			}
		}
	}
}

function WorkshopHelper.ShowItemInCell(attr, cell, namewnd)
	if attr then
		local iconManager = GetIconManager()
		namewnd:setText(attr.name)
		if attr.itemtypeid % 0x10 == 8 then
			local equipConfig = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(attr.id)
			local colorconfig = knight.gsp.item.GetCEquipColorConfigTableInstance():getRecorder(equipConfig.equipcolor);
			namewnd:setProperty("TextColours", colorconfig.colorvalue)
		else
			namewnd:setProperty("TextColours", attr.colour)
		end
		cell:SetImage(iconManager:GetItemIconByID(attr.icon))
	else
		namewnd:setText("")
		cell:SetImage(nil)
	end
end

function WorkshopHelper.GetLocalItem(itemtypeid)
	local t = itemtypeid % 16
	if t ~= 8 then
		return 0, nil
	end
	local type = math.floor(itemtypeid / 16) % 16
	for i = 1, #WorkshopHelper.ItemList do
		if WorkshopHelper.ItemList[i].type == type then
			return i, WorkshopHelper.ItemList[i]
		end
	end
	return 0, nil
end

function WorkshopHelper.GetItemPos(item)
	local attr = item:GetBaseObject()
	local t = item:GetItemTypeID() % 16
	if t ~= 8 then
		return -1
	end
	local pos = math.floor(item:GetItemTypeID() / 16 % 16)
	return pos
end

function WorkshopHelper.GetAttributeName(attrid)
	local index = math.floor(attrid/10)*10
	print(string.format("Get index=%d attr", index))
	local attrconfig = knight.gsp.effect.GetCEffectConfigTableInstance():getRecorder(index);
	
	return attrconfig.classname;
end

function WorkshopHelper.GetMoneyString( needmoney )
	local strBuild = StringBuilder:new()
	local str = nil
	local found = false
	local ids = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cyinliang"):getAllID()

    for k,v in pairs(ids) do
		local item = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cyinliang"):getRecorder(v)
		if Config.CUR_3RD_LOGIN_SUFFIX == item.platformid then
			found = true
			if needmoney < item.number then
				strBuild:SetNum("parameter1",needmoney)
				str = strBuild:GetString(MHSD_UTILS.get_resstring(3064))
			else
				if item.number == 1000000 then	
	 				strBuild:SetNum("parameter1",  (math.floor(needmoney / 1e4) / 1e2))
				 else
					strBuild:SetNum("parameter1", math.ceil(needmoney/item.number))
				end
				strBuild:SetNum("parameter2",item.company)
				str = strBuild:GetString(MHSD_UTILS.get_resstring(3063))
			end
			break
		end
	end

	if not found then
		local item = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cyinliang"):getRecorder(1)
		if needmoney < item.number then
			strBuild:SetNum("parameter1",needmoney)
			str = strBuild:GetString(MHSD_UTILS.get_resstring(3064))
		else
			if item.number == 1000000 then	
 				strBuild:SetNum("parameter1",  (math.floor(needmoney / 1e4) / 1e2))
			 else
				strBuild:SetNum("parameter1", math.ceil(needmoney/item.number))
			end
			strBuild:SetNum("parameter2",item.company)
			str = strBuild:GetString(MHSD_UTILS.get_resstring(3063))
		end
	end

	strBuild:delete()
	return str
end

return WorkshopHelper