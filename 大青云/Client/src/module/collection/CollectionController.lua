_G.CollectionController = setmetatable({}, {__index = IController})
CollectionController.name = "CollectionController"
CollectionController.currCollection = nil

function CollectionController:Create()
	CControlBase:RegControl(self, true)
	CPlayerControl:AddPickListen(self)
	self.bCanUse = true
	MsgManager:RegisterCallBack(MsgType.SC_CollectionState, self, self.OnCollectionState)
	return true
end

function CollectionController:Update(interval)
	local collectionList = CollectionModel:GetCollectionList()
	if collectionList then
		for cid, collection in pairs(collectionList) do
			if collection then
				collection:Update(interval)
			end
		end
	end
	return true
end

function CollectionController:Destroy()
	return true
end

function CollectionController:OnEnterGame()
	return true
end

function CollectionController:OnChangeSceneMap()
	CollectionModel:DeleteAllCollection()
	return true
end

function CollectionController:OnLeaveSceneMap()
	CollectionModel:DeleteAllCollection()
	return true
end

function CollectionController:OnDead()

end

function CollectionController:OnPosChange(newPos)

end

function CollectionController:OnMouseWheel()
	
end

function CollectionController:OnBtnPick(button, type, node)
	self:OnMouseClick(node)
end

function CollectionController:OnRollOver(type, node)
	self:OnMouseOver(node)
end

function CollectionController:OnRollOut(type, node)
	self:OnMouseOut(node)
end

function CollectionController:OnMouseOut(node)
	if node == nil then return; end;
    local cid = node.cid
	local collection = CollectionModel:GetCollection(cid)
	if collection and collection.__type and collection.__type == "collection" then
		self:MouseOut(collection)
	end
end

function CollectionController:OnMouseOver(node)
    if node == nil then return; end;
	local cid = node.cid
	local collection = CollectionModel:GetCollection(cid)
	if collection and collection.__type and collection.__type == "collection" then
		self:MouseOver(collection)
	end
end

function CollectionController:OnMouseClick(node)
    if node == nil then return; end;
	local cid = node.cid
	local collection = CollectionModel:GetCollection(cid)
	
	if collection and collection.__type and collection.__type == "collection" then
		if not collection.isShowHeadBoard then
			return
		end
		if collection:GetCollectionState() then
			return
		end
		local completeFuc = function()
		-- MainPlayerController.objPlayer:GetEatonChairState()
		-- 采集其他椅子之前告诉服务器离开之前做的那个椅子
		if ActivityController:GetCurrId() == ActivityConsts.Lunch then
			if MainPlayerController:IsEatOnChair() then
				ActivityLunch:SendMove()
			end
		end
			CollectionController:SendCollect(collection)
		end
		if self:CheckOpenDialogDistance(collection.configId) then
			completeFuc()
		else
			local config = t_collection[collection.configId]
			if not config then
				return false
			end
			local config_dis = config.distance
			CollectionController:RunToTargetCollection(collection, config_dis/2, completeFuc)
		end
	end
	
end

function CollectionController:MouseOver(collection)
	if not collection then
		return
	end
	if not collection.isShowHeadBoard then
		return
	end
	if collection:GetCollectionState() then
		return
	end

	if collection.avatar then 
		local light = Light.GetEntityLight(enEntType.eEntType_Collection,CPlayerMap:GetCurMapID());
		collection.avatar:SetHighLight( light.hightlight );
	end

	CCursorManager:AddStateOnChar("collect", collection.cid)
end

function CollectionController:MouseOut(collection)
	if not collection then
		return
	end
	
	if collection.avatar then 
		collection.avatar:DelHighLight()
    end
	
    CCursorManager:DelState("collect")

end

function CollectionController:AddCollectionList(collectionInfo)
	-- WriteLog(LogType.Normal,true,'CollectionController:AddCollectionList-> configId:'..tostring(collectionInfo.configId)..' charId:'..tostring(collectionInfo.charId));
	local id = collectionInfo.configId
	local cid = collectionInfo.charId
	local x = collectionInfo.x
	local y = collectionInfo.y
	local faceto = collectionInfo.faceto
	local born = collectionInfo.born
	local speed = collectionInfo.speed
	local collection = CollectionModel:GetCollection(cid)
	if collection then
		print("add collection ", cid, id)
		return
	end
	if isDebug and _G.isRecordRes then
		_Archive:beginRecord();
	end
	collection = Collection:NewCollection(id, cid, x, y, faceto)
	if not collection then
		return
	end
	collection:ShowCollection()
	collection:SetSpeed(speed)
	CollectionModel:AddCollection(collection)
	if born == 1 then
		collection:Born()
	end

	

	local visible = QuestController:GetConllectNeedShow(id);
	collection:HideSelf(not visible);
	-- 增加采集物后回调
	if self.collectionAddCallBack then
		self.collectionAddCallBack()
		self.collectionAddCallBack = nil
	end
	if isDebug and _G.isRecordRes then
		_Archive:endRecord()
		local recordlist = _Archive:getRecord();
		local file = _File.new();
		file:create("record/collect/"..id..".txt" );
		for _,f in ipairs(recordlist) do
			file:write(f .. "\r");
		end
		file:close();
	end
end

-- 增加采集物后回调
function CollectionController:AddCollectionAddCallBack( callBack )
	self.collectionAddCallBack = callBack
end

function CollectionController:DeleteCollection(cid)
	local collection = CollectionModel:GetCollection(cid)
    if not collection then
    	print("delete collection ", cid)
        return
	end
	-- WriteLog(LogType.Normal,true,'CollectionController:DeleteCollection->:configId:'..tostring(collection.configId)..' charId:'..tostring(collection.charId));
	if not collection.avatar then
		return
	end
	if collection:GetCollectionState() then
		collection:FadeOut()
	else
		CollectionController:DestroyCollection(cid)
	end
end

-- @param collectionId
function CollectionController:Collect(conllectionId)
	local conllection = CollectionModel:GetCollectionByCfgId(conllectionId)
	if not conllection then
		print("该采集物不存在", conllectionId)
		return false, -1
	end
	self:SendCollect(conllection)
	return true
end

function CollectionController:CheckTaskCollection()

end

-- ²É¼¯¾àÀë
function CollectionController:CheckOpenDialogDistance(conllectionId)
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return false
	end
	local config = t_collection[conllectionId]
	if not config then
		return false
	end
	local conllection = CollectionModel:GetCollectionByCfgId(conllectionId)
	if not conllection then
		return false
	end
	local pos1 = selfPlayer:GetPos()
	local pos2 = conllection:GetPos()
	if not pos1 or not pos2 then
		return false
	end
	
	local config_dis = config.distance
	local dis = GetDistanceTwoPoint(pos1, pos2)
	if dis >= config_dis + 1 then
		return false
	end
	return true
end

function CollectionController:RunToTargetCollection(collection, distance, stopFucntion)
    if not collection then
    	return
    end

    local collectionPos = collection:GetPos()
    if not collectionPos then
    	return
    end

    local dir = collection:GetDir()

    local posX, posY = nil, nil
    for i = 0, 3 do
    	local x , y = GetPosByDis(collectionPos, dir + math.pi * i / 2, distance)
		local ret = AreaPathFinder:CheckPoint(x, y)
		if ret then
			posX, posY = x, y
			break
		end
	end
	if posX and posY then
    	local mapId = CPlayerMap:GetCurMapID()
		MainPlayerController:DoAutoRun(mapId, _Vector3.new(posX, posY, 0), stopFucntion)
	end
end

function CollectionController:SendCollect(collection)
	MainPlayerController:StopMove()
	MountController:RemoveRideMount()
    if MainPlayerController:IsCanCollect(collection) == false then
    	return
    end
    CPlayerMap.changePosState = true
    local msg = ReqTriggerObjMsg:new()
    msg.cID = collection.cid
    MsgManager:Send(msg)
end

function CollectionController:GetCollection(cid)
	return CollectionModel:GetCollection(cid)
end

function CollectionController:UpdateCollectionState(collectId, state)
	local list = CollectionModel:GetCollectionList()
	for cid, collection in pairs(list) do
		if collection.configId == collectId then
			local cfgCollection = t_collection[collectId]
			if cfgCollection then
				local taskType = cfgCollection.taskType
				if taskType == 1 or taskType == 3 then
					if state then
						collection.isShowHeadBoard = true
					else
						collection.isShowHeadBoard = false
					end
				end
			end
		end
	end
end

function CollectionController:OnCollectionState(msg)
	local collection = CollectionModel:GetCollection(msg.cid)
    if not collection then
        return
	end
	collection:SetCollectionState()
	collection:Open()
end

function CollectionController:DestroyCollection(cid)
	-- WriteLog(LogType.Normal,true,'CollectionController:DestroyCollection->:'..tostring(cid));
	local collection = CollectionModel:GetCollection(cid)
	if collection then
		if collection.fadeTimePlan then
			TimerManager:UnRegisterTimer(collection.fadeTimePlan)
		end
		if collection.openTimePlan then
			TimerManager:UnRegisterTimer(collection.openTimePlan)
		end
		if cid == CCursorManager.CurrCharCid then
	    	CCursorManager:DelState(CCursorManager.CurrCursor)
	    end
		-- WriteLog(LogType.Normal,true,'CollectionController:DestroyCollection->::configId:'..tostring(collection.configId)..' charId:'..tostring(collection.charId));
		CollectionModel:DeleteCollection(collection)
		collection.avatar:ExitMap()
		collection.avatar = nil
		collection = nil
	end
end

function CollectionController:ClearCollection()
	local collectionList = CollectionModel:GetCollectionList()
	if collectionList then
		for cid, collection in pairs(collectionList) do
			if collection:GetCollectionState() then
				CollectionController:DestroyCollection(cid)
			end
		end
	end
end

function CollectionController:MoveTo(cid, x, y)
	local collection = CollectionModel:GetCollection(cid)
    if not collection then
        return
	end
	collection:MoveTo(x, y)
end

function CollectionController:StopMove(cid, x, y, faceto)
	local collection = CollectionModel:GetCollection(cid)
    if not collection then
        return
	end
	collection:StopMove(x, y, faceto)
end