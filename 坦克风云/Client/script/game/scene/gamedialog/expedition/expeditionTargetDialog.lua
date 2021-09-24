
expeditionTargetDialog=commonDialog:new()

function expeditionTargetDialog:new(eid,parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.rankLabel=nil
	self.nameLabel=nil
	self.levelLabel=nil
	self.valueLabel=nil
	self.labelTab={}
	self.cellHeight=72
	self.parent=parent
	self.eid=eid
    return nc
end


function expeditionTargetDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
         tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
    self:initLayer()
end

function expeditionTargetDialog:initLayer()	
	  local lbx=250
	  local lby = 10
	  --UI
	  local nameStr = expeditionVoApi:getName()
	  if expeditionVoApi:getUid()==0 then
	  	 nameStr=getlocal(expeditionVoApi:getName())
	  end
	  local aName = getlocal("alliance_info_content")
	  if expeditionVoApi:getAname() then
	  	 aName=expeditionVoApi:getAname()
	  end

	  local lbTB={
	  {str=nameStr,size=35,pos={lbx,G_VisibleSizeHeight-130-lby},aPos={0,0.5},color=G_ColorYellow},
	  {str=G_LV()..expeditionVoApi:getLevel(),size=26,pos={lbx,G_VisibleSizeHeight-170-lby},aPos={0,0.5},tag=101},
	  {str=getlocal("powerShow",{expeditionVoApi:getPower()}),size=26,pos={lbx,G_VisibleSizeHeight-210-lby},aPos={0,0.5},tag=102},
	  {str=getlocal("expeditionAllianceName",{aName}),size=26,pos={lbx,G_VisibleSizeHeight-250-lby},aPos={0,0.5},tag=102},
	  }

	  for k,v in pairs(lbTB) do
	    local strLb=GetTTFLabel(v.str,v.size)
	    if v.aPos then
	       strLb:setAnchorPoint(ccp(v.aPos[1],v.aPos[2]))
	    end
	    if v.color then
	       strLb:setColor(v.color)
	    end
	    strLb:setPosition(ccp(v.pos[1],v.pos[2]))
	    self.bgLayer:addChild(strLb)
	    if v.tag~=nil then
	      strLb:setTag(v.tag)
	    end
	  end

	  --local personPhotoName="photo"..playerVoApi:getPic()..".png"
	  --local photoSp = GetBgIcon(personPhotoName);
      local personPhotoName=playerVoApi:getPersonPhotoName(expeditionVoApi:getApic())
      local photoSp = playerVoApi:GetPlayerBgIcon(personPhotoName);
	  photoSp:setScale(2);
	  photoSp:setAnchorPoint(ccp(0,0.5));
	  photoSp:setPosition(ccp(60,G_VisibleSizeHeight-200));
	  self.bgLayer:addChild(photoSp,2);

	  local capInSetNew=CCRect(20, 20, 10, 10)
	  local function cellClick()
			
	  end
	  local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSetNew,cellClick)
	  backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, 68))
	  backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight-350))
	  backSprie:ignoreAnchorPointForPosition(false)
	  backSprie:setIsSallow(false)
	  backSprie:setTouchPriority(-42)
	  self.bgLayer:addChild(backSprie,1)

	  local strLb=GetTTFLabel(getlocal("forceInformation"),32)
      strLb:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2))
	  backSprie:addChild(strLb)


end

--设置对话框里的tableView
function expeditionTargetDialog:initTableView()	
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-510),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,120))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(100)

    local function award()
    	require "luascript/script/game/scene/gamedialog/expedition/expeditionSmallDialog"
      	expeditionSmallDialog:showReward(self.eid,self.layerNum+1)
    end
    local awardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",award,nil,getlocal("award"),25)
    local awardBtn=CCMenu:createWithItem(awardItem)
    awardBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    awardBtn:setAnchorPoint(ccp(1,0.5))
    awardBtn:setPosition(ccp(200,60))
    self.bgLayer:addChild(awardBtn)


    local function attack()
    	
    	
    	require "luascript/script/game/scene/gamedialog/expedition/expeditionAttackDialog"
    	local td=expeditionAttackDialog:new(self,self.layerNum+1)
        local tbArr={getlocal("AEFFighting"),getlocal("dispatchCard"),getlocal("repair")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("AEFFighting"),true,7)
        sceneGame:addChild(dialog,self.layerNum+1)
    	
    end
    local attackItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",attack,nil,getlocal("RankScene_attack"),25)
    local attackBtn=CCMenu:createWithItem(attackItem)
    attackBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    attackBtn:setAnchorPoint(ccp(1,0.5))
    attackBtn:setPosition(ccp(460,60))
    self.bgLayer:addChild(attackBtn)
end


--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function expeditionTargetDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
	   return 1
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize=CCSizeMake(400,750)
       return  tmpSize
   elseif fn=="tableCellAtIndex" then	
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellWidth=self.bgLayer:getContentSize().width-60
        local cellHeight=120

		local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local function cellClick(hd,fn,idx)
        end
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)

		backSprie:setContentSize(CCSizeMake(cellWidth-10, 700))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,1))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:setPosition(ccp(5,700-30))
        cell:addChild(backSprie,1)


	    local needHight = 0
	    if G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="de" then
	    	needHight =30
	    end

        local tHeight=backSprie:getContentSize().height-50
        local soldiersLb = GetTTFLabel(getlocal("player_leader_troop_num",{expeditionVoApi:getTroopsNum()}),26)
        soldiersLb:setAnchorPoint(ccp(0,0.5))
        soldiersLb:setPosition(ccp(60,tHeight+needHight))
        backSprie:addChild(soldiersLb,2)
        
 

        local layer1 = CCLayer:create()
        backSprie:addChild(layer1)
        local sizeLb=220*2+100
	    local temHight=0
	    if G_isIphone5() then
	        temHight=110
	    end

	    local tankTb=expeditionVoApi:getTroops()
	    local tskinTb=expeditionVoApi:getTroopsSkinTb()
	    local toscale=0.8
	    local hh=-90
	    if G_isIphone5() then
	    	hh=-170
	    end
        for k=1,6 do
	        local width = backSprie:getContentSize().width-(math.ceil(k/3))*260+30
	        local height = sizeLb-(((k-1)%3)*200+10)+hh
	        local function touchClick(hd,fn,idx)
	        
	        end
	        local bgSp =LuaCCScale9Sprite:createWithSpriteFrameName("BgEmptyTank.png",CCRect(10, 10, 20, 20),touchClick)
	        bgSp:setContentSize(CCSizeMake(150, 150))
	        bgSp:ignoreAnchorPointForPosition(false)
	        bgSp:setAnchorPoint(ccp(0,0))
	        bgSp:setIsSallow(false)
	        bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
	        bgSp:setPosition(ccp(width,height+temHight+needHight))
	        layer1:addChild(bgSp,1)
	        bgSp:setScale(toscale)
	        
	        
	        local v=nil;
	        if tankTb~=nil then
	            v=tankTb[k]
	        end
	        if v[1]~=nil and v[2]>0 then
	            local slotId=tonumber(RemoveFirstChar(v[1]))
	            local skinId = tskinTb[tankSkinVoApi:convertTankId(v[1])]
	            local icon = tankVoApi:getTankIconSp(slotId,skinId,nil,false)--CCSprite:createWithSpriteFrameName(tankCfg[slotId].icon)
	            icon:setPosition(getCenterPoint(bgSp))
	            bgSp:addChild(icon,2)

	            local id = tonumber(slotId) and tonumber(slotId) or tonumber(RemoveFirstChar(slotId))
	            if id~=G_pickedList(id) then
			        local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
			        icon:addChild(pickedIcon)
			        pickedIcon:setPosition(icon:getContentSize().width-30,30)
			        pickedIcon:setScale(1.5)
			    end
	            
	            local str=(getlocal(tankCfg[slotId].name)).."("..tostring(v[2])..")"
	            local descLable = GetTTFLabelWrap(str,26,CCSizeMake(260,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	            descLable:setAnchorPoint(ccp(0.5,1))
	            descLable:setPosition(ccp(bgSp:getContentSize().width/2,-10))
	            bgSp:addChild(descLable,2)
	        end
	        
	    end


        local layer2 = CCLayer:create()
        layer2:setPosition(ccp(10000,0))
        backSprie:addChild(layer2)

        local heroTb=expeditionVoApi:getAtkHeroTb()
        local heroStrTb = expeditionVoApi:getAtkHeroStrTb()
        for k=1,6 do
	        local width = backSprie:getContentSize().width-(math.ceil(k/3))*260+30
	        local height = sizeLb-(((k-1)%3)*200+10)+hh
	        local function touchClick(hd,fn,idx)
	        
	        end
	        local bgSp =LuaCCScale9Sprite:createWithSpriteFrameName("heroHeadBG.png",CCRect(10, 10, 20, 20),touchClick)
	        bgSp:setContentSize(CCSizeMake(150, 150))
	        bgSp:ignoreAnchorPointForPosition(false)
	        bgSp:setAnchorPoint(ccp(0,0))
	        bgSp:setIsSallow(false)
	        bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
	        bgSp:setPosition(ccp(width,height+temHight+needHight))
	        layer2:addChild(bgSp,1)
	        bgSp:setScale(toscale)
	        
	        if heroTb~=nil and heroTb[k]~=nil and SizeOfTable(heroTb[k])>0 then
	        	local adjutants={} --将领副官数据
	        	if heroStrTb and heroStrTb[k] then
	        		adjutants = heroAdjutantVoApi:decodeAdjutant(heroStrTb[k])
	        	end
	        	local heroSp=heroVoApi:getHeroIcon(heroTb[k][1],heroTb[k][3],nil,nil,nil,nil,nil,{adjutants=adjutants})
		        heroSp:setPosition(getCenterPoint(bgSp))
		        bgSp:addChild(heroSp)
		        local str=heroVoApi:getHeroName(heroTb[k][1])..G_LV()..heroTb[k][2]
	            local descLable = GetTTFLabelWrap(str,26,CCSizeMake(260,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	            descLable:setAnchorPoint(ccp(0.5,1))
	            descLable:setPosition(ccp(bgSp:getContentSize().width/2,-20))
	            bgSp:addChild(descLable,2)

	        end
	        
	    end

        local layer3 = CCLayer:create()
        layer3:setPosition(ccp(10000,0))
        backSprie:addChild(layer3)
	    local aitroopsTb=expeditionVoApi:getAtkAITroopsTb()
        for k=1,6 do
	        local width = backSprie:getContentSize().width-(math.ceil(k/3))*260+30
	        local height = sizeLb-(((k-1)%3)*200+10)+hh

	        local bgSp =LuaCCScale9Sprite:createWithSpriteFrameName("heroHeadBG.png",CCRect(10, 10, 20, 20),function ()	end)
	        bgSp:setContentSize(CCSizeMake(150, 150))
	        bgSp:ignoreAnchorPointForPosition(false)
	        bgSp:setAnchorPoint(ccp(0,0))
	        bgSp:setIsSallow(false)
	        bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
	        bgSp:setPosition(ccp(width,height+temHight+needHight))
	        layer3:addChild(bgSp,1)
	        bgSp:setScale(toscale)
        	local aitroops = aitroopsTb[k] or ""
            local atid, lv, grade, strength
            local mirror, arr = AITroopsVoApi:checkIsAITroopsMirror(aitroops)
            if mirror == true then
                local aitVo = AITroopsVoApi:createAITroopsVoByMirror(arr)
                if aitVo then
                    atid, lv, grade, strength = aitVo.id, aitVo.lv, aitVo.grade, aitVo:getTroopsStrength()
                end
            end
            if atid and lv and grade and strength then
                local spWidth = 150
                local aitroopsIconSp = AITroopsVoApi:getAITroopsSimpleIcon(atid, lv, grade)
                aitroopsIconSp:setScale(spWidth / aitroopsIconSp:getContentSize().width)
                aitroopsIconSp:setPosition(getCenterPoint(bgSp))
                bgSp:addChild(aitroopsIconSp)
                
                local nameStr, color = AITroopsVoApi:getAITroopsNameStr(atid)
                local troopsNameLb = GetTTFLabelWrap(nameStr, 26, CCSizeMake(160, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop,"Helvetica-bold")
                troopsNameLb:setAnchorPoint(ccp(0.5, 1))
                troopsNameLb:setColor(color)
                troopsNameLb:setPosition(aitroopsIconSp:getPositionX(),-5)
                bgSp:addChild(troopsNameLb, 2)
                
                local strengthLb = GetTTFLabel(strength, 22)
                strengthLb:setAnchorPoint(ccp(0.5, 1))
                strengthLb:setPosition(troopsNameLb:getPositionX(),troopsNameLb:getPositionY()-troopsNameLb:getContentSize().height-2)
                bgSp:addChild(strengthLb, 2)
            end
	    end

        local switchTankPic, switchHeroPic, switchAIPic = "changeRole1.png", "changeRole2.png", "smt_switchAI.png"
	    if base.AITroopsSwitch == 1 then
	        switchTankPic, switchHeroPic = "smt_switchTank.png", "smt_switchHero.png"
	    end

        local changeMenu=CCMenu:create()
	    local switchSp1 = CCSprite:createWithSpriteFrameName(switchTankPic)
	    local switchSp2 = CCSprite:createWithSpriteFrameName(switchTankPic)
	    local menuItemSp1 = CCMenuItemSprite:create(switchSp1,switchSp2)
	    local switchSp3 = CCSprite:createWithSpriteFrameName(switchHeroPic)
	    local switchSp4 = CCSprite:createWithSpriteFrameName(switchHeroPic)
	    local menuItemSp2 = CCMenuItemSprite:create(switchSp3,switchSp4)
	    local switchSp5 = CCSprite:createWithSpriteFrameName(switchAIPic)
	    local switchSp6 = CCSprite:createWithSpriteFrameName(switchAIPic)
	    local menuItemSp3 = CCMenuItemSprite:create(switchSp5,switchSp6)
	    local changeItem = CCMenuItemToggle:create(menuItemSp1)
	    if base.AITroopsSwitch == 1 then
	    	changeItem:addSubItem(menuItemSp3)
	    end
	    changeItem:addSubItem(menuItemSp2)
	    changeItem:setAnchorPoint(CCPointMake(1,1))
	    changeItem:setPosition(0,0)
	    local function changeHandler()
	    	local selectIndex = changeItem:getSelectedIndex()
	    	if selectIndex==0 then
	            layer1:setPosition(0,0)
	            layer1:setVisible(true)
	            layer2:setPosition(10000,0)
	            layer2:setVisible(false)
                layer3:setPosition(10000,0)
	            layer3:setVisible(false)
	        else
	        	if base.AITroopsSwitch==1 then
	        		if selectIndex==1 then
			          	layer1:setPosition(10000,0)
			            layer1:setVisible(false)
			            layer2:setPosition(10000,0)
			            layer2:setVisible(false)
		                layer3:setPosition(0,0)
			            layer3:setVisible(true)
			        else
    		          	layer1:setPosition(10000,0)
			            layer1:setVisible(false)
			            layer2:setPosition(0,0)
			            layer2:setVisible(true)
		                layer3:setPosition(10000,0)
			            layer3:setVisible(false)
	        		end
	        	else
		          	layer1:setPosition(10000,0)
		            layer1:setVisible(false)
		            layer2:setPosition(0,0)
		            layer2:setVisible(true)
	                layer3:setPosition(10000,0)
		            layer3:setVisible(false)
	        	end
	    	end
	    end
	    changeItem:registerScriptTapHandler(changeHandler)
	    changeMenu:addChild(changeItem)
	    changeMenu:setPosition(ccp(backSprie:getContentSize().width-10,backSprie:getContentSize().height-10))
	    changeMenu:setTouchPriority(-(self.layerNum-1)*20-3)
	    backSprie:addChild(changeMenu,2)
	    changeItem:setSelectedIndex(0)



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
function expeditionTargetDialog:tabClick(idx)
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
function expeditionTargetDialog:doUserHandler()
	
end


--点击了cell或cell上某个按钮
function expeditionTargetDialog:cellClick(idx)

end

function expeditionTargetDialog:dispose()
	self.parent:refresh()
	self=nil
end





