local AnimationUtil=classGc(function(self)
	self.m_animationCache  =cc.AnimationCache:getInstance()
	self.m_spriteFrameCache=cc.SpriteFrameCache:getInstance()
end)

function AnimationUtil.createAnimation(self,_plistFile,_spriteFrameName,_delayPerUnit,_loopNum)
	_delayPerUnit=_delayPerUnit or 0.2
    _loopNum     =_loopNum or 1
    
    if _plistFile~=nil and string.len(_plistFile)>0 then
        self.m_spriteFrameCache:addSpriteFrames(_plistFile)
    end
    
    local frameNum  = 100
    local animation = cc.Animation:create()
    for i=1,frameNum do
        local spriteFullName = string.format("%s%.2d.png",_spriteFrameName,i)
        
        local spriteFrame = self.m_spriteFrameCache:getSpriteFrame(spriteFullName)
        if spriteFrame==nil then
            CCLOG("COMPLETE spriteFrame spriteFullName=%s",spriteFullName)
            break
        end
        animation:addSpriteFrame(spriteFrame)
    end

    animation:setLoops(_loopNum)
    animation:setDelayPerUnit(_delayPerUnit)
    return animation
end

function AnimationUtil.createAnimateAction(self,_plistFile,_spriteFrameName,_delayPerUnit,_loopNum)
    local animation=self:createAnimation(_plistFile,_spriteFrameName,_delayPerUnit,_loopNum)
    return cc.Animate:create(animation)
end

function AnimationUtil.getSelectBtnAnimate(self)
	local szCacheName="effect_selectBtn"
	local pAnimation=self.m_animationCache:getAnimation(szCacheName)
	if pAnimation==nil then
		pAnimation=self:createAnimation(nil,"effect_scelectbtn_",0.1)
        self.m_animationCache:addAnimation(pAnimation,szCacheName)
	end
	return cc.Animate:create(pAnimation)
end

function AnimationUtil.getGoodsEffectAnimate(self,_colorIdx)
	local szCacheName=string.format("effect_goodsFram_%d",_colorIdx)
	local pAnimation=self.m_animationCache:getAnimation(szCacheName)
	if pAnimation==nil then
		pAnimation=self:createAnimation(nil,string.format("ui_goods_effect_%d",_colorIdx),0.1)
        self.m_animationCache:addAnimation(pAnimation,szCacheName)
	end
	return cc.Animate:create(pAnimation)
end

function AnimationUtil.getRoleDeadAnimate(self)
	local szCacheName="effect_roleDead"
	local pAnimation=self.m_animationCache:getAnimation(szCacheName)
	if pAnimation==nil then
		pAnimation=self:createAnimation(nil,"dead_effect_",0.1)
        self.m_animationCache:addAnimation(pAnimation,szCacheName)
	end
	return cc.Animate:create(pAnimation)
end

function AnimationUtil.getSkillBtnFinishAnimate(self)
	local szCacheName="effect_skillBtn_finish"
	local pAnimation=self.m_animationCache:getAnimation(szCacheName)
	if pAnimation==nil then
		pAnimation=self:createAnimation(nil,"battle_effect_",0.05)
        self.m_animationCache:addAnimation(pAnimation,szCacheName)
	end
	return cc.Animate:create(pAnimation)
end

function AnimationUtil.getVoiceRecordAnimate(self)
	local szCacheName="effect_voiceRecord"
	local pAnimation=self.m_animationCache:getAnimation(szCacheName)
	if pAnimation==nil then
		pAnimation=self:createAnimation(nil,"general_volume_",0.25)
        self.m_animationCache:addAnimation(pAnimation,szCacheName)
	end
	return cc.Animate:create(pAnimation)
end

return AnimationUtil