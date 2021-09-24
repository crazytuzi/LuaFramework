require "luascript/script/game/scene/gamedialog/Boss/BossBattleRewardDialog"
BossBattleDialogTab2={}

function BossBattleDialogTab2:new( ... )
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.parent=nil
    self.bossKiller=nil
    return nc
end

function BossBattleDialogTab2:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self.bossKiller = BossBattleVoApi:getBossKiller()
    self:initTableView()
    return self.bgLayer
end

function BossBattleDialogTab2:initTableView()
   local headBs=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
    headBs:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,100))
    headBs:setAnchorPoint(ccp(0.5,1))
    headBs:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height - 165))
    self.bgLayer:addChild(headBs,4)

    local killerName = getlocal("alliance_info_content")
    if self.bossKiller then
      killerName = self.bossKiller
    end

    self.killerLb = GetTTFLabelWrap(getlocal("BossBattle_rankDesc",{killerName}),30,CCSizeMake(headBs:getContentSize().width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.killerLb:setAnchorPoint(ccp(0,0.5))
    self.killerLb:setPosition(20,headBs:getContentSize().height/2)
    headBs:addChild(self.killerLb)

    local function goto( ... )
      if G_checkClickEnable()==false then
          do
            return
          end
        end
      BossBattleRewardDialog:create(self.layerNum+1)
    end

    local lookBtn =GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",goto,nil,getlocal("BossBattle_lookReward"),31)
    lookBtn:setScale(0.8)
    lookBtn:setAnchorPoint(ccp(1, 0.5))
    local lookMenu = CCMenu:createWithItem(lookBtn)
    lookMenu:setPosition(ccp(headBs:getContentSize().width-10,headBs:getContentSize().height/2))
    lookMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    headBs:addChild(lookMenu)  



    self.rankList=BossBattleVoApi:getRankList()
    local function nilFun()
    end
    local capInSet = CCRect(20, 20, 10, 10);
    self.backsprite = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",capInSet,nilFun)
    self.backsprite:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-400))
    self.backsprite:setAnchorPoint(ccp(0.5,1))
    self.backsprite:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height - 270)
    self.bgLayer:addChild(self.backsprite)

    self:initTitles()

    local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSP:setAnchorPoint(ccp(0.5,0.5))
    lineSP:setScaleX(self.backsprite:getContentSize().width/lineSP:getContentSize().width)
    lineSP:setScaleY(1.2)
    lineSP:setPosition(ccp(self.backsprite:getContentSize().width/2,self.backsprite:getContentSize().height-50))
    self.backsprite:addChild(lineSP,2)

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.backsprite:getContentSize().width,self.backsprite:getContentSize().height-70),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(0,10))
    self.backsprite:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    self:updateRewardBtn()
end

-- 更新领奖按钮显示
function BossBattleDialogTab2:updateRewardBtn()

  local state = 1
  if BossBattleVoApi:hadRankReward() == true then
      state = 3
  elseif (BossBattleVoApi:getBossState()~=3 and BossBattleVoApi:canRankReward() == true) then
      state = 2
  else
      state = 1
  end

  if self.rewardBtnState ~= state then
      if self.rewardMenu ~= nil then
        self.bgLayer:removeChild(self.rewardMenu,true)
        self.rewardMenu = nil
      end
      self.rewardBtnState = state
      local function hadReward(tag,object)
      end

      local function getReward(tag,object)
        if G_checkClickEnable()==false then
          do
            return
          end
        end
        --领取奖励
        
        local function RewardCallback(fn,data)
          local ret,sData = base:checkServerData(data)
          if ret == true then
            if sData.data.worldboss then
              BossBattleVoApi:onRefreshData(sData.data.worldboss)
            end
            local reward = BossBattleVoApi:getAllReward()
            if reward then
              local content = {}
              for k,v in pairs(reward) do
                if v and type(v)=="table" then
                  for m,n in pairs(v) do
                    G_addPlayerAward(n.type,n.key,n.id,n.num,nil,true)
                    table.insert(content,{award=n})
                  end
                end
              end
              self:updateRewardBtn()
              smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,nil,true,true,nil,nil,true)
            end
         elseif sData.ret==-1975 then
            local function ListCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data then
                        if self and self.bgLayer then
                            if sData.data.ranklist then
                                BossBattleVoApi:setRankList(sData.data.ranklist,sData.data.kill)
                            end
                            BossBattleVoApi:setFlag(1)
                            if self.tv then
                                self.tv:reloadData()
                            end
                            self:updateRewardBtn()
                        end
                    end
                end
            end
            socketHelper:BossBattleRank(ListCallback)
          end
        end
        socketHelper:BossBattleGetReward(BossBattleVoApi:getMyRank(),RewardCallback)
      end

      local rewardBtn
      if state == 3 then
          rewardBtn =GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",hadReward,3,getlocal("activity_hadReward"),28)
          rewardBtn:setEnabled(false)
      else
        rewardBtn =GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",getReward,3,getlocal("newGiftsReward"),28)
        if state == 2 then
          rewardBtn:setEnabled(true)
        elseif state == 1 then
          rewardBtn:setEnabled(false)
        end
      end
      rewardBtn:setAnchorPoint(ccp(0.5, 0))
      self.rewardMenu=CCMenu:createWithItem(rewardBtn)
      self.rewardMenu:setPosition(ccp(G_VisibleSizeWidth/2,40))
      self.rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
      self.bgLayer:addChild(self.rewardMenu) 
  end

end


--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function BossBattleDialogTab2:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return SizeOfTable(self.rankList)

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize =CCSizeMake(self.backsprite:getContentSize().width,80)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()

    local num=BossBattleVoApi:getRankNum()
    local capInSetNew=CCRect(20, 20, 10, 10)
    local backSprie

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
      backSprie:setContentSize(CCSizeMake(self.backsprite:getContentSize().width-20, 72))
      backSprie:ignoreAnchorPointForPosition(false)
      backSprie:setAnchorPoint(ccp(0,0))
      backSprie:setIsSallow(false)
      backSprie:setPosition(ccp(10,0))
      backSprie:setTouchPriority(-42)
      cell:addChild(backSprie,1)
      local height=40
      local w = self.backsprite:getContentSize().width/4
      local function getX(index)
        return  w * index + w/2
      end

      local rankData = self.rankList[idx+1]

        local rankStr=0
        local playerName="" --玩家名字
        local valueStr=0 -- 战斗力
        local nameStr="" -- 军团名字
        if rankData then
          rankStr=tonumber(idx+1)
          playerName = rankData[3]
          valueStr=tonumber(rankData[2])
          if rankData[4] ~= nil and rankData[4]~="" then
            nameStr=rankData[4]
          else
            nameStr = getlocal("noAlliance")
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
          rankStr = getlocal("activity_fbReward_rankLow",{30})
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
      
        local playerNameLabel=GetTTFLabelWrap(playerName,25,CCSizeMake(175,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        playerNameLabel:setAnchorPoint(ccp(0.5,0.5))
        playerNameLabel:setPosition(getX(1),height)
        cell:addChild(playerNameLabel,2)
        
        local valueLabel=GetTTFLabel(FormatNumber(valueStr),25)
        valueLabel:setAnchorPoint(ccp(0.5,0.5))
        valueLabel:setPosition(getX(2),height)
        cell:addChild(valueLabel,2)

        local nameLabel=GetTTFLabelWrap(nameStr,25,CCSizeMake(125,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        nameLabel:setAnchorPoint(ccp(0.5,0.5))
        nameLabel:setPosition(getX(3),height)
        cell:addChild(nameLabel,2)  

        local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
        lineSP:setAnchorPoint(ccp(0.5,0.5))
        lineSP:setScaleX(self.backsprite:getContentSize().width/lineSP:getContentSize().width)
        lineSP:setScaleY(1.2)
        lineSP:setPosition(ccp(self.backsprite:getContentSize().width/2,5))
        cell:addChild(lineSP,2)

       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

--用户处理特殊需求,没有可以不写此方法
function BossBattleDialogTab2:initTitles()

   local w = self.backsprite:getContentSize().width/4
   local function getX(index)
     return  w * index + w/2
   end

   local height=self.backsprite:getContentSize().height-30
    local lbSize=22
    local widthSpace=80
    local color=G_ColorGreen
    local rankLabel=GetTTFLabel(getlocal("alliance_scene_rank_title"),lbSize)
    rankLabel:setPosition(getX(0),height)
    self.backsprite:addChild(rankLabel,1)
    rankLabel:setColor(color)
  
    local playerNameLabel=GetTTFLabel(getlocal("playerName"),lbSize)
    playerNameLabel:setPosition(getX(1),height)
    self.backsprite:addChild(playerNameLabel,1)
    playerNameLabel:setColor(color)
    
    local valueLabel=GetTTFLabel(getlocal("BossBattle_damagePoint"),lbSize)
    valueLabel:setPosition(getX(2),height)
    self.backsprite:addChild(valueLabel,1)
    valueLabel:setColor(color)


    local nameLabel=GetTTFLabel(getlocal("alliance_scene_alliance_name_title"),lbSize)
    nameLabel:setPosition(getX(3),height)
    self.backsprite:addChild(nameLabel,1)
    nameLabel:setColor(color)

end

function BossBattleDialogTab2:refresh()
  if self  then
    self.rankList=BossBattleVoApi:getRankList()
    self:updateRewardBtn()
    local killer = BossBattleVoApi:getBossKiller()
    if killer and killer ~= self.bossKiller then
      self.bossKiller =killer
      local killerName = getlocal("alliance_info_content")
      if self.bossKiller then
        killerName = self.bossKiller
      end
      self.killerLb:setString(getlocal("BossBattle_rankDesc",{killerName}))
    end
    if self.tv then
      self.tv:reloadData()
    end
  end
end
function BossBattleDialogTab2:tick()
  
end

function BossBattleDialogTab2:dispose()
    self.rewardBtnState=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.bossKiller=nil
end


