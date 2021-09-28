require "Core.Module.Common.UIComponent"
require "Core.Module.Common.UIHeroAnimationModel"

MyRoleProperyPanel = class("MyRoleProperyPanel", UIComponent)

function MyRoleProperyPanel:New()
	self = {};
	setmetatable(self, {__index = MyRoleProperyPanel});
	return self;
end

function MyRoleProperyPanel:_Init()
	self._noneDes = LanguageMgr.Get("role/myRolePropertyPanel/none")
	self._roleParent = UIUtil.GetChildByName(self._transform, "imgRole/heroCamera/trsRoleParent");
	self._curPropertyPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "propertyPhalanx")
	self._curPropertyPhalanx = Phalanx:New()
	self._curPropertyPhalanx:Init(self._curPropertyPhalanxInfo, BasePropertyItem)
	self._curAttr = BaseAttrInfo:New()
	
	self._careerConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CAREER)
	local txts = UIUtil.GetComponentsInChildren(self._transform, "UILabel");
	self._txtPower = UIUtil.GetChildInComponents(txts, "txtPower");
	-- self._txtPhydefend = UIUtil.GetChildInComponents(txts, "txtPhydefend");
	-- self._txtMagdefend = UIUtil.GetChildInComponents(txts, "txtMagdefend");
	-- self._txtTenacity = UIUtil.GetChildInComponents(txts, "txtTenacity");
	-- self._txtDodge = UIUtil.GetChildInComponents(txts, "txtDodge");
	-- self._txtParry = UIUtil.GetChildInComponents(txts, "txtParry");
	-- self._txtKillrate = UIUtil.GetChildInComponents(txts, "txtKillrate");
	-- self._txtHitrate = UIUtil.GetChildInComponents(txts, "txtHitrate");
	-- self._txtCrit = UIUtil.GetChildInComponents(txts, "txtCrit");
	-- self._txtMagattack = UIUtil.GetChildInComponents(txts, "txtMagattack");
	-- self._txtPhyattack = UIUtil.GetChildInComponents(txts, "txtPhyattack");
	self._txtId = UIUtil.GetChildInComponents(txts, "txtId");
	self._txtMenpai = UIUtil.GetChildInComponents(txts, "txtMenpai");
	self._txtHp = UIUtil.GetChildInComponents(txts, "txtHp");
	self._txtMp = UIUtil.GetChildInComponents(txts, "txtMp");
	self._txtExp = UIUtil.GetChildInComponents(txts, "txtExp");
	self._txtVip = UIUtil.GetChildInComponents(txts, "txtVip");
	self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
	self._txtLv = UIUtil.GetChildInComponents(txts, "txtLv");
	self._txtBanghui = UIUtil.GetChildInComponents(txts, "txtBanghui");
	self._txtChenghao = UIUtil.GetChildInComponents(txts, "txtChenghao");
	self._goDetail = UIUtil.GetChildByName(self._transform, "btnDetail")
	local sliders = UIUtil.GetComponentsInChildren(self._transform, "UISlider");
	self._sliderHp = UIUtil.GetChildInComponents(sliders, "slider_hp");
	self._sliderMp = UIUtil.GetChildInComponents(sliders, "slider_mp");
	self._sliderExp = UIUtil.GetChildInComponents(sliders, "slider_exp");
	self._btnVip = UIUtil.GetChildByName(self._transform, "UISprite", "btnVip");
	UIUtil.GetComponent(self._btnVip, "LuaUIEventListener"):RegisterDelegate("OnClick", self._OnClickBtnVip);
	
	self._btnExpAdd = UIUtil.GetChildByName(self._transform, "UISprite", "btnExpAdd");
	self._trsExpAdd = UIUtil.GetChildByName(self._transform, "Transform", "trsExpAdd").gameObject;
	self._txtExpAdd = UIUtil.GetChildByName(self._trsExpAdd, "UILabel", "txtExpAdd");
	self._onClickBtnExpAdd = function() self:_OnClickBtnExpAdd() end
	UIUtil.GetComponent(self._btnExpAdd, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnExpAdd);
	self._onClickBtnBgExpAdd = function() self:_OnClickBtnBgExpAdd() end
	UIUtil.GetComponent(self._trsExpAdd, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnBgExpAdd);
	self._btnExpAdd.gameObject:SetActive(PlayerManager.CanExpAdd())
	
	self:InitEquips(self._transform);
	MessageManager.AddListener(EquipDataManager, EquipDataManager.MESSAGE_EQUIP_BAG_PRODUCTS_CHANGE, MyRoleProperyPanel.UpdatePanel, self);
	MessageManager.AddListener(PlayerManager, PlayerManager.SelfLevelChange, MyRoleProperyPanel.UpdatePanel, self)
	MessageManager.AddListener(PlayerManager, PlayerManager.SelfHpChange, MyRoleProperyPanel.UpdateMyHpSlider, self)
	MessageManager.AddListener(PlayerManager, PlayerManager.SelfMpChange, MyRoleProperyPanel.UpdateMyMpSlider, self)
	MessageManager.AddListener(EquipDataManager, EquipDataManager.MESSAGE_EXTEQUIP_CHANGE, MyRoleProperyPanel.UpExtEquip, self);
	
	
	local data = RoleModelCreater.CloneDress(PlayerManager.GetPlayerInfo(), true, true, false)	
	self._uiHeroAnimationModel = UIHeroAnimationModel:New(data, self._roleParent)
	self._onClickBtnDetail = function(go) self:_OnClickBtnDetail(self) end
	UIUtil.GetComponent(self._goDetail, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnDetail);
	
	self:UpExtEquip();
	
end

function MyRoleProperyPanel:_OnClickBtnExpAdd()
	local add, wl, pl, gl = PlayerManager.GetExpAdd()
	local s
	--Warning(tostring(add) .. "_" ..tostring(wl).. "_" ..tostring(pl).. "_" ..tostring(gl))
	if add and add > 0 then s = LanguageMgr.Get("MyRoleProperyPanel/expaddDes2", {n = wl, g = gl, a = add})
	else s = LanguageMgr.Get("MyRoleProperyPanel/expaddDes", {n = wl}) end
	self._txtExpAdd.text = s
	self._trsExpAdd:SetActive(true)
end
function MyRoleProperyPanel:_OnClickBtnBgExpAdd()
	self._trsExpAdd:SetActive(false)
end

function MyRoleProperyPanel:_OnClickBtnVip()
	ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, {val = 4})
end
function MyRoleProperyPanel:_OnClickBtnDetail()
	PlayerManager.CalculatePlayerAttribute()
	ModuleManager.SendNotification(MainUINotes.OPEN_ROLEATTRPANEL)
end

function MyRoleProperyPanel:UpdatePanel()
	if(self.attrData == nil) then
		self.attrData = HeroController.GetInstance():GetInfo()	
		self._curAttr:Init(self.attrData)
	end
	
	if(self.data == nil) then
		self.data = PlayerManager.GetPlayerInfo()
	end
	
	
	local carrer = self._careerConfig[self.data.kind]
	self._txtMenpai.text = carrer.career
	self._txtId.text = self.data.id
	self._txtPower.text = tostring(PlayerManager.GetSelfFightPower())
	--    local carrerAttr = PlayerManager.GetPlayerInfo()
	-- self._txtPhydefend.text = tostring(self.attrData.phy_def)
	-- self._txtTenacity.text = tostring(self.attrData.tough)
	-- self._txtDodge.text = tostring(self.attrData.eva)
	-- self._txtParry.text = tostring(self.attrData.block)
	-- self._txtKillrate.text = tostring(self.attrData.fatal)
	-- self._txtHitrate.text = tostring(self.attrData.hit)
	-- self._txtCrit.text = tostring(self.attrData.crit)
	-- -- self._txtMagattack.text = tostring(self.attrData.mag_att)
	-- self._txtPhyattack.text = tostring(self.attrData.phy_att)
	local p = self._curAttr:GetAllPropertyAndDes()
	self._curPropertyPhalanx:Build(5, 2, p)
	self._txtVip.text = VIPManager.GetVIPShowLevel()
	-- tostring(self.data.vip)
	self._txtName.text = tostring(self.data.name)
	self._txtBanghui.text = GuildDataManager.data and GuildDataManager.data.name or self._noneDes
	self._txtChenghao.text = TitleManager.GetCurrentEquipTitleData() and TitleManager.GetCurrentEquipTitleData().name or self._noneDes
	self._txtLv.text = GetLvDes(self.data.level)
	local maxExp = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CAREER_EXP) [self.data.level].exp
	self._txtExp.text = string.format("%s/%s", self.data.exp, maxExp)
	self._sliderExp.value = self.data.exp / maxExp
	self.maxHp = self.attrData.hp_max
	self.maxMp = self.attrData.mp_max
	self:UpdateMyHpSlider()
	self:UpdateMyMpSlider()
	self:_SetEquipsData()
	self._btnExpAdd.gameObject:SetActive(PlayerManager.CanExpAdd())
end

function MyRoleProperyPanel:UpdateMyHpSlider()
	self.attrData = HeroController.GetInstance():GetInfo()
	self._sliderHp.value = self.attrData.hp / self.attrData.hp_max
	self._txtHp.text = self.attrData.hp .. "/" .. self.attrData.hp_max
end

function MyRoleProperyPanel:UpdateMyMpSlider()
	self.attrData = HeroController.GetInstance():GetInfo()
	self._sliderMp.value = self.attrData.mp / self.attrData.mp_max
	self._txtMp.text = self.attrData.mp .. "/" .. self.attrData.mp_max
end

function MyRoleProperyPanel:_Dispose()
	for i = 1, 8 do
		self._equipCtrls[i]:Dispose()
	end
	for i = 1, 2 do
		
		self._extEquipCtrls[i]:Dispose();
	end
	if(self._curPropertyPhalanx) then
		self._curPropertyPhalanx:Dispose()
		self._curPropertyPhalanx = nil
	end
	MessageManager.RemoveListener(EquipDataManager, EquipDataManager.MESSAGE_EQUIP_BAG_PRODUCTS_CHANGE, MyRoleProperyPanel.UpdatePanel);
	MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfLevelChange, MyRoleProperyPanel.UpdatePanel)
	MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfHpChange, MyRoleProperyPanel.UpdateMyHpSlider)
	MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfMpChange, MyRoleProperyPanel.UpdateMyMpSlider)
	
	MessageManager.RemoveListener(EquipDataManager, EquipDataManager.MESSAGE_EXTEQUIP_CHANGE, MyRoleProperyPanel.UpExtEquip);
	
	
	UIUtil.GetComponent(self._goDetail, "LuaUIEventListener"):RemoveDelegate("OnClick");
	UIUtil.GetComponent(self._btnExpAdd, "LuaUIEventListener"):RemoveDelegate("OnClick")
	self._onClickBtnExpAdd = nil
	UIUtil.GetComponent(self._trsExpAdd, "LuaUIEventListener"):RemoveDelegate("OnClick")
	self._onClickBtnBgExpAdd = nil
	
	self._onClickBtnDetail = nil;
	if(self._uiHeroAnimationModel) then
		self._uiHeroAnimationModel:Dispose()
		self._uiHeroAnimationModel = nil
	end
end

function MyRoleProperyPanel:_SetEquipsData()
	for i = 1, 8 do
		local pinfo = EquipDataManager.GetProductByKind(i);
		self._equipCtrls[i]:SetData(pinfo);
	end
end

function MyRoleProperyPanel:UpExtEquip()
	
	local extEqinfo1 = EquipDataManager.GetExtEquip(EquipDataManager.ExtEquipIdx.Idx1);
	local extEqinfo2 = EquipDataManager.GetExtEquip(EquipDataManager.ExtEquipIdx.Idx2);
	
	self._extEquipCtrls[1]:SetData(extEqinfo1);
	self._extEquipCtrls[2]:SetData(extEqinfo2);
	
end

function MyRoleProperyPanel:InitEquips(parent)
	self._equipPanel = UIUtil.GetChildByName(parent, "equipPanel");
	self._equipCtrls = {};
	local style = {hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_circle}
	for i = 1, 8 do
		local eq_gameObject = UIUtil.GetChildByName(self._equipPanel, "eq_" .. i).gameObject;
		
		self._equipCtrls[i] = ProductCtrl:New();
		self._equipCtrls[i]:Init(eq_gameObject, style);
		self._equipCtrls[i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_EQUIPS);
	end
	
	self._extEquipCtrls = {};
	for i = 1, 2 do
		local exteq_gameObject = UIUtil.GetChildByName(self._equipPanel, "extEq_" .. i).gameObject;
		
		self._extEquipCtrls[i] = ProductCtrl:New();
		self._extEquipCtrls[i]:Init(exteq_gameObject, style);
		self._extEquipCtrls[i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_EQUIPS);
	end
	
end

