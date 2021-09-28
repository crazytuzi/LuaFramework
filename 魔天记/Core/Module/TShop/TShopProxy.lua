require "Core.Module.Pattern.Proxy"

TShopProxy = Proxy:New();
function TShopProxy:OnRegister()

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetTShopData, TShopProxy.GetTShopDataResult);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TShopExchange, TShopProxy.TShopExchangeResult);


end

function TShopProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetTShopData, TShopProxy.GetTShopDataResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TShopExchange, TShopProxy.TShopExchangeResult);




end



function TShopProxy.TryGetShopData(shop_id)


    SocketClientLua.Get_ins():SendMessage(CmdType.GetTShopData, { s = shop_id });

end

function TShopProxy.GetTShopDataResult(cmd, data)



    if (data.errCode == nil) then

        ShopDataManager.SetHasBuyProducts(data.id, data.shops)

        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);

    end

end


function TShopProxy.TryExchange(shopType, spid, num)


    SocketClientLua.Get_ins():SendMessage(CmdType.TShopExchange, { s = shopType, id = spid, n = num });

end

function TShopProxy.TShopExchangeResult(cmd, data)


    if (data.errCode == nil) then

        TShopProxy.TryGetShopData(data.s);

        UISoundManager.PlayUISound(UISoundManager.path_ui_gold);

        --  MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("TShop/TShopProxy/label1"));
        --    else
        --        MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
    end

end

