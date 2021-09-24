BossBattleRewardDialog=smallDialog:new()

function BossBattleRewardDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogHeight=400
	self.dialogWidth=550
	return nc
end

function BossBattleRewardDialog:create(layerNum)
    local sd=BossBattleRewardDialog:new()
    sd:init(layerNum,nameStr,uid,callback)
    return sd

end
function BossBattleRewardDialog:init(layerNum)
    self.isTouch=false
    self.isUseAmi=false
    self.layerNum = layerNum
    local function touchHandler()
    
    end
    
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),touchHandler)
    self.dialogLayer=CCLayer:create()
    
    self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(550,650)
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
    
    local function close()
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end 
      PlayEffect(audioCfg.mouseClick)
      return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-6)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    local titleLb=GetTTFLabel(getlocal("award"),40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)

  -- self.des = {}
  -- self.desH = {}
  -- -- self.rewardInterval = BossBattleVoApi:getRewardLevel()
  -- local koReward = bossCfg.attackHpreward
  -- if koReward then
  -- 	for k,v in pairs(koReward) do
  --     local tip = ""
  -- 		if v then
  --       for kk,vv in pairs(v) do
  --           local award = FormatItem(vv)
  --           local str = ""
  --           if award and SizeOfTable(award)>0 then
  --               for k,v in pairs(award) do
  --                   local nameStr=v.name
  --                   if v.type=="c" then
  --                       nameStr=getlocal(v.name,{v.num})
  --                   end
  --                   if k==SizeOfTable(award) then
  --                       str = str..nameStr .. " x" .. v.num
  --                   else
  --                       str = str..nameStr .. " x" .. v.num .. ","
  --                   end

  --               end
  --           end

  --           if kk==2 then
  --             tip = tip..getlocal("BossBattle_BossPaotou",{str}).."\n"
  --           elseif kk==1 then
  --             tip = tip..getlocal("BossBattle_commonPaotou",{str}).."\n"
  --           end
  --           print(".....tip",G_showRewardStr(award))
  --       end
  -- 		end
  --     local desH1,des1 = self:getDes(tip,25)
  --     table.insert(self.desH, desH1)
  --     table.insert(self.des, des1)
  -- 	end
  -- end

  -- local rankReward = bossCfg.rankReward
  -- if rankReward then
  -- 	for k,v in pairs(rankReward) do
  --     local rewardTip = ""
  --     for kk,vv in pairs(v) do
  --       rewardTip=rewardTip..self:getRankRewardStr(vv).."\n"
  --     end
  -- 	  local desH2,des2 = self:getDes(rewardTip,25)
  --     table.insert(self.desH, desH2)
  --     table.insert(self.des, des2)
  -- 	end
  -- end

  -- local damageRewardTip = getlocal("BossBattle_damageReward")
  -- local desH3,des3 = self:getDes(damageRewardTip,25)
  -- table.insert(self.desH, desH3)
  -- table.insert(self.des, des3)

  local function callBack(...)
     return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  local height=0;
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(dialogBg:getContentSize().width-20,dialogBg:getContentSize().height-110),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
  self.tv:setPosition(ccp(10,10))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(80)
  
  

end

-- function BossBattleRewardDialog:getRankRewardStr(reawrdCfg)
--   local str = ""
--   local awardStr=""
--   local rank1
--   local rank2
--   for k,v in pairs(reawrdCfg) do
--     if k =="range" then
--       if v[1] and v[2]  then
--         rank1 = v[1]
--         rank2 = v[2]
--       end
--     elseif v then
--       local award = FormatItem(v)
--       for k,v in pairs(award) do
--             local nameStr=v.name
--             if v.type=="c" then
--                 nameStr=getlocal(v.name,{v.num})
--             end
--             if k==SizeOfTable(award) then
--                 awardStr = awardStr..nameStr .. " x" .. v.num
--             else
--                 awardStr = awardStr..nameStr .. " x" .. v.num .. ","
--             end
--         end
--     end
--   end
--   if rank1 == rank2 then
--     str = getlocal("activity_cuikulaxiu_rankToReward",{rank1,awardStr})
--   else
--     str = getlocal("activity_cuikulaxiu_rankTorankReward",{rank1,rank2,awardStr})
--   end
--   return str
-- end
-- function BossBattleRewardDialog:getDes(content,size)
--   local showMsg=content or ""
--   local width=self.bgLayer:getContentSize().width - 40
--   local messageLabel=GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
--   local height=messageLabel:getContentSize().height
--   --messageLabel:setDimensions(CCSizeMake(width, height+50))
--   return tonumber(height), messageLabel
-- end

function BossBattleRewardDialog:getCellStrLb(index)
  local strLb = {}
  local textWidth = self.bgLayer:getContentSize().width-40
  local titleFontSize,subTitleFontSize = 27,25
  local num = #(bossCfg.rewardInterval)+1
  if index == 1 or index == (1+num) or index == (1+num*2) then
    local str
    if index == 1 then
      str = getlocal("BossBattle_destoryTitle")
    elseif index == (1+num) then
      str = getlocal("BossBattle_rankTitle")
    else
      str = getlocal("BossBattle_damageTitle")
      local subTitleLb = GetTTFLabelWrap(getlocal("BossBattle_damageReward"),subTitleFontSize,CCSizeMake(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
      subTitleLb:setAnchorPoint(ccp(0,0.5))
      strLb[2]=subTitleLb
    end
    local titleLb = GetTTFLabelWrap(str,titleFontSize,CCSizeMake(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    titleLb:setAnchorPoint(ccp(0,0.5))
    titleLb:setColor(G_ColorGreen)
    strLb[1]=titleLb
  else
    local str 
    local seq
    local flag 
    if index == num or index == num*2 or index == num*3  then
      local down = bossCfg.rewardInterval[num-1]
      str = getlocal("haidela_eve_subTitleUnlimit",{down})
      seq = num-1
    else
      seq = index%num-1
      local down = bossCfg.rewardInterval[seq]
      local up = bossCfg.rewardInterval[seq+1]
      str = getlocal("haidela_eve_subTitle",{down,up-1})
    end

    local koReward 

    if math.ceil(index/num) == 1 then
      koReward = bossCfg.attackHpreward[seq]
      flag = 1
    elseif math.ceil(index/num) == 2 then
      koReward = bossCfg.rankReward[seq]
      flag = 2
    elseif math.ceil(index/num) == 3 then
      flag = 3
      koReward = bossCfg.attacktolHpreward[seq]
    end

    local titleLb = GetTTFLabelWrap(str,titleFontSize,CCSizeMake(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    titleLb:setAnchorPoint(ccp(0,0.5))
    titleLb:setColor(G_ColorYellowPro)
    strLb[1]=titleLb

    if koReward then
       local tip =""
     
        for k,v in pairs(koReward) do
          if v then
            local rank1
            local rank2
            local award
            local str = ""

            if flag == 2 and v.range then
              award = FormatItem(v[1])
              rank1 = v.range[1]
              rank2 = v.range[2]
            else
              award = FormatItem(v)
            end
            if award and SizeOfTable(award)>0 then
                for k,v in pairs(award) do
                    local nameStr=v.name
                    if v.type=="c" then
                        nameStr=getlocal(v.name,{v.num})
                    end
                    if k==SizeOfTable(award) then
                        str = str..nameStr .. " x" .. v.num 
                    else
                        str = str..nameStr .. " x" .. v.num .. ","
                    end
    
                end
            end
            if flag == 1 then
              if k==2 then
                tip = tip..getlocal("BossBattle_BossPaotou",{str}).."\n"
              elseif k==1 then
                tip = tip..getlocal("BossBattle_commonPaotou",{str}).."\n"
              end
            elseif flag == 2  then
              if  rank1 == rank2 then
                tip = tip..getlocal("activity_cuikulaxiu_rankToReward",{rank1,str}).."\n"
              else
                tip = tip..getlocal("activity_cuikulaxiu_rankTorankReward",{rank1,rank2,str}).."\n"
            end
            elseif flag == 3 then
                tip = tip..str.."\n"
            end
          end
        end
        local rewardLabel = GetTTFLabelWrap(tip,subTitleFontSize,CCSizeMake(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        rewardLabel:setAnchorPoint(ccp(0,0.5))
        strLb[2]=rewardLabel
    end
  end
  return strLb
end

function BossBattleRewardDialog:getCellSize(index)
  if self.cellHeightTb==nil then
    self.cellHeightTb={}
  end
  if self.cellHeightTb[index]==nil then
    local height = 10
    local strLb = self:getCellStrLb(index)
    for k,lb in pairs(strLb) do
      height=height+lb:getContentSize().height
    end
    height=height+(#strLb-1)*5
    self.cellHeightTb[index]=height
  end
  return self.cellHeightTb[index]

  -- local tempSize = CCSizeMake(self.bgLayer:getContentSize().width-20,50)
  -- local num = #(bossCfg.rewardInterval)+1
  -- if index%num == 1 then
  --   if index == 11 then
  --     tempSize = CCSizeMake(self.bgLayer:getContentSize().width-20,100)
  --   end
  --   return tempSize
  -- elseif math.ceil(index/num) == 1 then
  --   tempSize = CCSizeMake(self.bgLayer:getContentSize().width-20,170)
  --   return tempSize
  -- elseif math.ceil(index/num) == 2 then
  --   tempSize = CCSizeMake(self.bgLayer:getContentSize().width-20,340)
  --   return tempSize
  -- elseif math.ceil(index/num) == 3 then
  --   tempSize = CCSizeMake(self.bgLayer:getContentSize().width-20,150)
  --   return tempSize
  -- end

  -- return tempSize
end

-- function BossBattleRewardDialog:initCell(index,cell)
  
--   local tempSize = self:getCellSize(index)
--   local num = #(bossCfg.rewardInterval)+1
--   cell:setContentSize(tempSize)
--   local levelTb = bossCfg.bossCfg
  
--   if index == 1 or index == (1+num) or index == (1+num*2) then
--     local str 
--     if index == 1 then
--       str = getlocal("BossBattle_destoryTitle")
--     elseif index == (1+num) then
--       str = getlocal("BossBattle_rankTitle")
--     else
--       str = getlocal("BossBattle_damageTitle")
--       local cellSubTitle = GetTTFLabelWrap(getlocal("BossBattle_damageReward"),25,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
--       cellSubTitle:setAnchorPoint(ccp(0,0.5))
--       cellSubTitle:setPosition(10,25)
--       cell:addChild(cellSubTitle)
--     end
--     local cellTitle = GetTTFLabelWrap(str,27,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
--     cellTitle:setAnchorPoint(ccp(0,0.5))
--     cellTitle:setPosition(10,cell:getContentSize().height-25)
--     cellTitle:setColor(G_ColorGreen)
--     cell:addChild(cellTitle)
--   else
--     self:initRewardStr(cell,index)
--   end

-- end

-- function BossBattleRewardDialog:initRewardStr(cell,index)

--     local str 
--     local seq
--     local flag 
--     local num = #(bossCfg.rewardInterval)+1

--     if index == num or index == num*2 or index == num*3  then
--       local down = bossCfg.rewardInterval[num-1]
--       str = getlocal("haidela_eve_subTitleUnlimit",{down})
--       seq = num-1
--     else
--       seq = index%num-1
--       local down = bossCfg.rewardInterval[seq]
--       local up = bossCfg.rewardInterval[seq+1]
--       str = getlocal("haidela_eve_subTitle",{down,up-1})
--     end

--     local koReward 

--     if math.ceil(index/num) == 1 then
--       koReward = bossCfg.attackHpreward[seq]
--       flag = 1
--     elseif math.ceil(index/num) == 2 then
--       koReward = bossCfg.rankReward[seq]
--       flag = 2
--     elseif math.ceil(index/num) == 3 then
--       flag = 3
--       koReward = bossCfg.attacktolHpreward[seq]
--     end

--     local cellTitle = GetTTFLabelWrap(str,27,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
--     cellTitle:setAnchorPoint(ccp(0,0.5))
--     cellTitle:setPosition(10,cell:getContentSize().height-25)
--     cellTitle:setColor(G_ColorYellowPro)
--     cell:addChild(cellTitle)

--     if koReward then
--        local tip =""
     
--         for k,v in pairs(koReward) do
--           if v then
--             local rank1
--             local rank2
--             local award
--             local str = ""

--             if flag == 2 and v.range then
--               award = FormatItem(v[1])
--               rank1 = v.range[1]
--               rank2 = v.range[2]
--             else
--               award = FormatItem(v)
--             end
--             if award and SizeOfTable(award)>0 then
--                 for k,v in pairs(award) do
--                     local nameStr=v.name
--                     if v.type=="c" then
--                         nameStr=getlocal(v.name,{v.num})
--                     end
--                     if k==SizeOfTable(award) then
--                         str = str..nameStr .. " x" .. v.num 
--                     else
--                         str = str..nameStr .. " x" .. v.num .. ","
--                     end
    
--                 end
--             end
--             if flag == 1 then
--               if k==2 then
--                 tip = tip..getlocal("BossBattle_BossPaotou",{str}).."\n"
--               elseif k==1 then
--                 tip = tip..getlocal("BossBattle_commonPaotou",{str}).."\n"
--               end
--             elseif flag == 2  then
--               if  rank1 == rank2 then
--                 tip = tip..getlocal("activity_cuikulaxiu_rankToReward",{rank1,str}).."\n"
--               else
--                 tip = tip..getlocal("activity_cuikulaxiu_rankTorankReward",{rank1,rank2,str}).."\n"
--             end
--             elseif flag == 3 then
--                 tip = tip..str.."\n"
--             end
--           end
--         end
--         local rewardLabel = GetTTFLabelWrap(tip,25,CCSizeMake(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
--         rewardLabel:setAnchorPoint(ccp(0,1))
--         rewardLabel:setPosition(10,cell:getContentSize().height-50)
--         cell:addChild(rewardLabel)
--     end
-- end

function BossBattleRewardDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
      local num = 0
      if bossCfg and bossCfg.rewardInterval then
        num = 3 + 3*(#bossCfg.rewardInterval)
      end
     return num
  elseif fn=="tableCellSizeForIndex" then
    -- local tmpSize = self:getCellSize(idx+1)
    local tmpSize = CCSizeMake(self.bgLayer:getContentSize().width-20,self:getCellSize(idx+1))
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local cellHeight = self:getCellSize(idx+1)
    local lbPosX,lbPosY = 10,cellHeight-5
    local strLb = self:getCellStrLb(idx+1)
    for k,lb in pairs(strLb) do
      lb = tolua.cast(lb,"CCLabelTTF")
      if lb then
        lb:setPosition(lbPosX,lbPosY-lb:getContentSize().height/2)
        cell:addChild(lb)
        lbPosY=lbPosY-lb:getContentSize().height-5
      end
    end
    -- self:initCell(idx+1,cell)
    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end


