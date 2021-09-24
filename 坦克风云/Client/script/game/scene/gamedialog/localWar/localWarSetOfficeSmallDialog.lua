localWarSetOfficeSmallDialog=smallDialog:new()

function localWarSetOfficeSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogHeight=850
	self.dialogWidth=600
	-- self.pageCellNum=10
	self.cellHeight=75
	self.allianceMem={}
	self.selectedMemId=0

	return nc
end

function localWarSetOfficeSmallDialog:updateAllianceMember()
	if self.officeId==10 then
		self.allianceMem=G_clone(localWarVoApi:getSlaveList())
	else
		local selfAlliance=allianceVoApi:getSelfAlliance()
		if selfAlliance then
			local memTab=G_clone(allianceMemberVoApi:getMemberTab())
			self.allianceMem=memTab
			local featList=localWarVoApi:getAllianceMemFeatList()
			for k,v in pairs(self.allianceMem) do
				v.uid=tonumber(v.uid)
				v.feat=0
				for m,n in pairs(featList) do
					if v and v.uid and m and n and tonumber(m) and tonumber(v.uid)==tonumber(m) then
						v.feat=tonumber(n) or 0
					end
				end
			end
		end
	end
	if self.allianceMem and SizeOfTable(self.allianceMem)>0 then
		local tempTab={}
		local officeTab=localWarVoApi:getOfficeTab()
		for k,v in pairs(officeTab) do
			if v and SizeOfTable(v)>0 then
				-- if k=="j10" then
					for m,n in pairs(v) do
						if n and SizeOfTable(n)>0 then
							local uid=n[1]
							table.insert(tempTab,uid)
						end
					end
				-- else
				-- 	local uid=v[1]
				-- 	table.insert(tempTab,uid)
				-- end
			end
		end
		for k,v in pairs(tempTab) do
			for m,n in pairs(self.allianceMem) do
				if v and n and n.uid and tonumber(n.uid)==tonumber(v) then
					table.remove(self.allianceMem,m)
				end
			end
		end
		local function sortFunc(a,b)
			if a and b then
				if a.feat and b.feat and a.feat~=b.feat then
					return a.feat>b.feat
				elseif tonumber(a.uid) and tonumber(b.uid) then
					return tonumber(a.uid)<tonumber(b.uid)
				end
			end
		end
		table.sort(self.allianceMem,sortFunc)
	end
end

function localWarSetOfficeSmallDialog:init(layerNum,officeId)
	self.layerNum=layerNum
	self.officeId=officeId

	if self.officeId==nil then
		do return end
	end

	self:updateAllianceMember()
	if self.allianceMem and self.allianceMem[1] then
		self.selectedMemId=self.allianceMem[1].uid or 0
	end

	local function nilFunc()
	end

	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168,86,10,10),nilFunc)
	self.dialogLayer=CCLayer:create()
	
	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	local function close()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
		 
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)
	
	local cfg=localWarCfg.jobs[self.officeId]
	local title=cfg.title
	local titleLb=GetTTFLabel(getlocal(title),40)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
	dialogBg:addChild(titleLb)

	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1);

	self:initHeader()
	self:initBottom()
	self:initTableBg()
	self:initTableView()

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
end

function localWarSetOfficeSmallDialog:initHeader()
	local cfg=localWarCfg.jobs[self.officeId]
	local title=cfg.title
	local pic=cfg.pic
	local buff=cfg.buff
	local buffStr=""
	for k,v in pairs(buff) do
		if v then
			if buffStr=="" then
				buffStr=localWarVoApi:getBuffStr(v)
			else
				buffStr=buffStr.."\n"..localWarVoApi:getBuffStr(v)
			end
		end
	end

	local headerW=self.dialogWidth-20
	local headerH=150
	local function cellClick(hd,fn,idx)
	end
	local headerSprie=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),cellClick)
	headerSprie:setAnchorPoint(ccp(0.5,1))
	headerSprie:setContentSize(CCSizeMake(headerW,headerH))
	headerSprie:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-85));
	self.bgLayer:addChild(headerSprie)

	local spScale=0.8
	local officeSp=CCSprite:createWithSpriteFrameName(pic)
	officeSp:setPosition(ccp(20+officeSp:getContentSize().width/2*spScale,headerH/2))
	headerSprie:addChild(officeSp)
	local officeBg=CCSprite:createWithSpriteFrameName("heroHead1.png")
	officeBg:setPosition(getCenterPoint(officeSp))
	officeSp:addChild(officeBg)
	officeSp:setScale(spScale)

	local lbWidth=headerSprie:getContentSize().width-officeSp:getContentSize().width*spScale-80
	local lbPosX=officeSp:getContentSize().width*spScale+40
	local lbTb={
        {getlocal("local_war_office_effect"),25,ccp(0,0.5),ccp(lbPosX,headerH-20),headerSprie,1,nil,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {buffStr,25,ccp(0,0.5),ccp(lbPosX,(headerH-30)/2),headerSprie,1,G_ColorGreen,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
    }
    for k,v in pairs(lbTb) do
        GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
    end
end
function localWarSetOfficeSmallDialog:initBottom()
	local bottomH=100
	local function cellClick(hd,fn,idx)
	end
	local bottomSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
	bottomSprie:setAnchorPoint(ccp(0.5,0))
	bottomSprie:setContentSize(CCSizeMake(self.dialogWidth-20,bottomH))
	bottomSprie:setPosition(ccp(self.dialogWidth/2,10))
	self.bgLayer:addChild(bottomSprie)
	local midY=bottomSprie:getContentSize().height/2

	local iconScale=0.6
	local allianceNumSp=CCSprite:createWithSpriteFrameName("allianceMemberIcon.png")
	allianceNumSp:setAnchorPoint(ccp(0.5,0.5))
	allianceNumSp:setPosition(ccp(40,midY+20))
	bottomSprie:addChild(allianceNumSp)
	allianceNumSp:setScale(iconScale)
	local num=SizeOfTable(self.allianceMem)
	local allianceNumLb=GetTTFLabel(num,25)
    allianceNumLb:setAnchorPoint(ccp(0.5,0.5))
	allianceNumLb:setPosition(ccp(40,midY-20))
	bottomSprie:addChild(allianceNumLb)

	local descLb=GetTTFLabelWrap(getlocal("local_war_office_no_change"),20,CCSizeMake(bottomSprie:getContentSize().width-300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0,0.5))
	descLb:setColor(G_ColorRed)
	descLb:setPosition(ccp(80,midY))
	bottomSprie:addChild(descLb)

	local midY=bottomSprie:getContentSize().height/2
	local function onPromoteHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if self.officeId and self.selectedMemId and self.selectedMemId>0 then
        	local jobid=self.officeId
        	local memuid=self.selectedMemId
	        local function setOfficeCallback()
				local nameStr=""
				if self.allianceMem then
					for k,v in pairs(self.allianceMem) do
						if v and v.uid==memuid then
							nameStr=v.name
						end
					end
				end
				local officeStr=""
	        	if localWarCfg.jobs[jobid] and localWarCfg.jobs[jobid].title then
	        		officeStr=getlocal(localWarCfg.jobs[jobid].title)
	        	end
	        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("local_war_office_set_success",{nameStr,officeStr}),30)
	        	self:close()
	        end
			localWarVoApi:setOffice(jobid,memuid,setOfficeCallback)
		end
	end
	local pStr=""
	if self.officeId==10 then
		pStr=getlocal("local_war_office_enslave")
	else
		pStr=getlocal("local_war_office_promoted")
	end
	local promoteItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onPromoteHandler,nil,pStr,25)
	local promoteMenu=CCMenu:createWithItem(promoteItem)
	promoteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	promoteMenu:setPosition(ccp(bottomSprie:getContentSize().width-100,midY))
	bottomSprie:addChild(promoteMenu)
	if self.allianceMem and SizeOfTable(self.allianceMem)>0 then
	else
		promoteItem:setEnabled(false)
	end
end

function localWarSetOfficeSmallDialog:initTableBg()
	local function nilFunc()
	end
	self.panelLineBg = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),nilFunc)
	self.panelLineBg:setContentSize(CCSizeMake(self.dialogWidth-20,self.dialogHeight-345))
	self.panelLineBg:setAnchorPoint(ccp(0.5,0))
	self.panelLineBg:setPosition(ccp(self.dialogWidth/2,110))
	self.bgLayer:addChild(self.panelLineBg)
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(20,20,10,10),nilFunc)
    titleBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,self.cellHeight-10))
    titleBg:setScaleX(self.panelLineBg:getContentSize().width/titleBg:getContentSize().width)
    titleBg:setAnchorPoint(ccp(0,1))
    titleBg:setPosition(ccp(0,self.panelLineBg:getContentSize().height))
    self.panelLineBg:addChild(titleBg)
    local color=G_ColorGreen
    local titleY=self.panelLineBg:getContentSize().height-(self.cellHeight-10)/2
	local operatorLb=GetTTFLabel(getlocal("alliance_list_scene_operator"),25)
	operatorLb:setPosition(ccp(55+5,titleY))
	self.panelLineBg:addChild(operatorLb)
	operatorLb:setColor(color)

	local nameLb=GetTTFLabel(getlocal("alliance_scene_button_info_name"),25)
	nameLb:setPosition(ccp(225+5,titleY))
	self.panelLineBg:addChild(nameLb)
	nameLb:setColor(color)

	local officeLb=GetTTFLabel(getlocal("local_war_help_title8"),25)
	officeLb:setPosition(ccp(400+5,titleY))
	self.panelLineBg:addChild(officeLb)
	officeLb:setColor(color)

	local featLb=GetTTFLabel(getlocal("local_war_alliance_feat"),25)
	featLb:setPosition(ccp(500+5,titleY))
	self.panelLineBg:addChild(featLb)
	featLb:setColor(color)

end

function localWarSetOfficeSmallDialog:initTableView()
    local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth,self.panelLineBg:getContentSize().height-88),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(5,10))
    self.panelLineBg:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(self.cellHeight)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function localWarSetOfficeSmallDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local num=(#self.allianceMem)
    	return num
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.dialogWidth,self.cellHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
    	local cell=CCTableViewCell:new()
    	cell:autorelease()

    	if idx==0 then
	    	local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png");
			lineSp1:setAnchorPoint(ccp(0.5,0.5))
			lineSp1:setScaleX(self.dialogWidth/lineSp1:getContentSize().width)
			lineSp1:setScaleY(1.2)
			lineSp1:setPosition(ccp(self.dialogWidth/2,self.cellHeight))
			cell:addChild(lineSp1)
		end

    	local midY=self.cellHeight/2

    	local memItem=self.allianceMem[idx+1]
    	local uid=memItem.uid
    	local name=memItem.name
    	local role=memItem.role
    	local feat=memItem.feat or 0
    	if tonumber(uid) == tonumber(playerVoApi:getUid()) then
    		name = playerVoApi:getPlayerName()
    	end

    	local function onClickCheckBox(object,name,tag)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                local memItem=self.allianceMem[idx+1]
		    	local uid=memItem.uid

                if self.selectedMemId==uid then
                else
                	self.selectedMemId=uid
                	local recordPoint=self.tv:getRecordPoint()
					self.tv:reloadData()
					self.tv:recoverToRecordPoint(recordPoint)
                end
            end
    	end
    	local function nilFunc()
    	end
    	local checkBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",onClickCheckBox)
		checkBox:setPosition(ccp(55,midY))
		checkBox:setTouchPriority(-(self.layerNum-1)*20-2)
		checkBox:setTag(1)
		cell:addChild(checkBox)
		local uncheckBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",onClickCheckBox)
		uncheckBox:setPosition(ccp(55,midY))
		uncheckBox:setTouchPriority(-(self.layerNum-1)*20-2)
		uncheckBox:setTag(2)
		cell:addChild(uncheckBox)
    	if self.selectedMemId==uid then
    		checkBox:setVisible(true)
    		uncheckBox:setVisible(false)
    	else
    		checkBox:setVisible(false)
    		uncheckBox:setVisible(true)
    	end

    	local color=G_ColorWhite
    	local nameLb=GetTTFLabel(name,25)
		nameLb:setPosition(ccp(225,midY))
		cell:addChild(nameLb)
		nameLb:setColor(color)

		-- local officeLb=GetTTFLabel(role,25)
		-- officeLb:setPosition(ccp(400,midY))
		-- cell:addChild(officeLb)
		-- officeLb:setColor(color)
		local roleSp
        if role==2 then
            roleSp=CCSprite:createWithSpriteFrameName("positiveHead.png")
        elseif role==1 then
            roleSp=CCSprite:createWithSpriteFrameName("deputyHead.png")
        else
            roleSp=CCSprite:createWithSpriteFrameName("soldierIcon.png")
        end
        roleSp:setPosition(ccp(400,midY))
        cell:addChild(roleSp)

		local featLb=GetTTFLabel(feat,25)
		featLb:setPosition(ccp(500,midY))
		cell:addChild(featLb)
		featLb:setColor(color)

		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
		lineSp:setAnchorPoint(ccp(0.5,0.5))
		lineSp:setScaleX(self.dialogWidth/lineSp:getContentSize().width)
		lineSp:setScaleY(1.2)
		lineSp:setPosition(ccp(self.dialogWidth/2,0))
		cell:addChild(lineSp)

    	return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end
