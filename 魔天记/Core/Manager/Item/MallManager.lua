MallManager = {}
local currentSelectItemInfo = nil
local mallLabelConfig = nil
local mallItems = nil
local currentBuyCount = 1
local insert = table.insert
local _sortfunc = table.sort
local storeConfig = nil
function MallManager.Init()
	currentSelectItemInfo = nil
	currentBuyCount = 1
	mallItems = {}
	mallLabelConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MALLLABEL)
end
-- items：{[id：编号,spId:物品id,op：原始价格,np:打折价格,st:限购类型,sn:限购剩余数量,ds:折扣标签,ri:消耗类型（元宝/绑定元宝）,vip:vip等级]}
function MallManager.SetItemDatas(data)
	if(data) then
		if(mallItems[data.t] == nil) then
			mallItems[data.t] = {}
		end
		
		if(data.t == 1) then
			mallItems[data.t] [data.k] = {}
			for k, v in ipairs(data.items) do
				local item = {}
				setmetatable(item, {__index = v})
				item.configData = {}
				setmetatable(item.configData, {__index = ProductManager.GetProductById(item.spId)})				 
				insert(mallItems[data.t] [data.k], item)
				
			end
			_sortfunc(mallItems[data.t] [data.k], function(a, b) return a.od < b.od end)
		else
			for k, v in ipairs(data.items) do
				local item = {}
				setmetatable(item, {__index = v})
				item.configData = {}
				setmetatable(item.configData, {__index = ProductManager.GetProductById(item.spId)})				 
				insert(mallItems[data.t], item)		
			end
			_sortfunc(mallItems[data.t], function(a, b) return a.od < b.od end)
		end
	end
end

function MallManager.GetItemDatas(t, kind)
	if(kind) then
		if(mallItems[t]) then
			return mallItems[t] [kind]
		else
			return {}
		end
	end
	
	return mallItems[t]
end

function MallManager.ResetItemDatas()
	mallItems = {}
end

function MallManager.GetCurrentSelectItemInfo()
	return currentSelectItemInfo
end

function MallManager.GetItemInfoById(t, k, id)
	local item = nil
	local ms = mallItems[t]
	if not ms then return item end
	if(t == 1) then
		for k, v in pairs(ms[k]) do
			if(v.id == id) then
				item = v
			end
		end
		
	elseif(t == 2) then
		for k, v in pairs(ms) do
			if(v.id == id) then
				return v
			end
		end
    elseif(t == 3) then
		for k, v in pairs(ms) do
			if(v.id == id) then
				return v
			end
		end
	end
	return item
end

function MallManager.SetCurrentSelectItemInfo(data)
	currentSelectItemInfo = data
	currentSelectCount = 0
end

function MallManager.SetCurrentBuyCount(v)
	currentBuyCount = v
end

function MallManager.GetCurrentBuyCount()
	return currentBuyCount
end

function MallManager.GetMallLabelConfig()
	return mallLabelConfig
end

function MallManager.GetStoreById(id)
	if not storeConfig then
		storeConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_STORE)
	end
	return storeConfig[id]
end
