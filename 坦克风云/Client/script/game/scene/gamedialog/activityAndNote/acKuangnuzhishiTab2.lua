acKuangnuzhishiTab2={

}

function acKuangnuzhishiTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    return nc
end

function acKuangnuzhishiTab2:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum

    self:initTableView()
    return self.bgLayer
end



function acKuangnuzhishiTab2:initTableView()

	local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
	  backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,150))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
	  backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-165))
    self.bgLayer:addChild(backSprie,1)

    local function showInfo()
    	 --propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,true,getlocal("activity_kuangnuzhishi_scores",{item.score[1],item.score[2]}))
    end
    local icon = LuaCCSprite:createWithSpriteFrameName("SpecialBox.png",showInfo)
    icon:setAnchorPoint(ccp(0,0.5))
    icon:setPosition(20,backSprie:getContentSize().height/2)
    backSprie:addChild(icon)

    self.descTv,self.descLb=G_LabelTableView(CCSize(backSprie:getContentSize().width-180,backSprie:getContentSize().height-20),getlocal("activity_kuangnuzhishi_rankContent",{acKuangnuzhishiVoApi:getRankLimit()}),25,kCCTextAlignmentCenter)
    self.descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.descTv:setAnchorPoint(ccp(0,0))
    self.descTv:setPosition(ccp(140,10))
    backSprie:addChild(self.descTv,2)
    self.descTv:setMaxDisToBottomOrTop(50)

    local rewardSprie =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
	  rewardSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,120))
    rewardSprie:ignoreAnchorPointForPosition(false)
    rewardSprie:setAnchorPoint(ccp(0.5,1))
    rewardSprie:setIsSallow(false)
    rewardSprie:setTouchPriority(-(self.layerNum-1)*20-2)
	  rewardSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-320))
    self.bgLayer:addChild(rewardSprie,1)

    self.myScores = GetTTFLabelWrap(getlocal("activity_kuangnuzhishi_myScores",{acKuangnuzhishiVoApi:getMyScores()}),25,CCSizeMake(rewardSprie:getContentSize().width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    self.myScores:setAnchorPoint(ccp(0,1))
    self.myScores:setPosition(20,rewardSprie:getContentSize().height-10)
    rewardSprie:addChild(self.myScores)

    local scoresLimit = GetTTFLabelWrap(getlocal("activity_kuangnuzhishi_rankScoresLimit",{acKuangnuzhishiVoApi:getScoresLimit()}),25,CCSizeMake(rewardSprie:getContentSize().width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    scoresLimit:setAnchorPoint(ccp(0,0))
    scoresLimit:setPosition(20,10)
    rewardSprie:addChild(scoresLimit)
    scoresLimit:setColor(G_ColorYellow)

  local function rewardTip( ... )
    	PlayEffect(audioCfg.mouseClick)
      local tabStr={};
      local tabColor ={};
      local td=smallDialog:new()
      local rankRewardCfg = acKuangnuzhishiVoApi:getRankRewardCfg()
      local rewardTip = ""
      for k,v in pairs(rankRewardCfg) do
        rewardTip=rewardTip..self:getRankRewardStr(v).."\n"
      end
      local labelSize = nil
      if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" then
        labelSize=23
      else
        labelSize=25
      end
      tabStr = {rewardTip,"\n",getlocal("award"),"\n",getlocal("activity_kuangnuzhishi_rankTip2"),"\n",getlocal("activity_kuangnuzhishi_rankTip1"),"\n",getlocal("shuoming")}
      local dialog=td:init("PanelPopup.png",CCSizeMake(600,400),CCRect(0, 0, 450, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,labelSize,{nil,nil,G_ColorGreen,nil,nil,nil,nil,nil,G_ColorGreen,nil},nil,true)
      sceneGame:addChild(dialog,self.layerNum+1)
  end
  local tableItem=GetButtonItem("SlotInfor.png","SlotInfor.png","SlotInfor.png",rewardTip,3,nil,0)
  tableItem:setAnchorPoint(ccp(0.5,0.5))
  local tableBtn=CCMenu:createWithItem(tableItem)
  tableBtn:setTouchPriority(-(self.layerNum-1)*20-5)
  tableBtn:setPosition(ccp(rewardSprie:getContentSize().width-50, rewardSprie:getContentSize().height/2+10))
  rewardSprie:addChild(tableBtn)
--兑奖表TTF
  local tableLb = GetTTFLabelWrap(getlocal("award"), 25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  tableLb:setAnchorPoint(ccp(0.5,1))
  --tableLb:setColor(G_ColorYellowPro)
  tableLb:setPosition(ccp(rewardSprie:getContentSize().width-50, rewardSprie:getContentSize().height/2-20))
  rewardSprie:addChild(tableLb)



  local function click(hd,fn,idx)
  end
  local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),click)
  tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,self.bgLayer:getContentSize().height-560))
  tvBg:ignoreAnchorPointForPosition(false)
  tvBg:setAnchorPoint(ccp(0,0))
  tvBg:setPosition(ccp(25, 110))
  self.bgLayer:addChild(tvBg)

  self.noRankLb = GetTTFLabelWrap(getlocal("activity_kuangnuzhishi_noRankList"),25,CCSizeMake(tvBg:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
  self.noRankLb:setPosition(tvBg:getContentSize().width/2,tvBg:getContentSize().height/2)
  tvBg:addChild(self.noRankLb)
  self.noRankLb:setVisible(false)

  local function callBack(...)
     return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvBg:getContentSize().width-20,tvBg:getContentSize().height-60),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  self.tv:setPosition(ccp(10,10))
  tvBg:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(120)


  self:initTitles(tvBg)
  self:showNoRank()


   local function rewardHandler(tag,object)
      if G_checkClickEnable()==false then
        do
          return
        end
      end
      PlayEffect(audioCfg.mouseClick)
      
      local function rewardCallback(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then  
          if sData.data["kuangnuzhishi"] then
            local awardData=sData.data["kuangnuzhishi"]["clientRankReward"]
            local content = {}
            for k,v in pairs(awardData) do
              local atype = v[1]
              local aID = v[2]
              local num = v[3]
              local award = {}
              local name,pic,desc,id,index,eType,equipId=getItem(aID,atype)
              award={name=name,num=num,pic=pic,desc=desc,id=id,type=atype,index=index,key=aID,eType=eType,equipId=equipId}
              G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
              table.insert(content,award)
            end
             G_showRewardTip(content, true)

            acKuangnuzhishiVoApi:updateHadRankReward()
            acKuangnuzhishiVoApi:updateShow()
            self:updateBtnShow()
          end
        end
      end

      socketHelper:activityKuangnuzhishiRankReward(rewardCallback)
    end

    self.rewardBtn =GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",rewardHandler,3,getlocal("daily_scene_get"),28,1010)
    self.rewardBtn:setAnchorPoint(ccp(0.5, 0))
    self.rewardMenu=CCMenu:createWithItem(self.rewardBtn)
    self.rewardMenu:setPosition(ccp(G_VisibleSizeWidth/2,30))
    self.rewardMenu:setTouchPriority(-(self.layerNum-1)*20-8)
    self.bgLayer:addChild(self.rewardMenu) 

    self:updateBtnShow()

end

function acKuangnuzhishiTab2:showNoRank()
  if SizeOfTable(acKuangnuzhishiVoApi.rankList)<=0 then
     self.noRankLb:setVisible(true)
  else
     self.noRankLb:setVisible(false)
  end
end

function acKuangnuzhishiTab2:updateBtnShow()
  if acKuangnuzhishiVoApi:hadRankReward() ==true then
    self.rewardMenu:setVisible(true)
    self.rewardBtn:setEnabled(false)
    tolua.cast(self.rewardBtn:getChildByTag(1010),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
  elseif acKuangnuzhishiVoApi:checkIfCanRankReward() == true  then
      self.rewardMenu:setVisible(true)
      self.rewardBtn:setEnabled(true)
  else
      self.rewardMenu:setVisible(false)
  end
end

function acKuangnuzhishiTab2:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return SizeOfTable(acKuangnuzhishiVoApi.rankList)
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize = CCSizeMake(G_VisibleSizeWidth-50,76)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    

    local acVo = acKuangnuzhishiVoApi:getAcVo()
    if acVo then
      local backSprie
      local capInSetNew=CCRect(20, 20, 10, 10)
      local capInSet = CCRect(40, 40, 10, 10)
      local function cellClick1(hd,fn,idx)
      end
      if idx==0 then
        backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",capInSetNew,cellClick1)
      elseif idx==1 then
        backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png",capInSetNew,cellClick1)
      elseif idx==2 then
        backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank2ItemBg.png",capInSetNew,cellClick1)
      elseif idx==3 then
        backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rank3ItemBg.png",capInSetNew,cellClick1)
      else
        backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",capInSet,cellClick1)
      end
      backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-70, 72))
      backSprie:ignoreAnchorPointForPosition(false)
      backSprie:setAnchorPoint(ccp(0,0))
      backSprie:setIsSallow(false)
      backSprie:setPosition(ccp(0,0))
      backSprie:setTouchPriority(-42)
      cell:addChild(backSprie,1)
      local height=40
      local w = (G_VisibleSizeWidth-60) / 4
      local function getX(index)
        return w * index+ w/2
      end
      local rankCfg

      rankCfg = acKuangnuzhishiVoApi.rankList[idx+1]

      if rankCfg ~= nil then
        local rankStr=0 -- 排名
        local name="" --名称
        local levStr="" -- 等级
        local pointStr=0 -- 军功
        if rankCfg then
          rankStr=rankCfg[2]
          name = rankCfg[4]
          levStr=rankCfg[5]
          pointStr = rankCfg[3]
        end
        

        local rankSp
        if tonumber(rankStr)==1 then
          rankSp=CCSprite:createWithSpriteFrameName("top1.png")
        elseif tonumber(rankStr)==2 then
          rankSp=CCSprite:createWithSpriteFrameName("top2.png")
        elseif tonumber(rankStr)==3 then
          rankSp=CCSprite:createWithSpriteFrameName("top3.png")
        elseif tonumber(rankStr) == 0 then
          rankStr = getlocal("activity_fbReward_rankLow",{10})
        end
        if rankSp then
          rankSp:setAnchorPoint(ccp(0.5,0.5))
          rankSp:setPosition(ccp(getX(0),height))
          cell:addChild(rankSp,3)
        else
          local rankLabel=GetTTFLabel(rankStr,25)
          rankLabel:setAnchorPoint(ccp(0.5,0.5))
          rankLabel:setPosition(getX(0),height)
          cell:addChild(rankLabel,2)
        end
      
        local nameLabel=GetTTFLabel(name,25)
        nameLabel:setAnchorPoint(ccp(0.5,0.5))
        nameLabel:setPosition(getX(1),height)
        cell:addChild(nameLabel,2)
        
        local levLabel=GetTTFLabel(levStr,25)
        levLabel:setAnchorPoint(ccp(0.5,0.5))
        levLabel:setPosition(getX(2),height)
        cell:addChild(levLabel,2)

        local fightLabel=GetTTFLabel(FormatNumber(pointStr),25)
        fightLabel:setAnchorPoint(ccp(0.5,0.5))
        fightLabel:setPosition(getX(3),height)
        cell:addChild(fightLabel,2)  


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

function acKuangnuzhishiTab2:updateMyScores()
  local scores = acKuangnuzhishiVoApi:getMyScores()
  if self.myScores then
    self.myScores:setString(getlocal("activity_kuangnuzhishi_myScores",{scores}))
  end

end

function acKuangnuzhishiTab2:updateData()
  local function getList(fn,data)
      local ret,sData=base:checkServerData(data)
      if ret==true then
         PlayEffect(audioCfg.mouseClick)

         if sData ~= nil and sData.data.kuangnuzhishi then
            acKuangnuzhishiVoApi:updateRankList(sData.data.kuangnuzhishi, true)
            acKuangnuzhishiVoApi:setLastSt()
            self.getTimes = 0
            if self.tv then
              self.tv:reloadData()
            end
            self:showNoRank()
            self:updateBtnShow()
         end
      end
    end
    print("***********acKuangnuzhishiTab2:updateData******2****")
    socketHelper:activityKuangnuzhishiRankList(getList)
end

function acKuangnuzhishiTab2:tick()

end


--用户处理特殊需求,没有可以不写此方法
function acKuangnuzhishiTab2:initTitles(bg)

   local w = bg:getContentSize().width / 4
   local function getX(index)
     return w * index+ w/2 +5
   end

   local height=bg:getContentSize().height-30
    local lbSize=22
    local widthSpace=80
    local color=G_ColorGreen
    local rankLabel=GetTTFLabel(getlocal("rank"),lbSize)
    rankLabel:setPosition(getX(0),height)
    bg:addChild(rankLabel,1)
    rankLabel:setColor(color)
  
    local nameLabel=GetTTFLabel(getlocal("alliance_scene_button_info_name"),lbSize)
    nameLabel:setPosition(getX(1),height)
    bg:addChild(nameLabel,1)
    nameLabel:setColor(color)
    
    local levelLabel=GetTTFLabel(getlocal("RankScene_level"),lbSize)
    levelLabel:setPosition(getX(2),height)
    bg:addChild(levelLabel,1)
    levelLabel:setColor(color)


    local pointLabel=GetTTFLabel(getlocal("activity_kuangnuzhishi_gotScores"),lbSize)
    pointLabel:setPosition(getX(3),height)
    bg:addChild(pointLabel,1)
    pointLabel:setColor(color)

end

function acKuangnuzhishiTab2:getRankRewardStr(reawrdCfg)
  local str = ""
  local awardStr=""
  local rank1
  local rank2
  local name1 = ""
  local name2 = ""
  local num
  for k,v in pairs(reawrdCfg) do
    if k ==1 then
      if v[1] and v[2]  then
        rank1 = v[1]
        rank2 = v[2]
      end
    elseif k==2 and v then
      local award = FormatItem(v)
      for m,n in pairs(award) do
            local nameStr=n.name
            if n.type=="c" then
                nameStr=getlocal(n.name,{n.num})
            end
            if m==1 then
              name1 = nameStr
            elseif m==2 then
              name2 = nameStr
            end
            num = n.num*100
        end
    end
  end
  awardStr=getlocal("activity_kuangnuzhishi_rankRewardTip",{name1,name2,num})
  if rank1 == rank2 then
    str = getlocal("activity_kuangnuzhishi_rankToReward",{rank1,name1,name2,num})
  else
    str = getlocal("activity_kuangnuzhishi_rankTorankReward",{rank1,rank2,name1,name2,num})
  end
  return str
end

function acKuangnuzhishiTab2:dispose()
  self.bgLayer:removeFromParentAndCleanup(true)
  self.bgLayer=nil
  self.tv=nil
  self.layerNum=nil
  self = nil 
end
