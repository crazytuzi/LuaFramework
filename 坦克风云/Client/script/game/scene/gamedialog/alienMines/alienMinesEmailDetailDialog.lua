alienMinesEmailDetailDialog=commonDialog:new()

function alienMinesEmailDetailDialog:new(layerNum,type,eid,replyTarget,replyTheme,chatSender,chatReport,isAllianceEmail)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum
    self.eid=eid
    self.emailType=type
    self.target=replyTarget
    self.theme=replyTheme
    self.chatSender=chatSender
    self.chatReport=chatReport
    self.isAllianceEmail=isAllianceEmail
    self.replayBtn=nil
    self.attackBtn=nil
    self.writeBtn=nil
    self.deleteBtn=nil
    self.sendBtn=nil
    self.feedBtn=nil
    --self.textField=nil
    --self.cursorSprite=nil
    self.sendSuccess=false
    self.canSand=true
    self.txtSize=26
    self.themeBoxLabel=nil
    self.cellHight=nil
    self.awardHeight=nil
    self.resHeight=nil
    self.resMsg=nil
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    -- local JidongbuduiVo = activityVoApi:getActivityVo("jidongbudui")
    -- if JidongbuduiVo  then
    --     if G_curPlatName()=="21" or G_curPlatName()=="androidarab" then
    --       CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/arabTurkeyImage.plist")
    --     end
        
    --     if G_curPlatName()=="13" or G_curPlatName()=="androidzhongshouyouko" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" then
    --     CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("koImage/koAcIconImage.plist")

    --     end

    --     CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acJidongbudui.plist")
    -- end
    return nc
end
--[[
playerisnotexist="目标玩家不存在,请重新输入收件人姓名。",
read_email_report_share_sucess="已成功发送战报到聊天频道",
]]


--设置对话框里的tableView
function alienMinesEmailDetailDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)

    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-36))
    self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-98))
    
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-180),nil)
    self.tv:setPosition(ccp(25,90))
    --self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-230),nil)
    --self.tv:setPosition(ccp(25,140))
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

    local emailVo=nil
    if self.eid and self.emailType then
        emailVo=alienMinesEmailVoApi:getEmailByEid(self.eid)
    end

    local report
    if self.chatReport then
        report=self.chatReport
    elseif emailVo then
        report=alienMinesEmailVoApi:getReport(emailVo.eid)
    end
    -- if report and (self.emailType==2 or self.emailType==4) then
    -- if report then
    --     if report.type==3 then
    --         local returnStr=""
    --         local allianceName=""
    --         if report.allianceName and report.allianceName~="" then
    --             allianceName=getlocal("report_content_alliance",{report.allianceName})
    --         end
    --         if report.returnType==1 then
    --             returnStr=getlocal("return_content_protected_tip",{report.name..allianceName,report.place.x,report.place.y})
    --         elseif report.returnType==2 then
    --             returnStr=getlocal("return_content_moved_tip",{report.place.x,report.place.y})
    --         elseif report.returnType==3 then
    --             returnStr=getlocal("return_content_tip",{G_getAlienIslandName(report.islandType),report.level,report.place.x,report.place.y})
    --         elseif report.returnType==4 then
    --             returnStr=getlocal("return_content_tip_1",{G_getAlienIslandName(report.islandType),report.level,report.place.x,report.place.y})
    --         elseif report.returnType==5 then
    --             returnStr=getlocal("return_content_tip_2",{report.name..allianceName,report.place.x,report.place.y})
    --         elseif report.returnType==6 then
    --             returnStr=getlocal("return_content_tip_3")
    --         elseif report.returnType==7 then
    --             returnStr=getlocal("return_content_tip_4")
    --         elseif report.returnType==8 then
    --             returnStr=getlocal("return_content_tip_5")
    --         end
    --         local msgLabel=GetTTFLabelWrap(returnStr,30,CCSizeMake(self.bgLayer:getContentSize().width-50, 30*10),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    --         msgLabel:setAnchorPoint(ccp(0,1))
    --         msgLabel:setPosition(ccp(25,self.bgLayer:getContentSize().height-110))
    --         self.bgLayer:addChild(msgLabel,2)
    --         self.target=report.name
    --     else
    --         local isAttacker=alienMinesEmailVoApi:isAttacker(report,self.chatSender)
    --         if ((isAttacker and report.isVictory==1 and report.islandType==6) or (isAttacker==false and report.isVictory~=1)) and self.chatSender==nil then
    --             if G_isShowShareBtn() then
    --                 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-230),nil)
    --                 self.tv:setPosition(ccp(25,140))
    --                 self.tv:setAnchorPoint(ccp(0,0))
    --                 self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    --             end
    --         end
    --         self.bgLayer:addChild(self.tv,2)
    --         self.tv:setMaxDisToBottomOrTop(120)
            
    --         if report.type==2 then
    --             self.target=report.defender.name
    --         elseif report.type==1 then
    --             selfId=playerVoApi:getUid()
    --             if selfId==report.defender.id then
    --                 self.target=report.attacker.name
    --             elseif selfId==report.attacker.id then
    --                 if report.islandType==6 then
    --                     self.target=report.defender.name
    --                 elseif report.islandType<6 then
    --                     if report.islandOwner>0 then
    --                         self.target=report.defender.name
    --                     end
    --                 end
    --             end
    --         end
    --     end
    -- else
    --     local rect = CCRect(0, 0, 50, 50);
    --     local capInSet = CCRect(20, 20, 10, 10);
    --     local function touch1(hd,fn,idx)

    --     end
    --     local headSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch1)
    --     headSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, 120))
    --     headSprie:ignoreAnchorPointForPosition(false)
    --     headSprie:setAnchorPoint(ccp(0,0))
    --     headSprie:setIsSallow(false)
    --     headSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    --     headSprie:setPosition(ccp(20, self.bgLayer:getContentSize().height-215))
    --     self.bgLayer:addChild(headSprie,1)
        
    --     local function touch2(hd,fn,idx)
    --         --if self.tv:getIsScrolled()==false and self.textField then
    --         --if self.tv:getIsScrolled()==false then
    --             PlayEffect(audioCfg.mouseClick)
    --             --self.textField:attachWithIME()
    --             if self.eid and (self.emailType==1 or self.emailType==3) then
    --             else
    --                 if self.editBox then
    --                     self.editBox:setVisible(true)
    --                     self.editBox:setText(textValue)
    --                 end
    --             end
    --             --[[
    --             if ifNotShowBoxBg then
    --                 textLabel:setVisible(false)
    --             end
    --             ]]
    --         --end
    --     end
    --     local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,touch2)
    --     backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, self.bgLayer:getContentSize().height-285))
    --     backSprie:ignoreAnchorPointForPosition(false)
    --     backSprie:setAnchorPoint(ccp(0,0))
    --     backSprie:setIsSallow(false)
    --     backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    --     backSprie:setPosition(ccp(20, 75))
    --     self.bgLayer:addChild(backSprie,1)
        
    --     if self.eid==nil then
    --     --输入框--------------------------------
    --         local textLabel=GetTTFLabelWrap("",30,CCSizeMake(backSprie:getContentSize().width-20,backSprie:getContentSize().height-20),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    --     textLabel:setAnchorPoint(ccp(0,1))
    --     textLabel:setPosition(ccp(10,backSprie:getContentSize().height-10))
    --     backSprie:addChild(textLabel,2)

    --     self.textValue=textLabel:getString()
    --     if self.textValue==nil then
    --         self.textValue=""
    --     end
    --     local function tthandler()
    
    --     end
    --     local function callBackHandler(fn,eB,str,type)
    --         --if type==0 then  --开始输入
    --             --eB:setText(textValue)
    --         if type==1 then  --检测文本内容变化
    --             if str==nil then
    --                 self.textValue=""
    --             else
    --                 self.textValue=str
    --                 if changeCallback then
    --                     local txt=changeCallback(fn,eB,str,type)
    --                     if txt then
    --                         self.textValue=txt
    --                         eB:setText(self.textValue)
    --                     end
    --                 end
    --             end
    --             textLabel:setString(self.textValue)
    --         elseif type==2 then --检测文本输入结束
    --             eB:setVisible(false)
    --         end
    --     end
        
    --     local winSize=CCEGLView:sharedOpenGLView():getFrameSize()
    --     local xScale=winSize.width/640
    --     local yScale=winSize.height/960
    --     local size=CCSizeMake(backSprie:getContentSize().width,50)
    --     local xBox=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler)
    --     self.editBox=CCEditBox:createForLua(size,xBox,nil,nil,callBackHandler)
    --     self.editBox:setFont(textLabel.getFontName(textLabel),yScale*textLabel.getFontSize(textLabel)/2)
    --     self.editBox:setMaxLength(300)
    --     self.editBox:setText(self.textValue)
    --     self.editBox:setAnchorPoint(ccp(0,0))
    --     self.editBox:setPosition(ccp(0,220))

    --     --self.editBox:setInputFlag(CCEditBox.kEditBoxInputFlagInitialCapsSentence)
    --     self.editBox:setInputMode(CCEditBox.kEditBoxInputModeSingleLine)

    --     self.editBox:setVisible(false)
    --     backSprie:addChild(self.editBox,3)


    --     ----------------------------------
    --     end


    --     local function showMailList()
    --         require "luascript/script/game/scene/gamedialog/chatDialog/mailListDialog"
    --         local vrd=mailListDialog:new()
    --         local vd = vrd:init(2,self,self.layerNum+1)
    --     end
    --     local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",showMailList,nil,"",25)
    --     local okBtn=CCMenu:createWithItem(okItem)
    --     okBtn:setTouchPriority(-(self.layerNum-1)*20-2)
    --     okBtn:setPosition(ccp(60,85))
    --     headSprie:addChild(okBtn)
    --     okItem:setScale(0.6)
        
    --     local targetLabel=GetTTFLabelWrap(getlocal("email_receiver"),25,CCSizeMake(110,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    --     if emailVo and self.emailType==1 then
    --         targetLabel=GetTTFLabelWrap(getlocal("email_sender"),25,CCSizeMake(110,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    --     end
    --     targetLabel:setPosition(getCenterPoint(okItem))
    --     okItem:addChild(targetLabel,2)
        
        
    --     local themeLabel=GetTTFLabel(getlocal("email_theme"),25)
    --     themeLabel:setPosition(60,35)
    --     headSprie:addChild(themeLabel,2)
        
    --     local function tthandler()
    --     end
    --     if self.eid==nil then
    --         local function callBackTargetHandler(fn,eB,str)
    --             if str==nil then
    --                 self.target=""
    --                 do return end
    --             end
    --             self.target=str
    --         end
    --         local editTargetBox=LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10,10,5,5),tthandler)
    --         editTargetBox:setContentSize(CCSizeMake(headSprie:getContentSize().width/4*3,50))
    --         editTargetBox:setIsSallow(false)
    --         editTargetBox:setTouchPriority(-(self.layerNum-1)*20-4)
    --         editTargetBox:setPosition(ccp(headSprie:getContentSize().width/2+40,85))
    --         self.targetBoxLabel=GetTTFLabel("",25)
    --         self.targetBoxLabel:setAnchorPoint(ccp(0,0.5))
    --         self.targetBoxLabel:setPosition(ccp(10,editTargetBox:getContentSize().height/2))
    --         if self.target then
    --             self.targetBoxLabel:setString(self.target)
    --         end
    --         local customEditBox=customEditBox:new()
    --         local length=12
    --         local function clickCanWriteTarget()
    --             if self.isAllianceEmail then
    --                 return true --军团邮件收件人不能编辑
    --             end
    --             return false
    --         end
    --         customEditBox:init(editTargetBox,self.targetBoxLabel,"mail_input_bg.png",nil,-(self.layerNum-1)*20-4,length,callBackTargetHandler,nil,nil,nil,clickCanWriteTarget)
    --         headSprie:addChild(editTargetBox,2)
            
            
    --         local function callBackThemeHandler(fn,eB,str)
    --             if str==nil then
    --                 self.theme=""
    --                 do return end
    --             end
    --             self.theme=str
    --         end
    --         local editThemeBox=LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10,10,5,5),tthandler)
    --         editThemeBox:setContentSize(CCSizeMake(headSprie:getContentSize().width/4*3,50))
    --         editThemeBox:setIsSallow(false)
    --         editThemeBox:setTouchPriority(-(self.layerNum-1)*20-4)
    --         editThemeBox:setPosition(ccp(headSprie:getContentSize().width/2+40,35))
    --         self.themeBoxLabel=GetTTFLabel("",25)
    --         self.themeBoxLabel:setAnchorPoint(ccp(0,0.5))
    --         self.themeBoxLabel:setPosition(ccp(10,editThemeBox:getContentSize().height/2))
    --         if self.theme then
    --             self.theme=getlocal("email_receiver_reply")..self.theme
    --             self.themeBoxLabel:setString(self.theme)
    --         end
    --         local customEditBox=customEditBox:new()
    --         local length=12
    --         customEditBox:init(editThemeBox,self.themeBoxLabel,"mail_input_bg.png",nil,-(self.layerNum-1)*20-4,length,callBackThemeHandler,nil,nil)
    --         headSprie:addChild(editThemeBox,2)
            
    --         local bHeight=self.bgLayer:getContentSize().height-220
    --         backSprie:setTouchPriority(-(self.layerNum-1)*20-4)
    --     else
    --         if self.eid and (self.emailType==1 or self.emailType==3) then
    --             if self.emailType==1 and emailVo and emailVo.gift and emailVo.gift>=1 then
    --                 local hSpace=260
    --                 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-300-hSpace),nil)
    --                 self.tv:setPosition(ccp(25,82+hSpace))


    --                 local capInSet = CCRect(20, 20, 10, 10)
    --                 local function touch(hd,fn,idx)

    --                 end
    --                 local headBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,touch)
    --                 headBg:setContentSize(CCSizeMake(backSprie:getContentSize().width,50))
    --                 headBg:ignoreAnchorPointForPosition(false)
    --                 headBg:setAnchorPoint(ccp(0,1))
    --                 headBg:setIsSallow(false)
    --                 headBg:setTouchPriority(-(self.layerNum-1)*20-1)
    --                 headBg:setPosition(ccp(0,hSpace))
    --                 backSprie:addChild(headBg,3)

    --                 local giftLb=GetTTFLabel(getlocal("gift_box"),25)
    --                 giftLb:setAnchorPoint(ccp(0,0.5))
    --                 giftLb:setPosition(ccp(10,headBg:getContentSize().height/2))
    --                 headBg:addChild(giftLb)

    --                 local iconSize=100
    --                 local space=15
    --                 local rewardTb={}
    --                 local awardTb={}
    --                 if emailVo.reward then
    --                     for k,v in pairs(emailVo.reward) do
    --                         local reType=k
    --                         local iconNum=SizeOfTable(v)
    --                         for m,n in pairs(v) do
    --                             local item={}
    --                             local isFlick=0
    --                             if emailVo.flick and emailVo.flick[m] and tonumber(emailVo.flick[m]) and tonumber(emailVo.flick[m])>0 then
    --                                 isFlick=1
    --                                 -- for i,j in pairs(emailVo.flick) do
    --                                 --  if m==j then
    --                                 --      isFlick=1
    --                                 --  end
    --                                 -- end
    --                             end
    --                             if n and type(n)=="table" then
    --                                 for i,j in pairs(n) do
    --                                     -- if i=="f" and j==1 then
    --                                     --  isFlick=1
    --                                     -- else
    --                                         local name,pic,desc,id,index,eType,equipId=getItem(i,reType)
    --                                         item={name=name,num=j,pic=pic,desc=desc,id=id,type=reType,index=index,key=i,eType=eType,equipId=equipId}
    --                                         table.insert(awardTb,item)
    --                                     -- end
    --                                 end
    --                                 table.insert(rewardTb,{item=item,isFlick=isFlick})
    --                             else
    --                                 local name,pic,desc,id,index,eType,equipId=getItem(m,reType)
    --                                 item={name=name,num=j,pic=pic,desc=desc,id=id,type=reType,index=index,key=i,eType=eType,equipId=equipId}
    --                                 table.insert(awardTb,item)
    --                             end
    --                         end
    --                     end
                        
    --                     -- local rewardTab=FormatItem(emailVo.reward)
    --                     local iconNum=SizeOfTable(rewardTb)
    --                     for k,v in pairs(rewardTb) do
    --                         local item=v.item
    --                         local isFlick=v.isFlick
    --                         local canClick=true
    --                         if item.type=="u" then
    --                             canClick=false
    --                         end
    --                         local icon,iconScale=G_getItemIcon(item,iconSize,canClick,self.layerNum+1)
    --                         local firstPosX=backSprie:getContentSize().width/2-(iconSize+space)/2*(iconNum-1)
    --                         icon:setPosition(ccp(firstPosX+(iconSize+space)*(k-1),150))
    --                         icon:setTouchPriority(-(self.layerNum-1)*20-4)
    --                         backSprie:addChild(icon,3)

    --                         if item.type=="u" then
    --                             local numLb=GetTTFLabel("x"..FormatNumber(item.num),25)
    --                             numLb:setAnchorPoint(ccp(1,0))
    --                             numLb:setPosition(ccp(icon:getContentSize().width*iconScale-5,5))
    --                             icon:addChild(numLb,1)
    --                         end

    --                         if isFlick and isFlick==1 then
    --                             G_addRectFlicker(icon,1.4*1/iconScale,1.4*1/iconScale)
    --                         end
    --                     end
    --                 end

    --                 local function rewardHandler()
    --                     if G_checkClickEnable()==false then
    --                         do
    --                             return
    --                         end
    --                     else
    --                         base.setWaitTime=G_getCurDeviceMillTime()
    --                     end
    --                     PlayEffect(audioCfg.mouseClick)
    --                     if emailVo.isReward~=1 then
    --                         local function rewardCallback(fn,data)
    --                             local ret,sData=base:checkServerData(data)
    --                             if ret==true then
    --                                 if awardTb and SizeOfTable(awardTb)>0 then
    --                                     for k,v in pairs(awardTb) do
    --                                         G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num), nil, true)
    --                                     end
    --                                     G_showRewardTip(awardTb, true)
    --                                 end

    --                                 alienMinesEmailVoApi:setIsReward(emailVo.eid)
    --                                 if self.rewardBtn then
    --                                     self.rewardBtn:setEnabled(false)
    --                                     local lb=tolua.cast(self.rewardBtn:getChildByTag(12),"CCLabelTTF")
    --                                     lb:setString(getlocal("activity_hadReward"))
    --                                 end
    --                             end
    --                         end
    --                         local mid=emailVo.eid
    --                         socketHelper:mailReward(mid,rewardCallback)
    --                     end
    --                 end
    --                 local itemStr=getlocal("daily_scene_get")
    --                 if emailVo.isReward==1 then
    --                     itemStr=getlocal("activity_hadReward")
    --                 end
    --                 self.rewardBtn=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",rewardHandler,11,itemStr,25,12)
    --                 local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
    --                 rewardMenu:setAnchorPoint(ccp(0.5,0.5))
    --                 rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    --                 rewardMenu:setPosition(ccp(backSprie:getContentSize().width/2,50))
    --                 backSprie:addChild(rewardMenu,3)
    --                 if emailVo.isReward==1 then
    --                     self.rewardBtn:setEnabled(false)
    --                 end

    --             else
    --                 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-300),nil)
    --                 self.tv:setPosition(ccp(25,82))
    --             end
    --             self.tv:setAnchorPoint(ccp(0,0))
    --             self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)

    --             self.bgLayer:addChild(self.tv,2)
    --             self.tv:setMaxDisToBottomOrTop(120)
    --         end

    --         local isShowTip=false
    --         if self.emailType==1 and (tostring(emailVo.sender)~="0" and tostring(emailVo.sender)~="1" and tostring(emailVo.sender)~="2") and allianceVoApi:isHasAlliance()==true and allianceMemberVoApi:getMemberByName(emailVo.from)==nil then
    --             isShowTip=true
    --         end
    --         local function tipClickHandler(tag,object)
    --             if isShowTip==true then
    --                 if G_checkClickEnable()==false then
    --                     do
    --                         return
    --                     end
    --                 end
    --                 PlayEffect(audioCfg.mouseClick)

    --                 -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("email_not_same_alliance"),30)
    --                 local tabStr={}
    --                 local tabColor ={}
    --                 local td=smallDialog:new()
    --                 tabStr = {"\n",getlocal("email_not_same_alliance"),"\n"}
    --                 local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,G_ColorRed,nil})
    --                 sceneGame:addChild(dialog,self.layerNum+1)
    --             end
    --         end
    --         local targetSprie=LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10, 10, 5, 5),tipClickHandler)
    --         --targetSprie:setAnchorPoint(ccp(0,0.5))
    --         targetSprie:setContentSize(CCSize(self.bgLayer:getContentSize().width/2+10,50))
    --         targetSprie:setPosition(headSprie:getContentSize().width/2-25,85)
    --         targetSprie:setTouchPriority(-(self.layerNum-1)*20-4)
    --         targetSprie:setIsSallow(false)
    --         headSprie:addChild(targetSprie)

    --         local noticeSp
    --         local spSize=50
    --         if emailVo.isAllianceEmail and emailVo.isAllianceEmail==1 then
    --             noticeSp=CCSprite:createWithSpriteFrameName("Icon_warn.png")
    --             noticeSp:setAnchorPoint(ccp(0.5,0.5))
    --             noticeSp:setScale(spSize/noticeSp:getContentSize().width)
    --             noticeSp:setPosition(ccp(headSprie:getContentSize().width/2-25-targetSprie:getContentSize().width/2+spSize/2,35))
    --             headSprie:addChild(noticeSp,3)
    --         end
        
    --         local themeSprie=LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10, 10, 5, 5),tthandler)
    --         --themeSprie:setAnchorPoint(ccp(0,0.5))
    --         if noticeSp then
    --             themeSprie:setContentSize(CCSize(self.bgLayer:getContentSize().width/2+10-spSize,50))
    --             themeSprie:setPosition(headSprie:getContentSize().width/2-25+spSize/2,35)
    --         else
    --             themeSprie:setContentSize(CCSize(self.bgLayer:getContentSize().width/2+10,50))
    --             themeSprie:setPosition(headSprie:getContentSize().width/2-25,35)
    --         end
    --         themeSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    --         themeSprie:setIsSallow(false)
    --         headSprie:addChild(themeSprie)
            
    --         local targetLabel
    --         if self.emailType==1 then
    --             targetLabel=GetTTFLabel(emailVo.from,25)
    --             self.target=emailVo.from
    --         else
    --             targetLabel=GetTTFLabel(emailVo.to,25)
    --             self.target=emailVo.to
    --         end
    --         targetLabel:setAnchorPoint(ccp(0,0.5))
    --         targetLabel:setPosition(headSprie:getContentSize().width/2-20-targetSprie:getContentSize().width/2,85)
    --         headSprie:addChild(targetLabel,2)
            
    --         local themeLbWidth=30*10
    --         local themeLbPosX=headSprie:getContentSize().width/2-20-targetSprie:getContentSize().width/2
    --         if noticeSp then
    --             themeLbWidth=themeLbWidth-spSize
    --             themeLbPosX=themeLbPosX+spSize
    --         end
    --         local themeLabel=GetTTFLabelWrap(emailVo.title,25,CCSizeMake(themeLbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    --         themeLabel:setAnchorPoint(ccp(0,0.5))
    --         themeLabel:setPosition(themeLbPosX,35)
    --         headSprie:addChild(themeLabel,2)
    --         if emailVo.title then
    --             self.theme=emailVo.title
    --         end
            
    --         local timeLabel
    --         if emailVo and emailVo.time then
    --             timeLabel=GetTTFLabel(alienMinesEmailVoApi:getTimeStr(emailVo.time),25)
    --         else
    --             timeLabel=GetTTFLabel(alienMinesEmailVoApi:getTimeStr(base.serverTime),25)
    --         end
    --         timeLabel:setPosition(headSprie:getContentSize().width-80,60)
    --         headSprie:addChild(timeLabel,2)
    --         --[[
    --         local msg=""
    --         if emailVo and emailVo.content then msg=emailVo.content end
    --         while string.find(msg,"\\n")~=nil do
    --             local startIdx,endIdx=string.find(msg,"\\n")
    --             msg=string.sub(msg,1,startIdx-1).."\n"..string.sub(msg,endIdx+1)
    --         end
    --         local contentLabel=GetTTFLabelWrap(msg,30,CCSizeMake(backSprie:getContentSize().width-20,backSprie:getContentSize().height-20),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    --         contentLabel:setAnchorPoint(ccp(0,1))
    --         contentLabel:setPosition(ccp(10,backSprie:getContentSize().height-10))
    --         backSprie:addChild(contentLabel,2)
    --         ]]

    --         --非公会成员添加tip提示
    --         if isShowTip==true then
    --             local scale=0.75
    --             local tipBtn=GetButtonItem("IconTip.png","IconTip.png","IconTip.png",tipClickHandler,11,nil,nil)
    --             tipBtn:setScale(scale)
    --             local tipMenu=CCMenu:createWithItem(tipBtn)
    --             tipMenu:setAnchorPoint(ccp(0.5,0.5))
    --             tipMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    --             local lbx,lby=targetLabel:getPosition()
    --             tipMenu:setPosition(ccp(lbx+targetLabel:getContentSize().width+tipBtn:getContentSize().width/2*scale+5,lby))
    --             headSprie:addChild(tipMenu,4)
    --         end
    --     end
    -- end
    
    local function operateHandler(tag,object)
        if G_checkClickEnable()==false then
                    do
                        return
                    end
        end
        PlayEffect(audioCfg.mouseClick)
        if tag==11 then
            --如果没有战斗
            if report.report==nil then
                --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("fight_content_result_no_play"),30)
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("fight_content_result_no_play"),true,self.layerNum+1)
            else
                local isAttacker=alienMinesEmailVoApi:isAttacker(report,self.chatSender)
                local data={data=report,isAttacker=isAttacker,isReport=true,alienBattleData={islandType=report.islandType}}
                battleScene:initData(data)
            end
        elseif tag==12 or tag==13 then
            if report then
                self:close()
                -- local isAttacker=alienMinesEmailVoApi:isAttacker(report,self.chatSender)
                local type=report.islandType
                local place=report.place
                -- if report.type==1 and isAttacker==false then
                --     if report.attackerPlace~=nil then
                --         type=6
                --         place=report.attackerPlace
                --     end
                -- end
                -- local island={type=type,x=place.x,y=place.y}

                local island=G_clone(alienMinesVoApi:getBaseVo(place.x,place.y))

                local flag
                if tag==12 then
                    flag=0
                else
                    flag=1
                end
                alienMinesVoApi:showAttackDialog(flag,island,self.layerNum+1)
                -- local td=tankAttackDialog:new(type,island,self.layerNum+1)
                -- local tbArr={getlocal("AEFFighting"),getlocal("dispatchCard"),getlocal("repair")}
                -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("AEFFighting"),true,7)
                -- sceneGame:addChild(dialog,self.layerNum+1)
            end
        -- elseif tag==13 then
        --     if report~=nil and report.islandType~=6 and report.islandOwner==0 then
        --         do return end
        --     end
        --     local lyNum=5
        --     local td=alienMinesEmailDetailDialog:new(lyNum,nil,nil,self.target,self.theme)
        --     local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("email_write"),false,lyNum)
        --     sceneGame:addChild(dialog,lyNum)
        --     self:close(false)
        -- elseif tag==14 then
        --     local function deleteEmailCallback(fn,data)
        --         --local retTb=OBJDEF:decode(data)
        --         if base:checkServerData(data)==true then
        --             alienMinesEmailVoApi:deleteByEid(self.emailType,self.eid)
        --             self.sendSuccess=true
        --             base:tick()
        --             self:close(false)
        --         end
        --     end
        --     if self.sendSuccess==false then
        --         if emailVo and emailVo.gift and emailVo.gift>=1 and emailVo.isReward and emailVo.isReward~=1 then
        --             local function onConfirm()
        --                 socketHelper:deleteEmail(self.emailType,self.eid,deleteEmailCallback)
        --             end
        --             smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("delete_confim"),nil,self.layerNum+1)
        --         else
        --             socketHelper:deleteEmail(self.emailType,self.eid,deleteEmailCallback)
        --         end
        --     end
        -- elseif tag==15 then
        --     local name=self.target
        --     local content=""
        --     --[[
        --     if self.textField then
        --         content=self.textField:getString()
        --     end
        --     ]]
        --     if self.textValue then
        --         content=self.textValue
        --     end
        --     local theme=""
        --     -- if self.theme then
        --     --  theme=self.theme
        --     -- end
        --     if self.themeBoxLabel then
        --         theme=self.themeBoxLabel:getString()
        --     end
        --     local hasEmjoy=G_checkEmjoy(theme)
        --     if hasEmjoy==false then
        --         do return end
        --     end
        --     local selfName=playerVoApi:getPlayerName()
        --     if self.isAllianceEmail then
        --         if content==nil or content=="" then
        --             smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("email_Content_null"),true,self.layerNum+1)
        --         else
        --             local function sendAllianceEmailCallback(fn,data)
        --                 local success,mailData=base:checkServerData(data)
        --                 if success==true and mailData~=nil then
        --                     local eid=mailData.data.eid
        --                     local ts=mailData.ts
        --                     local email={{eid=eid,sender=playerVoApi:getUid(),from=selfName,to=name,title=theme,content=content,ts=ts,isRead=true,gift=-1}}
        --                     alienMinesEmailVoApi:addEmail(3,email)
        --                     allianceVoApi:setSendEmailNum()
        --                     self.sendSuccess=true
        --                     base:tick()
        --                     self:close(false)
        --                     smallDialog:showTipsDialog("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_scene_email_send_success"),30)
        --                 end
        --             end
        --             if self.sendSuccess==false then
        --                 if allianceVoApi:isHasAlliance() then
        --                     local alliance=allianceVoApi:getSelfAlliance()
        --                     socketHelper:allianceMail(alliance.aid,theme,content,sendAllianceEmailCallback)
        --                 end
        --             end
        --         end
        --     else
        --         if name==nil or name=="" then
        --             --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("email_receiver_null"),30)
        --             smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("email_receiver_null"),true,self.layerNum+1)
        --         elseif content==nil or content=="" then
        --             --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("email_Content_null"),30)
        --             smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("email_Content_null"),true,self.layerNum+1)
        --         elseif name==selfName then
        --             --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("email_cant_send_self"),30)
        --             smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("email_cant_send_self"),true,self.layerNum+1)
        --         else
        --             local function sendEmailCallback(fn,data)
        --                 local success,mailData=base:checkServerData(data)
        --                 if success==true and mailData~=nil then
        --                     local eid=mailData.data.eid
        --                     local ts=mailData.ts
        --                     local email={{eid=eid,sender=playerVoApi:getUid(),from=selfName,to=name,title=theme,content=content,ts=ts,isRead=true}}
        --                     alienMinesEmailVoApi:addEmail(3,email)
        --                     self.sendSuccess=true
        --                     base:tick()
        --                     self:close(false)
        --                     smallDialog:showTipsDialog("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("email_send_sucess"),30)
        --                 end
        --             end
        --             if self.sendSuccess==false then
        --                 local data={name=name,title=theme,content=content,type=1}
        --                 socketHelper:sendEmail(data,sendEmailCallback)
        --             end
        --         end 
        --     end               
        -- elseif tag==16 then
        --     --检测是否被禁言
        --     if chatVoApi:canChat(self.layerNum)==false then
        --         do return end
        --     end
            
        --     local playerLv=playerVoApi:getPlayerLevel()
        --     local timeInterval=playerCfg.chatLimitCfg[playerLv] or 0
        --     local diffTime=0
        --     if base.lastSendTime then
        --         diffTime=base.serverTime-base.lastSendTime
        --     end
        --     --[[
        --     if diffTime>0 and diffTime<timeInterval then
        --         --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("time_limit_prompt",{timeInterval-diffTime}),30)
        --         smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("time_limit_prompt",{timeInterval-diffTime}),true,self.layerNum+1)
        --         do return end
        --     end
        --     ]]
        --     if diffTime>=timeInterval then
        --         self.canSand=true
        --     end
        --     if self.canSand==nil or self.canSand==false then
        --         smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("time_limit_prompt",{timeInterval-diffTime}),true,self.layerNum+1)
        --         do return end
        --     end
        --     self.canSand=false
            
        --     local sender=playerVoApi:getUid()
        --     local chatContent=emailVo.title
        --     if chatContent==nil then
        --         chatContent=""
        --     end
        --     --如果有联盟，选择联盟还是世界；没有则世界发送到世界 1为世界
        --     --if report.report~=nil then
        --         local hasAlliance=allianceVoApi:isHasAlliance()
        --         local reportData={}
        --         for k,v in pairs(report) do
        --             if k=="resource" then
        --                 local resData={u={}}
        --                 if v and SizeOfTable(v)>0 then
        --                     for m,n in pairs(v) do
        --                         if resData.u[m]==nil then
        --                             resData.u[m]={}
        --                         end
        --                         resData.u[m][n.key]=n.num
        --                     end
        --                 end
        --                 reportData[k]=resData
        --             elseif k=="award" then
        --                 reportData[k]={}
        --                 if report.report and report.report.r and type(report.report.r)=="table" then
        --                     reportData[k]=report.report.r
        --                 end
        --             elseif k=="lostShip" then
        --                 local defLost={o={}}
        --                 local attLost={o={}}
        --                 if v and v.defenderLost then
        --                     for m,n in pairs(v.defenderLost) do
        --                         if defLost.o[m]==nil then
        --                             defLost.o[m]={}
        --                         end
        --                         defLost.o[m][n.key]=n.num
        --                     end
        --                 end
        --                 if v and v.attackerLost then
        --                     for m,n in pairs(v.attackerLost) do
        --                         attLost.o[m]={}
        --                         if attLost.o[m]==nil then
        --                             attLost.o[m]={}
        --                         end
        --                         attLost.o[m][n.key]=n.num
        --                     end
        --                 end
        --                 reportData[k]={}
        --                 reportData[k]["defenderLost"]=defLost
        --                 reportData[k]["attackerLost"]=attLost
        --             else
        --                 reportData[k]=v
        --             end
        --         end
        --         if hasAlliance==false then
        --             base.lastSendTime=base.serverTime
        --             --local chatContent=alienMinesEmailVoApi:getAttackTitle(emailVo.eid)
                    
        --             local senderName=playerVoApi:getPlayerName()
        --             local level=playerVoApi:getPlayerLevel()
        --             local rank=playerVoApi:getRank()
        --             local language=G_getCurChoseLanguage()
        --             local params={subType=1,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=reportData,ts=base.serverTime,vip=playerVoApi:getVipLevel(),language=language,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime()}
        --             --chatVoApi:addChat(1,sender,senderName,0,"",params)
        --             chatVoApi:sendChatMessage(1,sender,senderName,0,"",params)
        --             --mainUI:setLastChat()
        --             smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
        --         else
        --             local function sendReportHandle(tag,object)
        --                 base.lastSendTime=base.serverTime
        --                 local channelType=tag or 1
                        
        --                 local senderName=playerVoApi:getPlayerName()
        --                 local level=playerVoApi:getPlayerLevel()
        --                 local rank=playerVoApi:getRank()
        --                 local allianceName
        --                 local allianceRole
        --                 if allianceVoApi:isHasAlliance() then
        --                     local allianceVo=allianceVoApi:getSelfAlliance()
        --                     allianceName=allianceVo.name
        --                     allianceRole=allianceVo.role
        --                 end
        --                 local language=G_getCurChoseLanguage()
        --                 local params={subType=channelType,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=reportData,ts=base.serverTime,allianceName=allianceName,allianceRole=allianceRole,vip=playerVoApi:getVipLevel(),language=language,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime()}
        --                 local aid=playerVoApi:getPlayerAid()
        --                 if channelType==1 then
        --                     chatVoApi:sendChatMessage(1,sender,senderName,0,"",params)
        --                     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
        --                 elseif aid then
        --                     chatVoApi:sendChatMessage(aid+1,sender,senderName,0,"",params)
        --                     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
        --                 end
        --             end
        --             allianceSmallDialog:selectChannelDialog("PanelHeaderPopup.png",CCSizeMake(450,350),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,sendReportHandle)
        --         end
        --         --end
        -- elseif tag==17 then
        --     local function sendFeedCallback()
        --         local function feedsawardHandler(fn,data)
        --             if base:checkServerData(data)==true then
        --                 if G_curPlatName()=="12" or G_curPlatName()=="androidzhongshouyouru" or G_curPlatName()=="0" then
        --                     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shareSuccess"),28)
        --                 end
        --             end
        --         end
        --         socketHelper:feedsaward(1,feedsawardHandler)
        --     end
        --     G_sendFeed(2,sendFeedCallback)
        end
    end
    
    local scale=0.75
    self.replayBtn=GetButtonItem("letterBtnPlay.png","letterBtnPlay_Down.png","letterBtnPlay_Down.png",operateHandler,11,nil,nil)
    self.replayBtn:setScaleX(scale)
    self.replayBtn:setScaleY(scale)
    local replaySpriteMenu=CCMenu:createWithItem(self.replayBtn)
    replaySpriteMenu:setAnchorPoint(ccp(0.5,0))
    replaySpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    --replaySpriteMenu:setScaleX(scale)
    --replaySpriteMenu:setScaleY(scale)
    
    -- self.attackBtn=GetButtonItem("IconAttackBtnLarge.png","IconAttackBtnLarge_Down.png","IconAttackBtnLarge_Down.png",operateHandler,12,nil,nil)
    self.attackBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",operateHandler,12,getlocal("alienMines_plunder"),25)
    self.attackBtn:setScaleX(scale)
    self.attackBtn:setScaleY(scale)
    local attackSpriteMenu=CCMenu:createWithItem(self.attackBtn)
    attackSpriteMenu:setAnchorPoint(ccp(0.5,0))
    attackSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    --attackSpriteMenu:setScaleX(scale)
    --attackSpriteMenu:setScaleY(scale)

    self.occupyBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",operateHandler,13,getlocal("alienMines_Occupied"),25)
    self.occupyBtn:setScaleX(scale)
    self.occupyBtn:setScaleY(scale)
    local occupySpriteMenu=CCMenu:createWithItem(self.occupyBtn)
    occupySpriteMenu:setAnchorPoint(ccp(0.5,0))
    occupySpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    --occupySpriteMenu:setScaleX(scale)
    --occupySpriteMenu:setScaleY(scale)
    
    -- self.writeBtn=GetButtonItem("letterBtnWrite.png","letterBtnWrite_Down.png","letterBtnWrite_Down.png",operateHandler,13,nil,nil)
    -- self.writeBtn:setScaleX(scale)
    -- self.writeBtn:setScaleY(scale)
    -- local writeSpriteMenu=CCMenu:createWithItem(self.writeBtn)
    -- writeSpriteMenu:setAnchorPoint(ccp(0.5,0))
    -- writeSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    -- --writeSpriteMenu:setScaleX(scale)
    -- --writeSpriteMenu:setScaleY(scale)
    
    -- self.deleteBtn=GetButtonItem("letterBtnDelete.png","letterBtnDelete_Down.png","letterBtnDelete_Down.png",operateHandler,14,nil,nil)
    -- self.deleteBtn:setScaleX(scale)
    -- self.deleteBtn:setScaleY(scale)
    -- local deleteSpriteMenu=CCMenu:createWithItem(self.deleteBtn)
    -- deleteSpriteMenu:setAnchorPoint(ccp(0.5,0))
    -- deleteSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    -- --deleteSpriteMenu:setScaleX(scale)
    -- --deleteSpriteMenu:setScaleY(scale)
    
    -- self.sendBtn=GetButtonItem("letterBtnSend.png","letterBtnSend_Down.png","letterBtnSend_Down.png",operateHandler,15,nil,nil)
    -- self.sendBtn:setScaleX(scale)
    -- self.sendBtn:setScaleY(scale)
    -- local sendSpriteMenu=CCMenu:createWithItem(self.sendBtn)
    -- sendSpriteMenu:setAnchorPoint(ccp(0.5,0))
    -- sendSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    -- --sendSpriteMenu:setScaleX(scale)
    -- --sendSpriteMenu:setScaleY(scale)
    
    -- --self.feedBtn=GetButtonItem("letterBtnSend.png","letterBtnSend_Down.png","letterBtnSend_Down.png",operateHandler,17,nil,nil)
    -- local btnTextSize = 30
    -- if G_getCurChoseLanguage()=="pt" then
    --     btnTextSize = 25
    -- end
    -- self.feedBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",operateHandler,17,getlocal("feedBtn"),btnTextSize)
    -- self.feedBtn:setScaleX(scale)
    -- self.feedBtn:setScaleY(scale)
    -- local feedSpriteMenu=CCMenu:createWithItem(self.feedBtn)
    -- feedSpriteMenu:setAnchorPoint(ccp(0.5,0))
    -- feedSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    -- --feedSpriteMenu:setScaleX(scale)
    -- --feedSpriteMenu:setScaleY(scale)
    
    local height=45
    local posXScale=self.bgLayer:getContentSize().width
    if (self.emailType==2 or self.emailType==4) and report~=nil then
        if report.type==1 then
            local isAttacker=alienMinesEmailVoApi:isAttacker(report,self.chatSender)
            if isAttacker==true then
                self.bgLayer:addChild(replaySpriteMenu,2)
                -- self.bgLayer:addChild(writeSpriteMenu,2)
                -- self.bgLayer:addChild(deleteSpriteMenu,2)
                -- self.bgLayer:addChild(sendSpriteMenu,2)
                replaySpriteMenu:setPosition(ccp(posXScale/2,height))
                -- replaySpriteMenu:setPosition(ccp(posXScale/5*1,height))
                -- writeSpriteMenu:setPosition(ccp(posXScale/5*2,height))
                -- deleteSpriteMenu:setPosition(ccp(posXScale/5*3,height))
                -- sendSpriteMenu:setPosition(ccp(posXScale/5*4,height))
                -- self.sendBtn:setTag(16)
                --[[
                self.bgLayer:addChild(replaySpriteMenu,2)
                self.bgLayer:addChild(writeSpriteMenu,2)
                self.bgLayer:addChild(deleteSpriteMenu,2)
                replaySpriteMenu:setPosition(ccp(posXScale/4*1,height))
                writeSpriteMenu:setPosition(ccp(posXScale/4*2,height))
                deleteSpriteMenu:setPosition(ccp(posXScale/4*3,height))
                ]]
                if report.report==nil then
                    self.replayBtn:setEnabled(false)
                end
                -- if report.islandType~=6 and report.islandOwner==0 then
                --     self.writeBtn:setEnabled(false)
                -- end
                -- if report.isVictory==1 and self.chatSender==nil and report.islandType==6 then
                --     if G_isShowShareBtn() then
                --         local feedDescLable = GetTTFLabelWrap(getlocal("feedDesc"),25,CCSizeMake(25*16,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                --         feedDescLable:setAnchorPoint(ccp(0,0))
                --         feedDescLable:setPosition(ccp(posXScale/5*1-self.replayBtn:getContentSize().width/2,self.feedBtn:getContentSize().height+15))
                --         self.bgLayer:addChild(feedDescLable,2)
                        
                --         self.bgLayer:addChild(feedSpriteMenu,2)
                --         feedSpriteMenu:setPosition(ccp(posXScale/5*4,height+self.sendBtn:getContentSize().height-15))
                --     end
                -- end
            else
                self.bgLayer:addChild(replaySpriteMenu,2)
                -- self.bgLayer:addChild(attackSpriteMenu,2)
                -- self.bgLayer:addChild(writeSpriteMenu,2)
                -- self.bgLayer:addChild(deleteSpriteMenu,2)
                -- self.bgLayer:addChild(sendSpriteMenu,2)
                replaySpriteMenu:setPosition(ccp(posXScale/2,height))
                -- replaySpriteMenu:setPosition(ccp(posXScale/6*1-30,height))
                -- attackSpriteMenu:setPosition(ccp(posXScale/6*2-15,height))
                -- writeSpriteMenu:setPosition(ccp(posXScale/6*3,height))
                -- deleteSpriteMenu:setPosition(ccp(posXScale/6*4+15,height))
                -- sendSpriteMenu:setPosition(ccp(posXScale/6*5+30,height))
                -- self.sendBtn:setTag(16)
                --[[
                self.bgLayer:addChild(replaySpriteMenu,2)
                self.bgLayer:addChild(attackSpriteMenu,2)
                self.bgLayer:addChild(writeSpriteMenu,2)
                self.bgLayer:addChild(deleteSpriteMenu,2)
                replaySpriteMenu:setPosition(ccp(posXScale/5*1-30,height))
                attackSpriteMenu:setPosition(ccp(posXScale/5*2-15,height))
                writeSpriteMenu:setPosition(ccp(posXScale/5*3,height))
                deleteSpriteMenu:setPosition(ccp(posXScale/5*4+15,height))
                ]]
                if report.report==nil then
                    self.replayBtn:setEnabled(false)
                end
                -- if report.isVictory~=1 and self.chatSender==nil then
                --     if G_isShowShareBtn() then
                --         local feedDescLable = GetTTFLabelWrap(getlocal("feedDesc"),25,CCSizeMake(25*16,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                --         feedDescLable:setAnchorPoint(ccp(0,0))
                --         feedDescLable:setPosition(ccp(posXScale/6*1-30,self.feedBtn:getContentSize().height+15))
                --         self.bgLayer:addChild(feedDescLable,2)
                        
                --         self.bgLayer:addChild(feedSpriteMenu,2)
                --         feedSpriteMenu:setPosition(ccp(posXScale/6*5+30,height+self.sendBtn:getContentSize().height-15))
                --     end
                -- end
            end
        elseif report.type==2 then
            attackSpriteMenu:setAnchorPoint(ccp(0.5,0))
            occupySpriteMenu:setAnchorPoint(ccp(0.5,0))

            self.bgLayer:addChild(attackSpriteMenu,2)
            self.bgLayer:addChild(occupySpriteMenu,2)
            -- self.bgLayer:addChild(deleteSpriteMenu,2)
            attackSpriteMenu:setPosition(ccp(posXScale/3*1,height))
            occupySpriteMenu:setPosition(ccp(posXScale/3*2,height))
            -- deleteSpriteMenu:setPosition(ccp(posXScale/3*2,height))

            if report.allianceName and allianceVoApi:isSameAlliance(report.allianceName) then
                self.attackBtn:setEnabled(false)
                self.occupyBtn:setEnabled(false)
            elseif report.islandOwner==0 then
                self.attackBtn:setEnabled(false)
            end
        elseif report.type==3 then
            -- self.bgLayer:addChild(deleteSpriteMenu,2)
            -- deleteSpriteMenu:setPosition(ccp(posXScale/2,height))
        end
        -- if emailVo and emailVo.sender==1 and emailVo.sender==1 then
        --  self.writeBtn:setEnabled(false)
        -- end
    -- elseif emailVo==nil then
    --     self.bgLayer:addChild(sendSpriteMenu,2)
    --     sendSpriteMenu:setPosition(ccp(posXScale/2,height))
    -- elseif self.emailType==1 then
    --     self.bgLayer:addChild(writeSpriteMenu,2)
    --     self.bgLayer:addChild(deleteSpriteMenu,2)
    --     writeSpriteMenu:setPosition(ccp(posXScale/3*1,height))
    --     deleteSpriteMenu:setPosition(ccp(posXScale/3*2,height))
    --     if emailVo and (emailVo.sender==1 or emailVo.sender==0) then
    --         self.writeBtn:setEnabled(false)
    --     end
    -- elseif self.emailType==3 then
    --     self.bgLayer:addChild(deleteSpriteMenu,2)
    --     deleteSpriteMenu:setPosition(ccp(posXScale/2,height))
    end
    
    -- if self.chatSender~=nil then
    --     self.attackBtn:setEnabled(false)
    --     self.writeBtn:setEnabled(false)
    --     self.deleteBtn:setEnabled(false)
    --     self.sendBtn:setEnabled(false)
    -- end
end

function alienMinesEmailDetailDialog:getReportAccessoryhight(report)
    if self.repAcceHeight==nil then
        local function cellClick()
        end
        local backSprie5 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
        backSprie5:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))

        local accessory=report.accessory or {}
        local attAccData={}
        local defAccData={}
        local isAttacker=alienMinesEmailVoApi:isAttacker(report,self.chatSender)
        if isAttacker==true then
            attAccData=accessory[1] or {}
            defAccData=accessory[2] or {}
        else
            attAccData=accessory[2] or {}
            defAccData=accessory[1] or {}
        end
        local attScore=attAccData[1] or 0
        local defScore=defAccData[1] or 0
        local attTab=attAccData[2] or {0,0,0}
        local defTab=defAccData[2] or {0,0,0}

        for i=1,2 do
            local content={}
            content[i]={}

            local campStr=""
            local scoreStr=getlocal("report_accessory_score")
            local score=0

            if i==1 then
                campStr=getlocal("report_accessory_owner")
                score=attScore

            elseif i==2 then
                campStr=getlocal("report_accessory_enemy")
                score=defScore

            end

            table.insert(content[i],{campStr,G_ColorGreen})
            table.insert(content[i],{scoreStr,G_ColorGreen})
            table.insert(content[i],{score,G_ColorWhite})

            local contentLbHight=60
            for k,v in pairs(content[i]) do
                local contentMsg=v
                local message=""
                local color
                if type(contentMsg)=="table" then
                    message=contentMsg[1]
                else
                    message=contentMsg
                end
                local contentLb
                contentLb=GetTTFLabelWrap(message,28,CCSizeMake((backSprie5:getContentSize().width-50)/2, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                if k==1 then
                    contentLbHight=contentLbHight+(contentLb:getContentSize().height+100)
                    if accessoryVoApi:isUpgradeQualityRed()==true or (attTab and SizeOfTable(attTab)>=5) or (defTab and SizeOfTable(defTab)>=5) then
                        contentLbHight=contentLbHight+40
                    end
                elseif k==2 then
                    contentLbHight=contentLbHight+(contentLb:getContentSize().height+5)
                else
                    contentLbHight=contentLbHight+(contentLb:getContentSize().height+25)
                end
            end
            contentLbHight=contentLbHight+30
            if self.repAcceHeight~=nil and tonumber(self.repAcceHeight)~=nil then
                if tonumber(self.repAcceHeight)<contentLbHight then
                    self.repAcceHeight=contentLbHight
                end
            else
                self.repAcceHeight=contentLbHight
            end
        end
    end
    return self.repAcceHeight
end
function alienMinesEmailDetailDialog:getcellhight( ... )
    -- body
    if self.cellHight==nil then
        -- if self.eid and (self.emailType==1 or self.emailType==3) then
        --     local emailVo=nil
        --     if self.eid and self.emailType then
        --         emailVo=alienMinesEmailVoApi:getEmailByEid(self.eid)
        --     end
        --     local msg=""
        --     if emailVo and emailVo.content then msg=emailVo.content end
        --     -- msg="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊" 
        --     while string.find(msg,"\\n")~=nil do
        --         local startIdx,endIdx=string.find(msg,"\\n")
        --         msg=string.sub(msg,1,startIdx-1).."\n"..string.sub(msg,endIdx+1)
        --     end

        --     local isHasUrl=false
        --     local messageTb={}
        --     if self.emailType==1 and (tostring(emailVo.sender)=="0" or tostring(emailVo.sender)=="1" or tostring(emailVo.sender)=="2") then 
        --         local strLen=string.len(msg)
        --         local wz=msg
        --         local endMsg=""
        --         while string.find(wz,"#(.-)#")~=nil do
        --             isHasUrl=true
        --             local startIdx,endIdx=string.find(wz,"#(.-)#")

        --             local firstStr=""
        --             local endStr=""
        --             if startIdx>1 then
        --                 firstStr=string.sub(wz,1,startIdx-1)
        --             end
        --             if endIdx<strLen then
        --                 endStr=string.sub(wz,endIdx+1)
        --             end
        --             if endIdx-startIdx>1 then
        --                 local newKey=string.sub(wz,startIdx+1,endIdx-1)
        --                 -- wz=firstStr..getlocal(newKey)..endStr
        --                 table.insert(messageTb,{firstStr,0})
        --                 table.insert(messageTb,{newKey,1})
        --             -- else
        --             --  wz=firstStr..endStr
        --             end
        --             wz=endStr
        --             endMsg=endStr
        --         end
        --         if endMsg and endMsg~="" then
        --             table.insert(messageTb,{endMsg,0})
        --         end
        --     end

        --     local height1=0
        --     if isHasUrl==true and messageTb and SizeOfTable(messageTb)>0 then
        --         for k,v in pairs(messageTb) do
        --             local msgStr=v[1]
        --             local isUrl=v[2]
        --             if isUrl and isUrl==1 then
        --                 local function jumpToHandler()
        --                 end
        --                 local contentLabel=GetTTFLabelWrap(msgStr,25,CCSizeMake(self.txtSize*23,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        --                 local meunItem = CCMenuItemLabel:create(contentLabel)
        --                 height1=height1+meunItem:getContentSize().height
        --             else
        --                 local contentLabel=GetTTFLabelWrap(msgStr,25,CCSizeMake(self.txtSize*23,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        --                 height1=height1+contentLabel:getContentSize().height
        --             end
        --         end
        --     else
        --         local contentLabel=GetTTFLabelWrap(msg,25,CCSizeMake(self.txtSize*23,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        --         height1=contentLabel:getContentSize().height
        --     end

        --     -- local contentLabel=GetTTFLabelWrap(msg,25,CCSizeMake(self.txtSize*23,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        --     -- contentLabel:setAnchorPoint(ccp(0,1))

        --     -- local height1=contentLabel:getContentSize().height+200
        --     self.cellHight=height1+400
        --     do return self.cellHight end
        -- end
        local contentLbHight=0
        local report=alienMinesEmailVoApi:getReport(self.eid)
        if self.chatReport then
            report=self.chatReport
        end
        if report==nil then
            do return end
        end
        local rtype=report.type
        -- if rtype==3 then
        --     do return end
        -- end

        -- local islandType,attacker,defender,attackerAllianceName,defenderAllianceName,helpDefender,helpDefenderAllianceName,hasHelpDefender,aLandform,dLandform,landform=alienMinesReportVoApi:formatReportData(report)
        local content=alienMinesReportVoApi:getReportContent(report,self.chatSender)

        for k,v in pairs(content) do
            if content[k]~=nil and content[k]~="" then
                local contentMsg=content[k]
                local message=""
                if type(contentMsg)=="table" then
                    message=contentMsg[1]
                else
                    message=contentMsg
                end
                local contentLb
                --contentLb = GetTTFLabel(message,self.txtSize)
                contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(self.txtSize*22, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                contentLb:setAnchorPoint(ccp(0,1))
                --local height = cellHeight-((k-1)*35)-60
                contentLbHight = contentLb:getContentSize().height+contentLbHight
            end
        end
        self.cellHight=contentLbHight+80
        return (contentLbHight+80)
    else
        return self.cellHight
    end
end
--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function alienMinesEmailDetailDialog:eventHandler(handler,fn,idx,cel)
    if (self.eid~=nil or self.chatReport) then
    else
        do return end
    end
    if fn=="numberOfCellsInTableView" then
        -- if self.eid and (self.emailType==1 or self.emailType==3) then
        --     do return 1 end
        -- end
        local report=alienMinesEmailVoApi:getReport(self.eid)
        if self.chatReport then
            report=self.chatReport
        end
        if report==nil then
            do return end
        end
        local rtype=report.type
        if rtype==3 then
            return 2
        elseif rtype==2 then
            return 3
        elseif rtype==1 then
            local num=4
            if alienMinesEmailVoApi:isShowHero(report) then
                num=num + 1
            end
            if alienMinesEmailVoApi:isShowAccessory(report) then
                num=num + 1
            end
            if alienMinesEmailVoApi:isShowEmblem(report)==true then
                num = num + 1
            end
            if G_isShowPlaneInReport(report,4)==true then
                num = num + 1
            end
            return num
        end
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        local width=400
        local height=30
        -- if self.eid and (self.emailType==1 or self.emailType==3) then
        --     height = self:getcellhight()
        --     tmpSize=CCSizeMake(width,height)
        --     do return tmpSize end
        -- end
        local report=alienMinesEmailVoApi:getReport(self.eid)
        if self.chatReport then
            report=self.chatReport
        end
        if report==nil then
            do return end
        end
        local rtype=report.type
        -- if rtype==3 then
        --     do return end
        -- end
        if idx==0 then
            height = self:getcellhight()
        elseif idx==1 then
            if rtype==2 or rtype==3 then
                -- if report.islandType==6 then
                --     -- height=80*5-30+50
                --     height=420
                -- elseif report.islandType<6 then
                    -- if base.landFormOpen==1 and base.richMineOpen==1 and report.richLevel and report.richLevel>0 then
                    --  height=190+50
                    -- else
                        -- height=190+150
                    -- end
                -- end
                height=self:getResHeight(rtype,report)
            else
                if report.award or report.acaward then
                -- if report.award or report.acaward then
                    local award={}
                    if report.award.u or report.award.p then
                        award=FormatItem(report.award,false)
                    else
                        award=report.award
                    end

                    -- local acaward = {}
                    -- if report.acaward ~= nil then
                    --     acaward = report.acaward
                    -- end
                    if self.awardHeight==nil then
                        -- self.awardHeight=math.floor((SizeOfTable(award)+SizeOfTable(acaward)+1)/2)*110+50
                        self.awardHeight=math.floor((SizeOfTable(award)+1)/2)*110+50
                    end
                    height=self.awardHeight
                else
                    height=50
                end
            end
        elseif idx==2 then
            if rtype==2 then
                -- height=220*3+10+50+50
                height=770
            else
                -- height=80*5-10+50
                height=(440-50)/5*4+50
            end
        elseif idx==3 or idx==4 or idx==5 or idx==6 or idx==7 then
            if rtype==1 then
                local showType=self:getShowType(report,idx)
                if showType==5 then
                    height=380
                elseif showType==1 then
                    height=410
                elseif showType==2 then
                    height=530
                elseif showType==3 then
                    height=self:getReportAccessoryhight(report)
                elseif showType==4 then
                    local attackerLostNum=0
                    local defenderLostNum=0
                    local attackerTotalNum=0
                    local defenderTotalNum=0
                    local attLost={}
                    local defLost={}
                    if report.lostShip.attackerTotal then
                        if report.lostShip.attackerTotal.o then
                            attackerTotalNum=SizeOfTable(report.lostShip.attackerTotal.o)
                        else
                            attackerTotalNum=SizeOfTable(report.lostShip.attackerTotal)
                        end
                    end
                    if report.lostShip.defenderTotal then
                        if report.lostShip.defenderTotal.o then
                            defenderTotalNum=SizeOfTable(report.lostShip.defenderTotal.o)
                        else
                            defenderTotalNum=SizeOfTable(report.lostShip.defenderTotal)
                        end
                    end
                    if report.lostShip.attackerLost then
                        if report.lostShip.attackerLost.o then
                            attackerLostNum=SizeOfTable(report.lostShip.attackerLost.o)
                        else
                            attackerLostNum=SizeOfTable(report.lostShip.attackerLost)
                        end
                    end
                    if report.lostShip.defenderLost then
                        if report.lostShip.defenderLost.o then
                            defenderLostNum=SizeOfTable(report.lostShip.defenderLost.o)
                        else
                            defenderLostNum=SizeOfTable(report.lostShip.defenderLost)
                        end
                    end
                    -- height=(self.txtSize+10)*(4+attackerLostNum+defenderLostNum)+50
                    if attackerTotalNum>0 or defenderTotalNum>0 then
                        height=(self.txtSize+30)*(4+attackerTotalNum+defenderTotalNum)+50
                    else
                        height=(self.txtSize+10)*(4+attackerLostNum+defenderLostNum)+50
                    end
                end
            end
        end
        tmpSize=CCSizeMake(width,height)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        -- if self.eid and (self.emailType==1 or self.emailType==3) then

        --     local cell=CCTableViewCell:new()
        --     cell:autorelease()

        --     local emailVo
        --     if self.eid and self.emailType then
        --         emailVo=alienMinesEmailVoApi:getEmailByEid(self.eid)
        --     end
        --     local msg=""
        --     if emailVo and emailVo.content then msg=emailVo.content end
        --     -- msg="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        --     while string.find(msg,"\\n")~=nil do
        --         local startIdx,endIdx=string.find(msg,"\\n")
        --         msg=string.sub(msg,1,startIdx-1).."\n"..string.sub(msg,endIdx+1)
        --     end
        --     local height1 = self:getcellhight()

        --     local isHasUrl=false
        --     local messageTb={}

        --     if self.emailType==1 and (tostring(emailVo.sender)=="0" or tostring(emailVo.sender)=="1" or tostring(emailVo.sender)=="2") then 
        --         local strLen=string.len(msg)            
        --         local wz=msg
        --         local endMsg=""
        --         while string.find(wz,"#(.-)#")~=nil do
        --             isHasUrl=true
        --             local startIdx,endIdx=string.find(wz,"#(.-)#")

        --             local firstStr=""
        --             local endStr=""
        --             if startIdx>1 then
        --                 firstStr=string.sub(wz,1,startIdx-1)
        --             end
        --             if endIdx<strLen then
        --                 endStr=string.sub(wz,endIdx+1)
        --             end
        --             if endIdx-startIdx>1 then
        --                 local newKey=string.sub(wz,startIdx+1,endIdx-1)
        --                 -- wz=firstStr..getlocal(newKey)..endStr
        --                 table.insert(messageTb,{firstStr,0})
        --                 table.insert(messageTb,{newKey,1})
        --             -- else
        --             --  wz=firstStr..endStr
        --             end
        --             wz=endStr
        --             endMsg=endStr
        --         end
        --         if endMsg and endMsg~="" then
        --             table.insert(messageTb,{endMsg,0})
        --         end
        --     end

        --     local posY=height1-5
        --     if isHasUrl==true and messageTb and SizeOfTable(messageTb)>0 then
        --         for k,v in pairs(messageTb) do
        --             local msgStr=v[1]
        --             local isUrl=v[2]
        --             if isUrl and isUrl==1 then
        --                 local function jumpToHandler()
        --                     local tmpTb={}
        --                     tmpTb["action"]="openUrl"
        --                     tmpTb["parms"]={}
        --                     tmpTb["parms"]["url"]=msgStr
        --                     local cjson=G_Json.encode(tmpTb)
        --                     G_accessCPlusFunction(cjson)
        --                 end
        --                 local contentLabel=GetTTFLabelWrap(msgStr,25,CCSizeMake(self.txtSize*23,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        --                 contentLabel:setColor(G_ColorOrange2)
        --                 local meunItem = CCMenuItemLabel:create(contentLabel)
        --                 meunItem:setAnchorPoint(ccp(0,1))
        --                 meunItem:registerScriptTapHandler(jumpToHandler)
        --                 local menu = CCMenu:createWithItem(meunItem)
        --                 menu:setAnchorPoint(ccp(0,1))
        --                 menu:setPosition(5,posY)
        --                 cell:addChild(menu,2)
        --                 posY=posY-meunItem:getContentSize().height
        --             else
        --                 local contentLabel=GetTTFLabelWrap(msgStr,25,CCSizeMake(self.txtSize*23,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        --                 contentLabel:setAnchorPoint(ccp(0,1))
        --                 contentLabel:setPosition(ccp(5,posY))
        --                 cell:addChild(contentLabel,2)
        --                 posY=posY-contentLabel:getContentSize().height
        --             end
        --         end
        --     else
        --         local contentLabel=GetTTFLabelWrap(msg,25,CCSizeMake(self.txtSize*23,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        --         contentLabel:setAnchorPoint(ccp(0,1))
        --         contentLabel:setPosition(ccp(5,height1-5))
        --         cell:addChild(contentLabel,2)
        --     end

        --     do return cell end
        -- end

        local report=alienMinesEmailVoApi:getReport(self.eid)
        if self.chatReport then
            report=self.chatReport
        end
        if report==nil then
            do return end
        end
        local rtype=report.type
        -- if rtype==3 then
        --     do return end
        -- end
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local islandType,attacker,defender,attackerAllianceName,defenderAllianceName,helpDefender,helpDefenderAllianceName,hasHelpDefender,aLandform,dLandform,landform=alienMinesReportVoApi:formatReportData(report)

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        end
        if idx==0 then
            local backSprie1=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
            backSprie1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
            backSprie1:ignoreAnchorPointForPosition(false)
            backSprie1:setAnchorPoint(ccp(0,0))
            backSprie1:setIsSallow(false)
            backSprie1:setTouchPriority(-(self.layerNum-1)*20-2)
            cell:addChild(backSprie1,1)
            
            local titleLabel
            local content=alienMinesReportVoApi:getReportContent(report,self.chatSender)
            local cellHeight = self:getcellhight()
            if rtype==2 or rtype==3 then
                backSprie1:setPosition(ccp(0, cellHeight-55))
                titleLabel=GetTTFLabel(getlocal("scout_content_target_info"),30)
            elseif rtype==1 then
                backSprie1:setPosition(ccp(0, cellHeight-55))
                titleLabel=GetTTFLabel(getlocal("fight_content_fight_info"),30)
            end
            titleLabel:setPosition(getCenterPoint(backSprie1))
            backSprie1:addChild(titleLabel,2)

            local contentLbHight=0
            for k,v in pairs(content) do
                if content[k]~=nil and content[k]~="" then
                    local contentMsg=content[k]
                    local message=""
                    local color
                    if type(contentMsg)=="table" then
                        message=contentMsg[1]
                        color=contentMsg[2]
                    else
                        message=contentMsg
                    end
                    local contentLb
                    local contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(self.txtSize*22, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    contentLb:setAnchorPoint(ccp(0,1))
                    if contentLbHight==0 then
                        contentLbHight = cellHeight-65
                    end
                    contentLb:setPosition(ccp(20,contentLbHight))
                    contentLbHight = contentLbHight - contentLb:getContentSize().height
                    cell:addChild(contentLb,1)
                    if color~=nil then
                        contentLb:setColor(color)
                    end
                end
            end
        elseif idx==1 then
            local backSprie2=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
            backSprie2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
            backSprie2:ignoreAnchorPointForPosition(false)
            backSprie2:setAnchorPoint(ccp(0,0))
            backSprie2:setIsSallow(false)
            backSprie2:setTouchPriority(-(self.layerNum-1)*20-2)
            cell:addChild(backSprie2,1)

            local titleLabel2
            if rtype==2 or rtype==3 then
                titleLabel2=GetTTFLabel(getlocal("fight_content_resource_info"),30)
                -- if report.islandType==6 then
                --     local sizeLb=80*5-30
                --     local resource=report.resource
                --     for k,v in pairs(resource) do
                --         if v and v.pic and v.name and v.num then
                --             local width = 30
                --             local height = sizeLb-k*70
                --             local icon = CCSprite:createWithSpriteFrameName(v.pic)
                --             icon:setAnchorPoint(ccp(0,0))
                --             icon:setPosition(ccp(width,height-10))
                --             cell:addChild(icon,2)
                --             if icon:getContentSize().width>100 then
                --                 icon:setScaleX(100/150)
                --                 icon:setScaleY(100/150)
                --             end
                --             icon:setScaleX(0.6)
                --             icon:setScaleY(0.6)
                        
                --             local str=getlocal("scout_content_player_plunder",{(v.name),FormatNumber(v.num)})
                --             local numLable=GetTTFLabelWrap(str,self.txtSize,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
                --             numLable:setAnchorPoint(ccp(0,0.5))
                --             numLable:setPosition(ccp(width+icon:getContentSize().width/2+15,height+25))
                --             cell:addChild(numLable,2)
                --         end
                --     end
                --     backSprie2:setPosition(ccp(0, 80*5-30))
                -- elseif report.islandType>0 and report.islandType<6 then
                    -- local resType=4
                    -- -- local resName=getlocal("scout_content_product_"..report.islandType)
                    -- -- local resNum=tonumber(mapCfg[report.islandType][report.level].resource)
                    -- local alienResType=report.islandType
                    -- local resName=getlocal("scout_content_product_"..resType)
                    -- local resNum=tonumber(mapCfg[resType][report.level].resource)
                    -- -- local resStr=getlocal("scout_content_defend",{resName,resNum})
                    -- local alienResName=getlocal("alien_tech_res_name_"..alienResType)
                    -- local rate=alienMineCfg.collect[alienResType].rate
                    -- local alienResNum=resNum*rate
                    -- local resStr=getlocal("alienMines_scout_resources_desc_1",{resName,resNum,alienResName,alienResNum})

                    -- -- local richLevel=report.richLevel or 0
                    -- -- local richLevelStr
                    -- -- if base.landFormOpen==1 and base.richMineOpen==1 and richLevel and richLevel>0 then
                    -- --     richLevelStr=getlocal("scout_content_defend_rich_mine",{resName,resNum*(tonumber(mapHeatCfg.resourceSpeed[richLevel])+1)})
                    -- --     resStr=resStr.."\n"..richLevelStr
                    -- -- end

                    -- if report.islandOwner>0 then
                    --     if report.resource~=nil and report.resource[1]~=nil then
                    --         local cNum=report.resource[1].num
                    --         -- resStr=resStr.."\n"..getlocal("scout_content_collect_num",{(report.resource[1].name),cNum})
                    --         resStr=resStr.."\n"..getlocal("alienMines_scout_resources_desc_2",{(report.resource[1].name),cNum,alienResName,cNum*rate})

                    --         -- if base.alien==1 and base.landFormOpen==1 and base.richMineOpen==1 and richLevel and richLevel>0 then
                    --         --     local collectCfg={}
                    --         --     if base.richMineOpen==1 and richLevel and richLevel>0 then
                    --         --         if alienTechCfg.collect[richLevel+1] then
                    --         --             collectCfg=alienTechCfg.collect[richLevel+1]
                    --         --         end
                    --         --     else
                    --         --         collectCfg=alienTechCfg.collect[1]
                    --         --     end
                    --         --     if collectCfg and SizeOfTable(collectCfg)>0 and alienTechCfg.resource[collectCfg.res] then
                    --         --         local resCfg=alienTechCfg.resource[collectCfg.res]
                    --         --         local resName=getlocal(resCfg.name)
                    --         --         local resNum=cNum*collectCfg.rate
                    --         --         if resName and resNum and resNum>0 then
                    --         --             resStr=resStr.."\n"..getlocal("scout_content_collect_num",{resName,resNum})
                    --         --         end
                    --         --     end
                    --         -- end
                    --     end
                    -- end

                    -- local resourceLabel=GetTTFLabelWrap(resStr,25,CCSizeMake(25*23,1000),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    -- resourceLabel:setAnchorPoint(ccp(0,1))
                    -- -- if base.landFormOpen==1 and base.richMineOpen==1 and richLevel and richLevel>0 then
                    -- --  resourceLabel:setPosition(ccp(10,190-50-10+50))
                    -- --  cell:addChild(resourceLabel,2)
                    -- --  backSprie2:setPosition(ccp(0,190-50+50))
                    -- -- else
                    --     resourceLabel:setPosition(ccp(10,190+150-50-10))
                    --     cell:addChild(resourceLabel,2)
                    --     backSprie2:setPosition(ccp(0,190+150-50))
                    -- -- end
                -- end

                local scoutHeight,scoutMsg=self:getResHeight(rtype,report)
                backSprie2:setPosition(ccp(0,scoutHeight-50))
                local sHeight=scoutHeight
                for k,v in pairs(scoutMsg) do
                    if v~=nil and v~="" then
                        local contentMsg=v
                        local message=""
                        local color
                        if type(contentMsg)=="table" then
                            message=contentMsg[1]
                            color=contentMsg[2]
                        else
                            message=contentMsg
                        end
                        local resourceLabel=GetTTFLabelWrap(message,25,CCSizeMake(25*23,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                        resourceLabel:setAnchorPoint(ccp(0,1))
                        resourceLabel:setPosition(ccp(10,sHeight-50-10))
                        cell:addChild(resourceLabel,2)
                        if color then
                            resourceLabel:setColor(color)
                        end
                        sHeight=sHeight-resourceLabel:getContentSize().height
                    end
                end

                if rtype==3 and report.resource then
                    local alienRecourse={}
                    if (report.resource.u or report.resource.r) then
                        alienRecourse=FormatItem(report.resource)
                    else
                        alienRecourse=report.resource
                    end

                    local iSize=100
                    for k,v in pairs(alienRecourse) do
                        local resIcon
                        local resLb
                        if v.pic then
                            resIcon=CCSprite:createWithSpriteFrameName(v.pic)
                            resLb=GetTTFLabel(getlocal("alienMines_return_resources",{v.name,v.num}),25)
                            resLb:setAnchorPoint(ccp(0,0.5))
                            resLb:setColor(G_ColorGreen)
                            if v and v.type=="u" then
                                resIcon:setPosition(ccp(15+iSize/2,sHeight-iSize/2-20-50-10))
                                resLb:setPosition(ccp(15+iSize+15,sHeight-iSize/2-20-50-10))
                            else
                                resIcon:setPosition(ccp(15+iSize/2,sHeight-iSize/2-20-50-10-130))
                                resLb:setPosition(ccp(15+iSize+15,sHeight-iSize/2-20-50-10-130))
                            end
                            cell:addChild(resIcon,2)
                            cell:addChild(resLb,2)
                        end
                    end
                end
            elseif rtype==1 then
                local award={}
                -- local acAward = {}
                if report.award.u or report.award.p then
                    award=FormatItem(report.award,false)
                else
                    award=report.award
                end
                -- if report.acaward ~= nil then
                --     acAward = report.acaward
                -- end
                
                -- local acAwardLen = SizeOfTable(acAward)

                if SizeOfTable(award)==0 then
                -- if SizeOfTable(award) + acAwardLen == 0 then
                    titleLabel2=GetTTFLabel(getlocal("fight_content_fight_award")..getlocal("fight_content_null"),30)
                else
                    titleLabel2=GetTTFLabel(getlocal("fight_content_fight_award"),30)
                end

                -- local hnum=math.floor((SizeOfTable(award)+ acAwardLen+1)/2)--math.floor((SizeOfTable(award)+1)/2)
                local hnum=math.floor((SizeOfTable(award)+1)/2)
                local sizeLb=hnum*110

                local i = 1

                for k,v in pairs(award) do
                    if v and v.pic and v.name and v.num then
                        local width = 20+((k-1)%2)*280
                        local height = sizeLb-(math.floor((k+1)/2))*100+5
                        local icon = CCSprite:createWithSpriteFrameName(v.pic)
                        icon:setAnchorPoint(ccp(0,0))
                        icon:setPosition(ccp(width,height))
                        cell:addChild(icon,2)
                        if icon:getContentSize().width>100 then
                            icon:setScaleX(100/150)
                            icon:setScaleY(100/150)
                        end
                        icon:setScaleX(0.75)
                        icon:setScaleY(0.75)

                        local nameLable = GetTTFLabelWrap((v.name),24,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                        nameLable:setAnchorPoint(ccp(0,0.5))
                        nameLable:setPosition(ccp(width+icon:getContentSize().width,height+15))
                        cell:addChild(nameLable,2)

                        local numLable = GetTTFLabel(v.num,24)
                        numLable:setAnchorPoint(ccp(0,0))
                        numLable:setPosition(ccp(width+icon:getContentSize().width,height+50))
                        cell:addChild(numLable,2)
                        i = i + 1
                    end
                end
                
                -- for k1,v1 in pairs(acAward) do
                --     local width = 20+((i-1)%2)*280
                --     local height = sizeLb-(math.floor((i+1)/2))*100+5
                --     local pCfg = nil
                --     local icon
                --     if string.sub(k1,1,1) == "s" then
                --         pCfg = acMiBaoVoApi:getPieceCfgForShowBySid(k1)
                --         icon = CCSprite:createWithSpriteFrameName(pCfg.icon)

                --     end
                --     if k1=="jidongbudui_mm_m1" then
                --         pCfg = acJidongbuduiVoApi:getTurkeyCfgForShow()
                --         icon= CCSprite:createWithSpriteFrameName("Icon_BG.png")
                        
                --         local function timeIconClick( ... )
                --         end
                --         local addIcon = LuaCCSprite:createWithSpriteFrameName(pCfg.icon,timeIconClick)
                --         addIcon:setPosition(getCenterPoint(icon))
                --         icon:addChild(addIcon)
                --     end

                --     icon:setAnchorPoint(ccp(0,0))
                --     icon:setPosition(ccp(width,height))
                --     cell:addChild(icon,2)
                --     if icon:getContentSize().width>100 then
                --         icon:setScaleX(100/150)
                --         icon:setScaleY(100/150)
                --     end
                    
                --     icon:setScaleX(75/icon:getContentSize().width)
                --     icon:setScaleY(75/icon:getContentSize().height)

                --     local nameLable = GetTTFLabelWrap(getlocal(pCfg.name),24,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                --     nameLable:setAnchorPoint(ccp(0,0.5))
                --     nameLable:setPosition(ccp(width+icon:getContentSize().width,height+15))
                --     cell:addChild(nameLable,2)

                --     local numLable = GetTTFLabel(v1,24)
                --     numLable:setAnchorPoint(ccp(0,0))
                --     numLable:setPosition(ccp(width+icon:getContentSize().width,height+50))
                --     cell:addChild(numLable,2)
                --     i = i + 1
                -- end
                backSprie2:setPosition(ccp(0, sizeLb))
            end
            titleLabel2:setPosition(getCenterPoint(backSprie2))
            backSprie2:addChild(titleLabel2,2)
        elseif idx==2 then
            local backSprie3 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
            backSprie3:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
            backSprie3:ignoreAnchorPointForPosition(false)
            backSprie3:setAnchorPoint(ccp(0,0))
            backSprie3:setIsSallow(false)
            backSprie3:setTouchPriority(-(self.layerNum-1)*20-2)
            cell:addChild(backSprie3,1)

            local titleLabel3
            if rtype==2 then
                titleLabel3=GetTTFLabel(getlocal("alliance_challenge_enemy_info"),30)
                backSprie3:setPosition(ccp(0, 220*3+10))
                
                local sizeLb=220*2+100
                local shipTab=report.defendShip
                
                for k=1,6 do
                    --local width = 80+((k-1)%2)*280
                    --local height = sizeLb-(math.floor((k+1)/2))*220
                    local width = self.bgLayer:getContentSize().width-(math.ceil(k/3))*280
                    local height = sizeLb-(((k-1)%3)*220+60)

                    local function touchClick(hd,fn,idx)
                    end
                    local bgSp =LuaCCScale9Sprite:createWithSpriteFrameName("BgEmptyTank.png",CCRect(10, 10, 20, 20),touchClick)
                    bgSp:setContentSize(CCSizeMake(150, 150))
                    bgSp:ignoreAnchorPointForPosition(false)
                    bgSp:setAnchorPoint(ccp(0,0))
                    bgSp:setIsSallow(false)
                    bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
                    bgSp:setPosition(ccp(width,height))
                    cell:addChild(bgSp,1)
                    
                    local v
                    if shipTab then
                        v=shipTab[k]
                    end
                    if v and v.pic and v.name and v.num then
                        local icon = CCSprite:createWithSpriteFrameName(v.pic)
                        icon:setPosition(getCenterPoint(bgSp))
                        bgSp:addChild(icon,2)

                        if G_pickedList(tonumber(RemoveFirstChar(v.key))) ~= tonumber(RemoveFirstChar(v.key)) then
                             local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                            icon:addChild(pickedIcon)
                            pickedIcon:setPosition(icon:getContentSize().width*0.7,icon:getContentSize().height*0.5-10)
                        end
                        
                        local str=(v.name).."("..tostring(v.num)..")"
                        local descLable = GetTTFLabelWrap(str,self.txtSize,CCSizeMake(self.txtSize*10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                        descLable:setAnchorPoint(ccp(0.5,1))
                        descLable:setPosition(ccp(width+bgSp:getContentSize().width/2,height))
                        cell:addChild(descLable,2)
                    end
                end
            elseif rtype==1 then
                local resource={}
                if (report.resource.u or report.resource.r) then
                    resource=FormatItem(report.resource)
                else
                    resource=report.resource
                end
                local resNum=SizeOfTable(resource)

                titleLabel3=GetTTFLabel(getlocal("fight_content_resource_info"),30)
                backSprie3:setPosition(ccp(0, 78*resNum))
                
                local isAttacker=alienMinesEmailVoApi:isAttacker(report,self.chatSender)

                local sizeLb=78*resNum
                for k,v in pairs(resource) do
                    if v and v.pic and v.name and v.num then
                        local width = 30
                        local height = sizeLb-k*70
                        local icon = CCSprite:createWithSpriteFrameName(v.pic)
                        icon:setAnchorPoint(ccp(0,0))
                        icon:setPosition(ccp(width,height-10))
                        cell:addChild(icon,2)
                        if icon:getContentSize().width>100 then
                            icon:setScaleX(100/150)
                            icon:setScaleY(100/150)
                        end
                        icon:setScaleX(0.6)
                        icon:setScaleY(0.6)
                        
                        local addStr=" "
                        local numLable
                        if tonumber(v.num)==0 then
                            numLable = GetTTFLabel((v.name)..addStr..(v.num),self.txtSize)
                        else
                            if isAttacker==true then
                                if report.isVictory==1 then
                                    addStr=" +"
                                    numLable = GetTTFLabel((v.name)..addStr..(v.num),self.txtSize)
                                    numLable:setColor(G_ColorGreen)
                                else
                                    addStr=" -"
                                    numLable = GetTTFLabel((v.name)..addStr..(v.num),self.txtSize)
                                    numLable:setColor(G_ColorRed)
                                end
                            else
                                if report.isVictory==1 then
                                    addStr=" -"
                                    numLable = GetTTFLabel((v.name)..addStr..(v.num),self.txtSize)
                                    numLable:setColor(G_ColorRed)
                                else
                                    addStr=" +"
                                    numLable = GetTTFLabel((v.name)..addStr..(v.num),self.txtSize)
                                    numLable:setColor(G_ColorGreen)
                                end
                            end
                        end
                        numLable:setAnchorPoint(ccp(0,0))
                        numLable:setPosition(ccp(width+icon:getContentSize().width/2+15,height))
                        cell:addChild(numLable,2)
                    end
                end
            end
            titleLabel3:setPosition(getCenterPoint(backSprie3))
            backSprie3:addChild(titleLabel3,2)
        elseif idx==3 or idx==4 or idx==5 or idx==6 or idx==7 then
            if rtype==1 then
                local showType=self:getShowType(report,idx)
                if showType==5 then
                    local isAttacker=alienMinesEmailVoApi:isAttacker(report,self.chatSender) 
                    G_addReportPlane(report,cell,isAttacker)
                elseif showType==1 then
                    local hCellWidth=self.bgLayer:getContentSize().width-50
                    local hCellHeight=410
                    local emblemTitleBg =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
                    emblemTitleBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
                    emblemTitleBg:ignoreAnchorPointForPosition(false)
                    emblemTitleBg:setAnchorPoint(ccp(0,0))
                    emblemTitleBg:setIsSallow(false)
                    emblemTitleBg:setTouchPriority(-(self.layerNum-1)*20-2)
                    cell:addChild(emblemTitleBg,1)
                    emblemTitleBg:setPosition(ccp(0,hCellHeight-50))

                    local emblemTitleLb=GetTTFLabel(getlocal("emblem_infoTitle"),30)
                    emblemTitleLb:setPosition(getCenterPoint(emblemTitleBg))
                    emblemTitleBg:addChild(emblemTitleLb,2)

                    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
                    lineSp:setAnchorPoint(ccp(0.5,0.5))
                    lineSp:setPosition(ccp(hCellWidth/2,(hCellHeight-50)/2))
                    lineSp:setScaleX((hCellHeight-30)/lineSp:getContentSize().width)
                    lineSp:setRotation(90)
                    cell:addChild(lineSp,1)

                    local ownerEmblemStr=getlocal("emblem_emailOwn")
                    local enemyEmblemStr=getlocal("emblem_emailEnemy")
                    local myEmblem,myEmblemCfg,myEmblemSkill,myEmblemStrong
                    local enemyEmblem,enemyEmblemCfg,enemyEmblemSkill,enemyEmblemStrong
                    
                    local emblemData=report.emblemID or {nil,nil}
                    local isAttacker=emailVoApi:isAttacker(report,self.chatSender)
                    if emblemData then
                        if isAttacker==true then
                            myEmblem = emblemData[1] ~= 0 and emblemData[1] or nil
                            enemyEmblem = emblemData[2] ~= 0 and emblemData[2] or nil
                        else
                            myEmblem = emblemData[2] ~= 0 and emblemData[2] or nil
                            enemyEmblem = emblemData[1] ~= 0 and emblemData[1] or nil
                        end
                        if myEmblem then
                            myEmblemCfg = emblemVoApi:getEquipCfgById(myEmblem)
                            myEmblemSkill = myEmblemCfg.skill
                            myEmblemStrong=myEmblemCfg.qiangdu
                        end

                        if enemyEmblem then
                            enemyEmblemCfg = emblemVoApi:getEquipCfgById(enemyEmblem)
                            enemyEmblemSkill = enemyEmblemCfg.skill
                            enemyEmblemStrong=enemyEmblemCfg.qiangdu
                        end
                    end

                    local ownerEmblemLb=GetTTFLabelWrap(ownerEmblemStr,28,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    ownerEmblemLb:setAnchorPoint(ccp(0.5,0.5))
                    ownerEmblemLb:setPosition(ccp(hCellWidth/4,hCellHeight-85))
                    cell:addChild(ownerEmblemLb,2)
                    ownerEmblemLb:setColor(G_ColorGreen)

                    local enemyEmblemLb=GetTTFLabelWrap(enemyEmblemStr,28,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    enemyEmblemLb:setAnchorPoint(ccp(0.5,0.5))
                    enemyEmblemLb:setPosition(ccp(hCellWidth/4*3,hCellHeight-85))
                    cell:addChild(enemyEmblemLb,2)
                    enemyEmblemLb:setColor(G_ColorRed)

                    local myEmblemIcon
                    if myEmblem then
                        myEmblemIcon = emblemVoApi:getEquipIcon(myEmblem,nil,nil,nil,myEmblemStrong)
                    else
                        myEmblemIcon = emblemVoApi:getEquipIconNull()
                    end
                    myEmblemIcon:setAnchorPoint(ccp(0.5,0))
                    myEmblemIcon:setPosition(ccp(hCellWidth/4,60))
                    cell:addChild(myEmblemIcon)
                    
                    local enemyEmblemIcon
                    if enemyEmblem then
                        enemyEmblemIcon = emblemVoApi:getEquipIcon(enemyEmblem,nil,nil,nil,enemyEmblemStrong)
                    else
                        enemyEmblemIcon = emblemVoApi:getEquipIconNull()
                    end
                    enemyEmblemIcon:setAnchorPoint(ccp(0.5,0))
                    enemyEmblemIcon:setPosition(ccp(hCellWidth/4 * 3,60))
                    cell:addChild(enemyEmblemIcon)

                    --我方装备信息（技能+强度）
                    if myEmblemSkill ~= nil then
                        local mySkillLb=GetTTFLabelWrap(emblemVoApi:getEquipSkillNameById(myEmblemSkill[1],myEmblemSkill[2]),25,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                        mySkillLb:setAnchorPoint(ccp(0.5,0.5))
                        mySkillLb:setPosition(ccp(hCellWidth/4,30))
                        cell:addChild(mySkillLb,2)
                    end

                    --敌方装备信息（技能+强度）
                    if enemyEmblemSkill ~= nil then
                        local enemySkillLb=GetTTFLabel(emblemVoApi:getEquipSkillNameById(enemyEmblemSkill[1],enemyEmblemSkill[2]),25)
                        enemySkillLb:setAnchorPoint(ccp(0.5,0.5))
                        enemySkillLb:setPosition(ccp(hCellWidth/4*3,30))--85
                        cell:addChild(enemySkillLb,2)
                    end
                elseif showType==2 then
                    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                    local hCellWidth=self.bgLayer:getContentSize().width-50
                    local hCellHeight=530
                    local backSprie6 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
                    backSprie6:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
                    backSprie6:ignoreAnchorPointForPosition(false)
                    backSprie6:setAnchorPoint(ccp(0,0))
                    backSprie6:setIsSallow(false)
                    backSprie6:setTouchPriority(-(self.layerNum-1)*20-2)
                    cell:addChild(backSprie6,1)
                    backSprie6:setPosition(ccp(0,hCellHeight-50))

                    local titleLabel6=GetTTFLabel(getlocal("report_hero_message"),30)
                    titleLabel6:setPosition(getCenterPoint(backSprie6))
                    backSprie6:addChild(titleLabel6,2)

                    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
                    lineSp:setAnchorPoint(ccp(0.5,0.5))
                    lineSp:setPosition(ccp(hCellWidth/2,(hCellHeight-50)/2))
                    lineSp:setScaleX((hCellHeight-30)/lineSp:getContentSize().width)
                    lineSp:setRotation(90)
                    cell:addChild(lineSp,1)

                    local ownerHeroStr=getlocal("report_hero_owner")
                    local enemyHeroStr=getlocal("report_hero_enemy")
                    local scoreStr=getlocal("report_hero_score")
                    -- ownerHeroStr=str
                    -- enemyHeroStr=str
                    -- scoreStr=str
                    local myHero={}
                    local enemyHero={}
                    local myScore=0
                    local enemyScore=0
                    local heroData=report.hero or {{{},0},{{},0}}
                    local isAttacker=alienMinesEmailVoApi:isAttacker(report,self.chatSender)
                    if heroData then
                        if isAttacker==true then
                            if heroData[1] then
                                myHero=heroData[1][1] or {}
                                myScore=heroData[1][2] or 0
                            end
                            if heroData[2] then
                                enemyHero=heroData[2][1] or {}
                                enemyScore=heroData[2][2] or 0
                            end
                        else
                            if heroData[1] then
                                enemyHero=heroData[1][1] or {}
                                enemyScore=heroData[1][2] or 0
                            end
                            if heroData[2] then
                                myHero=heroData[2][1] or {}
                                myScore=heroData[2][2] or 0
                            end
                        end
                    end

                    local ownerHeroLb=GetTTFLabelWrap(ownerHeroStr,28,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    ownerHeroLb:setAnchorPoint(ccp(0.5,0.5))
                    ownerHeroLb:setPosition(ccp(hCellWidth/4,hCellHeight-85))
                    cell:addChild(ownerHeroLb,2)
                    ownerHeroLb:setColor(G_ColorGreen)

                    local enemyHeroLb=GetTTFLabelWrap(enemyHeroStr,28,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    enemyHeroLb:setAnchorPoint(ccp(0.5,0.5))
                    enemyHeroLb:setPosition(ccp(hCellWidth/4*3,hCellHeight-85))
                    cell:addChild(enemyHeroLb,2)
                    enemyHeroLb:setColor(G_ColorGreen)


                    for i=1,6 do
                        local wSpace=20
                        local hSpace=10
                        local iconSize=90
                        local posX=hCellWidth/4+iconSize/2+wSpace/2-math.floor((i-1)/3)*(iconSize+wSpace)
                        local posY=hCellHeight-iconSize/2-((i-1)%3)*(iconSize+hSpace)-120
                        
                        local mHid=nil
                        local mLevel=nil
                        local mProductOrder=nil
                        local adjutants={}
                        if myHero and myHero[i] then
                            local myHeroArr=Split(myHero[i],"-")
                            mHid=myHeroArr[1]
                            mLevel=myHeroArr[2]
                            mProductOrder=myHeroArr[3]
                            adjutants = heroAdjutantVoApi:decodeAdjutant(myHero[i])
                        end
                        local myIcon=heroVoApi:getHeroIcon(mHid,mProductOrder,false,nil,nil,nil,nil,{adjutants=adjutants,showAjt=true})
                        if myIcon then
                            myIcon:setScale(iconSize/myIcon:getContentSize().width)
                            myIcon:setPosition(ccp(posX,posY))
                            cell:addChild(myIcon,2)
                        end

                        local ehid=nil
                        local elevel=nil
                        local eproductOrder=nil
                        local eadjutants={}
                        if enemyHero and enemyHero[i] then
                            local enemyHeroArr=Split(enemyHero[i],"-")
                            ehid=enemyHeroArr[1]
                            elevel=enemyHeroArr[2]
                            eproductOrder=enemyHeroArr[3]
                            eadjutants=heroAdjutantVoApi:decodeAdjutant(enemyHero[i])
                        end
                        posX=hCellWidth/4*3+iconSize/2+wSpace/2-math.floor((i-1)/3)*(iconSize+wSpace)
                        local enemyIcon=heroVoApi:getHeroIcon(ehid,eproductOrder,false,nil,nil,nil,nil,{adjutants=eadjutants,showAjt=true})
                        if enemyIcon then
                            enemyIcon:setScale(iconSize/myIcon:getContentSize().width)
                            enemyIcon:setPosition(ccp(posX,posY))
                            cell:addChild(enemyIcon,2)
                        end
                    end

                    local scoreLb1=GetTTFLabelWrap(scoreStr,28,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    scoreLb1:setAnchorPoint(ccp(0.5,0.5))
                    scoreLb1:setPosition(ccp(hCellWidth/4,85))
                    cell:addChild(scoreLb1,2)
                    scoreLb1:setColor(G_ColorGreen)

                    local scoreLb2=GetTTFLabelWrap(scoreStr,28,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    scoreLb2:setAnchorPoint(ccp(0.5,0.5))
                    scoreLb2:setPosition(ccp(hCellWidth/4*3,85))
                    cell:addChild(scoreLb2,2)
                    scoreLb2:setColor(G_ColorGreen)

                    local myScoreLb=GetTTFLabel(myScore,28)
                    myScoreLb:setAnchorPoint(ccp(0.5,0.5))
                    myScoreLb:setPosition(ccp(hCellWidth/4,40))
                    cell:addChild(myScoreLb,2)

                    local enemyScoreLb=GetTTFLabel(enemyScore,28)
                    enemyScoreLb:setAnchorPoint(ccp(0.5,0.5))
                    enemyScoreLb:setPosition(ccp(hCellWidth/4*3,40))
                    cell:addChild(enemyScoreLb,2)

                elseif showType==3 then
                    local backSprie5 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
                    backSprie5:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
                    backSprie5:ignoreAnchorPointForPosition(false)
                    backSprie5:setAnchorPoint(ccp(0,0))
                    backSprie5:setIsSallow(false)
                    backSprie5:setTouchPriority(-(self.layerNum-1)*20-2)
                    cell:addChild(backSprie5,1)

                    local titleLabel5=GetTTFLabel(getlocal("report_accessory_compare"),30)
                    titleLabel5:setPosition(getCenterPoint(backSprie5))
                    backSprie5:addChild(titleLabel5,2)

                    local accessory=report.accessory or {}
                    local attAccData={}
                    local defAccData={}
                    local isAttacker=alienMinesEmailVoApi:isAttacker(report,self.chatSender)
                    if isAttacker==true then
                        attAccData=accessory[1] or {}
                        defAccData=accessory[2] or {}
                    else
                        attAccData=accessory[2] or {}
                        defAccData=accessory[1] or {}
                    end
                    local attScore=attAccData[1] or 0
                    local defScore=defAccData[1] or 0
                    local attTab=attAccData[2] or {0,0,0,0}
                    local defTab=defAccData[2] or {0,0,0,0}
                    if accessoryVoApi:isUpgradeQualityRed()==true then
                        if attTab[5]==nil then
                            attTab[5]=0
                        end
                        if defTab[5]==nil then
                            defTab[5]=0
                        end
                    end

                    local htSpace=50
                    local perSpace=self.txtSize+10

                    local cellHeight=self:getReportAccessoryhight(report)
                    local lbHeight=cellHeight-htSpace
                    local lbWidth=backSprie5:getContentSize().width/2+10

                    backSprie5:setPosition(ccp(0,lbHeight))

                    local function tipTouch()
                        local sd=smallDialog:new()
                        local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,{" ",getlocal("report_accessory_desc")," "},25)
                        sceneGame:addChild(dialogLayer,self.layerNum+1)
                        dialogLayer:setPosition(ccp(0,0))
                    end
                    local tipItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",tipTouch,11,nil,nil)
                    local spScale=0.7
                    tipItem:setScale(spScale)
                    local tipMenu = CCMenu:createWithItem(tipItem)
                    tipMenu:setPosition(ccp(backSprie5:getContentSize().width-tipItem:getContentSize().width/2*spScale+10,cellHeight-50-tipItem:getContentSize().height/2*spScale+55))
                    tipMenu:setTouchPriority(-(self.layerNum-1)*20-2)
                    cell:addChild(tipMenu,1)

                    for i=1,2 do
                        local content={}
                        content[i]={}

                        local campStr=""
                        local scoreStr=getlocal("report_accessory_score")
                        local score=0

                        if i==1 then
                            campStr=getlocal("report_accessory_owner")
                            score=attScore
                        elseif i==2 then
                            campStr=getlocal("report_accessory_enemy")
                            score=defScore
                        end

                        table.insert(content[i],{campStr,G_ColorGreen})
                        table.insert(content[i],{scoreStr,G_ColorGreen})
                        table.insert(content[i],{score,G_ColorWhite})

                        local contentLbHight=0
                        for k,v in pairs(content[i]) do
                            local contentMsg=v
                            local message=""
                            local color
                            if type(contentMsg)=="table" then
                                message=contentMsg[1]
                                color=contentMsg[2]
                            else
                                message=contentMsg
                            end
                            local contentLb
                            contentLb=GetTTFLabelWrap(message,28,CCSizeMake((backSprie5:getContentSize().width-50)/2, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                            local contentShowLb
                            contentShowLb=GetTTFLabelWrap(message,28,CCSizeMake((backSprie5:getContentSize().width-50)/2, 500),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                            contentShowLb:setAnchorPoint(ccp(0,1))
                            if contentLbHight==0 then
                                contentLbHight=cellHeight-60
                            end
                            if i==1 then
                                contentShowLb:setPosition(ccp(10,contentLbHight))
                            else
                                contentShowLb:setPosition(ccp(lbWidth,contentLbHight))
                            end
                            if k==1 then
                                local accNum=0
                                local accTab={}
                                if i==1 then
                                    accNum=SizeOfTable(attTab)
                                    accTab=attTab
                                else
                                    accNum=SizeOfTable(defTab)
                                    accTab=defTab
                                end
                                if accNum>0 then
                                    for n=1,accNum do
                                        -- if n<4 or (n==4 and accTab[n] and accTab[n]>0) then
                                            local iWidth
                                            if i==1 then
                                                iWidth=10+((n+1)%2)*100
                                            else
                                                iWidth=lbWidth+((n+1)%2)*100
                                            end
                                            local iHeight=contentLbHight-contentLb:getContentSize().height-25-math.floor((n-1)/2)*45

                                            local iSize=30
                                            
                                            local icon=CCSprite:createWithSpriteFrameName("uparrow"..n..".png")
                                            local scale=iSize/icon:getContentSize().width
                                            -- icon:setAnchorPoint(ccp(0.5,0.5))
                                            icon:setScale(scale)
                                            icon:setPosition(ccp(iWidth+iSize/2,iHeight))
                                            cell:addChild(icon,1)

                                            local numLb
                                            if i==1 then
                                                numLb=GetTTFLabel((attTab[n] or 0),25)
                                            else
                                                numLb=GetTTFLabel((defTab[n] or 0),25)
                                            end
                                            -- numLb:setAnchorPoint(ccp(0.5,0.5))
                                            numLb:setPosition(ccp(iWidth+iSize+15,iHeight))
                                            cell:addChild(numLb,1)
                                        -- end
                                    end
                                end
                            end
                            if k==1 then
                                contentLbHight=contentLbHight-(contentLb:getContentSize().height+100)
                                if accessoryVoApi:isUpgradeQualityRed()==true or (attTab and SizeOfTable(attTab)>=5) or (defTab and SizeOfTable(defTab)>=5) then
                                    contentLbHight=contentLbHight-40
                                end
                            elseif k==2 then
                                contentLbHight=contentLbHight-(contentLb:getContentSize().height+5)
                            else
                                contentLbHight=contentLbHight-(contentLb:getContentSize().height+25)
                            end
                            cell:addChild(contentShowLb,1)
                            if color~=nil then
                                contentShowLb:setColor(color)
                            end

                        end

                    end
                elseif showType==4 then
                    local backSprie4 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
                    backSprie4:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
                    backSprie4:ignoreAnchorPointForPosition(false)
                    backSprie4:setAnchorPoint(ccp(0,0))
                    backSprie4:setIsSallow(false)
                    backSprie4:setTouchPriority(-(self.layerNum-1)*20-2)
                    cell:addChild(backSprie4,1)
                    
                    local titleLabel4=GetTTFLabel(getlocal("fight_content_ship_lose"),30)
                    titleLabel4:setPosition(getCenterPoint(backSprie4))
                    backSprie4:addChild(titleLabel4,2)

                    local attLost={}
                    local defLost={}
                    local attTotal = {}--当前战斗坦克的总数
                    local defTotal = {}

                    if report.lostShip.attackerLost then
                        if report.lostShip.attackerLost.o then
                            attLost=FormatItem(report.lostShip.attackerLost,false)
                        else
                            attLost=report.lostShip.attackerLost
                        end
                    end
                    if report.lostShip.defenderLost then
                        if report.lostShip.defenderLost.o then
                            defLost=FormatItem(report.lostShip.defenderLost,false)
                        else
                            defLost=report.lostShip.defenderLost
                        end
                    end
                    if report.lostShip.attackerTotal then
                        if report.lostShip.attackerTotal.o then
                            attTotal=FormatItem(report.lostShip.attackerTotal,false)
                        else
                            attTotal=report.lostShip.attackerTotal
                        end
                    end
                    if report.lostShip.defenderTotal then
                        if report.lostShip.defenderTotal.o then
                            defTotal=FormatItem(report.lostShip.defenderTotal,false)
                        else
                            defTotal=report.lostShip.defenderTotal
                        end
                    end                 

                    local attackerStr=""
                    local attackerLost=""
                    local defenderStr=""
                    local defenderLost=""
                    local attackerTotal = ""
                    local defenderTotal = ""
                    local repairStr=""
                    local content={}
                    
                    local htSpace=0
                    local perSpace=self.txtSize+10
                    --损失的船
                    local attackerLostNum=SizeOfTable(attLost)
                    local defenderLostNum=SizeOfTable(defLost)
                    local attackerTotalNum = SizeOfTable(attTotal)
                    local defenderTotalNum = SizeOfTable(defTotal)
                    if attackerTotalNum>0 or defenderTotalNum>0 then
                        perSpace=self.txtSize+30
                        --损失的船
                        -- local attackerLostNum=SizeOfTable(attLost)
                        -- local defenderLostNum=SizeOfTable(defLost)
                        -- local attackerTotalNum = SizeOfTable(attTotal)
                        -- local defenderTotalNum = SizeOfTable(defTotal)
                        backSprie4:setPosition(ccp(0, perSpace*(4+attackerTotalNum+defenderTotalNum)+10))
                        local hCellWidth = self.bgLayer:getContentSize().width-50
                        local cellHeight =backSprie4:getPositionY()
                        --local cellHeight=perSpace*(4+attackerLostNum+defenderLostNum)+htSpace
                        local armysContent = {getlocal("battleReport_armysName"),getlocal("battleReport_armysNums"),getlocal("battleReport_armysLosts"),getlocal("battleReport_armysleaves")}

                        local showColor = {G_ColorWhite,G_ColorOrange2,G_ColorRed,G_ColorGreen}--所有需要显示的文字颜色
                        local defHeight,attOrDefTotal,attOrDefLost --
                        for g=1,2 do --
                            if g==2 then
                                cellHeight = defHeight-20
                            end
                            if g==1 then
                                personStr=getlocal("fight_content_attacker",{attacker})
                                attOrDefTotal =G_clone(attTotal)
                                attOrDefLost =G_clone(attLost)
                            elseif g==2 then
                                local isAttacker=emailVoApi:isAttacker(report,self.chatSender)
                                attOrDefTotal =G_clone(defTotal)
                                attOrDefLost =G_clone(defLost)
                                local defendName=defender
                                if hasHelpDefender==true then
                                    defendName=helpDefender
                                end
                                if isAttacker==true then
                                    if report.islandType==6 then
                                        personStr=defenderStr..getlocal("fight_content_defender",{defendName})
                                    else
                                        if report.islandOwner>0 then
                                            personStr=defenderStr..getlocal("fight_content_defender",{defendName})
                                        else
                                            personStr=defenderStr..getlocal("fight_content_defender",{G_getAlienIslandName(islandType)})
                                        end
                                    end
                                else
                                    personStr=defenderStr..getlocal("fight_content_defender",{defendName})
                                end
                            end
                            local attContent=GetTTFLabel(personStr,self.txtSize)
                            attContent:setAnchorPoint(ccp(0,0.5))
                            attContent:setPosition(ccp(10,cellHeight-40))
                            cell:addChild(attContent,2)

                            if g==1 then
                                attContent:setColor(G_ColorGreen)
                            elseif g==2 then
                                attContent:setColor(G_ColorRed)
                            end

                            local function sortAsc(a, b)
                                if sortByIndex then
                                    if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
                                        return a.id < b.id
                                    end
                                else
                                    if a.type==b.type then
                                        if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
                                            return a.id < b.id
                                        end
                                    end
                                end
                            end
                            table.sort(attOrDefTotal,sortAsc)
                            local lablSize = self.txtSize-9
                            local lablSizeO = self.txtSize -8
                            if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
                                lablSize =self.txtSize
                                lablSizeO =self.txtSize-3
                            end
                            local lbPosWIdth = 6
                            for k,v in pairs(armysContent) do
                                local armyLb=GetTTFLabelWrap(v,lablSize,CCSizeMake(backSprie4:getContentSize().width*0.1+70,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                                armyLb:setAnchorPoint(ccp(0.5,0.5))
                                if k >1 then
                                    lbPosWIdth =7
                                end
                                armyLb:setPosition(ccp(hCellWidth*k/lbPosWIdth+((k-1)*70),cellHeight-90))
                                cell:addChild(armyLb,2)
                                armyLb:setColor(showColor[k])
                            end

                            local localLeaves = {}
                            for i=1,4 do
                                local localStr
                                local pos = 50
                                if i ==1 then
                                    for k,v in pairs(attOrDefTotal) do
                                        if v and v.name then
                                            localStr=v.name
                                            local armyStr =GetTTFLabelWrap(localStr,lablSizeO,CCSizeMake(backSprie4:getContentSize().width*0.1+70,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                                            armyStr:setAnchorPoint(ccp(0.5,0.5))
                                            armyStr:setPosition(ccp(hCellWidth*i/6+((i-1)*70),cellHeight-90-((pos-1)*k)))
                                            cell:addChild(armyStr,2)
                                            armyStr:setColor(showColor[i])
                                        end
                                        if tankCfg[v.id].isElite==1 then
                                            local pickedSp = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                                            -- pickedSp:setScale()
                                            pickedSp:setAnchorPoint(ccp(0.5,0.5))
                                            pickedSp:setPosition(ccp(15,cellHeight-90-(49*k)))
                                            cell:addChild(pickedSp,2)
                                        end
                                        if k == SizeOfTable(attOrDefTotal) then
                                            defHeight =cellHeight-90-((pos-1)*k)
                                        end
                                    end
                                end
                                if i==2 then
                                    for k,v in pairs(attOrDefTotal) do
                                        table.insert(localLeaves,{num=v.num})
                                        -- G_dayin(localLeaves)
                                    end
                                    for k,v in pairs(attOrDefTotal) do
                                        if v and v.num then
                                            localStr=v.num
                                            local armyStr =GetTTFLabelWrap(localStr,self.txtSize,CCSizeMake(backSprie4:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                                            armyStr:setAnchorPoint(ccp(0.5,0.5))
                                            armyStr:setPosition(ccp(hCellWidth*i/7+((i-1)*70),cellHeight-90-((pos-1)*k)))
                                            cell:addChild(armyStr,2)
                                            armyStr:setColor(showColor[i])
                                            
                                        end                                 
                                    end
                                end
                                if i==3 then
                                    local lostNum
                                    if SizeOfTable(attOrDefLost) ==0 then
                                        lostNum =attOrDefTotal
                                    elseif SizeOfTable(attOrDefLost) >0 and SizeOfTable(attOrDefLost) ~=SizeOfTable(attOrDefTotal) then
                                        local ishere =0
                                        for k,v in pairs(attOrDefTotal) do
                                            for m,n in pairs(attOrDefLost) do
                                                if m then
                                                    if v.id ==n.id then
                                                        ishere =0
                                                        break
                                                    else
                                                        ishere =1
                                                    end
                                                end
                                            end
                                            if ishere ==1 then
                                                table.insert(attOrDefLost,v)
                                                for h,j in pairs(attOrDefLost) do
                                                     if j.id ==v.id then
                                                        j.num =0
                                                     end
                                                end
                                                ishere =0
                                            end
                                        end                                     
                                        lostNum =attOrDefLost
                                    else
                                        lostNum =attOrDefLost
                                    end
                                    local function sortAsc(a, b)
                                        if sortByIndex then
                                            if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
                                                return a.id < b.id
                                            end
                                        else
                                            if a.type==b.type then
                                                if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
                                                    return a.id < b.id
                                                end
                                            end
                                        end
                                    end
                                    table.sort(lostNum,sortAsc)                                 
                                    for k,v in pairs(lostNum) do
                                        if v and v.num and SizeOfTable(attOrDefLost) >=1 then
                                            localStr=v.num
                                        else
                                            localStr=0
                                        end
                                            local armyStr =GetTTFLabelWrap(localStr,self.txtSize,CCSizeMake(backSprie4:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                                            armyStr:setAnchorPoint(ccp(0.5,0.5))
                                            armyStr:setPosition(ccp(hCellWidth*i/7+((i-1)*70),cellHeight-90-((pos-1)*k)))
                                            cell:addChild(armyStr,2)
                                            armyStr:setColor(showColor[i])
                                            if localLeaves and localLeaves[k] and localLeaves[k].num then
                                                localLeaves[k].num=localLeaves[k].num-localStr
                                            end
                                    end
                                end
                                if i==4 then
                                    for k,v in pairs(localLeaves) do
                                        if v and v.num then
                                            localStr=v.num
                                            local armyStr =GetTTFLabelWrap(localStr,self.txtSize,CCSizeMake(backSprie4:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                                            armyStr:setAnchorPoint(ccp(0.5,0.5))
                                            armyStr:setPosition(ccp(hCellWidth*i/7+((i-1)*70),cellHeight-90-((pos-1)*k)))
                                            cell:addChild(armyStr,2)
                                            armyStr:setColor(showColor[i])
                                        end                                 
                                    end
                                    localLeaves =nil
                                end                     
                            end                     
                        end
                        if SizeOfTable(attOrDefTotal) >=1 then
                            repairStr=getlocal("alienMines_battle_content_tip")
                            local repairLb =GetTTFLabelWrap(repairStr,25,CCSizeMake(backSprie4:getContentSize().width-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                            repairLb:setPosition(ccp(10,defHeight-70+10))
                            repairLb:setAnchorPoint(ccp(0,0.5))
                            cell:addChild(repairLb,2)
                            repairLb:setColor(G_ColorOrange2)
                        end
                    else
                        backSprie4:setPosition(ccp(0, perSpace*(4+attackerLostNum+defenderLostNum)+10))
                        
                        --local lostStr=""
                        local isAttacker=alienMinesEmailVoApi:isAttacker(report,self.chatSender)      
                        attackerStr=getlocal("fight_content_attacker",{attacker}).."\n"
                        table.insert(content,{attackerStr,htSpace})
                        for k,v in pairs(attLost) do
                            if v and v.name and v.num then
                                attackerLost=attackerLost.."    "..(v.name).." -"..tostring(v.num).."\n"
                            end
                        end
                        table.insert(content,{attackerLost,perSpace+htSpace,G_ColorRed})
                        local defendName=defender
                        if hasHelpDefender==true then
                            defendName=helpDefender
                        end
                        if isAttacker==true then
                            if report.islandType==6 then
                                defenderStr=defenderStr..getlocal("fight_content_defender",{defendName}).."\n"
                            else
                                if report.islandOwner>0 then
                                    defenderStr=defenderStr..getlocal("fight_content_defender",{defendName}).."\n"
                                else
                                    defenderStr=defenderStr..getlocal("fight_content_defender",{G_getAlienIslandName(islandType)}).."\n"
                                end
                            end
                        else
                            --defenderStr=defenderStr..getlocal("fight_content_defender",{playerVoApi:getPlayerName()}).."\n"
                            defenderStr=defenderStr..getlocal("fight_content_defender",{defendName}).."\n"
                        end
                        table.insert(content,{defenderStr,perSpace*attackerLostNum+perSpace+htSpace})
                        for k,v in pairs(defLost) do
                            if v and v.name and v.num then
                                defenderLost=defenderLost.."    "..(v.name).." -"..tostring(v.num).."\n"
                            end
                        end
                        table.insert(content,{defenderLost,perSpace*attackerLostNum+perSpace*2+htSpace,G_ColorRed})
                        repairStr=getlocal("alienMines_battle_content_tip")
                        table.insert(content,{repairStr,perSpace*(2+attackerLostNum+defenderLostNum)+htSpace})

                        local cellHeight=perSpace*(4+attackerLostNum+defenderLostNum)+htSpace
                        for k,v in pairs(content) do
                            if v~=nil and v~="" then
                                local contentMsg=content[k]
                                local message=""
                                local pos=0
                                local color
                                if type(contentMsg)=="table" then
                                    message=contentMsg[1]
                                    pos=contentMsg[2]
                                    color=contentMsg[3]
                                else
                                    message=contentMsg
                                end
                                if message~=nil and message~="" then
                                    local contentLb=GetTTFLabel(message,self.txtSize)
                                    if k==2 then
                                        contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(backSprie4:getContentSize().width-10,60*attackerLostNum),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                    elseif k==4 then
                                        contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(backSprie4:getContentSize().width-10,60*defenderLostNum),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                    elseif k==5 then
                                        contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(backSprie4:getContentSize().width,60*1.5),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                    end
                                    contentLb:setAnchorPoint(ccp(0,1))
                                    contentLb:setPosition(ccp(10,cellHeight-pos))
                                    cell:addChild(contentLb,2)
                                    if color~=nil then
                                        contentLb:setColor(color)
                                    end
                                end
                            end
                        end
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

function alienMinesEmailDetailDialog:getResHeight(rtype,report)
    if self.resHeight==nil or self.resMsg==nil then
        if rtype==2 then
            local resType=4
            local alienResType=report.islandType
            local resName=getlocal("scout_content_product_"..resType)
            local resNum=tonumber(mapCfg[resType][report.level].resource)
            -- local resStr=getlocal("scout_content_defend",{resName,resNum})
            local alienResName=getlocal("alien_tech_res_name_"..alienResType)
            local rate=alienMineCfg.collect[alienResType].rate
            local alienResNum=math.floor(resNum*rate)
            -- local resStr=getlocal("alienMines_scout_resources_desc_1",{resName,resNum,alienResName,alienResNum})
            
            local msgStr1=getlocal("alienMines_scout_resources_desc_1")
            local msgStr2=getlocal("alienMines_scout_resources_desc_2",{resName,resNum})
            local msgStr3=getlocal("alienMines_scout_resources_desc_3",{alienResName,alienResNum})
            local msgStr4=""
            if report.islandOwner>0 then
                if report.resource~=nil and report.resource[1]~=nil then
                    local cNum=report.resource[1].num
                    -- resStr=resStr.."\n"..getlocal("scout_content_collect_num",{(report.resource[1].name),cNum})
                    -- resStr=resStr.."\n"..getlocal("alienMines_scout_resources_desc_4",{(report.resource[1].name),cNum,alienResName,cNum*rate})
                    msgStr4=getlocal("alienMines_scout_resources_desc_4",{(report.resource[1].name),cNum,alienResName,math.floor(cNum*rate)})

                    -- if base.alien==1 and base.landFormOpen==1 and base.richMineOpen==1 and richLevel and richLevel>0 then
                    --     local collectCfg={}
                    --     if base.richMineOpen==1 and richLevel and richLevel>0 then
                    --         if alienTechCfg.collect[richLevel+1] then
                    --             collectCfg=alienTechCfg.collect[richLevel+1]
                    --         end
                    --     else
                    --         collectCfg=alienTechCfg.collect[1]
                    --     end
                    --     if collectCfg and SizeOfTable(collectCfg)>0 and alienTechCfg.resource[collectCfg.res] then
                    --         local resCfg=alienTechCfg.resource[collectCfg.res]
                    --         local resName=getlocal(resCfg.name)
                    --         local resNum=cNum*collectCfg.rate
                    --         if resName and resNum and resNum>0 then
                    --             resStr=resStr.."\n"..getlocal("scout_content_collect_num",{resName,resNum})
                    --         end
                    --     end
                    -- end
                end
            end
            local msgTab={msgStr1," ",msgStr2," ",msgStr3}
            if msgStr4 and msgStr4~="" then
                table.insert(msgTab," ")
                table.insert(msgTab,msgStr4)
            end
            local height=0
            for k,v in pairs(msgTab) do
                local resourceLabel=GetTTFLabelWrap(v,25,CCSizeMake(25*23,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                height=height+resourceLabel:getContentSize().height
            end
            height=height+50
            
            -- local resourceLabel=GetTTFLabelWrap(resStr,25,CCSizeMake(25*23,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            -- resourceLabel:setAnchorPoint(ccp(0,1))
            -- -- if base.landFormOpen==1 and base.richMineOpen==1 and richLevel and richLevel>0 then
            -- --  resourceLabel:setPosition(ccp(10,190-50-10+50))
            -- --  cell:addChild(resourceLabel,2)
            -- --  backSprie2:setPosition(ccp(0,190-50+50))
            -- -- else
            --     resourceLabel:setPosition(ccp(10,190+150-50-10))
            --     cell:addChild(resourceLabel,2)
            --     backSprie2:setPosition(ccp(0,190+150-50))
            -- -- end

            self.resHeight=height
            self.resMsg=msgTab
        else
            local alienPoint=report.alienPoint
            local aAlienPoint=report.aAlienPoint
            local msgStr1=getlocal("alienMines_return_alien_point",{alienPoint})
            local msgStr2=""
            local msgTab={msgStr1}
            if aAlienPoint and aAlienPoint>-1 then
                msgStr2=getlocal("alienMines_return_alliance_alien_point",{aAlienPoint})
                table.insert(msgTab," ")
                table.insert(msgTab,msgStr2)
            end
            local height=0
            for k,v in pairs(msgTab) do
                local resourceLabel=GetTTFLabelWrap(v,25,CCSizeMake(25*23,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                height=height+resourceLabel:getContentSize().height
            end
            height=height+150*2+50+50

            self.resHeight=height
            self.resMsg=msgTab
        end
    end
    return self.resHeight,self.resMsg
end

--idx:3,4,5,6,7
--return:1.emblem，2.hero，3.accessory，4.lostTanks，5.plane
function alienMinesEmailDetailDialog:getShowType(report,idx)
    local isShowHero=alienMinesEmailVoApi:isShowHero(report)
    local isShowAccessory=alienMinesEmailVoApi:isShowAccessory(report)
    local isShowEmblem=alienMinesEmailVoApi:isShowEmblem(report)
    local isShowPlane=G_isShowPlaneInReport(report,4)
    local showTypeTb={0,0}
    if(isShowPlane)then
        table.insert(showTypeTb,5)
    end
    if(isShowEmblem)then
        table.insert(showTypeTb,1)
    end
    if(isShowHero)then
        table.insert(showTypeTb,2)
    end
    if(isShowAccessory)then
        table.insert(showTypeTb,3)
    end
    table.insert(showTypeTb,4)
    return showTypeTb[idx]
end

-- function alienMinesEmailDetailDialog:setName(name)
--     self.target=name
--     self.targetBoxLabel:setString(self.target)
-- end
    
function alienMinesEmailDetailDialog:dispose()
    self.sendSuccess=nil
    self.layerNum=nil
    self.eid=nil
    self.emailType=nil
    self.target=nil
    self.theme=nil
    self.replayBtn=nil
    self.attackBtn=nil
    self.writeBtn=nil
    self.deleteBtn=nil
    self.sendBtn=nil
    self.feedBtn=nil
    self.chatSender=nil
    self.chatReport=nil
    self.canSand=nil
    self.txtSize=nil
    self.themeBoxLabel=nil
    self.cellHight=nil
    self.awardHeight=nil
    self.resHeight=nil
    self.resMsg=nil
    
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage.plist")
    
    -- if G_isCompressResVersion()==true then
    --     CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.png")
    -- else
    --     CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.pvr.ccz")
    -- end
    self=nil
end






