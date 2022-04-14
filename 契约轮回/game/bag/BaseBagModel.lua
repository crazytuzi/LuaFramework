--
-- @Author: chk
-- @Date:   2019-01-17 14:23:13
--
BaseBagModel = BaseBagModel or class("BaseBagModel",BaseModel)
local BaseBagModel = BaseBagModel

function BaseBagModel:ctor()
	--BaseBagModel.Instance = self
	self:Reset()
end

function BaseBagModel:Reset()

end

function BaseBagModel:GetItemByUid(uid)
	return BagModel.Instance:GetItemByUid(uid)
end

--获取该装备是否可穿戴
--默认对比(人物)身上的装备
--其他模块的装备要重载
function BaseBagModel:GetEquipCanPutOn(equipId)
	local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
	local equipConfig = Config.db_equip[equipId]
	local itemCfg = Config.db_item[equipId]
	if not equipConfig then
		return false
	end
	return EquipModel.Instance:GetEquipIsMapCareer(equipId) and 
	roleData.wake >= equipConfig.wake and roleData.level >= itemCfg.level 
end

function BaseBagModel:IsExpire(etime)
	return etime > 0 and etime < os.time()
end

--相差日期
--显示装备的有效期用到（人物身上的小恶魔）
-- 如果其他类型的装备，要重载，覆盖
function BaseBagModel:GetEquipDifTime(send_time,server_time)
	return EquipModel.Instance:GetEquipDifTime(send_time,server_time)
end

--获取(人物)配置表中装备分数
-- 如果其他类型的装备，要重载
function BaseBagModel:GetEquipScoreInCfg(item_id)
	local itemcfg = Config.db_item[item_id]
	if itemcfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST then
		return BeastModel:GetInstance():GetEquipScoreInCfg(item_id)
	elseif itemcfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
		return EquipModel.Instance:GetEquipScore(item_id)
	else
		return EquipModel.Instance:GetEquipScore(item_id)
	end
end

-- 获取根据uid获取背包中的物品TaskMode
-- 如果是其他背包要重载
function BaseBagModel:GetBagIdByUid(uid)
	return math.floor(uid / 1000000)
end

--根据下标获取格子的数据
-- 如果是其他背包要重载
function BaseBagModel:getItemDataByIndex(index)
	return BagModel.Instance:GetItemDataByIndex(index)
end

--获取身上是否穿有该位置的装备(用来对比)
-- 如果是其他各类的装备要重载
function BaseBagModel:GetPutOn(equip_cfg_id)
	return BagModel.Instance:GetPutOn(equip_cfg_id)
end

--获取(装备)物品在配置的信息，item 表不用获取
--如果是其他各类的装备要重载
function BaseBagModel:GetConfig(item_id)
	return Config.db_equip[item_id]
end

--根据根性类型和值 设置 属性颜色值
function BaseBagModel:GetAttrTypeInfo(attr,attrValue)
	return EquipModel.Instance:GetAttrTypeInfo(attr,attrValue)
end

function BaseBagModel:GetAttrTypeInfo2(attr,attrValue)
	return EquipModel.Instance:GetAttrTypeInfo2(attr,attrValue)
end



----根据(配置表中的id)获取身上对应的装备
--function BaseBagModel:GetPutonEquipMap(equipId)
--
--
--end

--身上是否有该id(配置表)的装备
--equip_id 配置表的id
function BaseBagModel:GetEquipIsOn(equip_id)
end

--套装相关
--判断该装备是否可打造套装
--equipDetail  服务器发的p_item
--suitLv 套装等级
-- 不是人物套装要重载
function BaseBagModel:GetCanBuildSuit(equipDetail,suitLv)

end

--获取该装备激活的套装等级
-- equip_item 服务器发的p_item
-- 不是人物套装要重载
function BaseBagModel:GetShowSuitLvByEquip(equip_item)
end

--获取激活套装的数量
--slot 部位
--order 阶位
--suitLv 套装等级
-- 不是人物套装要重载
function BaseBagModel:GetActiveSuitCount(slot,order,suitLv)
end

--获取套装配置信息
--slot 部位
--order 阶位
--suitLv 套装等级
-- 不是人物套装要重载
function BaseBagModel:GetSuitConfig(slot,order,suitLv)
end


--获取套装数量
--slot 部位
--order 阶位
--suitLv 套装等级
-- 不是人物套装要重载
function BaseBagModel:GetSuitCount(slot,order,suitLv)
end

--获取套装是否激活
-- slot 部位
--suitLv 套装等级
-- 不是人物套装要重载
function BaseBagModel:GetActiveByEquip(slot,suitLv)
end

--获取套装等级(类别)名字
-- suitLv 套装等级(类别)
-- 不是人物套装要重载
function BaseBagModel:GetSuitLvName(suitLv)
end

--根据职业和装备唤醒等级获取装备唤醒配置，匹配是否可以穿戴
function BaseBagModel:GetEquipWakeCfg(career, equipWake)
end

--根据部位判断是否可镶嵌宝石(默认判断角色的装备)
function BaseBagModel:GetEquipCanStoneBySlot(slot)
	return EquipModel.GetInstance():GetEquipCanStoneBySlot(slot)
end

function BaseBagModel:GetMatchSex(item_id)
	local match = false
	local iconTbl = LuaString2Table(Config.db_item[item_id])
	if type(iconTbl) == "table" then
		local roleData = RoleInfoModel.Instance:GetMainRoleData()
		for i, v in pairs(iconTbl) do
			if i == roleData.sex then
				match = true
				break
			end
		end

		return match
	else
		return true
	end
end

--获取身上装备的评分
function BaseBagModel:GetEquipScore(slot)
	local equipitem = EquipModel:GetInstance():GetEquipBySlot(slot)
	return equipitem and equipitem.score or 0
end

--判断是否有熔炼
function BaseBagModel:IsCanSmelt()
	for k, v in pairs(self.bagItems) do
		if v ~= 0 then
			local item = Config.db_item[v.id]
			if item.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP and item.color>= enum.COLOR.COLOR_PURPLE
			 and item.color <= enum.COLOR.COLOR_RED and item.stype ~= enum.ITEM_STYPE.ITEM_STYPE_FAIRY 
			 and item.stype ~= enum.ITEM_STYPE.ITEM_STYPE_FAIRY2
			 and item.stype ~= enum.ITEM_STYPE.ITEM_STYPE_RING1 and item.stype ~= enum.ITEM_STYPE.ITEM_STYPE_RING2 then
				local equip = Config.db_equip[v.id]
				local slot = equip.slot
				local score = v.score
				local equip_score = self:GetEquipScore(slot)
				if (item.color < enum.COLOR.COLOR_RED or ( item.color == enum.COLOR.COLOR_RED and equip.star < 3))
				  and score <= equip_score then
					return true
				end
			end
		end
	end
	return false
end



function BaseBagModel:SplicingDifTime(difDay,difTime)

	if difTime < 59 then
		return ConfigLanguage.Mix.Just
	end

	local timeTab = TimeManager:GetLastTimeBySeconds(difTime)

	if timeTab then

		local day, hour, minute, sec

		if (timeTab.day) then
			day = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Green),
					timeTab.day) .. ConfigLanguage.Mix.Day
		end

		if (timeTab.hour) then
			hour = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Green),
					timeTab.hour) .. ConfigLanguage.Mix.Hour
		end

		if (timeTab.min) then
			minute = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Green),
					timeTab.min) .. ConfigLanguage.Mix.Minute
		end

		if (timeTab.sec) then
			sec = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Green),
					timeTab.sec) .. ConfigLanguage.Mix.Sec
		end

		return day .. hour .. minute .. sec
	end


	--if difDay <= 0 then
	--	if difTime < 59 then
	--		return ConfigLanguage.Mix.Just
	--	elseif difTime >= 60 and difTime < 3600 then
	--		return string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Green),
	--				math.floor(difTime / 60))   .. ConfigLanguage.Mix.Minute .. string.format("<color=#%s>%s</color>",
	--				ColorUtil.GetColor(ColorUtil.ColorType.Green),math.floor(difTime % 60))
	--	else
	--		local hour = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Green),
	--				math.floor(difTime / 3600))  .. ConfigLanguage.Mix.Hour
	--		local minute = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Green),
	--				math.floor((difTime % 3600) / 60)) .. ConfigLanguage.Mix.Minute
	--		local sec = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Green),
	--				math.floor((difTime % 60))) .. ConfigLanguage.Mix.Sec
	--
	--		return hour .. minute .. sec
	--	end
	--else
	--	local day = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Green),difDay)
	--	local hour = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Green),
	--			math.floor(difTime / 3600))  .. ConfigLanguage.Mix.Hour
	--	local minute = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Green),
	--			math.floor((difTime % 3600) / 60)) .. ConfigLanguage.Mix.Minute
	--	local sec = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Green),
	--			math.floor((difTime % 60))) .. ConfigLanguage.Mix.Sec
	--
	--	return day .. hour .. minute .. sec
	--end
end

function BaseBagModel:GetRareNum(color)
	if color == enum.COLOR.COLOR_PURPLE then
		return 1
	elseif color == enum.COLOR.COLOR_ORANGE then
		return 2
	elseif color == enum.COLOR.COLOR_RED then
		return 3
	elseif color == enum.COLOR.COLOR_PINK then
		return 4
	else
		return 0
	end
end

local color_2_effect_id = {
		[1] = {
		    [4] = 10301,
		    [5] = 10302,
		    [6] = 10303,
		    [7] = 10304,
		    [8] = 10305,
		},
		[2] = {
			[4] = 10306,
	    	[5] = 10307,
	    	[6] = 10308,
	    	[7] = 10309,
	    	[8] = 10310,
		},
	}

function BaseBagModel:GetEffectIdByColor(color, effect_type)
	return color_2_effect_id[effect_type][color] or 0
end

