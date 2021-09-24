planeSkillStudyDialog=smallDialog:new()

function planeSkillStudyDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.layerNum = nil
	nc.bgSize = nil
	nc.sid = nil
	return nc
end

function planeSkillStudyDialog:showStudyDialog(layerNum,sid,titleStr,parent)
	local sd = planeSkillStudyDialog:new()
	sd:initStudyDialog(layerNum,sid,titleStr,parent)
	return sd
end

function planeSkillStudyDialog:initStudyUI()
    if self.bgLayer and tolua.cast(self.bgLayer,"CCNode") then
        self.bgLayer:removeFromParentAndCleanup(true)
    end
    self.studyList=nil
    self.consumeGems=nil

    local function closeDialog()
        base:removeFromNeedRefresh(self)
        self:close()
    end
    
    local fontSize=20
    if G_isAsia() == false then
        fontSize = 15
    end
    local skillInfo,maxLv=planeVoApi:getNewSkillInfoById(self.sid)
    local curLevel=skillInfo.lv or 0
    local lvinfo=planeVoApi:getNewSkillCfgByLv(self.sid,curLevel+1)
    if lvinfo then
        self.bgSize=CCSizeMake(580,850)
    else
        self.bgSize=CCSizeMake(580,300)
        --已研究至最大等级
    end

    local dialogBg,titleBg,titleLb,closeBtnItem,closeBtn=G_getNewDialogBg(self.bgSize,self.titleStr,32,nil,self.layerNum,true,function()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        closeDialog()
    end,nil)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.dialogLayer:addChild(self.bgLayer,2)

    local function onInfoHandler()
        require "luascript/script/game/scene/gamedialog/plane/planeSkillDetailDialog"
        planeSkillDetailDialog:showSkillDetail(self.layerNum+1,self.sid,getlocal("buffEffectStr"))
    end

    local _lbPosX=0
    local skillIcon
    skillIcon=planeVoApi:getNewSkillIcon(self.sid,function()
        G_touchedItem(skillIcon,onInfoHandler,0.8)
    end)
    skillIcon:setPosition(85,self.bgSize.height-125)
    skillIcon:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(skillIcon)
    if _lbPosX<skillIcon:getPositionX()+skillIcon:getContentSize().width/2 then
        _lbPosX=skillIcon:getPositionX()+skillIcon:getContentSize().width/2
    end

    local infoSp=CCSprite:createWithSpriteFrameName("i_sq_Icon1.png")
    infoSp:setScale(0.6)
    infoSp:setAnchorPoint(ccp(0,1))
    infoSp:setPosition(0,skillIcon:getContentSize().height)
    skillIcon:addChild(infoSp)

    local skillNameLb=GetTTFLabelWrap(planeVoApi:getNewSkillNameStr(self.sid),fontSize,CCSizeMake(skillIcon:getContentSize().width+40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    skillNameLb:setPosition(skillIcon:getPositionX(),skillIcon:getPositionY()-skillIcon:getContentSize().height/2-skillNameLb:getContentSize().height/2-3)
    self.bgLayer:addChild(skillNameLb)
    if _lbPosX<skillNameLb:getPositionX()+skillNameLb:getContentSize().width/2 then
        _lbPosX=skillNameLb:getPositionX()+skillNameLb:getContentSize().width/2
    end

    local scheduleStr=curLevel.."/"..maxLv
    local per=(curLevel/maxLv)*100
    local barPic="smallGreenBar.png"
    if curLevel>=maxLv then
        barPic="smallYellowBar.png"
    end
    AddProgramTimer(self.bgLayer,ccp(0,0),11,12,scheduleStr,"smallBarBg.png",barPic,13,1,1,nil,nil,fontSize-2)
    local prgoressBarBg=tolua.cast(self.bgLayer:getChildByTag(13),"CCSprite")
    local prgoressBar=tolua.cast(self.bgLayer:getChildByTag(11),"CCProgressTimer")
    local pw,ph=prgoressBarBg:getContentSize().width,prgoressBarBg:getContentSize().height
    local prgoressBarPos=ccp(skillIcon:getPositionX(),skillNameLb:getPositionY()-skillNameLb:getContentSize().height/2-5-ph/2)
    prgoressBarBg:setPosition(prgoressBarPos)
    prgoressBar:setPosition(prgoressBarPos)
    prgoressBar:setPercentage(per)
    if _lbPosX<prgoressBarBg:getPositionX()+prgoressBarBg:getContentSize().width/2 then
        _lbPosX=prgoressBarBg:getPositionX()+prgoressBarBg:getContentSize().width/2
    end

    _lbPosX=_lbPosX+10
    local descBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20,20,1,1),function()end)
    descBg:setContentSize(CCSizeMake(self.bgSize.width-_lbPosX-25,skillIcon:getPositionY()+skillIcon:getContentSize().height/2-(prgoressBarPos.y-ph/2)))
    descBg:setAnchorPoint(ccp(0,1))
    descBg:setPosition(_lbPosX,skillIcon:getPositionY()+skillIcon:getContentSize().height/2)
    self.bgLayer:addChild(descBg)

    --如果等于主动技能
    if self.skillCfg.skill[self.sid].type==1 then
        local curLabel=GetTTFLabel(getlocal("effect"),fontSize)
        curLabel:setAnchorPoint(ccp(1,1))
        curLabel:setPosition(10+curLabel:getContentSize().width,descBg:getContentSize().height-5)
        descBg:addChild(curLabel)
        local colorTb={ --结合cn3.lua中的  plane_skill_nsdesc_s5,plane_skill_nsdesc_s10,plane_skill_nsdesc_s15,plane_skill_nsdesc_s20
            s5={nil,G_ColorGreen2,nil,G_ColorGreen2},
            s10={nil,G_ColorGreen2,nil,G_ColorGreen2,nil,G_ColorGreen2},
            s15={nil,G_ColorGreen2,nil,G_ColorGreen2,nil,G_ColorGreen2},
            s20={nil,G_ColorGreen2,nil},
        }
        local descTb={
            {planeVoApi:getNewSkillDesc(self.sid,(curLevel==0) and 1 or curLevel,true),colorTb[self.sid]}
        }
        local descSize=CCSizeMake(descBg:getContentSize().width-curLabel:getPositionX()-5,descBg:getContentSize().height-10)
        local descTv=G_LabelTableViewNew(descSize,descTb,fontSize,nil,nil,nil,true)
        descTv:setPosition(curLabel:getPositionX(),5)
        descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
        descTv:setMaxDisToBottomOrTop(0)
        descBg:addChild(descTv)
    else
        local curLabel=GetTTFLabel(getlocal("current_text"),fontSize)
        curLabel:setAnchorPoint(ccp(1,1))
        curLabel:setPosition(10+curLabel:getContentSize().width,descBg:getContentSize().height-5)
        descBg:addChild(curLabel)
        if lvinfo then
            local nextLabel=GetTTFLabel(getlocal("upgrade_text"),fontSize)
            nextLabel:setAnchorPoint(ccp(1,1))
            if curLabel:getPositionX()<10+nextLabel:getContentSize().width then
                curLabel:setPositionX(10+nextLabel:getContentSize().width)
            end
            nextLabel:setPosition(curLabel:getPositionX(),descBg:getContentSize().height/2-5)
            descBg:addChild(nextLabel)
            local nextDescLb=GetTTFLabelWrap(planeVoApi:getNewSkillDesc(self.sid,curLevel+1,true),fontSize,CCSizeMake(descBg:getContentSize().width-nextLabel:getPositionX()-5,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            nextDescLb:setAnchorPoint(ccp(0,1))
            nextDescLb:setPosition(nextLabel:getPosition())
            descBg:addChild(nextDescLb)
        end
        local curDescLb=GetTTFLabelWrap(planeVoApi:getNewSkillDesc(self.sid,curLevel,true),fontSize,CCSizeMake(descBg:getContentSize().width-curLabel:getPositionX()-5,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        curDescLb:setAnchorPoint(ccp(0,1))
        curDescLb:setPosition(curLabel:getPosition())
        descBg:addChild(curDescLb)
    end

    if lvinfo then
        local cellData={}
        local studyTb=planeVoApi:getStudyList()

        --@研究队列
        if studyTb then
            for k, v in pairs(studyTb) do
                table.insert(cellData,{1,v})
            end
            --有研究队列
            -- if SizeOfTable(studyTb)<planeVoApi:getMaxStudyListNum() then
            --     --研究队列未满
            -- else
            --     --研究队列已满
            -- end
        else
            --研究队列为空
            table.insert(cellData,{1,nil})
        end

        --@前置技能
        if lvinfo.preSkill then
            for k, v in pairs(lvinfo.preSkill) do
                table.insert(cellData,{2,{sid=v[1],lv=v[2]}})
            end
        end

        --@新道具
        if lvinfo.p then
            for k, v in pairs(lvinfo.p) do
                local name,pic,desc,id,index,eType,equipId,bgname=getItem(k,"p",v)
                local ownNum=bagVoApi:getItemNumId(id)
                local item={name=name,needNum=v,num=ownNum,pic=pic,desc=desc,id=id,type="p",index=index,key=k,eType=eType,equipId=equipId,bgname=bgname,callback=function(isReturn)
                    if isReturn then
                        bagVoApi:addBag(id,math.ceil(v*self.skillCfg.returnRes))
                    else
                        bagVoApi:useItemNumId(id,v)
                    end
                end}
                table.insert(cellData,{3,item})
            end
        end

        --@资源
        if lvinfo.r then
            local rrate = planeVoApi:getSkillStudyResCostBuff()
            for i=1,4 do
                local k="r"..i
                if lvinfo.r[k] then
                    local r = {}
                    local rcost = math.floor(lvinfo.r[k]*(1-rrate))
                    r[k] = rcost
                    local picName=G_getResourceIcon(k)
                    local ownNum=playerVoApi["getR"..i]()
                    local item={pic=picName,needNum=rcost,num=ownNum,index=i,callback=function(isReturn)
                        if isReturn then
                            local scost = rcost
                            if cellData[1] and cellData[1][1] == 1 and cellData[1][2] then --如果有研究队列的话，取当时升级时的消耗
                                local study = cellData[1][2]
                                if study.res and study.res[k] then
                                    scost = study.res[k]
                                end
                            end
                            -- print("cost,rcost,scost====>",lvinfo.r[k],rcost,scost)
                            local _num=playerVoApi["getR"..i]()+math.ceil(scost*self.skillCfg.returnRes)
                            playerVoApi:setValue(k,_num)
                        else
                            playerVoApi:useResource(r.r1,r.r2,r.r3,r.r4)
                        end
                    end}
                    table.insert(cellData,{4,item})
                end
            end
        end

        --当前的技能是否正在研究中
        local isStudying=planeVoApi:isNewSkillStudying(self.sid)
        --是否可以研究
        local isCanStudy=true

        local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
        tvBg:setContentSize(CCSizeMake(self.bgSize.width-40,descBg:getPositionY()-descBg:getContentSize().height-10-90))
        tvBg:setAnchorPoint(ccp(0.5,0))
        tvBg:setPosition(self.bgSize.width/2,90)
        self.bgLayer:addChild(tvBg)

        local tvTitleBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
        tvTitleBg:setAnchorPoint(ccp(0.5,1))
        tvTitleBg:setPosition(tvBg:getContentSize().width/2,tvBg:getContentSize().height)
        tvBg:addChild(tvTitleBg)
        local tvTitle=GetTTFLabel(getlocal("condition_text"),25,true)
        tvTitle:setPosition(tvTitleBg:getContentSize().width/2,tvTitleBg:getContentSize().height/2)
        tvTitle:setColor(G_ColorBlue3)
        tvTitleBg:addChild(tvTitle)

        local tvSize=CCSizeMake(tvBg:getContentSize().width,tvTitleBg:getPositionY()-tvTitleBg:getContentSize().height-5)
        local cellW,cellH=tvSize.width,65
        local function tvCallBack(handler,fn,index,cel)
            if fn=="numberOfCellsInTableView" then
                return SizeOfTable(cellData)
            elseif fn=="tableCellSizeForIndex" then
                return  CCSizeMake(cellW,cellH)
            elseif fn=="tableCellAtIndex" then
                local cell=CCTableViewCell:new()
                cell:autorelease()

                local fontSize=22
                if G_isAsia() == false then
                    fontSize = 15
                end
                local data=cellData[index+1]
                local showType=data[1]
                local showData=data[2]
                local stateSp=nil
                local btnImage=nil
                if showType==1 then --@研究队列
                    local lbStr
                    local lbColor
                    local timeStr
                    if showData then
                        lbStr=planeVoApi:getNewSkillNameStr(showData.sid)
                        lbColor=G_ColorRed
                        stateSp=CCSprite:createWithSpriteFrameName("IconFault.png")
                        btnImage={"yh_taskGoto.png","yh_taskGoto_down.png","yh_taskGoto.png"}
                        timeStr=G_formatActiveDate(showData.q - base.serverTime)
                    else
                        lbStr=getlocal("can_study")
                        lbColor=G_ColorGreen2
                        stateSp=CCSprite:createWithSpriteFrameName("IconCheck.png")
                    end
                    local lb=GetTTFLabelWrap(lbStr,fontSize,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    lb:setAnchorPoint(ccp(0,0.5))
                    lb:setPosition(25,cellH/2)
                    lb:setColor(lbColor)
                    cell:addChild(lb)
                    if timeStr then
                        local timeLb=GetTTFLabel(timeStr,fontSize)
                        timeLb:setAnchorPoint(ccp(1,0.5))
                        timeLb:setPosition(cellW-135,cellH/2)
                        cell:addChild(timeLb)
                        if self.studyList==nil then
                            self.studyList={}
                        end
                        table.insert(self.studyList,{label=timeLb,sid=showData.sid,time=showData.q})
                    end
                    if isStudying then
                        lb:setColor(G_ColorWhite)
                        stateSp=nil
                        -- btnImage=nil
                    end
                elseif showType==2 then --@前置技能
                    local str=planeVoApi:getNewSkillNameStr(showData.sid).."："..getlocal("lower_level")..showData.lv
                    local lb=GetTTFLabel(str,fontSize)
                    lb:setAnchorPoint(ccp(0,0.5))
                    lb:setPosition(25,cellH/2)
                    cell:addChild(lb)
                    local _curLv=planeVoApi:getNewSkillInfoById(showData.sid).lv or 0
                    if _curLv>=showData.lv then
                        lb:setColor(G_ColorGreen2)
                        stateSp=CCSprite:createWithSpriteFrameName("IconCheck.png")
                    else
                        lb:setColor(G_ColorRed)
                        stateSp=CCSprite:createWithSpriteFrameName("IconFault.png")
                        btnImage={"yh_nbSkillGoto.png","yh_nbSkillGoto_Down.png","yh_nbSkillGoto.png"}
                    end
                    if isStudying then
                        lb:setColor(G_ColorGray)
                        stateSp=nil
                        btnImage=nil
                    end
                elseif showType==3 then --@新道具
                    local icon,scale=G_getItemIcon(showData,100)
                    scale=32/icon:getContentSize().width
                    icon:setScale(scale)
                    icon:setPosition(25+icon:getContentSize().width*scale/2,cellH/2)
                    cell:addChild(icon)
                    local ownNum=showData.num
                    local needNum=showData.needNum
                    local lb=GetTTFLabel(FormatNumber(ownNum).."/"..FormatNumber(needNum),fontSize)
                    lb:setAnchorPoint(ccp(0,0.5))
                    lb:setPosition(icon:getPositionX()+icon:getContentSize().width*scale/2+5,cellH/2)
                    cell:addChild(lb)
                    if ownNum>=needNum then
                        lb:setColor(G_ColorGreen2)
                        stateSp=CCSprite:createWithSpriteFrameName("IconCheck.png")
                    else
                        lb:setColor(G_ColorRed)
                        stateSp=CCSprite:createWithSpriteFrameName("IconFault.png")
                        btnImage={"sYellowAddBtn.png","sYellowAddBtn.png","sYellowAddBtn.png"}
                    end
                    if isStudying then
                        lb:setColor(G_ColorGray)
                        stateSp=nil
                        btnImage=nil
                    end
                elseif showType==4 then --@资源
                    local icon=CCSprite:createWithSpriteFrameName(showData.pic)
                    icon:setPosition(25+icon:getContentSize().width/2,cellH/2)
                    cell:addChild(icon)
                    local ownNum=showData.num
                    local needNum=showData.needNum
                    local lb=GetTTFLabel(FormatNumber(ownNum).."/"..FormatNumber(needNum),fontSize)
                    lb:setAnchorPoint(ccp(0,0.5))
                    lb:setPosition(icon:getPositionX()+icon:getContentSize().width/2+5,cellH/2)
                    cell:addChild(lb)
                    if ownNum>=needNum then
                        lb:setColor(G_ColorGreen2)
                        stateSp=CCSprite:createWithSpriteFrameName("IconCheck.png")
                    else
                        lb:setColor(G_ColorRed)
                        stateSp=CCSprite:createWithSpriteFrameName("IconFault.png")
                        btnImage={"sYellowAddBtn.png","sYellowAddBtn.png","sYellowAddBtn.png"}
                    end
                    if isStudying then
                        lb:setColor(G_ColorGray)
                        stateSp=nil
                        btnImage=nil
                    end
                end

                if stateSp then
                    stateSp:setPosition(cellW-100,cellH/2)
                    cell:addChild(stateSp)
                end

                if btnImage then
                    isCanStudy=false
                    local button
                    local function onBtnHandler(tag,obj)
                        if G_checkClickEnable()==false then
                            do return end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)
                        local function onBtnTouchHandler()
                            if tag==1 then
                                if self.consumeGems==nil then
                                    do return end
                                end
                                if self.consumeGems and self.consumeGems[showData.sid] then
                                    local _price=self.consumeGems[showData.sid]
                                    if playerVoApi:getGems()<_price then
                                        GemsNotEnoughDialog(nil,nil,_price-playerVoApi:getGems(),self.layerNum+1,_price)
                                        do return end
                                    end
                                    local function onSureLogic()
                                        planeVoApi:speedupUpgradeNewSkill(showData.sid,function()
                                            playerVoApi:setGems(playerVoApi:getGems()-_price)
                                            self:initStudyUI()
                                        end)
                                    end
                                    local function secondTipFunc(sbFlag)
                                        local sValue=base.serverTime .. "_" .. sbFlag
                                        G_changePopFlag("planeSkillStudyDialog",sValue)
                                    end
                                    if G_isPopBoard("planeSkillStudyDialog") then
                                        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{_price}),true,onSureLogic,secondTipFunc)
                                    else
                                        onSureLogic()
                                    end
                                end
                            elseif tag==2 then
                                if self.parent and self.parent.jumpToSkill then
                                    closeDialog()
                                    self.parent:jumpToSkill(showData.sid)
                                end
                            elseif tag==3 then
                                G_showBatchBuyPropSmallDialog(showData.key,self.layerNum+1,function()
                                    self:initStudyUI()
                                end,nil,1000,nil,"plskill.buy.prop")
                            elseif tag==4 then
                                smallDialog:showBuyResDialog(showData.index,self.layerNum+1,function()
                                    self:initStudyUI()
                                end)
                            end
                        end
                        G_touchedItem(button,onBtnTouchHandler,0.8)
                    end
                    button=GetButtonItem(btnImage[1],btnImage[2],btnImage[3],onBtnHandler,showType)
                    button:setScale(50/button:getContentSize().height)
                    button:setAnchorPoint(ccp(0.5,0.5))
                    local menu=CCMenu:createWithItem(button)
                    menu:setTouchPriority(-(self.layerNum-1)*20-4)
                    menu:setPosition(ccp(cellW-button:getContentSize().width/2-25,cellH/2))
                    cell:addChild(menu)
                end

                if index+1~=SizeOfTable(cellData) then
                    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
                    lineSp:setContentSize(CCSizeMake(cellW-30, 3))
                    lineSp:setPosition(cellW/2,0)
                    cell:addChild(lineSp)
                end

                return cell
            elseif fn=="ccTouchBegan" then
                return true
            elseif fn=="ccTouchMoved" then
            elseif fn=="ccTouchEnded" then
            end
        end
        local hd=LuaEventHandler:createHandler(tvCallBack)
        local tv=LuaCCTableView:createWithEventHandler(hd,tvSize,nil)
        tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
        tv:setMaxDisToBottomOrTop(100)
        tv:setPosition(0,3)
        tvBg:addChild(tv)

        local btnTag=11
        local btnStr=getlocal("startResearch")
        if isStudying==true then
            isCanStudy=true
            btnTag=12
            btnStr=getlocal("cancel")
        end

        local button
        local function buttonHandler(tag,obj)
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local function buttonTouchHandler()
                if tag==11 then
                    planeVoApi:upgradeNewSkill(self.sid,function()
                        --TODO 更新道具和资源
                        for k, v in pairs(cellData) do
                            if v and v[2] and v[2].callback then
                                v[2].callback()
                            end
                        end
                        self:initStudyUI()
                    end)
                elseif tag==12 then
                    G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("cancel_study"),nil,function(...)
                        planeVoApi:cancelUpgradeNewSkill(self.sid,function()
                            --取消后要加减去的资源和道具返回一半
                            for k, v in pairs(cellData) do
                                if v and v[2] and v[2].callback then
                                    v[2].callback(true)
                                end
                            end
                            self:initStudyUI()
                        end)
                    end)
                end
            end
            G_touchedItem(button,buttonTouchHandler,button:getScale()-0.2)
        end
        local btnScale=0.8
        button=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",buttonHandler,btnTag,btnStr,24/btnScale)
        button:setScale(btnScale)
        button:setAnchorPoint(ccp(0.5,0.5))
        local menu=CCMenu:createWithItem(button)
        menu:setTouchPriority(-(self.layerNum-1)*20-4)
        menu:setPosition(ccp(self.bgSize.width/2,20+button:getContentSize().height*button:getScale()/2))
        self.bgLayer:addChild(menu)
        button:setEnabled(isCanStudy)
    end
end

function planeSkillStudyDialog:initStudyDialog(layerNum,sid,titleStr,parent)
	self.layerNum=layerNum
	self.isUseAmi=true

    self.sid=sid
    self.titleStr=titleStr
    self.parent=parent
	self.skillCfg=planeVoApi:getNewSkillCfg()

	self.dialogLayer=CCLayer:create()

    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function()end)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    -- touchDialogBg:setOpacity(50)
    touchDialogBg:setAnchorPoint(ccp(0.5,0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.dialogLayer:addChild(touchDialogBg)

    self:initStudyUI()
    base:addNeedRefresh(self)

    self:show()
    sceneGame:addChild(self.dialogLayer,self.layerNum)
end

function planeSkillStudyDialog:tick()
    if self then
        if self.studyList then
            for k, v in pairs(self.studyList) do
                if v and v.label and tolua.cast(v.label,"CCLabelTTF") and v.time then
                    if self.consumeGems==nil then
                        self.consumeGems={}
                    end
                    self.consumeGems[v.sid]=math.ceil((v.time-base.serverTime)/self.skillCfg.gold2Time)
                    if v.time-base.serverTime<0 then
                        self:initStudyUI()
                    else
                        tolua.cast(v.label,"CCLabelTTF"):setString(G_formatActiveDate(v.time - base.serverTime))
                    end
                end
            end
        end
    end
end