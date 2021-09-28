--------------------------------------------------------------------------------------
-- 文件名:	Hero.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	zgj
-- 日  期:	2015-05-25 18:21
-- 版  本:	1.0
-- 描  述:	spine
-- 应  用:
---------------------------------------------------------------------------------------
CSpine = class("CSpine")
CSpine.__index = CSpine

function CSpine:loadBuZhenSpine()
	local count = 0
	local tbBattleList = g_Hero:getBattleCardList()
	for k,v in pairs(tbBattleList) do		
	    tbCardBattle = g_Hero:getCardObjByServID(v.nServerID)
		if(tbCardBattle)then
			local CSV_CardBase = tbCardBattle:getCsvBase()
			-- echoj("CSpine:loadBuZhenSpine", CSV_CardBase)
			count = count + 1
			if CSV_CardBase.SpineAnimation and CSV_CardBase.SpineAnimation ~= "" then
				g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, 1, true)
			end
			
		end
    end
    for i = count+1,3 do  
    	local tbCard = g_Hero:getCardsInfoByIndex(i)
    	if tbCard then
            local CSV_CardBase = tbCard:getCsvBase()
            g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, 1, true)
        end
    end
end

g_Spine = CSpine:new()