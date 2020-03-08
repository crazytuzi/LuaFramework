ChangeName.ITEM_ChangeName = 2593; --改名道具
ChangeName.OPEN_LEVEL = 11 ;-- 开放等级
ChangeName.FREE_LEVEL = 30; --30级(包含)之前可以一次免费改名

ChangeName.SAVE_GROUP = 26;
ChangeName.KEY_TIMES  = 1; --改名次数
ChangeName.KEY_FREE   = 2; --免费改名是否用了

--每次改名的价格， 超过最高就以最高值
ChangeName.tbPriceSetting = {
	900,
	1800,
	5000,
	10000,
	50000,
	100000,
}


function ChangeName:GetChangePrice(pPlayer)
	if pPlayer.nLevel <= self.FREE_LEVEL then
        local nUseFree = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_FREE)
        if nUseFree == 0 then
            return 0;
        end
    end

    local nChangeItem = pPlayer.GetItemCountInAllPos(self.ITEM_ChangeName)
    if nChangeItem > 0 then
        return 0, true
    end

	local nChangedTimes = pPlayer.GetUserValue(self.SAVE_GROUP, self.KEY_TIMES)
    local nPrice = self.tbPriceSetting[nChangedTimes + 1]
    if not nPrice then
    	nPrice = self.tbPriceSetting[#self.tbPriceSetting]
    end
    return nPrice
end