armorMatrixSelectDialog=commonDialog:new()

function armorMatrixSelectDialog:new(tankPos,index)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.tankPos=tankPos
    nc.index=index
    nc.emptyLb=nil
	nc.nameLb=nil
	nc.attrLb=nil
	nc.valueLb=nil
	nc.equipedIcon=nil
	nc.removeItem=nil
	nc.headerSprie=nil
	nc.id=nil
	nc.mid=nil
	nc.amList=nil
	nc.everyCellNum=25

	-- nc.vipPageDialog=nil
    nc.amLayer=nil
    nc.page=1
    nc.curPageFlag=nil
    nc.pageFlagList={}
    nc.tvTab={}
    -- nc.backSpTab={}
    nc.layerBgWidth=G_VisibleSizeWidth-40
    -- nc.lastPageNum=0
    nc.btnScale1=140/205
    nc.btnScale2=140/205

	spriteController:addPlist("public/vipFinal.plist")
    return nc
end

function armorMatrixSelectDialog:updateData()
	self.mid,self.id=armorMatrixVoApi:getEquipedData(self.tankPos,self.index)
	-- print("self.tankPos,self.index,self.mid,self.id",self.tankPos,self.index,self.mid,self.id)
	self.amList=armorMatrixVoApi:canEquipArmor(self.tankPos,self.index,self.everyCellNum)
	-- if self.amList then
	--     self.lastPageNum=SizeOfTable(self.amList)
	-- else
	-- 	self.lastPageNum=0
	-- end
end

--设置对话框里的tableView
function armorMatrixSelectDialog:initTableView()
	-- self.panelLineBg:setContentSize(CCSizeMake(600,self.bgLayer:getContentSize().height-200))
 --    self.panelLineBg:setAnchorPoint(ccp(0,0))
 --    self.panelLineBg:setPosition(ccp(20,20))
 --    self.bgLayer:reorderChild(self.panelLineBg,2)
 	self.panelLineBg:setVisible(false)

	local function onLoadIcon(fn,icon)
	    if self and self.bgLayer and icon then
			self.bgLayer:addChild(icon)
			icon:setScaleX(self.bgLayer:getContentSize().width/icon:getContentSize().width)
			icon:setScaleY((self.bgLayer:getContentSize().height-80)/icon:getContentSize().height)
			icon:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-40)
	    end
	end
	local url=G_downloadUrl("active/buyreward/acBuyrewardjpg4.jpg")
	-- print("url~~~~",url)
	local webImage = LuaCCWebImage:createWithURL(url,onLoadIcon)

	self.everyCellNum=armorMatrixVoApi:perPageShowNum()
	self:updateData()

    local function callBack(...)
		-- return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.layerBgWidth,self.tvHeight),nil)
    -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(25,self.tvPosH))
    -- self.bgLayer:addChild(self.tv,1)
    -- self.tv:setMaxDisToBottomOrTop(120)
  

    if self.amList and SizeOfTable(self.amList)>0 then
	    self:initPage()
	else
		self:refreshGetMatrix()
    end
end

function armorMatrixSelectDialog:initPage()
	-- self.page=1
    local space=50
    self.list={}
    self.dlist={}
    self.pageFlagList={}
    local poy=self.bgLayer:getContentSize().height-340
    local pfScale=1
    local pageNum=SizeOfTable(self.amList)
    local armorCfg=armorMatrixVoApi:getArmorCfg()
    local maxPage=math.ceil(armorCfg.storeHouseMaxNum/self.everyCellNum)
    for i=1,pageNum do
        local backSprie=self:initPageBg(i)

        self.list[i]=backSprie
        -- self.dlist[i]=backSprie
    end

    self.curPageFlag=CCSprite:createWithSpriteFrameName("selectedPoint.png")
    self.curPageFlag:setScale(pfScale)
    self.bgLayer:addChild(self.curPageFlag,3)
    self.curPageFlag:setVisible(false)
    local pxTab=G_getIconSequencePosx(2,space,self.bgLayer:getContentSize().width/2,pageNum)
    for i=1,maxPage do
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
        -- if self.amList and SizeOfTable(self.amList)>1 then
        -- else
        -- 	do return false end
        -- end
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
            -- if self.tvTab[self.page] and isTouch==true then
            --     local tv=self.tvTab[self.page]
            --     if tv and tv.getScrollEnable and tv.getIsScrolled then
            --         canMove=false
            --         if tv:getScrollEnable()==true and tv:getIsScrolled()==false then
            --             canMove=true
            --         end
            --     end
            -- end
        end
        return canMove
    end
    self.amPageDialog=pageDialog:new()
    self.amPageDialog:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(20, 20, 10, 10),self.bgLayer,ccp(0,0),self.layerNum,self.page,self.list,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos,movedCallback,-(self.layerNum-1)*20-4,nil,"vipArrow.png",true,nil,150)

    self:refreshMid()
    -- self.curTankTab=self.dlist[1]
    -- self.curTankTab.isShow=true

    -- local maskSpHeight=self.bgLayer:getContentSize().height-405
    -- for k=1,3 do
    --     local leftMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
    --     leftMaskSp:setAnchorPoint(ccp(0,0))
    --     -- leftMaskSp:setPosition(0,pos.y+25)
    --     leftMaskSp:setPosition(0,100)
    --     leftMaskSp:setScaleY(maskSpHeight/leftMaskSp:getContentSize().height)
    --     self.bgLayer:addChild(leftMaskSp,6)

    --     local rightMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
    --     -- rightMaskSp:setRotation(180)
    --     rightMaskSp:setFlipX(true)
    --     rightMaskSp:setAnchorPoint(ccp(0,0))
    --     -- rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,pos.y+25)
    --     rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,115)
    --     rightMaskSp:setScaleY(maskSpHeight/rightMaskSp:getContentSize().height)
    --     self.bgLayer:addChild(rightMaskSp,6)
    -- end
end

function armorMatrixSelectDialog:addPage()
    if self.list then
    	local pageNum=1 
	    if SizeOfTable(self.list)>0 then
	    	pageNum=SizeOfTable(self.list)+1
	    end
	    local backSprie=self:initPageBg(pageNum)
	    self.list[pageNum]=backSprie
	    -- self.backSpTab[pageNum]=backSprie
	    -- self:initPageDetail(pageNum)
	    -- self:refreshUI()
	end
end
function armorMatrixSelectDialog:removePage()
	-- if self.tvTab then
	-- 	local pageNum=1 
	--     if SizeOfTable(self.tvTab)>0 then
	--     	pageNum=SizeOfTable(self.tvTab)
	--     end
	--     print("tvTab~~~~~pageNum",pageNum)
	--     local tv=tolua.cast(self.tvTab[pageNum],"LuaCCTableView")
	-- 	table.remove(self.tvTab,pageNum)
	-- 	if tv then
	-- 		tv:removeFromParentAndCleanup(true)
	-- 		tv=nil
	-- 	end
	-- end
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
	    	-- table.remove(self.backSpTab,pageNum)
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

function armorMatrixSelectDialog:pageDispose()
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

function armorMatrixSelectDialog:initPageBg(indx)
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
    -- self.backSpTab[index+1]=backSprie
    return backSprie
end
function armorMatrixSelectDialog:initPageDetail(index)
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
				local tmpSize=CCSizeMake(backSprie:getContentSize().width,120)
			    return  tmpSize
			elseif fn=="tableCellAtIndex" then
				local cell=CCTableViewCell:new()
				cell:autorelease()

				if self.amList and page and self.amList[page] then
				else
					do return cell end
				end

			    local capInSet = CCRect(20, 20, 10, 10)
			    local function cellClick(hd,fn,idx)
			    end
			    local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
				cellBg:setContentSize(CCSizeMake(backSprie:getContentSize().width,118))
			    cellBg:ignoreAnchorPointForPosition(false)
			    cellBg:setAnchorPoint(ccp(0,0))
			    cellBg:setIsSallow(false)
			    cellBg:setTouchPriority(-(self.layerNum-1)*20-2)
				cellBg:setPosition(ccp(0,2))
			    cell:addChild(cellBg,1)

			    local amItem=self.amList[page][idx+1]
			    local id=amItem.id
				local level=amItem.lv
				local mid=amItem.mid
				local cfg=armorMatrixVoApi:getCfgByMid(mid)
				local attrStr,value=armorMatrixVoApi:getAttrAndValue(mid,level)
				-- print("page,id,level,mid,cfg.quality",page,id,level,mid,cfg.quality)

			    local bgWidth,bgHeight=cellBg:getContentSize().width,cellBg:getContentSize().height
				-- local equipedIcon=CCSprite:createWithSpriteFrameName("pro_ship_attack.png")
				local function clickHandler( ... )
			    end
				local equipedIcon=armorMatrixVoApi:getArmorMatrixIcon(mid,90,100,clickHandler,level)
				equipedIcon:setPosition(ccp(75,bgHeight/2))
				cell:addChild(equipedIcon,1)
				armorMatrixVoApi:addLightEffect(equipedIcon, mid)

				local posy=bgHeight/2
				local nameLb=GetTTFLabelWrap(getlocal(cfg.name),24,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
				nameLb:setAnchorPoint(ccp(0,0.5))
				nameLb:setPosition(ccp(145,posy+20))
				cellBg:addChild(nameLb,1)
				local color=armorMatrixVoApi:getColorByQuality(cfg.quality)
				nameLb:setColor(color)

				local attrLb=GetTTFLabel(attrStr,20)
				attrLb:setAnchorPoint(ccp(0,0.5))
				attrLb:setPosition(ccp(145,posy-20))
				cellBg:addChild(attrLb,1)
				local valueLb=GetTTFLabel("+"..value.."%",20)
				valueLb:setAnchorPoint(ccp(0,0.5))
				valueLb:setPosition(ccp(attrLb:getPositionX()+attrLb:getContentSize().width+10,posy-20))
				cellBg:addChild(valueLb,1)
				valueLb:setColor(G_ColorGreen)

				--配备按钮
				local function onEquip()
					if G_checkClickEnable()==false then
			            do
			                return
			            end
			        else
			            base.setWaitTime=G_getCurDeviceMillTime()
			        end
			        PlayEffect(audioCfg.mouseClick)

			        local equipMid=armorMatrixVoApi:getEquipedData(self.tankPos,self.index)
				    if equipMid then
				        local equipCfg=armorMatrixVoApi:getCfgByMid(equipMid)
				        if equipCfg and equipCfg.quality==5 then --橙色矩阵不能更换
				        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armorMatrix_unable_change"),30)
				        	do return end
				        end
				    end

				    local function onArmorUsedAndRemove()
				    	local function armorUsedCallback( ... )
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
				        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alien_tech_use_success"),30)
				        end
				        local line,id,pos=self.tankPos,amItem.id
				        armorMatrixVoApi:armorUsedAndRemove(line,id,pos,armorUsedCallback)
				    end

				    if cfg.quality==5 then --装备橙色矩阵的二次确认提示
				    	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onArmorUsedAndRemove,getlocal("dialog_title_prompt"),getlocal("armorMatrix_equipOrange_tips"),nil,self.layerNum+1)
				    else
				    	onArmorUsedAndRemove()
				    end
				end
				local equipItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onEquip,nil,getlocal("armorMatrix_equipped"),24/self.btnScale2,101)
				equipItem:setScale(self.btnScale2)
				local btnLb = equipItem:getChildByTag(101)
				if btnLb then
					btnLb = tolua.cast(btnLb,"CCLabelTTF")
					btnLb:setFontName("Helvetica-bold")
				end
				local equipMenu=CCMenu:createWithItem(equipItem)
				equipMenu:setTouchPriority(-(self.layerNum-1)*20-2)
				equipMenu:setAnchorPoint(ccp(0.5,0.5))
				equipMenu:setPosition(ccp(bgWidth-100,posy))
				cell:addChild(equipMenu,1)
				
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
        -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
        tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        tv:setPosition(ccp(0,0))
        backSprie:addChild(tv,1)
        tv:setMaxDisToBottomOrTop(120)
        self.tvTab[page]=tv
    end
end

function armorMatrixSelectDialog:doUserHandler()
	self.everyCellNum=armorMatrixVoApi:perPageShowNum()
	self:updateData()
	
	local startH=G_VisibleSizeHeight-100

	local headerH=160
	local headerPosH=startH
	self:initHeader(headerH,headerPosH)

	local bottomH=0
	local bottomPosH=20
    -- self:initBottom(bottomPosH)

    self.tvPosH=bottomPosH+bottomH
    self.midH=70
    self.tvHeight=startH-headerH-self.tvPosH-10-self.midH
end

function armorMatrixSelectDialog:initHeader(headerH,headerPosH)
	local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function (...)end)
    headerSprie:setContentSize(CCSizeMake(self.layerBgWidth,headerH))
    headerSprie:ignoreAnchorPointForPosition(false)
    headerSprie:setAnchorPoint(ccp(0.5,1))
    headerSprie:setIsSallow(false)
    headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
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
    local posLb=GetTTFLabelWrap(getlocal("armorMatrix_fight_pos",{self.index}),24,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	posLb:setAnchorPoint(ccp(0.5,0.5))
	posLb:setPosition(ccp(headerSprie:getContentSize().width/2,posy))
	headerSprie:addChild(posLb,1)
	posLb:setColor(G_ColorYellowPro)

	posy=posy-60
	self.emptyLb=GetTTFLabelWrap(getlocal("armorMatrix_equip_empty"),22,CCSizeMake(headerSprie:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.emptyLb:setPosition(ccp(headerSprie:getContentSize().width/2,posy))
	headerSprie:addChild(self.emptyLb,1)
	self.emptyLb:setColor(G_ColorRed)


	self.nameLb=GetTTFLabelWrap("",24,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	self.nameLb:setAnchorPoint(ccp(0,0.5))
	self.nameLb:setPosition(ccp(150,posy+20))
	headerSprie:addChild(self.nameLb,1)
	local mid=armorMatrixVoApi:getEquipedData(self.tankPos,self.index)
    if mid then
        local cfg=armorMatrixVoApi:getCfgByMid(mid)
        if cfg and cfg.quality then
			local color=armorMatrixVoApi:getColorByQuality(cfg.quality)
			self.nameLb:setColor(color)
		end
	end
	self.attrLb=GetTTFLabel("",20)
	self.attrLb:setAnchorPoint(ccp(0,0.5))
	self.attrLb:setPosition(ccp(150,posy-20))
	headerSprie:addChild(self.attrLb,1)
	self.valueLb=GetTTFLabel("",20)
	self.valueLb:setAnchorPoint(ccp(0,0.5))
	self.valueLb:setPosition(ccp(self.attrLb:getPositionX()+self.attrLb:getContentSize().width+10,posy+20))
	headerSprie:addChild(self.valueLb,1)
	self.valueLb:setColor(G_ColorGreen)

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

        local mid=armorMatrixVoApi:getEquipedData(self.tankPos,self.index)
	    if mid then
	        local cfg=armorMatrixVoApi:getCfgByMid(mid)
	        if cfg and cfg.quality==5 then --橙色矩阵不能卸下
	        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armorMatrix_unable_unware"),30)
	        	do return end
	        end
	    end

        local isFull=armorMatrixVoApi:bagIsOver(1)
        if isFull==true then
            local function onConfirm()
                self:close()
                armorMatrixVoApi:showBagDialog(self.layerNum)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("armorMatrix_bag_full"),nil,self.layerNum+1)
            do return end
        end

        local function armorRemoveCallback( ... )
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
        local mid=armorMatrixVoApi:getEquipedData(self.tankPos,self.index)
        if mid then
	        local cfg=armorMatrixVoApi:getCfgByMid(mid)
	        if cfg and cfg.part then
		        local line,id,pos=self.tankPos,nil,cfg.part
		        armorMatrixVoApi:armorUsedAndRemove(line,id,pos,armorRemoveCallback)
		    end
		end
	end
	local strSize2 = 35
    if G_getCurChoseLanguage() =="de" then
        strSize2 = 28
    end
	self.removeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",onRemove,nil,getlocal("accessory_unware"),strSize2,101)
	self.removeItem:setScale(self.btnScale1)
	local btnLb = self.removeItem:getChildByTag(101)
	if btnLb then
		btnLb = tolua.cast(btnLb,"CCLabelTTF")
		btnLb:setFontName("Helvetica-bold")
	end
	local removeMenu=CCMenu:createWithItem(self.removeItem)
	removeMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	removeMenu:setAnchorPoint(ccp(0.5,0.5))
	removeMenu:setPosition(ccp(headerSprie:getContentSize().width-100,posy))
	headerSprie:addChild(removeMenu,1)

	local mid,id,lv=armorMatrixVoApi:getEquipedData(self.tankPos,self.index)
	if id and id~=0 then
		self:updateEquiped(true)
	else
		self:updateEquiped(false)
	end
end

function armorMatrixSelectDialog:updateEquiped(isEquiped)
	if isEquiped==true then
		local mid,id,lv=armorMatrixVoApi:getEquipedData(self.tankPos,self.index)
		local cfg=armorMatrixVoApi:getCfgByMid(mid)
		if self.emptyLb then
			self.emptyLb:setVisible(false)
		end
		if self.nameLb then
			if cfg then
				self.nameLb:setVisible(true)
				self.nameLb:setString(getlocal(cfg.name))
				local color=armorMatrixVoApi:getColorByQuality(cfg.quality)
				self.nameLb:setColor(color)
			end
		end
		local attrStr,value=armorMatrixVoApi:getAttrAndValue(mid,lv)
		if self.attrLb then
			self.attrLb:setVisible(true)
			self.attrLb:setString(attrStr)
		end
		if self.valueLb then
			self.valueLb:setVisible(true)
			self.valueLb:setString("+"..value.."%")
			if self.attrLb then
				self.valueLb:setPosition(ccp(self.attrLb:getPositionX()+self.attrLb:getContentSize().width+10,self.attrLb:getPositionY()))
			end
		end
		if self.removeItem then
			self.removeItem:setVisible(true)
			self.removeItem:setEnabled(true)
		end
		if self.equipedIcon then
			self.equipedIcon:removeFromParentAndCleanup(true)
			self.equipedIcon=nil
		end
		if self.headerSprie then
			local function clickHandler( ... )
		    end
		    self.equipedIcon=armorMatrixVoApi:getArmorMatrixIcon(mid,90,100,clickHandler,lv)
			self.equipedIcon:setPosition(ccp(75,self.headerSprie:getContentSize().height-95))
			self.headerSprie:addChild(self.equipedIcon,1)
			armorMatrixVoApi:addLightEffect(self.equipedIcon, mid)
		end
	else
		if self.emptyLb then
			self.emptyLb:setVisible(true)
		end
		if self.nameLb then
			self.nameLb:setVisible(false)
		end
		if self.attrLb then
			self.attrLb:setVisible(false)
		end
		if self.valueLb then
			self.valueLb:setVisible(false)
		end
		if self.removeItem then
			self.removeItem:setVisible(false)
			self.removeItem:setEnabled(false)
		end
		if self.equipedIcon then
			self.equipedIcon:removeFromParentAndCleanup(true)
			self.equipedIcon=nil
		end
	end
end

-- 屏蔽层
function armorMatrixSelectDialog:resetTv(tvHeight)
	local function callBack(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.layerBgWidth,tvHeight),nil)
    self.tv:setPosition(ccp(25,self.tvPosH))
end

function armorMatrixSelectDialog:refreshPageDetail(index)
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

			-- self.cellNum=self.bagNum-(self.pageId-1)*self.everyCellNum
			-- if self.cellNum>self.everyCellNum then
			-- 	self.cellNum=self.everyCellNum
			-- end

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

function armorMatrixSelectDialog:refreshUI()
	-- self:updateData()
	local mid,id,lv=armorMatrixVoApi:getEquipedData(self.tankPos,self.index)
	if id and id~=0 then
		self:updateEquiped(true)
	else
		self:updateEquiped(false)
	end

	self:refreshPageDetail(self.page)
	self:refreshMid()
	self:refreshGetMatrix()
end

function armorMatrixSelectDialog:refreshMid()
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
function armorMatrixSelectDialog:refreshPageFlag(pIndex)
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
function armorMatrixSelectDialog:refreshGetMatrix()
	local node=self.bgLayer:getChildByTag(1001)
	if self.amList and SizeOfTable(self.amList)>0 then
		if node and node.removeFromParentAndCleanup then
			node:removeFromParentAndCleanup(true)
			node=nil
		end
	else
		if node then
		else
			self:addGetMatrix()
		end
	end
	
end
function armorMatrixSelectDialog:addGetMatrix()
    -- self.bgLayer
    local uselessNode=CCNode:create()
    uselessNode:setContentSize(CCSizeMake(G_VisibleSizeWidth,300))
    self.bgLayer:addChild(uselessNode,2)
    uselessNode:setAnchorPoint(ccp(0.5,0.5))
    uselessNode:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    uselessNode:setTag(1001)

    local uselessLb=GetTTFLabelWrap(getlocal("armorMatrix_bag_noMatrix"),25,CCSizeMake(550,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
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
        armorMatrixVoApi:showRecruitDialog(self.layerNum)
    end
    local obtainItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",goObtainFunc,nil,getlocal("accessory_get"),24/self.btnScale1)
    obtainItem:setScale(self.btnScale1)
    obtainItem:setAnchorPoint(ccp(0.5,1))
    local obtainMenu = CCMenu:createWithItem(obtainItem)
    uselessNode:addChild(obtainMenu)
    obtainMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    obtainMenu:setBSwallowsTouches(true)
    obtainMenu:setPosition(G_VisibleSizeWidth/2,uselessNode:getContentSize().height/2-10)
end

function armorMatrixSelectDialog:tick()

end

function armorMatrixSelectDialog:dispose()
	self.emptyLb=nil
	self.nameLb=nil
	self.attrLb=nil
	self.valueLb=nil
	self.equipedIcon=nil
	self.removeItem=nil
	self.headerSprie=nil
	self.mid=nil
	self.amList=nil
	self.amPageDialog=nil
	-- self.backSpTab=nil
	-- self.lastPageNum=nil
	spriteController:removePlist("public/vipFinal.plist")
end




