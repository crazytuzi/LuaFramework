acCuikulaxiuTab2={

}

function acCuikulaxiuTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    return nc
end

function acCuikulaxiuTab2:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum

    self:initTableView()
    return self.bgLayer
end



function acCuikulaxiuTab2:initTableView()

  local function click(hd,fn,idx)
  end
  local titleBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
  titleBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50, 200))
  titleBg:ignoreAnchorPointForPosition(false)
  titleBg:setAnchorPoint(ccp(0,1))
  titleBg:setPosition(ccp(25, self.bgLayer:getContentSize().height-165))
  self.bgLayer:addChild(titleBg)

  local h = titleBg:getContentSize().height
  local rankStr = ""
  local myRank = acCuikulaxiuVoApi:getMyRank()
  if myRank and myRank>=1 and myRank<=10 then
    rankStr= tostring(myRank)
  else
    rankStr = "10+"
  end
  local rank = GetTTFLabel(rankStr,30)
  rank:setAnchorPoint(ccp(0,0))
  rank:setPosition(40,h/2)
  rank:setColor(G_ColorYellowPro)
  titleBg:addChild(rank)

  local myRankLb = GetTTFLabelWrap(getlocal("activity_cuikulaxiu_myRank"),25,CCSizeMake(titleBg:getContentSize().width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  myRankLb:setAnchorPoint(ccp(0,0))
  myRankLb:setPosition(10,h/2+rank:getContentSize().height)
  titleBg:addChild(myRankLb)

  local jungongLb = GetTTFLabelWrap(getlocal("activity_cuikulaxiu_acHadPoint"),25,CCSizeMake(self.bgLayer:getContentSize().width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  jungongLb:setAnchorPoint(ccp(0,1))
  jungongLb:setPosition(10,h/2)
  titleBg:addChild(jungongLb)

  local acMedals = acCuikulaxiuVoApi:getMyPoint()
  self.medalsLb = GetTTFLabel(acMedals,30)
  self.medalsLb:setAnchorPoint(ccp(0,1))
  self.medalsLb:setPosition(40,h/2-jungongLb:getContentSize().height)
  titleBg:addChild(self.medalsLb)
  self.medalsLb:setColor(G_ColorYellowPro)

  
  local function showInfo()
      PlayEffect(audioCfg.mouseClick)
      local tabStr={};
      local tabColor ={};
      local td=smallDialog:new()
      local rankRewardCfg = acCuikulaxiuVoApi:getRankRewardCfg()
      local rewardTip = ""
      for k,v in pairs(rankRewardCfg) do
        rewardTip=rewardTip..self:getRankRewardStr(v).."\n"
      end    
      local labelSize = 20
      if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
        labelSize =25
      end
      tabStr = {rewardTip,"\n",getlocal("award"),"\n",getlocal("activity_cuikulaxiu_rankTip3"),"\n",getlocal("activity_cuikulaxiu_rankTip2",{acCuikulaxiuVoApi:getRankMinPoint()}),"\n",getlocal("activity_cuikulaxiu_rankTip1"),"\n",getlocal("shuoming")}
      local dialog=td:init("PanelPopup.png",CCSizeMake(600,400),CCRect(0, 0, 450, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,labelSize,{nil,nil,G_ColorGreen,nil,nil,nil,nil,nil,nil,nil,G_ColorGreen,nil},nil,true)
      sceneGame:addChild(dialog,self.layerNum+1)
  end

  local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",showInfo,11,nil,nil)
  --infoItem:setScale(0.8)
  infoItem:setAnchorPoint(ccp(1,0.5))
  local infoBtn = CCMenu:createWithItem(infoItem);
  infoBtn:setAnchorPoint(ccp(1,0.5))
  infoBtn:setPosition(ccp(titleBg:getContentSize().width-35,titleBg:getContentSize().height/2))
  infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
  titleBg:addChild(infoBtn,3); 

  local function click(hd,fn,idx)
  end
  local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),click)
  tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,self.bgLayer:getContentSize().height-475))
  tvBg:ignoreAnchorPointForPosition(false)
  tvBg:setAnchorPoint(ccp(0,0))
  tvBg:setPosition(ccp(25, 110))
  self.bgLayer:addChild(tvBg)

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

          local awardCfg = acCuikulaxiuVoApi:getRewardByRank(myRank)
          if awardCfg then
            local award = FormatItem(awardCfg)
            if award then
              for k,v in pairs(award) do
                G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
              end
              G_showRewardTip(award)
            end
          end
          acCuikulaxiuVoApi:updateHadRankReward()
          acCuikulaxiuVoApi:updateShow()
          self:updateBtShow()
        end
      end

      socketHelper:activityCuikulaxiuRankReward(rewardCallback)
    end

    self.rewardBtn =GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",rewardHandler,3,getlocal("daily_scene_get"),28)
    self.rewardBtn:setAnchorPoint(ccp(0.5, 0))
    self.rewardMenu=CCMenu:createWithItem(self.rewardBtn)
    self.rewardMenu:setPosition(ccp(G_VisibleSizeWidth/2,30))
    self.rewardMenu:setTouchPriority(-(self.layerNum-1)*20-8)
    self.bgLayer:addChild(self.rewardMenu) 

    self:updateBtShow()

end

function acCuikulaxiuTab2:updateBtShow()
  if acCuikulaxiuVoApi:checkIfCanRankReward() == true  then
      self.rewardMenu:setVisible(true)
    else
      self.rewardMenu:setVisible(false)
  end
end

function acCuikulaxiuTab2:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return SizeOfTable(acCuikulaxiuVoApi.rankList)
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize = CCSizeMake(G_VisibleSizeWidth-50,76)
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    

    local acVo = acCuikulaxiuVoApi:getAcVo()
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

      rankCfg = acCuikulaxiuVoApi.rankList[idx+1]

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
          local uid = rankCfg[1]
          if tonumber(uid)==tonumber(playerVoApi:getUid()) then
            name = playerVoApi:getPlayerName()
          end
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


function acCuikulaxiuTab2:tick()

end


--用户处理特殊需求,没有可以不写此方法
function acCuikulaxiuTab2:initTitles(bg)

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


    local pointLabel=GetTTFLabelWrap(getlocal("alliance_medals"),lbSize,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    pointLabel:setPosition(getX(3),height)
    bg:addChild(pointLabel,1)
    pointLabel:setColor(color)

end

function acCuikulaxiuTab2:getRankRewardStr(reawrdCfg)
  local str = ""
  local awardStr=""
  local rank1
  local rank2
  for k,v in pairs(reawrdCfg) do
    if k ==1 then
      if v[1] and v[2]  then
        rank1 = v[1]
        rank2 = v[2]
      end
    elseif k==2 and v then
      local award = FormatItem(v)
      for k,v in pairs(award) do
            local nameStr=v.name
            if v.type=="c" then
                nameStr=getlocal(v.name,{v.num})
            end
            if k==SizeOfTable(award) then
                awardStr = awardStr..nameStr .. " x" .. v.num
            else
                awardStr = awardStr..nameStr .. " x" .. v.num .. ","
            end
        end
    end
  end
  if rank1 == rank2 then
    str = getlocal("activity_cuikulaxiu_rankToReward",{rank1,awardStr})
  else
    str = getlocal("activity_cuikulaxiu_rankTorankReward",{rank1,rank2,awardStr})
  end
  return str
end

function acCuikulaxiuTab2:dispose()
  self.bgLayer:removeFromParentAndCleanup(true)
  self.bgLayer=nil
  self.tv=nil
  self.layerNum=nil
  self = nil 
end
