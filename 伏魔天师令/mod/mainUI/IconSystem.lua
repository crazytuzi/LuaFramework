local IconPosTypeArray={
	[_G.Const.kMainIconPos1]=true,
	[_G.Const.kMainIconPos2]=true,
	[_G.Const.kMainIconPos3]=true,
	[_G.Const.kMainIconPos4]=true,
}

local IconSystem=classGc(view,function(self)
	self.m_iconArray1={}
	self.m_iconArray2={}
	self.m_iconCountArray={}
	self.m_iconCountArray[_G.Const.kMainIconPos1]=0
	self.m_iconCountArray[_G.Const.kMainIconPos2]=0
	self.m_iconCountArray[_G.Const.kMainIconPos3]=0
	self.m_iconCountArray[_G.Const.kMainIconPos4]=0

	self.m_iconNumArray={}
	self.m_signSprArray={}
	self.m_guideSprArray={}

	self.m_winSize=cc.Director:getInstance():getWinSize()
end)

function IconSystem.create(self)
	self.m_rootNode=cc.Node:create()

	self:init()
	return self.m_rootNode
end

function IconSystem.init(self)
	self:initView()
	self:initIconButton()
end

function IconSystem.initView(self)
	local function touchEvent(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			if self.m_isMenuChuange then
				self:showMenuNormal()
			else
				self:showMenuChuang()
			end
        end
    end

    self.m_openSpr=cc.Sprite:createWithSpriteFrameName("main_sys_close.png")
    self.m_menuSize=self.m_openSpr:getContentSize()
    self.m_openSpr:setPosition(cc.p(self.m_menuSize.width/2,self.m_menuSize.height/2))

    self.m_menuPos=cc.p(self.m_winSize.width-self.m_menuSize.width/2-10,self.m_menuSize.height/2+10)
	self.m_menuBtn=ccui.Widget:create()
	self.m_menuBtn:setContentSize(self.m_menuSize)
	self.m_menuBtn:setTouchEnabled(true)
	self.m_menuBtn:setPosition(self.m_menuPos)
	self.m_menuBtn:addTouchEventListener(touchEvent)
	self.m_menuBtn:addChild(self.m_openSpr)
    self.m_rootNode:addChild(self.m_menuBtn)

    if _G.GSystemProxy:isSystemViewShow() then
    	self.m_isMenuChuange=true
    else
    	self.m_isMenuChuange=false
    end

    local highBtn=cc.Sprite:createWithSpriteFrameName("main_sys_dins.png")
    highBtn:setPosition(cc.p(self.m_menuSize.width/2,self.m_menuSize.height/2+18))
    self.m_menuBtn:addChild(highBtn,2)
end

function IconSystem.getIconBtnById(self,_sysId)
	if self.m_iconArray1[_sysId] then
		return self.m_iconArray1[_sysId].btn,true
	elseif self.m_iconArray2[_sysId] then
		return self.m_iconArray2[_sysId].btn,false
	end
end

function IconSystem.showMenuNormal(self)
	if not self.m_isMenuChuange then return end
	self.m_isMenuChuange=false
	
	self.m_openSpr:runAction(cc.RotateTo:create(0.3,0))

	self:showIconAction()
	_G.GSystemProxy:setSystemViewShow(false)
	-- _G.g_SmallChatView:showView()
end
function IconSystem.showMenuChuang(self)
	if self.m_isMenuChuange then return end
	self.m_isMenuChuange=true

	self.m_openSpr:runAction(cc.RotateTo:create(0.3,-135))

	self:showIconAction()
	_G.GSystemProxy:setSystemViewShow(true)
	-- _G.g_SmallChatView:hideView()
end
function IconSystem.showMenuAuto(self)
	if self.m_isMenuChuange then
		self:showMenuNormal()
	else
		self:showMenuChuang()
	end
end
function IconSystem.isMenuChuange(self)
	return self.m_isMenuChuange
end

function IconSystem.getSortSysArray(self)
	local arrayT=_G.Cfg.sys_open_array
    local newArray={}
    local curCount=0
    for k,v in pairs(self.m_sysList) do
    	local dataT=arrayT[k]
    	if dataT~=nil then
    		local posType=dataT.type
    		if IconPosTypeArray[posType] then
    			curCount=curCount+1
	        	newArray[curCount]=v
	        	newArray[curCount].array=arrayT[k] and arrayT[k].array or 1000
	        	newArray[curCount].type=posType
    		end
    	end
    end

    local function local_sort(v1,v2)
        if v1.array==v2.array then
            return v1.id<v2.id
        else
            return v1.array<v2.array
        end
    end
    table.sort( newArray, local_sort )
    return newArray
end

function IconSystem.initIconButton(self)
	self.m_sysList=_G.GOpenProxy:getSysId() --功能按钮id

	local signArray=_G.GOpenProxy:getSysSignArray()
	local resList=_G.Cfg.IconResList

	local newSys=self:getSortSysArray()
	for i=1,#newSys do
		local value=newSys[i]
		local sysId=value.id
		local szImg=resList[sysId]
		if szImg~=nil then
			self:addIconBtn(value.type,sysId,szImg,value.state,value.number)
			if signArray[sysId] then
				self:addSignSpr(sysId)
			end
		end
	end
end
function IconSystem.addIconBtn(self,_posType,_id,_szName,_state,_number)
	local tempArray,isNormalPos=nil
	if _posType==_G.Const.kMainIconPos1 or _posType==_G.Const.kMainIconPos2 then
		tempArray=self.m_iconArray1
		isNormalPos=true
	else
		tempArray=self.m_iconArray2
		isNormalPos=false
	end

	if tempArray[_id] then
		self:resetSysNumber(_id)
		return
	end
	self.m_iconCountArray[_posType]=self.m_iconCountArray[_posType]+1

	local iconT={}
	iconT.id=_id

	local function c(sender,eventType)
        return self:iconClickCallBack(sender,eventType)
    end

	local button = gc.CButton:create(_szName)
    button:setPosition(self:getIconBtnPos(_posType,self.m_iconCountArray[_posType]))
    button:addTouchEventListener(c)
    button:setTag(_id)
    button:ignoreContentAdaptWithSize(false)
    button:setContentSize(_G.Const.kMainIconSize)
    self.m_rootNode:addChild(button)

    if self.m_isMenuChuange==isNormalPos then
    	button:setOpacity(0)
    	button:setScale(0.01)
    	button:setVisible(false)
    end

    iconT.btn=button

    tempArray[_id]=iconT

    if _number~=nil and _number~=0 then
    	self:resetSysNumber(_id)
    end
end
function IconSystem.getIconBtnPos(self,_posType,_idx)
	if _posType==_G.Const.kMainIconPos1 or _posType==_G.Const.kMainIconPos3 then
		return self:getUpBtnPos(_idx)
	else
		return self:getDownBtnPos(_idx)
	end
end
function IconSystem.getUpBtnPos(self,_idx)
	local nPosY=self.m_menuPos.y+(_G.Const.kMainIconSize.height+10)*_idx
	return self.m_menuPos.x,nPosY
end
function IconSystem.getDownBtnPos(self,_idx)
	local rowCount=5
	local r=_idx%rowCount
	local row=r==0 and math.floor(_idx/rowCount)-1 or math.floor(_idx/rowCount)
	local rowCount=r==0 and rowCount or r
	local nPosX=self.m_menuPos.x-self.m_menuSize.width/2+35-_G.Const.kMainIconSize.width*rowCount
	local nPosY=self.m_menuPos.y+(_G.Const.kMainIconSize.height+10)*row
	return nPosX,nPosY
end

function IconSystem.showIconAction(self)
	local fadeTo=cc.FadeTo:create(0.15,255)
	local scale1=cc.ScaleTo:create(0.05,1.2)
	local scale2=cc.ScaleTo:create(0.05,1)
	local action1=cc.Sequence:create(cc.Show:create(),fadeTo,scale1,scale2)
	local action2=cc.ScaleTo:create(0.25,1)

	local scale1=cc.ScaleTo:create(0.05,1.2)
	local scale2=cc.ScaleTo:create(0.05,1)
	local scale3=cc.ScaleTo:create(0.15,0.01)
	local action3=cc.Sequence:create(scale1,scale2,scale3,cc.Hide:create())
	local action4=cc.FadeTo:create(0.25,0)

	local actFade1,actScale1,actFade2,actScale2
	if self.m_isMenuChuange then
		actFade1=action3
		actScale1=action4
		actFade2=action1
		actScale2=action2
	else
		actFade1=action1
		actScale1=action2
		actFade2=action3
		actScale2=action4
	end
	if self.m_menuTouchSpr~=nil then
		if self.m_isMenuChuange==self.m_menuTouchIsNormal and self.m_guideVisible then
			self.m_menuTouchSpr:setVisible(true)
		else
			self.m_menuTouchSpr:setVisible(false)
		end
		print("GGGGGG=========>>>",self.m_isMenuChuange,self.m_menuTouchIsNormal)
	end

	for id,iconT in pairs(self.m_iconArray1) do
		local btn=iconT.btn
		btn:stopAllActions()
		btn:runAction(actFade1:clone())
		btn:runAction(actScale1:clone())
	end
	for id,iconT in pairs(self.m_iconArray2) do
		local btn=iconT.btn
		btn:stopAllActions()
		btn:runAction(actFade2:clone())
		btn:runAction(actScale2:clone())
	end
end

function IconSystem.sysOpenDataChuange(self,_cList)
	local resList=_G.Cfg.IconResList
	local arrayT=_G.Cfg.sys_open_array
	for _,id in pairs(_cList) do
		local dataT=arrayT[id]
		-- print("sysOpenDataChuange===========>>>>>",id,dataT)
		if dataT and IconPosTypeArray[dataT.type] then
			self:addIconBtn(dataT.type,id,resList[id],self.m_sysList[id].state,self.m_sysList[id].number)
		end
	end
end
function IconSystem.resetSysNumber(self,_id)
	if self.m_sysList[_id]==nil then return end
	local tNum=self.m_sysList[_id].number
	
	if tNum==nil or tNum==0 then
		self:removeSysNumber(_id)
		return
	end
	local szNum=tNum>9 and "N" or tostring(tNum)
	if self.m_iconNumArray[_id]~=nil then
		self.m_iconNumArray[_id]:getChildByTag(33):setString(szNum)
		return
	end

	local tParent=self.m_iconArray1[_id] or self.m_iconArray2[_id]
	if tParent==nil then return end

	tParent=tParent.btn
	local numSpr=cc.Sprite:createWithSpriteFrameName("general_report_tips2.png")
	numSpr:setPosition(65,65)
	tParent:addChild(numSpr,20)

	local sprSize=numSpr:getContentSize()
	local tempLabel=_G.Util:createLabel(szNum,18)
	tempLabel:setTag(33)
	tempLabel:setPosition(sprSize.width*0.5+1.5,sprSize.height*0.5-2)
	numSpr:addChild(tempLabel)

	self.m_iconNumArray[_id]=numSpr
end
function IconSystem.removeSysNumber(self,_id)
	if self.m_iconNumArray[_id]~=nil then
		self.m_iconNumArray[_id]:removeFromParent(true)
		self.m_iconNumArray[_id]=nil
	end
end

function IconSystem.addSignSpr(self,_id)
	if self.m_signSprArray[_id] then return end

	local tParent=self.m_iconArray1[_id] or self.m_iconArray2[_id]
	if tParent==nil then return end

	tParent=tParent.btn
	local signSpr=cc.Sprite:createWithSpriteFrameName("general_redpoint.png")
	signSpr:setPosition(70,65)
	tParent:addChild(signSpr,15)

	self.m_signSprArray[_id]=signSpr
end
function IconSystem.delSignSpr(self,_id)
	if self.m_signSprArray[_id]~=nil then
		self.m_signSprArray[_id]:removeFromParent(true)
		self.m_signSprArray[_id]=nil
	end
end

function IconSystem.iconClickCallBack(self,sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local tag=sender:getTag()
		print("iconClickCallBack---->>",tag)

	    _G.GLayerManager:openLayer(tag)

	    -- if self.m_sysList[tag].state == _G.Const.CONST_ACTIVITY_NEW then
	    --     local msg=REQ_ROLE_USE_SYS()
	    --     msg:setArgs(tag)  -- {功能ID}
	    --     _G.Network:send(msg)
	    -- end

	    -- self:showMenuNormal()
	end
end

function IconSystem.addGuideTouch(self,_guideSysId)
	if self.m_guideSprArray[_guideSysId] then return end

	local guideBtn=self.m_iconArray1[_guideSysId] or self.m_iconArray2[_guideSysId]
	if guideBtn==nil then return end

	guideBtn=guideBtn.btn
	local btnSize=guideBtn:getContentSize()
    local guideNode=_G.GGuideManager:createTouchNode()
    guideNode:setPosition(btnSize.width*0.5,btnSize.height*0.5)
    guideBtn:addChild(guideNode,100)
    guideBtn:setLocalZOrder(guideBtn:getLocalZOrder()+1)

    local szNotic=_G.GGuideManager:getCurGuideCnf().name
    -- szNotic=string.format("开始%s",szNotic)
    local noticNode=_G.GGuideManager:createNoticNode(szNotic or "【ERROR】",true)
    noticNode:setPosition(-190,5)
    guideNode:addChild(noticNode)

	self.m_guideSprArray[_guideSysId]=guideNode

	self:__addMenuTouch(_guideSysId)
	return true
end
function IconSystem.removeGuideTouch(self,_guideSysId)
	if self.m_guideSprArray[_guideSysId]~=nil then
		self.m_guideSprArray[_guideSysId]:removeFromParent(true)
		self.m_guideSprArray[_guideSysId]=nil
		if next(self.m_guideSprArray)==nil then
			self:__removeMenuTouch()
		end
	end
end
function IconSystem.setVisibleGuideTouch(self,_bool)
	if self.m_guideSprArray~=nil then
		for k,v in pairs(self.m_guideSprArray) do
			v:setVisible(_bool)
		end
	end
	if self.m_menuTouchSpr~=nil and self:isMenuChuange()==self.m_menuTouchIsNormal then
		self.m_menuTouchSpr:setVisible(_bool)
	end

	self.m_guideVisible=_bool
end
function IconSystem.__addMenuTouch(self,_guideSysId)
	if self.m_menuTouchSpr~=nil then return end

	-- local btnSize=self.m_menuBtn:getContentSize()
    local guideNode=_G.GGuideManager:createTouchNode()
    guideNode:setPosition(self.m_menuBtn:getPosition())
	self.m_rootNode:addChild(guideNode,10)

	local noticNode=_G.GGuideManager:createNoticNode("展开功能列表",true)
    noticNode:setPosition(-200,0)
    guideNode:addChild(noticNode)

    self.m_menuTouchIsNormal=self.m_iconArray1[_guideSysId]~=nil
    self.m_menuTouchSpr=guideNode
    self.m_guideVisible=true

	if self:isMenuChuange()~=self.m_menuTouchIsNormal then
		guideNode:setVisible(false)
	end
end
function IconSystem.__removeMenuTouch(self)
	if self.m_menuTouchSpr~=nil then
		self.m_menuTouchSpr:removeFromParent(true)
		self.m_menuTouchSpr=nil
	end
	self.m_menuTouchIsNormal=nil
	self.m_guideVisible=false
end

return IconSystem