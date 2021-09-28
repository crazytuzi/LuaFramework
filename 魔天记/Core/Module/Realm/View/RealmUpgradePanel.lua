require "Core.Module.Common.UISubPanel";
require "Core.Module.Common.UIHeroAnimationModel"
require "Core.Manager.Item.RealmManager"
require "Core.Manager.Item.MoneyDataManager";
require "Core.Module.Realm.View.Item.RealmUpgradeLevel"
local BaseIconItem = require "Core.Module.Common.BaseIconItem"
local BaseNextPropertyItem = require "Core.Module.Common.BaseNextPropertyItem"

RealmUpgradePanel = class("RealmUpgradePanel", UISubPanel)

function RealmUpgradePanel:New(transform)
	if(transform) then
		self = {};
		setmetatable(self, {__index = RealmUpgradePanel});
		-- self._imgBg = imgBg;
		self:Init(transform)
		-- self._nextHasSkillLevel = self:_GetNextHasSkillLevel();
		return self;
	end
	return nil;
end

function RealmUpgradePanel:_InitReference()
	
	self._trsLevelAttributes = UIUtil.GetChildByName(self._transform, "Transform", "trsLevelAttributes");
	self._trsCanUpdate = UIUtil.GetChildByName(self._transform, "CanUpdate")
	self._trsCantUpdate = UIUtil.GetChildByName(self._transform, "CantUpdate")
	
	self._imgTitle = UIUtil.GetChildByName(self._transform, "UISprite", "imgTitle");
	self._imgTitleLV = UIUtil.GetChildByName(self._transform, "UISprite", "imgTitleLV");
	-- self._txtTitle = UIUtil.GetChildByName(self._transform, "UILabel", "txtTitle");
	self._txtMySpend = UIUtil.GetChildByName(self._transform, "UILabel", "txtMySpend");
	
	-- self._txtAttributes = UIUtil.GetChildByName(self._transform, "UILabel", "txtAttributes");
	-- self._txtActivate = UIUtil.GetChildByName(self._transform, "UILabel", "txtActivate");
	self._helpPanel = UIUtil.GetChildByName(self._transform, "Transform", "helpPanel");
	self._helpPanelMask = UIUtil.GetChildByName(self._helpPanel, "Transform", "mask");
	self._btnHelp = UIUtil.GetChildByName(self._transform, "UIButton", "btnHelp");
	
	self._btnUpgrade = UIUtil.GetChildByName(self._trsCanUpdate, "UIButton", "btnUpgrade");
	self._txtUpgradeLabel = UIUtil.GetChildByName(self._btnUpgrade, "UILabel", "Label");
	
	self._txtFight = UIUtil.GetChildByName(self._transform, "UILabel", "txtFight");
	
	self._txtNeedFight = UIUtil.GetChildByName(self._trsCanUpdate, "UILabel", "txtNeedFight");
	self._txtNeedRes = UIUtil.GetChildByName(self._trsCanUpdate, "UILabel", "txtNeedRes");
	self._txtNum = UIUtil.GetChildByName(self._trsCanUpdate, "UILabel", "item/num")
	self._imgRole = UIUtil.GetChildByName(self._transform, "UITexture", "imgRole");
	self._effect = UIUtil.GetChildByName(self._transform, "imgRole/uEffect")
	self._uiEffect = UIEffect:New()
	self._uiEffect:Init(self._effect, self._imgRole, 5, "ui_realm1")
	
	local item = UIUtil.GetChildByName(self._trsCanUpdate, "item").gameObject
	self._baseIconItem = BaseIconItem:New()
	self._baseIconItem:Init(item)
	self._baseIconItem:SetActive(false)
	local data = RoleModelCreater.CloneDress(PlayerManager.GetPlayerInfo(), fasle, false, false)	
	data.dress.a = 0
	-- dress：{a:spId武器,b:spId衣服,w:spId翅膀,m:载具id,h:spId坐骑,c:模型id,String,t:spId法宝}
	-- self._heroCamera = UIUtil.GetChildByName(self._transform, "Camera", "imgRole/heroCamera");
	self._roleParent = UIUtil.GetChildByName(self._transform, "imgRole/heroCamera/trsRoleParent");
	self._uiHeroAnimationModel = UIHeroAnimationModel:New(data, self._roleParent, "dazuo");
	
	self._lvItems = {}
	for i = 1, 9 do
		local item = UIUtil.GetChildByName(self._trsLevelAttributes, "item" .. i).gameObject
		self._lvItems[i] = RealmUpgradeLevel:New(item, i)
	end
	self._curPropertyPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "propertyPhalanx")
	self._curPropertyPhalanx = Phalanx:New()
	self._curPropertyPhalanx:Init(self._curPropertyPhalanxInfo, BasePropertyItem)
	
	self._nextPropertyPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "nextpropertyPhalanx")
	self._nextPropertyPhalanx = Phalanx:New()
	self._nextPropertyPhalanx:Init(self._nextPropertyPhalanxInfo, BaseNextPropertyItem)
	
	
	self:_OnHelpMaskButtonClick();
	self:_RefreshUI();
end

function RealmUpgradePanel:_InitListener()
	MessageManager.AddListener(RealmNotes, RealmNotes.EVENT_REALMUPGRADE, RealmUpgradePanel._OnRealmUpgrade, self);
	MessageManager.AddListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, RealmUpgradePanel.OnProductsChange, self);
	self._onUpgradeButtonClick = function(go) self:_OnUpgradeButtonClick() end
	UIUtil.GetComponent(self._btnUpgrade, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onUpgradeButtonClick);
	
	self._onHelpButtonClick = function(go) self:_OnHelpButtonClick() end
	UIUtil.GetComponent(self._btnHelp, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onHelpButtonClick);
	
	self._onHelpMaskButtonClick = function(go) self:_OnHelpMaskButtonClick() end
	UIUtil.GetComponent(self._helpPanelMask, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onHelpMaskButtonClick);
end

function RealmUpgradePanel:_DisposeListener()
	MessageManager.RemoveListener(RealmNotes, RealmNotes.EVENT_REALMUPGRADE, RealmUpgradePanel._OnRealmUpgrade, self);
	MessageManager.RemoveListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, RealmUpgradePanel.OnProductsChange, self);
	UIUtil.GetComponent(self._btnUpgrade, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onUpgradeButtonClick = nil;	
	UIUtil.GetComponent(self._btnHelp, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onHelpButtonClick = nil
	UIUtil.GetComponent(self._helpPanelMask, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onHelpMaskButtonClick = nil
end

function RealmUpgradePanel:_DisposeReference()
	if(self._baseIconItem) then
		self._baseIconItem:Dispose()
		self._baseIconItem = nil
	end
	
	if(self._uiHeroAnimationModel) then
		self._uiHeroAnimationModel:Dispose()
		self._uiHeroAnimationModel = nil
	end
	
	-- if(self._timer) then
	-- 	self._timer:Stop();
	-- 	self._timer = nil;
	-- end
	if(self._upgradeEff) then
		Resourcer.Recycle(self._upgradeEff, false);
		self._upgradeEff = nil;
	end
	
	if(self._lvItems ~= nil) then
		for i, v in pairs(self._lvItems) do
			v:Dispose()			
		end
	end
	
	if(self._uiEffect) then
		self._uiEffect:Dispose()
		self._uiEffect = nil
	end
	self._imgRole = nil;
	self._effect = nil; 
	self._lvItems = nil; 
	self._roleParent = nil;
	self._imgTitle = nil;
	self._imgTitleLV = nil; 
	self._btnUpgrade = nil; 
	self._helpPanel = nil;
	self._helpPanelMask = nil;
	self._btnHelp = nil;
	self._txtFight = nil;
	self._txtNeedFight = nil;
	self._txtNeedRes = nil;
end

-- function RealmUpgradePanel:_OnTickHandler()
-- 	if(self._trsLevels and self._smallRealmLevel) then
-- 		local tran = self._trsLevels.transform;
-- 		self._formAngle = self:lerp(self._formAngle, self._toAngle, Timer.deltaTime * 4)
-- 		tran.localRotation = Quaternion.Euler(0, self._formAngle % 360, 0);
-- 		if(table.getCount(self._lvItems) > 0) then
-- 			for i, v in pairs(self._lvItems) do
-- 				v:Update(self._trsLevels.transform.localRotation.eulerAngles.y, self._enable);
-- 			end
-- 		end
-- 	end
-- end
-- function RealmUpgradePanel:lerp(a, b, t)
-- 	return a +(b - a) * math.clamp(t, 0, 1);
-- end
function RealmUpgradePanel:_OnEnable()
	local rLevel = RealmManager.GetRealmLevel();
	self:OnProductsChange()
	-- if(table.getCount(self._lvItems) > 0) then
	-- 	for i, v in pairs(self._lvItems) do
	-- 		if(i <= self._smallRealmLevel and rLevel > 0) then
	-- 			v:SetEnabled(true)
	-- 		else
	-- 			v:SetEnabled(false)
	-- 		end
	-- 		v:Refresh();
	-- 	end
	-- end 
	-- self._transform.gameObject:SetActive(true)
	if(self._uiHeroAnimationModel) then self._uiHeroAnimationModel:Play() end
end
local Get = LanguageMgr.Get
function RealmUpgradePanel:_FormatAttrsText()
	local attrs = RealmManager.GetUpgradeAttrs()
	local nextattrs = RealmManager.GetNextUpgradeAttrs()
	
	local p = attrs:GetAllPropertyAndDes()
	self._curPropertyPhalanx:Build(#p, 1, p)
	
	if(nextattrs) then
		nextattrs:Sub(attrs)
		local p = nextattrs:GetAllPropertyAndDes()
		self._nextPropertyPhalanx:Build(#p, 1, p)
	else
		self._nextPropertyPhalanx:Build(0, 0, {})	
	end
end

local none = Get("realm/none")
local green = ColorDataManager.Get_green()
local red = ColorDataManager.Get_red()

function RealmUpgradePanel:OnProductsChange()
	local nInfo = self._nextInfo
	local showTips = false
	if(nInfo) then
		if(nInfo.req_item[1] ~= nil and nInfo.req_item[1] ~= "") then
			local tmp = string.split(nInfo.req_item[1], "_");
			local id = tonumber(tmp[1]);
			local total = tonumber(tmp[2]);
			local item = ProductManager.GetProductById(id)
			if(item) then
				self._txtNeedRes.text = ""
				local num = BackpackDataManager.GetProductTotalNumBySpid(id);
				self._txtNum.text = num .. "/" .. total
				self._txtNum.color = num >= total and green or red
				if(num < total) then			
					showTips = false				
				else				
					showTips = PlayerManager.power >= nInfo.req_fighting
				end
				self._baseIconItem:SetActive(true)
				self._baseIconItem:UpdateItem(item)
			else
				self._txtNeedRes.text = none
				self._txtNum.text = ""
				self._baseIconItem:SetActive(false)				
			end
		else
			self._txtNeedRes.text = none
			self._txtNum.text = ""
			self._baseIconItem:SetActive(false)
			showTips = PlayerManager.power >= nInfo.req_fighting
		end
	else
		self._txtNeedRes.text = none
		self._txtNum.text = ""
		self._baseIconItem:SetActive(false)
		showTips = false	
	end
	MessageManager.Dispatch(RealmNotes, RealmNotes.EVENT_UPGRADETIP_CHANGE, showTips);
	self._txtFight.text = PlayerManager.GetSelfFightPower();
end

function RealmUpgradePanel:_RefreshBg()
	-- if(self._imgBg) then
	-- 	local bLV = math.ceil(RealmManager.GetRealmLevel() / 9);
	-- 	if(bLV > 0) then
	-- 		self._imgBg.mainTexture = UIUtil.GetTexture("realm/ubg/" .. bLV);
	-- 	else
	-- 		self._imgBg.mainTexture = UIUtil.GetTexture("realm/ubg/1");
	-- 	end
	-- end
end

function RealmUpgradePanel:_RefreshLevels(level)
	if(self._realmLevel ~= level) then		
		for i, v in pairs(self._lvItems) do
			v:UpdateItem(level)		
		end
	
		self._realmLevel = level;
	end
end

function RealmUpgradePanel:_RefreshUI()
	local rLevel = RealmManager.GetRealmLevel();
	local heroInfo = PlayerManager.hero.info;
	local currInfo = RealmManager.GetUpgradeInfoByLevel();
	local nextInfo = RealmManager.GetUpgradeInfoByLevel(rLevel + 1);
	if(currInfo == nil) then
		currInfo = nextInfo;
	end
	if(currInfo) then
		local bLV = math.ceil(currInfo.realm_lev / 9);
		local canReq = heroInfo.level >= currInfo.req_lev;	
		self._imgTitle.spriteName = "lv" .. bLV;
		if(rLevel == 0) then
			self._imgTitleLV.spriteName = "";
		else
			local slv = rLevel % 9;
			if(slv == 0 or slv == 9) then
				self._imgTitleLV.spriteName = "9";
			else
				self._imgTitleLV.spriteName = tostring(slv);
			end
		end
		
		self:_FormatAttrsText();
		
		if(nextInfo) then
			
			SetUIEnable(self._trsCantUpdate, false)
			SetUIEnable(self._trsCanUpdate, true)
			if(nextInfo.req_fighting > PlayerManager.power) then
				self._txtNeedFight.text = ColorDataManager.GetColorTextByQuality(6, Get("realm/needFight", {n = nextInfo.req_fighting}));
			else
				self._txtNeedFight.text = ColorDataManager.GetColorTextByQuality(1, Get("realm/needFight", {n = nextInfo.req_fighting}));
			end
			
			local slv = nextInfo.realm_lev % 9;
			if((slv == 1 and rLevel > 1) or slv == 4 or slv == 7) then
				self._txtUpgradeLabel.text = Get("realm/breakthrough")
			else
				self._txtUpgradeLabel.text = Get("realm/upgrade")
			end
		else
			 
			SetUIEnable(self._trsCantUpdate, true)
			SetUIEnable(self._trsCanUpdate, false)
			
			self._txtNeedFight.text = ""
		end
	end
	self._txtFight.text = PlayerManager.GetSelfFightPower();
	self._nextInfo = nextInfo;
	self:_RefreshLevels(rLevel)
	self:OnProductsChange();
end

function RealmUpgradePanel:_RefreshRes()
	
end


function RealmUpgradePanel:_OnUpgradeButtonClick()
	local nInfo = self._nextInfo;
	
	if(nInfo) then
		if(nInfo.req_item[1] ~= nil and nInfo.req_item[1] ~= "") then
			local tmp = string.split(nInfo.req_item[1], "_");
			local id = tonumber(tmp[1]);
			local total = tonumber(tmp[2]);
			if(BackpackDataManager.GetProductTotalNumBySpid(id) < total) then			
				ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL, {id = id, msg = RealmNotes.CLOSE_REALM})		
				return;
			end
		end
		if(PlayerManager.power < self._nextInfo.req_fighting) then
			MsgUtils.ShowTips(nil, nil, nil, Get("realm/fighting"));
			return;
		end
		RealmProxy.Upgrade()
		-- if(RealmProxy.Upgrade()) then
		-- 	self._btnUpgrade.isEnabled = false			
		-- end		
	end
	SequenceManager.TriggerEvent(SequenceEventType.Guide.REALM_UPGRADE);
end

function RealmUpgradePanel:_OnHelpButtonClick()
	self._helpPanel.gameObject:SetActive(true);
end

function RealmUpgradePanel:_OnHelpMaskButtonClick()
	self._helpPanel.gameObject:SetActive(false);
end

function RealmUpgradePanel:_PlayerUpgradeEffect(level)
	if(self._lvItems and level) then
		-- local sLV = level % 9;
		-- if(sLV == 0) then
		-- 	sLV = 9;
		-- end
		-- if((sLV == 1 and level > 1) or sLV == 4 or sLV == 7) then
		-- 	self._uiEffect:Play();
		-- end
		-- local item = self._lvItems[sLV];
		-- if(item ~= nil) then
		-- 	if(self._upgradeEff == nil) then
		-- 		self._upgradeEff = Resourcer.Get("Effect/UIEffect", "UI_jingjie_levUp", item._transform);
		-- 		NGUITools.SetChildLayer(self._upgradeEff.transform, Layer.UIModel)
		-- 	else
		-- 		self._upgradeEff.transform:SetParent(item._transform);
		-- 	end
		-- 	Util.SetLocalPos(self._upgradeEff, 0, 0, 0)
		-- 	--        self._upgradeEff.transform.localPosition = Vector3.zero;
		-- 	self._upgradeEff:SetActive(true);
		-- 	UIUtil.StopParticleSystem(self._upgradeEff)
		-- 	UIUtil.PlayParticleSystem(self._upgradeEff)
		-- end
	end
end

function RealmUpgradePanel:_OnRealmUpgrade(data)
	-- self._btnUpgrade.isEnabled = true;
	if data and data.errCode == nil then
		self:_RefreshUI();
		-- self:_PlayerUpgradeEffect(data.rlv);	
	end
end

