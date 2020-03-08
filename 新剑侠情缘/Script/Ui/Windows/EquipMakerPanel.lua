local tbUI = Ui:CreateClass("EquipMakerPanel")

tbUI.tbOnClick = 
{
    BtnClose = function(self)
        Ui:CloseWindow(self.UI_NAME)
    end,
    BtnMake = function(self)
    	if not self.tbCurSel or not self.bCanMake then
    		return
    	end
    	if Shop:MakeEquip(self.tbCurSel.nId) then
	    	self.bCanMake = false
    		self:SetResultItem(0)
	    end
    end,
    BtnSelect = function(self)
    	self:SetLeftState(not self.bShowEquips)
    end,
}

function tbUI:SetLeftState(bShowEquips)
	self.bShowEquips = bShowEquips
   	self.pPanel:ChangeScale("BtnSelectSprite", 1, bShowEquips and 1 or -1, 1)

   	self.ScrollViewItem1.pPanel:SetActive("Main", bShowEquips)
   	self.pPanel:SetActive("ScrollView", not bShowEquips)
end

function tbUI:RegisterEvent()
	local tbRegEvent = {
		{UiNotify.emNOTIFY_CHANGE_MONEY, self.RefreshMoney, self},
		{UiNotify.emNOTIFY_EQUIP_MAKE_RSP, self.OnEquipMade, self},
	}

	return tbRegEvent
end

function tbUI:OnEquipMade(nEquipId)
	self.pPanel:SetActive("dazaochenggong", false)
	local fnQHTime = self.pPanel:NpcView_PlayAnimation("ShowRole", "qh", 0.1, 1)
    if fnQHTime > 0 then
        if self.nTimerQH then
            Timer:Close(self.nTimerQH)
        end
        self.nTimerQH = Timer:Register( math.floor(Env.GAME_FPS * fnQHTime * 2 - 5) , function ()
            self.pPanel:NpcView_PlayAnimation("ShowRole", "st", 0.2, 1)            
            self.nTimerQH = nil
			local szEquipName = Item:GetItemTemplateShowInfo(nEquipId, me.nFaction, me.nSex)
		    me.CenterMsg(string.format("恭喜您打造了一件[FFFE0D]%s[-]", szEquipName))
		    self.pPanel:SetActive("dazaochenggong", true)
		    self.bCanMake = true

		    self:SetResultItem(nEquipId)
        end)
    end
end

function tbUI:SetResultItem(nItemId)
	local bValid = nItemId and nItemId>0
	self.pPanel:SetActive("FinalEquip", bValid)
	if bValid then
		self.Equipitemframe:SetItemByTemplate(nItemId, nil, me.nFaction)
	end
end

function tbUI:OnOpen(nHouseId)
	self.nHouseId = nHouseId
	self:InitUI()
	self.bCanMake = true
end

function tbUI:OnClose()
    self.pPanel:SetActive("ModelTexture", false)
    self.pPanel:NpcView_Close("ShowRole")
end

function tbUI:InitUI()
	self.pPanel:Label_SetText("Title", Kin.Def.BuildingName[self.nHouseId])
	self.tbQualities = Shop:GetEquipMakerQualities(self.nHouseId)
	self:InitSelectList()

	self.pPanel:SetActive("dazaochenggong", false)
	self.pPanel:SetActive("ModelTexture", true)
    self.pPanel:NpcView_Open("ShowRole")
    self.pPanel:NpcView_ShowNpc("ShowRole", 1124)
    self.pPanel:NpcView_SetScale("ShowRole", 0.9)
    self.pPanel:NpcView_ChangeDir("ShowRole", 180, false)

    self:SetLeftState(true)
    self.Equipitemframe.fnClick = self.Equipitemframe.DefaultClick
end

function tbUI:_GetQulityName(nQuality)
	for _,tb in ipairs(self.tbQualities) do
		if tb.nQuality==nQuality then
			return tb.szQualityName
		end
	end
	return nil
end

function tbUI:_IsQulityValid(nQuality)
	return not not self:_GetQulityName(nQuality)
end

function tbUI:_UpdateQualityList()
	for nQuality, pGrid in pairs(self.tbQualityGrids) do
		pGrid.pPanel:Toggle_SetChecked("Main", self.nCurQuality==nQuality)
	end
end

function tbUI:InitSelectList()
	self.tbQualityGrids = {}
	local nNextDay, nNextQuality = Shop:EquipMakerGetNextQualityInfo()
	local nRow = math.ceil((Shop.nEquipMakerQualityMax-Shop.nEquipMakerQualityMin+1)/2)
	self.ScrollView:Update(nRow, function(pGrid, nIdx)
		for i=1, 2 do
			local nQuality = Shop.nEquipMakerQualityMin+(nIdx-1)*2+i-1
			local pBtn = pGrid[string.format("BtnGrade%d", i)]
			self.tbQualityGrids[nQuality] = pBtn
			local bValid = self:_IsQulityValid(nQuality)
			pGrid.pPanel:SetActive(string.format("BtnGrade%d", i), bValid)
			pGrid.pPanel:SetActive(string.format("LimiteGrade%d", i), nQuality==nNextQuality)
			if bValid then
				local szName = self:_GetQulityName(nQuality)
				pBtn.pPanel:Label_SetText("Dark", szName)
				pBtn.pPanel:Label_SetText("Light", szName)
			end

			if nQuality==nNextQuality then
				pGrid.pPanel:Label_SetText(string.format("Name%d", i), nNextQuality.."阶")
				pGrid.pPanel:Label_SetText(string.format("LG%d", i), nNextDay.."天后开放")
			end
			pBtn.pPanel.OnTouchEvent = function()
				self:SelectQuality(nQuality)
    			self:SetLeftState(true)
			end
		end
	end)
	self:SelectQuality(self.tbQualities[1].nQuality)
end

function tbUI:SelectQuality(nQuality)
	self.nCurQuality = nQuality
	self.tbList = Shop:GetEquipMakerItems(self.nHouseId, nQuality)
	local nCount = #self.tbList
	self.tbItemGrids = {}
	self.ScrollViewItem1:Update(nCount, function(pGrid, nIdx)
		table.insert(self.tbItemGrids, pGrid)
		local tbItem = self.tbList[nIdx]
		local nId = Item:GetIdAfterIdentify(tbItem.nItem1Id) or tbItem.nItem1Id
		local tbInfo = KItem.GetItemBaseProp(nId)
		local szName = Item:GetItemTemplateShowInfo(tbItem.nItem1Id, me.nFaction, me.nSex)
		pGrid.pPanel:Label_SetText("Name", szName)
		pGrid.pPanel:Label_SetText("Level", tbInfo.nRequireLevel)
		pGrid.itemframe:SetItemByTemplate(tbItem.nItem1Id, nil, me.nFaction)
		pGrid.itemframe.fnClick = pGrid.itemframe.DefaultClick

		pGrid.pPanel.OnTouchEvent = function()
			self:SelectItem(nIdx)
		end
	end)
	self:SelectItem(1)

	local szName = self:_GetQulityName(nQuality)
	self.pPanel:Label_SetText("BtnSelectLabel", string.format("装备品阶·%s", szName))
	self:_UpdateQualityList()
end

function tbUI:SelectItem(nIdx)
	local tbSetting = self.tbList[nIdx]
	self.tbCurSel = tbSetting
	local tbItems = {}
	local nTotalRate = 0
	for i=1,3 do
		local nId = tbSetting[string.format("nItem%dId", i)]
		local nRate = tbSetting[string.format("nRate%d", i)]
		if nId and nRate and nId>0 and nRate>0 then
			table.insert(tbItems, {
				nId = nId,
				nRate = nRate,
			})
			nTotalRate = nTotalRate+nRate
		end
	end

	for i=1,3 do
		local tbItem = tbItems[i]

		self.pPanel:Label_SetText(string.format("BuildProbability%d", i), string.format("打造概率：%d%%", tbItem.nRate*100/nTotalRate))

		local pItemFrame = self[string.format("itemframe%d", i)]
		pItemFrame:SetItemByTemplate(tbItem.nId, nil, me.nFaction)
		pItemFrame.fnClick = pItemFrame.DefaultClick
	end

	local nPrice = Shop:GetEquipMakerPrice(me, tbSetting.nId)
	local szIcon, szAtlas = Shop:GetMoneyIcon(tbSetting.szMoneyType)
	self.pPanel:Sprite_SetSprite("CostMoneyIcon", szIcon, szAtlas)
	self.pPanel:Sprite_SetSprite("HaveMoneyIcon", szIcon, szAtlas)
	self.pPanel:Label_SetText("TxtCostMoney", nPrice)
	self.pPanel:Label_SetText("TxtHaveMoney", me.GetMoney(tbSetting.szMoneyType))

	for n, pGrid in pairs(self.tbItemGrids) do
		pGrid.pPanel:Toggle_SetChecked("Main", n==nIdx)
	end

	self:SetResultItem(0)
end

function tbUI:RefreshMoney()
	local tbSetting = self.tbList[1]
	self.pPanel:Label_SetText("TxtHaveMoney", me.GetMoney(tbSetting.szMoneyType))
end