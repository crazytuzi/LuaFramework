--------------------------------------------------------------------------------------
-- 文件名:	HF_TipEquip.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  flamehong
-- 日  期:	2014-10-28 10:47
-- 版  本:	1.0
-- 描  述:	装备界面
-- 应  用:  

---------------------------------------------------------------------------------------
Game_TipEquip = class("Game_TipEquip")
Game_TipEquip.__index = Game_TipEquip

local tbEquipPos = {1, 1, 1, 1, 1, 2, 3, 4, 5, 6}
local function setBtnFunc(Image_TipEquipViewPNL, tbCardInfo, GameObj_Equip, tbCsvBase)
	local Button_EquipOrDisarm = tolua.cast(Image_TipEquipViewPNL:getChildByName("Button_EquipOrDisarm"), "Button")
	local function onClick_Button_EquipOrDisarm()
		if tonumber(GameObj_Equip.nOwnerID) > 0 then
			--御下
			g_MsgMgr:requestDressEquip(tbCardInfo.nServerID, tbEquipPos[tbCsvBase.SubType], 0)
		else
           if tbCardInfo.nLevel < tbCsvBase.NeedLevel then
			    g_ClientMsgTips:showMsgConfirm(string.format(_T("伙伴需要达到%d级才可装备该装备"), tbCsvBase.NeedLevel))
			    return
		    end
		
		    local CSV_CardBase = tbCardInfo:getCsvBase()
		    if tbCsvBase.SubType >= 1 and tbCsvBase.SubType < 5 
			    and tbCsvBase.SubType ~= CSV_CardBase.Profession then
			    g_ClientMsgTips:showMsgConfirm(_T("伙伴职业不匹配"))
			    return
		    end
			--穿着
			g_MsgMgr:requestDressEquip(tbCardInfo.nServerID, tbEquipPos[tbCsvBase.SubType], GameObj_Equip.nServerID)
		    g_WndMgr:closeWnd("Game_TipEquip")
        end		
	end
	g_SetBtnWithOpenCheck(Button_EquipOrDisarm, 1, onClick_Button_EquipOrDisarm, true)
	
	local Button_Decompose = tolua.cast(Image_TipEquipViewPNL:getChildByName("Button_Decompose"), "Button")
	local function onClick_Button_Decompose()
		local function tipsFunc()
			g_MsgMgr:requestEquipSell(GameObj_Equip.nServerID) 	
		end
		
		local tips = string.format(_T("出售装备可获得%d铜钱，是否确认出售?"), GameObj_Equip:getSellPrice())
		g_ClientMsgTips:showConfirm(tips,tipsFunc)
		g_WndMgr:closeWnd("Game_TipEquip")
	end
	--出售
	g_SetBtnWithOpenCheck(Button_Decompose, 2, onClick_Button_Decompose, true)
    Button_Decompose:setTouchEnabled(tonumber(GameObj_Equip.nOwnerID) <= 0)
	
	--重铸
	local Button_ChongZhu = tolua.cast(Image_TipEquipViewPNL:getChildByName("Button_ChongZhu"), "Button")
	local function onClick_Button_ChongZhu()
		g_WndMgr:hideWnd("Game_TipEquip") 
		g_WndMgr:showWnd("Game_EquipChongZhu", GameObj_Equip.nServerID) 
	end
	g_SetBtnWithOpenCheck(Button_ChongZhu, 4, onClick_Button_ChongZhu, true)
	
	--合成
	local Button_Refine = tolua.cast(Image_TipEquipViewPNL:getChildByName("Button_Refine"), "Button")
	local function onClick_Button_Refine()
		g_WndMgr:hideWnd("Game_TipEquip")
		local param = {
			nLevel = tbCardInfo.nLevel ,
			nNeedLevel = tbCsvBase.NeedLevel,
			nEquipID = GameObj_Equip.nServerID,
		}
		g_WndMgr:showWnd("Game_EquipRefine",param) 
	end
	g_SetBtnWithOpenCheck(Button_Refine, 3, onClick_Button_Refine, true)
	
	--强化
	local Button_Strengthen = tolua.cast(Image_TipEquipViewPNL:getChildByName("Button_Strengthen"), "Button")
	local function onClick_Button_Strengthen()
		g_WndMgr:hideWnd("Game_TipEquip")
		g_WndMgr:showWnd("Game_EquipStrengthen", GameObj_Equip.nServerID) 
	end
    g_SetBtnWithOpenCheck(Button_Strengthen, 3, onClick_Button_Strengthen, true)	
	
	--装备升星
	local Button_EquipStarUp = tolua.cast(Image_TipEquipViewPNL:getChildByName("Button_EquipStarUp"), "Button")
	local function onClick_Button_Strengthen()
		g_WndMgr:hideWnd("Game_TipEquip")
		g_WndMgr:showWnd("Game_EquipRefineStarUp",GameObj_Equip.nServerID) 
	end
    g_SetBtnWithOpenCheck(Button_EquipStarUp, 3, onClick_Button_Strengthen, true)
	
	local button ={
		Button_Strengthen,
		Button_Refine,
		Button_EquipStarUp,
		Button_ChongZhu,
	}
	for nIndex = 1, 4 do
		g_addUpgradeGuide(button[nIndex], ccp(55, 15), nil, g_CheckEquipUpgradeByType(GameObj_Equip,nIndex))
	end
	
end

local function setEquipTipInfo(Image_TipEquipViewPNL, tbCardInfo, GameObj_Equip, tbCsvBase, strFuncName)
	local rLevel = GameObj_Equip:getRefineLev()
	--装备星级
	local Image_RefineLevel = tolua.cast(Image_TipEquipViewPNL:getChildByName("Image_RefineLevel"), "ImageView")
	if rLevel > 0 then 
		Image_RefineLevel:loadTexture(getUIImg("Icon_StarLevel"..rLevel))
		Image_RefineLevel:setVisible(true)
	else
		Image_RefineLevel:setVisible(false)
	end
	
	local Image_Icon = tolua.cast(Image_TipEquipViewPNL:getChildByName("Image_Icon"), "ImageView")
	Image_Icon:loadTexture(getIconImg(tbCsvBase.Icon))
	local tbCsvBase = GameObj_Equip:getCsvBase()
	g_SetEquipSacleTip(Image_Icon, tbCsvBase.SubType)
	
	local Image_EuipeBase = tolua.cast(Image_TipEquipViewPNL:getChildByName("Image_EuipeBase"), "ImageView")
	Image_EuipeBase:loadTexture(getUIImg("FrameEquipLight"..tbCsvBase.ColorType))
	
	local Label_Name = tolua.cast(Image_TipEquipViewPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(tbCsvBase.Name)
	g_SetWidgetColorBySLev(Label_Name, tbCsvBase.ColorType)

	local nStrengthLv = GameObj_Equip:getStrengthenLev()
	local BitmapLabel_MainProp = tolua.cast(Image_TipEquipViewPNL:getChildByName("BitmapLabel_MainProp"), "LabelBMFont")
	BitmapLabel_MainProp:setText(GameObj_Equip:getEquipMainPropFloor())
	
	local Label_MainPropName = tolua.cast(Image_TipEquipViewPNL:getChildByName("Label_MainPropName"), "Label")
	Label_MainPropName:setText(g_tbMainPropName[tbCsvBase.SubType])
	--多个控件的左对齐
	g_AdjustWidgetsPosition({BitmapLabel_MainProp,Label_MainPropName},-8)
	
	local Label_StrengthenLevel = tolua.cast(Image_TipEquipViewPNL:getChildByName("Label_StrengthenLevel"), "Label")
	Label_StrengthenLevel:setText(_T("Lv.")..nStrengthLv)
	

	g_AdjustWidgetsPosition({Label_Name, Label_StrengthenLevel}, 5)
	
	local Button_EquipOrDisarm = tolua.cast(Image_TipEquipViewPNL:getChildByName("Button_EquipOrDisarm"), "Button")
    if Button_EquipOrDisarm then
        local Label_FuncName = tolua.cast(Button_EquipOrDisarm:getChildByName("Label_FuncName"), "Label")
		Label_FuncName:setText(strFuncName)
        setBtnFunc(Image_TipEquipViewPNL, tbCardInfo, GameObj_Equip, tbCsvBase)
    end

	local tbProp = GameObj_Equip:getEquipTbProp()
	for i=1,3 do
		local Label_AdditionalProp = tolua.cast(Image_TipEquipViewPNL:getChildByName("Label_AdditionalProp"..i), "Label")
		local tbSubProp = tbProp[i]
		if tbSubProp then
			local nType = tbSubProp.Prop_Type
			local bIsPercent, nBasePercent = g_CheckPropIsPercent(nType)
			if bIsPercent then 
				Label_AdditionalProp:setText(g_PropName[nType].." +"..string.format("%.2f", tbSubProp.Prop_Value/100).."%")
			else
				Label_AdditionalProp:setText(g_PropName[nType].." +"..tbSubProp.Prop_Value)
			end
			setRandomPropColor(Label_AdditionalProp, tbSubProp.Prop_Value, tbCsvBase.PropTypeRandID)
			Label_AdditionalProp:setVisible(true)
		else
			Label_AdditionalProp:setVisible(false)
		end
	end
	
	local Image_NeedLevel = tolua.cast(Image_TipEquipViewPNL:getChildByName("Image_NeedLevel"), "ImageView")
	local Label_NeedLevel = tolua.cast(Image_NeedLevel:getChildByName("Label_NeedLevel"), "Label")
	Label_NeedLevel:setText(string.format(_T("需求等级 %d"), tbCsvBase.NeedLevel))
	
	local Image_Price = tolua.cast(Image_TipEquipViewPNL:getChildByName("Image_Price"), "ImageView")
	local Label_Price = tolua.cast(Image_Price:getChildByName("Label_Price"), "Label")
	Label_Price:setText(string.format(_T("出售价格 %d"), GameObj_Equip:getSellPrice()))
end

function Game_TipEquip:initWnd()

end

function Game_TipEquip:openWnd(tbParams)
    if g_bReturn then 
        return 
    end
	
	if not tbParams or tbParams == {} then
		return
	end

	local Image_TipEquipPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipEquipPNL"), "ImageView")
	local Image_TipEquipViewPNL = tolua.cast(Image_TipEquipPNL:getChildByName("Image_TipEquipViewPNL"), "ImageView")
	local Image_TipCurrentEquipPNL = tolua.cast(Image_TipEquipPNL:getChildByName("Image_TipCurrentEquipPNL"), "ImageView")
	
	local tbCardInfo = g_Hero:getCardObjByServID(tbParams.nCardID)
	if not tbCardInfo then return end 
	local GameObj_Equip = g_Hero:getEquipObjByServID(tbParams.nEquipID)
	if GameObj_Equip then
		local tbCsvBase = GameObj_Equip:getCsvBase()
		

		--如果是装备，显示两个tip，作比较
		Image_TipCurrentEquipPNL:setVisible(false)
		if tonumber(GameObj_Equip.nOwnerID) > 0 then
			Image_TipEquipPNL:setSize(CCSizeMake(530, 520))
			setEquipTipInfo(Image_TipEquipViewPNL, tbCardInfo, GameObj_Equip, tbCsvBase, _T("卸下"))
			Image_TipEquipViewPNL:setPositionXY(5, 0)
		else
			Image_TipEquipPNL:setSize(CCSizeMake(990, 520))
			if GameObj_Equip:checkEquipMatchProfession(tbCardInfo) then
				if GameObj_Equip:checkHasAllreadyEquiped(tbCardInfo) then
					local nCurEquipID = tbCardInfo:getEquipIDByPos(tbEquipPos[tbCsvBase.SubType])
					local tbCurEquip = g_Hero:getEquipObjByServID(nCurEquipID)
					local tbCurItemBase = tbCurEquip:getCsvBase()
					Image_TipCurrentEquipPNL:setVisible(true)
					setEquipTipInfo(Image_TipCurrentEquipPNL, tbCardInfo, tbCurEquip, tbCurItemBase)
					
					Image_TipEquipViewPNL:setPositionXY(240, 0)
					local tbCurSize = Image_TipCurrentEquipPNL:getSize()
					Image_TipCurrentEquipPNL:setPositionXY(-265, 0)
					setEquipTipInfo(Image_TipEquipViewPNL, tbCardInfo, GameObj_Equip, tbCsvBase, _T("更换"))
				else
					setEquipTipInfo(Image_TipEquipViewPNL, tbCardInfo, GameObj_Equip, tbCsvBase, _T("装备"))
				end
			else
				setEquipTipInfo(Image_TipEquipViewPNL, tbCardInfo, GameObj_Equip, tbCsvBase, _T("不匹配"))
			end
		end
	end
end

function Game_TipEquip:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipEquipPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipEquipPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipEquipPNL, funcWndOpenAniCall, 1.05, 0.2)
end

function Game_TipEquip:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipEquipPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipEquipPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipEquipPNL, funcWndCloseAniCall, 1.05, 0.2)
end