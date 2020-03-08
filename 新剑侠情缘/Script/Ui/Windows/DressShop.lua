Require("Script/Ui/Windows/CommonShop.lua")

local tbUi = Ui:CreateClass("DressShop");
local tbCommonShop = Ui:GetClass("CommonShop");

tbUi.szMoneyType = "SilverBoard";

tbUi.szPage = "Dress"
tbUi.szAllSubType = "门派";

function tbUi:OnOpenEnd(szTabKey, nItemId)
    self.szRideActionName = "hst"
    self.szTabKey = szTabKey;
    self:InitShowTabs()
    
    self.nSubTabIndex = 0;
    self.tbSelectItem = nil;

    self:UpdateTabs();
    self:UpdateShopWares();

    self.pPanel:NpcView_Open("ShowRole", me.nFaction, me.nSex);
    self.pPanel:NpcView_SetScale("ShowRole", 0.9);

    
    self:ChangeFeatrue()
    self:UpdateRightPanel()

    local tbInfo = Gift:GetMailGiftInfo("WaiYiGift")
    local bShowSend = tbInfo and me.GetVipLevel() >= tbInfo.nVip or false
	if bShowSend then
		self.pPanel:SetActive("BtnTry1", true)
		self.pPanel:SetActive("BtnGift", true)
		self.pPanel:SetActive("BtnTry2", false)
	else
		self.pPanel:SetActive("BtnTry1", false)
		self.pPanel:SetActive("BtnGift", false)
		self.pPanel:SetActive("BtnTry2", true)
	end
	
    self:CloseTimer()
    self:UpdateTimer()
    self.nTimer = Timer:Register(Env.GAME_FPS , function ()
        self:UpdateTimer()
        return true
    end)

    self.pPanel:SetActive("BtnAdd", not Client:IsCloseIOSEntry())
end

function tbUi:InitShowTabs()
    local tbTypes = { } -- self.szAllSubType
    for nFactionId, v in pairs(Faction.tbFactionInfo) do
        local tbSexes = Player:GetFactionSexs(nFactionId)
        if #tbSexes == 1 then
            table.insert(tbTypes, v.szName)
        else
            table.insert(tbTypes, string.format("%s(%s)", v.szName, Player.SEX_NAME[Player.SEX_MALE]))
            table.insert(tbTypes, string.format("%s(%s)", v.szName, Player.SEX_NAME[Player.SEX_FEMALE]) )
        end
    end
    self.tbTypes = tbTypes
    
    
    local tbTabs = Lib:CopyTB(tbCommonShop.tbTabText[self.szPage]) 

    local tbDressWares = Shop:GetShopWares("Dress", nil,true)
    local tbHasTabs = {}
    for i,v in ipairs(tbDressWares) do
        if v.SubType then
            tbHasTabs[v.SubType] = 1;
        end
    end
    for i = #tbTabs, 1, -1 do
        local szTabKey = tbTabs[i]
        if not tbHasTabs[szTabKey] then
            table.remove(tbTabs, i)
        end
    end
    if not tbHasTabs[self.szTabKey]  then
        self.szTabKey = tbTabs[1]
    end

    self.tbTabs = tbTabs    
end

function tbUi:OnLoadResFinish()
    if self.tbPart then
        for nChangePart,v in pairs(self.tbPart) do
            if nChangePart == Npc.NpcResPartsDef.npc_part_horse then
                self.pPanel:NpcView_PlayAnimation("ShowRole", self.szRideActionName, 0.0, true);
                break;
            end
        end    
    end
end

function tbUi:OnTimerChangeFeatrue(tbChanePartParams, tbChanePartParamsEffect)
    if self.nTimerChangeFeatrue then
        Timer:Close(self.nTimerChangeFeatrue);
        self.nTimerChangeFeatrue = nil;
    end

    local tbNpcRes, tbEffectRes = me.GetNpcResInfo();
    local nViewHorseTemplate = nil;
    if tbChanePartParams and tbChanePartParamsEffect then
        self.tbPart = self.tbPart or {};
        self.tbPartEffect = self.tbPartEffect or {};
        for nChangePart, nWaiZhuanRes in pairs(tbChanePartParams) do
            self.tbPart[nChangePart] = nWaiZhuanRes;
            if nChangePart == Npc.NpcResPartsDef.npc_part_horse then
                nViewHorseTemplate = nWaiZhuanRes
            end
        end
        for nChangePart, nWaiZhuanResEffect in pairs(tbChanePartParamsEffect) do
            self.tbPartEffect[nChangePart] = nWaiZhuanResEffect;
        end
        
        if nViewHorseTemplate then
            self.tbPart = { [Npc.NpcResPartsDef.npc_part_horse] = nViewHorseTemplate };
            self.tbPartEffect = {};
        else
            self.tbPart[Npc.NpcResPartsDef.npc_part_horse] = nil;
        end
    else
        self.tbPart = {}
        self.tbPartEffect = {};
        self.nFixFaction = me.nFaction
        self.nSex = Player:Faction2Sex(self.nFixFaction, me.nSex);
    end


    if nViewHorseTemplate then
        local nNpcRes = Item:GetHorseShoNpc(nViewHorseTemplate)
        if nNpcRes then
            self.szRideActionName = KNpc.GetRideActionName(nNpcRes) or "hst";
            self.pPanel:SetActive("ShowRole", true);
            self.pPanel:NpcView_ShowNpc("ShowRole", nNpcRes);
            self.pPanel:NpcView_ChangePartRes("ShowRole", Npc.NpcResPartsDef.npc_part_weapon, 0);
            self.pPanel:NpcView_ChangePartRes("ShowRole", Npc.NpcResPartsDef.npc_part_head, 0);
            self.pPanel:NpcView_SetScale("ShowRole", 0.7);
        else
            self.pPanel:SetActive("ShowRole", false);
        end
    else
        local tbNpcRes, tbEffectRes;
        if self.nFixFaction == me.nFaction and self.nSex == me.nSex then
            tbNpcRes, tbEffectRes = me.GetNpcResInfo();
        else
            local nSex = Player:Faction2Sex(self.nFixFaction, self.nSex);
            local tbFactionInfo = KPlayer.GetPlayerInitInfo(self.nFixFaction, nSex)
            tbNpcRes, tbEffectRes = {}, {}
            tbNpcRes[0] = tbFactionInfo.nBodyResId;
            tbNpcRes[1] = tbFactionInfo.nWeaponResId;
            tbNpcRes[4] = tbFactionInfo.nHeadResId
            for i = 0, Npc.NpcResPartsDef.npc_res_part_count - 1 do
                tbNpcRes[i] = tbNpcRes[i] or 0;
                tbEffectRes[i] = 0;
            end
        end

        local tbFactionScale =  Ui:GetClass("ItemBox").tbFactionScale;
        local fScale = tbFactionScale[self.nFixFaction] or 1
        self.pPanel:SetActive("ShowRole", true);

        for nPartId, nResId in pairs(tbNpcRes) do
            local nCurResId = nResId
            if nPartId == Npc.NpcResPartsDef.npc_part_horse then
                nCurResId = 0;
            elseif self.tbPart[nPartId] then
                nCurResId = self.tbPart[nPartId];
            end

            self.pPanel:NpcView_ChangePartRes("ShowRole", nPartId, nCurResId);
        end
        for nPartId, nResId in pairs(tbEffectRes) do
            if self.tbPartEffect[nPartId] then
                nResId = self.tbPartEffect[nPartId]
            end
            self.pPanel:NpcView_ChangePartEffect("ShowRole", nPartId, nResId);
        end

        self.pPanel:NpcView_SetScale("ShowRole", fScale);
    end
    
end

function tbUi:ChangeFeatrue(tbChanePartParams,tbChanePartParamsEffect)
    if self.nTimerChangeFeatrue then
        Timer:Close(self.nTimerChangeFeatrue);
        self.nTimerChangeFeatrue = nil;
    end 
    self.nTimerChangeFeatrue = Timer:Register(1, self.OnTimerChangeFeatrue, self, tbChanePartParams,tbChanePartParamsEffect)
end

function tbUi:UpdateTimer()
    if self.szTabKey ~= "tabActShop" then
        return
    end

    local nNow = GetTime()
    local pScrollViewDress = self.ScrollViewDress1
    local Grid = pScrollViewDress.Grid;
    for i = 0, 15 do
        local itemObj = Grid["Item" .. i]
        if itemObj and itemObj.nEndTime then
            if itemObj.pPanel:IsActive("Title") then
                local nLeftTime = itemObj.nEndTime - nNow
                nLeftTime = nLeftTime < 0 and 0 or nLeftTime;
                itemObj.Title.pPanel:Label_SetText("Time", string.format("剩余时间 [ffff00]%s[-]", Lib:TimeDesc2(nLeftTime) ) )
            end
        end
    end
end

function tbUi:OnClose()
    self:CloseTimer()
    self.pPanel:NpcView_Close("ShowRole");
    if self.nTimerChangeFeatrue then
        Timer:Close(self.nTimerChangeFeatrue);
        self.nTimerChangeFeatrue = nil;
    end
end

function tbUi:CloseTimer()
    if self.nTimer then
        Timer:Close(self.nTimer)
        self.nTimer = nil
    end
end

function tbUi:UpdateTabs()
    for i=1,6 do
        local szTabKey = self.tbTabs[i]
        self.pPanel:SetActive("BtnTab" .. i, szTabKey and true or false)
        if szTabKey then
            self["BtnTab" .. i].pPanel:Label_SetText("LabelLight", Shop.tabUiKeyName[szTabKey])
            self["BtnTab" .. i].pPanel:Label_SetText("LabelDark", Shop.tabUiKeyName[szTabKey])
            self["BtnTab" .. i].pPanel:Toggle_SetChecked("Main", szTabKey == self.szTabKey)
        end
    end
end

function tbUi:UpdateRightPanel()
    -- 更新价格
    local szMoneyType = self.szMoneyType
    local szIcon, szIconAtlas = Shop:GetMoneyIcon(szMoneyType);
    self.pPanel:Sprite_SetSprite("CostMoneyIcon", szIcon, szIconAtlas);
    self.pPanel:Sprite_SetSprite("HasMoneyIcon", szIcon, szIconAtlas);

	self.pPanel:Label_SetText("TxtHaveMoney", me.GetMoney(szMoneyType));
	local tbSelectItem = self.tbSelectItem
	if not tbSelectItem then
			self.pPanel:Label_SetText("TxtCostMoney", 0);
            self.pPanel:SetActive("Type", false)
			return
	end
	local nCount = tbSelectItem.nCount;
	local nPrice = tbSelectItem.nPrice * nCount;
	if Shop:HasEnoughMoney(me, szMoneyType, tbSelectItem.nPrice, nCount) then
		self.pPanel:Label_SetColorByName("TxtCostMoney", "White");
	else
		self.pPanel:Label_SetColorByName("TxtCostMoney", "Red");
	end
	self.pPanel:Label_SetText("TxtCostMoney", nPrice);

    local nTargetWaiyi = self:CanPreViewTargetWaiyi()
    local bShowFactionButton = false
    if nTargetWaiyi then
        local tbBaseProp = KItem.GetItemBaseProp(nTargetWaiyi)
        if tbBaseProp.nFactionLimit == 0 then
            bShowFactionButton = true
        end
        local nPart = Item.tbChangeColor:GetChangePart(nTargetWaiyi)    
        if nPart == Npc.NpcResPartsDef.npc_part_horse then
            bShowFactionButton = false
        end
    end
    self.pPanel:SetActive("Type", bShowFactionButton)

    if not nTargetWaiyi then
        Item:ShowItemDetail({nTemplate = self.tbSelectItem.nTemplateId}, { x = 90, y = -1})
    end
end

function tbUi:OnClickItem()
    if not self.tbSelectItem then
        return
    end
    Item:ShowItemDetail({nTemplate = self.tbSelectItem.nTemplateId}, { x = 90, y = -1})
end

function tbUi:UpdateActShop(tbView)
    self:UpdateSelTypeName()
    self.pPanel:SetActive("ScrollViewDress1", true)
    self.pPanel:SetActive("ScrollViewDress2", false)
    self.pPanel:SetActive("ScrollViewDress3", false)

    local tbScrollViewData = tbCommonShop.GetWaresTimeSort(tbView)

    local nFaction, nSex = self:GetSubTypeSelFaction();

    local tbHeight = {};
    local fnSetItem = function (itemObj, index)
        local tbData = tbScrollViewData[index]
        local pPanel = itemObj.pPanel
        if tbData.nIndex then
            local tbSize = pPanel:Widget_GetSize("Title")
            tbHeight[index] = tbSize.y
            pPanel:SetActive("item1", false)
            pPanel:SetActive("item2", false)
            pPanel:SetActive("Title", true)
            itemObj.nEndTime = tbData.nEndTime
            
            local szName = Shop:GetActShopPartName(tbData.nStarTime, tbData.nEndTime) 
            if not szName then
                szName = "活动" .. Lib:Transfer4LenDigit2CnNum(tbData.nIndex)
            end
            itemObj.Title.pPanel:Label_SetText("Name", szName)

        else
            local tbSize = pPanel:Widget_GetSize("item1")
            tbHeight[index] = tbSize.y

            pPanel:SetActive("Title", false)
            for i=1,2 do
                local tbOneData = tbData[i]
                if tbOneData then
                    pPanel:SetActive("item" .. i, true)
                    tbCommonShop.fnSetWareItem(self, itemObj["item" .. i], tbOneData, nFaction, nSex)

                else
                    pPanel:SetActive("item" .. i, false)
                end
            end
        end
    end
    self.ScrollViewDress1:Update(#tbScrollViewData, fnSetItem);
    self.ScrollViewDress1:UpdateItemHeight(tbHeight);
    self:UpdateTimer();
end



function tbUi:UpdateOtherShop(tbView)

    self.pPanel:SetActive("ScrollViewDress1", false)


    self.pPanel:SetActive("ScrollViewDress2", false)
    self.pPanel:SetActive("ScrollViewDress3", true)
    
    self.tbAllView = tbView


    self:UpdateSelTypeWares() --默认是全部
end

function tbUi:UpdateSelTypeName()
    local nSubTabIndex = self.nSubTabIndex
    
    local szTypeName = self.tbTypes[nSubTabIndex] or self.szAllSubType


    self.pPanel:Label_SetText("TypeLabel", szTypeName)

end

function tbUi:UpdateSelTypeWares()
    self:UpdateSelTypeName()
    local nFaction, nSex = self:GetSubTypeSelFaction();
    
    local tbView = self.tbAllView;
    local pScrollView = self.ScrollViewDress3

    local fnSetItem = function (itemObj, index)
        for i=1,2 do
            local tbGrid = itemObj["item" .. i]
            local tbData = tbView[ (index - 1) * 2 + i ]
            if tbData then
                tbGrid.pPanel:SetActive("Main", true)
                tbCommonShop.fnSetWareItem(self, tbGrid, tbData, nFaction, nSex)
            else
                tbGrid.pPanel:SetActive("Main", false)
            end
        end
    end

    pScrollView:Update(math.ceil(#tbView / 2) , fnSetItem);
end



function tbUi:UpdateShopWares()
    local tbView  = Shop:GetShopWares(self.szPage, self.szTabKey);
    table.sort(tbView, function (item1, item2)
        return item1.nSort < item2.nSort;
    end);
    if self.szTabKey == "tabActShop" then
        self:UpdateActShop(tbView)        
    else
        self:UpdateOtherShop(tbView)
    end
end

function tbUi:OnSelTab(i)
    local szTabKey = self.tbTabs[i]
    if not szTabKey or szTabKey == self.szTabKey then
        return
    end
    self.szTabKey = szTabKey
    self.tbSelectItem = nil;
    self:UpdateShopWares()
    self:UpdateRightPanel()
end

function tbUi:CheckReOpenNpcView(nFaction, nSex)
    nSex = nSex or me.nSex
    if self.nFixFaction ~= nFaction or self.nSex ~= nSex then
        self.tbPart = {}
        self.tbPartEffect = {}
    end
    if self.nFixFaction ~= nFaction then
        self.pPanel:NpcView_Close("ShowRole");
        self.pPanel:NpcView_Open("ShowRole", nFaction, nSex);
        self.nFixFaction = nFaction 
    end
    self.nSex = Player:Faction2Sex(self.nFixFaction, nSex);
end

function tbUi:GetSubTypeSelFaction()
    local nFaction = me.nFaction;
    local nSex = me.nSex
    if self.nSubTabIndex and self.tbTypes then
        local szTypeName = self.tbTypes[self.nSubTabIndex]
        if szTypeName then
            local nFactionId = Faction:GetFactionIdByName(szTypeName)
            if nFactionId then
                nFaction = nFactionId
                nSex = Player:Faction2Sex(nFaction, nSex)
            else
                local szFactionName,szSex = string.match(szTypeName, "(.-)[\(](.-)[\)]")
                if szFactionName and szSex then
                    local nFactionId = Faction:GetFactionIdByName(szFactionName)
                    if nFactionId then
                        nFaction = nFactionId
                        local _nSex = Player:GetSexByName(szSex)
                        if _nSex then
                            nSex = _nSex
                        end
                    end

                end
            end
        end
    end
    return nFaction, nSex
end

function tbUi:CanPreViewTargetWaiyi()
    if not self.tbSelectItem then
        return
    end
    local nFaction = self:GetSubTypeSelFaction() ;
    local tbTargetWaiyis = Shop:CanPreViewTargetWaiyiListFromItemPack(self.tbSelectItem.nTemplateId, nFaction)
    return tbTargetWaiyis[1], tbTargetWaiyis
end

function tbUi:TryDress()
	local tbSelectItem = self.tbSelectItem
	if not tbSelectItem then
        me.CenterMsg("你没有选中外装")
		return
    end

    local nTargetWaiyi, tbTargetWaiyis = self:CanPreViewTargetWaiyi()
    if not nTargetWaiyi then
        me.CenterMsg("当前道具不能试穿")
        return
    end

    local nFaction, nSex = self:GetSubTypeSelFaction() ;
    local tbBaseProp = KItem.GetItemBaseProp(nTargetWaiyi)
    if tbBaseProp.nFactionLimit > 0  then
        nFaction = tbBaseProp.nFactionLimit
        nSex = Player:Faction2Sex(nFaction, nSex)
    end
    self:CheckReOpenNpcView(nFaction, nSex)
    local tbChanePartParams = {}
    local tbChanePartParamsEffect = {}
    for i,_nTargetWaiyi in ipairs(tbTargetWaiyis) do
        local nPart = Item.tbChangeColor:GetChangePart(_nTargetWaiyi)    
        local nRes,nEffectResId; 
        if nPart == Npc.NpcResPartsDef.npc_part_horse then
            nRes = _nTargetWaiyi;
        else
            nRes,nEffectResId = Item.tbChangeColor:GetWaiZhuanRes(_nTargetWaiyi, self.nFixFaction, self.nSex)
        end
        tbChanePartParams[nPart] = nRes
        if nEffectResId and nEffectResId ~= 0 then
            tbChanePartParamsEffect[nPart] = nEffectResId;
        end

    end
    

    
    self:ChangeFeatrue(tbChanePartParams,tbChanePartParamsEffect)
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

for i=1,6 do
    tbUi.tbOnClick["BtnTab" .. i] = function (self)
        self:OnSelTab(i)
    end
end

tbUi.tbOnClick.Type = function (self)
    if not self.tbTypes  then
        return
    end
     
    local fnSelCallBack = function (index)
        self.nSubTabIndex = index;
        self:TryDress()
        self:UpdateShopWares()
    end
    Ui:OpenWindowAtPos("SelectScrollView", 263, 32, self.tbTypes, fnSelCallBack)
end

tbUi.tbOnClick.BtnTry1 = function (self)
	self:TryDress()
end

tbUi.tbOnClick.BtnTry2 = function (self)
	self:TryDress()
end

tbUi.tbOnClick.BtnRefresh = function (self)
    self.nSubTabIndex = 0;
    self:UpdateShopWares()
    self:CheckReOpenNpcView(me.nFaction, me.nSex)
	self:ChangeFeatrue()
end

tbUi.tbOnClick.BtnBuy = function (self)
	if not self.tbSelectItem then
        me.CenterMsg("你没有选中物品");
        return;
    end

    local szMoneyType = self.tbSelectItem.szMoneyType;
    local nbuyCount   = self.tbSelectItem.nCount;
    local nTemplateId = self.tbSelectItem.nTemplateId;
    local nGoodsId = self.tbSelectItem.nGoodsId;

    if me.GetMoney(szMoneyType) < self.tbSelectItem.nPrice * nbuyCount then
    	local szMoneyName = Shop:GetMoneyName(szMoneyType)
    	Recharge:RequestBuyDressMoney(string.format("%s不足，", szMoneyName))
    	return
    end

    local bSuccess, szInfo = Shop:CanBuyGoodsWare(me, self.szPage, nGoodsId, nbuyCount);
    if not bSuccess then
        me.CenterMsg(szInfo);
        return;
    end

    Shop:TryBuyItem(false, self.szPage, nTemplateId, nGoodsId, nbuyCount, self.tbSelectItem.nPrice)
end

tbUi.tbOnClick.BtnGift = function (self)
	if not self.tbSelectItem then
        me.CenterMsg("你没有选中物品");
        return;
    end
    local nTemplateId = self.tbSelectItem.nTemplateId
    local tbInfo = Gift:GetMailGiftItemInfo(nTemplateId)
    if not tbInfo then
    	me.CenterMsg("该物品不能赠送")
        return 
    end

    if me.GetVipLevel()<tbInfo.tbData.nVip then
    	me.CenterMsg("不满足条件")
        return 
    end	
    local bSuccess, szInfo = Shop:CanBuyGoodsWare(me, self.szPage, self.tbSelectItem.nGoodsId, self.tbSelectItem.nCount);
    if not bSuccess then
        me.CenterMsg(szInfo);
        return;
    end
    Ui:OpenWindow("ShopGiftPanel", self.tbSelectItem)
end

tbUi.tbOnClick.BtnAdd = function (self)
	Recharge:RequestBuyDressMoney()
end

tbUi.tbOnDrag =
{
    ShowRole = function (self, szWnd, nX, nY)
        self.pPanel:NpcView_ChangeDir("ShowRole", -nX, true)
    end,

--    HorseView = function (self, szWnd, nX, nY)
--        self.pPanel:NpcView_ChangeDir("HorseView", -nX, true);
--    end,
}
