--北美用户协议的面板，显示在登录面板上，覆盖登录按钮，用户必须点同意才能继续游戏
kunlunTermsDialog=smallDialog:new()
function kunlunTermsDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogWidth=550
	self.dialogHeight=400
	self.tagOffset=518
	self.titleStr={["en"]="User Notice",["fr"]="Avis d'utilisateur",["it"]="Avviso agli Utenti"}
	self.contentStr={
		["en"]="We have updated our Terms of Service and Privacy Policy in order to make it easier to be understood by our users around the world. Please review them carefully.",
		["fr"]="Nous avons mis à jour nos conditions d'utilisation et notre politique de confidentialité afin de faciliter leur compréhension pour nos utilisateurs dans le monde entier. Merci de les relire attentivement.",
		["it"]="Abbiamo aggiornato i nostri Termini di Servizio e la normativa sulla Privacy, in modo tale che siano facilmente comprensibili dai nostri utenti in tutto il mondo.\nVi preghiamo di leggerli con attenzione."
	}
	self.btnStr={["en"]="Privacy Policy",["fr"]="Politique de confidentialité",["it"]="Normativa sulla Privacy"}
	return nc
end

function kunlunTermsDialog:init(layerNum)
	self.layerNum=layerNum
	self:show()
	self.dialogLayer=CCLayer:create()

	local function nilFunc()
	end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	self.language=G_getCurChoseLanguage()
	if(self.language~="en" and self.language~="fr" and self.language~="it")then
		self.language="en"
	end
	self:initPanel()

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function kunlunTermsDialog:initPanel()
	if(self.bgLayer)then
		self.bgLayer:removeFromParentAndCleanup(true)
		self.bgLayer=nil
	end
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	local titleLb=GetTTFLabel(self.titleStr[self.language],30)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-titleLb:getContentSize().height-5))
	dialogBg:addChild(titleLb,1)

	local contentLb=GetTTFLabelWrap(self.contentStr[self.language],23,CCSizeMake(self.dialogWidth - 40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	contentLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight/2))
	dialogBg:addChild(contentLb)

	local function onClose( ... )
		CCUserDefault:sharedUserDefault():setIntegerForKey("gameHasShown",1)
		CCUserDefault:sharedUserDefault():flush()
		self:close()
	end
	local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClose,2,getlocal("confirm"),25)
	local okBtn=CCMenu:createWithItem(okItem)
	okBtn:setPosition(ccp(120,60))
	okBtn:setTouchPriority(-(self.layerNum-1)*20-3)
	dialogBg:addChild(okBtn,1)

	local function onRedirect()
		local tmpTb={}
		tmpTb["action"]="openUrl"
		tmpTb["parms"]={}
		tmpTb["parms"]["url"]="http://www.koramgame.com/?act=service.privacy"
		local cjson=G_Json.encode(tmpTb)
		G_accessCPlusFunction(cjson)
	end
	local redirectItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onRedirect,2,self.btnStr[self.language],18,nil,CCRect(30,10,102,54),CCSizeMake(200,74))
	local redirectBtn=CCMenu:createWithItem(redirectItem)
	redirectBtn:setPosition(ccp(self.dialogWidth - 120,60))
	redirectBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	dialogBg:addChild(redirectBtn,1)
end