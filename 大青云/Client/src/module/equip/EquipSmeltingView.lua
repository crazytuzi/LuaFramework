--[[
	2015年9月28日, PM 12:02:41
	wangyanwei
	装备熔炼
]]

_G.UIEquipSmelting = BaseUI:new('UIEquipSmelting');

function UIEquipSmelting:Create()
	self:AddSWF('equipSmeltingPanel.swf',true,'center')
end

UIEquipSmelting.autoSmelt = false;

function UIEquipSmelting:OnLoaded(objSwf)
	objSwf.bgList.itemRollOver = function(e) self:OnBagItemOver(e); end
	objSwf.bgList.itemRollOut = function(e)TipsManager:Hide(); end
	objSwf.bgList.itemClick = function(e) self:OnBGEquipClick(e); end
	objSwf.smeltingList.itemRollOver = function(e) self:OnBagItemOver(e); end
	objSwf.smeltingList.itemRollOut = function(e)TipsManager:Hide(); end
	objSwf.smeltingList.itemClick = function(e) self:OnSmeltClick(e); end
	objSwf.btn_close.click = function () self:Hide(); end
	
	objSwf.check_1.click = function () self:OnSetEquipData(1); end
	objSwf.check_2.click = function () self:OnSetEquipData(2); end
	objSwf.check_3.click = function () self:OnSetEquipData(3); end
	
	objSwf.btn_allIn.click = function () self:InAllEquip(); end
	objSwf.btn_smelting.click = function () self:OnSmelting(); end
	
	objSwf.num_exp.loadComplete = function ()
		objSwf.num_exp._x = objSwf.bar._x - objSwf.num_exp._width - 2;
	end
	objSwf.check_auto.click = function () self.autoSmelt = not self.autoSmelt; self:OnSetEquipData(); end
end

function UIEquipSmelting:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.check_1.textField.htmlText = StrConfig['equip1101'];
	objSwf.check_2.textField.htmlText = StrConfig['equip1102'];
	objSwf.check_3.textField.htmlText = StrConfig['equip1103'];
	
	local smeltExp = EquipModel:GetSmeltFlags();
	for i = 1 , 3 do
		self.checkData[i] = bit.band(smeltExp,math.pow(2,i)) == math.pow(2,i);
		objSwf['check_' .. i].selected = bit.band(smeltExp,math.pow(2,i)) == math.pow(2,i)
	end
	
	self.autoSmelt = bit.band(smeltExp,math.pow(2,4)) == math.pow(2,4);
	
	print(self.autoSmelt,'=------------=')
	objSwf.check_auto.selected = self.autoSmelt;
	self:InItEquipList();
	self:ShowBGEquip();
	self:ShowSmeltEquip();
	self:ShowSmeltLevelInfo();
	EquipNewTipsManager:CloseAll();
end

--等级信息
function UIEquipSmelting:ShowSmeltLevelInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local level = EquipModel:GetSmeltLevel();
	objSwf.num_level.num = level;
	objSwf.txt_level.text = 'Lv.' .. level;
	self:ShowAddInfo();
end

--属性信息
function UIEquipSmelting:ShowAddInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local level = EquipModel:GetSmeltLevel();
	local cfg = t_smeltlevel[level];
	if not cfg then return end
	local attr = split(cfg.attr,'#');
	for i , v in pairs(attr) do
		local strCfg = split(v,',');
		objSwf['txt_' .. strCfg[1]].htmlText = string.format(StrConfig['equip1111'],enAttrTypeName[AttrParseUtil.AttMap[strCfg[1]]],strCfg[2]);
	end
	objSwf.smeltProbar.maximum = cfg.level_exp;
	objSwf.smeltProbar.value = EquipModel:GetSmeltExp();
	objSwf.num_maxExp.num = cfg.level_exp;
	objSwf.num_exp.num = EquipModel:GetSmeltExp();
	self:ShowNextAddInfo();				--下一级的界面显示
end

function UIEquipSmelting:ShowNextAddInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local level = EquipModel:GetSmeltLevel();
	local nextCfg = t_smeltlevel[level + 1];
	if not nextCfg then
		objSwf.add_att._visible = false;
		objSwf.add_hp._visible = false;
		objSwf.add_defcri._visible = false;
		objSwf.add_hit._visible = false;
		objSwf.add_def._visible = false;
		objSwf.add_cri._visible = false;
		objSwf.add_dodge._visible = false;
		return
	end
	
	local curLevel = EquipModel:GetSmeltLevel();
	local curCfg = t_smeltlevel[curLevel];
	if not curCfg then return end
	local curAttr = split(curCfg.attr,'#');
	
	local attr = split(nextCfg.attr,'#');
	for i , v in pairs(attr) do
		local strCfg = split(v,',');
		local curStrCfg = split(curAttr[i],',');
		objSwf['add_' .. strCfg[1]].textField.text = toint(strCfg[2]) - toint(curStrCfg[2]);
	end
end

--背包
function UIEquipSmelting:OnBagItemOver(e)
	if not e.item then return; end
	local pos = e.item.pos;
	if not pos then return; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Bag,pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	itemTipsVO.compareTipsVO = nil;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end

--初始装备列表
function UIEquipSmelting:InItEquipList()
	--背包装备列表
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	self.bgEquipList = nil;
	self.bgEquipList = bagVO:GetEquipList();
	--熔炼装备列表
	self.smeltingEquipList = {};
end

function UIEquipSmelting:ShowBGEquip()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.bgList.dataProvider:cleanUp();
	
	table.sort(self.bgEquipList , function (A,B)
		return A:GetPos() < B:GetPos();
	end)
	
	for i,item in ipairs(self.bgEquipList) do
		local vo = self:GetSlotVO(BagConsts.BagType_Bag,item:GetPos(),i);
		objSwf.bgList.dataProvider:push(UIData.encode(vo));
	end
	objSwf.bgList:invalidateData();
end

function UIEquipSmelting:ShowSmeltEquip()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.smeltingList.dataProvider:cleanUp();
	table.sort(self.smeltingEquipList , function (A,B)
		return A.index < B.index;
	end)
	
	for i,item in ipairs(self.smeltingEquipList) do
		local vo = self:GetSlotVO(BagConsts.BagType_Bag,item:GetPos(),i);
		objSwf.smeltingList.dataProvider:push(UIData.encode(vo));
	end
	objSwf.smeltingList:invalidateData();
end

--获取格子VO
function UIEquipSmelting:GetSlotVO(bagType,pos,index,isBig)
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
	vo.index = index;
	vo.isBig = isBig and true or false;
	EquipUtil:GetDataToEquipUIVO(vo,item,isBig);
	return vo;
end

--背包列表点击
function UIEquipSmelting:OnBGEquipClick(e)
	if not e.item then return end
	if not e.item.pos or not e.item.index then return end
	local objSwf = self.objSwf;
	if not objSwf then return end
	local item = table.remove(self.bgEquipList,e.item.index)
	item.index = #self.smeltingEquipList + 1;
	table.push(self.smeltingEquipList,item)
	self:ShowBGEquip();
	self:ShowSmeltEquip();
end

--熔炼列表点击
function UIEquipSmelting:OnSmeltClick(e)
	if not e.item then return end
	if not e.item.index then return end
	local objSwf = self.objSwf;
	if not objSwf then return end
	local item = table.remove(self.smeltingEquipList,e.item.index);
	table.push(self.bgEquipList,item)
	self:ShowBGEquip();
	self:ShowSmeltEquip();
end

--量选
UIEquipSmelting.checkData = {
	[1] = false;
	[2] = false;
	[3] = false;
};
function UIEquipSmelting:OnSetEquipData(_type)
	if _type == 1 or _type == 2 or _type == 3 then
		if self.checkData[_type] == false then
			self.checkData[_type] = true;
		else
			self.checkData[_type] = false;
		end
	end
	local flags = 0;
	for i , v in ipairs(self.checkData) do
		if v then
			flags = flags + math.pow(2,i);
		end
	end
	if self.autoSmelt then
		flags = flags + math.pow(2,4);
	end
	EquipController:OnSendEquipSmelting({},flags)
end

--一键放入
function UIEquipSmelting:InAllEquip()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local listBag = bagVO:GetEquipList();
	for i , v in ipairs(self.checkData) do
		if v == true then
			for _ , item in ipairs(listBag) do
				local equipCfg = t_equip[item:GetTid()];
				if equipCfg then
					if equipCfg.quality == EquipConsts.QualityConsts[i] then
						local itemCfg = self:OnRemoveBGEquipList(item:GetId());
						if itemCfg then
							itemCfg.index = #self.smeltingEquipList + 1;
							table.push(self.smeltingEquipList,itemCfg);
						end
					end
				end
			end
		end
	end
	self:ShowBGEquip();
	self:ShowSmeltEquip();
end

function UIEquipSmelting:OnRemoveBGEquipList(id)
	for _ , item in ipairs(self.bgEquipList) do
		if item:GetId() == id then
			return table.remove(self.bgEquipList,_);
		end
	end
	return nil
end
--熔炼发送
function UIEquipSmelting:OnSmelting()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local smeltlist = {};
	for i , item in ipairs(self.smeltingEquipList) do
		smeltlist[i] = {};
		smeltlist[i].guid = item:GetId();
	end
	-- trace(smeltlist);
	local flags = 0;
	for i , v in ipairs(self.checkData) do
		if v == true then
			flags = flags + math.pow(2,i);
		end
	end
	if self.autoSmelt then
		flags = flags + math.pow(2,4);
	end
	EquipController:OnSendEquipSmelting(smeltlist,flags)
end

function UIEquipSmelting:OnHide()
	
end

function UIEquipSmelting:GetWidth()
	return 810;
end

function UIEquipSmelting:GetHeight()
	return 600;
end

function UIEquipSmelting:IsTween()
	return true;
end

function UIEquipSmelting:GetPanelType()
	return 1;
end

function UIEquipSmelting:IsShowSound()
	return true;
end

function UIEquipSmelting:IsShowLoading()
	return true;
end

function UIEquipSmelting:HandleNotification(name,body)
	if name == NotifyConsts.EquipSmeltingData then
		self:InItEquipList();
		self:ShowBGEquip();
		self:ShowSmeltEquip();
		self:ShowSmeltLevelInfo();
	elseif name == NotifyConsts.BagAdd or NotifyConsts.BagRemove then
		self:OnShow();
	end
end
function UIEquipSmelting:ListNotificationInterests()
	return {NotifyConsts.EquipSmeltingData,
			NotifyConsts.BagRemove,
			NotifyConsts.BagAdd,
	}
end