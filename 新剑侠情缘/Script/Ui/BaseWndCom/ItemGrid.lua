
local tbGrid = Ui:CreateClass("ItemGrid");
tbGrid.ANIMA_FRAM = 6 --动画帧数

tbGrid.nTitleDefaultIcon = 790

tbGrid.tbOnClick =
{
	ItemLayer = function (self)
		if self.fnClick then
			self.fnClick(self);
		end
		if Ui.bShowDebugInfo then
			local szClass = "nil";
			local nTemplate = self.nTemplate;
			if self.nItemId then
				local pItem = KItem.GetItemObj(self.nItemId);
				if pItem then
					szClass = pItem.szClass;
					nTemplate = pItem.dwTemplateId;
				end
			end
			local szDebugInfo = "" ..
			"nItemId: " .. (self.nItemId or "nil") .. "\n" ..
			"nTemplate: " .. (nTemplate or "nil") .. "\n" ..
			"szClass: " .. (szClass or "nil") .. "\n" ..
			"nPartnerId: " .. (self.nPartnerId or "nil") .. "\n" ..
			"nFragNum: " .. (self.nFragNum or "nil") .. "\n" ..
			"szDigitalType: " .. (self.szDigitalType or "nil") .. "\n" ..
			"nSkillId: " .. (self.nSkillId or "nil") .. "\n" ..
			"nSkillLevel: " .. (self.nSkillLevel or "nil") .. "\n" ..
			"nFaction: " .. (self.nFaction or "nil") .. "\n" ..
			"nSeqId: " .. (self.nSeqId or "nil") .. "\n" ..
			"nTitleId: " .. (self.nTitleId or "nil") .. "\n"
			Ui:SetDebugInfo(szDebugInfo);
		end
	end
}

tbGrid.tbOnLongPress = {
	ItemLayer = function (self)
		if self.fnLongPress then
			self.fnLongPress(self);
		end
	end
}

tbGrid.tbOnPress = {
	ItemLayer = function (self, szBtnName, bIsPress)
		if self.fnPress then
			self.fnPress(self, szBtnName, bIsPress);
		end
	end
}

tbGrid.tbOnDoubleClick = {
	ItemLayer = function (self)
		if self.fnDoubleClick then
			self.fnDoubleClick(self);
		end
	end
}

tbGrid.tbControls = {
	bShowTip     = false;
	bShowCDLayer = false;
	bShowCount   = false;
	bShowForbit  = false;
}
--非货币数值道具配置
tbGrid.tbOtherConfig = {
	Exp = {
		szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab";
		szIcon = "ExpBig";
	};
	FactionHonor = {
		szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab";
		szIcon = "HonorRongBig";
	};
	BattleHonor = {
		szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab";
		szIcon = "HonorZhanBig";
	};
	BattleHonor2 = {
		szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab";
		szIcon = "HonorZhanBig";
	};
	DomainHonor = {
		szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab";
		szIcon = "HonorZhanBig";
	};
	CrossDomainHonor = {
		szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab";
		szIcon = "HonorZhanBig";
	};
	HSLJHonor = {
		szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab";
		szIcon = "HonorZhanBig";
	};
	DXZHonor = {
		szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab";
		szIcon = "HonorZhanBig";
	};
	IndifferHonor = {
		szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab";
		szIcon = "HonorZhanBig";
	};
	VipExp = {
		szIconAtlas = "UI/Atlas/Item/Item/Item2.prefab";
		szIcon = "ExpVIP";
	};
	LTZ_Honor = {
		szIconAtlas = "UI/Atlas/Item/CurrencyIcon/CurrencyIcon.prefab";
		szIcon = "HonorZhanBig";
	};
}
tbGrid.tbOtherConfig.BasicExp = tbGrid.tbOtherConfig.Exp;

function tbGrid:SetItem(nItemId, tbControls, nFaction, nSex, szHighlightAni, szHighlightAniAtlas)
	self:ClearType();
	self.nItemId = nItemId;
	self.nFaction = nFaction or me.nFaction; --查看别人装备时
	self.szHighlightAni = szHighlightAni
	self.szHighlightAniAtlas = szHighlightAniAtlas
	self.nSex = Player:Faction2Sex(self.nFaction, nSex or me.nSex);
	self:DefaultControls();
	for k,v in pairs(tbControls or {}) do
		self.tbControls[k] = v;
	end
--[[
	Log("eeeeeeee[tbGrid:SetItem]nItemId=", nItemId);
	Log("eeeeeeee[tbGrid:SetItem]nFaction=", nFaction);
	Log("eeeeeeee[tbGrid:SetItem]me.nFaction=", me.nFaction);
	Log("eeeeeeee[tbGrid:SetItem]nSex=", nSex);
	Log("eeeeeeee[tbGrid:SetItem]me.nSex=", me.nSex);
	Log("eeeeeeee[tbGrid:SetItem]self.nSex=", self.nSex);
	Log("eeeeeeee[tbGrid:SetItem]szHighlightAni=", szHighlightAni);
	Log("eeeeeeee[tbGrid:SetItem]szHighlightAniAtlas=", szHighlightAniAtlas);
]]
	self:Update();
end

function tbGrid:SetItemByTemplate(nTemplate, nCount, nFaction, nSex, tbControls, nFragNum, bGray)
	self:ClearType();
	self.nTemplate = nTemplate;
	self.nCount = nCount;
	self.nFaction = nFaction or me.nFaction; -- 门派默认一个
	self.nFragNum = nFragNum;
	self.nSex = Player:Faction2Sex(self.nFaction, nSex or me.nSex);
	self.bGray = bGray

	self:DefaultControls();
	for k,v in pairs(tbControls or {}) do
		self.tbControls[k] = v;
	end
	
--[[
	Log("eeeeeeee[tbGrid:SetItemByTemplate]nTemplate=", nTemplate);
	Log("eeeeeeee[tbGrid:SetItemByTemplate]nCount=", nCount);
	Log("eeeeeeee[tbGrid:SetItemByTemplate]nFaction=", nFaction);
	Log("eeeeeeee[tbGrid:SetItemByTemplate]me.nFaction=", me.nFaction);
	Log("eeeeeeee[tbGrid:SetItemByTemplate]nSex=", nSex);
	Log("eeeeeeee[tbGrid:SetItemByTemplate]me.nSex=", me.nSex);
	Log("eeeeeeee[tbGrid:SetItemByTemplate]self.nSex=", self.nSex);
	Log("eeeeeeee[tbGrid:SetItemByTemplate]nFragNum=", nFragNum);
]]
	self:Update();
end

function tbGrid:SetSkill(nSkillId, nSkillLevel)
	self:ClearType();
	self.nSkillLevel = nSkillLevel;
	self.nSkillId = nSkillId;

	local tbRec = Item:GetSkillItemSetting(nSkillId, nSkillLevel);
	local _, szIcon, szIconAtlas, _, nQuality = unpack(tbRec or {});
	local szFrameColor = Item.tbQualityColor[nQuality or 1];

	self.pPanel:Sprite_SetSprite("Color", szFrameColor);
	self.pPanel:Sprite_SetSprite("ItemLayer", szIcon or "", szIconAtlas);

	self.pPanel:SetActive("Color", true);
	self.pPanel:SetActive("ItemLayer", true);
	self.pPanel:SetActive("LabelSuffix", false);
	self.pPanel:SetActive("LightAnimation", false);
	self.pPanel:SetActive("Fragment", false);
	self.pPanel:SetActive("TagNew", false);
	self.pPanel:SetActive("CDLayer", false);
	self.pPanel:SetActive("TagTip", false);
end

function tbGrid:SetDigitalItem(szType, nValue, tbControls, bGray)
	self:ClearType();
	nValue             = nValue or 0;
	tbControls         = tbControls or {bShowCount = true};
	self.szDigitalType = szType;
	self.nCount        = nValue;
	self.bGray = bGray

	local nQuality = Item:GetDigitalItemQuality(szType, nValue);
    local szFrameColor = Item.tbQualityColor[nQuality];
    local szIcon, szIconAtlas;
    if Shop:IsMoneyType(szType) then
		szIcon, szIconAtlas = Shop:GetMoneyBigIcon(szType);
    elseif self.tbOtherConfig[szType] then
    	if szType == "BasicExp" then
			local nBaseExp = me.GetBaseAwardExp();
			nValue = me.TrueChangeExp(nValue * nBaseExp);
		elseif szType == "Exp" then
			nValue = me.TrueChangeExp(nValue);
		end
		szIcon      = self.tbOtherConfig[szType].szIcon;
		szIconAtlas = self.tbOtherConfig[szType].szIconAtlas;
    else
    	Log("[ItemGrid] SetDigitalItem Type Error", szType);
    	return;
    end
    if bGray then
    	self.pPanel:Sprite_SetSpriteGray("Color", szFrameColor);
    else
    	self.pPanel:Sprite_SetSprite("Color", szFrameColor);
    end

	if szIconAtlas then
		if bGray then
	    	self.pPanel:Sprite_SetSpriteGray("ItemLayer", szIcon, szIconAtlas);
	    else
	    	self.pPanel:Sprite_SetSprite("ItemLayer", szIcon, szIconAtlas);
	    end

	else
		if bGray then
	    	self.pPanel:Sprite_SetSpriteGray("ItemLayer", szIcon);
	    else
	    	self.pPanel:Sprite_SetSprite("ItemLayer", szIcon);
	    end
	end

	if nValue > 0 then
		local OHT = 100000;
		local szValue = nValue >= OHT and math.floor(nValue/10000) .. "万" or tostring(nValue);
		self.pPanel:Label_SetText("LabelSuffix", szValue);
	end

	self.pPanel:SetActive("Color", true);
	self.pPanel:SetActive("ItemLayer", true);
	self.pPanel:SetActive("LightAnimation", false);
	self.pPanel:SetActive("Fragment", false);
	self.pPanel:SetActive("TagNew", false);
	self.pPanel:SetActive("CDLayer", tbControls.bShowCDLayer);
	self.pPanel:SetActive("TagTip", false);
	self.pPanel:SetActive("LabelSuffix", tbControls.bShowCount and nValue > 0);
end

function tbGrid:SetPartner(nPartnerId)
	self:ClearType();
	self.nPartnerId    = nPartnerId;

	self:DefaultControls();
	for k,v in pairs(tbControls or {}) do
		self.tbControls[k] = v;
	end
	self:Update();
end

function tbGrid:SetEquipDebris(nTemplateId, nIndex)
	self:SetItemByTemplate(nTemplateId, nil, nil, nil, nil, nIndex or 0);
end

function tbGrid:SetGenericItemTemplate(nTemplate, nCount, szGray)
	local bGray = self:CheckGray(szGray)
	self:SetItemByTemplate(nTemplate, nCount, nil, nil, nil, nil, bGray)
end

function tbGrid:SetComposeValue(nSeqId)
	self:ClearType();
	self.nSeqId = nSeqId;
	self:Update();
end

function tbGrid:SetTitleItem(nTitleId)
	self:ClearType();
	self.nTitleId = nTitleId;
	self:Update();
end

local tbSetGridFunc =
{
	[Player.award_type_item]            = tbGrid.SetGenericItemTemplate,
	[Player.award_type_partner]         = tbGrid.SetPartner,
	[Player.award_type_special_partner] = tbGrid.SetPartner,
	[Player.award_type_equip_debris]    = tbGrid.SetEquipDebris,
	[Player.award_type_compose_value]   = tbGrid.SetComposeValue,
	[Player.award_type_add_timetitle]   = tbGrid.SetTitleItem,
}

function tbGrid:SetGenericItem(tbData)
	if not tbData or not next(tbData) then
		Log("ItemGrid:SetGenericItem Error, param is error");
		return;
	end
	local szType = tbData[1];
	local fnSetGrid = tbSetGridFunc[Player.AwardType[szType]]
	if fnSetGrid then
		fnSetGrid(self, unpack(tbData, 2))
	else
		local szType, nValue, tbControls, szGray = unpack(tbData)
		local bGray = self:CheckGray(szGray)
		self:SetDigitalItem(szType, nValue, tbControls, bGray)
	end
end

function tbGrid:CheckGray(szGray)
	return szGray and szGray == "Gray"
end

function tbGrid:ClearType()
	self.nItemId = nil;
	self.nTemplate = nil;
	self.nPartnerId = nil;
	self.nFragNum = nil;
	self.szDigitalType = nil;
	self.nSkillId = nil;
	self.nSkillLevel = nil;
	self.nFaction = nil;
	self.nSeqId = nil;
	self.nTitleId = nil;
	self.nSex = nil;
	self.bGray = nil;
end

function tbGrid:Clear()
	self:ClearType();
	self:DefaultControls();
	self:Update();
end

function tbGrid:DefaultControls()
	for k,v in pairs(self.tbControls) do
		self.tbControls[k] = false;
	end
end

tbGrid.tbZhenYuanSkillToSprite = {
	[3801] = "ZhenyuanSkill01"; --【真元】冰清玉润
	[3803] = "ZhenyuanSkill02"; --【真元】穆如清风
	[3804] = "ZhenyuanSkill03"; --【真元】逆水行舟
	[3806] = "ZhenyuanSkill04"; --【真元】天地归心
	[3807] = "ZhenyuanSkill05"; --【真元】铜肤铁骨
}
tbGrid.tbFunTagNew =
{
	["ZhenYuan"] = function (self, pItem)
		local nSkillInfo = pItem.GetIntValue(Item.tbZhenYuan.nItemKeySKillInfo)
		if nSkillInfo ~= 0 then
			local nSkillId, nSkillLevel = Item.tbRefinement:SaveDataToAttrib(nSkillInfo)
			local szSprite = tbGrid.tbZhenYuanSkillToSprite[nSkillId] or "itemtag_skill"
			self.pPanel:Sprite_SetSprite("TagNew",szSprite)
			self.pPanel:SetActive("TagNew", true);
			self.pPanel:ChangePosition("TagNew", -27, -27);
		else
			self.pPanel:SetActive("TagNew", false);
		end
	end;
}


function tbGrid:Update()
	local szName, nIcon, nView, szCount;
	local szFrameColor = "itemframebg";
	local szAnimation;
	local szAnimationAtlas;
	local szColor;
	local pItem;
	local nQuality;

	if self.nItemId then		-- 优先道具ID
		pItem = KItem.GetItemObj(self.nItemId)
		if pItem then
			self.nTemplate = pItem.dwTemplateId;
			nQuality = pItem.nQuality
			if pItem.IsEquip() == 1 then
				local nShowQUanli = Item:GetEqipShowColor(pItem, self.szItemOpt == "PlayerEquip", self.pAsyncRole or me)
				if nShowQUanli then
					nQuality = nShowQUanli
				end
			elseif pItem.nItemType==Item.ITEM_INSCRIPTION then
				local tbClass = Item.tbClass["InscriptionItem"];
				if tbClass then
					local tbAttr
					tbAttr, nQuality = tbClass:GetTip(pItem, me, false);
				end
			end
			
			szName, nIcon, nView = Item:GetDBItemShowInfo(pItem, self.nFaction, self.nSex)

		    if ((not nIcon) or (nIcon == 0)) then
		        Log("eeeeeeee[tbGrid:Update(),nItemId]self.nItemId=", self.nItemId);
		        Log("eeeeeeee[tbGrid:Update(),nItemId]self.nTemplate=", self.nTemplate);
		        Log("eeeeeeee[tbGrid:Update(),nItemId]self.nFaction=", self.nFaction);
		        Log("eeeeeeee[tbGrid:Update(),nItemId]self.nSex=", self.nSex);
		        Log("eeeeeeee[tbGrid:Update(),nItemId]GetItemTemplateShowInfo=", szName, nIcon, nView, nQuality);
		    end
		
			szColor, szFrameColor, szAnimation, szAnimationAtlas = Item:GetQualityColor(nQuality)
			if pItem.nMaxCount > 1 and pItem.nCount > 1 then
				szCount = tostring(pItem.nCount)
			end
		end

	elseif self.nTemplate then
		szName, nIcon, nView, nQuality = Item:GetItemTemplateShowInfo(self.nTemplate, self.nFaction, self.nSex)

		if ((not nIcon) or (nIcon == 0)) then
		    Log("eeeeeeee[tbGrid:Update(),nTemplate]self.nTemplate=", self.nTemplate);
		    Log("eeeeeeee[tbGrid:Update(),nTemplate]self.nFaction=", self.nFaction);
		    Log("eeeeeeee[tbGrid:Update(),nTemplate]self.nSex=", self.nSex);
		    Log("eeeeeeee[tbGrid:Update(),nTemplate]GetItemTemplateShowInfo=", szName, nIcon, nView, nQuality);
		end
		
		local tbSaveRandomAttrib = Item.tbRefinement:GetCustomAttri(self.nTemplate)
		if tbSaveRandomAttrib then
			local  _, nMaxAttribQuality = Item:GetClass("equip"):GetTipByTemplate(self.nTemplate, tbSaveRandomAttrib)
			if nMaxAttribQuality then
				nQuality = nMaxAttribQuality
			end
		end

		szColor, szFrameColor, szAnimation, szAnimationAtlas = Item:GetQualityColor(nQuality)

		if szName then
			if (type(self.nCount) == "number" and self.nCount > 1) or (type(self.nCount) == "string") then
				szCount = tostring(self.nCount);
			end
		end
	elseif self.nPartnerId then
		local _, _, nNpcTemplateId = GetOnePartnerBaseInfo(self.nPartnerId);
		nIcon = KNpc.GetNpcShowInfo(nNpcTemplateId);

		local nValue   = Partner:GetPartnerValueByTemplateId(self.nPartnerId)
		local nQuality = Item:GetDigitalItemQuality("Partner", nValue)
		szFrameColor   = Item.tbQualityColor[nQuality] or Item.DEFAULT_COLOR
	elseif self.nSeqId then
		local szDirTitle, szTips
		nIcon, szDirTitle, szTips, nQuality = Compose.ValueCompose:GetShowInfo(self.nSeqId);
		szColor, szFrameColor, szAnimation, szAnimationAtlas = Item:GetQualityColor(nQuality)
	elseif self.nTitleId then

		nIcon = self.nTitleDefaultIcon;
		szFrameColor = Item.DEFAULT_COLOR;
		local tbTitle = PlayerTitle:GetTitleTemplate(self.nTitleId)
   		if tbTitle then
			szFrameColor = Item.tbQualityColor[tbTitle.Quality] or Item.DEFAULT_COLOR
			if tbTitle.Icon > 0 then
				nIcon = tbTitle.Icon
			end
		end
	end

	if self.nTemplate then
		self.nFragNum = Compose.EntityCompose.tbShowFragTemplates[self.nTemplate]
	end
	if self.nFragNum then
		local szAtlas = "UI/Atlas/NewAtlas/Panel/NewPanel.prefab";
		local szSprite = "itemfragmnet";
		self.pPanel:Sprite_SetSprite("Fragment", szSprite, szAtlas);
		self.pPanel:SetActive("Fragment", true)
	else
		self.pPanel:SetActive("Fragment", false)
	end

	--强制显示高亮
	szAnimation = self.szHighlightAni or szAnimation
	szAnimationAtlas = self.szHighlightAniAtlas or szAnimationAtlas
	if self.bGray then
		self.pPanel:Sprite_SetSpriteGray("Color", szFrameColor);
	else
		self.pPanel:Sprite_SetSprite("Color", szFrameColor);
	end

	if szAnimation and szAnimation ~= "" and szAnimationAtlas ~= "" then
		self.pPanel:SetActive("LightAnimation", true)
		self.pPanel:Sprite_Animation("LightAnimation", szAnimation, szAnimationAtlas, self.ANIMA_FRAM);
		self.pPanel:HideEffect("LightAnimation")
		if  pItem and self.szItemOpt == "PlayerEquip"  then
			local nEffect = Item:GetQualityEffect(nQuality)
			if  nEffect ~= 0 then
				self.pPanel:ShowEffect("LightAnimation", nEffect, 1)
			end
		end
	else
		--因为显示LightAnimation是异步的，如果这时接连做了 显示隐藏，则上次异步加载的动画会在下次显示
		self.pPanel:SetActive("LightAnimation", false)
		self.pPanel:Sprite_SetEnable("LightAnimation", false)
	end

	-- 道具图标
	if nIcon then
		local szIconAtlas, szIconSprite;
		if self.nPartnerId then
			szIconAtlas, szIconSprite = Npc:GetFace(nIcon);
		else
			local szExtAtlas, szExtSprite;
			szIconAtlas, szIconSprite, szExtAtlas, szExtSprite = Item:GetIcon(nIcon);
			if not self.nFragNum and szExtAtlas and szExtAtlas ~= "" and szExtSprite and szExtSprite ~= "" then
				self.pPanel:Sprite_SetSprite("Fragment", szExtSprite, szExtAtlas);
				self.pPanel:SetActive("Fragment", true)
			elseif self.szFragmentSprite then
				self.pPanel:Sprite_SetSprite("Fragment", self.szFragmentSprite, self.szFragmentAtlas);
				self.pPanel:SetActive("Fragment", true)
			end
		end

		self.pPanel:SetActive("ItemLayer", true)
		if self.bGray then
			self.pPanel:Sprite_SetSpriteGray("ItemLayer", szIconSprite, szIconAtlas);
		else
			self.pPanel:Sprite_SetSprite("ItemLayer", szIconSprite, szIconAtlas);
		end

	else
		self.pPanel:SetActive("ItemLayer", false);
	end
	-- 下标
	if szCount then
		self.pPanel:SetActive("LabelSuffix", true)
		self.pPanel:Label_SetText("LabelSuffix", szCount);
	else
		self.pPanel:SetActive("LabelSuffix", false)
	end

	-- tag标识
	self:SetTagTip();

	-- 新道具标识
	if pItem and self.tbFunTagNew[pItem.szClass] then
		self.tbFunTagNew[pItem.szClass](self, pItem)
	elseif (self.tbControls.bShowForbit) or ( pItem and Item:IsForbidStall(pItem) )  then
		self.pPanel:Sprite_SetSprite("TagNew","itemtag_seal")
		self.pPanel:SetActive("TagNew", true);
		self.pPanel:ChangePosition("TagNew", -27, -27);
	else
		self.pPanel:SetActive("TagNew", false);
	end

	-- CD层
	local bUseable = true
	if pItem and me.GetItemInBag(pItem.dwId) then
		bUseable = Item:CheckUsable(pItem, pItem.szClass) == 1;
	end
	if not bUseable then
		self.pPanel:SetActive("CDLayer", true);
		self.pPanel:Sprite_SetSprite("CDLayer", "itemframeDisable")
	else
		self.pPanel:Sprite_SetSprite("CDLayer", "itemframeCDL")
		self.pPanel:SetActive("CDLayer", self.tbControls.bShowCDLayer);
	end
end

tbGrid.tbFunTagTip =
{
	["SkillBook"] = function (pItem)
		if pItem.nUseLevel > me.nLevel then
			return;
		end

		local tbBook = Item:GetClass("SkillBook");
		local bRet = tbBook:HaveSkillBook(me, pItem.dwTemplateId);
		if bRet then
			return;
		end

		local nEquipPos = tbBook:FinEmptyHole(me);
        if not nEquipPos then
            return;
        end

        local bRet, szMsg = tbBook:CheckUseEquip(me, pItem, nEquipPos);
        if not bRet then
        	return;
        end

		local tbBookInfo = tbBook:GetBookInfo(pItem.dwTemplateId);
	    if not tbBookInfo then
	        return;
	    end

	    if tbBookInfo.LimitFaction > 0 and tbBookInfo.LimitFaction ~= me.nFaction then
	        return;
	    end

		return "itemtag_kezhuangbei";
	end;
	["RefineStone"] = function ( pItem )
		local nEquipPos = Item.tbRefinementStone:GetEquipPosByTemplateId( pItem.dwTemplateId )
		local pCurEquip = me.GetEquipByPos(nEquipPos)
		if not pCurEquip then
			return
		end
		local nRealLevel = KItem.GetItemExtParam(pItem.dwTemplateId, Item.tbRefinementStone.REFINE_STONE_PARAM_LEVEL)
		if nRealLevel <= pCurEquip.nRealLevel and pItem.nUseLevel <= me.nLevel  then
			if Item.tbRefinement:IsCanDoRefinementItemPos(nEquipPos) and Item.tbRefinement:CanRefinement(pCurEquip, pItem, false) then
				return "itemtag_kexilian";	-- 可洗练
			end
		end
	end;

}

tbGrid.tbUnidentifyClasses = {
	Unidentify = true,
	UnidentifyScriptItem = true,
	UnidentifyZhenYuan = true,
	UnidentWishItem = true,
	WorldCupUnidentMedal = true,
	WorldCupUnidentMedal4 = true,
	WorldCupUnidentMedal8 = true,
	UnidentifySeriesStone = true,
	UnidentifyRefineStone = true,
	UnidentifyJuexue = true,
	UnidentifyPiFeng = true,
}

function tbGrid:SetTagTip()
	if not self.tbControls.bShowTip then
		self.pPanel:SetActive("TagTip", false);
		return;
	end

	local szImage;
	if self.nItemId then
		local pItem = KItem.GetItemObj(self.nItemId);
		if pItem and self.tbFunTagTip[pItem.szClass] then
			szImage = self.tbFunTagTip[pItem.szClass](pItem);
		elseif pItem and pItem.IsEquip() == 1 then
			local pCurEquip = me.GetEquipByPos(pItem.nEquipPos)
			if not pCurEquip then
				if  pItem.nUseLevel <= me.nLevel then
					szImage = "itemtag_kezhuangbei";		-- 可装备
				end
			else
				if pCurEquip.dwId ~= self.nItemId then
					if pItem.nRealLevel > pCurEquip.nRealLevel and pItem.nUseLevel <= me.nLevel  then
						szImage = "itemtag_kezhuangbei";		-- 可装备
					else
						if Item.tbRefinement:IsCanDoRefinementItemPos(pItem.nEquipPos) and Item.tbRefinement:CanRefinement(pCurEquip, pItem, false) then
							szImage = "itemtag_kexilian";	-- 可洗练
						end
					end
				end
			end
		elseif pItem and self.tbUnidentifyClasses[pItem.szClass] then
			szImage = "itemtag_weijianding";	-- 未鉴定
		elseif pItem and Compose.EntityCompose:CheckIsCanCompose(me, pItem.dwTemplateId) then
			szImage = "itemtag_kehecheng";
		elseif pItem and pItem.szClass == "JuanZhou" then
			if Item:GetClass("JuanZhou"):CheckCanCommitInBag(pItem.dwTemplateId) then
				szImage = "itemtag_yiwancheng";
			end
		elseif pItem and pItem.szClass == "LockedWishItem" then
			szImage = "itemtag_fengyin";
		elseif pItem and pItem.szClass=="InscriptionItem" then
			if Furniture.MagicBowl:CanRefinement(pItem) then
				szImage = "itemtag_kexilian"
			end
		end
	end

	if szImage then
		self.pPanel:SetActive("TagTip", true)
		self.pPanel:Sprite_SetSprite("TagTip", szImage);
	else
		self.pPanel:SetActive("TagTip", false);
	end
end

function tbGrid:DefaultClick()
	Item:ShowItemDetail(self);
end


