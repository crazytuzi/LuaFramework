--require "luascript/script/componet/commonDialog"
enterServerDialog=commonDialog:new()

function enterServerDialog:new(tabType,layerNum,isGuide)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil


    self.layerNum=layerNum
   
    return nc
end

--设置对话框里的tableView
function enterServerDialog:initTableView()

	local textStr1 = CCUserDefault:sharedUserDefault():getStringForKey("customServer1")
	local textStr2 = CCUserDefault:sharedUserDefault():getStringForKey("customServer2")
	local textStr3 = CCUserDefault:sharedUserDefault():getStringForKey("customServer3")
	local textStr4 = CCUserDefault:sharedUserDefault():getStringForKey("customServer4")
	local textStr5 = CCUserDefault:sharedUserDefault():getStringForKey("customServer5")

	local function callBackUserNameHandler1(fn,eB,str,type)
		textStr1=str
    end
    local function callBackUserNameHandler2(fn,eB,str,type)
    	textStr2=str
    end
    local function callBackUserNameHandler3(fn,eB,str,type)
    	textStr3=str
    end
    local function callBackUserNameHandler4(fn,eB,str,type)
    	textStr4=str
    end
    local function callBackUserNameHandler5(fn,eB,str,type)
    	textStr5=str
    end

	local tb={
	{text="入口机域名",callBack=callBackUserNameHandler1,text2=textStr1},
	{text="本服域名",callBack=callBackUserNameHandler2,text2=textStr2},
	{text="服编号",callBack=callBackUserNameHandler3,text2=textStr3},
	{text="游戏端口",callBack=callBackUserNameHandler4,text2=textStr4},
	{text="聊天端口",callBack=callBackUserNameHandler5,text2=textStr5},

	}
	local size=CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height)
	local function tthandler()
    
    end

	for k,v in pairs(tb) do

		local titleLb=GetTTFLabel(v.text,30)
		titleLb:setAnchorPoint(ccp(0,0.5))
		titleLb:setPosition(ccp(30,size.height-100-100*k))
		self.bgLayer:addChild(titleLb)

		local accountBox=LuaCCScale9Sprite:createWithSpriteFrameName("LegionInputBg.png",CCRect(10,10,1,1),tthandler)
	    accountBox:setContentSize(CCSize(340,60))
	    accountBox:setPosition(ccp(size.width/2+80,size.height-100-100*k))
	    self.bgLayer:addChild(accountBox)

	    local lbSize=25
	    
	    local targetBoxLabel=GetTTFLabel(v.text2,lbSize)
	    targetBoxLabel:setAnchorPoint(ccp(0,0.5))
	    targetBoxLabel:setPosition(ccp(10,accountBox:getContentSize().height/2))
	    local customEditAccountBox=customEditBox:new()
	    local length=30
	    customEditAccountBox:init(accountBox,targetBoxLabel,"inputNameBg.png",nil,-(self.layerNum-1)*20-4,length,v.callBack,nil,nil)


	end

	local function ok()
		print("textStr1=",textStr1,textStr2,textStr3,textStr4,textStr5)
		CCUserDefault:sharedUserDefault():setStringForKey("customServer1",textStr1)
		CCUserDefault:sharedUserDefault():setStringForKey("customServer2",textStr2)
		CCUserDefault:sharedUserDefault():setStringForKey("customServer3",textStr3)
		CCUserDefault:sharedUserDefault():setStringForKey("customServer4",textStr4)
		CCUserDefault:sharedUserDefault():setStringForKey("customServer5",textStr5)
		CCUserDefault:sharedUserDefault():flush()
        loginScene:enterServerInfo()
		self:close()
	end

	local okBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",ok,0,"保存",28)
    local menuAward=CCMenu:createWithItem(okBtn)
    menuAward:setPosition(ccp(size.width/2,100))
    menuAward:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(menuAward)

	
    

    
end


--用户处理特殊需求,没有可以不写此方法
function enterServerDialog:doUserHandler()

end



function enterServerDialog:tick()

    
end

function enterServerDialog:dispose()
    self=nil
end




