--------------------------------------------------------------------------------------
-- 文件名:	HJW_GroupBuildingSchool.lua
-- 版  权:	(C)深圳市美天互动有限公司
-- 创建人:	
-- 日  期:	2016-01-14
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  书画院
---------------------------------------------------------------------------------------

Game_GuildSchool = class("Game_GuildSchool")
Game_GuildSchool.__index = Game_GuildSchool

function Game_GuildSchool:initWnd()
	local chooseType = g_Guild:getLastChooseType(2)
	local chooseTimeat = g_Guild:getLastChooseTimeat(2)
	if chooseTimeat ~= 0 then 
		if SecondsToTable( g_GetServerTime() - (chooseTimeat)  ).hour >= 24 then
			 g_Guild:setLastChooseTimeat(2, 0)
			 g_Guild:setLastChooseType(2, 0)
		end
	end
end

function Game_GuildSchool:openWnd(param)	
	
	if not param then return end
	local buildName = param.buildName
	local buildType = param.buildType
	
	local rootWidget = self.rootWidget
	if not rootWidget then return end 

	local schoolLv = g_Guild:getBuildingLevel(buildType);--万宝楼等级;--书画院等级
	
	local schoolData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSchoolLevel",schoolLv)
	
	local maxLevel = g_DataMgr:getCsvConfig("GuildBuildingSchoolLevel")
	local nextSchoolLv = schoolLv + 1 
	if nextSchoolLv >= #maxLevel  then nextSchoolLv = schoolLv end
	
	local schoolNextData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSchoolLevel",nextSchoolLv)

	local param = {
		buildLevel = schoolLv, 
		buildExp = schoolData.BuildingExp,--升级需要的经验
		buildNeedMoney = schoolData.BuildNeedKnowledge, --建设需要的学识
		buildReward = schoolData.RewardInterest,--客户端显示的利率
		nextBuildReward = schoolNextData.RewardInterest,--客户端显示的利率
		buildType = buildType,
	}
	
	local Image_GuildSchoolPNL = tolua.cast(rootWidget:getChildByName("Image_GuildSchoolPNL"), "ImageView")
	g_BuildingElement:setBuildInfoView(Image_GuildSchoolPNL,buildName,param)

		
	local schoolDataReward = g_DataMgr:getCsvConfig("GuildBuildingSchoolReward")
	if not schoolDataReward then return end 
	
	local Image_GuildSchoolContentPNL = tolua.cast(Image_GuildSchoolPNL:getChildByName("Image_GuildSchoolContentPNL"), "ImageView")
	local ListView_SchoolItemList = tolua.cast(Image_GuildSchoolContentPNL:getChildByName("ListView_SchoolItemList"), "ListViewEx")
	local Image_SchoolItemRowPNL = tolua.cast(ListView_SchoolItemList:getChildByName("Image_SchoolItemRowPNL"), "ImageView")	
	
	local param = {upItemNum = #schoolDataReward, buildType = buildType}	
	g_BuildingElement:setListImage(ListView_SchoolItemList, Image_SchoolItemRowPNL, "Button_SchoolItem", param)
	
end

function Game_GuildSchool:closeWnd()
end

--书画院
function Game_GuildSchool:buttonSchool(objPnl, nIndex, buildType)

	local schoolDataReward = g_DataMgr:getCsvConfig("GuildBuildingSchoolReward")

	local schoolLevel = g_Guild:getBuildingLevel(buildType)
	local itemData = schoolDataReward[nIndex]
	local schoolLevelItemData = itemData[schoolLevel]
	
	--普通书籍 Lv.2
	local Label_SchoolItemName = tolua.cast(objPnl:getChildByName("Label_SchoolItemName"), "Label")
	Label_SchoolItemName:setText(itemData.RewardName.." ".._T("Lv.")..schoolLevel)


	local Label_SchoolItemDesc1 = tolua.cast(objPnl:getChildByName("Label_SchoolItemDesc1"), "Label")
	Label_SchoolItemDesc1:setText(string.format(_T("阅读需要%s阅历"), itemData.CostKnowledege))
	g_setTextColor(Label_SchoolItemDesc1,ccs.COLOR.BRIGHT_GREEN)
	
	local flag = false
	local btnRead = true
	local openLevelTip = true

	--阅历不足
	if itemData.CostKnowledege > g_Hero:getKnowledge() then
		g_setTextColor(Label_SchoolItemDesc1,ccs.COLOR.RED)
		btnRead = false
	end
	
	--建筑等级
	if schoolLevel >= itemData.OpenLevel then
		--已经开启
		openLevelTip = false
		-- btnRead = true
		flag = true
	end
	
	local chooseType = g_Guild:getLastChooseType(2)
	local txt = ""
	local buyTxt = _T("已阅读")
	if chooseType == 0 then 
		txt = _T("未阅读, 阅读后可获得增长阅历")
		buyTxt = _T("阅读")
	else
		if chooseType == nIndex then 
			txt = string.format(_T("24小时后可获得%s点阅历"),schoolLevelItemData.ReturnKnowledege)
			buyTxt = _T("已阅读")
			btnRead = false
		else
			txt = _T("您今天已阅读其他项目")
			buyTxt = _T("未阅读")
			btnRead = false
		end
	end

	local Label_SchoolItemDesc2 = tolua.cast(objPnl:getChildByName("Label_SchoolItemDesc2"), "Label")
	Label_SchoolItemDesc2:setText(g_stringSize_insert(txt,"\n",21,310))
	Label_SchoolItemDesc2:setVisible(flag)
	
	local Label_OpenLevelTip = tolua.cast(objPnl:getChildByName("Label_OpenLevelTip"), "Label")
	Label_OpenLevelTip:setText(string.format(_T("书画院%d级解锁"), itemData.OpenLevel))
	Label_OpenLevelTip:setVisible(openLevelTip)

	
	local Button_Read = tolua.cast(objPnl:getChildByName("Button_Read"), "Button")
	--已阅读
	
	if schoolLevel < itemData.OpenLevel then
		buyTxt = _T("未解锁")
	end
	local BitmapLabel_FuncName = tolua.cast(Button_Read:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
	BitmapLabel_FuncName:setText(buyTxt)
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_SchoolItemDesc2:setFontSize(18)
		BitmapLabel_FuncName:setScale(0.8)
	end
	
	local function onClick(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			
			local chooseType = g_Guild:getLastChooseType(2)
			if chooseType == pSender:getTag() then 
				echoj("已经购买了")
				return 
			end
			--建筑等级
			if schoolLevel < itemData.OpenLevel then
				echoj("还没有到开启等级")
				return 
			end
			
			if g_Guild:getLastChooseTimeat(2) > 0 then 
				echoj("冷却时间还没有结束")
				return 
			end
			
			g_BuildingElement:requestGuildBuildBuyReq(buildType, nIndex)
		end
	end

	Button_Read:setBright(btnRead)
	Button_Read:setTouchEnabled(btnRead)
	Button_Read:addTouchEventListener(onClick)
	Button_Read:setTag(nIndex)
	
	local Button_SchoolItemIcon = tolua.cast(objPnl:getChildByName("Button_SchoolItemIcon"), "Button")
	local Image_Frame = tolua.cast(Button_SchoolItemIcon:getChildByName("Image_Frame"), "ImageView")
	local BitmapLabel_OpenLevel = tolua.cast(Button_SchoolItemIcon:getChildByName("BitmapLabel_OpenLevel"), "LabelBMFont")
	local function onClickScholl(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			-- echoj("书籍====icon")
			local param = {
				CSV_QiShu = itemData,
				nQiShuID = nIndex,
				nTipType = 3,
				buildType = buildType,
			}
			g_WndMgr:showWnd("Game_TipQiShu", param)
		end
	end
	Button_SchoolItemIcon:setTouchEnabled(true)
	Button_SchoolItemIcon:addTouchEventListener(onClickScholl)
	Button_SchoolItemIcon:loadTextures(getIconImg(itemData.RewardIcon),getIconImg(itemData.RewardIcon),getIconImg(itemData.RewardIcon))
end

