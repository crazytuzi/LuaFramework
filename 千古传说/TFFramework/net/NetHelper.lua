local NetHelper = {}

function NetHelper.receive(nType , tTemp)
	TFDirector.nReciveCount = TFDirector.nReciveCount + 1
	print("###############receive success#############", string.format("0x%04x, 发送了%d条，接收第%d条",nType, TFDirector.nSendCount, TFDirector.nReciveCount));
	TFDirector:dispatchProtocolWith(nType, tTemp)
end

return NetHelper