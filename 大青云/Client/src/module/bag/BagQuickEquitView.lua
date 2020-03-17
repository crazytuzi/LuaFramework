--[[快速换装
zhangshuhui
2015年3月5日16:57:20
]]

_G.UIBagQuickEquitView = BaseSlotPanel:new("UIBagQuickEquitView")
UIBagQuickEquitView.allcount = 0;--总个数
UIBagQuickEquitView.equitlist = {};
UIBagQuickEquitView.curpageIndex = 0;--当前显示页数
UIBagQuickEquitView.pagecount = 0;--总页数
UIBagQuickEquitView.bagtype = 0;
UIBagQuickEquitView.equiptype = 0;
UIBagQuickEquitView.pos = nil;-- 装备位
UIBagQuickEquitView.hasItem = nil;
UIBagQuickEquitView.slotMc = nil;--mc

function UIBagQuickEquitView:Create()
	self:AddSWF("bagQuickEquitPanel.swf", true, "center")
end

function UIBagQuickEquitView:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	--卸下
	objSwf.btnOff.click = function() self:OnBtnOffClick(); end;
	--展示
	objSwf.btnShow.click = function() self:OnBtnShowClick(); end;
	
	--初始化格子
	for i=1,BagConsts.Equip_Quick_Count do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end
end

function UIBagQuickEquitView:OnDelete()
	self:RemoveAllSlotItem();
end

function UIBagQuickEquitView:OnShow(name)
	--显示装备
	self:ShowEquitList();
end

function UIBagQuickEquitView:OnHide()
	TipsManager:Hide();
end

--点击关闭按钮
function UIBagQuickEquitView:OnBtnCloseClick()
	self:Hide();
end

function UIBagQuickEquitView:OnBtnOffClick()
	if not self.hasItem then
	end
	
	BagController:UnEquipItem(self.bagtype,self.pos);
	self:Hide();
end

function UIBagQuickEquitView:OnBtnShowClick()
	if not self.hasItem then
	end
	
	ChatQuickSend:SendItem(self.bagtype,self.pos);
	self:Hide();
end

-------------------事件------------------

function UIBagQuickEquitView:HandleNotification(name,body)
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
		   body.type == BagConsts.BagType_LingShouHorse or
				body.type == BagConsts.BagType_MingYu or
				body.type == BagConsts.BagType_Armor or
				body.type == BagConsts.BagType_MagicWeapon or
				body.type == BagConsts.BagType_LingQi then
			self:ShowEquitList();
		end
	elseif name == NotifyConsts.BagRemove then
		if body.type == BagConsts.BagType_Role or
		   body.type == BagConsts.BagType_Horse or
		   body.type == BagConsts.BagType_Bag or
		   body.type == BagConsts.BagType_LingShou or
		   body.type == BagConsts.BagType_LingShouHorse or
			body.type == BagConsts.BagType_MingYu or
			body.type == BagConsts.BagType_Armor or
			body.type == BagConsts.BagType_MagicWeapon or
			body.type == BagConsts.BagType_LingQi then
			self:ShowEquitList();
		end
	elseif name == NotifyConsts.BagUpdate then
		if body.type == BagConsts.BagType_Role or
		   body.type == BagConsts.BagType_Horse or
		   body.type == BagConsts.BagType_Bag or
		   body.type == BagConsts.BagType_LingShou or
		   body.type == BagConsts.BagType_LingShouHorse or
			body.type == BagConsts.BagType_MingYu or
			body.type == BagConsts.BagType_Armor or
			body.type == BagConsts.BagType_MagicWeapon or
			body.type == BagConsts.BagType_LingQi then
			self:ShowEquitList();
		end
	end
end

function UIBagQuickEquitView:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut,
			NotifyConsts.BagAdd,NotifyConsts.BagRemove,
			NotifyConsts.BagUpdate};
end

function UIBagQuickEquitView:Open(slotMc, bagtype, equiptype, pos, hasItem)
	self.slotMc = slotMc;
	self.bagtype = bagtype;
	self.equiptype = equiptype;
	self.pos = pos;
	self.hasItem = hasItem;
	
	if self:IsShow() then
		self:ShowEquitList();
	else
		self:Show();
	end
end

function UIBagQuickEquitView:InitData()
	
end

function UIBagQuickEquitView:InitUI()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local ishaveequit = false;
	self.equitlist = {};
	self.equitlist, ishaveequit = BagUtil:GetListByEquipType(BagConsts.BagType_Bag, self.equiptype);
	
	objSwf.lablehaveinfo.htmlText = "";
	objSwf.lablenohaveinfo.htmlText = "";
	-- 描述
	local str = "";
	local equitname = BagConsts:GetEquipName(self.equiptype);
	
	if ishaveequit == true then
		str = string.format(StrConfig['bag201'], equitname);
		objSwf.lablehaveinfo.htmlText = str;
	else
		str = string.format( StrConfig['bag202'], equitname);
		objSwf.lablenohaveinfo.htmlText = str;
	end
	
	local pos = nil;
	if self.slotMc then
		pos = UIManager:GetMcPos(self.slotMc);
		local width = self.slotMc.width or self.slotMc._width;
		local height = self.slotMc.height or self.slotMc._height;
		
		if self.pos <= 5 then
			pos.x = pos.x - objSwf._width - 10;
			pos.y = pos.y + height/2 -   objSwf._height/2;
		elseif self.pos >= 20 then
			pos.x = pos.x - objSwf._width / 2;
			pos.y = pos.y -   objSwf._height;
		else
			pos.x = pos.x + width;
			pos.y = pos.y + height/2 -   objSwf._height/2;
		end
	else
		pos = _sys:getRelativeMouse();
	end
	objSwf._x = pos.x + 5;
	objSwf._y = pos.y;
end

--显示列表
function UIBagQuickEquitView:ShowEquitList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--初始化数据
	self:InitData();
	--初始化UI
	self:InitUI();
	
	objSwf.list.dataProvider:cleanUp();
	for i,slotVO in ipairs(self.equitlist) do
		objSwf.list.dataProvider:push(slotVO:GetUIData());
	end
	objSwf.list:invalidateData();
	objSwf.list:scrollToIndex(0);
	
	objSwf.scrollBar._visible = true;
	if #self.equitlist <= BagConsts.Equip_Quick_Count then
		objSwf.scrollBar._visible = false;
	end
end

function UIBagQuickEquitView:OnItemRollOver(item)
	local data = item:GetData();
	if not data.hasItem then
		return;
	end
	TipsManager:ShowBagTips(BagConsts.BagType_Bag,data.pos);
end

function UIBagQuickEquitView:OnItemRollOut(item)
	TipsManager:Hide();
end

function UIBagQuickEquitView:OnItemClick(item)
	self:DressEquit(item);
end

function UIBagQuickEquitView:OnItemDoubleClick(item)
	self:DressEquit(item);
end

function UIBagQuickEquitView:OnItemRClick(item)
	self:DressEquit(item);
end

function UIBagQuickEquitView:DressEquit(item)
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
		self:Hide();
		return;
    end
end