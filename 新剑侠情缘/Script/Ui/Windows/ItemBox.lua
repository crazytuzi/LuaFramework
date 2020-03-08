
local tbItemBox    = Ui:CreateClass("ItemBox");
local RepresentSetting = luanet.import_type("RepresentSetting");
tbItemBox.tbPlayStateAni =
{
    [1] =
    {
        nNextFrame = 50;
        nNextState = 2;
        tbEvent =
        {
            {"PlayAni", "shuiniao", "fly01", 0.1, 1, 1.0};
            {"PlayAniQueued", "shuiniao", "Take 001", 0.1, 2, 1.0};
        };
    };

    [2] =
    {
        nRandomFrame = 100;
        nNextFrame = 900;
        nNextState = 3;
        tbEvent =
        {
            {"RandomPlayAni", "shuiniao", {{"Take 001", 40, 10}, {"st01", 45, 1}, {"Take 001", 20, 10}, {"st02", 51, 1}, {"Take 001", 20, 10}, {"st03", 42, 1}}, 0.1, 1.0, 1};
        };
    };

    [3] =
    {
        nNextFrame = 200;
        nNextState = -1;
        tbEvent =
        {
            {"PlayAni", "shuiniao", "fly02", 0.1, 1, 1.0};
        };
    };
};

local tbToggle =
{
	TogNoCount = 0,
	TogNormal = 1,
    TogEquip = 2,
    TogPartnerEquip = 3,
    TogAll = 4,
    --TogHorse = 5,
}

local ITEM_PER_LINE = 4;
local MIN_LINE = 5;
--local nMountsAttribNum = 5;

--local tbNotMainToggle =
--{
--    [tbToggle.TogHorse] = 1;
--}

local ITEM_TYPE =
{
    [Item.PARTNER]   = tbToggle.TogPartnerEquip, -- 同伴装备
	[Item.EQUIP_WAIYI] = tbToggle.TogNoCount,
	[Item.EQUIP_WAI_WEAPON] = tbToggle.TogNoCount,
	[Item.EQUIP_WAI_HORSE] = tbToggle.TogNoCount,
    [Item.EQUIP_WAI_HEAD] = tbToggle.TogNoCount,
    [Item.EQUIP_WAI_BACK] = tbToggle.TogNoCount,
    [Item.EQUIP_WAI_BACK2] = tbToggle.TogNoCount,
    [Item.ITEM_JUE_YAO] = tbToggle.TogNoCount,
}

local ITEM_CLASS_TYPE =
{
	Stone = {tbToggle.TogEquip},
	equip = {tbToggle.TogEquip, tbToggle.TogNormal},
	horse = {tbToggle.TogEquip, tbToggle.TogNormal},
	horse_equip = {tbToggle.TogEquip, tbToggle.TogNormal},
	ZhenYuan = {tbToggle.TogEquip, tbToggle.TogNormal};
	--waiyi = {tbToggle.TogNoCount},
	Unidentify = {tbToggle.TogEquip, tbToggle.TogNormal},
	ComposeMeterial = "CheckCoposeable",
	EquipMeterial = "CheckCoposeable",
    NormalMeterial = "CheckCoposeable",
	MysteryStone = {tbToggle.TogEquip},
	TaskItem = {},
    EmptyItemClass = {},
    QuickBuyFromMS = {},
    JueYaoMaterial = {tbToggle.TogNormal},
    PiFeng = {tbToggle.TogEquip, tbToggle.TogNormal},
}

local _ITEM_CLASS_SORT =
{
	"XiuLianZhu" ;
    "CookMaterialBox" ;
    "AnniversaryVideo";
	"RechargeSumOpenBox" ;
    "RechargeSumOpenKey" ;
    "DongRiJiItem" ;
    "NewYearQAActItem" ;
    "DrinkToDreamItem" ;
    "XingYiDouZhuanItem" ;
    "BeautyPageantPaper" ;
    "BeautyPageantVote" ;
    "GoodVoicePaper" ;
    "GoodVoiceVote" ;
    "KinElectPaper" ;
    "KinElectVote" ;
    "BaiXiaoShengTuJianItem";
    "CollectAndRobClueBox" ;
    "EmptyXinDeBook" ;
    "XinDeBook" ;
    "TeacherStudentItem" ;--师徒信物
    "WeddingWelcome" ; --婚礼请柬
    "MarriagePaper" ;  --婚书
    "UnidentifyScriptItem" ;
    "ShengDianKeyItem" ;
    "UnidentifyPiFeng" ;
    "PiFeng" ;
    "ImpressionBook" ;
    "JuexueBook" ;
    "MibenBook" ;
    "DuanpianBook" ;
    "InscriptionItem" ;
}
local ITEM_CLASS_SORT = {};
for i,v in ipairs(_ITEM_CLASS_SORT) do
    ITEM_CLASS_SORT[v] = i;
end

local HIDE_CLASS = {
    JuexueBook = true;
    MibenBook = true;
    DuanpianBook = true;
}

local ITEM_CHANGE_SORT_FUN1 = {
    EquipMeterial = function (dwTemplateId)
        if Compose.EntityCompose:CheckIsCanCompose(me, dwTemplateId) then
            return 12;  --可合成材料对应sort 12
        end
    end;
};

local ITEM_CLASS_SORT_FUN =
{
	EquipMeterial = function (pItem)
		local nRet = Compose.EntityCompose:GetBagSort(pItem.dwTemplateId)
		return nRet
	end,
    JuexueBook = function (pItem)
        return -pItem.nLevel
    end,
    MibenBook = function (pItem)
        return -pItem.nLevel
    end,
    DuanpianBook = function (pItem)
        return -pItem.nLevel
    end,
}

local _SORT_KEY =
{
	Item.EQUIP_EX,			-- 未鉴定装备
	Item.EQUIP_WEAPON,      -- 武器
    Item.EQUIP_ARMOR,       -- 衣服
    Item.EQUIP_RING,        -- 戒指
    Item.EQUIP_NECKLACE,    -- 项链
    Item.EQUIP_AMULET,      -- 护身符
    Item.EQUIP_BOOTS,       -- 鞋子
    Item.EQUIP_BELT,        -- 腰带
    Item.EQUIP_HELM,        -- 头盔
    Item.EQUIP_CUFF,        -- 护腕
    Item.EQUIP_PENDANT,	    -- 腰坠
    Item.EQUIP_ZHEN_YUAN,   -- 真元
    Item.ITEM_SCRIPT,		-- 普通脚本道具
    Item.PARTNER,			-- 同伴装备
}

local SORT_KEY = {}
for nIdx, nType in ipairs(_SORT_KEY) do
	SORT_KEY[nType] = nIdx + 100;
end

local tbChangeTabPanel =
{
    ["BtnRole"] = "PlayerDetail";
    ["BtnAttribute"] = "AttributeDetail";
};

tbItemBox.tbOnClick =
{
    BtnRole = function (self)
        self:ChangeTabPanel("BtnRole");
    end,

    BtnAttribute = function (self)
        self:ChangeTabPanel("BtnAttribute");
    end,

    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,
    TogNormal = function(self, szName)
        self:UpdateItemList(tbToggle.TogNormal)
        self:SelectPageShow(szName);
    end,
    TogEquip = function(self, szName)
        self:UpdateItemList(tbToggle.TogEquip)
        self:SelectPageShow(szName);
    end,
    TogPartnerEquip = function(self, szName)
        self:UpdateItemList(tbToggle.TogPartnerEquip)
        self:SelectPageShow(szName);
    end,
    TogAll = function(self, szName)
        self:UpdateItemList(tbToggle.TogAll)
        self:SelectPageShow(szName);
    end,

    BtnEnhanceAttrib = function (self)
		Ui:OpenWindow("EquipStarAttribTips", "Enhance");
    end,
    BtnInsetAttrib = function (self)
		Ui:OpenWindow("EquipStarAttribTips", "Inset");
    end,

    Btndetail = function (self)
         Ui:OpenWindow("RoleAttrib");
    end,

    BtnFashion = function (self)
    	Ui:OpenWindow("WaiyiPreview")
    end,
    Mounts = function (self)
        Ui:OpenWindow("HorsePanel");
    end,
    Meridian = function (self)
        Ui:OpenWindow("JingMaiPanel");
    end,
    BtnClock = function ( self )
        local bChecked = self.pPanel:Button_GetCheck("BtnClock")
        self.pPanel:SetActive("BtnClockLabel2", not bChecked)
        local nHide = bChecked and 0 or 1;
        Item.tbChangeColor:ChangeResPartHide( me, Npc.NpcResPartsDef.npc_part_wing ,nHide)
        self:ChangeFeature()
    end;
}

tbItemBox.tbOnDrag =
{
    ShowRole = function (self, szWnd, nX, nY)
        self.pPanel:NpcView_ChangeDir("ShowRole", -nX, true)
    end,

--    HorseView = function (self, szWnd, nX, nY)
--        self.pPanel:NpcView_ChangeDir("HorseView", -nX, true);
--    end,
}

function tbItemBox:OnOpen(szPage, dwHightlightItem, szHighlightAni, szHighlightAniAtlas)
    self.dwHightlightItem = dwHightlightItem;
    self.szHighlightAni = szHighlightAni or "item1_"
    self.szHighlightAniAtlas = szHighlightAni or "UI/Atlas/ItemGrid/ItemGrid.prefab"

    self.pPanel:SetActive("texiaotiaozhan1", false)
    self.pPanel:SetActive("texiaotiaozhan2", false)
    self.pPanel:SetActive("texiao_TW", false)

    self.pPanel:SetActive("BtnEnhanceAttrib", me.nLevel >= 15)
    self.pPanel:SetActive("BtnInsetAttrib", me.nLevel >= 27)

    local bJingMaiOpen = JingMai:CheckOpen(me);
    self.pPanel:SetActive("Meridian", bJingMaiOpen);
    self.szPage = szPage or "TogNormal";
    self:CloseRoleAniTimer();
    self:ChangeTabPanel(self.szCurTagPanel or "BtnRole", true);
    self:UpdateItemType();
    self:UpdateItemList(tbToggle[self.szPage])
    self:UpdateEquip();
    self:ChangePlayerExp();

    self:UpdateTitleInfo();
    self:CheckCanUpgrade();

    self:CloseAllUiAniState();
    self.pPanel:SetActive("shuiniao", false);
    self.nStartExecuteTimer = Timer:Register(1, self.ExecuteUiAniState, self, 1)
    self:UpdateJingMainBtn()
end

function tbItemBox:UpdateJingMainBtn()
    self.pPanel:SetActive("MeridianUpgradeFlag", JingMai:CheckJingMaiRedPoint(me))
end


function tbItemBox:CloseAllUiAniState()
    if self.nUiStateTimer then
        Timer:Close(self.nUiStateTimer);
        self.nUiStateTimer = nil;
    end

    if self.nUiStateRandomTimer then
        Timer:Close(self.nUiStateRandomTimer);
        self.nUiStateRandomTimer = nil;
    end

    if self.nStartExecuteTimer then
        Timer:Close(self.nStartExecuteTimer);
        self.nStartExecuteTimer = nil;
    end
end

function tbItemBox:ExecuteUiAniState(nState)
    self:CloseAllUiAniState();

    local tbState = self.tbPlayStateAni[nState];
    if not tbState then
        return;
    end

    self.pPanel:SetActive("shuiniao", true);
    for _, tbInfo in ipairs(tbState.tbEvent) do
        local fnExecute = self["ExecuteOn"..tbInfo[1]];
        if fnExecute then
            Lib:CallBack({fnExecute, self, unpack(tbInfo, 2)})
        end
    end

    if tbState.nNextFrame > 0 then
        local nRandomFrame = MathRandom(tbState.nRandomFrame or 0);
        self.nUiStateTimer = Timer:Register(tbState.nNextFrame + nRandomFrame, self.ExecuteUiAniState, self, tbState.nNextState)
    end
end

function tbItemBox:ExecuteOnPlayAni(szWndName, stAni, fCrossFade, nWrapMode, fSpeed)
    self.pPanel:Animation_Play(szWndName, stAni, fCrossFade, nWrapMode, fSpeed);
end

function tbItemBox:ExecuteOnPlayAniQueued(szWndName, stAni, fCrossFade, nWrapMode, fSpeed)
    self.pPanel:Animation_PlayQueued(szWndName, stAni, fCrossFade, nWrapMode, fSpeed);
end

function tbItemBox:ExecuteOnRandomPlayAni(szWndName, tbAllAni, fCrossFade, fSpeed, nIndex)
    self.nUiStateRandomTimer = nil;
    local nIndex = (nIndex % (#tbAllAni) + 1);
    local tbAni = tbAllAni[nIndex];
    local nCount = MathRandom(tbAni[3]);
    local nTime = tbAni[2] * nCount;
    self.pPanel:Animation_Play(szWndName, tbAni[1], fCrossFade, 2, fSpeed);
    self.nUiStateRandomTimer = Timer:Register(nTime, self.ExecuteOnRandomPlayAni, self, szWndName, tbAllAni, fCrossFade, fSpeed, nIndex)
end

function tbItemBox:OnOpenEnd()
    self.pPanel:Toggle_SetChecked(self.szPage, true);
    self:SelectPageShow("TogNormal");
    self:ShowExAttribLevel()
    local bHide = Item.tbChangeColor:IsResPartHide( me, Npc.NpcResPartsDef.npc_part_wing )
    self.pPanel:Toggle_SetChecked("BtnClock",not bHide )
    self.pPanel:SetActive("BtnClockLabel2", bHide)
end

function tbItemBox:ChangeTabPanel(szCurBtn, bFirst)
    if not bFirst then
        if self.szCurTagPanel == "BtnRole" then
            self.pPanel:NpcView_Close("ShowRole");
--        elseif self.szCurTagPanel == "BtnMounts" then
--            self.pPanel:NpcView_Close("HorseView");
        end
    end

    self.szCurTagPanel = szCurBtn;
    for szBtn, szPanel in pairs(tbChangeTabPanel) do
        if szBtn ~= szCurBtn then
            self.pPanel:SetActive(szPanel, false);
        else
            self.pPanel:SetActive(szPanel, true);
        end
    end

    if self.szCurTagPanel == "BtnRole" then
        self.pPanel:NpcView_Open("ShowRole", me.nFaction,me.nSex);
        self.pPanel:NpcView_UseDynamicBone("ShowRole", true);
        self:ChangeFeature();
--    elseif self.szCurTagPanel == "BtnMounts" then
--        self.pPanel:NpcView_Open("HorseView");
    elseif self.szCurTagPanel == "BtnAttribute" then
        self.AttributeDetail:OnOpen();
    end
end

function tbItemBox:CheckCanUpgrade()
    local tbEquip = me.GetEquips();
    local tbStrengthen = me.GetStrengthen();
    for i = 0, Item.EQUIPPOS_MAIN_NUM  - 1 do
        local bCanUpgrade = false
        local nItemId = tbEquip[i]
        local nStrenLevel;
        if nItemId then
            bCanUpgrade = Strengthen:CanEquipUpgrade(nItemId)
            nStrenLevel = tbStrengthen[i + 1] > 0 and tbStrengthen[i + 1] or nil;
        end
        self.pPanel:SetActive("UpgradeFlag" .. i,  bCanUpgrade)
        self.pPanel:Label_SetText("StrengthenLevel" .. i, nStrenLevel  and "+" .. nStrenLevel or "")
    end
    local bCanUpgrade = Item.GoldEquip:IsShowHorseUpgradeRed(me)
    self.pPanel:SetActive("UpgradeFlag10",  bCanUpgrade)

    local bCanUpgrade = Item.GoldEquip:IsShowPiFengUpgradeRed(me)
    self.pPanel:SetActive("UpgradeFlag81",  bCanUpgrade)
end

function tbItemBox:ShowExAttribLevel()
	-- 更新强化、镶嵌额外属性
    local bChange = false;
    local tbLastShowExAttribLevel = Client:GetUserInfo("LastShowExAttribLevel")
    if me.nEnhExIdx then
        local tbSetting = Strengthen:GetEnhExAttrib(me.nEnhExIdx)
        self.pPanel:Label_SetText("EnhAttribInfo",  tostring(me.nEnhExIdx))
        self.pPanel:Button_SetSprite("BtnEnhanceAttrib", tbSetting.Img)

        if Ui.UiManager.GetTopPanelName() == self.UI_NAME and tbSetting.EnhLevel ~= tbLastShowExAttribLevel.EnhLevel then
            bChange = true
            tbLastShowExAttribLevel.EnhLevel = tbSetting.EnhLevel;
            self.pPanel:SetActive("texiao_TW", true)
            self.pPanel:PlayUiAnimation("Role&Bagpannle_qianghua", false, false, {"self.pPanel:SetActive('texiaotiaozhan1', true)", "self:ShowLabelScale('EnhAttribInfo')"})
        end
    else
        self.pPanel:Label_SetText("EnhAttribInfo",  "0")
    end
    if me.nInsetExIdx then
        local tbSetting = StoneMgr:GetInsetExAttrib(me.nInsetExIdx)
        self.pPanel:Label_SetText("InsetAttribInfo",  tostring(me.nInsetExIdx))
        self.pPanel:Button_SetSprite("BtnInsetAttrib", tbSetting.Img)

        if Ui.UiManager.GetTopPanelName() == self.UI_NAME and tbSetting.StoneLevel ~= tbLastShowExAttribLevel.StoneLevel then
            bChange = true
            tbLastShowExAttribLevel.StoneLevel = tbSetting.StoneLevel;

            self.pPanel:SetActive("texiao_TW", true)
            self.pPanel:PlayUiAnimation("Role&Bagpannle_qianghua", false, false, {"self.pPanel:SetActive('texiaotiaozhan2', true)", "self:ShowLabelScale('InsetAttribInfo')"})
        end
    else
        self.pPanel:Label_SetText("InsetAttribInfo",  "0")
    end


    if bChange then
        Client:SaveUserInfo();
    end
end

function tbItemBox:ShowLabelScale(szAttribInfo)
    Timer:Register(1, function ( ... )
        self[szAttribInfo].pPanel:PlayUiAnimation("EnhanceLabelScale", false, false, {});
    end)
    self.pPanel:SetActive("texiao_TW", false)
    self.pPanel:SetActive('texiaotiaozhan1', false)
    self.pPanel:SetActive('texiaotiaozhan2', false)
end



function tbItemBox:SelectPageShow(szBtnName)
    -- for szName, nType in pairs(tbToggle) do
    --     if not tbNotMainToggle[nType] then
    --         self[szName].pPanel:SetActive("LabelLight", szBtnName == szName);
    --         self[szName].pPanel:SetActive("Label", szBtnName ~= szName);
    --     end
    -- end
end

function tbItemBox:UpdateTitleInfo()
    PlayerTitle:SetTitleLabel(self, "Title");
end

function tbItemBox:CheckChangePifengReq(  )
    if self.pPanel:IsActive("BtnClock") then
        local bHide = Item.tbChangeColor:IsResPartHide( me, Npc.NpcResPartsDef.npc_part_wing )
        local bCheck = self.pPanel:Button_GetCheck("BtnClock")
        if bHide == bCheck  then
            RemoteServer.PiFengReq("HidePiFeng", not bCheck)
        end
    end
end

function tbItemBox:OnClose()
    if self.szCurTagPanel == "BtnRole" then
        self.pPanel:NpcView_Close("ShowRole");
    elseif self.szCurTagPanel == "BtnMounts" then
        self.pPanel:NpcView_Close("HorseView");
    end

    self:CloseRoleAniTimer();

    self:CloseAllUiAniState();

    if self.nTimerFeature then
        Timer:Close(self.nTimerFeature);
        self.nTimerFeature = nil;
    end
    self:CheckChangePifengReq();
end


function tbItemBox:ChangePlayerExp()
    --local fExpPer = me.GetExp() / me.GetNextLevelExp();
    --self.pPanel:ProgressBar_SetValue("Exstrip", fExpPer);
end

function tbItemBox:UpdateEquip()
    local tbEquip = me.GetEquips(1);
	self.tbShowEquip = {};
    for i = 0, Item.EQUIPPOS_MAIN_NUM - 1 do
        local tbEquipGrid = self["Equip"..i]
        tbEquipGrid.nEquipPos = i;
        tbEquipGrid.szItemOpt = "PlayerEquip"
        tbEquipGrid.fnClick = tbEquipGrid.DefaultClick;
        if i == Item.EQUIPPOS_RING and tbEquip[i] then
        	local pItem = KItem.GetItemObj(tbEquip[i])
        	if pItem and pItem.GetStrValue(1) then
        		tbEquipGrid.szFragmentSprite = "MarriedMark";
        		tbEquipGrid.szFragmentAtlas = "UI/Atlas/NewAtlas/Panel/NewPanel.prefab";
        	else
        		tbEquipGrid.szFragmentSprite = nil;
        		tbEquipGrid.szFragmentAtlas = nil;
        	end
        end
        tbEquipGrid:SetItem(tbEquip[i])
    	if tbEquip[i] and tbEquip[i] > 0 then
        	self.tbShowEquip[tbEquip[i]] = true
        end
    end

 --    local tbEqiptHorse = self["Equip"..Item.EQUIPPOS_HORSE]
 --    if tbEquip[Item.EQUIPPOS_HORSE] then
	--     tbEqiptHorse.nEquipPos = Item.EQUIPPOS_HORSE;
	-- 	tbEqiptHorse.szItemOpt = "PlayerEquip"
	-- 	if GetTimeFrameState("OpenLevel89") == 1 then
	-- 		tbEqiptHorse.fnClick = function () Ui:OpenWindow("HorsePanel") end;
	-- 	else
	-- 		tbEqiptHorse.fnClick = tbEqiptHorse.DefaultClick;
	-- 	end
	-- 	tbEqiptHorse:SetItem(tbEquip[Item.EQUIPPOS_HORSE])
	-- 	tbEqiptHorse.pPanel:SetActive("Main", true)
	-- else
	-- 	tbEqiptHorse.pPanel:SetActive("Main", false)
	-- end

    if GetTimeFrameState(Item.tbZhenYuan.szOpenTimeFrame) == 1 then
        self.pPanel:SetActive("Vitality", true)
        local tbEquipZhenYuan = self["Equip"..Item.EQUIPPOS_ZHEN_YUAN]
        if tbEquip[Item.EQUIPPOS_ZHEN_YUAN] then
            tbEquipZhenYuan.nEquipPos = Item.EQUIPPOS_ZHEN_YUAN;
            tbEquipZhenYuan.szItemOpt = "PlayerEquip"
            tbEquipZhenYuan:SetItem(tbEquip[Item.EQUIPPOS_ZHEN_YUAN])
            tbEquipZhenYuan.fnClick = tbEquipZhenYuan.DefaultClick;
            tbEquipZhenYuan.pPanel:SetActive("Main", true)
        else
            tbEquipZhenYuan.pPanel:SetActive("Main", false)
        end
    else
        self.pPanel:SetActive("Vitality", false)
    end

    if GetTimeFrameState(Item.tbPiFeng.OPEN_TIME_FRAME) == 1 then
        self.pPanel:SetActive("Clock", true)
        local bShowBtnClock = false

        local tbEquipPF = self["Equip"..Item.EQUIPPOS_BACK2]
        if tbEquip[Item.EQUIPPOS_BACK2] then
            tbEquipPF.nEquipPos = Item.EQUIPPOS_BACK2;
            tbEquipPF.szItemOpt = "PlayerEquip"
            tbEquipPF:SetItem(tbEquip[Item.EQUIPPOS_BACK2])
            tbEquipPF.fnClick = tbEquipPF.DefaultClick;
            tbEquipPF.pPanel:SetActive("Main", true)
            bShowBtnClock = true
        else
            tbEquipPF.pPanel:SetActive("Main", false)
        end
        if not bShowBtnClock then
            local pCurEquipPFWY = me.GetEquipByPos(Item.EQUIPPOS_WAI_BACK2)
            if pCurEquipPFWY then
                bShowBtnClock = true;
            end
        end
        self.pPanel:SetActive("BtnClock", bShowBtnClock)

    else
        self.pPanel:SetActive("Clock", false)
        self.pPanel:SetActive("BtnClock", false)
    end

end

function tbItemBox:SetFilterItemFunc( fnFilterItem )
    self.fnFilterItem = fnFilterItem
end

function tbItemBox:UpdateItemType()
    self.tbItemLists = {}
    for _, nType in pairs(tbToggle) do
        self.tbItemLists[nType] = {};
    end

    local nCount = 0;
    local tbItem = me.GetItemListInBag();
    for nIdx, pItem in ipairs(tbItem) do
        if (not self.fnFilterItem or self.fnFilterItem(pItem)) and not HIDE_CLASS[pItem.szClass] then
            local nType = ITEM_TYPE[pItem.nItemType];
            local szClass = pItem.szClass;
            local tbType = ITEM_CLASS_TYPE[szClass];
            local nSort = ITEM_CLASS_SORT[szClass]
            if ITEM_CHANGE_SORT_FUN1[szClass] then
                nSort = ITEM_CHANGE_SORT_FUN1[szClass](pItem.dwTemplateId) or nSort;
            end
            local nSortParam = ITEM_CLASS_SORT_FUN[szClass] and ITEM_CLASS_SORT_FUN[szClass](pItem) or 0
            local tbData = { nKey1 = nSort or SORT_KEY[pItem.nItemType] or 1000, nKey2 = pItem.nDetailType * 10000 + nSortParam, nKey3 = pItem.GetSingleValue(), nItemId = pItem.dwId, dwTemplateId = pItem.dwTemplateId};

            if nType ~= tbToggle.TogNoCount then
                table.insert(self.tbItemLists[tbToggle.TogAll] , tbData);
                nCount = nCount + 1;
            end

            if type(tbType) == "table" then
                for _, i in ipairs(tbType) do
                    table.insert(self.tbItemLists[i], tbData);
                end
            elseif type(tbType) == "string" and self[tbType] then
                local fnFunction = self[tbType]
                local tbTypeByCheck = fnFunction(self, pItem)
                for _, i in ipairs(tbTypeByCheck or {}) do
                    if self.tbItemLists[i] then
                        table.insert(self.tbItemLists[i], tbData);
                    end
                end

            elseif nType and self.tbItemLists[nType] then
                table.insert(self.tbItemLists[nType], tbData);
            else
                table.insert(self.tbItemLists[tbToggle.TogNormal], tbData);
            end
        end
    end

    self.pPanel:Label_SetText("LabItemCount", string.format("%d / %d", nCount, GameSetting.MAX_COUNT_IN_BAG + Item:GetExtBagCount(me)))
    --self:UpdateHorseItemList();
end

function tbItemBox:UpdateItemList(nType)
    self.nShowType = nType or self.nShowType;
    if self.tbItemLists[self.nShowType] then
        self.tbItemList = self.tbItemLists[self.nShowType]
    end

    -- 先按类型升序，小类型升序，再按价值量降序
    local fnSort = function (tbA, tbB)
        if tbA.nKey1 == tbB.nKey1 then
        	if tbA.nKey2 == tbB.nKey2 then
                if tbA.nKey3 == tbB.nKey3 then
                    return tbA.nItemId < tbB.nItemId
                end
        		return tbA.nKey3 > tbB.nKey3
        	end
            return tbA.nKey2 < tbB.nKey2
        end
        return tbA.nKey1 < tbB.nKey1
    end

    table.sort(self.tbItemList, fnSort)

    self.tbShowItem = {};
    local fnSetItem = function(tbItemGrid, index)
        local nStart = (index - 1) * ITEM_PER_LINE
        for i = 1, ITEM_PER_LINE do
            local tbItem = self.tbItemList[nStart + i];
            local nItemId = tbItem and tbItem.nItemId;
            local tbGridParams = {bShowTip = true}
            local szHighlightAni = nil
            local szHighlightAniAtlas = nil
            if self.dwHightlightItem and self.dwHightlightItem == (tbItem and tbItem.dwTemplateId) then
                szHighlightAni = self.szHighlightAni
                szHighlightAniAtlas = self.szHighlightAniAtlas
            end
            tbItemGrid:SetItem(i, nItemId, nil, "ItemBox", tbGridParams, szHighlightAni, szHighlightAniAtlas);
            if nItemId then
                self.tbShowItem[nItemId] = tbItemGrid:GetGrid(i);
            end
        end
    end

    self.ScrollView:Update( math.max(math.ceil(#self.tbItemList / ITEM_PER_LINE), MIN_LINE), fnSetItem);    -- 至少显示5行
end

function tbItemBox:CheckCoposeable(pItem)
    local tbBag = Compose.EntityCompose:GetToggleSetting(pItem.dwTemplateId)
    if tbBag then
        return tbBag
    end
	tbBag = {}

    local bIsCan,szTip,nTargetID = Compose.EntityCompose:CheckIsCanCompose(me, pItem.dwTemplateId)
    local bNormal
	if bIsCan then
        local tbItemBase = KItem.GetItemBaseProp(nTargetID)
        if tbItemBase.szClass == "horse_equip" then
            local nEquipPos = KItem.GetEquipPos(nTargetID)
            local pCurEquip = me.GetEquipByPos(nEquipPos)
            if pCurEquip and pCurEquip.nLevel >= 3 then
                bIsCan = false
            end
        end
        if bIsCan then
            bNormal = true
            table.insert(tbBag, tbToggle.TogNormal);
        end
	end

	if pItem.szClass == "EquipMeterial" then
		table.insert(tbBag, tbToggle.TogEquip);
	end

    if pItem.szClass == "NormalMeterial" and not bNormal then
        table.insert(tbBag, tbToggle.TogNormal);
    end

	return tbBag
end

function tbItemBox:OnSyncItem(nItemId, bUpdateAll)
	if self.bStopUpdateAtOnce then
		return;
	end
    if bUpdateAll == 1 then
        self:UpdateItemType();
        self:UpdateItemList();
        self:UpdateEquip();
    else
        if self.tbShowItem[nItemId] and self.tbShowItem[nItemId].nItemId == nItemId then
            self.tbShowItem[nItemId]:SetItem(nItemId, {bShowTip = true})
        end
        if self.tbShowEquip[nItemId] then
        	self:UpdateEquip()
        end
    end
    self:CheckCanUpgrade();
end

function tbItemBox:OnDelItem(nItemId)
    self:UpdateItemType();
    self:UpdateItemList();
    self:UpdateEquip();
end

function tbItemBox:UpdateBaseAttrib()
    -- local pNpc = me.GetNpc();
    -- local nMin, nMax = me.GetBaseDamage()
    -- self.pPanel:Label_SetText("LabAttack", tostring(nMax))
    -- self.pPanel:Label_SetText("LabMaxHp", tostring(pNpc.nMaxLife))

    --local nStar = StarAttrib:CalcTotalStar(me);
    --local nStarLevel = string.format("%d", math.floor(nStar / 2));
    --self.pPanel:Label_SetText("EquipStarText", nStarLevel);
end

tbItemBox.tbFactionScale = {0.92, 1, 1.15, 1, 1, 1, 0.92, 1, 1, 1, 1, 1.15} -- 贴图缩放比例
function tbItemBox:OnTimerChangeFeature()
    if self.nTimerFeature then
        Timer:Close(self.nTimerFeature);
        self.nTimerFeature = nil;
    end

    local tbNpcRes, tbEffectRes = me.GetNpcResInfo();
    local nNpcResID, tbPartsRes = me.GetNpc().GetFeature();
	--local tbFactionScale = {0.65, 0.7, 0.8, 0.7}	-- 贴图缩放比例
	local tbFactionScale = self.tbFactionScale
	local fScale = tbFactionScale[me.nFaction] or 1
    --print("tbItemBox:ChangeFeature");
    if tbPartsRes and tbPartsRes[Npc.NpcResPartsDef.npc_part_body] > 0 then
        for nPartId, nResId in pairs(tbNpcRes) do
            local nCurResId = nResId
            if nPartId == Npc.NpcResPartsDef.npc_part_horse then
                nCurResId = 0;
            end

            self.pPanel:NpcView_ChangePartRes("ShowRole", nPartId, nCurResId);
            --print("ShowRole", nPartId, nCurResId);
        end

        for nPartId, nResId in pairs(tbEffectRes) do
            self.pPanel:NpcView_ChangePartEffect("ShowRole", nPartId, nResId);
        end
    else
        for nPartId, nResId in pairs(tbNpcRes) do
            self.pPanel:NpcView_ChangePartRes("ShowRole", nPartId, 0);
        end

        for nPartId, nResId in pairs(tbEffectRes) do
            self.pPanel:NpcView_ChangePartEffect("ShowRole", nPartId, 0);
        end
        self.pPanel:NpcView_ShowNpc("ShowRole", nNpcResID);
    end

	self.pPanel:NpcView_SetScale("ShowRole", fScale);

    if self.bLoadRoleRes then
        self:PlayRoleAnimation();
    end
    -- self.pPanel:ChangeScale("ModelTexture", fScale, fScale, fScale)

end

function tbItemBox:ChangeFeature()
    if self.bClearFeature then
        self:PlayRoleAnimation();
        self.bClearFeature = nil;
    end

    if self.nTimerFeature then
        Timer:Close(self.nTimerFeature);
        self.nTimerFeature = nil;
    end

    --头部和武器资源可能多次加载BUG临时处理
    self.nTimerFeature = Timer:Register(1, self.OnTimerChangeFeature, self)
end

function tbItemBox:OnSyncItemsBegin()
	self.bStopUpdateAtOnce = true;
	if not self.nStopUpdateTimer then
		self.nStopUpdateTimer = Timer:Register(Env.GAME_FPS * 1, self.OnStopUpdateTimer, self)
	end
end

function tbItemBox:OnSyncItemsEnd()
	self.bStopUpdateAtOnce = false;
	if self.nStopUpdateTimer then
		Timer:Close(self.nStopUpdateTimer)
		self.nStopUpdateTimer = nil;
	end
	self:OnSyncItem(0, 1);
end

function tbItemBox:OnStopUpdateTimer()
	self.bStopUpdateAtOnce = false;
	self.nStopUpdateTimer = nil
	self:OnSyncItem(0, 1);
end

function tbItemBox:AutoClose()
    Ui:CloseWindow(self.UI_NAME);
end

tbItemBox.tbCheckFeatureCloese =
{
    ["WaiyiPreview"] = 1;
};

function tbItemBox:OnWindowOpen( szWndName )
    if tbItemBox.tbCheckFeatureCloese[szWndName] then
        self:CheckChangePifengReq()
    end
end

function tbItemBox:OnWindowCloese(szWndName)
    if szWndName ~= self.UI_NAME and tbItemBox.tbCheckFeatureCloese[szWndName] and self.bLoadRoleRes and self.szCurTagPanel == "BtnRole" then
        self.bClearFeature = true;
        self:ChangeFeature();
    end

    if Ui.UiManager.GetTopPanelName() ~= self.UI_NAME then
        return
    end
    self:ShowExAttribLevel()
end

function tbItemBox:PlayStandAnimaion()
    self.nPlayStTimer = nil;
    self.pPanel:NpcView_PlayAnimationByActId("ShowRole", Npc.ActionId.act_stand, 0.1, true);
end

function tbItemBox:PlayNextRoleAnimation(nActId)
    self.pPanel:NpcView_PlayAnimationByActId("ShowRole", nActId, 0.0, false);
    ViewRole:CheckPlayeRoleAniEffect(self,nActId )

    if self.nPlayStTimer then
        Timer:Close(self.nPlayStTimer);
        self.nPlayStTimer = nil;
    end

    local nPlayTime = self.pPanel:NpcView_GetPlayAniTime("ShowRole");
    nPlayTime = math.max(math.floor(nPlayTime * Env.GAME_FPS), 2);
    self.nPlayStTimer  = Timer:Register(nPlayTime, self.PlayStandAnimaion, self);
    self.nPlayNextTimer = nil;
    self:PlayRoleAnimation();
end

function tbItemBox:PlayRoleAnimation()
    local tbSkillIniSet = FightSkill.tbSkillIniSet;
    local nTotalID = #tbSkillIniSet.tbActStandID;
    if nTotalID <= 0 then
        return 0;
    end

    local nFrame = tbSkillIniSet.nActStandMinFrame;
    local nMaxFrame = tbSkillIniSet.nActStandMaxFrame - tbSkillIniSet.nActStandMinFrame;
    if nMaxFrame > 0 then
       nFrame = MathRandom(nMaxFrame) + tbSkillIniSet.nActStandMinFrame;
    end

    local nAniIndex = MathRandom(nTotalID);
    local nActId    = tbSkillIniSet.tbActStandID[nAniIndex];
    local tbActionInfo = Npc:GetNpcActionInfo(nActId);

    if self.nPlayNextTimer then
        Timer:Close(self.nPlayNextTimer);
        self.nPlayNextTimer = nil;
    end

    if not tbActionInfo then
        return;
    end

    local pNpc = me.GetNpc();
    if not pNpc then
        return;
    end

    local nActFrame = pNpc.GetActionFrame(nActId);
    if nActFrame <= 2 then
        nActFrame = 70;
    end

    self.nPlayNextTimer  = Timer:Register(nFrame + nActFrame, self.PlayNextRoleAnimation, self, nActId);
end

function tbItemBox:CloseRoleAniTimer()
    if self.nPlayStTimer then
        Timer:Close(self.nPlayStTimer);
        self.nPlayStTimer = nil;
    end

    if self.nPlayNextTimer then
        Timer:Close(self.nPlayNextTimer);
        self.nPlayNextTimer = nil;
    end
end

function tbItemBox:OnLoadResFinish()
    if self.szCurTagPanel == "BtnMounts" then
        self.pPanel:NpcView_ChangeDir("HorseView", 220, false);
    elseif self.szCurTagPanel == "BtnRole" then
        self:PlayRoleAnimation();
        self.bLoadRoleRes = true;
    end
end

function tbItemBox:OnSyncData(szType)
    if szType == "PlayerAttribute" then
        if self.szCurTagPanel == "BtnAttribute" then
            self.AttributeDetail:SetData();
        end
    end
end

function tbItemBox:ChangeFeatureEvent()
    self.bClearFeature = nil;
    self:ChangeFeature();
    self.bClearFeature = true;
end

function tbItemBox:RegisterEvent()
    local tbRegEvent =
    {
		{ UiNotify.emNOTIFY_SYNC_ITEM,			self.OnSyncItem },
		{ UiNotify.emNOTIFY_DEL_ITEM,			self.OnDelItem },
		{ UiNotify.emNOTIFY_CHANGE_PLAYER_EXP,	self.ChangePlayerExp},
		{ UiNotify.emNOTIFY_CHANGE_FEATURE,		self.ChangeFeatureEvent},
		{ UiNotify.emNOTIFY_UPDATE_TITLE,		self.UpdateTitleInfo},
		{ UiNotify.emNOTIFY_STRENGTHEN_RESULT,	self.CheckCanUpgrade},
		{ UiNotify.emNOTIFY_INSET_RESULT, 		self.CheckCanUpgrade},
		{ UiNotify.emNOTYFY_SYNC_ITEMS_BEGIN, 	self.OnSyncItemsBegin},
        { UiNotify.emNOTIFY_SYNC_DATA,          self.OnSyncData},
        { UiNotify.emNOTIFY_LOAD_RES_FINISH,    self.OnLoadResFinish, self},
		{ UiNotify.emNOTYFY_SYNC_ITEMS_END, 	self.OnSyncItemsEnd},
        { UiNotify.emNOTIFY_SHOW_DIALOG,         self.AutoClose},
        { UiNotify.emNOTIFY_WND_CLOSED,         self.OnWindowCloese},
        { UiNotify.emNOTIFY_WND_OPENED,         self.OnWindowOpen},
        { UiNotify.emNOTIFY_JINGMAI_DATA_CHANGE,         self.UpdateJingMainBtn},


    };

    return tbRegEvent;
end
