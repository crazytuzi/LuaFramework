setGarrsionDialog = commonDialog:new()

function setGarrsionDialog:new(tabType,layerNum )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum

	return nc
end

function setGarrsionDialog:initTableView( )
	self.panelLineBg:setAnchorPoint(ccp(0.5,0.5))
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.panelLineBg:getContentSize().height*0.5+55))
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSize.width-20,G_VisibleSize.height-105))

    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end	
    self.backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
    self.backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, 350))
    self.backSprie:setAnchorPoint(ccp(0.5,1))
    self.backSprie:setPosition(ccp(self.panelLineBg:getContentSize().width*0.5,self.panelLineBg:getContentSize().height-10))
    self.panelLineBg:addChild(self.backSprie,1)

    local function tipTouch()
        local sd=smallDialog:new()
        local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,{" ",getlocal("alliance_desc_1")," ",getlocal("alliance_desc_2")," "},25,{nil,G_ColorYellow,nil,G_ColorYellow,nil})
        sceneGame:addChild(dialogLayer,self.layerNum+1)
        dialogLayer:setPosition(ccp(0,0))
    end
    local tipItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",tipTouch,11,nil,nil)
    -- local spScale=0.7
    -- tipItem:setScale(spScale)
    local tipMenu = CCMenu:createWithItem(tipItem)
    tipMenu:setPosition(ccp(self.backSprie:getContentSize().width-55,self.backSprie:getContentSize().height-55))
    tipMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.backSprie:addChild(tipMenu,1)


    local stateOfGarrsionLb = GetTTFLabelWrap(getlocal("alliance_stateOfGarrsion"),40,CCSizeMake(self.backSprie:getContentSize().width*0.6,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    stateOfGarrsionLb:setAnchorPoint(ccp(0,0.5))
    stateOfGarrsionLb:setPosition(ccp(20,self.backSprie:getContentSize().height-60))
    self.backSprie:addChild(stateOfGarrsionLb,1)
    stateOfGarrsionLb:setColor(G_ColorYellowPro)

    for i=1,3 do
    	local btnLb = getlocal("alliance_choosingOfGarrsionByState_"..i)
    	self:initEveryBtn(i,btnLb)
    end

end

function setGarrsionDialog:initEveryBtn(idx,btnLb)

	local function chooseStateOfGarrsion(tag,object)
		self:chooseStateOfGarrsion(tag,object)
	end 

	local choseNum = base.stateOfGarrsion or idx
	local vari = (idx-1)*75
	local choseItNow = (choseNum-1)*75
	local chooseItBgIt=GetButtonItem("BtnCheckBg.png","BtnCheckBg.png","BtnCheckBg.png",chooseStateOfGarrsion,idx+110,nil,0)
	local chooseItBg=CCMenu:createWithItem(chooseItBgIt)
    chooseItBg:setAnchorPoint(ccp(0.5,0.5))
    chooseItBg:setPosition(ccp(50,self.backSprie:getContentSize().height*0.6-10-vari))
    chooseItBg:setTouchPriority(-(self.layerNum-1)*20-4)
    self.backSprie:addChild(chooseItBg,1)
    if self.chooseItIcon ==nil then
	    self.chooseItIcon = CCSprite:createWithSpriteFrameName("BtnCheck.png")
	    self.chooseItIcon:setAnchorPoint(ccp(0.5,0.5))
	    self.chooseItIcon:setPosition(ccp(50,self.backSprie:getContentSize().height*0.6-10-choseItNow))
	    self.backSprie:addChild(self.chooseItIcon,2)
	end
    local GarrsionDesc = GetTTFLabelWrap(btnLb,25,CCSizeMake(self.backSprie:getContentSize().width*0.6,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    GarrsionDesc:setAnchorPoint(ccp(0,0.5))
    GarrsionDesc:setPosition(ccp(105,chooseItBg:getPositionY()))
    self.backSprie:addChild(GarrsionDesc,1)
    GarrsionDesc:setColor(G_ColorGreen)   
end

function setGarrsionDialog:chooseStateOfGarrsion(tag,object)
		if tag ==111 then
			self.chooseItIcon:setPosition(ccp(50,self.backSprie:getContentSize().height*0.6-10))
		elseif tag ==112 then
			self.chooseItIcon:setPosition(ccp(50,self.backSprie:getContentSize().height*0.6-85))
		elseif tag ==113 then
			self.chooseItIcon:setPosition(ccp(50,self.backSprie:getContentSize().height*0.6-160))
		end
		self:sendGarrsionOfStates(tag)
end 

function setGarrsionDialog:sendGarrsionOfStates(tag )
	local idx = tag-110
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret ==true then
			-- smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_setGarrsion"),getlocal("save_success"),nil,self.layerNum + 1)
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("save_success"),28)
		end
	end
	socketHelper:GarrsionOfState(idx,callback)
end

function setGarrsionDialog:dispose( )
    self.panelLineBg =nil
    self.backSprie=nil
    self.chooseStateOfGarrsion=nil
    self.chooseItIcon=nil
end
