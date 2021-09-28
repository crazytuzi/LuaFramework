--------------------------------------------------------------------------------------
-- 文件名:	Game_TipQiShu.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	huangjingwei
-- 日  期:	2015-1-8 11:53
-- 版  本:	1.0
-- 描  述:	阵法奇术tip界面
-- 应  用:   
---------------------------------------------------------------------------------------
Game_TipQiShu = class("Game_TipQiShu")
Game_TipQiShu.__index = Game_TipQiShu

local function setWidegtSize(widegt, lable)  
	local lableSize = lable:getSize()
	local nHeight = lableSize.height - 45
	local pos = widegt:getPosition()
	local widSize = widegt:getSize()
	widegt:setSize(CCSizeMake(widSize.width, widSize.height + nHeight))
	widegt:setPosition(ccp(pos.x, pos.y + nHeight/2))
end

function Game_TipQiShu:initWnd()
end 

function Game_TipQiShu:openWnd(tbParam)
	if not tbParam then return end
	local CSV_QiShu = tbParam.CSV_QiShu
	local nQiShuID = tbParam.nQiShuID
	local nTipType = tbParam.nTipType
	local buildType = tbParam.buildType 
	
	local Image_TipQiShuPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipQiShuPNL"), "ImageView")
	Image_TipQiShuPNL:setSize(CCSizeMake(560, 310))
	Image_TipQiShuPNL:setPosition(ccp(645, 520))

	--阵法图案
	local Image_QiShuIcon = tolua.cast(Image_TipQiShuPNL:getChildByName("Image_QiShuIcon"), "ImageView")
	--阵法名称 等级
	local Label_Name = tolua.cast(Image_TipQiShuPNL:getChildByName("Label_Name"), "Label")
	--提示的属性 数值
	local Label_QiShuProp = tolua.cast(Image_TipQiShuPNL:getChildByName("Label_QiShuProp"), "Label")
	--每级增加物攻
	local Label_QiShuPropGrow = tolua.cast(Image_TipQiShuPNL:getChildByName("Label_QiShuPropGrow"), "Label")
	--升级需要等级: 
	local Label_NeedLevelLB = tolua.cast(Image_TipQiShuPNL:getChildByName("Label_NeedLevelLB"), "Label")
	local Label_NeedLevel = tolua.cast(Label_NeedLevelLB:getChildByName("Label_NeedLevel"), "Label")
	Label_NeedLevel:setPositionX(Label_NeedLevelLB:getSize().width)
	
	--升级消耗阅历: 
	local Label_NeedXueShiLB = tolua.cast(Image_TipQiShuPNL:getChildByName("Label_NeedXueShiLB"), "Label")
	local Label_NeedXueShi = tolua.cast(Label_NeedXueShiLB:getChildByName("Label_NeedXueShi"), "Label")
	Label_NeedXueShi:setPositionX(Label_NeedXueShiLB:getSize().width)
	--描述
	local Label_QiShuDesc = tolua.cast(Image_TipQiShuPNL:getChildByName("Label_QiShuDesc"), "Label")
	
	local strDesc = nil
	local nNeedKnowledge = nil
	local strTxt = nil
	local txt = nil
	local strName = nil
	local sizeText = 0
	local id = nil
	
	if nTipType == 1 then --阵法
		local nZhenFaLevel = g_Hero:getZhenFaLevel(nQiShuID)
		Label_Name:setText(CSV_QiShu.ZhenFaName.." ".._T("Lv.")..nZhenFaLevel)
		Label_QiShuProp:setText(g_Hero:getZhenFaPropString(nQiShuID))
		Label_QiShuPropGrow:setText(g_Hero:getZhenFaPropGrow(nQiShuID))
		Label_NeedXueShi:setText(g_Hero:getZhenFaNeedKnowledge(nQiShuID))
		Image_QiShuIcon:loadTexture(getIconImg(CSV_QiShu.ZhenFaIcon))
		Label_NeedLevel:setText(nZhenFaLevel+1)
		
		if g_Hero:checkZhenFaCost(nQiShuID) then
			g_setTextColor(Label_NeedXueShi,ccs.COLOR.BRIGHT_GREEN)
		else
			g_setTextColor(Label_NeedXueShi,ccs.COLOR.RED)
		end
		
		if g_Hero:checkZhenFaLevel(nQiShuID) then
			g_setTextColor(Label_NeedLevel,ccs.COLOR.BRIGHT_GREEN)
		else
			g_setTextColor(Label_NeedLevel,ccs.COLOR.RED)
		end
		
		strDesc = (g_stringSize_insert(CSV_QiShu.ZhenFaDesc,"\n",21,530))
		Label_QiShuDesc:setText(strDesc)
	elseif nTipType == 2 then --心法
		local nXinFaLevel = g_Hero:getXinFaLevel(nQiShuID)
		Label_Name:setText(CSV_QiShu.Name.." ".._T("Lv.")..nXinFaLevel)
		Label_QiShuProp:setText(g_Hero:getXinFaPropString(nQiShuID))
		Label_QiShuPropGrow:setText(g_Hero:getXinFaPropGrow(nQiShuID))
		Label_NeedXueShi:setText(g_Hero:getXinFaNeedKnowledge(nQiShuID))
		Image_QiShuIcon:loadTexture(getIconImg(CSV_QiShu.Icon))
		Label_NeedLevel:setText(nXinFaLevel+1)
		
		if g_Hero:checkXinFaCost(nQiShuID) then
			g_setTextColor(Label_NeedXueShi,ccs.COLOR.BRIGHT_GREEN)
		else
			g_setTextColor(Label_NeedXueShi,ccs.COLOR.RED)
		end
		
		if g_Hero:checkXinFaLevel(nQiShuID) then
			g_setTextColor(Label_NeedLevel,ccs.COLOR.BRIGHT_GREEN)
		else
			g_setTextColor(Label_NeedLevel,ccs.COLOR.RED)
		end
		
		strDesc = (g_stringSize_insert(CSV_QiShu.Desc,"\n",21,530))
		Label_QiShuDesc:setText(strDesc)
	elseif nTipType == 3 then --帮派建筑	

		local buildName = { _T("主角"), _T("万宝楼"), _T("书画院"), _T("炼神塔"), _T("金刚堂"), _T("神兵殿") }
		local buildLeve = g_Guild:getBuildingLevel(buildType)

		local name = ""
		local openLevel = CSV_QiShu.OpenLevel
		local icon = ""
		local desc = ""
		local propGrowth = ""
		
		local costNeed = 0
		local jnLevel = 0
		local valueProp = ""
		local flag = true
		if buildType >= 4 then 
			local buildIndex = { [4] = 1, [5] = 2, [6] = 3, }
			name = CSV_QiShu.Name
			icon = CSV_QiShu.Icon
			desc = CSV_QiShu.CSV_QiShu
			propGrowth = g_BuildingElement:getBuildSkillLevelInfoStringcsvData(CSV_QiShu)
		
			--nQiShuID 建筑中的第几个技能	
			jnLevel = g_Guild:getBuildSkillLevel(buildIndex[buildType], nQiShuID)  --技能等级
			local qiShuUpgradeCost = g_DataMgr:getCsvConfigByOneKey("QiShuUpgradeCost",jnLevel)
			valueProp = g_BuildingElement:getBuildSillPropString(CSV_QiShu, buildIndex[buildType], nQiShuID)
			-- 需阅历: 
			costNeed =  math.floor( qiShuUpgradeCost.ZhenXinCost * CSV_QiShu.CostFactor / g_BasePercent )
		
			if costNeed > g_Hero:getKnowledge() then
				flag = false
			end
		elseif buildType == 3 then
			name = CSV_QiShu.RewardName
			jnLevel = buildLeve
			icon = CSV_QiShu.RewardIcon
			 
			local schoolLevelItemData = CSV_QiShu[buildLeve]
			costNeed = CSV_QiShu.CostKnowledege
			valueProp = _T("可获得阅历")..": "..schoolLevelItemData.ReturnKnowledege
			local maxLevel = g_DataMgr:getCsvConfig("GuildBuildingSchoolLevel")
			local buildMaxLevel = #maxLevel
			local lv =  buildLeve + 1
			if lv > buildMaxLevel then lv = buildMaxLevel end
			propGrowth = _T("下一等级返回阅历:").." "..CSV_QiShu[lv].ReturnKnowledege
			
			Label_NeedXueShiLB:setText(_T("阅读需要阅历:").." ")
			
			if costNeed > g_Hero:getKnowledge() then
				flag = false
			end
		else
			name = CSV_QiShu.RewardName
			jnLevel = buildLeve
			icon = CSV_QiShu.RewardIcon
			local schoolLevelItemData = CSV_QiShu[buildLeve]
			costNeed = CSV_QiShu.CostCoins
			
			valueProp = _T("可获得铜钱:").." "..schoolLevelItemData.ReturnCoins
			local maxLevel = g_DataMgr:getCsvConfig("GuildBuildingSchoolLevel")
			local buildMaxLevel = #maxLevel
			local lv =  buildLeve + 1
			if lv > buildMaxLevel then lv = buildMaxLevel end
			propGrowth = _T("下一等级返回铜钱:").." "..CSV_QiShu[lv].ReturnCoins
			
			Label_NeedXueShiLB:setText(_T("认购需要铜钱:").." ")
			
			if costNeed >  g_Hero:getCoins()  then
				flag = false
			end
		end
		
		Label_Name:setText(name.." ".._T("Lv.")..jnLevel)
		
		Label_NeedLevelLB:setText(_T("需要")..buildName[buildType].._T("等级:").." ")
		Label_NeedLevel:setText(openLevel)
		Label_NeedLevel:setPositionX(Label_NeedLevelLB:getSize().width)
		
		Label_QiShuProp:setText(valueProp)
		
		Label_QiShuPropGrow:setText(propGrowth)
		
		Label_NeedXueShi:setText(costNeed)
		Label_NeedXueShi:setPositionX(Label_NeedXueShiLB:getSize().width)
		
		Image_QiShuIcon:loadTexture(getIconImg(icon))
		
		
		if flag then
			g_setTextColor(Label_NeedXueShi,ccs.COLOR.BRIGHT_GREEN)
		else
			g_setTextColor(Label_NeedXueShi,ccs.COLOR.RED)
		end
		
		if buildLeve >= openLevel then
			g_setTextColor(Label_NeedLevel,ccs.COLOR.BRIGHT_GREEN)
		else
			g_setTextColor(Label_NeedLevel,ccs.COLOR.RED)
		end
		
		local strDesc = (g_stringSize_insert(desc, "\n", 21, 530))
		Label_QiShuDesc:setText(strDesc)
	end
	setWidegtSize(Image_TipQiShuPNL, Label_QiShuDesc)
end

function Game_TipQiShu:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipQiShuPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipQiShuPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipQiShuPNL, funcWndOpenAniCall, 1.05, 0.2)
end
function Game_TipQiShu:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipQiShuPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipQiShuPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipQiShuPNL, funcWndCloseAniCall, 1.05, 0.2)
end