--require "luascript/script/componet/commonDialog"
helpDialog=commonDialog:new()

function helpDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.helpConf = {
    {id = 1, icon = "helpRecharge.png", content = {1} -- id 第几个  icon  图标图片名称  content{第一个标题下有几个二级标题，第二个标题下有几个二级标题，以此类推}
    },
    {id = 2, icon = "helpPlayer.png", content = {4,2,3}
    },
    {id = 3, icon = "helpBuliding.png", content = {7,4,2}
    },
    {id = 4, icon = "helpTank.png", content = {4,4,4,9}
    },
    {id = 5, icon = "helpAlliance.png", content = {6,15,1}
    },
    {id = 6, icon = "helpItem.png", content = {1}
    },
  }
    self.detailTv=nil -- 帮助内容滚动
    self.contentH = nil -- 滚动内容的高度
    -- self.bottomH = 60  --  屏幕下方论坛地址背景高度
    self.bottomH = 0 
    self.leftW = nil -- 左侧按钮的宽度
    self.leftx = 10 -- 左侧按钮区域x坐标
    self.lefty = nil -- 左侧按钮区域和右侧文字区域y坐标
    self.rightW = nil -- 右侧宽度
    self.rightx = nil -- 右侧x坐标
    self.rightTitleH = 50 -- 右侧滚动区域每一条标题的高度
    self.w = 2 -- 左右小间距
    self.h = 5 -- 上下小间距
    self.selectedIndex = 1 -- 当前选择的按钮id
    self.btnBgs = nil -- 左侧按钮点击显示背景
    self.heightTb = {} --记录下来每个cell的高度
    self.subLbTb={}
    self.titleLbTb={}
    self.subLbHeightTb={}
    self.titleLbHeightTb={}
    return nc
end

--点击tab页签 idx:索引
function helpDialog:initTableView()

  -- 调整滚动背景框
  self.panelLineBg:setVisible(false)
  self.btnBgs = {}
  local function click(hd,fn,idx)
  end
  self.lefty = self.bottomH + 13
  self.contentH = self.bgLayer:getContentSize().height-100 - self.bottomH
  self.leftW = self.bgLayer:getContentSize().width * 0.23
  self.rightW = self.bgLayer:getContentSize().width - self.leftx * 2 - self.leftW;
  self.rightx = self.leftx + self.leftW
  -- local bottomSp = nil
  -- for i=1,3 do 
  for i = 1,2 do
    local bgSprie = nil
      if i==1 then
        bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),click)
        bgSprie:setContentSize(CCSizeMake(self.leftW, self.contentH))
        bgSprie:setPosition(ccp(self.leftx,self.lefty))
      elseif i==2 then
        bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
        bgSprie:setContentSize(CCSizeMake(self.rightW, self.contentH))
        bgSprie:setPosition(ccp(self.rightx,self.lefty))
      -- elseif i== 3 then
      --   bgSprie = LuaCCScale9Sprite:createWithSpriteFrameName("HelpBgBottom.png", CCRect(20,20,1,1),click)
      --   bgSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - self.leftx * 2, self.bottomH))
      --   bgSprie:setPosition(ccp(self.leftx, 10))
      --   bottomSp = bgSprie
      end
        bgSprie:ignoreAnchorPointForPosition(false)
        bgSprie:setIsSallow(false)
        bgSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        bgSprie:ignoreAnchorPointForPosition(true)
        bgSprie:setAnchorPoint(ccp(0.5,0.5))
        self.bgLayer:addChild(bgSprie,1)
  end
  
  -- if bottomSp ~= nil then
  --       local forumUrl = GetTTFLabelWrap(getlocal("help_forum_url"),28,CCSizeMake(self.bgLayer:getContentSize().width - self.leftx * 2,self.bottomH),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  --       local forumUrl = GetTTFLabel(getlocal("help_forum_url"),28)
  --       bottomSp:addChild(forumUrl)
  --       forumUrl:setPosition(ccp(self.leftx + forumUrl:getContentSize().width/2,self.bottomH/2))
        
  --       local function itemMeun_OnClick( ... )
  --         self:getToForum()
  --       end

  --       local labelMeun = GetTTFLabel("www.tankefengyu.com",28)
  --       labelMeun:setColor(G_ColorGreen)
  --       local itemMeun = CCMenuItemLabel:create(labelMeun)
  --       itemMeun:registerScriptTapHandler(itemMeun_OnClick)
  --       --创建菜单
  --       local menu = CCMenu:createWithItem(itemMeun)
  --       menu:setPosition(ccp(self.leftx + forumUrl:getContentSize().width + labelMeun:getContentSize().width/2,self.bottomH/2))
  --       bottomSp:addChild(menu)
  -- end
  
  local function ctvCallBack(...)
    return self:ctvEventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(ctvCallBack)
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.leftW-self.w*2,self.contentH - self.h*2),nil)
  self.tv:setAnchorPoint(ccp(0,0))
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setPosition(ccp(self.leftx + self.w,self.lefty + self.h))
  self.bgLayer:addChild(self.tv,2)
  self.tv:setMaxDisToBottomOrTop(120)
  local function callBack(...)
    return self:eventHandler(...)
  end
  hd= LuaEventHandler:createHandler(callBack)
  -- 第二个参数设置滚动区域的宽高
  self:getAllLbAndHeight(0)
  self.detailTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.rightW - self.w * 2,self.contentH - self.h*2),nil)
  self.detailTv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.detailTv:setPosition(ccp(self.rightx + self.w,self.lefty + self.h))
  self.bgLayer:addChild(self.detailTv,2)
  self.detailTv:setMaxDisToBottomOrTop(120)

      
end

function helpDialog:ctvEventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return SizeOfTable(self.helpConf)
  elseif fn=="tableCellSizeForIndex" then
     local tmpSize=CCSizeMake(self.leftW-self.w*2,100)
     return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local function touchLuaSp(object,name,tag)
        self:updateContentByTag(tag)
    end
    local bgSp = CCSprite:createWithSpriteFrameName("LanguageSelectBtn.png")
    bgSp:setAnchorPoint(ccp(0,0))
    bgSp:setPosition(ccp((self.leftW - bgSp:getContentSize().width) * 0.5,0.5));

    local sp=LuaCCSprite:createWithSpriteFrameName(self.helpConf[idx+1].icon,touchLuaSp)
    sp:setTag(idx + 1)
    sp:setTouchPriority(-(self.layerNum-1)*20-2)
    sp:setPosition(getCenterPoint(bgSp))

    cell:addChild(bgSp,1)
    cell:addChild(sp,2)
    table.insert(self.btnBgs, idx + 1, bgSp)
    if self.selectedIndex == idx + 1 then
       bgSp:setVisible(true)
    else
       bgSp:setVisible(false)
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

function helpDialog:updateContentByTag(tag)
  self.selectedIndex = tag
  for k,v in pairs(self.btnBgs) do
      if k == tag then
        v:setVisible(true)
      else
        v:setVisible(false)
      end
  end
  self:getAllLbAndHeight(tag-1)
  self.detailTv:reloadData()
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function helpDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    if self.selectedIndex ~= nil then
      return SizeOfTable(self.helpConf[self.selectedIndex].content)
    else
      return 1
    end
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize=CCSizeMake(self.rightW - 10 * 2,self.rightTitleH + self.heightTb[idx+1])
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()

    local rightContentH = self:getAllMessageHeight(idx)
    local title = idx+1
    --local rightContentH=self.heightTb[idx+1]
    --local self.selectedIndex = "0"..idx+1
    -- 标题
    local function cellClick(hd,fn,idx)
    end
    
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
    titleBg:setContentSize(CCSizeMake(self.rightW - self.w * 2, self.rightTitleH))
    titleBg:setAnchorPoint(ccp(0,0))
    titleBg:setPosition(ccp(0,rightContentH))
    cell:addChild(titleBg,1)
      
    -- 添加标题文字
    local typeLabel =GetTTFLabel(getlocal("help"..self.selectedIndex.."_t"..title),30)
    typeLabel:setPosition(getCenterPoint(titleBg))
    titleBg:addChild(typeLabel)

    local subNum = self.helpConf[self.selectedIndex].content[idx +1]
    local mHeight = 0
    local h = 0
    local descLabel = nil
    for i=1,subNum do
      for k=1,2 do
        if k == 1 then
          descLabel = self.titleLbTb["help"..self.selectedIndex.."_t"..title.."_t"..i]
          --self:getSubTitleHeight(getlocal("help"..self.selectedIndex.."_t"..title.."_t"..i))
          descLabel:setColor(G_ColorGreen)
          h=self.titleLbHeightTb["help"..self.selectedIndex.."_t"..title.."_t"..i]
        else
          local hcStr = "help"..self.selectedIndex.."_t"..title.."_t"..i.."_content"
          if hcStr == "help2_t3_t1_content" and FuncSwitchApi:isEnabled("luck_lottery") == false then
            hcStr = "help2_t3_t1_content_ms"
          end
          descLabel = self.subLbTb[hcStr]
          --self:getContentHeight(getlocal(hcStr));
          h=self.subLbHeightTb[hcStr]
        end
        descLabel:setAnchorPoint(ccp(0,1))
        descLabel:setPosition(ccp(10, rightContentH-mHeight))
        mHeight = mHeight + h
        cell:addChild(descLabel)
      end


    end
    if self.selectedIndex == 4 and idx + 1 == 2 then
      local tipsLbHeight, tipsLb = self:getContentHeight(getlocal("help4_t4_tips"))
      tipsLb:setColor(G_ColorRed)
      tipsLb:setAnchorPoint(ccp(0, 1))
      tipsLb:setPosition(ccp(10, rightContentH-mHeight))
      mHeight = mHeight + tipsLbHeight
      cell:addChild(tipsLb)
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

function helpDialog:getAllLbAndHeight(idx)
   self.heightTb={}
   self.subLbTb={}
   self.titleLbTb={}
   
   for k,v in pairs(self.helpConf[self.selectedIndex].content) do              
       local mHeight = 0
       local subNum = self.helpConf[self.selectedIndex].content[k]
       for i=1,subNum do
         local titleLbHeight,titleLb=self:getSubTitleHeight(getlocal("help"..self.selectedIndex.."_t"..k.."_t"..i))
         local contentLbHeight,contentLb   
         local hcStr = "help"..self.selectedIndex.."_t"..k.."_t"..i.."_content"
         if hcStr == "help2_t3_t1_content" and FuncSwitchApi:isEnabled("luck_lottery") == false then
            hcStr = "help2_t3_t1_content_ms"
         end
         if self.selectedIndex==1 and k==1 and i==1 then
            local strTb=Split(playerCfg.gem4vip,",")
                
            contentLbHeight,contentLb=self:getContentHeight(getlocal(hcStr,{strTb[1],strTb[2],strTb[3],strTb[4],strTb[5],strTb[6],strTb[7],strTb[8],strTb[9]}))

         else
            contentLbHeight,contentLb=self:getContentHeight(getlocal(hcStr))

         end
         self.titleLbTb["help"..self.selectedIndex.."_t"..k.."_t"..i]=titleLb
         self.subLbTb[hcStr]=contentLb
         mHeight = mHeight + titleLbHeight
         mHeight = mHeight + contentLbHeight
         mHeight = mHeight + 24

         self.titleLbHeightTb["help"..self.selectedIndex.."_t"..k.."_t"..i]=titleLbHeight
         self.subLbHeightTb[hcStr]=contentLbHeight
       end
   end

   for k,v in pairs(self.helpConf[self.selectedIndex].content) do
        local mHeight = self:getAllMessageHeight(k-1)
        self.heightTb[k]=mHeight
   end


end

function helpDialog:getAllMessageHeight(idx) 
   local title = idx + 1
   local mHeight = 0

   local subNum = self.helpConf[self.selectedIndex].content[title]
   for i=1,subNum do
     mHeight = mHeight + self.titleLbHeightTb["help"..self.selectedIndex.."_t"..title.."_t"..i]
     local hcStr = "help"..self.selectedIndex.."_t"..title.."_t"..i.."_content"
     if hcStr == "help2_t3_t1_content" and FuncSwitchApi:isEnabled("luck_lottery") == false then
        hcStr = "help2_t3_t1_content_ms"
     end
     mHeight = mHeight + self.subLbHeightTb[hcStr]
   end
   if self.selectedIndex == 4 and idx + 1 == 2 then
    local contentLbHeight, contentLb = self:getContentHeight(getlocal("help4_t4_tips"))
    mHeight = mHeight + contentLbHeight
   end
   mHeight = mHeight + 24 -- 一级分类标签最后与下一个一级分类标签之间的间距
   return mHeight
end

function helpDialog:getSubTitleHeight(content)
  local showMsg=content or ""
  local width=self.rightW - 20
  local messageLabel=GetTTFLabelWrap(showMsg,24,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
  local height=messageLabel:getContentSize().height+20
  --messageLabel:setDimensions(CCSizeMake(width, height))
  return height, messageLabel
end

function helpDialog:getContentHeight(content)
  local showMsg=content or ""
  local width=self.rightW - 20
  local messageLabel=GetTTFLabelWrap(showMsg,20,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  local height=messageLabel:getContentSize().height+20
  messageLabel:setDimensions(CCSizeMake(width, height+50))
  return height, messageLabel
end

function helpDialog:getToForum( ... )
  -- body
end

function helpDialog:dispose()
    self.helpConf = nil
    self.detailTv=nil
    self.contentH = nil
    self.leftW = nil
    self.leftx = nil
    self.lefty = nil
    self.rightW = nil
    self.rightx = nil
    self.rightTitleH = nil
    self.w = nil
    self.h = nil
    self.selectedIndex = nil
    self.heightTb = nil
    self.subLbTb=nil
    self.titleLbTb=nil
    self.subLbHeightTb=nil
    self.titleLbHeightTb=nil
    self=nil

end





