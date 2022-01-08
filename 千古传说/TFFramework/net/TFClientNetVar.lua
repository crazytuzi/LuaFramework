local netOp = require("TFFramework.net.TFClientNetVarOp")
if tblVarS2CData then
	return require("TFFramework.net.TFClientNetVar")
end
tblVarS2CData = {}
tblVarC2SData = {}

local net = {}
setmetatable(net , netOp)

net.recvHeadFunc = nil
net.sendHeadFunc = nil
net.errorCallback = nil

function net.RecvCallback(nRet)
	if nRet <= 0 then
		print("net Recv error nRet = " , nRet);
		return ;
	end

	TFFunction.call(net.recvHeadFunc, net)
	nProtoType = netOp.UnpackType()
	if tblVarS2CData[nProtoType] == nil then
		print("[error]no this protocol " , string.format("0x%04x",nProtoType))
	else
		netOp.RecvData(nProtoType , tblVarS2CData[nProtoType]());
	end
end

function net.ConnectCallback(nRet)
	print("ConnectCallback ",nRet)
end

function net.CloseCallback(nRet)
	print("CloseCallback ",nRet)
end

function net.ErrorHandle(pData)
	if pData == 'msg0' then
		TFDirector:dispatchGlobalEventWith(TFSESSION_TIMEOUT)
	end

	if type(net.errorCallback) == 'function' then
		net.errorCallback(pData)
	end
end

function net:Send(nType , tblData , bEncrypteByRsa)
	TFFunction.call(net.sendHeadFunc, net)
	netOp.PackType(nType)
	netOp.setErrorHandle(net.ErrorHandle)
	netOp.SendData(tblVarC2SData[nType]() , tblData,nType,bEncrypteByRsa)
end

function net:Connect(szIp , nPort, ConnectCallback, RecvCallback, CloseCallback , bType)
	if bType then
		netOp:setConnectType(bType)
	end
	ConnectCallback = ConnectCallback or net.ConnectCallback
	RecvCallback = RecvCallback or net.RecvCallback
	CloseCallback = CloseCallback or net.CloseCallback
	return netOp.Connect(szIp , nPort , ConnectCallback , RecvCallback , CloseCallback)
end

function net:SetEncodeKeys(tblInt , bEncode)--true Encode , false Decode , nil Both
	if bEncode == nil then
		netOp.SetEncodeKeys(tblInt , true)
		netOp.SetEncodeKeys(tblInt , false)
	else
		netOp.SetEncodeKeys(tblInt , bEncode)
	end
end

function net:SetDecodeKeys(tblInt)
	return netOp.SetEncodeKeys(tblInt , false)
end

function net.createStruct(nProtoType, tblRecv)-- stream server to client packet
	local tblStruct
	tblProtoData = tblVarS2CData[nProtoType]()
	if tblProtoData == nil then
		print("can't find the code :" , nProtoType)
	else
		local tblName = tblProtoData[3]
		tblStruct = netOp.PackStruct(tblName , tblRecv)
	end
	return tblStruct
end

function net:setRecvSerialize(bSerialize)
	netOp.bRecvSerialize = bSerialize
end

function net:setSendSerialize(bSerialize)
	netOp.bSendSerialize = bSerialize
end

function net:setRecvCallBack(funcCallBack)
	netOp.funcRecvData = funcCallBack
end

function net:setErrorCallBack(functionCallBack)
	netOp.errorCallback = functionCallBack
end

return net