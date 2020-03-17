--[[
	传承界面
	2014年12月1日, PM 05:55:00
	wangyanwei 
]]

_G.UIEquipInherit =  BaseUI:new("UIEquipInherit");

--背包装备列表
UIEquipInherit.baglist = {};
--0强化传承,1追加传承
UIEquipInherit.state = 0;
--源装备
UIEquipInherit.srcBag = -1;
UIEquipInherit.srcPos = -1;
--目标装备
UIEquipInherit.tarBag = -1;
UIEquipInherit.tarPos = -1;

--需要道具
UIEquipInherit.needItemId = 0;

function UIEquipInherit:Create()
	self:AddSWF("equipInheritPanel.swf",true,nil);
end;
function UIEquipInherit:OnLoaded(objSwf)
	--设置模型不接受事件
	objSwf.roleLoaderInherit.hitTestDisable = true;
	objSwf.btnRule.rollOver = function () TipsManager:ShowBtnTips(StrConfig['equip150'],TipsConsts.Dir_RightDown);end;
	objSwf.btnRule.rollOut = function () TipsManager:Hide() end;
	--
	objSwf.list.itemRollOver = function(e) self:OnRoleItemOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
	objSwf.list.itemClick = function(e) self:OnRoleItemClick(e); end
	objSwf.baglist.itemRollOver = function(e) self:OnBagItemOver(e); end
	objSwf.baglist.itemRollOut = function(e)TipsManager:Hide(); end
	objSwf.baglist.itemClick = function(e) self:OnBagItemClick(e); end
	--
	objSwf.btnSrcEquip.rollOver = function() self:OnSrcEquipOver(); end
	objSwf.btnSrcEquip.rollOut = function() TipsManager:Hide(); end
	objSwf.btnSrcEquip.click = function() self:OnSrcEquipClick(); end
	objSwf.btnTarEquip.rollOver = function() self:OnTarEquipOver(); end
	objSwf.btnTarEquip.rollOut = function() TipsManager:Hide(); end
	objSwf.btnTarEquip.click = function() self:OnTarEquipClick(); end
	--
	-- objSwf.btnTypeStren.click = function() self:OnBtnTypeStrenClick(); end
	-- objSwf.btnTypeExtra.click = function() self:OnBtnTypeExtraClick(); end
	--
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick(); end
	-- objSwf.btnNeedItem.rollOver = function() if self.needItemId>0 then TipsManager:ShowItemTips(self.needItemId); end end
	-- objSwf.btnNeedItem.rollOut = function() TipsManager:Hide(); end
	objSwf.btnNeedMoney.rollOver = function() TipsManager:ShowBtnTips(StrConfig['tips50'],TipsConsts.Dir_RightDown); end
	objSwf.btnNeedMoney.rollOut = function() TipsManager:Hide(); end
	
	objSwf.lastInherit.complete = function () objSwf.lastInherit.visible = false end
	objSwf.flashInherit.complete = function () objSwf.flashInherit.visible = false;objSwf.nowInherit:playEffect(1); end
	objSwf.nowInherit.complete = function () objSwf.nowInherit.visible = false end
	
	objSwf.cbAutoBuy.visible = false;
end

function UIEquipInherit:OnShow()
	self:ShowEquipList(); -- 显示装备的LIST；
	self:ShowBagEquipList(); --显示背包内的装备
	self.state = 0;
	-- self.objSwf.btnTypeStren.selected = true;
	self:ClearSelect();
	self:DrawRole();
end

function UIEquipInherit:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end;

function UIEquipInherit:OnHide()
	self.baglist = {};
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	UIConfirm:Close(self.uiConfirmID);
end

--显示人物装备list
function UIEquipInherit:ShowEquipList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local list = {};
	for i,pos in ipairs(EquipConsts.EquipStrenType) do
		table.push(list,UIData.encode(EquipUtil:GetEquipUIVO(pos)));
	end
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(list));
	objSwf.list:invalidateData();
end

--显示背包内的装备；
function UIEquipInherit:ShowBagEquipList()
	local objSwf = self.objSwf;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	objSwf.baglist.dataProvider:cleanUp();
	self.baglist = bagVO:GetEquipList();
	for i,item in ipairs(self.baglist) do
		local vo = self:GetSlotVO(BagConsts.BagType_Bag,item:GetPos());
		objSwf.baglist.dataProvider:push(UIData.encode(vo));
	end
	objSwf.baglist:invalidateData();
end

--获取格子VO
function UIEquipInherit:GetSlotVO(bagType,pos,isBig)
	if bagType == BagConsts.BagType_Role then
		return EquipUtil:GetEquipUIVO(pos,isBig);
	end
	local bagVO = BagModel:GetBag(bagType);
	if not bagVO then return {}; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return {}; end
	local vo = {};
	vo.hasItem = true;
	vo.pos = item:GetPos();
	vo.isBig = isBig and true or false;
	EquipUtil:GetDataToEquipUIVO(vo,item,isBig);
	return vo;
end

--人物
function UIEquipInherit:OnRoleItemOver(e)
	local pos = e.item.pos;
	if self.srcBag==BagConsts.BagType_Role and self.srcPos==pos then
		return;
	end
	if self.tarBag==BagConsts.BagType_Role and self.tarPos==pos then
		return;
	end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	itemTipsVO.compareTipsVO = nil;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end
function UIEquipInherit:OnRoleItemClick(e)
	local pos = e.item.pos;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	self:SelectEquip(BagConsts.BagType_Role,item);
end

--背包
function UIEquipInherit:OnBagItemOver(e)
	if not e.item then return; end
	local pos = e.item.pos;
	if not pos then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Bag,pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	itemTipsVO.compareTipsVO = nil;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end
function UIEquipInherit:OnBagItemClick(e)
	-- UIConfirm:Close(self.uiConfirmID);
	if not e.item then return; end
	local pos = e.item.pos;
	if not pos then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	self:SelectEquip(BagConsts.BagType_Bag,item);
end

--选中的装备
function UIEquipInherit:OnSrcEquipOver()
	if self.srcBag<0 or self.srcPos<0 then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(self.srcBag,self.srcPos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	itemTipsVO.compareTipsVO = nil;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end
function UIEquipInherit:OnSrcEquipClick()
	if self.srcBag<0 or self.srcPos<0 then return; end
	self:UnSelectEquip(0);
end
function UIEquipInherit:OnTarEquipOver()
	if self.tarBag<0 or self.tarPos<0 then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(self.tarBag,self.tarPos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	itemTipsVO.compareTipsVO = nil;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end
function UIEquipInherit:OnTarEquipClick()
	if self.tarBag<0 or self.tarPos<0 then return; end
	self:UnSelectEquip(1);
end

--选中装备
function UIEquipInherit:SelectEquip(bagType,item)
	--选中到源装备
	if self.srcBag<0 or self.srcPos<0 then
		--没有对应属性,禁止选中
		if self.state == 0 then
			if EquipModel:GetStrenLvl(item:GetId()) == 0 then
				FloatManager:AddNormal(StrConfig['equip250']);
				return;
			end
		else
			if EquipModel:GetExtraLvl(item:GetId()) == 0 then
				FloatManager:AddNormal(StrConfig['equip258']);
				return;
			end
		end
		if bagType==self.tarBag and item:GetPos()==self.tarPos then 
			FloatManager:AddNormal(StrConfig["equip259"]);
			return; 
		end
		self:FlyIn(bagType,item:GetPos(),0);
		self.srcBag = bagType;
		self.srcPos = item:GetPos();
		self:ShowEquip(0);
		self.objSwf.btnSrcEquip.hide = true;
		TipsManager:Hide();
		return;
	end
	--选中到目标装备
	if bagType==self.srcBag and item:GetPos()==self.srcPos then
		FloatManager:AddNormal(StrConfig["equip259"]);
		return;
	end
	
	-- local func = function()
		--目标装备已有,飞出
	if self.tarBag>=0 and self.tarPos>=0 then
		self:FlyOut(self.tarBag,self.tarPos,1);
	end
	self:FlyIn(bagType,item:GetPos(),1);
	self.tarBag = bagType;
	self.tarPos = item:GetPos();
	self:ShowEquip(1);
	self.objSwf.btnTarEquip.hide = true;
	TipsManager:Hide();
	-- end
	-- if item:GetBindState() ~= 3 then
		-- self.uiConfirmID = UIConfirm:Open(StrConfig['equip153'],func);
	-- else
		-- func();
	-- end
	
end

--取消选中装备
--@param type  0,源装备;1,目标装备
function UIEquipInherit:UnSelectEquip(type)
	if type == 0 then
		if self.srcBag<0 or self.srcPos<0 then return; end
		self:FlyOut(self.srcBag,self.srcPos,0);
		self.srcBag = -1;
		self.srcPos = -1;
		self:ShowEquip(0);
		return;
	end
	--
	if self.tarBag<0 or self.tarPos<0 then return; end
	self:FlyOut(self.tarBag,self.tarPos,1);
	self.tarBag = -1;
	self.tarPos = -1;
	self:ShowEquip(1);
end


--清除选中的装备
function UIEquipInherit:ClearSelect()
	local objSwf = self.objSwf;
	if self.srcBag == BagConsts.BagType_Role then
		local uiItem = objSwf.list:getRendererAt(self.srcPos);
		if uiItem then uiItem.hide = false; end
	end
	if self.tarBag == BagConsts.BagType_Role then
		local uiItem = objSwf.list:getRendererAt(self.tarPos);
		if uiItem then uiItem.hide = false; end
	end
	self.srcBag = -1;
	self.srcPos = -1;
	self.tarBag = -1;
	self.tarPos = -1;
	self:ShowEquip(0);
	self:ShowEquip(1);
end

--切换状态
function UIEquipInherit:OnBtnTypeStrenClick()
	if self.state == 0 then return; end
	self.state = 0;
	self:ClearSelect();
end
function UIEquipInherit:OnBtnTypeExtraClick()
	if self.state == 1 then return; end
	self.state = 1;
	self:ClearSelect();
end

--显示选中的装备
--@param type  0,源装备;1,目标装备
function UIEquipInherit:ShowEquip(type)
	local objSwf = self.objSwf;
	if type == 0 then
		if self.srcBag<0 or self.srcPos<0 then
			objSwf.btnSrcEquip:setData(UIData.encode({}));
			-- objSwf.btnNeedItem.label = "";
			objSwf.btnNeedMoney.label = "";
			self.needItemId = 0;
			return;
		end
		local vo = self:GetSlotVO(self.srcBag,self.srcPos,true);
		objSwf.btnSrcEquip:setData(UIData.encode(vo));
		self:ShowCondition();
		return;
	end
	if type == 1 then
		if self.tarBag<0 or self.tarPos<0 then
			objSwf.btnTarEquip:setData(UIData.encode({}));
			return;
		end	
		local vo = self:GetSlotVO(self.tarBag,self.tarPos,true);
		objSwf.btnTarEquip:setData(UIData.encode(vo));
	end
end

--显示条件
function UIEquipInherit:ShowCondition()
	local objSwf = self.objSwf;
	local bagVO = BagModel:GetBag(self.srcBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.srcPos);
	if not item then return; end
	if self.state == 0 then
		local cfg = t_strentrans[item:GetCfg().level];
		local contItemNum = cfg["costNum" .. (item:GetCfg().quality+1)];
		-- self.needItemId = cfg.costItem;
		-- local needItemCfg = t_item[cfg.costItem];
		-- if BagModel:GetItemNumInBag(cfg.costItem) < contItemNum then
			-- objSwf.btnNeedItem.htmlLabel = string.format(StrConfig["equip114"],needItemCfg.name,contItemNum);
		-- else
			-- objSwf.btnNeedItem.htmlLabel = string.format(StrConfig["equip103"],needItemCfg.name,contItemNum)
		-- end
		if MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold < contItemNum then
			objSwf.btnNeedMoney.htmlLabel = string.format(StrConfig['equip115'],contItemNum);
		else
			objSwf.btnNeedMoney.htmlLabel = string.format(StrConfig['equip104'],contItemNum);
		end
		return;
	end
	----
	-- local zjCfg = t_consts[35];
	-- if not zjCfg then return end
	-- local param = split(zjCfg.param,',');
	-- if BagModel:GetItemNumInBag(param[1]) < toint(param[2]) then
		-- objSwf.btnNeedItem.htmlLabel = string.format(StrConfig["equip114"],t_item[toint(param[1])].name,param[2]);
	-- else
		-- objSwf.btnNeedItem.htmlLabel = string.format(StrConfig["equip103"],t_item[toint(param[1])].name,param[2]);
	-- end
	--objSwf.btnNeedItem.label = "";
	-- self.needItemId = toint(param[1]);
	-- local gold = t_consts[35].val1;
	-- if MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold < gold then
		-- objSwf.btnNeedMoney.htmlLabel = string.format(StrConfig['equip115'],gold);
	-- else
		-- objSwf.btnNeedMoney.htmlLabel = string.format(StrConfig['equip104'],gold);
	-- end
end

--点击提交
function UIEquipInherit:OnBtnConfirmClick()
	local srcBag = BagModel:GetBag(self.srcBag);
	if not srcBag then 
		FloatManager:AddNormal(StrConfig['equip256']);
		return; 
	end
	local srcItem = srcBag:GetItemByPos(self.srcPos);
	if not srcItem then 
		FloatManager:AddNormal(StrConfig['equip256']);
		return; 
	end
	--
	local tarBag = BagModel:GetBag(self.tarBag);
	if not tarBag then 
		FloatManager:AddNormal(StrConfig['equip255']);
		return; 
	end
	local tarItem = tarBag:GetItemByPos(self.tarPos);
	if not tarItem then
		FloatManager:AddNormal(StrConfig['equip255']);
		return;
	end
	-----
	--强化传承
	if EquipModel:GetStrenLvl(srcItem:GetId()) == EquipModel:GetStrenLvl(tarItem:GetId()) then 
		FloatManager:AddNormal(StrConfig['equip263']); 
		return; 
	end
	if EquipModel:GetStrenLvl(srcItem:GetId()) < EquipModel:GetStrenLvl(tarItem:GetId()) then 
		FloatManager:AddNormal(StrConfig['equip253']); 
		return; 
	end
	
	local cfg = t_strentrans[srcItem:GetCfg().level];
	local contItemNum = cfg["costNum" .. (srcItem:GetCfg().quality+1)];
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local num = playerinfo.eaBindGold + playerinfo.eaUnBindGold;
	if num < contItemNum then 
		if self.objSwf.cbAutoBuy.selected == false then 
			FloatManager:AddNormal(StrConfig['equip252']);
			return 
		end
	end
	local func = function ()
		-- print(srcItem:GetId(),tarItem:GetId())
		-- print('============================-----------------=================')
		EquipController:OnEquipInherit(srcItem:GetId(),tarItem:GetId(),false)--self.objSwf.cbAutoBuy.selected);
		self.objSwf.lastInherit:playEffect(1);
	end
	if EquipModel:GetStrenLvl(tarItem:GetId()) > 0 then
		UIConfirm:Open(StrConfig['equip152'],func)
	elseif tarItem:GetBindState() ~= 3 then
		UIConfirm:Open(StrConfig['equip153'],func)
	else 
		func();
	end
end

--成功特效
function UIEquipInherit:OnPlayWinEffect()
	local objSwf = self.objSwf;
	if objSwf then 
		objSwf.flashInherit.visible = true;
		objSwf.flashInherit:playEffect(1);
	end
end

--强化传承返回处理,交换数据
function UIEquipInherit:OnStrenInheirtResult(result,srcId,tarId)
	if result == 0 then
		self:OnPlayWinEffect();
	end
	if not self.bShowState then return; end
	if self.state ~= 0 then return; end
	local srcBag = BagModel:GetBag(self.srcBag);
	if not srcBag then return; end
	local srcItem = srcBag:GetItemByPos(self.srcPos);
	if not srcItem then return; end
	local tarBag = BagModel:GetBag(self.tarBag);
	if not tarBag then return; end
	local tarItem = tarBag:GetItemByPos(self.tarPos);
	if not tarItem then return;end
	--
	local objSwf = self.objSwf;
	if srcItem:GetId() == srcId then
		self:ShowEquip(0);
		local vo = self:GetSlotVO(self.srcBag,self.srcPos);
		if self.srcBag == BagConsts.BagType_Role then
			objSwf.list.dataProvider[self.srcPos] = UIData.encode(vo);
		else
			local pos = -1;
			for i,bagItem in ipairs(self.baglist) do
				if bagItem:GetPos() == self.srcPos then
					pos = i-1;
					break;
				end
			end
			if pos>=0 then  
				objSwf.baglist.dataProvider[pos] = UIData.encode(vo);
			end
		end
		local uiItem = self:GetUIItem(self.srcBag,self.srcPos);
		if uiItem then
			uiItem:setData(UIData.encode(vo));
			if self.srcBag == BagConsts.BagType_Role then
				uiItem.hide = true;
			end
		end
	end
	if tarItem:GetId() == tarId then
		self:ShowEquip(1);
		local vo = self:GetSlotVO(self.tarBag,self.tarPos);
		if self.tarBag == BagConsts.BagType_Role then
			objSwf.list.dataProvider[self.tarPos] = UIData.encode(vo);
		else
			local pos = -1;
			for i,bagItem in ipairs(self.baglist) do
				if bagItem:GetPos() == self.tarPos then
					pos = i-1;
					break;
				end
			end
			if pos>=0 then  
				objSwf.baglist.dataProvider[pos] = UIData.encode(vo);
			end
		end
		local uiItem = self:GetUIItem(self.tarBag,self.tarPos);
		if uiItem then
			uiItem:setData(UIData.encode(vo));
			if self.tarBag == BagConsts.BagType_Role then
				uiItem.hide = true;
			end
		end
	end
end

function UIEquipInherit:HandleNotification(name,body)
	if name == NotifyConsts.BagItemNumChange then
		if body.id == self.needItemId then 
			self:ShowCondition();
		end
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaBindGold or body.type==enAttrType.eaUnBindGold then
			self:ShowCondition();
		end
	elseif name == NotifyConsts.EquipInherEffect then
		self:OnPlayWinEffect();
	end
end
function UIEquipInherit:ListNotificationInterests()
	return {NotifyConsts.BagItemNumChange,NotifyConsts.PlayerAttrChange,NotifyConsts.EquipInherEffect}
end


---------------------------------------图标飞效果----------------------
--飞入
--@param type  0,源装备;1,目标装备
function UIEquipInherit:FlyIn(fromBag,fromPos,type)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(fromBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(fromPos);
	if not item then return; end
	local uiItem = self:GetUIItem(fromBag,fromPos);
	if not uiItem then return; end
	local flyVO = {};
	flyVO.objName = 'FlyVO'
	flyVO.startPos = UIManager:PosLtoG(uiItem.iconLoader,0,0);
	if type == 0 then
		flyVO.endPos = UIManager:PosLtoG(objSwf.btnSrcEquip.iconLoader,0,0);
	else
		flyVO.endPos = UIManager:PosLtoG(objSwf.btnTarEquip.iconLoader,0,0);
	end
	flyVO.time = 0.5;
	flyVO.url = BagUtil:GetItemIcon(item:GetTid(),true);
	flyVO.onStart = function(loader)
		loader._width = 40;
		loader._height = 40;
		if fromBag == BagConsts.BagType_Role then
			uiItem.hide = true;
		end
	end
	flyVO.tweenParam = {};
	flyVO.tweenParam._width = 54;
	flyVO.tweenParam._height = 54;
	flyVO.onUpdate = function()
		if type == 0 then
			objSwf.btnSrcEquip.hide = true;
		else
			objSwf.btnTarEquip.hide = true;
		end
		if fromBag == BagConsts.BagType_Role then
			uiItem.hide = true;
		end
	end
	flyVO.onComplete = function()
		if type == 0 then
			objSwf.btnSrcEquip.hide = false;
		else
			objSwf.btnTarEquip.hide = false;
		end
	end
	FlyManager:FlyIcon(flyVO);
end

--飞出
function UIEquipInherit:FlyOut(toBag,toPos,type)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(toBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(toPos);
	if not item then return; end
	local uiItem = self:GetUIItem(toBag,toPos);
	--
	local flyVO = {};
	flyVO.objName = 'FlyVO'
	if type == 0 then
		flyVO.startPos = UIManager:PosLtoG(objSwf.btnSrcEquip.iconLoader,0,0);
	else
		flyVO.startPos = UIManager:PosLtoG(objSwf.btnTarEquip.iconLoader,0,0);
	end
	if uiItem then
		flyVO.endPos = UIManager:PosLtoG(uiItem.iconLoader,0,0);
	else
		flyVO.endPos = UIManager:PosLtoG(objSwf,objSwf.scrollbar._x-40,objSwf.scrollbar._y+15);
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
	flyVO.onComplete = function()
		if toBag == BagConsts.BagType_Role then
			uiItem.hide = false;
		end
	end
	FlyManager:FlyIcon(flyVO);
end

function UIEquipInherit:GetUIItem(bagType,pos)
	local objSwf = self.objSwf;
	if bagType == BagConsts.BagType_Role then
		return objSwf.list:getRendererAt(pos);
	end
	for i,bagItem in ipairs(self.baglist) do
		if bagItem:GetPos() == pos then
			return objSwf.baglist:getRendererAt(i-1);
		end
	end
	return nil;
end

--画模型
function UIEquipInherit:DrawRole()
	local uiLoader = self.objSwf.roleLoaderInherit;

	
	local vo = {};
	local info = MainPlayerModel.sMeShowInfo;
	vo.prof = MainPlayerModel.humanDetailInfo.eaProf
	vo.arms = info.dwArms
	vo.dress = info.dwDress
	vo.fashionsHead = info.dwFashionsHead
	vo.fashionsArms = info.dwFashionsArms
	vo.fashionsDress = info.dwFashionsDress
	vo.shoulder = info.dwShoulder;
	vo.wuhunId = 0;--SpiritsModel:GetFushenWuhunId()
	vo.wing = info.dwWing
	vo.suitflag = info.suitflag
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;	
	end
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar:CreateByVO(vo);
	--
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
    if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("rolePanelPlayerInherit", self.objAvatar, uiLoader,
							UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos,
							0x00000000,"UIRole", prof);
	else
		self.objUIDraw:SetUILoader(uiLoader);
		self.objUIDraw:SetCamera(UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos);
		self.objUIDraw:SetMesh(self.objAvatar);
	end
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	self.objUIDraw:SetDraw(true);
	self.objAvatar:PlayLianhualuAction()
	-- --播放特效
	-- local sex = MainPlayerModel.humanDetailInfo.eaSex;
	-- local pfxName = "ui_role_sex" ..sex.. ".pfx";
	-- local name,pfx = self.objUIDraw:PlayPfx(pfxName);
	-- 微调参数
	--pfx.transform:setRotationX(UIDrawRoleCfg[prof].pfxRotationX);
end


