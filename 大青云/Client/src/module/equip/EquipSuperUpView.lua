--[[
卓越传承
lizhuangzhuang
2015年1月29日11:13:54
]]

_G.UIEquipSuperUp = BaseUI:new("UIEquipSuperUp");

--孔总数
UIEquipSuperUp.TotalHoleNum = 5;

--显示的人物里的装备
UIEquipSuperUp.roleList = {};
--显示的背包里的装备
UIEquipSuperUp.bagList = {};
--当前选中的背包
UIEquipSuperUp.currBag = -1;
--当前选中的格子
UIEquipSuperUp.currPos = -1;
--选中的属性索引
UIEquipSuperUp.currAttrIndex = 0;
--当前选中的库属性id
UIEquipSuperUp.currLibId = "";

--当前需要的道具id
UIEquipSuperUp.needItemId = 0;

function UIEquipSuperUp:Create()
	self:AddSWF("equipSuperUp.swf",false,nil);
end

function UIEquipSuperUp:OnLoaded(objSwf)
	objSwf.nonPanel._visible = false;
	objSwf.btnRule.rollOver = function() TipsManager:ShowBtnTips(StrConfig['equip601'],TipsConsts.Dir_RightDown); end
	objSwf.btnRule.rollOut = function() TipsManager:Hide(); end
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
	for i=1,self.TotalHoleNum do
		objSwf["btnSuperAttr"..i].click = function() self:OnSuperAttrClick(i); end
		objSwf["btnNoAttr"..i].visible = false;
		objSwf["btnNoAttr"..i].click = function() self:OnSuperNoAttrClick(i); end
	end
	--
	objSwf.btnNeedItem.rollOver = function() if self.needItemId>0 then TipsManager:ShowItemTips(self.needItemId); end end
	objSwf.btnNeedItem.rollOut = function() TipsManager:Hide(); end
	objSwf.btnNeedMoney.rollOver = function() TipsManager:ShowBtnTips(StrConfig['tips50'],TipsConsts.Dir_RightDown); end
	objSwf.btnNeedMoney.rollOut = function() TipsManager:Hide(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	--
	objSwf.libList.itemClick = function(e) self:OnLibListItemClick(e); end
	objSwf.libList.itemRollOver = function(e) self:OnLibListItemRollOver(e); end
	objSwf.libList.itemRollOut = function() TipsManager:Hide(); end
	objSwf.btnLibDelete.click = function() self:OnLibDelete(); end
	objSwf.btnConfirm.label = StrConfig["equip607"];
	objSwf.tfInfo.text = StrConfig["equip616"];
end

function UIEquipSuperUp:OnShow()
	self.currAttrIndex = 0;
	self.currLibId = "";
	self:ShowRoleList();
	self:ShowBagList();
	self:ShowRight();
	self:ShowLib();
end

function UIEquipSuperUp:OnHide()
	if self.currBag>-1 or self.currPos>-1 then
		self:UnSelectEquip(true);
	end
	self.bagList = {};
	self.roleList = {};
	UIEquipSuperOpenHole:Hide();
end

--显示人物装备
function UIEquipSuperUp:ShowRoleList()
	local objSwf = self.objSwf;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local list = {};
	self.roleList = {};
	for k,item in pairs(bagVO.itemlist) do
		if EquipModel:CheckSuperHole(item:GetId()) then
			table.push(self.roleList,item);
			table.push(list,UIData.encode(self:GetSlotVO(item)));
		end
	end
	objSwf.roleList.dataProvider:cleanUp();
	objSwf.roleList.dataProvider:push(unpack(list));
	objSwf.roleList:invalidateData();
end

--显示背包装备
function UIEquipSuperUp:ShowBagList()
	local objSwf = self.objSwf;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local list = {};
	self.bagList = {};
	for k,item in pairs(bagVO.itemlist) do
		if item:GetShowType() == BagConsts.ShowType_Equip then
			if EquipModel:CheckSuperHole(item:GetId()) then
				table.push(self.bagList,item);
				table.push(list,UIData.encode(self:GetSlotVO(item)));
			end
		end
	end
	objSwf.bagList.dataProvider:cleanUp();
	objSwf.bagList.dataProvider:push(unpack(list));
	objSwf.bagList:invalidateData();
end

--选中装备
function UIEquipSuperUp:SelectEquip(bag,pos)
	if self.currBag>=0 and self.currPos>=0 then
		self:FlyOut(self.currBag,self.currPos);
	end
	self:FlyIn(bag,pos);
	self.currBag = bag;
	self.currPos = pos;
	self:ShowRight();
	self.objSwf.btnEquip.hide = true;
end

--取消选中装备
function UIEquipSuperUp:UnSelectEquip(unFly)
	if self.currBag>=0 and self.currPos>=0 then
		if not unFly then
			self:FlyOut(self.currBag,self.currPos);
		end
	end
	self:UnSelecteLib();
	self.currBag = -1;
	self.currPos = -1;
	self.currAttrIndex = 0;
	self:ShowRight();
end

--显示右侧
function UIEquipSuperUp:ShowRight()
	local objSwf = self.objSwf;
	if self.currBag<0 or self.currPos<0 then
		objSwf.btnEquip:setData(UIData.encode({}));
		for i=1,self.TotalHoleNum do
			objSwf["btnSuperAttr"..i].visible = false;
			objSwf["btnNoAttr"..i].visible = false;
		end
		objSwf.btnNeedItem.label = "";
		objSwf.btnNeedMoney.label = "";
		self.needItemId = 0;
		objSwf.nonPanel._visible = true;
		objSwf.lbNeedItem.visible = false;
		objSwf.btnNeedItem.visible = false;
		objSwf.lbNeedMoney.visible = false;
		objSwf.btnNeedMoney.visible = false;
		objSwf.cbAutoBuy.visible = false;
		objSwf.btnConfirm.visible = false;
		return;
	end
	objSwf.nonPanel._visible = false;
	objSwf.lbNeedItem.visible = true;
	objSwf.btnNeedItem.visible = true;
	objSwf.lbNeedMoney.visible = true;
	objSwf.btnNeedMoney.visible = true;
	objSwf.cbAutoBuy.visible = true;
	objSwf.btnConfirm.visible = true;
	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	local vo = self:GetSlotVO(item);
	objSwf.btnEquip:setData(UIData.encode(vo));
	--
	local superVO = EquipModel:GetSuperVO(item:GetId());
	if not superVO then return; end
	local superNum = superVO.superNum;
	--道具
	self:ShowCondition();
	--选中第一个有属性的项
	self.currAttrIndex = 1;
	for i=1,superNum do
		local attrVO = superVO.superList[i];
		if attrVO.id == 0 then
			self.currAttrIndex = i;
			break;
		end
	end
	if not objSwf["btnSuperAttr"..self.currAttrIndex] then
		self.currAttrIndex = 1;
	end
	objSwf["btnSuperAttr"..self.currAttrIndex].selected = true;
	--
	local noAttrNotice = false;
	local bagNum = BagModel:GetItemNumInBag(EquipConsts:GetSuperHoleItem());
	if bagNum >= EquipConsts:GetSuperHoleItemNum() then
		noAttrNotice = true;
	end
	for i=1,self.TotalHoleNum do
		if i<=superNum then
			objSwf["btnSuperAttr"..i].visible = true;
			self:SetSuperAttrItem(objSwf["btnSuperAttr"..i],item,i);
			objSwf["btnNoAttr"..i].visible = false;
		else
			objSwf["btnSuperAttr"..i].visible = false;
			objSwf["btnNoAttr"..i].visible = true;
			if noAttrNotice then
				objSwf["btnNoAttr"..i].mcEff._visible = true;
				noAttrNotice = false;
			else
				objSwf["btnNoAttr"..i].mcEff._visible = false;
			end
		end
	end
end

--显示条件
function UIEquipSuperUp:ShowCondition()
	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	local objSwf = self.objSwf;
	local inheritCfg = t_fujiafix[item:GetCfg().level*10+item:GetCfg().quality];
	local needGold = inheritCfg.gold;
	self.needItemId = inheritCfg.itemId;
	local needItemCfg = t_item[inheritCfg.itemId];
	if needItemCfg then
		local name = needItemCfg.name;
		if BagModel:GetItemNumInBag(inheritCfg.itemId) < inheritCfg.itemNum then
			objSwf.btnNeedItem.htmlLabel = string.format(StrConfig["equip114"],name,inheritCfg.itemNum);
		else
			objSwf.btnNeedItem.htmlLabel = string.format(StrConfig["equip103"],name,inheritCfg.itemNum);
		end
	end
	if MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold < needGold then
		objSwf.btnNeedMoney.htmlLabel = string.format(StrConfig['equip115'],needGold);
	else
		objSwf.btnNeedMoney.htmlLabel = string.format(StrConfig['equip104'],needGold);
	end
end

--设置卓越属性Item信息
UIEquipSuperUp.libListIndex = nil
function UIEquipSuperUp:SetSuperAttrItem(uiItem,bagItem,index,listIndex)
	local superVO = EquipModel:GetSuperVO(bagItem:GetId());
	local attrVO = superVO.superList[index];
	local cfg = t_fujiashuxing[attrVO.id];
	uiItem.iconLoader.source = ResUtil:GetSuperHoleDefault();
	if self.currAttrIndex==index and self.currLibId~="" then
		local superLibVO = EquipModel:GetSuperLibVO(self.currLibId);
		local attrStr = self:GetSuperAttrStr(superLibVO.id,superLibVO.val1,true);
		attrStr = attrStr .. "<font color='#2fe00d'>  （待铭刻）</font>";
		uiItem.tfName.htmlText = attrStr;
		local cfg = t_fujiashuxing[superLibVO.id];
		if cfg then
			uiItem.iconLoader.source = ResUtil:GetSuperIconUrl(cfg.icon);
		end
		if listIndex then 
			self.libListIndex = listIndex;
			local attrStr = self:GetSuperAttrStr(attrVO.id,attrVO.val1);
			self:ShowLib(attrStr);
		end
	else
		if cfg then
			local attrStr = self:GetSuperAttrStr(attrVO.id,attrVO.val1);
			uiItem.tfName.htmlText = attrStr;
			local cfg = t_fujiashuxing[attrVO.id];
			if cfg then
				uiItem.iconLoader.source = ResUtil:GetSuperIconUrl(cfg.icon);
			end
		else
			uiItem.tfName.htmlText = StrConfig["equip603"];
			uiItem.iconLoader:unload();
		end
	end
end

function UIEquipSuperUp:GetSuperAttrStr(id,val1,gray)
	local cfg = t_fujiashuxing[id];
	if not cfg then return ""; end
	local attrStr = formatAttrStr(cfg.attrType,val1);
	attrStr = "「"..cfg.name.."」" .. attrStr;
	if gray then
		attrStr = string.format("<font color='#2fe00d'>%s</font>",attrStr);
	else
		attrStr = string.format("<font color='%s'>%s</font>",TipsConsts.SuperColor,attrStr);
	end
	return attrStr;
end

function UIEquipSuperUp:OnBtnEquipClick()
	if self.currBag>=0 and self.currPos>=0 then
		self:UnSelectEquip();
	end
end
function UIEquipSuperUp:OnBtnEquipOver()
	if self.currBag<0 or self.currPos<0 then
		return;
	end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(self.currBag,self.currPos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	itemTipsVO.compareTipsVO = nil;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end

--显示属性库
function UIEquipSuperUp:ShowLib(attrStr)
	local objSwf = self.objSwf;
	objSwf.libList.dataProvider:cleanUp();

	--取到当前坑的，属性
	local bagVO = BagModel:GetBag(self.currBag);
	local attrVO = {};
	if bagVO then 
		local bagItem = bagVO:GetItemByPos(self.currPos);
		local superVO = EquipModel:GetSuperVO(bagItem:GetId());
		attrVO = superVO.superList[self.currAttrIndex];
	end

	
	for i,vo in ipairs(EquipModel.superLib) do
		local uiVO = {};
		uiVO.uid = vo.uid;
		local name;
		if i == self.libListIndex then
			if attrVO.id and attrVO.id ~= 0 then 
				attrStr = attrStr or ""
				name = attrStr .. ' (替)';
			else
				name = self:GetSuperAttrStr(vo.id,vo.val1);
			end;
			self.libListIndex = nil;
		else
			name = self:GetSuperAttrStr(vo.id,vo.val1);
		end
		uiVO.label = name;
		uiVO.iconUrl = "";
		local cfg = t_fujiashuxing[vo.id];
		if cfg then
			uiVO.iconUrl = ResUtil:GetSuperIconUrl(cfg.icon);
		end
		objSwf.libList.dataProvider:push(UIData.encode(uiVO));
	end
	objSwf.libList:invalidateData();
	--
	for i,vo in ipairs(EquipModel.superLib) do
		if self.currLibId == vo.uid then
			objSwf.libList.selectedIndex = i-1;
			objSwf.libList:scrollToIndex(i-1);
			return;
		end
	end
	objSwf.libList.selectedIndex = -1;
	self.currLibId = "";
end

--取消选中库中的
function UIEquipSuperUp:UnSelecteLib()
	if self.currLibId == "" then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.currLibId = "";
	objSwf.libList.selectedIndex = -1;
end

--点击属性库item
function UIEquipSuperUp:OnLibListItemClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if e.item.uid == self.currLibId then
		objSwf.libList.selectedIndex = 0
		self.currLibId = '';
		-- self:SelectEquip(self.currBag,self.currPos)
		self:ShowRight();
		self.libListIndex = nil;
		self:ShowLib();
		return
	end
	if not e.item.uid then
		for i,vo in ipairs(EquipModel.superLib) do
			if vo.uid == self.currLibId then
				objSwf.libList.selectedIndex = i-1;
				return;
			end
		end
		objSwf.libList.selectedIndex = -1;
		return;
	end
	self.currLibId = e.item.uid;
	--
	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:SetSuperAttrItem(objSwf["btnSuperAttr"..self.currAttrIndex],item,self.currAttrIndex,e.index + 1);
end

function UIEquipSuperUp:OnLibListItemRollOver(e)
	--[[ if not e.item.uid then
		return;
	end
	local superLibVO = EquipModel:GetSuperLibVO(e.item.uid);
	if not superLibVO then return; end
	local cfg = t_fujiashuxing[superLibVO.id];
	if not cfg then return; end
	local str = "";
	str = string.format("<font color='%s'>%s</font>",TipsConsts.SuperColor,cfg.name);
	str = str .. "<br/>";
	local attrStr = formatAttrStr(cfg.attrType,superLibVO.val1);
	str = str .. string.format("<font color='#b86f11'>%s</font>",attrStr);
	TipsManager:ShowBtnTips(str,TipsConsts.Dir_RightDown); ]]
end


--点击属性
function UIEquipSuperUp:OnSuperAttrClick(index)
	local oldIndex = self.currAttrIndex;
	self.currAttrIndex = index;
	if oldIndex~=self.currAttrIndex then
		self:UnSelecteLib();
		local bagVO = BagModel:GetBag(self.currBag);
		if not bagVO then return; end
		local item = bagVO:GetItemByPos(self.currPos);
		if not item then return; end
		local objSwf = self.objSwf;
		if not objSwf then return; end
		self:SetSuperAttrItem(objSwf["btnSuperAttr"..oldIndex],item,oldIndex);
		self:SetSuperAttrItem(objSwf["btnSuperAttr"..self.currAttrIndex],item,self.currAttrIndex);
		self:ShowLib();
	end
end

--点击无属性
function UIEquipSuperUp:OnSuperNoAttrClick(index)
	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	UIEquipSuperOpenHole:Open(item:GetId());
end

--提交
function UIEquipSuperUp:OnBtnConfirmClick()
	if self.currBag<0 or self.currPos<0 then return; end
	local objSwf = self.objSwf;
	--铭刻
	if self.currLibId == "" then
		FloatManager:AddNormal(StrConfig["equip608"]);
		return;
	end
	if self.currAttrIndex <= 0 then return; end
	EquipController:SuperAttrUp(self.currLibId,self.currBag,self.currPos,self.currAttrIndex,objSwf.cbAutoBuy.selected);
end

--删除库属性
function UIEquipSuperUp:OnLibDelete()
	if self.currLibId == "" then
		FloatManager:AddNormal(StrConfig["equip608"]);
		return;
	end
	UIConfirm:Open(StrConfig["equip609"],function()
		EquipController:SuperLibRemove(self.currLibId);
	end);
end

--
function UIEquipSuperUp:OnRoleItemClick(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	if self.currBag==BagConsts.BagType_Role and self.currPos==pos then
		return;
	end
	self:UnSelecteLib();
	self:SelectEquip(BagConsts.BagType_Role,pos);
	TipsManager:Hide();
	
	self.currLibId = '';
	self.libListIndex = nil;
	self:ShowLib();
end
function UIEquipSuperUp:OnRoleItemOver(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end
function UIEquipSuperUp:OnBagItemClick(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	if self.currBag==BagConsts.BagType_Bag and self.currPos==pos then
		return;
	end
	self:UnSelecteLib();
	self:SelectEquip(BagConsts.BagType_Bag,pos);
	TipsManager:Hide();
	
	self.currLibId = '';
	self.libListIndex = nil;
	self:ShowLib();
end
function UIEquipSuperUp:OnBagItemOver(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Bag,pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	itemTipsVO.compareTipsVO = nil;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end

--获取格子VO
function UIEquipSuperUp:GetSlotVO(item,isBig)
	local vo = {};
	vo.hasItem = true;
	vo.pos = item:GetPos();
	vo.isBig = isBig and true or false;
	EquipUtil:GetDataToEquipUIVO(vo,item,isBig);
	return vo;
end

--铭刻成功
function UIEquipSuperUp:OnSuperAttrUp(eid,index)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	if item:GetId() ~= eid then return; end
	-- objSwf["btnSuperAttr"..index].eff:playEffect(1);
end

--卓越属性改变
function UIEquipSuperUp:OnSuperChange(id)
	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local bagItem = bagVO:GetItemByPos(self.currPos);
	if not bagItem then return; end
	if bagItem:GetId() == id then
		self:ShowRight();
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.currBag == BagConsts.BagType_Role then
		for i,item in ipairs(self.roleList) do
			if item:GetId() == id then
				local uiData = UIData.encode(self:GetSlotVO(item));
				objSwf.roleList.dataProvider[i-1] = uiData;
				local uiItem = objSwf.roleList:getRendererAt(i-1);
				if uiItem then
					uiItem:setData(uiData);
				end
				break;
			end
		end
	elseif self.currBag == BagConsts.BagType_Bag then
		for i,item in ipairs(self.bagList) do
			if item:GetId() == id then
				local uiData = UIData.encode(self:GetSlotVO(item));
				objSwf.bagList.dataProvider[i-1] = uiData;
				local uiItem = objSwf.bagList:getRendererAt(i-1);
				if uiItem then
					uiItem:setData(uiData);
				end
				break;
			end
		end
	end
end

function UIEquipSuperUp:HandleNotification(name,body)
	if not UIEquipSuperUp:IsShow() then return end;
	if name==NotifyConsts.BagAdd or name==NotifyConsts.BagRemove or name==NotifyConsts.BagRefresh then
		if body.type == BagConsts.BagType_Role then
			self:ShowRoleList();
		end
		if body.type == BagConsts.BagType_Bag then
			self:ShowBagList();
		end
		if body.type==self.currBag and body.pos==self.currPos then
			self:UnSelectEquip(true);
		end
	elseif name == NotifyConsts.EquipSuperChange then
		self:OnSuperChange(body.id);
	elseif name == NotifyConsts.SuperLibRefresh then
		self:ShowLib();
	elseif name == NotifyConsts.SuperLibRemove then
		if body.id == self.currLibId then
			self:UnSelecteLib();
			self:ShowRight();
		end
	elseif name == NotifyConsts.BagItemNumChange then
		if body.id == self.needItemId then
			self:ShowCondition();
		end
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaBindGold or body.type==enAttrType.eaUnBindGold then
			self:ShowCondition();
		end
	end
end

function UIEquipSuperUp:ListNotificationInterests()
	return {NotifyConsts.BagAdd,NotifyConsts.BagRemove,NotifyConsts.BagItemNumChange,NotifyConsts.BagRefresh,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.EquipSuperChange,NotifyConsts.SuperLibRefresh,NotifyConsts.SuperLibRemove};
end

----------------------------------面板飞效果-----------------------
--飞入
function UIEquipSuperUp:FlyIn(fromBag,fromPos)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(fromBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(fromPos);
	if not item then return; end
	local uiItem = nil;
	if fromBag == BagConsts.BagType_Role then
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
	flyVO.tweenParam._width = 48;
	flyVO.tweenParam._height = 48;
	flyVO.onUpdate = function()
		objSwf.btnEquip.hide = true;
	end
	flyVO.onComplete = function()
		objSwf.btnEquip.hide = false;
	end
	FlyManager:FlyIcon(flyVO);
end

--飞出
function UIEquipSuperUp:FlyOut(toBag,toPos)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(toBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(toPos);
	if not item then return; end
	local uiItem = nil;
	if toBag == BagConsts.BagType_Role then
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
		loader._width = 48;
		loader._height = 48;
	end
	flyVO.tweenParam = {};
	flyVO.tweenParam._width = 40;
	flyVO.tweenParam._height = 40;
	FlyManager:FlyIcon(flyVO);
end

-------------------------------------------------以下是引导相关-----------------------------------
--卓越引导,取得一个有空孔的卓越物品
function UIEquipSuperUp:GetSuperUpGuideItem(tid)
	if not self:IsShow() then return; end
	local uiItem,bag,pos = self:GetItemById(tid);
	if uiItem then 
		return uiItem,bag,pos; 
	end
	--
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local i = 1;
	for k,item in pairs(bagVO.itemlist) do
		if EquipModel:CheckSuperHole(item:GetId()) then
			local superVO = EquipModel:GetSuperVO(item:GetId());
			for j=1,superVO.superNum do
				if superVO.superList[j].id == 0 then
					local uiItem = self.objSwf.roleList:getRendererAt(i-1);
					if uiItem then 
						return uiItem,BagConsts.BagType_Role,item:GetPos();
					end
				end
			end
			i = i + 1;
		end
	end
	--
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local i = 1;
	for k,item in pairs(bagVO.itemlist) do
		if item:GetShowType() == BagConsts.ShowType_Equip and EquipModel:CheckSuperHole(item:GetId()) then
			local superVO = EquipModel:GetSuperVO(item:GetId());
			for j=1,superVO.superNum do
				if superVO.superList[j].id == 0 then
					local uiItem = self.objSwf.bagList:getRendererAt(i-1);
					if uiItem then 
						return uiItem,BagConsts.BagType_Bag,item:GetPos();
					end
				end
			end
			i = i + 1;
		end
	end
	return nil;
end

--获得指定id格子
function UIEquipSuperUp:GetItemById(id)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local i = 1;
	for k,item in pairs(bagVO.itemlist) do
		if EquipModel:CheckSuperHole(item:GetId()) then
			if item:GetTid() == id then
				local uiItem = self.objSwf.roleList:getRendererAt(i-1);
				if uiItem then 
					return uiItem,BagConsts.BagType_Role,item:GetPos();
				else
					return nil;
				end
			end
			i = i + 1;
		end
	end
	--
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local i = 1;
	for k,item in pairs(bagVO.itemlist) do
		if item:GetShowType() == BagConsts.ShowType_Equip and EquipModel:CheckSuperHole(item:GetId()) then
			if item:GetTid() == id then
				local uiItem = self.objSwf.bagList:getRendererAt(i-1);
				if uiItem then 
					return uiItem,BagConsts.BagType_Bag,item:GetPos();
				else
					return nil;
				end
			end
			i = i + 1;
		end
	end
	return nil;
end

--卓越引导,提示剥离
function UIEquipSuperUp:GetConfirmBtn()
	if not self:IsShow() then return; end
	return self.objSwf.btnConfirm;
end

--取库中第一个属性
function UIEquipSuperUp:GetFirstLibItem()
	if not self:IsShow() then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if #EquipModel.superLib == 0 then return; end
	local uiItem = objSwf.libList:getRendererAt(0);
	return uiItem;
end

--选中库中第一个
function UIEquipSuperUp:SelectLibFirst()
	if not self:IsShow() then return; end
	if #EquipModel.superLib == 0 then return; end
	self.currLibId = EquipModel.superLib[1].uid;
	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:SetSuperAttrItem(objSwf["btnSuperAttr"..self.currAttrIndex],item,self.currAttrIndex);
end