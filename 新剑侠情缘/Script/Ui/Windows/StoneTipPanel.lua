local tbUi = Ui:CreateClass("StoneTipsPanel");
tbUi.tbLevel =
{
	[1] = "初级",
	[2] = "中级",
	[3] = "高级",
}

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_WND_CLOSED, 		self.OnTipsClose},
	}

	return tbRegEvent;
end

function tbUi:OnOpen(nItemId, nTemplateId)
    self.Stone3.pPanel:SetActive("Number3", false)
    self.pPanel:SetActive("BtnGroup", false)
    self:SetItem(nItemId, nTemplateId)
end

function tbUi:SetItem(nItemId, nTemplateId)
	if not nTemplateId  and not nItemId then
        return;
    end

    local pItem;
    if nItemId then
        pItem = KItem.GetItemObj(nItemId)
        if not pItem then
            return;
        end
        nTemplateId = pItem.dwTemplateId;
    end

    local tbInfo = KItem.GetItemBaseProp(nTemplateId)
    if not tbInfo then
        return;
    end

    self.nTemplateId = nTemplateId
    self.nItemId = nItemId

    local szName, nIcon, nView, nQuality = Item:GetItemTemplateShowInfo(nTemplateId, me.nFaction, me.nSex);
    local szNameColor = Item:GetQualityColor(nQuality) or "White";

     if szName then
        szName = pItem and Item:GetDisplayName(pItem, szName) or szName;
        self.pPanel:Label_SetText("Name", szName);
        self.pPanel:Label_SetColorByName("Name", szNameColor);
    end

    self.Details_Item:SetItemByTemplate(nTemplateId)

    local nHaveNum  = me.GetItemCountInAllPos(nTemplateId) or 0;
    local szHaveNum = string.format("[92d2ff]拥有[-] %d [92d2ff]件", nHaveNum);
    self.pPanel:Label_SetText("Have", szHaveNum);

    local szClassName = tbInfo.szClass
    local tbClass = Item.tbClass[szClassName];

    self.pPanel:SetActive("Label1", false)
    self.pPanel:SetActive("Label2", false)
    self.pPanel:SetActive("Label3", false)

    local szConbineTip,szLevelTip,szProperty,szUnique

    if tbClass and tbClass.GetIntrol then
        szConbineTip,szLevelTip,szProperty,szUnique = tbClass:GetIntrol(nTemplateId);
    end

    if szConbineTip and szConbineTip ~="" then
        self.pPanel:SetActive("Label1", true)
        self.pPanel:Label_SetText("Label1", szConbineTip)
    end

     if szLevelTip and szLevelTip ~="" then
        self.pPanel:SetActive("Label2", true)
        self.pPanel:Label_SetText("Label2", szLevelTip)
    end

     if szProperty and szProperty ~="" then
        self.pPanel:SetActive("Label3", true)
        self.pPanel:Label_SetText("Label3", szProperty)
        self.pPanel:Label_SetColorByName("Label3", szNameColor);
    end

    szUnique = szUnique or ""
    self.pPanel:Label_SetText("ContentTip", szUnique)

    local szCombineDes = ""
    if tbClass and tbClass.CombineDes then
    	szCombineDes = tbClass:CombineDes(nTemplateId);
    end
    self.pPanel:Label_SetText("TipBottom",szCombineDes)

    local szConsumeTip = ""
    if tbClass and tbClass.GetIntroBottom then
       szConsumeTip = tbClass:GetIntroBottom(nTemplateId);
    end
    self.pPanel:Label_SetText("CostTip", szConsumeTip)


     local tbUseSetting;
     if tbClass.GetUseSetting then
        tbUseSetting = tbClass:GetUseSetting(nTemplateId, nItemId);
     end

     if tbUseSetting then
        if type(tbUseSetting.fnFirst) == "string" then
            tbUseSetting.fnFirst = self[tbUseSetting.fnFirst];
        end
        if type(tbUseSetting.fnSecond) == "string" then
            tbUseSetting.fnSecond = self[tbUseSetting.fnSecond];
        end
        if type(tbUseSetting.fnThird) == "string" then
            tbUseSetting.fnThird = self[tbUseSetting.fnThird];
        end

        self:SetButtonFunc(tbUseSetting.szFirstName, tbUseSetting.fnFirst, tbUseSetting.szSecondName, tbUseSetting.fnSecond, tbUseSetting.szThirdName, tbUseSetting.fnThird)
     end
     for i=1,3 do
     	self.pPanel:SetActive("Stone" ..i,false)
     	self["Stone" ..i].pPanel:SetActive("texiao_hunshihecheng",false)
     end
     local tbTemplateId = StoneMgr:GetStoneLevelQueue(nTemplateId)
     local nMyIndex
     for nIndex,nTId in ipairs(tbTemplateId) do
		if nIndex > 3 then
		    break
		end

     	if nTId == nTemplateId then
     		nMyIndex = nIndex
     	end
     	self.pPanel:SetActive("Stone" ..nIndex,true)
     	local itemObj = self["Stone" ..nIndex]
     	local szName, nIcon, nView, nQuality = Item:GetItemTemplateShowInfo(nTId, me.nFaction, me.nSex);
     	local szNameColor = Item:GetQualityColor(nQuality) or "White";
     	if nIcon then
     		 local szIconAtlas, szIconSprite, szExtAtlas, szExtSprite = Item:GetIcon(nIcon);
     		 self.pPanel:Sprite_SetSprite("Stone" ..nIndex,szIconSprite, szIconAtlas)
             if szExtAtlas and szExtAtlas ~= "" and szExtSprite and szExtSprite ~= "" then
                itemObj.pPanel:Sprite_SetSprite("Quality" .. nIndex, szExtSprite, szExtAtlas);
                itemObj.pPanel:SetActive("Quality" .. nIndex, true)
             else
                itemObj.pPanel:SetActive("Quality" .. nIndex, false)
             end
     	end
     	itemObj.pPanel:Label_SetText("Level" ..nIndex,self.tbLevel[nIndex] or "")
     	itemObj.pPanel:Label_SetColorByName("Level" ..nIndex, szNameColor);
     	itemObj.pPanel:Label_SetColorByName("Number" ..nIndex, szNameColor);                  -- 在界面写死
     end

     if nMyIndex then
     	self["Stone" ..nMyIndex].pPanel:SetActive("texiao_hunshihecheng",true)
     end

end

function tbUi:SetButtonFunc(szName1, func1, szName2, func2, szName3, func3)
    if not self.nItemId then
        return
    end

    if not szName1 and not szName2 and not szName3 then
        self.pPanel:SetActive("BtnGroup", false);
        return;
    end

    self.pPanel:SetActive("BtnGroup", true)
    if szName1 then
        self.func1 = func1;
        self.pPanel:SetActive("Btn1", true)
        self.pPanel:Button_SetText("Btn1", szName1)
    else
        self.pPanel:SetActive("Btn1", false)
    end

    if szName2 then
        self.func2 = func2;
        self.pPanel:SetActive("Btn2", true)
        self.pPanel:Button_SetText("Btn2", szName2)
    else
        self.pPanel:SetActive("Btn2", false)
    end

    if szName3 then
        self.func3 = func3;
        self.pPanel:SetActive("Btn3", true)
        self.pPanel:Button_SetText("Btn3", szName3)
    else
        self.pPanel:SetActive("Btn3", false)
    end
end


function tbUi:UseItem()
    if self.nItemId then
        RemoteServer.UseItem(self.nItemId);
    end

    if me.GetItemCountInAllPos(self.nTemplateId) > 1 then
        return;
    end
    Ui:CloseWindow(self.UI_NAME);
end

function tbUi:UseInset()
    Ui:CloseWindow(self.UI_NAME)
    local nEquipId;
    local tbPosType = StoneMgr:GetCanInsetPos(self.nTemplateId)
    if tbPosType and next(tbPosType) then
        local nPos = Item.EQUIPTYPE_POS[tbPosType[1]]
        local pEquip = me.GetEquipByPos(nPos)
        if pEquip then
            nEquipId = pEquip.dwId
        end
    end
    Ui:OpenWindow("StrengthenPanel", StoneMgr:IsCrystal(self.nTemplateId) and "Strengthen" or "Inset", nEquipId)
end

function tbUi:SellItem()
    if not self.nItemId then
        return
    end
    Shop:ConfirmSell(self.nItemId);
end

function tbUi:UseCombine()
    local nNextTemplateId = StoneMgr:GetNextLevelStone(self.nTemplateId);
    if not nNextTemplateId then
        return
    end

    local tbBaseInfo = KItem.GetItemBaseProp(nNextTemplateId)
    local tbPosType = StoneMgr:GetCanInsetPos(nNextTemplateId)
    if tbPosType then
        for i,nType in ipairs(tbPosType) do
            local nEquipPos = Item.EQUIPTYPE_POS[nType]
            if nEquipPos then
                local pEquip = me.GetEquipByPos(nEquipPos)
                if pEquip and tbBaseInfo.nLevel > pEquip.nInsetLevel then --因为现在是每件魂石只对应一个位置了
                    local fnYse = function ()
                        RemoteServer.OnCombine(self.nTemplateId, 1);
                    end
                    Ui:OpenWindow("MessageBox",
                      string.format("你当前的%s只能镶嵌%d级魂石，\n你确定要合成%d级魂石吗", Item.EQUIPPOS_NAME[nEquipPos],pEquip.nInsetLevel, tbBaseInfo.nLevel),
                     { {fnYse},{} },
                     {"确定", "取消"});
                    Ui:CloseWindow(self.UI_NAME);
                    return
                end
            end
        end
    end
    RemoteServer.OnCombine(self.nTemplateId, 1);
end

tbUi.tbOnClick = {}

tbUi.tbOnClick.Btn1 = function (self)
    if self.func1 then
        self.func1(self, self.nItemId);
         Ui:CloseWindow(self.UI_NAME)
    end
end

tbUi.tbOnClick.Btn2 = function (self)
    if self.func2 then
        self.func2(self, self.nItemId)
         Ui:CloseWindow(self.UI_NAME)
    end
end

tbUi.tbOnClick.Btn3 = function (self)
    if self.func3 then
        self.func3(self, self.nItemId)
         Ui:CloseWindow(self.UI_NAME)
    end
end

function tbUi:OnScreenClick(szClickUi)
    if szClickUi ~= "CompareTips" then
		Ui:CloseWindow(self.UI_NAME);
	end
end

function tbUi:OnTipsClose(szWnd)
	if szWnd == "CompareTips" then
		Ui:CloseWindow(self.UI_NAME);
	end
end
