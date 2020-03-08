local tbUi    = Ui:CreateClass("ItemTips");

--目前只是魂石，水晶，未鉴定装备用这个页面

local tbItemClassSetting =
{
    ["Item"] = function (self, nItemId, nTemplateId, nFaction, nSex, nCount)
        self:SetItem(nItemId, nTemplateId, nFaction, nSex, nCount)
    end;
    ["Digit"] = function (self, szDigitalType, nCount)
        self:SetDigitalItem(szDigitalType, nCount);
    end;
    ["Skill"] = function (self, nSkillId, nSkillLevel)
        self:SetSkillItem(nSkillId, nSkillLevel);
    end;
    ["Partner"] = function (self, nPartnerId)
        self:SetPartner(nPartnerId)
    end;
    ["partner"] = function (self, nPartnerId)
        self:SetPartner(nPartnerId)
    end;
    ["ComposeValue"] = function (self, nSeqId)
        local nIcon, szTitle, szTips, nQuality = Compose.ValueCompose:GetShowInfo(nSeqId);
        local szIconAtlas, szIconSprite= Item:GetIcon(nIcon);
        self:SetOther({szName = szTitle, szIntro = szTips, bHideEffect = true, nQuality = nQuality}, {szAtlas = szIconAtlas, szSprite = szIconSprite});
    end;
    ["AddTimeTitle"] = function (self, nTitleId)
        local nIcon, szTitle, szTips, nQuality = self:GetTitleDes(nTitleId);
        local szIconAtlas, szIconSprite= Item:GetIcon(nIcon);
        self:SetOther({szName = szTitle, szIntro = szTips, nQuality = nQuality, bHideEffect = true}, {szAtlas = szIconAtlas, szSprite = szIconSprite});
    end;
    ["Other"] = function (self, tbInfo, tbIcon)
        self:SetOther(tbInfo, tbIcon)
    end;
    ["CollectClue"] = function (self, nItemTemplateId)
        self:SetCollectClueItem(nItemTemplateId)
    end;
}

function tbUi:InitPosInfo()
    local tbPosLabel1 = self.pPanel:GetPosition("Label1")
    self.POS_LB1_X = tbPosLabel1.x
    self.POS_LB1_Y = tbPosLabel1.y

    local tbPosLabel2 = self.pPanel:GetPosition("Label2")
    self.POS_LB2_X = tbPosLabel2.x
    self.POS_LB2_Y = tbPosLabel2.y

    self.HEIGHT_FROM = 106  --背景最低起始值
    self.HEIGHT_PART_1 = 116 --第一段tip的高度，
    self.HEIGHT_PART_3 = 140 ; --按钮区域的高度
    self.HEIGHT_TIP_BT = 40; --底部鉴定按钮的高度

    local tbSize = self.pPanel:Widget_GetSize("Bg")

    self.WIDTH_BG = tbSize.x
end

-- label2 是一定会显示，label1手动控制显不显示
function tbUi:OnOpen(szType, ...)
    if not self.POS_LB1_X then
        self:InitPosInfo()
    end


    self.szType = szType;
    local tbFuncSet = tbItemClassSetting[szType]
    assert(tbFuncSet)

    self.pPanel:SetActive("BtnGroup", false)
    self.pPanel:SetActive("TipBottom", false)
    self.pPanel:SetActive("Have", true)
    self.fnCenter = nil;
    self.fnLeft = nil;
    self.fnRight = nil;
    self.pPanel:Label_SetColorByName("Name", "White");

    tbFuncSet(self, ...)

    local bShowPart1 = self.pPanel:IsActive("Label1")
    if bShowPart1 then
        self.pPanel:ChangePosition("Label2", self.POS_LB2_X, self.POS_LB2_Y)
    else
        self.pPanel:ChangePosition("Label2", self.POS_LB1_X, self.POS_LB1_Y)
    end

    local tbSize = self.pPanel:Label_GetPrintSize("Label2")
    local nPrt2Height = tbSize.y + 25 --25是Label2背景的额外高度

    local nTotalHeght = self.HEIGHT_FROM + nPrt2Height
    if bShowPart1 then
        nTotalHeght  = nTotalHeght + self.HEIGHT_PART_1
    end
    if self.pPanel:IsActive("BtnGroup") then
        nTotalHeght = nTotalHeght + self.HEIGHT_PART_3
        if not self.pPanel:IsActive("TipBottom") then
            nTotalHeght = nTotalHeght - self.HEIGHT_TIP_BT
        end
        self.pPanel:ChangePosition("BtnGroup", 0, 330 - nTotalHeght)

    end
    self.nTotalHeght = nTotalHeght
    -- self.pPanel:Widget_SetSize("Bg", self.WIDTH_BG, nTotalHeght) --没 active 不会执行碰撞体的自动调整所以放OnOpenEnd 里了
end

function tbUi:OnOpenEnd()
    self.pPanel:Widget_SetSize("Bg", self.WIDTH_BG, self.nTotalHeght)
end

function tbUi:SetMainIntro(szIntro)
    szIntro = string.gsub(szIntro, "\\n", "\n") ;
    self.pPanel:SetActive("Label2", true);

    self.Label2:SetLinkText(szIntro);
    local tbSize = self.pPanel:Label_GetSize("Label2");

    if tbSize.y < 60 then
        if tbSize.y <= 20 then
            szIntro = szIntro .. "\n\n";
        elseif tbSize.y <= 40 then
            szIntro = szIntro .. "\n";
        end
        self.Label2:SetLinkText(szIntro);
    end
end

function tbUi:SetItem(nItemId, nTemplateId, nFaction, nSex, nCount)
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

    local tbFuncSet = tbItemClassSetting[tbInfo.szClass]
    if tbFuncSet then -- 是用自定义的
        tbFuncSet(self, nItemId, nTemplateId)
        return
    end


    self.nTemplateId = nTemplateId
    self.nItemId = nItemId
    self.nSex = nSex
    self.nFaction = nFaction

    local szClassName = tbInfo.szClass
    local tbClass = Item.tbClass[szClassName];

    --图标
    nSex = Player:Faction2Sex(nFaction or me.nFaction, nSex or me.nSex);
    local szName, _, _, nQuality = Item:GetItemTemplateShowInfo(nTemplateId, nFaction or me.nFaction, nSex);
    local szNameColor = Item:GetQualityColor(nQuality) or "White";
    if pItem then
        szName = Item:GetDisplayName(pItem, szName)
    end
    if tbClass and tbClass.GetDefineName then
        szName = tbClass:GetDefineName(pItem or {dwTemplateId = self.nTemplateId});
    end
    if szName then
        self.pPanel:Label_SetText("Name", szName);
        self.pPanel:Label_SetColorByName("Name", szNameColor);
    end

    self.Details_Item:SetItemByTemplate(nTemplateId, nil, nFaction, nSex)

    self:UpdateItemCount(nCount)

    --描述
    local szIntro1;
    if tbClass and tbClass.GetTip then
        szIntro1 = tbClass:GetTip(pItem or {dwTemplateId = self.nTemplateId});
    end

    if szIntro1 and  szIntro1 ~= "" then
        self.pPanel:SetActive("Label1", true)
        self.pPanel:Label_SetText("Label1", szIntro1)
        self.pPanel:Label_SetColorByName("Label1", szNameColor);
    else
        self.pPanel:SetActive("Label1", false)
    end

    local szIntro2 = tbInfo.szIntro
    local szIntroBottom;

    if tbClass then
        if tbClass.GetIntroBottom then
            szIntroBottom = tbClass:GetIntroBottom(nTemplateId);
        end

        if tbClass.GetIntrol then
            local szIntro = tbClass:GetIntrol(nTemplateId, self.nItemId);
            if szIntro and szIntro ~= "" then
                szIntro2 = szIntro;
            end
        end
    end
    self:SetSetButtonFuncByInfo(tbInfo)

    if szIntroBottom and szIntroBottom ~= "" then
        self.pPanel:SetActive("TipBottom", true)
        self.pPanel:Label_SetText("TipBottom", szIntroBottom)
    end

    if pItem then
        local szTimeOut = Item:GetItemTimeOut(pItem)
        if szTimeOut then
            szIntro2 = (szIntro2 or "").."\n有效期：\n"..szTimeOut
        end
    end

    self:SetMainIntro(szIntro2)
end

function tbUi:SetSetButtonFuncByInfo(tbInfo)
    local szClassName = tbInfo.szClass;
    if szClassName == "" then
        self:SetButtonFunc();
        return
    end
    local tbClass = Item.tbClass[szClassName];
    if not tbClass then
        self:SetButtonFunc();
        return
    end

    local tbUseSetting;
    if tbClass.GetUseSetting then
        tbUseSetting = tbClass:GetUseSetting(self.nTemplateId, self.nItemId);
    end

    if tbUseSetting then
        self:SetButtonFunc(tbUseSetting.szFirstName, tbUseSetting.fnFirst, tbUseSetting.szSecondName, tbUseSetting.fnSecond, tbUseSetting.bForceShow)
    elseif tbClass.OnUseAll and tbClass.OnUse then
        self:SetButtonFunc("全部使用", self.UseAll, "使用", self.UseItem)
    elseif tbClass.OnUse or tbClass.OnClientUse then
        self:SetButtonFunc("使用", self.UseItem)
    end
end

function tbUi:SetDigitalItem(szDigitalType, nValue)
    nValue = nValue or 0;

    local szName, szIntro;
    self.pPanel:SetActive("Have", false)
    self.Details_Item:SetDigitalItem(szDigitalType)

    if Shop:IsMoneyType(szDigitalType) then
        szName = Shop:GetMoneyName(szDigitalType);
        szIntro = Shop:GetMoneyDesc(szDigitalType);
    else--目前只有经验值是非货币的数值道具
        szName = "未知";
        szIntro = string.format("%s x%d", szName, nValue);
        if szDigitalType == "Exp" then
            szName  = "经验值";
            szIntro = string.format("获得%d点角色经验", me.TrueChangeExp(nValue));
        elseif szDigitalType == "BasicExp" then
            local nBaseExp = me.GetBaseAwardExp();
            nValue  = nValue * nBaseExp;
            szIntro = string.format("获得%d点角色经验", me.TrueChangeExp(nValue));
            szName  = "经验值";
        elseif szDigitalType == "FactionHonor" then
            szIntro = string.format("获得%d点门派荣誉\n[FFFE0D]（自动兑换门派竞技宝箱）[-]", nValue);
            szName  = "门派荣誉";
        elseif szDigitalType == "BattleHonor" or szDigitalType == "BattleHonor2" then
            szIntro = string.format("获得%d点战场荣誉\n[FFFE0D]（自动兑换战场宝箱）[-]", nValue);
            szName  = "战场荣誉";
        elseif szDigitalType == "VipExp" then
            szIntro = string.format("获得%d点Vip经验", nValue);
            szName  = "Vip经验值";
        elseif szDigitalType == "DomainHonor" then
            szIntro = string.format("获得%d点城战荣誉\n[FFFE0D]（每800点自动兑换城战宝箱）[-]", nValue);
            szName  = "城战荣誉";
        elseif szDigitalType == "CrossDomainHonor" then
            szIntro = string.format("获得%d点跨服城战荣誉\n[FFFE0D]（每800点自动兑换跨服城战宝箱）[-]", nValue);
            szName  = "跨服城战荣誉";
        elseif szDigitalType == "HSLJHonor" then
            szIntro = string.format("获得%d点华山论剑荣誉\n[FFFE0D]（每%s点自动兑换华山论剑宝箱）[-]", nValue, HuaShanLunJian.tbDef.nHSLJHonorBox);
            szName  = "华山论剑荣誉";
        elseif szDigitalType == "DXZHonor" then
            szIntro = string.format("获得%d点雪战荣誉\n[FFFE0D]（自动兑换雪战宝箱）[-]", nValue);
            szName  = "雪战荣誉";
        elseif szDigitalType == "IndifferHonor" then
            szIntro = string.format("获得%d点心魔幻境荣誉\n[FFFE0D]（自动兑换幻境宝箱）[-]", nValue);
            szName  = "心魔幻境荣誉";
        elseif szDigitalType == "LTZ_Honor" then
            szIntro = string.format("获得%d点跨服领土战荣誉\n[FFFE0D]（自动兑换领土战宝箱）[-]", nValue);
            szName  = "跨服领土战荣誉";
        end
    end

    self.pPanel:Label_SetText("Name", szName);
    self.pPanel:SetActive("Label1", false)
    self:SetMainIntro(szIntro)
end

function tbUi:SetSkillItem(nSkillId, nSkillLevel)
    local tbInfo = Item:GetSkillItemSetting(nSkillId, nSkillLevel);
    local szName, szIconSprite, szIconAtlas, szIntro, nQuality = unpack(tbInfo);
    local szColor = Item.tbQualityColor[nQuality or 0] or Item.DEFAULT_COLOR;

    self:UpdateItemCount()
    self.pPanel:SetActive("Label1", false)
    self:SetMainIntro(szIntro);
    self.pPanel:Label_SetText("Name", szName);
    self.Details_Item.pPanel:Sprite_SetSprite("ItemLayer", szIconSprite, szIconAtlas);
    self.Details_Item.pPanel:Sprite_SetSprite("Color", szColor);

    self.Details_Item.pPanel:SetActive("ItemLayer", true);
    self.Details_Item.pPanel:SetActive("LightAnimation", false);
end

function tbUi:SetPartner(nPartnerId)
    local szName, nLevel, nNpcTemplateId = GetOnePartnerBaseInfo(nPartnerId);
    local nIcon = KNpc.GetNpcShowInfo(nNpcTemplateId);
    local szIconAtlas, szIconSprite = Npc:GetFace(nIcon);

    self:UpdateItemCount()

    local szDesc = Partner:GetPartnerDesc(nPartnerId)
    self:SetMainIntro(szDesc)
    self.pPanel:SetActive("Label1", false)
    self.pPanel:Label_SetText("Name", szName or "");
    self.Details_Item.pPanel:SetActive("ItemLayer", true);
    self.Details_Item.pPanel:Sprite_SetSprite("ItemLayer", szIconSprite, szIconAtlas);

    local nValue   = Partner:GetPartnerValueByTemplateId(nPartnerId)
    local nQuality = Item:GetDigitalItemQuality("Partner", nValue)
    local szIcon   = Item.tbQualityColor[nQuality] or Item.DEFAULT_COLOR
    self.Details_Item.pPanel:Sprite_SetSprite("Color", szIcon)
end

function tbUi:SetOther(tbInfo, tbIcon)
    self.pPanel:Label_SetText("Name", tbInfo.szName or "什么鬼！");
    self.pPanel:SetActive("Label1",false)
    self.pPanel:SetActive("Have", false);
    self:SetMainIntro(tbInfo.szIntro or "")
    self.Details_Item.pPanel:SetActive("ItemLayer", true);
    self.Details_Item.pPanel:Sprite_SetSprite("ItemLayer", tbIcon.szSprite, tbIcon.szAtlas);
    self.Details_Item.pPanel:SetActive("LabelSuffix", false)
    if tbInfo.bHideEffect then
        self.Details_Item.pPanel:SetActive("LightAnimation", false);
    end

    self.pPanel:Label_SetColorByName("Name", "White");
    if tbInfo.nQuality then
        local szIcon   = Item.tbQualityColor[tbInfo.nQuality] or Item.DEFAULT_COLOR
        self.Details_Item.pPanel:Sprite_SetSprite("Color", szIcon)
        local szNameColor = Item:GetQualityColor(tbInfo.nQuality) or "White";
        self.pPanel:Label_SetColorByName("Name", szNameColor);
    end
end

function tbUi:SetCollectClueItem(nTemplateId)
    self.nTemplateId = nTemplateId
    self.nItemId = nTemplateId --强制显示按钮
    self.Details_Item:SetItemByTemplate(nTemplateId)
    local tbInfo = KItem.GetItemBaseProp(nTemplateId)
    self.pPanel:Label_SetText("Name", tbInfo.szName);
    self.pPanel:SetActive("Label1",false)
    local tbAct = Activity.CollectAndRobClue
    local nHaveNum  = tbAct:GetItemCount(nTemplateId)
    local szHaveNum = string.format("[92d2ff]拥有[-] %d [92d2ff]件", nHaveNum);
    self.pPanel:SetActive("Have", true);
    self.pPanel:Label_SetText("Have", szHaveNum)

    self:SetMainIntro(tbInfo.szIntro or "")
    self:SetSetButtonFuncByInfo(tbInfo)
end

function tbUi:SetButtonFunc(szName1, func1, szName2, func2, bForce)
    if not bForce and not self.nItemId then
        return
    end

    --如果原来没有或只有1个按钮时，如果能出售则自动添加出售按钮
    if not szName2 and not func2 and szName1 ~= "出售" and func1 ~= "SellItem"  then
        if Shop:CanSellWare(me, self.nItemId, 1) then
            local szOldName1, szOldFunc1 = szName1, func1
            szName1, func1 = "出售", "SellItem"
            szName2, func2 = szOldName1, szOldFunc1
        end
    end

    if not szName1 then
        self.pPanel:SetActive("BtnGroup", false);
        return;
    end

    if type(func1) == "string" then
        func1 = self[func1];
    end
    if type(func2) == "string" then
        func2 = self[func2];
    end

    self.pPanel:SetActive("BtnGroup", true)
    if not szName2 then
        self.pPanel:SetActive("BtnLeft", false)
        self.pPanel:SetActive("BtnRight", false)
        self.pPanel:SetActive("BtnCenter", true)
        self.fnCenter = func1
        self.pPanel:Button_SetText("BtnCenter", szName1)
        return
    end

    self.pPanel:SetActive("BtnLeft", true)
    self.pPanel:SetActive("BtnRight", true)
    self.pPanel:SetActive("BtnCenter", false)
    self.fnLeft = func1
    self.fnRight = func2
    self.pPanel:Button_SetText("BtnLeft", szName1)
    self.pPanel:Button_SetText("BtnRight", szName2)
end

function tbUi:UseItem()
    Item:ClientUseItem(self.nItemId)

    if me.GetItemCountInAllPos(self.nTemplateId) > 1 then
        return;
    end
    Ui:CloseWindow(self.UI_NAME);
end

function tbUi:UseChuangGongDan()
    Item:GetClass("ChuangGongDan"):UseChuangGongDan(self.nItemId)

    if me.GetItemCountInAllPos(self.nTemplateId) > 1 then
        return;
    end

    Ui:CloseWindow(self.UI_NAME);
end

function tbUi:ComposeEntityItem()
     if self.nTemplateId then
        local bRet, szMsg = me.CheckNeedArrangeBag();
        if bRet then
            me.CenterMsg(szMsg);
            return
        end
        local bRet,szMsg = Compose.EntityCompose:CheckIsComposeMaterial(self.nTemplateId);
        if not bRet then
            me.CenterMsg(szMsg);
            return
        end
        local bIsCan,szMsg,nTargetID = Compose.EntityCompose:CheckIsCanCompose(me,self.nTemplateId);
        if not bIsCan then
            me.CenterMsg(szMsg);
            return
        end
        RemoteServer.ComposeEntityItem(self.nTemplateId);
    end
end

function tbUi:UseAll()
    if not self.nItemId then
        return;
    end
    RemoteServer.UseAllItem(self.nItemId)
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

function tbUi:UseCombine()
    local nNextTemplateId = StoneMgr:GetNextLevelStone(self.nTemplateId);
    if not nNextTemplateId then
        return
    end

    local fnYes = function ( )
        local bRet,szMsg = StoneMgr:CanCombine(me, self.nTemplateId, 1)
        if not bRet then
            if szMsg then
                me.CenterMsg(szMsg, true)
            end
            return
        end

        RemoteServer.OnCombine(self.nTemplateId, 1);
    end

    local tbBaseInfo = KItem.GetItemBaseProp(nNextTemplateId)
    local tbPosType = StoneMgr:GetCanInsetPos(nNextTemplateId)
    if tbPosType then
        for i,nType in ipairs(tbPosType) do
            local nEquipPos = Item.EQUIPTYPE_POS[nType]
            if nEquipPos then
                local pEquip = me.GetEquipByPos(nEquipPos)
                if pEquip and tbBaseInfo.nLevel > pEquip.nInsetLevel then --因为现在是每件魂石只对应一个位置了
                    Ui:OpenWindow("MessageBox",
                      string.format("你当前的%s只能镶嵌%d级魂石，\n你确定要合成%d级魂石吗", Item.EQUIPPOS_NAME[nEquipPos],pEquip.nInsetLevel, tbBaseInfo.nLevel),
                     { {fnYes},{} },
                     {"确定", "取消"});
                    return
                end
            end
        end
    end

    fnYes()
end

function tbUi:SellItem()
    if not self.nItemId then
        return
    end
    Shop:ConfirmSell(self.nItemId);
end

function tbUi:UnCompose()
    if not self.nItemId then
        return
    end
    Compose.UnCompose:DoRequestUncompose(self.nItemId)
end


tbUi.tbOnClick = {}

tbUi.tbOnClick.BtnLeft = function (self)
    if self.fnLeft then
        if self.fnLeft(self, self.nItemId) == 1 then
            Ui:CloseWindow(self.UI_NAME)
        end
    end
end

tbUi.tbOnClick.BtnRight = function (self)
    if self.fnRight then
        if self.fnRight(self, self.nItemId) == 1 then
            Ui:CloseWindow(self.UI_NAME)
        end
    end
end

tbUi.tbOnClick.BtnCenter = function (self)
    if self.fnCenter then
        if self.fnCenter(self, self.nItemId) == 1 then
            Ui:CloseWindow(self.UI_NAME)
        end
    end
end

function tbUi:OnScreenClick(szClickUi)
    if szClickUi ~= "CompareTips" and szClickUi ~= "ItemCompareTips" then
        Ui:CloseWindow(self.UI_NAME);
    end
end

function tbUi:OnResponseCombine()
   local nHaveNum = me.GetItemCountInAllPos(self.nTemplateId) or 0;
   self.pPanel:Label_SetText("Have", string.format("[92d2ff]拥有[-] %d [92d2ff]件", nHaveNum));
   if not nHaveNum or nHaveNum == 0 then
        Ui:CloseWindow(self.UI_NAME)
   end
end

function tbUi:UpdateItemCount(nCount)
    if not self.nItemId and not self.nTemplateId then
        self.pPanel:SetActive("Have", false)
        return
    end
    local nHaveNum  = nCount or me.GetItemCountInAllPos(self.nTemplateId) or 0;
    local nMaterialId =  Furniture.Cook:GetBoxMaterialId(self.nTemplateId)
    if nMaterialId then
        nHaveNum = Furniture.Cook:GetMaterialCount(me, nMaterialId)
    end
    local szHaveNum = string.format("[92d2ff]拥有[-] %d [92d2ff]件", nHaveNum);
    self.pPanel:Label_SetText("Have", szHaveNum);
end

function tbUi:OnDelItem(nItemId)
    if self.nItemId == nItemId then
        Ui:CloseWindow(self.UI_NAME);
    end
end

function tbUi:UpdateItemOtherData()
    self:SetItem(self.nItemId, self.nTemplateId, self.nFaction, self.nSex)
end

function tbUi:UpdateItemData()
    self:UpdateItemCount();
    self:UpdateItemOtherData()
    local szIntro1 = "";
    local tbInfo = KItem.GetItemBaseProp(self.nTemplateId)
    local szClassName = tbInfo.szClass
    local tbClass = Item.tbClass[szClassName];
    local pItem = nil
     if self.nItemId then
        pItem = KItem.GetItemObj(self.nItemId)
    end
    if not pItem then return; end
    if tbClass and tbClass.GetTip then
        szIntro1 = tbClass:GetTip(pItem);
    end
    if szIntro1 and szIntro1 ~= "" then
        self.pPanel:SetActive("Label1", true)
        self.pPanel:Label_SetText("Label1", szIntro1)
        local szNameColor = Item:GetQualityColor(tbInfo.nQuality) or "White";
        self.pPanel:Label_SetColorByName("Label1", szNameColor);
    else
        self.pPanel:SetActive("Label1", false)
    end
end

function tbUi:GetTitleDes(nTitleId)
    local nIcon = 790                               -- 称号默认Icon
    if not nTitleId then
        return nIcon
    end
    local szTitle = "称号"
    local szTips = "领取获得称号"
    local nQuality

    local tbTitle = PlayerTitle:GetTitleTemplate(nTitleId)
    if tbTitle then
        szTitle = tbTitle.Name
        szTips = string.format("领取获得[FFFE0D]%s[-]称号", szTitle)
        nQuality = tbTitle.Quality
        if tbTitle.Icon > 0 then
            nIcon = tbTitle.Icon
        end
    end
    return nIcon, szTitle, szTips, nQuality
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_COMBINE_RESULT,         self.OnResponseCombine},
        { UiNotify.emNOTIFY_SYNC_ITEM,              self.UpdateItemData},
        { UiNotify.emNOTIFY_DEL_ITEM,               self.OnDelItem },
        { UiNotify.emNOTIFY_WND_CLOSED,             self.OnTipsClose},
    };

    return tbRegEvent;
end

function tbUi:OnClose()
    self.pPanel:ChangePosition("Main", 0, 0);
end

function tbUi:OnTipsClose(szWnd)
    if szWnd == "CompareTips" or szWnd == "ItemCompareTips" or szWnd == "ItemTips" then
        Ui:CloseWindow(self.UI_NAME);
    end
end