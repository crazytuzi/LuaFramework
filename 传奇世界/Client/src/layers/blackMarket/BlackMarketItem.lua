--Author:		bishaoqing
--DateTime:		2016-05-13 15:09:41
--Region:		黑市商品类
local BlackMarketItem = class("BlackMarketItem")
local Items = require("src/config/RidingCfg")
--[[
message MysteryItemInfo
{
	optional uint32 moneyType = 1;
	optional uint32 arrayIndex = 2;
	optional uint32 itemID = 3;
	optional uint32 price = 4;
	optional int32 itemLeft = 5; 				//0 is sell out
	optional int32 souceNum = 6; 				//-1 is infinite
	optional int32 serverLimit = 7; 			//-1 is not limit
	optional int32 roleLimit = 8; 				//-1 is not limit
	optional int32 roleCurBuy = 9; 				//-1 is not limit
	optional int32 isBind = 10;					//1 is no bind, 2 is bind
}
]]
function BlackMarketItem:ctor( iUid, stInfo )
	-- body
	self.m_iUid = iUid
	self:Reset(stInfo)
end

--初始化成员变量
function BlackMarketItem:Reset( stInfo )
	-- body
	self.m_stInfo = stInfo
	self.m_nMoneyType = stInfo.moneyType
	self.m_nArrayIndex = stInfo.arrayIndex
	self.m_nItemID = stInfo.itemID
	self.m_nPrice = stInfo.price
	self.m_nItemLeft = stInfo.itemLeft
	self.m_nSouceNum = stInfo.souceNum
	self.m_nServerLimit = stInfo.serverLimit
	self.m_bIsBind = stInfo.isBind

	self.m_nRoleLimit = stInfo.roleLimit
	self.m_nRoleCurBuy = stInfo.roleCurBuy

	self.m_nMaxNum = 99
end

function BlackMarketItem:getRoleLimie( ... )
	-- body
	return self.m_nRoleLimit
end

function BlackMarketItem:getRoleCurBuy( ... )
	-- body
	return self.m_nRoleCurBuy
end

function BlackMarketItem:IsBind( ... )
	-- body
	print("self.m_bIsBind",self.m_bIsBind)
	return self.m_bIsBind > 1
end

function BlackMarketItem:GetMaxNum( ... )
	-- body
	return self.m_nMaxNum
end

--获取唯一id
function BlackMarketItem:GetUid( ... )
	-- body
	return self.m_iUid
end

--获取参数设置
function BlackMarketItem:GetInfo( ... )
	-- body
	return self.m_stInfo
end

function BlackMarketItem:GetMoneyType( ... )
	-- body
	return self.m_nMoneyType
end

function BlackMarketItem:GetArrayIndex( ... )
	-- body
	return self.m_nArrayIndex
end

function BlackMarketItem:GetItemID( ... )
	-- body
	return self.m_nItemID
end

function BlackMarketItem:GetPrice( ... )
	-- body
	return self.m_nPrice
end

function BlackMarketItem:GetItemLeft( ... )
	-- body
	return self.m_nItemLeft
end

function BlackMarketItem:GetSouceNum( ... )
	-- body
	return self.m_nSouceNum
end

function BlackMarketItem:GetServerLimit( ... )
	-- body
	return self.m_nServerLimit
end

function BlackMarketItem:IsServerLimit( ... )
	-- body
	return self.m_nServerLimit ~= -1
end

function BlackMarketItem:IsSingleLimit( ... )
	-- body
	return self.m_nRoleLimit ~= -1
end

function BlackMarketItem:IsLimit( ... )
	-- body
	return self:IsServerLimit() or self:IsSingleLimit()
end

--是否需要显示特殊购买界面
function BlackMarketItem:needShowRideBuyPanel( ... )
	-- body
	-- if self.m_nItemID == 1076 then--黄金宝马
	-- 	return true
	-- end
	--如果在坐骑表里有就调用
	if not Items then
		return false
	end
	for k,v in pairs(Items) do
		if v.q_propID == self.m_nItemID then
			return true
		end
	end
end

function BlackMarketItem:Dispose( ... )
	-- body
end

return BlackMarketItem