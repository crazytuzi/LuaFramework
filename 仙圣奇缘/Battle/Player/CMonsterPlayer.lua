--------------------------------------------------------------------------------------
-- 文件名:	CMonsterPlayerPlayer.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-27 15:24
-- 版  本:	1.0
-- 描  述:	怪物
-- 应  用:
---------------------------------------------------------------------------------------

--创建CMonsterPlayerPlayer类继承CCObject
CMonsterPlayer = class("CMonsterPlayer", function() return CPlayer:new() end)
CMonsterPlayer.__index = CMonsterPlayer

--初始化怪物数据
function CMonsterPlayer:initData(tbBattleInfo, nSide, bAddLayout, nUniqueId)
	local nMonsterID = tbBattleInfo.configid
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

	local CSV_MonsterBase = g_DataMgr:getMonsterBaseCsv(nMonsterID)
	local nMonsterScale = math.max(g_nCardScale, CSV_MonsterBase.FighterScale/100)
	local nPosX = 0
	local nPosY = 0
	
	local nPosHpX = 0
	local nPosHpY = 0
	
	if nSide == 1 then --左边
		nPosX = CSV_MonsterBase.Pos_X * nMonsterScale / g_nCardScale
		nPosY = CSV_MonsterBase.Pos_Y * nMonsterScale / g_nCardScale
		
		nPosHpX = CSV_MonsterBase.HPBarX * nMonsterScale / g_nCardScale
		nPosHpY = CSV_MonsterBase.HPBarY * nMonsterScale / g_nCardScale
	elseif nSide == 2 then --右边
		nPosX = -CSV_MonsterBase.Pos_X * nMonsterScale / g_nCardScale
		nPosY = CSV_MonsterBase.Pos_Y * nMonsterScale / g_nCardScale
		nPos = nPos + 10
		
		nPosHpX = -CSV_MonsterBase.HPBarX * nMonsterScale / g_nCardScale
		nPosHpY = CSV_MonsterBase.HPBarY * nMonsterScale / g_nCardScale
	end
	
	self.nPos = nPos
	self.tbPos_HP = ccp(nPosHpX, nPosHpY + g_nManaOffset * nMonsterScale / g_nCardScale)

	self.nEvoluteLevel = tbBattleInfo.breachlv

	
	self.Label_Name = Label:create()
	self.FigterName = g_GetCardNameWithSuffix(CSV_MonsterBase, self.nEvoluteLevel, self.Label_Name)
	self.Label_Name:setText(self.FigterName)
	self.Label_Name:setPositionXY(nPosHpX, nPosHpY + 28 + g_nManaOffset)
	
	local fontSize = eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() and 19 or 21
	self.Label_Name:setFontSize(fontSize)
	self:addChild(self.Label_Name, 3)

	self.Image_Shadow = self:createUIImageVeiw(getUIImg("Shadow"), 0, 0)
	self.Image_Shadow:setScaleX(nMonsterScale/0.6)
	self.Image_Shadow:setScaleY(nMonsterScale/0.6)
	self:addChild(self.Image_Shadow, 1)

	local paramPos = {
		nPos = nPos, nPosHpY = nPosHpY, nPosHpX = nPosHpX, nPosX = nPosX, nPosY = nPosY
	}
	self:creationCard(tbBattleInfo, CSV_MonsterBase, paramPos, nMonsterScale, bAddLayout)
	
	--把血量重置一下
	--self:setCurrentHp(0)
end

function CMonsterPlayer:getName()
	return self.FigterName
end
