--[[
 灵兽印记，仓库
 wangshuai
]]

_G.UIQiZhanZhenYanHouseView = BaseSlotPanel:new("UIQiZhanZhenYanHouseView")

UIQiZhanZhenYanHouseView.SlotTotalNum = 50;
function UIQiZhanZhenYanHouseView:Create()
	self:AddSWF("qizhanLingYinHouse.swf",true,nil)
end;

function UIQiZhanZhenYanHouseView:OnLoaded(objSwf)
	objSwf.closepanel.click = function() self:OnClosePanel()end;
	
	for i=1,self.SlotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["houseitem"..i]),i);
	end
end;

function UIQiZhanZhenYanHouseView:OnShow()
	self:OnShowHosueList();
	self:SetPos(0, 0);
end;

function UIQiZhanZhenYanHouseView:OnDelete()
	self:RemoveAllSlotItem();
end;

-- 左键click
function UIQiZhanZhenYanHouseView:OnItemClick(item)
	self:DressEquit(item);
end;
function UIQiZhanZhenYanHouseView:OnItemDoubleClick(item)
	self:DressEquit(item);
end
-- 右键click
function UIQiZhanZhenYanHouseView:OnItemRClick(item)
	self:DressEquit(item);
end;
-- 移入
function UIQiZhanZhenYanHouseView:OnItemRollOver(e)
end;
-- 移除
function UIQiZhanZhenYanHouseView:OnItemRollOut(item)
end
--开始拖拽
function UIQiZhanZhenYanHouseView:OnItemDragBegin(item)
end;
-- 拖拽结束
function UIQiZhanZhenYanHouseView:OnItemDragEnd(item)
end;
-- 拖拽中
function UIQiZhanZhenYanHouseView:OnItemDragIn(fromData,toData)
end;

function UIQiZhanZhenYanHouseView:DressEquit(item)
	local itemData = item:GetData();
	if not itemData then
		return;
	end
	if not itemData.hasItem  then
		return;
	end
	
	--是装备,穿戴
	if not BagUtil:GetLevelAccord(itemData.tid) then
		FloatManager:AddNormal( StrConfig["qizhan2"]);
		return
	end
	
	if BagUtil:GetItemShowType(itemData.tid)==BagConsts.ShowType_Equip then
		BagController:EquipItem(BagConsts.BagType_Bag,itemData.pos);
		return;
    end
end

function UIQiZhanZhenYanHouseView:OnItemRollOver(item)
	local data = item:GetData();
	if not data.hasItem then
		return;
	end
	TipsManager:ShowBagTips(BagConsts.BagType_Bag,data.pos);
end

function UIQiZhanZhenYanHouseView:OnItemRollOut(item)
	TipsManager:Hide();
end

function UIQiZhanZhenYanHouseView:OnShowHosueList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--初始化数据
	self:InitData();
	--初始化UI
	self:InitUI();
	
	objSwf.baglist.dataProvider:cleanUp();
	for i,slotVO in ipairs(self.equitlist) do
		objSwf.baglist.dataProvider:push(slotVO:GetUIData());
	end
	objSwf.baglist:invalidateData();
	objSwf.baglist:scrollToIndex(0);
	
	-- objSwf.scrollBar._visible = true;
	-- if #self.equitlist <= self.SlotTotalNum then
		-- objSwf.scrollBar._visible = false;
	-- end
end;

function UIQiZhanZhenYanHouseView:InitData()
	
end

function UIQiZhanZhenYanHouseView:InitUI()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	self.equitlist = {};
	self.equitlist = BagUtil:GetQiYinListByEquipType(BagConsts.BagType_Bag);
end

function UIQiZhanZhenYanHouseView:ListNotificationInterests()
	return {NotifyConsts.BagAdd,
			NotifyConsts.BagRemove,
			NotifyConsts.BagUpdate};
end;
function UIQiZhanZhenYanHouseView:HandleNotification(name,body)
	if not self.bShowState then return end;
	if name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		self:OnShowHosueList();
	end;
end;

function UIQiZhanZhenYanHouseView:OnClosePanel()
	self:Hide();
end;
function UIQiZhanZhenYanHouseView:OnHide()

end;