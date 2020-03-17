_G.classlist['DropItemController'] = 'DropItemController'
_G.DropItemController = setmetatable({}, { __index = IController })
DropItemController.name = "DropItemController"
DropItemController.objName = 'DropItemController'
DropItemController.lastPickTime = 0
DropItemController.lastPickItemTime = 0
DropItemController.lastPickItemCid = ""
DropItemController.lastPickMoneyTime = 0
DropItemController.mouseItem = nil
DropItemController.itemList = {} --新生掉落物品先存这里 --挨个掉落效果
DropItemController.lastAutoShowTime = 0 --挨个掉落效果时间间隔
DropItemController.showSoundTime = 0
DropItemController.ZhenqiItemId = 14

function DropItemController:Create()
	CControlBase:RegControl(self, true)
	CPlayerControl:AddPickListen(self)
	self.bCanUse = true
	MsgManager:RegisterCallBack(MsgType.SC_PickUpItem_Ret, self, self.OnPickUpResult)
	return true
end

function DropItemController:Update(interval)
	DropItemController:AutoPickMoney()
	DropItemController:AutoShow()
	return true
end

function DropItemController:DoPickUp()
	if GetCurTime() - self.lastPickTime < 500 then
		return
	end
	self.lastPickTime = GetCurTime()
	self:PickUpItemAll()
end

function DropItemController:AutoShow()
	if GetCurTime() - self.lastAutoShowTime < 150 then
		return
	end
	self.lastAutoShowTime = GetCurTime()
	for cid, items in pairs(DropItemController.itemList) do
		if items and #items == 0 then
			DropItemController.itemList[cid] = nil
		end
		if items then
			local itemNumber = #items
			local number = 1
			if itemNumber > 20 then
				number = 5
			elseif itemNumber > 10 then
				number = 3
			end
			DropItemController:ShowSomeItem(cid, number)
		end
	end
end

function DropItemController:ShowSomeItem(cid, number)
	local items = DropItemController.itemList[cid]
	if not items then
		return
	end
	if #items < number then
		return
	end
	if number < 1 then
		return
	end
	for i = 1, number do
		for index, item in pairs(items) do
			local item = DropItemController.itemList[cid][index]
			if GetCurTime() - item.bornTime > 0 then
				DropItemController:ShowItem(item)
				table.remove(DropItemController.itemList[cid], index)
				break
			end
		end
	end
end

function DropItemController:RemoveItem(itemCid)
	for cid, items in pairs(DropItemController.itemList) do
		if items and #items == 0 then
			DropItemController.itemList[cid] = nil
		end
		if items then
			for index, item in pairs(items) do
				local item = DropItemController.itemList[cid][index]
				if itemCid == item.ObjId then
					table.remove(DropItemController.itemList[cid], index)
					break
				end
			end
		end
	end
end

function DropItemController:AddItem(source, item)
	if not DropItemController.itemList[source] then
		DropItemController.itemList[source] = {}
	end
	item.bornTime = GetCurTime()
	table.insert(DropItemController.itemList[source], item)
end

function DropItemController:ShowItem(item)
	item:Show()
	MainPlayerModel.allDropItem[item.ObjId] = item
end

function DropItemController:PrintItem()
	for cid, items in pairs(DropItemController.itemList) do
		if items and #items == 0 then
			DropItemController.itemList[cid] = nil
		end
		if items then
			for index, item in pairs(items) do
				local item = DropItemController.itemList[cid][index]
				print(item.ObjId)
			end
		end
	end
end

local resultTable = {}
function DropItemController:AutoPickMoney()
	if GetCurTime() - self.lastPickMoneyTime < 2000 then
		return
	end
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return
	end
	local pos = selfPlayer:GetPos()
	if not pos then
		return
	end
	local selfCid = MainPlayerController:GetRoleID()
	table.ClearTable(resultTable)

	for cid, item in pairs(MainPlayerModel.allDropItem) do
		if not item.isSim then
			if item.dwRoleId == selfCid or item.dwRoleId == "0_0" then
				if item.configId == 7
						or item.configId == 10
						or item.configId == 11
						or item.configId == 12
						or item.configId == 13
						or item.configId == 14
						or item.configId == 51
						or item.configId == 54
						or item.configId == 55 then
					local itemPos = item:GetPos()
					local itemId = item:GetItemId()
					if GetDistanceTwoPoint(itemPos, pos) <= 15 and BagModel:CheckCanPutItem(itemId, 1) then
						table.insert(resultTable, { id = cid })
					end
				end
			end
		end
	end
	if not next(resultTable) then
		return
	end
	DropItemController:SendPickUpItem(resultTable)
	self.lastPickMoneyTime = GetCurTime()
end

function DropItemController:Destroy()
	return true
end

function DropItemController:OnEnterGame()
	return true
end

function DropItemController:OnChangeSceneMap()
	MainPlayerModel.allDropItem = {}
	DropItemController.itemList = {}
	return true
end

function DropItemController:OnLeaveSceneMap()
	MainPlayerModel.allDropItem = {}
	DropItemController.itemList = {}
	return true
end

function DropItemController:OnMouseWheel()
end

function DropItemController:OnBtnPick(button, type, node)
	self:OnMouseClick(node)
end

function DropItemController:OnRollOver(type, node)
	self:OnMouseOver(node)
end

function DropItemController:OnRollOut(type, node)
	self:OnMouseOut(node)
end

function DropItemController:OnMouseOut(node)
	if not node or not node.GetItemID then
		return
	end
	local cid = node:GetItemID()
	if not cid then
		return
	end
	local item = MainPlayerController:GetItemByCid(cid)
	if not item then
		return
	end
	self:MouseOutItem(item)
end

function DropItemController:OnMouseOver(node)
	if not node or not node.GetItemID then
		return
	end
	local cid = node:GetItemID()
	if not cid then
		return
	end
	local item = MainPlayerController:GetItemByCid(cid)
	if not item then
		return
	end
	self:MouseOverItem(item)
end

function DropItemController:OnMouseClick(node)
	if not node or not node.GetItemID then
		return
	end
	local cid = node:GetItemID()
	if not cid then
		return
	end
	local item = MainPlayerController:GetItemByCid(cid)
	if not item then
		return
	end
	if item.isSim then
		return;
	end
	self:PickUpItem(cid)
end

function DropItemController:MouseOverItem(item)
	if item:GetAvatar() then
		local light = Light.GetEntityLight(enEntType.eEntType_Item,CPlayerMap:GetCurMapID());
		item:GetAvatar():SetHighLight( light.hightlight );
		DropItemController.mouseItem = item.ObjId
	end
	CCursorManager:AddStateOnChar("pick", item.ObjId)
end

function DropItemController:MouseOutItem(item)
	if item:GetAvatar() then
		item:GetAvatar():DelHighLight()
		DropItemController.mouseItem = nil
	end
	CCursorManager:DelState("pick")
end

function DropItemController:PickUpItem(cid)
	if DropItemController.lastPickItemCid == cid
			and DropItemController.lastPickItemTime - GetCurTime() < 200 then
		return
	end
	DropItemController.lastPickItemTime = GetCurTime()
	DropItemController.lastPickItemCid = cid
	DropItemController:SendPickUpItem({ { id = cid } })
end

function DropItemController:SendPickUpItem(pickList)
	if not pickList then
		return
	end
	if not next(pickList) then
		return
	end
	local msg = ReqPickUpItemMsg:new()
	msg.data = pickList
	MsgManager:Send(msg)
end

function DropItemController:OnPickUpResult(msg)
	local result = 0
	local soundType = 0
	for index, item in pairs(msg.data) do
		if item.result == 0 then
			if result == 0 then
				result = 3
			end
			local func = FuncManager:GetFunc(FuncConsts.Bag);
			local dropItem = MainPlayerController:GetItemByCid(item.id)
			if func and dropItem then
				func:ShowPickEffect(dropItem.configId);
			end
			if dropItem then
				if t_equip[dropItem.configId] then
					soundType = 1
				else
					if t_item[dropItem.configId] and (dropItem.configId == 10 or dropItem.configId == 11) then
						soundType = 2
					else
						soundType = 1
					end
				end
				self:FlyItemToPlayer(item.id)
				self:PlayItemPfx(item.id)
				local vo = { configId = dropItem.configId, stackCount = dropItem.stackCount }
				Notifier:sendNotification(NotifyConsts.CaveReward, vo);
			end
		elseif item.result == -3 then
			result = 2
		elseif item.result == -1 then
			result = 4
		else
			result = 1
		end
	end
	DropItemController:PlayPickSound(soundType)
	DropItemController:ShowNotice(result)
end

function DropItemController:PlayPickSound(soundType)
	if soundType == 1 then
		SoundManager:PlaySkillSfx(2015)
	elseif soundType == 2 then
		SoundManager:PlaySkillSfx(2016)
	end
end

function DropItemController:PlayShowSound(soundType)
	local nowTime = GetCurTime()
	if nowTime - DropItemController.showSoundTime < 250 then
		return
	end
	if soundType == 1 then
		SoundManager:PlaySkillSfx(2009)
	elseif soundType == 2 then
		SoundManager:PlaySkillSfx(2010)
	end
	DropItemController.showSoundTime = nowTime
end

function DropItemController:ShowNotice(result)
	if AutoBattleController.closeTime > GetCurTime() then
		return
	end
	if result == 3 then
		--FloatManager:AddCenter(StrConfig["item1"])
	elseif result == 1 then
		if not AutoBattleController:GetAutoHang() then
			FloatManager:AddCenter(StrConfig["item2"])
		end
	elseif result == 2 then
		FloatManager:AddCenter(StrConfig["item3"])
	elseif result == 4 then
		if not AutoBattleController:GetAutoHang() then
			--FloatManager:AddCenter(StrConfig["item5"])
		end
	end
end

function DropItemController:PlayItemPfx(cid)
	local item = MainPlayerController:GetItemByCid(cid)
	if not item then
		return
	end
	if item.configId == 7
			or item.configId == 10
			or item.configId == 11
			or item.configId == 12
			or item.configId == 13
			or item.configId == 14 then
		item:PlayItemPfx()
	end
end

local pp = _ParticleParam.new('fly')
local tmat = _Matrix3D.new()
local smat = _Matrix3D.new()
local pmat = _Matrix3D.new()

function DropItemController:FlyItemToPlayer(cid)
	local item = MainPlayerController:GetItemByCid(cid)
	if not item then
		return
	end
	local pos = item:GetPos()
	if not pos then
		return
	end
	local player = MainPlayerController:GetPlayer()
	if not player then
		return
	end
	local tmat = _Matrix3D.new()
	local smat = _Matrix3D.new()
	local pmat = _Matrix3D.new()

	smat:setTranslation(pos)
	smat.ignoreWorld = true

	pmat = player:GetAvatar().objMesh.transform
	local skl = player:GetAvatar():GetSkl()
	tmat = skl:getBone('beatpoint')
	if not tmat then
		return
	end
	tmat.parent = pmat

	pp:addMarker('source', smat)
	pp:addMarker('target', tmat)
	pp:addDuration('bind_target', 350)

	skl.pfxPlayer:clearParams()
	skl.pfxPlayer:addParam(pp)

	skl.pfxPlayer:playParam('v_shiqu_ui.pfx', 'fly')
	skl.pfxPlayer:clearParams()
end

function DropItemController:PickUpItemAll()
	local list, ret = self:GetPickUpItem()
	if #list >= 1 then
		DropItemController:SendPickUpItem(list)
	else
		if ret then
			FloatManager:AddCenter(StrConfig["item3"])
		else
			FloatManager:AddCenter(StrConfig["item4"])
		end
	end
end

function DropItemController:GetPickUpItem()
	local result = {}
	local ret = false
	local pos = MainPlayerController:GetPlayer():GetPos()
	for cid, item in pairs(MainPlayerModel.allDropItem) do
		local itemPos = item:GetPos()
		local itemId = item:GetItemId()
		if not item.isSim then
			if GetDistanceTwoPoint(itemPos, pos) <= 100 then
				ret = true
				if BagModel:CheckCanPutItem(itemId, 1) then
					table.insert(result, { id = cid })
				end
			end
		end
	end
	return result, ret
end