SaleManager = {}
local saleConfig = {}
local saleConfigData = {}
local saleData = {}
local selectType = 0
local selectKind = 0
local mySaleData = {}
local recordData = {}
local curSelectItem = nil
local MaxGroundingCount = 20
local insert = table.insert
local _sortfunc = table.sort
local saleMoney = 0
SaleManager.SALEMONEYCHANGE = "SALEMONEYCHANGE"

function SaleManager.Init()
	saleConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SALE)
	local temp = {}
	saleConfigData = {}
	saleData = {}
	mySaleData = {}
	recordData = {}
	curSelectItem = nil
	saleMoney = 0
	for k, v in pairs(saleConfig) do
		local t = v["type"]
		local item = {}
		if(temp[t] == nil) then
			temp[t] = {}
			temp[t].name = v.type_name
			temp[t].t = t
			temp[t].datas = {}
		end
		
		if(temp[t].datas[v.kind] == nil) then
			temp[t].datas[v.kind] = {}
			temp[t].datas[v.kind].k = v.kind
			temp[t].datas[v.kind].name = v.kind_name
		end
	end
	
	for k, v in pairs(temp) do
		local item = ConfigManager.Clone(v)
		local datas = {}
		for k1, v1 in pairs(item.datas) do
			insert(datas, v1)
		end
		item.datas = datas
		insert(saleConfigData, item)
	end
end

function SaleManager.SetSaleMoney(value)
	if(value) then
		saleMoney = value
	end
end

function SaleManager.GetCanGetSaleMoney()
	return saleMoney > 0
end

--是否有上架物品已过期
function SaleManager.IsSomethingOvertime()
	local result = false
	if(mySaleData and #mySaleData > 0) then
		local time = GetTimeMillisecond()		
		for k, v in ipairs(mySaleData) do
			if(time > v.et) then
				result = true
				break
			end			
		end
	end
	
	return result
end

function SaleManager.GetRedPoint()
	return SaleManager.GetCanGetSaleMoney() or SaleManager.IsSomethingOvertime()
end

function SaleManager.GetMaxGroundingCount()
	return MaxGroundingCount
end


function SaleManager.GetConfigData()
	return saleConfigData
end

function SaleManager.SetCurSelectType(t)
	selectType = t
end

function SaleManager.GetCurSelectType()
	return selectType
end

function SaleManager.SetCurSelectKind(k)
	selectKind = k
end

function SaleManager.GetCurSelectKind()
	return selectKind
end

function SaleManager.GetSaleData(t, k)
	return saleData[t] [k]
end

function SaleManager.SetSaleData(t, kind, data)
	if(saleData == nil) then
		saleData = {}
	end
	
	if(saleData[t] == nil) then
		saleData[t] = {}
	end
	saleData[t] [kind] = {}
	for k, v in ipairs(data) do
		local item = {}
		--        item.id = v.id
		item.spId = v.spId
		item.configData = ProductManager.GetProductById(item.spId)
		item.price = v.price
		item.num = v.num
		
		insert(saleData[t] [kind], 1, item)
	end
end

function SaleManager.GetCurSaleList()
	return SaleManager.GetSaleData(selectType, selectKind)
end

function SaleManager.GetSaleDataByPriceAndSpId(spId, price)
	for k, v in pairs(saleData) do
		for k1, v1 in pairs(v) do
			for k2, v2 in pairs(v1) do
				if(spId == v2.spId and price == v2.price) then
					return v2
				end
			end
		end
	end
end

function SaleManager.RemoveSaleDataByPriceAndSpId(spId, price)
	for k, v in pairs(saleData) do
		for k1, v1 in pairs(v) do
			for k2, v2 in pairs(v1) do
				if(spId == v2.spId and price == v2.price) then
					table.remove(v1, k2)
				end
			end
		end
	end
end

function SaleManager.GetMySaleCountText()
	if(mySaleData) then
		return table.getCount(mySaleData) .. "/" .. MaxGroundingCount
	end
	return "0/" .. MaxGroundingCount
end

function SaleManager.SetMySaleData(data)
	if(data) then
		mySaleData = {}
		for k, v in ipairs(data.l) do
			local item = {}
			item.id = v.id
			item.spId = v.spId
			item.configData = ProductManager.GetProductById(item.spId)
			item.price = v.price
			item.num = v.num
			item.et = v.et
			insert(mySaleData, item)
		end
		SaleManager.SortMySaleData()
	end
end

function SaleManager.InsertMySaleData(v)
	local item = {}
	item.id = v.id
	item.spId = v.spId
	item.configData = ProductManager.GetProductById(item.spId)
	item.price = v.price
	item.num = v.num
	item.et = v.et
	insert(mySaleData, item)
	SaleManager.SortMySaleData()
	
end

function SaleManager.SortMySaleData()
	if(mySaleData and table.getCount(mySaleData) > 1) then
		_sortfunc(mySaleData, SaleManager.MySaleCampare)
	end
end

function SaleManager.MySaleCampare(a, b)
	return a.et > b.et
end

function SaleManager.RemoveMyGroungdingDataById(id)
	for k, v in pairs(mySaleData) do
		if(v.id == id) then
			table.remove(mySaleData, k)
		end
	end
	
end

function SaleManager.GetMyGroudingDataById(id)
	for k, v in pairs(mySaleData) do
		if(v.id == id) then
			return v
		end
	end
end


function SaleManager.GetMySaleData()
	return mySaleData
end

function SaleManager.GetMySaleDataCount()
	if(mySaleData) then
		return table.getCount(mySaleData)
	end
	return 0
end

function SaleManager.SetSaleRecordData(data)
	SaleManager.SetSaleGold(data.gold)
	SaleManager.SetSaleRecord(data.l)
end


function SaleManager.GetSaleRecordData()
	--    local temp = { }
	--    temp.gold = 100
	--    temp.record = { }
	--    temp.record[1] = { }
	--    temp.record[1].num = 100
	--    temp.record[1].configData = ProductManager.GetProductById(301000)
	--    return temp
	return recordData
end

function SaleManager.SetSaleGold(gold)
	if(gold) then
		recordData.gold = gold
	end
end

function SaleManager.SetSaleRecord(record)
	recordData.record = {}
	if(record) then
		for k, v in ipairs(record) do
			local item = {}
			item.num = v.num
			item.t = v.add_time
			item.configData = ProductManager.GetProductById(v.spId)
			insert(recordData.record, item)
		end
		if(table.getCount(recordData.record) > 1) then
			_sortfunc(recordData.record, function(a, b) return a.t > b.t end)
		end
	end
	
end

function SaleManager.SetCurSelectItem(v)
	curSelectItem = v
end

function SaleManager.GetCurSelectItem()
	return curSelectItem
end 