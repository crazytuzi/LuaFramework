-- @Author hj
-- @Date 2018-11-20
-- @Description 信息列表

newAllianceMemberInfoDialog = {}

function newAllianceMemberInfoDialog:new(layerNum)
	
	local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum = layerNum
    return nc

end

function newAllianceMemberInfoDialog:init( ... )
	self.bgLayer=CCLayer:create()

	self:initTabLayer()
    return self.bgLayer
end

function newAllianceMemberInfoDialog:initTabLayer( ... )
	-- body
	self:resetTab()
	self:initTabLayer1()
    self:initTabLayer2()
    self:initTabLayer3()

end

-- 成员列表
function newAllianceMemberInfoDialog:initTabLayer1( ... )
	-- body
end

-- 捐献列表
function newAllianceMemberInfoDialog:initTabLayer2( ... )
	-- body
end

-- 申请加入
function newAllianceMemberInfoDialog:initTabLayer3( ... )
	-- body
end

function newAllianceMemberInfoDialog:resetTab( ... )
	
	self.allTabs={getlocal("alliance_scene_member_list"),getlocal("alliance_donate"),getlocal("alliance_info_apply")}
    self:initTab(self.allTabs)
    -- self:refreshTips(4)
    local index=0
    local tabH = 0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if index==0 then
            tabBtnItem:setPosition(100,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         elseif index==1 then
            tabBtnItem:setPosition(248,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         elseif index==2 then
            tabBtnItem:setPosition(394,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-tabH-10-160)
    self.bgLayer:addChild(tabLine,5)

end

function newAllianceMemberInfoDialog:initTab( ... )

	local tabBtn=CCMenu:create()
   	local tabIndex=0
   	local tabBtnItem

   	if tabTb~=nil then

       	for k,v in pairs(tabTb) do
           	tabBtnItem = CCMenuItemImage:create("yh_ltzdzHelp_tab.png", "yh_ltzdzHelp_tab_down.png","yh_ltzdzHelp_tab_down.png")
           
           	tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))

           	local function tabClick(idx)
            	return self:tabClick(idx)
           	end
           	tabBtnItem:registerScriptTapHandler(tabClick)
           
           	local lb=GetTTFLabel(v,24)
           	lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           	tabBtnItem:addChild(lb)
       		lb:setTag(31)
       
       
        	local numHeight=25
      		local iconWidth=36
      		local iconHeight=36
        	local newsNumLabel = GetTTFLabel("0",numHeight)
        	newsNumLabel:setPosition(ccp(newsNumLabel:getContentSize().width/2+5,iconHeight/2))
        	newsNumLabel:setTag(11)
          	local capInSet1 = CCRect(17, 17, 1, 1)
          	local function touchClick()
          	end
          	local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
      		if newsNumLabel:getContentSize().width+10>iconWidth then
        		iconWidth=newsNumLabel:getContentSize().width+10
      		end
          	newsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
        	newsIcon:ignoreAnchorPointForPosition(false)
        	newsIcon:setAnchorPoint(CCPointMake(1,0.5))
          	newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width+5,tabBtnItem:getContentSize().height-15))
          	newsIcon:addChild(newsNumLabel,1)
      		newsIcon:setTag(10)
        	newsIcon:setVisible(false)
        	tabBtnItem:addChild(newsIcon)
       
           	local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
       		lockSp:setAnchorPoint(CCPointMake(0,0.5))
       		lockSp:setPosition(ccp(10,tabBtnItem:getContentSize().height/2))
       		lockSp:setScaleX(0.7)
       		lockSp:setScaleY(0.7)
       		tabBtnItem:addChild(lockSp,3)
       		lockSp:setTag(30)
       		lockSp:setVisible(false)
      
           	self.allTabs[k]=tabBtnItem
           	tabBtn:addChild(tabBtnItem)
           	tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
           	tabBtnItem:setTag(tabIndex)
           	tabIndex=tabIndex+1
       	end

   	end

   	tabBtn:setPosition(0,0)
   	self.bgLayer:addChild(tabBtn)

end

function newAllianceMemberInfoDialog:dispose( ... )
	-- body
end

function newAllianceMemberInfoDialog:tick( ... )
	-- body
end