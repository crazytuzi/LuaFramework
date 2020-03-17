_G.UIChibangPickView = BaseSlotPanel:new("UIChibangPickView")
UIChibangPickView.allcount = 0;--总个数
UIChibangPickView.equitlist = {};
UIChibangPickView.curpageIndex = 0;--当前显示页数
UIChibangPickView.pagecount = 0;--总页数
UIChibangPickView.bagtype = 0;
UIChibangPickView.equiptype = 0;
UIChibangPickView.pos = nil;-- 装备位
UIChibangPickView.hasItem = nil;
UIChibangPickView.slotMc = nil;--mc
function UIChibangPickView:Create()
	self:AddSWF("bagQuickEquitPanel.swf", true, "center")
end

function UIChibangPickView:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	--卸下itemlist
	objSwf.btnOff.click = function() self:OnBtnOffClick(); end;
	--展示
	objSwf.btnShow.click = function() self:OnBtnShowClick(); end;
	
	--初始化格子
	for i=1,BagConsts.Equip_Quick_Count do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end
end

function UIChibangPickView:OnDelete()
	self:RemoveAllSlotItem();
end

function UIChibangPickView:OnShow()
	print('------------------------------ UIChibangPickView:OnShow()')
	--显示装备
	self:ShowEquitList();
end

function UIChibangPickView:OnHide()
end

--点击关闭按钮
function UIChibangPickView:OnBtnCloseClick()
	self:Hide();
end

function UIChibangPickView:OnBtnOffClick()
	if not self.hasItem then
	end
	
	BagController:UnEquipItem(self.bagtype,self.pos);
	self:Hide();
end

function UIChibangPickView:OnBtnShowClick()
	if not self.hasItem then
	end
	
	ChatQuickSend:SendItem(4,0);
	self:Hide();
end

function UIChibangPickView:Open(bagtype, pos)
	-- self.slotMc = slotMc;
	self.bagtype = bagtype;
	-- self.equiptype = equiptype;
	self.pos = pos;
	-- self.hasItem = hasItem;
	
	if self:IsShow() then
		self:ShowEquitList();
	else
		self:Show();
	end
end


-------------------事件------------------

function UIChibangPickView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.StageClick then
		if self.slotMc then
			if not self.slotMc then
				self:Hide();
				return;
			end
			
			local listTarget = string.gsub(objSwf._target, "/",".");
			if string.find(body.target,listTarget) then
				return
			end
			self:Hide();
		end
	elseif name == NotifyConsts.StageFocusOut then
		self:Hide();
	elseif name == NotifyConsts.BagAdd then
		if body.type == BagConsts.BagType_Role or
		   body.type == BagConsts.BagType_Horse or
		   body.type == BagConsts.BagType_Bag or
		   body.type == BagConsts.BagType_LingShou or
		   body.type == BagConsts.BagType_LingShouHorse then
			self:ShowEquitList();
		end
	elseif name == NotifyConsts.BagRemove then
		if body.type == BagConsts.BagType_Role or
		   body.type == BagConsts.BagType_Horse or
		   body.type == BagConsts.BagType_Bag or
		   body.type == BagConsts.BagType_LingShou or
		   body.type == BagConsts.BagType_LingShouHorse then
			self:ShowEquitList();
		end
	elseif name == NotifyConsts.BagUpdate then
		if body.type == BagConsts.BagType_Role or
		   body.type == BagConsts.BagType_Horse or
		   body.type == BagConsts.BagType_Bag or
		   body.type == BagConsts.BagType_LingShou or
		   body.type == BagConsts.BagType_LingShouHorse then
			self:ShowEquitList();
		end
	end
end

function UIChibangPickView:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut,
			NotifyConsts.BagAdd,NotifyConsts.BagRemove,
			NotifyConsts.BagUpdate};
end

--显示列表
function UIChibangPickView:ShowEquitList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local pos = nil;
	pos = _sys:getRelativeMouse();
	objSwf._x = pos.x - 5 - self:GetWidth();
	objSwf._y = pos.y;
	
	objSwf.lablehaveinfo.htmlText = "";
	objSwf.lablenohaveinfo.htmlText = "";
	local str = "";
	
	local list = nil;
	
	objSwf.list.dataProvider:cleanUp();
	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
	list = bag:BagItemListBySub(BagConsts.SubT_Wing);
	print('----------------UIChibangPickView:ShowEquitList()list'..#list)
	if #list == 0 then
		objSwf.scrollBar._visible = false;
		-- self:OnBtnCloseClick();
		str = StrConfig['bag20000002'];
		objSwf.lablenohaveinfo.htmlText = str;
		return;
	else
		objSwf.scrollBar._visible = true;
		if #list <= BagConsts.Equip_Quick_Count then
			objSwf.scrollBar._visible = false;
		end
		str = StrConfig['bag20000001'];
		objSwf.lablehaveinfo.htmlText = str;
	end
	local items = {};
	for i,item in ipairs(list) do
		local slotVO = BagSlotVO:new();
		slotVO.pos = item:GetPos();
		slotVO.bagType = BagConsts.BagType_Bag;
		slotVO.opened = true;
		slotVO.hasItem = true;
		slotVO.tid = item:GetTid();
		slotVO.count = item:GetCount();
		slotVO.bindState = item:GetBindState() ;
		table.push(items,slotVO);
	end
	table.sort(items,function(A,B) return A.pos < B.pos end);
	for i,item in ipairs(items) do
		objSwf.list.dataProvider:push(item:GetUIData());
	end	
	objSwf.list:invalidateData();
	objSwf.list:scrollToIndex(0);
	
end
function UIChibangPickView:GetWidth()
	return 305;
end
function UIChibangPickView:OnItemRollOver(item)
	local data = item:GetData();
	if not data.hasItem then
		return;
	end
	TipsManager:ShowBagTips(BagConsts.BagType_Bag,data.pos);
end

function UIChibangPickView:OnItemRollOut(item)
	TipsManager:Hide();
end

function UIChibangPickView:OnItemClick(item)
	print('----------------------------- UIChibangPickView:OnItemClick(item)')
	self:DressEquit(item);
end

function UIChibangPickView:OnItemDoubleClick(item)
	self:DressEquit(item);
end

function UIChibangPickView:OnItemRClick(item)
	self:DressEquit(item);
end

function UIChibangPickView:DressEquit(item)
	local itemData = item:GetData();
	print('-------------------UIChibangPickView:DressEquit(item) ')
	if not itemData then
		return;
	end
	if not itemData.hasItem  then
		return;
	end
	print('-------------------UIChibangPickView:DressEquit(item) itemData.hasItem  '..BagUtil:GetItemShowType(itemData.tid))
	print('-------------------UIChibangPickView:DressEquit(item) itemData.tid  '..itemData.tid)
	
	--是装备,穿戴
	-- if BagUtil:GetItemShowType(itemData.tid)==BagConsts.ShowType_Equip then
		-- BagController:EquipItem(BagConsts.BagType_Bag,itemData.pos);
		-- self:Hide();
		-- return;
    -- end
	BagController:EquipWing(BagConsts.BagType_Bag,itemData.pos);
	self:Hide();
end