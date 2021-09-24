--require "luascript/script/componet/commonDialog"
require "luascript/script/game/gamemodel/bookmark/bookmarkVoApi"

bookmarkDialog=commonDialog:new()

function bookmarkDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.btnTab={}
    self.recordMarkTab={}
	self.noBookmarksLabel=nil
    return nc
end

--设置或修改每个Tab页签
function bookmarkDialog:resetTab()
    local tabBtn=CCMenu:create()
    local tabIndex=0
    local tabBtnItem
	for i=1,4 do
	    local textLabel=GetTTFLabelWrap("",24,CCSizeMake(140,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
		local height=110
		local textHeight=height-50
        if i==1 then
            tabBtnItem = CCMenuItemImage:create("worldBtnadd.png", "worldBtnadd_Down.png","worldBtnadd_Down.png")
			tabBtnItem:setPosition(self.bgSize.width/5*1-20,height)
			textLabel:setString(getlocal("bookmarksAll"))
			textLabel:setPosition(self.bgSize.width/5*1-20,textHeight)
        elseif i==2 then
            tabBtnItem = CCMenuItemImage:create("worldBtnSelf.png", "worldBtnSelf_Down.png","worldBtnSelf_Down.png")
			tabBtnItem:setPosition(self.bgSize.width/5*2-10,height)
			textLabel:setString(getlocal("bookmarksResource"))
			textLabel:setPosition(self.bgSize.width/5*2-10,textHeight)
		elseif i==3 then
			tabBtnItem = CCMenuItemImage:create("worldBtnEnemy.png", "worldBtnEnemy_Down.png","worldBtnEnemy_Down.png")
			tabBtnItem:setPosition(self.bgSize.width/5*3+10,height)
			textLabel:setString(getlocal("bookmarksEnemy"))
			textLabel:setPosition(self.bgSize.width/5*3+10,textHeight)
		elseif i==4 then
			tabBtnItem = CCMenuItemImage:create("worldBtnFriend.png", "worldBtnFriend_Down.png","worldBtnFriend_Down.png")
			tabBtnItem:setPosition(self.bgSize.width/5*4+20,height)
			textLabel:setString(getlocal("bookmarksFriend"))
			textLabel:setPosition(self.bgSize.width/5*4+20,textHeight)
        end
       	textLabel:setColor(G_ColorGreen)
		self.bgLayer:addChild(textLabel)
		
        tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))
	    local function tabClick(idx)
	        return self:tabClick(idx)
	    end
        tabBtnItem:registerScriptTapHandler(tabClick)
		
        if tabIndex==self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end

        self.allTabs[i]=tabBtnItem
        tabBtn:addChild(tabBtnItem)
        tabBtn:setTouchPriority(-44)
        tabBtnItem:setTag(tabIndex)
        tabIndex=tabIndex+1
	end
    tabBtn:setPosition(0,0)
   	self.bgLayer:addChild(tabBtn)
    
    
end

--设置对话框里的tableView
function bookmarkDialog:initTableView()
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-30))
	self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-115))
	
	self.bookmarkTb = bookmarkVoApi:getBookmarkByType(self.selectedTabIndex)
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-45,self.bgLayer:getContentSize().height-270),nil)
    self.bgLayer:setTouchPriority(-41)
    self.tv:setTableViewTouchPriority(-43)
    self.tv:setPosition(ccp(22.5,175))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    
    local tab=bookmarkVoApi:getAllBookmark()
    for k,v in pairs(tab) do
        local i1=v.id
        local i2={v.type[1],v.type[2],v.type[3]}
        local i3=v.name
        local i4=v.x
        local i5=v.y
        self.recordMarkTab[k]={i1,i2,i3,i4,i5}
    end
	
	self:doUserHandler()
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function bookmarkDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local num = self.bookmarkTb and SizeOfTable(self.bookmarkTb) or bookmarkVoApi:getBookmarkNum(self.selectedTabIndex)
		return num
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(580,150)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local bookmarks = self.bookmarkTb or bookmarkVoApi:getBookmarkByType(self.selectedTabIndex)
		local bookmarkVo=bookmarks[idx+1]
		
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick(hd,fn,idx)
		end
		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
		backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-45, 140))
		backSprie:ignoreAnchorPointForPosition(false)
		backSprie:setAnchorPoint(ccp(0,0))
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-42)
		backSprie:setPosition(ccp(0,0))
		cell:addChild(backSprie,1)
		
		local function operateHandler(tag,object)
			PlayEffect(audioCfg.mouseClick)
			if tag==101 then
				worldScene:focus(bookmarkVo.x,bookmarkVo.y)
				self:close(false)
			elseif tag==102 then
                local function touchDelete()
                    
                     local function serverRemove(fn,data)
                          --local retTb=OBJDEF:decode(data)

                          if base:checkServerData(data)==true then
                            --self.recordMarkTab=bookmarkVoApi:getAllBookmark()
                            self.bookmarkTb = bookmarkVoApi:getBookmarkByType(self.selectedTabIndex)
                            self.tv:reloadData()
                            self:doUserHandler()
                          end
                    end
                    socketHelper:removeBookmark(bookmarkVo.id,serverRemove)
                    --bookmarkVoApi:deleteBookmark(bookmarkVo.x,bookmarkVo.y)
                    
                end

                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchDelete,getlocal("dialog_title_prompt"),getlocal("collect_scene_delete_prompt",{bookmarkVo.name,bookmarkVo.x,bookmarkVo.y}),nil,4)
				
			elseif tag==103 then
				bookmarkVoApi:changeType(bookmarkVo.x,bookmarkVo.y,1)
                
			elseif tag==104 then
				bookmarkVoApi:changeType(bookmarkVo.x,bookmarkVo.y,2)
			elseif tag==105 then
				bookmarkVoApi:changeType(bookmarkVo.x,bookmarkVo.y,3)
			end

		end		
	    local searchBtn=GetButtonItem("worldBtnSearch.png","worldBtnSearch_Down.png","worldBtnPosition_Down.png",operateHandler,101,nil,nil)
       if platCfg.platUseUIWindow[G_curPlatName()]~=nil and platCfg.platUseUIWindow[G_curPlatName()]==2 then
            searchBtn:setScaleX(0.8)
            searchBtn:setScaleY(0.8)
       end

	    searchBtn:setAnchorPoint(ccp(0.5,0.5))
	    local searchBtnMenu=CCMenu:createWithItem(searchBtn)
	    searchBtnMenu:setPosition(ccp(backSprie:getContentSize().width-searchBtn:getContentSize().width/2,45))
	    searchBtnMenu:setTouchPriority(-42)
	    backSprie:addChild(searchBtnMenu,2)
		
	    local deleteBtn=GetButtonItem("IconFault.png","IconFault.png","IconFault.png",operateHandler,102,nil,nil)
	    local deleteBtnMenu=CCMenu:createWithItem(deleteBtn)
	    deleteBtnMenu:setPosition(ccp(backSprie:getContentSize().width-searchBtn:getContentSize().width/2,backSprie:getContentSize().height-40))
	    deleteBtnMenu:setTouchPriority(-42)
	    backSprie:addChild(deleteBtnMenu,2)

		self.btnTab[idx]={}
	    local tabBtn=CCMenu:create()
		for i=1,3 do
			local height=0
			local tabBtnItem
	        if i==1 then
				local collectionSp1 = CCSprite:createWithSpriteFrameName("worldBtnSelf.png")
		        local collectionSp2 = CCSprite:createWithSpriteFrameName("worldBtnSelf.png")
		        local collectionItemSp = CCMenuItemSprite:create(collectionSp1,collectionSp2)
				local selectSp3 = CCSprite:createWithSpriteFrameName("worldBtnSelf_Down.png")
				local selectSp4 = CCSprite:createWithSpriteFrameName("worldBtnSelf_Down.png")
				local menuItemSp2 = CCMenuItemSprite:create(selectSp3,selectSp4)
		        tabBtnItem = CCMenuItemToggle:create(collectionItemSp)
				tabBtnItem:addSubItem(menuItemSp2)
				tabBtnItem:setPosition(0,height)
			elseif i==2 then
				local collectionSp1 = CCSprite:createWithSpriteFrameName("worldBtnEnemy.png")
		        local collectionSp2 = CCSprite:createWithSpriteFrameName("worldBtnEnemy.png")
		        local collectionItemSp = CCMenuItemSprite:create(collectionSp1,collectionSp2)
				local selectSp3 = CCSprite:createWithSpriteFrameName("worldBtnEnemy_Down.png")
				local selectSp4 = CCSprite:createWithSpriteFrameName("worldBtnEnemy_Down.png")
				local menuItemSp2 = CCMenuItemSprite:create(selectSp3,selectSp4)
		        tabBtnItem = CCMenuItemToggle:create(collectionItemSp)
				tabBtnItem:addSubItem(menuItemSp2)
				tabBtnItem:setPosition(120,height+3)
			elseif i==3 then
				local collectionSp1 = CCSprite:createWithSpriteFrameName("worldBtnFriend.png")
		        local collectionSp2 = CCSprite:createWithSpriteFrameName("worldBtnFriend.png")
		        local collectionItemSp = CCMenuItemSprite:create(collectionSp1,collectionSp2)
				local selectSp3 = CCSprite:createWithSpriteFrameName("worldBtnFriend_Down.png")
				local selectSp4 = CCSprite:createWithSpriteFrameName("worldBtnFriend_Down.png")
				local menuItemSp2 = CCMenuItemSprite:create(selectSp3,selectSp4)
		        tabBtnItem = CCMenuItemToggle:create(collectionItemSp)
				tabBtnItem:addSubItem(menuItemSp2)
				tabBtnItem:setPosition(240,height+3)
	        end
	        tabBtnItem:setAnchorPoint(CCPointMake(0,0))
	        tabBtnItem:registerScriptTapHandler(operateHandler)
			
			if bookmarkVoApi:isBookmark(bookmarkVo.x,bookmarkVo.y,i) then
				tabBtnItem:setSelectedIndex(1)
			else
				tabBtnItem:setSelectedIndex(0)
			end
	        tabBtn:addChild(tabBtnItem)
	        tabBtnItem:setTag(102+i)
			table.insert(self.btnTab[idx],102+i,tabBtnItem)
		end
		tabBtn:setPosition(ccp(155,0))
		tabBtn:setTouchPriority(-42)
		backSprie:addChild(tabBtn,2)
		
		local writeIcon = CCSprite:createWithSpriteFrameName("worldBtnModify.png")
      	writeIcon:setPosition(ccp(backSprie:getContentSize().width-80-writeIcon:getContentSize().width/2+5,backSprie:getContentSize().height-writeIcon:getContentSize().height/2))
		backSprie:addChild(writeIcon,2)
	   	
		local function tthandler()
		end
		local bookmarkBox=LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10,10,5,5),tthandler)
		bookmarkBox:setContentSize(CCSizeMake(backSprie:getContentSize().width/4*3-10,60))
		bookmarkBox:ignoreAnchorPointForPosition(false)
		bookmarkBox:setAnchorPoint(ccp(0,1))
		bookmarkBox:setIsSallow(false)
		bookmarkBox:setTouchPriority(-42)
		bookmarkBox:setPosition(ccp(5,backSprie:getContentSize().height-5))
		backSprie:addChild(bookmarkBox,1)

		local function callBackBookmarkHandler(fn,eB,str)
			if str==nil then
				bookmarkVoApi:changeText(bookmarkVo.x,bookmarkVo.y,"")
			else
				bookmarkVoApi:changeText(bookmarkVo.x,bookmarkVo.y,str)
			end
		end
		
	    local bookmarkLabel=GetTTFLabelWrap("",20,CCSizeMake(bookmarkBox:getContentSize().width-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		bookmarkLabel:setAnchorPoint(ccp(0,0.5))
	    bookmarkLabel:setPosition(ccp(10,bookmarkBox:getContentSize().height/2))
		if bookmarkVo.name==nil then
			bookmarkLabel:setString("")
		else
			bookmarkLabel:setString(bookmarkVo.name)
		end
		
		local customEditBox=customEditBox:new()
		local length=40
		local function clickCallback()
            if self and self.tv then
                return self.tv:getIsScrolled()
            else
                return false
            end
		end
		-- customEditBox:init(bookmarkBox,bookmarkLabel,"mail_input_bg.png",CCSizeMake(backSprie:getContentSize().width/8*7-10,60),-42,length,callBackBookmarkHandler,nil,nil,true,clickCallback)
		customEditBox:init(bookmarkBox,bookmarkLabel,"mail_input_bg.png",CCSizeMake(bookmarkBox:getContentSize().width-10,60),-42,length,callBackBookmarkHandler,nil,nil,true,clickCallback)
		local placeLb=GetTTFLabel(getlocal("city_info_coordinate_style",{bookmarkVo.x,bookmarkVo.y}),20)
	    placeLb:setAnchorPoint(ccp(0,0))
	    placeLb:setPosition(ccp(10,25))
	    backSprie:addChild(placeLb,1)

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
function bookmarkDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self.bookmarkTb = bookmarkVoApi:getBookmarkByType(self.selectedTabIndex)
            self.tv:reloadData()
            self:doUserHandler()
        else
            v:setEnabled(true)
        end
    end
end

--用户处理特殊需求,没有可以不写此方法
function bookmarkDialog:doUserHandler()
	if self.noBookmarksLabel==nil then
	    self.noBookmarksLabel=GetTTFLabel(getlocal("noBookmarks"),20)
		self.noBookmarksLabel:setAnchorPoint(ccp(0.5,0.5))
	    self.noBookmarksLabel:setPosition(ccp(self.panelLineBg:getContentSize().width/2,self.panelLineBg:getContentSize().height/2+100))
		self.bgLayer:addChild(self.noBookmarksLabel,1)
		self.noBookmarksLabel:setColor(G_ColorGray)
	end
	local bookmarksNum=bookmarkVoApi:getBookmarkNum(self.selectedTabIndex)
	if bookmarksNum>0 then
		self.noBookmarksLabel:setVisible(false)
	else
		self.noBookmarksLabel:setVisible(true)
	end
end

function bookmarkDialog:realCloseSend()
    

end

function bookmarkDialog:doSendOnClose()
    local isSend=false
     local tab=bookmarkVoApi:getAllBookmark()
    local tabBook={}
    for k,v in pairs(tab) do
        if v.name~=self.recordMarkTab[k][3] or v.type[1]~=self.recordMarkTab[k][2][1] or v.type[2]~=self.recordMarkTab[k][2][2] or v.type[3]~=self.recordMarkTab[k][2][3] then
            do
                tabBook[k]=v  
                isSend=true              
            end
        end
    end
    local tabMarkUp={}
    for k,v in pairs(tabBook) do
        local hasEmjoy=G_checkEmjoy(v.name)
        if hasEmjoy==false then
        	isSend=false
            do return end
        end
        local mark={}
        local mid="m"..v.id
        tabMarkUp[mid]={v.name,v.x,v.y,v.type,v.t}
    end
    if isSend==true then
        local function serverUpgrade(fn,data)
              --local retTb=OBJDEF:decode(data)

              if base:checkServerData(data)==true then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("collect_scene_save_ok"),28)
              else
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("collect_scene_save_fail"),28)

              end
        end
        socketHelper:updateBookmark(tabMarkUp,serverUpgrade)
    end

end

function bookmarkDialog:dispose()
	self.noBookmarksLabel=nil
	self.btnTab={}
	self=nil
end








