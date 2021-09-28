--Author:		bishaoqing
--DateTime:		2016-05-16 17:03:42
--Region:		黑市商店配置

local Arg = 
{
	--神秘商店类型（1.普通神秘商店；2.魂值神秘商店；3.高级VIP神秘商店；4为黑市商人）
	Ingot = 0,
	Normal = 1,
	Soul = 2,
	Vip = 3,
	BlackMarket = 4,
	BookMarket = 5,
	--货币类型
	MoneyIngot = 1,
	MoneySoal = 2,
	MoneyNormal = 3,
}

local BookSpeakWords = 
{
	-- "想想看，不买书你能变强吗？",
	"书中自有那个......嘿嘿嘿",
	"年轻人，读书少会被人骗的！"
}
local BlackSpeakWords =
{
	"想看看我的宝贝吗？",
	"货真价实，童叟无欺！",
	"小本生意，概不赊欠！"
}
Arg.getSpeakWords = function( nShopType )
	-- body
	local nIndex = math.random(1,3)
	print("nIndex", nIndex, nShopType)
	if nShopType == Arg.BlackMarket then
		return BlackSpeakWords[nIndex]
	elseif nShopType == Arg.BookMarket then
		return BookSpeakWords[nIndex]
	else
		return BlackSpeakWords[nIndex]
	end
end

Arg.GetMoneyName = function( nMoneyType )
	-- body
	if nMoneyType == Arg.MoneyIngot then
		return "元宝"
	elseif nMoneyType == Arg.MoneySoal then
		return "魂值"
	end
	return ""
end

Arg.GetMoneyIcon = function( nMoneyType )
	-- body
	if nMoneyType == Arg.MoneyIngot then
		return "res/group/currency/3.png"
	elseif nMoneyType == Arg.MoneyNormal then
		return "res/group/currency/1.png"
	else
		return "res/group/currency/1.png"
	end
end

Arg.GetShopName = function( nShopType )
	-- body
	if nShopType == Arg.BlackMarket then
		return "黑市商人"
	elseif nShopType == Arg.BookMarket then
		return "书店"
	end
end

Arg.getPerson = function ( nShopType )
	-- body
	if nShopType == Arg.BlackMarket then
		return "res/mainui/npc_big_head/black.png"
	elseif nShopType == Arg.BookMarket then
		return "res/mainui/npc_big_head/10015.png"
	else
		return "res/mainui/npc_big_head/0-1.png"
	end
end
return Arg