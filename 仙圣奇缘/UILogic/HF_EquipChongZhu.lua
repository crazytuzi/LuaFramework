--------------------------------------------------------------------------------------
-- 文件名:	HF_EquipChongZhu.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  flamehong
-- 日  期:	2014-10-30 17:04
-- 版  本:	1.0
-- 描  述:	重铸界面
-- 应  用:  

--------------------------------------------------------------------------------------
Game_EquipChongZhu = class("Game_EquipChongZhu")
Game_EquipChongZhu.__index = Game_EquipChongZhu

local tbEquipChongZhu = {}
local function setRandomItem(widget, nNo, nType, nValue)
	local Label_RandomProp = tolua.cast(g_WidgetModel.RandomProp:clone(),"Label")
	Label_RandomProp:setText(g_PropName[nType])
	
	local Label_ValueArea = tolua.cast(Label_RandomProp:getChildByName("Label_ValueArea"),"Label")

	local bIsPercent, nBasePercent = g_CheckPropIsPercent(nType)
	if bIsPercent then 
		--在重铸的时候 概率不会超过 此数值
		Label_ValueArea:setText("[0~"..string.format("%.2f", nValue/100).."%".."]")
	else
		Label_ValueArea:setText("[0~"..nValue.."]")
	end
	
    Label_RandomProp:setPositionXY(-285, -80-30*(nNo-1))
	widget:addChild(Label_RandomProp)
end

local function isDiffRandom(tbEquip, nNo, nPropID)
	for key, value in pairs(tbEquip.tbProps) do
		if key ~= nNo and value.Prop_Type == nPropID then
			return false
		end
	end 
	return true
end

local function setRandomInfo(bVisible, tbEquip, nNo)
	local ImageView_EquipChongZhuPNL = tolua.cast(tbEquipChongZhu.layer:getChildByName("ImageView_EquipChongZhuPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(ImageView_EquipChongZhuPNL:getChildByName("Image_ContentPNL"),"ImageView")
	local Image_RandomPropPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_RandomPropPNL"),"ImageView")
	Image_RandomPropPNL:setVisible(bVisible)
	local Label_Tip = tolua.cast(Image_ContentPNL:getChildByName("Label_Tip"),"Label")
	Label_Tip:setVisible(bVisible)
	if not bVisible then return end
	Image_RandomPropPNL:removeAllChildren()
	local tbCsvBase = tbEquip:getCsvBase()
	local CSV_EquipPropRandType = g_DataMgr:getCsvConfig_SecondKeyTableData("EquipPropRandType", tbCsvBase.PropTypeRandID)
	local nNum = 0
	for i=1, #CSV_EquipPropRandType do
		if isDiffRandom(tbEquip, nNo, CSV_EquipPropRandType[i].PropID) then
            nNum = nNum + 1
			setRandomItem(Image_RandomPropPNL, nNum, CSV_EquipPropRandType[i].PropID, CSV_EquipPropRandType[i].PropArea5)
		end
	end
end

local function setChongZhuInfo(nEquipID)
	local tbEquip = g_Hero:getEquipObjByServID(nEquipID)
	local tbCsvBase = tbEquip:getCsvBase()
	local ImageView_EquipChongZhuPNL = tolua.cast(tbEquipChongZhu.layer:getChildByName("ImageView_EquipChongZhuPNL"),"ImageView")
	
	local Image_ContentPNL = tolua.cast(ImageView_EquipChongZhuPNL:getChildByName("Image_ContentPNL"),"ImageView")
	local Image_LuDing = tolua.cast(Image_ContentPNL:getChildByName("Image_LuDing"),"ImageView")
	local Image_EuipeIconCircle = tolua.cast(Image_LuDing:getChildByName("Image_EuipeIconCircle"),"ImageView")
	Image_EuipeIconCircle:loadTexture(getUIImg("FrameEquipCircle"..tbCsvBase.ColorType))
	
	local rLevel = tbEquip:getRefineLev()
	local Image_RefineLevel = tolua.cast(Image_ContentPNL:getChildByName("Image_RefineLevel"),"ImageView")
	if rLevel > 0 then 
		Image_RefineLevel:loadTexture(getUIImg("Icon_StarLevel"..rLevel))
		Image_RefineLevel:setVisible(true)
	else
		Image_RefineLevel:setVisible(false)
	end
	
	local Image_Icon = tolua.cast(Image_EuipeIconCircle:getChildByName("Image_Icon"),"ImageView")
	Image_Icon:loadTexture(getIconImg(tbCsvBase.Icon))
	g_SetEquipSacle(Image_Icon,tbCsvBase.SubType)
	
	local  Label_SourceName = tolua.cast(Image_ContentPNL:getChildByName("Label_SourceName"),"Label")
    Label_SourceName:setText(tbCsvBase.Name)
    g_SetWidgetColorBySLev(Label_SourceName, tbCsvBase.ColorType)

	
	local nStrengthenLev = tbEquip:getStrengthenLev()
	local Label_SourceStrengthenLevel = tolua.cast(Image_ContentPNL:getChildByName("Label_SourceStrengthenLevel"),"Label")
	Label_SourceStrengthenLevel:setText(_T("Lv.")..nStrengthenLev)
	--左对齐
	Label_SourceName:setPositionX(-305-(Label_SourceName:getSize().width+Label_SourceStrengthenLevel:getSize().width)/2)
	g_AdjustWidgetsPosition({Label_SourceName, Label_SourceStrengthenLevel},10)
	
	local Button_ChongZhu = tolua.cast(Image_ContentPNL:getChildByName("Button_ChongZhu"),"Button")
	local BitmapLabel_NeedMoney = tolua.cast(Button_ChongZhu:getChildByName("BitmapLabel_NeedMoney"),"LabelBMFont")
	BitmapLabel_NeedMoney:setText(tbCsvBase.ChongZhuBaseCost)
	BitmapLabel_NeedMoney:setVisible(false)
	
	local Image_Coins = tolua.cast(Button_ChongZhu:getChildByName("Image_Coins"),"ImageView")
	Image_Coins:setVisible(false)
	
	g_adjustWidgetsRightPosition({BitmapLabel_NeedMoney, Image_Coins},2)
		
	local tbMaterialCfg = g_DataMgr:getEquipWorkMaterialGroupCsv(tbCsvBase.ChongZhuMaterialGroupID)
	local BitmapLabel_FuncName = tolua.cast(Button_ChongZhu:getChildByName("BitmapLabel_FuncName"),"LabelBMFont")
	BitmapLabel_FuncName:setAnchorPoint(ccp(0.5, 0.5))
	BitmapLabel_FuncName:setPositionXY(4, 3)
	
	--重铸按钮
	local function onClickChongZhu(pSender, nTag)
		if nEquipID and nEquipID > 0 then
			if not tbEquipChongZhu.nChoose then
				--g_ClientMsgTips:showMsgConfirm("没有选中重铸的属性")
				return 
			end
			
			g_MsgMgr:requestEquipChongZhu(nEquipID, tbEquipChongZhu.nChoose)
			
			-- 测试概率的代码
			-- local function sendMsg()
				-- g_MsgMgr:requestEquipChongZhu(nEquipID, tbEquipChongZhu.nChoose)
			-- end
			-- g_Timer:pushLimtCountTimer(5000, 0.05, sendMsg)
		end
    end
	g_SetBtnWithGuideCheck(Button_ChongZhu, 1, onClickChongZhu, true)
	g_SetButtonEnabled(Button_ChongZhu, false, _T("选择需要替换掉的属性"), true)
	
	for i = 1, 3 do
		local CheckBox_AdditionalProp = tolua.cast(Image_ContentPNL:getChildByName("CheckBox_AdditionalProp"..i),"CheckBox")
		local Label_AdditionalProp = tolua.cast(CheckBox_AdditionalProp:getChildByName("Label_AdditionalProp"),"Label")
		if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
			local size = 19
			Label_AdditionalProp:setFontSize(size)
		end
		
		local tbRandomProp = tbEquip.tbProps[i]
		if tbRandomProp then
			local bIsPercent, nBasePercent = g_CheckPropIsPercent(tbRandomProp.Prop_Type)
			if bIsPercent then 
				Label_AdditionalProp:setText(g_PropName[tbRandomProp.Prop_Type].." +"..string.format("%.2f", tbRandomProp.Prop_Value/100).."%")
			else
				Label_AdditionalProp:setText(g_PropName[tbRandomProp.Prop_Type].." +"..tbRandomProp.Prop_Value)
			end

			Label_AdditionalProp:setVisible(true)
			--随机颜色
			setRandomPropColor(Label_AdditionalProp, tbRandomProp.Prop_Value, tbCsvBase.PropTypeRandID)
		else
			Label_AdditionalProp:setVisible(false)
		end
	end
	setRandomInfo(false)
	
	for i = 1,3 do
		local CheckBox_AdditionalProp = tolua.cast(Image_ContentPNL:getChildByName("CheckBox_AdditionalProp"..i),"CheckBox")
		tbEquipChongZhu.CBGroup:PushBack(CheckBox_AdditionalProp, function()
			tbEquipChongZhu.select = i
			local tbEquip = g_Hero:getEquipObjByServID(tbEquipChongZhu.nEquipID)
			local tbCsvBase = tbEquip:getCsvBase()
			local tbRandomProp = tbEquip.tbProps[i]
			local bVisible = false
			if tbRandomProp then
				bVisible = true
			end
			
			tbEquipChongZhu.nChoose = i-1
			setRandomInfo(bVisible, tbEquip, i)

			local bMaterialEnough = g_CheckChongZhuMaterialByCsv(tbMaterialCfg)
			if g_Hero:getCoins() < tbCsvBase.ChongZhuBaseCost then
				g_SetButtonEnabled(Button_ChongZhu, false, _T("铜钱不足"))
				g_SetLabelRed(BitmapLabel_NeedMoney, true)
			elseif not bMaterialEnough then
				g_SetButtonEnabled(Button_ChongZhu, bMaterialEnough, _T("材料不足"))
			else
				g_SetButtonEnabled(Button_ChongZhu, true, _T("重铸费用"))
				g_SetLabelRed(BitmapLabel_NeedMoney, false)
			end	
			for i = 1,6 do 
				local value = tbMaterialCfg
				if not value then return end
				local param = { 
					nNo= i,--第几个位置
					nNeedNum =value[tostring("MaterialNum"..i)],--消耗数值,
					widgetParent = Image_ContentPNL,
					nCsvID = value[tostring("MaterialID"..i)],
					nStarLevel = value[tostring("MaterialStarLevel"..i)],
				}
				g_SetMaterialBtn(param)
			end
			BitmapLabel_NeedMoney:setVisible(true)
			Image_Coins:setVisible(true)
			BitmapLabel_FuncName:setAnchorPoint(ccp(0.0, 0.5))
			BitmapLabel_FuncName:setPositionXY(-135, 3)
		end)
	end
	
	if tbEquipChongZhu.select then 
		tbEquipChongZhu.CBGroup:Check(tbEquipChongZhu.select)
	end
	
end

function Game_EquipChongZhu:initWnd(widget)
	tbEquipChongZhu = {}
	tbEquipChongZhu.layer = widget
	tbEquipChongZhu.CBGroup = CheckBoxGroup:New()
	
	local ImageView_EquipChongZhuPNL = tolua.cast(tbEquipChongZhu.layer:getChildByName("ImageView_EquipChongZhuPNL"),"ImageView")
	local Button_ChongZhuGuide = tolua.cast(ImageView_EquipChongZhuPNL:getChildByName("Button_ChongZhuGuide"), "Button")
	g_RegisterGuideTipButtonWithoutAni(Button_ChongZhuGuide)
end

function freshChongZhuWnd(nEquipID)
	if not tbEquipChongZhu.bOpen then return end
	tbEquipChongZhu.nEquipID = nEquipID
	tbEquipChongZhu.nChoose = nil
	
	local ImageView_EquipChongZhuPNL = tolua.cast(tbEquipChongZhu.layer:getChildByName("ImageView_EquipChongZhuPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(ImageView_EquipChongZhuPNL:getChildByName("Image_ContentPNL"),"ImageView")
	local Image_LuDing = tolua.cast(Image_ContentPNL:getChildByName("Image_LuDing"),"ImageView")
	local Image_EuipeIconCircle = tolua.cast(Image_LuDing:getChildByName("Image_EuipeIconCircle"),"ImageView")
	local Image_Icon = tolua.cast(Image_EuipeIconCircle:getChildByName("Image_Icon"),"ImageView")
	g_ShowEquipDaZaoAnimation(Image_Icon)
	setChongZhuInfo(nEquipID)
	
	local function writefile(path, content)
		local file = io.open(path, "ab")
		if file then
			if file:write(content) == nil then return false end
			io.close(file)
			return true
		else
			return false
		end
	end
	
	-- 测试概率的代码
	-- local tbEquip = g_Hero:getEquipObjByServID(nEquipID)
	-- local tbCsvBase = tbEquip:getCsvBase()
	-- local tbRandomProp = tbEquip.tbProps[1]
	
	-- local CSV_EquipPropRandType = g_DataMgr:getEquipPropRandTypeCsv(tbCsvBase.PropTypeRandID, 1)

	-- local nIndex = 0
	-- if tbRandomProp.Prop_Value <= CSV_EquipPropRandType.PropArea1 then
		-- nIndex = 1
	-- elseif  tbRandomProp.Prop_Value <= CSV_EquipPropRandType.PropArea2 then
		-- nIndex = 2
	-- elseif tbRandomProp.Prop_Value <= CSV_EquipPropRandType.PropArea3 then
		-- nIndex = 3
	-- elseif tbRandomProp.Prop_Value <= CSV_EquipPropRandType.PropArea4 then
		-- nIndex = 4
	-- elseif tbRandomProp.Prop_Value <= CSV_EquipPropRandType.PropArea5 then
		-- nIndex = 5
    -- else
        -- nIndex = 0
	-- end
	
	-- local logFileName = string.format("ChongZhu.log", g_logPath)
	-- writefile(logFileName, nIndex.."-"..tbRandomProp.Prop_Value.."\n")
end

function Game_EquipChongZhu:closeWnd(nEquipID)
	tbEquipChongZhu.bOpen = nil
	tbEquipChongZhu.nEquipID = nil
	tbEquipChongZhu.nChoose = nil
	tbEquipChongZhu.select = nil
end 

function Game_EquipChongZhu:openWnd(nEquipID)
	if not nEquipID then return end 
	local ImageView_EquipChongZhuPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_EquipChongZhuPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(ImageView_EquipChongZhuPNL:getChildByName("Image_ContentPNL"),"ImageView")
	--隐藏上一个装备的重铸材料
	for i = 1,6 do 
		local btnMaterial = tolua.cast(Image_ContentPNL:getChildByName("Button_Material"..i),"Button")
		local Img_Material = btnMaterial:getChildByName("EquipWorkMaterial")
		if Img_Material then 
			Img_Material:setVisible(false)
		end
	end
	tbEquipChongZhu.bOpen = true
	tbEquipChongZhu.nEquipID = nEquipID
	setChongZhuInfo(nEquipID)
end

function Game_EquipChongZhu:showWndOpenAnimation(funcWndOpenAniCall)
	local ImageView_EquipChongZhuPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_EquipChongZhuPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(ImageView_EquipChongZhuPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_EquipChongZhu:showWndCloseAnimation(funcWndCloseAniCall)
	local ImageView_EquipChongZhuPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_EquipChongZhuPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(ImageView_EquipChongZhuPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end





