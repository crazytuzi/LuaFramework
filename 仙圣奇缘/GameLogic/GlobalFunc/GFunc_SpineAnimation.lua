--------------------------------------------------------------------------------------
-- 文件名:	g_function.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	王家麒
-- 日  期:	2013-3-4 9:37
-- 版  本:	1.0
-- 描  述:	专门用来存放动画相关的公用函数
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

--每次重新加载 不要定时清理
local tbSpineAnimation = {}
tbSpineAnimationcount = 0
local tbSpineAnimationTemp = {}
function g_CocosSpineAnimation(szName, nScale, bBattleCard)
	if not szName or szName == "" then return end
	local nScale = nScale or 1
	
	cclog(szName.." g_CocosSpineAnimation "..tostring(nScale).." "..tostring(bBattleCard))
	local spine = tbSpineAnimation[szName]
    if spine and nScale == 1 then
        return spine:clone()
	else
		local szJson = string.format("SpineCharacter/%s.json", szName)
        local szAtlas = string.format("SpineCharacter/%s.atlas", szName)
        local skeletonNode = SkeletonAnimation:createWithFile(szJson, szAtlas, nScale)

		if nScale == 1 then --bBattleCard then
			if tbSpineAnimationcount > 15 then
                g_ClearSpineAnimation()
			end
			skeletonNode:retain()
			tbSpineAnimation[szName] = skeletonNode
            tbSpineAnimationcount = tbSpineAnimationcount + 1
		end
        cclog("cont ==================== " .. skeletonNode:retainCount())
        return skeletonNode
	end
end

--异步加载spine 
function g_CocosSpineAnimationAsync(CCNode_Skeleton, Image_Card, szName, nScale, animation)
	local lag = CListenFunction:new("spine加载时间 "..szName)
	cclog("spine   "..szName)
	local function createSpineDataCB(ccNode)
		lag:delete()
		skeletonAnimation = tolua.cast(ccNode, "SkeletonAnimation")
		if not Image_Card:isExsit() then
			cclog("Image_Card not exsit")
			return
		end
		Image_Card:addNode(skeletonAnimation)
		if CCNode_Skeleton then
			CCNode_Skeleton = ccNode
		end
		if animation then
			g_runSpineAnimation(skeletonAnimation, animation, true)
		end
	end
	local szJson = string.format("SpineCharacter/%s.json", szName)
	local szAtlas = string.format("SpineCharacter/%s.atlas", szName)
	SkeletonAnimation:createWithFileAsync(szJson, szAtlas, nScale, createSpineDataCB)
end

function g_ClearSpineAnimation(bBattleCard)

    for k, v in pairs(tbSpineAnimation) do 
        cclog("cont ==================== " .. v:retainCount())
        -- local c = v:retainCount()
        -- for i=1,c do
        	v:release()
        -- end
        
    end
    tbSpineAnimation = {}
    tbSpineAnimationcount = 0
   -- SkeletonAnimation:releaseAndClear()
   -- tbSpineAnimationTemp = {}
   --tbSpineAnimation = {}
end

function g_runSpineAnimation(skeletonNode, szName, bLoop)
   skeletonNode:setAnimation(0, szName, bLoop)
end