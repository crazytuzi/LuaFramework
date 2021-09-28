require "Core.Module.Common.Panel"

require "Core.Module.Backpack.View.PageItem"
require "Core.Manager.Item.MoneyDataManager";
require "Core.Manager.PlayerManager";
require "Core.Manager.Item.BackpackDataManager";
require "Core.Manager.Item.EquipDataManager";
require "Core.Module.Common.UIHeroAnimationModel"

BackpackPanel = Panel:New();


function BackpackPanel:_Init()
	self:_InitReference();
	self:_InitListener();
	local data = RoleModelCreater.CloneDress(PlayerManager.GetPlayerInfo(), true, true, false)

 
	-- local data = ConfigManager.Clone(PlayerManager.GetPlayerInfo())
	self._uiHeroAnimationModel = UIHeroAnimationModel:New(data, self._roleParent)


end

function BackpackPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtHeroName = UIUtil.GetChildInComponents(txts, "txtHeroName");
	self._txtVip = UIUtil.GetChildInComponents(txts, "txtVip");
	self._txtPower = UIUtil.GetChildInComponents(txts, "txtPower");
	
	self._coinBar = UIUtil.GetChildByName(self._trsContent, "CoinBar");
	self._coinBarCtrl = CoinBar:New(self._coinBar);
	
	
	self._txt_title = UIUtil.GetChildInComponents(txts, "txt_title");
	self._txt_title = UIUtil.GetChildInComponents(txts, "txt_title");
	self._txt_title = UIUtil.GetChildInComponents(txts, "txt_title");
	self._txt_title = UIUtil.GetChildInComponents(txts, "txt_title");
	self._txt_title = UIUtil.GetChildInComponents(txts, "txt_title");
	self._txt_proudctNumpc = UIUtil.GetChildInComponents(txts, "txt_proudctNumpc");
	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
	
	self._btnReset = UIUtil.GetChildInComponents(btns, "btnReset");
	self._btnShop = UIUtil.GetChildInComponents(btns, "btnShop");
	
	
	self._leftPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "leftPanel");
	self._rightPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "rightPanel");
	self._bag_all = UIUtil.GetChildByName(self._rightPanel, "Transform", "bag_all");
	self._ScrollView = UIUtil.GetChildByName(self._bag_all, "Transform", "ScrollView");
	self._pag_phalanx = UIUtil.GetChildByName(self._ScrollView, "LuaAsynPhalanx", "bag_phalanx");
	
	
	
	
	self._pages = UIUtil.GetChildByName(self._rightPanel, "Transform", "pages");
	self._product_tabs = UIUtil.GetChildByName(self._rightPanel, "Transform", "product_tabs");
	
	local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
	self._roleParent = UIUtil.GetChildInComponents(trss, "trsRoleParent");
	
	self._pageIcons = {};
	self._pageIcons["0"] = UIUtil.GetChildByName(self._pages, "UISprite", "pageSelect0");
	self._pageIcons["1"] = UIUtil.GetChildByName(self._pages, "UISprite", "pageSelect1");
	self._pageIcons["2"] = UIUtil.GetChildByName(self._pages, "UISprite", "pageSelect2");
	self._pageIcons["3"] = UIUtil.GetChildByName(self._pages, "UISprite", "pageSelect3");
	self._pageIcons["4"] = UIUtil.GetChildByName(self._pages, "UISprite", "pageSelect4");
	
	self.myUICenterOnChild = UIUtil.GetComponent(self._pag_phalanx, "MyUICenterOnChild");
	
	self.myUICenterOnChildCallBack = function(name) self:PageChange(name); end
	self.myUICenterOnChild.onFinishedHandler = self.myUICenterOnChildCallBack;
	
	self:SetTagleHandler(BackpackNotes.classify_all);
	self:SetTagleHandler(BackpackNotes.classify_eq);
	self:SetTagleHandler(BackpackNotes.classify_mat);
	self:SetTagleHandler(BackpackNotes.classify_st);
	self:SetTagleHandler(BackpackNotes.classify_sue);
	
	
	self:InitEqule(self._leftPanel);
	
	self._curr_classify = nil;
	
	MessageManager.AddListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, BackpackPanel.ProductsChange, self);
	MessageManager.AddListener(EquipDataManager, EquipDataManager.MESSAGE_EQUIP_BAG_PRODUCTS_CHANGE, BackpackPanel.EquipChange, self);
	MessageManager.AddListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, BackpackPanel.MoneyChange, self);
	MessageManager.AddListener(BackPackCDData, BackPackCDData.MESSAGE_PRODUCTS_CD_CHANGE, BackpackPanel.ProductCDChange, self);
	
	MessageManager.AddListener(BackpackProxy, BackpackProxy.MESSAGE_CD_BOXIDX_CHANGE, BackpackPanel.BoxIdx_CD_change, self);
	
	MessageManager.AddListener(EquipDataManager, EquipDataManager.MESSAGE_EXTEQUIP_CHANGE, BackpackPanel.UpExtEquip, self);
	
	-- test
	-- HeroController:GetInstance():StartFollow(20100582,RoleFollowAiController.FOLLOW_TYPE_LEADER);
	self:UpExtEquip();
	
end




function BackpackPanel:_Opened()
	--  self._trsContent.gameObject:SetActive(false);
	--  self._trsContent.gameObject:SetActive(true);
end

function BackpackPanel:ProductsChange()
	
	self:SetBagCalssiftByTypes(self._curr_types);
end

function BackpackPanel:EquipChange()
	self:UpEquips();
end

function BackpackPanel:MoneyChange()
	self:SetMomeyData();
end



function BackpackPanel:InitEqule(parent)
	
	self._equitPanel = UIUtil.GetChildByName(parent, "Transform", "equitPanel");
	self._equipsCtrls = {};
	
	for i = 1, 8 do
		local eq_gameObject = UIUtil.GetChildByName(self._equitPanel, "eq_" .. i).gameObject;
		self._equipsCtrls[i] = ProductCtrl:New();
		self._equipsCtrls[i]:Init(eq_gameObject, {hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_circle});
		self._equipsCtrls[i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_EQUIPS);
	end
	
	self._extEquipsCtrls = {};
	
	for i = 1, 2 do
		local eq_gameObject = UIUtil.GetChildByName(self._equitPanel, "extEq_" .. i).gameObject;
		self._extEquipsCtrls[i] = ProductCtrl:New();
		self._extEquipsCtrls[i]:Init(eq_gameObject, {hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_circle});
		self._extEquipsCtrls[i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_EQUIPS);
	end
	
end

function BackpackPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	
	self._onClickBtnReset = function(go) self:_OnClickBtnReset(self) end
	UIUtil.GetComponent(self._btnReset, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReset);
	self._onClickBtnShop = function(go) self:_OnClickBtnShop(self) end
	UIUtil.GetComponent(self._btnShop, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnShop);
end

function BackpackPanel:_OnClickBtnShop()
	ModuleManager.SendNotification(TShopNotes.OPEN_TSHOP, {type = TShopNotes.Shop_type_npc});
	
end

function BackpackPanel:InitData()
	self._productPanels = {};
	self._productPanels_index = 1;
	local data = {
		{name = "page0", page_id = "0"},
		{name = "page1", page_id = "1"},
		{name = "page2", page_id = "2"},
		{name = "page3", page_id = "3"},
		{name = "page4", page_id = "4"},
	}
	
	
	self.pag_phalanx = Phalanx:New();
	self.pag_phalanx:Init(self._pag_phalanx, PageItem)
	self.pag_phalanx:Build(1, 5, data);
	self.currPage_id = "-1";
	
	
	local num = self._productPanels_index - 1;
	for i = 1, num do
		self._productPanels[i]:SetIdx(i);
	end
	
	self._centerOnChild = UIUtil.GetChildByName(self._ScrollView, "UICenterOnChild", "bag_phalanx")
	self._delegate = function(go) self:_OnCenterCallBack(go) end;
	self._centerOnChild.onCenter = self._delegate
	
	
end

function BackpackPanel:_OnCenterCallBack(go)
	if(go and self.pag_phalanx ~= nil) then
		if(self._currentGo == go) then
			return
		end
		self._currentGo = go
		
		local index = self.pag_phalanx:GetItemIndex(go)
		
		self:upPageIcon(index - 1);
		
	end
end


function BackpackPanel:_OnClickBtn_close()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
	ModuleManager.SendNotification(BackpackNotes.CLOSE_BAG_ALL)
end


function BackpackPanel:_OnClickBtnReset()
	BackpackProxy.TryResetBackPack()
end

function BackpackPanel:SetTagleHandler(name)
	
	self[name .. "Handler"] = function(go) self:Classify_OnClick(name) end
	self["_" .. name] = UIUtil.GetChildByName(self._product_tabs, "Transform", name).gameObject;
	UIUtil.GetComponent(self["_" .. name], "LuaUIEventListener"):RegisterDelegate("OnClick", self[name .. "Handler"]);
	
end

function BackpackPanel:RemoveTagle(name)
	
	UIUtil.GetComponent(self["_" .. name], "LuaUIEventListener"):RemoveDelegate("OnClick");
	
	self[name .. "Handler"] = nil;
end


function BackpackPanel:SetTagleSelect(name)
	
	local gobj = UIUtil.GetChildByName(self._product_tabs, "Transform", name).gameObject;
	local toggle = UIUtil.GetComponent(gobj, "UIToggle");
	toggle.value =(true);
end

function BackpackPanel:PageChange(args)
	
	local str_len = string.len(args);
	local page_id = string.sub(args, str_len, - 1);
	
	if self.currPage_id ~= page_id then
		self.currPage_id = page_id;
		self:ShowPageIcon(self.currPage_id);
	end
	
	self:CheckLockCD();
	
end

function BackpackPanel:CheckLockCD()
	local num = self._productPanels_index - 1;
	for i = 1, num do
		self._productPanels[i]:CheckLockCD();
	end
end

function BackpackPanel:BoxIdx_CD_change()
	
	if BackPackBoxLockCDCtr.enble then
		
		self:CheckLockCD();
		
	end
	
end

function BackpackPanel:OnPressedHandler(args)
	
	local str_len = string.len(args);
	local pid = string.sub(args, str_len, - 1);
	
	-- 设置 显示
	-- self:upPageV(pid);
end

-- function BackpackPanel:upPageV(pid)
--     local _items = self.pag_phalanx._items;
--     pid = pid + 0;
--     if pid == 0 then
--         _items[1].itemLogic:SetActive(true);
--         _items[2].itemLogic:SetActive(true);
--     elseif pid == 1 then
--         _items[1].itemLogic:SetActive(true);
--         _items[2].itemLogic:SetActive(true);
--         _items[3].itemLogic:SetActive(true);
--     elseif pid == 2 then
--         _items[2].itemLogic:SetActive(true);
--         _items[3].itemLogic:SetActive(true);
--         _items[4].itemLogic:SetActive(true);
--     elseif pid == 3 then
--         _items[3].itemLogic:SetActive(true);
--         _items[4].itemLogic:SetActive(true);
--         _items[5].itemLogic:SetActive(true);
--     elseif pid == 4 then
--         _items[4].itemLogic:SetActive(true);
--         _items[5].itemLogic:SetActive(true);
--     end
-- end
function BackpackPanel:Classify_OnClick(name)
	
	BackPackBoxLockCDCtr.enble = false;
	
	if self._curr_classify ~= name then
		self._curr_classify = name;
		if name == BackpackNotes.classify_all then
			self:SetBagCalssiftByTypes({0});
			BackPackBoxLockCDCtr.enble = true;
		elseif name == BackpackNotes.classify_eq then
			self:SetBagCalssiftByTypes({1});
		elseif name == BackpackNotes.classify_mat then
			self:SetBagCalssiftByTypes({3, 7});
		elseif name == BackpackNotes.classify_st then
			self:SetBagCalssiftByTypes({2});
		elseif name == BackpackNotes.classify_sue then
			self:SetBagCalssiftByTypes({4, 5, 6});
		end
		
		local tf = self.pag_phalanx:GetItem(1).gameObject.transform;
		self.myUICenterOnChild:CenterOn(tf);
		self:PageChange("0");
	end
	
end

-- 锁/解锁 所有的物品容器
function BackpackPanel:SetlockAllProductPanel(v)
	local nun = self._productPanels_index - 1;
	self:SetlockProductPanels(1, nun, v);
end

function BackpackPanel:SetlockProductPanels(startIndex, endIndex, v)
	for i = startIndex, endIndex do
		self:SetProductPanelLock(i, v);
	end
end

function BackpackPanel:SetProductPanelLock(index, v)
	self._productPanels[index]:SetLock(v);
end

function BackpackPanel:ShowPageIcon(pid)
	
	-- local _items = self.pag_phalanx._items;
	self:upPageIcon(pid)
	
	-- for j = 1, 5 do
	--     _items[j].itemLogic:SetActive(false);
	-- end
	-- self:upPageV(pid);
end

function BackpackPanel:upPageIcon(pid)
	
	
	pid = pid .. "";
	
	for j = 1, 5 do
		local index = j - 1;
		local id = "" .. index;
		
		if pid == id then
			self._pageIcons[id].spriteName = "circle2";
			self._pageIcons[id]:MakePixelPerfect();
		else
			self._pageIcons[id].spriteName = "circle1";
			self._pageIcons[id]:MakePixelPerfect();
		end
	end
	
end

function BackpackPanel:SetData()
	self:SetPlayerInfo();
	self:UpEquips();
	
	self:SetTagleSelect(BackpackNotes.classify_all);
	self:Classify_OnClick(BackpackNotes.classify_all);

    self._gameObject:SetActive(true);
end

-- 设置左边装备栏数据
function BackpackPanel:UpEquips()
	
	for i = 1, 8 do
		local pinfo = EquipDataManager.GetProductByKind(i);
		self._equipsCtrls[i]:SetData(pinfo);
	end
	
	self._txtPower.text = PlayerManager.GetSelfFightPower() .. "";
end

function BackpackPanel:UpExtEquip()
	
	local extEqinfo1 = EquipDataManager.GetExtEquip(EquipDataManager.ExtEquipIdx.Idx1);
	local extEqinfo2 = EquipDataManager.GetExtEquip(EquipDataManager.ExtEquipIdx.Idx2);
	
	self._extEquipsCtrls[1]:SetData(extEqinfo1);
	self._extEquipsCtrls[2]:SetData(extEqinfo2);
	
end

function BackpackPanel:SetBagCalssiftByTypes(types)
	
	self._curr_types = types;
	local products = nil;
	local pnum = 0;
	local needByIndex = false;
	
	if types[1] == 0 then
		-- 全部物品
		products = BackpackDataManager.GetAllProducts(false);
		local bagSize = BackpackDataManager.GetBagSize();
		self:SetlockAllProductPanel(true);
		self:SetlockProductPanels(1, bagSize, false);
		pnum = BackpackDataManager.GetProductNum();
		needByIndex = true;
	else
		products = BackpackDataManager.GetProductsByTypes(types);
		self:SetlockAllProductPanel(false);
		pnum = table.getn(products);
		needByIndex = false;
	end
	
	self:ResetProductInfos();
	self:SetProductInfos(products, needByIndex);
	
	
	local bs = BackpackDataManager.GetBagSize();
	
	self._txt_proudctNumpc.text = pnum .. "/" .. bs;
end

function BackpackPanel:SetProductInfos(infos, needByIndex)
	
	local index = 0;
	
	for key, value in pairs(infos) do
		
		if needByIndex then
			index = key + 1;
		else
			index = index + 1;
		end
		
		self._productPanels[index]:SetData(value);
	end
end

function BackpackPanel:ProductCDChange()
	for key, value in pairs(self._productPanels) do
		value:ProductCDChange();
	end
end





function BackpackPanel:ResetProductInfos()
	local num = self._productPanels_index - 1;
	for i = 1, num do
		self._productPanels[i]:SetData(nil);
	end
end

function BackpackPanel:SetPlayerInfo()
	
	local info = PlayerManager.GetPlayerInfo();
	self._txtHeroName.text = info:GetName() .. "      " .. GetLvDes(info:GetLevel());
	
	self._txtVip.text = VIPManager.GetVIPShowLevel() .. "";
end

function BackpackPanel:SetMomeyData()
	
	
end


function BackpackPanel:AddProductItem(v)
	self._productPanels[self._productPanels_index] = v;
	self._productPanels_index = self._productPanels_index + 1;
end

function BackpackPanel:_Dispose()
	self:_DisposeReference();
	self._uiHeroAnimationModel:Dispose()
	self._uiHeroAnimationModel = nil;
	
	
	self._txtHeroName = nil;
	self._txtVip = nil;
	self._txtPower = nil;
	
	self._coinBar = nil;
	self._coinBarCtrl = nil;
	
	
	self._txt_title = nil;
	
	self._txt_proudctNumpc = nil;
	
	self._btn_close = nil;
	
	self._btnReset = nil;
	
	self._leftPanel = nil;
	self._rightPanel = nil;
	self._bag_all = nil;
	self._ScrollView = nil;
	
	
	
	self._pages = nil;
	self._product_tabs = nil;
	
	
	self._roleParent = nil;
	
	self._pageIcons = nil;
	
	
	
	self.myUICenterOnChildCallBack = nil;
	if self.myUICenterOnChild and self.myUICenterOnChild.onFinishedHandler then
		self.myUICenterOnChild.onFinishedHandler:Destroy();
		self.myUICenterOnChild = nil;
	end
	
end

function BackpackPanel:_DisposeReference()
	
	
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	UIUtil.GetComponent(self._btnReset, "LuaUIEventListener"):RemoveDelegate("OnClick");
	UIUtil.GetComponent(self._btnShop, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnShop = nil
	self._onClickBtn_close = nil;
	self._onClickBtnReset = nil;
	
	self._btn_close = nil;
	
	self._btnReset = nil;
	
	MessageManager.RemoveListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, BackpackPanel.ProductsChange);
	MessageManager.RemoveListener(EquipDataManager, EquipDataManager.MESSAGE_EQUIP_BAG_PRODUCTS_CHANGE, BackpackPanel.EquipChange);
	MessageManager.RemoveListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, BackpackPanel.MoneyChange)
	
	MessageManager.RemoveListener(BackPackCDData, BackPackCDData.MESSAGE_PRODUCTS_CD_CHANGE, BackpackPanel.ProductCDChange);
	MessageManager.RemoveListener(BackpackProxy, BackpackProxy.MESSAGE_CD_BOXIDX_CHANGE, BackpackPanel.BoxIdx_CD_change);
	
	MessageManager.RemoveListener(EquipDataManager, EquipDataManager.MESSAGE_EXTEQUIP_CHANGE, BackpackPanel.UpExtEquip);
	
	self._coinBarCtrl:Dispose();

    self._delegate = nil;
	if self._centerOnChild and self._centerOnChild.onCenter then
		self._centerOnChild.onCenter:Destroy();
	end
	
	for key, value in pairs(self._productPanels) do
		value:_Dispose();
	end
	
	for i = 1, 8 do
		self._equipsCtrls[i]:Dispose()
	end
	
	for i = 1, 2 do
		self._extEquipsCtrls[i]:Dispose();
	end
	
	if self.pag_phalanx ~= nil then
		self.pag_phalanx:Dispose();
		self.pag_phalanx = nil;
	end
	
	self:RemoveTagle(BackpackNotes.classify_all);
	self:RemoveTagle(BackpackNotes.classify_eq);
	self:RemoveTagle(BackpackNotes.classify_mat);
	self:RemoveTagle(BackpackNotes.classify_st);
	self:RemoveTagle(BackpackNotes.classify_sue);
	
	
	BackPackBoxLockCDCtr.SetDaoJiShiHandler(nil, nil);
	
end
