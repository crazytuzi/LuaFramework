planeSkillSelectDialog=commonDialog:new()

function planeSkillSelectDialog:new(planeVo,pos,activeFlag)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.planeVo=planeVo
    nc.pos=pos
    nc.activeFlag=activeFlag or false --是否是主动技能的标记
    nc.index=index
    nc.emptyLb=nil
	nc.nameLb=nil
	nc.attrLb=nil
	nc.valueLb=nil
	nc.skillIcon=nil
	nc.removeItem=nil
	nc.headerSprie=nil
	nc.amList=nil
	nc.everyCellNum=25
	nc.sid=nil
    nc.amLayer=nil
    nc.page=1
    nc.curPageFlag=nil
    nc.pageFlagList={}
    nc.tvTab={}
    nc.layerBgWidth=G_VisibleSizeWidth-40

	spriteController:addPlist("public/vipFinal.plist")
    return nc
end

function planeSkillSelectDialog:updateData()
	local pid=self.planeVo.pid
	self.planeVo=planeVoApi:getPlaneVoById(pid)
	local equipFlag,sid=self.planeVo:isSkillSlotEquiped(self.pos,self.activeFlag)
	self.amList=planeVoApi:getCanEquipSkill(pid,sid,25,self.activeFlag)
end

--设置对话框里的tableView
function planeSkillSelectDialog:initTableView()
 	self.panelLineBg:setVisible(false)
	local function onLoadIcon(fn,icon)
	    if self and self.bgLayer and icon then
			self.bgLayer:addChild(icon)
			icon:setScaleX(self.bgLayer:getContentSize().width/icon:getContentSize().width)
			icon:setScaleY((self.bgLayer:getContentSize().height-80)/icon:getContentSize().height)
			icon:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-40)
	    end
	end
	local url="http://" .. base.serverUserIp .."/tankheroclient/tankimg/active/buyreward/acBuyrewardjpg4.jpg"
	-- print("url~~~~",url)
	local webImage = LuaCCWebImage:createWithURL(url,onLoadIcon)

	self:updateData()
    if self.amList and SizeOfTable(self.amList)>0 then
	    self:initPage()
	else
		self:refreshGetSkill()
    end

	local function onRefresh(event,data)
		self:refreshSkillPageLayer()
	end
	self.refreshListener=onRefresh
	eventDispatcher:addEventListener("plane.skillpage.refresh",self.refreshListener)
end

function planeSkillSelectDialog:initPage()
	-- self.page=1
    local space=50
    self.list={}
    self.dlist={}
    self.pageFlagList={}
    local poy=self.bgLayer:getContentSize().height-340
    local pfScale=1
    local pageNum=SizeOfTable(self.amList)
    for i=1,pageNum do
        local backSprie=self:initPageBg(i)

        self.list[i]=backSprie
    end

    self.curPageFlag=CCSprite:createWithSpriteFrameName("selectedPoint.png")
    self.curPageFlag:setScale(pfScale)
    self.bgLayer:addChild(self.curPageFlag,3)
    self.curPageFlag:setVisible(false)
    local pxTab=G_getIconSequencePosx(2,space,self.bgLayer:getContentSize().width/2,pageNum)
    for i=1,pageNum do
    	local pageFlag=CCSprite:createWithSpriteFrameName("unselectedPoint.png")
        pageFlag:setScale(pfScale)
        pageFlag:setTag(100 + i)
        self.bgLayer:addChild(pageFlag,2)
        local pox
        if pxTab and pxTab[i] then
        	pox=pxTab[i]
        	pageFlag:setPosition(ccp(pxTab[i],poy))
        else
        	pox=0
        	pageFlag:setVisible(false)
        end
        
        if self.page==i then
        	self:initPageDetail(i)
        	self.curPageFlag:setPosition(ccp(pox,poy))
        	self.curPageFlag:setVisible(true)
        end
        self.pageFlagList[i]=pageFlag
    end
    
    local isShowBg=false
    local isShowPageBtn=true
    local function onPage(topage)
    	-- print("self.page,topage",self.page,topage)
        self.page=topage
        if self.curPageFlag then
        	local pageNum=SizeOfTable(self.amList)
        	local pxTab=G_getIconSequencePosx(2,space,self.bgLayer:getContentSize().width/2,pageNum)
        	if pxTab and pxTab[topage] then
	            local pox=pxTab[topage]
	            self.curPageFlag:setPositionX(pox)
	        end
        end
    end
    local leftBtnPos=ccp(40,poy)
    local rightBtnPos=ccp(self.bgLayer:getContentSize().width-40,poy)
    local function movedCallback(turnType,isTouch)
        local pageNum=SizeOfTable(self.amList)
        local canMove=true
        if self.page and self.tvTab then
            local turnPage=self.page+1
            if turnType==1 then
                turnPage=self.page-1
            end
            if turnPage<=0 then
                turnPage=pageNum
            elseif turnPage>pageNum then
                turnPage=1
            end
            if self.tvTab[turnPage] then            	
            	self:refreshPageDetail(turnPage)
            else
                self:initPageDetail(turnPage)
            end
        end
        return canMove
    end
    self.amPageDialog=pageDialog:new()
    self.amPageDialog:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(20, 20, 10, 10),self.bgLayer,ccp(0,0),self.layerNum,self.page,self.list,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos,movedCallback,-(self.layerNum-1)*20-4,nil,"vipArrow.png",true,nil,150)

    self:refreshMid()
end

function planeSkillSelectDialog:addPage()
    if self.list then
    	local pageNum=1 
	    if SizeOfTable(self.list)>0 then
	    	pageNum=SizeOfTable(self.list)+1
	    end
	    local backSprie=self:initPageBg(pageNum)
	    self.list[pageNum]=backSprie
	end
end
function planeSkillSelectDialog:removePage()
	if self.list then
    	local pageNum=1 
	    if SizeOfTable(self.list)>0 then
	    	pageNum=SizeOfTable(self.list)
	    end
	    if self.tvTab and self.tvTab[pageNum] then
	    	self.tvTab[pageNum]=nil
	    end
	    if self.list[pageNum] then
	    	local backSprie=self.list[pageNum]
	    	table.remove(self.list,pageNum)
	    	if backSprie then
		    	backSprie:removeFromParentAndCleanup(true)
		    	backSprie=nil
		    end
	    end
	    if SizeOfTable(self.list)==0 then
	    	self:pageDispose()
	    end
	end
end

function planeSkillSelectDialog:pageDispose()
	self.amPageDialog=nil
	self.curPageFlag=nil
	if self.pageFlagList then
		for k,v in pairs(self.pageFlagList) do
			self.pageFlagList[k]:removeFromParentAndCleanup(true)
			self.pageFlagList[k]=nil
		end
	end
	self.pageFlagList={}
	if self.curPageFlag then
		self.curPageFlag:removeFromParentAndCleanup(true)
		self.curPageFlag=nil
	end
	self.tvTab={}
	self.list={}
end

function planeSkillSelectDialog:initPageBg(indx)
    local index=indx-1
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
    backSprie:setContentSize(CCSizeMake(self.layerBgWidth,self.tvHeight+self.midH))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    backSprie:setPosition(ccp(20,self.tvPosH))
    self.bgLayer:addChild(backSprie,1)
    backSprie:setOpacity(0)
    return backSprie
end
function planeSkillSelectDialog:initPageDetail(index)
	local page=index
	local backSprie=self.list[page]
    if backSprie then
        backSprie=tolua.cast(backSprie,"LuaCCScale9Sprite")
        local function tvCallBack(handler,fn,idx,cel)
	        if fn=="numberOfCellsInTableView" then
	        	local num=0
	        	if self.amList and page and self.amList[page] then
	        		num=SizeOfTable(self.amList[page])
	        	end
				return num
			elseif fn=="tableCellSizeForIndex" then
				local tmpSize=CCSizeMake(backSprie:getContentSize().width,150)
			    return  tmpSize
			elseif fn=="tableCellAtIndex" then
				local cell=CCTableViewCell:new()
				cell:autorelease()
				local cellWidth=backSprie:getContentSize().width
				local cellHeight=150
				if self.amList and page and self.amList[page] then
				else
					do return cell end
				end
			    local amItem=self.amList[page][idx+1]
			   	local nameStr,descStr=planeVoApi:getSkillInfoById(amItem.sid)
				local function equipHandler()
			        local function skillUsedCallBack( ... )
			        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alien_tech_use_success"),30)
		    	    	if otherGuideMgr.isGuiding==false and otherGuideMgr:checkGuide(38)==false then --教学时装配完技能强制关闭面板
			        		self:close()
					        otherGuideMgr:showGuide(38)
					    else
							self:refreshSkillPageLayer()
					    end
			        end
			        planeVoApi:skillEquipOrRemoveRequest(1,self.planeVo,self.pos,amItem.sid,self.activeFlag,skillUsedCallBack)
				end
			   	local cellBg
			    local capInSet = CCRect(20, 20, 10, 10)
				local function showInfo( ... )
					if self.tvTab[page] and self.tvTab[page]:getScrollEnable()==true and self.tvTab[page]:getIsScrolled()==false then
						if G_checkClickEnable()==false then
							do return end
						else
							base.setWaitTime=G_getCurDeviceMillTime()
						end
			            PlayEffect(audioCfg.mouseClick)
						local function realShow()
							planeVoApi:showInfoDialog(amItem,self.layerNum+1,true,equipHandler)
						end
						if cellBg then
							G_touchedItem(cellBg,realShow)
						end
					end
			    end
			    cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,showInfo)
				cellBg:setContentSize(CCSizeMake(backSprie:getContentSize().width,148))
			    cellBg:setIsSallow(false)
			    cellBg:setTouchPriority(-(self.layerNum-1)*20-2)
				cellBg:setPosition(cellWidth/2,cellHeight/2)
			    cell:addChild(cellBg,1)

			    local bgWidth,bgHeight=cellBg:getContentSize().width,cellBg:getContentSize().height
			    local skillIcon=planeVoApi:getSkillIcon(amItem.sid,100)
				skillIcon:setPosition(ccp(60,bgHeight/2))
				skillIcon:setTouchPriority(-(self.layerNum-1)*20-1)
				cellBg:addChild(skillIcon,1)

				local posy=bgHeight/2
				local nameLb=GetTTFLabelWrap(nameStr,28,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				nameLb:setAnchorPoint(ccp(0,0.5))
				nameLb:setPosition(ccp(120,posy+30))
				cellBg:addChild(nameLb,1)
				local color=planeVoApi:getColorByQuality(amItem.gcfg.color)
				nameLb:setColor(color)

				local attrLb=GetTTFLabel(getlocal("skill_power",{amItem.gcfg.skillStrength}),25)
				attrLb:setAnchorPoint(ccp(0,0.5))
				attrLb:setPosition(ccp(120,posy-30))
				attrLb:setColor(G_ColorGreen)
				cellBg:addChild(attrLb,1)
				--配备按钮
				local function onEquip()
					if self.tvTab[page] and self.tvTab[page]:getScrollEnable()==true and self.tvTab[page]:getIsScrolled()==false then
						if G_checkClickEnable()==false then
				            do
				                return
				            end
				        else
				            base.setWaitTime=G_getCurDeviceMillTime()
				        end
				        PlayEffect(audioCfg.mouseClick)
						equipHandler()
					end
				end
				local scale=0.8
				local equipItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onEquip,nil,getlocal("accessory_ware"),25/scale)
				equipItem:setScale(scale)
				local equipMenu=CCMenu:createWithItem(equipItem)
				equipMenu:setTouchPriority(-(self.layerNum-1)*20-3)
				equipMenu:setAnchorPoint(ccp(0.5,0.5))
				equipMenu:setPosition(ccp(bgWidth-100,posy))
				cellBg:addChild(equipMenu,1)
				
				return cell
			elseif fn=="ccTouchBegan" then
				self.isMoved=false
				return true
			elseif fn=="ccTouchMoved" then
				self.isMoved=true
			elseif fn=="ccTouchEnded" then
			end
		end
        local hd=LuaEventHandler:createHandler(tvCallBack)
        local tv
        local pageNum=SizeOfTable(self.amList)
    	if pageNum==1 then
    		tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(backSprie:getContentSize().width,self.tvHeight+self.midH),nil)
    	else
    		tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(backSprie:getContentSize().width,self.tvHeight),nil)
    	end
        tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
        tv:setPosition(ccp(0,0))
        backSprie:addChild(tv,1)
        tv:setMaxDisToBottomOrTop(120)
        self.tvTab[page]=tv
    end
end

function planeSkillSelectDialog:refreshSkillPageLayer()
	if self==nil or self.amList==nil then
		do return end
	end
	local lastPageNum=SizeOfTable(self.amList)
	self:updateData()
	if self.amList then
    	local pageNum=SizeOfTable(self.amList)
    	if lastPageNum>pageNum then
    		if pageNum==0 then
    			self:removePage()
				self:refreshUI()
    		else
        		if self.page>pageNum then
	        		self.page=pageNum
	        		if self.amPageDialog then
	        			local function pageCallback( ... )
	        				self:removePage()
	        				self:refreshUI()
	        			end
	        			self.page=1
	        			self.amPageDialog:rightPage(nil,self.page,pageCallback)
	        		end
	        	else
	        		self:removePage()
    				self:refreshUI()
	        	end
	        end
        else
    		self:refreshUI()
    	end
    end
end

function planeSkillSelectDialog:doUserHandler()
	self:updateData()
	
	local startH=G_VisibleSizeHeight-100

	local headerH=200
	local headerPosH=startH
	self:initHeader(headerH,headerPosH)

	local bottomH=0
	local bottomPosH=20
    -- self:initBottom(bottomPosH)

    self.tvPosH=bottomPosH+bottomH
    self.midH=70
    self.tvHeight=startH-headerH-self.tvPosH-10-self.midH
end

function planeSkillSelectDialog:initHeader(headerH,headerPosH)
	local function clickHandler()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end

		if self.sid then
			local scfg,gcfg=planeVoApi:getSkillCfgById(self.sid)
			local skillVo=planeSkillVo:new(scfg,gcfg)
			skillVo:initWithData(self.sid,1,2)
			local refitSkillAttr
			if self.pos == 5 then --战机改装中新增的5号位技能槽
				local isUnlockSlot, unlockAttrValue, unlockSkillId = planeRefitVoApi:isUnlockPlaneSkillSlot(self.planeVo.pid)
		        if isUnlockSlot == true then
		        	refitSkillAttr = unlockAttrValue
		        end
			end
			planeVoApi:showInfoDialog(skillVo,self.layerNum+1,nil,nil,refitSkillAttr)
		end
	end
	local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),clickHandler)
    headerSprie:setContentSize(CCSizeMake(self.layerBgWidth,headerH))
    headerSprie:ignoreAnchorPointForPosition(false)
    headerSprie:setAnchorPoint(ccp(0.5,1))
    headerSprie:setIsSallow(false)
    headerSprie:setTouchPriority(-(self.layerNum-1)*20-4)
    headerSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,headerPosH))
    self.bgLayer:addChild(headerSprie,1)
    self.headerSprie=headerSprie

    local posy=headerSprie:getContentSize().height-30
	local lineSp1=CCSprite:createWithSpriteFrameName("lineAndPoint.png")
    lineSp1:setAnchorPoint(ccp(0,0.5))
    lineSp1:setPosition(ccp(200,posy))
    headerSprie:addChild(lineSp1,1)
    lineSp1:setRotation(180)
    local lineSp2=CCSprite:createWithSpriteFrameName("lineAndPoint.png")
    lineSp2:setAnchorPoint(ccp(0,0.5))
    lineSp2:setPosition(ccp(headerSprie:getContentSize().width-200,posy))
    headerSprie:addChild(lineSp2,1)
    local skillTypeStr=""
    if self.activeFlag==true then
    	skillTypeStr=getlocal("plane_skill_active")
    else
		skillTypeStr=getlocal("plane_skill_passive")
    end
    local skillTypeLb=GetTTFLabelWrap(skillTypeStr,25,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	skillTypeLb:setAnchorPoint(ccp(0.5,0.5))
	skillTypeLb:setPosition(ccp(headerSprie:getContentSize().width/2,posy))
	headerSprie:addChild(skillTypeLb,1)
	skillTypeLb:setColor(G_ColorYellowPro)

	posy=posy-85
	self.emptyLb=GetTTFLabelWrap(getlocal("plane_skill_equip_empty"),25,CCSizeMake(headerSprie:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.emptyLb:setPosition(ccp(headerSprie:getContentSize().width/2,posy))
	headerSprie:addChild(self.emptyLb,1)
	self.emptyLb:setColor(G_ColorRed)


	self.nameLb=GetTTFLabelWrap("",28,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	self.nameLb:setAnchorPoint(ccp(0,0.5))
	self.nameLb:setPosition(ccp(150,posy+30))
	headerSprie:addChild(self.nameLb,1)
	local equipFlag,sid=self.planeVo:isSkillSlotEquiped(self.pos,self.activeFlag)
	-- local scfg,gcfg=planeVoApi:getSkillCfgById(sid)
 --    if equipFlag==true then
 --        if gcfg and gcfg.color then
	-- 		local color=planeVoApi:getColorByQuality(gcfg.color)
	-- 		self.nameLb:setColor(color)
	-- 	end
	-- end
	self.attrLb=GetTTFLabel("",25)
	self.attrLb:setAnchorPoint(ccp(0,0.5))
	self.attrLb:setPosition(ccp(150,posy-30))
	self.attrLb:setColor(G_ColorGreen)
	headerSprie:addChild(self.attrLb,1)

	--卸下按钮
	local function onRemove()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        -- local isFull=armorMatrixVoApi:bagIsOver(1)
        -- if isFull==true then
        --     local function onConfirm()
        --         self:close()
        --         armorMatrixVoApi:showBagDialog(self.layerNum)
        --     end
        --     smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("armorMatrix_bag_full"),nil,self.layerNum+1)
        --     do return end
        -- end

        local function skillRemoveCallback( ... )
        	if self==nil or self.amList==nil then
        		do return end
        	end
        	local lastPageNum=SizeOfTable(self.amList)
        	self:updateData()
        	if self.amList and SizeOfTable(self.amList)>0 then
	        	local pageNum=SizeOfTable(self.amList)
	        	if lastPageNum<pageNum then
	        		if self.amPageDialog==nil then
		        		self:initPage()
		        	else
		        		self:addPage()
		        	end
	        	end
	        	self:refreshUI()
	        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_takeoff_success"),30)
	        end
        end
		local equipFlag,sid=self.planeVo:isSkillSlotEquiped(self.pos,self.activeFlag)
        if equipFlag==true then
        	planeVoApi:skillEquipOrRemoveRequest(2,self.planeVo,self.pos,sid,self.activeFlag,skillRemoveCallback)
		end
	end
	local scale=0.8
	self.removeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onRemove,nil,getlocal("accessory_unware"),25/scale)
	self.removeItem:setScale(scale)
	local removeMenu=CCMenu:createWithItem(self.removeItem)
	removeMenu:setTouchPriority(-(self.layerNum-1)*20-5)
	removeMenu:setAnchorPoint(ccp(0.5,0.5))
	removeMenu:setPosition(ccp(headerSprie:getContentSize().width-100,posy))
	headerSprie:addChild(removeMenu,1)

	if equipFlag==true then
		self:updateEquiped(true,sid)
	else
		self:updateEquiped(false)
	end
end

function planeSkillSelectDialog:updateEquiped(isEquiped,sid)
	if isEquiped==true then
		if self.emptyLb then
			self.emptyLb:setVisible(false)
		end
		self.sid=sid
		local nameStr,descStr=planeVoApi:getSkillInfoById(sid)
		local scfg,gcfg=planeVoApi:getSkillCfgById(sid)
		if self.nameLb and self.attrLb then
			if gcfg and gcfg.color then
				self.nameLb:setVisible(true)
				self.nameLb:setString(nameStr)
				local color=planeVoApi:getColorByQuality(gcfg.color)
				self.nameLb:setColor(color)

				self.attrLb:setVisible(true)
				local strong = gcfg.skillStrength
				if self.pos == 5 then --战机改装中新增的5号位技能槽
					local isUnlockSlot, unlockAttrValue, unlockSkillId = planeRefitVoApi:isUnlockPlaneSkillSlot(self.planeVo.pid)
			        if isUnlockSlot == true then
			        	strong = math.floor(strong * unlockAttrValue)
			        end
				end
				self.attrLb:setString(getlocal("skill_power",{strong}))
			end
		end
		if self.removeItem then
			self.removeItem:setVisible(true)
			self.removeItem:setEnabled(true)
		end
		if self.skillIcon then
			self.skillIcon:removeFromParentAndCleanup(true)
			self.skillIcon=nil
		end
		if self.headerSprie then
		    self.skillIcon=planeVoApi:getSkillIcon(sid,120)
		    self.skillIcon:setTouchPriority(-(self.layerNum-1)*20-1)
			self.skillIcon:setPosition(ccp(75,self.headerSprie:getContentSize().height-115))
			self.headerSprie:addChild(self.skillIcon,1)
		end
	else
		self.sid=nil
		if self.emptyLb then
			self.emptyLb:setVisible(true)
		end
		if self.nameLb then
			self.nameLb:setVisible(false)
		end
		if self.attrLb then
			self.attrLb:setVisible(false)
		end
		if self.removeItem then
			self.removeItem:setVisible(false)
			self.removeItem:setEnabled(false)
		end
		if self.skillIcon then
			self.skillIcon:removeFromParentAndCleanup(true)
			self.skillIcon=nil
		end
	end
end

-- 屏蔽层
function planeSkillSelectDialog:resetTv(tvHeight)
	local function callBack(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.layerBgWidth,tvHeight),nil)
    self.tv:setPosition(ccp(25,self.tvPosH))
end

function planeSkillSelectDialog:refreshPageDetail(index)
	local page=index
	if page and page>0 and self.tvTab and self.tvTab[page] then
		local tv=tolua.cast(self.tvTab[page],"LuaCCTableView")
		if tv then
			local pageNum=SizeOfTable(self.amList)
			if pageNum==1 then
				tv:setViewSize(CCSizeMake(self.layerBgWidth,self.tvHeight+self.midH))
			else
				tv:setViewSize(CCSizeMake(self.layerBgWidth,self.tvHeight))
			end
			local recordPoint=tv:getRecordPoint()
			tv:reloadData()
			if self.amList[page] then
				local cellNum=SizeOfTable(self.amList[page])
				if cellNum>5 then
					tv:recoverToRecordPoint(recordPoint)
				end
			end
		end
	end
	self:refreshPageFlag(page)
end

function planeSkillSelectDialog:refreshUI()
	-- self:updateData()
	local equipFlag,sid=self.planeVo:isSkillSlotEquiped(self.pos,self.activeFlag)
	if equipFlag==true then
		self:updateEquiped(true,sid)
	else
		self:updateEquiped(false)
	end

	self:refreshPageDetail(self.page)
	self:refreshMid()
	self:refreshGetSkill()
end

function planeSkillSelectDialog:refreshMid()
	if self.amList and self.amPageDialog then
		local pageNum=SizeOfTable(self.amList) or 0
		if pageNum<=1 then
			self.amPageDialog:setEnabled(false)
			self:resetTv(self.tvHeight+self.midH)
		else
			self.amPageDialog:setEnabled(true)
			self:resetTv(self.tvHeight)
		end
	end
	self:refreshPageFlag()
end
function planeSkillSelectDialog:refreshPageFlag(pIndex)
	local page
	if pIndex then
		page=pIndex
	else
		page=self.page
	end
	if self.curPageFlag then
        self.curPageFlag:setVisible(false)
    end
	local pageNum=SizeOfTable(self.amList) or 0
	if pageNum<=1 then
		if self.pageFlagList then
	        for k,v in pairs(self.pageFlagList) do
	        	local pageFlag=v
	        	if pageFlag then
		        	pageFlag:setVisible(false)
		        end
	        end
	    end
	else
		local pxTab=G_getIconSequencePosx(2,50,self.bgLayer:getContentSize().width/2,pageNum)
		if self.pageFlagList then
	        for k,v in pairs(self.pageFlagList) do
	        	local pageFlag=v
	        	if pageFlag then
	    			if pxTab and pxTab[k] then
			        	pageFlag:setPosition(ccp(pxTab[k],self.bgLayer:getContentSize().height-340))
			        	pageFlag:setVisible(true)
			        else
			        	pox=0
			        	pageFlag:setVisible(false)
			        end
	        	end
	        	if k==page then
	        		if self.curPageFlag then
				        self.curPageFlag:setVisible(true)
				        self.curPageFlag:setPosition(ccp(pageFlag:getPosition()))
				    end
	        	end
	        end
	    end
	end
end
function planeSkillSelectDialog:refreshGetSkill()
	local node=self.bgLayer:getChildByTag(1001)
	if self.amList and SizeOfTable(self.amList)>0 then
		if node and node.removeFromParentAndCleanup then
			node:removeFromParentAndCleanup(true)
			node=nil
		end
	else
		if node then
		else
			self:addGetSkill()
		end
	end
	
end
function planeSkillSelectDialog:addGetSkill()
    local uselessNode=CCNode:create()
    uselessNode:setContentSize(CCSizeMake(G_VisibleSizeWidth,300))
    self.bgLayer:addChild(uselessNode,2)
    uselessNode:setAnchorPoint(ccp(0.5,0.5))
    uselessNode:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    uselessNode:setTag(1001)

    local uselessLb=GetTTFLabelWrap(getlocal("plane_bag_noSkill"),25,CCSizeMake(550,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    uselessLb:setAnchorPoint(ccp(0.5,0))
    uselessLb:setPosition(G_VisibleSizeWidth/2,uselessNode:getContentSize().height/2+10)
    uselessNode:addChild(uselessLb)

    local function goObtainFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        self:close()
        planeVoApi:showGetDialog(self.layerNum+1)
    end
    local scale=0.8
    local obtainItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",goObtainFunc,nil,getlocal("accessory_get"),25/scale)
    obtainItem:setScale(scale)
    obtainItem:setAnchorPoint(ccp(0.5,1))
    local obtainMenu = CCMenu:createWithItem(obtainItem)
    uselessNode:addChild(obtainMenu)
    obtainMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    obtainMenu:setBSwallowsTouches(true)
    obtainMenu:setPosition(G_VisibleSizeWidth/2,uselessNode:getContentSize().height/2-10)
end

function planeSkillSelectDialog:tick()

end

function planeSkillSelectDialog:dispose()
	eventDispatcher:removeEventListener("plane.skillpage.refresh",self.refreshListener)
	self.emptyLb=nil
	self.nameLb=nil
	self.attrLb=nil
	self.valueLb=nil
	self.skillIcon=nil
	self.removeItem=nil
	self.headerSprie=nil
	self.mid=nil
	self.amList=nil
	self.amPageDialog=nil
	spriteController:removePlist("public/vipFinal.plist")
end
