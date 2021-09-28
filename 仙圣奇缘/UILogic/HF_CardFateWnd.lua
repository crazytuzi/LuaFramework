--------------------------------------------------------------------------------------
-- 文件名:	HF_CardFateWnd.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2013-4-8 9:37
-- 版  本:	1.0
-- 描  述:	伙伴异兽界面
-- 应  用:
---------------------------------------------------------------------------------------
--伙伴界面

Game_CardFate1 = class("Game_CardFate1")
Game_CardFate1.__index = Game_CardFate1

local tbCardFateData = {
	tbCard = nil,
	CSV_CardBase = nil,
	nFateID = nil,
	tbCanBeConsumeFateList = {},
	tbSelectedFateList = {},
	tbSelectedFateListID = {},
	nAddExp = 0,
}

local nPage = nil
local nMaxLev = 10

local function SortByStarAndExpHigh(tbFateA, tbFateB)
	local nColorTypeA = tbFateA:getCardFateCsv().ColorType
	local nColorTypeB = tbFateB:getCardFateCsv().ColorType
	if nColorTypeA == nColorTypeB then
		local nFateExpA = tbFateA:getFateExp()
		local nFateExpB = tbFateB:getFateExp()
		if nFateExpA == nFateExpB then
			local nCsvIdA = tbFateA:getCsvBase().ID
			local nCsvIdB = tbFateB:getCsvBase().ID
			if nCsvIdA == nCsvIdB then
				return tbFateA:getServerId() < tbFateB:getServerId()
			else
				return nCsvIdA < nCsvIdB
			end
		else
			return nFateExpA > nFateExpB
		end
	else
		return nColorTypeA > nColorTypeB
	end
end

local function SortByStarAndExpLow(tbFateA, tbFateB)
	if tbFateA:getServerId() == tbCardFateData.nTargetFateID then
		return true
	elseif tbFateB:getServerId() == tbCardFateData.nTargetFateID then
		return false
	else
		local nColorTypeA = tbFateA:getCardFateCsv().ColorType
		local nColorTypeB = tbFateB:getCardFateCsv().ColorType
		if nColorTypeA == nColorTypeB then
			local nFateExpA = tbFateA:getFateExp()
			local nFateExpB = tbFateB:getFateExp()
			if nFateExpA == nFateExpB then
				local nCsvIdA = tbFateA:getCsvBase().ID
				local nCsvIdB = tbFateB:getCsvBase().ID
				if nCsvIdA == nCsvIdB then
					return tbFateA:getServerId() > tbFateB:getServerId()
				else
					return nCsvIdA < nCsvIdB
				end
			else
				return nFateExpA < nFateExpB
			end
		else
			return nColorTypeA < nColorTypeB
		end
	end
end

local function updateListView_FateMaterialList(strWndName)
	tbCardFateData.tbUnDressFateList = {}
	if strWndName == "Game_CardFate1" then
		for nIndex = 1, g_Hero:getFateUnDressedAmmount() do
			table.insert(tbCardFateData.tbUnDressFateList, g_Hero:getFateByIndex(nIndex))
		end
		table.sort(tbCardFateData.tbUnDressFateList, SortByStarAndExpHigh)
	elseif strWndName == "Game_CardFateLevelUp1" then
		local tbTargetFate = g_Hero:getFateInfoByID(tbCardFateData.nTargetFateID)
		for nIndex = 1, g_Hero:getFateUnDressedAmmount() do
			local tbUnDressFate = g_Hero:getFateByIndex(nIndex)
			if tbUnDressFate:checkCanBeConsumed(tbTargetFate) then
				table.insert(tbCardFateData.tbUnDressFateList, g_Hero:getFateByIndex(nIndex))
			end
		end
		table.sort(tbCardFateData.tbUnDressFateList, SortByStarAndExpLow)
	end
	
    local nRowCount = math.ceil(#tbCardFateData.tbUnDressFateList/4)
	tbCardFateData.ListView_FateMaterialList:updateItems(nRowCount)
end

local function resetCanBeConsumeFateTableByTarget(tbTargetFate, strWndName)
	tbCardFateData.tbCanBeConsumeFateList = {}
	if not tbTargetFate or tbTargetFate:checkIsExpFull() then
		return
	end
	if strWndName == "Game_CardFate1" then
		local nCount = 0
		for nIndex = #tbCardFateData.tbUnDressFateList, 1, -1  do
			local tbCurrentFate = tbCardFateData.tbUnDressFateList[nIndex]
			if tbCurrentFate:checkCanBeOneKeyConsumed(tbTargetFate) then
				nCount = nCount + 1
				table.insert(tbCardFateData.tbCanBeConsumeFateList, tbCurrentFate:getServerId())
			end
			if nCount >= 90 then
				break
			end
		end
	
	elseif strWndName == "Game_CardFateLevelUp1" then
		local nCount = 0
		for nIndex = 1, #tbCardFateData.tbUnDressFateList do
			local tbCurrentFate = tbCardFateData.tbUnDressFateList[nIndex]
			if tbCurrentFate:checkCanBeConsumedExcludeSelf(tbTargetFate) then
				nCount = nCount + 1
				table.insert(tbCardFateData.tbCanBeConsumeFateList, 
					{
						nUdressFateID = tbCurrentFate:getServerId(),
						nUndressFateIndex = nIndex,
					}
				)
			end
			if nCount >= 8 then
				break
			end
		end
		if nCount < 8 then
			for nIndex = nCount + 1 , 8 do
				tbCardFateData.tbCanBeConsumeFateList[nIndex] = {
					nUdressFateID = 0,
					nUndressFateIndex = 0,
				}
			end
		end
	
	end
end

local function getAllMaterialExp()
	tbCardFateData.nAddExp = 0
	for nPosIndex = 1, 8 do
		local nSelectedFateID = tbCardFateData.tbSelectedFateList[nPosIndex]
		if nSelectedFateID > 0 then
			local tbSelectedFate = g_Hero:getFateInfoByID(nSelectedFateID)
			tbCardFateData.nAddExp = tbCardFateData.nAddExp + tbSelectedFate:getAddExp()
		end
	end
	return tbCardFateData.nAddExp
end

--更新材料选择状态
local function setImage_FateState(Image_FateState, nUdressFateID)
	if tbCardFateData.Image_FateLevelUpPNL:isVisible() then
		local Label_FateState = tolua.cast(Image_FateState:getChildByName("Label_FateState"),"Label")
		local bShow = false
		local szStatus = ""
		if tbCardFateData.nTargetFateID == nUdressFateID then
			szStatus = 
			Image_FateState:setVisible(true)
			Label_FateState:setVisible(true)
			Label_FateState:setText(_T("强化中"))
		else
			if tbCardFateData.tbSelectedFateListID[nUdressFateID] then
				Image_FateState:setVisible(true)
				Label_FateState:setVisible(true)
				Label_FateState:setText(_T("已选中"))
			else
				Image_FateState:setVisible(false)
			end
		end
	else
		Image_FateState:setVisible(false)
	end
end

local function getButton_FateIconBaseByIndex(nUndressFateIndex)
	if not nUndressFateIndex or nUndressFateIndex == 0 then return end
	local nRow = math.floor((nUndressFateIndex-1)/4)
	local nColumn = math.mod((nUndressFateIndex-1), 4) + 1
	local Panel_FateRow = tbCardFateData.ListView_FateMaterialList:getChildByIndex(nRow)
	if Panel_FateRow then
		local Button_FateIconBase = tolua.cast(Panel_FateRow:getChildByName("Button_FateIconBase"..nColumn), "Button")
		return Button_FateIconBase
	end
	return nil
end

local function setButton_Material(nMaterialFateID, nOnTouchIndex, nUndressFateIndex)
	local nPosIndex
	if not nOnTouchIndex then
	    for nIndex = 1, 8 do
		    if tbCardFateData.tbSelectedFateList[nIndex] == 0 then
			    nPosIndex = nIndex
                break
		    end
	    end
		if not nPosIndex then return end
	else
		nPosIndex = nOnTouchIndex
    end
	
	local nImageFateStateIndex
	local nSelectedFateID
	if nMaterialFateID > 0 then
		nSelectedFateID = nMaterialFateID
		tbCardFateData.tbSelectedFateList[nPosIndex] = nSelectedFateID
		tbCardFateData.tbSelectedFateListID[nSelectedFateID] = nUndressFateIndex
		nImageFateStateIndex = nUndressFateIndex
	else
		nSelectedFateID = tbCardFateData.tbSelectedFateList[nPosIndex]
		if nSelectedFateID and nSelectedFateID > 0 then
			nUndressFateIndex = tbCardFateData.tbSelectedFateListID[nSelectedFateID]
			if nUndressFateIndex and nUndressFateIndex > 0 then
				nImageFateStateIndex = nUndressFateIndex
				tbCardFateData.tbSelectedFateListID[nSelectedFateID] = nil
				tbCardFateData.tbSelectedFateList[nPosIndex] = 0
				nSelectedFateID = nil
			else
				tbCardFateData.tbSelectedFateList[nPosIndex] = 0
			end
		end
	end
	
	
	local Button_Material = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Button_Material"..nPosIndex),"Button")
	local Image_Add = tolua.cast(Button_Material:getChildByName("Image_Add"),"ImageView")
	if nSelectedFateID and nSelectedFateID > 0 then
		g_SetFateWidgetByFateID(Button_Material, nSelectedFateID)
		Image_Add:setVisible(false)
		Image_Add:stopAllActions()
	else
		local Image_FateItem = Button_Material:getChildByName("Image_FateItem")
		if Image_FateItem then
			Image_FateItem:setVisible(false)
		end
		Image_Add:setVisible(true)
        Image_Add:stopAllActions()
        g_CreateScaleInOutAction(Image_Add)
	end
	
	if not nImageFateStateIndex then return end
	
	local Button_FateIconBase = getButton_FateIconBaseByIndex(nImageFateStateIndex)
	if not Button_FateIconBase  then return end
	local Image_FateState = tolua.cast(Button_FateIconBase:getChildByName("Image_FateState"), "ImageView")
	setImage_FateState(Image_FateState, nSelectedFateID)
end

function setImage_FateLevelUpPNL(bIsResetCanBeConsumeFateList)
	local tbTargetFate = g_Hero:getFateInfoByID(tbCardFateData.nTargetFateID)
	if bIsResetCanBeConsumeFateList then
		resetCanBeConsumeFateTableByTarget(tbTargetFate, "Game_CardFateLevelUp1")
		for nPosIndex = 1, 8 do
			setButton_Material(0, nPosIndex)
			tbCardFateData.tbSelectedFateList[nPosIndex] = 0
			local Button_Material = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Button_Material"..nPosIndex),"Button")
			local Image_Add = tolua.cast(Button_Material:getChildByName("Image_Add"),"ImageView")
			if next(tbCardFateData.tbCanBeConsumeFateList) ~= nil and tbCardFateData.tbCanBeConsumeFateList[nPosIndex].nUdressFateID > 0 then
				Image_Add:setVisible(true)
				Image_Add:stopAllActions()
				g_CreateScaleInOutAction(Image_Add)
			else
				Image_Add:setVisible(false)
				Image_Add:stopAllActions()
			end
		end
	end
	
	local Button_MainFate = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Button_MainFate"),"Button")
	g_SetFateWidgetByFateID(Button_MainFate, tbCardFateData.nTargetFateID)
	local CSV_CardFate = tbTargetFate:getCardFateCsv()
	local Label_Name = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Label_Name"),"Label")
	Label_Name:setText(tbTargetFate:getFateNameInColor(Label_Name))
	local Label_LevelSource = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Label_LevelSource"),"Label")
	Label_LevelSource:setText(tbTargetFate:getFateLevelStringInColor(Label_LevelSource))

	g_AdjustWidgetsPosition({Label_Name, Label_LevelSource},10)
		
	local Label_FatePropLB = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Label_FatePropLB"),"Label")
	local Label_FatePropSource = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Label_FatePropSource"),"Label")
	Label_FatePropLB:setText(tbTargetFate:getPropName())
	Label_FatePropSource:setText("+"..tbTargetFate:getPropValue())
	-- Label_FatePropSource:setPositionX(Label_FatePropLB:getSize().width)
	
	g_AdjustWidgetsPosition({Label_FatePropLB, Label_FatePropSource},10)
	
	local Label_FateExpLB = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Label_FateExpLB"),"Label")
	local Label_FateExp = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Label_FateExp"),"Label")

	local nAddExp = getAllMaterialExp()
	if nAddExp > 0 then
		Label_FateExp:setText(tbTargetFate:getCurLevFateExp().."(+"..nAddExp..")")
		g_setTextColor(Label_FateExp, ccs.COLOR.BRIGHT_GREEN)
	else
		Label_FateExp:setText(tbTargetFate:getCurLevFateExp())
		g_setTextColor(Label_FateExp, ccs.COLOR.WHITE)
	end
	
	local Label_FateExpMax = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Label_FateExpMax"),"Label")
	Label_FateExpMax:setText("/ "..tbTargetFate:getCurLevFateFullExp())
	g_AdjustWidgetsPosition({Label_FateExpLB, Label_FateExp, Label_FateExpMax},10)

	local nFateNewLevel = tbTargetFate:getFateNewLevByAddExp(nAddExp)
	local Image_ArrowIncreaseLevel = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Image_ArrowIncreaseLevel"),"ImageView")
	local Label_LevelTarget = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Label_LevelTarget"),"Label")
	local Image_ArrowIncreaseProp = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Image_ArrowIncreaseProp"),"ImageView")
	local Label_FatePropTarget = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Label_FatePropTarget"),"Label")

	if tbTargetFate:checkIsExpFull() then
		Image_ArrowIncreaseLevel:setVisible(true)
		Label_LevelTarget:setVisible(true)
		Image_ArrowIncreaseProp:setVisible(true)
		Label_FatePropTarget:setVisible(true)
		Label_LevelTarget:setText(tbTargetFate:getFateLevelStringInColorByLev(nFateNewLevel, Label_LevelTarget).." ".._T("满级"))
		Label_FatePropTarget:setText("+"..tbTargetFate:getFateBaseByLev(nFateNewLevel).PropValue)
	else
		Image_ArrowIncreaseLevel:setVisible(false)
		Label_LevelTarget:setVisible(false)
		Image_ArrowIncreaseProp:setVisible(false)
		Label_FatePropTarget:setVisible(false)
	end
	
	
	
end

local function onClickButton_MaterialCancel(nPosIndex)
	setButton_Material(0, nPosIndex)
end

local function onClickButton_MaterialAdd(nPosIndex)
	local nSelectedFateID = tbCardFateData.tbCanBeConsumeFateList[nPosIndex].nUdressFateID
	if nSelectedFateID > 0 then
		local nUndressFateIndex = tbCardFateData.tbCanBeConsumeFateList[nPosIndex].nUndressFateIndex
		setButton_Material(nSelectedFateID, nPosIndex, nUndressFateIndex)
	end
end

local function onClickButton_Material(pSender, nPosIndex)
	local nMaterialFateID = tbCardFateData.tbSelectedFateList[nPosIndex]
	if nMaterialFateID > 0 then
		onClickButton_MaterialCancel(nPosIndex)
	else
		local tbTargetFate = g_Hero:getFateInfoByID(tbCardFateData.nTargetFateID)
		if tbTargetFate:checkIsExpFullByAddExp(tbCardFateData.nAddExp) then
			g_ClientMsgTips:showMsgConfirm(_T("异兽经验已满，无法继续吞噬"))
			return
		end
		onClickButton_MaterialAdd(nPosIndex)
	end
	setImage_FateLevelUpPNL()
end

local function getMaxCanBeLevelUpFate()
	if not tbCardFateData.tbUnDressFateList or #tbCardFateData.tbUnDressFateList == 0 then
		return nil
	end
	
	for nIndex = 1, #tbCardFateData.tbUnDressFateList do
		if not tbCardFateData.tbUnDressFateList[nIndex]:checkIsExpFull() then
			return tbCardFateData.tbUnDressFateList[nIndex]
		end
	end
	
	return nil
end

local function onClickButton_FateIconBase(pSender, eventType)
	if eventType == ccs.TouchEventType.ended then
		local nUndressFateIndex = pSender:getTag()
		local tbUnDressFate = tbCardFateData.tbUnDressFateList[nUndressFateIndex]
		local nUdressFateID = tbUnDressFate:getServerId()
		if not tbCardFateData.Image_FateLevelUpPNL:isVisible() then
			local tbData = {}
			tbData.nFateID = nUdressFateID
			tbData.nCardID = tbCardFateData.nCardID
			g_WndMgr:showWnd("Game_TipFate", tbData)
			return
		end
		
        if nUdressFateID == tbCardFateData.nTargetFateID then return end
		
		local tbTargetFate = g_Hero:getFateInfoByID(tbCardFateData.nTargetFateID)
		if tbTargetFate:checkIsExpFullByAddExp(tbCardFateData.nAddExp) then
			g_ClientMsgTips:showMsgConfirm(_T("异兽经验已满，无法继续吞噬"))
			return
		end
		
		if (tbCardFateData.tbSelectedFateListID
			and tbCardFateData.tbSelectedFateListID[nUdressFateID]
		)then
			return
		end
		
		local nSelectedFateCount = GetTableLen(tbCardFateData.tbSelectedFateListID)
		if nSelectedFateCount >= 8 then return end

		setButton_Material(nUdressFateID, nPosIndex, nUndressFateIndex)
		setImage_FateLevelUpPNL()
	end
end

--设置材料列表
local function setPanel_FateRow(Panel_FateRow, tbMaterialFate, nColumn, nUndressFateIndex)
	local Button_FateIconBase = tolua.cast(Panel_FateRow:getChildByName("Button_FateIconBase"..nColumn),"Button")
	local Image_FateState = tolua.cast(Button_FateIconBase:getChildByName("Image_FateState"),"ImageView")
	local Label_FateState = tolua.cast(Image_FateState:getChildByName("Label_FateState"),"Label")
	local Label_Name = tolua.cast(Button_FateIconBase:getChildByName("Label_Name"),"Label")
	Image_FateState:setVisible(false)
	Label_FateState:setVisible(false)
	Label_Name:setVisible(false)

	if tbMaterialFate then
		local CSV_CardFate = tbMaterialFate:getCardFateCsv()
		local nMaterialFateID = tbMaterialFate:getServerId()
		if nMaterialFateID == tbCardFateData.nUpgradeFateID then
			tbCardFateData.nUpgradeFateIndex = nUndressFateIndex
		end
		Button_FateIconBase:setTag(nUndressFateIndex)
		Button_FateIconBase:addTouchEventListener(onClickButton_FateIconBase)
		Button_FateIconBase:setTouchEnabled(true)
		Label_Name:setVisible(true)
		Label_Name:setText(tbMaterialFate:getFateNameWithLevelInColor(Label_Name))
		g_SetFateWidgetByFateID(Button_FateIconBase, nMaterialFateID)

		setImage_FateState(Image_FateState, nMaterialFateID)
	else
		local Image_FateItem = Button_FateIconBase:getChildByName("Image_FateItem")
		if Image_FateItem then
			Image_FateItem:setVisible(false)
		end
	end
end

local function updateListViewItem(Panel_FateRow, nRow)
	Panel_FateRow:setName("Panel_FateRow"..nRow)
	for nColumn = 1, 4 do
		local nUndressFateIndex = (nRow-1)*4 + nColumn
		local tbMaterialFate = tbCardFateData.tbUnDressFateList[nUndressFateIndex]
		setPanel_FateRow(Panel_FateRow, tbMaterialFate, nColumn, nUndressFateIndex)
	end
end

local function onClickButton_Fate(pSender, nPosIndex)
	local tbCard =  g_Hero:getCardObjByServID(tbCardFateData.nCardID)
	local nReleaseLevel = g_DataMgr:getCardFateReleaseCsvLevel(nPosIndex)
	if tbCard:getLevel() < nReleaseLevel then
		
		g_ClientMsgTips:showMsgConfirm(string.format(_T("需要伙伴达到%d级方可解锁该空位"), nReleaseLevel))
		return
	end
	
	local nFateID = tbCard:getFateIDByPos(nPosIndex)
	if nFateID > 0 then
		local tbData = {}
		tbData.nCardID = tbCardFateData.nCardID
		tbData.nChooseIdx = nPosIndex
		tbData.nFateID = nFateID
		g_WndMgr:showWnd("Game_TipFate", tbData)
		return
	end
	for nIndex = 1, #tbCardFateData.tbUnDressFateList do
		local tbFate = tbCardFateData.tbUnDressFateList[nIndex]
		if tbFate:checkIsCanBeEquiped(tbCard) then 
			g_MsgMgr:requestChangeFate(macro_pb.Operator_Fate_Type_Inlay, tbCardFateData.nCardID, nPosIndex, tbFate:getServerId())
			break
		end
	end
end

local function setCardEquipedFateInfo(tbCard, CSV_CardBase)
	local Image_FateStreangth = tolua.cast(tbCardFateData.Image_FatePNL:getChildByName("Image_FateStreangth"),"ImageView")
	
	local Label_FateStreangthLB = tolua.cast(Image_FateStreangth:getChildByName("Label_FateStreangthLB"),"Label")
	local Label_FateStreangth = tolua.cast(Image_FateStreangth:getChildByName("Label_FateStreangth"),"Label")
	Label_FateStreangth:setText(tbCard:getFateExp())
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_FateStreangthLB:setFontSize(18)
		Label_FateStreangth:setFontSize(18)
	end
	-- Label_FateStreangth:setPositionX(Label_FateStreangthLB:getSize().width)
	g_AdjustWidgetsPosition({Label_FateStreangthLB, Label_FateStreangth},2)
	--已经镶嵌上的异兽
	for nPosIndex =1, 8 do
		local Button_Fate = tolua.cast(tbCardFateData.Image_FatePNL:getChildByName("Button_Fate"..nPosIndex),"Button")
		g_SetBtnWithGuideCheck(Button_Fate, nPosIndex, onClickButton_Fate, true, nil, nil, nil)
		
		local nReleaseLevel = g_DataMgr:getCardFateReleaseCsvLevel(nPosIndex)
		

        local Label_Name = tolua.cast(Button_Fate:getChildByName("Label_Name"),"Label")
		local Label_Level = tolua.cast(Button_Fate:getChildByName("Label_Level"),"Label")
		local Image_Add = tolua.cast(Button_Fate:getChildByName("Image_Add"),"ImageView")
		Label_Name:setVisible(false)

        if tbCard:getLevel() < nReleaseLevel then
            Label_Level:setVisible(true)
            Label_Name:setVisible(false)
            Label_Level:setText(_T("Lv.")..nReleaseLevel)
            Button_Fate:setBright(false)
            Image_Add:setVisible(false)

            local Image_FateItem = Button_Fate:getChildByName("Image_FateItem")
            if  Image_FateItem then
                Image_FateItem:setVisible(false)
            end
        else
		    Button_Fate:setBright(true)
		    Label_Level:setVisible(false)
		    Image_Add:setVisible(tbCard:getLevel() >= nReleaseLevel)
		    Label_Name:setZOrder(2)
		    Label_Level:setZOrder(2)
		    local nFateID = tbCard:getFateIDByPos(nPosIndex)
		    if nFateID > 0 then
			    g_SetFateWidgetByFateID(Button_Fate, nFateID, nPosIndex)
			    Label_Name:setVisible(true)
			    Label_Level:setVisible(false)
                Image_Add:setVisible(false)
			    local tbFateInfo = g_Hero:getFateInfoByID(nFateID)
			    Label_Name:setText(tbFateInfo:getFateNameWithLevelInColor(Label_Name))
            else
                local Image_FateItem = Button_Fate:getChildByName("Image_FateItem")
                if  Image_FateItem then
                    Image_FateItem:setVisible(false)
                end
			    Label_Level:setVisible(false)
                Image_Add:setVisible(true)
                Image_Add:stopAllActions()

				if tbCard:checkIsCanEquipFateByPosIndex(nPosIndex) then
					g_CreateScaleInOutAction(Image_Add)
				else
					Image_Add:setVisible(false)
					Image_Add:stopAllActions()
				end
		    end
        end
	end
end

--设置伙伴异兽信息
local function setCardFateInfo(nCardID)
    local tbCard = g_Hero:getCardObjByServID(nCardID)
	if not tbCard then return end
    local CSV_CardBase = tbCard:getCsvBase()
	setCardEquipedFateInfo(tbCard, CSV_CardBase)

	local Label_Name = tolua.cast(tbCardFateData.Image_FatePNL:getChildByName("Label_Name"),"Label")
	Label_Name:setText(tbCard:getNameWithSuffix(Label_Name))
	local Label_Level = tolua.cast(tbCardFateData.Image_FatePNL:getChildByName("Label_Level"),"Label")
	Label_Level:setText(tbCard:getLevelString(Label_Level))
	
	g_AdjustWidgetsPosition({Label_Name, Label_Level}, 10)
end

local function onSwitch_PageView_Card(Panel_CardPage, nIndex)
	g_CurrentPageViewCardIndex = nIndex
	tbCardFateData.nCardID = g_Hero:GetCardIDByIndexPV(tbCardFateData.PageView_Card:getCurPageIndex())
	tbCardFateData.nSelectedIndex = nil
	setCardFateInfo(tbCardFateData.nCardID)
end

function Game_CardFate1:showFateUpgradeAnimation(strWndName)
	local Button_FateIconBase = getButton_FateIconBaseByIndex(tbCardFateData.nUpgradeFateIndex)
	if Button_FateIconBase then
		local Image_FateItem = tolua.cast(Button_FateIconBase:getChildByName("Image_FateItem"), "ImageView")
		if Image_FateItem then
			local armature, userAnimation = g_CreateCoCosAnimationWithCallBacks("XianMaiActivate", nil, nil, 5)
			local tbWorldPos = Image_FateItem:getWorldPosition()
			armature:setPositionXY(tbWorldPos.x - 1, tbWorldPos.y + 1)
			armature:setScale(1.25)
			self.rootWidget:addNode(armature, 100)
			userAnimation:playWithIndex(0)
		end
	end
	
	if strWndName == "Game_CardFateLevelUp1" then
		local Button_MainFate = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Button_MainFate"),"Button")
		local Image_FateItem = tolua.cast(Button_MainFate:getChildByName("Image_FateItem"), "ImageView")
		if Image_FateItem then
			local armature, userAnimation = g_CreateCoCosAnimationWithCallBacks("XianMaiActivate", nil, nil, 5)
			local tbWorldPos = Image_FateItem:getWorldPosition()
			armature:setPositionXY(tbWorldPos.x - 1, tbWorldPos.y + 1)
			armature:setScale(1.35)
			self.rootWidget:addNode(armature, 100)
			userAnimation:playWithIndex(0)
		end
	end
end

function Game_CardFate1:refreshWnd(bRefreshCurrentPage, nUpgradeFateID)
	if tbCardFateData.strWndName == "Game_CardFate1" then
		if bRefreshCurrentPage then
			onSwitch_PageView_Card()
		end
		tbCardFateData.nUpgradeFateID = nUpgradeFateID
		tbCardFateData.nUpgradeFateIndex = 0
		updateListView_FateMaterialList("Game_CardFate1")
		if nUpgradeFateID then
			self:showFateUpgradeAnimation("Game_CardFate1")
		end
		tbCardFateData.Button_AutoCompose:setBright(true)
		tbCardFateData.Button_AutoCompose:setTouchEnabled(true)
		tbCardFateData.Button_AutoCompose:setVisible(true)
	elseif tbCardFateData.strWndName == "Game_CardFateLevelUp1" then
		tbCardFateData.nUpgradeFateID = nUpgradeFateID
		tbCardFateData.nUpgradeFateIndex = 0
		updateListView_FateMaterialList("Game_CardFateLevelUp1")
		setImage_FateLevelUpPNL(true)
		if nUpgradeFateID then
			self:showFateUpgradeAnimation("Game_CardFateLevelUp1")
		end
		tbCardFateData.Button_AutoCompose:setBright(false)
		tbCardFateData.Button_AutoCompose:setTouchEnabled(false)
		tbCardFateData.Button_AutoCompose:setVisible(false)
	end
end

local function onClickButton_AutoCompose(pSender, nTag)
	local tbMaxCanBeLevelUpFate = getMaxCanBeLevelUpFate()
	if not tbMaxCanBeLevelUpFate then return end
	resetCanBeConsumeFateTableByTarget(tbMaxCanBeLevelUpFate, "Game_CardFate1")
	local tbBeConsumedFateList = {}
	local nFateRemainExp = tbMaxCanBeLevelUpFate:getFateRemainExp()
	local nCurIndex = #tbCardFateData.tbUnDressFateList
	local nCount = 1
	for nIndex = 1, #tbCardFateData.tbUnDressFateList do	--倒序判断最垃圾的材料
		local tbBeConsumedFate = tbCardFateData.tbUnDressFateList[nCurIndex]
		if tbBeConsumedFate:checkCanBeOneKeyConsumed(tbMaxCanBeLevelUpFate) then
			local nAddExp = tbBeConsumedFate:getAddExp()
			if (nFateRemainExp + 120 - nAddExp) < 0 then --经验超载
				--Jump Over
			else
				nFateRemainExp = nFateRemainExp - nAddExp
				table.insert(tbBeConsumedFateList, tbBeConsumedFate:getServerId())
				nCount = nCount + 1
			end
			if nCount >= 90 then
				break
			end
		end
		nCurIndex = nCurIndex - 1
	end
	
	if tbBeConsumedFateList and #tbBeConsumedFateList > 0 then
		g_MsgMgr:requestUpgardeFate(tbMaxCanBeLevelUpFate:getServerId(), tbBeConsumedFateList)
	end
end

local function onClickButton_AutoAdd(pSender, nTag)
	local tbTargetFate = g_Hero:getFateInfoByID(tbCardFateData.nTargetFateID)
	if not tbTargetFate then
		return
	end
	
	if tbTargetFate:checkIsExpFull() then
		g_ClientMsgTips:showMsgConfirm(_T("异兽经验已满，无法继续吞噬"))
		return
	end
	
	for nPosIndex = 1, 8 do
		local nAddExp = getAllMaterialExp()
		if tbTargetFate:checkIsExpFullByAddExp(nAddExp) then
			break
		end
		if tbCardFateData.tbCanBeConsumeFateList[nPosIndex].nUdressFateID > 0 then
			setButton_Material(0, nPosIndex)
			local nUdressFateID = tbCardFateData.tbCanBeConsumeFateList[nPosIndex].nUdressFateID
			local nUndressFateIndex = tbCardFateData.tbCanBeConsumeFateList[nPosIndex].nUndressFateIndex
			setButton_Material(nUdressFateID, nPosIndex, nUndressFateIndex)
		end
	end
	setImage_FateLevelUpPNL()
end
	
local function onClickButton_FateConsume(pSender, nTag)
	local tbTargetFate = g_Hero:getFateInfoByID(tbCardFateData.nTargetFateID)
	if not tbTargetFate then
		return
	end
	if tbTargetFate:checkIsExpFull() then
		g_ClientMsgTips:showMsgConfirm(_T("异兽经验已满，无法继续吞噬"))
		return
	end
	
	local function onClickConfirm()
		local tbSelectedFateListToServer = {}
		for nPosIndex = 1, 8 do
			if tbCardFateData.tbSelectedFateList[nPosIndex] > 0 then
				table.insert(tbSelectedFateListToServer, tbCardFateData.tbSelectedFateList[nPosIndex])
			end
		end
		if not tbSelectedFateListToServer or #tbSelectedFateListToServer == 0 then return end
		g_MsgMgr:requestUpgardeFate(tbTargetFate:getServerId(), tbSelectedFateListToServer)
	end
	
	if tbTargetFate:checkIsExpFullByAddExp(tbCardFateData.nAddExp) then
		g_ClientMsgTips:showConfirm(_T("异兽吞噬的经验会造成浪费，需要继续吗？"), onClickConfirm, nil)
		return
	else
		onClickConfirm()
	end
end

function Game_CardFate1:initWnd(rootWidget)
	tbCardFateData = {}
	tbCardFateData.layer = rootWidget
	tbCardFateData.tbCanBeConsumeFateList = {}
	tbCardFateData.tbSelectedFateList = {}
	tbCardFateData.tbSelectedFateListID = {}

	--pageview 初始化
	tbCardFateData.Image_FatePNL = tolua.cast(tbCardFateData.layer:getChildByName("Image_FatePNL"),"ImageView")
	tbCardFateData.Image_FatePackagePNL = tolua.cast(tbCardFateData.layer:getChildByName("Image_FatePackagePNL"),"ImageView")
	tbCardFateData.Image_FateLevelUpPNL = tolua.cast(tbCardFateData.layer:getChildByName("Image_FateLevelUpPNL"),"ImageView")

	--增加page view效果
	local function setPanel_CardPage(Panel_CardPage, nIndex)
		local nCardID = g_Hero:GetCardIDByIndexPV(nIndex)
		local tbCard = g_Hero:getCardObjByServID(nCardID)
		local CSV_CardBase = tbCard:getCsvBase()
		local Panel_Card = tolua.cast(Panel_CardPage:getChildByName("Panel_Card"), "Layout")
		local Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"), "ImageView")
		local CCNode_Skeleton = g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, 1)
		Image_Card:removeAllNodes()
		Image_Card:loadTexture(getUIImg("Blank"))
		Image_Card:setPositionXY(CSV_CardBase.Pos_X*Panel_Card:getScale()/0.6, CSV_CardBase.Pos_Y*Panel_Card:getScale()/0.6)
		Image_Card:addNode(CCNode_Skeleton)
		g_runSpineAnimation(CCNode_Skeleton, "idle", true)
	end

	local Button_ForwardPage = tolua.cast(tbCardFateData.Image_FatePNL:getChildByName("Button_ForwardPage"),"Button")
	local Button_NextPage = tolua.cast(tbCardFateData.Image_FatePNL:getChildByName("Button_NextPage"),"Button")
	
	local PageView_Card = tolua.cast(tbCardFateData.Image_FatePNL:getChildByName("PageView_Card"),"PageView")
	local Panel_CardPage = tolua.cast(PageView_Card:getChildByName("Panel_CardPage"),"Layout")

	tbCardFateData.PageView_Card = Class_LuaPageView.new()
	tbCardFateData.PageView_Card:registerUpdateFunction(setPanel_CardPage)
	tbCardFateData.PageView_Card:registerClickEvent(onSwitch_PageView_Card)
	tbCardFateData.PageView_Card:setModel(Panel_CardPage, Button_ForwardPage, Button_NextPage, 0.50, 0.50)
	tbCardFateData.PageView_Card:setPageView(PageView_Card)

	--listview
	tbCardFateData.ListView_FateMaterialList = tolua.cast(tbCardFateData.Image_FatePackagePNL:getChildByName("ListView_FateMaterialList"),"ListViewEx")
	local imgScrollSlider = tbCardFateData.ListView_FateMaterialList:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_FateMaterialList_X then
		g_tbScrollSliderXY.ListView_FateMaterialList_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_FateMaterialList_X + 8)

	registerListViewEvent(tbCardFateData.ListView_FateMaterialList, g_WidgetModel.Panel_FateRow, updateListViewItem, 0)

    for nPosIndex = 1, 8 do
        local Button_Material = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Button_Material"..nPosIndex),"Button")
		g_SetBtnWithEvent(Button_Material, nPosIndex, onClickButton_Material, true, true)
    end

	local Button_AutoCompose = tolua.cast(tbCardFateData.Image_FatePackagePNL:getChildByName("Button_AutoCompose"),"Button")
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Button_AutoCompose:setSize(CCSize(190,50))
	end
	
	tbCardFateData.Button_AutoCompose = Button_AutoCompose
	g_SetBtnWithGuideCheck(Button_AutoCompose, nil, onClickButton_AutoCompose, true)
		
	local Button_AutoAdd = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Button_AutoAdd"), "Button")
	g_SetBtnWithGuideCheck(Button_AutoAdd, nil, onClickButton_AutoAdd, true, nil, nil, nil)
	
	local Button_FateConsume = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Button_FateConsume"), "Button")
	g_SetBtnWithGuideCheck(Button_FateConsume, nil, onClickButton_FateConsume, true)

	local Image_FateStreangth = tolua.cast(tbCardFateData.Image_FatePNL:getChildByName("Image_FateStreangth"),"ImageView")
	g_SetBtnWithPressingEvent(Image_FateStreangth, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	
	self:registerCloseEvent(rootWidget)
	
	local Image_SymbolBlueLight = tolua.cast(tbCardFateData.Image_FateLevelUpPNL:getChildByName("Image_SymbolBlueLight"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
	
	local Image_SymbolBlueLight = tolua.cast(tbCardFateData.Image_FatePNL:getChildByName("Image_SymbolBlueLight"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
	
	local Image_SymbolOutside = tolua.cast(tbCardFateData.Image_FatePNL:getChildByName("Image_SymbolOutside"), "ImageView")
	local actionRotateTo_SymbolOutside = CCRotateBy:create(45, -360)
	local actionForever_SymbolOutside = CCRepeatForever:create(actionRotateTo_SymbolOutside)
	Image_SymbolOutside:runAction(actionForever_SymbolOutside)
	
	local Image_SymbolInside = tolua.cast(tbCardFateData.Image_FatePNL:getChildByName("Image_SymbolInside"), "ImageView")
	local actionRotateTo_SymbolInside = CCRotateBy:create(45, 360)
	local actionForever_SymbolInsidet = CCRepeatForever:create(actionRotateTo_SymbolInside)
	Image_SymbolInside:runAction(actionForever_SymbolInsidet)
end

function Game_CardFate1:closeWnd()
	tbCardFateData.tbCard = nil
	tbCardFateData.CSV_CardBase = nil
    tbCardFateData.nTargetFateID = nil
    tbCardFateData.tbCanBeConsumeFateList = {}
    if tbCardFateData.PageView_Card then
    	tbCardFateData.PageView_Card:ReleaseItemModle()
    end
    
    tbCardFateData.PageView_Card = nil
end

function Game_CardFate1:registerCloseEvent(rootWidget)
	local Button_Return = tolua.cast(rootWidget:getChildByName("Button_Return"), "Button")

	if Button_Return then
		local function onClickButton_Return(pSender, nTag)
			self:onClickButton_Return()
		end
		g_SetBtnWithGuideCheck(Button_Return, nil, onClickButton_Return, true, true, nil, nil)
	else
		--
	end
end

function Game_CardFate1:onClickButton_Return()
	local b_visible = tbCardFateData.Image_FateLevelUpPNL:isVisible()
	if b_visible then
		tbCardFateData.strWndName = "Game_CardFate1"
		tbCardFateData.Image_FateLevelUpPNL:setVisible(false)
		self:refreshWnd(true)
		tbCardFateData.nTargetFateID = nil
		tbCardFateData.Image_FatePNL:setVisible(true)
	else
		g_WndMgr:closeWnd("Game_CardFate1")
	end
end

function Game_CardFate1:openWnd(tbData)
	YI_SHOU_S = true
	if g_bReturn then return end
	if not tbData then return end
	if tbData.nFateID then
		tbCardFateData.Image_FateLevelUpPNL:setVisible(true)
		tbCardFateData.Image_FatePNL:setVisible(false)
		tbCardFateData.strWndName = "Game_CardFateLevelUp1"
		tbCardFateData.nTargetFateID = tbData.nFateID
		self:refreshWnd()
	else
		tbCardFateData.Image_FateLevelUpPNL:setVisible(false)
		tbCardFateData.Image_FatePNL:setVisible(true)
		tbCardFateData.nCardID = tbData.nCardID
		tbCardFateData.nAddExp = 0
		tbCardFateData.strWndName = "Game_CardFate1"
		
		self:refreshWnd()
		
		g_Hero:SetCardFlagPV(1)
		tbCardFateData.PageView_Card:setCurPageIndex(g_Hero:GetCardIndexByIDPV(tbCardFateData.nCardID))
		tbCardFateData.PageView_Card:updatePageView(g_Hero:GetCardAmmountForPV())
	end
end