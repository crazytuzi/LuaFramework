--[[
]]

_G.UIHun = BaseSlotPanel:new("UIHun");

UIHun.slotTotalNum = 9;--UI上格子总数
UIHun.list = {};--当前格子
UIHun.effectTotalNum = 3;--套装特效
UIHun.STORE = "store"

function UIHun:Create()
	self:AddSWF("magicWeaponHun.swf", true, nil)
	
	self:AddChild(UIHunStore, UIHun.STORE)
end

function UIHun:OnLoaded(objSwf,name)
	self:GetChild(UIHun.STORE):SetContainer(objSwf.childPanel);
	--初始化格子
	for i=1,self.slotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end
	objSwf.btnbag.click = function() self:OnOpenHouse() end;
	objSwf.btnbag.label = StrConfig['magicWeapon061']
end

function UIHun:OnDelete()
	self:RemoveAllSlotItem();
end

function UIHun:OnShow()
	self:UpdateShow();
	self:Show3DWeapon();
end

function UIHun:OnHide()
	if self.objAvatar then
		self.objAvatar:Destroy()
		self.objAvatar = nil
	end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false)
	end
end

function UIHun:UpdateShow()
	self:ShowEquip();
	self:ShowImgSuo();
	self:ShowGroupEffect();
	self:ShowFight();
	self:ShowAttr();
end

local viewPort
function UIHun:Show3DWeapon()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1100, 744) end
		self.objUIDraw = UISceneDraw:new( "UIHun", objSwf.loader, viewPort );
	end
	local func = function()
		local skn, skl, san, pfx = "sq_zhushenzhiren_01.skn", "sq_zhushenzhiren_01.skl", "sq_dajian_ui_daiji.san", "sq_zhushenzhiren_11.pfx"
		self.objAvatar = ShenWuAvatar:new(skn, skl, san)
		local list = self.objUIDraw:GetMarkers()
		local marker
		for _, mkr in pairs(list) do
			marker = mkr
			break
		end
		if not marker then return end
		self.objAvatar:EnterUIScene( self.objUIDraw.objScene, marker.pos, marker.dir, marker.scale, enEntType.eEntType_ShenWu)
		self.objAvatar:PlayPfxOnBone(skl, pfx, pfx)
		self.objAvatar:ExecIdleAction()
	end

	self.objUIDraw:SetUILoader( objSwf.loader )
	self.objUIDraw:SetScene( "sq_zhushenzhiren_01.sen", func )
	self.objUIDraw:SetDraw( true )
end

-- 仓库
function UIHun:OnOpenHouse()
	if not UIHunStore:IsShow() then 
		self:OnShowHouse()
	else
		UIHunStore:Hide();
	end;
end;

-- 显示仓库
function UIHun:OnShowHouse()
	local child = self:GetChild(UIHun.STORE)
	if not child then return end;
	self:ShowChild(UIHun.STORE)
end;

---------------------------------消息处理------------------------------------
function UIHun:HandleNotification(name,body)
	if name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		if body.type == BagConsts.BagType_Hun then
			self:DoAddItem(body.pos)
			self:UpdateShow()
		end
	elseif name == NotifyConsts.MagicWeaponLevelUp then
		self:ShowImgSuo()
	end
end

function UIHun:ListNotificationInterests()
	return {
		NotifyConsts.MagicWeaponLevelUp,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate
	};
end

function UIHun:ShowFight()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local nfight, attrlist = MagicWeaponUtils:GetHunAttrMap();
	objSwf.numLoaderFight.num = nfight;
end

function UIHun:ShowAttr()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local nfight, attrMap = MagicWeaponUtils:GetHunAttrMap();
	if not attrMap then return; end
	local attrTotal = {};
	for _, attrName in pairs(MagicWeaponConsts.HunAttrs) do
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
function UIHun:ShowEquip()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.list = BagUtil:GetBagItemList(BagConsts.BagType_Hun,BagConsts.ShowType_All);
    objSwf.list.dataProvider:cleanUp();
	for i,slotVO in ipairs(self.list) do
		local defaultIcon = "img://resfile/itemicon/default.png";
		local equipConfig = t_equip[slotVO.tid];
		slotVO.iconUrl = equipConfig and ResUtil:GetItemIconUrl(equipConfig.icon,64) or defaultIcon
		local dataObj = UIData.decode(slotVO:GetUIData());
		if dataObj.tid > 0 then
			dataObj.qualityUrl = ResUtil:GetSlotYuanQuality(t_equip[dataObj.tid].quality,true);
		end
		objSwf.list.dataProvider:push(UIData.encode(dataObj));
	end
	objSwf.list:invalidateData();
end

--显示锁
function UIHun:ShowImgSuo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i=1, self.slotTotalNum do
		objSwf["statebtn"..i]._visible = false;
		local state,level = MagicWeaponUtils:GetHunStateByPos(i-1);
		if not state then
			objSwf["statebtn"..i]._visible = true;
		end
	end
end

function UIHun:ShowGroupEffect()
	
end

--添加Item
function UIHun:DoAddItem(pos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Hun);
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
function UIHun:DoRemoveItem(pos)
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
function UIHun:DoUpdateItem(pos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Hun);
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

function UIHun:OnItemRollOver(item)
	local data = item:GetData();
	if not data.hasItem then
		local state,level = MagicWeaponUtils:GetHunStateByPos(data.pos);
		if state then
			local str = string.format(StrConfig['magicWeapon059'], BagConsts:GetShenBingHunEquipNameByPos(data.pos));
			TipsManager:ShowBtnTips(str);
		else
			local str = string.format(StrConfig['magicWeapon060'], level);
			TipsManager:ShowBtnTips(str);
		end
		return;
	end
	TipsManager:ShowBagTips(BagConsts.BagType_Hun,data.pos);
end

function UIHun:OnItemRollOut(item)
	TipsManager:Hide();
end

--双击卸载
function UIHun:OnItemDoubleClick(item)
	TipsManager:Hide();
	local data = item:GetData();
	if not data.hasItem  then
		return;
	end
	BagController:UnEquipItem(BagConsts.BagType_Hun,data.pos);
end

--右键卸载
function UIHun:OnItemRClick(item)
	TipsManager:Hide();
	local data = item:GetData();
	if not data.hasItem then
		return;
	end
	BagController:UnEquipItem(BagConsts.BagType_Hun,data.pos);
end
---------------------------以上是装备处理--------------------------------------