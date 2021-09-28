local SdkPay = {}


function SdkPay.getPayOrderParam(payItem)
    local channelId = SDKWrapper.Instance:GetChannel()
    local data = {
        channel_id = channelId,
        money=payItem.price / 100,
        card_id=payItem.itemNumId,
        card_str_id=payItem.itemStrId,
    }
    return data
end

return SdkPay
