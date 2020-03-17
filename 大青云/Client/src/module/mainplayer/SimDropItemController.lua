--[[
    Created by IntelliJ IDEA.
    客户端本地模拟掉落的控制
    User: Hongbin Yang
    Date: 2016/7/27
    Time: 15:35
   ]]

_G.classlist['SimDropItemController'] = 'SimDropItemController'
_G.SimDropItemController = setmetatable({}, { __index = IController })

SimDropItemController.name = "SimDropItemController"
SimDropItemController.objName = 'SimDropItemController'
SimDropItemController.lastPickTime = 0
SimDropItemController.lastPickItemTime = 0
SimDropItemController.lastPickItemCid = ""
SimDropItemController.mouseItem = nil
SimDropItemController.itemList = {} --新生掉落物品先存这里 --挨个掉落效果
SimDropItemController.lastAutoShowTime = 0 --挨个掉落效果时间间隔
SimDropItemController.showSoundTime = 0
SimDropItemController.constsAutPickUpInterval = 0;
function SimDropItemController:Create()
	CControlBase:RegControl(self, true)
	CPlayerControl:AddPickListen(self)
	self.constsAutPickUpInterval = t_consts[316].val1 * 1000;
	self.bCanUse = true
	--MsgManager:RegisterCallBack(MsgType.SC_PickUpItem_Ret, self, self.OnPickUpResult)
	return true
end

function SimDropItemController:Update(interval)
	self:AutoPickUp();
	self:AutoShow()
	return true
end

function SimDropItemController:AutoShow()
	--[[
	if GetCurTime() - self.lastAutoShowTime < 150 then
		return
	end
	self.lastAutoShowTime = GetCurTime()
	]]
	for cid, items in pairs(self.itemList) do
		if items and #items == 0 then
			self.itemList[cid] = nil
		end
		if items then
			self:ShowSomeItem(cid)
		end
	end
end

function SimDropItemController:ShowSomeItem(cid)
	local items = self.itemList[cid]
	if not items then
		return
	end
	for index, item in pairs(items) do
		local item = self.itemList[cid][index]
		self:ShowItem(item)
	end
	self.itemList[cid] = {};
end

function SimDropItemController:AddItem(vo)
	if MainPlayerModel.allDropItem[vo.charId] then
		Debug("sim add item error ~~~~~~~~~~~~~~~ " .. vo.charId)
		return
	end
	local item = DropItem:NewDropItem(vo)
	if not item then
		Debug("sim add item error ~~~~~~~~~~~~~~~ ")
		return
	end

	if not self.itemList[vo.source] then
		self.itemList[vo.source] = {}
	end
	item.bornTime = GetCurTime()
	table.insert(self.itemList[vo.source], item)
end

function SimDropItemController:RemoveItem(itemCid)
	for cid, items in pairs(self.itemList) do
		if items and #items == 0 then
			self.itemList[cid] = nil
		end
		if items then
			for index, item in pairs(items) do
				local item = self.itemList[cid][index]
				if itemCid == item.ObjId then
					table.remove(self.itemList[cid], index)
					break
				end
			end
		end
	end
	local item = MainPlayerController:GetItemByCid(itemCid)
	if not item then
		Debug("sim remove item error ~~~~~~~~~~~~~~~ " .. itemCid)
		return
	end
	MainPlayerModel.allDropItem[itemCid] = nil
	item:Delete()
	item = nil
end

function SimDropItemController:ShowItem(item)
	item:Show()
	MainPlayerModel.allDropItem[item.ObjId] = item
end

function SimDropItemController:Destroy()
	return true
end

function SimDropItemController:OnEnterGame()
	return true
end

function SimDropItemController:OnChangeSceneMap()
	MainPlayerModel.allDropItem = {}
	self.itemList = {}
	return true
end

function SimDropItemController:OnLeaveSceneMap()
	MainPlayerModel.allDropItem = {}
	self.itemList = {}
	return true
end

function SimDropItemController:OnBtnPick(button, type, node)
	self:OnMouseClick(node)
end

function SimDropItemController:OnRollOver(type, node)
	self:OnMouseOver(node)
end

function SimDropItemController:OnRollOut(type, node)
	self:OnMouseOut(node)
end


function SimDropItemController:OnMouseOut(node)
	CCursorManager:DelState("pick")
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

function SimDropItemController:OnMouseOver(node)
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

function SimDropItemController:OnMouseClick(node)
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
	if not item.isSim then
		return;
	end
	self:PickUpItem(cid)
	--因为模拟的时候直接将掉落从地图上删除了，所以在OnMouseOut中会return就不会改变鼠标状态，所以写在这里 改变下鼠标状态
	CCursorManager:DelState("pick")
end

function SimDropItemController:MouseOverItem(item)
	if item:GetAvatar() then
		item:GetAvatar():SetHighLight(0x10333333)
		self.mouseItem = item.ObjId
	end
	CCursorManager:AddStateOnChar("pick", item.ObjId)
end

function SimDropItemController:MouseOutItem(item)
	if item:GetAvatar() then
		item:GetAvatar():DelHighLight()
		self.mouseItem = nil
	end
	CCursorManager:DelState("pick")
end

function SimDropItemController:AutoPickUp()
	if GetCurTime() - self.lastPickTime < self.constsAutPickUpInterval then
		return
	end
	self.lastPickTime = GetCurTime()
	self:PickUpItemAll()
end

function SimDropItemController:PickUpItem(cid)
	if self.lastPickItemCid == cid
			and self.lastPickItemTime - GetCurTime() < 200 then
		return
	end
	self.lastPickItemTime = GetCurTime()
	self.lastPickItemCid = cid
	self:SendPickUpItem({ { id = cid } })
end

function SimDropItemController:SendPickUpItem(pickList)
	if not pickList then
		return
	end
	if not next(pickList) then --判断是否有内容
	return
	end
	self:OnPickUpResult(pickList);
end

function SimDropItemController:OnPickUpResult(pickList)
	local soundType = 0
	for index, item in pairs(pickList) do
		local func = FuncManager:GetFunc(FuncConsts.Bag);
		local dropItem = MainPlayerController:GetItemByCid(item.id)
		if dropItem.isSim then
			--[[
			--屏蔽了
			if func and dropItem then
				func:ShowPickEffect(dropItem.configId);
			end
			]]
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
			end
			self:RemoveItem(item.id);
		end
	end
	if soundType ~= 0 then
		self:PlayPickSound(soundType)
	end
	pickList = nil;
end

function SimDropItemController:PlayPickSound(soundType)
	if soundType == 1 then
		SoundManager:PlaySkillSfx(2015)
	elseif soundType == 2 then
		SoundManager:PlaySkillSfx(2016)
	end
end

function SimDropItemController:PlayShowSound(soundType)
	local nowTime = GetCurTime()
	if nowTime - self.showSoundTime < 250 then
		return
	end
	if soundType == 1 then
		SoundManager:PlaySkillSfx(2009)
	elseif soundType == 2 then
		SoundManager:PlaySkillSfx(2010)
	end
	self.showSoundTime = nowTime
end


function SimDropItemController:PlayItemPfx(cid)
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

function SimDropItemController:FlyItemToPlayer(cid)
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

function SimDropItemController:PickUpItemAll()
	local list, ret = self:GetPickUpItem()
	if #list >= 1 then
		self:SendPickUpItem(list)
	end
end

function SimDropItemController:GetPickUpItem()
	local result = {}
	local ret = false
	local pos = MainPlayerController:GetPlayer():GetPos()
	for cid, item in pairs(MainPlayerModel.allDropItem) do
		local itemPos = item:GetPos()
		local itemId = item:GetItemId()
		if item.isSim then
			if GetDistanceTwoPoint(itemPos, pos) <= 1000 then
				ret = true
				table.insert(result, { id = cid })
			end
		end
	end
	return result, ret
end