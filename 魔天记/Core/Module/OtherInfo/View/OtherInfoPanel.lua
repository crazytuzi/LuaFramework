require "Core.Module.Common.Panel";
require "Core.Module.Common.PropsItem";

OtherInfoPanel = Panel:New();

function OtherInfoPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function OtherInfoPanel:_InitReference()
	self._trsRole = UIUtil.GetChildByName(self._trsContent, "Transform", "trsRole");
	self._trsInfo = UIUtil.GetChildByName(self._trsContent, "Transform", "trsInfo");
	
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
	-- self._btnSkill = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnSkill");
	-- self._btnPet = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnPet");
	self._btnFight = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnFight");
	
	self._txtName = UIUtil.GetChildByName(self._trsRole, "UILabel", "txtName");
	self._txtLv = UIUtil.GetChildByName(self._trsRole, "UILabel", "txtLv");
	self._txtFight = UIUtil.GetChildByName(self._trsRole, "UILabel", "txtFight");
	self._txtVip = UIUtil.GetChildByName(self._trsRole, "UILabel", "icoVip/txtVip");
	
	self._trsRoleParent = UIUtil.GetChildByName(self._trsRole, "Transform", "imgRole/heroCamera/trsRoleParent");
	self._trsEquip = UIUtil.GetChildByName(self._trsRole, "Transform", "trsEquip");
	self._equipParents = {};
	self._equips = {};
	self._equipGos = {};
	for i = 1, 10 do
		local parent = UIUtil.GetChildByName(self._trsEquip, "Transform", "eq_" .. i);
		local item = PropsItem:New();
		local itemGo = UIUtil.GetUIGameObject(ResID.UI_PropsItem);
		UIUtil.AddChild(parent, itemGo.transform);
		item:Init(itemGo, nil);
		self._equipParents[i] = parent;
		self._equips[i] = item;
		self._equipGos[i] = itemGo;
	end
	
	self._icoHp = UIUtil.GetChildByName(self._trsInfo, "UISlider", "trsHp/icoHp");
	self._icoMp = UIUtil.GetChildByName(self._trsInfo, "UISlider", "trsMp/icoMp");
	
	self._txtId = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleId/txtId");
	self._txtGuild = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleGuild/txtGuild");
	self._txtRealm = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleRealm/txtRealm");
	self._txtNick = UIUtil.GetChildByName(self._trsInfo, "UILabel", "titleNick/txtNick");
	
	self._txtHp = UIUtil.GetChildByName(self._trsInfo, "UILabel", "trsHp/txtHp");
	self._txtMp = UIUtil.GetChildByName(self._trsInfo, "UILabel", "trsMp/txtMp");
	
	self._curPropertyPhalanxInfo = UIUtil.GetChildByName(self._trsInfo, "LuaAsynPhalanx", "propertyPhalanx")
	self._curPropertyPhalanx = Phalanx:New()
	self._curPropertyPhalanx:Init(self._curPropertyPhalanxInfo, BasePropertyItem)
	self._curAttr = BaseAttrInfo:New()
	
	
	-- self._txt_phy_att = UIUtil.GetChildByName(self._trsInfo, "UILabel", "title_phy_att/txt_phy_att");
	-- self._txt_phy_def = UIUtil.GetChildByName(self._trsInfo, "UILabel", "title_phy_def/txt_phy_def");
	-- -- self._txt_mag_att = UIUtil.GetChildByName(self._trsInfo, "UILabel", "title_mag_att/txt_mag_att");
	-- -- self._txt_mag_def = UIUtil.GetChildByName(self._trsInfo, "UILabel", "title_mag_def/txt_mag_def");
	-- self._txt_crit = UIUtil.GetChildByName(self._trsInfo, "UILabel", "title_crit/txt_crit");
	-- self._txt_hit = UIUtil.GetChildByName(self._trsInfo, "UILabel", "title_hit/txt_hit");
	-- self._txt_fatal = UIUtil.GetChildByName(self._trsInfo, "UILabel", "title_fatal/txt_fatal");
	-- self._txt_tough = UIUtil.GetChildByName(self._trsInfo, "UILabel", "title_tough/txt_tough");
	-- self._txt_eva = UIUtil.GetChildByName(self._trsInfo, "UILabel", "title_eva/txt_eva");
	-- self._txt_block = UIUtil.GetChildByName(self._trsInfo, "UILabel", "title_block/txt_block");
end

function OtherInfoPanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	
	-- self._onClickBtnSkill = function(go) self:_OnClickBtnSkill(self) end
	-- UIUtil.GetComponent(self._btnSkill, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSkill);
	--[[    self._onClickBtnPet = function(go) self:_OnClickBtnPet(self) end
    UIUtil.GetComponent(self._btnPet, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnPet);
    ]]
	self._onClickBtnFight = function(go) self:_OnClickBtnFight(self) end
	UIUtil.GetComponent(self._btnFight, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFight);
	
	self._onClickEquip = function(go) self:_OnClickEquip(go) end;
	for i, v in ipairs(self._equipParents) do
		UIUtil.GetComponent(v, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickEquip);
	end
	
end

function OtherInfoPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	if(self._curPropertyPhalanx) then
		self._curPropertyPhalanx:Dispose()
		self._curPropertyPhalanx = nil
	end
end

function OtherInfoPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
	
	-- UIUtil.GetComponent(self._btnSkill, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickBtnSkill = nil;
	-- UIUtil.GetComponent(self._btnPet, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickBtnPet = nil;
	UIUtil.GetComponent(self._btnFight, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnFight = nil;
	
	
	for i, v in ipairs(self._equipParents) do
		UIUtil.GetComponent(v, "LuaUIEventListener"):RemoveDelegate("OnClick");
	end
	self._onClickEquip = nil;
	
	for i, v in ipairs(self._equips) do
		v:Dispose();
		Resourcer.Recycle(self._equipGos[i], true);
	end
end

function OtherInfoPanel:_DisposeReference()
	if self._uiAnimationModel then
		self._uiAnimationModel:Dispose();
	end
	
	NGUITools.DestroyChildren(self._trsRoleParent);
end

function OtherInfoPanel:Update(d)
	self.data = d;
	self:UpdateDisplay();
end

function OtherInfoPanel:UpdateDisplay()
	local d = self.data;
	
	self._txtName.text = d.name;
	self._txtLv.text = GetLvDes(d.level);
	self._txtFight.text = d.fight;
	self._txtVip.text = VIPManager.GetVIPShowLevel(d.vip)
	
	self._txtId.text = d.id;
	self._txtGuild.text = d.tgn or LanguageMgr.Get("common/nil");
	if d.realm.rlv > 0 then
		local realmCfg = RealmManager.GetUpgradeInfoByLevel(d.realm.rlv, d.kind);
		local realmComCfg = RealmManager.GetCompactInfoByLevel(d.realm.clv);
		local realmStr = realmCfg.realm_name;
		if realmComCfg then
			realmStr = LanguageMgr.GetColor(realmComCfg.realm_quality, realmStr);
		end
		self._txtRealm.text = realmStr;
	else
		self._txtRealm.text = LanguageMgr.Get("realm/0");
	end
	
	local titleCfg = TitleManager.GetTitleConfigById(d.title);
	self._txtNick.text = titleCfg and titleCfg.name or LanguageMgr.Get("common/nil");
	
	self._txtHp.text = d.attr.hp .. "/" .. d.attr.hp_max;
	self._txtMp.text = d.attr.mp .. "/" .. d.attr.mp_max;
	
	self._icoHp.value = d.attr.hp / d.attr.hp_max;
	self._icoMp.value = d.attr.mp / d.attr.mp_max;
	
	self._curAttr:Init(d.attr)
	local p = self._curAttr:GetAllPropertyAndDes()
	self._curPropertyPhalanx:Build(5, 2,p)
	-- self._txt_phy_att.text = d.attr.phy_att;
	-- self._txt_phy_def.text = d.attr.phy_def; 
	-- self._txt_crit.text = d.attr.crit;
	-- self._txt_hit.text = d.attr.hit;
	-- self._txt_fatal.text = d.attr.fatal;
	-- self._txt_tough.text = d.attr.tough;
	-- self._txt_eva.text = d.attr.eva;
	-- self._txt_block.text = d.attr.block;
	local equipData = {};
	for i = 1, 10 do
		equipData[i] = nil;
	end
	
	for i, v in ipairs(d.equip) do
		equipData[v.idx + 1] = v.spId;
	end
	
	for i, v in ipairs(d.ext_equip) do
		equipData[v.idx + 9] = v.spId;
	end
	
	for i, v in ipairs(self._equips) do
		local info = nil;
		if equipData[i] then
			info = ProductInfo:New();
			info:Init({spId = equipData[i], am = 1});
		end
		v:UpdateItem(info);
	end
	
	local roleData = {};
	roleData.kind = d.kind;
	roleData.dress = d.dress;
	roleData.dress.h = nil;
	roleData.dress.ap = nil;
	roleData.dress.bp = nil;
	
	if(self._uiAnimationModel == nil) then
		self._uiAnimationModel = UIAnimationModel:New(roleData, self._trsRoleParent, UIRoleModelCreater);
	else
		self._uiAnimationModel:ChangeModel(roleData, self._trsRoleParent);
	end
	
	
end

function OtherInfoPanel:_OnClickBtnClose()
	ModuleManager.SendNotification(OtherInfoNotes.CLOSE_INFO_PANEL);
end

-- function OtherInfoPanel:_OnClickBtnSkill()
-- 	-- self:_OnClickBtnClose();
-- 	ModuleManager.SendNotification(OtherInfoNotes.OPEN_SKILL_PANEL, self.data.id);
-- end	

function OtherInfoPanel:_OnClickBtnPet()
	if self.data.pet_id then
		-- self:_OnClickBtnClose();
		ModuleManager.SendNotification(OtherInfoNotes.OPEN_PET_PANEL, {id = self.data.id, pid = self.data.pet_id});
	else
		MsgUtils.ShowTips("other/info/notpet");
	end
end

function OtherInfoPanel:_OnClickBtnFight()
	ModuleManager.SendNotification(OtherInfoNotes.OPEN_FIGHT_PANEL, self.data.id);
end

function OtherInfoPanel:_OnClickEquip(go)
	local idx = tonumber(string.sub(go.name, 4)) - 1;
	local equip = nil;
	
	for i, v in ipairs(self.data.equip) do
		if v.idx == idx then
			equip = ProductInfo:New();
			equip:Init(v);
			break;
		end
	end
	
	for i, v in ipairs(self.data.ext_equip) do
		if v.idx + 8 == idx then
			equip = ProductInfo:New();
			equip:Init(v);
			break;
		end
	end
	
	local info = nil;
	if equip ~= nil then
		for i, v in ipairs(self.data.equip_lv) do
			if v.idx == idx then
				info = v;
				break;
			end
		end
		
		if idx < 8 or info ~= nil then
			--把VIP信息传过去
			info.vip = self.data.vip;
			ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, {info = equip, type = ProductCtrl.TYPE_FROM_OTHER_PLAYER, exData = info});
		elseif idx >= 8 then
			ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, {info = equip, type = ProductCtrl.TYPE_FROM_OTHER_PLAYER, exData = info});
        end


	end
end
