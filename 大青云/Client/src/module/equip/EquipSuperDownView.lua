--[[
卓越传承
lizhuangzhuang
2015年1月29日11:13:54
]]

_G.UIEquipSuperDown = BaseUI:new("UIEquipSuperDown");

--孔总数
UIEquipSuperDown.TotalHoleNum = 5;

--显示的人物里的装备
UIEquipSuperDown.roleList = {};
--显示的背包里的装备
UIEquipSuperDown.bagList = {};
--当前选中的背包
UIEquipSuperDown.currBag = -1;
--当前选中的格子
UIEquipSuperDown.currPos = -1;
--选中的属性索引
UIEquipSuperDown.currAttrIndex = 0;
--当前选中的库属性id
UIEquipSuperDown.currLibId = "";
--当前显示属性库
UIEquipSuperDown.curLibList = {};

function UIEquipSuperDown:Create()
	self:AddSWF("equipSuperDown.swf",false,nil);
end

function UIEquipSuperDown:OnLoaded(objSwf)
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
		objSwf["btnNoAttr"..i]._visible = false;
	end
	--
	objSwf.btnNeedMoney.rollOver = function() TipsManager:ShowBtnTips(StrConfig['tips50'],TipsConsts.Dir_RightDown); end
	objSwf.btnNeedMoney.rollOut = function() TipsManager:Hide(); end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	--
	objSwf.libList.itemClick = function(e) self:OnLibListItemClick(e); end
	objSwf.btnLibDelete.click = function() self:OnLibDelete(); end
	objSwf.btnLibDelete.rollOver = function() self:OnLibDeleteTips(); end
	objSwf.btnLibDelete.rollOut = function()TipsManager:Hide(); end

	objSwf.btnBuildScroll.click = function() self:OnBtnBuildScrollClick(); end
	objSwf.btnBuildScroll.rollOver = function() self:OnBtnBuildScrollRollOver(); end
	objSwf.btnBuildScroll.rollOut = function()TipsManager:Hide(); end

	objSwf.btnLibCreate.click = function() self:OnLibCreate(); end
	objSwf.tfInfo.text = StrConfig["equip617"];
	objSwf.btnConfirm.label = StrConfig["equip606"];

	objSwf.okDelete_btn.click = function() self:OkDeleteLibClick()end;
	objSwf.cancelDelete_btn.click = function() self:CanceldeleteClick()end;

	objSwf.mcEdge._visible = false

end

function UIEquipSuperDown:OnShow()
	self.currAttrIndex = 0;
	self:ShowRoleList();
	self:ShowBagList();
	self:ShowRight();
	self:ShowLib();
	self:UpdataDataState();
end

function UIEquipSuperDown:OnHide()
	if self.currBag>-1 or self.currPos>-1 then
		self:UnSelectEquip(true);
	end
	self.bagList = {};
	self.roleList = {};
	self:CloseConfirm()
end

--删除属性

function UIEquipSuperDown:OnLibDeleteTips()
	TipsManager:ShowBtnTips(StrConfig['equip626'],TipsConsts.Dir_RightDown); 
end;

UIEquipSuperDown.isDeleteAtbIng = false;
UIEquipSuperDown.isScrollBuilding = false;
function UIEquipSuperDown:OkDeleteLibClick()
	local label, func
	if self.isDeleteAtbIng then
		label = StrConfig["equip624"]
		func = function() self:OkDeleteLib() end
	elseif self.isScrollBuilding then
		label = StrConfig["equip634"]
		func = function() self:OkBuildScroll() end
	else
		return
	end
	self.erjiPanl2 = UIConfirm:Open(label,func)
end;

function UIEquipSuperDown:CloseConfirm()
	if self.erjiPanl2 then 
		UIConfirm:Close(self.erjiPanl2)
		self.erjiPanl2 = nil
	end;
end

function UIEquipSuperDown:OkDeleteLib()
	local objSwf = self.objSwf;
	
	local delist = {};
	for i,info in ipairs(self.curLibList) do 
		if info.state == 1 then
			local vo = {};
			vo.uid = info.uid;
			table.push(delist,vo)
		end;
	end;
	if #delist <= 0 then 
		FloatManager:AddNormal(StrConfig["equip627"]);
		return 
	end;
	EquipController:SuperLibRemove(delist)

	self:UpdataAtbLib();
	
	self.isDeleteAtbIng = false;
	self.isScrollBuilding = false;
	self:UpdataDataState();
	self:CloseConfirm()
end;

function UIEquipSuperDown:OkBuildScroll()
	local attrlist = {};
	for i,info in ipairs(self.curLibList) do 
		if info.state == 1 then
			table.push( attrlist, {uid = info.uid} )
		end;
	end;
	if #attrlist <= 0 then 
		FloatManager:AddNormal(StrConfig["equip637"]);
		return 
	end;
	EquipController:ReqBuildAttrScroll(attrlist)

	self:UpdataAtbLib();
	
	self.isDeleteAtbIng = false;
	self.isScrollBuilding = false;
	self:UpdataDataState();
	self:CloseConfirm()
end

function UIEquipSuperDown:CanceldeleteClick()
	self.isDeleteAtbIng = false;
	self.isScrollBuilding = false;
	self:UpdataDataState();
	self:UpdataAtbLib();
	self:CloseConfirm()
end;

function UIEquipSuperDown:UpdataAtbLib()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local uilist = {};
	for i,vo in ipairs(self.curLibList) do 
		table.push(uilist,UIData.encode(vo))
	end;
	objSwf.libList.dataProvider:cleanUp();
	objSwf.libList.dataProvider:push(unpack(uilist));
	objSwf.libList:invalidateData();
end;

--删除库属性
function UIEquipSuperDown:OnLibDelete()
	-- if self.currLibId == "" then
	-- 	FloatManager:AddNormal(StrConfig["equip608"]);
	-- 	return;
	-- end
	-- UIConfirm:Open(StrConfig["equip609"],function()
	-- 	EquipController:SuperLibRemove(self.currLibId);
	-- end);
	self.isDeleteAtbIng = true;
	self.isScrollBuilding = false;

	local objSwf = self.objSwf;
	if not objSwf then return end;
	self:UpdataDataState();
end

function UIEquipSuperDown:UpdataDataState()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	objSwf.mcEdge._visible = self.isDeleteAtbIng or self.isScrollBuilding
	objSwf.okDelete_btn._visible = self.isDeleteAtbIng or self.isScrollBuilding
	objSwf.cancelDelete_btn._visible = self.isDeleteAtbIng or self.isScrollBuilding
	objSwf.btnLibDelete._visible = not self.isDeleteAtbIng and not self.isScrollBuilding
	objSwf.btnBuildScroll._visible = not self.isDeleteAtbIng and not self.isScrollBuilding


	for i,info in ipairs(self.curLibList) do 
		info.state = 0;
	end;
	objSwf.libList.selectedIndex = -1;

end;




--显示人物装备
function UIEquipSuperDown:ShowRoleList()
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
function UIEquipSuperDown:ShowBagList()
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
function UIEquipSuperDown:SelectEquip(bag,pos)
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
function UIEquipSuperDown:UnSelectEquip(unFly)
	if self.currBag>=0 and self.currPos>=0 then
		if not unFly then
			self:FlyOut(self.currBag,self.currPos);
		end
	end
	self.currBag = -1;
	self.currPos = -1;
	self.currAttrIndex = 0;
	self:ShowRight();
end

--显示右侧
function UIEquipSuperDown:ShowRight()
	local objSwf = self.objSwf;
	if self.currBag<0 or self.currPos<0 then
		objSwf.btnEquip:setData(UIData.encode({}));
		for i=1,self.TotalHoleNum do
			objSwf["btnSuperAttr"..i].visible = false;
			objSwf["btnNoAttr"..i]._visible = false;
		end
		objSwf.btnNeedMoney.label = "";
		objSwf.nonPanel._visible = true;
		objSwf.lbNeedMoney.visible = false;
		objSwf.btnNeedMoney.visible = false;
		objSwf.btnConfirm.visible = false;
		return;
	end
	objSwf.nonPanel._visible = false;
	objSwf.lbNeedMoney.visible = true;
	objSwf.btnNeedMoney.visible = true;
	objSwf.btnConfirm.visible = true;
	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	local vo = self:GetSlotVO(item,false);
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
		if attrVO.id > 0 then
			self.currAttrIndex = i;
			break;
		end
	end
	if not objSwf["btnSuperAttr"..self.currAttrIndex] then
		self.currAttrIndex = 1;
	end
	objSwf["btnSuperAttr"..self.currAttrIndex].selected = true;
	--
	for i=1,self.TotalHoleNum do
		if i<=superNum then
			objSwf["btnSuperAttr"..i].visible = true;
			self:SetSuperAttrItem(objSwf["btnSuperAttr"..i],item,i);
			objSwf["btnNoAttr"..i]._visible = false;
		else
			objSwf["btnSuperAttr"..i].visible = false;
			objSwf["btnNoAttr"..i]._visible = true;
		end
		objSwf["btnNoAttr"..i].mcEff._visible = false;
	end
end

--显示条件
function UIEquipSuperDown:ShowCondition()
	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	local objSwf = self.objSwf;
	local inheritCfg = t_fujiafix[item:GetCfg().level*10+item:GetCfg().quality];
	local needGold = inheritCfg.downGold;
	if MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold < needGold then
		objSwf.btnNeedMoney.htmlLabel = string.format(StrConfig['equip115'],needGold);
	else
		objSwf.btnNeedMoney.htmlLabel = string.format(StrConfig['equip104'],needGold);
	end
end

--设置卓越属性Item信息
function UIEquipSuperDown:SetSuperAttrItem(uiItem,bagItem,index)
	local superVO = EquipModel:GetSuperVO(bagItem:GetId());
	local attrVO = superVO.superList[index];
	local cfg = t_fujiashuxing[attrVO.id];
	uiItem.iconLoader.source = ResUtil:GetSuperHoleDefault();
	-- if self.currAttrIndex==index and self.currLibId~="" then
	-- 	local superLibVO = EquipModel:GetSuperLibVO(self.currLibId);
	-- 	local attrStr = self:GetSuperAttrStr(superLibVO.id,superLibVO.val1,true);
	-- 	attrStr = attrStr --.. "<font color='#2fe00d'>  （待铭刻）</font>";
	-- 	uiItem.tfName.htmlText = attrStr;
	-- 	local cfg = t_fujiashuxing[superLibVO.id];
	-- 	if cfg then
	-- 		uiItem.iconLoader.source = ResUtil:GetSuperIconUrl(cfg.icon);
	-- 	end
	-- 	if listIndex then 
	-- 		self.libListIndex = listIndex;
	-- 		local attrStr = self:GetSuperAttrStr(attrVO.id,attrVO.val1);
	-- 		self:ShowLib(attrStr);
	-- 	end
	-- else
		if cfg then
			local attrStr = self:GetSuperAttrStr(attrVO.id,attrVO.val1);
			uiItem.tfName.htmlText = attrStr;
			local cfg = t_fujiashuxing[attrVO.id];
			if cfg then
				uiItem.iconLoader.source = ResUtil:GetSuperIconUrl(cfg.icon);
			end
		else
			uiItem.tfName.htmlText = StrConfig["equip602"];
			uiItem.iconLoader:unload();
		end
	-- end
end

function UIEquipSuperDown:GetSuperAttrStr(id,val1)
	local cfg = t_fujiashuxing[id];
	if not cfg then return ""; end
	local attrStr = formatAttrStr(cfg.attrType,val1);
	attrStr = "「"..cfg.name.."」" .. attrStr;
	attrStr = string.format("<font color='%s'>%s</font>",TipsConsts.SuperColor,attrStr);
	return attrStr;
end

function UIEquipSuperDown:OnBtnEquipClick()
	if self.currBag>=0 and self.currPos>=0 then
		self:UnSelectEquip();
	end
end
function UIEquipSuperDown:OnBtnEquipOver()
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
function UIEquipSuperDown:ShowLib()
	local objSwf = self.objSwf;
	objSwf.libList.dataProvider:cleanUp();
	self.curLibList = {};
	for i,vo in ipairs(EquipModel.superLib) do
		local uiVO = {};
		uiVO.uid = vo.uid;
		uiVO.state = 0;
		local name;
		name = self:GetSuperAttrStr(vo.id,vo.val1);
		uiVO.label = name;
		uiVO.iconUrl = "";
		local cfg = t_fujiashuxing[vo.id];
		if cfg then
			uiVO.iconUrl = ResUtil:GetSuperIconUrl(cfg.icon);
		end
		objSwf.libList.dataProvider:push(UIData.encode(uiVO));
		table.push(self.curLibList,uiVO)
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

--点击属性库item
function UIEquipSuperDown:OnLibListItemClick(e)
	self.currLibId = e.item.uid;
	local objSwf = self.objSwf;
	if not objSwf then return; end

	if self.isDeleteAtbIng or self.isScrollBuilding then 
		local index = e.index + 1;
		local uiData = self.curLibList[index];
		if uiData then 
			uiData.state = uiData.state == 0 and 1 or 0;
			uiData = UIData.encode(uiData);
			objSwf.libList.dataProvider[e.index] = uiData;
			local uiItem = objSwf.libList:getRendererAt(e.index);
			if uiItem then
				uiItem:setData(uiData);
			end
		end;
		return 
	else
		objSwf.libList.selectedIndex = -1;
	end;
	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	
	self:SetSuperAttrItem(objSwf["btnSuperAttr"..self.currAttrIndex],item,self.currAttrIndex);
end

function UIEquipSuperDown:OnBtnBuildScrollClick()
	self.isScrollBuilding = true
	self.isDeleteAtbIng = false;
	self:UpdataDataState()
end

function UIEquipSuperDown:OnBtnBuildScrollRollOver()
	TipsManager:ShowBtnTips(StrConfig["equip638"])
end

--点击属性
function UIEquipSuperDown:OnSuperAttrClick(index)
	local oldIndex = self.currAttrIndex;
	self.currAttrIndex = index;
end

--提交
function UIEquipSuperDown:OnBtnConfirmClick()
	if self.currBag<0 or self.currPos<0 then return; end
	local objSwf = self.objSwf;
	if self.currAttrIndex<=0 then return; end
	EquipController:SuperAttrDown(self.currBag,self.currPos,self.currAttrIndex);
end

--用库属性创建道具
function UIEquipSuperDown:OnLibCreate()
	if self.currLibId == "" then
		FloatManager:AddNormal(StrConfig["equip608"]);
		return;
	end
	EquipController:CreateSuperItem(self.currLibId);
end

--
function UIEquipSuperDown:OnRoleItemClick(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	if self.currBag==BagConsts.BagType_Role and self.currPos==pos then
		return;
	end
	self:SelectEquip(BagConsts.BagType_Role,pos);
	TipsManager:Hide();
end
function UIEquipSuperDown:OnRoleItemOver(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end
function UIEquipSuperDown:OnBagItemClick(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	if self.currBag==BagConsts.BagType_Bag and self.currPos==pos then
		return;
	end
	self:SelectEquip(BagConsts.BagType_Bag,pos);
	TipsManager:Hide();
end
function UIEquipSuperDown:OnBagItemOver(e)
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
function UIEquipSuperDown:GetSlotVO(item,isBig)
	local vo = {};
	vo.hasItem = true;
	vo.pos = item:GetPos();
	vo.isBig = isBig and true or false;
	EquipUtil:GetDataToEquipUIVO(vo,item,isBig);
	return vo;
end

--剥离成功
function UIEquipSuperDown:OnSuperAttrDown(eid,index)
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
function UIEquipSuperDown:OnSuperChange(id)
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

function UIEquipSuperDown:HandleNotification(name,body)
	if not UIEquipSuperDown:IsShow() then return end;
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
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaBindGold or body.type==enAttrType.eaUnBindGold then
			self:ShowCondition();
		end
	end
end

function UIEquipSuperDown:ListNotificationInterests()
	return {NotifyConsts.BagAdd,NotifyConsts.BagRemove,NotifyConsts.BagRefresh,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.EquipSuperChange,NotifyConsts.SuperLibRefresh};
end

----------------------------------面板飞效果-----------------------
--飞入
function UIEquipSuperDown:FlyIn(fromBag,fromPos)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(fromBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(fromPos);
	if not item then return; end
	local uiItem = nil;
	if fromBag == BagConsts.BagType_Role then
		uiItem = objSwf.roleList:getRendererAt(fromPos);
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
function UIEquipSuperDown:FlyOut(toBag,toPos)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(toBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(toPos);
	if not item then return; end
	local uiItem = nil;
	if toBag == BagConsts.BagType_Role then
		uiItem = objSwf.roleList:getRendererAt(toPos);
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

-------------------------------------------------以下是引导相关-----------------------------------
--卓越引导,取一个有卓越属性的物品
function UIEquipSuperDown:GetSuperDownGuideItem(tid)
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
				if superVO.superList[j].id > 0 then
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
				if superVO.superList[j].id > 0 then
					local uiItem = self.objSwf.bagList:getRendererAt(i-1);
					if uiItem then 
						return uiItem,BagConsts.BagType_Bag,pos; 
					end
				end
			end
			i = i + 1;
		end
	end
	return nil;
end

--获得指定id格子
function UIEquipSuperDown:GetItemById(id)
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
function UIEquipSuperDown:GetConfirmBtn()
	if not self:IsShow() then return; end
	return self.objSwf.btnConfirm;
end
