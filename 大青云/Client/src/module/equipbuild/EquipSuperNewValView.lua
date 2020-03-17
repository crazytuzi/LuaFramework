 --[[
卓越洗练
wangshuai
2015年11月28日16:06:12
 ]]

 _G.UIEquipSuperNewWash = BaseUI:new("UIEquipSuperNewWash")

UIEquipSuperNewWash.maxSuperLengh = 3;
--显示的人物里的装备
UIEquipSuperNewWash.roleList = {};
--显示的背包里的装备
UIEquipSuperNewWash.bagList = {};
--当前选中 bag
UIEquipSuperNewWash.currBag = -1;
--当前选中 pos
UIEquipSuperNewWash.currPos = -1;
--选中的idnex
UIEquipSuperNewWash.currAttrIndex = 1;

function UIEquipSuperNewWash:Create()
 	self:AddSWF("equipSupernewPanel.swf",true,nil)
end;

function UIEquipSuperNewWash:OnLoaded(objSwf)

	objSwf.roleList.itemClick = function(e) self:OnRoleItemClick(e); end
	objSwf.roleList.itemRollOver = function(e) self:OnRoleItemOver(e); end
	objSwf.roleList.itemRollOut = function() TipsManager:Hide(); end

	objSwf.bagList.itemClick = function(e) self:OnBagItemClick(e); end
	objSwf.bagList.itemRollOver = function(e) self:OnBagItemOver(e); end
	objSwf.bagList.itemRollOut = function() TipsManager:Hide(); end

	objSwf.btnEquip.rollOver = function() self:OnBtnEquipOver(); end
	objSwf.btnEquip.rollOut = function() TipsManager:Hide(); end
	objSwf.btnEquip.click = function() self:OnBtnEquipClick(); end

	RewardManager:RegisterListTips(objSwf.myItemList);

	objSwf.btnConfirm.click = function() self:WashClick()end;

	for i=1,self.maxSuperLengh do
		objSwf["btnNoAttr"..i].click = function() self:OnSuperAttrClick(i); end
	end

	objSwf.savePanel.saceWash_btn.click = function() self:SaveWashClick()end;
	objSwf.savePanel.cancelWash_btn.click = function() self:CancelWashClick()end;

	objSwf.btnRule.rollOver = function() self:OnBtnRuleOver() end;
 	objSwf.btnRule.rollOut = function() TipsManager:Hide()end;

 	objSwf.savePanel.jixuWash_btn.click = function() self:JixuWashClick()end;
end;

function UIEquipSuperNewWash:WashAtb()
	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	local equipCfg = t_equip[item:GetTid()]
	if not equipCfg then return end;
	local superVO = EquipModel:GetNewSuperVO(item:GetId());
	if not superVO then return; end
	local newSuperList = superVO.newSuperList;
	local NbSuperVal = 0;

	for ak,kao in ipairs(newSuperList) do 
		local cfg = t_zhuoyueshuxing[kao.id];
		if cfg and cfg.isBest then 
			NbSuperVal = NbSuperVal + 1;
		end
	end;

	local washId = equipCfg.pos * 1000 + NbSuperVal + equipCfg.level * 10;
	local washCfg = t_equipsuperwash[washId];
	local xiaohaoList = {};
	if washCfg then 
		local data = split(washCfg.cost,'#')
		for da,xiaohao in ipairs(data) do 
			local xcfg = split(xiaohao,",");
			local vo = {};
			vo.id = toint(xcfg[1]);               
			vo.num = toint(xcfg[2]);
			table.push(xiaohaoList,vo)
		end;
	end;

	for re,hao in ipairs(xiaohaoList) do 
		if hao then 
			local num = BagModel:GetItemNumInBag(hao.id)
			if num < hao.num then 
				--不够
				FloatManager:AddNormal(StrConfig["equip507"]);--道具不足
				return
			end;
		end;
	end;

	EquipController:UpSuperNewWash(item:GetId(),self.currAttrIndex)
end;

function UIEquipSuperNewWash:JixuWashClick()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if self.wocaoNbWash then 
		local func = function ()
			self:WashAtb();
			self.wocaoNbWash = false;
		end
		self.erjiPanel = UIConfirm:Open(StrConfig['equipWash004'],func);
		return 
	end;
	self:WashAtb();
end;

function UIEquipSuperNewWash:OnBtnRuleOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	TipsManager:ShowBtnTips(StrConfig["equipWash002"],TipsConsts.Dir_RightDown);
end


function UIEquipSuperNewWash:OnShow()
	--当前选中 bag
	UIEquipSuperNewWash.currBag = -1;
	--当前选中 pos
	UIEquipSuperNewWash.currPos = -1;
	--选中的idnex
	UIEquipSuperNewWash.currAttrIndex = 1;
	--牛逼属性
	UIEquipSuperNewWash.wocaoNbWash = false;

	self:ShowRoleList();
	self:ShowBagList();
	self:ShowRight();
	self:ShowCanWashAtb();
end;

function UIEquipSuperNewWash:OnHide()
	self.bagList = {};
	self.roleList = {};
	self.wocaoNbWash = false;
	UIConfirm:Close(self.erjiPanel)
	self.currAttrIndex = 0;
end;

function UIEquipSuperNewWash:ShowCanWashAtb()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	objSwf.libList.dataProvider:cleanUp();
	objSwf.libList.dataProvider:push( unpack({}) );
	objSwf.libList:invalidateData();

	local uidata = {};
	

	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	local equipCfg = t_equip[item:GetTid()]
	if not equipCfg then return end;
	local superVO = EquipModel:GetNewSuperVO(item:GetId());
	if not superVO then return; end
	local newSuperList = superVO.newSuperList;
	local NbSuperVal = 0;

	for ak,kao in ipairs(newSuperList) do 
		local cfg = t_zhuoyueshuxing[kao.id];
		if cfg and cfg.isBest then 
			NbSuperVal = NbSuperVal + 1;
		end
	end;

	local washId = 1000000 + (equipCfg.level * 10000) + (equipCfg.pos * 100) + equipCfg.quality;

	local washCfg = {};
	if NbSuperVal == 0 then 
		washCfg = t_zhuoyuewash0[washId];
	elseif NbSuperVal == 1 then 
		washCfg = t_zhuoyuewash1[washId];
	elseif NbSuperVal == 2 then 
		washCfg = t_zhuoyuewash2[washId];
	elseif NbSuperVal == 3 then 
		washCfg = t_zhuoyuewash3[washId];
	end

	local attrLenght = 10;
	for ao=1,attrLenght do 
		if washCfg["attr"..ao] and washCfg["attr"..ao] ~= "" then 
			local supercfg = split(washCfg["attr"..ao],',')
			local supCgg = t_zhuoyueshuxing[toint(supercfg[1])];
			if supCgg then 
				local valList = split(supCgg.washrange,"#");
				local miniVal = split(valList[1],",");
				local maxVal 	= split(valList[#valList],',');
				local txtStr = ""
				local typeName = AttrParseUtil.AttMap[supCgg.attrType];
				if typeName then
					local str = miniVal[2] .."~" ..maxVal[3]
					if attrIsX(typeName) then
						if attrIsPercent(typeName) then
							txtStr = enAttrTypeName[typeName] ..string.format("%0.2f",tonumber(miniVal[2])/10000) .."~"..string.format("%0.2f",tonumber(maxVal[3])/10000);
						else
							txtStr = enAttrTypeName[typeName] .. str;
						end
					elseif attrIsPercent(typeName) then
						txtStr = enAttrTypeName[typeName] .." +"..string.format("%0.2f%%",tonumber(miniVal[2])/100) .."~"..string.format("%0.2f%%",tonumber(maxVal[3])/100);
					else
						txtStr = enAttrTypeName[typeName] .." +".. str;
					end
				end

				local attrStr = "卓越 （";
				attrStr = attrStr .. txtStr
				attrStr = attrStr .. "）  ";

				local vo = {};
				vo.label = attrStr
				table.push(uidata,UIData.encode(vo))
			end;
		end;
	end

	objSwf.libList.dataProvider:cleanUp();
	objSwf.libList.dataProvider:push( unpack(uidata) );
	objSwf.libList:invalidateData();
end;

function UIEquipSuperNewWash:SetWashTemporary()
	if not self:IsShow() then return end;
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self:ShowRight();

	objSwf.savePanel._visible = true;
	local data = EquipModel.washTemporaryData

	local uiItem = objSwf["btnNoAttr"..data.idx];

	uiItem.tfName.htmlText = self:GetSuperNewAttrStr(data.id,data.wash);
	uiItem.save_txt.htmlText = "待保存"
	local cfg = t_zhuoyueshuxing[data.id];
	if cfg.isBest then 
		uiItem.jiping._visible = true;
		self.wocaoNbWash = true;
	else
		uiItem.jiping._visible = false;
	end;
end;

function UIEquipSuperNewWash:SaveWashClick()
	
	--self:ShowRight();
	local data = EquipModel.washTemporaryData
	EquipController:SaveSuperNewWash(data.cid,data.idx)
	self.wocaoNbWash = false;
end;

function UIEquipSuperNewWash:CancelWashClick()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self:ShowRight();
	self.wocaoNbWash = false;
end;

function UIEquipSuperNewWash:OnSuperAttrClick(i)
	self.currAttrIndex = i
end;

function UIEquipSuperNewWash:WashClick()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	local superVO = EquipModel:GetNewSuperVO(item:GetId());
	if not superVO then return; end
	local newSuperList = superVO.newSuperList[self.currAttrIndex];
	local cfg = t_zhuoyueshuxing[newSuperList.id];
	if cfg and cfg.isBest then 
		local func = function ()
			self:WashAtb();
		end
		self.erjiPanel = UIConfirm:Open(StrConfig['equipWash005'],func);
		return 
	end;
	
	self:WashAtb();
end;

--选中装备
function UIEquipSuperNewWash:SelectEquip(bag,pos)
	if self.currBag>=0 and self.currPos>=0 then
		self:FlyOut(self.currBag,self.currPos);
	end
	self:FlyIn(bag,pos);
	self.currBag = bag;
	self.currPos = pos;
	self:ShowRight();
	self.objSwf.btnEquip.hide = true;
end

--显示右侧面板
function UIEquipSuperNewWash:ShowRight()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.savePanel._visible = false;
	if self.currBag<0 or self.currPos<0 then
		objSwf.btnEquip:setData(UIData.encode({}));
		objSwf.nonPanel._visible = true;
		return;
	end

	objSwf.nonPanel._visible = false;
	--显示装备icon
	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	local vo = self:GetSlotVO(item);
	objSwf.btnEquip:setData(UIData.encode(vo));
	--
	local superVO = EquipModel:GetNewSuperVO(item:GetId());
	if not superVO then return; end
	local newSuperList = superVO.newSuperList;
	local NbSuperVal = 0;
	for i=1,self.maxSuperLengh do 
		local info = newSuperList[i];
		local uiItem = objSwf["btnNoAttr"..i];
		if i == self.currAttrIndex then 
			uiItem.selected = true;
		else
			uiItem.selected = false;
		end;
		if info.id and info.id > 0 then 
			if uiItem then 
				uiItem.tfName.htmlText = self:GetSuperNewAttrStr(info.id,info.wash)
				uiItem.save_txt.htmlText = ""
				local cfg = t_zhuoyueshuxing[info.id];
				if cfg and cfg.isBest then 
					uiItem.jiping._visible = true;
					NbSuperVal = NbSuperVal + 1;
				else
					uiItem.jiping._visible = false;
				end;
			end;
			uiItem._visible = true;
		else
			uiItem._visible = false;
		end;
	end;
	self:UpdataXiaohaoNum()
end;

function UIEquipSuperNewWash:UpdataXiaohaoNum()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(self.currPos);
	if not item then return; end
	--
	local superVO = EquipModel:GetNewSuperVO(item:GetId());
	if not superVO then return; end
	local newSuperList = superVO.newSuperList;
	local NbSuperVal = 0;
	for aa,iis in ipairs(newSuperList) do 
		local cfg = t_zhuoyueshuxing[iis.id];
		if cfg and cfg.isBest then 
			NbSuperVal = NbSuperVal + 1;
		end;		
	end;
	--
	local equipCfg = t_equip[item:GetTid()]
	if not equipCfg then return end;
	local washId = equipCfg.pos * 1000 + NbSuperVal + equipCfg.level * 10;
	local washCfg = t_equipsuperwash[washId];
	local xiaohaoList = {};
	if washCfg then 
		local data = split(washCfg.cost,'#')
		for da,xiaohao in ipairs(data) do 
			local xcfg = split(xiaohao,",");
			local vo = {};
			vo.id = toint(xcfg[1]);               
			vo.num = toint(xcfg[2]);
			table.push(xiaohaoList,vo)
		end;
	end;
	--
	for re=1,4  do 
		local hao = xiaohaoList[re]
		if hao then 
			local itemvo = RewardSlotVO:new()
			itemvo.id = hao.id;
			itemvo.count = 0;
			objSwf["item"..re]:setData(itemvo:GetUIData());

			local num = BagModel:GetItemNumInBag(hao.id)
			local color = "#ff0000"
			if num >= hao.num then 
				--ff0000
				color = "#00ff00"
			else
				color = "#ff0000"
			end;
			objSwf["xiaohao_"..re].htmlText = string.format(StrConfig["equipWash001"],color,num,hao.num)
		else
			objSwf["xiaohao_"..re].htmlText = ""
			objSwf["item"..re]:setData({});
		end;
	end;
end;

--属性格式化
function UIEquipSuperNewWash:GetSuperNewAttrStr(id,wash)
	local attrStr = "";
	if not id then return "" end;
	local cfg = t_zhuoyueshuxing[id];
	if not cfg then return "" end;
	if wash and wash > 0 then 
		attrStr = attrStr .. "卓越 （";
		attrStr = attrStr .. formatAttrStr(cfg.attrType,wash);
		attrStr = attrStr .. "）  ";
	else
		attrStr = attrStr .. "卓越 （";
		attrStr = attrStr .. formatAttrStr(cfg.attrType,cfg.val);
		attrStr = attrStr .. "）  ";
	end;
	

	return attrStr;
end

--
function UIEquipSuperNewWash:OnBtnEquipClick()
	if self.currBag>=0 and self.currPos>=0 then
		self:UnSelectEquip();
	end

	self:ShowCanWashAtb();
end
function UIEquipSuperNewWash:OnBtnEquipOver()
	if self.currBag<0 or self.currPos<0 then
		return;
	end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(self.currBag,self.currPos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	itemTipsVO.compareTipsVO = nil;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end

--取消选中装备
function UIEquipSuperNewWash:UnSelectEquip(unFly)
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

function UIEquipSuperNewWash:HandleNotification(name,body)
	if not UIEquipSuperNewWash:IsShow() then return end;
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
	elseif name == NotifyConsts.EquipNewSuperChange then 

	elseif name == NotifyConsts.BagItemNumChange then 
		self:UpdataXiaohaoNum();
	end
end

function UIEquipSuperNewWash:ListNotificationInterests()
	return {NotifyConsts.BagAdd,
			NotifyConsts.BagRemove,
			NotifyConsts.BagItemNumChange,
			NotifyConsts.BagRefresh,
			NotifyConsts.EquipNewSuperChange,};
end


--显示人物装备
function UIEquipSuperNewWash:ShowRoleList()
	local objSwf = self.objSwf;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role);
	if not bagVO then return; end
	local list = {};
	self.roleList = {};
	for k,item in pairs(bagVO.itemlist) do
		if EquipModel:CheckNewSuper(item:GetId()) then
			table.push(self.roleList,item);
			table.push(list,UIData.encode(self:GetSlotVO(item)));
		end
	end
	objSwf.roleList.dataProvider:cleanUp();
	objSwf.roleList.dataProvider:push(unpack(list));
	objSwf.roleList:invalidateData();
end

--显示背包装备
function UIEquipSuperNewWash:ShowBagList()
	local objSwf = self.objSwf;
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local list = {};
	self.bagList = {};
	for k,item in pairs(bagVO.itemlist) do
		if item:GetShowType() == BagConsts.ShowType_Equip then
			if EquipModel:CheckNewSuper(item:GetId()) then
				table.push(self.bagList,item);
				table.push(list,UIData.encode(self:GetSlotVO(item)));
			end
		end
	end
	objSwf.bagList.dataProvider:cleanUp();
	objSwf.bagList.dataProvider:push(unpack(list));
	objSwf.bagList:invalidateData();
end

 --人物装备
function UIEquipSuperNewWash:OnRoleItemClick(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	if self.currBag==BagConsts.BagType_Role and self.currPos==pos then
		return;
	end
--	self:UnSelecteLib();
	self.currAttrIndex = 1;
	self:SelectEquip(BagConsts.BagType_Role,pos);
	TipsManager:Hide();
	self:ShowCanWashAtb()
end

function UIEquipSuperNewWash:OnRoleItemOver(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end

--背包装备
function UIEquipSuperNewWash:OnBagItemClick(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	if self.currBag==BagConsts.BagType_Bag and self.currPos==pos then
		return;
	end
	self.currAttrIndex = 1;
	self:SelectEquip(BagConsts.BagType_Bag,pos);
	TipsManager:Hide();
	self:ShowCanWashAtb();
end

function UIEquipSuperNewWash:OnBagItemOver(e)
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
function UIEquipSuperNewWash:GetSlotVO(item,isBig)
	local vo = {};
	vo.hasItem = true;
	vo.pos = item:GetPos();
	vo.isBig = isBig and true or false;
	EquipUtil:GetDataToEquipUIVO(vo,item,isBig);
	return vo;
end

----------------------------------面板飞效果-----------------------
--飞入
function UIEquipSuperNewWash:FlyIn(fromBag,fromPos)
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
function UIEquipSuperNewWash:FlyOut(toBag,toPos)
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
