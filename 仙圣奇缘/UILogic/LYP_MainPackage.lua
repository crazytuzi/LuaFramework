
Game_Package1 = class("Game_Package1")
Game_Package1.__index = Game_Package1

g_ItemTypeInPackage =
{
    All = 1,	--全部
    UseItem = 2,	--道具
    Materail = 3,	--材料
	SkillFrag = 4,	--碎片
    Formula = 5,	--配方
    HunPo = 6,	--魂魄
    CardSoul = 7,	--元神
}

local GoodsServerType =
{
	macro_pb.ITEM_TYPE_MATERIAL,
	macro_pb.ITEM_TYPE_CARD_GOD,
	macro_pb.ITEM_TYPE_SOUL,
}

local tbSellBtnOption = {
	Sell = 1,
	UseItem = 2,
	CardLevelUp = 3,
	ComposeChild = 4,
	SummonItem = 5,
	Horn = 6,
	ComposeFather = 7,
	OpenEvent = 8,
	OpenSummon = 9,
	OpenHuntFate = 10,
	OpenShangXiang = 11,
}

local tbDetailBtnOption = {
	BatchUseItem = 1,
	ComposeChild = 2,
	DropGuide = 3,
	Sell = 4,
	ComposeCrystal = 5,
	ComposeFather = 6,
}

NUM_ItemBaseType = {
	Material = 0,
	SkillFrag = 1,
	CanUseItem = 2,
	EquipFormula = 3,
	EquipPackAll = 4,
	CardExpItem = 6,
}

NUM_ItemBaseSubType = {
	EquipComposeMaterial = 1,
	DanYaoFrag = 2,
	CanUseItem = 3,
	ReforgeStone = 4,
	SummonStone = 5,
	Horn = 6,
	EquipMaterialPack = 7,
	EquipFormulaPack = 8,
	EquipPack = 9,
	EquipComposeMaterialFrag = 10,
	SoulMaterialPack = 11,
	RandomPack = 12,
	SelectedPack = 13,
	EventToken = 14,
	SummonToken = 15,
	HuntFateToken = 16,
	ShangXiangToken = 17,
}



--[[
ITEM_TYPE_CARD = 1;				--伙伴
ITEM_TYPE_EQUIP = 2;			--装备
ITEM_TYPE_ARRAYMETHOD = 3;		--阵法(暂时作废)
ITEM_TYPE_FATE = 4;				--异兽
ITEM_TYPE_CARD_GOD = 5;			--魂魄
ITEM_TYPE_MATERIAL = 6;			--ItemBase(道具)
ITEM_TYPE_SOUL = 7;				--元神
ITEM_TYPE_MASTER_EXP = 8;		--主角经验
ITEM_TYPE_MASTER_ENERGY = 9;	--体力
ITEM_TYPE_COUPONS = 10;			--点券、元宝
ITEM_TYPE_GOLDS = 11;			--金币、铜钱
ITEM_TYPE_PRESTIGE = 12;		--声望
ITEM_TYPE_KNOWLEDGE = 13;		--阅历
ITEM_TYPE_SKILL_SHARD = 14;		--技能碎片(材料)
]]

local nOffset = 62
local moveTime = 0.2
NULL_BOX = -1 --格子中没有道具

local tbItemImageName = {
	[g_ItemTypeInPackage.All] = "",--1,	--全部
    [g_ItemTypeInPackage.UseItem] ="", --2,	--道具
    [g_ItemTypeInPackage.Materail] = "Image_PackageIconMaterial", 	--3,	--材料
	[g_ItemTypeInPackage.SkillFrag] = "Image_PackageIconSkillFrag",	-- 4,	--碎片
    [g_ItemTypeInPackage.Formula] = "Image_PackageIconFormula",		-- 5,	--配方
    [g_ItemTypeInPackage.HunPo] = "Image_PackageIconHunPo",			--6,	--魂魄
    [g_ItemTypeInPackage.CardSoul] ="Image_PackageIconSoul",		-- 7,	--元神
}

function Game_Package1:PackagePNLAction(widget,funcCallBack)
	local posX
	local ImageView_PackagePNL = tolua.cast(self.rootWidget:getChildByName("ImageView_PackagePNL"), "ImageView")
	local Pox = ImageView_PackagePNL:getPositionX()
	if Pox == 645  then
		posX = 900
	else
		posX = 645
	end

	local actionMoveTo = CCMoveTo:create(moveTime, ccp(posX,350))
	local actionMoveToEasing =  CCEaseSineIn:create(actionMoveTo)
	local arrAct = CCArray:create()
	arrAct:addObject(actionMoveToEasing)
	if(funcCallBack)then
		arrAct:addObject(CCCallFuncN:create(funcCallBack))
	end
	local action = CCSequence:create(arrAct)
	widget:runAction(action)
end

function Game_Package1:DetailPNLAction(widget,funcCallBack)
	widget:setCascadeOpacityEnabled(true)
	local posX
	local actionFadein
	local ImageView_PackagePNL = tolua.cast(self.rootWidget:getChildByName("ImageView_PackagePNL"), "ImageView")
	local Pox = ImageView_PackagePNL:getPositionX()
	if Pox == 645  then
		posX = 290
		actionFadein = CCFadeIn:create(moveTime)
	else
		actionFadein = CCFadeOut:create(moveTime)
		posX = 645
	end
	widget:setVisible(true)
	widget:setOpacity(0)
	local actionMoveTo = CCMoveTo:create(moveTime, ccp(posX,350))
	local actionMoveToEasing =  CCEaseSineIn:create(actionMoveTo)

	local actionFadeinEasing =  CCEaseSineIn:create(actionFadein)
	local actionSpwan = CCSpawn:createWithTwoActions(actionMoveToEasing, actionFadeinEasing)
	local arrAct = CCArray:create()
	arrAct:addObject(actionSpwan)
	if(funcCallBack)then
		arrAct:addObject(CCCallFuncN:create(funcCallBack))
	end
	local action = CCSequence:create(arrAct)
	widget:runAction(action)
end

function Game_Package1:ItemDetailPNLAction(str,funcCallBack)
	local ImageView_PackagePNL = tolua.cast(self.rootWidget:getChildByName("ImageView_PackagePNL"), "ImageView")
	local ImageView_ItemDetailPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_ItemDetailPNL"), "ImageView")

	local Pox = ImageView_PackagePNL:getPositionX()
	if str == "open" and Pox == 645 then
		self:PackagePNLAction(ImageView_PackagePNL)
		self:DetailPNLAction(ImageView_ItemDetailPNL)
	elseif str == "close" and Pox == 900 then
		self:PackagePNLAction(ImageView_PackagePNL)
		self:DetailPNLAction(ImageView_ItemDetailPNL,funcCallBack)
	elseif funcCallBack then
		funcCallBack()
	end
end

function Game_Package1:updateItemDetailNum(nRemainNum)
	local wndInstance = g_WndMgr:getWnd("Game_Package1")
	if wndInstance then
		local nRemainNum = nRemainNum
		if nRemainNum <= 0 then
			nRemainNum = 0
			wndInstance:ItemDetailPNLAction("close")
			return
		end
		
		wndInstance.nHaveNum = nRemainNum
		
		if wndInstance.Label_HaveNum and wndInstance.Label_HaveNum:isExsit() then
			wndInstance.Label_HaveNum:setText(nRemainNum)
		end
		
		if wndInstance.Current_Label_HaveNum and wndInstance.Current_Label_HaveNum:isExsit() then
			wndInstance.Current_Label_HaveNum:setText(nRemainNum)
		end
		
	end
end

function Game_Package1:setItemDetailPNL(widgetChild, GameObj, Button_EquipIconBase)
	if not GameObj then return end
	
	local nGameObjType = Button_EquipIconBase:getTag()
	
	local wndInstance = g_WndMgr:getWnd("Game_Package1")
	if not wndInstance or not wndInstance.rootWidget then return end
	
	local Image_CheckCover = tolua.cast(Button_EquipIconBase:getChildByName("Image_CheckCover"), "ImageView")
	if wndInstance.Image_CheckCover and wndInstance.Image_CheckCover:isExsit() then wndInstance.Image_CheckCover:setVisible(false) end
	wndInstance.Image_CheckCover = Image_CheckCover
	Image_CheckCover:setVisible(true)
	
	wndInstance:ItemDetailPNLAction("open")
	
	local ImageView_ItemDetailPNL = tolua.cast(wndInstance.rootWidget:getChildByName("ImageView_ItemDetailPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(ImageView_ItemDetailPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Image_ItemIconBase = tolua.cast(Image_ContentPNL:getChildByName("Image_ItemIconBase"), "ImageView")
	Image_ItemIconBase:removeAllChildrenWithCleanup(true)
	
	local widgetChild_Clone = widgetChild:clone()
	Image_ItemIconBase:addChild(widgetChild_Clone)
	widgetChild_Clone:setPosition(ccp(0,0))

	local Image_PackageIconBase = tolua.cast(widgetChild_Clone, "ImageView")
	local Image_Frame = tolua.cast(widgetChild_Clone:getChildByName("Image_Frame"), "ImageView")
	local Image_Icon = tolua.cast(widgetChild_Clone:getChildByName("Image_Icon"), "ImageView")
	local Image_Symbol = tolua.cast(widgetChild_Clone:getChildByName("Image_Symbol"), "ImageView")
	local Image_Cover = tolua.cast(widgetChild_Clone:getChildByName("Image_Cover"), "ImageView")

	local widgetChild_Label_HaveNum = tolua.cast(widgetChild_Clone:getChildByName("Label_HaveNum"), "Label")
	if widgetChild_Label_HaveNum then widgetChild_Label_HaveNum:setVisible(false) end
	
	
	local Image_MoneyBase = tolua.cast(Image_ContentPNL:getChildByName("Image_MoneyBase"), "ImageView")
	local Label_PriceLB = tolua.cast(Image_MoneyBase:getChildByName("Label_PriceLB"), "Label")
	Label_PriceLB:setVisible(false)
	
	local Label_Tip = tolua.cast(Image_MoneyBase:getChildByName("Label_Tip"), "Label")
	Label_Tip:setVisible(false)
	
	local Image_Coins = tolua.cast(Label_PriceLB:getChildByName("Image_Coins"), "ImageView")
	if nGameObjType == g_ItemTypeInPackage.HunPo then
		Image_Coins:loadTexture(getUIImg("Icon_PlayerInfo_JiangHunShi"))
	else
		Image_Coins:loadTexture(getUIImg("Icon_PlayerInfo_TongQian"))
	end
	
	local Button_Sell = tolua.cast(Image_ContentPNL:getChildByName("Button_Sell"), "Button")
	local BitmapLabel_FuncName = tolua.cast(Button_Sell:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
	BitmapLabel_FuncName:setVisible(true)
	BitmapLabel_FuncName:setOpacity(255)
    local Button_Detail = Image_ContentPNL:getChildByName("Button_Detail")
    local Button_DetailBitmapLabel_FuncName = tolua.cast(Button_Detail:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
	Button_DetailBitmapLabel_FuncName:setVisible(true)
	Button_DetailBitmapLabel_FuncName:setOpacity(255)
	
	local tbCsvBase = GameObj:getCsvBase()
	local nStarLevel = GameObj:getStarLevel()
	local nColorType = tbCsvBase.ColorType or nStarLevel
	
	local strDesc = ""

	local nSellBtnOption = tbSellBtnOption.Sell
    local nDetailBtnOption = tbDetailBtnOption.DropGuide
	
	local nBtnLabelLfetName = _T("点击使用")
	local nBtnLabelRightName = ""
	
	local ImageIcon = tbCsvBase.Icon
	
    if nGameObjType == g_ItemTypeInPackage.UseItem then
		strDesc = tbCsvBase.Desc
		if tbCsvBase.Type == NUM_ItemBaseType.CanUseItem then
			if tbCsvBase.SubType == NUM_ItemBaseSubType.CanUseItem
				or tbCsvBase.SubType == NUM_ItemBaseSubType.EquipMaterialPack
				or tbCsvBase.SubType == NUM_ItemBaseSubType.EquipFormulaPack
				or tbCsvBase.SubType == NUM_ItemBaseSubType.SoulMaterialPack
				or tbCsvBase.SubType == NUM_ItemBaseSubType.RandomPack
				or tbCsvBase.SubType == NUM_ItemBaseSubType.SelectedPack
			then --可使用道具
				nSellBtnOption = tbSellBtnOption.UseItem
				nDetailBtnOption = tbDetailBtnOption.BatchUseItem
				nBtnLabelRightName = _T("批量使用")
			elseif tbCsvBase.SubType == NUM_ItemBaseSubType.SummonStone then --万能魂石
				nSellBtnOption = tbSellBtnOption.SummonItem
				nDetailBtnOption = tbDetailBtnOption.Sell
				nBtnLabelRightName = _T("点击出售")
			elseif tbCsvBase.SubType == NUM_ItemBaseSubType.EventToken then --活动货币
				nSellBtnOption = tbSellBtnOption.OpenEvent
				nDetailBtnOption = tbDetailBtnOption.Sell
				nBtnLabelRightName = _T("点击出售")
			elseif tbCsvBase.SubType == NUM_ItemBaseSubType.Horn then --嘹亮的号角
				nSellBtnOption = tbSellBtnOption.Horn
				nDetailBtnOption = tbDetailBtnOption.Sell
				nBtnLabelRightName = _T("点击出售")
			elseif tbCsvBase.SubType == NUM_ItemBaseSubType.SummonToken then --召唤代币
				nSellBtnOption = tbSellBtnOption.OpenSummon
				nDetailBtnOption = tbDetailBtnOption.Sell
				nBtnLabelRightName = _T("点击出售")
			elseif tbCsvBase.SubType == NUM_ItemBaseSubType.HuntFateToken then --猎妖代币
				nSellBtnOption = tbSellBtnOption.OpenHuntFate
				nDetailBtnOption = tbDetailBtnOption.Sell
				nBtnLabelRightName = _T("点击出售")
			elseif tbCsvBase.SubType == NUM_ItemBaseSubType.ShangXiangToken then --上香代币
				nSellBtnOption = tbSellBtnOption.OpenShangXiang
				nDetailBtnOption = tbDetailBtnOption.Sell
				nBtnLabelRightName = _T("点击出售")
			end
		elseif tbCsvBase.Type == NUM_ItemBaseType.CardExpItem then --经验道具
			nSellBtnOption = tbSellBtnOption.CardLevelUp
			nDetailBtnOption = tbDetailBtnOption.Sell
			nBtnLabelRightName = _T("点击出售")
			
		elseif tbCsvBase.Type == NUM_ItemBaseType.EquipPackAll then --材料包
			Image_Symbol:loadTexture(getIconImg("ResourceItem_MaterialPack"..nColorType))
			nSellBtnOption = tbSellBtnOption.UseItem
			nDetailBtnOption = tbDetailBtnOption.BatchUseItem
			nBtnLabelRightName = _T("批量使用")
        end
	elseif nGameObjType == g_ItemTypeInPackage.Materail then
		strDesc = tbCsvBase.Desc
		if strDesc ~= "" then
			strDesc = tbCsvBase.Desc..tbCsvBase.Desc1
		end
		if tbCsvBase.SubType == NUM_ItemBaseSubType.EquipComposeMaterial then --合成材料
			nDetailBtnOption = tbDetailBtnOption.ComposeFather
			nBtnLabelRightName = _T("碎片合成")
		elseif tbCsvBase.SubType == NUM_ItemBaseSubType.ReforgeStone then --重铸晶石
			nDetailBtnOption = tbDetailBtnOption.ComposeCrystal
			nBtnLabelRightName = _T("晶石合成")
		end
		nBtnLabelLfetName = _T("点击出售")
		
	elseif nGameObjType == g_ItemTypeInPackage.SkillFrag then
		strDesc = tbCsvBase.Desc
		if strDesc ~= "" then
			strDesc = tbCsvBase.Desc..tbCsvBase.Desc1
		end
		Image_Symbol:loadTexture(getFrameSymbolSkillFrag(nColorType))
		
		if tbCsvBase.SubType == NUM_ItemBaseSubType.EquipComposeMaterial then --合成材料
			nSellBtnOption = tbSellBtnOption.Sell
			nDetailBtnOption = tbDetailBtnOption.ComposeChild
			nBtnLabelLfetName = _T("点击出售")
			nBtnLabelRightName = _T("碎片合成")
		elseif tbCsvBase.SubType == NUM_ItemBaseSubType.DanYaoFrag or tbCsvBase.SubType == NUM_ItemBaseSubType.EquipComposeMaterialFrag then --丹药/装备碎片
			nBtnLabelLfetName = _T("点击出售")
			nBtnLabelRightName = _T("查看掉落")
		end
	elseif nGameObjType == g_ItemTypeInPackage.Formula then
		strDesc = tbCsvBase.Desc
		Image_Symbol:loadTexture(getFrameSymbolFormula(nColorType))

		nBtnLabelLfetName = _T("点击出售")
		nBtnLabelRightName = _T("查看掉落")
	elseif nGameObjType == g_ItemTypeInPackage.HunPo then
		strDesc = tbCsvBase.Desc
		ImageIcon = GameObj:getCardBase().SpineAnimation
		Image_Cover:loadTexture(getFrameCoverHunPo(nColorType))

		nBtnLabelLfetName = _T("点击出售")
		nBtnLabelRightName = _T("查看掉落")
	elseif nGameObjType == g_ItemTypeInPackage.CardSoul then
		local nStrLen = string.len(tbCsvBase.Name)
		local strName = string.sub(tbCsvBase.Name, 10, nStrLen)
		strDesc = strName.._T("的元神，被伙伴吞噬后可为伙伴增加境界经验，从而提高伙伴的境界。")
		ImageIcon = tbCsvBase.SpineAnimation
		Image_Cover:loadTexture(getFrameCoverSoul(nColorType))
		nBtnLabelLfetName = _T("点击出售")
		nBtnLabelRightName = _T("查看掉落")
	end
	Image_PackageIconBase:loadTexture(getFrameBackGround(nColorType))
	Image_Icon:loadTexture(getIconImg(ImageIcon))
	Image_Frame:loadTexture(getIconFrame(nColorType))
	BitmapLabel_FuncName:setText(nBtnLabelLfetName)
	Button_DetailBitmapLabel_FuncName:setText(nBtnLabelRightName)
	Label_PriceLB:setVisible(true)
	
	
	local Label_Name = tolua.cast(Image_ContentPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(tbCsvBase.Name)
	g_SetWidgetColorBySLev(Label_Name, nColorType)
	
	local Label_QualityLB = tolua.cast(Image_ContentPNL:getChildByName("Label_QualityLB"), "Label")
	local Label_Quality = tolua.cast(Label_QualityLB:getChildByName("Label_Quality"), "Label")
	-- cclog("========================="..nColorType)
	if nColorType > #g_tbQuality then
		nColorType = #g_tbQuality
	end
	Label_Quality:setText(g_tbQuality[nColorType])
	g_SetWidgetColorBySLev(Label_Quality, nColorType)
	
	Label_Quality:setPositionX(Label_QualityLB:getSize().width)
	Label_PriceLB:setPositionX(0)
	-- Label_PriceLB:setAnchorPoint(ccp(0.5,05))
	--需要修改
	local Label_Price = tolua.cast(Label_PriceLB:getChildByName("Label_Price"), "Label")
	Label_Price:setText(tbCsvBase.Price)
	
	local Label_HaveNumLB = tolua.cast(Image_ContentPNL:getChildByName("Label_HaveNumLB"), "Label")
	local Label_Unit = tolua.cast(Label_HaveNumLB:getChildByName("Label_Unit"), "Label")
	self.Label_HaveNum = tolua.cast(Label_HaveNumLB:getChildByName("Label_HaveNum"), "Label")
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_Name:setFontSize(18)
		Label_QualityLB:setFontSize(18)
		Label_Quality:setFontSize(18)
		Label_HaveNumLB:setFontSize(18)
		self.Label_HaveNum:setFontSize(18)
		Label_Unit:setFontSize(18)
	end
	
	Label_Quality:setPositionX(Label_QualityLB:getSize().width + 5)

	local nHaveNum = GameObj:getNum()
	if nHaveNum then
		self.nHaveNum = nHaveNum
	end
		
	if self.Label_HaveNum then
		self.Label_HaveNum:setText(nHaveNum)
		self.Label_HaveNum:setPositionX(Label_HaveNumLB:getSize().width + 5)
		g_AdjustWidgetsPosition({self.Label_HaveNum, Label_Unit}, 5)
	end

	local Image_DescPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_DescPNL"), "ImageView")
	local Label_Desc = tolua.cast(Image_DescPNL:getChildByName("Label_Desc"), "Label")
	Label_Desc:setText(strDesc)
	
	local function onClick_Confirm(InputText)
		local nCsvID = GameObj:getCsvID()
        local nStarLevel = GameObj:getStarLevel()
		local serverId = GameObj:getServerId()
		local itemType = nGameObjType

		if  nGameObjType == g_ItemTypeInPackage.UseItem
			or nGameObjType == g_ItemTypeInPackage.Materail
			or nGameObjType == g_ItemTypeInPackage.SkillFrag
			or nGameObjType == g_ItemTypeInPackage.Formula
		then
			itemType = GoodsServerType[1]
		elseif  nGameObjType == g_ItemTypeInPackage.HunPo then
			itemType = GoodsServerType[2]
		elseif  nGameObjType== g_ItemTypeInPackage.CardSoul then
			itemType = GoodsServerType[3]
		end
		g_MsgMgr:requestBagSell(itemType, nCsvID, nStarLevel,serverId,InputText)
	end
	
	local function onClick_Button_Sell(pSender, nSellBtnOption)
		if nSellBtnOption == tbSellBtnOption.Sell then
			g_ClientMsgTips:showConfirmInputNumber(_T("出售数量"),self.nHaveNum, onClick_Confirm, nil, self.nHaveNum)
		elseif nSellBtnOption == tbSellBtnOption.UseItem then

            local itemBase = g_DataMgr:getCsvConfigByTwoKey("ItemBase",GameObj:getCsvID(), GameObj:getStarLevel())
            if itemBase ~= nil and itemBase.DropPackType == 2 then --2  是可选择掉落礼包或者物品
                g_RewardSelectSys:ShowRewardSelectWnd(GameObj, 1)
            else
			    local tbSendMsg = {}
			    tbSendMsg.item_id = GameObj:getServerId()
			    tbSendMsg.use_item_info = {}
			    tbSendMsg.use_item_info.use_num = 1
			    g_MsgMgr:requestUseItemRequest(tbSendMsg)
            end
		elseif nSellBtnOption == tbSellBtnOption.CardLevelUp then
			local param = {
				id = GameObj:getServerId(),
				starLev = GameObj:getStarLevel(),
				addValue = GameObj["tbCsvBase"].AddValue,
				num = nHaveNum,
			}
			g_WndMgr:showWnd("Game_CardLevelUp", param)
		elseif nSellBtnOption == tbSellBtnOption.ComposeFather then
			--合成
			local tbCsvBase = GameObj:getCsvBase()
			local param = {
				nType = ComposeTypeDefine.MATERIAL_TYPE,
				itemId = GameObj:getCsvID(),
				itemStar = GameObj:getStarLevel(),
				name = tbCsvBase.Name
			}
			g_WndMgr:showWnd("Game_ItemDropGuide",param)
		elseif nSellBtnOption == tbSellBtnOption.ComposeChild then
			local tbCsvBase = GameObj:getCsvBase()
			local CSV_ItemCompose = g_DataMgr:getItemComposeCsvByMaterialID(tbCsvBase.ID, tbCsvBase.StarLevel)
			local CSV_ItemBase = g_DataMgr:getItemBaseCsv(CSV_ItemCompose.TargetID, CSV_ItemCompose.TargetStarLevel)
			local param = {
				nType = ComposeTypeDefine.MATERIAL_TYPE, --合成界面
				itemId = CSV_ItemCompose.TargetID, 
				itemStar = CSV_ItemCompose.TargetStarLevel, 
				detailType = macro_pb.ITEM_TYPE_MATERIAL,--道具
				name = CSV_ItemBase.Name
			}
			g_WndMgr:showWnd("Game_ItemDropGuide",param)
		elseif nSellBtnOption == tbSellBtnOption.SummonItem then
			g_WndMgr:showWnd("Game_Card", true)
		elseif nSellBtnOption == tbSellBtnOption.OpenEvent then
			g_WndMgr:openWnd("Game_ActivityCenter")
		elseif nSellBtnOption == tbSellBtnOption.Horn then
			g_WndMgr:showWnd("Game_ChatCenter")
		elseif nSellBtnOption == tbSellBtnOption.OpenSummon then
			g_WndMgr:openWnd("Game_Summon")
		elseif nSellBtnOption == tbSellBtnOption.OpenHuntFate then
			g_FateData:requestHuntFateRefresh()
		elseif nSellBtnOption == tbSellBtnOption.OpenShangXiang then
			g_WndMgr:openWnd("Game_ShangXiang1")
		end
	end

	g_SetBtnWithOpenCheck(Button_Sell, nSellBtnOption, onClick_Button_Sell, true)

    local function onClick_Button_Detail(pSender, nDetailBtnOption)
        if nDetailBtnOption == tbDetailBtnOption.BatchUseItem then
            local itemBase = g_DataMgr:getCsvConfigByTwoKey("ItemBase",GameObj:getCsvID(), GameObj:getStarLevel())
            if itemBase ~= nil and itemBase.DropPackType == 2 then --2  是可选择掉落礼包或者物品
                g_RewardSelectSys:ShowRewardSelectWnd(GameObj, GameObj:getNum())
            else
                local tbSendMsg = {}
				tbSendMsg.item_id = GameObj:getServerId()
				tbSendMsg.use_item_info = {}
				tbSendMsg.use_item_info.use_num = GameObj:getNum()
                g_MsgMgr:requestUseItemRequest(tbSendMsg)
            end
        elseif nDetailBtnOption == tbDetailBtnOption.ComposeFather then
			--合成
			local tbCsvBase = GameObj:getCsvBase()
			local param = {
				nType = ComposeTypeDefine.MATERIAL_TYPE,
				itemId = GameObj:getCsvID(),
				itemStar = GameObj:getStarLevel(),
				name = tbCsvBase.Name
			}
			g_WndMgr:showWnd("Game_ItemDropGuide",param)
		elseif nDetailBtnOption == tbDetailBtnOption.ComposeChild then
			local tbCsvBase = GameObj:getCsvBase()
			local CSV_ItemCompose = g_DataMgr:getItemComposeCsvByMaterialID(tbCsvBase.ID, tbCsvBase.StarLevel)
			local CSV_ItemBase = g_DataMgr:getItemBaseCsv(CSV_ItemCompose.TargetID, CSV_ItemCompose.TargetStarLevel)
			local param = {
				nType = ComposeTypeDefine.MATERIAL_TYPE, --合成界面
				itemId = CSV_ItemCompose.TargetID, 
				itemStar = CSV_ItemCompose.TargetStarLevel, 
				detailType = macro_pb.ITEM_TYPE_MATERIAL,--道具
				name = CSV_ItemBase.Name
			}
			g_WndMgr:showWnd("Game_ItemDropGuide",param)
        elseif nDetailBtnOption == tbDetailBtnOption.DropGuide then
			local tbCsvBase = GameObj:getCsvBase()
			local nTag = nGameObjType
			if nTag == 4 or nTag == 5 then --[[ 4 碎片 5 配方 这里的数据是按背包 按钮顺序来的]]
				nTag = macro_pb.ITEM_TYPE_MATERIAL
			elseif nTag == 6 then 
				nTag = macro_pb.ITEM_TYPE_CARD_GOD
			elseif nTag == 7 then 
				nTag = macro_pb.ITEM_TYPE_SOUL	
			end
			local param = {
				nType = ComposeTypeDefine.DEBRIS_TYPE,
				itemId = GameObj:getCsvID(),
				itemStar = GameObj:getStarLevel(),
				detailType = nTag,
				name = tbCsvBase.Name
			}
			g_WndMgr:showWnd("Game_ItemDropGuide",param)
			
        elseif nDetailBtnOption == tbDetailBtnOption.Sell then
            g_ClientMsgTips:showConfirmInputNumber(_T("出售数量"), self.nHaveNum, onClick_Confirm, nil, self.nHaveNum)
		 elseif nDetailBtnOption == tbDetailBtnOption.ComposeCrystal then
			--重铸晶石的合成规则跟别的不一样，改动时注意跟策划确认
			local tbCsvBase = GameObj:getCsvBase()
			if tbCsvBase.StarLevel < 5 then
				local CSV_ItemCompose = g_DataMgr:getItemComposeCsvByMaterialID(tbCsvBase.ID, tbCsvBase.StarLevel)
				local CSV_ItemBase = g_DataMgr:getItemBaseCsv(CSV_ItemCompose.TargetID, CSV_ItemCompose.TargetStarLevel)
				local param = {nType = ComposeTypeDefine.MATERIAL_TYPE, itemId = CSV_ItemCompose.TargetID, itemStar = CSV_ItemCompose.TargetStarLevel, detailType = macro_pb.ITEM_TYPE_MATERIAL, name = CSV_ItemBase.Name}
				g_WndMgr:showWnd("Game_ItemDropGuide",param)
			else
				local param = {nType = ComposeTypeDefine.MATERIAL_TYPE, itemId = tbCsvBase.ID, itemStar = tbCsvBase.StarLevel, detailType = macro_pb.ITEM_TYPE_MATERIAL, name = tbCsvBase.Name}
				g_WndMgr:showWnd("Game_ItemDropGuide",param)
			end
        end
    end
	g_SetBtnWithOpenCheck(Button_Detail, nDetailBtnOption, onClick_Button_Detail, true)
end

function Game_Package1:getItemGoodsAmmount(nPackagePageType)
	--这里的数据填充还需要再优化一次，等有空再搞
    if nPackagePageType == g_ItemTypeInPackage.All then
        self.tbPackageItemList = {}
        
		 --可使用道具
        local tbGameObjList = g_Hero:getUseItemListSortAscend()
        for nIndex = 1, #tbGameObjList do
			table.insert(self.tbPackageItemList, {GameObj = tbGameObjList[nIndex], nGameObjType = g_ItemTypeInPackage.UseItem})
        end

        --材料
        tbGameObjList = g_Hero:getMaterialItemListSortAscend()
        for nIndex = 1, #tbGameObjList do
			table.insert(self.tbPackageItemList, {GameObj = tbGameObjList[nIndex], nGameObjType = g_ItemTypeInPackage.Materail })
        end

		--技能碎片
        tbGameObjList = g_Hero:getFragItemListSortAscend()
        for nIndex = 1, #tbGameObjList do
			table.insert(self.tbPackageItemList, {GameObj = tbGameObjList[nIndex], nGameObjType = g_ItemTypeInPackage.SkillFrag })
        end

        --配方
		tbGameObjList = g_Hero:getFormulaItemListSortAscend()
        for nIndex = 1, #tbGameObjList do
			table.insert(self.tbPackageItemList, {GameObj = tbGameObjList[nIndex], nGameObjType = g_ItemTypeInPackage.Formula})
        end

        --魂魄
        tbGameObjList = g_Hero:getHunPoListSortAscend()
        for nIndex = 1, #tbGameObjList do
            table.insert(self.tbPackageItemList, {GameObj = tbGameObjList[nIndex], nGameObjType = g_ItemTypeInPackage.HunPo})
        end

        --元神 getCsvBase()
        tbGameObjList = g_Hero:getSoulListSortAscend()
        for nIndex = 1, #tbGameObjList do
            table.insert(self.tbPackageItemList, {GameObj = tbGameObjList[nIndex], nGameObjType = g_ItemTypeInPackage.CardSoul})
        end
    elseif nPackagePageType == g_ItemTypeInPackage.UseItem then
        self.tbPackageItemList = {}
        local tbGameObjList = g_Hero:getUseItemListSortAscend()
        for nIndex = 1, #tbGameObjList do
			local tbCsvBase = tbGameObjList[nIndex]:getCsvBase()
            if tbCsvBase and tbCsvBase.Type == NUM_ItemBaseType.CanUseItem or tbCsvBase.Type == NUM_ItemBaseType.EquipPackAll or tbCsvBase.Type == NUM_ItemBaseType.CardExpItem then
				table.insert(self.tbPackageItemList, {GameObj = tbGameObjList[nIndex], nGameObjType = g_ItemTypeInPackage.UseItem})
			end
        end
    elseif nPackagePageType == g_ItemTypeInPackage.Materail then
        self.tbPackageItemList = {}
        local tbGameObjList = g_Hero:getMaterialItemListSortAscend()
        for nIndex = 1, #tbGameObjList do
			local tbCsvBase = tbGameObjList[nIndex]:getCsvBase()
            if tbCsvBase and tbCsvBase.Type == NUM_ItemBaseType.Material then
				table.insert(self.tbPackageItemList, {GameObj = tbGameObjList[nIndex], nGameObjType = g_ItemTypeInPackage.Materail})
			end
        end
	 elseif nPackagePageType == g_ItemTypeInPackage.SkillFrag then
        self.tbPackageItemList = {}
        local tbGameObjList = g_Hero:getFragItemListSortAscend()
        for nIndex = 1, #tbGameObjList do
			local tbCsvBase = tbGameObjList[nIndex]:getCsvBase()
            if tbCsvBase and tbCsvBase.Type == NUM_ItemBaseType.SkillFrag then
				table.insert(self.tbPackageItemList, {GameObj = tbGameObjList[nIndex], nGameObjType = g_ItemTypeInPackage.SkillFrag})
			end
        end
    elseif nPackagePageType == g_ItemTypeInPackage.Formula then
        self.tbPackageItemList = {}
        local tbGameObjList = g_Hero:getFormulaItemListSortAscend()
        for nIndex = 1, #tbGameObjList do
			local tbCsvBase = tbGameObjList[nIndex]:getCsvBase()
            if tbCsvBase and tbCsvBase.Type == NUM_ItemBaseType.EquipFormula then
				table.insert(self.tbPackageItemList, {GameObj = tbGameObjList[nIndex], nGameObjType = g_ItemTypeInPackage.Formula})
			end
        end
    elseif nPackagePageType == g_ItemTypeInPackage.HunPo then
		self.tbPackageItemList = {}
        local tbGameObjList = g_Hero:getHunPoListSortAscend()
        for nIndex = 1, #tbGameObjList do
			table.insert(self.tbPackageItemList, {GameObj = tbGameObjList[nIndex], nGameObjType = g_ItemTypeInPackage.HunPo})
        end
    elseif nPackagePageType == g_ItemTypeInPackage.CardSoul then
		self.tbPackageItemList = {}
        local tbGameObjList = g_Hero:getSoulListSortAscend()
        for nIndex = 1, #tbGameObjList do
			table.insert(self.tbPackageItemList, {GameObj = tbGameObjList[nIndex], nGameObjType = g_ItemTypeInPackage.CardSoul})
        end
    end

    return #self.tbPackageItemList
end

g_LuaListView_Package_Index = 1
function Game_Package1:onAdjustListView(ListViewItem, nIndex)
	g_LuaListView_Package_Index = nIndex
end

function Game_Package1:getCheckBoxEvent()
    local function onClick_CheckBox(nPackagePageType, pSender)
        local nItemGoods = self:getItemGoodsAmmount(nPackagePageType)
        self.nPackagePageType = nPackagePageType
		
		g_LuaListView_Package_Index = g_LuaListView_Package_Index or 1
		self.LuaListView_Package:setAdjustFunc(handler(self, self.onAdjustListView))
        self.LuaListView_Package:updateItems(math.floor((nItemGoods+3)/4), g_LuaListView_Package_Index)
		
		self.Image_CheckCover = nil
        for nIndex = 1, #self.CheckBoxGroup_Package.cblist do
            local widgetCheckBox = self.CheckBoxGroup_Package.cblist[nIndex].cb
            if widgetCheckBox then
                widgetCheckBox:setZOrder(0)
            end
        end
		self.CheckIndex = pSender:getTag()
        pSender:setZOrder(10)
    end

    return onClick_CheckBox
end

function Game_Package1:setAllItemRow(Panel_EuipeRow, nRowIndex)
    local nBeginRowIndex = (nRowIndex-1)*4
    for nColumn = 1, 4 do
		local Button_EquipIconBase = tolua.cast(Panel_EuipeRow:getChildByName("Button_EquipIconBase"..nColumn), "Button")
		local Image_CheckCover = tolua.cast(Button_EquipIconBase:getChildByName("Image_CheckCover"), "ImageView")
		Image_CheckCover:setVisible(false)
		
		local widgetChild = Button_EquipIconBase:getChildByName("ItemModel")
		if widgetChild then
		   widgetChild:removeFromParent()
		end
		
        local tbPackageItem = self.tbPackageItemList[nBeginRowIndex + nColumn]
        if tbPackageItem then
			local widgetChild = nil
            local nGameObjType = tbPackageItem.nGameObjType
            if nGameObjType == g_ItemTypeInPackage.UseItem then
				local tbCsvBase = tbPackageItem.GameObj:getCsvBase()
				if tbCsvBase.Type == NUM_ItemBaseType.CanUseItem or tbCsvBase.Type == NUM_ItemBaseType.CardExpItem then
					widgetChild = tolua.cast(g_WidgetModel.Image_PackageIconUseItem:clone(), "ImageView")
				elseif tbCsvBase.Type == NUM_ItemBaseType.EquipPackAll then
					widgetChild = tolua.cast(g_WidgetModel.Image_PackageIconEquipPack:clone(), "ImageView")
				end
				self:setItemColumnIcon(widgetChild, tbPackageItem.GameObj, Button_EquipIconBase,nGameObjType)
            elseif nGameObjType == g_ItemTypeInPackage.Materail 
				or nGameObjType == g_ItemTypeInPackage.SkillFrag
				or nGameObjType == g_ItemTypeInPackage.Formula
				or nGameObjType == g_ItemTypeInPackage.HunPo
				or nGameObjType == g_ItemTypeInPackage.CardSoul then
		
				widgetChild = tolua.cast(g_WidgetModel[tbItemImageName[nGameObjType]]:clone(), "ImageView")
                self:setItemColumnIcon(widgetChild, tbPackageItem.GameObj, Button_EquipIconBase,nGameObjType)
            end
			
			widgetChild:setScale(0.95)
			widgetChild:setName("ItemModel")
			widgetChild:setPositionXY(0, 0)
			
            Button_EquipIconBase:addChild(widgetChild)
			Button_EquipIconBase:setTag(nGameObjType)
		else
			Button_EquipIconBase:setTag(-1)
        end
   end
end

function Game_Package1:setItemColumnIcon(widgetChild, GameObj, Button_EquipIconBase,typeKey)
	local tbCsvBase = nil
	local nColorType = 0
	if typeKey == g_ItemTypeInPackage.Materail
		or typeKey == g_ItemTypeInPackage.SkillFrag 
		or typeKey == g_ItemTypeInPackage.Formula 
		or typeKey == g_ItemTypeInPackage.UseItem then
		tbCsvBase = GameObj:getCsvBase()
		nColorType = tbCsvBase.ColorType
	elseif typeKey == g_ItemTypeInPackage.CardSoul then
		tbCsvBase = GameObj:getCsvBase()
		nColorType = tbCsvBase.StarLevel
	elseif typeKey == g_ItemTypeInPackage.HunPo then
		tbCsvBase = GameObj:getCardBase()
		nColorType = tbCsvBase.StarLevel
	end
	local image = tolua.cast(widgetChild, "ImageView")
	image:loadTexture(getFrameBackGround(nColorType))
	
	local Image_Frame = tolua.cast(widgetChild:getChildByName("Image_Frame"), "ImageView")
	Image_Frame:loadTexture(getIconFrame(nColorType))

	local Label_HaveNum = tolua.cast(widgetChild:getChildByName("Label_HaveNum"), "Label")
	Label_HaveNum:setText(GameObj:getNum())
	
	local Image_Icon = tolua.cast(widgetChild:getChildByName("Image_Icon"), "ImageView")
	if typeKey == g_ItemTypeInPackage.Materail
		or typeKey == g_ItemTypeInPackage.SkillFrag 
		or typeKey == g_ItemTypeInPackage.UseItem --[[道具]] then
		
		Image_Icon:loadTexture(getIconImg(tbCsvBase.Icon))
		if tbCsvBase.Type == NUM_ItemBaseType.EquipPackAll then
			equipSacleAndRotate(Image_Icon,tbCsvBase.FormulaType)
			local Image_Symbol = tolua.cast(widgetChild:getChildByName("Image_Symbol"), "ImageView")
			Image_Symbol:loadTexture(getIconImg("ResourceItem_MaterialPack"..nColorType))
			
			local Image_IconTag = tolua.cast(widgetChild:getChildByName("Image_IconTag"), "ImageView")
			if tbCsvBase.SubType == NUM_ItemBaseSubType.EquipPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..(math.mod(tbCsvBase.ID, 100) - 1)))
			else
				Image_IconTag:setVisible(false)
			end
		elseif tbCsvBase.Type == NUM_ItemBaseType.CanUseItem or tbCsvBase.Type == NUM_ItemBaseType.CardExpItem then
			local Image_IconTag = tolua.cast(widgetChild:getChildByName("Image_IconTag"), "ImageView")
			if tbCsvBase.SubType == NUM_ItemBaseSubType.EquipMaterialPack or tbCsvBase.SubType == NUM_ItemBaseSubType.EquipFormulaPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..tbCsvBase.StarLevel))
			elseif tbCsvBase.SubType == NUM_ItemBaseSubType.SoulMaterialPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_SoulTag_"..tbCsvBase.ColorType.."_"..tbCsvBase.FormulaType))
			elseif tbCsvBase.SubType == NUM_ItemBaseSubType.RandomPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_PackRandTag"..tbCsvBase.ColorType))
			elseif tbCsvBase.SubType == NUM_ItemBaseSubType.SelectedPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_PackSelectTag"..tbCsvBase.ColorType))
			else
				Image_IconTag:setVisible(false)
			end
		elseif tbCsvBase.Type == NUM_ItemBaseType.Material then
			local Image_IconTag = tolua.cast(widgetChild:getChildByName("Image_IconTag"), "ImageView")
			if tbCsvBase.SubType == NUM_ItemBaseSubType.EquipComposeMaterial then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..tbCsvBase.FormulaType))
			else
				Image_IconTag:setVisible(false)
			end
		elseif tbCsvBase.Type == NUM_ItemBaseType.SkillFrag then
			local Image_IconTag = tolua.cast(widgetChild:getChildByName("Image_IconTag"), "ImageView")
			if tbCsvBase.SubType == NUM_ItemBaseSubType.EquipComposeMaterialFrag then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..tbCsvBase.FormulaType))
			else
				Image_IconTag:setVisible(false)
			end
		end
		
	elseif typeKey == g_ItemTypeInPackage.HunPo then --"魂魄" 
		
		Image_Icon:loadTexture(getIconImg(tbCsvBase.SpineAnimation))
		local Image_Cover = tolua.cast(widgetChild:getChildByName("Image_Cover"), "ImageView")
		Image_Cover:loadTexture(getFrameCoverHunPo(nColorType))
		
	elseif typeKey == g_ItemTypeInPackage.CardSoul then --元神
	
		Image_Icon:loadTexture(getIconImg(tbCsvBase.SpineAnimation))
		local Image_Cover = tolua.cast(widgetChild:getChildByName("Image_Cover"), "ImageView")
		Image_Cover:loadTexture(getFrameCoverSoul(nColorType))
		
		local Label_Level = tolua.cast(widgetChild:getChildByName("Label_Level"), "Label")
		Label_Level:setText(_T("Lv.")..tbCsvBase.Level)
		
		local Image_SoulType = tolua.cast(widgetChild:getChildByName("Image_SoulType"), "ImageView")
		if tbCsvBase.Class < 5 then
			Image_SoulType:loadTexture(getUIImg("Image_SoulTag_"..nColorType.."_"..tbCsvBase.FatherLevel))
		else
			Image_SoulType:loadTexture(getEctypeIconResource("FrameEctypeNormalChar", nColorType))
		end
	elseif typeKey == g_ItemTypeInPackage.Formula then --配方
		Image_Icon:loadTexture(getIconImg(tbCsvBase.Icon))
		equipSacleAndRotate(Image_Icon,tbCsvBase.FormulaType)
		
		local Image_Symbol = tolua.cast(widgetChild:getChildByName("Image_Symbol"), "ImageView")
		Image_Symbol:loadTexture(getFrameSymbolFormula(nColorType))
		
		local Image_IconTag = tolua.cast(widgetChild:getChildByName("Image_IconTag"), "ImageView")
		Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..(math.mod(tbCsvBase.ID, 100) - 1)))
		Image_IconTag:setVisible(true)
	end
	
	local function onClick_IconBase(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			if pSender:getTag() ~= NULL_BOX then
				local wndInstance = g_WndMgr:getWnd("Game_Package1")
				if wndInstance then
					wndInstance.Current_Label_HaveNum = Label_HaveNum
					wndInstance:setItemDetailPNL(widgetChild, GameObj, pSender)
				end
			end
		end
	end
	Button_EquipIconBase:setTouchEnabled(true)
	Button_EquipIconBase:addTouchEventListener(onClick_IconBase)
end

function Game_Package1:setItemView(Panel_EuipeRow, nRowIndex,typeKey)
	local nBeginRowIndex = (nRowIndex-1)*4
    for nColumn = 1, 4 do
		local Button_EquipIconBase = tolua.cast(Panel_EuipeRow:getChildByName("Button_EquipIconBase"..nColumn), "Button")
		local Image_CheckCover = tolua.cast(Button_EquipIconBase:getChildByName("Image_CheckCover"), "ImageView")
		Image_CheckCover:setVisible(false)
		
		local widgetChild = Button_EquipIconBase:getChildByName("ItemModel")
		if widgetChild then
		   widgetChild:removeFromParent()
		end
				
		local tbPackageItem = self.tbPackageItemList[nBeginRowIndex + nColumn]
		if tbPackageItem then
			local widgetChild = nil
			if typeKey == g_ItemTypeInPackage.UseItem  then
				local tbCsvBase = tbPackageItem.GameObj:getCsvBase()
				if tbCsvBase.Type == NUM_ItemBaseType.CanUseItem or tbCsvBase.Type == NUM_ItemBaseType.CardExpItem then
					widgetChild = tolua.cast(g_WidgetModel.Image_PackageIconUseItem:clone(), "ImageView")
				elseif tbCsvBase.Type == NUM_ItemBaseType.EquipPackAll then
					widgetChild = tolua.cast(g_WidgetModel.Image_PackageIconEquipPack:clone(), "ImageView")
				end
			else
				widgetChild = tolua.cast(g_WidgetModel[tbItemImageName[typeKey]]:clone(), "ImageView")
			end
			if not widgetChild then cclog("widgetChildwidgetChild") end
			self:setItemColumnIcon(widgetChild, tbPackageItem.GameObj, Button_EquipIconBase,typeKey)
			widgetChild:setScale(0.95)
			widgetChild:setName("ItemModel")
			widgetChild:setPositionXY(0, 0)
			
			Button_EquipIconBase:setTag(tbPackageItem.nGameObjType)
			Button_EquipIconBase:addChild(widgetChild)
		else
			Button_EquipIconBase:setTag(NULL_BOX)
		end
    end
	
end


function Game_Package1:setListViewItem(Panel_EuipeRow, nRowIndex)
    local nPackagePageType = self.nPackagePageType
    if nPackagePageType == g_ItemTypeInPackage.All then
        self:setAllItemRow(Panel_EuipeRow, nRowIndex)
	else
       self:setItemView(Panel_EuipeRow, nRowIndex,nPackagePageType)
    end
end

function Game_Package1:registerListViewEvent(ListView_Package)
    local LuaListView_Package = Class_LuaListView:new()
    LuaListView_Package:setListView(ListView_Package)

    local function updateFunction(widget, nIndex)
        self:setListViewItem(widget, nIndex)
    end
	-- listView:updateItems(nZhenFaNum,place)
    LuaListView_Package:setUpdateFunc(updateFunction)
    LuaListView_Package:setModel(g_WidgetModel.PanelEuipeRow)
    self.LuaListView_Package = LuaListView_Package
end

function Game_Package1:initWnd()
	g_LuaListView_Package_Index = 1
	
	local ImageView_PackagePNL = tolua.cast(self.rootWidget:getChildByName("ImageView_PackagePNL"), "ImageView")
	ImageView_PackagePNL:setVisible(true)
	local ImageView_ItemDetailPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_ItemDetailPNL"), "ImageView")
	ImageView_ItemDetailPNL:setVisible(false)

	local Image_ContentPNL = tolua.cast(ImageView_PackagePNL:getChildByName("Image_ContentPNL"), "ImageView")
	
	self.CheckIndex  =  1
	local CheckBox_All = tolua.cast(Image_ContentPNL:getChildByName("CheckBox_All"), "CheckBox")
	CheckBox_All:setTag(1)
	local CheckBox_FunctionItem = tolua.cast(Image_ContentPNL:getChildByName("CheckBox_FunctionItem"), "CheckBox")
	CheckBox_FunctionItem:setTag(2)
	local CheckBox_Material = tolua.cast(Image_ContentPNL:getChildByName("CheckBox_Material"), "CheckBox")
	CheckBox_Material:setTag(3)
	local CheckBox_SkillFrag = tolua.cast(Image_ContentPNL:getChildByName("CheckBox_SkillFrag"), "CheckBox")
	CheckBox_SkillFrag:setTag(4)
	local CheckBox_Formula = tolua.cast(Image_ContentPNL:getChildByName("CheckBox_Formula"), "CheckBox")
	CheckBox_Formula:setTag(5)
	local CheckBox_HunPo = tolua.cast(Image_ContentPNL:getChildByName("CheckBox_HunPo"), "CheckBox")
	CheckBox_HunPo:setTag(6)
    local CheckBox_Soul = tolua.cast(Image_ContentPNL:getChildByName("CheckBox_Soul"), "CheckBox")
	CheckBox_Soul:setTag(7)
    local ListView_Package = tolua.cast(Image_ContentPNL:getChildByName("ListView_Package"), "ListViewEx")
	
	if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		local BitmapLabel_FuncName = tolua.cast(CheckBox_All:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
		BitmapLabel_FuncName:setScale(0.75)
		local BitmapLabel_FuncName = tolua.cast(CheckBox_FunctionItem:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
		BitmapLabel_FuncName:setScale(0.75)
		local BitmapLabel_FuncName = tolua.cast(CheckBox_Material:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
		BitmapLabel_FuncName:setScale(0.75)
		local BitmapLabel_FuncName = tolua.cast(CheckBox_SkillFrag:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
		BitmapLabel_FuncName:setScale(0.75)
		local BitmapLabel_FuncName = tolua.cast(CheckBox_Formula:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
		BitmapLabel_FuncName:setScale(0.75)
		local BitmapLabel_FuncName = tolua.cast(CheckBox_HunPo:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
		BitmapLabel_FuncName:setScale(0.75)
		local BitmapLabel_FuncName = tolua.cast(CheckBox_Soul:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
		BitmapLabel_FuncName:setScale(0.75)
	end
	
    self:registerListViewEvent(ListView_Package)

	self.CheckBoxGroup_Package = CheckBoxGroup:New()
    local func = self:getCheckBoxEvent()
	self.CheckBoxGroup_Package:PushBack(CheckBox_All, func)
	self.CheckBoxGroup_Package:PushBack(CheckBox_FunctionItem, func)
    self.CheckBoxGroup_Package:PushBack(CheckBox_Material, func)
	self.CheckBoxGroup_Package:PushBack(CheckBox_SkillFrag, func)
	self.CheckBoxGroup_Package:PushBack(CheckBox_Formula, func)
	self.CheckBoxGroup_Package:PushBack(CheckBox_HunPo, func)
    self.CheckBoxGroup_Package:PushBack(CheckBox_Soul, func)
end

function Game_Package1:closeWnd()
    self.LuaListView_Package:updateItems(0)
	self.Image_CheckCover = nil
end

function Game_Package1:openWnd()
	if g_bReturn then return end
	self.Current_Label_HaveNum = nil
    self.CheckBoxGroup_Package:Click(self.CheckIndex)

	local ImageView_PackagePNL = tolua.cast(self.rootWidget:getChildByName("ImageView_PackagePNL"), "ImageView")
	ImageView_PackagePNL:setVisible(true)
end

function Game_Package1:showWndOpenAnimation(funcWndOpenAniCall)
	local ImageView_PackagePNL = tolua.cast(self.rootWidget:getChildByName("ImageView_PackagePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(ImageView_PackagePNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
	mainWnd:showMainHomeZoomInAnimation()
end

function Game_Package1:showWndCloseAnimation(funcWndCloseAniCall)
	local function actionEndCallBack()
		local ImageView_PackagePNL = tolua.cast(self.rootWidget:getChildByName("ImageView_PackagePNL"), "ImageView")
		local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
		local function actionEndCall()
			if funcWndCloseAniCall then
				funcWndCloseAniCall()
			end
			mainWnd:showMainHomeZoomOutAnimation()
		end
		g_CreateUIDisappearAnimation_Scale(ImageView_PackagePNL, actionEndCall, 1.05, 0.15, Image_Background)	
	end
	self:ItemDetailPNLAction("close",actionEndCallBack)
end