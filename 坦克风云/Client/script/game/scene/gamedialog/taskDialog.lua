--require "luascript/script/componet/commonDialog"
require "luascript/script/game/gamemodel/task/taskVoApi"

taskDialog=commonDialog:new()

function taskDialog:new(selectedTabIndex)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.selectedTabIndex=selectedTabIndex or 0

	self.layerTab1=nil
    self.layerTab2=nil
    
    self.taskTab1=nil
    self.taskTab2=nil

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/swChallenge.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/iconLevel.plist")
    spriteController:addPlist("public/taskYouhua.plist")
    spriteController:addTexture("public/taskYouhua.png")
    spriteController:addPlist("public/acMonthlySign.plist")
    spriteController:addTexture("public/acMonthlySign.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    return nc
end

--设置或修改每个Tab页签
function taskDialog:resetTab()
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
		 --[[
		 if not self.newsIconTab[index] then
	 		 local newsIcon = CCSprite:createWithSpriteFrameName("IconTip.png");
	         newsIcon:setAnchorPoint(ccp(1,0.5))
			 newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width-10,tabBtnItem:getContentSize().height/2))
	 		 tabBtnItem:addChild(newsIcon,1)
			 table.insert(self.newsIconTab,index,newsIcon)
		 end
		 ]]
         if index==0 then
         	tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
         	tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==2 then
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end 
         index=index+1
    end

    local flag=taskVoApi:getDaliyFlag()
    if taskVoApi:isShowNew()==false and flag==-1 then
        local function dailytaskGetHandler(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                self:switchTab(self.selectedTabIndex)
                self:doUserHandler()
                taskVoApi:setDaliyFlag(1)
            end
        end
        socketHelper:dailytaskGet(dailytaskGetHandler)
    else
        self:switchTab(self.selectedTabIndex)
        self:doUserHandler()
    end
end

--设置对话框里的tableView
function taskDialog:initTableView()
	local tvHeight=230
	local hPos=65
    local function callBack(...)
		-- return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-tvHeight),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,hPos))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function taskDialog:switchTab(idx)
    -- if self.taskTab1==nil then
    --     self.taskTab1=taskDialogTab1:new()
    --     self.layerTab1=self.taskTab1:init(self.layerNum,self)
    --     self.bgLayer:addChild(self.layerTab1,1);
    -- end
    -- if self.taskTab2==nil then
    --     self.taskTab2=taskDialogTab2:new()
    --     self.layerTab2=self.taskTab2:init(self.layerNum,self)
    --     self.bgLayer:addChild(self.layerTab2,1);
    -- end
    if idx==0 then
        if self.taskTab1==nil then
            self.taskTab1=taskDialogTab1:new()
            self.layerTab1=self.taskTab1:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab1,1);
        end

        if self.layerTab1 then
            self.layerTab1:setVisible(true)
            self.layerTab1:setPosition(ccp(0,0))
        end
        
        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(99930,0))
        end

    elseif idx==1 then
        if self.taskTab2==nil then
            self.taskTab2=taskDialogTab2:new()
            self.layerTab2=self.taskTab2:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab2,1);
        end

        if self.layerTab1 then
            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(10000,0))
        end
        
        if self.layerTab2 then
            self.layerTab2:setVisible(true)
            self.layerTab2:setPosition(ccp(0,0))
        end

    end
end

--点击tab页签 idx:索引
function taskDialog:tabClick(idx)
    if newGuidMgr:isNewGuiding()==true then
        if idx==1 then
            do
                return
            end
        end
    end
    PlayEffect(audioCfg.mouseClick)

    -- if (G_curPlatName()=="18" or G_curPlatName()=="androidtuerqi" or G_curPlatName()=="0") and playerVoApi:getPlayerLevel()<5 and idx==1  then

    --     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("limitLockTask"),30)
    --         self.allTabs[1]:setEnabled(true)
    --         self.allTabs[2]:setEnabled(false)

    --     do
    --         return
    --     end
    -- end
    
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
    -- self:getDataByType(idx)
    self:switchTab(idx)
    self:doUserHandler()

    self:resetForbidLayer()
end

function taskDialog:resetForbidLayer()
    if self and self.selectedTabIndex and self.topforbidSp and self.bottomforbidSp then
        if (self.selectedTabIndex==0) then
        	local mainBgHeight=0
        	local mainTask=taskVoApi:getMainTask()
        	if newGuidMgr:isNewGuiding()==false and mainTask then
        		mainBgHeight=185
        	end
            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-165-mainBgHeight))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 165+mainBgHeight))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 65))
        elseif (self.selectedTabIndex==1) then
            local extraBgHeight=140
            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-220-extraBgHeight))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 220+extraBgHeight))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 65))
        end
    end
end
--用户处理特殊需求,没有可以不写此方法
function taskDialog:doUserHandler()
	local currentNum=taskVoApi:hadCurrentCompletedTask()
	if currentNum>0 then
		self:setTipsVisibleByIdx(true,1,currentNum)
		--self.newsIconTab[0]:setVisible(true)
	else
		self:setTipsVisibleByIdx(false,1)
		--self.newsIconTab[0]:setVisible(false)
	end
	local dailyNum=taskVoApi:hadDailyCompletedTask()
	if dailyNum>0 then
		self:setTipsVisibleByIdx(true,2,dailyNum)
		--self.newsIconTab[1]:setVisible(true)
	else
		self:setTipsVisibleByIdx(false,2)
		--self.newsIconTab[1]:setVisible(false)
	end
end


--刷新板子
function taskDialog:refresh()
	if self==nil then
		do return end
	end

	if self.taskTab1~=nil then
		self.taskTab1:refresh()
	end
	if self.taskTab2~=nil then
		self.taskTab2:refresh()
	end

	-- self.tv:reloadData()
	self:doUserHandler()
	mainUI:switchTaskIcon()
end

function taskDialog:tick()
	local flag=taskVoApi:getRefreshFlag()
	local isUpdate=taskVoApi:updateDailyTaskNum()
	if flag==0 then
		-- local recordPoint = self.tv:getRecordPoint()
		self:refresh()
		-- self.tv:recoverToRecordPoint(recordPoint)
	elseif isUpdate==true then
		self:refresh()
	end

    if self.taskTab2~=nil then
        self.taskTab2:tick()
    end
end

function taskDialog:dispose()
	-- self.cancelBtn=nil
 --    self.refreshBtn=nil
	-- self.resetBtn=nil
	-- self.resetCountLabel=nil

	if self.playerTab1~=nil then
        self.playerTab1:dispose()
    end
    if self.playerTab2~=nil then
        self.playerTab2:dispose()
    end

	self.layerTab1=nil
    self.layerTab2=nil
    
    self.taskTab1=nil
    self.taskTab2=nil

    spriteController:removePlist("public/taskYouhua.plist")
    spriteController:removeTexture("public/taskYouhua.png")
    spriteController:removePlist("public/acMonthlySign.plist")
    spriteController:removeTexture("public/acMonthlySign.png")
end
