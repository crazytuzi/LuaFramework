local SysArrayView=classGc(view,function(self,_sysParentId,_sysName,_sysCnfArray,_limitArray,_guideArray)
	self.m_sysParentId=_sysParentId
	self.m_sysCnfArray=_sysCnfArray
	self.m_limitArray=_limitArray
	self.m_guideArray=_guideArray or {}
	self.m_sysOpenArray=_G.GOpenProxy:getSysId()
	self.m_limitOnlineArray=_G.GOpenProxy:getLimitId() or {}
	self.m_szTitle=_sysName or "未配置"

	self.m_resourcesArray = {}
	self.numSpr = {} 

	self:__initParameter()

	self.m_mediator = require("mod.mainUI.SysArrayMediator")(self) 
end)

function SysArrayView.__initParameter(self)
	local newArray={}
	local newCount=0
	for key,value in pairs(self.m_sysCnfArray) do
		if self.m_limitArray[key] then
			if self.m_limitOnlineArray[key] then
				newCount=newCount+1
				newArray[newCount]=value
			end
		elseif self.m_sysOpenArray[key] then
			newCount=newCount+1
			newArray[newCount]=value
		end
	end

	local function local_sort(v1,v2)
        if v1.array==v2.array then
            return v1.mod_id<v2.mod_id
        else
            return v1.array<v2.array
        end
    end
    table.sort(newArray,local_sort)

    self.m_sysCnfArray=newArray
end

function SysArrayView.create(self)
	self.m_normalView=require("mod.general.NormalView")()
    self.m_rootLayer=self.m_normalView:create()
	self.m_normalView:setTitle(self.m_szTitle)

	local tempScene=cc.Scene:create()
	tempScene:addChild(self.m_rootLayer)

	self:__initView()

	return tempScene
end

function SysArrayView.__initView(self)
	local function nCloseFun()
		self:closeWindow()
	end
	self.m_normalView:addCloseFun(nCloseFun)

	local mainSize=cc.size(848,517)
	self.m_normalView:setSecondSize(mainSize)
	local mainSpr=self.m_normalView:getSecondSpr()
	mainSpr:setPosition(0,280)

	local tempPos=cc.p(0,2)
	local tempNode=cc.Node:create()

	local sysCount=#self.m_sysCnfArray
	local rowCount=4
	local colCount=math.ceil(sysCount/rowCount-0.01)
	local scoSize=cc.size(mainSize.width,mainSize.height-tempPos.y*2)

	local function nBtnEvent(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            local nTag=sender:getTag()
            print("nBtnEvent  click!!  nTag="..nTag)
            -- self:closeWindow()

            if nTag==_G.Const.CONST_FUNC_OPEN_COPY or nTag==_G.Const.CONST_FUNC_OPEN_COPY_COMMON then
            	_G.GLayerManager:openLayerByMapOpenId(_G.Const.CONST_MAP_COPY,nil,true)
            elseif nTag==_G.Const.CONST_FUNC_OPEN_COPY_NIGHTMARE then
            	_G.GLayerManager:openLayerByMapOpenId(_G.Const.CONST_MAP_COPY_NIGHTMARE,nil,true)
            elseif nTag==_G.Const.CONST_FUNC_OPEN_COPY_HELL then
            	_G.GLayerManager:openLayerByMapOpenId(_G.Const.CONST_MAP_COPY_HELL,nil,true)
            elseif nTag==_G.Const.CONST_FUNC_OPEN_QIECHUO_GONGLUE then
            	local myText = "在城镇里点击其他玩家，选择切磋，待对方同意后即可进行切磋"
			    local function fun1( )
			        self:closeWindow()
			    end
			    _G.Util:showTipsBox(myText,fun1)
            else
            	_G.GLayerManager:openLayer(nTag)
            end
        end
    end

	local divWidth=mainSize.width/rowCount-3
	local divHeight=scoSize.height*0.5-3
	local szNormal="general_fram_sys.png"
	local tempIdx=1
	print("GGGGGGGGGGGG>>>>>>>>>>",sysCount)
	for i=1,colCount do
		local nCount
		if i==colCount then
			local tempN=sysCount%rowCount
			nCount=tempN==0 and rowCount or tempN
		else
			nCount=rowCount
		end
		for j=1,nCount do
			local showCnf=self.m_sysCnfArray[tempIdx]
			local posX=6+(j-0.5)*divWidth
			local posY=colCount==1 and 3+1.5*divHeight or 3+(colCount-i+0.5)*divHeight
			local tempBtn=gc.CButton:create(szNormal)
	        tempBtn:setPosition(posX,posY)
	        tempBtn:addTouchEventListener(nBtnEvent)
	        tempBtn:setTag(showCnf.mod_id)
	        tempBtn:setTouchActionType(_G.Const.kCButtonTouchTypeGray)
	        tempNode:addChild(tempBtn)

	        local btnSize=tempBtn:getContentSize()
	        local szName=showCnf.name or "[ERROR]"
	        local sysNameLabel=_G.Util:createLabel(szName,20)
	        sysNameLabel:setPosition(posX,posY+btnSize.height*0.5-20)
	        sysNameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
	        tempNode:addChild(sysNameLabel)

	        local iconPath=string.format("icon/i%s.png",tostring(showCnf.mod_id))
		    if _G.FilesUtil:check(iconPath)==false then
		        iconPath="icon/i30300.png"
		    end
		    local iconSpr=_G.ImageAsyncManager:createNormalSpr(iconPath)
		    iconSpr:setPosition(posX,posY+13)
		    tempNode:addChild(iconSpr)

		    if self.m_resourcesArray[iconPath] == nil then
		    	self.m_resourcesArray[iconPath] = true
		    end

		    local szInfo=showCnf.des or "[ERROR]"
		    local infoLabel=_G.Util:createLabel(szInfo,20)
		    infoLabel:setDimensions(btnSize.width-10,0)
		    -- infoLabel:setAnchorPoint(cc.p(0.5,1))
		    infoLabel:setPosition(posX+5,posY-btnSize.height*0.5+35)
		    infoLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
		    infoLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
		    tempNode:addChild(infoLabel)

		    if self.m_sysOpenArray[showCnf.mod_id]~=nil then
			    local tNum=self.m_sysOpenArray[showCnf.mod_id].number
			    if tNum~=nil and tNum~=0 then
			    	local szNum=tNum>9 and "N" or tostring(tNum)
			    	local numSpr=cc.Sprite:createWithSpriteFrameName("general_report_tips2.png")
				    numSpr:setPosition(posX+75,posY+60)
				    tempNode:addChild(numSpr,20)
				    self.numSpr[showCnf.mod_id] = numSpr

				    local sprSize=numSpr:getContentSize()
				    local tempLabel=_G.Util:createLabel(szNum,18)
				    tempLabel:setPosition(sprSize.width*0.5+2,sprSize.height*0.5-2)
				    tempLabel:setTag(1)
				    numSpr:addChild(tempLabel)
				    
			    end

			    if self.m_guideArray[showCnf.mod_id] then
				    local guideNode=_G.GGuideManager:createTouchNode()
				    guideNode:setPosition(posX,posY+5)
				    tempNode:addChild(guideNode,100)

				    local isTurn=j>2
				    local guideCnf=_G.GGuideManager:getCurGuideCnf()
				    local noticNode=_G.GGuideManager:createNoticNode(guideCnf.name,isTurn)
				    if isTurn then
				    	noticNode:setPosition(-190,-20)
				    else
		            	noticNode:setPosition(190,-20)
		            end
		            guideNode:addChild(noticNode)
		            self.m_guideNode=guideNode
			    end
			end

	        tempIdx=tempIdx+1
		end
	end

	if colCount>2 then
		local tempScrollView=cc.ScrollView:create()
		tempScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
		tempScrollView:setViewSize(scoSize)
		tempScrollView:setTouchEnabled(true)
		tempScrollView:setBounceable(false)
		tempScrollView:setPosition(tempPos)
		tempScrollView:setContentSize(cc.size(scoSize.width,divHeight*colCount))
		tempScrollView:setContentOffset(cc.p(0,divHeight*(2-colCount)))
		tempScrollView:addChild(tempNode)
		mainSpr:addChild(tempScrollView)
	else
		tempNode:setPosition(tempPos)
		mainSpr:addChild(tempNode)
	end
end

function SysArrayView.Net_SYS_CHANGE( self, _ackMsg )
	local msg = _ackMsg
	print( " 系统ID===>> 	", msg.sys_id )
	print( " 可玩次数=>> 	", msg.num 	  )
	local sys_id = msg.sys_id
	local num    = msg.num
	if self.numSpr[sys_id] then
		if num <= 0 then
			self.numSpr[sys_id] : removeFromParent(true)
			self.numSpr[sys_id] = nil
		else
			local numLab = self.numSpr[sys_id] : getChildByTag(1)
			if not numLab then  return end
			local szNum=num>9 and "N" or tostring(num)
			numLab : setString( szNum )
 		end
	end
end

function SysArrayView.closeWindow(self)
	-- ScenesManger.releaseFileArray(self.m_resourcesArray)

	if self.m_rootLayer==nil then return end

	cc.Director:getInstance():popScene()
	-- self.m_rootLayer:removeFromParent(true)
	self.m_rootLayer=nil

	self:destroy()
end

function SysArrayView.removeGuideNode(self)
	if self.m_guideNode then
		self.m_guideNode:removeFromParent(true)
		self.m_guideNode=nil
	end
end
function SysArrayView.showGuideNode(self)
	if self.m_guideNode then
		self.m_guideNode:setVisible(true)
	end
end
function SysArrayView.hideGuideNode(self)
	if self.m_guideNode then
		self.m_guideNode:setVisible(false)
	end
end

return SysArrayView