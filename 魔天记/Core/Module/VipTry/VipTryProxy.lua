require "Core.Module.Pattern.Proxy"

VipTryProxy = Proxy:New();
function VipTryProxy:OnRegister()

end

function VipTryProxy:OnRemove()

end

function VipTryProxy.StartTryVip(id)
    local pb_item = BackpackDataManager.GetProductBySpid(id)
    ProductTipProxy.TryUseProduct(pb_item, 1)
end

function VipTryProxy.GetVipTryTime()
    return 30 * 60
end
