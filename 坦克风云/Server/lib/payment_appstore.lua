local appStorePayMent = {}
   
-- 测试地址
appStorePayMent.sandboxUrl = getConfig("base.sandboxUrl")

-- 实际交易地址
appStorePayMent.buyUrl = getConfig("base.buyUrl")

-- 获取交易信息
function appStorePayMent:getOrderData(iapOrder,sandbox)
    local reqbody = iapOrder    
    local url = sandbox and self.sandboxUrl or self.buyUrl

    self.iapOrder = iapOrder
    self.requestUrl = url
    
    -- reqbody = 'eyJzaWduYXR1cmUiID0gIkFnWllCTHJxT01QZVIvODZCWWFwWThyQW5CSlBzdnBLZSs1L1UzMTFXOWtqOEtMb3l6QjBJOTcrZ0JHb3hxZWRidkZnVjB3ck12bEFSTzF3ZmNhUU0rV0tTRllONC9wbk9MN3BaSHVWNnpIYy9rcCtmRXdFa1loaU41RWhvL3lGSUFWRm02WXpHNlhuYjF6MWVzRlgxL08zcW13elp1UUdyT2RwNk1HR3dlenBBQUFEVnpDQ0ExTXdnZ0k3b0FNQ0FRSUNDR1VVa1UzWldBUzFNQTBHQ1NxR1NJYjNEUUVCQlFVQU1IOHhDekFKQmdOVkJBWVRBbFZUTVJNd0VRWURWUVFLREFwQmNIQnNaU0JKYm1NdU1TWXdKQVlEVlFRTERCMUJjSEJzWlNCRFpYSjBhV1pwWTJGMGFXOXVJRUYxZEdodmNtbDBlVEV6TURFR0ExVUVBd3dxUVhCd2JHVWdhVlIxYm1WeklGTjBiM0psSUVObGNuUnBabWxqWVhScGIyNGdRWFYwYUc5eWFYUjVNQjRYRFRBNU1EWXhOVEl5TURVMU5sb1hEVEUwTURZeE5ESXlNRFUxTmxvd1pERWpNQ0VHQTFVRUF3d2FVSFZ5WTJoaGMyVlNaV05sYVhCMFEyVnlkR2xtYVdOaGRHVXhHekFaQmdOVkJBc01Fa0Z3Y0d4bElHbFVkVzVsY3lCVGRHOXlaVEVUTUJFR0ExVUVDZ3dLUVhCd2JHVWdTVzVqTGpFTE1Ba0dBMVVFQmhNQ1ZWTXdnWjh3RFFZSktvWklodmNOQVFFQkJRQURnWTBBTUlHSkFvR0JBTXJSakYyY3Q0SXJTZGlUQ2hhSTBnOHB3di9jbUhzOHAvUndWL3J0LzkxWEtWaE5sNFhJQmltS2pRUU5mZ0hzRHM2eWp1KytEcktKRTd1S3NwaE1kZEtZZkZFNXJHWHNBZEJFakJ3Ukl4ZXhUZXZ4M0hMRUZHQXQxbW9LeDUwOWRoeHRpSWREZ0p2MllhVnM0OUIwdUp2TmR5NlNNcU5OTEhzREx6RFM5b1pIQWdNQkFBR2pjakJ3TUF3R0ExVWRFd0VCL3dRQ01BQXdId1lEVlIwakJCZ3dGb0FVTmgzbzRwMkMwZ0VZdFRKckR0ZERDNUZZUXpvd0RnWURWUjBQQVFIL0JBUURBZ2VBTUIwR0ExVWREZ1FXQkJTcGc0UHlHVWpGUGhKWENCVE16YU4rbVY4azlUQVFCZ29xaGtpRzkyTmtCZ1VCQkFJRkFEQU5CZ2txaGtpRzl3MEJBUVVGQUFPQ0FRRUFFYVNiUGp0bU40Qy9JQjNRRXBLMzJSeGFjQ0RYZFZYQWVWUmVTNUZhWnhjK3Q4OHBRUDkzQmlBeHZkVy8zZVRTTUdZNUZiZUFZTDNldHFQNWdtOHdyRm9qWDBpa3lWUlN0USsvQVEwS0VqdHFCMDdrTHM5UVVlOGN6UjhVR2ZkTTFFdW1WL1VndkRkNE53Tll4TFFNZzRXVFFmZ2tRUVZ5OEdYWndWSGdiRS9VQzZZNzA1M3BHWEJrNTFOUE0zd294aGQzZ1NSTHZYaitsb0hzU3RjVEVxZTlwQkRwbUc1K3NrNHR3K0dLM0dNZUVONS8rZTFRVDlucC9LbDFuaithQnc3QzB4c3kwYkZuYUFkMWNTUzZ4ZG9yeS9DVXZNNmd0S3Ntbk9PZHFUZXNicDBiczhzbjZXcXMwQzlkZ2N4Ukh1T01aMnRtOG5wTFVtN2FyZ09TelE9PSI7CiJwdXJjaGFzZS1pbmZvIiA9ICJld29KSW05eWFXZHBibUZzTFhCMWNtTm9ZWE5sTFdSaGRHVXRjSE4wSWlBOUlDSXlNREV6TFRFd0xUSTBJREEyT2pVNE9qQTJJRUZ0WlhKcFkyRXZURzl6WDBGdVoyVnNaWE1pT3dvSkluVnVhWEYxWlMxcFpHVnVkR2xtYVdWeUlpQTlJQ0l6TlRWak9EYzBaR1ZoTldZMU9EZGxPVFUyWkdOaU1qQXdZVFZoT1RBeFlUZzNZalZoTWpBMklqc0tDU0p2Y21sbmFXNWhiQzEwY21GdWMyRmpkR2x2YmkxcFpDSWdQU0FpTVRBd01EQXdNREE1TVRJMU1UWXpNQ0k3Q2draVluWnljeUlnUFNBaU1TNHdJanNLQ1NKMGNtRnVjMkZqZEdsdmJpMXBaQ0lnUFNBaU1UQXdNREF3TURBNU1USTFNVFl6TUNJN0Nna2ljWFZoYm5ScGRIa2lJRDBnSWpFaU93b0pJbTl5YVdkcGJtRnNMWEIxY21Ob1lYTmxMV1JoZEdVdGJYTWlJRDBnSWpFek9ESTJNak13T0RZeU5qTWlPd29KSW5WdWFYRjFaUzEyWlc1a2IzSXRhV1JsYm5ScFptbGxjaUlnUFNBaU5qVTJSVUl3T0RJdFJEazVSaTAwUmpjeUxVSTVPVUl0TkRNMk5VRXlPVFl5TlVReklqc0tDU0p3Y205a2RXTjBMV2xrSWlBOUlDSjBhMTluYjJ4a1h6RWlPd29KSW1sMFpXMHRhV1FpSUQwZ0lqY3pNRGt6TVRReE5TSTdDZ2tpWW1sa0lpQTlJQ0pqYjIwdWJIWnRZWGd1WVhCd2MzUnZjbVV1ZEdGdWF5STdDZ2tpY0hWeVkyaGhjMlV0WkdGMFpTMXRjeUlnUFNBaU1UTTRNall5TXpBNE5qSTJNeUk3Q2draWNIVnlZMmhoYzJVdFpHRjBaU0lnUFNBaU1qQXhNeTB4TUMweU5DQXhNem8xT0Rvd05pQkZkR012UjAxVUlqc0tDU0p3ZFhKamFHRnpaUzFrWVhSbExYQnpkQ0lnUFNBaU1qQXhNeTB4TUMweU5DQXdOam8xT0Rvd05pQkJiV1Z5YVdOaEwweHZjMTlCYm1kbGJHVnpJanNLQ1NKdmNtbG5hVzVoYkMxd2RYSmphR0Z6WlMxa1lYUmxJaUE5SUNJeU1ERXpMVEV3TFRJMElERXpPalU0T2pBMklFVjBZeTlIVFZRaU93cDkiOwoiZW52aXJvbm1lbnQiID0gIlNhbmRib3giOyJwb2QiID0gIjEwMCI7InNpZ25pbmctc3RhdHVzIiA9ICIwIjt9'

    require("socket")
    local https = require("ssl.https")
    local ltn12 = require "ltn12"

    reqbody = json.encode({["receipt-data"]=reqbody})

    local respbody, code, headers, status = https.request(url,reqbody)
    self.requestCode = code
    
    local response = {
        ret=-1,
        ConsumeStreamId = 0,
        GoodsId = 0,
        GoodsCount = 0
    }
    
    if tonumber(code) == 200 then
        local data = json.decode(respbody)
        self.status = data.status
        response.ret = data.status
        if tonumber(data.status) == 0 then
            self.ConsumeStreamId    = data.receipt.transaction_id
            self.GoodsCount         = data.receipt.quantity
            self.GoodsId            = data.receipt.product_id
            
            response.ConsumeStreamId    = data.receipt.transaction_id
            response.GoodsCount         = data.receipt.quantity
            response.GoodsId            = data.receipt.product_id
        end
    end
    return response
end

-- return boolen
function appStorePayMent:checkConsumeStreamId()
    local db = getDbo()
    local result = db:getRow("select * from tradelog where id=:ConsumeStreamId",{ConsumeStreamId=self.ConsumeStreamId})
    
    return result
end

function appStorePayMent:processOrder(uid)
    local ts = getClientTs()
    local goodsInfo = self.GoodsId:split('_')   -- tk_gold_1
    local goodsType = tonumber(goodsInfo[3])

    if #(goodsInfo) > 3 or goodsInfo[1] ~= 'tk' or goodsInfo[2] ~= 'gold' or not goodsType then
        return false,-9001
    end
    
    local payCfg = getConfig('pay')

    if not payCfg[goodsType] then
        return false,-9002
    end

    local num = payCfg[goodsType].gold * self.GoodsCount        
    local cost = payCfg[goodsType].TWD * self.GoodsCount
    self.num = num
    self.cost = cost

    local result = self:checkConsumeStreamId()

    if type(result) == 'table' and tonumber(result.status) == 0 then        
        return true
    end

    if not result then
        local iapOrder = {
            id = self.ConsumeStreamId,
            userid = uid,
            cost = cost,
            num = num,
            name = goodsInfo[2],
            trade_type = 1,
            status = self.status,
            create_time = ts,
            updateTime = ts,
        }

        local db = getDbo()
        local ret = db:insert('tradelog',iapOrder)
        if ret and ret > 0 then 
            return true
        end

        local queryStr = db:getQueryString() or ''
        self:payLog({uid,'insert failed: '..queryStr,-126})
        return false,-126
    end

    return false,-127
end

function appStorePayMent:payLog(logInfo,filename)
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

    filename = filename or 'pay'
    writeLog(log,filename)
end

-- 更新订单状态
function appStorePayMent:updateOrderStatus()
    local db = getDbo()
    local ret = db:update('tradelog',{status=1},"id="..self.ConsumeStreamId)
    if ret and ret > 0 then
        return true
    end
    return false, -128
end

return appStorePayMent