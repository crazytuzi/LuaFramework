acOpenGiftVo=activityVo:new()
function acOpenGiftVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.discountData = nil
    self.buyData = nil
    self.baseGoldNum = 0
    return nc
end

function acOpenGiftVo:updateSpecialData(data)
    -- self.t 上一次的领奖时间
    self.refreshTs = G_getWeeTs(base.serverTime)+86400  -- 刷新时间（比如排行结束时间，可能与st 或 et 有关系 ，所以有可能写到updateData里)
    self.refresh = false --是否已刷新过数据

    if data.d then
    	self.buyData=data.d
    end
    
    if data.baseGoldNum ~= nil then
        self.baseGoldNum = data.baseGoldNum
    end

    self:updateDiscountData(data)
end

function acOpenGiftVo:getBuynumByDay(gift)
    local dayNum = math.floor((G_getWeeTs(base.serverTime) - G_getWeeTs(self.st))/86400) -- 第几天
     if dayNum < 0 then
        return 0
     end     
        
     dayNum = dayNum + 1

    if self.buyData == nil then
        return 0
    end
    local d = self.buyData["d"..dayNum]
    if d ~= nil then
        for k,v in pairs(d) do
            if k == gift and gift ~= nil then
                return tonumber(v)
            end
        end
    end
    return 0
end

function acOpenGiftVo:updateDiscountData(data)
    if data.openGift ~= nil then
        self.discountData = data.openGift.shop
        if self.discountData ~= nil then
            for k,v in pairs(self.discountData) do
                if v ~= nil and v.buynum == nil then
                    v.buynum = self:getBuynumByDay(v.gift)
                end
            end
        end
    end
end

function acOpenGiftVo:initRefresh()
    self.needRefresh = true -- 这里是从前一天到第二天时需要刷新数据
end

