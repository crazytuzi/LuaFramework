--[[
卓越属性值洗练
wangshuai
2015年12月4日13:42:44
 ]]

 _G.UIEquipSuperValWash = BaseUI:new("UIEquipSuperValWash")

UIEquipSuperValWash.maxSuperLengh = 3;
--显示的人物里的装备
UIEquipSuperValWash.roleList = {};
--显示的背包里的装备
UIEquipSuperValWash.bagList = {};
--当前选中 bag
UIEquipSuperValWash.currBag = -1;
--当前选中 pos
UIEquipSuperValWash.currPos = -1;
--选中的idnex
UIEquipSuperValWash.currAttrIndex = 1;
--消耗类型,1普通2高级
UIEquipSuperValWash.curXiaohaotype = 1;


function UIEquipSuperValWash:Create()
 	self:AddSWF("equipSuperJinglian.swf",true,nil)
end;

function UIEquipSuperValWash:OnLoaded(objSwf)

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

	objSwf.putong_btn.click = function() self:OnPutongClick() end;
	objSwf.gaoji_btn.click = function() self:OnGaojiClick()end;

	objSwf.btnConfirm.click = function() self:OnValWashClick()end;

	objSwf.savePanel.saceWash_btn.click = function() self:SaveWashClick()end;
	objSwf.savePanel.cancelWash_btn.click = function() self:CancelWashClick()end;
	--objSwf.savePanel.jixuWash_btn.click = function() self:JixuWashClick()end;

	for i=1,self.maxSuperLengh do
		objSwf["btnNoAttr"..i].click = function() self:OnSuperAttrClick(i); end
	end

	objSwf.btnRule.rollOver = function() self:OnBtnRuleOver() end;
 	objSwf.btnRule.rollOut = function() TipsManager:Hide()end;

 	objSwf.nonPanel.text_btn.htmlText = StrConfig["equip630"];
 	objSwf.tfInfo.htmlText = StrConfig["equip632"]
end;

function UIEquipSuperValWash:OnShow()
	self:ShowRoleList();
	self:ShowBagList();
	self:ShowRight();
	--self.curXiaohaotype = 1;
	self:OnPutongClick()
end;

function UIEquipSuperValWash:OnHide()
	self.bagList = {};
	self.roleList = {};
	self.currAttrIndex = 0;
	--当前选中 bag
	self.currBag = -1;
	--当前选中 pos
	self.currPos = -1;
	--选中的idnex
	self.currAttrIndex = 1;
end;

function UIEquipSuperValWash:SetWashTemporary()
	if not self:IsShow() then return end;
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self:ShowRight();

	objSwf.savePanel._visible = true;

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
	if newVal > oldVal then 
		uiItem.img:gotoAndStop(1);
		color = "#00ff00"
	else
		uiItem.img:gotoAndStop(2);
		color = "#ff0000"
	end;

	uiItem.save_txt.htmlText = "<font color='"..color.."'>"..val.."</font>";
	local uiItem = objSwf["btnNoAttr"..data.idx];
	--uiItem.tfName.htmlText = self:GetSuperNewAttrStr(data.id,data.wash);
end;


function UIEquipSuperValWash:OnValWashClick()
	self:ValWash();
end;

function UIEquipSuperValWash:ValWash()

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
	--print('打算打扫打扫打扫的1')
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
		--trace(data)
		for da,xiaohao in ipairs(data) do 
			local xcfg = split(xiaohao,",");
			local vo = {};
			vo.id = toint(xcfg[1]);               
			vo.num = toint(xcfg[2]);
			table.push(xiaohaoList,vo)
		end;
	end;

	--trace(xiaohaoList)
	--print('打算打扫打扫打扫的2')

	for re,hao in ipairs(xiaohaoList) do 
		if hao then 
			local num = BagModel:GetItemNumInBag(hao.id)
			--print(num,'消耗list啊啊啊啊')
			if num < hao.num then 
				--不够
				FloatManager:AddNormal(StrConfig["equip507"]);--道具不足
				return
			end;
		end;
	end;

	--print('打算打扫打扫打扫的3')

	EquipController:UpSuperNewJinglian(item:GetId(),self.currAttrIndex,self.curXiaohaotype)



	-- local msg = {};
	-- msg.result = 0;
	-- msg.cid = item:GetId();
	-- msg.id = 13004
	-- msg.wash = math.random(300)
	-- msg.idx = self.currAttrIndex
	-- EquipController:SuperValWash(msg)

end;

function UIEquipSuperValWash:JixuWashClick()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self:ValWash();
end;

function UIEquipSuperValWash:SaveWashClick()
	--self:ShowRight();
	local data = EquipModel.washJinglian
	EquipController:SaveSuperNewJinglian(data.cid,data.idx)

	-- local msg = {};
	-- msg.result = 0;
	-- msg.cid = data.cid;
	-- msg.id = 13004;
	-- msg.wash = math.random(123);
	-- msg.idx = data.idx;
	-- EquipController:SuperValWashSave(msg)
end;

function UIEquipSuperValWash:CancelWashClick()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self:ShowRight();
end;


function UIEquipSuperValWash:OnGaojiClick()
	do return end;
	self.curXiaohaotype = 2;
	self:UpdataXiaohaoNum();
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.gaoji_btn.selected = true;
	self:ShowRight();
end;

function UIEquipSuperValWash:OnPutongClick()
	self.curXiaohaotype = 1;
	self:UpdataXiaohaoNum();
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.putong_btn.selected = true;
	self:ShowRight();
end;

function UIEquipSuperValWash:OnSuperAttrClick(i)
	self.currAttrIndex = i
end;

function UIEquipSuperValWash:OnBtnRuleOver()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	TipsManager:ShowBtnTips(StrConfig["equip628"],TipsConsts.Dir_RightDown);
end

--显示右侧面板
function UIEquipSuperValWash:ShowRight()
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
				uiItem.save_txt.htmlText = "";
				uiItem.img._visible = false;
				local cfg = t_zhuoyueshuxing[info.id];
				if cfg then 
					local maxVal = split(cfg["washnum"..self.curXiaohaotype.."max"],'#');
					if maxVal[2] then 
						uiItem.max_txt.htmlText = StrConfig["equip631"] ..self:GetFormatVal(cfg.attrType,maxVal[2]);
					else
						uiItem.max_txt.htmlText = ""
					end;
				end;
			end;
			uiItem._visible = true;
		else
			uiItem._visible = false;
		end;
	end;
	self:UpdataXiaohaoNum();
end;

--处理，最大属性val
function UIEquipSuperValWash:GetFormatVal(atrtype,val)
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

function UIEquipSuperValWash:UpdataXiaohaoNum()

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
function UIEquipSuperValWash:GetSuperNewAttrStr(id,wash)
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


--选中装备
function UIEquipSuperValWash:SelectEquip(bag,pos)
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
function UIEquipSuperValWash:UnSelectEquip(unFly)
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


--显示人物装备
function UIEquipSuperValWash:ShowRoleList()
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
function UIEquipSuperValWash:ShowBagList()
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
function UIEquipSuperValWash:OnRoleItemClick(e)
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
end

function UIEquipSuperValWash:OnRoleItemOver(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role,pos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end

--背包装备
function UIEquipSuperValWash:OnBagItemClick(e)
	if not e.item then return; end
	if not e.item.hasItem then return; end
	local pos = e.item.pos;
	if self.currBag==BagConsts.BagType_Bag and self.currPos==pos then
		return;
	end
	self.currAttrIndex = 1;
	self:SelectEquip(BagConsts.BagType_Bag,pos);
	TipsManager:Hide();
end

function UIEquipSuperValWash:OnBagItemOver(e)
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
function UIEquipSuperValWash:GetSlotVO(item,isBig)
	local vo = {};
	vo.hasItem = true;
	vo.pos = item:GetPos();
	vo.isBig = isBig and true or false;
	EquipUtil:GetDataToEquipUIVO(vo,item,isBig);
	return vo;
end

function UIEquipSuperValWash:OnBtnEquipClick()
	if self.currBag>=0 and self.currPos>=0 then
		self:UnSelectEquip();
	end

	--self:ShowCanWashAtb();
end
function UIEquipSuperValWash:OnBtnEquipOver()
	if self.currBag<0 or self.currPos<0 then
		return;
	end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(self.currBag,self.currPos);
	if not itemTipsVO then return; end
	itemTipsVO.isInBag = false;
	itemTipsVO.compareTipsVO = nil;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown);
end


function UIEquipSuperValWash:HandleNotification(name,body)
	if not UIEquipSuperValWash:IsShow() then return end;
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

function UIEquipSuperValWash:ListNotificationInterests()
	return {NotifyConsts.BagAdd,
			NotifyConsts.BagRemove,
			NotifyConsts.BagItemNumChange,
			NotifyConsts.BagRefresh,
			NotifyConsts.EquipNewSuperChange,};
end


----------------------------------面板飞效果-----------------------
--飞入
function UIEquipSuperValWash:FlyIn(fromBag,fromPos)
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
function UIEquipSuperValWash:FlyOut(toBag,toPos)
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


