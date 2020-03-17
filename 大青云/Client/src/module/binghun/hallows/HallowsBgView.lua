--[[
	2016年1月4日15:46:04
	wangyanwei
	圣灵背包
]]

_G.UIHallowsBG = BaseSlotPanel:new('UIHallowsBG');

function UIHallowsBG:Create()
	self:AddSWF('hallowsBgpanel.swf',true,'center');
end

UIHallowsBG.SlotTotalNum = 50;
function UIHallowsBG:OnLoaded(objSwf)
	objSwf.btn_close.click = function () self:Hide(); end
	for i=1,self.SlotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["hallowsItem"..i]),i);
	end
end

function UIHallowsBG:OnShow()
	self:ShowBGItem();
end

function UIHallowsBG:OnHide()
	
end

function UIHallowsBG:ShowBGItem()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	local hallowslist = bagVO:BagItemListBySub(BagConsts.SubT_Hallows);
	local list = {};
	for i , item in pairs(hallowslist) do
		local itemCfg = t_item[item:GetTid()];
		if itemCfg then
			if itemCfg.sub == BagConsts.SubT_Hallows then
				local slotVO = BagSlotVO:new();
				slotVO.pos = item:GetPos();
				slotVO.bagType = BagConsts.BagType_Bag;
				slotVO.opened = true;
				slotVO.hasItem = true;
				slotVO.tid = item:GetTid();
				slotVO.count = item:GetCount();
				slotVO.bindState = item:GetBindState() ;
				slotVO.strenLvl = EquipModel:GetStrenLvl(item:GetId());
				table.push(list,slotVO);
			end
		end
	end
	table.sort(list,function(A,B) return A.pos < B.pos end)
	
	-- --补全n个
	-- local last = 0;
	-- if #list == 0 then
	-- 	last = LingzhenConsts.SlotTotalNum;
	-- else
	-- 	if #list%self.SlotTotalNum > 0 then
	-- 		last = self.SlotTotalNum - #list%self.SlotTotalNum;
	-- 	end
	-- end
	-- for i=1,last do
	-- 	local slotVO = BagSlotVO:new();
	-- 	slotVO.bagType = BagConsts.BagType_Bag;
	-- 	slotVO.opened = true;
	-- 	slotVO.hasItem = false;
	-- 	table.push(list,slotVO);
	-- end
	
	objSwf.baglist.dataProvider:cleanUp();
	for i,slotVO in ipairs(list) do
		objSwf.baglist.dataProvider:push(slotVO:GetUIData());
	end
	objSwf.baglist:invalidateData();
	objSwf.baglist:scrollToIndex(0);
end

-- 左键click
function UIHallowsBG:OnItemClick(item)
	self:ClickHallows(item);
end;
function UIHallowsBG:OnItemDoubleClick(item)
	self:ClickHallows(item);
end
-- 右键click
function UIHallowsBG:OnItemRClick(item)
	self:ClickHallows(item);
end;

--物品点击
function UIHallowsBG:ClickHallows(item)
	local itemData = item:GetData();
	if not itemData then
		return;
	end
	if not itemData.hasItem  then
		return;
	end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	local item = bagVO:GetItemByPos(itemData.pos);
	local hallowsID = UIHallows.hallowSelected + 1;
	HallowsController:InlayHallows(hallowsID,item:GetId())
end

-- 移入
function UIHallowsBG:OnItemRollOver(e)
end;
-- 移除
function UIHallowsBG:OnItemRollOut(item)
end
--开始拖拽
function UIHallowsBG:OnItemDragBegin(item)
end;
-- 拖拽结束
function UIHallowsBG:OnItemDragEnd(item)
end;
-- 拖拽中
function UIHallowsBG:OnItemDragIn(fromData,toData)
end;

function UIHallowsBG:OnItemRollOver(item)
	local data = item:GetData();
	if not data.hasItem then
		return;
	end
	TipsManager:ShowBagTips(BagConsts.BagType_Bag,data.pos);
end

function UIHallowsBG:OnItemRollOut(item)
	TipsManager:Hide();
end

function UIHallowsBG:GetWidth()
	return 328
end

function UIHallowsBG:GetHeight()
	return 609
end

function UIHallowsBG:OnDelete()
	self:RemoveAllSlotItem();
end

function UIHallowsBG:HandleNotification(name,body)
	if not self.bShowState then return end
	if name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		self:ShowBGItem();
	end
end

function UIHallowsBG:ListNotificationInterests()
	return {NotifyConsts.BagAdd,
			NotifyConsts.BagRemove,
			NotifyConsts.BagUpdate};
end