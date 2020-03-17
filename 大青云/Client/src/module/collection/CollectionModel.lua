_G.CollectionModel = CollectionModel or {
	collectionList = {}
}

function CollectionModel:DeleteAllCollection()
	self.collectionList = {}
end

function CollectionModel:GetCollectionList()
	return self.collectionList
end

function CollectionModel:AddCollection(collection)
	self.collectionList[collection.cid] = collection
end

function CollectionModel:GetCollection(cid)
	return self.collectionList[cid]
end

function CollectionModel:GetCollectionByCfgId(cfgId)
	for index,collection in pairs (self.collectionList) do
		if collection.configId == cfgId then
			return collection
		end
	end
	
	return nil
end

function CollectionModel:GetActiveCollectionByCfgId(cfgId)
	for index, collection in pairs (self.collectionList) do
		if collection.configId == cfgId and not collection:GetCollectionState() then
			return collection
		end
	end
	return nil
end

function CollectionModel:DeleteCollection(collection)
	self.collectionList[collection.cid] = nil
end

function CollectionModel:GetCollectionNum()
	local count = 0;
	for _, v in pairs(self.collectionList) do
		if v ~= nil then
			count = count + 1;
		end
	end
	return count;
end