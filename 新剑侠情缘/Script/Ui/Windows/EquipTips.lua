
local uiTips = Ui:CreateClass("EquipTips");

function uiTips:OnOpen(nItemId, nTemplateId)
	if not nTemplateId and not nItemId then
		return 0;
	end
	Ui:OpenWindow("BgBlackAll", 0.7, Ui.LAYER_NORMAL)
end

function uiTips:OnOpenEnd(nItemId, nTemplateId, nFaction, szOpt, tbSaveRandomAttrib, pAsyncData, nSex,pOrgEquip)
	self.tbOpenParam = {nItemId, nTemplateId, nFaction, szOpt, tbSaveRandomAttrib, pAsyncData, nSex,pOrgEquip}
	local bIsCompare = self.UI_NAME == "CompareTips"
	if type(pAsyncData) ~= "userdata" and type(pAsyncData) ~= "table" then --最后一个传nil会在初次加载时丢数据，因为有链接用这个格式就不改传数据形式了
		pAsyncData = nil;
	end
	nFaction = nFaction or me.nFaction
	nSex = nSex or me.nSex;

	local pItem, nValue;
	local szName, nIcon, nView, nQuality, nMaxAttribQuality;
	self.fnBtnClick = {}

	if nItemId then
		pItem = KItem.GetItemObj(nItemId)
		if not pItem then
			return;
		end
		nTemplateId = pItem and pItem.dwTemplateId or nTemplateId;
		szName, nIcon, nView = Item:GetDBItemShowInfo(pItem, nFaction, nSex)
		nQuality = pItem.nQuality
	else
		szName, nIcon, nView, nQuality = Item:GetItemTemplateShowInfo(nTemplateId, nFaction, nSex)
	end

	self.nItemId = nItemId
	self.nTemplateId = nTemplateId

	local tbInfo = KItem.GetItemBaseProp(nTemplateId)
	if not tbInfo then
		return;
	end

	--出售
	local nPrice, szMoneyType = Shop:GetSellSumPrice(me, nTemplateId, pItem and pItem.nCount or 1);
	self.nPrice = nPrice;
	self.szMoneyType = szMoneyType
	if szMoneyType and nPrice then
		self.pPanel:SetActive("SalePrice", true);
		self.pPanel:Label_SetText("TxtCoin", nPrice);
		local szMoneyIcon, szMoneyIconAtlas = Shop:GetMoneyIcon(szMoneyType);
		self.pPanel:Sprite_SetSprite("Ylicon", szMoneyIcon, szMoneyIconAtlas);
	else
		self.pPanel:SetActive("SalePrice", false);
	end


	--强化等级
	local nStrenghLevel;
	if szOpt == "PlayerEquip" or szOpt == "ViewOtherEquip" or pAsyncData then
		nStrenghLevel = Strengthen:GetStrengthenLevel(pAsyncData or me, pItem.nEquipPos)
	elseif szOpt == "JuexueEquip" then
		nStrenghLevel = JueXue:GetItemXiuLianLv(pItem)
	end
	if nStrenghLevel then
		self.pPanel:Label_SetText("TxtEnhLevel", "+" ..  nStrenghLevel);
		self.pPanel:SetActive("TxtEnhLevel", true);
	else
		self.pPanel:SetActive("TxtEnhLevel", false);
	end

	--图标
	if nView and nView ~= 0 then
		local szIconAtlas, szIconSprite = Item:GetIcon(nView);
		self.pPanel:SetActive("ItemLayer", true)
		self.pPanel:Sprite_SetSprite("ItemLayer", szIconSprite, szIconAtlas);
	else
		self.pPanel:SetActive("ItemLayer", false);
	end


	--等级限制与描述
	self.pPanel:Label_SetText("TxtLevelLimit", string.format("%d级", tbInfo.nRequireLevel));


	--属性
	local szClassName = tbInfo.szClass
	self.szClassName = szClassName
	local tbClass = Item.tbClass[szClassName];
	if (not tbClass) then
		tbClass = self.tbClass["default"];
	end

	local szRank = ""
	if tbClass.GetRankDesc then
		szRank = tbClass:GetRankDesc(nTemplateId)
	else
		szRank = string.format("%d阶", tbInfo.nLevel)
	end
	self.pPanel:Label_SetText("Rank", szRank)

	local szCustomDesc = ""
	if tbClass.GetCustomDescInTips then
		szCustomDesc = tbClass:GetCustomDescInTips(nItemId) or ""
	end
	self.pPanel:SetActive("LostKnowledge", true)
	self.pPanel:Label_SetText("LostKnowledge", szCustomDesc)

	local szEquipType = ""
	if tbClass.GetEquipTypeDesc then
		szEquipType = tbClass:GetEquipTypeDesc(nTemplateId)
	elseif Item.EQUIPTYPE_NAME[tbInfo.nItemType] then
		szEquipType = Item.EQUIPTYPE_NAME[tbInfo.nItemType]
	end
	self.pPanel:Label_SetText("TxtEquipType", szEquipType)

	local bEquiped = false
	local tbAttrib;
	if pItem then
		local pPlayer = pAsyncData or me;
		local bNotShowAll = bIsCompare; --看自己背包里的装备比较时是不带强化的，但是看别人的装备比较时是带强化的
		if  szOpt == "ViewOtherEquip" then
			bNotShowAll = false;
		end
		if pItem.nPos ~= Item.emITEMPOS_BAG and pItem.nPos ~= -1 then
			local pCurEquip = me.GetEquipByPos(pItem.nPos);
			if pCurEquip and pCurEquip.dwId == nItemId then
				bEquiped = true
			end
		end

		tbAttrib, nMaxAttribQuality = tbClass:GetTip(pItem, pPlayer, bNotShowAll);
		nValue = pItem.nValue;
		local tbEquips = pPlayer.GetEquips();
		local nFightPower = pItem.nFightPower;

		if szOpt == "RefineStone" then
			self.pPanel:SetActive("TxtFightPower", false)
		else
			if tbEquips[pItem.nEquipPos] and tbEquips[pItem.nEquipPos] == nItemId then
				if not bNotShowAll then
					nFightPower = nFightPower + Strengthen:GetStrenFightPower(pPlayer, pItem.nEquipPos) + StoneMgr:GetInsetFightPower(pPlayer, pItem.nEquipPos);
				end
			end
			if tbClass.GetOtherFightpower then
				nFightPower = nFightPower + tbClass:GetOtherFightpower(me, pItem)
			end
			self.pPanel:Label_SetText("TxtFightPower", "战力：".. tostring(nFightPower));
			self.pPanel:SetActive("TxtFightPower", true)
		end

		local nShowQuality = Item:GetEqipShowColor(pItem, bEquiped or (pPlayer == pAsyncData), pPlayer)
		if nShowQuality then
			nQuality = nShowQuality
		end

	else
		if not tbSaveRandomAttrib then
			tbSaveRandomAttrib = Item.tbRefinement:GetCustomAttri(nTemplateId)
		end
		tbAttrib, nMaxAttribQuality = tbClass:GetTipByTemplate(nTemplateId, tbSaveRandomAttrib, pOrgEquip)
		nValue = tbInfo.nValue
		local nFightPower = KItem.GetEquipBaseFightPower(nTemplateId)
--[[
		if pOrgEquip then --升阶操作的对比tip
			local nOldEquipLevel = pOrgEquip.nLevel
			if pOrgEquip.GetIntValue(Item.EQUIP_KEY_LAST_GOLD_LEVEL) > nOldEquipLevel then
				nOldEquipLevel = pOrgEquip.GetIntValue(Item.EQUIP_KEY_LAST_GOLD_LEVEL)
			end
			local tbRetModify = Item.GoldEquip:GetPlatinumSaveGoldAttr(pOrgEquip, Item.DetailType_Platinum, nOldEquipLevel, tbInfo.nLevel)
			 if tbRetModify and tbRetModify.nFightPower then
			 	nFightPower = nFightPower + tbRetModify.nFightPower
			 end
		end
]]

		local bHasRandomAttrib = false; -- bHasRandomAttrib 有非0值时则以随机属性进行计算
		for _, v in pairs(tbSaveRandomAttrib or {}) do
			if v ~= 0 then
				bHasRandomAttrib = true;
				break;
			end
		end

		if szOpt == "RefineStone" then
			self.pPanel:SetActive("TxtFightPower", false)
		else
			self.pPanel:SetActive("TxtFightPower", true)
			if bHasRandomAttrib then
				nFightPower = nFightPower + Item.tbRefinement:GetFightPowerFromSaveAttri(tbInfo.nLevel, tbSaveRandomAttrib, tbInfo.nItemType)
			end
			self.pPanel:Label_SetText("TxtFightPower", "战力：".. nFightPower );
		end
	end
	self:SetTips(tbAttrib or {})

	self.pPanel:SetActive("Equipped", bEquiped);

	local szIntro = tbInfo.szIntro
	if tbClass.GetCustomIntrol then
		szIntro = tbClass:GetCustomIntrol(pItem)
	end
	self.pPanel:Label_SetText("TxtIntro", szIntro);

--[[
	--吃掉升级经验
	local bShowEatAddExp = false
	if tbClass.GetEatAddExp then
		local nAddExp = tbClass:GetEatAddExp(pItem)
		if nAddExp and nAddExp > 0 then
			bShowEatAddExp = true
			self.pPanel:Label_SetText("TxtExperience", nAddExp)
		end
	end
	self.pPanel:SetActive("ExperienceEnhancement", bShowEatAddExp)
]]
	local szColor, szFrameColor, szAnimation, szAnimationAtlas, _, nGTopColorID, nGBottomColorID = Item:GetQualityColor(nMaxAttribQuality or 0)
	self.pPanel:Sprite_SetSprite("Color", szFrameColor);
	if szAnimation and szAnimation ~= "" and szAnimationAtlas ~= "" then
		self.pPanel:SetActive("LightAnimation", true);
		self.pPanel:Sprite_Animation("LightAnimation", szAnimation, szAnimationAtlas);
		local nEffect = Item:GetQualityEffect(nQuality)
		if  nEffect ~= 0 then
			self.pPanel:ShowEffect("LightAnimation", nEffect, 1)
		end
	else
		self.pPanel:SetActive("LightAnimation", false);
	end

	--名字
	if szName then
		self.pPanel:Label_SetText("TxtTitle", szName);
		if nGTopColorID ~= 0 and nGBottomColorID ~= 0 then
			local GTopColor = Ui.RepresentSetting.GetColorSet(nGTopColorID);
            local GTBottomColor = Ui.RepresentSetting.GetColorSet(nGBottomColorID);
            self.pPanel:Label_SetGradientByColor("TxtTitle", GTopColor, GTBottomColor);
            self.pPanel:Label_SetColor("TxtTitle",  255,  255, 255);
		else
			local szNameColor = szColor or "White";
			self.pPanel:Label_SetColorByName("TxtTitle", szNameColor);
		end

	end

	--星级
	local nStarLevel = Item:GetStarLevel(tbInfo.nItemType, nValue)
	local nBrightStar = math.ceil(nStarLevel / 2)
	for i = 1, 10 do
		if nBrightStar >= i then
			self.pPanel:SetActive("SprStar"..i, true)
			if (nBrightStar == i and nStarLevel % 2 == 1) then
				self.pPanel:Sprite_SetSprite("SprStar"..i, "Star_half")
			else
				self.pPanel:Sprite_SetSprite("SprStar"..i, "Star_01")
			end
		else
			self.pPanel:SetActive("SprStar"..i, false)
		end
	end

	--按钮
	local bShowButton = false;
	if szOpt and self.Option[szOpt] then
		if pItem and me.GetItemInBag(nItemId) then
			bShowButton = true
		elseif szOpt == "ViewUpgrade" then
			bShowButton = true
		end
	end
	if bShowButton then
		self.pPanel:SetActive("BtnGroup", true)
		local nIndex = 1;
		for _,tbButton in ipairs(self.Option[szOpt]) do
			local fnVisible, szBtnName, fnCallback, fnSowRedPoint,IsFifxPos = unpack(tbButton);
			local szButton = "Btn" .. nIndex
			if fnVisible == true or fnVisible(self) then
				self.pPanel:Button_SetText(szButton, szBtnName)
				self.pPanel:SetActive(szButton, true)
				self.fnBtnClick[szButton] = fnCallback;
				local bShowRed = fnSowRedPoint and fnSowRedPoint(self)
				self.pPanel:SetActive("BtnNew" .. nIndex, bShowRed)
				nIndex = nIndex + 1;
			elseif IsFifxPos then
				self.pPanel:SetActive(szButton, false)
				nIndex = nIndex + 1;
			end
		end

		for i = nIndex, 5 do
			local szButton = "Btn" .. i
			self.pPanel:SetActive(szButton, false);
			self.fnBtnClick[szButton] = nil;
		end
	else
		self.pPanel:SetActive("BtnGroup", false)
	end
end


function uiTips:SetTips(tbAttribs)
	local tbHeight = {};
	local fnSetItem = function (itemObj, nIndex)
		local tbDesc = tbAttribs[nIndex];
		local nHeight = itemObj:SetText(tbDesc, self);
		tbHeight[nIndex] = nHeight
		self.ScrollView:UpdateItemHeight(tbHeight);
	end

	self.ScrollView:Update(#tbAttribs, fnSetItem);
	self.ScrollView:UpdateItemHeight(tbHeight);
	self.ScrollView:GoTop();
	self:CheckShowDown()
end

function uiTips:CheckShowDown()
	self.pPanel:SetActive("down", not self.ScrollView.pPanel:ScrollViewIsBottom())
end

function uiTips:UseEquip()
	if not self.nItemId then
		return;
	end

	local bRet = Player:UseEquip(self.nItemId);
	if not bRet then
		return;
	end

	Ui:CloseWindow(self.UI_NAME);
end

function uiTips:UnuseEquip()
	if not self.nItemId then
		return;
	end
	local pItem = KItem.GetItemObj(self.nItemId)
	if not pItem then
		return;
	end
	Player:ClientUnUseEquip( pItem.nPos )
	Ui:CloseWindow(self.UI_NAME);
end

function uiTips:GetEquipPos(pItem)
	if pItem.szClass == "RefineStone" then
		return Item.tbRefinementStone:GetEquipPosByTemplateId(pItem.dwTemplateId)
	else
		return pItem.nEquipPos
	end
end

function uiTips:Refinement()
	if not self.nItemId then
		return;
	end
	local pItem = KItem.GetItemObj(self.nItemId);
	if not pItem then
		return;
	end
	local nEquipPos = self:GetEquipPos(pItem)
	local pCurEquip = me.GetEquipByPos(nEquipPos)
	if pCurEquip then
		Ui:OpenWindow("RefinementPanel", self.nItemId, pCurEquip.dwId);
		Ui:CloseWindow(self.UI_NAME);
	end

end

function uiTips:RefineAttriTypePF(  )
	if not self:CanRefineAttriTypePF() then
		return
	end
	Item.tbPiFeng:ClientReRandomAttriTypes(self.nItemId)
end

function uiTips:RefineAttriNumPF( )
	if not self:CanRefineAttriNumPF() then
		return
	end
	Ui:CloseWindow(self.UI_NAME)
	Ui:OpenWindow("CloakNumberRandomPanel", self.nItemId)
end

function uiTips:Enhance()
	if not self.nItemId then
		return;
	end

	local pItem = KItem.GetItemObj(self.nItemId)
	if not pItem then
		return;
	end

	Ui:OpenWindow("StrengthenPanel", "Strengthen", self.nItemId);
	Ui:CloseWindow(self.UI_NAME);
end

function uiTips:Inset()
	if not self.nItemId then
		return;
	end

	local pItem = KItem.GetItemObj(self.nItemId)
	if not pItem then
		return;
	end

	Ui:OpenWindow("StrengthenPanel", "Inset", self.nItemId);
	Ui:CloseWindow(self.UI_NAME);
end

function uiTips:Sell()
	if not self.nItemId then
		return;
	end

	Shop:ConfirmSell(self.nItemId)

	Ui:CloseWindow(self.UI_NAME);
end

function uiTips:Exchange( ... )
	if not self.nItemId then
		return;
	end

	local fnAgree = function (nItemId)
        RemoteServer.EquipExchange(nItemId);
    end

    local pItem = KItem.GetItemObj(self.nItemId);
	if not pItem then
		me.CenterMsg("装备不存在！");
		return ;
	end

	local bRet, szMsg = Item.tbEquipExchange:CanExchange(pItem.dwTemplateId, me)
	if not bRet then
		Ui:OpenWindow("MessageBox", szMsg,{{}},	{"确定"});
		return;
	end

	local bRet, nCost = Item.tbEquipExchange:GetCost(pItem.dwTemplateId)
	if not bRet then
		return
	end

    Ui:OpenWindow("MessageBox", string.format("收藏装备会变为外装，需要[FFFE0D]消耗%d银两[-]，装备上所有[FFFE0D]属性将会消失[-]。您确定收藏此装备吗？", nCost),
     { {fnAgree, self.nItemId},{} },
     {"同意", "取消"});

	Ui:CloseWindow(self.UI_NAME);
end

function uiTips:TrainAttrib()
	Ui:OpenWindow("RefinePanel", self.nItemId)
	Ui:CloseWindow(self.UI_NAME);
end

function uiTips:DoUpgrade()
	Ui:OpenWindow("EquipmentEvolutionPanel", "Type_Upgrade", self.nItemId)
	Ui:CloseWindow(self.UI_NAME);

end

function uiTips:DoEvolutionHorse()
	Ui:OpenWindow("EquipmentEvolutionPanel", "Type_EvolutionHorse", self.nItemId)
	Ui:CloseWindow(self.UI_NAME);
end

function uiTips:DoEvolutionPF( )
	Ui:OpenWindow("CloakUpgradePanel", self.nItemId)
	Ui:CloseWindow(self.UI_NAME);
end

function uiTips:LevelUpSKill()
	Ui:OpenWindow("VitalitySkillPanel")
	Ui:CloseWindow(self.UI_NAME)
end

function uiTips:RefineSkill()
	Item.tbZhenYuan:RequestRefineSkill(self.nItemId);
end

function uiTips:UnCompose()
	Compose.UnCompose:DoRequestUncompose(self.nItemId)
end

function uiTips:CanEvolutionPF( )
	if not self.nItemId then
		return false;
	end
	local pEquip = me.GetItemInBag(self.nItemId)
	if not  pEquip  then
		return false
	end
	if pEquip.szClass ~= "PiFeng" then
		return false
	end
	if not Item.GoldEquip:CanEvolutionTarItem(pEquip.dwTemplateId) then
		return false
	end
	return true
end

function uiTips:CanEvolutionHorse()
	if not self.nItemId then
		return false;
	end
	local pEquip = me.GetItemInBag(self.nItemId)
	if not  pEquip  then
		return false
	end
	if not pEquip.nEquipPos then
		return false
	end
	if not Item.tbHorseItemPos[pEquip.nEquipPos] then
		return false
	end

	if not Item.GoldEquip:CanEvolutionTarItem(pEquip.dwTemplateId) then
		return false
	end
	return true
end

function uiTips:CanUpgrade()
	if not self.nItemId then
		return false;
	end
	local pEquip = me.GetItemInBag(self.nItemId)
	if not  pEquip  then
		return false
	end
	local dwTemplateId = pEquip.dwTemplateId
	local tbSetting = Item.GoldEquip:GetUpgradeSetting(dwTemplateId)
	if not tbSetting then
		return false
	end
	local TarItem = tbSetting.TarItem
	local tbBaseInfo = KItem.GetItemBaseProp(TarItem)
	if me.nLevel < tbBaseInfo.nRequireLevel then
		return false
	end
	return true
end

function uiTips:CanTrainAtrri()
	if not self.nItemId then
		return false;
	end
	local pEquip = me.GetItemInBag(self.nItemId)
	if not  pEquip or pEquip.GetBaseIntValue(Item.EQUIP_VALUE_TRAIN_ATTRI_LEVEL) == 0 then
		return false
	end
	if self:CanUpgrade() then --现在最多4个按钮，能进化就不显示精炼了
		return false
	end
	return true
end

function uiTips:CanUseEquip()
	if not self.nItemId then
		return false;
	end

	return true;
end

function uiTips:CanEnhance()
	if not self.nItemId then
		return false;
	end

	return true;
end

function uiTips:CanRefineAttriTypePF( )
	if not self.nItemId then
		return false
	end
	local pItem = KItem.GetItemObj(self.nItemId);
	if not pItem then
		return false
	end
	if pItem.szClass ~= "PiFeng" then
		return false
	end
	return true
end

function uiTips:CanRefineAttriNumPF( )
	if not self.nItemId then
		return false
	end
	local pItem = KItem.GetItemObj(self.nItemId);
	if not pItem then
		return false
	end
	if pItem.szClass ~= "PiFeng" then
		return false
	end
	return true
end

function uiTips:CanRefinement()
	local bCanRefinement = false;
	if not self.nItemId then
		return false
	end
	local pItem = KItem.GetItemObj(self.nItemId);
	if not pItem then
		return false
	end
	local nEquipPos;
	if pItem.szClass == "PiFeng" then
		return false
	end
	if pItem.IsEquip() == 1 then
		nEquipPos = pItem.nEquipPos
	elseif pItem.szClass == "RefineStone" then
		nEquipPos = Item.tbRefinementStone:GetEquipPosByTemplateId( pItem.dwTemplateId )
	end
	if not nEquipPos then
		return false
	end

	local pCurEquip = me.GetEquipByPos(nEquipPos)
	if not pCurEquip then
		return false
	end
	return Item.tbRefinement:CanRefinement(pCurEquip, pItem, true);
end

function uiTips:CanSell()
	if self.nItemId and self.szMoneyType and self.nPrice  then
		return true;
	end

	return false;
end

function uiTips:CanRefineSkill()
	return Item.tbZhenYuan:CanRefineSkill(me, self.nItemId)
end

function uiTips:CanInset()
	if me.nLevel < StoneMgr.MinInsetRoleLevel then
		return false
	end

	local pItem = KItem.GetItemObj(self.nItemId);
	if not pItem then
		return false
	end
	if pItem.nHoleCount and pItem.nHoleCount <= 0 then
		return false
	end

	return true
end

function uiTips:CanStrengthen()
	if me.nLevel < Strengthen.OPEN_LEVEL then
		return false
	end

	local pItem = KItem.GetItemObj(self.nItemId);
	if not pItem then
		return false
	end
	local nEquipPos = KItem.GetEquipPos(pItem.dwTemplateId)
	if nEquipPos < 0 or nEquipPos >= Item.EQUIPPOS_MAIN_NUM then
		return false;
	end
	return true
end

function uiTips:CanUnuseEquip()
	if not self.nItemId then
		return
	end
	local pItem = me.GetItemInBag(self.nItemId)
	if not pItem then
		return
	end
	return true
end

function uiTips:CanExchange()

	local pItem = KItem.GetItemObj(self.nItemId);
	if not pItem then
		return false
	end

	local dwTemplateId = pItem.dwTemplateId
	return Item.tbEquipExchange:CanExchange(dwTemplateId, me)
end

function uiTips:CanLevelUpSKill()
	return Item.tbZhenYuan:CanSkillLevelUp(me, self.nItemId);
end

function uiTips:CanXiuLian()
	if not self.nItemId then
		return
	end

	local pItem = KItem.GetItemObj(self.nItemId)
	if not pItem then
		return false
	end
	local nAreaId = pItem.nCurEquipAreaId
	if not nAreaId then
		return false
	end
	local nLevel = JueXue:GetCurXiuLianLv(me, nAreaId)
	return JueXue:GetXiulianConsume(nLevel)
end


function uiTips:ShowEnhanceRedpoint()
	local pItem = KItem.GetItemObj(self.nItemId);
	if not pItem then
		return false
	end
	return Strengthen:CanStrengthen(me, pItem);
end

function uiTips:ShowInsetRedpoint()
	return StoneMgr:CheckInsetUpgradeFlag(self.nItemId)
end

function uiTips:ShowDoUpgradeRedpoint()
	local pItem = KItem.GetItemObj(self.nItemId);
	if not pItem then
		return false
	end
	return Item.GoldEquip:CanUpgrade(me, pItem)
end

function uiTips:ShowDoEvolutionHorseRed()
	local pItem = KItem.GetItemObj(self.nItemId);
	if not pItem then
		return false
	end
	return Item.GoldEquip:CanEvolution(me, pItem.dwId)
end

function uiTips:CanUnCompose()
	if not self.nItemId then
		return
	end
	local pItem = KItem.GetItemObj(self.nItemId);
	if not pItem then
		return false
	end
	return Compose.UnCompose:CanUnCompose(pItem.dwTemplateId)
end

function uiTips:XiuLian()
	if not self.nItemId then
		return
	end
	Ui:OpenWindow("CheatsOperationPanel", self.nItemId, "XiuLian")
	Ui:CloseWindow(self.UI_NAME);
end

function uiTips:CheckJueXueRP()
	if not self.nItemId then
		return
	end

	local pItem = KItem.GetItemObj(self.nItemId)
	if not pItem then
		return
	end
	local nAreaId = pItem.nCurEquipAreaId
	if not nAreaId then
		return
	end
	return JueXue:CheckCanXiuLian(me, nAreaId, true)
end

function uiTips:GetViewUpgradeParam(  )
	local nTemplateId = self.nTemplateId
	if not nTemplateId then
		return
	end
	local nEquipPos = KItem.GetEquipPos(nTemplateId)
	if not nEquipPos then
		return
	end
	local pCurEquip = me.GetEquipByPos(nEquipPos)
	if not pCurEquip then
		return
	end
	if not Item.GoldEquip.DetailTypeGoldUp[pCurEquip.nDetailType] then
		return
	end
	local tbItemBase = KItem.GetItemBaseProp(nTemplateId)
	local nMaxEquipLevel = Strengthen:GetEquipLevel( me.nLevel, pCurEquip)
	return tbItemBase.nLevel, pCurEquip.nLevel,nMaxEquipLevel,pCurEquip
end

function uiTips:CanViewUpgradePriew()
	local nTarLevel,nMyLevel,nMaxEquipLevel = self:GetViewUpgradeParam()
	if not nTarLevel or not nMyLevel or not nMaxEquipLevel then
		return
	end
	return nTarLevel - 1 > nMyLevel
end

function uiTips:CanViewUpgradeNext( )
	local nTarLevel,nMyLevel,nMaxEquipLevel = self:GetViewUpgradeParam()
	if not nTarLevel or not nMyLevel or not nMaxEquipLevel then
		return
	end
	return nTarLevel + 1 <= nMaxEquipLevel
end

function uiTips:ViewUpgradePriew( )
	local nTarLevel,nMyLevel,nMaxEquipLevel, pCurEquip = self:GetViewUpgradeParam()
	local nToLevel = nTarLevel - 1;
	--找到目标阶段的黄金白金装备
	local nToItemTemplateId = Item.GoldEquip:GetTemplateIdFromTypeAndLevel( pCurEquip.nDetailType,pCurEquip.nEquipPos, nToLevel)
	if not nToItemTemplateId then
		return
	end

	local nItemId, nTemplateId, nFaction, szOpt, tbSaveRandomAttrib, pAsyncData, nSex,pOrgEquip = unpack(self.tbOpenParam)
	nTemplateId = nToItemTemplateId;
	self:OnOpenEnd(nItemId, nTemplateId, nFaction, szOpt, tbSaveRandomAttrib, pAsyncData, nSex,pOrgEquip)
end

function uiTips:ViewUpgradeNext( )
	local nTarLevel,nMyLevel,nMaxEquipLevel, pCurEquip = self:GetViewUpgradeParam()
	local nToLevel = nTarLevel + 1;
	--找到目标阶段的黄金白金装备
	local nToItemTemplateId = Item.GoldEquip:GetTemplateIdFromTypeAndLevel( pCurEquip.nDetailType,pCurEquip.nEquipPos, nToLevel)
	if not nToItemTemplateId then
		return
	end
	local nItemId, nTemplateId, nFaction, szOpt, tbSaveRandomAttrib, pAsyncData, nSex,pOrgEquip = unpack(self.tbOpenParam)
	nTemplateId = nToItemTemplateId;
	self:OnOpenEnd(nItemId, nTemplateId, nFaction, szOpt, tbSaveRandomAttrib, pAsyncData, nSex,pOrgEquip)
end

uiTips.Option =
{
	ItemBox =
	{
		{ uiTips.CanUseEquip, 		"穿上", uiTips.UseEquip},
		{ uiTips.CanRefinement, 	"洗练", uiTips.Refinement},
		{ uiTips.CanExchange,		"收藏", uiTips.Exchange},
		{ uiTips.CanEvolutionHorse,	"升阶", uiTips.DoEvolutionHorse, uiTips.ShowDoEvolutionHorseRed},  --坐骑的升阶，和上面黄金装备不一样
		{ uiTips.CanSell,			"出售", uiTips.Sell},
		{ uiTips.CanRefineSkill,	"技能洗练", uiTips.RefineSkill};
		{ uiTips.CanUnCompose,		"拆分", uiTips.UnCompose},

	},
	PlayerEquip =
	{
		{ uiTips.CanUnuseEquip, 				"卸下", uiTips.UnuseEquip},
		{ uiTips.CanStrengthen, "强化", uiTips.Enhance, uiTips.ShowEnhanceRedpoint },
		{ uiTips.CanInset, 		"镶嵌", uiTips.Inset,	 uiTips.ShowInsetRedpoint },
		{ uiTips.CanTrainAtrri,	"精炼", uiTips.TrainAttrib},
		{ uiTips.CanUpgrade,	"升阶", uiTips.DoUpgrade, uiTips.ShowDoUpgradeRedpoint},
		{ uiTips.CanEvolutionHorse,	"升阶", uiTips.DoEvolutionHorse, uiTips.ShowDoEvolutionHorseRed},  --坐骑的升阶，和上面黄金装备不一样
		{ uiTips.CanLevelUpSKill,			"技能升级", uiTips.LevelUpSKill},
		{ uiTips.CanUnCompose,		"拆分", uiTips.UnCompose},
		{ uiTips.CanRefineAttriTypePF, 	"重铸", uiTips.RefineAttriTypePF},
		{ uiTips.CanRefineAttriNumPF, 	"淬炼", uiTips.RefineAttriNumPF},
		{ uiTips.CanEvolutionPF,	"升阶", uiTips.DoEvolutionPF},  --披风升阶
	},
	ViewUpgrade = {
		{ uiTips.CanViewUpgradePriew, 		"上一阶", uiTips.ViewUpgradePriew, false,true},
		{ uiTips.CanViewUpgradeNext, 		"下一阶", uiTips.ViewUpgradeNext,false, true},
	};
	InDifferBattle =
	{
		{ uiTips.CanUseEquip, 		"穿上", uiTips.UseEquip},
	},
	JuexueEquip =
	{
		{ uiTips.CanXiuLian, 				"修炼", uiTips.XiuLian, uiTips.CheckJueXueRP},
		{ uiTips.CanUnuseEquip, 			"卸下", uiTips.UnuseEquip},
	},
	RefineStone =
	{
		{ uiTips.CanRefinement, 	"洗练", uiTips.Refinement},
		{ uiTips.CanSell,			"出售", uiTips.Sell},
	},
}


function uiTips:OnButtonClick(szWnd)
	if self.fnBtnClick[szWnd] then
		self.fnBtnClick[szWnd](self)
	end
end

function uiTips:OnScreenClick(szClickUi)
	if szClickUi ~= "CompareTips" and szClickUi ~= "EquipTips" then
		Ui:CloseWindow(self.UI_NAME);
	end
end

function uiTips:OnTipsClose(szWnd)
	if szWnd == "CompareTips" or szWnd == "EquipTips" or szWnd == "StoneTipsPanel" or szWnd == "ItemTips" then
		Ui:CloseWindow(self.UI_NAME);
	end
end

function uiTips:OnClose()
	if Ui:WindowVisible("CompareTips") == 1 and Ui:WindowVisible("EquipTips") == 1 then
		return
	end
	Ui:CloseWindow("BgBlackAll")
end

function uiTips:OnResponseSell(bSuccess)
	if bSuccess then
		Ui:CloseWindow(self.UI_NAME)
	end
end

function uiTips:OnDelItem(nItemId)
	if nItemId == self.nItemId then
		Ui:CloseWindow(self.UI_NAME)
	end
end

uiTips.tbOnClick =
{
	Btn1 = uiTips.OnButtonClick,
	Btn2 = uiTips.OnButtonClick,
	Btn3 = uiTips.OnButtonClick,
	Btn4 = uiTips.OnButtonClick,
}

function uiTips:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_WND_CLOSED, 		self.OnTipsClose},
		{ UiNotify.emNOTIFY_SHOP_SELL_RESULT,   self.OnResponseSell},
		{ UiNotify.emNOTIFY_DEL_ITEM,			self.OnDelItem },

	}

	return tbRegEvent;
end


local tbEquipAttribItem = Ui:CreateClass("EquipAttribItem");

function tbEquipAttribItem:SetText(tbDesc, pParent)
	self.pParent = pParent
	local szText, nColor, szIcon, szAtlas, szText2, szStoneName, szEquipFrameColor,szExtAtlas, szExtSprite= unpack(tbDesc); --镶嵌有的有2条属性,szFrameColor在SetTips里设置
	local nStyle;
	if type(szText) == "table" then
		nStyle = 3;
	elseif not nColor then
		nStyle = 1;
		if Lib:Utf8Len(szText) > 20  then
			nStyle = 4; --换行的文本
		end
	elseif szIcon then
		nStyle = 2; --镶嵌描述
		if type(nColor) == "string" then
			nStyle = 5; --技能描述
		end
	else
		nStyle = 3;
	end

	local nHeight = 26;
	self.pPanel:SetActive("line1", true)
	self.pPanel:SetActive("line2", false)
	self.pPanel:SetActive("line3", false)
	self.pPanel:SetActive("line4", false)

	self.pPanel:ChangePosition("Text", 2, 0);
	if nStyle == 1 then
		--类别条
		self.pPanel:SetActive("TxtClass", true);
		self.pPanel:Label_SetText("TxtClass", szText);
		self.pPanel:SetActive("Text", false);
		self.pPanel:Label_SetGradientColor("Text", "Blue");
		self.pPanel:SetActive("icon", false);
	elseif nStyle == 2 then
		-- 带图标属性条
		local szColor, szFrameColor = Item:GetQualityColor(nColor);
		szFrameColor = szEquipFrameColor or szFrameColor
		if szText2 and szStoneName  then
			self.pPanel:SetActive("line1", false)
			self.pPanel:SetActive("line2", true)

			if szText ~= "" then
				szText = szStoneName .. "\n" .. szText
			else
				szText = szStoneName
			end

			if szText2 ~= "" then
				szText = szText .. "\n" .. szText2;
			end

			self.pPanel:Label_SetText("Text2", szText)
			-- self.pPanel:ChangePosition("Text2", 64, 0);
			self.pPanel:Label_SetColorByName("Text2", szColor or "White");
			self.pPanel:Sprite_SetSprite("Color", szFrameColor);

			self.pPanel:Sprite_SetSprite("ItemLayer", szIcon, szAtlas);

			if szExtAtlas and szExtAtlas ~= "" and szExtSprite and szExtSprite ~= "" then
				self.pPanel:Sprite_SetSprite("ItemLayer2", szExtSprite, szExtAtlas);
				self.pPanel:SetActive("ItemLayer2", true);
			else
				self.pPanel:SetActive("ItemLayer2", false);
			end

			nHeight = 74

		else
			self.pPanel:Label_SetText("Text", szText);
			self.pPanel:SetActive("Text", true);
			self.pPanel:SetActive("TextExt", false);
			self.pPanel:SetActive("TxtClass", false);
			self.pPanel:ChangePosition("Text", 34, 0);
			self.pPanel:Label_SetColorByName("Text", szColor or "White");
			self.pPanel:SetActive("icon", true);
			self.pPanel:Sprite_SetSprite("icon", szIcon, szAtlas);
		end
	elseif nStyle == 4 then
		self.pPanel:SetActive("line1", false)
		self.pPanel:SetActive("line3", true)
		szText = string.gsub(szText, "\\n", "\n")
		self.pPanel:Label_SetText("Text3", szText)
		local tbTextSize = self.pPanel:Label_GetPrintSize("Text3");
		nHeight =  tbTextSize.y

	elseif nStyle == 5 then
		self.pPanel:SetActive("line1", false)
		self.pPanel:SetActive("line4", true)
		self.pPanel:Sprite_SetSprite("SkillItem", szIcon, szAtlas);
		self.pPanel:Label_SetText("SkillName", szText)
		self.pPanel:Label_SetText("SkillLevel", nColor)
		local tbSize = self.pPanel:Widget_GetSize("SkillItem");
		nHeight =  tbSize.y ;
	else
		--属性条
		if type(szText) == "table" then
			self.pPanel:SetActive("Text", true);
			self.pPanel:SetActive("TextExt", true);

			self.pPanel:Label_SetText("Text", szText[1]);
			local szColor = Item:GetQualityColor(szText[2]);
			self.pPanel:Label_SetColorByName("Text", szColor or "White");

			self.pPanel:Label_SetText("TextExt", szText[3]);
			szColor = Item:GetQualityColor(szText[4]);
			self.pPanel:Label_SetColorByName("TextExt", szColor or "White");
		else
			self.pPanel:SetActive("Text", true);
			self.pPanel:SetActive("TextExt", false);
			self.pPanel:Label_SetText("Text", szText);
			local szColor = type(nColor) == "string" and nColor or Item:GetQualityColor(nColor);
			self.pPanel:Label_SetColorByName("Text", szColor or "White");
		end

		self.pPanel:SetActive("TxtClass", false);
		self.pPanel:SetActive("icon", false);
	end

	self.pPanel:SetActive("Main", true);
	self.pPanel:Widget_SetSize("Main", 392, nHeight);
	return nHeight
end

tbEquipAttribItem.tbOnDrag =
{
	Main = function (self, szWnd, nX, nY)
	end
}

tbEquipAttribItem.tbOnDragEnd =
{
	Main = function (self, szWnd, nX, nY)
		if not self.pParent or not self.pParent.CheckShowDown then
			return
		end
		self.pParent:CheckShowDown()
	end
}
