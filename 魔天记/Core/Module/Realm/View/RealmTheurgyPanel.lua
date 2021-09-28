require "Core.Module.Common.UISubPanel";
require "Core.Module.Common.UIHeroAnimationModel"
require "Core.Manager.Item.RealmManager"
require "Core.Manager.Item.MoneyDataManager";
require "Core.Module.Skill.SkillNotes"
require "Core.Module.Realm.View.Item.RealmCompactButton"
require "Core.Module.Realm.View.Item.RealmSkillPanel"

local skillCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SKILL);

RealmTheurgyPanel = class("RealmTheurgyPanel", UISubPanel)

function RealmTheurgyPanel:New(transform)
	if(transform) then
		self = {};
		setmetatable(self, {__index = RealmTheurgyPanel});
		self._currLayer = 0;	
		-- self._imgBg = imgBg
		self:Init(transform)
		return self;
	end
	return nil;
end

function RealmTheurgyPanel:_InitReference()
	self._levelItems = UIUtil.GetChildByName(self._transform, "Transform", "levels");
	self._levels = {};
	
	for i = 1, 7 do
		local item = UIUtil.GetChildByName(self._levelItems, "Transform", "lv" .. i);
		--local btn = RealmCompactButton:New(item, RealmManager.GetUpgradeInfoByLevel((i - 1) * 9 + 1));
		local info = RealmManager.GetFairy(i, 1)
		local info2 = RealmManager.GetFairy(i, 2)
		local btn = RealmCompactButton:New(item, info, info2);
		btn.layer = i;
		btn:AddClickListener(self, RealmTheurgyPanel._OnClickCompactButtonHandler);
		self._levels[i] = btn
	end
	
	self._skills = {};
	for i = 1, 2 do
		local item = UIUtil.GetChildByName(self._transform, "Transform", "skill" .. i);
		local skillBtn = RealmSkillPanel:New(item);
		skillBtn:AddClickListener(self, nil, RealmTheurgyPanel._OnUpgradeButtonHandler);
		self._skills[i] = skillBtn
	end
	
	
	self._txtSelectLevel = UIUtil.GetChildByName(self._transform, "UILabel", "txtSelectLevel");
	
	self._txtMySpend = UIUtil.GetChildByName(self._transform, "UILabel", "txtMySpend");
	self._btnConfigure = UIUtil.GetChildByName(self._transform, "UIButton", "btnConfigure");	
	
	self._helpPanel = UIUtil.GetChildByName(self._transform, "Transform", "helpPanel");
	self._helpPanelMask = UIUtil.GetChildByName(self._helpPanel, "Transform", "mask");
	self._btnHelp = UIUtil.GetChildByName(self._transform, "UIButton", "btnHelp");
	
	self:_OnHelpMaskButtonClick();
	
	InstanceDataManager.UpData(function()
		self:_RefreshLevel();
		self:_RefreshUI();
	end)
end

function RealmTheurgyPanel:_InitListener()
	MessageManager.AddListener(PlayerManager, PlayerManager.OhterInfoChg, RealmTheurgyPanel.OnMoneyChange, self);
	MessageManager.AddListener(SkillNotes, SkillNotes.EVENT_UPGRADE, RealmTheurgyPanel.OnSkillUpgrade, self);
	MessageManager.AddListener(RealmNotes, RealmNotes.EVENT_CHOOSEREALMSKILL, RealmTheurgyPanel.OnChooseRealmSkill, self);
	self._onConfigureButtonClick = function(go) self:_OnConfigureButtonClick() end
	UIUtil.GetComponent(self._btnConfigure, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onConfigureButtonClick);
	
	self._onHelpButtonClick = function(go) self:_OnHelpButtonClick() end
	UIUtil.GetComponent(self._btnHelp, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onHelpButtonClick);
	
	self._onHelpMaskButtonClick = function(go) self:_OnHelpMaskButtonClick() end
	UIUtil.GetComponent(self._helpPanelMask, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onHelpMaskButtonClick);	
end

function RealmTheurgyPanel:_DisposeListener()
	MessageManager.RemoveListener(PlayerManager, PlayerManager.OhterInfoChg, RealmTheurgyPanel.OnMoneyChange, self);
	MessageManager.RemoveListener(SkillNotes, SkillNotes.EVENT_UPGRADE, RealmTheurgyPanel.OnSkillUpgrade, self);
	MessageManager.RemoveListener(RealmNotes, RealmNotes.EVENT_CHOOSEREALMSKILL, RealmTheurgyPanel.OnChooseRealmSkill, self);
	UIUtil.GetComponent(self._btnConfigure, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onConfigureButtonClick = nil;
	
	UIUtil.GetComponent(self._btnHelp, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onHelpButtonClick = nil
	UIUtil.GetComponent(self._helpPanelMask, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onHelpMaskButtonClick = nil
end

function RealmTheurgyPanel:_DisposeReference()
	for i, v in pairs(self._levels) do
		self._levels[i]:Dispose();
		self._levels[i] = nil;
	end
	self._levels = nil;
	
	for i, v in pairs(self._skills) do
		self._skills[i]:Dispose();
		self._skills[i] = nil;
	end
	self._skills = nil;
	
	self._txtSelectLevel = nil;
	self._txtMySpend = nil;
	self._btnConfigure = nil;
	-- self._imgBg = nil;
	self._helpPanel = nil;
	self._helpPanelMask = nil;
	self._btnHelp = nil;
end

function RealmTheurgyPanel:_GetSkillById(id)
	local heroInfo = PlayerManager.hero.info;
	if(heroInfo) then
		local skill = heroInfo:GetSkill(id, true);
		if(skill) then
			return skill
		end
	end
	return skillCfg[id .. "_1"];
end

function RealmTheurgyPanel:_OnEnable()
	-- self._transform.gameObject:SetActive(true)
	self:_RefreshLevel();
	self:_RefreshUI();
	self:_RefreshBg();
	if(self._currSelecte == nil) then
		--[[        local rLv = RealmManager.GetRealmLevel();
        if (rLv == 0) then rLv = 1 end;
        local tlv = math.ceil(rLv / 90);
        if (self._levels[tlv]) then
            self._levels[tlv]:SetSelected(true);
        end--]]
		self._levels[1]:SetSelected(true);
	else
		self._currSelecte:SetSelected(false);
		self._currSelecte:SetSelected(true);
	end	
end

function RealmTheurgyPanel:_OnDisable()
	-- self._transform.gameObject:SetActive(false)
end

function RealmTheurgyPanel:_RefreshBg()
	-- if(self._imgBg) then
	-- 	self._imgBg.mainTexture = UIUtil.GetTexture("realm/tbg");
	-- end
end

local theurgy = LanguageMgr.Get("realm/RealmTheurgyPanel/theurgy")
function RealmTheurgyPanel:_OnClickCompactButtonHandler(owner)
	if(self._currSelecte ~= owner) then
		if(self._currSelecte) then
			self._currSelecte:SetSelected(false)
		end
	 
		local info = owner.info
		local info2 = owner.info2
		self._currSelecte = owner;
		self._currLayer = owner.layer;
		self._txtSelectLevel.text = info.name .. theurgy;
		local xlCeng = RealmProxy.GetXLTier()
		local skill = RealmManager.GetRealmSkill(owner.layer);
		for i = 1, 2 do
			local sk = self._skills[i];
			local inf = i == 1 and info or info2
			local s = RealmManager:GetHeroSkillById(inf.skill)
			sk:SetSkillAndRealm(s, inf)
			sk:SetEnabled(inf.num <= xlCeng)
			sk:SetSelected(s.id == skill)
		end
	end
end

--function RealmTheurgyPanel:_OnClickSkillButtonHandler(owner)    
--    if (owner and self._currSelecte) then        
--        local skill = owner.skill;
--        if (skill and self._currLayer > 0 and self._currLayer <= 7) then
--            RealmProxy.ChooseSkill(self._currLayer, skill.id);
--        end
--    end
--end
function RealmTheurgyPanel:_OnUpgradeButtonHandler(owner)
	if(owner and owner.skill) then
		SkillProxy.ReqUpgrade(owner.skill.id);
	end
end

function RealmTheurgyPanel:_OnHelpButtonClick()
	self._helpPanel.gameObject:SetActive(true);
end

function RealmTheurgyPanel:_OnHelpMaskButtonClick()
	self._helpPanel.gameObject:SetActive(false);
end

function RealmTheurgyPanel:OnChooseRealmSkill(data)	
	if data and data.errCode == nil then
		local layer = data.layer;
		local skid = data.sk;
		if(skid and layer > 0 and layer <= 7) then			
			if(self._currLayer == layer) then
				for i, v in pairs(self._skills) do
					if(v and v.skill and v.skill.id == skid) then
						v:SetSelected(true)
					else
						v:SetSelected(false)
					end
				end
			end
		end
	end
end

function RealmTheurgyPanel:OnSkillUpgrade()
	for i, v in pairs(self._skills) do
		v:Refresh();
        v:SetUpgrade()
	end
end

function RealmTheurgyPanel:OnMoneyChange()
	if(self._txtMySpend) then
		self._txtMySpend.text = PlayerManager.vp;
	end
	self:OnSkillUpgrade();
end

function RealmTheurgyPanel:_RefreshLevel()
	local levels = self._levels;
	--[[    local rLv = RealmManager.GetRealmLevel();    
    local maxLayer = math.ceil(rLv / 9);    
    for i = 1, 7 do
        local btn = levels[i];
        local blEnabled = maxLayer >= i;
        if (btn) then
            btn:SetEnabled(blEnabled);
            if (btn == self._currSelecte) then
                local skill = RealmManager.GetRealmSkill(i);               
                for j, sk in pairs(self._skills) do
                    sk:SetEnabled(blEnabled);
                    if (sk.skill and sk.skill.id == skill) then
                        sk:SetSelected(true);
                    else
                        sk:SetSelected(false);
                    end
                end
            end
        end
    ]]
	local xlCeng = RealmProxy.GetXLTier()
	for i = 1, 7 do
		local btn = levels[i];
		if(btn) then
			local info = btn.info
			local info2 = btn.info2
			local blEnabled1 = info.num <= xlCeng
			local blEnabled2 = info2.num <= xlCeng
			local blEnabled = blEnabled1 or blEnabled2;
			btn:SetEnabled(blEnabled);
			if(btn == self._currSelecte) then
				local skill = RealmManager.GetRealmSkill(i);
				for j, sk in pairs(self._skills) do
					sk:SetEnabled(j == 1 and blEnabled1 or blEnabled2);
					if(sk.skill and sk.skill.id == skill) then
						sk:SetSelected(true);
					else
						sk:SetSelected(false);
					end
				end
			end
		end
	end
end


function RealmTheurgyPanel:_RefreshUI()
	self:OnMoneyChange()
end

function RealmTheurgyPanel:_RefreshRes()
	
end

function RealmTheurgyPanel:_OnConfigureButtonClick()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, "UI_RealmPanel");
	ModuleManager.SendNotification(RealmNotes.CLOSE_REALM);
	ModuleManager.SendNotification(SkillNotes.OPEN_SKILLPANEL, 4);
end 