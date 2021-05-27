require("scripts/game/open_serve_gift/open_serve_gift_data")
require("scripts/game/open_serve_gift/merge_server_discount_view")

OpenSerVeGiftCtrl = OpenSerVeGiftCtrl or BaseClass(BaseController)

function OpenSerVeGiftCtrl:__init()
    if OpenSerVeGiftCtrl.Instance then
        ErrorLog("[OpenSerVeGiftCtrl]:Attempt to create singleton twice!")
    end
    OpenSerVeGiftCtrl.Instance = self
    
    self.data = OpenSerVeGiftData.New()
    self.merge_server_discount_view = MergeServerDiscountView.New(ViewDef.MergeServerDiscount)

    --注册
    require("scripts/game/open_serve_gift/open_serve_gift_view").New(ViewDef.OpenSerVeGift)
    require("scripts/game/open_serve_gift/open_serve_qianggou_view").New(ViewDef.OpenSerVeGift.LimitTimeBuy)
    require("scripts/game/open_serve_gift/open_serve_tehui_view").New(ViewDef.OpenSerVeGift.SaleGift)

    self:RegisterAllProtocols()
end

function OpenSerVeGiftCtrl:__delete()
    self.data:DeleteMe()
    self.data = nil
    
    OpenSerVeGiftCtrl.Instance = nil
end

function OpenSerVeGiftCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCTeHuiGiftInfo, "OnTeHuiGiftInfo")
    self:RegisterProtocol(SCTeHuiGifResult, "OnTeHuiGifResult")

    self:RegisterProtocol(SCQiangGouGiftInfo, "OnQiangGouGiftInfo")
    self:RegisterProtocol(SCQiangGouGifResult, "OnQiangGouGifResult")
    self:RegisterProtocol(SCMergeServerDiscountInfo, "OnMergeServerDiscountInfo")
end




----特惠礼包相关
--信息
function OpenSerVeGiftCtrl:OnTeHuiGiftInfo(protocol)
    self.data:SetTeHuiInfo(protocol.info_t)
end

--结果
function OpenSerVeGiftCtrl:OnTeHuiGifResult(protocol)
    --设置改变的值
    self.data:SetTeHuiInfo(protocol.gift_type, protocol.gift_level)
end

--请求信息
function OpenSerVeGiftCtrl.SendTHInfoReq()
    local protocol = ProtocolPool.Instance:GetProtocol(CSTHGiftInfoReq)
    protocol:EncodeAndSend()
end

--请求购买
function OpenSerVeGiftCtrl.SendTHBuyReq(gift_type, gift_level)
    local protocol = ProtocolPool.Instance:GetProtocol(CSTHGiftBuyReq)
    protocol.gift_type = gift_type
    protocol.gift_level = gift_level
    protocol:EncodeAndSend()
end


----限时礼包相关
--信息
function OpenSerVeGiftCtrl:OnQiangGouGiftInfo(protocol)
    self.data:SetQiangGouInfo(protocol.info_t, protocol.gift_type)
end

--结果
function OpenSerVeGiftCtrl:OnQiangGouGifResult(protocol)
    --设置改变的值
    self.data:SetQiangGouInfo(protocol.gift_type, protocol.gift_level)
end

--请求信息
function OpenSerVeGiftCtrl.SendQGInfoReq(id)
    local protocol = ProtocolPool.Instance:GetProtocol(CSQGGiftInfoReq)
    protocol.id = id
    protocol:EncodeAndSend()
end

--请求购买
function OpenSerVeGiftCtrl.SendQGBuyReq(gift_type, gift_level)
    local protocol = ProtocolPool.Instance:GetProtocol(CSQGGiftBuyReq)
    protocol.gift_type = gift_type
    protocol.gift_level = gift_level
    protocol:EncodeAndSend()
end

function OpenSerVeGiftCtrl:GetRemindNum(remind_name)
end

--------------------
-- 合服特惠
--------------------

-- 接收合服特惠礼包信息(请求 139 49)
function OpenSerVeGiftCtrl:OnMergeServerDiscountInfo(protocol)
    self.data:SetMergeServerDiscountInfo(protocol)
end

-- 请求特惠礼包信息 返回(139 63)
function OpenSerVeGiftCtrl.SendMergeServerDiscountInfo(type)
    local protocol = ProtocolPool.Instance:GetProtocol(CSMergeServerDiscountInfo)
    protocol.type = type
    protocol:EncodeAndSend()
end

-- 请求购买合服特惠礼包 (139, 50)
function OpenSerVeGiftCtrl.SendBuyMergeServerDiscount(type, index)
    local protocol = ProtocolPool.Instance:GetProtocol(CSBuyMergeServerDiscount)
    protocol.type = type
    protocol.index = index
    protocol:EncodeAndSend()
end

--------------------