local MountNode=classGc(function(self,_playerSkinId,_mountSkinId,_mountEffectId,_character)
	self.m_mountResArray={}
	self.m_playerSkinId=_playerSkinId
	self.m_mountSkinId=_mountSkinId
	self.m_mountEffectId=_mountEffectId
	self.m_myCharacter=_character

	self.m_mountData=_G.Cfg.mount_pos[self.m_playerSkinId][self.m_mountSkinId]
    self.m_mountEffect=_G.Cfg.mount_texiao[self.m_mountSkinId]
end)

function MountNode.create(self)
    self.m_rooNode=cc.Node:create()

	local nScale=_G.g_SkillDataManager:getSkinData(self.m_mountSkinId).scale*0.0001 or 1
    local szSpineName="spine/"..tostring(self.m_mountSkinId)
    self.m_mountMainSpine=_G.SpineManager.createSpine(szSpineName,nScale)
    if self.m_mountMainSpine==nil then
        return
    end

    self.m_rooNode:addChild(self.m_mountMainSpine)
    self.m_rooNode:setLocalZOrder(self.m_mountData.zorder)

	self.m_mountResArray[szSpineName]=true

	if self.m_mountEffectId~=nil and self.m_mountEffectId~=0 then

        if self.m_myCharacter and self.m_mountEffect.mapEffect~=nil then
            local function onCallFunc(event)
                if event.type=="complete" then
                    if event.animation=="move" then
                        self:showMapEffect()
                    end
                end
            end
            self.m_mountMainSpine:registerSpineEventHandler(onCallFunc,2)
        end

        if self.m_mountEffect.particle then
            local openEffect=cc.ParticleSystemQuad:create("particle/"..self.m_mountEffect.particle..".plist")
            openEffect:setPosition(80,15)
            openEffect:setPositionType(cc.POSITION_TYPE_GROUPED)
            self.m_rooNode:addChild(openEffect)
        end

        -- if self.m_mountSkinId==40136 then
        --     self.m_mountMainSpine:setBornChildEnable(true)
        --     local particleNode1=cc.ParticleSystemQuad:create("particle/mount_effect_40136.plist")
        --     particleNode1:setPositionType(cc.POSITION_TYPE_GROUPED)
        --     local particleNode2=cc.ParticleSystemQuad:create("particle/mount_effect_40136.plist")
        --     particleNode2:setPositionType(cc.POSITION_TYPE_GROUPED)
        --     local particleNode3=cc.ParticleSystemQuad:create("particle/mount_effect_40136.plist")
        --     particleNode3:setPositionType(cc.POSITION_TYPE_GROUPED)
        --     local particleNode4=cc.ParticleSystemQuad:create("particle/mount_effect_40136.plist")
        --     particleNode4:setPositionType(cc.POSITION_TYPE_GROUPED)
        --     local legNode1=self.m_mountMainSpine:addChildForBorn("1",particleNode1)
        --     local legNode1=self.m_mountMainSpine:addChildForBorn("10",particleNode2)
        --     local legNode1=self.m_mountMainSpine:addChildForBorn("11",particleNode3)
        --     local legNode1=self.m_mountMainSpine:addChildForBorn("12",particleNode4)
        -- end

        local tx1=self.m_mountEffect.tx1
        local szSpineName   = "spine/"..tostring(self.m_mountSkinId).."_1"
        print( " create , szSpineName =", szSpineName )
        self.m_effectSpine1 = _G.SpineManager.createSpine(szSpineName,1*tx1.nScale)
        if self.m_effectSpine1==nil then
            return
        end
        self.m_effectSpine1 : setPosition( tx1.posx, 0 )
        self.m_mountMainSpine:addChild(self.m_effectSpine1,self.m_mountEffect.tx1.z)
        self.m_mountResArray[szSpineName]=true

        if tx1.type==4 then
            self.m_effectSpine1:setAnimation(0,"idle",true)
        elseif tx1.type==5 then
            self.m_effectSpine1:setAnimation(0,"move",true)
        elseif tx1.type==6 then
            self.m_effectSpine1:setAnimation(0,"idle2",true)
        end

        -- 特效2的判定
        local tx2=self.m_mountEffect.tx2
        if tx2 then
            local szSpineName="spine/"..tostring(self.m_mountSkinId).."_2"
            self.m_effectSpine2=_G.SpineManager.createSpine(szSpineName,1*tx2.nScale)
            if self.m_effectSpine2==nil then
                return
            end
            self.m_effectSpine2:setPosition( tx2.posx, 0 )
            self.m_mountMainSpine:addChild(self.m_effectSpine2,tx2.z)
            self.m_mountResArray[szSpineName]=true

            if tx2.type==4 then
                self.m_effectSpine2:setAnimation(0,"idle",true)
            elseif tx2.type==5 then
                self.m_effectSpine2:setAnimation(0,"move",true)
            elseif tx2.type==6 then
                self.m_effectSpine2:setAnimation(0,"idle2",true)
            end
        end
    end

    return self.m_rooNode
end

function MountNode.runIdle(self)
	if self.m_mountMainSpine==nil then return end

    self.m_mountMainSpine:setAnimation(0,"idle1",true)
    if self.m_effectSpine1~=nil and self.m_mountEffect.tx1 then
        local isVis=self.m_mountEffect.tx1.type
        if isVis==1 or isVis==3 then
            self.m_effectSpine1:setVisible(true)
            self.m_effectSpine1:setAnimation(0,"idle",true)
        elseif isVis==2 then
            self.m_effectSpine1:setVisible(false)
        end
    end
    if self.m_effectSpine2~=nil and self.m_mountEffect.tx2 then
        local isVis=self.m_mountEffect.tx2.type
        if isVis==1 or isVis==3 then
            self.m_effectSpine2:setVisible(true)
            self.m_effectSpine2:setAnimation(0,"idle",true)
        elseif isVis==2 then
            self.m_effectSpine2:setVisible(false)
        end
    end
    if self.m_playerHandSpine~=nil and not self.m_isHidePlayerHand then
        self.m_playerHandSpine:setAnimation(0,"m_idle",true)
        self.m_playerHandSpine:setPosition(self.m_mountData.idle_x,self.m_mountData.idle_y)
    end
end
function MountNode.runMove(self)
	if self.m_mountMainSpine==nil then return end

    self.m_mountMainSpine:setAnimation(0,"move",true)
    if self.m_effectSpine1~=nil and self.m_mountEffect.tx1 then
        local isVis=self.m_mountEffect.tx1.type
        if isVis==1 or isVis==2 then
            self.m_effectSpine1:setVisible(true)
            self.m_effectSpine1:setAnimation(0,"move",true)
        elseif isVis==3 then
            self.m_effectSpine1:setVisible(false)
        end
    end
    if self.m_effectSpine2~=nil and self.m_mountEffect.tx2 then
        local isVis=self.m_mountEffect.tx2.type
        if isVis==1 or isVis==2 then
            self.m_effectSpine2:setVisible(true)
            self.m_effectSpine2:setAnimation(0,"move",true)
        elseif isVis==3 then
            self.m_effectSpine2:setVisible(false)
        end
    end
    if self.m_playerHandSpine~=nil and not self.m_isHidePlayerHand then
        self.m_playerHandSpine:setAnimation(0,"m_move",true)
        self.m_playerHandSpine:setPosition(self.m_mountData.move_x,self.m_mountData.move_y)
    end
end
function MountNode.hidePlayerHand(self)
	self.m_isHidePlayerHand=true
	if self.m_playerHandSpine~=nil then
		self.m_playerHandSpine:setVisible(false)
	end
end
function MountNode.showPlayerHand(self)
	self.m_isHidePlayerHand=nil
	if self.m_playerHandSpine~=nil then
		self.m_playerHandSpine:setVisible(true)
	end
end

function MountNode.remove(self)
	if self.m_rooNode==nil then return end
	self.m_rooNode:removeFromParent(true)
	self.m_rooNode=nil
end

function MountNode.getMountResArray(self)
	return self.m_mountResArray
end

function MountNode.getMountData(self)
	return self.m_mountData
end

function MountNode.showMapEffect(self)
    local nScale=_G.g_SkillDataManager:getSkinData(self.m_mountSkinId).scale*0.0001 or 1
    local szSpineName = "spine/"..tostring(self.m_mountSkinId).."_1"
    print( "szSpineName = ", szSpineName )
    local effectSpine = _G.SpineManager.createSpine(szSpineName,nScale)

	local szAction="idle"
    local mapTx = self.m_mountEffect.mapEffect.type
    if mapTx == 6 then
        szAction = "idle2"
    end
	effectSpine:setPosition(self.m_myCharacter.m_nLocationX,self.m_myCharacter.m_nLocationY)
    effectSpine:setScaleX(nScale*self.m_myCharacter:getScaleX())

	local function onCallFunc(event)
        if event.type=="complete" then
        	if event.animation==szAction then
                local function nFun()
                    effectSpine:removeFromParent(true)
                end
                effectSpine:runAction(cc.Sequence:create(
                                                         -- cc.FadeOut:create(0.7),
                                                         -- cc.DelayTime:create(0.35),
                                                            
                                                         cc.CallFunc:create(nFun)
                                                         ))
        	end
        end
    end

    effectSpine:setAnimation(0,szAction,false)

    effectSpine:registerSpineEventHandler(onCallFunc,2)

    _G.g_Stage.m_lpCharacterContainer:addChild(effectSpine,-500)
end

return MountNode