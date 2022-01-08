local netop = {
				bRecvSerialize	= true,
				bSendSerialize	= false ,
				funcRecvData	= nil}
local InsClientNet = TFClientSocket:GetInstance()
local tblUnpackFunc = 0
local tblPackFunc = 0

function netop:setConnectType(nType) --0 long ,1 short
	if nType == 0 then
		InsClientNet:setNetType(0)
	else
		InsClientNet:setNetType(1)
	end
end

function netop:setMaxCloseSec(nSec)
	InsClientNet:setMaxCloseSec(nSec)
end
-----数据序列化---------begin
function netop.PackSubStruct(tblName , tblData)
	local tblSubStruct	= {}
	local bMulTable		= tblName[1]
	local tblName		= tblName[2]
	local szName		= 0
	local i				= 0
	local k				= 0
--	table.remove(tblName , 1)
	if bMulTable == false then
		for i = 2 , #tblName do
			szName = netop.GetValueName(tblName[i])
			tblSubStruct[szName] = netop.PackSingleValue(tblName[i] , tblData[i - 1])
		end
	else
		for i = 1 , #tblData do
			local tblTemp = {}
			for k = 2 , #tblName do
				szName = netop.GetValueName(tblName[k])
				tblTemp[szName] = netop.PackSingleValue(tblName[k] , tblData[i][k - 1])
			end
			table.insert(tblSubStruct , tblTemp)
		end
	end
	return tblSubStruct
end

function netop.PackSingleValue(tblName , tblData)
	local tblPack = {}
	if tblData == NULL then
		tblPack = nil
	elseif type(tblName) == 'table' then
		tblPack = netop.PackSubStruct(tblName , tblData)
	else
		tblPack = tblData
	end
	return tblPack
end

function netop.GetValueName(tblName)
	if type(tblName) == 'table' then
		return tblName[2][1]
	end
	return tblName
end

function netop.PackStruct(tblName , tblData)
	local tblStruct = {}
	local szName	= 0
	for i = 1 , #tblName do
		szName = netop.GetValueName(tblName[i])
		tblStruct[szName] = netop.PackSingleValue(tblName[i] , tblData[i])
	end
	return tblStruct;
end
-----数据序列化---------end


function netop.SetEncodeKeys(tblInt , bEncode)
	return InsClientNet:SetEncodeKeys(tblInt[1],tblInt[2],tblInt[3],tblInt[4],tblInt[5],tblInt[6],tblInt[7],tblInt[8] , bEncode)
end

function netop.UnpackType()
	return InsClientNet:UnpackType()
end

function netop.UnpackInt()
	return InsClientNet:UnpackInt()
end

function netop.UnpackShort()
	return InsClientNet:UnpackShort()
end

function netop.UnpackByte()
	return InsClientNet:UnpackByte()
end

function netop.UnpackHeadInt()
	return InsClientNet:UnpackHeadInt()
end

function netop.UnpackString()
	local nLen = InsClientNet:UnpackIntVar32()
	local s = ""
	if nLen ~= 0 then
		s = InsClientNet:UnpackString(nLen)
	end
	return s
end

function netop.UnpackStringNoLen()
	return InsClientNet:UnpackString()
end

function netop.UnpackIntVar32()
	return InsClientNet:UnpackIntVar32()
end

function netop.UnpackSIntVar32()
	return InsClientNet:UnpackSIntVar32()
end

function netop.UnpackBool()
	local bRet = InsClientNet:UnpackIntVar32()
	if bRet == 0 then
		return false
	else
		return true
	end
end


function netop.UnpackIntVar64()
	return InsClientNet:UnpackIntVar64()
end

function netop.UnpackFloat()
	return InsClientNet:UnpackFloat()
end

function netop:CloseSocket()
	InsClientNet:CloseSocket()
end

function netop.Connect(szIp , nPort , connectHandle , receiveHandle , closeHandle)
	return InsClientNet:Connect(szIp, nPort,connectHandle,receiveHandle,closeHandle)
end


function netop.PreUnpackByte()
	return InsClientNet:PreUnpackTagType()
end

function netop.PreUnpackIntVar32()
	return InsClientNet:PreUnpackWiretype()
end

function netop.GetReadPacketSize()
	return InsClientNet:GetReadPacketSize()
end
local tblTypeNum = {
		["n1"]	= 0,
		["n2"]	= 0,
		["n4"]	= 0,
		["s"]	= 2,
		["a"]	= 2,
		['v4']	= 0,
		['v8']	= 0,
		["av4"]	= 2,
		["av8"] = 2,
		["an1"]	= 2,
		['t']	= 2,
		['ts']	= 2,
		['tv4'] = 0,
		['tv8'] = 0,
		['pv4'] = 2,
		['pv8'] = 2,
		["srsa"]= 2,
		['f4']	= 5,
		['b']	= 0,
		['sv4'] = 0,
		}



function netop.TypeCount(nIndex , szType)
	local nType = 0
	if type(szType) == "table" then
		nType = tblTypeNum['t']
	else
		nType = tblTypeNum[szType]
	end
	return (nIndex * 8 + nType)
end



function netop.UnpackArray(szType)
	local tblArray = {}
	local szSubType = string.sub(szType,2,-1)
	local nLen = netop.UnpackIntVar32()
	for i = 1 , nLen do
		table.insert(tblArray , tblUnpackFunc[szSubType]())
	end
	return tblArray
end

function netop.UnpackTable(tblData , nTagType , nLimitLen)
	local tblRecv = {}
	local bMulTable = tblData[1]
	local tblData = tblData[2]
	local nLastLen = netop.GetReadPacketSize()

	while netop.PreUnpackIntVar32() == nTagType do
		local nLen = nil
		if #tblData > 1 or bMulTable == false then-- no repeat msg
			netop.UnpackIntVar32()--wire type
			nLen = netop.UnpackIntVar32()--single list length
		elseif #tblData == 1 and type(tblData[1]) == 'table' then -- repeated include only one repeated
			netop.UnpackIntVar32()--wire type
			nLen = netop.UnpackIntVar32()--single list length
		end
		local tblSubRecv = {}
		for i = 1 , #tblData do
			local nTempLen = netop.GetReadPacketSize()
			tblSubRecv[i] = netop.UnpackSingleVaule(tblData , i , nLen)
			if nLen then
				nLen = nLen - (nTempLen - netop.GetReadPacketSize())
			end
		end

		if bMulTable == true then
			table.insert(tblRecv , tblSubRecv)
		else
			tblRecv = tblSubRecv
			break;
		end

		if nLastLen and nLimitLen and nLastLen - netop.GetReadPacketSize() == nLimitLen then
			break;
		end
	end
	return tblRecv
end

function netop.UnpackRepeatInt(szData , nIndex)
	local tblArray = {}
	local szSubType = string.sub(szData , 2 , -1)
	while netop.PreUnpackIntVar32() == netop.TypeCount(nIndex , szSubType) do
		netop.UnpackIntVar32()
		table.insert(tblArray , tblUnpackFunc[szSubType]())
	end
	return tblArray
end

function netop.UnpackRepeatIntPacked(szData)
	local nLen		 = netop.UnpackIntVar32()
	local nPacketLen = netop.GetReadPacketSize();
	local tblArray	 = {}
	local szType	 = string.sub(szData , 2 , -1)
	while nPacketLen - netop.GetReadPacketSize() < nLen do
		table.insert(tblArray,tblUnpackFunc[szType]())
	end
	return tblArray;
end



tblUnpackFunc = {
				n1	 = netop.UnpackByte ,
				n2	 = netop.UnpackShort ,
				n4	 = netop.UnpackInt,
				s	 = netop.UnpackString,
				v4 	 = netop.UnpackIntVar32,
				v8 	 = netop.UnpackIntVar64,
				av4  = netop.UnpackArray,
				av8	 = netop.UnpackArray,
				an1	 = netop.UnpackArray,
				t 	 = netop.UnpackTable,
				ts	 = netop.UnpackRepeatInt,
				tv4	 = netop.UnpackRepeatInt,
				tv8	 = netop.UnpackRepeatInt,
				pv4	 = netop.UnpackRepeatIntPacked,
				pv8	 = netop.UnpackRepeatIntPacked,
				f4	 = netop.UnpackFloat,
				b	 = netop.UnpackBool,
				sv4  = netop.UnpackSIntVar32,
				
				}

function netop.UnpackSingleVaule(tblData , i , nLimitLen)
	local tblRecv	= 0
	local tblSubData= tblData[i]
	local nType	= netop.PreUnpackIntVar32();
	local nCurType	= netop.TypeCount(i , tblSubData)
	if nType == nCurType then
		if type(tblSubData) == "table" then
			tblRecv = tblUnpackFunc['t'](tblSubData , nType , nLimitLen)
		else
			if string.sub(tblSubData , 1, 1) ~= 't' then
				netop.UnpackIntVar32();
			end
			tblRecv = tblUnpackFunc[tblSubData](tblSubData , i);
		end
	else
		if math.floor(nType/8.0) == math.floor(nCurType/8.0) then
			print("[error]not the same type at " , i , tblSubData , tblData)
		end
		tblRecv = NULL
	end
	return tblRecv
end

function netop.RecvData(nProtoType , tblProtoData)
	local tblRecv = {}
	local tblCB = tblProtoData[1]
	local tblData = tblProtoData[2]
	local tblName = tblProtoData[3]
	for i = 1, #tblData do
		tblRecv[i] = netop.UnpackSingleVaule(tblData , i)
	end
	local h = require('TFFramework.'..tblCB[1])
	local funcCallBack = nil
	if h == nil then
		funcCallBack = _G[tblCB[2]]
	else
		funcCallBack = h[tblCB[2]]
	end

	if netop.bRecvSerialize then
		tblRecv = netop.PackStruct(tblName , tblRecv)
	end
	if netop.funcRecvData then
		funcCallBack = netop.funcRecvData
	end
	funcCallBack(nProtoType , tblRecv)
end

--------------------------------------------------------------------Send
function netop.Send(bRsa)
	if bRsa then
		return InsClientNet:Send(bRsa)
	else
		return InsClientNet:Send()
	end
end

function netop.GetWritePacketSize()
	return InsClientNet:GetWritePacketSize();
end


function netop.PacketBufInsert(nNum , nIndex)
	return InsClientNet:PacketBufInsert(nNum , nIndex)
end

function netop.SubPack()
	return InsClientNet:SubPack()
end
function netop.PackType(nNum)
	return InsClientNet:PackType(nNum)
end

function netop.PackInt(nNum)
	return InsClientNet:PackInt(nNum)
end

function netop.PackShort(nNum)
	return InsClientNet:PackShort(nNum)
end

function netop.PackByte(nNum)
	return InsClientNet:PackByte(nNum)
end

function netop.PackHeadInt(nNum)
	return InsClientNet:PackHeadInt(nNum)
end

function netop.PackString(szStr)
	InsClientNet:PackIntVar32(#szStr)
	InsClientNet:PackString(szStr , #szStr)
end

function netop.PackStringByRsa(szStr)
	InsClientNet:PackStringByRsa(szStr , #szStr)
end

function netop.PackIntVar32(nNum)
	return InsClientNet:PackIntVar32(nNum)
end

function netop.PackIntVar64(nNum)
	return InsClientNet:PackIntVar64(nNum)
end

function netop.PackSIntVar32(nNum)
	return InsClientNet:PackSIntVar32(nNum)
end

function netop.PackBool(nNum)
	if nNum then
		nNum = 1
	else
		nNum = 0
	end
	return InsClientNet:PackIntVar32(nNum)
end

function netop.PackFloat(nNum)
	return InsClientNet:PackFloat(nNum)
end

function netop.PackEncytpeByRsa()
	return InsClientNet:PackEncytpeByRsa()
end

function netop.PackArray(tblData , szType)
	local nLen = #tblData
	if nLen <=0 then
		print("PackArray nLen errr, ",nLen)
		return nil
	end
	local nPreSize = netop.GetWritePacketSize()
	local szSubType = string.sub(szType,2,-1)
	for i = 1 , nLen do
		tblPackFunc[szSubType](tblData[i])
	end
	netop.PacketBufInsert(netop.GetWritePacketSize() - nPreSize, nPreSize)--single list length
end

function netop.PackSingleElement(tblData , tblType , nType)
	for k = 1 , #tblData do
		netop.PackIntVar32(nType)--wire type
		for i = 1, #tblType do
			local nSubType = netop.TypeCount(i , tblType[i])
			if type(tblType[i]) == "table" then
				tblPackFunc['t'](tblData[k][i],tblType[i] , nSubType)
			else
				if string.sub(tblType[i] , 1, 1) ~= 't' then
					tblPackFunc[tblType[i]](tblData[k][i],tblType[i])
				else
					tblPackFunc[tblType[i]](tblData[k][i],tblType[i] , nSubType)
				end
			end
		end
	end
end


function netop.PackTable(tblData , tblType , nType)
	local bMulTable = tblType[1]
	local tblType = tblType[2]
	if bMulTable == true then
		if #tblType == 1 then--{an1}
			netop.PackSingleElement(tblData ,tblType , nType)
			return
		else--{sub msg repeat}
			for k = 1 , #tblData do
				netop.PackIntVar32(nType)--wire type
				local nPreSize = netop.GetWritePacketSize()
				netop.PackSubTable(tblData[k] , tblType)
				netop.PacketBufInsert(netop.GetWritePacketSize() - nPreSize, nPreSize)--single list length
			end
		end
	else-- submsg no repeat
		netop.PackIntVar32(nType)--wire type
		local nPreSize = netop.GetWritePacketSize()
		netop.PackSubTable(tblData , tblType , true)
		netop.PacketBufInsert(netop.GetWritePacketSize() - nPreSize, nPreSize)--single list length
	end
end

function netop.PackSubTable(tblData , tblType , bNoRepeat)
	for i = 1, #tblType do
		if tblData[i] ~= NULL then
			local nSubType = netop.TypeCount(i , tblType[i])
			if type(tblType[i]) == "table" then
				tblPackFunc['t'](tblData[i],tblType[i] ,nSubType)
			else
				if string.sub(tblType[i] , 1, 1) ~= 't' then
					if #tblType > 1 or bNoRepeat then
						netop.PackIntVar32(nSubType)
					end
					tblPackFunc[tblType[i]](tblData[i],tblType[i])
				else
					tblPackFunc[tblType[i]](tblData[i],tblType[i] , nSubType)
				end
			end
		end
	end
end

function netop.PackRepeatInt(tblData ,szType, nType)
	local tblArray = {}
	local szSubType = string.sub(szType , 2 , -1)
	for i = 1 , #tblData do
		netop.PackIntVar32(nType)
		tblPackFunc[szSubType](tblData[i])
	end
end

function netop.PackRepeatIntPacked(tblData , szType)
	local nLen		 = netop.UnpackIntVar32()
	local nPacketLen = netop.GetWritePacketSize();
	local szSubType	 = string.sub(szType , 2 , -1)
	for i = 1 , #tblData do
		tblPackFunc[szSubType](tblData[i])
	end
	netop.PacketBufInsert(netop.GetWritePacketSize() - nPacketLen , nPacketLen)--single list length
	return tblArray;
end

tblPackFunc   = {
				n1	 = netop.PackByte ,
				n2	 = netop.PackShort ,
				n4	 = netop.PackInt,
				s	 = netop.PackString,
				srsa = netop.PackStringByRsa,
				v4 	 = netop.PackIntVar32,
				v8 	 = netop.PackIntVar64,

				av4  = netop.PackArray,
				av8	 = netop.PackArray,
				an1  = netop.PackArray,
				t 	 = netop.PackTable,
				ts	 = netop.PackRepeatInt,
				tv4	 = netop.PackRepeatInt,
				tv8	 = netop.PackRepeatInt,
				pv4	 = netop.PackRepeatIntPacked,
				pv8	 = netop.PackRepeatIntPacked,
				f4	 = netop.PackFloat,
				b	 = netop.PackBool,
				sv4  = netop.PackSIntVar32,
}

function netop.UnpackSingleValue(tblName , tblData)
	local valData = {}
	if tblData == nil then
		valData = NULL
	elseif type(tblName) == 'table' then
		valData = netop.UnpackSubStruct(tblName , tblData)
	else
		valData = tblData
	end
	return valData
end

function netop.UnpackSubStruct(tblName , tblData)
	local tblSubStruct	= {}
	local bMulTable		= tblName[1]
	local tblName		= tblName[2]
	local szName		= 0
	local i				= 0
	local k				= 0

	if bMulTable == false then
		for i = 2 , #tblName do
			szName = netop.GetValueName(tblName[i])
			tblSubStruct[i - 1] = netop.UnpackSingleValue(tblName[i] , tblData[szName])
		end
	else
		for i = 1 , #tblData do
			local tblTemp = {}
			for k = 2 , #tblName do
				szName = netop.GetValueName(tblName[k])
				tblTemp[k - 1] = netop.UnpackSingleValue(tblName[k] , tblData[i][szName])
			end
			table.insert(tblSubStruct , tblTemp)
		end
	end
	return tblSubStruct
end

function netop.UnpackStruct(tblName , tblData)
	local tblStruct = {}
	local szName 	= 0
	for i = 1 , #tblName do
		szName = netop.GetValueName(tblName[i])
		tblStruct[i] =  netop.UnpackSingleValue(tblName[i] , tblData[szName])
	end
	return tblStruct
end

function netop.SendData(tblType , tblData , nProtoType , bEncrypteByRsa)
	local tblName	= tblType[3]
	local tblType	= tblType[2]

--	netop.UnpackStruct(tblName , tblData)
	if netop.bSendSerialize then
		tblData = netop.UnpackStruct(tblName , tblData)
	end
	if #tblData < #tblType then
		print("Send Packet Data not long enough")
		return nil
	end
	for i = 1, #tblData do
		if tblData[i] ~= NULL then
			local nType = netop.TypeCount(i , tblType[i])
			if type(tblType[i]) == "table" then
				tblPackFunc['t'](tblData[i],tblType[i] , nType)
			else
				if string.sub(tblType[i] , 1, 1) ~= 't' then
					netop.PackIntVar32(nType)
					tblPackFunc[tblType[i]](tblData[i],tblType[i])
				else
					tblPackFunc[tblType[i]](tblData[i],tblType[i] , nType)
				end
			end
		end
	end
	if bEncrypteByRsa then
		netop.PackEncytpeByRsa()
	end
	netop.Send()
end

function netop:SetNetLogEnable(bEnable)
	InsClientNet:SetNetLogEnable(bEnable)
end

function netop:getTotFlow()
	return InsClientNet:getTotFlow()
end

function netop:setMaxConnectSec(nSec)
	InsClientNet:setMaxConnectSec(nSec);
end

function netop:setEncodeEnable(bEnable)
	InsClientNet:setEncodeEnable(bEnable)
end

netop.__index = netop;
return netop
