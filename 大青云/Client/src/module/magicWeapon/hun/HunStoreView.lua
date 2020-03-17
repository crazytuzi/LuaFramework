--[[
]]

_G.UIHunStore = BaseSlotPanel:new("UIHunStore")

UIHunStore.SlotTotalNum = 50;
function UIHunStore:Create()
	self:AddSWF("magicWeaponHunStore.swf",true,nil)
end;

function UIHunStore:OnLoaded(objSwf)
	objSwf.closepanel.click = function() self:OnClosePanel()end;
	
	for i=1,self.SlotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["houseitem"..i]),i);
	end
end;

function UIHunStore:OnShow()
	self:OnShowHosueList();
	self:SetPos(0, 0);
end;

function UIHunStore:OnDelete()
	self:RemoveAllSlotItem();
end;

-- 左键click
function UIHunStore:OnItemClick(item)
	self:DressEquit(item);
end;
function UIHunStore:OnItemDoubleClick(item)
	self:DressEquit(item);
end
-- 右键click
function UIHunStore:OnItemRClick(item)
	self:DressEquit(item);
end;
-- 移入
function UIHunStore:OnItemRollOver(e)
end;
-- 移除
function UIHunStore:OnItemRollOut(item)
end
--开始拖拽
function UIHunStore:OnItemDragBegin(item)
end;
-- 拖拽结束
function UIHunStore:OnItemDragEnd(item)
end;
-- 拖拽中
function UIHunStore:OnItemDragIn(fromData,toData)
end;

function UIHunStore:DressEquit(item)
	local itemData = item:GetData();
	if not itemData then
		return;
	end
	if not itemData.hasItem  then
		return;
	end
	
	--是装备,穿戴
	if BagUtil:GetItemShowType(itemData.tid)==BagConsts.ShowType_Equip then
		BagController:EquipItem(BagConsts.BagType_Bag,itemData.pos);
		return;
    end
end

function UIHunStore:OnItemRollOver(item)
	local data = item:GetData();
	if not data.hasItem then
		return;
	end
	TipsManager:ShowBagTips(BagConsts.BagType_Bag,data.pos);
end

function UIHunStore:OnItemRollOut(item)
	TipsManager:Hide();
end

function UIHunStore:OnShowHosueList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--初始化UI
	self:InitUI()
	
	objSwf.baglist.dataProvider:cleanUp();
	for i,slotVO in ipairs(self.equitlist) do
		objSwf.baglist.dataProvider:push(slotVO:GetUIData());
	end
	objSwf.baglist:invalidateData();
	objSwf.baglist:scrollToIndex(0)
end

function UIHunStore:InitUI()
	self.equitlist = BagUtil:GetHunListByEquipType( BagConsts.BagType_Bag );
end

function UIHunStore:ListNotificationInterests()
	return { NotifyConsts.BagItemNumChange }
end

function UIHunStore:HandleNotification(name,body)
	if name == NotifyConsts.BagItemNumChange then
		self:OnShowHosueList()
	end
end

function UIHunStore:OnClosePanel()
	self:Hide()
end