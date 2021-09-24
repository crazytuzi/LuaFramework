acLmqrjTabTwo={}

function acLmqrjTabTwo:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum

    return nc
end

function acLmqrjTabTwo:init()
	self.bgLayer=CCLayer:create()
	self:initUI()
	self.refreshUIListener=function()
		self:refreshUI()
	end
	eventDispatcher:addEventListener("acLmqrjTabTwo.refreshUI",self.refreshUIListener)
	return self.bgLayer
end

function acLmqrjTabTwo:initUI()
	self.tvData=acLmqrjVoApi:getTaskReward()
	local listViewBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
    listViewBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSizeHeight-165))
    listViewBg:setAnchorPoint(ccp(0.5,1))
    listViewBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-158)
    self.bgLayer:addChild(listViewBg)
    local function callBack(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,listViewBg:getContentSize(),nil)
	-- self.tv:setAnchorPoint(ccp(0,0))
	-- self.tv:setPosition(ccp(0,0))
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
	self.tv:setMaxDisToBottomOrTop(100)
	listViewBg:addChild(self.tv)
end

function acLmqrjTabTwo:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return SizeOfTable(self.tvData)
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(G_VisibleSizeWidth-30,150)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellW,cellH=G_VisibleSizeWidth-30,150

		local _data=self.tvData[idx+1]
		if _data==nil then
			do return cell end
		end

		local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,16,1,1),function()end)
		titleBg:setContentSize(CCSizeMake(cellW/2+55,titleBg:getContentSize().height))
		titleBg:setAnchorPoint(ccp(0,1))
		titleBg:setPosition(3,cellH-10)
		cell:addChild(titleBg)
		local _curNum=acLmqrjVoApi:getTaskNum(_data.type)
		local _key=_data.type
		_key=(_key=="gb") and "gba" or _key
		local titleLb=GetTTFLabel(getlocal("activity_chunjiepansheng_".._key.."_title",{_curNum,_data.needNum}),22)
		titleLb:setAnchorPoint(ccp(0,0.5))
		titleLb:setPosition(15,titleBg:getContentSize().height/2)
		titleLb:setColor(G_ColorYellowPro)
		titleBg:addChild(titleLb)

		local rewardTb=FormatItem(_data.reward,nil,true)
		if rewardTb then
			local itemPosY=(cellH-(titleBg:getContentSize().height+10))/2
			if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
				itemPosY=itemPosY-10
			end
			for k, v in pairs(rewardTb) do
				local icon, iconScale = G_getItemIcon(v,85,false,self.layerNum,function()
					G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
				end)
	            icon:setTouchPriority(-(self.layerNum-1)*20-1)
	            icon:setPosition(50+icon:getContentSize().width*iconScale/2+(k-1)*(30+icon:getContentSize().width*iconScale),itemPosY)
	            local numLb=GetTTFLabel("x"..FormatNumber(v.num),20)
	            numLb:setAnchorPoint(ccp(1,0))
	            if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
	            	numLb:setPosition(ccp(icon:getContentSize().width,5))
	            else
	            	numLb:setPosition(ccp(icon:getContentSize().width-10,5))
	            end
	            icon:addChild(numLb,1)
	            numLb:setScale(1/iconScale)
	            cell:addChild(icon)
	    	end
    	end
    	if _curNum<_data.needNum then
    		local stateLb=GetTTFLabel(getlocal("noReached"),24)
    		stateLb:setAnchorPoint(ccp(1,0.5))
    		stateLb:setPosition(cellW-65,(cellH-(titleBg:getContentSize().height+10))/2)
    		cell:addChild(stateLb)
    	else
    		local btnStr,btnEnabled
    		if _data.state==1 then
    			btnStr=getlocal("daily_scene_get")
    			btnEnabled=true
    		elseif _data.state==2 then
    			btnStr=getlocal("activity_hadReward")
    			btnEnabled=false
    		end
    		if btnStr then
				local function awardHandler(tag,obj)
					if G_checkClickEnable()==false then
			            do return end
			        else
			            base.setWaitTime=G_getCurDeviceMillTime()
			        end
			        PlayEffect(audioCfg.mouseClick)
			        socketHelper:activeLmqrjTaskReward({_data.id},function(fn,data)
			        	local ret,sData=base:checkServerData(data)
			            if ret==true then
			            	if sData and sData.data and sData.data.lmqrj then
			            		acLmqrjVoApi:updateData(sData.data.lmqrj)
			            	end
			            	for k,v in pairs(rewardTb) do
		                        G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
		                    end
		                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
		                    G_showRewardTip(rewardTb,true)
			            	self:refreshUI()
			            	eventDispatcher:dispatchEvent("acLmqrjTabOne.refreshUI",{})
			            end
			        end)
				end
				local btnScale=0.8
				local awardBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",awardHandler,11,btnStr,24/btnScale)
			    awardBtn:setScale(btnScale)
			    awardBtn:setAnchorPoint(ccp(1,0.5))
			    local menu=CCMenu:createWithItem(awardBtn)
			    menu:setTouchPriority(-(self.layerNum-1)*20-1)
			    menu:setPosition(ccp(cellW-10,(cellH-(titleBg:getContentSize().height+10))/2))
			    awardBtn:setEnabled(btnEnabled)
			    cell:addChild(menu)
			end
    	end

    	local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
        lineSp:setContentSize(CCSizeMake((cellW-10),4))
        lineSp:ignoreAnchorPointForPosition(false)
        lineSp:setAnchorPoint(ccp(0.5,0))
        lineSp:setPosition(cellW/2,0)
        cell:addChild(lineSp)

		return cell
	elseif fn=="ccTouchBegan" then
		-- self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		-- self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function acLmqrjTabTwo:refreshUI()
	if self then
		self.tvData=acLmqrjVoApi:getTaskReward()
    	if self.tv then
    		self.tv:reloadData()
    	end
	end
end

function acLmqrjTabTwo:dispose()
	eventDispatcher:removeEventListener("acLmqrjTabTwo.refreshUI",self.refreshUIListener)
	self.tvData = nil
	self.tv = nil
	self = nil
end