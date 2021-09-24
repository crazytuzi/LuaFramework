ltzdzForeignDialog=commonDialog:new()

function ltzdzForeignDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function ltzdzForeignDialog:resetTab()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
    self.panelLineBg:setVisible(false)
    G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight-80)
end

function ltzdzForeignDialog:updateUser()
    self.sortUser={}
    self.myUser=nil
    local myuid=playerVoApi:getUid()
    local mapUserTb=G_clone(ltzdzFightApi:getMapUserList())
    for k,v in pairs(mapUserTb) do
        if tonumber(myuid)==tonumber(k) then
            self.myUser=ltzdzFightApi:getUserInfo(tostring(myuid))
            mapUserTb[k]=nil
            do break end
        end
    end
    if self.myUser==nil then
        self.cellNum=0
        do return end
    end
    table.insert(self.sortUser,self.myUser)

    local invitelist=self.myUser.invitelist or {}
    for k,inviteId in pairs(invitelist) do --帅选出邀请自己的玩家排到自己的后面
        local uid=tostring(inviteId)
        if mapUserTb[uid] then
            local user=ltzdzFightApi:getUserInfo(uid)
            table.insert(self.sortUser,user)
            mapUserTb[uid]=nil
        end
    end
    local myAllyUid=tonumber(self.myUser.ally) or 0

    local singleUserTb={} --没有结盟的玩家
    local function fliterAlly()
        for k,v in pairs(mapUserTb) do
            if mapUserTb[k].s and mapUserTb[k].s<2 then
                local user=ltzdzFightApi:getUserInfo(k)
                if myAllyUid==tonumber(user.uid) then --如果是自己盟友，则插入到自己后面
                    table.insert(self.sortUser,2,user)
                    mapUserTb[k]=nil
                else
                    local allyUid=tonumber(user.ally) or 0
                    if allyUid~=0 then --该玩家有盟友
                        allyUid=tostring(allyUid)
                        local allyUser=ltzdzFightApi:getUserInfo(allyUid)
                        table.insert(self.sortUser,user)
                        table.insert(self.sortUser,allyUser)
                        mapUserTb[k]=nil
                        mapUserTb[allyUid]=nil
                    else
                        table.insert(singleUserTb,user)
                        mapUserTb[k]=nil
                    end
                end
            end
            mapUserTb[k]=nil
            
            fliterAlly()
            do return end
       end
    end
    fliterAlly() --筛选出配对盟友

    for k,v in pairs(singleUserTb) do --把没有配对盟友的玩家插入列表中
        table.insert(self.sortUser,v)
    end

    self.ownCityList={}
    local citylist=ltzdzFightApi:getAllCity()
    for k,v in pairs(citylist) do
        if v.oid and self.ownCityList[v.oid]==nil then
            self.ownCityList[v.oid]=1
        else
            self.ownCityList[v.oid]=self.ownCityList[v.oid]+1
        end
    end
    self.cellNum=SizeOfTable(self.sortUser)
end

function ltzdzForeignDialog:initTableView()
    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzForeignDialog",self)

    self:updateUser()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSize.width-30,G_VisibleSize.height-120),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setMaxDisToBottomOrTop(120)
    self.tv:setPosition(ccp(15,40))
    self.bgLayer:addChild(self.tv)

    --刷新同盟关系
    local function refreshAlly(event,data)
       self:refresh()
    end
    self.refreshListener=refreshAlly
    eventDispatcher:addEventListener("ltzdz.allyChanged",refreshAlly)

    local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
    mLine:setPosition(ccp(G_VisibleSizeWidth/2,40))
    mLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,mLine:getContentSize().height))
    self.bgLayer:addChild(mLine)
end

function ltzdzForeignDialog:eventHandler(handler,fn,idx,cel)
   	if fn=="numberOfCellsInTableView" then
   		return self.cellNum
   	elseif fn=="tableCellSizeForIndex" then
       	local tmpSize=CCSizeMake(G_VisibleSize.width-30,150)
       	return tmpSize
   	elseif fn=="tableCellAtIndex" then
   	    local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellWidth=G_VisibleSize.width-30
        local cellHeight=150
        local itemHeight=140
        local myuid=playerVoApi:getUid()
        local user=self.sortUser[idx+1]
        local function nilFunc()
        end
        local itemBg
        if tonumber(myuid)==tonumber(user.uid) then
            itemBg=LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),nilFunc)
            itemBg:setContentSize(CCSizeMake(cellWidth,itemHeight))
            itemBg:setPosition(cellWidth/2,cellHeight/2)
            cell:addChild(itemBg)
        else
            itemBg=G_getThreePointBg(CCSizeMake(cellWidth,itemHeight),nilFunc,ccp(0.5,0.5),ccp(cellWidth/2,cellHeight/2),cell)
        end
        if user and user.pic and user.uid then
            local iconSize=100
            local function showPlayerInfo()
                ltzdzVoApi:showPlayerInfoSmallDialog(self.layerNum+1,true,true,nil,getlocal("playerRole"),user)
            end
            local personPhotoName=playerVoApi:getPersonPhotoName(user.pic)
            local playerIconSp=playerVoApi:GetPlayerBgIcon(personPhotoName,showPlayerInfo)
            playerIconSp:setTouchPriority(-(self.layerNum-1)*20-2)
            playerIconSp:setAnchorPoint(ccp(0,0.5))
            playerIconSp:setPosition(15,itemHeight/2)
            playerIconSp:setScale(iconSize/playerIconSp:getContentSize().width)
            itemBg:addChild(playerIconSp)

            local nameLb=GetTTFLabelWrap(user.nickname,22,CCSizeMake(cellWidth-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            nameLb:setPosition(15+iconSize+10,itemHeight-nameLb:getContentSize().height/2-30)
            nameLb:setAnchorPoint(ccp(0,0.5))
            nameLb:setColor(G_ColorYellowPro)
            itemBg:addChild(nameLb)
            local tempLb=GetTTFLabel(user.nickname,25)
            local realW=tempLb:getContentSize().width
            if realW>nameLb:getContentSize().width then
                realW=nameLb:getContentSize().width
            end

            if ltzdzVoApi:isQualifying()==true then --定级赛
                local segLb=GetTTFLabelWrap(getlocal("ltzdz_qualifying"),22,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                segLb:setAnchorPoint(ccp(0,0.5))
                segLb:setPosition(nameLb:getPositionX()+realW+30,nameLb:getPositionY())
                itemBg:addChild(segLb)
            else
                local rpoint=tonumber(user.rpoint or 0)
                local seg,smallLevel,totalSeg=ltzdzVoApi:getSegByLevel(rpoint)
                local segIconSp=ltzdzVoApi:getSegIcon(seg,smallLevel,nil,1)
                if segIconSp then
                    -- segIconSp:setScale(0.3)
                    segIconSp:setAnchorPoint(ccp(0,0.5))
                    segIconSp:setPosition(nameLb:getPositionX()+realW+10,nameLb:getPositionY())
                    itemBg:addChild(segIconSp)
                end
            end

            local powerLb=GetTTFLabelWrap(getlocal("alliance_info_power")..FormatNumber(user.fc or 0),20,CCSizeMake(140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            powerLb:setPosition(15+iconSize+10,powerLb:getContentSize().height/2+30)
            powerLb:setAnchorPoint(ccp(0,0.5))
            itemBg:addChild(powerLb)
            local ownNum=self.ownCityList[tostring(user.uid)] or 0
            local ownLb=GetTTFLabelWrap(getlocal("ltzdz_ownCity")..ownNum,20,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            ownLb:setPosition(powerLb:getPositionX()+powerLb:getContentSize().width+5,powerLb:getPositionY())
            ownLb:setAnchorPoint(ccp(0,0.5))
            itemBg:addChild(ownLb)

            local priority=-(self.layerNum-1)*20-2
            -- print("user.uid,user.ally----->",user.uid,user.ally)
            if user.ally and tonumber(user.ally)~=0 then
                local userTb=ltzdzFightApi:getUserList()
                local allyUser=userTb[tostring(user.ally)]
                if allyUser then
                    local fontSize,fontWidth=20,200
                    local allyLb=GetTTFLabelWrap(getlocal("ltzdz_hasAlly"),fontSize,CCSizeMake(fontWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
                    allyLb:setAnchorPoint(ccp(0.5,0))
                    allyLb:setPosition(cellWidth-fontWidth/2-5,itemHeight/2+2)
                    itemBg:addChild(allyLb)

                    local allyNameLb=GetTTFLabelWrap(allyUser.nickname,fontSize,CCSizeMake(fontWidth,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    allyNameLb:setAnchorPoint(ccp(0.5,1))
                    allyNameLb:setColor(G_ColorRed)
                    allyNameLb:setPosition(cellWidth-fontWidth/2-5,itemHeight/2-2)
                    itemBg:addChild(allyNameLb)
                end
                do return cell end
            end
            -- print("self.myUser.ally-------->",self.myUser.ally)
            if self.myUser and self.myUser.ally and tonumber(self.myUser.ally)~=0 then --如果自己有了盟友，则没有后续处理
                do return cell end
            end
            if tonumber(myuid)~=tonumber(user.uid) then
                local function showApply()
                    local function showApplySmallDialog()
                        if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                            local function allyHandler() --申请同盟
                                local function applyCallBack()
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("ltzdz_apply_success"),30)
                                    self:refresh()
                                end
                                ltzdzFightApi:ltzdzAllyOperate(1,user.uid,applyCallBack)
                            end
                            local desInfo={25,G_ColorYellowPro,kCCTextAlignmentCenter}
                            local addStrTb={
                                {getlocal("ltzdz_applyAlly_tip1"),G_ColorWhite,25,kCCTextAlignmentLeft,20}
                            }
                            if self.myUser.invite and tonumber(self.myUser.invite)>0  then --如果已经申请过结盟，则添加一条提示信息
                                local strInfo={getlocal("ltzdz_applyAlly_tip2"),G_ColorRed,25,kCCTextAlignmentCenter,20}
                                table.insert(addStrTb,1,strInfo)
                            end
                            G_showSecondConfirm(self.layerNum+1,true,true,getlocal("ltzdz_applyAlly_title"),getlocal("ltzdz_applyAlly_promptStr",{user.nickname}),false,allyHandler,nil,nil,desInfo,addStrTb)
                        end
                    end
                    local applyItem,useBtn=G_createBotton(itemBg,ccp(cellWidth-80,itemHeight/2),{getlocal("ltzdz_ally")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",showApplySmallDialog,0.7,priority)
                end
                if self.myUser then
                    local inviteFlag=ltzdzFightApi:isBeInvited(user.uid)
                    -- print("inviteFlag,self.myUser.invite------->",inviteFlag,self.myUser.invite)
                    if inviteFlag==true then --已被邀请，则显示同意或者拒绝
                        local function showAgreeOrRefuseSmallDialog()
                            if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                                local function confirm()
                                    local function agreeCallBack()
                                        -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("ltzdz_apply_success"),30)
                                        self:refresh()
                                    end
                                    ltzdzFightApi:ltzdzAllyOperate(2,user.uid,agreeCallBack)
                                end
                                local function cancel()
                                    local function refuseCallBack()
                                        -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("ltzdz_apply_success"),30)
                                        self:refresh()
                                    end
                                    ltzdzFightApi:ltzdzAllyOperate(3,user.uid,refuseCallBack)
                                end
                                local desInfo={25,G_ColorYellowPro,kCCTextAlignmentCenter}
                                local addStrTb={
                                    {getlocal("ltzdz_applyAlly_tip1"),G_ColorWhite,25,kCCTextAlignmentLeft,20}
                                }
                                G_showSecondConfirm(self.layerNum+1,true,true,getlocal("ltzdz_applyAlly_title"),getlocal("ltzdz_agreeApply_promptStr",{user.nickname}),false,confirm,nil,cancel,desInfo,addStrTb)
                            end
                        end
                        local agreeItem,agreeBtn=G_createBotton(itemBg,ccp(cellWidth-80,itemHeight/2),{getlocal("agreeTTF")},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",showAgreeOrRefuseSmallDialog,0.7,priority)
                    elseif self.myUser.invite and tonumber(self.myUser.invite)==tonumber(user.uid) then --如果该玩家被自己申请，则显示取消申请
                        local function cancelApply()
                            local function callBack()
                               self:refresh()
                            end
                            ltzdzFightApi:ltzdzAllyOperate(4,user.uid,callBack)
                        end
                        local cancelItem,cancelBtn=G_createBotton(itemBg,ccp(cellWidth-80,itemHeight/2),{getlocal("alliance_info_cancel_apply")},"newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn_Down.png",cancelApply,0.7,priority)
                    else
                        showApply()
                    end
                end
            end
        end

		return cell
   	elseif fn=="ccTouchBegan" then
       	self.isMoved=false
       	return true
   	elseif fn=="ccTouchMoved" then
       	self.isMoved=true
   	elseif fn=="ccTouchEnded"  then
       
   	end
end

function ltzdzForeignDialog:tick()

end

function ltzdzForeignDialog:refresh()
    if self.tv then
        self:updateUser()
        local recordPoint=self.tv:getRecordPoint() 
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function ltzdzForeignDialog:dispose()
    self.sortUser={}
    self.myUser=nil
    if self.refreshListener then
        eventDispatcher:removeEventListener("ltzdz.allyChanged",self.refreshListener)
        self.refreshListener=nil
    end
    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzForeignDialog")

end