local UISceneTest=classGc(function(self)

end)

function UISceneTest.create(self)
	self.m_rootScene=cc.Scene:create()
	self:initView()

	return self.m_rootScene
end

function UISceneTest.initView(self)
	self.m_winSize=cc.Director:getInstance():getWinSize()

	local titleLabel=_G.Util:createLabel("Spine测试-空场景",30)
	titleLabel:setPosition(self.m_winSize.width*0.5,600)
	self.m_rootScene:addChild(titleLabel,100)

	self.m_characterNode=cc.Node:create()
	self.m_rootScene:addChild(self.m_characterNode)

	local function c(sender,eventType)
		if eventType==ccui.TouchEventType.ended then
			local tag=sender:getTag()
			if tag==1 then
				self:createCharacter(1)
			elseif tag==2 then
				self:createCharacter(10)
			elseif tag==4 then
				self.m_nCount=0
				self.m_countLabel:setString(string.format("spine数量: %d",self.m_nCount))
				self.m_characterNode:removeAllChildren()
			elseif tag==3 then
				cc.Director:getInstance():popScene()
			elseif tag==5 then
				if self.m_isUseCache then
					self.m_isUseCache=false
					self.m_createTypeBtn:setTitleText("原始创建")
				else
					self.m_isUseCache=true
					self.m_createTypeBtn:setTitleText("缓存创建")
				end
			end
		end
	end

	local tempSize=cc.size(120,40)
	local tempLayer=cc.LayerColor:create(cc.c4b(200,150,0,150))
	tempLayer:setContentSize(tempSize)
	tempLayer:setPosition(0,600-tempSize.height*0.5)
	self.m_rootScene:addChild(tempLayer,100)

	self.m_lpTextField=ccui.TextField:create()
	self.m_lpTextField:setTouchEnabled(true)
	-- self.m_lpTextField:setFontName(_G.FontName.Heiti)
    self.m_lpTextField:setFontSize(18)
    self.m_lpTextField:setPlaceHolder("spine名称")
	self.m_lpTextField:setMaxLengthEnabled(true)
	self.m_lpTextField:setMaxLength(15)
	self.m_lpTextField:setAnchorPoint(cc.p(0,0.5))
	self.m_lpTextField:setPosition(0,tempSize.height*0.5)
	self.m_lpTextField:ignoreContentAdaptWithSize(false)
	self.m_lpTextField:setContentSize(tempSize)
	tempLayer:addChild(self.m_lpTextField)

	local createBtn=gc.CButton:create("general_btn_gold.png")
	createBtn:addTouchEventListener(c)
	createBtn:setPosition(tempSize.width+70,600)
	createBtn:setTitleFontSize(24)
    createBtn:setTitleText("创建")
    createBtn:setTitleFontName(_G.FontName.Heiti)
    createBtn:setTag(1)
	self.m_rootScene:addChild(createBtn,100)

	local createBtn=gc.CButton:create("general_btn_gold.png")
	createBtn:addTouchEventListener(c)
	createBtn:setPosition(tempSize.width+70*3,600)
	createBtn:setTitleFontSize(24)
    createBtn:setTitleText("创建(10)")
    createBtn:setTitleFontName(_G.FontName.Heiti)
    createBtn:setTag(2)
	self.m_rootScene:addChild(createBtn,100)

	local createBtn=gc.CButton:create("general_btn_gold.png")
	createBtn:addTouchEventListener(c)
	createBtn:setPosition(self.m_winSize.width-70,45)
	createBtn:setTitleFontSize(24)
    createBtn:setTitleText("清除")
    createBtn:setTitleFontName(_G.FontName.Heiti)
    createBtn:setTag(4)
	self.m_rootScene:addChild(createBtn,100)

	local createBtn=gc.CButton:create("general_btn_gold.png")
	createBtn:addTouchEventListener(c)
	createBtn:setPosition(self.m_winSize.width-70,600)
	createBtn:setTitleFontSize(24)
    createBtn:setTitleText("退出")
    createBtn:setTitleFontName(_G.FontName.Heiti)
    createBtn:setTag(3)
	self.m_rootScene:addChild(createBtn,100)

	self.m_createTypeBtn=gc.CButton:create("general_btn_gold.png")
	self.m_createTypeBtn:addTouchEventListener(c)
	self.m_createTypeBtn:setPosition(self.m_winSize.width-70*3,45)
	self.m_createTypeBtn:setTitleFontSize(24)
    self.m_createTypeBtn:setTitleText("缓存创建")
    self.m_createTypeBtn:setTitleFontName(_G.FontName.Heiti)
    self.m_createTypeBtn:setTag(5)
	self.m_rootScene:addChild(self.m_createTypeBtn,100)
	self.m_isUseCache=true


	self.m_countLabel=_G.Util:createLabel("spine数量: 0",22)
	self.m_countLabel:setAnchorPoint(cc.p(0,1))
	self.m_countLabel:setPosition(0,575)
	self.m_rootScene:addChild(self.m_countLabel,100)
	self.m_nCount=0
end

function UISceneTest.createCharacter(self,_count)
	local szName=self.m_lpTextField:getString()
	if szName=="" then return end

	szName=string.format("spine/%s",szName)

	if not _G.FilesUtil:check(szName..".png") then
		return
	end

	for i=1,_count do
		local tempSpine
		if self.m_isUseCache then
			tempSpine=_G.SpineManager.createSpine(szName,0.5)
		else
			tempSpine=sp.SkeletonAnimation:create(szName..".json",szName..".atlas",0.5)
		end
		if tempSpine==nil then return end
		local rX=math.random(60,self.m_winSize.width-60)
		local rY=math.random(0,400)
		tempSpine:setPosition(rX,rY)
		tempSpine:setAnimation(0,"idle",true)
		self.m_characterNode:addChild(tempSpine,-rY)

		
	end
	self.m_nCount=self.m_nCount+_count
	self.m_countLabel:setString(string.format("spine数量: %d",self.m_nCount))
end

return UISceneTest