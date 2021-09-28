require "Core.Module.Common.Panel";
require "Core.Module.Common.Phalanx";
require "Core.Module.Common.BasePropertyItem"

OtherPetPanel = Panel:New();

function OtherPetPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function OtherPetPanel:_InitReference()
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
	self._trsPet = UIUtil.GetChildByName(self._trsContent, "Transform", "trsPet");
	self._trsInfo = UIUtil.GetChildByName(self._trsContent, "Transform", "trsInfo");
	
	self._trsRoleParent = UIUtil.GetChildByName(self._trsPet, "Transform", "imgPet/heroCamera/trsRoleParent");
	self._txtName = UIUtil.GetChildByName(self._trsPet, "UILabel", "txtName");
	self._txtLv = UIUtil.GetChildByName(self._trsPet, "UILabel", "txtLv");
	self._txtFight = UIUtil.GetChildByName(self._trsPet, "UILabel", "txtFight");
	self._icoRank = UIUtil.GetChildByName(self._trsPet, "UISprite", "icoRank");
	-- self._txtRank = UIUtil.GetChildByName(self._trsPet, "UILabel", "txtRank");
	self._rankConst = {"lianqi", "ningye", "huajing", "zhendan", "tianxiang", "tongxuan", "yongsheng"};
	
	self._trsSkills = UIUtil.GetChildByName(self._trsPet, "Transform", "trsSkills");
	self._skills = {};
	self._skillIcons = {};
	self._skillLocks = {};
	for i = 1, 5 do
		local item = UIUtil.GetChildByName(self._trsSkills, "Transform", "skill" .. i);
		local ico = UIUtil.GetChildByName(item, "UISprite", "icon");
		local lock = UIUtil.GetChildByName(item, "Transform", "ico_lock");
		self._skills[i] = item;
		self._skillIcons[i] = ico;
		self._skillLocks[i] = lock;
	end
	
	self._title_att = UIUtil.GetChildByName(self._trsInfo, "UILabel", "title_att");
	self._txt_att = UIUtil.GetChildByName(self._title_att, "UILabel", "txt_att");
	self._txt_crit = UIUtil.GetChildByName(self._trsInfo, "UILabel", "title_crit/txt_crit");
	self._txt_hit = UIUtil.GetChildByName(self._trsInfo, "UILabel", "title_hit/txt_hit");
	self._txt_fatal = UIUtil.GetChildByName(self._trsInfo, "UILabel", "title_fatal/txt_fatal");
	
	self._btnOtherPet = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnOtherPet");
	
	--self._trsZF = UIUtil.GetChildByName(self._trsInfo, "Transform", "trsZF");
	self._zfAttrInfo = UIUtil.GetChildByName(self._trsInfo, "LuaAsynPhalanx", "trsZF");
	self._zfPhalanx = Phalanx:New();
	self._zfPhalanx:Init(self._zfAttrInfo, nil);
	
	--[[    self._zfAttrTitle = {};
    self._zfAttrTxt = {};
    for i = 1, 12 do
    	local title = UIUtil.GetChildByName(self._trsZF, "UILabel", "titleVal"..i);
    	local txt = UIUtil.GetChildByName(title, "UILabel", "txtVal"..i);
    	self._zfAttrTitle[i] = title;
    	self._zfAttrTxt[i] = txt;
    end
    ]]
	self._trsSkillInfo = UIUtil.GetChildByName(self._trsContent, "Transform", "trsSkillInfo");
	self._detailClose = UIUtil.GetChildByName(self._trsSkillInfo, "UIButton", "btnClose");
	self._dtTxtName = UIUtil.GetChildByName(self._trsSkillInfo, "UILabel", "txtName");
	self._dtIcoSkill = UIUtil.GetChildByName(self._trsSkillInfo, "UISprite", "icoSkill");
	self._dtIcoTalent = UIUtil.GetChildByName(self._trsSkillInfo, "UISprite", "icoTalent");
	self._dtTxtLevel = UIUtil.GetChildByName(self._trsSkillInfo, "UILabel", "titleLevel/txtLevel");
	self._dtTxtKind = UIUtil.GetChildByName(self._trsSkillInfo, "UILabel", "titleKind/txtKind");
	self._dtTxtCd = UIUtil.GetChildByName(self._trsSkillInfo, "UILabel", "titleCd/txtCd");
	self._dtTxtDis = UIUtil.GetChildByName(self._trsSkillInfo, "UILabel", "titleDis/txtDis");
	self._dtTxtDesc = UIUtil.GetChildByName(self._trsSkillInfo, "UILabel", "titleDesc/txtDesc");
	self._trsSkillInfo.gameObject:SetActive(false);
	
	self._trsOtherPet = UIUtil.GetChildByName(self._trsContent, "Transform", "trsOtherPet");
	self._otherPetClose = UIUtil.GetChildByName(self._trsOtherPet, "UIButton", "btnClose");
	self._trsPets = UIUtil.GetChildByName(self._trsOtherPet, "Transform", "trsPets");
	self.otherPetIcon = {};
	self.otherPetQuality = {};
	self.otherPetName = {};
	
	self.otherPetRealm = {};
	self._phalanxInfo = {}
	self._phalanx = {}
	for i = 1, 6 do
		local item = UIUtil.GetChildByName(self._trsPets, "Transform", "pet" .. i);
		self.otherPetIcon[i] = UIUtil.GetChildByName(item, "UISprite", "icon");
		self.otherPetQuality[i] = UIUtil.GetChildByName(item, "UISprite", "icon/quality");
		self.otherPetName[i] = UIUtil.GetChildByName(item, "UILabel", "txtName");
		-- self.otherPetLevel[i] = UIUtil.GetChildByName(item, "UILabel", "titleLevel/txtLevel");
		-- self.otherPetRealm[i] = UIUtil.GetChildByName(item, "UILabel", "titleRealm/txtRealm");
		self._phalanxInfo[i] = UIUtil.GetChildByName(item, "LuaAsynPhalanx", "phalanx")
		self._phalanx[i] = Phalanx:New()
		self._phalanx[i]:Init(self._phalanxInfo[i], BasePropertyItem)
	end
	self._trsOtherPet.gameObject:SetActive(false);
end

function OtherPetPanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	
	self._onClickDetailClose = function(go) self:_OnClickDetailClose(self) end
	UIUtil.GetComponent(self._detailClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickDetailClose);
	
	self._onClickOtherPetClose = function(go) self:_OnClickOtherPetClose(self) end
	UIUtil.GetComponent(self._otherPetClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickOtherPetClose);
	
	self._onClickOtherPet = function(go) self:_OnClickOtherPet(self) end
	UIUtil.GetComponent(self._btnOtherPet, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickOtherPet);
	
	self._onSkillClick = function(go) self:_OnSkillClick(go) end
	for i, v in ipairs(self._skills) do
		UIUtil.GetComponent(v, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onSkillClick);
	end
	
	MessageManager.AddListener(OtherInfoNotes, OtherInfoNotes.RSP_PET_TEAM_INFO, OtherPetPanel.OnTeamInfo, self);
end

function OtherPetPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	for i = 1, 6 do
		self._phalanx[i]:Dispose()
		self._phalanx[i] = nil
	end
	
end

function OtherPetPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
	
	UIUtil.GetComponent(self._detailClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickDetailClose = nil;
	
	UIUtil.GetComponent(self._otherPetClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickOtherPetClose = nil;
	
	UIUtil.GetComponent(self._btnOtherPet, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickOtherPet = nil;
	
	for i, v in ipairs(self._skills) do
		UIUtil.GetComponent(v, "LuaUIEventListener"):RemoveDelegate("OnClick");
	end
	self._onSkillClick = nil;
	
	MessageManager.RemoveListener(OtherInfoNotes, OtherInfoNotes.RSP_PET_TEAM_INFO, OtherPetPanel.OnTeamInfo);
end

function OtherPetPanel:_DisposeReference()
	if self._uiAnimationModel then
		self._uiAnimationModel:Dispose();
	end
	
	self._zfPhalanx:Dispose();
	
	NGUITools.DestroyChildren(self._trsRoleParent);
end

function OtherPetPanel:Update(d)
	self.data = d;
	self:UpdateDisplay();
end

function OtherPetPanel:UpdateDisplay()
	local d = self.data;
	local petCfg = PetManager.GetPetConfigById(d.pid);
	self._txtName.text = LanguageMgr.GetColor(petCfg.quality, d.name);
	self._txtLv.text = GetLvDes(d.level);
	self._txtFight.text = d.fighting;
	self._icoRank.spriteName = "rank" .. d.aptitude_lev;
	-- self._txtRank.text = LanguageMgr.Get("Pet/PetPanel/Rank" ..(d.rank % 3));
	local p = {kind = d.pid, rank = 1, level = 1, id = 1};
	local petData = PetInfo:New(p, true);
	
	if(self._uiAnimationModel == nil) then
		self._uiAnimationModel = UIAnimationModel:New(petData, self._trsRoleParent, PetModelCreater);
	else
		self._uiAnimationModel:ChangeModel(petData, self._trsRoleParent);
	end
	
	self.skillData = {nil, nil, nil, nil, nil};
	for i, v in ipairs(d.skill) do
		self.skillData[i] = {id = v.id, lv = v.level};
	end
	for i, v in ipairs(self._skillIcons) do
		if self.skillData[i] then
			local sklCfg = ConfigManager.GetSkillById(self.skillData[i].id, self.skillData[i].lv);
			self._skillIcons[i].spriteName = sklCfg.icon_id;
		else
			self._skillIcons[i].spriteName = "";
		end
		self._skillLocks[i].gameObject:SetActive(false);
	end
	
	self._title_att.text = LanguageMgr.Get("attr/desc/phy_att") .. " :";
	self._txt_att.text = d.attr.phy_att
	self._txt_crit.text = d.attr.crit;
	self._txt_hit.text = d.attr.hit;
	self._txt_fatal.text = d.attr.fatal;
	
	local idx = 1;
	local attrs = {};
	for k, v in pairs(d.form_attr) do
		if v > 0 then
			--self._zfAttrTitle[idx].text = LanguageMgr.Get("attr/desc/"..k) .. " :" ;
			--self._zfAttrTxt[idx].text = v;
			table.insert(attrs, LanguageMgr.Get("attr/desc/" .. k) .. " :" .. v);
		end
	end
	
	self._zfPhalanx:Build(math.ceil(#attrs / 2), 2, attrs);
	
	local items = self._zfPhalanx:GetItems();
	for i, v in ipairs(items) do
		local label = UIUtil.GetComponent(v.gameObject, "UILabel");
		label.text = attrs[i];
	end
	
end

function OtherPetPanel:_OnClickBtnClose()
	ModuleManager.SendNotification(OtherInfoNotes.CLOSE_PET_PANEL);
end

function OtherPetPanel:_OnClickDetailClose()
	self._trsSkillInfo.gameObject:SetActive(false);
end

function OtherPetPanel:_OnClickOtherPetClose()
	self._trsOtherPet.gameObject:SetActive(false);
end

function OtherPetPanel:_OnClickOtherPet()
	if self.data.form_count > 0 then
		if self.teamData == nil then
			OtherInfoProxy.ReqOtherTeamPet(self.data.id);
		else
			--self:UpdateOtherPet(self.teamData);
			self._trsOtherPet.gameObject:SetActive(true);
		end
	else
		MsgUtils.ShowTips("other/pet/notTeam");
	end
end

function OtherPetPanel:_OnSkillClick(go)
	local idx = tonumber(string.sub(go.name, - 1));
	local skl = self.skillData[idx];
	local d = {skill = skl.id, lv = skl.lv};
	self:ShowSkillInfo(d);
end

function OtherPetPanel:ShowSkillInfo(data)
	local cfg = ConfigManager.GetSkillById(data.skill, data.lv);
	if cfg == nil then
		log("can't find skill or talent cfg .. ");
		return;
	end
	self._trsSkillInfo.gameObject:SetActive(true);
	
	self._dtTxtName.text = cfg.name;
	self._dtIcoSkill.spriteName = cfg.icon_id;
	self._dtTxtLevel.text = data.lv .. "/" .. cfg.max_lv;
	local cId = string.sub(data.skill, 3, 3);
	self._dtTxtKind.text = LanguageMgr.Get("career/" .. cId);
	self._dtTxtCd.text = LanguageMgr.Get("skill/cd", {s = cfg.cd / 100});
	self._dtTxtDis.text = LanguageMgr.Get("skill/dis", {s = cfg.distance / 100});
	self._dtTxtDesc.text = LanguageMgr.GetColor("d", cfg.skill_desc);
end

function OtherPetPanel:OnTeamInfo(data)
	self.teamData = data;
	self:UpdateOtherPet(data);
end

function OtherPetPanel:UpdateOtherPet(data)
	self._trsOtherPet.gameObject:SetActive(true);
	
	for i = 1, 6 do
		local d = data.l[i];
		if d then
			local petCfg = PetManager.GetPetConfigById(d.pid);
			self.otherPetIcon[i].spriteName = petCfg and petCfg.icon or "";
			self.otherPetQuality[i].color = ColorDataManager.GetColorByQuality(petCfg and petCfg.quality or 0);
			self.otherPetName[i].text = LanguageMgr.GetColor(petCfg and petCfg.quality or "d", d.name);
			
			local rankCfg = PetManager.GetPetTitle(d.rank);
			-- self.otherPetRealm[i].text = rankCfg and rankCfg.name or d.rank;
			local baseAttr = BaseAdvanceAttrInfo:New()
			local rankAttr = PetManager.GetPetAttrConfigById(d.pid, d.rank)
			baseAttr:Init(rankAttr)
			self._phalanx[i]:Build(2, 1, baseAttr:GetPropertyAndDes())
		else
			self.otherPetIcon[i].spriteName = "";
			self.otherPetQuality[i].color = ColorDataManager.GetColorByQuality(0)
			self.otherPetName[i].text = "";
			-- self.otherPetLevel[i].text = "";
			-- self.otherPetRealm[i].text = "";
		end
	end
end
