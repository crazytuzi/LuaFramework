module(..., package.seeall)

--GS2C--

function GS2CTestBigPacket(pbdata)
	local is_change = pbdata.is_change
	local s = pbdata.s
	--todo
	print("GS2CTestBigPacket", is_change, string.len(s))
	IOTools.SaveByteFile(IOTools.GetPersistentDataPath("/data"), s)	
	C_api.Utils.LoadDataPackage()

	for k, v in pairs (data) do
		local name = "logic.data."..k
		package.loaded[name] = nil
		package.preload[name] = nil
		data[k] = nil
	end
end

function GS2CTestOnlineUpdate(pbdata)
	local a = pbdata.a
	local b = pbdata.b
	local c = pbdata.c
	local d = pbdata.d
	local e = pbdata.e
	--todo
end

function GS2CTestOnlineAdd(pbdata)
	local a = pbdata.a
	--todo
end

function GS2CTestEncode(pbdata)
	local a = pbdata.a
	local b = pbdata.b
	--todo
end

function GS2CTestNotice(pbdata)
	local notices = pbdata.notices
	--todo
	local list = {}
	for i, notice in ipairs(notices) do
		local d = {}
		d.id = os.time() + i
		d.title = notice.title
		d.content = notice.content
		d.hot = notice.hot or 3
		table.insert(list, d)
	end
	g_LoginCtrl:SetNoticeList(list)
	CLoginNoticeView:ShowView()
end

function GS2CCheckProxy(pbdata)
	local record = pbdata.record
	--todo
end

function GS2CCheckProxyMerge(pbdata)
	local record_list = pbdata.record_list
	--todo
end


--C2GS--

function C2GSTestBigPacket(s)
	local t = {
		s = s,
	}
	g_NetCtrl:Send("test", "C2GSTestBigPacket", t)
end

function C2GSTestOnlineAdd()
	local t = {
	}
	g_NetCtrl:Send("test", "C2GSTestOnlineAdd", t)
end

function C2GSCheckProxy(record, type)
	local t = {
		record = record,
		type = type,
	}
	g_NetCtrl:Send("test", "C2GSCheckProxy", t)
end

