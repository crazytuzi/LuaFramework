--------------------------------------------------------------------------------------
-- 文件名:	Class_Fate.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	2015-4-22
-- 版  本:	1.0
-- 描  述:	7-28 声望商店数据 根据角色等级来分类
-- 应  用:  
---------------------------------------------------------------------------------------

local CsvName = "ShopPrestege"

--PrestigeItem
PrestigeItem = class("PrestigeItem")
PrestigeItem.__index = PrestigeItem

function PrestigeItem:Init(tab)
	self.tab = {}
	self.tab = tab
end

function PrestigeItem:GetShopID()
	return self.tab["ID"]
end

function PrestigeItem:GetItemID()
	return self.tab["DropItemID"]
end

--商品消耗货币图标
function PrestigeItem:GetItemIcon()
	return self.tab["CurrencyIcon"]
end

function PrestigeItem:ISEnabelBuy()
	
	if self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_MASTER_EXP then --主角经验
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_MASTER_ENERGY then --体力
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_COUPONS then --元宝
		return g_Hero:getYuanBao() >= self:getNeedCurrencyNum()
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_GOLDS then --铜钱
		return g_Hero:getCoins() >= self:getNeedCurrencyNum()
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_PRESTIGE then --声望
		return g_Hero:getPrestige() >= self:getNeedCurrencyNum()
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_KNOWLEDGE then --阅历
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_INCENSE then --香贡
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_POWER then --神力/神识
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_ARENA_TIME then --竞技场挑战次数
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_ESSENCE then --元素精华、灵力
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_FRIENDHEART then --友情之心
		return g_Hero:getFriendPoints() >= self:getNeedCurrencyNum()
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_CARDEXPINBATTLE then --伙伴经验
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_XIAN_LING then --仙令
		return g_Hero:getXianLing() >= self:getNeedCurrencyNum()
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_DRAGON_BALL then --神龙令
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_XIANMAI_ONE_KEY then --一键消除
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_XIANMAI_BA_ZHE then --霸者横栏
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_XIANMAI_LIAN_SUO then --消除连锁
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_XIANMAI_DOU_ZHUAN then --斗转星移
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_XIANMAI_DIAN_DAO then --颠倒乾坤
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_METAL then --金灵核
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_NATURE then --木灵核
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_WATER then --水灵核
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_FIRE then --火灵核
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_EARTH then --土灵核
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_AIR then --风灵核
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_LIGHTNING then --雷灵核
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_SECRET_JIANGHUN then --将魂石
		return false
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_SECRET_REFRESH_TOKEN then --将魂令
		return false
	end

	return true
end

function PrestigeItem:getNeedCurrencyNum()
	return self.tab["NeedCurrencyNum"]
end

function PrestigeItem:IsEnablePreLv()
	return g_Hero:getPrestige() >= self.tab["Prestege"]
end

function PrestigeItem:IsEnableLevel()
	return g_Hero:getMasterCardLevel() >= self.tab["NeedLevel"]
end

function PrestigeItem:GetNeedPrestigeLv()
	return self.tab["PrestigeLevel"]
end

function PrestigeItem:GetNeedLevel()
	return self.tab["NeedLevel"]
end

function PrestigeItem:GetItemDropInfo()
	local DropItem=
	{
		DropItemType 			= self.tab["DropItemType"],
		DropItemID 				= self.tab["DropItemID"],
		DropItemStarLevel 		= self.tab["DropItemStarLevel"],
		DropItemNum 			= self.tab["DropItemNum"],
		DropItemEvoluteLevel	= 0,
	}

	return DropItem
end

--Class_ShopPrestige
Class_ShopPrestige = class("Class_ShopPrestige")
Class_ShopPrestige.__index = Class_ShopPrestige


function Class_ShopPrestige:ctor()
	--根据角色的等级来给配置表格中的物品 分组
	--根据 NeedLevel 为key
	self.tbLevelItem = {}

	self.tbIndex = {}
	--tbindex 下标
	self.nIndex = 0
end


function sortShopPage(left, right)
	return left < right
end

function sortShopItem(left, right)
	return left.tab.ID < right.tab.ID
end


function Class_ShopPrestige:InitDate()

	local tab = g_DataMgr:getCsvConfig(CsvName)
	self.tbLevelItem = {}
	self.tbIndex = {}

	for k, v in pairs(tab) do
		local tm = PrestigeItem.new()
		tm:Init(v);

		if self.tbLevelItem[v.NeedLevel] == nil then
			self.tbLevelItem[v.NeedLevel] = {}
			table.insert(self.tbIndex, v.NeedLevel)
		end
		table.insert(self.tbLevelItem[v.NeedLevel], tm)
	end

	table.sort(self.tbIndex, sortShopPage)
	
	for k, v in pairs(self.tbLevelItem) do
		table.sort(v, sortShopItem)
	end
end

function Class_ShopPrestige:GetCurPage()
	--丹药进入声望商店 
	if g_ItemDropGuildFunc:getDanYaoStarByIndex() 
		and g_ItemDropGuildFunc:getDanYaoStarByIndex() > 0 then 
		return g_ItemDropGuildFunc:getDanYaoStarByIndex()
	end

	local Rolelv = g_Hero:getMasterCardLevel()
	for nIndex = 1, #self.tbIndex do
		if self.tbIndex[nIndex] <= Rolelv then
			self.nIndex = nIndex
		end
	end
	return self.nIndex
end


--向前翻页
function Class_ShopPrestige:PrvShopItemPage()
	self.nIndex = self.nIndex - 1
	if self.nIndex < 1 then
		self.nIndex = 1
	end

	if not self.tbIndex[self.nIndex] then
		return nil
	end

	return #self.tbLevelItem[self.tbIndex[self.nIndex]]
end


--向后翻页
function Class_ShopPrestige:NextShopItemPage()
	self.nIndex = self.nIndex + 1
	if self.nIndex > #self.tbIndex then
		self.nIndex = #self.tbIndex 
	end

	if not self.tbIndex[self.nIndex] then
		return nil
	end
	return #self.tbLevelItem[self.tbIndex[self.nIndex]]
end


--获取当前页的物品个数
function Class_ShopPrestige:GetCurShopPageNum(nPage)
	if not self.tbIndex or not self.tbIndex[nPage] then
		return 0 
	end
	return #self.tbLevelItem[self.tbIndex[nPage]]
end

function Class_ShopPrestige:GetCurPageLevel(nPage)
	return self.tbIndex[nPage]
end


--通过下标 获取当前页面的具体元素
function Class_ShopPrestige:GetCurItemByIndex(nPage, nIndex)
	if not self.tbIndex or not self.tbIndex[nPage] then
		return nil
	end
	
	if not self.tbLevelItem or not self.tbLevelItem[self.tbIndex[nPage]] then
		return nil
	end
	return self.tbLevelItem[self.tbIndex[nPage]][nIndex]
end


function Class_ShopPrestige:GetShopPage()
	return #self.tbIndex
end

function Class_ShopPrestige:GetCSVName()
	return CsvName
end


--声望商店购买物品
function Class_ShopPrestige:requestBuyItemShopPrestige(config_id, num)
	local msg = zone_pb.BuyPrestigeShopItemRequest() 
	msg.config_id = config_id
	msg.buy_num = num
	g_MsgMgr:sendMsg(msgid_pb.MSGID_PRESTIGE_SHOP_ITEM_REQUEST, msg)
end
