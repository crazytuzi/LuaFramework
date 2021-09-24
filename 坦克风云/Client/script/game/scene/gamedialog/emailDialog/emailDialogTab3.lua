emailDialogTab3={}

function emailDialogTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	
	self.normalHeight=120
	self.writeBtn=nil
	self.deleteBtn=nil
	self.unreadLabel=nil
	self.totalLabel=nil
	self.tvHeight=nil
	self.canClick=false
	self.mailClick=0
	self.noEmailLabel=nil
	
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
	self.selectedTabIndex=2
	self.emailDialog=nil
	
    return nc
end

function emailDialogTab3:init(layerNum,selectedTabIndex,emailDialog)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
	self.selectedTabIndex=selectedTabIndex
	self.emailDialog=emailDialog
    self:initTableView()
    
    return self.bgLayer
end

--设置对话框里的tableView
function emailDialogTab3:initTableView()
	self.tvHeight=self.bgLayer:getContentSize().height-340
    local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,self.tvHeight),nil)
    --self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,165))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(self.normalHeight)
end
--[[
function emailDialogTab3:getDataByType(type)
	if type==nil then
		type=1
	end	
	local flag=emailVoApi:getFlag(type)
	local function showEmailList(fn,data)
		if base:checkServerData(data)==true then
		      self:refresh()										
		end
	end
	if self.noEmailLabel then
		self.noEmailLabel:setVisible(false)
	end
	if flag==nil or flag==-1 then
		socketHelper:emailList(type,0,0,showEmailList,1)
	else
		self:refresh()
	end
end
]]

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function emailDialogTab3:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local hasMore=emailVoApi:hasMore(self.selectedTabIndex+1)
		local num=emailVoApi:getNumByType(self.selectedTabIndex+1)
		if hasMore then
			num=num+1
		end
		return num
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,self.normalHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		
		local hasMore=emailVoApi:hasMore(self.selectedTabIndex+1)
		local num=emailVoApi:getNumByType(self.selectedTabIndex+1)
		local emailVoTab=emailVoApi:getEmailsByType(self.selectedTabIndex+1)
		
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick(hd,fn,idx)
			return self:cellClick(idx)
		end
		local backSprie
		if hasMore and idx==num then
			backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
			backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, self.normalHeight-2))
			backSprie:ignoreAnchorPointForPosition(false);
			backSprie:setAnchorPoint(ccp(0.5,0));
			backSprie:setTag(idx)
			backSprie:setIsSallow(false)
			backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
			backSprie:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2,0));
			cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, self.normalHeight))
			cell:addChild(backSprie,1)
			
			local moreLabel=GetTTFLabel(getlocal("showMoreTen"),24)
			moreLabel:setPosition(getCenterPoint(backSprie))
			backSprie:addChild(moreLabel,2)
			
			return cell
		end

		local emailVo=emailVoTab[idx+1]
		if emailVo.isRead==1 then
			backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("newReadBg.png",CCRect(5,5,1,1),cellClick)
		else
			backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("newUnReadBg.png",CCRect(5,23,1,1),cellClick)
		end
		backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, self.normalHeight-10))
		backSprie:ignoreAnchorPointForPosition(false);
		backSprie:setAnchorPoint(ccp(0.5,0));
		backSprie:setTag(idx)
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2,5));
		cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, self.normalHeight))
		cell:addChild(backSprie,1)
		
		local emailIconBg
		if emailVo.isRead==1 then
			emailIconBg=LuaCCScale9Sprite:createWithSpriteFrameName("emailNewUI_readIconBg.png",CCRect(16,16,2,2),function()end)
		else
			emailIconBg=LuaCCScale9Sprite:createWithSpriteFrameName("newChat_head_shade.png",CCRect(16,16,2,2),function()end)
		end
		emailIconBg:setContentSize(CCSizeMake(backSprie:getContentSize().height,backSprie:getContentSize().height))
		emailIconBg:setAnchorPoint(ccp(0,0.5))
		emailIconBg:setPosition(0,backSprie:getContentSize().height/2)
		backSprie:addChild(emailIconBg)

		local emailIcon
		if emailVo.isRead==1 then
			emailIcon=CCSprite:createWithSpriteFrameName("emailNewUI_readIcon.png")
		else
			emailIcon=CCSprite:createWithSpriteFrameName("emailNewUI_unReadIcon.png")
		end
		emailIcon:setPosition(getCenterPoint(emailIconBg))
		emailIconBg:addChild(emailIcon,2)

		local _posX=emailIconBg:getPositionX()+emailIconBg:getContentSize().width+10
		
		local fromToLabel
    	if self.selectedTabIndex==0 or self.selectedTabIndex==1 then
        	fromToLabel=GetTTFLabel(getlocal("email_from",{emailVo.from}),20)
		elseif self.selectedTabIndex==2 then
			fromToLabel=GetTTFLabel(getlocal("email_to",{emailVo.to}),20)
			for k,v in pairs(GM_Name) do
	            if v == emailVo.to then
	                fromToLabel:setColor(G_ColorYellowPro)
	                do break end
	            end
	        end
		end
		fromToLabel:setAnchorPoint(ccp(0,0))
		fromToLabel:setPosition(_posX,65)
		backSprie:addChild(fromToLabel)
		
		local noticeSp
		local spSize=40
		if emailVo.isAllianceEmail and emailVo.isAllianceEmail==1 then
			noticeSp=CCSprite:createWithSpriteFrameName("Icon_warn.png")
			noticeSp:setAnchorPoint(ccp(0.5,0.5))
			noticeSp:setPosition(ccp(_posX+spSize/2,80))
		    noticeSp:setScale(spSize/noticeSp:getContentSize().width)
			backSprie:addChild(noticeSp)

			fromToLabel:setPosition(_posX,15)
		end
		
		local titleStr=emailVo.title
		if titleStr and titleStr~="" then
			local lbWidth=25*16
			if noticeSp then
				lbWidth=lbWidth-(spSize+5)
			end
			local titleLabel=GetTTFLabelWrap(titleStr,24,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
			titleLabel:setAnchorPoint(ccp(0,0.5))
			titleLabel:setColor(G_ColorYellow)
			backSprie:addChild(titleLabel,2)
			local lbx=_posX
			if noticeSp then
				lbx=lbx+spSize+5
			end
			titleLabel:setPosition(lbx,80)

			local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("reportWhiteLine.png",CCRect(4,0,1,2),function()end)
	        lineSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40-emailIconBg:getContentSize().width-24, 2))
	        lineSp:setAnchorPoint(ccp(0,1))
	        lineSp:setPosition(emailIconBg:getContentSize().width+12,titleLabel:getPositionY()-titleLabel:getContentSize().height/2-5)
	        lineSp:setOpacity(255*0.06)
	        backSprie:addChild(lineSp)
			
			fromToLabel:setPosition(_posX,15)
		end
		
		local timeLabel=GetTTFLabel(emailVoApi:getTimeStr(emailVo.time),20)
		timeLabel:setAnchorPoint(ccp(1,0))
		timeLabel:setPosition(backSprie:getContentSize().width-25,15)
		backSprie:addChild(timeLabel,2)

		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

--点击了cell或cell上某个按钮
function emailDialogTab3:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        PlayEffect(audioCfg.mouseClick)
		local type=self.selectedTabIndex+1
		local num=emailVoApi:getNumByType(type)
		local hasMore=emailVoApi:hasMore(type)
		local nextHasMore=false
		if hasMore and tostring(idx)==tostring(num) then
			local function emailListCallback(fn,data)
				if base:checkServerData(data)==true then
					self.canClick=true
					local newNum=emailVoApi:getNumByType(type)
					local diffNum=newNum-num
					local nextHasMore=emailVoApi:hasMore(type)
					if nextHasMore then
						diffNum=diffNum+1
					end
					local recordPoint = self.tv:getRecordPoint()
					self:refresh()
					recordPoint.y=-(diffNum-1)*self.normalHeight+recordPoint.y
					self.tv:recoverToRecordPoint(recordPoint)
					--emailVoApi:setRefreshFlag(self.selectedTabIndex+1,1)
					emailVoApi:setFlag(self.selectedTabIndex+1,1)
					self.canClick=false
				end
			end
			if self.canClick==false then
				local mineid,maxeid=emailVoApi:getMinAndMaxEid(type)
				socketHelper:emailList(type,mineid,maxeid,emailListCallback,1,true)
			end
		else
			if self.mailClick==0 then
				self.mailClick=1
				local emailVoTab=emailVoApi:getEmailsByType(type)
				local emailVo=emailVoTab[idx+1]
				local eid=emailVo.eid
				local ifCallBack=false
				if type==2 then
					local report=reportVoApi:getReport(eid)
					if report==nil then
						ifCallBack=true
					end
				else
					if emailVo.content==nil or emailVo.content=="" then
						ifCallBack=true
					end
				end
				--if emailVo and emailVo.isRead==0 then
				if ifCallBack==true then
					local function readEmailCallback(fn,data)
						if base:checkServerData(data)==true then
							self:showDetailDialog(emailVo)
							if emailVo.isRead==0 then
								emailVoApi:setIsRead(type,eid)
								if self==nil or self.tv==nil then
									do return end
								end
								local recordPoint = self.tv:getRecordPoint()
								self:refresh()
								self.tv:recoverToRecordPoint(recordPoint)
							end
						end
					end
					socketHelper:readEmail(type,eid,readEmailCallback)
				else
					self:showDetailDialog(emailVo)
				end
			end
		end
    end
end

function emailDialogTab3:showDetailDialog(emailVo)
	local titleStr=getlocal("email_read")
	if self.selectedTabIndex==1 then
		local report=emailVoApi:getReport(emailVo.eid)
		if report~=nil then
			if report.type==1 then
				titleStr=getlocal("fight_content_fight_title")
			elseif report.type==2 then
				titleStr=getlocal("scout_content_scout_title")
			elseif report.type==3 then
				titleStr=getlocal("fight_content_return_title")
			end
		end
	end
    require "luascript/script/game/scene/gamedialog/emailDetailDialog"
	local layerNum=4
	local td=emailDetailDialog:new(layerNum,self.selectedTabIndex+1,emailVo.eid)
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,titleStr,false,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

function emailDialogTab3:tick()
	if self.mailClick>0 then
		self.mailClick=0
	end
	--local flag=emailVoApi:getRefreshFlag(self.selectedTabIndex+1)
	local flag=emailVoApi:getFlag(self.selectedTabIndex+1)
	if flag==0 then
		--local recordPointOld = self.tv:getRecordPoint()
		self:refresh()
		--[[
		local recordPointNew = self.tv:getRecordPoint()
		if recordPointOld.y<=0 and recordPointNew.y<=0 then
			self.tv:recoverToRecordPoint(recordPointOld)
		end
		]]
		--emailVoApi:setRefreshFlag(self.selectedTabIndex+1,1)
		emailVoApi:setFlag(self.selectedTabIndex+1,1)
	end
end

function emailDialogTab3:refresh()
	if self~=nil then
		if self.emailDialog then
			self.emailDialog:doUserHandler()
		end
		if self.tv~=nil then
			self.tv:reloadData()
		end
	end
end

function emailDialogTab3:dispose()
	self.mailClick=nil
	self.canClick=nil
	self.normalHeight=nil
	self.writeBtn=nil
	self.deleteBtn=nil
	self.unreadLabel=nil
	self.totalLabel=nil
	self.tvHeight=nil
	self.noEmailLabel=nil
	
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
	self.selectedTabIndex=0
	self.emailDialog=nil
	
    self=nil
end






