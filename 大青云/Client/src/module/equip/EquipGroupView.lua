--[[
使用套装道具
lizhuangzhuang
2015年7月24日17:49:11
]]

_G.UIEquipGroup = BaseUI:new("UIEquipGroup");

--道具所在的背包
UIEquipGroup.itemUid = nil;

--显示的人物里的装备(坐骑)
UIEquipGroup.roleList = {};
--显示的背包里的装备
UIEquipGroup.bagList = {};

--道具类型,1装备,2坐骑装备,3灵兽装备
UIEquipGroup.itemType = 0;
--套装id
UIEquipGroup.groupId = 0;

--当前选中的背包
UIEquipGroup.currBag = -1;
--当前选中的格子
UIEquipGroup.currPos = -1;

function UIEquipGroup:Create()
	self:AddSWF("equipGroup.swf",true,"center");
end

function UIEquipGroup:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	--
	objSwf.roleList.itemClick = function(e) self:OnRoleItemClick(e); end
	objSwf.roleList.itemRollOver = function(e) self:OnRoleItemOver(e); end
	objSwf.roleList.itemRollOut = function() TipsManager:Hide(); end
	objSwf.bagList.itemClick = function(e) self:OnBagItemClick(e); end
	objSwf.bagList.itemRollOver = function(e) self:OnBagItemOver(e); end
	objSwf.bagList.itemRollOut = function() TipsManager:Hide(); end
	--
	objSwf.btnEquip.rollOver = function() self:OnBtnEquipOver(); end
	objSwf.btnEquip.rollOut = function() TipsManager:Hide(); end
	objSwf.btnEquip.click = function() self:OnBtnEquipClick(); end
	--
	objSwf.btnItem.rollOver = function(e) self:OnBtnItemOver(e); end
	objSwf.btnItem.rollOut = function() TipsManager:Hide(); end
end


function UIEquipGroup:Open(bagType,pos)
	if bagType ~= BagConsts.BagType_Bag then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local bagItem = bagVO:GetItemByPos(pos);
	if not bagItem then return; end
	if bagItem:GetCfg().sub ~= BagConsts.SubT_EquipGroup then return; end
	self.groupId = bagItem:GetCfg().use_param_1;
	local groupCfg = t_equipgroup[self.groupId];
	if not groupCfg then return; end
	if groupCfg.type == 1 then
		self.itemType = 1;
	elseif groupCfg.type == 2 then
		self.itemType = 2;
	elseif groupCfg.type == 3 then
		self.itemType = 3;
	elseif groupCfg.type == 4 then
		self.itemType = 4;
	else
		self.itemType = 5;
	end
	self.itemUid = bagItem:GetId();
	if self:IsShow() then
		self:Top();
		self:OnShow();
	else
		self:Show();
	end
end

function UIEquipGroup:OnShow()
	if self.currBag>-1 or self.currPos>-1 then
		self:UnSelectEquip(true);
	end
	self:ShowRoleList();
	self:ShowBagList();
	self:ShowRightItem();
	self:ShowRightEquip();
end

function UIEquipGroup:OnHide()
	if self.currBag>-1 or self.currPos>-1 then
		self:UnSelectEquip(true);
	end
	self.itemUid = nil;
	self.bagList = {};
	self.roleList = {};
end


function UIEquipGroup:ShowRoleList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = nil;
	if self.itemType == 1 then
		bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	elseif self.itemType == 2 then
		bagVO = BagModel:GetBag(BagConsts.BagType_Horse);
	elseif self.itemType == 3 then
		bagVO = BagModel:GetBag(BagConsts.BagType_LingShou);
	else
		bagVO = BagModel:GetBag(BagConsts.BagType_LingShouHorse);
	end	
	if not bagVO then return; end
	local list = {};
	self.roleList = {};
	for k,item in pairs(bagVO.itemlist) do
		table.push(self.roleList,item);
		table.push(list,UIData.encode(self:GetSlotVO(item)));
	end
	objSwf.roleList.dataProvider:cleanUp();
	objSwf.roleList.dataProvider:push(unpack(list));
	objSwf.roleList:invalidateData();
end

function UIEquipGroup:ShowBagList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local list = {};
	self.bagList = {};
	for k,item in pairs(bagVO.itemlist) do
		if item:GetShowType() == BagConsts.ShowType_Equip then
			if self.itemType == 1 then
				if item:GetCfg().pos>=BagConsts.Equip_WuQi and item:GetCfg().pos<=BagConsts.Equip_JieZhi2 then
					table.push(self.bagList,item);
					table.push(list,UIData.encode(self:GetSlotVO(item)));
				end
			else
				if item:GetCfg().pos>=BagConsts.Equip_H_AnJu and item:GetCfg().pos<=BagConsts.Equip_H_DengJu then
					table.push(self.bagList,item);
					table.push(list,UIData.encode(self:GetSlotVO(item)));
				end
			end
		end
	end
	objSwf.bagList.dataProvider:cleanUp();
	objSwf.bagList.dataProvider:push(unpack(list));
	objSwf.bagList:invalidateData();
end

function UIEquipGroup:SelectEquip(bag,pos)
	if self.currBag>=0 and self.currPos>=0 then
		self:FlyOut(self.currBag,self.currPos);
	end
	self:FlyIn(bag,pos);
	self.currBag = bag;
	self.currPos = pos;
	self:ShowRightEquip();
	self.objSwf.btnEquip.hide = true;
end

function UIEquipGroup:UnSelectEquip(unFly)
	if self.currBag>=0 and self.currPos>=0 then
		if not unFly then
			self:FlyOut(self.currBag,self.currPos);
		end
	end
	self.currBag = -1;
	self.currPos = -1;
	self:ShowRightEquip();
end

function UIEquipGroup:ShowRightEquip()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.currBag<0 or self.currPos<0 then
		objSwf.btnEquip:setData(UIData.encode({}));
		return;
	end
	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	local vo = self:GetSlotVO(item,true);
	objSwf.btnEquip:setData(UIData.encode(vo));
end

function UIEquipGroup:ShowRightItem()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local item = bagVO:GetItemById(self.itemUid);
	if not item then return; end
	local slotVO = RewardSlotVO:new();
	slotVO.id = item:GetTid();
	slotVO.count = 0;
	objSwf.btnItem:setData( slotVO:GetUIData() );
	local groupCfg = t_equipgroup[self.groupId];
	objSwf.tfGroupName.text = groupCfg.name;
	--
	local str = "";
	for i=2,11 do
		local attrCfg = groupCfg["attr"..i];
		if attrCfg ~= "" then
			str = str .. "<textformat leading='-14' leftmargin='11'><p>";
			str = str .. BaseTips:GetHtmlText(string.format("%s件效果：",i),"#be8c44",TipsConsts.Default_Size,false);
			str = str .. "</p></textformat>";
			local attrStr = "";
			local attrlist = AttrParseUtil:Parse(attrCfg);
			for i=1,#attrlist do
				attrStr = attrStr .. enAttrTypeName[attrlist[i].type] .. 
						" <font color='#20ff00'>+" .. getAtrrShowVal(attrlist[i].type,attrlist[i].val) .. "</font>   ";
				if i%2==0 and i<#attrlist then
					attrStr = attrStr .. "<br/>";
				end
			end
			attrStr = BaseTips:GetHtmlText(attrStr,"#c8c8c8",TipsConsts.Default_Size,false);
			str = str .. "<textformat leading='7' leftmargin='80'><p>" .. attrStr .. "</p></textformat>";
			str = str .. "<br/>";
		end
	end
	objSwf.tfGroupInfo.htmlText = str;
end

function UIEquipGroup:OnRoleItemClick(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	local bagType = e.item.bagType;
	if self.currBag==bagType and self.currPos==pos then
		return;
	end
	self:SelectEquip(bagType,pos);
	TipsManager:Hide();
end

function UIEquipGroup:OnRoleItemOver(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	local bagType = e.item.bagType;
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(bagType,pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end

function UIEquipGroup:OnBagItemClick(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	if self.currBag==BagConsts.BagType_Bag and self.currPos==pos then
		return;
	end
	self:SelectEquip(BagConsts.BagType_Bag,pos);
	TipsManager:Hide();
end

function UIEquipGroup:OnBagItemOver(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Bag,pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	itemTipsVO.compareTipsVO = nil;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end

function UIEquipGroup:OnBtnEquipOver()
	if self.currBag<0 or self.currPos<0 then
		return;
	end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(self.currBag,self.currPos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	itemTipsVO.compareTipsVO = nil;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end

function UIEquipGroup:OnBtnEquipClick()
	if self.currBag>=0 and self.currPos>=0 then
		self:UnSelectEquip();
	end
end

function UIEquipGroup:OnBtnItemOver(e)
	local target = e.target;
	if target.data and target.data.id then
		TipsManager:ShowItemTips( target.data.id);
	end
end

function UIEquipGroup:OnBtnConfirmClick()
	if self.currBag<0 or self.currPos<0 then 
		FloatManager:AddNormal(StrConfig["equip1001"]);
		return; 
	end
	if not self.itemUid then return; end
	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	EquipController:ChangEquipGroup(item:GetId(),self.itemUid);
end

function UIEquipGroup:HandleNotification(name,body)
	if name == NotifyConsts.BagAdd then
		if body.type == BagConsts.BagType_Role then
			self:ShowRoleList();
		end
		if (body.type==BagConsts.BagType_Bag and self.itemType==1) or 
			(body.type == BagConsts.BagType_Horse and self.itemType==2) or
			(body.type == BagConsts.BagType_LingShou and self.itemType==3) or
			(body.type == BagConsts.BagType_LingShouHorse and self.itemType==4) then
			local bagVO = BagModel:GetBag(body.type);
			if not bagVO then return; end
			local item = bagVO:GetItemByPos(body.pos);
			if not item then return; end
			if item:GetShowType() == BagConsts.ShowType_Equip then
				self:ShowBagList();
			end
		end
	elseif name == NotifyConsts.BagRemove then
		if body.type == BagConsts.BagType_Role then
			self:ShowRoleList();
		end
		if (body.type==BagConsts.BagType_Bag and self.itemType==1) or 
			(body.type == BagConsts.BagType_Horse and self.itemType==2) or
			(body.type == BagConsts.BagType_LingShou and self.itemType==3) or
			(body.type == BagConsts.BagType_LingShouHorse and self.itemType==4) then
			self:ShowBagList();
		end
		--
		if body.type==self.currBag and body.pos==self.currPos then
			self:UnSelectEquip(true);
		end
		if body.id == self.itemUid then
			self:Hide();
		end
	end
end

function UIEquipGroup:ListNotificationInterests()
	return {NotifyConsts.BagAdd,NotifyConsts.BagRemove};
end

--获取格子VO
function UIEquipGroup:GetSlotVO(item,isBig)
	local vo = {};
	vo.hasItem = true;
	vo.bagType = item:GetBagType();
	vo.pos = item:GetPos();
	vo.isBig = false;
	EquipUtil:GetDataToEquipUIVO(vo,item,isBig);
	return vo;
end

--飞入
function UIEquipGroup:FlyIn(fromBag,fromPos)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(fromBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(fromPos);
	if not item then return; end
	local uiItem = nil;
	if fromBag==BagConsts.BagType_Role or fromBag==BagConsts.BagType_Horse or fromBag==BagConsts.BagType_LingShou or fromBag==BagConsts.BagType_LingShouHorse then
		for i,bagItem in ipairs(self.roleList) do
			if bagItem:GetPos() == fromPos then
				uiItem = objSwf.roleList:getRendererAt(i-1);
				break;
			end
		end
	else
		for i,bagItem in ipairs(self.bagList) do
			if bagItem:GetPos() == fromPos then
				uiItem = objSwf.bagList:getRendererAt(i-1);
				break;
			end
		end
	end
	if not uiItem then return; end
	local flyVO = {};
	flyVO.objName = 'FlyVO'
	flyVO.startPos = UIManager:PosLtoG(uiItem.iconLoader,0,0);
	flyVO.endPos = UIManager:PosLtoG(objSwf.btnEquip.iconLoader,0,0);
	flyVO.time = 0.5;
	flyVO.url = BagUtil:GetItemIcon(item:GetTid(),true);
	flyVO.onStart = function(loader)
		loader._width = 40;
		loader._height = 40;
	end
	flyVO.tweenParam = {};
	flyVO.tweenParam._width = 54;
	flyVO.tweenParam._height = 54;
	flyVO.onUpdate = function()
		objSwf.btnEquip.hide = true;
	end
	flyVO.onComplete = function()
		objSwf.btnEquip.hide = false;
	end
	FlyManager:FlyIcon(flyVO);
end

--飞出
function UIEquipGroup:FlyOut(toBag,toPos)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(toBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(toPos);
	if not item then return; end
	local uiItem = nil;
	if toBag==BagConsts.BagType_Role or toBag==BagConsts.BagType_Horse or toBag==BagConsts.BagType_LingShou or toBag==BagConsts.BagType_LingShouHorse then
		for i,bagItem in ipairs(self.roleList) do
			if bagItem:GetPos() == toPos then
				uiItem = objSwf.roleList:getRendererAt(i-1);
				break;
			end
		end
	else
		for i,bagItem in ipairs(self.bagList) do
			if bagItem:GetPos() == toPos then
				uiItem = objSwf.bagList:getRendererAt(i-1);
				break;
			end
		end
	end
	local flyVO = {};
	flyVO.startPos = UIManager:PosLtoG(objSwf.btnEquip.iconLoader,0,0);
	if uiItem then
		flyVO.endPos = UIManager:PosLtoG(uiItem.iconLoader,0,0);
	else
		flyVO.endPos = UIManager:PosLtoG(objSwf,objSwf.scrollBar._x-40,objSwf.scrollBar._y+15);
	end
	flyVO.time = 0.5;
	flyVO.url = BagUtil:GetItemIcon(item:GetTid(),true);
	flyVO.onStart = function(loader)
		loader._width = 54;
		loader._height = 54;
	end
	flyVO.tweenParam = {};
	flyVO.tweenParam._width = 40;
	flyVO.tweenParam._height = 40;
	FlyManager:FlyIcon(flyVO);
end

function UIEquipGroup:OnBtnCloseClick()
	self:Hide();
end