selectHeroDialog={}

function selectHeroDialog:new()
    local nc={
      bgLayer=nil,             --背景sprite
      dialogLayer,         --对话框层
      closeBtn,
      tv,
      mylayerNum,
      bgSize,
      isTouch,
      isUseAmi,
      isMoved,
      keyTable,
      tankTable,
      cellHeight,
      slider,
      totalTroops,
      hei,
      myCell,
      myTouchSp,
      selectedSp,
      topforbidSp, --顶端遮挡层
      bottomforbidSp, --底部遮挡层

    }
    setmetatable(nc,self)
    self.__index=self
    return nc
end
--type:类型 1是防守板子的选择面板 2进攻 3关卡 layerNum:层数 callBack:确定按钮回调
-- cid:领土争夺战要用
function selectHeroDialog:showselectHeroDialog(type,layerNum,callBack,cid)
    base:setWait()
    self.hei=0
    self.bType=type
    if type==7 or type==8 or type==9 then
        self.heroList=heroVoApi:getCanSetHeroList()
    elseif type==11 then
        self.heroList=heroVoApi:getCanSetBestHeroListExpedition()
    elseif type==13 or type==14 or type==15 then
        self.heroList=heroVoApi:getWorldWarCanSetHeroList()
    elseif type==21 or type==22 or type==23 then
        self.heroList=heroVoApi:getPlatWarCanSetHeroList()
    elseif type==24 or type==25 or type==26 then
        self.heroList=heroVoApi:getServerWarLocalCanSetHeroList(type)
    elseif type==35 or type==36 then
        self.heroList=ltzdzFightApi:getCanUseHeroList(type,cid)
    else
        self.heroList=heroVoApi:getSelectHeroList()
    end
    self.selectCallBack=callBack

    
    if self.heroList~=nil then
      local count=SizeOfTable(self.heroList)
      local countR=0
      if count>6 then
        countR=count-6
      end
      self.hei=math.ceil(countR/3)
    end
    self.mylayerNum=layerNum
    local td=selectHeroDialog:new()
    local dia=td:init(layerNum);
    sceneGame:addChild(dia,layerNum)
    base:cancleWait()
end


function selectHeroDialog:init(layerNum)
    self.dialogLayer=CCLayer:create();
    table.insert(G_SmallDialogDialogTb,self)
    local tHeight=900;
    
    for i=1,2 do
        local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
        grayBgSp:setAnchorPoint(ccp(0.5,0.5))
        grayBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
        grayBgSp:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5))
        self.dialogLayer:addChild(grayBgSp)  
    end
    
--背景    
    local function touch()
    
    end
    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local rect=CCRect(0, 0, 400, 350)
    local capInSet=CCRect(168, 86, 10, 10)
    self.bgLayer=G_getNewDialogBg(CCSizeMake(600,tHeight),getlocal("selectHero"),30,touch,layerNum,true,close)
    --LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",capInSet,touch)
    -- self.bgLayer:setContentSize(CCSizeMake(600,tHeight));
    self.bgLayer:setTouchPriority((-(layerNum-1)*20-1))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:addChild(self.bgLayer,1)
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",capInSet,touch);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect=G_VisibleSize
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(0)
    touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(touchDialogBg,1);

    
--title    
    -- local titleLb = GetTTFLabel(getlocal("selectHero"),36);
    -- titleLb:setAnchorPoint(ccp(0.5,0.5));
    -- titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-titleLb:getContentSize().height/2-8));
    -- self.bgLayer:addChild(titleLb,2);
--上面的取消按钮    
    
    
    -- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    --     closeBtnItem:setPosition(0, 0)
    --     closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    -- closeBtnItem:registerScriptTapHandler(close)

    -- self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    -- self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    -- self.closeBtn:setPosition(ccp(self.bgLayer:getContentSize().width-closeBtnItem:getContentSize().width-5,self.bgLayer:getContentSize().height-closeBtnItem:getContentSize().height-5))
    -- self.bgLayer:addChild(self.closeBtn)
        


--拥有坦克的 tableView
    self:initTableView()




     --以下代码处理上下遮挡层
       local function forbidClick()
       
       end
       local rect2 = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       self.topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
       self.topforbidSp:setTouchPriority(-(layerNum-1)*20-3)
       self.topforbidSp:setAnchorPoint(ccp(0,0))
       self.bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
       self.bottomforbidSp:setTouchPriority(-(layerNum-1)*20-3)
       self.bottomforbidSp:setAnchorPoint(ccp(0,0))
       local tvX,tvY=self.tv:getPosition()
       local topY=tvY+self.tv:getViewSize().height
       local topHeight=rect.height-topY
       topHeight = G_isIphone5() and topHeight -80 or topHeight
       topY = G_isIphone5() and topY + 80 or topY
       self.topforbidSp:setContentSize(CCSize(rect.width,topHeight))
       self.topforbidSp:setPosition(0,topY)
       self.dialogLayer:addChild(self.topforbidSp)

       self.dialogLayer:addChild(self.bottomforbidSp)
       self:resetForbidLayer()
       self.topforbidSp:setVisible(false)
       self.bottomforbidSp:setVisible(false)
       --以上代码处理上下遮挡层

    
    return self.dialogLayer

end

--设置对话框里的tableView
function selectHeroDialog:initTableView()
    -- local capInSet = CCRect(20, 20, 10, 10);
    -- local tvBackSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function ()end)
    -- tvBackSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,self.bgLayer:getContentSize().height-115))
    -- tvBackSprie:setAnchorPoint(ccp(0,0));
    -- tvBackSprie:setPosition(ccp(25,15))
    -- self.bgLayer:addChild(tvBackSprie)

    self.cellHeight=self.bgLayer:getContentSize().height-165-85
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-125),nil)
    self.tv:setTableViewTouchPriority((-(self.mylayerNum-1)*20-3))
    self.tv:setPosition(ccp(30,20))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function selectHeroDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
        
       return 1

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize


       
       tmpSize=CCSizeMake(600,self.hei*280+self.cellHeight)

       return tmpSize
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
 
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
           --return self:cellClick(idx)
       end

       local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
       backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.hei*280+self.cellHeight))
       backSprie:ignoreAnchorPointForPosition(false);
       backSprie:setOpacity(0)
       backSprie:setAnchorPoint(ccp(0,0));
       backSprie:setTag(1000+idx)
       backSprie:setIsSallow(false)
       backSprie:setTouchPriority(-42)
       cell:addChild(backSprie,1)
       
       local numX=0
       local numY=0
       
       local function touch(object,name,tag)
            if self.tv:getIsScrolled()==true then
                do
                    return
                end
            end
            PlayEffect(audioCfg.mouseClick)
            local touchSp=cell:getChildByTag(tag)
            self.selectCallBack(self.heroList[tag].hid,self.heroList[tag].productOrder)
            self:close()
          
       end

       if self.heroList~=nil and SizeOfTable(self.heroList)>0 then
           for k,v in pairs(self.heroList) do
              local heroAdjData = nil
              if self.bType==35 or self.bType==36 then
                local heroVo,heroAjt=ltzdzFightApi:getHeroByHid(v.hid)
                if heroAjt then
                  heroAdjData = {adjutants=heroAjt,showAjt=true}  
                end
              end
               local sprite = heroVoApi:getHeroIcon(v.hid,v.productOrder,true,touch,nil,nil,nil,heroAdjData)
               sprite:setAnchorPoint(ccp(0.5,0.5));
               sprite:setTag(k)
          
               sprite:setIsSallow(false)
               sprite:setTouchPriority((-(self.mylayerNum-1)*20-2))
               local wid = sprite:getContentSize().width
               local dis = sprite:getContentSize().height+60            
               sprite:setPosition(24+wid/2+wid*numX+20*numX, self.hei*280+self.cellHeight-dis/2-numY*dis-20*numY+20)
               sprite:setScale(0.7)
               cell:addChild(sprite,2)
               
               local soldiersLbName = GetTTFLabelWrap(heroVoApi:getHeroName(v.hid),24,CCSizeMake(24*7,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
               soldiersLbName:setAnchorPoint(ccp(0.5,1));
               soldiersLbName:setPosition(ccp(wid/2,-30));
               soldiersLbName:setScale(1.2)
               sprite:addChild(soldiersLbName,2);

               local function checkCallback()
                  if self.tv:getIsScrolled()==true then
                    do return end
                  end
                  PlayEffect(audioCfg.mouseClick)
                  require "luascript/script/game/scene/gamedialog/heroDialog/heroShareSmallDialog"
                  -- v.level = heroCfg.heroLevel[v.productOrder]
                  v.gd = v.productOrder

                  adTb = {}
                  for mm,nn in pairs(heroListCfg[v.hid].heroAtt) do
                      table.insert( adTb, mm )
                  end

                  if self.bType==35 or self.bType==36 then

                  else
                    local equipOpenLv=base.heroEquipOpenLv or 30
                    if base.he==1 and playerVoApi:getPlayerLevel()>=equipOpenLv then
                        local newAllAttList={}
                        noData,newAllAttList = heroEquipVoApi:getAttListByHid(v.hid,nil,v.productOrder)
                        for m,n in pairs(newAllAttList) do
                            local ifHas = false
                            for kk,vv in pairs(adTb) do
                                if vv==n.key then
                                    ifHas=true
                                    break
                                end
                            end
                            if ifHas==false then
                                table.insert( adTb, n.key )
                            end
                        end
                    end
                    if heroAdjutantVoApi:isOpen() == true and heroAdjutantVoApi:isCanEquipAdjutant(v) then
                      local adjAttTb = heroAdjutantVoApi:getExtraProperty(v.hid, 1)
                      for m, n in pairs(adjAttTb) do
                        local ifHas = false
                        for kk, vv in pairs(adTb) do
                          if vv == n.key then
                            ifHas = true
                            break
                          end
                        end
                        if ifHas == false then
                          table.insert(adTb, n.key)
                        end
                      end
                    end
                  end
                 
                  local share = self:getShareData(v,adTb)
                  heroShareSmallDialog:showHeroInfoSmallDialog({name=getlocal("heroInfo")},share,self.mylayerNum+1,"TankInforPanel.png",CCRect(130, 50, 1, 1))
                  -- smallDialog:showHeroInfoDialog("PanelPopup.png",CCSizeMake(600,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.mylayerNum+1,v)
               end
               local strSize2 = 30
               if G_getCurChoseLanguage() =="cn" then
                  strSize2 = 38
               end
               local checkItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",checkCallback,nil,getlocal("alliance_list_check_info"),strSize2)
               checkItem:setAnchorPoint(ccp(0.5,1))
               checkItem:setScale(0.9)
              local checkBtn=CCMenu:createWithItem(checkItem);
              checkBtn:setTouchPriority(-(self.mylayerNum-1)*20-2);
              checkBtn:setPosition(ccp(wid/2,-40-soldiersLbName:getContentSize().height))
              sprite:addChild(checkBtn)


               numX=numX+1
               if numX>2 then
                  numX=0
                  numY=numY+1
               end
           end
       elseif base.heroSwitch==1 then
            if self.bType==35 or self.bType==36 then
              local noHeroStr=getlocal("ltzdz_no_hero_des")
              local noHeroLb = GetTTFLabelWrap(noHeroStr,25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
              backSprie:addChild(noHeroLb)
              noHeroLb:setPosition(backSprie:getContentSize().width/2, backSprie:getContentSize().height/2+50)
            else
              local noHeroStr=getlocal("set_troops_no_hero")
              local noHeroLb = GetTTFLabelWrap(noHeroStr,25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
              backSprie:addChild(noHeroLb)
              noHeroLb:setPosition(backSprie:getContentSize().width/2, backSprie:getContentSize().height/2+50)
              -- noHeroLb:setColor(G_ColorYellowPro)

              local function tiaozhuan()
                  if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                      if G_checkClickEnable()==false then
                          do
                              return
                          end
                      else
                          base.setWaitTime=G_getCurDeviceMillTime()
                      end
                      -- 跳转军事学院
                      PlayEffect(audioCfg.mouseClick)
                      self:close()
                      G_closeAllSmallDialog()
                      G_goToDialog("hero",self.mylayerNum,true)
                  end
              end
              local tiaozhuanItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",tiaozhuan,nil,getlocal("activity_heartOfIron_goto"),25)
              tiaozhuanItem:registerScriptTapHandler(tiaozhuan)
              local tiaozhuanMenu=CCMenu:createWithItem(tiaozhuanItem)
              tiaozhuanMenu:setTouchPriority(-(self.mylayerNum-1)*20-2)
              tiaozhuanMenu:setPosition(ccp(backSprie:getContentSize().width/2, backSprie:getContentSize().height/2-50))
              backSprie:addChild(tiaozhuanMenu,2)
            end
       end
        
       self.myCell=cell

       return cell;
       
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function selectHeroDialog:getShareData(heroVo,addAdTb)
  local sbSkillNum,nbSkillNum = SizeOfTable(heroListCfg[heroVo.hid].skills),0
  if heroVoApi:heroHonorIsOpen()==true and heroVo and heroVo.hid then
    if self.bType==35 or self.bType==36 then
      nbSkillNum=#ltzdzFightApi:getUsedRealiseSkill(heroVo.hid)
    else
      nbSkillNum=#heroVoApi:getUsedRealiseSkill(heroVo.hid)
    end
      
  end
  local equipAttList,newAllAttList = heroEquipVoApi:getAttListByHid(heroVo.hid,nil,heroVo.productOrder)
  if heroVo and addAdTb and sbSkillNum and nbSkillNum then
    local atb=heroVoApi:getAddBuffTb(heroVo)
    local share={}
    share.heroVo = heroVo
    share.stype=2 --将领分享类型
    share.name=playerVoApi:getPlayerName()
    share.hid=heroVo.hid --将领id
    share.lv=heroVo.level --将领等级
    share.gd=heroVo.productOrder --将领品阶
    local property={} --属性加成
    local adjAttTb, adjAttList = heroAdjutantVoApi:getExtraProperty(heroVo.hid, 1)
    for i=1,#addAdTb do
      property[i]={}
      local strLb2
      if atb[addAdTb[i]] then
        property[i][1]=atb[addAdTb[i]].."%"
      else
        property[i][1]="-"
      end

      if self.bType==35 or self.bType==36 then
      else
        local pValue = 0
        local equipOpenLv=base.heroEquipOpenLv or 30
        if base.he==1 and playerVoApi:getPlayerLevel()>=equipOpenLv and equipAttList and SizeOfTable(equipAttList) then
          if equipAttList[addAdTb[i]] then
            -- property[i][2]=equipAttList[addAdTb[i]].value.."%"
            -- if addAdTb[i]=="first" then
              -- property[i][2]=equipAttList[addAdTb[i]].value
            -- end
            pValue = equipAttList[addAdTb[i]].value
          end
        end
        if heroAdjutantVoApi:isOpen() == true and heroAdjutantVoApi:isCanEquipAdjutant(heroVo) and adjAttList then
          if adjAttList[addAdTb[i]] then
            pValue = pValue + adjAttList[addAdTb[i]]
          end
        end
        if pValue > 0 then
          property[i][2] = pValue .. "%"
          if addAdTb[i]=="first" then
            property[i][2] = pValue
          end
        end
      end
     
      if property[i][2]==nil then
        property[i][2]="-"
      end
      property[i][3]=addAdTb[i]
    end
    share.p=property --将领的属性的加成
    local skillTb={} --常规技能
    for i=1,sbSkillNum do
      if i>heroVo.productOrder then
        do break end
      end
      local sid=heroListCfg[heroVo.hid].skills[i][1]
      local lvStr,value,isMax,skillLv
      if self.bType==35 or self.bType==36 then
        lvStr,value,isMax,skillLv=ltzdzFightApi:getHeroSkillLvAndValue(heroVo.hid,sid,heroVo.productOrder)
      else
        lvStr,value,isMax,skillLv=heroVoApi:getHeroSkillLvAndValue(heroVo.hid,sid,heroVo.productOrder)
      end

      local awakenSid=sid
      if heroVo.skill[sid]==nil and equipCfg[heroVo.hid]["e1"].awaken.skill then
        local awakenSkill=equipCfg[heroVo.hid]["e1"].awaken.skill
        if awakenSkill[sid] then
          awakenSid=awakenSkill[sid]
        end
      end
      local skill={sid,skillLv,awakenSid}
      skillTb[i]=skill
    end
    share.sb=skillTb --常规技能
    local nbSkillTb={}
    local totalNum=1
    if(heroVoApi:heroHonor2IsOpen())then
      totalNum=totalNum+1
    end
    if(nbSkillNum==0)then
      totalNum=0
    end
    for i=1,totalNum do
      if(i>nbSkillNum)then
        break
      end
      local sid=heroVo.honorSkill[i][1]
      local skillLv=heroVo.honorSkill[i][2]
      local lvStr,value,isMax,skillLv=heroVoApi:getHeroHonorSkillLvAndValue(heroVo.hid,sid,heroVo.productOrder,skillLv)
      if self.bType==35 or self.bType==36 then
        lvStr,value,isMax,skillLv=ltzdzFightApi:getHeroHonorSkillLvAndValue(heroVo.hid,sid,heroVo.productOrder,skillLv)
      else
        lvStr,value,isMax,skillLv=heroVoApi:getHeroHonorSkillLvAndValue(heroVo.hid,sid,heroVo.productOrder,skillLv)
      end
      local skill={sid,skillLv}
      nbSkillTb[i]=skill
    end
    share.nb=nbSkillTb --授勋技能

    if self.bType==35 or self.bType==36 then
        local attriTb={"atk","hlp","hit","cri","eva","res"}
        local totalValeu=ltzdzFightApi:getTotalBufferByHid(heroVo.hid)
        -- if totalValeu[5]>0 then
          for i=1,7 do
            if property[i]==nil then
              property[i]={}
            end
            if i<5 then
              property[i][3]=addAdTb[i]
              for k,v in pairs(attriTb) do
                if v==addAdTb[i] then
                  table.remove(attriTb,k)
                end
              end
               print("addAdTb[i]",addAdTb[i])
              property[i][2]=(totalValeu[addAdTb[i]]-atb[addAdTb[i]]) .. "%"
            else
              for k,v in pairs(attriTb) do
                print(k,v)
              end
              if i==7 then
                property[i][3]="first"
                property[i][2]=totalValeu[i]
              else
                if totalValeu[attriTb[i-4]]==0 then
                  break
                end
                property[i][3]=attriTb[i-4]
                property[i][2]=totalValeu[attriTb[i-4]] .. "%"
              end
              
            end
          end
        -- end
    end

    return share
  end
  return nil
end


--顶部和底部的遮挡层
function selectHeroDialog:resetForbidLayer()
   local tvX,tvY=self.tv:getPosition()
   self.bottomforbidSp:setContentSize(CCSizeMake(640,tvY))
end


function selectHeroDialog:close()

    self.dialogLayer:removeFromParentAndCleanup(true)
    for k,v in pairs(G_SmallDialogDialogTb) do
        if v==self then
            v=nil
            G_SmallDialogDialogTb[k]=nil
        end
    end
end



