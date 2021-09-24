planeSkillDetailDialog=smallDialog:new()

function planeSkillDetailDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.layerNum = nil
	nc.bgSize = nil
	return nc
end

function planeSkillDetailDialog:showSkillDetail(layerNum,sid,titleStr)
	local sd = planeSkillDetailDialog:new()
	sd:initSkillDetail(layerNum,sid,titleStr)
	return sd
end

function planeSkillDetailDialog:initSkillDetail(layerNum,sid,titleStr)
	self.layerNum=layerNum
	self.isUseAmi=true

	local skillCfg=planeVoApi:getNewSkillCfg()
	local skillData=skillCfg.skill[sid]
	local skillType=skillData.type -- 0:被动技能，1:主动技能

	self.dialogLayer=CCLayer:create()

    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function()end)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    -- touchDialogBg:setOpacity(50)
    touchDialogBg:setAnchorPoint(ccp(0.5,0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.dialogLayer:addChild(touchDialogBg)

    local function closeDialog()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    self.bgSize=CCSizeMake(580,730)
    local dialogBg,titleBg,titleLb,closeBtnItem,closeBtn=G_getNewDialogBg(self.bgSize,titleStr,32,nil,self.layerNum,true,closeDialog,nil)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.dialogLayer:addChild(self.bgLayer,2)

    local fontSize=22
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
    tvBg:setContentSize(CCSizeMake(self.bgSize.width-40,self.bgSize.height-120))
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(self.bgSize.width/2,self.bgSize.height-90)
    self.bgLayer:addChild(tvBg)

    local tvTitleBg=LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png",CCRect(4,4,1,1),function()end)
    tvTitleBg:setContentSize(CCSizeMake(tvBg:getContentSize().width,45))
    tvTitleBg:setAnchorPoint(ccp(0.5,1))
    tvTitleBg:setPosition(tvBg:getContentSize().width/2,tvBg:getContentSize().height)
    tvBg:addChild(tvTitleBg)

    local tvSize=CCSizeMake(tvBg:getContentSize().width,tvTitleBg:getPositionY()-tvTitleBg:getContentSize().height-5)
    local cellW,cellH=tvSize.width,45

    if skillType==0 then
    	local label1=GetTTFLabel(getlocal("RankScene_level"),fontSize)
    	local label2=GetTTFLabel(getlocal("total_effect"),fontSize)
    	label1:setPosition(tvTitleBg:getContentSize().width*0.2,tvTitleBg:getContentSize().height*0.5)
    	label2:setPosition(tvTitleBg:getContentSize().width*0.7,tvTitleBg:getContentSize().height*0.5)
    	tvTitleBg:addChild(label1)
    	tvTitleBg:addChild(label2)
    elseif skillType==1 then
    	local str3,str4="",""
    	local data=skillData.lvinfo[1]
    	if data then
    		if data.addBox then
    			str3=getlocal("tanke")..getlocal("help3_t3_t2")
    			str4=getlocal("amountStr")
    			for k, v in pairs(skillData.lvinfo) do
    				local _lbH=0
	    			for k, v in pairs(data.addBox.pool[3]) do
	    				local tid=RemoveFirstChar(Split(v[1],"_")[2])
	    				local lb=GetTTFLabel(getlocal(tankCfg[tonumber(tid)].name),fontSize)
	    				_lbH=_lbH+lb:getContentSize().height
	    			end
	    			if _lbH>cellH then
	    				cellH=_lbH+10
	    			end
    			end
    		elseif data.hitFly then
    			str3=getlocal("gloryDegreeStr")
    			str4=getlocal("plunder_num")
    		elseif data.addTroops then
    			str3=getlocal("time_of_duration")
    			str4=getlocal("lifting_capacity")
    		elseif data.killProtect then
    			str3=getlocal("enemyLost_text")
    			str4=getlocal("myLost_text")
    		end
    	end
    	local label1=GetTTFLabel(getlocal("RankScene_level"),fontSize)
    	local label2=GetTTFLabel(getlocal("skill_cd"),fontSize)
    	local label3=GetTTFLabel(str3,fontSize)
    	local label4=GetTTFLabel(str4,fontSize)
    	label1:setPosition(tvTitleBg:getContentSize().width*0.1,tvTitleBg:getContentSize().height*0.5)
    	label2:setPosition(tvTitleBg:getContentSize().width*0.3,tvTitleBg:getContentSize().height*0.5)
    	label3:setPosition(tvTitleBg:getContentSize().width*0.57,tvTitleBg:getContentSize().height*0.5)
    	label4:setPosition(tvTitleBg:getContentSize().width*0.87,tvTitleBg:getContentSize().height*0.5)
    	tvTitleBg:addChild(label1)
    	tvTitleBg:addChild(label2)
    	tvTitleBg:addChild(label3)
    	tvTitleBg:addChild(label4)
    end

    local function tvCallBack(handler,fn,index,cel)
        if fn=="numberOfCellsInTableView" then
            return SizeOfTable(skillData.lvinfo)
        elseif fn=="tableCellSizeForIndex" then
            return  CCSizeMake(cellW,cellH)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            if (index+1)%2==0 then
                local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function()end)
                cellBg:setContentSize(CCSizeMake(cellW,cellH))
                cellBg:setPosition(cellW/2,cellH/2)
                cell:addChild(cellBg)
            end
            if skillType==0 then
            	local label1=GetTTFLabel(tostring(index+1),fontSize)
            	local label2=GetTTFLabel(planeVoApi:getNewSkillDesc(sid,index+1),fontSize)
            	label1:setPosition(cellW*0.2,cellH*0.5)
		    	label2:setPosition(cellW*0.7,cellH*0.5)
		    	cell:addChild(label1)
		    	cell:addChild(label2)
		    elseif skillType==1 then
		    	local data=skillData.lvinfo[index+1]
		    	local str3,str4="",""
		    	if data then
		    		if data.addBox then
		    			str3={}
		    			for k, v in pairs(data.addBox.pool[3]) do
		    				local tid=RemoveFirstChar(Split(v[1],"_")[2])
		    				table.insert(str3,getlocal(tankCfg[tonumber(tid)].name))
		    			end
		    			str4=tostring(data.addBox.num*2)
		    		elseif data.hitFly then
		    			str3=(data.hitFly.prosperous*100).."%"
                        str4=GetTimeStr(data.hitFly.haveTime,true)
		    		elseif data.addTroops then
		    			str3=GetTimeStr(data.buffTime,true)
		    			str4=tostring(data.addTroops.num)
		    		elseif data.killProtect then
		    			str3=(data.killProtect.enemyLost*100).."%"
		    			str4=(data.killProtect.myLost*100).."%"
		    		end
		    	end

		    	local label1=GetTTFLabel(tostring(index+1),fontSize)
		    	local label2=GetTTFLabel(GetTimeStr(data.cd,true),fontSize)
		    	local label4=GetTTFLabel(str4,fontSize)
		    	label1:setPosition(cellW*0.1,cellH*0.5)
		    	label2:setPosition(cellW*0.3,cellH*0.5)
		    	label4:setPosition(cellW*0.87,cellH*0.5)
		    	cell:addChild(label1)
		    	cell:addChild(label2)
		    	cell:addChild(label4)

		    	if type(str3)=="table" then
		    		-- local _posY=cellH/(SizeOfTable(str3)+1)
                    local _posY=cellH-5
		    		for k, v in pairs(str3) do
		    			local label3=GetTTFLabel(v,fontSize)
		    			label3:setPosition(cellW*0.57,_posY-label3:getContentSize().height/2)
		    			cell:addChild(label3)
		    			_posY=_posY-label3:getContentSize().height
		    		end
		    	else
		    		local label3=GetTTFLabel(str3,fontSize)
		    		label3:setPosition(cellW*0.57,cellH*0.5)
		    		cell:addChild(label3)
		    	end
            end

            return cell
        elseif fn=="ccTouchBegan" then
            return true
        elseif fn=="ccTouchMoved" then
        elseif fn=="ccTouchEnded" then
        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tv=LuaCCTableView:createWithEventHandler(hd,tvSize,nil)
    tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    tv:setMaxDisToBottomOrTop(100)
    tv:setPosition(0,3)
    tvBg:addChild(tv)

    self:show()
    sceneGame:addChild(self.dialogLayer,self.layerNum)
end