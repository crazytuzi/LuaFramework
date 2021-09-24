local payCenter = {}

function payCenter:getOrderInfo()
    local db = getDbo()
    local result = db:getRow("select * from tradelog where id=:ConsumeStreamId",{ConsumeStreamId=self.ConsumeStreamId})
    
    return result
end

function payCenter:processOrder(uid)
    local orderInfo = self:getOrderInfo()

    if type (orderInfo) ~= 'table' or tonumber(orderInfo.userid) == nil then
        return false,-126
    end

    self.uid = tonumber(orderInfo.userid)

    if tonumber(orderInfo.status) ~= 0 then
        return false,-127
    end

    local ts = getClientTs()
    local goodsInfo = orderInfo.name:split('_')   -- tk_gold_1
    local goodsType = tonumber(goodsInfo[3])

    if #(goodsInfo) > 3 or string.sub(goodsInfo[1],1,2) ~= 'tk' or goodsInfo[2] ~= 'gold' or not goodsType then
        return false,-9001
    end

    local payCfg = getConfig('pay')

    if not payCfg[goodsType] or not payCfg[goodsType][orderInfo.curType] then
        return false,-9002
    end
    
    self.GoodsCount = self.GoodsCount or 1
    local num = payCfg[goodsType].gold * self.GoodsCount        
    local cost = payCfg[goodsType][orderInfo.curType] * self.GoodsCount

    -- if num ~= tonumber(orderInfo.num) or cost ~= tonumber(orderInfo.cost) then
    --     return false,-9002
    -- end 

    self.num = num
    self.cost = cost
    self.GoodsId = orderInfo.name        

    return true

end

function payCenter:payLog(logInfo,filename)
    local log = ""
    log = log .. os.time() .. "|"
    log = log .. (logInfo.uid or ' ') .. "|"
    log = log .. (self.requestCode or ' ') .. "|"
    log = log .. (self.status or ' ') .. "|"
    log = log .. (self.requestUrl or ' ') .. "|"
    log = log .. (self.ConsumeStreamId  or ' ') .. "|"    
    log = log .. (logInfo.msg or ' ') .. "|"
    log = log .. (logInfo.code or '-1') .. "|"
    log = log .. (self.iapOrder or ' ')

    if self.request then
        if type(self.request) == 'table' then
            log = log .. '|request:' .. (json.encode(self.request) or '')
        else
            log = log .. '|request:' .. (tostring(self.request) or '')
        end
    end

    filename = filename or 'pay'
    writeLog(log,filename)
end

-- 更新订单状态
function payCenter:updateOrderStatus(conditions)
    conditions = conditions or {}
    conditions.status=1

    local db = getDbo()
    local ret = db:update('tradelog',conditions,"id='".. self.ConsumeStreamId.."'")

    if ret and ret > 0 then
        return true
    end
    return false, -128
end

return payCenter