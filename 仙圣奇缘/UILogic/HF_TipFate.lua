--------------------------------------------------------------------------------------
-- 文件名:	HF_TipFate.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2013-4-8 9:37
-- 版  本:	1.0
-- 描  述:	异兽tip窗口
-- 应  用:
---------------------------------------------------------------------------------------
--伙伴界面

Game_TipFate = class("Game_TipFate")
Game_TipFate.__index = Game_TipFate

local tbTipFate = nil
local bIsExchange = nil
local nExchangePosIndex = nil

function Game_TipFate:initWnd(widget)
	tbTipFate = {}
	tbTipFate.layer = widget
	tbTipFate.layer:setTouchEnabled(true)

	local function onClickLayer(pSender,eventType)
		if eventType ==ccs.TouchEventType.ended then
			g_WndMgr:closeWnd("Game_TipFate")
		end
	end

	tbTipFate.layer:addTouchEventListener(onClickLayer)
end

local function onClickUpgrade(pSender,nTag)
	local nFateID = tbTipFate.tbData.nFateID
	local tbFate = g_Hero:getFateInfoByID(nFateID)
	if tbFate:checkIsExpFull() then
		g_ClientMsgTips:showMsgConfirm(_T("异兽已满级,无法继续进行升级"))
		g_WndMgr:closeWnd("Game_TipFate")
		return
	end
	g_WndMgr:closeWnd("Game_TipFate")
	local tbData = {}
	tbData.nFateID = nFateID
	g_WndMgr:openWnd("Game_CardFate1", tbData)
end

local function onClickUnLoad(pSender,eventType)
	if eventType == ccs.TouchEventType.ended then
		if tbTipFate.nFatePos then
			g_MsgMgr:requestChangeFate(macro_pb.Operator_Fate_Type_Pick, tbTipFate.tbData.nCardID, tbTipFate.tbData.nChooseIdx, tbTipFate.tbData.nFateID)
		else
			if bIsExchange then
				g_MsgMgr:requestChangeFate(macro_pb.Operator_Fate_Type_Exchange, tbTipFate.tbData.nCardID, nExchangePosIndex, tbTipFate.tbData.nFateID)
			else
			
				if not tbTipFate.tbData or tbTipFate.tbData == "" then return end
				
				local tbCardInfo = g_Hero:getCardObjByServID(tbTipFate.tbData.nCardID)
				local nEmptyPosIdex = tbCardInfo:getEmptyFatePosIndex()
				if not nEmptyPosIdex then
					g_ClientMsgTips:showMsgConfirm(_T("身上携带的异兽已达到上限，请先卸下一个"))
				else
					g_MsgMgr:requestChangeFate(macro_pb.Operator_Fate_Type_Inlay, tbTipFate.tbData.nCardID, nEmptyPosIdex, tbTipFate.tbData.nFateID)
				end
			end
		end
		g_WndMgr:closeWnd("Game_TipFate")
	end
end

function Game_TipFate:closeWnd()
	tbTipFate.tbData = nil
end

function Game_TipFate:openWnd(tbData)
	if g_bReturn then return end
	if not tbData then return end
	
	local nCardID = tbData.nCardID
	local nFateID = tbData.nFateID
	tbTipFate.tbData = tbData

	local tbCardInfo = g_Hero:getCardObjByServID(nCardID)
	local tbFateInfo = g_Hero:getFateInfoByID(nFateID)
	local CSV_CardFate = tbFateInfo:getCardFateCsv()

    local Image_TipFatePNL = tolua.cast(tbTipFate.layer:getChildByName("Image_TipFatePNL"), "ImageView")
	local Label_Name = tolua.cast(Image_TipFatePNL:getChildByName("Label_Name"), "Label")
	local CSV_CardFateOneKey = g_DataMgr:getCsvConfigByOneKey("CardFate", tbFateInfo:getCfgID())
	if tbFateInfo:getFateLevel() >= #CSV_CardFateOneKey then
		Label_Name:setText(tbFateInfo:getFateNameWithLevelInColor(Label_Name).." ".._T("满级"))
	else
		Label_Name:setText(tbFateInfo:getFateNameWithLevelInColor(Label_Name))
	end
	local Label_FateProp = tolua.cast(Image_TipFatePNL:getChildByName("Label_FateProp"), "Label")
	Label_FateProp:setText(tbFateInfo:getPropValueString())
	local Label_FateExp = tolua.cast(Image_TipFatePNL:getChildByName("Label_FateExp"), "Label")
	Label_FateExp:setText(tbFateInfo:getCurLevFateExpString())
	
	local Image_FateBase = tolua.cast(Image_TipFatePNL:getChildByName("Image_FateBase"), "ImageView")
	Image_FateBase:loadTexture(getEquipLightImg(CSV_CardFate.ColorType))
	
	local Image_DropIcon = tolua.cast(Image_TipFatePNL:getChildByName("Image_DropIcon"), "ImageView")
	Image_DropIcon:setPosition(ccp(-225+CSV_CardFate.OffsetX, -80+CSV_CardFate.OffsetY))
	Image_DropIcon:loadTexture(getIconImg(CSV_CardFate.Animation))

	local Button_FunctionLeft = tolua.cast(Image_TipFatePNL:getChildByName("Button_FunctionLeft"), "Button")
	g_SetBtnWithGuideCheck(Button_FunctionLeft, nil, onClickUpgrade, true, nil, nil, nil)

	local Button_FunctionRight = tolua.cast(Image_TipFatePNL:getChildByName("Button_FunctionRight"), "Button")
	Button_FunctionRight:setTouchEnabled(true)
	Button_FunctionRight:addTouchEventListener(onClickUnLoad)
	local Label_FuncName = tolua.cast(Button_FunctionRight:getChildByName("Label_FuncName"), "Label")
	tbTipFate.nFatePos = tbCardInfo:getFatePosIndex(nFateID)
	if tbTipFate.nFatePos then
		Label_FuncName:setText(_T("卸下"))
	else
		if nCardID then
			local tbCardInfo = g_Hero:getCardObjByServID(nCardID)
			bIsExchange, nExchangePosIndex = tbCardInfo:checkFateTypeIsInLayWithPosIndex(CSV_CardFate.Type)
			if bIsExchange then
				Label_FuncName:setText(_T("更换"))
			else
				Label_FuncName:setText(_T("装备"))
			end
		end
	end

end

function Game_TipFate:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipFatePNL = tolua.cast(self.rootWidget:getChildByName("Image_TipFatePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipFatePNL, funcWndOpenAniCall, 1.05, 0.2)
end
function Game_TipFate:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipFatePNL = tolua.cast(self.rootWidget:getChildByName("Image_TipFatePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipFatePNL, funcWndCloseAniCall, 1.05, 0.2)
end










