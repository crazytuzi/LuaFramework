module(..., package.seeall)

--GS2C--

function GS2CWareHouseInfo(pbdata)
	local size = pbdata.size --仓库的数目
	local namelist = pbdata.namelist --名字列表
	--todo
end

function GS2CRefreshWareHouse(pbdata)
	local wid = pbdata.wid
	local name = pbdata.name
	local itemdata = pbdata.itemdata --道具信息
	--todo
end

function GS2CWareHouseName(pbdata)
	local wid = pbdata.wid
	local name = pbdata.name
	--todo
end

function GS2CAddWareHouseItem(pbdata)
	local wid = pbdata.wid
	local itemdata = pbdata.itemdata
	--todo
end

function GS2CDelWareHouseItem(pbdata)
	local wid = pbdata.wid
	local itemid = pbdata.itemid --道具
	--todo
end

function GS2CWHItemArrange(pbdata)
	local wid = pbdata.wid --仓库id
	local pos_info = pbdata.pos_info
	--todo
end

function GS2CWHItemAmount(pbdata)
	local wid = pbdata.wid
	local itemid = pbdata.itemid
	local amount = pbdata.amount
	--todo
end


--C2GS--

function C2GSSwitchWareHouse(wid)
	local t = {
		wid = wid,
	}
	g_NetCtrl:Send("warehouse", "C2GSSwitchWareHouse", t)
end

function C2GSBuyWareHouse()
	local t = {
	}
	g_NetCtrl:Send("warehouse", "C2GSBuyWareHouse", t)
end

function C2GSRenameWareHouse(wid, name)
	local t = {
		wid = wid,
		name = name,
	}
	g_NetCtrl:Send("warehouse", "C2GSRenameWareHouse", t)
end

function C2GSWareHouseWithStore(wid, itemid)
	local t = {
		wid = wid,
		itemid = itemid,
	}
	g_NetCtrl:Send("warehouse", "C2GSWareHouseWithStore", t)
end

function C2GSWareHouseWithDraw(wid, pos)
	local t = {
		wid = wid,
		pos = pos,
	}
	g_NetCtrl:Send("warehouse", "C2GSWareHouseWithDraw", t)
end

function C2GSWareHouseArrange(wid)
	local t = {
		wid = wid,
	}
	g_NetCtrl:Send("warehouse", "C2GSWareHouseArrange", t)
end

