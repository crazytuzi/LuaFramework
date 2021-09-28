require "Core.Module.Common.UISubPanel";
require "Core.Module.Common.UIHeroAnimationModel"
require "Core.Manager.Item.RealmManager"
require "Core.Manager.Item.MoneyDataManager";
require "Core.Module.Realm.View.Item.RealmCompactProductItem"

RealmCompactPanel = class("RealmCompactPanel", UISubPanel)

RealmCompactPanel.WAITTIME = 0.5;
local LOCALTO = Vector3.New(0, 0.9, 1.5);
RealmCompactPanel.HANGS = {"S_leg_R", "S_leg_L", "S_Spine", "S_RH", "S_LH", "S_Head"};
RealmCompactPanel.ACTIONS = {"leg_R", "leg_L", "spine", "hand", "hand", "head_L"};
RealmCompactPanel.EFFECTNAMES = {"UI_jingjie_leg_R", "UI_jingjie_leg_L", "UI_jingjie_spine", "UI_jingjie_hand", "UI_jingjie_hand", "UI_jingjie_head"};

function RealmCompactPanel:New(transform )
	if(transform) then
		self = {};
		setmetatable(self, {__index = RealmCompactPanel});
		-- self._imgBg = imgBg;
		self:Init(transform)
		return self;
	end
	return nil;
end

function RealmCompactPanel:_InitReference()
	self._nextLevelInfo = UIUtil.GetChildByName(self._transform, "Transform", "nextLevelInfo");
	self._txtIsBest = UIUtil.GetChildByName(self._transform, "Transform", "txtIsBest");
	
	self._effects = {};
	
	--[[    self._expends = { };
    for j = 1, 2 do
        local transform = UIUtil.GetChildByName(self._transform, "Transform", "expend" .. j);
        local item = RealmCompactProductItem:New(transform);
        self._expends[j] = item;
    end]]
	self._txtNextLevel = UIUtil.GetChildByName(self._nextLevelInfo, "UILabel", "txtNextLevel");
	self._txtAddPer = UIUtil.GetChildByName(self._nextLevelInfo, "UILabel", "txtAddPer");
	self._txtAddAttributeLabel = UIUtil.GetChildByName(self._nextLevelInfo, "UILabel", "txtAddAttributeLabel");
	self._txtAddAttribute = UIUtil.GetChildByName(self._nextLevelInfo, "UILabel", "txtAddAttribute");
	
	self._txtAttributes = UIUtil.GetChildByName(self._transform, "UILabel", "txtAttributes");
	self._txtTitle = UIUtil.GetChildByName(self._transform, "UILabel", "txtTitle");
	self._txtMySpend = UIUtil.GetChildByName(self._transform, "UILabel", "txtMySpend");
	self._btnCompact = UIUtil.GetChildByName(self._transform, "UIButton", "btnCompact");
	self._txtCondition = UIUtil.GetChildByName(self._transform, "UILabel", "txtCondition");
	
	local trsRoleParent = UIUtil.GetChildByName(self._transform, "Transform", "imgRole/roleCamera/trsRoleParent");
	self._role = Resourcer.Get("Roles", "n_jl", trsRoleParent);
	Util.SetLocalPos(self._role, LOCALTO.x, LOCALTO.y, LOCALTO.z)
	
	--    self._role.transform.localPosition = LOCALTO;
	self._centrePosition = self._role.transform.position;
	
	Util.SetLocalPos(self._role, 0, 0, 0)
	
	--    self._role.transform.localPosition = Vector3.zero;
	NGUITools.SetChildLayer(self._role.transform, Layer.UIModel)
	
	self._roleAnimator = self._role:GetComponent("Animator");
	self._roleHangs = UIUtil.GetComponentsInChildren(self._role, "Transform");
	self._roleOriginPoint = self._role.transform.position;
	
	self._timer = Timer.New(function(val) self:_OnTickHandler(val) end, 0, - 1, false);
	self:_InitEffect();
	InstanceDataManager.UpData(RealmCompactPanel._RefreshUI, self)
	if(RealmManager.GetCompactLevel() == 0) then
		MessageManager.AddListener(RealmNotes, RealmNotes.EVENT_REALMUPGRADE1, RealmCompactPanel.OnRealmUpgrade, self);
	end
end

function RealmCompactPanel:_InitEffect()
	local level = RealmManager.GetCompactLevel();
	local bLV = math.ceil(level / 5);
	for i = 1, 6 do
		self._effects[i] = Resourcer.Get("Effect/UIEffect", RealmCompactPanel.EFFECTNAMES[i], self._role.transform);
		self._effects[i]:SetActive(i == bLV or level >= 30)
		UIUtil.SetGameObjectTintColor(self._effects[i], ColorDataManager.GetRealmMeridiansEffectColor((level - 1) % 5 + 1));
	end
	NGUITools.SetChildLayer(self._role.transform, Layer.UIModel)
end

function RealmCompactPanel:_InitListener()
	MessageManager.AddListener(RealmNotes, RealmNotes.EVENT_REALMCOMPACT, RealmCompactPanel.OnCompact, self);
	--MessageManager.AddListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, RealmCompactPanel.OnProductsChange, self);
	self._onCompactButtonClick = function(go) self:_OnCompactButtonClick() end
	UIUtil.GetComponent(self._btnCompact, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onCompactButtonClick);
end

function RealmCompactPanel:_DisposeListener()
	MessageManager.RemoveListener(RealmNotes, RealmNotes.EVENT_REALMCOMPACT, RealmCompactPanel.OnCompact);
	--MessageManager.RemoveListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, RealmCompactPanel.OnProductsChange, self);
	UIUtil.GetComponent(self._btnCompact, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onCompactButtonClick = nil;
end

function RealmCompactPanel:_DisposeReference()
	if(RealmManager.GetCompactLevel() == 0) then
		MessageManager.RemoveListener(RealmNotes, RealmNotes.EVENT_REALMUPGRADE1, RealmCompactPanel.OnRealmUpgrade);
	end
	self._nextLevelInfo = nil;
	self._txtIsBest = nil;
	
	self._timer:Stop();
	self._timer = nil;
	
	for i, v in pairs(self._effects) do
		Resourcer.Recycle(v, false);
	end
	self._effects = nil;
	
	--[[    for i, v in pairs(self._expends) do
        self._expends[i]:Dispose();
        self._expends[i] = nil;
    end
    self._expends = nil;]]
	self._txtNextLevel = nil;
	self._txtAddPer = nil;
	self._txtAddAttributeLabel = nil;
	self._txtAddAttribute = nil;
	
	self._txtAttributes = nil;
	self._txtTitle = nil;
	self._txtMySpend = nil;
	self._btnCompact = nil;
	
	self._roleAnimator = nil;
	self._roleHangs = nil;
	Resourcer.Recycle(self._role, false);
	self._role = nil;
	-- self._imgBg = nil;
end

function RealmCompactPanel:_OnEnable()
	self:_RefreshUI();
	self:_RefreshBg();
	-- self._transform.gameObject:SetActive(true)
end

function RealmCompactPanel:_OnDisable()
	-- self._transform.gameObject:SetActive(false)
end

function RealmCompactPanel:_RefreshBg()
	-- if(self._imgBg) then
	-- 	self._imgBg.mainTexture = UIUtil.GetTexture("realm/cbg");
	-- end
end

function RealmCompactPanel:_FormatAttrsText(info)
	local attrs = RealmManager.GetUpgradeAttrs()
	local hInfo = PlayerManager.hero.info;
	if(attrs) then
		if(info) then
			local addHpMax = info.hp_max;
			local rade = info.plus_rate / 100;
			local value = math.floor((attrs.hp_max * rade + addHpMax) - attrs.hp_max);
			if(value > 0) then
				text = LanguageMgr.Get("attr/hp_max") .. "：+" .. math.floor(attrs.hp_max) .. "    [9dff4e]+" .. value .. "[-]\n";
			else
				text = LanguageMgr.Get("attr/hp_max") .. "：+" .. math.floor(attrs.hp_max) .. "\n";
			end
			-- 		value = math.floor((attrs.mp_max * rade) - attrs.mp_max)
			-- 		if (value > 0) then
			-- 			text = text .. LanguageMgr.Get("attr/mp_max") .. "：+" .. math.floor(attrs.mp_max) .. "    [9dff4e]+" .. value .. "[-]\n";
			-- 		else
			-- 			text = text .. LanguageMgr.Get("attr/mp_max") .. "：+" .. math.floor(attrs.mp_max) .. "\n";
			-- 		end
			-- if(hInfo.dmg_type == 1) then
				value = math.floor((attrs.phy_att * rade + info.phy_att) - attrs.phy_att)
				if(value > 0) then
					text = text .. LanguageMgr.Get("attr/phy_att") .. "：+" .. math.floor(attrs.phy_att) .. "    [9dff4e]+" .. value .. "[-]\n";
				else
					text = text .. LanguageMgr.Get("attr/phy_att") .. "：+" .. math.floor(attrs.phy_att) .. "\n";
				end
			-- end
			-- if(hInfo.dmg_type == 2) then
			-- 	value = math.floor((attrs.mag_att * rade + info.mag_att) - attrs.mag_att)
			-- 	if(value > 0) then
			-- 		text = text .. LanguageMgr.Get("attr/mag_att") .. "：+" .. math.floor(attrs.mag_att) .. "    [9dff4e]+" .. value .. "[-]\n";
			-- 	else
			-- 		text = text .. LanguageMgr.Get("attr/mag_att") .. "：+" .. math.floor(attrs.mag_att) .. "\n";
			-- 	end
			-- end
			value = math.floor((attrs.phy_def * rade + info.phy_def) - attrs.phy_def)
			if(value > 0) then
				text = text .. LanguageMgr.Get("attr/phy_def") .. "：+" .. math.floor(attrs.phy_def) .. "    [9dff4e]+" .. value .. "[-]\n";
			else
				text = text .. LanguageMgr.Get("attr/phy_def") .. "：+" .. math.floor(attrs.phy_def) .. "\n";
			end
			value = math.floor((attrs.mag_def * rade + info.mag_def) - attrs.mag_def)
			if(value > 0) then
				text = text .. LanguageMgr.Get("attr/mag_def") .. "：+" .. math.floor(attrs.mag_def) .. "    [9dff4e]+" .. value .. "[-]\n";
			else
				text = text .. LanguageMgr.Get("attr/mag_def") .. "：+" .. math.floor(attrs.mag_def) .. "\n";
			end
			value = math.floor((attrs.hit * rade + info.hit) - attrs.hit)
			if(value > 0) then
				text = text .. LanguageMgr.Get("attr/hit") .. "：+" .. math.floor(attrs.hit) .. "    [9dff4e]+" .. value .. "[-]\n";
			else
				text = text .. LanguageMgr.Get("attr/hit") .. "：+" .. math.floor(attrs.hit) .. "\n";
			end
			value = math.floor((attrs.eva * rade + info.eva) - attrs.eva)
			if(value > 0) then
				text = text .. LanguageMgr.Get("attr/eva") .. "：+" .. math.floor(attrs.eva) .. "    [9dff4e]+" .. value .. "[-]\n";
			else
				text = text .. LanguageMgr.Get("attr/eva") .. "：+" .. math.floor(attrs.eva) .. "\n";
			end
			value = math.floor((attrs.crit * rade + info.crit) - attrs.crit)
			if(value > 0) then
				text = text .. LanguageMgr.Get("attr/crit") .. "：+" .. math.floor(attrs.crit) .. "    [9dff4e]+" .. value .. "[-]\n";
			else
				text = text .. LanguageMgr.Get("attr/crit") .. "：+" .. math.floor(attrs.crit) .. "\n";
			end
			value = math.floor((attrs.tough * rade + info.tough) - attrs.tough)
			if(value > 0) then
				text = text .. LanguageMgr.Get("attr/tough") .. "：+" .. math.floor(attrs.tough) .. "    [9dff4e]+" .. value .. "[-]\n";
			else
				text = text .. LanguageMgr.Get("attr/tough") .. "：+" .. math.floor(attrs.tough) .. "\n";
			end
			
			value = math.floor((attrs.fatal * rade + info.fatal) - attrs.fatal)
			if(value > 0) then
				text = text .. LanguageMgr.Get("attr/fatal") .. "：+" .. math.floor(attrs.fatal) .. "    [9dff4e]+" .. value .. "[-]\n";
			else
				text = text .. LanguageMgr.Get("attr/fatal") .. "：+" .. math.floor(attrs.fatal) .. "\n";
			end
			
			value = math.floor((attrs.block * rade + info.block) - attrs.block)
			if(value > 0) then
				text = text .. LanguageMgr.Get("attr/block") .. "：+" .. math.floor(attrs.block) .. "    [9dff4e]+" .. value .. "[-]";
			else
				text = text .. LanguageMgr.Get("attr/block") .. "：+" .. math.floor(attrs.block);
			end
		else
			text = LanguageMgr.Get("attr/hp_max") .. "：+" .. math.floor(attrs.hp_max) .. "\n";
			-- text = text .. LanguageMgr.Get("attr/mp_max") .. "：+" .. math.floor(attrs.mp_max) .. "\n";
			-- if(hInfo.dmg_type == 1) then
				text = text .. LanguageMgr.Get("attr/phy_att") .. "：+" .. math.floor(attrs.phy_att) .. "\n";
			-- end
			-- if(hInfo.dmg_type == 2) then
			-- 	text = text .. LanguageMgr.Get("attr/mag_att") .. "：+" .. math.floor(attrs.mag_att) .. "\n";
			-- end
			text = text .. LanguageMgr.Get("attr/phy_def") .. "：+" .. math.floor(attrs.phy_def) .. "\n";
			-- text = text .. LanguageMgr.Get("attr/mag_def") .. "：+" .. math.floor(attrs.mag_def) .. "\n";
			text = text .. LanguageMgr.Get("attr/hit") .. "：+" .. math.floor(attrs.hit) .. "\n";
			text = text .. LanguageMgr.Get("attr/eva") .. "：+" .. math.floor(attrs.eva) .. "\n";
			text = text .. LanguageMgr.Get("attr/crit") .. "：+" .. math.floor(attrs.crit) .. "\n";
			text = text .. LanguageMgr.Get("attr/tough") .. "：+" .. math.floor(attrs.tough) .. "\n";
			text = text .. LanguageMgr.Get("attr/fatal") .. "：+" .. math.floor(attrs.fatal) .. "\n";
			text = text .. LanguageMgr.Get("attr/block") .. "：+" .. math.floor(attrs.block);
		end
	end
	return text
end

function RealmCompactPanel:OnProductsChange()
	local realmLv = RealmManager.GetRealmLevel()
	local btnEnabled = realmLv > 0;
	for i, v in pairs(self._expends) do
		local spid = v.id;
		if(spid) then
			local num = BackpackDataManager.GetProductTotalNumBySpid(spid);
			v:SetValue(num);
			btnEnabled = btnEnabled and(num >= v.total)
		end
	end
	if(realmLv > 0) then
		MessageManager.Dispatch(RealmNotes, RealmNotes.EVENT_COMPACTTIP_CHANGE, btnEnabled);
	else
		MessageManager.Dispatch(RealmNotes, RealmNotes.EVENT_COMPACTTIP_CHANGE, false);
	end
	self._btnCompact.isEnabled = btnEnabled;
end

local notCompact = LanguageMgr.Get("realm/notCompact")
function RealmCompactPanel:_RefreshUI()
	local realmLv = RealmManager.GetRealmLevel()
	local info = RealmManager.GetCompactInfoByLevel();
	local nextInfo = RealmManager.GetCompactInfoByLevel(RealmManager.GetCompactLevel() + 1);
	self._txtAttributes.text = self:_FormatAttrsText(info);
	if(info) then
		local effColor = ColorDataManager.GetRealmEffectColor(info.realm_quality + 1);
		self._txtTitle.text = info.quality_title;
		self._txtTitle.applyGradient = true;
		self._txtTitle.effectColor = effColor.ec;
		self._txtTitle.gradientTop = effColor.tc;
		self._txtTitle.gradientBottom = effColor.bc;
	else
		self._txtTitle.text = notCompact;
		self._txtTitle.applyGradient = false;
		self._txtTitle.effectColor = Color.New(0, 0, 0, 0);
	end
	local btnEnabled = realmLv > 0;
	if(nextInfo) then
		local addName, addValue = RealmManager.GetCompactAddAttribute(info, nextInfo);
		--[[        for i, v in pairs(nextInfo.compact_consume) do
            local item = self._expends[i];
            local p = string.split(v, "_");
            local num = BackpackDataManager.GetProductTotalNumBySpid(tonumber(p[1]));
            local needNum = tonumber(p[2]);
            item:SetProductId(tonumber(p[1]), tonumber(p[2]));
            item:SetValue(num);
            btnEnabled = btnEnabled and(num >= needNum);
        end]]
		-- self._btnCompact.isEnabled = btnEnabled;
		btnEnabled = self:_UpdateCondition(nextInfo)
		self._txtNextLevel.text = nextInfo.quality_title;
		self._txtAddPer.text = "+" ..(nextInfo.plus_rate - 100) .. "%";
		self._txtAddAttributeLabel.text = addName;
		self._txtAddAttribute.text = "+" .. addValue;
		self._nextLevelInfo.gameObject:SetActive(true)
		self._txtIsBest.gameObject:SetActive(false);
		self._btnCompact.gameObject:SetActive(btnEnabled)
	else
		--[[        for i, v in pairs(self._expends) do
--            v:SetProductId(-1, 0);
--        end
        self._btnCompact.isEnabled = false;]]
		self._btnCompact.gameObject:SetActive(false)
		self._nextLevelInfo.gameObject:SetActive(false)
		self._txtIsBest.gameObject:SetActive(true);
		btnEnabled = false
		self._txtCondition.text = ""
	end
	if(btnEnabled) then
		MessageManager.Dispatch(RealmNotes, RealmNotes.EVENT_COMPACTTIP_CHANGE, btnEnabled);
	else
		MessageManager.Dispatch(RealmNotes, RealmNotes.EVENT_COMPACTTIP_CHANGE, false);
	end
	
end

function RealmCompactPanel:_UpdateCondition(nextInfo)
	local n = nextInfo.num
	local ceng = RealmProxy.GetXLTier()
	local ok = ceng >= n
	--Warning("_UpdateCondition_," .. n  .. "___" .. ceng)
	if ok then
		self._txtCondition.text = ""
	else
		self._txtCondition.text = LanguageMgr.Get("realm/condition", {n = n})
	end
	return ok
end

function RealmCompactPanel:_OnTickHandler()
	local stateInfo = self._roleAnimator:GetCurrentAnimatorStateInfo(0);
	if(self._blZoomIn) then
		if(stateInfo:IsName(self._actName)) then
			self._to = self._role.transform.position +(self._centrePosition - self._currHang.position);
		else
			self._to = self._roleOriginPoint
			self._blZoomIn = false
		end
	end
	Util.SetPos(self._role.gameObject, Vector3.Lerp(self._role.transform.position, self._to, 0.3))
	--    self._role.transform.position = Vector3.Lerp(self._role.transform.position, self._to, 0.3);
	if Vector3.Distance2(self._role.transform.position, self._to) < 0.005 and not self._blZoomIn then
		self._btnCompact.isEnabled = true;
		Util.SetPos(self._role.gameObject, self._roleOriginPoint.x, self._roleOriginPoint.y, self._roleOriginPoint.z)
		--        self._role.transform.position = self._roleOriginPoint;
		self._timer:Stop();
		if(RealmManager.GetCompactLevel() == 30) then
			for i = 1, 5 do
				if(self._effects[i] ~= nil) then
					UIUtil.SetGameObjectTintColor(self._effects[i], ColorDataManager.GetRealmMeridiansEffectColor(5));
					self._effects[i]:SetActive(true);
				end
			end
		end
	end
end

function RealmCompactPanel:_PlayLevelEffect(levle)
	if(self._role) then
		local bLV = math.ceil(levle / 5);
		self._currHang = UIUtil.GetChildInComponents(self._roleHangs, RealmCompactPanel.HANGS[bLV])
		if(self._currHang) then
			self._blZoomIn = true;
			self._actName = RealmCompactPanel.ACTIONS[bLV];
			if(self._roleAnimator) then
				self._roleAnimator:Play(self._actName)
				self._roleAnimator:Update(0);
			end
			for i, v in pairs(self._effects) do
				if(v) then
					if(i == bLV) then
						local animator = v:GetComponent("Animator");
						v:SetActive(true)
						if(animator) then
							animator:Play("effect");
						end
						UIUtil.SetGameObjectTintColor(v, ColorDataManager.GetRealmMeridiansEffectColor((levle - 1) % 5 + 1));
						UIUtil.StopParticleSystem(v)
						UIUtil.PlayParticleSystem(v)
					else
						v:SetActive(false)
					end
				end
			end
			self._to = self._role.transform.position +(self._centrePosition - self._currHang.position);
			self._btnCompact.isEnabled = false;
			if(not self._timer.IsRunning) then
				self._timer:Start();
			end
		end
	end
end

function RealmCompactPanel:_RefreshRes()
	
end

function RealmCompactPanel:_OnCompactButtonClick()
	--[[    local realmLv = RealmManager.GetRealmLevel()
    if (realmLv > 0) then
        local lbEnabled = true;
        local resId;
        for i, v in pairs(self._expends) do
            local spid = v.id;
            if (spid) then                
                local num = BackpackDataManager.GetProductTotalNumBySpid(spid);
                v:SetValue(num);
                if (v.total > num and resId == nil) then
                    resId = spid
                end
                lbEnabled = lbEnabled and(num >= v.total)
            end
        end
        if (lbEnabled) then ]]
	RealmProxy.Compact();
	--[[        else
            ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL, {id = resId, msg= RealmNotes.CLOSE_REALM})
            --MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("realm/res"));
        end
    else
        MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("realm/level"));
    end]]
	SequenceManager.TriggerEvent(SequenceEventType.Guide.REALM_COMPACT);
end

function RealmCompactPanel:OnCompact(data)
	if data and data.errCode == nil then
		RealmManager.SetCompactLevel(data.clv);
		self:_PlayLevelEffect(data.clv);
		self:_RefreshUI();
	end
end

function RealmCompactPanel:OnRealmUpgrade(data)
	if data and data.errCode == nil then
		MessageManager.RemoveListener(RealmNotes, RealmNotes.EVENT_REALMUPGRADE1, RealmCompactPanel.OnRealmUpgrade);
		self:_RefreshUI();
	end
end
