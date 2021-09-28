require "Core.Module.Pattern.Proxy"

LingYaoProxy = Proxy:New();

LingYaoProxy.MESSAGE_LINGYAO_COM_COMPLETE = "MESSAGE_LINGYAO_COM_COMPLETE";
LingYaoProxy.MESSAGE_USE_PRO_COMPLETE = "MESSAGE_USE_PRO_COMPLETE";

function LingYaoProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TryComLingYao, LingYaoProxy.TryComLingYaoResult);

    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Use_Product, LingYaoProxy.Use_Product_Result);


end

function LingYaoProxy:OnRemove()

    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TryComLingYao, LingYaoProxy.TryComLingYaoResult);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Use_Product, LingYaoProxy.Use_Product_Result);


end


------------------------- CmdType.TryComLingYao


function LingYaoProxy.TryComLingYao(spId, am)


    SocketClientLua.Get_ins():SendMessage(CmdType.TryComLingYao, { spId = spId, am = am });

end

function LingYaoProxy.TryComLingYaoResult(cmd, data)


    if (data.errCode == nil) then

        MessageManager.Dispatch(LingYaoProxy, LingYaoProxy.MESSAGE_LINGYAO_COM_COMPLETE);


    end


end






------------------------------------------------------------------------



function LingYaoProxy.TryUseProduct(productInfo, num, use_successHandler, hd_target)

    LingYaoProxy.use_successHandler = use_successHandler;
    LingYaoProxy.hd_target = hd_target;


    SocketClientLua.Get_ins():SendMessage(CmdType.Use_Product, { id = productInfo:GetId(), am = num });

end

function LingYaoProxy.Use_Product_Result(cmd, data)


    if (data.errCode == nil and  LingYaoProxy.use_successHandler ~= nil ) then

        local obj = ProductManager.GetProductById(data.spId);
        if obj.type == ProductManager.type_6 then

            BackPackCDData.CheckUseProduct(data.spId);

            LingYaoDataManager.AddHasAm(data.spId, 1);

            if LingYaoProxy.use_successHandler ~= nil then

                if LingYaoProxy.hd_target ~= nil then
                    LingYaoProxy.use_successHandler(LingYaoProxy.hd_target);
                else
                    LingYaoProxy.use_successHandler();
                end
                LingYaoProxy.use_successHandler = nil;
            end

            MessageManager.Dispatch(LingYaoProxy, LingYaoProxy.MESSAGE_USE_PRO_COMPLETE);

        end


    end


end