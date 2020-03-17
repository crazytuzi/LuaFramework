--[[
装备强化面板
lizhuangzhuang
2014年11月13日12:22:12
]]

_G.UIEquipStren = BaseUI:new("UIEquipStren");

--当前选中id
UIEquipStren.currId = nil;
--当前选中格子
UIEquipStren.currPos = -1;
--自动购买
UIEquipStren.autoBuy = false;
--防掉级
UIEquipStren.keepLvl = false;
--是否在自动强化
UIEquipStren.isAutoLvlUp = false;
--自动强化到的等级
UIEquipStren.autoLvlUplist = nil;
UIEquipStren.autoLvlUpLvl = 0;
--连锁按钮
UIEquipStren.linkBtns = {};
--是否使用强化升星符
UIEquipStren.itemLvlUp = false;

function UIEquipStren:Create()
	self:AddSWF("equipStrenPanel.swf",true,nil);
end

function UIEquipStren:OnLoaded(objSwf)
	--设置模型不接受事件
	objSwf.roleLoaderStren.hitTestDisable = true;
	objSwf.panel._visible = false;
	objSwf.maxLvlPanel._visible = false;
	objSwf.nonPanel._visible = false;
	objSwf.btnRule.rollOver = function() TipsManager:ShowBtnTips(StrConfig['equip112'],TipsConsts.Dir_RightDown); end
	objSwf.btnRule.rollOut = function() TipsManager:Hide(); end
	objSwf.list.itemClick = function(e) self:OnRoleEquipItemClick(e); end
	objSwf.list.itemRollOver = function(e) self:OnRoleEquipRollOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
	objSwf.btnEquip.rollOver = function() self:OnBtnEquipRollOver(); end
	objSwf.btnEquip.rollOut = function() TipsManager:Hide(); end
	objSwf.btnEquip.click = function() self:OnBtnEquipClick(); end
	objSwf.btnMaxLvlEquip.rollOver = function() self:OnBtnMaxLvlEquipRollOver(); end
	objSwf.btnMaxLvlEquip.rollOut = function() TipsManager:Hide(); end
	objSwf.panel.siStrenVal.rollOver = function() TipsManager:ShowBtnTips(StrConfig["equip117"]); end
	objSwf.panel.siStrenVal.rollOut = function() TipsManager:Hide(); end
	objSwf.panel.btnNeedItem.click = function() self:OnBtnNeedItemClick(); end
	objSwf.panel.btnNeedItem.rollOver = function() self:OnBtnNeedItemRollOver(); end
	objSwf.panel.btnNeedItem.rollOut = function() TipsManager:Hide(); end
	objSwf.panel.btnNeedMoney.rollOver = function() 
										TipsManager:ShowBtnTips(StrConfig['tips50'],TipsConsts.Dir_RightDown);
										end
	objSwf.panel.btnNeedMoney.rollOut = function() TipsManager:Hide(); end
	objSwf.panel.cbAutoBuy.click = function() self:OnCBAutoBuyClick(); end
	objSwf.panel.cbKeepLvl.click = function() self:OnCBKeepLvlClick(); end
	objSwf.panel.cbKeepLvl.rollOver = function() self:OnCBKeepLvlRollOver(); end
	objSwf.panel.cbKeepLvl.rollOut = function() TipsManager:Hide(); end
	objSwf.panel.cbItemLvUp.click = function() self:OnCBItemLvUpClick(); end
	objSwf.panel.cbItemLvUp.rollOver = function() self:OnBtnItemLvUpRollOver(); end
	objSwf.panel.cbItemLvUp.rollOut = function() TipsManager:Hide(); end
	objSwf.panel.btnStren.click = function() self:OnBtnStrenClick(); end
	objSwf.panel.btnAutoStren.click = function() self:OnBtnAutoStrenClick(); end
	objSwf.panel.btnAutoStren.rollOver = function() 
										TipsManager:ShowBtnTips(StrConfig['equip111'],TipsConsts.Dir_RightDown);
										end
	objSwf.panel.btnAutoStren.rollOut = function() TipsManager:Hide(); end
	objSwf.panel.ddList.change = function(e) self:OnDDListCick(e); end
	objSwf.panel.ddList.rowCount = 5;
	objSwf.panel.btnAutoStren.label = StrConfig["equip107"];
end

function UIEquipStren:OnDelete()
	for k,_ in pairs(self.linkBtns) do
		if self.linkBtns[k] then self.linkBtns[k]:removeMovieClip(); end
		self.linkBtns[k] = nil;
	end;
	if self.objUIDraw then 
		self.objUIDraw:SetUILoader(nil);
	end;
end

function UIEquipStren:OnShow()
	self.autoBuy = false;
	self.keepLvl = false;
	self.itemLvlUp = false;
	self:ShowRoleEquip();
	self:AutoSelectEquip();
	self:ShowStrenLink();
	self:DrawRole();
end

function UIEquipStren:OnHide()
	if self.currPos > -1 then
		self:UnSelectEquip(true);
	end
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
	for k,_ in pairs(self.linkBtns) do
		if self.linkBtns[k] then self.linkBtns[k]:removeMovieClip(); end
		self.linkBtns[k] = nil;
	end;
end

function UIEquipStren:HandleNotification(name,body)
	if name==NotifyConsts.BagAdd or name==NotifyConsts.BagRemove then
		if body.type ~= BagConsts.BagType_Role then return; end
		self:ShowRoleEquip();
		if body.pos == self.currPos then
			self:UnSelectEquip(true);
		end
	elseif name == NotifyConsts.EquipAttrChange then
		self:ShowStrenLink();
	elseif name == NotifyConsts.BagItemNumChange then
		local strenLvl = EquipModel:GetStrenLvl(self.currId);
		local cfg = t_stren[strenLvl+1];
		if cfg then
			if cfg.itemId==body.id then
				self:ShowStrenCondition();
			end
			if cfg.keepItem == body.id then
				self:ShowKeepLvlItem();
			end
		end
		self:ShowStrenItemLvlUpCondition();
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaBindGold or body.type==enAttrType.eaUnBindGold then
			self:ShowStrenCondition();
		end
	end
end

function UIEquipStren:ListNotificationInterests()
	return {NotifyConsts.BagAdd,NotifyConsts.BagRemove,
			NotifyConsts.EquipAttrChange,NotifyConsts.BagItemNumChange,NotifyConsts.PlayerAttrChange};
end

--自动选中装备
function UIEquipStren:AutoSelectEquip()
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local list = {};
	local minLvl = -1;
	local minPos = -1;
	for i,pos in ipairs(EquipConsts.EquipStrenType) do
		local item = bagVO:GetItemByPos(pos);
		if item then
			if minLvl < 0 then
				minLvl = EquipModel:GetStrenLvl(item:GetId());
				minPos = pos;
			else
				if EquipModel:GetStrenLvl(item:GetId()) < minLvl then
					minLvl = EquipModel:GetStrenLvl(item:GetId());
					minPos = pos;
				end
			end
		end
	end
	if minPos > -1 then
		self.currPos = minPos;
		self:ShowEquip();
		local uiItem = self.objSwf.list:getRendererAt(minPos);
		if uiItem then
			uiItem.hide = true;
		end
		
		-- if self.currPos~=minPos then
			-- self:ShowEquip(minPos);
		-- end
		-- local uiItem = self.objSwf.list:getRendererAt(minPos);
		-- if uiItem then
			-- uiItem.hide = true;
		-- end
		-- return;
	else
		self:ShowEquip();
	end
	-- self:ShowStrenNon();
end

--选中装备
function UIEquipStren:SelectEquip(pos)
	if self.isAutoLvlUp then
		self:CancelAutoStren();
	end
	if self.currPos >= 0 then
		self:FlyOut(self.currPos);
	end
	self.currPos = pos;
	self:FlyIn(self.currPos);
	
	self:ShowEquip();
	
end

--取消选中装备
function UIEquipStren:UnSelectEquip(unFly)
	if self.isAutoLvlUp then
		self:CancelAutoStren();
	end
	if self.currPos>=0 then
		if not unFly then
			self:FlyOut(self.currPos);
		end
	end
	self.currPos = -1;
	self.currId = 0;
	self:ShowEquip();
end

--显示装备信息
function UIEquipStren:ShowEquip()
	if self.currPos < 0 then
		self:ShowStrenNon();
		return;
	end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	self.currId = item:GetId();
	local vo = EquipUtil:GetEquipUIVO(self.currPos,true);
	self.objSwf.btnEquip:setData(UIData.encode(vo));
	self.objSwf.tfEquipName.textColor = TipsConsts:GetItemQualityColorVal(item:GetCfg().quality);
	self.objSwf.tfEquipName.text = item:GetCfg().name;
	local strenLvl = EquipModel:GetStrenLvl(self.currId);
	if strenLvl == EquipConsts.StrenMaxLvl then
		self:ShowStrenMaxLvl(self.currPos);
	else
		self:ShowStren(self.currPos);
	end
end

--显示未强化
function UIEquipStren:ShowStrenNon()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.tfEquipName.text = "";
	objSwf.btnEquip:setData("");
	objSwf.btnMaxLvlEquip:setData("");
	objSwf.btnMaxLvlEquip.visible = false;
	objSwf.labelMaxLvl.visible = false;
	objSwf.panel._visible = false;
	objSwf.maxLvlPanel._visible = false;
	objSwf.nonPanel._visible = true;
end

--显示满级
function UIEquipStren:ShowStrenMaxLvl(pos)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.panel._visible = false;
	objSwf.nonPanel._visible = false;
	objSwf.maxLvlPanel._visible = true;
	objSwf.labelMaxLvl.visible = false;
	objSwf.btnMaxLvlEquip.visible = false;
	local panel = objSwf.maxLvlPanel;
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,self.currPos);
	local attrlist = itemTipsVO:GetEquipStrenAttr();
	--
	local typeStr = "";
	typeStr = typeStr .. StrConfig['equip109'] .. "：<br/>";
	for i,attrVO in ipairs(attrlist) do
		typeStr = typeStr .. string.format(StrConfig['equip113'],enAttrTypeName[attrVO.type]) .. "：<br/>";
	end
	panel.tfAttrName.htmlText = typeStr;
	--
	local attrStr = "";
	attrStr = attrStr .. itemTipsVO:GetFight() .. "<br/>";
	for i,attrVO in ipairs(attrlist) do
		attrStr = attrStr .. "+" .. getAtrrShowVal(attrVO.type,attrVO.val) .. "<br/>";
	end
	panel.tfAttr.htmlText = attrStr;
end

--显示强化中
function UIEquipStren:ShowStren(pos)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.panel._visible = true;
	objSwf. nonPanel._visible = false;
	objSwf.maxLvlPanel._visible = false;
	objSwf.labelMaxLvl.visible = true;
	objSwf.btnMaxLvlEquip.visible = true;
	--
	local maxLvlVO = EquipUtil:GetEquipUIVO(pos);
	maxLvlVO.strenLvl = EquipConsts.StrenMaxLvl;
	objSwf.btnMaxLvlEquip:setData(UIData.encode(maxLvlVO));
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	--
	local strenLvl = EquipModel:GetStrenLvl(self.currId);
	local nextStrenLvl = strenLvl + 1;
	local panel = objSwf.panel;
	--当前星星
	if strenLvl <= EquipConsts.StrenMaxStar then
		panel.tfLvl.text = "+" .. strenLvl;
		panel.star.star = "EquipStrenStar";
		panel.star.grayStar = "EquipStrenGrayStar";
		panel.star.offsetY = 0;
		panel.star:updatePosition();
	else
		panel.tfLvl.text = "+" .. (strenLvl - EquipConsts.StrenMaxStar);
		panel.star.star = "EquipStrenGem";
		panel.star.grayStar = "EquipStrenGrayGem";
		panel.star.offsetY = -3;
		panel.star:updatePosition();
	end
	--下级星星
	if nextStrenLvl <= EquipConsts.StrenMaxStar then
		panel.tfNextLvl.text = "+" .. nextStrenLvl;
		panel.nextStar.star = "EquipStrenStar";
		panel.nextStar.grayStar = "EquipStrenGrayStar";
		panel.nextStar.offsetY = 0;
		panel.nextStar:updatePosition();
	else
		panel.tfNextLvl.text = "+" .. (nextStrenLvl - EquipConsts.StrenMaxStar);
		panel.nextStar.star = "EquipStrenGem";
		panel.nextStar.grayStar = "EquipStrenGrayGem";
		panel.nextStar.offsetY = -3;
		panel.nextStar:updatePosition();
	end
	--当前属性,下级属性
	self:ShowStrenAttr();
	--进度
	panel.siStrenVal.visible = strenLvl<EquipConsts.StrenMaxStar;
	panel.mcStartInfo._visible = strenLvl < EquipConsts.StrenMaxStar;
	panel.tfGemSuccess._visible = not(strenLvl < EquipConsts.StrenMaxStar);
	panel.cbKeepLvl._visible = not(strenLvl < EquipConsts.StrenMaxStar);
	panel.labelNoDropLvl.visible = not(strenLvl < EquipConsts.StrenMaxStar);
	panel.cbAutoBuy.visible = strenLvl < EquipConsts.StrenMaxStar;
	panel.cbItemLvUp.visible = strenLvl<EquipConsts.StrenMaxLvl;
	self.autoBuy = strenLvl<EquipConsts.StrenMaxStar and self.autoBuy or false;
	--
	if strenLvl <= EquipConsts.StrenMaxStar then
		panel.siStar.star = "EquipStrenStar";
		panel.siStar.grayStar = "EquipStrenGrayStar";
		panel.siStar.value = strenLvl;
	else
		panel.siStar.star = "EquipStrenGem";
		panel.siStar.grayStar = "EquipStrenStar";
		panel.siStar.value = strenLvl - EquipConsts.StrenMaxStar;
	end
	local cfg = t_stren[nextStrenLvl];
	if not cfg then return; end
	if strenLvl < EquipConsts.StrenMaxStar then
		panel.siStrenVal:GoToAndStopProcess(EquipModel:GetStrenVal(self.currId),cfg.maxVal);
		panel.siStrenVal.tf.text = EquipModel:GetStrenVal(self.currId).."/"..cfg.maxVal;
	end
	if strenLvl >= EquipConsts.StrenMaxStar then
		panel.tfGemSuccess.text = string.format(StrConfig['equip101'],cfg.showSuccess);
		self:ShowKeepLvlItem();
	end
	panel.cbAutoBuy.selected = self.autoBuy;
	panel.cbItemLvUp.selected = self.itemLvlUp;
	self:ShowStrenCondition();
	self:ShowStrenItemLvlUpCondition();
	--
	self:ShowAutoLvlUpList();
end

--显示强化保护道具
function UIEquipStren:ShowKeepLvlItem()
	local strenLvl = EquipModel:GetStrenLvl(self.currId);
	local cfg = t_stren[strenLvl+1];
	if not cfg then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local panel = objSwf.panel;
	if cfg.keepItem > 0 then
		panel.labelNoDropLvl.visible = false;
		panel.cbKeepLvl.visible = true;
		panel.cbKeepLvl.selected = self.keepLvl;
		local keepLvlItemCfg = t_item[cfg.keepItem];
		if not keepLvlItemCfg then return; end
		if BagModel:GetItemNumInBag(cfg.keepItem) < cfg.keepNum then
			panel.cbKeepLvl.htmlLabel = string.format(StrConfig["equip116"],t_item[cfg.keepItem].name);
		else
			panel.cbKeepLvl.htmlLabel = string.format(StrConfig["equip102"],t_item[cfg.keepItem].name);
		end
	else
		panel.labelNoDropLvl.visible = true;
		panel.cbKeepLvl.visible = false;
	end
end

--显示强化条件
function UIEquipStren:ShowStrenCondition()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local panel = objSwf.panel;
	local strenLvl = EquipModel:GetStrenLvl(self.currId);
	local cfg = t_stren[strenLvl+1];
	if not cfg then return; end
	local needItemCfg = t_item[cfg.itemId];
	if needItemCfg then
		local name = needItemCfg.name;
		if BagModel:GetItemNumInBag(cfg.itemId) < cfg.itemNum then
			panel.btnNeedItem.htmlLabel = string.format(StrConfig["equip114"],name,cfg.itemNum);
		else
			panel.btnNeedItem.htmlLabel = string.format(StrConfig["equip103"],name,cfg.itemNum);
		end
	end
	if MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold < cfg.gold then
		panel.btnNeedMoney.htmlLabel = string.format(StrConfig['equip115'],cfg.gold);
	else
		panel.btnNeedMoney.htmlLabel = string.format(StrConfig['equip104'],cfg.gold);
	end
end

--显示强化升星符条件
function UIEquipStren:ShowStrenItemLvlUpCondition()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local panel = objSwf.panel;
	local strenLvl = EquipModel:GetStrenLvl(self.currId);
	local itemId, isEnough = EquipUtil:GetConsumeItem(self.currId);
	if strenLvl<EquipConsts.StrenMaxStar then
		local needItemCfg = t_item[itemId];
		if needItemCfg then
			local name = needItemCfg.name;
			if itemId == EquipConsts.itemLvlUp15Id then
				if isEnough then
					panel.cbItemLvUp.htmlLabel = string.format(StrConfig["equip135"],name.."*1");
				else
					panel.cbItemLvUp.htmlLabel = string.format(StrConfig["equip134"],name.."*1");
				end
			elseif itemId == EquipConsts.itemLvlUpId then
				if isEnough then
					panel.cbItemLvUp.htmlLabel = string.format(StrConfig["equip133"],name.."*1");
				else
					panel.cbItemLvUp.htmlLabel = string.format(StrConfig["equip132"],name.."*1");
				end
			end
		end
	else
		local needItemCfg = t_item[itemId];
		if needItemCfg then
			local name = needItemCfg.name;
			if isEnough then
				panel.cbItemLvUp.htmlLabel = string.format(StrConfig["equip640"],name.."*1");
			else
				panel.cbItemLvUp.htmlLabel = string.format(StrConfig["equip639"],name.."*1");
			end
		end
	end
end

--显示强化属性变化
function UIEquipStren:ShowStrenAttr()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local panel = objSwf.panel;
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,self.currPos);
	local attrlist = itemTipsVO:GetOriginAttrList();
	local nextItemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,self.currPos);
	nextItemTipsVO.strenLvl = nextItemTipsVO.strenLvl + 1;
	local nextAttrlist = nextItemTipsVO:GetOriginAttrList();
	--
	local typeStr = "";
	typeStr = typeStr .. StrConfig['equip109'] .. "：<br/>";
	for i,attrVO in ipairs(nextAttrlist) do
		typeStr = typeStr .. string.format(StrConfig['equip113'],enAttrTypeName[attrVO.type]) .. "：<br/>";
	end
	panel.tfAttrName.htmlText = typeStr;
	panel.tfNextAttrName.htmlText = typeStr;
	--
	local attrStr = "";
	attrStr = attrStr ..itemTipsVO:GetFight() .. "<br/>";
	local nextAttrStr = "";
	nextAttrStr = nextAttrStr ..nextItemTipsVO:GetFight() .. "<br/>";
	for i=1,#attrlist do
		local attrVO = attrlist[i];
		local nextAttrVo = nextAttrlist[i];
		attrStr = attrStr ..getAtrrShowVal(attrVO.type,attrVO.val) .. "<br/>";
		nextAttrStr = nextAttrStr .. getAtrrShowVal(nextAttrVo.type,nextAttrVo.val);
		nextAttrStr = nextAttrStr .. " ↑" .. nextAttrVo.val-attrVO.val;
		nextAttrStr = nextAttrStr .. "<br/>";
	end
	panel.tfAttr.htmlText = attrStr;
	panel.tfNextAttr.htmlText = nextAttrStr;
end

--显示自动强化列表
function UIEquipStren:ShowAutoLvlUpList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.autoLvlUplist = {};
	local strenLvl = EquipModel:GetStrenLvl(self.currId);
	for i=strenLvl+1,EquipConsts.StrenMaxLvl do
		local vo = {};
		vo.strenLvl = i;
		if i > EquipConsts.StrenMaxStar then
			vo.name = string.format(StrConfig['equip106'],i-EquipConsts.StrenMaxStar);
		else
			vo.name = string.format(StrConfig['equip105'],i);
		end
		table.push(self.autoLvlUplist,vo);
	end
	objSwf.panel.ddList.dataProvider:cleanUp();
	for i,vo in ipairs(self.autoLvlUplist) do
		objSwf.panel.ddList.dataProvider:push(vo.name);
	end
	if self.isAutoLvlUp then
		for i,vo in ipairs(self.autoLvlUplist) do
			if vo.strenLvl == self.autoLvlUpLvl then
				objSwf.panel.ddList.selectedIndex = i-1;
				break;
			end
		end
	else
		if self.autoLvlUplist[1].strenLvl > 10 then
			self.autoLvlUpLvl = EquipConsts.StrenMaxLvl;
			objSwf.panel.ddList.selectedIndex = #self.autoLvlUplist - 1;
		else
			for i,vo in ipairs(self.autoLvlUplist) do
				if vo.strenLvl == EquipConsts.StrenMaxStar then
					objSwf.panel.ddList.selectedIndex = i-1;
					self.autoLvlUpLvl = vo.strenLvl;
					break;
				end
			end
		end
		
		for i,vo in ipairs(self.autoLvlUplist) do
			if vo.strenLvl == EquipConsts.StrenMaxStar then
				objSwf.panel.ddList.selectedIndex = i-1;
				self.autoLvlUpLvl = vo.strenLvl;
				break;
			end
		end
	end
end

--选择自动强化到的等级
function UIEquipStren:OnDDListCick(e)
	if self.isAutoLvlUp then return; end
	if self.autoLvlUplist[e.index+1] then
		self.autoLvlUpLvl = self.autoLvlUplist[e.index+1].strenLvl;
	end
end

--切换自动购买
function UIEquipStren:OnCBAutoBuyClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.isAutoLvlUp then
		self:CancelAutoStren();
	end
	self.autoBuy = objSwf.panel.cbAutoBuy.selected;
end

--切换使用强化升星符
function UIEquipStren:OnCBItemLvUpClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.isAutoLvlUp then
		self:CancelAutoStren();
	end
	self.itemLvlUp = objSwf.panel.cbItemLvUp.selected;
end

function UIEquipStren:OnBtnItemLvUpRollOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local strenLvl = EquipModel:GetStrenLvl(self.currId);
	if strenLvl<EquipConsts.StrenMaxStar then
		local itemcfg = t_item[EquipConsts.itemLvlUpId];
		if itemcfg then
			TipsManager:ShowItemTips(EquipConsts.itemLvlUpId);
		end
	else
		local itemcfg = t_item[EquipConsts.itemJZLvlUpId];
		if itemcfg then
			TipsManager:ShowItemTips(EquipConsts.itemJZLvlUpId);
		end
	end
end

--防掉级Tips
function UIEquipStren:OnCBKeepLvlRollOver()
	local strenLvl = EquipModel:GetStrenLvl(self.currId);
	local cfg = t_stren[strenLvl+1];
	if not cfg then return; end
	if cfg.keepItem == 0 then return; end
	TipsManager:ShowItemTips(cfg.keepItem);
end

--切换防掉级
function UIEquipStren:OnCBKeepLvlClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.isAutoLvlUp then
		self:CancelAutoStren();
	end
	local selected = objSwf.panel.cbKeepLvl.selected;
	self.keepLvl = selected;
	--选中时道具不足弹出商店
	if selected then
		local strenLvl = EquipModel:GetStrenLvl(self.currId);
		if not strenLvl then return; end
		local cfg = t_stren[strenLvl+1];
		if not cfg then return; end
		if BagModel:GetItemNumInBag(cfg.keepItem) < cfg.keepNum then
			-- UIShopQuickBuy:Open( cfg.keepItem, UIEquip,UIEquip:GetShopContainer(), cfg.keepNum-BagModel:GetItemNumInBag(cfg.keepItem));
		end
	end
end

--防掉级道具不足
function UIEquipStren:OnKeepLvlItemUnenough()
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.keepLvl = false;
	objSwf.panel.cbKeepLvl.selected = false;
end

UIEquipStren.lastSendTime = 0;
--点击强化
function UIEquipStren:OnBtnStrenClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if GetCurTime() - self.lastSendTime < 200 then
		return;
	end
	self.lastSendTime = GetCurTime();

	if self.isAutoLvlUp then
		self:CancelAutoStren();
	end
	EquipController:StrenEquip(self.currId,self.autoBuy,self.keepLvl,self.itemLvlUp);
end

--点击自动强化
function UIEquipStren:OnBtnAutoStrenClick()
	if self.isAutoLvlUp then
		self:CancelAutoStren();
	else
		self.isAutoLvlUp = true;
		self.objSwf.panel.btnAutoStren.label = StrConfig["equip108"];
		self.objSwf.panel.ddList.disabled = true;
		EquipController:AutoStrenEquip(self.currId,self.autoBuy,self.keepLvl,self.autoLvlUpLvl,self.itemLvlUp)
	end
end

--取消自动强化
function UIEquipStren:CancelAutoStren()
	if not self.isAutoLvlUp then return; end
	self.isAutoLvlUp = false;
	local objSwf = self.objSwf;
	objSwf.panel.btnAutoStren.label = StrConfig["equip107"];
	self.objSwf.panel.ddList.disabled = false;
end

--显示强化结果
function UIEquipStren:OnStrenResult(id,result,strenLvl,strenVal,oldStrenLvl,oldStrenVal)
	if self.currId ~= id then return; end
	local objSwf = self.objSwf;
	local cfg = t_stren[strenLvl+1];
	if result == 0 then
		if strenLvl > oldStrenLvl then
			SoundManager:PlaySfx(2006);
			-- FloatManager:AddSysNotice(2007004);--升星成功
			FloatManager:AddNormal(StrConfig["equip125"],objSwf.panel.siStrenVal);
		end
		if strenLvl==oldStrenLvl and not self.isAutoLvlUp then
			SoundManager:PlaySfx(2005);
		end
		if strenLvl == EquipConsts.StrenMaxStar then
			-- FloatManager:AddSysNotice(2007006);--到高级强化
			FloatManager:AddNormal(StrConfig["equip126"],objSwf.panel.siStrenVal);
		end
		if strenLvl == EquipConsts.StrenMaxLvl then
			-- FloatManager:AddSysNotice(2007007);--强化到满钻
			FloatManager:AddNormal(StrConfig["equip127"],objSwf.panel.siStrenVal);
		end
		if strenLvl==oldStrenLvl and strenLvl < EquipConsts.StrenMaxStar then
			FloatManager:AddNormal(string.format(StrConfig['equip124'],strenVal-oldStrenVal),objSwf.panel.siStrenVal);
			objSwf.panel.siStrenVal:moveToProcess(strenVal,cfg.maxVal);
			objSwf.panel.siStrenVal.tf.text = strenVal.."/"..cfg.maxVal;
		end
	else
		if strenLvl < oldStrenLvl then
			-- FloatManager:AddSysNotice(2007009);--装备掉级 
			FloatManager:AddNormal(StrConfig["equip129"],objSwf.panel.siStrenVal);
		else
			-- FloatManager:AddSysNotice(2007008);--强化失败
			FloatManager:AddNormal(StrConfig["equip128"],objSwf.panel.siStrenVal);
		end
	end
	if strenLvl ~= oldStrenLvl then
		self:ShowEquip(self.currPos);
	end
end

--强化装备tips
function UIEquipStren:OnBtnEquipRollOver()
	if self.currPos < 0 then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,self.currPos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end

function UIEquipStren:OnBtnEquipClick()
	if self.currPos < 0 then return; end
	self:UnSelectEquip();
	TipsManager:Hide();
end

--满级强化tips
function UIEquipStren:OnBtnMaxLvlEquipRollOver()
	if self.currPos < 0 then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,self.currPos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	itemTipsVO.equiped = false;
	itemTipsVO.strenLvl = EquipConsts.StrenMaxLvl;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end

--点击强化道具
function UIEquipStren:OnBtnNeedItemClick()
	local strenLvl = EquipModel:GetStrenLvl(self.currId);
	local cfg = t_stren[strenLvl+1];
	if not cfg then return; end
	-- UIShopQuickBuy:Open( cfg.itemId, UIEquip,UIEquip:GetShopContainer());
end

--强化需要道具Tips
function UIEquipStren:OnBtnNeedItemRollOver()
	local strenLvl = EquipModel:GetStrenLvl(self.currId);
	local cfg = t_stren[strenLvl+1];
	if not cfg then return; end
	TipsManager:ShowItemTips(cfg.itemId);
end

--显示玩家装备
function UIEquipStren:ShowRoleEquip()
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

--玩家装备tips
function UIEquipStren:OnRoleEquipRollOver(e)
	local pos = e.item.pos;
	if pos == self.currPos then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end

--选中玩家装备
function UIEquipStren:OnRoleEquipItemClick(e)
	local pos = e.item.pos;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	if self.currPos == pos then
		return;
	end
	self:SelectEquip(pos);
	TipsManager:Hide();
end

--显示连锁
function UIEquipStren:ShowStrenLink()
	local currLinkId = EquipModel:GetStrenLinkId();
	for i,btn in ipairs(self.linkBtns) do
		btn.visible = false;
	end
	for i,cfg in ipairs(t_strenlink) do
		if currLinkId >= cfg.id then
			self:ShowStrenLinkBtn(i,true);
		else
			self:ShowStrenLinkBtn(i,false);
			break;
		end
	end
end

--显示连锁按钮
function UIEquipStren:ShowStrenLinkBtn(index,active)
	if self.linkBtns[index] then
		self.linkBtns[index].visible = true;
		self.linkBtns[index].disabled = not active;
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local depth = objSwf:getNextHighestDepth();
	local button = objSwf:attachMovie("StrenLinkButton"..index,"linkBtn"..index,depth);
	self.linkBtns[index] = button;
	button._x = 18 + (index-1)*36;
	button._y = 20;
	button.alwaysRollEvent = true;
	button.visible = true;
	button.disabled = not active;
	button.rollOut = function() TipsManager:Hide(); end
	button.rollOver = function() self:OnStrenLinkRollOver(index,button); end
end

--连锁tips
function UIEquipStren:OnStrenLinkRollOver(index,button)
	local linkCfg = t_strenlink[index];
	if not linkCfg then return; end
	local tipsVO = {};
	tipsVO.linkId = index;
	if button.disabled then
		local num = 0;
		local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
		if bagVO then
			for i,pos in ipairs(EquipConsts.EquipStrenType) do
				local item = bagVO:GetItemByPos(pos);
				if item and EquipModel:GetStrenLvl(item:GetId())>=linkCfg.level then
					num = num + 1;
				end
			end
		end
		tipsVO.activeNum = num;
	else
		tipsVO.activeNum = #EquipConsts.EquipStrenType;
	end
	TipsManager:ShowTips(TipsConsts.Type_StrenLink,tipsVO,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end

---------------------------图标飞效果-----------------------------------------
--飞入
function UIEquipStren:FlyIn(fromPos)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(fromPos);
	if not item then return; end
	local flyVO = {};
	flyVO.objName = 'FlyVO'
	local uiItem = objSwf.list:getRendererAt(fromPos);
	if not uiItem then return; end
	flyVO.startPos = UIManager:PosLtoG(uiItem.iconLoader,0,0);
	flyVO.endPos = UIManager:PosLtoG(objSwf.btnEquip.iconLoader,0,0);
	flyVO.time = 0.5;
	flyVO.url = BagUtil:GetItemIcon(item:GetTid(),true);
	flyVO.onStart = function(loader)
		loader._width = 40;
		loader._height = 40;
		uiItem.hide = true;
	end
	flyVO.tweenParam = {};
	flyVO.tweenParam._width = 54;
	flyVO.tweenParam._height = 54;
	flyVO.onUpdate = function()
		objSwf.btnEquip.hide = true;
		uiItem.hide = true;
	end
	flyVO.onComplete = function()
		objSwf.btnEquip.hide = false;
	end
	FlyManager:FlyIcon(flyVO);
end

--飞出
function UIEquipStren:FlyOut(toPos)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	local flyVO = {};
	flyVO.objName = 'FlyVO'
	local uiItem = objSwf.list:getRendererAt(toPos);
	if not uiItem then return; end
	flyVO.startPos = UIManager:PosLtoG(objSwf.btnEquip.iconLoader,0,0);
	flyVO.endPos = UIManager:PosLtoG(uiItem.iconLoader,0,0);
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
		uiItem.hide = false;
		uiItem:setData(UIData.encode(EquipUtil:GetEquipUIVO(toPos)));
	end
	FlyManager:FlyIcon(flyVO);
end

--获取强化按钮
function UIEquipStren:GetStrenBtn()
	if not self:IsShow() then return; end
	return self.objSwf.panel.btnStren;
end


--画模型
function UIEquipStren:DrawRole()
	local uiLoader = self.objSwf.roleLoaderStren;

	
	local vo = {};
	local info = MainPlayerModel.sMeShowInfo;
	vo.prof = MainPlayerModel.humanDetailInfo.eaProf
	vo.arms = info.dwArms
	vo.dress = info.dwDress
	vo.shoulder = info.dwShoulder;
	vo.fashionsHead = info.dwFashionsHead
	vo.fashionsArms = info.dwFashionsArms
	vo.fashionsDress = info.dwFashionsDress
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
		self.objUIDraw = UIDraw:new("rolePanelPlayerStren", self.objAvatar, uiLoader,
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
