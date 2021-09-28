local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
-----------------------------------------------------------------------------
local tPropIdAsKey = getConfigItemByKey("propCfg", "q_id")
local MColor = require "src/config/FontColor"

-- 获取一个原型道具的所有信息
local item = function(id)
	--cclog("道具id " .. id)
	return tPropIdAsKey[id]
end
-----------------------------------------------------------------------------

--彩色道具名
createColorName = function( grid, parent, pos, anchor, fontSize )
	-- body
	local nProtoId = MPackStruct.protoIdFromGird(grid)
	local nQuality = quality(nProtoId, grid)
	local nColor = MColor:getQualityColor(nQuality)
	local sName = name(nProtoId)
	print("nProtoId",nProtoId, nQuality, sName)
	local uiName = createLabel(parent, sName, pos, anchor, fontSize)
	uiName:setColor(nColor)
	return uiName
end

-- 道具名称
name = function(id)
	local record = item(id)
	return record and tostring(record.q_name)
end

-- 道具图标
icon = function(id)
	-- 占位值为惊叹号图标
	local propIconDir = "res/group/itemIcon/"
	local record = item(id)
	local ret = propIconDir .. ((record and record.q_tiny_icon) or "000000") .. ".png"
	local texture = TextureCache:addImage(ret)
	if texture then
		return ret
	else
		return propIconDir .. "000000.png"
	end
end

-- 是否是带特效的道具
ItemEffect = function(id)
    local record = item(id)
    if record ~= nil then
        if record.q_tiny_eff and record.q_tiny_eff > 0 then
            return ("item_" ..record.q_tiny_eff);
        end
    end

    return nil;
end

-- 特效叠加模式
ItemEffectMode = function(id)
    local record = item(id)
    if record ~= nil then
        if record.q_eff_mode and record.q_eff_mode > 0 then
            return record.q_eff_mode;
        end
    end

    return 3;
end

-- 特效每帧间隔
ItemEffectTime = function(id)
    local record = item(id)
    if record ~= nil then
        if record.q_eff_time and record.q_eff_time > 0 then
            return record.q_eff_time;
        end
    end

    return 80;
end


-- 道具品质
quality = function(id, grid)
	-- 占位值为红色品质
	
	--[[
	--dump(grid, "grid")
	local MequipOp = require "src/config/equipOp"
	-- 是否是装备
	local isEquip = grid and MPackStruct.categoryFromGird(grid) == MPackStruct.eEquipment
	-- 是否是套装
	local isSuit = MequipOp.isSuit(id)
	
	if isEquip and not isSuit then
		local randomAttrSet = MPackStruct.attrFromGird(grid, MPackStruct.eAttrRandom)
		local num = MPackStruct.numOfRandomAttr(randomAttrSet)
		--dump(num, "num")
		if num < 1 then -- 白色
			-- 读表
		elseif num < 3 then -- 绿色
			return 2
		elseif num < 4 then -- 蓝色
			return 3
		elseif num < 5 then -- 紫色
			return 4
		else -- 橙色
			return 5
		end
	end
	--]]
	
	local record = item(id)
	return record and tonumber(record.q_default) or 0
end

-- 名字颜色
local tNameColor = {
	[0] = MColor.red,
	[1] = MColor.drop_white,
	[2] = MColor.green,
	[3] = MColor.blue,
	[4] = MColor.purple,
	[5] = MColor.orange,
}

allQualityColors = function()
    return tNameColor
end

nameColor = function(id, grid)
	-- 占位值为红色
	return tNameColor[quality(id, grid)] or MColor.red
end

nameColorExEx = function(id)
	-- 占位值为红色
	local colorCfg = {
						[0] = "red" ,
						[1] = "drop_white" ,
						[2] = "green",
						[3] = "blue",
						[4] = "purple",
						[5] = "orange",
					}
	return colorCfg[quality(id, grid)] or colorCfg[0]
end

nameColorEx = function(index)
	-- 占位值为红色
	return tNameColor[index] or MColor.red
end


-- 道具边框图标
border = function(id, grid)
	-- 占位值为红色边框
	local borderDir = "res/group/itemBorder/"
	local itemQuality = quality(id, grid)
	local ret = borderDir .. itemQuality .. ".png"
	local texture = TextureCache:addImage(ret)
	if texture then
		return ret
	else
		return borderDir .. "0.png"
	end
end

-- 显示道具时的tips背景图片
tips = function(id, grid)
	-- 占位值为红色背景
	local tipsDir = "res/group/itemTips/"
	local itemQuality = quality(id, grid)
	local ret = tipsDir .. itemQuality .. ".png"
	local texture = TextureCache:addImage(ret)
	if texture then
		return ret
	else
		return tipsDir .. "0.png"
	end
end

-- 使用职业限制
schoolLimits = function(id)
	local record = item(id)
	return tonumber((record and record.q_job) or 0)
end

-- 使用性别限制
sexLimits = function(id)
	-- 默认值通用
	local record = item(id)
	return tonumber((record and record.q_sex) or 0)
end

-- 使用等级限制
levelLimits = function(id)
	local record = item(id)
	local default = (record and tonumber(record.q_level)) or 1
		
	local MequipOp = require "src/config/equipOp"
	local MPackStruct = require "src/layers/bag/PackStruct"
	local MpropOp = require "src/config/propOp"
	-- 是否是套装
	local isSuit = MequipOp.isSuit(id)
	local isEquip = MPackStruct:getCategoryByPropId(id) == MPackStruct.eEquipment
	local quality = MpropOp.quality(id)
	
--	if isSuit or (isEquip and quality == 5) then
--		return 1, default
--	else
--		return default
--	end

    return default or 1
end

-- 本角色是否可以使用或穿戴
isLimitToMe = function(protoId)
	local MPackStruct = require "src/layers/bag/PackStruct"
	local MpropOp = require "src/config/propOp"
	local Mconvertor = require "src/config/convertor"
	local MRoleStruct = require("src/layers/role/RoleStruct")
	
	local roleLv = MRoleStruct:getAttr(ROLE_LEVEL) or 1
	local propLv = MpropOp.levelLimits(protoId)
	
	local roleSchool = MRoleStruct:getAttr(ROLE_SCHOOL)
	local propSchool = MpropOp.schoolLimits(protoId)
	
	local roleSex = MRoleStruct:getAttr(PLAYER_SEX)
	local propSex = MpropOp.sexLimits(protoId)
	
	return roleLv < propLv or (propSchool ~= Mconvertor.eWhole and propSchool ~= roleSchool) or (propSex ~= Mconvertor.eSexWhole and propSex ~= roleSex)
end

-- 每个格子的最大叠加数目
maxOverlay = function(id)
	-- 默认最大可叠加99
	local record = item(id)
	return (record and record.q_max) or 99
end

-- 道具所属类别
category = function(id)
	-- 没有默认值
	local record = item(id)
	local cate = record and record.q_type
	return cate and tonumber(cate)
end

-- 商店是否回收(0不回收，1回收)
recyclable = function(id)
	-- 默认不可回收
	local record = item(id)
	return record and record.q_sell == 1
end

-- 商店回收价格
recyclePrice = function(id)
	-- 默认回收价格为0
	local record = item(id)
	return (record and record.q_sell_price) or 0
end

-- 商店回收时是否二次确认(0否, 1是)
recycleConfirm = function(id)
	-- 默认不需要二次确定
	local record = item(id)
	return record and record.q_sell_confirm == 1
end

-- 道具的描述信息1
description1 = function(id)
	local record = item(id)
	return (record and record.q_describe) or ""
end

-- 道具的描述信息2
description2 = function(id)
	local record = item(id)
	return (record and record.q_describe_two) or ""
end

-- 道具的功能或用途
usage = function(id)
	local record = item(id)
	return (record and record.q_function) or ""
end

-- 药品使用冷却时间(单位: 毫秒)
cd = function(id)
	-- 占位值为 1000 毫秒
	local record = item(id)
	local ret = (record and record.q_cooldown) or 1000
	return ret, ret/1000 .. "秒"
end

-- 药品公共冷却层级
cdl = function(id)
	-- 占位值为为0
	local record = item(id)
	return (record and record.q_cooldown_level) or 0
end

-- 药品公共冷却时间(单位: 毫秒)
lcd = function(id)
	-- 占位值为 1000 毫秒
	local record = item(id)
	local ret = (record and record.q_cooldown_type) or 1000
	return ret, ret/1000 .. "秒"
end

-- 绑定类型(0不绑定, 1获得时绑定, 2使用后绑定)
bind = function(id)
	-- 默认为不绑定
	local record = item(id)
	return record and record.q_bind == 1
end

-- 是否允许被拖放至物品快捷栏(0不允许，1允许)
shortcut = function(id)
	-- 默认为不可放入快捷栏
	local record = item(id)
	return record and record.q_shortcut == 1
end

-- 着装的资源id
equipResId = function(id)
	-- 占位值为鬼头刀
	local record = item(id)
	return (record and record.q_equip_resource) or 0
end

-- 背包中的物品是否可以放入仓库(1否，0是)
accessible = function(id)
	-- 默认为可以放入仓库
	local record = item(id)
	if record then
		if record.q_save_warehouse == 1 then
			return false
		else
			return true
		end
	else
		return true
	end
end

-- 是否能使用(0是不能，1是能)
canUse = function(id)
	local record = item(id)
	if record then
		if record.nfsy == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

-- 背包中的物品是否可以批量使用(0否，1是)
canUsedInBatch = function(id)
	-- 默认为不可批量使用
	local record = item(id)
	if record then
		if record.q_whether_batch == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

-- 普通物品是否能合成(0是不能，1是能)
canCompound = function(id)
	local record = item(id)
	if record then
		if record.nfhc == 1 then
			return true
		else
			return false
		end
	else
		return false
	end
end

-- 装备是否能合成
equipCanCompound = function(id)
	local record = item(id)
	if record then
		return tonumber(record.q_sourceNeedID)
	else
		return false
	end
end

-- 装备合成所需材料
equipCompoundMaterialNeed = function(id)
	local record = item(id)
	if record then
		return tonumber(record.q_sourceNeedID), tonumber(record.q_sourceNeedNum), tonumber(record.q_sourceNeedNum2)
	end
end

-- 产出途径
outputWay = function(id)
	local record = item(id)
	if record and record.hqtj and record.hqtj ~= "" then
		return string.mysplit(string.mytrim(tostring(record.hqtj)), ",")
	else
		return {}
	end
end

-- 前往使用
goUse = function(id)
	local record = item(id)
	if record and record.qwsy and record.qwsy ~= "" then
		local list = string.mysplit(string.mytrim(tostring(record.qwsy)), ",")
		local no1 = list[1]
		if not no1 then return end
		
		no1 = tonumber(no1)
		if not no1 then return end
		
		local MPropOutput = require "src/config/PropOutputWayOp"
		record = MPropOutput:record(no1)
		return MPropOutput:goto(record)
	end
end

-- 寻路npc使用
goToNPC = function(id)
	local record = item(id)
	return record and tonumber(record.Go_NPC)
end

--掉落特效
effectType = function(id)
	local record = item(id)
	return tonumber((record and record.q_append)) or 1
end

-- 寄售分类编号
consignCate = function(id)
	local record = getConfigItemByKey("TransactionLimit", "q_ItemId",id)
	return tonumber((record and record.q_query_type)) or 0
end

-- 熔炼返回熔炼值
meltingValue = function(id)
	local record = item(id)
	return tonumber((record and record.q_rlx)) or 0
end


local tSoundEffect = 
{
	[0] = "sounds/uiMusic/ui_click.mp3", -- 默认
	[1] = "sounds/uiMusic/ui_Ring.mp3", -- 宝石类
	[2] = "sounds/uiMusic/ui_Necklace.mp3", -- 饰品类
	[3] = "sounds/uiMusic/ui_drug.mp3", -- 液体药品
	[4] = "sounds/uiMusic/ui_cloth.mp3", -- 衣物
	[5] = "sounds/uiMusic/ui_Armour.mp3", -- 武器
}
-- 道具声音
soundEffect = function(id)
	local record = item(id)
	local code = tonumber((record and record.q_genre)) or 0
	return tSoundEffect[code]
end

-- 拍卖行寄售价格上下限
consignPrice = function(id)
	local record = getConfigItemByKey("TransactionLimit", "q_ItemId",id)
	if record ~= nil then
		return tonumber(record.q_LimitMin) or 0, tonumber(record.q_LimitMax) or 0
	else
		return 0, 0
	end
end

-- local propInSKillBag = {}
isInSkill = function()
	-- if propInSKillBag then
	-- else
		local propInSKillBag = {}
		for k,v in pairs(tPropIdAsKey) do
			if v.q_inskill and tonumber(v.q_inskill) == 1 then
				propInSKillBag[#propInSKillBag+1] = {0,2,v.q_id}
			end
		end
	-- end
	return propInSKillBag
end

-- 熔炼装备返还七彩石上下限
smeltRet = function(id)
	local record = item(id)
	if record ~= nil then
		return tonumber(record.q_qicai1) or 0, tonumber(record.q_qicai2) or 0, tonumber(record.q_qicai_rate) or 100
	else
		return 0, 0, 100
	end
end

--快捷购买看商城有没有卖
local buyDrugTab = nil
getBuyDrugTab = function()
	if buyDrugTab then
	else
		buyDrugTab = {}
		local drugTab = {}
		if G_NO_OPEN_PAY then
			drugTab = {{20028,14},{20025,14},{20035,14},{20037,1},{20023,1},{1034,1}}
		else
			drugTab = {{20028,14},{20025,14},{20035,14},{20037,0},{20023,0},{1034,0}}
		end
		for k,v in pairs(drugTab) do
			local huobi = ""
			if v[2] == 0 then
				huobi = "q_gold"
			elseif v[2] == 1 then
				huobi = "q_bindgold"
			elseif v[2] == 14 then
				huobi = "q_coin"
			end
			local tShopCfg =  getConfigItemByKeys("MallDB", {
				"q_shop_type",
				"q_sell",
			},{v[2],v[1]},huobi) or 0
			
			table.insert(buyDrugTab,{v[1],tShopCfg,v[2]})			
		end
	end
	return buyDrugTab
end

-- 矿石纯度
purity = function(id)
	local record = item(id)
	return record and tonumber(record.OreLv)
end


--饰纹类型
shiwen = function(id)
	local record = item(id)
	return record and record.q_oxe_type and tonumber(record.q_oxe_type) > 0 and tonumber(record.q_oxe_type)
end

-- 灵兽模型
avatar = function(id)
	local record = item(id)
	return record and tonumber(record.q_avatar_resource)
end