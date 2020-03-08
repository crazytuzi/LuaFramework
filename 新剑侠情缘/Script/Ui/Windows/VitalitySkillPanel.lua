local tbUi = Ui:CreateClass("VitalitySkillPanel");

local ITEM_PER_LINE = 4;
local MIN_LINE_Right = 4;
local MIN_LINE_Left = 3;


function tbUi:OnOpen()
	local pCurEquip = me.GetEquipByPos(Item.EQUIPPOS_ZHEN_YUAN)
	if not pCurEquip then
		me.CenterMsg("您当前未装备真元")
		return 0;
	end
	self:Reset()
end

function tbUi:Reset()
	local pCurEquip = me.GetEquipByPos(Item.EQUIPPOS_ZHEN_YUAN)
	if not pCurEquip then
		return
	end
	local tbSkillInfo = Item:GetClass("ZhenYuan"):GetSkillAttribTip(pCurEquip)
	local nSkillID, nSkillLevel = unpack(tbSkillInfo)

	local tbIcon, szSkillName = FightSkill:GetSkillShowInfo(nSkillID);
	-- local tbSkillSetting = FightSkill:GetSkillSetting(nSkillID, nSkillLevel);
	self.pPanel:Sprite_SetSprite("SkillIcon", tbIcon.szIconSprite, tbIcon.szIconAtlas);
	local nCurMaxLevel = Item.tbZhenYuan:GetEquipMaxSkillLevel(pCurEquip.nLevel)
	self.pPanel:Label_SetText("Level", string.format("等级：%d/%d", nSkillLevel, nCurMaxLevel))

	local nCurExp = pCurEquip.GetIntValue(Item.tbZhenYuan.nItemKeySKillExp)
	local nNeedExp = Item.tbZhenYuan:GetSkillLevelUpNeedExp(nSkillLevel)
	self.nNeedExp = nNeedExp;
	self.nCurExp = nCurExp
	if nNeedExp > 0 then
		self.pPanel:Sprite_SetFillPercent("Bar", math.min(nCurExp / nNeedExp, 1))
		self.pPanel:Label_SetText("Exp", string.format("%d/%d", math.floor(nCurExp * Item.tbZhenYuan.nItemValueToExpParam), math.floor(nNeedExp * Item.tbZhenYuan.nItemValueToExpParam) ))	
	else
		self.pPanel:Sprite_SetFillPercent("Bar", 1)
		self.pPanel:Label_SetText("Exp", "已满级")
	end

	

	local tbAllZhenYuans = me.FindItemInBag("ZhenYuan")
	local tbRightItemList = {}
	for i, pItem in ipairs(tbAllZhenYuans) do
		if pItem.GetSingleValue() > 0 then
			table.insert(tbRightItemList, pItem)
		end
	end
	self.tbRightItemList = tbRightItemList; --由于都是不可叠加的，就直接诶按道具id来了

	self.tbLeftItemList = {};

	self:UpdateLeftAndRight()
end

function tbUi:UpdateLeftAndRight()
	self:UpdateRigtItemList()
	self:UpdateLeftItemList()
end


function tbUi:UpdateRigtItemList()
	local fnClick = function (itemObj)
		if itemObj.bCanAdd then
			local pCurEquip = me.GetEquipByPos(Item.EQUIPPOS_ZHEN_YUAN)
			local nCurMaxLevel = Item.tbZhenYuan:GetEquipMaxSkillLevel(pCurEquip.nLevel)
			local tbSkillInfo = Item:GetClass("ZhenYuan"):GetSkillAttribTip(pCurEquip)
			local nSkillID, nSkillLevel = unpack(tbSkillInfo)
			if nSkillLevel >= nCurMaxLevel then
				me.CenterMsg("当前已满级")
				return
			end

			if self.nNeedExp == 0 then
				me.CenterMsg("当前已不可再升级")
				return
			end
			if self.nCurExp + self.nTotalExp >= self.nNeedExp then
				me.CenterMsg("您已经放入足够多的真元了")
				return
			end
			self:OnSelItem(self.tbRightItemList, self.tbLeftItemList, itemObj.nItemIndex)
		end
	end

	local fnSetItem = function(tbItemGrid, index)
		local nStart = (index - 1) * ITEM_PER_LINE
		for i = 1, ITEM_PER_LINE do
			local pItem = self.tbRightItemList[nStart + i];
			local tbGrid = tbItemGrid:GetGrid(i)
			if pItem then
				tbGrid.bCanAdd = true; --MathRandom(10) > 5;
				tbGrid:SetItem(pItem.dwId );
				tbGrid.nItemIndex = nStart + i;
				tbGrid.fnClick = fnClick;
				tbGrid.fnLongPress = tbGrid.DefaultClick;
				tbGrid.pPanel:SetActive("Main", true)

				tbGrid.pPanel:SetActive("CDLayer", not tbGrid.bCanAdd);
			else
				tbGrid.nItemIndex = nil;
				tbGrid:Clear();
				tbGrid.pPanel:SetActive("Main", false)
			end
		end
	end

	self.ScrollView2:Update( math.max(math.ceil(#self.tbRightItemList / ITEM_PER_LINE), MIN_LINE_Right), fnSetItem);    -- 至少显示5行
end

function tbUi:OnSelItem(tbScrItems, tbTarItems, nItemIndex)
	local pMoveItem = tbScrItems[nItemIndex]
	if not pMoveItem then
		return
	end

	table.remove(tbScrItems, nItemIndex)
	table.insert(tbTarItems, pMoveItem)

	self:UpdateLeftAndRight();
end


function tbUi:UpdateLeftItemList()
	local fnClick = function (itemObj)
		self:OnSelItem(self.tbLeftItemList, self.tbRightItemList, itemObj.nItemIndex)
	end

    local fnSetItem = function(tbItemGrid, index)
	    local nStart = (index - 1) * ITEM_PER_LINE
	    for i = 1, ITEM_PER_LINE do
	        local pItem = self.tbLeftItemList[nStart + i];
        	local tbGrid = tbItemGrid:GetGrid(i)
	        if pItem then
	        	tbGrid:SetItem(pItem.dwId);
	        	tbGrid.nItemIndex = nStart + i;
	        	tbGrid.fnClick = fnClick;
	        	tbGrid.fnLongPress = tbGrid.DefaultClick;
			else
				tbGrid.nItemIndex = nil;
				tbGrid:Clear();
	        end
	    end
	end

    self.ScrollView1:Update( math.max(math.ceil(#self.tbLeftItemList / ITEM_PER_LINE), MIN_LINE_Left), fnSetItem);    -- 至少显示5行

    local pCurEquip = me.GetEquipByPos(Item.EQUIPPOS_ZHEN_YUAN)
	local nTotalExp = Item.tbZhenYuan:CalItemsTotalExp(self.tbLeftItemList, pCurEquip)
    self.pPanel:Label_SetText("TextPutIn", string.format("已放入的真元，总经验：%d", math.floor(nTotalExp * Item.tbZhenYuan.nItemValueToExpParam) ))
    self.nTotalExp = nTotalExp
end

function tbUi:OnSyncItem()
	self:Reset();
end

function tbUi:OnResult()
	self:Reset();
end

tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnLevelUp()
	if self.nTotalExp == 0 then
		me.CenterMsg("您并未放入任何真元!")
		return
	end
	local tbItemIds = {};
	for i,v in ipairs(self.tbLeftItemList) do
		table.insert(tbItemIds, v.dwId)
	end
	local bRet, szMsg = Item.tbZhenYuan:CheckCanSkillLevelUp(me, tbItemIds)
	if not bRet then
		me.CenterMsg(szMsg)
		return
	end
	RemoteServer.ZhenYuanSkillLevelUp(tbItemIds);
end

function tbUi.tbOnClick:SkillIcon()
	local tbZhenYuanSkillInfo = Item:GetClass("ZhenYuan"):GetZhenYuanSkillAttribTip(me)
	local nSkillId, nSkillLevel, nMaxSkillLevel = unpack(tbZhenYuanSkillInfo)
	local tbSubInfo = FightSkill:GetSkillShowTipInfo(nSkillId, nSkillLevel, nMaxSkillLevel);
	Ui:OpenWindow("SkillShow", tbSubInfo);
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
		{ UiNotify.emNOTIFY_SYNC_ITEM,			self.OnSyncItem },
		{ UiNotify.emNOTIFY_DEL_ITEM,			self.OnSyncItem },
		{ UiNotify.emNOTIFY_ZHEN_YUAN_MAKE,		self.OnResult },
    };

    return tbRegEvent;
end
