--------------------------------------------------------------------------------------
-- 文件名:	CCardPlayerPlayer.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-27 15:24
-- 版  本:	1.0
-- 描  述:	怪物
-- 应  用:
---------------------------------------------------------------------------------------

--创建CCardPlayer类继承UILayout
CCardPlayer = class("CCardPlayer", function() return CPlayer:new() end)
CCardPlayer.__index = CCardPlayer

--[[
0，以九宫格Pos的中心点为描点
1，以伙伴图片的中心点为描点
2，以伙伴头顶血条的中心点为描点
3，以纵向平移AOE特效写死的坐标点为描点
4，以伙伴的右上角顶点为描点
5，以伙伴右边的中心点为描点

1，飘字，放在Mesh下面
2，飞行光效，放在Mesh下面,设置为技能释放者释放者的的层级
3，Fire光效放在Pos下面
4，hit光效放在Pos下面
5，Status光效放在Pos下面
6，区域特效，放在Mesh下面,纵向技能设置为技能释放者当前层级，其余为最高层级 纵向即->这种的设置为安放点的层级
]]

--初始化怪物数据
--nSide=1为左边，2为右边
function CCardPlayer:initData(tbBattleInfo, nSide, bAddLayout, nUniqueId)
	local nCardID = tbBattleInfo.configid
	local nPos = tbBattleInfo.arraypos
	
	if nUniqueId ~= nil then
		self.nUniqueId = nUniqueId
	else
		if tbBattleInfo.is_def == false then
			self.nUniqueId = tbBattleInfo.arraypos
		else
			self.nUniqueId = 100 + tbBattleInfo.arraypos
		end
	end

	local tbBattleCard = g_Hero:getBattleCardList()
	--教学
	if (g_BattleTeachSystem:IsTeaching() == nil or g_BattleTeachSystem:IsTeaching() == false) and (tbBattleCard.nPosIdx and tbBattleCard.nPosIdx == nPos) then
		 self.bLeader = true
	end

	local CSV_CardBase = g_DataMgr:getCardBaseCsv(nCardID, tbBattleInfo.star_lv)
	local nCardScale = g_nCardScale

	local nPosX = 0
	local nPosY = 0
	
	local nPosHpX = 0
	local nPosHpY = 0
	if nSide == 1 then
		nPosX = CSV_CardBase.Pos_X
		nPosY = CSV_CardBase.Pos_Y
		
		nPosHpX = CSV_CardBase.HPBarX
		nPosHpY = CSV_CardBase.HPBarY
	elseif nSide == 2 then
		nPosX = -CSV_CardBase.Pos_X
		nPosY = CSV_CardBase.Pos_Y
		nPos = nPos + 10
		
		nPosHpX = -CSV_CardBase.HPBarX
		nPosHpY = CSV_CardBase.HPBarY
	end
	
	self.nPos = nPos
	self.tbPos_HP = ccp(nPosHpX, nPosHpY + g_nManaOffset)
	
	self.nEvoluteLevel = tbBattleInfo.breachlv

		
	self.Label_Name = Label:create()
	--是主角卡g_Hero.otherLeaderName
	if CSV_CardBase.ID == 3001 or CSV_CardBase.ID == 3002 then	
		local strName = nSide == 1 and g_Hero:getMasterName() or g_BattleMgr:getDefenceSideName()
		self.FigterName = getFormatSuffixLevel(strName, g_GetCardEvoluteSuffixByEvoLev(self.nEvoluteLevel))
		self.Label_Name:setText(self.FigterName)
		g_SetCardNameColorByEvoluteLev(self.Label_Name, self.nEvoluteLevel)
		
	else
		self.FigterName = g_GetCardNameWithSuffix(CSV_CardBase, self.nEvoluteLevel, self.Label_Name)
		self.Label_Name:setText(self.FigterName)
	end
	self.Label_Name:setPositionXY(nPosHpX, nPosHpY + 28 + g_nManaOffset)
	local fontSize = eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() and 19 or 21
	self.Label_Name:setFontSize(fontSize)
	self:addChild(self.Label_Name, 3)


	self.Image_Shadow = self:createUIImageVeiw(getUIImg("Shadow"), 0, 0)
	self:addChild(self.Image_Shadow, 1)

	local paramPos = {
		nPos = nPos, nPosHpY = nPosHpY, nPosHpX = nPosHpX, nPosX = nPosX, nPosY = nPosY
	}
	self:creationCard(tbBattleInfo, CSV_CardBase, paramPos, nCardScale, bAddLayout)
end


function CCardPlayer:resetPosition()
	local tbCardPos = g_tbCardPos[self.nPos]
	TbBattleReport.Mesh:addChild(self, tbCardPos.nBattleLayer)
	self:runSpineIdle()
	self.CCNode_Skeleton:activeUpdate()

	self:setPosition(tbCardPos.tbPos)
	self:setScale(tbCardPos.Scale)
end

function CCardPlayer:changePosition(nPosFrom, BOnlyChangePos)
	if BOnlyChangePos then
		self:resetPosition()
	end

	local tbCardPos = g_tbCardPos[nPosFrom]
	self:setPosition(tbCardPos.tbPos)
	self:setScale(tbCardPos.Scale)
	self:setZOrder(tbCardPos.nBattleLayer)

	self.nPos = nPosFrom
	self.Layout_CardClickArea:setTag(nPosFrom)

	TbBattleReport.tbGameFighters_OnWnd[self.nPos] = self
end

function CCardPlayer:getName()
	return self.FigterName
end

