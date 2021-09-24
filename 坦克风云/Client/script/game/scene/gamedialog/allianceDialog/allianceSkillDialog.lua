--require "luascript/script/componet/commonDialog"
allianceSkillDialog=commonDialog:new()

--jumpIdx:要定位到哪个科技
function allianceSkillDialog:new(tabType,layerNum,jumpIdx,closeCallback)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.layerNum=layerNum
    self.closeCallback = closeCallback
    self.expandHeight2=G_VisibleSize.height-120
    self.normalHeight2=150
    self.extendSpTag2=113
    self.header2Tb={}
    self.requires={}
    self.jumpIdx=jumpIdx
   
    return nc 
end

--设置或修改每个Tab页签
function allianceSkillDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)

         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end    
    
end

function allianceSkillDialog:doSendOnClose( ... )
    if self.closeCallback and type(self.closeCallback) == "function" then
      self.closeCallback()
    end
end


--设置对话框里的tableView
function allianceSkillDialog:initTableView()
    spriteController:addPlist("public/allianceSkills.plist")
    spriteController:addTexture("public/allianceSkills.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/newAlliance.plist")
    spriteController:addTexture("public/newAlliance.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.allianceLv=allianceVoApi:getSelfAlliance().level
    
    local function callBack2(...)
       return self:eventHandler2(...)
    end
    local hd2= LuaEventHandler:createHandler(callBack2)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd2,CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-120),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,20))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    if self.jumpIdx then --跳转到指定科技的位置
      local recordPoint=self.tv:getRecordPoint()
      self.tv:reloadData()
      local jumpHeight=self.jumpIdx*self.normalHeight2
      self.tv:recoverToRecordPoint(ccp(recordPoint.x,recordPoint.y+jumpHeight))
      self:cellClick(self.jumpIdx+1000)
      self.jumpIdx=nil
    end

end
--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function allianceSkillDialog:eventHandler2(handler,fn,idx,cel)
if fn=="numberOfCellsInTableView" then
           local num=SizeOfTable(allianceSkillCfg)+1;
           return num

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       if self.expandIdx["k"..idx]~=nil then
          tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.expandHeight2)
       else
          tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.normalHeight2)
       end
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
        
       local cell=CCTableViewCell:new()
       cell:autorelease()
       
       local expanded=false
       if self.expandIdx["k"..idx]==nil then
             expanded=false
       else
             expanded=true
       end
       if expanded then
            cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, self.expandHeight2))
       else
            cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, self.normalHeight2))
       end
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(65, 25, 1, 1);
       
       local function cellClick(hd,fn,idx)
           if G_checkClickEnable()==false then
                do
                    return
                end
           else
                base.setWaitTime=G_getCurDeviceMillTime()
           end
           return self:cellClick(idx)
       end
       
       local kuangRect = CCRect(15,15,2,2)
       local bgName="rankKuang.png"
       if idx==0 then
          bgName="newItemKuang.png"
       end
       
       local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName(bgName,kuangRect,cellClick)
       backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20, self.normalHeight2-10))
       backSprie:ignoreAnchorPointForPosition(false);
       backSprie:setAnchorPoint(ccp(0,0));
       backSprie:setTag(1000+idx)
       backSprie:setIsSallow(false)
       backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
       backSprie:setPosition(ccp(0,cell:getContentSize().height-backSprie:getContentSize().height));
       cell:addChild(backSprie,1)
       
       self.header2Tb[idx+1]=backSprie

       local iconName=nil
       local nameAndLvStr=nil
       local notOpen = false -- 功能未开启

       if idx==0 then
          iconName="alliance_icon.png"
           if allianceVoApi:getSelfAlliance().level>=allianceVoApi:getMaxLevel() then
            nameAndLvStr=getlocal("alliance_scene_level").."("..getlocal("alliance_lvmax")..")"
          else
            nameAndLvStr=getlocal("alliance_scene_level").."("..G_LV()..allianceVoApi:getSelfAlliance().level..")"
          end

       else
            iconName=allianceSkillCfg[idx].imageName

            if (allianceSkillCfg[idx].sid=="22" or allianceSkillCfg[idx].sid=="23") and base.allianceCitySwitch==0 then
                notOpen = true
            elseif (allianceSkillCfg[idx].sid=="24") and base.isAf==0 then
                notOpen = true
            end

        if notOpen then
          nameAndLvStr=nil
        else
          local skillLv=allianceSkillVoApi:getAllSkills()[idx].level
          if skillLv>=allianceSkillVoApi:getSkillMaxLevel(idx) then
             nameAndLvStr=getlocal(allianceSkillCfg[idx].name).."("..getlocal("alliance_lvmax")..")"
          else
            nameAndLvStr=getlocal(allianceSkillCfg[idx].name).."("..G_LV()..skillLv..")"
          end
          if allianceSkillCfg[idx].sid=="99" then
             nameAndLvStr=getlocal(allianceSkillCfg[idx].name)
          end
        end
       end

       local iconSp=CCSprite:createWithSpriteFrameName(iconName)
       iconSp:setAnchorPoint(ccp(0,0.5))
       iconSp:setPosition(ccp(10,backSprie:getContentSize().height/2))
       backSprie:addChild(iconSp)

       if nameAndLvStr then

         local function nilFunc( ... )
            -- body
        end
        local titleSpire = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),nilFunc)
        titleSpire:setContentSize(CCSizeMake(G_VisibleSizeWidth-300-20,32))
        titleSpire:setAnchorPoint(ccp(0,0.5))
        backSprie:addChild(titleSpire)
        titleSpire:setPosition(ccp(10+iconSp:getContentSize().width+20,backSprie:getContentSize().height-40))

         local nameLb=GetTTFLabelWrap(nameAndLvStr,24,CCSizeMake(24*18,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
         nameLb:setPosition(iconSp:getPositionX()+iconSp:getContentSize().width+20+15,backSprie:getContentSize().height-40)
         nameLb:setAnchorPoint(ccp(0,0.5));
         nameLb:setColor(G_ColorYellowPro2)
         nameLb:setTag(9)
         backSprie:addChild(nameLb,2)
       end

       if idx~=0 then
        if notOpen then
          local unlockLb=GetTTFLabelWrap(getlocal("backstage180"),24,CCSizeMake(24*16,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
          unlockLb:setPosition(ccp(iconSp:getPositionX()+20+iconSp:getContentSize().width+15,backSprie:getContentSize().height/2))
          unlockLb:setColor(G_ColorRed)
          unlockLb:setAnchorPoint(ccp(0,0.5))
          backSprie:addChild(unlockLb,2)
        else
          if tonumber(allianceSkillCfg[idx].allianceUnlockLevel)<=allianceVoApi:getSelfAlliance().level then
                
                local skillLv,curExp,curMaxExp,percent=allianceSkillVoApi:getSkillLvAndExpAndPerById(idx)
                -- print("sid , skillLv , curExp , curMaxExp , percent ====== ",idx,skillLv,curExp,curMaxExp,percent)
                if allianceSkillCfg[idx].sid=="99" then
                    AddProgramTimer(backSprie,ccp(backSprie:getContentSize().width/2,40),10,11,"","skillBg.png","skillBar.png",11)
                    local ccprogress=backSprie:getChildByTag(10)
                    ccprogress=tolua.cast(ccprogress,"CCProgressTimer")
                    ccprogress:setPercentage(percent)
                else
                   AddProgramTimer(backSprie,ccp(backSprie:getContentSize().width/2,40),10,11,curExp.."/"..curMaxExp,"skillBg.png","skillBar.png",11)
                   local ccprogress=backSprie:getChildByTag(10)
                   ccprogress=tolua.cast(ccprogress,"CCProgressTimer")
                   ccprogress:setPercentage(percent)
                end

                
          else

              local unlockLb=GetTTFLabelWrap(getlocal("alliance_skillUnlockLv",{allianceSkillCfg[idx].allianceUnlockLevel}),24,CCSizeMake(24*16,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
               unlockLb:setPosition(ccp(20+iconSp:getContentSize().width+15+iconSp:getPositionX(),40))
               unlockLb:setColor(G_ColorRed)
               unlockLb:setAnchorPoint(ccp(0,0.5))
               backSprie:addChild(unlockLb,2)

          end
        end
       else
           local allianceLv,curExp,curMaxExp,percent =allianceVoApi:getLvAndExpAndPer()
           AddProgramTimer(backSprie,ccp(backSprie:getContentSize().width/2,50),10,11,curExp.."/"..curMaxExp,"skillBg.png","skillBar.png",11)
           local ccprogress=backSprie:getChildByTag(10)
           ccprogress=tolua.cast(ccprogress,"CCProgressTimer")
           ccprogress:setPercentage(percent)
       end

       


       --显示加减号
       local btn
       if expanded==false then
           btn=CCSprite:createWithSpriteFrameName("sYellowAddBtn.png")
       else
           btn=CCSprite:createWithSpriteFrameName("sYellowSubBtn.png")
       end
       btn:setAnchorPoint(ccp(0,0.5))
       btn:setPosition(ccp(backSprie:getContentSize().width-10-btn:getContentSize().width,backSprie:getContentSize().height/2))
       backSprie:addChild(btn)
       btn:setTag(self.extendSpTag2)
       
       if expanded==true then --显示展开信息
           
          local function touchHander()
          
          end
          local capInSet = CCRect(15,15,2,2);
          local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",capInSet,touchHander)
          exBg:setAnchorPoint(ccp(0.5,0))
          exBg:setContentSize(CCSize(G_VisibleSizeWidth-20,self.expandHeight2-self.normalHeight2-150-20-30))
          exBg:setPosition(ccp((G_VisibleSizeWidth-20)/2,4))
          exBg:setTag(2)
          cell:addChild(exBg)

           local desStr=nil
           if idx==0 then
              desStr=getlocal("alliance_des")
           else
              desStr=getlocal(allianceSkillCfg[idx].description)
           end
           
           local labelSize = CCSize(G_VisibleSizeWidth-40,100);

          local declarationBg =LuaCCScale9Sprite:createWithSpriteFrameName("newAlliance_desc1.png",CCRect(198,24, 2, 2),function()end)
          declarationBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,135))
          declarationBg:setAnchorPoint(ccp(0.5,1))
          declarationBg:setPosition(ccp(exBg:getContentSize().width/2,exBg:getContentSize().height+170))
          declarationBg:setIsSallow(false)
          exBg:addChild(declarationBg)

          local noticeLable = GetTTFLabel(getlocal("newalliance_skillTip"),25,true)
          noticeLable:setColor(G_ColorYellowPro2)
          noticeLable:setAnchorPoint(ccp(0.5,0))
          noticeLable:setPosition(ccp(exBg:getContentSize().width/2,exBg:getContentSize().height+170-18))
          exBg:addChild(noticeLable)

           
           -- local desLbTip1=GetTTFLabelWrap(getlocal("alliance_skillTip"),21,CCSizeMake(21*7,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
           -- desLbTip1:setPosition(ccp(20,self.expandHeight2-self.normalHeight2-80-15))
           -- desLbTip1:setColor(G_ColorYellowPro)
           -- desLbTip1:setAnchorPoint(ccp(0,0.5))
           -- exBg:addChild(desLbTip1,2)

           local desLb=GetTTFLabelWrap(desStr,21,CCSize(G_VisibleSizeWidth-60,100),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
           desLb:setPosition(exBg:getContentSize().width/2,exBg:getContentSize().height+170-20);
           desLb:setAnchorPoint(ccp(0.5,1));
           exBg:addChild(desLb,2)
           --[[xw
           local desLbTip2=GetTTFLabel(getlocal("alliance_donateTip"),21)
           desLbTip2:setPosition(ccp(20,exBg:getContentSize().height+25))
           desLbTip2:setColor(G_ColorYellowPro)
           desLbTip2:setAnchorPoint(ccp(0,0))
           exBg:addChild(desLbTip2,2)
           
           local desLb2=GetTTFLabelWrap(getlocal("alliance_skillNotice"),21,labelSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
           desLb2:setPosition(desLbTip2:getPositionX()+desLbTip2:getContentSize().width+10,exBg:getContentSize().height);
           desLb2:setAnchorPoint(ccp(0,0));
           --desLb2:setColor(G_ColorGreen)
           exBg:addChild(desLb2,2)
           ]]
           
         local aDonate=allianceDonate:new()
           aDonate:create(exBg,idx,self.layerNum,self.tv)
           self.requires[idx+1]=aDonate
 
       end

       return cell;

       elseif fn=="ccTouchBegan" then
           self.isMoved=false
           return true
       elseif fn=="ccTouchMoved" then
           self.isMoved=true
       elseif fn=="ccTouchEnded"  then
           
       elseif fn=="ccScrollEnable" then
           if newGuidMgr:isNewGuiding()==true then
                return 0
           else
                return 1
           end
        end

end

--点击tab页签 idx:索引
function allianceSkillDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self:tabClickColor(idx)
            self:doUserHandler()
         else
            v:setEnabled(true)
         end
    end
    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function allianceSkillDialog:doUserHandler()
  if self.panelLineBg then
    self.panelLineBg:setVisible(false)
  end

  if self.panelTopLine then
    self.panelTopLine:setVisible(false)
  end

  local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
  panelBg:setAnchorPoint(ccp(0.5,0))
  panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
  panelBg:setPosition(G_VisibleSizeWidth/2,5)
  self.bgLayer:addChild(panelBg)

end

--点击了cell或cell上某个按钮
function allianceSkillDialog:cellClick(idx)
  if allianceSkillCfg[(idx-1000)] and allianceSkillCfg[(idx-1000)].sid then
    local sid=allianceSkillCfg[(idx-1000)].sid
    if sid=="22" or sid=="23" then
      if base.allianceCitySwitch==0 then --军团城市相关科技做开关判断
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26000"),28)
        do return end
      elseif allianceCityVoApi:hasCity()==false then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26003"),28)
        do return end
      end
    elseif sid=="24" and base.isAf == 0 then
      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("allianceFlagNotOpen"),28)
      do return end
    end
  end

    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,self.normalHeight2)
        else
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,self.expandHeight2)
        end
    end
end

function allianceSkillDialog:tick()
    for k,v in pairs(self.requires) do
            if self.expandIdx["k"..k-1]~=nil then
                v:tick()
            end
        end
        
        if self.allianceLv~=allianceVoApi:getSelfAlliance().level then
            self.tv:reloadData()
            self.allianceLv=allianceVoApi:getSelfAlliance().level
        end

        for k,v in pairs(self.header2Tb) do
            local timerSpriteLv=v:getChildByTag(10)

            local lvLb=v:getChildByTag(9)
            local nameAndLvStr=nil
            local lvmaxLb=v:getChildByTag(15)
            if timerSpriteLv~=nil then
                local lbPrNum=timerSpriteLv:getChildByTag(11)
                local skillLv,curExp,curMaxExp,percent=0,0,0,0
                if k==1 then
                    
                    skillLv,curExp,curMaxExp,percent =allianceVoApi:getLvAndExpAndPer()
                    if allianceVoApi:getSelfAlliance().level>=allianceVoApi:getMaxLevel() then
                      nameAndLvStr=getlocal("alliance_scene_level").."("..getlocal("alliance_lvmax")..")"
                    else
                      nameAndLvStr=getlocal("alliance_scene_level").."("..G_LV()..skillLv..")"
                    end

                else
                    skillLv,curExp,curMaxExp,percent=allianceSkillVoApi:getSkillLvAndExpAndPerById(k-1)
                    if skillLv>=allianceSkillVoApi:getSkillMaxLevel(k-1) then
                      nameAndLvStr=getlocal(allianceSkillCfg[k-1].name).."("..getlocal("alliance_lvmax")..")"
                    else
                      nameAndLvStr=getlocal(allianceSkillCfg[k-1].name).."("..G_LV()..skillLv..")"
                    end
                    if k==#self.header2Tb then
                      nameAndLvStr=getlocal(allianceSkillCfg[k-1].name)
                    end 
                end
                lvLb=tolua.cast(lvLb,"CCLabelTTF")
                lbPrNum=tolua.cast(lbPrNum,"CCLabelTTF")
                lvmaxLb=tolua.cast(lvmaxLb,"CCLabelTTF")
                timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
                lvLb:setString(nameAndLvStr)
                local str = curExp.."/"..curMaxExp
                if k==#self.header2Tb then
                    str=""
                end
                lbPrNum:setString(str)
                timerSpriteLv:setPercentage(percent)
            end

        end

end

function allianceSkillDialog:dispose()
    self.expandIdx=nil
    self.jumpIdx=nil
    self=nil
    spriteController:removePlist("public/allianceSkills.plist")
    spriteController:removeTexture("public/allianceSkills.png")
    spriteController:removePlist("public/newAlliance.plist")
    spriteController:removeTexture("public/newAlliance.png")
end




