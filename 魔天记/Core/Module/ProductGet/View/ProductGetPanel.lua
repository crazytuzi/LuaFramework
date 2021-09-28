require "Core.Module.Common.Panel"
ProductGetPanel = class("ProductGetPanel", Panel)

function ProductGetPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function ProductGetPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtTitle = UIUtil.GetChildInComponents(txts, "txtTitle");
	self._txtItemType = UIUtil.GetChildInComponents(txts, "txtItemType");
	self._txtUseLevel = UIUtil.GetChildInComponents(txts, "txtUseLevel");
	self._txtDec = UIUtil.GetChildInComponents(txts, "txtDec");
	self._txtPrice = UIUtil.GetChildInComponents(txts, "txtPrice");
	local product = UIUtil.GetChildByName(self._trsContent, "Product").gameObject;
	self._productCtrl = ProductCtrl:New();
	self._productCtrl:Init(product, {hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle}, false);
	
	self._txtName1 = UIUtil.GetChildInComponents(txts, "txtName1");
	self._txtName2 = UIUtil.GetChildInComponents(txts, "txtName2");
	self._txtName3 = UIUtil.GetChildInComponents(txts, "txtName3");
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UISprite");
	self._imgicon1 = UIUtil.GetChildInComponents(txts, "imgicon1");
	self._imgicon2 = UIUtil.GetChildInComponents(txts, "imgicon2");
	self._imgicon3 = UIUtil.GetChildInComponents(txts, "imgicon3");
	self._item1 = UIUtil.GetChildInComponents(txts, "item1");
	self._item2 = UIUtil.GetChildInComponents(txts, "item2");
	self._item3 = UIUtil.GetChildInComponents(txts, "item3");
	self._item1.name = "1"
	self._item2.name = "2"
	self._item3.name = "3"
	
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
end

function ProductGetPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close)
	
	self._onClickItem = function(go) self:_OnClickItem(go) end
	UIUtil.GetComponent(self._item1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem)
	UIUtil.GetComponent(self._item2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem)
	UIUtil.GetComponent(self._item3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem)
end

function ProductGetPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(ProductGetNotes.CLOSE_EQUIP_GET_PANEL)
end

function ProductGetPanel:_OnClickItem(go)
	local info = self._getinfo[tonumber(go.name)]
	local _updateNote = self._updateNote
	ModuleManager.SendNotification(ProductGetNotes.CLOSE_EQUIP_GET_PANEL)
	local id = info[2]
	
	if info[1] == '2' then
		local storeConfig = MallManager.GetStoreById(tonumber(id))
	 
        ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3, other = storeConfig, updateNote = _updateNote });
		--ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, {val = 1, other = storeConfig, updateNote = _updateNote})
	else
		ActivityDataManager.OpenActivityUI(id)
	end
end

function ProductGetPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function ProductGetPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
	UIUtil.GetComponent(self._item1, "LuaUIEventListener"):RemoveDelegate("OnClick")
	UIUtil.GetComponent(self._item2, "LuaUIEventListener"):RemoveDelegate("OnClick")
	UIUtil.GetComponent(self._item3, "LuaUIEventListener"):RemoveDelegate("OnClick")
	self._onClickItem = nil
end

function ProductGetPanel:_DisposeReference()
	self._productCtrl:Dispose()
end

function ProductGetPanel:SetData(info, getinfo, updateNote)
	self._updateNote = updateNote
	self._productCtrl:SetData(info);
	
	local quality = info:GetQuality();
	self._txtTitle.text = ColorDataManager.GetColorTextByQuality(quality, info:GetName());
	
	-- 需要判断是否 符合要求
	local r_lv = info:GetReq_lev();
	local me = HeroController:GetInstance();
	local heroInfo = me.info;
	local my_lv = heroInfo.level;
	
	if my_lv < r_lv then
		self._txtUseLevel.text = "[ff4b4b]" .. info:GetReq_lev() .. LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label1") .. "[-]";
	else
		self._txtUseLevel.text = info:GetReq_lev() .. LanguageMgr.Get("ProductTip/EquipComparisonLeftPanel/label1");
	end
	
	self._txtItemType.text = info:GetTypeName();
	self._txtPrice.text = info:GetPrice();
	self._txtDec.text = info:GetDesc()
	
	self._getinfo = getinfo
	self._item1.gameObject:SetActive(true)
	self:SetItem(self._txtName1, self._imgicon1, getinfo[1])
	local len = # getinfo
	if len > 1 then
		self._item2.gameObject:SetActive(true)
		self:SetItem(self._txtName2, self._imgicon2, getinfo[2])
	end
	if len > 2 then
		self._item3.gameObject:SetActive(true)
		self:SetItem(self._txtName3, self._imgicon3, getinfo[3])
	end
end

function ProductGetPanel:SetItem(txt, icon, d)
	d[2] = tonumber(d[2])
	if d[1] == '2' then
		icon.spriteName = '50'
		txt.text = LanguageMgr.Get("ProductGetPanel/mall")
	else
		local ac = ProductGetProxy.GetActivityConfig(d[2])
		icon.spriteName = ac.activity_icon
		txt.text = ac.activity_name
	end
	UIUtil.AdjustHeight(icon, 0)
end
