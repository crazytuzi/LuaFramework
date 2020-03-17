--[[灵阵阵眼界面
zhangshuhui
]]

_G.UIQiZhanZhenYan = BaseSlotPanel:new("UIQiZhanZhenYan");

UIQiZhanZhenYan.slotTotalNum = 9;--UI上格子总数
UIQiZhanZhenYan.list = {};--当前格子
UIQiZhanZhenYan.effectTotalNum = 3;--套装特效

function UIQiZhanZhenYan:Create()
	self:AddSWF("qizhanZhenYanPanel.swf", true, nil)
	
	self:AddChild(UIQiZhanZhenYanHouseView, "house")
end

function UIQiZhanZhenYan:OnLoaded(objSwf,name)
	self:GetChild("house"):SetContainer(objSwf.childPanel);
	--初始化格子
	for i=1,self.slotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end
	objSwf.btnbag.click = function() self:OnOpenHouse() end;
end

function UIQiZhanZhenYan:OnDelete()
	self:RemoveAllSlotItem();
end

function UIQiZhanZhenYan:OnShow(name)
	self:UpdateShow();
end

function UIQiZhanZhenYan:UpdateShow()
	self:ShowEquip();
	self:ShowImgSuo();
	-- self:ShowGroupEffect();
	self:ShowQiYinFight();
	self:ShowQiYinAttr();
end

function UIQiZhanZhenYan:OnHide()
end

-- 仓库
function UIQiZhanZhenYan:OnOpenHouse()
	if not UIQiZhanZhenYanHouseView:IsShow() then 
		self:OnShowHouse()
	else
		UIQiZhanZhenYanHouseView:Hide();
	end;
end;

-- 显示仓库
function UIQiZhanZhenYan:OnShowHouse()
	local child = self:GetChild("house")
	if not child then return end;
	self:ShowChild("house")
end;

---------------------------------消息处理------------------------------------
function UIQiZhanZhenYan:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf
	if not objSwf then return; end
	if name == NotifyConsts.BagAdd then
		if body.type ~= BagConsts.BagType_QiZhan then return; end
		self:DoAddItem(body.pos);
		self:UpdateShow();
	elseif name == NotifyConsts.BagRemove then
		if body.type ~= BagConsts.BagType_QiZhan then return; end
		self:DoRemoveItem(body.pos);
		self:UpdateShow();
	elseif name == NotifyConsts.BagUpdate then
		if body.type ~= BagConsts.BagType_QiZhan then return; end
		self:DoUpdateItem(body.pos);
		self:UpdateShow();
	end
end

function UIQiZhanZhenYan:ListNotificationInterests()
	return {NotifyConsts.BagAdd,
			NotifyConsts.BagRemove,
			NotifyConsts.BagUpdate};
end

function UIQiZhanZhenYan:ShowQiYinFight()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local nfight, attrlist = QiZhanUtils:GetQiYinAttrMap();
	objSwf.numLoaderFight.num = nfight;
end

function UIQiZhanZhenYan:ShowQiYinAttr()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local nfight, attrMap = QiZhanUtils:GetQiYinAttrMap();
	if not attrMap then return; end
	local attrTotal = {};
	for _, attrName in pairs(QiZhanConsts.QiZhanAttrs) do
		attrTotal[attrName] = attrMap[attrName];
	end
	
	local att, def, hp, cri, defcri, dodge, hit = attrTotal["att"],attrTotal["def"],attrTotal["hp"],attrTotal["cri"],attrTotal["defcri"],attrTotal["dodge"],attrTotal["hit"]
	local str = ""
	str = str .. "<textformat leading='16'><p>"
	local addPro = 0
	addPro = att
	if addPro then
		str = str .. StrConfig["lingzhen025"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = def
	if addPro then
		str = str .. StrConfig["lingzhen026"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = hp
	if addPro then
		str = str .. StrConfig["lingzhen027"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = cri
	if addPro then
		str = str .. StrConfig["lingzhen028"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = defcri
	if addPro then
		str = str .. StrConfig["lingzhen029"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = dodge
	if addPro then
		str = str .. StrConfig["lingzhen030"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	addPro = hit
	if addPro then
		str = str .. StrConfig["lingzhen031"]..':    <font color = "#FBBF78"> '.. addPro ..' </font><br/>'
	end
	str = str .. "</p></textformat>"
	objSwf.labProShow.htmlText = str
end

---------------------------以下是装备处理--------------------------------------
--显示装备
function UIQiZhanZhenYan:ShowEquip()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.list = BagUtil:GetBagItemList(BagConsts.BagType_QiZhan,BagConsts.ShowType_All);
    objSwf.list.dataProvider:cleanUp();
	-- FTrace(self.list, '显示装备')
	for i,slotVO in ipairs(self.list) do
		local dataObj = UIData.decode(slotVO:GetUIData());
		if dataObj.tid > 0 then
			dataObj.qualityUrl = ResUtil:GetSlotYuanQuality(t_equip[dataObj.tid].quality,true);
		end
		objSwf.list.dataProvider:push(UIData.encode(dataObj));
	end
	objSwf.list:invalidateData();
end

--显示锁
function UIQiZhanZhenYan:ShowImgSuo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i=1, self.slotTotalNum do
		objSwf["statebtn"..i]._visible = false;
		local state,level = QiZhanUtils:GetQiYinStateByPos(i-1);
		if not state then
			objSwf["statebtn"..i]._visible = true;
		end
	end
end

--添加Item
function UIQiZhanZhenYan:DoAddItem(pos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_QiZhan);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end;
	local objSwf = self.objSwf
	if not objSwf then return; end
	local bagSlotVO = self.list[pos+1];
	bagSlotVO.hasItem = true;
	bagSlotVO.id = item:GetId();
	bagSlotVO.tid = item:GetTid();
	bagSlotVO.count = item:GetCount();
	bagSlotVO.bindState = item:GetBindState();
	objSwf.list.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = objSwf.list:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

--移除Item
function UIQiZhanZhenYan:DoRemoveItem(pos)
	local objSwf = self.objSwf;
	if not objSwf then return; end;
	local bagSlotVO = self.list[pos+1];
	bagSlotVO.hasItem = false;
	objSwf.list.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = objSwf.list:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

--更新Item
function UIQiZhanZhenYan:DoUpdateItem(pos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_QiZhan);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagSlotVO = self.list[pos+1];
	bagSlotVO.id = item:GetId();
	bagSlotVO.tid = item:GetTid();
	bagSlotVO.count = item:GetCount();
	bagSlotVO.bindState = item:GetBindState();
	objSwf.list.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = objSwf.list:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

function UIQiZhanZhenYan:OnItemRollOver(item)
	local data = item:GetData();
	if not data.hasItem then
		local state,level = QiZhanUtils:GetQiYinStateByPos(data.pos);
		if state then
			local str = string.format(StrConfig['qizhan1008'], BagConsts:GetQiZhanZhenYanEquipNameByPos(data.pos));
			TipsManager:ShowBtnTips(str);
		else
			local str = string.format(StrConfig['qizhan1009'], level);  
			TipsManager:ShowBtnTips(str);
		end
		return;
	end
	TipsManager:ShowBagTips(BagConsts.BagType_QiZhan,data.pos);
end

function UIQiZhanZhenYan:OnItemRollOut(item)
	TipsManager:Hide();
end

--双击卸载
function UIQiZhanZhenYan:OnItemDoubleClick(item)
	TipsManager:Hide();
	local data = item:GetData();
	if not data.hasItem  then
		return;
	end
	BagController:UnEquipItem(BagConsts.BagType_QiZhan,data.pos);
end

--右键卸载
function UIQiZhanZhenYan:OnItemRClick(item)
	TipsManager:Hide();
	local data = item:GetData();
	if not data.hasItem then
		return;
	end
	BagController:UnEquipItem(BagConsts.BagType_QiZhan,data.pos);
end

-- 拖拽中
function UIQiZhanZhenYan:OnItemDragIn(fromData,toData)
	--print("拖拽中")
	if toData.hasItem then return end
	
	local itemData = fromData;
	if not itemData then
		return;
	end	
	if not BagUtil:GetLevelAccord(itemData.tid) then
		FloatManager:AddNormal( StrConfig["qizhan2"]);
		return
	end
	--是装备,穿戴
	if BagUtil:GetItemShowType(itemData.tid)==BagConsts.ShowType_Equip then
		BagController:EquipItem(BagConsts.BagType_Bag,itemData.pos);
		return;
    end
end;
---------------------------以上是装备处理--------------------------------------