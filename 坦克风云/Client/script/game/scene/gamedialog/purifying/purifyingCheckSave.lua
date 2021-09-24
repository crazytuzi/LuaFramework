purifyingCheckSave=smallDialog:new()

function purifyingCheckSave:new(parent,flag)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.parentDialog = parent
    self.flag=flag
    self.dialogHeight=400
    self.dialogWidth=600

    self.parent=nil
    self.data=nil
    self.type=0     --是配件还是碎片
    return nc
end

function purifyingCheckSave:init(layerNum,parent,titleStr,contentStr,callback)
	self.layerNum=layerNum
    self.parent=parent  

    local function nilFunc()
	end

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168,86,10,10),nilFunc)
    self.dialogLayer=CCLayer:create()

    local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
    self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
    self.dialogLayer:setBSwallowsTouches(true);

    if titleStr~=nil then
        if G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="thai"  or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage()=="pt" or G_getCurChoseLanguage()=="fr" then
          self.titleLabel = GetTTFLabelWrap(titleStr,33,CCSizeMake(dialogBg:getContentSize().width-220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
        else
          self.titleLabel = GetTTFLabel(titleStr,40)
        end
        self.titleLabel:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height-40))
        dialogBg:addChild(self.titleLabel,2);
     end

    local function close()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0,0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
         
	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
	dialogBg:addChild(self.closeBtn)

	--遮罩层
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local tipLb  
    if contentStr then
        tipLb=GetTTFLabelWrap(contentStr,25,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    else
        tipLb=GetTTFLabelWrap(getlocal("purifying_save_tip"),25,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    end
    tipLb:setAnchorPoint(ccp(0.5,1))
    tipLb:setPosition(dialogBg:getContentSize().width/2,240)
    dialogBg:addChild(tipLb)

	local function touchOkBtn()
		if G_checkClickEnable()==false then
                  do
                      return
                  end
            else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
		PlayEffect(audioCfg.mouseClick)
        if contentStr then
            socketHelper:accessoryPurifyingSave(1,callback)
            self:close()
        else
            self:close()
            if self.flag then
                for k,v in pairs(self.parentDialog.changeTypeLb) do
                    v:removeFromParentAndCleanup(true)
                end
                if self.parentDialog.gsAddLb then
                    self.parentDialog.gsAddLb:removeFromParentAndCleanup(true)
                end
                self.parentDialog.saveItem:setEnabled(false)
                self.parentDialog.changeTypeLb=nil
                self.parentDialog.changeTypeTb=nil
                self.parentDialog.gsAddLb=nil
                require "luascript/script/game/scene/gamedialog/purifying/begingPurifyingDialog"
                local td=begingPurifyingDialog:new(self.parentDialog,self.parentDialog.data,"p"..self.parentDialog.partID,"t"..self.parentDialog.tankID)
                local tbArr={}
                local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("begin_purifying"),true,self.parentDialog.layerNum+1)
                sceneGame:addChild(dialog,self.parentDialog.layerNum+1)
            else
                self.parentDialog:purifyingClose()
            end
        end
		
		
		
	end
	local btnOkItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchOkBtn,nil,getlocal("confirm"),25)
	btnOkItem:setAnchorPoint(ccp(0.5,0))
	local okBtn=CCMenu:createWithItem(btnOkItem);
	okBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	okBtn:setPosition(ccp(dialogBg:getContentSize().width/2-150,30))
	dialogBg:addChild(okBtn)

	local function touchCancelBtn()
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
	local btnCancelItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchCancelBtn,nil,getlocal("cancel"),25)
	btnCancelItem:setAnchorPoint(ccp(0.5,0))
	local cancelBtn=CCMenu:createWithItem(btnCancelItem);
	cancelBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	cancelBtn:setPosition(ccp(dialogBg:getContentSize().width/2+150,30))
	dialogBg:addChild(cancelBtn)


    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
   

end


