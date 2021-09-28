--CardPrizeInfo.lua

CardPrizeInfo = class()
--local prop = Property(CardPrizeInfo)
--prop:accessor("itemid",0)
--prop:accessor("itemnum",0)
--prop:accessor("probability",0)

function CardPrizeInfo:__init(itemid,itemnum,probability)
	--prop(self,"itemid",itemid)
	--prop(self,"itemnum",itemnum)
	--prop(self,"probability",probability)
	self.itemid = itemid
	self.itemnum = itemnum
	self.probability = probability
end


