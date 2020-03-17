--[[
神兵快捷背包
2015年7月24日11:01:38
haohu
]]
--------------------------------------------------------

_G.UIMagicWeaponBagShortcut = BaseSlotPanel:new("UIMagicWeaponBagShortcut")

UIMagicWeaponBagShortcut.SLOT_NUM = 6

function UIMagicWeaponBagShortcut:Create()
	self:AddSWF( "magicWeaponBagShortcut.swf", true, nil )
end

function UIMagicWeaponBagShortcut:OnLoaded( objSwf )
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
	--初始化格子
	for i = 1, self.SLOT_NUM do
		self:AddSlotItem( BaseItemSlot:new( objSwf["item"..i] ), i )
	end
end

function UIMagicWeaponBagShortcut:OnDelete()
	self:RemoveAllSlotItem()
end

function UIMagicWeaponBagShortcut:OnShow()
	self:UpdateShow()
end

function UIMagicWeaponBagShortcut:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local slotVOList = self:GetSlotVOList()
	objSwf.list.dataProvider:cleanUp()
	for i, slotVO in ipairs( slotVOList ) do
		objSwf.list.dataProvider:push( slotVO:GetUIData() )
	end
	objSwf.list:invalidateData()
end

function UIMagicWeaponBagShortcut:CheckHasProficiencyItem()
	local bagVO = BagModel:GetBag( BagConsts.BagType_Bag )
	if not bagVO then return false end
	local itemList = bagVO:GetItemList()
	for _, item in pairs(itemList) do
		if self:CheckIsProficiencyItem( item:GetTid() ) then
			return true
		end
	end
	return false
end

function UIMagicWeaponBagShortcut:GetSlotVOList()
	local bagVO = BagModel:GetBag( BagConsts.BagType_Bag )
	if not bagVO then self:Hide() return end
	local slotVOList = {}
	local itemList = bagVO:GetItemList()
	for pos, item in pairs(itemList) do
		if self:CheckIsProficiencyItem( item:GetTid() ) then
			if #slotVOList == self.SLOT_NUM then
				break
			end
			local slotVO     = BagSlotVO:new()
			slotVO.bagType   = BagConsts.BagType_Bag
			slotVO.uiPos     = #slotVOList + 1
			slotVO.pos       = pos
			slotVO.opened    = true
			slotVO.hasItem   = true
			slotVO.id        = item:GetId()
			slotVO.tid       = item:GetTid()
			slotVO.count     = item:GetCount()
			slotVO.bindState = item:GetBindState()
			slotVO.flags     = item.flags
			table.push( slotVOList, slotVO )
		end
	end
	while( #slotVOList < self.SLOT_NUM ) do
		local slotVO = BagSlotVO:new()
		slotVO.opened    = true
		slotVO.hasItem   = false
		table.push( slotVOList, slotVO )
	end
	return slotVOList
end

function UIMagicWeaponBagShortcut:CheckIsProficiencyItem( itemId )
	local itemDic = MagicWeaponConsts:GetProficiencyItemDic()
	return itemDic[itemId] == true
end

function UIMagicWeaponBagShortcut:OnBtnCloseClick()
	self:Hide()
end

--点击Item
function UIMagicWeaponBagShortcut:OnItemClick(item)
	self:UseItem(item)
end

--右键点击Item
function UIMagicWeaponBagShortcut:OnItemRClick(item)
	self:UseItem(item)
end

--鼠标移上Item
function UIMagicWeaponBagShortcut:OnItemRollOver(item)
	local itemData = item:GetData()
	if not itemData.opened then
		return
	end
	if not itemData.hasItem then
		return
	end
	local itemId = itemData.tid
	if itemId then
		TipsManager:ShowItemTips( itemId )
	end
end

--鼠标移出Item
function UIMagicWeaponBagShortcut:OnItemRollOut(item)
	TipsManager:Hide()
end

UIMagicWeaponBagShortcut.lastSendTime = 0;

function UIMagicWeaponBagShortcut:UseItem( item )
	if GetCurTime() - self.lastSendTime < 200 then
		return;
	end
	self.lastSendTime = GetCurTime();
	TipsManager:Hide()
	local itemData = item:GetData()
	if not itemData.opened then
		return
	end
	if not itemData.hasItem then
		return
	end
	BagController:UseItem( BagConsts.BagType_Bag, itemData.pos, 1 )
end

function UIMagicWeaponBagShortcut:ListNotificationInterests()
	return {
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate
	}
end

function UIMagicWeaponBagShortcut:HandleNotification( name, body )
	if name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		self:UpdateShow()
	end
end

function UIMagicWeaponBagShortcut:ToggleShow()
	if not self.bShowState then
		if self:CheckHasProficiencyItem() then
			self:Show()
			return true
		end
		return false
	end
	self:Hide()
	return true
end