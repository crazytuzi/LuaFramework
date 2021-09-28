--------------------------------------------------------------------------------------
-- 文件名:	CTipDropItem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	陆奎安
-- 日  期:	2015-1-15 9:24
-- 版  本:	1.0
-- 描  述:	Tip界面
-- 应  用:  
---------------------------------------------------------------------------------------

local function setWidegtSize(widegt, lable)  
	local lableSize = lable:getSize()
	local nHeight = lableSize.height - 30
	local pos = widegt:getPosition()
	local widSize = widegt:getSize()
	widegt:setSize(CCSizeMake(widSize.width, 240 + nHeight))
	widegt:setPosition(ccp(pos.x, pos.y + nHeight/2))
end

Game_TipDropItemCard = class("Game_TipDropItemCard")
Game_TipDropItemCard.__index = Game_TipDropItemCard
function Game_TipDropItemCard:initWnd()
end
function Game_TipDropItemCard:closeWnd()
end
function Game_TipDropItemCard:openWnd(CSV_DropItem)
	if not CSV_DropItem then return end
	local CSV_CardBase = g_DataMgr:getCardBaseCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_CardBase then return end
	
	local Image_TipDropItemCardPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemCardPNL"), "ImageView")
	local Label_Name = tolua.cast(Image_TipDropItemCardPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(_T("伙伴：")..CSV_CardBase.Name)
	g_SetCardNameColorByEvoluteLev(Label_Name, CSV_DropItem.DropItemEvoluteLevel)
	
	local Label_Profession = tolua.cast(Image_TipDropItemCardPNL:getChildByName("Label_Profession"), "Label")
	Label_Profession:setText(g_Profession[CSV_CardBase.Profession])
	
	local Label_Desc = tolua.cast(Image_TipDropItemCardPNL:getChildByName("Label_Desc"), "Label")
	if not CSV_DropItem.DropItemDesc then
		local desc = _T("可获得伙伴【")..CSV_CardBase.Name.._T("】, 如已拥有该伙伴系统将会自动转换为魂魄。")
		Label_Desc:setText(g_stringSize_insert(desc,"\n",21,678))
	else
		Label_Desc:setText(g_stringSize_insert(CSV_DropItem.DropItemDesc,"\n",21,678))
	end
	
	local Image_DropCard = tolua.cast(Image_TipDropItemCardPNL:getChildByName("Image_DropCard"), "ImageView")
	Image_DropCard:loadTexture(getCardBackByEvoluteLev(CSV_DropItem.DropItemEvoluteLevel))
	
	local Image_Frame = tolua.cast(Image_DropCard:getChildByName("Image_Frame"), "ImageView")
	Image_Frame:loadTexture(getCardFrameByEvoluteLev(CSV_DropItem.DropItemEvoluteLevel))
	
	local Image_DropIcon = tolua.cast(Image_DropCard:getChildByName("Image_DropIcon"), "ImageView")
	Image_DropIcon:loadTexture(getIconImg(CSV_CardBase.SpineAnimation))
	
	local Image_StarLevel = tolua.cast(Image_DropCard:getChildByName("Image_StarLevel"), "ImageView")
	Image_StarLevel:loadTexture(getIconStarLev(CSV_DropItem.DropItemStarLevel))

	setWidegtSize(Image_TipDropItemCardPNL, Label_Desc)
end

function Game_TipDropItemCard:ModifyWnd_viet_VIET()
    local Label_ProfessionLB = self.rootWidget:getChildAllByName("Label_ProfessionLB")
	local Label_Profession = self.rootWidget:getChildAllByName("Label_Profession")
    g_AdjustWidgetsPosition({Label_ProfessionLB, Label_Profession}, 2)
end

function Game_TipDropItemCard:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipDropItemCardPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemCardPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipDropItemCardPNL, funcWndOpenAniCall, 1.05, 0.2)
end
function Game_TipDropItemCard:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipDropItemCardPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemCardPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipDropItemCardPNL, funcWndCloseAniCall, 1.05, 0.2)
end

Game_TipDropItemEquip = class("Game_TipDropItemEquip")
Game_TipDropItemEquip.__index = Game_TipDropItemEquip
function Game_TipDropItemEquip:initWnd()
end
function Game_TipDropItemEquip:closeWnd()
end
function Game_TipDropItemEquip:openWnd(CSV_Equip)
	if not CSV_Equip then return end
	
	local Image_TipDropItemEquipPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemEquipPNL"), "ImageView")
	
	local Label_Name = tolua.cast(Image_TipDropItemEquipPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(_T("装备")..CSV_Equip.Name)
	g_SetWidgetColorBySLev(Label_Name, CSV_Equip.ColorType)
	
	local Label_MainProp = tolua.cast(Image_TipDropItemEquipPNL:getChildByName("Label_MainProp"), "Label")
	Label_MainProp:setText(g_tbEquipMainProp[CSV_Equip.SubType].." +"..CSV_Equip.BaseMainProp)  
	
	local Label_Desc = tolua.cast(Image_TipDropItemEquipPNL:getChildByName("Label_Desc"), "Label")
	Label_Desc:setText(g_stringSize_insert(CSV_Equip.Desc,"\n",21,678))
	
	local Image_EuipeBase = tolua.cast(Image_TipDropItemEquipPNL:getChildByName("Image_EuipeBase"), "ImageView")
	Image_EuipeBase:loadTexture(getEquipLightImg(CSV_Equip.ColorType))
	
	local Image_DropIcon = tolua.cast(Image_TipDropItemEquipPNL:getChildByName("Image_DropIcon"), "ImageView")
	Image_DropIcon:loadTexture(getIconImg(CSV_Equip.Icon))
	equipSacleAndRotate(Image_DropIcon, CSV_Equip.SubType)
	
	local Image_IconTag = tolua.cast(Image_TipDropItemEquipPNL:getChildByName("Image_IconTag"), "ImageView")
	Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..(CSV_Equip.StarLevel-1)))
	
	setWidegtSize(Image_TipDropItemEquipPNL,Label_Desc)  
end
function Game_TipDropItemEquip:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipDropItemEquipPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemEquipPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipDropItemEquipPNL, funcWndOpenAniCall, 1.05, 0.2)
end
function Game_TipDropItemEquip:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipDropItemEquipPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemEquipPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipDropItemEquipPNL, funcWndCloseAniCall, 1.05, 0.2)
end

Game_TipDropItemFate = class("Game_TipDropItemFate")
Game_TipDropItemFate.__index = Game_TipDropItemFate
function Game_TipDropItemFate:initWnd()
end
function Game_TipDropItemFate:closeWnd()
end
function Game_TipDropItemFate:openWnd(CSV_CardFate)
	if not CSV_CardFate then return end
	
	local Image_TipDropItemFatePNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemFatePNL"), "ImageView")
	
	local Label_Name = tolua.cast(Image_TipDropItemFatePNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(CSV_CardFate.Name)
	g_SetWidgetColorBySLev(Label_Name, CSV_CardFate.ColorType)
	
	local Label_MainProp = tolua.cast(Image_TipDropItemFatePNL:getChildByName("Label_MainProp"), "Label")
	Label_MainProp:setText(g_tbFatePropName[CSV_CardFate.Type].."+"..CSV_CardFate.PropValue)
	
	local Label_Desc = tolua.cast(Image_TipDropItemFatePNL:getChildByName("Label_Desc"), "Label")
	Label_Desc:setText(g_stringSize_insert(CSV_CardFate.Desc,"\n",21,678))
	
	local Label_FateExp = tolua.cast(Image_TipDropItemFatePNL:getChildByName("Label_FateExp"), "Label")
	if CSV_CardFate.Level > 1 then
		local CSV_DataLastLevel = g_DataMgr:getCardFateCsv(CSV_CardFate.ID, CSV_CardFate.Level-1)
		Label_FateExp:setText(_T("经验 0/")..(CSV_CardFate.FullLevelExp-CSV_DataLastLevel.FullLevelExp))
	else
		Label_FateExp:setText(_T("经验 0/")..(CSV_CardFate.FullLevelExp))
	end
	
	local Image_FateBase = tolua.cast(Image_TipDropItemFatePNL:getChildByName("Image_FateBase"), "ImageView")
	Image_FateBase:loadTexture(getEquipLightImg(CSV_CardFate.ColorType))
	
	local Image_DropIcon = tolua.cast(Image_TipDropItemFatePNL:getChildByName("Image_DropIcon"), "ImageView")
	Image_DropIcon:setPosition(ccp(-280+CSV_CardFate.OffsetX, -85+CSV_CardFate.OffsetY))
	Image_DropIcon:loadTexture(getIconImg(CSV_CardFate.Animation))

	setWidegtSize(Image_TipDropItemFatePNL, Label_Desc)  
end
function Game_TipDropItemFate:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipDropItemFatePNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemFatePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipDropItemFatePNL, funcWndOpenAniCall, 1.05, 0.2)
end
function Game_TipDropItemFate:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipDropItemFatePNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemFatePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipDropItemFatePNL, funcWndCloseAniCall, 1.05, 0.2)
end

Game_TipDropItemHunPo = class("Game_TipDropItemHunPo")
Game_TipDropItemHunPo.__index = Game_TipDropItemHunPo
function Game_TipDropItemHunPo:initWnd()
end
function Game_TipDropItemHunPo:closeWnd()
end
function Game_TipDropItemHunPo:openWnd(CSV_DropItem)
	if not CSV_DropItem then return end
	
	local CSV_CardHunPo = g_DataMgr:getCardHunPoCsv(CSV_DropItem.DropItemID)
	if not CSV_CardHunPo then return end
	local CSV_CardBase = g_DataMgr:getCardBaseCsv(CSV_DropItem.DropItemID, CSV_CardHunPo.CardStarLevel)
	if not CSV_CardBase then return end
	
	local Image_TipDropItemHunPoPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemHunPoPNL"), "ImageView")
	
	local Label_Name = tolua.cast(Image_TipDropItemHunPoPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(CSV_CardHunPo.Name)
	g_SetWidgetColorBySLev(Label_Name, CSV_CardHunPo.CardStarLevel)
	
	local Image_StarLevel = tolua.cast(Image_TipDropItemHunPoPNL:getChildByName("Image_StarLevel"), "ImageView")
	Image_StarLevel:loadTexture(getIconStarLev(CSV_CardHunPo.CardStarLevel))
	
	local Label_Desc = tolua.cast(Image_TipDropItemHunPoPNL:getChildByName("Label_Desc"), "Label")
	Label_Desc:setText(g_stringSize_insert(CSV_CardHunPo.Desc,"\n",21,678))
	
	local Image_DropHunPoItem = tolua.cast(Image_TipDropItemHunPoPNL:getChildByName("Image_DropHunPoItem"), "ImageView")
	Image_DropHunPoItem:loadTexture(getFrameBackGround(CSV_CardHunPo.CardStarLevel))
	
	local Image_Frame = tolua.cast(Image_DropHunPoItem:getChildByName("Image_Frame"), "ImageView")
	Image_Frame:loadTexture(getIconFrame(CSV_CardHunPo.CardStarLevel))
	
	local Image_DropIcon = tolua.cast(Image_DropHunPoItem:getChildByName("Image_DropIcon"), "ImageView")
	Image_DropIcon:loadTexture(getIconImg(CSV_CardBase.SpineAnimation))
	
	local Image_Cover = tolua.cast(Image_DropHunPoItem:getChildByName("Image_Cover"), "ImageView")
	Image_Cover:loadTexture(getFrameCoverHunPo(CSV_CardHunPo.CardStarLevel))
	
	local Label_DropNum = tolua.cast(Image_DropHunPoItem:getChildByName("Label_DropNum"), "Label")
	Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
		
	setWidegtSize(Image_TipDropItemHunPoPNL, Label_Desc)
end
function Game_TipDropItemHunPo:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipDropItemHunPoPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemHunPoPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipDropItemHunPoPNL, funcWndOpenAniCall, 1.05, 0.2)
end
function Game_TipDropItemHunPo:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipDropItemHunPoPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemHunPoPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipDropItemHunPoPNL, funcWndCloseAniCall, 1.05, 0.2)
end

Game_TipDropItemMaterial = class("Game_TipDropItemMaterial")
Game_TipDropItemMaterial.__index = Game_TipDropItemMaterial
function Game_TipDropItemMaterial:initWnd()
end
function Game_TipDropItemMaterial:closeWnd()
end
function Game_TipDropItemMaterial:openWnd(CSV_DropItem)
	if not CSV_DropItem then return end
	
	local CSV_ItemBase = g_DataMgr:getItemBaseCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_ItemBase then return end
	
	local Image_TipDropItemMaterialPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemMaterialPNL"), "ImageView")
	
	local Label_Name = tolua.cast(Image_TipDropItemMaterialPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(_T("材料：")..CSV_ItemBase.Name)
	g_SetWidgetColorBySLev(Label_Name, CSV_ItemBase.ColorType)
	
	local Image_StarLevel = tolua.cast(Image_TipDropItemMaterialPNL:getChildByName("Image_StarLevel"), "ImageView")
	Image_StarLevel:loadTexture(getIconStarLev(CSV_ItemBase.ColorType))
	
	local Label_Desc = tolua.cast(Image_TipDropItemMaterialPNL:getChildByName("Label_Desc"), "Label")
	local strDesc = CSV_ItemBase.Desc..CSV_ItemBase.Desc1
	Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	
	local Image_DropItemMaterial = tolua.cast(Image_TipDropItemMaterialPNL:getChildByName("Image_DropItemMaterial"), "ImageView")
	Image_DropItemMaterial:loadTexture(getFrameBackGround(CSV_ItemBase.ColorType))
	
	local Image_Frame = tolua.cast(Image_DropItemMaterial:getChildByName("Image_Frame"), "ImageView")
	Image_Frame:loadTexture(getIconFrame(CSV_ItemBase.ColorType))
	
	local Image_DropIcon = tolua.cast(Image_DropItemMaterial:getChildByName("Image_DropIcon"), "ImageView")
	Image_DropIcon:loadTexture(getIconImg(CSV_ItemBase.Icon))
	
	local Label_DropNum = tolua.cast(Image_DropItemMaterial:getChildByName("Label_DropNum"), "Label")
	Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	
	local Image_IconTag = tolua.cast(Image_DropItemMaterial:getChildByName("Image_IconTag"), "ImageView")
	if CSV_ItemBase.SubType == NUM_ItemBaseSubType.EquipComposeMaterial then
		Image_IconTag:setVisible(true)
		Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..CSV_ItemBase.FormulaType))
	else
		Image_IconTag:setVisible(false)
	end
	
	setWidegtSize(Image_TipDropItemMaterialPNL, Label_Desc)
end
function Game_TipDropItemMaterial:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipDropItemMaterialPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemMaterialPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipDropItemMaterialPNL, funcWndOpenAniCall, 1.05, 0.2)
end
function Game_TipDropItemMaterial:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipDropItemMaterialPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemMaterialPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipDropItemMaterialPNL, funcWndCloseAniCall, 1.05, 0.2)
end

Game_TipDropItemFrag = class("Game_TipDropItemFrag")
Game_TipDropItemFrag.__index = Game_TipDropItemFrag
function Game_TipDropItemFrag:initWnd()
end
function Game_TipDropItemFrag:closeWnd()
end
function Game_TipDropItemFrag:openWnd(CSV_DropItem)
	if not CSV_DropItem then return end
	
	local CSV_ItemBase = g_DataMgr:getItemBaseCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_ItemBase then return end
	
	local Image_TipDropItemFragPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemFragPNL"), "ImageView")
	
	local Label_Name = tolua.cast(Image_TipDropItemFragPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(_T("碎片：")..CSV_ItemBase.Name)
	g_SetWidgetColorBySLev(Label_Name, CSV_ItemBase.ColorType)
	
	local Image_StarLevel = tolua.cast(Image_TipDropItemFragPNL:getChildByName("Image_StarLevel"), "ImageView")
	Image_StarLevel:loadTexture(getIconStarLev(CSV_ItemBase.ColorType))
	
	local Label_Desc = tolua.cast(Image_TipDropItemFragPNL:getChildByName("Label_Desc"), "Label")
	local strDesc = CSV_ItemBase.Desc..CSV_ItemBase.Desc1
	Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	
	local Image_DropItemFrag = tolua.cast(Image_TipDropItemFragPNL:getChildByName("Image_DropItemFrag"), "ImageView")
	Image_DropItemFrag:loadTexture(getFrameBackGround(CSV_ItemBase.ColorType))
	
	local Image_Frame = tolua.cast(Image_DropItemFrag:getChildByName("Image_Frame"), "ImageView")
	Image_Frame:loadTexture(getIconFrame(CSV_ItemBase.ColorType))
	
	local Image_DropIcon = tolua.cast(Image_DropItemFrag:getChildByName("Image_DropIcon"), "ImageView")
	Image_DropIcon:loadTexture(getIconImg(CSV_ItemBase.Icon))
	
	local Image_Symbol = tolua.cast(Image_DropItemFrag:getChildByName("Image_Symbol"), "ImageView")
	Image_Symbol:loadTexture(getFrameSymbolSkillFrag(CSV_ItemBase.ColorType))
	
	local Label_DropNum = tolua.cast(Image_DropItemFrag:getChildByName("Label_DropNum"), "Label")
	Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	
	local Image_IconTag = tolua.cast(Image_DropItemFrag:getChildByName("Image_IconTag"), "ImageView")
	if CSV_ItemBase.SubType == NUM_ItemBaseSubType.EquipComposeMaterialFrag then
		Image_IconTag:setVisible(true)
		Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..CSV_ItemBase.FormulaType))
	else
		Image_IconTag:setVisible(false)
	end
	
	setWidegtSize(Image_TipDropItemFragPNL, Label_Desc)
end
function Game_TipDropItemFrag:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipDropItemFragPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemFragPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipDropItemFragPNL, funcWndOpenAniCall, 1.05, 0.2)
end
function Game_TipDropItemFrag:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipDropItemFragPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemFragPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipDropItemFragPNL, funcWndCloseAniCall, 1.05, 0.2)
end

Game_TipDropItemUseItem = class("Game_TipDropItemUseItem")
Game_TipDropItemUseItem.__index = Game_TipDropItemUseItem
function Game_TipDropItemUseItem:initWnd()
end
function Game_TipDropItemUseItem:closeWnd()
end
function Game_TipDropItemUseItem:openWnd(CSV_DropItem)
	if not CSV_DropItem then return end
	
	local CSV_ItemBase = g_DataMgr:getItemBaseCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_ItemBase then return end
	
	local Image_TipDropItemUseItemPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemUseItemPNL"), "ImageView")
	
	local Label_Name = tolua.cast(Image_TipDropItemUseItemPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(_T("道具：")..CSV_ItemBase.Name)
	g_SetWidgetColorBySLev(Label_Name, CSV_ItemBase.ColorType)
	
	local Image_StarLevel = tolua.cast(Image_TipDropItemUseItemPNL:getChildByName("Image_StarLevel"), "ImageView")
	Image_StarLevel:loadTexture(getIconStarLev(CSV_ItemBase.ColorType))
	
	local Label_Desc = tolua.cast(Image_TipDropItemUseItemPNL:getChildByName("Label_Desc"), "Label")
	Label_Desc:setText(g_stringSize_insert(CSV_ItemBase.Desc,"\n",21,678))
	
	local Image_DropItemUseItem = tolua.cast(Image_TipDropItemUseItemPNL:getChildByName("Image_DropItemUseItem"), "ImageView")
	Image_DropItemUseItem:loadTexture(getFrameBackGround(CSV_ItemBase.ColorType))
	
	local Image_Frame = tolua.cast(Image_DropItemUseItem:getChildByName("Image_Frame"), "ImageView")
	Image_Frame:loadTexture(getIconFrame(CSV_ItemBase.ColorType))
	
	local Image_DropIcon = tolua.cast(Image_DropItemUseItem:getChildByName("Image_DropIcon"), "ImageView")
	Image_DropIcon:loadTexture(getIconImg(CSV_ItemBase.Icon))
	
	local Label_DropNum = tolua.cast(Image_DropItemUseItem:getChildByName("Label_DropNum"), "Label")
	Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	
	local Image_IconTag = tolua.cast(Image_DropItemUseItem:getChildByName("Image_IconTag"), "ImageView")
	if CSV_ItemBase.SubType == NUM_ItemBaseSubType.EquipMaterialPack or CSV_ItemBase.SubType == NUM_ItemBaseSubType.EquipFormulaPack then
		Image_IconTag:setVisible(true)
		Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..CSV_ItemBase.StarLevel))
	elseif CSV_ItemBase.SubType == NUM_ItemBaseSubType.SoulMaterialPack then
		Image_IconTag:setVisible(true)
		Image_IconTag:loadTexture(getUIImg("Image_SoulTag_"..CSV_ItemBase.ColorType.."_"..CSV_ItemBase.FormulaType))
	elseif CSV_ItemBase.SubType == NUM_ItemBaseSubType.RandomPack then
		Image_IconTag:setVisible(true)
		Image_IconTag:loadTexture(getUIImg("Image_PackRandTag"..CSV_ItemBase.ColorType))
	elseif CSV_ItemBase.SubType == NUM_ItemBaseSubType.SelectedPack then
		Image_IconTag:setVisible(true)
		Image_IconTag:loadTexture(getUIImg("Image_PackSelectTag"..CSV_ItemBase.ColorType))
	else
		Image_IconTag:setVisible(false)
	end
	
	setWidegtSize(Image_TipDropItemUseItemPNL, Label_Desc)
end
function Game_TipDropItemUseItem:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipDropItemUseItemPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemUseItemPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipDropItemUseItemPNL, funcWndOpenAniCall, 1.05, 0.2)
end
function Game_TipDropItemUseItem:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipDropItemUseItemPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemUseItemPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipDropItemUseItemPNL, funcWndCloseAniCall, 1.05, 0.2)
end

Game_TipDropItemFormula = class("Game_TipDropItemFormula")
Game_TipDropItemFormula.__index = Game_TipDropItemFormula
function Game_TipDropItemFormula:initWnd()
end
function Game_TipDropItemFormula:closeWnd()
end
function Game_TipDropItemFormula:openWnd(CSV_DropItem)
	if not CSV_DropItem then return end
	
	local CSV_ItemBase = g_DataMgr:getItemBaseCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_ItemBase then return end
	
	local Image_TipDropItemFormulaPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemFormulaPNL"), "ImageView")
	
	local Label_Name = tolua.cast(Image_TipDropItemFormulaPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(CSV_ItemBase.Name)
	g_SetWidgetColorBySLev(Label_Name, CSV_ItemBase.ColorType)
	
	local Image_StarLevel = tolua.cast(Image_TipDropItemFormulaPNL:getChildByName("Image_StarLevel"), "ImageView")
	Image_StarLevel:loadTexture(getIconStarLev(CSV_ItemBase.ColorType))
	
	local Label_Desc = tolua.cast(Image_TipDropItemFormulaPNL:getChildByName("Label_Desc"), "Label")
	Label_Desc:setText(g_stringSize_insert(CSV_ItemBase.Desc,"\n",21,678))
	
	local Image_DropItemFormula = tolua.cast(Image_TipDropItemFormulaPNL:getChildByName("Image_DropItemFormula"), "ImageView")
	Image_DropItemFormula:loadTexture(getFrameBackGround(CSV_ItemBase.ColorType))
	
	local Image_Frame = tolua.cast(Image_DropItemFormula:getChildByName("Image_Frame"), "ImageView")
	Image_Frame:loadTexture(getIconFrame(CSV_ItemBase.ColorType))
	
	local Image_DropIcon = tolua.cast(Image_DropItemFormula:getChildByName("Image_DropIcon"), "ImageView")
	Image_DropIcon:loadTexture(getIconImg(CSV_ItemBase.Icon))
	equipSacleAndRotate(Image_DropIcon, CSV_ItemBase.FormulaType)
	
	local Image_Symbol = tolua.cast(Image_DropItemFormula:getChildByName("Image_Symbol"), "ImageView")
	Image_Symbol:loadTexture(getFrameSymbolSkillFrag(CSV_ItemBase.ColorType))
	
	local Label_DropNum = tolua.cast(Image_DropItemFormula:getChildByName("Label_DropNum"), "Label")
	Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	
	local Image_IconTag = tolua.cast(Image_DropItemFormula:getChildByName("Image_IconTag"), "ImageView")
	Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..(math.mod(CSV_ItemBase.ID, 100) - 1)))
	
	setWidegtSize(Image_TipDropItemFormulaPNL, Label_Desc)
end
function Game_TipDropItemFormula:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipDropItemFormulaPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemFormulaPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipDropItemFormulaPNL, funcWndOpenAniCall, 1.05, 0.2)
end
function Game_TipDropItemFormula:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipDropItemFormulaPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemFormulaPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipDropItemFormulaPNL, funcWndCloseAniCall, 1.05, 0.2)
end

Game_TipDropItemEquipPack = class("Game_TipDropItemEquipPack")
Game_TipDropItemEquipPack.__index = Game_TipDropItemEquipPack
function Game_TipDropItemEquipPack:initWnd()
end
function Game_TipDropItemEquipPack:closeWnd()
end
function Game_TipDropItemEquipPack:openWnd(CSV_DropItem)
	if not CSV_DropItem then return end
	
	local CSV_ItemBase = g_DataMgr:getItemBaseCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_ItemBase then return end
	
	local Image_TipDropItemEquipPackPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemEquipPackPNL"), "ImageView")
	
	local Label_Name = tolua.cast(Image_TipDropItemEquipPackPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(CSV_ItemBase.Name)
	g_SetWidgetColorBySLev(Label_Name, CSV_ItemBase.ColorType)
	
	local Image_StarLevel = tolua.cast(Image_TipDropItemEquipPackPNL:getChildByName("Image_StarLevel"), "ImageView")
	Image_StarLevel:loadTexture(getIconStarLev(CSV_ItemBase.ColorType))
	
	local Label_Desc = tolua.cast(Image_TipDropItemEquipPackPNL:getChildByName("Label_Desc"), "Label")
	Label_Desc:setText(g_stringSize_insert(CSV_ItemBase.Desc,"\n",21,678))
	
	local Image_DropItemEquipPack = tolua.cast(Image_TipDropItemEquipPackPNL:getChildByName("Image_DropItemEquipPack"), "ImageView")
	Image_DropItemEquipPack:loadTexture(getFrameBackGround(CSV_ItemBase.ColorType))
	
	local Image_Frame = tolua.cast(Image_DropItemEquipPack:getChildByName("Image_Frame"), "ImageView")
	Image_Frame:loadTexture(getIconFrame(CSV_ItemBase.ColorType))
	
	local Image_DropIcon = tolua.cast(Image_DropItemEquipPack:getChildByName("Image_DropIcon"), "ImageView")
	Image_DropIcon:loadTexture(getIconImg(CSV_ItemBase.Icon))
	equipSacleAndRotate(Image_DropIcon, CSV_ItemBase.FormulaType)
	
	local Image_Symbol = tolua.cast(Image_DropItemEquipPack:getChildByName("Image_Symbol"), "ImageView")
	Image_Symbol:loadTexture(getIconImg("ResourceItem_MaterialPack"..CSV_ItemBase.ColorType))
	
	local Label_DropNum = tolua.cast(Image_DropItemEquipPack:getChildByName("Label_DropNum"), "Label")
	Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	
	local Image_IconTag = tolua.cast(Image_DropItemEquipPack:getChildByName("Image_IconTag"), "ImageView")
	Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..(math.mod(CSV_ItemBase.ID, 100) - 1)))
	
	setWidegtSize(Image_TipDropItemEquipPackPNL, Label_Desc)
end
function Game_TipDropItemEquipPack:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipDropItemEquipPackPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemEquipPackPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipDropItemEquipPackPNL, funcWndOpenAniCall, 1.05, 0.2)
end
function Game_TipDropItemEquipPack:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipDropItemEquipPackPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemEquipPackPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipDropItemEquipPackPNL, funcWndCloseAniCall, 1.05, 0.2)
end

Game_TipDropItemSoul = class("Game_TipDropItemSoul")
Game_TipDropItemSoul.__index = Game_TipDropItemSoul
function Game_TipDropItemSoul:initWnd()
end
function Game_TipDropItemSoul:closeWnd()
end
function Game_TipDropItemSoul:openWnd(CSV_DropItem)
	if not CSV_DropItem then return end
	
	local CSV_CardSoul = g_DataMgr:getCardSoulCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
	if not CSV_CardSoul then return end
	
	local Image_TipDropItemSoulPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemSoulPNL"), "ImageView")
	
	local Label_Name = tolua.cast(Image_TipDropItemSoulPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(CSV_CardSoul.Name)
	g_SetWidgetColorBySLev(Label_Name, CSV_DropItem.DropItemStarLevel)
	
	local Image_StarLevel = tolua.cast(Image_TipDropItemSoulPNL:getChildByName("Image_StarLevel"), "ImageView")
	Image_StarLevel:loadTexture(getIconStarLev(CSV_DropItem.DropItemStarLevel))
	
	local nStrLen = string.len(CSV_CardSoul.Name)
	local strName = string.sub(CSV_CardSoul.Name, 10, nStrLen)
	CSV_CardSoul.Desc = strName.._T("的元神，被伙伴吞噬后可为伙伴增加境界经验，从而提高伙伴的境界。")
	local Label_Desc = tolua.cast(Image_TipDropItemSoulPNL:getChildByName("Label_Desc"), "Label")
	Label_Desc:setText(g_stringSize_insert(CSV_CardSoul.Desc,"\n",21,678))
	
	local Image_DropCardSoul = tolua.cast(Image_TipDropItemSoulPNL:getChildByName("Image_DropCardSoul"), "ImageView")
	Image_DropCardSoul:loadTexture(getFrameBackGround(CSV_DropItem.DropItemStarLevel))
	
	local Image_Frame = tolua.cast(Image_DropCardSoul:getChildByName("Image_Frame"), "ImageView")
	Image_Frame:loadTexture(getIconFrame(CSV_DropItem.DropItemStarLevel))
	
	local Image_DropIcon = tolua.cast(Image_DropCardSoul:getChildByName("Image_DropIcon"), "ImageView")
	Image_DropIcon:loadTexture(getIconImg(CSV_CardSoul.SpineAnimation))
	
	local Image_Cover = tolua.cast(Image_DropCardSoul:getChildByName("Image_Cover"), "ImageView")
	Image_Cover:loadTexture(getFrameCoverSoul(CSV_DropItem.DropItemStarLevel))
	
	local Label_DropNum = tolua.cast(Image_DropCardSoul:getChildByName("Label_DropNum"), "Label")
	Label_DropNum:setText("×"..CSV_DropItem.DropItemNum)
	
	local Label_Level = tolua.cast(Image_DropCardSoul:getChildByName("Label_Level"), "Label")
	Label_Level:setText(_T("Lv.")..CSV_CardSoul.Level)
	
	local Image_SoulType = tolua.cast(Image_DropCardSoul:getChildByName("Image_SoulType"), "ImageView")
	if CSV_CardSoul.Class < 5 then
		Image_SoulType:loadTexture(getUIImg("Image_SoulTag_"..CSV_CardSoul.StarLevel.."_"..CSV_CardSoul.FatherLevel))
	else
		Image_SoulType:loadTexture(getEctypeIconResource("FrameEctypeNormalChar", CSV_CardSoul.StarLevel))
	end
	
	setWidegtSize(Image_TipDropItemSoulPNL, Label_Desc)
end
function Game_TipDropItemSoul:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipDropItemSoulPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemSoulPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipDropItemSoulPNL, funcWndOpenAniCall, 1.05, 0.2)
end
function Game_TipDropItemSoul:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipDropItemSoulPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemSoulPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipDropItemSoulPNL, funcWndCloseAniCall, 1.05, 0.2)
end

Game_TipDropItemResource = class("Game_TipDropItemResource")
Game_TipDropItemResource.__index = Game_TipDropItemResource
function Game_TipDropItemResource:initWnd()
end
function Game_TipDropItemResource:closeWnd()
end
function Game_TipDropItemResource:openWnd(CSV_DropItem)
	if not CSV_DropItem then return end
	
	local Image_TipDropItemResourcePNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemResourcePNL"), "ImageView")
	
	local Image_DropResource = tolua.cast(Image_TipDropItemResourcePNL:getChildByName("Image_DropResource"),"ImageView")
	Image_DropResource:loadTexture(getFrameBackGround(CSV_DropItem.DropItemStarLevel))
	
	local Image_Frame = tolua.cast(Image_DropResource:getChildByName("Image_Frame"),"ImageView")
	Image_Frame:loadTexture(getIconFrame(CSV_DropItem.DropItemStarLevel))
	
	local Label_Name = tolua.cast(Image_TipDropItemResourcePNL:getChildByName("Label_Name"), "Label")
	g_SetWidgetColorBySLev(Label_Name, CSV_DropItem.DropItemStarLevel)
	
	local Image_DropIcon = tolua.cast(Image_DropResource:getChildByName("Image_DropIcon"),"ImageView")
	local Label_Desc = tolua.cast(Image_TipDropItemResourcePNL:getChildByName("Label_Desc"), "Label")
	if CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_MASTER_EXP then 	--主角经验
		Label_Name:setText(_T("主角经验"))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop8_YueLi"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("主角经验作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_MASTER_ENERGY then 	--体力
		Label_Name:setText(_T("体力"))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop9_Energy"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("体力作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_COUPONS then 	--点券、元宝
		Label_Name:setText(_T("元宝"))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop10_YuanBao"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("元宝作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_GOLDS then 	--金币、铜钱
		Label_Name:setText(_T("铜钱"))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop11_TongQian"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("铜钱作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_PRESTIGE then 	--声望
		Label_Name:setText(_T("声望"))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop12_Prestige"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("声望作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_KNOWLEDGE then 	--阅历
		Label_Name:setText(_T("阅历"))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop13_Knowledge"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("阅历作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_INCENSE then 	--香贡
		Label_Name:setText(_T("香贡"))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop14_Incense"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("香贡作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_POWER then 	--神力
		Label_Name:setText(_T("神力"))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop19_CardExp"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("神力作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_ARENA_TIME then 	--竞技场挑战次数
		Label_Name:setText(_T("天榜次数"))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop16_ArenaTimes"))
		local strDesc = _T("天榜次数")..CSV_DropItem.DropItemNum.._T("天榜次数作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_ESSENCE then 	--灵力
		Label_Name:setText(_T("灵力"))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop17_Essence"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("灵力作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_FRIENDHEART then 	--友情之心
		Label_Name:setText(_T("友情之心"))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop18_FriendPoints"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("友情之心作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_CARDEXPINBATTLE then 	--伙伴经验
		Label_Name:setText(_T("伙伴经验"))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop19_CardExp"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("伙伴经验作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIAN_LING then 	--仙令
		Label_Name:setText(_T("仙令"))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop20_XianLing"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("仙令作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_DRAGON_BALL then 	--神龙令
		Label_Name:setText(_T("神龙令"))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop21_ShenLongLing"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("神龙令作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ONE_KEY then 	--一键消除
		Label_Name:setText(_T("一键消除"))
		Image_DropIcon:loadTexture(getIconImg("ResourceItem_XiaoChu1"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("次一键消除技能使用次数")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_BA_ZHE then 	--霸者横栏
		Label_Name:setText(_T("霸者横栏"))
		Image_DropIcon:loadTexture(getIconImg("ResourceItem_XiaoChu2"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("次霸者横栏技能使用次数")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_LIAN_SUO then 	--消除连锁
		Label_Name:setText(_T("消除连锁"))
		Image_DropIcon:loadTexture(getIconImg("ResourceItem_XiaoChu3"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("次消除连锁技能使用次数")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_DOU_ZHUAN then 	--斗转星移
		Label_Name:setText(_T("斗转星移"))
		Image_DropIcon:loadTexture(getIconImg("ResourceItem_XiaoChu4"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("次斗转星移技能使用次数")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_DIAN_DAO then 	--颠倒乾坤
		Label_Name:setText(_T("颠倒乾坤"))
		Image_DropIcon:loadTexture(getIconImg("ResourceItem_XiaoChu5"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("次颠倒乾坤技能使用次数")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_METAL then 	--金灵核
		Label_Name:setText(_T("金灵核"))
		Image_DropIcon:loadTexture(getIconImg("ResourceItem_LingHe1"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("个金灵核作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_NATURE then 	--木灵核
		Label_Name:setText(_T("木灵核"))
		Image_DropIcon:loadTexture(getIconImg("ResourceItem_LingHe2"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("个木灵核作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_WATER then 	--水灵核
		Label_Name:setText(_T("水灵核"))
		Image_DropIcon:loadTexture(getIconImg("ResourceItem_LingHe3"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("个水灵核作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_FIRE then 	--火灵核
		Label_Name:setText(_T("火灵核"))
		Image_DropIcon:loadTexture(getIconImg("ResourceItem_LingHe4"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("个火灵核作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_EARTH then 	--土灵核
		Label_Name:setText(_T("土灵核"))
		Image_DropIcon:loadTexture(getIconImg("ResourceItem_LingHe5"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("个土灵核作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_AIR then 	--风灵核
		Label_Name:setText(_T("风灵核"))
		Image_DropIcon:loadTexture(getIconImg("ResourceItem_LingHe6"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("个风灵核作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_LIGHTNING then 	--雷灵核
		Label_Name:setText(_T("雷灵核"))
		Image_DropIcon:loadTexture(getIconImg("ResourceItem_LingHe7"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("个雷灵核作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_SECRET_JIANGHUN then 	--将魂石
		Label_Name:setText(_T("将魂石"))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop40_JiangHunShi"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("个将魂石作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_SECRET_REFRESH_TOKEN then 	--将魂令
		Label_Name:setText(_T("将魂令"))
		Image_DropIcon:loadTexture(getIconImg("ResourceDrop41_RefreshToken"))
		local strDesc = _T("可获得")..CSV_DropItem.DropItemNum.._T("个将魂令作为奖励")
		Label_Desc:setText(g_stringSize_insert(strDesc,"\n",21,678))
	end
end
function Game_TipDropItemResource:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipDropItemResourcePNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemResourcePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipDropItemResourcePNL, funcWndOpenAniCall, 1.05, 0.2)
end
function Game_TipDropItemResource:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipDropItemResourcePNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropItemResourcePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipDropItemResourcePNL, funcWndCloseAniCall, 1.05, 0.2)
end

--[[接口协议
CSV_DropItem = {
	DropItemType,
	DropItemID,
	DropItemStarLevel,
	DropItemNum,
	DropItemEvoluteLevel,
	DropItemDesc, --如果为nil的话则使用默认值
}
]]--
function g_ShowDropItemTip(CSV_DropItem)
	if not CSV_DropItem then return end
	
	if CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_CARD then 	--伙伴
		g_WndMgr:showWnd("Game_TipDropItemCard", CSV_DropItem)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_EQUIP then 	--装备
		local CSV_Equip = g_DataMgr:getEquipCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
		g_WndMgr:showWnd("Game_TipDropItemEquip", CSV_Equip)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_ARRAYMETHOD then 	--阵法(暂时作废)
		--
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_FATE then 	--异兽
		local CSV_CardFate = g_DataMgr:getCardFateCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
		g_WndMgr:showWnd("Game_TipDropItemFate", CSV_CardFate)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_CARD_GOD then 	--魂魄
		g_WndMgr:showWnd("Game_TipDropItemHunPo", CSV_DropItem)
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_MATERIAL then 	--ItemBase(道具)
		local CSV_ItemBase = g_DataMgr:getItemBaseCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
		if not CSV_ItemBase then return nil end
		
		if CSV_ItemBase.Type == 0 then
			g_WndMgr:showWnd("Game_TipDropItemMaterial", CSV_DropItem)
		elseif CSV_ItemBase.Type == 1 then
			g_WndMgr:showWnd("Game_TipDropItemFrag", CSV_DropItem)
		elseif CSV_ItemBase.Type == 2 or CSV_ItemBase.Type == 6 then
			g_WndMgr:showWnd("Game_TipDropItemUseItem", CSV_DropItem)
		elseif CSV_ItemBase.Type == 3 then
			g_WndMgr:showWnd("Game_TipDropItemFormula", CSV_DropItem)
		elseif CSV_ItemBase.Type == 4 then
			g_WndMgr:showWnd("Game_TipDropItemEquipPack", CSV_DropItem)
		else
			g_WndMgr:showWnd("Game_TipDropItemUseItem", CSV_DropItem)
		end
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_SOUL then 	--元神
		g_WndMgr:showWnd("Game_TipDropItemSoul", CSV_DropItem)
	else	--主角资源数值
		g_WndMgr:showWnd("Game_TipDropItemResource", CSV_DropItem)
	end
end

--装备查看的Tip
Game_TipEquipView = class("Game_TipEquipView")
Game_TipEquipView.__index = Game_TipEquipView
function Game_TipEquipView:initWnd()
end
function Game_TipEquipView:closeWnd()
end
function Game_TipEquipView:openWnd(GameObj_Equip)
	if not GameObj_Equip then return end
	
	local CSV_Equip = GameObj_Equip:getCsvBase()
	
	local Image_TipEquipViewPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipEquipViewPNL"), "ImageView")
	
	local Image_Icon = tolua.cast(Image_TipEquipViewPNL:getChildByName("Image_Icon"), "ImageView")
	Image_Icon:loadTexture(getIconImg(CSV_Equip.Icon))
	g_SetEquipSacleTip(Image_Icon, CSV_Equip.SubType)
	
	local Image_EuipeBase = tolua.cast(Image_TipEquipViewPNL:getChildByName("Image_EuipeBase"), "ImageView")
	Image_EuipeBase:loadTexture(getEquipLightImg(CSV_Equip.ColorType))
	
	local Label_Name = tolua.cast(Image_TipEquipViewPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(CSV_Equip.Name)
	g_SetWidgetColorBySLev(Label_Name, CSV_Equip.ColorType)
	
	local BitmapLabel_MainProp = tolua.cast(Image_TipEquipViewPNL:getChildByName("BitmapLabel_MainProp"), "LabelBMFont")
	BitmapLabel_MainProp:setText(GameObj_Equip:getEquipMainPropFloor())
	
	local Label_MainPropName = tolua.cast(Image_TipEquipViewPNL:getChildByName("Label_MainPropName"), "Label")
	Label_MainPropName:setText(g_tbMainPropName[CSV_Equip.SubType])
	g_AdjustWidgetsPosition({BitmapLabel_MainProp,Label_MainPropName},-8)
	
	local nStrengthenLevel = GameObj_Equip:getStrengthenLev()
	local Label_StrengthenLevel = tolua.cast(Image_TipEquipViewPNL:getChildByName("Label_StrengthenLevel"), "Label")
	Label_StrengthenLevel:setText(_T("Lv.")..nStrengthenLevel)
	g_AdjustWidgetsPosition({Label_Name,Label_StrengthenLevel})
		--装备星级
	local rLevel = GameObj_Equip:getRefineLev()
	local Image_RefineLevel = tolua.cast(Image_TipEquipViewPNL:getChildByName("Image_RefineLevel"),"ImageView")
	if rLevel > 0 then 
		Image_RefineLevel:loadTexture(getUIImg("Icon_StarLevel"..rLevel))
		Image_RefineLevel:setVisible(true)
	else
		Image_RefineLevel:setVisible(false)
	end
	
	local tbProp = GameObj_Equip:getEquipTbProp()

	for nIndex = 1,3 do
		local Label_AdditionalProp = tolua.cast(Image_TipEquipViewPNL:getChildByName("Label_AdditionalProp"..nIndex), "Label")
		local tbSubProp = tbProp[nIndex]
		if tbSubProp then
			local nType = tbSubProp.Prop_Type
			local bIsPercent, nBasePercent = g_CheckPropIsPercent(nType)
			if bIsPercent then 
				Label_AdditionalProp:setText(g_PropName[nType].." +"..string.format("%.2f", tbSubProp.Prop_Value/100).."%")
			else
				Label_AdditionalProp:setText(g_PropName[nType].." +"..tbSubProp.Prop_Value)
			end
			setRandomPropColor(Label_AdditionalProp, tbSubProp.Prop_Value, CSV_Equip.PropTypeRandID)
			Label_AdditionalProp:setVisible(true)
		else
			Label_AdditionalProp:setVisible(false)
		end
	end
	
	local Image_NeedLevel = tolua.cast(Image_TipEquipViewPNL:getChildByName("Image_NeedLevel"), "ImageView")
	local Label_NeedLevel = tolua.cast(Image_NeedLevel:getChildByName("Label_NeedLevel"), "Label")
	Label_NeedLevel:setText(string.format(_T("需求等级 %d"), CSV_Equip.NeedLevel))
	
	local Image_Price = tolua.cast(Image_TipEquipViewPNL:getChildByName("Image_Price"), "ImageView")
	local Label_Price = tolua.cast(Image_Price:getChildByName("Label_Price"), "Label")
	Label_Price:setText(string.format(_T("出售价格 %d"), GameObj_Equip:getSellPrice()))
end
function Game_TipEquipView:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipEquipViewPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipEquipViewPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipEquipViewPNL, funcWndOpenAniCall, 1.05, 0.2)
end
function Game_TipEquipView:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipEquipViewPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipEquipViewPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipEquipViewPNL, funcWndCloseAniCall, 1.05, 0.2)
end

--消除技能的Tip
Game_TipXiaoChuSkill = class("Game_TipXiaoChuSkill")
Game_TipXiaoChuSkill.__index = Game_TipXiaoChuSkill
function Game_TipXiaoChuSkill:initWnd()
end 
function Game_TipXiaoChuSkill:openWnd(nIndex)
	if not nIndex then return end
	
	local CSV_PlayerXianMaiSkill = g_DataMgr:getCsvConfigByOneKey("PlayerXianMaiSkill",nIndex)
	
	local Image_TipXiaoChuSkillPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipXiaoChuSkillPNL"), "ImageView")
	--名称
	local Label_Name = tolua.cast(Image_TipXiaoChuSkillPNL:getChildByName("Label_Name"),"Label")
	Label_Name:setText(CSV_PlayerXianMaiSkill.Name)
	-- local desc = CSV_PlayerXianMaiSkill.Desc
	-- if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
	local desc = g_stringSize_insert(CSV_PlayerXianMaiSkill.Desc, "\n", 16, 350)
	-- end
	--描述
	local Label_Desc = tolua.cast(Image_TipXiaoChuSkillPNL:getChildByName("Label_Desc"),"Label")
	Label_Desc:setText(desc)
	
	local height = Label_Desc:getSize().height
	if height > 30 then 
		Image_TipXiaoChuSkillPNL:setSize(CCSizeMake(Image_TipXiaoChuSkillPNL:getSize().width,  200))
	end
	
	--消耗
	local CSV_XianMai = g_DataMgr:getCsvConfigByOneKey("PlayerXianMai", g_XianMaiInfoData:getXianmaiLevel()) 
	local Label_CostLingLiLB = tolua.cast(Image_TipXiaoChuSkillPNL:getChildByName("Label_CostLingLiLB"),"Label")
	local Label_CostLingLi = tolua.cast(Image_TipXiaoChuSkillPNL:getChildByName("Label_CostLingLi"),"Label")
	Label_CostLingLi:setText(CSV_XianMai.NeedElementCoreNum)
	
	g_AdjustWidgetsPosition({Label_CostLingLiLB,Label_CostLingLi})
	
	local Image_IconBase = tolua.cast(Image_TipXiaoChuSkillPNL:getChildByName("Image_IconBase"),"ImageView")
	local Image_Icon = tolua.cast(Image_IconBase:getChildByName("Image_Icon"),"ImageView")
	Image_Icon:loadTexture(getIconImg("ResourceItem_XiaoChu"..nIndex))
end
function Game_TipXiaoChuSkill:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipXiaoChuSkillPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipXiaoChuSkillPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipXiaoChuSkillPNL, funcWndOpenAniCall, 1.05, 0.2)
end
function Game_TipXiaoChuSkill:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipXiaoChuSkillPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipXiaoChuSkillPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipXiaoChuSkillPNL, funcWndCloseAniCall, 1.05, 0.2)
end


