
--创建CSpineMgr
CSpineMgr = class("CSpineMgr")
CSpineMgr.__index = CSpineMgr

--初始化
function CSpineMgr:initSpine(tbSpineName)
    self.tSpineAni = {}
	for i=1, #tbSpineName do
        local szName = tbSpineName[i]
        if not self.tbSpineName[szName] then
            local spine = self.createSpineAnimation(szName)
            spine:retain()
            self.tSpineAni[szName] = spine
            spine.bMain = true
        end
    end
end

--创建spine动画
function CSpineMgr:createSpineAnimation(szSpineName, nScale)
    nScale = nScale or 1
	local spine = self.tSpineAni[szName]
    if spine then
        if not spine.bFirst then
            spine.bFirst = true
            return spine
        else
            return spine:clone()
        end
    else
        local szJson = string.format("SpineCharacter/%s.json", szName)
        local szAtlas = string.format("SpineCharacter/%s.atlas", szName)
        local CCNode_Skeleton = SkeletonAnimation:createWithFile(szJson, szAtlas, nScale)
        return CCNode_Skeleton
    end
end

--获取动画
function CSpineMgr:getSpineAnimation(szName, bMain)
    local spine = self:createCocosSpineAnimation(szName, nScale)
    if bMain then
       spine.bMain = bMain
    end
    --spine:activeUpdate()
    return spine
end

--播放动画
function CSpineMgr:runSpineAnimation(CCNode_Skeleton, szName, bLoop)
   CCNode_Skeleton:setAnimation(0, szName, bLoop)
end

--清除资源
function CSpineMgr:clearSpine(bClearAll)
    for key, vaule in pairs(self.tSpineAni) do
        if bClearAll then
            vaule.release()
        else
            if not vaule.bMain then
               vaule:release()
            end
        end
    end
end

--清除标志
function CSpineMgr:clearSpineFlag(bMain)
    for key, vaule in pairs(self.tSpineAni) do
        if bMain == vaule.bMain then
           vaule.bFirst = nil
        end
    end
end

--创建对象
g_SpineMgr = CSpineMgr:new()