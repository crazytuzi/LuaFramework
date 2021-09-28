--------------------------------------------------------------------------------------
-- 文件名:	HJW_EquipRefineStarUp.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	装备升星界面
-- 应  用:  
---------------------------------------------------------------------------------------
Game_EquipRefineStarUp = class("Game_EquipRefineStarUp")
Game_EquipRefineStarUp.__index = Game_EquipRefineStarUp

-- local equipRefineCost = g_DataMgr:getCsvConfig("EquipRefineCost")
local equipId_ = nil
function Game_EquipRefineStarUp:initWnd()

end
function Game_EquipRefineStarUp:openWnd(nEquipID)
	if not nEquipID then return end 
	if	nEquipID then  equipId_ = nEquipID end

	self:equipRefineInfo(equipId_)

	local Image_EquipRefineStarUpPNL = tolua.cast(self.rootWidget:getChildByName("Image_EquipRefineStarUpPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_EquipRefineStarUpPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Button_RefineStarUp = tolua.cast(Image_ContentPNL:getChildByName("Button_RefineStarUp"), "Button")
	local function maxLevel()
		local GameObj_Equip = g_Hero:getEquipObjByServID(equipId_)
		if not GameObj_Equip then return false end
		
		local maxRefineLevel,maxFlagRefineLevel = GameObj_Equip:refineMaxLevel()
		if maxFlagRefineLevel then 
			Button_RefineStarUp:setTouchEnabled(false)
			Button_RefineStarUp:setBright(false)
			return true
		end
		return false
	end
	local function onClickStarUp(pSender, nTag)
		local GameObj_Equip = g_Hero:getEquipObjByServID(equipId_)
		local nNextRefineLevel,CSVRefineLevelInfo = GameObj_Equip:getNextRefineLevel()
		
		local CSV_Equip = GameObj_Equip:getCsvBase()
		if CSV_Equip.Type == Enum_EuipMainType.Weapon then
			if not g_CheckMoneyConfirm(CSVRefineLevelInfo.NeedMoney_Weapon) then 
				return
			end
			if CSVRefineLevelInfo.NeedDragonBall_Weapon > g_Hero:getDragonBall() then 
				g_ClientMsgTips:showMsgConfirm(_T("装备升星所需的神龙令数量不足"))
				return 
			end
		elseif CSV_Equip.Type == Enum_EuipMainType.Ring then
			if not g_CheckMoneyConfirm(CSVRefineLevelInfo.NeedMoney_Ring) then 
				return
			end
			if CSVRefineLevelInfo.NeedDragonBall_Ring > g_Hero:getDragonBall() then 
				g_ClientMsgTips:showMsgConfirm(_T("装备升星所需的神龙令数量不足"))
				return 
			end
		else
			if not g_CheckMoneyConfirm(CSVRefineLevelInfo.NeedMoney) then 
				return
			end
			if CSVRefineLevelInfo.NeedDragonBall > g_Hero:getDragonBall() then 
				g_ClientMsgTips:showMsgConfirm(_T("装备升星所需的神龙令数量不足"))
				return 
			end
		end
		
		if maxLevel() then 
			return
		end
		g_EquipRefineStarUpData:upFunc(function(equipId) 
			self:equipRefineInfo(equipId) 
	
			local Image_EquipRefineStarUpPNL = tolua.cast(self.rootWidget:getChildByName("Image_EquipRefineStarUpPNL"), "ImageView")
			local Image_ContentPNL = tolua.cast(Image_EquipRefineStarUpPNL:getChildByName("Image_ContentPNL"), "ImageView")
			
			local Image_LuDing = tolua.cast(Image_ContentPNL:getChildByName("Image_LuDing"), "ImageView")
			--装备品质
			local Image_EuipeIconCircle = tolua.cast(Image_LuDing:getChildByName("Image_EuipeIconCircle"), "ImageView")
			--装备Icon
			local Image_Icon = tolua.cast(Image_EuipeIconCircle:getChildByName("Image_Icon"), "ImageView")
			g_ShowEquipDaZaoAnimation(Image_Icon)
		end)
		g_EquipRefineStarUpData:requestEquipRefineLvupRequest(equipId_)
	end
	g_SetBtnWithGuideCheck(Button_RefineStarUp, 1, onClickStarUp, true)
	
	maxLevel()
	
end

function Game_EquipRefineStarUp:closeWnd()

end

function Game_EquipRefineStarUp:equipRefineInfo(equipId)
	
	local GameObj_Equip = g_Hero:getEquipObjByServID(equipId)
	if not GameObj_Equip then return end 
	local CSV_Equip = GameObj_Equip:getCsvBase()
	
	local nStrengthenLev = GameObj_Equip:getStrengthenLev()
	
	local Image_EquipRefineStarUpPNL = tolua.cast(self.rootWidget:getChildByName("Image_EquipRefineStarUpPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_EquipRefineStarUpPNL:getChildByName("Image_ContentPNL"), "ImageView")
	--
	local Image_LuDing = tolua.cast(Image_ContentPNL:getChildByName("Image_LuDing"), "ImageView")
	--装备品质
	local Image_EuipeIconCircle = tolua.cast(Image_LuDing:getChildByName("Image_EuipeIconCircle"), "ImageView")
	Image_EuipeIconCircle:loadTexture(getUIImg("FrameEquipCircle"..CSV_Equip.ColorType))
	--装备Icon
	local Image_Icon = tolua.cast(Image_EuipeIconCircle:getChildByName("Image_Icon"), "ImageView")
	Image_Icon:loadTexture(getIconImg(CSV_Equip.Icon))
	g_SetEquipSacle(Image_Icon, CSV_Equip.SubType)
	--[[
		当前等级信息
	]]
	--装备名称
	local Label_SourceName = tolua.cast(Image_ContentPNL:getChildByName("Label_SourceName"),"Label")
	Label_SourceName:setText(CSV_Equip.Name) --合成等级
    g_SetWidgetColorBySLev(Label_SourceName, CSV_Equip.ColorType)
	--装备等级
	local Label_SourceStrengthenLevel = tolua.cast(Image_ContentPNL:getChildByName("Label_SourceStrengthenLevel"),"Label")
	Label_SourceStrengthenLevel:setText(_T("Lv.")..nStrengthenLev)
	
	g_AdjustWidgetsPosition({Label_SourceName,Label_SourceStrengthenLevel}, 5)
	--
	local BitmapLabel_SourceMainProp = tolua.cast(Image_ContentPNL:getChildByName("BitmapLabel_SourceMainProp"),"LabelBMFont")
	BitmapLabel_SourceMainProp:setText(GameObj_Equip:getEquipMainPropFloor())
	
	--属性 比如 物攻 法攻
	local Label_SourceMainPropName = tolua.cast(Image_ContentPNL:getChildByName("Label_SourceMainPropName"),"Label")
	Label_SourceMainPropName:setText(g_tbMainPropName[CSV_Equip.SubType])
	
	g_AdjustWidgetsPosition({BitmapLabel_SourceMainProp,Label_SourceMainPropName})
	

	--装备星级
	local rLevel = GameObj_Equip:getRefineLev()
	
	local Image_RefineLevelSource = tolua.cast(Image_ContentPNL:getChildByName("Image_RefineLevelSource"),"ImageView")
	if rLevel > 0 then 
		Image_RefineLevelSource:loadTexture(getUIImg("Icon_StarLevel"..rLevel))
		Image_RefineLevelSource:setVisible(true)
	else
		Image_RefineLevelSource:setVisible(false)
	end
	
	--[[
		下一等级信息
	]]
		
	local Label_TargetName = tolua.cast(Image_ContentPNL:getChildByName("Label_TargetName"),"Label")
	Label_TargetName:setText(CSV_Equip.Name) --合成等级
    g_SetWidgetColorBySLev(Label_TargetName, CSV_Equip.ColorType)
	
	local Label_TargetStrengthenLevel = tolua.cast(Image_ContentPNL:getChildByName("Label_TargetStrengthenLevel"),"Label")
	Label_TargetStrengthenLevel:setText(_T("Lv.")..nStrengthenLev)
	
	g_AdjustWidgetsPosition({Label_TargetName,Label_TargetStrengthenLevel}, 5)
	
	local BitmapLabel_TargetMainProp = tolua.cast(Image_ContentPNL:getChildByName("BitmapLabel_TargetMainProp"),"LabelBMFont")
	BitmapLabel_TargetMainProp:setText(GameObj_Equip:getEquipMainPropNextRefineLvFloor())

	--属性 比如 物攻 法攻
	local Label_TargetMainPropName = tolua.cast(Image_ContentPNL:getChildByName("Label_TargetMainPropName"),"Label")
	Label_TargetMainPropName:setText(g_tbMainPropName[CSV_Equip.SubType])
	g_AdjustWidgetsPosition({BitmapLabel_TargetMainProp,Label_TargetMainPropName})
	
	local nNextRefineLevel,CSVRefineLevelInfo = GameObj_Equip:getNextRefineLevel()
	--装备星级
	local Image_RefineLevelTarget = tolua.cast(Image_ContentPNL:getChildByName("Image_RefineLevelTarget"),"ImageView")
	if nNextRefineLevel > 0 then 
		Image_RefineLevelTarget:loadTexture(getUIImg("Icon_StarLevel"..nNextRefineLevel))
		Image_RefineLevelTarget:setVisible(true)
	else
		Image_RefineLevelTarget:setVisible(false)
	end
	--消耗数值
	local Image_Resource = tolua.cast(Image_ContentPNL:getChildByName("Image_Resource"),"ImageView")
	Image_Resource:setVisible(true)
	local Image_DragonBall = tolua.cast(Image_Resource:getChildByName("Image_DragonBall"),"ImageView")
	--龙珠
	local BitmapLabel_NeedDragonBall = tolua.cast(Image_DragonBall:getChildByName("BitmapLabel_NeedDragonBall"),"LabelBMFont")

	local Image_Coins = tolua.cast(Image_Resource:getChildByName("Image_Coins"),"ImageView")
	local BitmapLabel_NeedMoney = tolua.cast(Image_Coins:getChildByName("BitmapLabel_NeedMoney"),"LabelBMFont")

	if CSV_Equip.Type == Enum_EuipMainType.Weapon then
		BitmapLabel_NeedMoney:setText(CSVRefineLevelInfo.NeedMoney_Weapon)
		BitmapLabel_NeedDragonBall:setText(CSVRefineLevelInfo.NeedDragonBall_Weapon)
		g_SetLabelRed(BitmapLabel_NeedMoney,CSVRefineLevelInfo.NeedMoney_Weapon > g_Hero:getCoins())
		g_SetLabelRed(BitmapLabel_NeedDragonBall,CSVRefineLevelInfo.NeedDragonBall_Weapon > g_Hero:getDragonBall())
	elseif CSV_Equip.Type == Enum_EuipMainType.Ring then
		BitmapLabel_NeedMoney:setText(CSVRefineLevelInfo.NeedMoney_Ring)
		BitmapLabel_NeedDragonBall:setText(CSVRefineLevelInfo.NeedDragonBall_Ring)
		g_SetLabelRed(BitmapLabel_NeedMoney,CSVRefineLevelInfo.NeedMoney_Ring > g_Hero:getCoins())
		g_SetLabelRed(BitmapLabel_NeedDragonBall,CSVRefineLevelInfo.NeedDragonBall_Ring > g_Hero:getDragonBall())
	else
		BitmapLabel_NeedMoney:setText(CSVRefineLevelInfo.NeedMoney)
		BitmapLabel_NeedDragonBall:setText(CSVRefineLevelInfo.NeedDragonBall)
		g_SetLabelRed(BitmapLabel_NeedMoney,CSVRefineLevelInfo.NeedMoney > g_Hero:getCoins())
		g_SetLabelRed(BitmapLabel_NeedDragonBall,CSVRefineLevelInfo.NeedDragonBall > g_Hero:getDragonBall())
	end
end

function Game_EquipRefineStarUp:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_EquipRefineStarUpPNL = tolua.cast(self.rootWidget:getChildByName("Image_EquipRefineStarUpPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_EquipRefineStarUpPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_EquipRefineStarUp:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_EquipRefineStarUpPNL = tolua.cast(self.rootWidget:getChildByName("Image_EquipRefineStarUpPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_EquipRefineStarUpPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end