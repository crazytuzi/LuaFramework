--require "luascript/script/componet/commonDialog"
homeBuildUpgradeDialog=commonDialog:new()

function homeBuildUpgradeDialog:new(bid,isShowPoint)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bid=bid
    self.upgradeDialog=nil
    self.normalHeight=155
    self.expandHeight=G_VisibleSize.height-140
    self.isShowPoint=isShowPoint
  return nc
end

--设置或修改每个Tab页签
function homeBuildUpgradeDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end

--设置对话框里的tableView
function homeBuildUpgradeDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-200),nil)
    self.bgLayer:setTouchPriority(-41)
    self.tv:setTableViewTouchPriority(1)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(self.normalHeight)
    --任务跳转指引
    if self.btnItem ~= nil then
      local groupId = G_getGroupIdByBid(self.bid)
      local x,y,z,w  = G_getSpriteWorldPosAndSize(self.btnItem, 1)
      if groupId then
          newSkipCfg[groupId].clickRect = CCRectMake(x,y+G_VisibleSize.height,z,w)
      else
          print("======= groupId is nil ! =======")
      end
    end

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function homeBuildUpgradeDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
         return 1
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
         tmpSize=CCSizeMake(600,self.expandHeight)
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
       self:loadCCTableViewCell(cell,idx)
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

--点击tab页签 idx:索引
function homeBuildUpgradeDialog:tabClick(idx)
        PlayEffect(audioCfg.mouseClick)
        for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self.tv:reloadData()
            self:doUserHandler()
         else
            v:setEnabled(true)
         end
    end
end

--用户处理特殊需求,没有可以不写此方法
function homeBuildUpgradeDialog:doUserHandler()
    
end

--点击了cell或cell上某个按钮
function homeBuildUpgradeDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,self.normalHeight)
        else
            self.requires[idx-1000+1]:dispose()
            self.requires[idx-1000+1]=nil
            self.allCellsBtn[idx-1000+1]=nil
            self.buildBtn=nil
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,self.expandHeight)
        end
    end
end

--创建或刷新CCTableViewCell
function homeBuildUpgradeDialog:loadCCTableViewCell(cell,idx,refresh)
    self.upgradeDialog=buildingUpgradeCommon:new()
    self.upgradeDialog:init(cell,self.bgLayer,self.bid,self,self.layerNum,self.isShowPoint)
    self.btnItem = self.upgradeDialog.allCellsBtn[1]
end

function homeBuildUpgradeDialog:tick()
    self.upgradeDialog:tick()
end

function homeBuildUpgradeDialog:dispose()
    self.isShowPoint=nil
    self.upgradeDialog:dispose()
      self.upgradeDialog=nil
end












