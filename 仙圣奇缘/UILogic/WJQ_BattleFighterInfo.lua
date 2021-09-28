--------------------------------------------------------------------------------------
-- 文件名:	LKA_ArenaRewardReward.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	竞技场界面
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_BattleFighterInfo = class("Game_BattleFighterInfo")
Game_BattleFighterInfo.__index = Game_BattleFighterInfo

function Game_BattleFighterInfo:initWnd(rootWidget, GameObj_Fighter)
	
end

function Game_BattleFighterInfo:closeWnd()
	
end

function Game_BattleFighterInfo:openWnd(GameObj_Fighter)
	if not GameObj_Fighter then return end
	if not TbBattleReport then return end
	
	local Image_BattleFighterInfoPNL = self.rootWidget:getChildByName("Image_BattleFighterInfoPNL")
	local Label_Name = tolua.cast(Image_BattleFighterInfoPNL:getChildByName("Label_Name"), "Label")
	local AtlasLabel_Profession = tolua.cast(Image_BattleFighterInfoPNL:getChildByName("AtlasLabel_Profession"), "LabelAtlas")
	local LabelBMFont_Level = tolua.cast(Image_BattleFighterInfoPNL:getChildByName("LabelBMFont_Level"), "LabelBMFont")
	local Image_HPBack = Image_BattleFighterInfoPNL:getChildByName("Image_HPBack")
	local Loading_HP = tolua.cast(Image_HPBack:getChildByName("Loading_HP"), "LoadingBar")
	local Label_HP = tolua.cast(Loading_HP:getChildByName("Label_HP"), "Label")
	local Image_ManaBack = Image_BattleFighterInfoPNL:getChildByName("Image_ManaBack")
	local LoadingBar_Mana = tolua.cast(Image_ManaBack:getChildByName("LoadingBar_Mana"), "LoadingBar")
	local Label_Mana = tolua.cast(LoadingBar_Mana:getChildByName("Label_Mana"), "Label")
	
	if not GameObj_Fighter.tbFighterBase then return end
	
	if GameObj_Fighter.tbFighterBase.ID == 3001 or GameObj_Fighter.tbFighterBase.ID == 3002 then	--是主角卡g_Hero.otherLeaderName
		if GameObj_Fighter.nPos < 10 then
			Label_Name:setText(getFormatSuffixLevel(g_Hero:getMasterName(), g_GetCardEvoluteSuffixByEvoLev(GameObj_Fighter.nEvoluteLevel)))
		else
			Label_Name:setText(getFormatSuffixLevel(g_BattleMgr:getDefenceSideName(), g_GetCardEvoluteSuffixByEvoLev(GameObj_Fighter.nEvoluteLevel)))
		end
		g_SetCardNameColorByEvoluteLev(Label_Name, GameObj_Fighter.nEvoluteLevel)
	else
		Label_Name:setText(g_GetCardNameWithSuffix(GameObj_Fighter.tbFighterBase, GameObj_Fighter.nEvoluteLevel, Label_Name))
	end
	
	AtlasLabel_Profession:setStringValue(GameObj_Fighter.tbFighterBase.Profession)
	g_AdjustWidgetsPosition({Label_Name, AtlasLabel_Profession},10)
	LabelBMFont_Level:setText(string.format(_T("Lv.%d"), GameObj_Fighter.nLevel))
	Loading_HP:setPercent(math.floor(100*GameObj_Fighter.nCurHp/GameObj_Fighter.nMaxHp))
	Label_HP:setText(GameObj_Fighter.nCurHp.."/"..GameObj_Fighter.nMaxHp)

	LoadingBar_Mana:setPercent(math.floor(math.min(100*GameObj_Fighter.nCurSp/GameObj_Fighter.nMaxSp, 100)))
	Label_Mana:setText(string.format("%d/%d", GameObj_Fighter.nCurSp, GameObj_Fighter.nMaxSp))

	local tbSkillData = TbBattleReport.tbSkillData[GameObj_Fighter.nPos]
	for i = 1, 3 do
		local Button_Skill = Image_BattleFighterInfoPNL:getChildByName(string.format("Button_Skill%d", i))
		local Label_Name = tolua.cast(Button_Skill:getChildByName("Label_Name"), "Label")
		local CSV_SkillBase = tbSkillData[i+1]
		local nEumnBattleSide, nPosInBattleMgr = g_BattleMgr:getBattleSideAndPosInBattleMgr(GameObj_Fighter.nPos)
		local nSkillLev = g_BattleMgr:getFighterUseSkillLevel(nEumnBattleSide, nPosInBattleMgr, i) or 1
		Label_Name:setText(getFormatSuffixLevel(CSV_SkillBase.Name, g_GetCardEvoluteSuffixByEvoLev(nSkillLev)))
		g_SetWidgetColorBySLev(Label_Name, g_GetCardColorTypeByEvoLev(nSkillLev))
		
		local Panel_SkillIcon = tolua.cast(Button_Skill:getChildByName("Panel_SkillIcon"), "Layout")
		Panel_SkillIcon:setClippingEnabled(true)
		Panel_SkillIcon:setRadius(39)
		local Image_SkillIcon = tolua.cast(Panel_SkillIcon:getChildByName("Image_SkillIcon"), "ImageView")
		Image_SkillIcon:loadTexture(getIconImg(CSV_SkillBase.Icon))
	end
end