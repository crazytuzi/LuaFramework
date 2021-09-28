--------------------------------------------------------------------------------------
-- 文件名:	HF_EquipStrengthen.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  flamehong
-- 日  期:	2014-10-28 20:52
-- 版  本:	1.0
-- 描  述:	强化界面
-- 应  用:  

---------------------------------------------------------------------------------------
Game_EquipStrengthen = class("Game_EquipStrengthen")
Game_EquipStrengthen.__index = Game_EquipStrengthen

local tbEqStrength = {}
function Game_EquipStrengthen:initWnd(widget)
	tbEqStrength = {}
	tbEqStrength.layer = widget
end

local function setViewInfo(nEquipID)
	if not nEquipID then return end
	
	local GameObj_Equip = g_Hero:getEquipObjByServID(nEquipID)
	local tbCsvBase = GameObj_Equip:getCsvBase()

	local PNL = tolua.cast(tbEqStrength.layer:getChildByName("ImageView_EquipStrengthenPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(PNL:getChildByName("Image_ContentPNL"),"ImageView")
	--星级
	local Image_RefineLevelSource = tolua.cast(Image_ContentPNL:getChildByName("Image_RefineLevelSource"),"ImageView")
	local rLevel = GameObj_Equip:getRefineLev()
	if rLevel > 0 then 
		Image_RefineLevelSource:loadTexture(getUIImg("Icon_StarLevel"..rLevel))
		Image_RefineLevelSource:setVisible(true)
	else
		Image_RefineLevelSource:setVisible(false)
	end
	
	local Image_LuDing = tolua.cast(Image_ContentPNL:getChildByName("Image_LuDing"),"ImageView")
	local Image_EuipeIconCircle = tolua.cast(Image_LuDing:getChildByName("Image_EuipeIconCircle"),"ImageView")
	Image_EuipeIconCircle:loadTexture(getUIImg("FrameEquipCircle"..tbCsvBase.ColorType))
	local Image_Icon = tolua.cast(Image_EuipeIconCircle:getChildByName("Image_Icon"),"ImageView")
	Image_Icon:loadTexture(getIconImg(tbCsvBase.Icon))
	g_SetEquipSacle(Image_Icon,tbCsvBase.SubType)
	
	local nStrengthenLev = GameObj_Equip:getStrengthenLev()
	
	local Button_Strengthen = tolua.cast(Image_ContentPNL:getChildByName("Button_Strengthen"),"Button")
	local Button_QuickStrengthen = tolua.cast(Image_ContentPNL:getChildByName("Button_QuickStrengthen"),"Button")
	local Image_NeedMoney = tolua.cast(Image_ContentPNL:getChildByName("Image_NeedMoney"),"ImageView")
	local Image_Coins = tolua.cast(Image_NeedMoney:getChildByName("Image_Coins"),"ImageView")
	local BitmapLabel_NeedMoney = tolua.cast(Image_Coins:getChildByName("BitmapLabel_NeedMoney"),"LabelBMFont")
	Image_Coins:setPositionX(-(Image_Coins:getSize().width + BitmapLabel_NeedMoney:getSize().width + 5)/2)
	
	local CSV_EquipStrengthenCost = g_DataMgr:getEquipStrengthenCostCsv(nStrengthenLev)
	local CSV_Equip = g_DataMgr:getCsvConfigByTwoKey("Equip",GameObj_Equip.nCsvID, GameObj_Equip:getStarLevel())
	
	local nNeedMoney = math.floor(CSV_EquipStrengthenCost.StrengthenCost * CSV_Equip.StrengthenFactor/g_BasePercent)
	BitmapLabel_NeedMoney:setText(nNeedMoney)

	local strTxt = _T("点击强化")
	local strQuickTxt = _T("一键强化")
	local nEnable = false
	local flagMoney = false
	if g_Hero:getCoins() < nNeedMoney then
		strTxt = _T("铜钱不足")
		strQuickTxt = strTxt
		flagMoney = true
		nEnable = true
	elseif GameObj_Equip:checkIsStrengthenLevelFull() then
		-- nEnable = false
		strTxt = _T("已达上限")
		strQuickTxt = strTxt
	else
		nEnable = true
	end
	
	g_SetButtonEnabled(Button_Strengthen, nEnable, strTxt)
	g_SetButtonEnabled(Button_QuickStrengthen, nEnable, strQuickTxt)
	g_SetLabelRed(BitmapLabel_NeedMoney, flagMoney)
	
	local function onClickStrengthen(pSender, nTag)
		if nEquipID and nEquipID > 0 then
			if g_CheckMoneyConfirm(nNeedMoney) then
				g_MsgMgr:requestEquipStrengthen(nEquipID)--单次强化
			end
		end
    end
	g_SetBtnWithGuideCheck(Button_Strengthen, 1, onClickStrengthen, nEnable)
	
	
	local function onClickQuickStrengthen(pSender, nTag)
		if nEquipID and nEquipID > 0 then
			if g_CheckMoneyConfirm(nNeedMoney) then
				g_MsgMgr:requestStrengthOneKeyRequest(nEquipID)--一键强化
			end
		end
    end
	g_SetBtnWithGuideCheck(Button_QuickStrengthen, 1, onClickQuickStrengthen, nEnable)
	
	local Label_SourceName = tolua.cast(Image_ContentPNL:getChildByName("Label_SourceName"),"Label")
	Label_SourceName:setText(tbCsvBase.Name) --合成等级
    g_SetWidgetColorBySLev(Label_SourceName,tbCsvBase.ColorType)

	
	local BitmapLabel_SourceMainProp = tolua.cast(Image_ContentPNL:getChildByName("BitmapLabel_SourceMainProp"),"LabelBMFont")
	BitmapLabel_SourceMainProp:setText(GameObj_Equip:getEquipMainPropFloor())
	
	local Label_SourceMainPropName = tolua.cast(Image_ContentPNL:getChildByName("Label_SourceMainPropName"),"Label")
	Label_SourceMainPropName:setText(g_tbMainPropName[tbCsvBase.SubType])
	
	g_AdjustWidgetsPosition({BitmapLabel_SourceMainProp,Label_SourceMainPropName},-8)
	
	local Label_SourceStrengthenLevel = tolua.cast(Image_ContentPNL:getChildByName("Label_SourceStrengthenLevel"),"Label")
	Label_SourceStrengthenLevel:setText(_T("Lv.").." "..nStrengthenLev)
	
	g_AdjustWidgetsPosition({Label_SourceName,Label_SourceStrengthenLevel}, 5)
	local nNewStrengthLv = nStrengthenLev + 1
	
	--预览星级
	local Image_RefineLevelTarget = tolua.cast(Image_ContentPNL:getChildByName("Image_RefineLevelTarget"),"ImageView")
	if rLevel > 0 then 
		Image_RefineLevelTarget:loadTexture(getUIImg("Icon_StarLevel"..rLevel))
		Image_RefineLevelTarget:setVisible(true)
	else
		Image_RefineLevelTarget:setVisible(false)
	end
	
	local Label_TargetName = tolua.cast(Image_ContentPNL:getChildByName("Label_TargetName"),"Label")
	Label_TargetName:setText(tbCsvBase.Name) --合成等级
    g_SetWidgetColorBySLev(Label_TargetName,tbCsvBase.ColorType)

	local BitmapLabel_TargetMainProp = tolua.cast(Image_ContentPNL:getChildByName("BitmapLabel_TargetMainProp"),"LabelBMFont")
	BitmapLabel_TargetMainProp:setText(GameObj_Equip:getEquipMainPropNextStrengthenLvFloor())
	
	local Label_TargetMainPropName = tolua.cast(Image_ContentPNL:getChildByName("Label_TargetMainPropName"),"Label")
	Label_TargetMainPropName:setText(g_tbMainPropName[tbCsvBase.SubType])
	g_AdjustWidgetsPosition({BitmapLabel_TargetMainProp,Label_TargetMainPropName},-8)
	
	local Label_TargetStrengthenLevel = tolua.cast(Image_ContentPNL:getChildByName("Label_TargetStrengthenLevel"),"Label")
	Label_TargetStrengthenLevel:setText(_T("Lv.").." "..nNewStrengthLv)
	g_setTextColor(Label_TargetStrengthenLevel, ccs.COLOR.BRIGHT_GREEN)
	
	g_AdjustWidgetsPosition({Label_TargetName,Label_TargetStrengthenLevel}, 5)
end

function refreshStrengthenWnd(nEquipID)
	if not tbEqStrength.bOpen then return end
	local ImageView_EquipStrengthenPNL = tolua.cast(tbEqStrength.layer:getChildByName("ImageView_EquipStrengthenPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(ImageView_EquipStrengthenPNL:getChildByName("Image_ContentPNL"),"ImageView")
	local Image_LuDing = tolua.cast(Image_ContentPNL:getChildByName("Image_LuDing"),"ImageView")
	local Image_EuipeIconCircle = tolua.cast(Image_LuDing:getChildByName("Image_EuipeIconCircle"),"ImageView")
	local Image_Icon = tolua.cast(Image_EuipeIconCircle:getChildByName("Image_Icon"),"ImageView")
	g_ShowEquipDaZaoAnimation(Image_Icon)
	setViewInfo(nEquipID)
end

function Game_EquipStrengthen:closeWnd()
	tbEqStrength.bOpen = nil
end

function Game_EquipStrengthen:openWnd(nEquipID)
	tbEqStrength.bOpen = true
	setViewInfo(nEquipID)
end

function Game_EquipStrengthen:showWndOpenAnimation(funcWndOpenAniCall)
	local ImageView_EquipStrengthenPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_EquipStrengthenPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(ImageView_EquipStrengthenPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_EquipStrengthen:showWndCloseAnimation(funcWndCloseAniCall)
	local ImageView_EquipStrengthenPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_EquipStrengthenPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(ImageView_EquipStrengthenPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end







