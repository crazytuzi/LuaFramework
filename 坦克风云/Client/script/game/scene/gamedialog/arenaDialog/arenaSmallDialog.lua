arenaSmallDialog=smallDialog:new()

function arenaSmallDialog:new(parent,cityID)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogHeight=400
	self.dialogWidth=550

	self.parent=parent
	self.cityID=cityID
	return nc
end

function arenaSmallDialog:create(layerNum)
    local sd=arenaSmallDialog:new()
    sd:init(layerNum)
    return sd

end
function arenaSmallDialog:init(layerNum)
    self.isTouch=false
    self.isUseAmi=false
    local function touchHandler()
    
    end
    
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),touchHandler)
    self.dialogLayer=CCLayer:create()
    
    self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(550,400)
    self.bgLayer:setContentSize(self.bgSize)
    self:show()
    
    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);
    sceneGame:addChild(self.dialogLayer,layerNum)
    
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    

    local size=25
    local layerX=self.bgLayer:getContentSize().width/2
    local layerY=self.bgLayer:getContentSize().height
    local lb1 = GetTTFLabel(getlocal("arena_getReward_desc1"),size);
    lb1:setPosition(ccp(layerX,layerY-130));
    self.bgLayer:addChild(lb1,2);

    local lb2 = GetTTFLabel(getlocal("arena_getReward_desc2",{arenaVoApi:getArenaVo().ranked}),size);
    lb2:setPosition(ccp(layerX,layerY-180));
    self.bgLayer:addChild(lb2,2);

    local isreward,luckrank=arenaVoApi:isLuckReward()
    if isreward then
        local lb3 = GetTTFLabel(getlocal("arena_getReward_desc3",{luckrank}),size);
        lb3:setPosition(ccp(layerX,layerY-230));
        self.bgLayer:addChild(lb3,2);
    end
    
    local function reward()

        local function callback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData.data~=nil and sData.data.reward~=nil then
                    local award=FormatItem(sData.data.reward) or {}
                    for k,v in pairs(award) do
                        G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                    end
                    G_showRewardTip(award)
                    arenaVoApi:getArenaVo().reward_at=base.serverTime

                    local isreward,luckrank=arenaVoApi:isLuckReward()
                    if isreward and sData.data.luckreward~=nil then
                        local function callBack2()
                            local award=FormatItem(sData.data.luckreward) or {}
                            for k,v in pairs(award) do
                                G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                            end
                            G_showRewardTip(award)
                        end
                        local callFunc=CCCallFunc:create(callBack2)
                        local delay=CCDelayTime:create(1.5)
                        local acArr=CCArray:create()
                        acArr:addObject(delay)
                        acArr:addObject(callFunc)
                        local seq=CCSequence:create(acArr)
                        sceneGame:runAction(seq)
                    end

                end
                
            end
            self:close()
        end
        socketHelper:militaryGetreward(callback)
    end
    local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnCancleSmall.png",reward,nil,getlocal("newGiftsReward"),25)
    local rewardMenu=CCMenu:createWithItem(rewardItem);
    rewardMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,70))
    rewardMenu:setTouchPriority((-(layerNum-1)*20-4));
    self.bgLayer:addChild(rewardMenu)

end



