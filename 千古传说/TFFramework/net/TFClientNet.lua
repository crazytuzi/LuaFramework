local netOp = require("TFFramework.net.TFClientNetOp")
if tblS2CData then
	return require("TFFramework.net.TFClientNet")
end

tblS2CData = tblS2CData or {}
tblC2SData = tblC2SData or {}

local net = {}
setmetatable(net , netOp)

net.recvHeadFunc = nil
net.sendHeadFunc = nil

function net.RecvCallback(nRet)
	if nRet <= 0 then
		print("net Recv error nRet = " , nRet);
		return ;
	end

	nProtoType = netOp.UnpackType()
	TFFunction.call(net.recvHeadFunc, net , nProtoType)
	if tblS2CData[nProtoType] == nil then
		print("[error]no this protocol " , string.format("0x%04x",nProtoType))
	else
		netOp.RecvData(nProtoType , tblS2CData[nProtoType]());
	end
end

function net.ConnectCallback(nRet)
	print("ConnectCallback ",nRet)
end

function net.CloseCallback(nRet)
	print("CloseCallback ",nRet)
end

function net:Send(nType , tblData , bEncrypteByRsa)
	netOp.PackType(nType)
	TFFunction.call(net.sendHeadFunc, net , nType)
	netOp.SendData(tblC2SData[nType]() , tblData,nType,bEncrypteByRsa)
end

function net:Connect(szIp , nPort, ConnectCallback, RecvCallback, CloseCallback , bType)
	bType = bType or 0
	netOp:setConnectType(bType)
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
	tblProtoData = tblS2CData[nProtoType]()
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

function net:SetNetLogEnable(bEnable)
	netOp:SetNetLogEnable(bEnable)
end

return net