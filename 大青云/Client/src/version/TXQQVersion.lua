--[[
腾讯
lizhuangzhuang
2016年1月16日17:30:21
]]

_G.TXQQVersion = BaseVersion:new(VersionConsts.TXQQ);

function TXQQVersion:OnStart()
	_G.gateServerAddress = _sys:getGlobal("gsAddress");
	_G.crossGateServerAddres = _sys:getGlobal("crossAddress");
	--
	MsgManager:RegisterCallBack(MsgType.WC_TXRecharge,self,self.OnTXRecharge);
	MsgManager:RegisterCallBack(MsgType.WC_TXOpenkeyOut,self,self.OnTXOpenKeyOut);
end

function TXQQVersion:IsHideMClient()
	return true;
end

function TXQQVersion:IsLianYun()
	return true;
end

function TXQQVersion:Login()
	local msg = ReqConnSrvTXMsg:new();
	msg.openid = _sys:getGlobal("openid");
	msg.openkey = _sys:getGlobal("openkey");
	msg.seqid = _sys:getGlobal("seqid");
	msg.pfkey = _sys:getGlobal("pfkey");
	msg.pf = _sys:getGlobal("pf");
	msg.serverid = toint(_sys:getGlobal("skey"));
	msg.version = _G.MsgBuildVersion
	msg.mac = _sys.macAddress
	msg.virtualIP = 0;
	MsgManager:Send(msg);
end

function TXQQVersion:Charge(amount)
	UIQQCharge:Show();
end

function TXQQVersion:TXCharge(payitem,goodsmeta)
	local msg = ReqTXRechargeMsg:new();
	msg.pfkey = _sys:getGlobal("pfkey");
	msg.payitem = payitem;
	msg.goodsmeta = goodsmeta;
	MsgManager:Send(msg);
end

function TXQQVersion:OnTXRecharge(msg)
	if msg.result ~= 0 then 
		print("充值错误,code:",msg.result);
		return; 
	end
	--todo mclient
	print(msg.url)
	_sys:invoke('fusion2_dialog_buy',msg.url)
end

function TXQQVersion:OnTXOpenKeyOut(msg)
	_sys:invoke("fusion2_relogin");
end