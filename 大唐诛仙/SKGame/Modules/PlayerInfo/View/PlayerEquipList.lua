PlayerEquipList =BaseClass(LuaUI)

function PlayerEquipList:__init( ... )
	self.URL = "ui://0oudtuxpn1gaq";
	self:__property(...)
	self:Config()
end

function PlayerEquipList:SetProperty( ... )
end
function PlayerEquipList:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("PlayerInfo","PlayerEquipList")
	self.c1 = self.ui:GetController("c1")
	self.item1 = self.ui:GetChild("item1")
	self.item2 = self.ui:GetChild("item2")
	self.item3 = self.ui:GetChild("item3")
	self.item4 = self.ui:GetChild("item4")
	self.item5 = self.ui:GetChild("item5")
	self.item6 = self.ui:GetChild("item6")
	self.item7 = self.ui:GetChild("item7")
	self.item8 = self.ui:GetChild("item8")

end
function PlayerEquipList.Create( ui, ...)
	return PlayerEquipList.New(ui, "#", {...})
end
function PlayerEquipList:Config()
	self.isInited = false
	self.itemList = {}
	self.model = PlayerInfoModel:GetInstance()
	self:InitEvent()
end

function PlayerEquipList:InitEvent()
	self.item7.onClick:Add(function()
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end)
end

--初始化装备栏信息
function PlayerEquipList:Init()
	if not self.isInited then
		self.c1.selectedIndex = 0
		for i=1,#GoodsVo.EquipTypeName do -- 获取装备格子栏
			local info = self.model:GetPlayerEquipmentVoByPos(i)
			self["item"..i] = PlayerEquipItem.Create(self["item"..i],i)
			self["item"..i]:Refresh(info)
			self.itemList[i] = self["item"..i]
		end
		self.model:RemoveEventListener(self.handler)
		self.handler=self.model:AddEventListener(PlayerInfoConst.EventName_RefreshPlayerEquipList, function ()
			self:Refresh()
		end)
		self.isInited = true
	else
		self:Refresh()
	end
	self:SetRedTipsState()
end

--刷新玩家列表(后续改成单刷指定的位置，为穿上装备 出现特效做准备)
function PlayerEquipList:Refresh()
	if self.itemList == nil then return end
	for i = 1, #GoodsVo.EquipTypeName do
		local info = self.model:GetPlayerEquipmentVoByPos(i)
		self.itemList[i]:Refresh(info)
	end
end

function PlayerEquipList:SetRedTipsState()
	local redTipsData = self.model:GetEquipSlotRedTipsList()
	for slotIdx , data in pairs(redTipsData) do
		if self["item" .. slotIdx] then
			self["item" .. slotIdx]:SetRedTipsState(data.isShow)
		end
	end
end

function PlayerEquipList:__delete()
	self.c1 = nil
	if self.itemList then
		for i,v in ipairs(self.itemList) do
			v:Destroy()
			v = nil
			self["item"..i] = nil
		end
	end
	self.itemList = nil
	self.model:RemoveEventListener(self.handler)
	self.isInited = false
end