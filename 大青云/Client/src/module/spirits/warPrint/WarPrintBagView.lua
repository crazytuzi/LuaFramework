--[[
灵兽装备背包
wangshuai

]]

_G.UIWarPrintBag = BaseSlotPanel:new("UIWarPrintBag");

UIWarPrintBag.SlotTotalNum = 32;

function UIWarPrintBag:Create()
	self:AddSWF("spiritWarPrintBag.swf",true,nil)
	self:AddChild(UIWarPrintFengjie, "fenjie")
end;

function UIWarPrintBag:OnLoaded(objSwf)
	self:GetChild("fenjie"):SetContainer(objSwf.childPanel);

	--objSwf.closepanel.click = function() self:OnCloseBtn()end;
	objSwf.tunshibtn.click = function() self:OnTunshiClick() end;
	objSwf.tunshibtn.rollOver = function() self:OnTunshiOver() end;
	objSwf.tunshibtn.rollOut = function() TipsManager:Hide() end;
	--objSwf.fenjiebtn.click = function() self:OnFenjieClick() end;
	objSwf.housebtn.click = function() self:OnOpenHouse() end;
	objSwf.shopBtn.click = function() self:OnStoreShow()end;
	for i=1,self.SlotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["bagitem"..i]),i);
	end
	objSwf.mcMask.click = function() self:McMaskClick()end;
end;

function UIWarPrintBag:OnTunshiOver()
	TipsManager:ShowBtnTips(StrConfig["warprintstore017"],TipsConsts.Dir_RightDown);
end;

function UIWarPrintBag:McMaskClick()
	FloatManager:AddNormal(StrConfig["warprintstore014"])
end;

function UIWarPrintBag:OnDelete()
	self:RemoveAllSlotItem();
end;

function UIWarPrintBag:SetBtnState(boolean)
	if self:IsShow() then 
		local objSwf = self.objSwf;
		objSwf.tunshibtn.disabled = not boolean
		--objSwf.fenjiebtn.disabled = not boolean
		objSwf.housebtn.disabled = not boolean
		objSwf.shopBtn.disabled = not boolean
		objSwf.mcMask.disabled = boolean;
		objSwf.mcMask._visible = not boolean;
	end;
	self:CloseUIConfi();
end;

-- 左键click
function UIWarPrintBag:OnItemClick(itemc)
	local itemdata = itemc:GetData();
	if not itemdata.open then return end;

	if UIWarPrintHouse:IsShow() then 
		local item = itemc:GetData();
		local list = WarPrintUtils:GetSpiritBagitem(WarPrintModel.spirit_House);
		local isChuan = false;
		for i,info in pairs(list) do 
			if info.isdata == false then 
				WarPrintController:OnReqItemSwap(WarPrintModel.spirit_Bag,item.pos,WarPrintModel.spirit_House,info.pos)
				isChuan =  true;
				break;
			end;
		end;
		if isChuan == false then
			FloatManager:AddNormal(StrConfig["warprintstore012"])
			return
		end;
	elseif UIWarPrintEquip:IsShow() then 
		local item = itemc:GetData();
		local list = WarPrintUtils:GetSpiritBagitem(WarPrintModel.spirit_Wear);
		local isChuan = false;
		for i,info in pairs(list) do 
			if info.isopen and info.isdata == false then 
				isChuan = true;
				WarPrintController:OnReqItemSwap(WarPrintModel.spirit_Bag,item.pos,WarPrintModel.spirit_Wear,info.pos)
				break;
			end;
		end;
		if isChuan == false then
			FloatManager:AddNormal(StrConfig["warprintstore011"])
			return
		end;
	end;
	
end;
-- 右键click
function UIWarPrintBag:OnItemRClick(item)

end;

-- 移入
function UIWarPrintBag:OnItemRollOver(e)
	local item = e:GetData();
	if not item then return end;
	if item.open == false then return end;
	if not item.bagType or not item.pos then return end;
	local tipsvo = WarPrintUtils:OnGetItemTipsVO(item.bagType,item.pos)
	if not tipsvo then 
		print("Log : itemdata UIWarPrintBag #100",item.bagType,item.pos)
		return end;
	TipsManager:ShowTips(TipsConsts.Type_SpiritWarPrint,tipsvo,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end;
-- 移除
function UIWarPrintBag:OnItemRollOut(item)
	TipsManager:Hide();
end
--开始拖拽
function UIWarPrintBag:OnItemDragBegin(item)
	--print("开始拖拽")
end;
-- 拖拽结束
function UIWarPrintBag:OnItemDragEnd(item)
	--print("拖拽结束")
end;
-- 拖拽中
function UIWarPrintBag:OnItemDragIn(fromData,toData)
	if UIWarPrintShop.goldDuoState then
		FloatManager:AddNormal(StrConfig["warprintstore036"]);
		return;
	end
	--print("拖拽中")
	if not fromData.open then 
		--当前格子没数据
		return 
	end;

	if toData.open == true then 
		-- 有数据
		if fromData.bagType ~= WarPrintModel.spirit_Wear then 
			if fromData.pos == toData.pos and fromData.bagType == toData.bagType then 
				--print("同贱装备")
				return end; 
			-- 不是身上的装备  吞噬
			local fromitem = WarPrintUtils:OnGetItem(fromData.bagType,fromData.pos);
			local toitem = WarPrintUtils:OnGetItem(toData.bagType,toData.pos);

			local toCfg = t_zhanyin[toitem.tid];
			if toCfg.ifequip == 1 then 
					FloatManager:AddNormal(StrConfig["warprint008"])
				return 
			end;
			self:OnTunshiDanci(toitem,fromitem)
		elseif fromData.bagType == WarPrintModel.spirit_Wear then
			WarPrintController:OnReqItemSwap(fromData.bagType,fromData.pos,toData.bagType,toData.pos)
		end;
	elseif toData.open == false then 
		-- 没数据 换格子
		WarPrintController:OnReqItemSwap(fromData.bagType,fromData.pos,toData.bagType,toData.pos)
	end;
end;

-- 显示分解
function UIWarPrintBag:OnShowFengjie()
	local child = self:GetChild("fenjie")
	if not child then return end;
	--child:Show();
	self:ShowChild("fenjie")
end;
function UIWarPrintBag:OnShow()
	self:OnShowEquipList();
	self:SetBtnState(true);
end;
-- 单次吞噬
function UIWarPrintBag:OnTunshiDanci(item,beitem)
	local cfg = WarPrintUtils:OnGetItemCfg(item.tid)
	local becfg = WarPrintUtils:OnGetItemCfg(beitem.tid)
	if not becfg then 
		print(debug.traceback(),beitem.tid)
		return end;
	local color = TipsConsts:GetItemQualityColor(becfg.quality)
	local str = string.format(StrConfig["warprint004"],color,becfg.name,becfg.lvl)
	if self.ConfiId then 
		UIConfirm:Close(self.ConfiId)
		self.ConfiId = nil;
	end;
	local okfun = function ()
		if UIWarPrintShop.goldDuoState then
			FloatManager:AddNormal(StrConfig["warprintstore036"]);
			return;
		end
		-- WarPrintController:OnReqItemDuociTunshi(scrbag,scridx,dstbag,dstidx)
		WarPrintController:OnReqItemDuociTunshi(beitem.bagType,beitem.pos,item.bagType,item.pos);
	end;
	self.ConfiId = UIConfirm:Open(str, okfun, nil, nil, nil, nil, nil, true);
end;
-- 一键吞噬
function UIWarPrintBag:OnTunshiClick()
	local list = WarPrintUtils:GetSpiritHaveDataItem(WarPrintModel.spirit_Bag);
	local num =  WarPrintUtils:OnGetListLenght(list)
	if num <= 1 then 
		FloatManager:AddNormal(StrConfig["warprintstore010"])
		return 
	end;
	local quality = 0;
	local lvl = 0;
	local pos = 100;

	--先取品质最高的
	for ca,ao in pairs(list) do 
		local cfg = WarPrintUtils:OnGetItemCfg(ao.tid);
		if cfg.quality > quality and cfg.nextlvlid ~= -2 then 
			quality = cfg.quality;
		end;
	end;

	--再选等级最高的
	for pa,po in pairs(list) do 
		local cfg = WarPrintUtils:OnGetItemCfg(po.tid)
		if cfg.quality == quality then 
			if cfg.lvl > lvl and cfg.nextlvlid ~= -2 then 
				lvl = cfg.lvl;
			end;
		end;
	end;
	for wa,ro in pairs(list) do 
		local cfg = WarPrintUtils:OnGetItemCfg(ro.tid)
		if cfg.quality == quality then 
			if cfg.lvl == lvl then 
				pos = ro.pos;
			end;
		end
	end;
	local item = WarPrintUtils:OnGetItem(WarPrintModel.spirit_Bag,pos)
	if not item  then return end;
	local cfg = WarPrintUtils:OnGetItemCfg(item.tid)
	if cfg.ifequip ~= 0 then 
		FloatManager:AddNormal(StrConfig["warprintstore010"])
		return 
	end;
	local color = TipsConsts:GetItemQualityColor(cfg.quality);
	local lvl = 0;
	for yo,ur in pairs(list) do
		if ur.pos ~= pos then 
			local cfg = WarPrintUtils:OnGetItemCfg(ur.tid);
			if cfg.nextlvlid ~= -2 then 
				lvl = cfg.swallow_exp + lvl;
			end;
		end;
	end;
	local maxcfg,allExp = WarPrintUtils:OnGetItemMaxLvl(cfg.id,true)
	local maxExpNum = allExp - item.value
	if lvl > maxExpNum then 
		lvl = maxExpNum;
	end;
	local txt = string.format(StrConfig["warprint002"],color,cfg.name,cfg.lvl,lvl)
	local okfun = function ()
		if UIWarPrintShop.goldDuoState then
			FloatManager:AddNormal(StrConfig["warprintstore036"]);
			return;
		end

		WarPrintController:OnReqItemTunshi(item.pos)
	end;
	self.UIconfi2 = UIConfirm:Open(txt,okfun, nil, nil, nil, nil, nil, true);

end;

function UIWarPrintBag:CloseUIConfi()
	if not self:IsShow() then return end;
	if self.UIconfi2 then 
		UIConfirm:Close(self.UIconfi2);
		self.UIconfi2 = nil;
	end;
	if self.ConfiId then 
		UIConfirm:Close(self.ConfiId)
		self.ConfiId = nil
	end;
end;

-- 分解 , 已经屏蔽 yanghongbin/yaochunlong 2016-8-5
function UIWarPrintBag:OnFenjieClick()
	if not UIWarPrintFengjie:IsShow() then 
		self:OnShowFengjie()
	else
		UIWarPrintFengjie:Hide();
	end;
end;

-- 仓库
function UIWarPrintBag:OnOpenHouse()
	if not UIWarPrintHouse:IsShow() then
		UIWarPrintHouse:Show();
	else
		UIWarPrintHouse:Hide();
	end;
end;

--  商店购买印记
function UIWarPrintBag:OnStoreShow()
	if UIWarPrintExchange:IsShow() then
		UIWarPrintExchange:Hide()
	else
		UIWarPrintExchange:Show()
	end;
end;


--  显示装备
function UIWarPrintBag:OnShowEquipList()
	local objSwf = self.objSwf;
	local list = WarPrintUtils:GetSpiritBagitem(WarPrintModel.spirit_Bag)
	local listvo = {};
	for i,info in ipairs(list) do 
		local vo = {};
		WarPrintUtils:OnEquipItemData(info,vo);
		table.push(listvo,UIData.encode(vo));
	end;
	objSwf.baglist.dataProvider:cleanUp();
	objSwf.baglist.dataProvider:push(unpack(listvo));
	objSwf.baglist:invalidateData();

end;

function UIWarPrintBag:ShowEquipListADD(pos)
	local item = WarPrintUtils:OnGetItem(WarPrintModel.spirit_Bag,pos)
	if not item then return end;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local uidata = {};
	WarPrintUtils:OnEquipItemData(item,uidata)
	objSwf.baglist.dataProvider[pos] = UIData.encode(uidata);
	local uiSlot = objSwf.baglist:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(UIData.encode(uidata));
	end
end;

function UIWarPrintBag:ShowEquipListRemove(pos)
	local objSwf = self.objSwf;
	if not objSwf then return; end;
	local item = WarPrintUtils:OnGetItem(WarPrintModel.spirit_Bag,pos)
	if not item then return end;
	local uidata = {};
	WarPrintUtils:OnEquipItemData(item,uidata)
	objSwf.baglist.dataProvider[pos] = UIData.encode(uidata);
	local uiSlot = objSwf.baglist:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(UIData.encode(uidata));
	end
end;


function UIWarPrintBag:ListNotificationInterests()
	return {
			NotifyConsts.SpiritWarPrintItemSwap,
			NotifyConsts.SpiritWarPrintItemUpdata,
			NotifyConsts.SpiritWarPrintItemRemove,
			NotifyConsts.SpiritWarPrintItemAdd,
		}
end;
function UIWarPrintBag:HandleNotification(name,body)
	if not self.bShowState then return end;
	if name == NotifyConsts.SpiritWarPrintItemSwap then 
		self:OnShowEquipList();
	elseif name == NotifyConsts.SpiritWarPrintItemUpdata then 
		self:ShowEquipListADD(body)
	elseif name == NotifyConsts.SpiritWarPrintItemRemove then 
		self:ShowEquipListRemove(body)
	elseif name == NotifyConsts.SpiritWarPrintItemAdd then 
		--self:OnShowEquipList();
		self:ShowEquipListADD(body)
	end;
end;

-- close
function UIWarPrintBag:OnCloseBtn()
	self:Hide();
end;

function UIWarPrintBag:OnHide()

end;
