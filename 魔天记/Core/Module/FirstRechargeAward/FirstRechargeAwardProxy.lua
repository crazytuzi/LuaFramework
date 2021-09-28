require "Core.Module.Pattern.Proxy"

FirstRechargeAwardProxy = Proxy:New();

FirstRechargeAwardProxy.MESSAGE_GETAWARD_COMPLETE = "MESSAGE_GETAWARD_COMPLETE";

function FirstRechargeAwardProxy:OnRegister()
    
      SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetFirstRechargeAward, FirstRechargeAwardProxy.GetFirstRechargeAwardResult);

end

function FirstRechargeAwardProxy:OnRemove()
 
     SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetFirstRechargeAward, FirstRechargeAwardProxy.GetFirstRechargeAwardResult);

end


function FirstRechargeAwardProxy.GetFirstRechargeAwardResult(cmd, data)
    if (data.errCode == nil) then
    	VIPManager.my_fr = data.fr;
    	VIPManager.my_fr2 = data.fr2;
		MessageManager.Dispatch(FirstRechargeAwardProxy, FirstRechargeAwardProxy.MESSAGE_GETAWARD_COMPLETE);
    	MessageManager.Dispatch(MainUINotes, MainUINotes.ENV_REFRESH_SYSICONS);
    end
end


function FirstRechargeAwardProxy.TryGetFirstRechargeAward()

   
    SocketClientLua.Get_ins():SendMessage(CmdType.GetFirstRechargeAward, { });

end


function FirstRechargeAwardProxy.TestPlayRMB(num)
  
   SocketClientLua.Get_ins():SendMessage(CmdType.GmCmd, {cmd="pay "..num });

end

-- pay rmb 