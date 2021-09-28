--------------------------------------------------------------------------------------
-- 文件名:	HJW_ComposeData.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	技能（丹药）合成  数据
-- 应  用:  
---------------------------------------------------------------------------------------
--[[
	每一个技能下有三个丹药，
	每个丹药需要的材料类型数量 由1-3个组成
	每个材料类型数量 由1-3个组成
]]

ComposeData = class("ComposeData")
ComposeData.__index = ComposeData

COMPOSE_STATE = {
	NotActivate = 1,	--未激活
	Activate = 2,	--激活
}
--[[
	@param PowerfulSkillID 技能ID 
	@param nIndex 此卡牌的第几个丹药 类型  1-3
	@return 丹药Id 1-9
]]
function ComposeData:cvsCardEvoluteSkillCondition(skillID)
	return g_DataMgr:getCsvConfigByOneKey("CardEvoluteSkillCondition",skillID)
end

--[[
	丹药消耗表
	@param danYaoIndex 丹药Id类型 分别为 1-9
	@danYaoLevel 丹药等级 从 0 开始
	丹药等级+1默认取当下一等级 
]]
function ComposeData:cvsCardEvoluteDanYao(danYaoIndex,danYaoLevel)
	danYaoLevel = danYaoLevel + 1
	local cardEvoluteDanYao = g_DataMgr:getCsvConfigByTwoKey("CardEvoluteDanYao",danYaoIndex,danYaoLevel)
	return cardEvoluteDanYao
end

--[[
	背包里拥有多少材料是否足够
	@param nItemID 
	@param nStarLevel
	@param nMax 需要的数量
]]
function ComposeData:danYaoNumContrast(nItemID,nStarLevel,nMax)
	local nCurNum = g_Hero:getItemNumByCsv(nItemID,nStarLevel) 
	return nCurNum >= nMax
end

--当前丹药的需要多少个不同类型的材料数量
function ComposeData:evoluteDanYaoItemTypeNum(cvsCardEvoluteDanYao)
	local nNum = 0 
	for i = 1, 3 do
		if cvsCardEvoluteDanYao["ItemID"..i] 
			and cvsCardEvoluteDanYao["ItemID"..i] > 0 then
			nNum = nNum + 1
		end
	end
	return nNum
end

--[[
	合成材料是否足够
	@param skillID	技能ID
	@param nIndex	此卡牌的第几个丹药 类型 1-3
	@param danYaoLevel 丹药等级
	@return true 材料足够 false 材料不够
]]
function ComposeData:composeMaterailContrast(skillID,nIndex,danYaoLevel)
	local cvsCondition =  self:cvsCardEvoluteSkillCondition(skillID)
	local needDanYaoID = cvsCondition["NeedDanYaoID"..nIndex]
	local cardEvoluteDanYao = self:cvsCardEvoluteDanYao(needDanYaoID,danYaoLevel)
	--激活丹药的是 先判断 铜钱是否足够
	if cardEvoluteDanYao.NeedMoney > g_Hero:getCoins() then return false end 
	
	local nNum = self:evoluteDanYaoItemTypeNum(cardEvoluteDanYao)
	local nCount = 0
	for i = 1,nNum do
		local nItemStarLev = cardEvoluteDanYao["ItemStarLevel"..i]
		local nItemID = cardEvoluteDanYao["ItemID"..i]
		local nItemNum = cardEvoluteDanYao["ItemNum"..i] --要消耗多少材料
		if self:danYaoNumContrast(nItemID,nItemStarLev,nItemNum) then 
			nCount = nCount + 1
		end
	end
	return nCount == nNum 
end

--[[
	当前 丹药的状态
	@param danYaoLevel 丹药等级
	@param skillLevel 技能等级
	@param skillID	技能ID
	@param nIndex	
]]
function ComposeData:composeCheckDanyaoItemState(danYaoLevel,skillLevel)
	local flagString = nil
	if tonumber(skillLevel) > danYaoLevel then --未激活丹药
		flagString =  COMPOSE_STATE.NotActivate --未激活
	elseif skillLevel == danYaoLevel then --激活丹药
		flagString = COMPOSE_STATE.Activate
	end
	return flagString
end

--[[
	某个技能下 三个丹药是否已经全激活
	@param skillID 技能ID
	@return true 三个丹药已经全激活 
]]
function ComposeData:danyaoAllActivate(skillLevel,evoluteLevel,tbDanYao,skillID)
	if skillLevel > evoluteLevel then return false end
	local nActiveCout = 0
	local active = 3
	for i = 1,active do --技能下的三个丹药
		local danYaoLevel = tbDanYao[i]
		local flagString = self:composeCheckDanyaoItemState(danYaoLevel,skillLevel)
		if flagString == COMPOSE_STATE.Activate then --激活
			nActiveCout = nActiveCout + 1
		end
	end
	return nActiveCout == active
end

function ComposeData:iconPostionXY(nNum)
	local tbX = {}
	local y = -173
	if nNum == 1 then 
		tbX = {0}
	elseif nNum == 2 then
		tbX = {-75,75}
	elseif nNum == 3 then 
		tbX = {-150,0,150}
	end
	return tbX,y
end

function ComposeData:toolPosX(nNum)
	local tbX = {}
	local y = -173
	if nNum == 1 then 
		tbX = {930}
	elseif nNum == 2 then
		tbX = {800,1014}
	elseif nNum == 3 then 
		tbX = {770,920,1077}
	end
	return tbX
end 

function ComposeData:getItemDropGuilePosX(nNum)
	local tbX = {}
	if nNum == 1 then 
		tbX = {650}
	elseif nNum == 2 then
		tbX = {570,730}
	elseif nNum == 3 then 
		tbX = {490,620,780}
	end
	return tbX
end

function ComposeData:OneKeyUpgradeByHintShow(tbDanYao,skillLevel,skillID,bLevel)
	local cvsCondition =  self:cvsCardEvoluteSkillCondition(skillID)
    local need = cvsCondition.CoinsCostBase + cvsCondition.CoinsCostGrow * skillLevel
	local notActivateNeed = need
	
	local onekeyCount= 0
	local onekeyUpgradeFlag = false
	--三个丹药
    for nIndex = 1, 3 do 
        local needDanYaoID = cvsCondition["NeedDanYaoID"..nIndex]
        local danYaoLevel = tbDanYao[nIndex]
        local strStateFlag = g_ComposeData:composeCheckDanyaoItemState(danYaoLevel,skillLevel)
		--已经激活
        if strStateFlag == COMPOSE_STATE.Activate then 
			--激活丹药的个数
			onekeyCount = onekeyCount + 1
        else
	        local nCount = 0
			local cardEvoluteDanYao = self:cvsCardEvoluteDanYao(needDanYaoID,danYaoLevel)
			notActivateNeed = notActivateNeed + cardEvoluteDanYao.NeedMoney
	        --计算要消耗的材料数量
	        local nItemDataNum = self:evoluteDanYaoItemTypeNum(cardEvoluteDanYao)
	        for i = 1,nItemDataNum do 
		        local nItemStarLev = cardEvoluteDanYao["ItemStarLevel"..i]
		        local nItemID = cardEvoluteDanYao["ItemID"..i]
		        local nItemNum = cardEvoluteDanYao["ItemNum"..i] --要消耗多少材料
			    --材料数量足够
			    if self:danYaoNumContrast(nItemID,nItemStarLev,nItemNum) then 
				    if skillLevel > bLevel then
						onekeyCount = onekeyCount - 1
					elseif cardEvoluteDanYao.NeedMoney > g_Hero:getCoins() then 
					else
					    nCount = nCount + 1
			            if nCount ==  nItemDataNum then 
							onekeyCount = onekeyCount + 1
						else
							onekeyCount = onekeyCount - 1
	                    end
				    end
				else
					onekeyCount = onekeyCount - 1
			    end
	        end
        end
    end

	if onekeyCount == 3 then 
		onekeyUpgradeFlag = true
	end

	return notActivateNeed,onekeyUpgradeFlag
end


function ComposeData:ctor()

end


---------------------------------------------------------------------------------
g_ComposeData = ComposeData.new()






