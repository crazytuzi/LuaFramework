--[[
卓越属性值洗练
wangshuai
2015年12月4日13:42:44
 ]]

 _G.UIEquipSeniorJinglian = BaseUI:new("UIEquipSeniorJinglian")

UIEquipSeniorJinglian.maxSuperLengh = 3;
--显示的人物里的装备
UIEquipSeniorJinglian.roleList = {};
--显示的背包里的装备
UIEquipSeniorJinglian.bagList = {};
--当前选中 bag
UIEquipSeniorJinglian.currBag = -1;
--当前选中 pos
UIEquipSeniorJinglian.currPos = -1;
--选中的idnex
UIEquipSeniorJinglian.currAttrIndex = 1;
--消耗类型,1普通2高级
UIEquipSeniorJinglian.curXiaohaotype = 2;


function UIEquipSeniorJinglian:Create()
 	self:AddSWF("equipSeniorJinglian.swf",true,nil)
end;

function UIEquipSeniorJinglian:OnLoaded(objSwf)

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

	objSwf.btnConfirm.click = function() self:JixuWashClick()end;

	for i=1,self.maxSuperLengh do
		objSwf["btnNoAttr"..i].click = function() self:OnSuperAttrClick(i); end
	end

	objSwf.btnRule.rollOver = function() self:OnBtnRuleOver() end;
 	objSwf.btnRule.rollOut = function() TipsManager:Hide()end;

 	objSwf.tfInfo.htmlText = StrConfig["equip1004"]
end;

function UIEquipSeniorJinglian:OnShow()
	self:ShowRoleList();
	self:ShowBagList();
	self:ShowRight();
	self:OnShowProBar();
end;

function UIEquipSeniorJinglian:OnHide()
	self.bagList = {};
	self.roleList = {};
	self.currAttrIndex = 0;
	--当前选中 bag
	self.currBag = -1;
	--当前选中 pos
	self.currPos = -1;
	--选中的idnex
	self.currAttrIndex = 1;
	self.isBackFlag = false;
	local objSwf = self.objSwf;
	if not objSwf then return end
	for i = 1 , 3 do
		objSwf['effect_updata' .. i]:stopEffect();
	end
	objSwf.effect_win:stopEffect();
	objSwf.effect_lose:stopEffect();
	self.oldInfo = nil;
end;

function UIEquipSeniorJinglian:SetWashTemporary()
	if not self:IsShow() then return end;
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self:ShowRight();

	local data = EquipModel.washJinglian
	local uiItem = objSwf["btnNoAttr"..data.idx];

	local superVO = EquipModel:GetNewSuperVO(data.cid);
	if not superVO then return; end
	local newSuperList = superVO.newSuperList;

	local oldData = newSuperList[data.idx]
	local cfg = t_zhuoyueshuxing[data.id];
	local oldVal = oldData.wash --Oldval
	local newVal = data.wash --newVal 


	local val = self:GetFormatVal(cfg.attrType,newVal - oldVal) ;

	--特殊处理属性值
	local atrType = AttrParseUtil.AttMap[cfg.attrType];
	if atrType == enAttrType.eaKillHp then
		oldVal = 1/oldVal;
		newVal = 1/newVal;
		val = self:GetFormatVal(cfg.attrType,toint(1/(newVal - oldVal))) ;
	end;

	local color = "#00ff00"
	uiItem.img._visible = true;
	uiItem.mc_flag._visible = true;
	if newVal > oldVal then 
		uiItem.img:gotoAndStop(1);
		color = "#00ff00"
	else
		uiItem.img:gotoAndStop(2);
		color = "#ff0000"
	end;

	uiItem.save_txt.htmlText = "<font color='"..color.."'>"..val.."</font>";
	local uiItem = objSwf["btnNoAttr"..data.idx];
end;

function UIEquipSeniorJinglian:ValWash()

	local bagVO = BagModel:GetBag(self.currBag);
	if not bagVO then FloatManager:AddNormal(StrConfig['equip1003']); return; end
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
		local data = split(washCfg["washnumcost"..self.curXiaohaotype],'#')
		for da,xiaohao in ipairs(data) do 
			local xcfg = split(xiaohao,",");
			local vo = {};
			vo.id = toint(xcfg[1]);               
			vo.num = toint(xcfg[2]);
			table.push(xiaohaoList,vo)
		end;
	end
	
	for re,hao in ipairs(xiaohaoList) do 
		if hao then 
			local num = BagModel:GetItemNumInBag(hao.id)
			if num < hao.num then 
				FloatManager:AddNormal(StrConfig["equip507"]);--道具不足
				return
			end;
		end;
	end;
	self.isBackFlag = true;
	EquipController:UpSuperNewJinglian(item:GetId(),self.currAttrIndex,self.curXiaohaotype)
end;

UIEquipSeniorJinglian.isBackFlag = false;
function UIEquipSeniorJinglian:JixuWashClick()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self:ShowRight();
	self:ValWash();
end;

function UIEquipSeniorJinglian:OnSuperAttrClick(i)
	self.currAttrIndex = i
	self.isBackFlag = false;
end;

function UIEquipSeniorJinglian:OnBtnRuleOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	TipsManager:ShowBtnTips(StrConfig["equip641"],TipsConsts.Dir_RightDown);
end

--显示右侧面板
function UIEquipSeniorJinglian:ShowRight()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if self.currBag<0 or self.currPos<0 then
		objSwf.btnEquip:setData(UIData.encode({}));
		for i = 1 , 3 do
			objSwf['btnNoAttr' .. i].tfName.text = '';
			objSwf['btnNoAttr' .. i]._visible = false;
			objSwf['btnNoAttr' .. i].max_txt.text = '';
			objSwf['btnNoAttr' .. i].save_txt.text = '';
			objSwf['btnNoAttr' .. i].img._visible = false;
		end
		for i = 1 , 4 do
			objSwf['xiaohao_' .. i].text = '';
			objSwf["item"..i]._visible = false
		end
		self.oldInfo = nil
		return;
	end

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
	
	self.oldInfo = {};				--记录之前的属性
	
	for i=1,self.maxSuperLengh do 
		local info = newSuperList[i];
		local uiItem = objSwf["btnNoAttr"..i];
		if i == self.currAttrIndex then 
			uiItem.selected = true;
		else
			uiItem.selected = false;
		end;
		if info.id and info.id > 0 then 
			local vo = {};
			vo.id = info.id;
			vo.wash = info.wash;
			self.oldInfo[i] = vo;
			
			if uiItem then 
				uiItem.tfName.htmlText = self:GetSuperNewAttrStr(info.id,info.wash)
				uiItem.save_txt.htmlText = "";
				uiItem.img._visible = false;
				uiItem.max_txt.htmlText = ""
			end;
			uiItem._visible = true;
		else
			uiItem._visible = false;
		end;
	end;
	
	self:UpdataXiaohaoNum();
end;

--处理，最大属性val
function UIEquipSeniorJinglian:GetFormatVal(atrtype,val)
	local atrType = AttrParseUtil.AttMap[atrtype];

	--特殊处理值
	if atrType == enAttrType.eaKillHp then
		return "1/" .. val;
	end;

	if attrIsX(atrType) then
		if attrIsPercent(atrType) then
			return string.format("%0.2f",val/10000);
		else
			return val;
		end
	elseif attrIsPercent(atrType) then
		return string.format("%0.2f%%",val/100)--"%"..val/100;
	else
		return val;
	end

end;

function UIEquipSeniorJinglian:UpdataXiaohaoNum()

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
	if not washCfg then return end;
	local xiaohaoList = {};

	if washCfg then 
		local data = split(washCfg["washnumcost"..self.curXiaohaotype],'#')
		for da,xiaohao in ipairs(data) do 
			local xcfg = split(xiaohao,",");
			local vo = {};
			vo.id = toint(xcfg[1]);               
			vo.num = toint(xcfg[2]);
			print(vo.num,'-------------vo.num')
			table.push(xiaohaoList,vo)
		end;
	end;
	--trace(xiaohaoList)
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
function UIEquipSeniorJinglian:GetSuperNewAttrStr(id,wash,_type)
	local attrStr = "";
	if not id then return "" end;
	local cfg = t_zhuoyueshuxing[id];
	if not cfg then return "" end;
	if _type then
		return formatAttrStr(cfg.attrType,wash);
	end
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


--选中装备
function UIEquipSeniorJinglian:SelectEquip(bag,pos)
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
function UIEquipSeniorJinglian:UnSelectEquip(unFly)
	if self.currBag>=0 and self.currPos>=0 then
		if not unFly then
			self:FlyOut(self.currBag,self.currPos);
		end
	end
	self.currBag = -1;
	self.currPos = -1;
	self.currAttrIndex = 0;
	
	self.isBackFlag = false;
	
	self:ShowRight();
end


--显示人物装备
function UIEquipSeniorJinglian:ShowRoleList()
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
function UIEquipSeniorJinglian:ShowBagList()
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
function UIEquipSeniorJinglian:OnRoleItemClick(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	if self.currBag==BagConsts.BagType_Role and self.currPos==pos then
		return;
	end
	self.isBackFlag = false;
--	self:UnSelecteLib();
	self.currAttrIndex = 1;
	self:SelectEquip(BagConsts.BagType_Role,pos);
	TipsManager:Hide();
end

function UIEquipSeniorJinglian:OnRoleItemOver(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end

--背包装备
function UIEquipSeniorJinglian:OnBagItemClick(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	if self.currBag==BagConsts.BagType_Bag and self.currPos==pos then
		return;
	end
	self.isBackFlag = false;
	self.currAttrIndex = 1;
	self:SelectEquip(BagConsts.BagType_Bag,pos);
	TipsManager:Hide();
end

function UIEquipSeniorJinglian:OnBagItemOver(e)
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
function UIEquipSeniorJinglian:GetSlotVO(item,isBig)
	local vo = {};
	vo.hasItem = true;
	vo.pos = item:GetPos();
	vo.isBig = isBig and true or false;
	EquipUtil:GetDataToEquipUIVO(vo,item,isBig);
	return vo;
end

function UIEquipSeniorJinglian:OnBtnEquipClick()
	if self.currBag>=0 and self.currPos>=0 then
		self:UnSelectEquip();
	end
	
	--self:ShowCanWashAtb();
end
function UIEquipSeniorJinglian:OnBtnEquipOver()
	if self.currBag<0 or self.currPos<0 then
		return;
	end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(self.currBag,self.currPos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	itemTipsVO.compareTipsVO = nil;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end

--数据返回时UI变化
function UIEquipSeniorJinglian:OnChangeItem(idx)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if not self.isBackFlag then
		return
	end
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
	for i=1,self.maxSuperLengh do 
		local info = newSuperList[i];
		local oldinfo = self.oldInfo[i];
		if not oldinfo then return end
		if i == idx then 
			local uiItem = objSwf["btnNoAttr"..i];
			local effectItem = objSwf["effect_updata"..i];
			uiItem.selected = true;
			if info.id and info.id > 0 then 
				uiItem.tfName.htmlText = self:GetSuperNewAttrStr(info.id,oldinfo.wash)
				
				local cfg = t_zhuoyueshuxing[info.id];
				if not cfg then return end;

				local _type = AttrParseUtil.AttMap[cfg.attrType];
				if not _type then return end
				local addval = nil;
				local upval = nil;
				if attrIsX(_type) then
					if attrIsPercent(_type) then
						addval = string.format("%0.2f",info.wash/10000);
						upval = string.format("%0.2f",(info.wash - oldinfo.wash)/10000);
					else
						addval = info.wash;
						upval = info.wash - oldinfo.wash;
					end
				elseif attrIsPercent(_type) then
					addval = string.format("%0.2f%%",info.wash/100);
					upval = string.format("%0.2f",(info.wash - oldinfo.wash)/100);
				else
					addval = info.wash;
					upval = info.wash - oldinfo.wash;
				end
				local vo = {};
				vo.id = info.id;
				vo.wash = info.wash;
				self.oldInfo[i] = vo;
				if not addval or not upval then return end
				uiItem.max_txt.htmlText = addval;
				if _type == enAttrType.eaKillHp then
					uiItem.save_txt.text = math.abs(upval);
				else
					uiItem.save_txt.text = upval;
				end
				uiItem.img._visible = true;
				uiItem.img:gotoAndStop(1);
				effectItem:playEffect(1);
				effectItem.complete = function () effectItem:stopEffect(); end
				objSwf.effect_win:playEffect(1);
				objSwf.effect_win.complete = function () objSwf.effect_win:stopEffect(); end
			end
		end
	end
end

function UIEquipSeniorJinglian:OnShowProBar(istween)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local constsCfg = t_consts[198];
	if not constsCfg then return end
	local proVal = MainPlayerModel.humanDetailInfo.eaWashLucky;
	local maxVal = constsCfg.val2;
	local num = toint(proVal / maxVal * 100)
	if num == 0 then
		objSwf.effect_progress:GoToAndStopProcess(0,100);
		local str = string.format('%s%%',num);
		objSwf.txt_pronum.htmlText = str;
		return
	end
	if istween then
		objSwf.effect_progress:moveToProcess(num,100);
	else
		objSwf.effect_progress:GoToAndStopProcess(num,100);
	end
	local str = string.format('%s%%',num);
	objSwf.txt_pronum.htmlText = str;
end

function UIEquipSeniorJinglian:ShowLoseEffect()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.effect_lose:playEffect(1);
	objSwf.effect_lose.complete = function () objSwf.effect_lose:stopEffect(); end
end	

function UIEquipSeniorJinglian:HandleNotification(name,body)
	if not UIEquipSeniorJinglian:IsShow() then return end;
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
	elseif name == NotifyConsts.BagItemNumChange then 
		self:UpdataXiaohaoNum();
	elseif name == NotifyConsts.EquipSeniorJinglian then
		self:OnChangeItem(body.idx);
	elseif name == NotifyConsts.EquipSeniorJinglianLacky then
		self:OnShowProBar(true);
	elseif name == NotifyConsts.EquipSeniorJinglianLose then
		self:ShowLoseEffect();
	end
end

function UIEquipSeniorJinglian:ListNotificationInterests()
	return {NotifyConsts.BagAdd,
			NotifyConsts.BagRemove,
			NotifyConsts.BagItemNumChange,
			NotifyConsts.BagRefresh,
			NotifyConsts.EquipSeniorJinglian,
			NotifyConsts.EquipSeniorJinglianLacky,
			NotifyConsts.EquipSeniorJinglianLose,};
end


----------------------------------面板飞效果-----------------------
--飞入
function UIEquipSeniorJinglian:FlyIn(fromBag,fromPos)
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
function UIEquipSeniorJinglian:FlyOut(toBag,toPos)
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


