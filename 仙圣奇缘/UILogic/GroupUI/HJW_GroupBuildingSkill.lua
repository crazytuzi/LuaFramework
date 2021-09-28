--------------------------------------------------------------------------------------
-- 文件名:	HJW_GroupBuildingSkill.lua
-- 版  权:	(C)深圳市美天互动有限公司
-- 创建人:	
-- 日  期:	2016-01-14
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  炼神塔, 金刚堂, 神兵殿
---------------------------------------------------------------------------------------

Game_GuildSkill = class("Game_GuildSkill")
Game_GuildSkill.__index = Game_GuildSkill


function Game_GuildSkill:initWnd()

end

function Game_GuildSkill:openWnd(param)	
	
	if not param then return end
	local buildName = param.buildName
	local buildType = param.buildType
	
	local rootWidget = self.rootWidget
	if not rootWidget then return end 

	local skilllLv = g_Guild:getBuildingLevel(buildType);--等级

	local skillData = nil;
	local skillCharacterData = nil;
	local buildSkillCVS = nil;
	if buildType == 4 then 
		
		skillData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillHpLevel",skilllLv)
		
		local nextSkillLv = g_BuildingElement:SkillBuillNextLevel("GuildBuildingSkillHpLevel", skilllLv)
		local skillNextData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillHpLevel",nextSkillLv)
	
		buildSkillCVS = {
			buildLevel = skilllLv, 
			buildExp = skillData.BuildingExp,--升级需要的经验
			buildNeedMoney = skillData.BuildNeedKnowledge, --建设需要的铜钱
			buildReward = skillData.MaxSkillLevel,--功法升级上限
			nextBuildReward = skillNextData.MaxSkillLevel,--功法升级上限
			buildType = buildType,
		}

		skillCharacterData = g_DataMgr:getCsvConfig("GuildBuildingSkillHp")
			
	elseif buildType == 5 then --金刚堂
			
		skillData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillDefenceLevel",skilllLv)
		
		local nextSkillLv = g_BuildingElement:SkillBuillNextLevel("GuildBuildingSkillDefenceLevel", skilllLv)
		local skillNextData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillDefenceLevel",nextSkillLv)
	
		buildSkillCVS = {
			buildLevel = skilllLv, 
			buildExp = skillData.BuildingExp,--升级需要的经验
			buildNeedMoney = skillData.BuildNeedKnowledge, --建设需要的铜钱
			buildReward = skillData.MaxSkillLevel,--功法升级上限
			nextBuildReward = skillNextData.MaxSkillLevel,--功法升级上限
			buildType = buildType,
		}
		
		skillCharacterData = g_DataMgr:getCsvConfig("GuildBuildingSkillDefence")
		
	elseif buildType == 6 then --神兵殿
	
		skillData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillAttackLevel",skilllLv)
		
		local nextSkillLv = g_BuildingElement:SkillBuillNextLevel("GuildBuildingSkillAttackLevel", skilllLv)
		local skillNextData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillAttackLevel",nextSkillLv)
		
			
		buildSkillCVS = {
			buildLevel = skilllLv, 
			buildExp = skillData.BuildingExp,--升级需要的经验
			buildNeedMoney = skillData.BuildNeedKnowledge, --建设需要的铜钱
			buildReward = skillData.MaxSkillLevel,--功法升级上限
			nextBuildReward = skillNextData.MaxSkillLevel,--功法升级上限
			buildType = buildType,
		}
	
		skillCharacterData = g_DataMgr:getCsvConfig("GuildBuildingSkillAttack")
	
	end

	if not skillData then return end 
	if not skillCharacterData then return end 
	
	local Image_GuildSkillPNL = tolua.cast(rootWidget:getChildByName("Image_GuildSkillPNL"), "ImageView")
	
	g_BuildingElement:setBuildInfoView(Image_GuildSkillPNL, buildName, buildSkillCVS)
	
	
	local Image_GuildSkillContentPNL = tolua.cast(Image_GuildSkillPNL:getChildByName("Image_GuildSkillContentPNL"), "ImageView")
	local ListView_GuildSkillList = tolua.cast(Image_GuildSkillContentPNL:getChildByName("ListView_GuildSkillList"), "ListViewEx")
	local Image_GuildSkillRowPNL = tolua.cast(ListView_GuildSkillList:getChildByName("Image_GuildSkillRowPNL"), "ImageView")	
	
	local param = {upItemNum = #skillCharacterData, buildType = buildType}
	g_BuildingElement:setListImage(ListView_GuildSkillList, Image_GuildSkillRowPNL, "Button_GuildSkillItem", param)
	
end

function Game_GuildSkill:closeWnd()
end

-- function Game_GuildSkill:SkillBuillNextLevel(cvsName, buildLeve )
	-- local maxLevel = g_DataMgr:getCsvConfig(cvsName)
	-- local nextSchoolLv = buildLeve + 1 
	-- if nextSchoolLv >= #maxLevel  then nextSchoolLv = schoolLv end
	-- return nextSchoolLv
-- end

--炼神塔,, 金刚堂, 神兵殿
function Game_GuildSkill:buttonSkill(objPnl, nIndex, buildType)
	
	local buildLeve = g_Guild:getBuildingLevel(buildType)
	local skillData = nil
	local buildIndex = 1
	local buildName = _T("炼神塔")
	local cvsSkillLevel = nil
	if buildType == 4 then 
		skillData = g_DataMgr:getCsvConfig("GuildBuildingSkillHp")
		buildIndex = 1
		cvsSkillLevel = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillHpLevel",buildLeve)

	elseif buildType == 5 then --金刚堂
		skillData = g_DataMgr:getCsvConfig("GuildBuildingSkillDefence")
		buildIndex = 2
		buildName = _T("金刚堂")
		cvsSkillLevel = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillDefenceLevel",buildLeve)

	elseif buildType == 6 then --神兵殿
		skillData = g_DataMgr:getCsvConfig("GuildBuildingSkillAttack")
		buildIndex = 3
		buildName = _T("神兵殿") 
		cvsSkillLevel = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillAttackLevel",buildLeve)
	end

	if not skillData then return end
	if not cvsSkillLevel then return end
	
	local jnLevel = g_Guild:getBuildSkillLevel(buildIndex, nIndex)  --技能等级

	local openLevel = skillData[nIndex].OpenLevel
	
	local maxLevel = #g_DataMgr:getCsvConfig("QiShuUpgradeCost")
	
	local costJnLevel = jnLevel + 1
	if costJnLevel > maxLevel then costJnLevel = maxLevel end
	
	local qiShuUpgradeCost = g_DataMgr:getCsvConfigByOneKey("QiShuUpgradeCost",costJnLevel)
	
	--物理攻击 
	local Label_GuildSkillName = tolua.cast(objPnl:getChildByName("Label_GuildSkillName"), "Label")
	Label_GuildSkillName:setText(skillData[nIndex].Name)
	--Lv.1
	local Label_GuildSkillLevel = tolua.cast(Label_GuildSkillName:getChildByName("Label_GuildSkillLevel"), "Label")
	Label_GuildSkillLevel:setText(" ".._T("Lv.")..jnLevel)
	Label_GuildSkillLevel:setPositionX(Label_GuildSkillName:getSize().width)
	
	local value = g_BuildingElement:getBuildSillPropString(skillData[nIndex], buildIndex, nIndex)
	--先攻 + 1200
	local Label_GuildSkillProp = tolua.cast(objPnl:getChildByName("Label_GuildSkillProp"), "Label")	
	Label_GuildSkillProp:setText( value )
	
	local Label_GuildSkillLevelTarget = tolua.cast(objPnl:getChildByName("Label_GuildSkillLevelTarget"), "Label")
	local Label_GuildSkillPropTarget = tolua.cast(objPnl:getChildByName("Label_GuildSkillPropTarget"), "Label")
	if jnLevel == 0 then
		Label_GuildSkillLevelTarget:setVisible(true)
		Label_GuildSkillPropTarget:setVisible(true)
		Label_GuildSkillPropTarget:setText("+"..skillData[nIndex].PropBase)
		g_AdjustWidgetsPosition({Label_GuildSkillName, Label_GuildSkillLevelTarget}, 105)
		g_AdjustWidgetsPosition({Label_GuildSkillProp, Label_GuildSkillPropTarget}, 60)
	else
		Label_GuildSkillLevelTarget:setVisible(false)
		Label_GuildSkillPropTarget:setVisible(false)
	end
	
	-- 需阅历: 
	local costNeed =  math.floor( qiShuUpgradeCost.ZhenXinCost * skillData[nIndex].CostFactor / g_BasePercent )
	
	local Label_NeedXueShiLB = tolua.cast(objPnl:getChildByName("Label_NeedXueShiLB"), "Label")
	local Label_NeedXueShi = tolua.cast(Label_NeedXueShiLB:getChildByName("Label_NeedXueShi"), "Label")
	Label_NeedXueShi:setText(costNeed)
	g_setTextColor(Label_NeedXueShiLB,ccs.COLOR.BRIGHT_GREEN)
	g_setTextColor(Label_NeedXueShi,ccs.COLOR.BRIGHT_GREEN)

	--1级解锁
	local Label_OpenLevelTip = tolua.cast(objPnl:getChildByName("Label_OpenLevelTip"), "Label")
	local flag = true
	local btnTxt = _T("升级")
	if buildLeve >= openLevel then 
		Label_OpenLevelTip:setVisible(false)
		Label_NeedXueShiLB:setVisible(true)
		flag = true
	else
		Label_OpenLevelTip:setVisible(true)
		Label_OpenLevelTip:setText(buildName..openLevel.._T("级解锁"))
		Label_NeedXueShiLB:setVisible(false)
		flag = false
		btnTxt = _T("未解锁")
	end
		--阅历不足
	if costNeed > g_Hero:getKnowledge() then
		g_setTextColor(Label_NeedXueShiLB,ccs.COLOR.RED)
		g_setTextColor(Label_NeedXueShi,ccs.COLOR.RED)
		flag = false
	end
	if  cvsSkillLevel.MaxSkillLevel == jnLevel then 
		flag = false 
	end
	local Button_LevelUp = tolua.cast(objPnl:getChildByName("Button_LevelUp"), "Button")
	local BitmapLabel_FuncName = tolua.cast(Button_LevelUp:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
	BitmapLabel_FuncName:setText(btnTxt)
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_OpenLevelTip:setFontSize(18)
		Label_GuildSkillName:setFontSize(18)
		Label_GuildSkillLevel:setFontSize(18)
		Label_GuildSkillLevelTarget:setFontSize(18)
		BitmapLabel_FuncName:setScale(0.8)
		g_AdjustWidgetsPosition({Label_GuildSkillName, Label_GuildSkillLevelTarget},90)
	end
	
	Label_GuildSkillLevel:setPositionX(Label_GuildSkillName:getSize().width)
	Label_NeedXueShi:setPositionX(Label_NeedXueShiLB:getSize().width)
	
	local function onClick(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			
			if costNeed > g_Hero:getKnowledge() then 
				g_ShowSysTips({text = _T("阅历不足")})
				return 
			end
			if  cvsSkillLevel.MaxSkillLevel == jnLevel then 
				g_ShowSysTips({text = _T("已经达到当前建筑的最高等级")})
				return 
			end
			
			g_BuildingElement:requestGuildBuildSkillLvUpReq(buildType, nIndex)
			
		end
	end
	Button_LevelUp:setBright(flag)
	Button_LevelUp:setTouchEnabled(flag)
	Button_LevelUp:addTouchEventListener(onClick)
	
	local Button_GuildSkillIcon = tolua.cast(objPnl:getChildByName("Button_GuildSkillIcon"), "Button")
	local Image_Frame = tolua.cast(Button_GuildSkillIcon:getChildByName("Image_Frame"), "ImageView")
	local BitmapLabel_OpenLevel = tolua.cast(Button_GuildSkillIcon:getChildByName("BitmapLabel_OpenLevel"), "LabelBMFont")
	local function onClickSkill(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			-- echoj("炼神塔 技能icon")
			local param = {
				CSV_QiShu = skillData[nIndex],
				nQiShuID = nIndex,
				nTipType = 3,
				buildType = buildType,
			}
			g_WndMgr:showWnd("Game_TipQiShu", param)
		end
	end
	Button_GuildSkillIcon:setTouchEnabled(true)
	Button_GuildSkillIcon:addTouchEventListener(onClickSkill)
	Button_GuildSkillIcon:loadTextures(getIconImg(skillData[nIndex].Icon),getIconImg(skillData[nIndex].Icon),getIconImg(skillData[nIndex].Icon))
	
end

