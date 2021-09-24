local FriendView = classGc(view,function(self)
	self.TAG_FRIEND 	= _G.Const.CONST_FRIEND_FRIEND
	self.TAG_RECENT 	= _G.Const.CONST_FRIEND_RECENT
	self.TAG_SELECT 	= _G.Const.CONST_FRIEND_SEARCH
	self.TAG_WISH 		= _G.Const.CONST_FRIEND_GET_BLESS
	self.TAG_BLACKLIST 	= _G.Const.CONST_FRIEND_BLACKLIST

	self.m_mediator =require("mod.friend.FriendViewMediator")() --here??
	self.m_mediator:setView(self) --here??
end)

local tipsTable = {
	{1,"查看信息"},
	{2,"发起私聊"},
	{3,"删除好友"},
	{4,"加黑名单"},
	{5,"战力对比"},
}

local buttonText = {[_G.Const.CONST_FRIEND_FRIEND]="祝 福",[_G.Const.CONST_FRIEND_RECENT]="私 聊",
[_G.Const.CONST_FRIEND_SEARCH]="添 加",[_G.Const.CONST_FRIEND_GET_BLESS]="领 取",
[_G.Const.CONST_FRIEND_BLACKLIST]="解 除"}

local FONTSIZE = 20
local m_winSize=cc.Director:getInstance():getWinSize()
local downSize   = cc.size(610, 498)
local ldownSize   = cc.size(828, 498)
function FriendView.create( self )
	self.generalView=require("mod.general.TabLeftView")()
	self.mainLayer=self.generalView:create("好 友",true)

	local tempScene=cc.Scene:create()
 	tempScene:addChild(self.mainLayer)

	self:initView()
	return tempScene
end

function FriendView.initView( self )
	self.mainContainer = cc.Node:create()
	self.mainContainer : setPosition(cc.p(m_winSize.width/2,m_winSize.height/2))
	self.mainLayer : addChild(self.mainContainer)

	self.di2kuanSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
	self.di2kuanSpr:setPreferredSize(cc.size(617,517))
	self.di2kuanSpr:setPosition(105,-20)
	self.mainContainer:addChild(self.di2kuanSpr)

	local function closeFun()
		if self.mainLayer==nil then return end
		self.mainLayer=nil
		cc.Director:getInstance():popScene()
		self:destroy()
		self:__removeScheduler()
	end

	local function tabBtnCallBack(tag)
		print("FriendView.tabBtnCallBack--> tag=",tag)
		self:__removeScheduler()
		self:tabOperate(tag)
	end

	self.generalView:addCloseFun(closeFun)
	self.generalView:addTabFun(tabBtnCallBack)

	self.generalView:addTabButton("好 友",self.TAG_FRIEND)
	self.generalView:addTabButton("最 近 联 系",self.TAG_RECENT)
	self.generalView:addTabButton("搜 索 好 友",self.TAG_SELECT)
	self.generalView:addTabButton("领 取 祝 福",self.TAG_WISH)
	self.generalView:addTabButton("黑 名 单",self.TAG_BLACKLIST)
	
	self.currentTag = self.TAG_FRIEND
	print("here--111->",self.currentTag)
	self.generalView:selectTagByTag(self.currentTag)
	self:tabOperate(self.currentTag,true)
end

function FriendView.NetWorkSend(self,_type)
    --向服务器发送页面数据请求
    local msg = REQ_FRIEND_REQUES()
	msg : setArgs(_type)
    _G.Network : send(msg)

    local msg = REQ_FRIEND_TIME_REQUEST()
    _G.Network : send(msg)
end

function FriendView.tabOperate( self, _tag, _bool,uid)
	print("SettingView --- tag --->",_tag,_bool,uid)
	if self.currentTag == _tag and _bool == nil then
		return
	end

	self.currentTag = _tag	

	if _tag == self.TAG_FRIEND then
		self.di2kuanSpr:setPreferredSize(cc.size(617,517))
		self.di2kuanSpr:setPosition(105,-42)
		self:NetWorkSend(self.TAG_FRIEND)	
	elseif _tag == self.TAG_RECENT then
		self.di2kuanSpr:setPreferredSize(cc.size(617,517))
		self.di2kuanSpr:setPosition(105,-42)
		self:NetWorkSend(self.TAG_RECENT)
	elseif _tag == self.TAG_SELECT then
		self.di2kuanSpr:setPreferredSize(cc.size(617,517))
		self.di2kuanSpr:setPosition(105,-42)
		self:selectView()
	elseif _tag == self.TAG_WISH then
		self.di2kuanSpr:setPreferredSize(cc.size(617,517))
		self.di2kuanSpr:setPosition(105,-42)
		self:NetWorkSend(self.TAG_WISH)
	elseif _tag == self.TAG_BLACKLIST then
		self.di2kuanSpr:setPreferredSize(cc.size(617,517))
		self.di2kuanSpr:setPosition(105,-42)
		self:NetWorkSend(self.TAG_BLACKLIST)
	end
end

function FriendView.returntabid( self, _tag, _bool,uid)
	print("SettingView --- tag --->",_tag)
	if self.currentTag == _tag and _bool == nil then
		return
	end
	if _tag == self.TAG_FRIEND then
		local msg = REQ_FRIEND_TIME_REQUEST()
    	_G.Network : send(msg)
    	print("asdasdsad祝福",uid)
    	if self.m_roleCellArray[uid]==nil then return end
		self.m_roleCellArray[uid].btn:setTouchEnabled(false)
		self.m_roleCellArray[uid].btn:setBright(false)
		self.m_roleCellArray[uid].btn:setTitleText("已祝福")
	elseif _tag == self.TAG_SELECT then
		print("asdasdsad添加",uid)
		if self.m_roleCellArray[uid]==nil then return end
		self.m_roleCellArray[uid].btn:setTouchEnabled(false)
		self.m_roleCellArray[uid].btn:setBright(false)
		self.m_roleCellArray[uid].btn:setTitleText("已添加")

		self.friendNum = self.friendNum + 1
		tabString = "好 友 ("..self.onLineCount.."/"..self.friendNum..")"
		self.generalView:setTabStringByTag(self.TAG_FRIEND,tabString)
	elseif _tag == self.TAG_WISH then
		local msg = REQ_FRIEND_TIME_REQUEST()
    	_G.Network : send(msg)

		self:NetWorkSend(self.TAG_WISH)
	end
end

function FriendView.updatedata(self,_tag)
	if self.currentTag~=_tag then return end
	local itemList = _G.GFriendProxy:getDatalList(_tag)
	print("getDatalList --->",itemList)

	self:cleanTabView()
	if _tag == self.TAG_FRIEND then
		self:friendListView(itemList)
	elseif _tag == self.TAG_RECENT then
		self:recentListView(itemList)
	elseif _tag == self.TAG_SELECT then
		self:selectView()
	elseif _tag == self.TAG_WISH then
		self:wishView(itemList)
	elseif _tag == self.TAG_BLACKLIST then
		self:blackListView(itemList)
	end
end

function FriendView.createScrollView(self,_tag,_dataList)
	local Count = #_dataList

	self.oneHeight = (downSize.height-60)/5
	self.viewSize = nil

	print("createScrollView",_tag)
	if _tag == self.TAG_RECENT or _tag == self.TAG_BLACKLIST then
		self.viewSize = cc.size(downSize.width,downSize.height+10)
	else
		self.viewSize = cc.size(downSize.width,downSize.height-60)
	end
	print("createScrollView",self.viewSize.height)
	self.scrollViewSize = cc.size(downSize.width,self.oneHeight*Count-2)
	local contentView = cc.ScrollView:create()
	contentView : setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	contentView : setViewSize(self.viewSize)
	contentView : setContentSize(self.scrollViewSize)
	contentView : setContentOffset( cc.p( 0,self.viewSize.height-self.scrollViewSize.height)) -- 设置初始位置
	    
    if #_dataList>1 then
	    local function sort( data1, data2 )
	    	if data1.is_online==data2.is_online then
	    		if data1.is==data2.is then
	    			return data1.id<data2.id
	    		else
	    			return data1.is<data2.is
	    		end
	    	else
	    		return data1.is_online>data2.is_online
	    	end
		end
		table.sort( _dataList , sort )
	end
    
    self.m_roleCellArray={}

    local index=1
    local function nFun()
    	if index>Count then
    		self:__removeScheduler()
    		return
    	end

   		if _dataList[index] then 
			local itemFrame = self:createOneItem(_dataList[index],index,_tag)
	    	itemFrame:setPosition(downSize.width/2,self.scrollViewSize.height-self.oneHeight/2-self.oneHeight*(index-1))
	    	contentView:addChild(itemFrame)
	    end

    	index=index+1
    end

    local firstEnd=Count>5 and 5 or Count
    for i=1,firstEnd do
    	nFun()
    end
    self.m_mySchedule=_G.Scheduler:schedule(nFun,0)
 
    return contentView
end

function FriendView.__removeScheduler(self)
	print("关闭__removeScheduler")
	if self.m_mySchedule~=nil then
		_G.Scheduler:unschedule(self.m_mySchedule)
		self.m_mySchedule=nil
	end
end

function FriendView.createOneItem( self, _dataTable, _index,_tag)
	if _dataTable == nil then return  end
	local function testCallBack( sender,eventType )
		if eventType == ccui.TouchEventType.began then
			-- sender:setOpacity(180)
            self.myMove = sender : getWorldPosition().y
        elseif eventType == ccui.TouchEventType.ended then
            local posY = sender : getWorldPosition().y
            local move = posY - self.myMove
            print( "isMove = ", move, posY, self.myMove )
            if move > 5 or move < -5 then
                return
            end
        	-- sender:setOpacity(255)
            local Position = sender:getWorldPosition()
            local upHeight = nil
            local downHeight = nil
            if _tag == self.TAG_SELECT then
            	upHeight = m_winSize.height/2+downSize.height/2-110
            	downHeight=m_winSize.height/2-downSize.height/2-16
            else
            	upHeight = m_winSize.height/2+downSize.height/2-68
            	if _tag==self.TAG_FRIEND or _tag==self.TAG_WISH then
            		downHeight=m_winSize.height/2-downSize.height/2+24
            	else
            		downHeight=m_winSize.height/2-downSize.height/2-22
            	end
            end

            print("Position.yWid--->>>",Position.y,upHeight,downHeight)
            if Position.y>upHeight or Position.y<downHeight then
	            return
	        end
            self:createFriendTips(_dataTable)
        elseif eventType==ccui.TouchEventType.canceled then
            -- sender:setOpacity(255)
        end
	end

	local widgetTest = ccui.Button:create("general_nothis.png","general_isthis.png","general_isthis.png",1)
	print("createOneItem--->",_dataTable.id,_dataTable.name,_index)
	print("createOneItem--->",_dataTable.powerful,_dataTable.clan,_index)
	print("createOneItem--->",_dataTable.pro,_dataTable.is,_index)
	print("createOneItem--->",_dataTable.lv,_dataTable.is_online,_index)
	local widgetSize=cc.size(downSize.width-10,self.oneHeight-4)
	widgetTest:setScale9Enabled(true)
	widgetTest:setContentSize(widgetSize)
	widgetTest:setSwallowTouches(false)
 	widgetTest:addTouchEventListener(testCallBack)
	widgetTest:setTag(_index)

	local szProImg=string.format("general_role_head%d.png",_dataTable.pro)
	local playerSpr = gc.GraySprite:createWithSpriteFrameName(szProImg)
	playerSpr : setPosition(50,widgetSize.height/2)
	playerSpr : setScale(0.75)
	widgetTest:addChild(playerSpr)

	if _dataTable.is_online == 1 then
		playerSpr : setDefault()
	else
		playerSpr : setGray()
	end

	local nameLabel = _G.Util:createLabel(_dataTable.name,FONTSIZE)
	nameLabel:setPosition(275,widgetSize.height-27)
	nameLabel:setAnchorPoint(cc.p(0,0.5))
	nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
	widgetTest:addChild(nameLabel) 

	local indexLv = _dataTable.lv or 10
	local lvLabel = _G.Util:createLabel("等级:",FONTSIZE)
	lvLabel:setPosition(120,widgetSize.height-27)
	lvLabel:setAnchorPoint(cc.p(0,0.5))
	lvLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	widgetTest:addChild(lvLabel)

	local lvnumLabel = _G.Util:createLabel(indexLv,FONTSIZE)
	lvnumLabel:setPosition(175,widgetSize.height-27)
	lvnumLabel:setAnchorPoint(cc.p(0,0.5))
	lvnumLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
	widgetTest:addChild(lvnumLabel) 

	local clanString = _dataTable.clan or "暂无门派"
	local clanLabel = _G.Util:createLabel(clanString,FONTSIZE)
	clanLabel:setPosition(275,27)
	clanLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
	clanLabel:setAnchorPoint(cc.p(0,0.5))
	widgetTest : addChild(clanLabel) 

	local powerLabel = _G.Util:createLabel("战力:",FONTSIZE)
	powerLabel:setPosition(120,27)
	powerLabel:setAnchorPoint(cc.p(0,0.5))
	powerLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	widgetTest : addChild(powerLabel)

	local powernumLabel = _G.Util:createLabel(_dataTable.powerful,FONTSIZE)
	powernumLabel:setPosition(175,27)
	powernumLabel:setAnchorPoint(cc.p(0,0.5))
	powernumLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
	widgetTest : addChild(powernumLabel) 

	local function buttonCallBack(sender,eventType)
		print("buttonCallBack",sender:getTag())
		if eventType == ccui.TouchEventType.ended then
			local Position = sender:getWorldPosition()
			local upHeight=nil
			local downHeight=nil
            if _tag == self.TAG_SELECT then
            	upHeight = m_winSize.height/2+downSize.height/2-110
            	downHeight=m_winSize.height/2-downSize.height/2-16
            else
            	upHeight = m_winSize.height/2+downSize.height/2-68
            	if _tag==self.TAG_FRIEND or _tag==self.TAG_WISH then
            		downHeight=m_winSize.height/2-downSize.height/2+24
            	else
            		downHeight=m_winSize.height/2-downSize.height/2-22
            	end
            end
            print("Position.yBtn--->>>",Position.y,upHeight,downHeight)
            if Position.y>upHeight or Position.y<downHeight then
	            return
	        end
			self:itemButtonCallBack(sender,eventType,self.currentTag,_dataTable)
		end
	end 

	local itemFriendBtn = gc.CButton : create()
	itemFriendBtn:loadTextures("general_btn_gold.png")
	itemFriendBtn:setPosition(widgetSize.width-80,widgetSize.height*0.5)
	itemFriendBtn:setTitleText(buttonText[self.currentTag])
	itemFriendBtn:setTitleFontName(_G.FontName.Heiti)
	itemFriendBtn:setTitleFontSize(FONTSIZE+4)
	itemFriendBtn:setTag(_dataTable.id)
	itemFriendBtn:addTouchEventListener(buttonCallBack)
	-- itemFriendBtn:setButtonScale(0.85)
	widgetTest  :addChild(itemFriendBtn)

	print("_dataTable.is ",_dataTable.is) 
	if _dataTable.is == 1 then
		local buttonText = {[_G.Const.CONST_FRIEND_FRIEND]="已祝福",[_G.Const.CONST_FRIEND_RECENT]="私聊",
		[_G.Const.CONST_FRIEND_SEARCH]="已添加",[_G.Const.CONST_FRIEND_GET_BLESS]="已领取",
		[_G.Const.CONST_FRIEND_BLACKLIST]="解除"}
		itemFriendBtn:setTitleText(buttonText[self.currentTag])
		if self.currentTag == self.TAG_FRIEND or self.currentTag == self.TAG_SELECT or self.currentTag == self.TAG_WISH then
			itemFriendBtn:setTouchEnabled(false)
			itemFriendBtn:setBright(false)
		end
	end

	self.m_roleCellArray[_dataTable.id]={}
	self.m_roleCellArray[_dataTable.id].wid=widgetTest
	self.m_roleCellArray[_dataTable.id].btn=itemFriendBtn
	return widgetTest
end

function FriendView.itemButtonCallBack(self,sender,eventType,_type,_sendList)
	local tag = sender:getTag()
	print("itemButtonCallBack--->",tag,_type)
	if _type == self.TAG_SELECT then
		local sendList = {}
		sendList[1] = _sendList.id
		local msg = REQ_FRIEND_ADD()
		msg:setArgs(1,1,sendList)
		_G.Network:send(msg)
	elseif _type == self.TAG_FRIEND then
		local msg = REQ_FRIEND_BLESS()
		msg:setArgs(tag)
		_G.Network:send(msg)
	elseif _type == self.TAG_WISH then
		local msg = REQ_FRIEND_BLESS_GET()
		msg:setArgs(tag)
		_G.Network:send(msg)
		
	elseif _type == self.TAG_BLACKLIST then
		local sendList = {}
		sendList[1] = _sendList.id
		local msg = REQ_FRIEND_DEL()
		msg:setArgs(_sendList.id,5)
		_G.Network:send(msg)
	elseif _type == self.TAG_RECENT then
		local chatData={}
		chatData.dataType=_G.Const.kChatDataTypeSL
		chatData.chatName=_sendList.name
		chatData.chatId=_sendList.id
		_G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_CHATTING,nil,chatData)
	end
end

function FriendView.createFriendTips( self,_dataTable)
	if self.currentTag~=self.TAG_FRIEND then return end

	local containerSize = cc.size(176,335)
	self.tipsContainer = cc.LayerColor:create(cc.c4b(0,0,0,150))

	local function removeTips()
		if self.tipsContainer ~= nil then
			self.tipsContainer:removeFromParent(true)
			self.tipsContainer=nil
		end
	end

	local function onTouchCallBack( touch,sender )
		local touchPoint=touch:getStartLocation()
      	print("onTouchBegan=====>>>",touchPoint.x,touchPoint.y)
        local arPoint=self.tipSprite:getAnchorPoint()
        local forNodePos=self.tipSprite:convertToNodeSpaceAR(touchPoint)
        local touchRect=cc.rect(-arPoint.x*containerSize.width,-arPoint.y*containerSize.height,containerSize.width,containerSize.height)
        if not cc.rectContainsPoint(touchRect,forNodePos) then
        	performWithDelay(self.tipsContainer,removeTips,0.05)
        end
        return true
	end

	local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchCallBack,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)
 
    self.tipsContainer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.tipsContainer)
	self.mainLayer:addChild(self.tipsContainer,10)

	self.tipSprite = ccui.Scale9Sprite : createWithSpriteFrameName( "general_friendkuang.png" ) 
	self.tipSprite : setPreferredSize( containerSize )
	self.tipSprite : setPosition(m_winSize.width/2,m_winSize.height/2)
	self.tipsContainer : addChild(self.tipSprite)

	local act2=cc.ScaleTo:create(0.2,1.04)
	local act3=cc.ScaleTo:create(0.1,0.98)
	local act4=cc.ScaleTo:create(0.05,1)
	self.tipSprite:setScale(0.9)
	self.tipSprite:runAction(cc.Sequence:create(act2,act3,act4))

	local nameTipsLabel=_G.Util:createLabel(_dataTable.name,  FONTSIZE)
	nameTipsLabel:setPosition(containerSize.width/2,containerSize.height-30)
	nameTipsLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
	self.tipSprite:addChild(nameTipsLabel)

	local function operateBtnCallBack( sender,eventType )
		local _tag = sender:getTag()
		if eventType==ccui.TouchEventType.began then
            -- sender:setOpacity(180)
		elseif eventType == ccui.TouchEventType.ended then
			print("operateBtnCallBack --->",_tag)
			-- sender:setOpacity(255)
			if _tag~=1 and _tag~=2 and self.m_mySchedule~=nil then 
				local command = CErrorBoxCommand("数据加载中，请稍后...")
   	        	controller : sendCommand( command )
				return 
			end
			self:tipsOperateCallBack(sender,_dataTable)
			removeTips()
		elseif eventType==ccui.TouchEventType.canceled then
            -- sender:setOpacity(255)
		end
	end

	local nPosX=containerSize.width/2
	local nPosY=containerSize.height-22
	self.tipsLabel ={1,2,3,4,5}
	for i=1,5 do
		nPosY=nPosY-55
		local widgetTest=gc.CButton:create("general_btn_gray.png")
		widgetTest:setPosition(nPosX,nPosY)
		widgetTest:addTouchEventListener(operateBtnCallBack)
		widgetTest:setTag(tipsTable[i][1])   
		self.tipSprite:addChild(widgetTest) 

		widgetTest : setTitleText(tipsTable[i][2])
		widgetTest : setTitleFontSize(24)
		widgetTest : setTitleFontName(_G.FontName.Heiti)

		-- self.tipsLabel[i]=_G.Util:createLabel(tipsTable[i][2],FONTSIZE+5)
		-- self.tipsLabel[i]:setPosition(nPosX,nPosY-2)
		-- self.tipsLabel[i]:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
		-- self.tipSprite:addChild(self.tipsLabel[i]) 	
	end
end

function FriendView.tipsOperateCallBack(self,sender,tableList)
	local tag = sender:getTag()
	if tag == tipsTable[1][1] then
		_G.GLayerManager:showPlayerView(tableList.id)
	elseif tag == tipsTable[2][1] then
		local chatData={}
		chatData.dataType=_G.Const.kChatDataTypeSL
		chatData.chatName=tableList.name
		chatData.chatId=tableList.id
		_G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_CHATTING,nil,chatData)
	elseif tag == tipsTable[3][1] then
		-- del
		local msg = REQ_FRIEND_DEL()
		msg:setArgs(tableList.id,self.TAG_FRIEND)
		_G.Network:send(msg)
	elseif tag == tipsTable[4][1] then
		-- black
		local sendList = {}
		sendList[1] = tableList.id
		local msg = REQ_FRIEND_ADD()
		msg:setArgs(5,1,sendList)
		_G.Network:send(msg)
	elseif tag == tipsTable[5][1] then
		_G.GLayerManager:openLayer(_G.Cfg.UI_BattleCompareView,nil,tableList.id)
	end
end

function FriendView.cleanTabView( self )
	if self.tableView ~= nil then
		self.tableView : removeAllChildren(true)
	else
		self.tableView=cc.Node:create()
		self.tableView:setPosition(-downSize.width/2+105,-downSize.height/2-16)
		self.mainContainer:addChild(self.tableView)
	end
	self.friendTimes=nil
	self.getRewardTimes=nil
end

function FriendView.friendListView( self,friendList)
    local function editCallback(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			print(sender:getTag(),"editCallback")
			local msg = REQ_FRIEND_BLESS_ALL()
			_G.Network:send(msg)
		end
	end

	local diSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_friendbg.png")
	diSpr:setPreferredSize(cc.size(620,76))
	diSpr:setPosition(305,4)
	self.tableView   : addChild(diSpr) 

	local friendWishBtn  = gc.CButton : create()
	friendWishBtn  : loadTextures("general_btn_gold.png")
	friendWishBtn  : setTag(111)
	friendWishBtn  : setTitleText("一键祝福")
	friendWishBtn  : setTitleFontName(_G.FontName.Heiti)
	friendWishBtn  : setTitleFontSize(FONTSIZE+2)
	--friendWishBtn  : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
	friendWishBtn  : addTouchEventListener(editCallback)
	friendWishBtn  : setPosition(downSize.width-90,0)
	self.tableView   : addChild(friendWishBtn,10)

	local friendLab =  _G.Util:createLabel("剩余祝福次数:",  FONTSIZE+4)
	-- friendLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	friendLab : setPosition(130,0)
	friendLab : setAnchorPoint(cc.p(0,0.5))
	self.tableView   : addChild(friendLab,1) 

	local labWidth=friendLab:getContentSize().width
	self.friendTimes =  _G.Util:createLabel("",  FONTSIZE+4)
	self.friendTimes : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GREEN))
	self.friendTimes : setPosition(135+labWidth,0)
	self.friendTimes : setAnchorPoint(cc.p(0,0.5))
	self.tableView   : addChild(self.friendTimes) 

    local friListView = self : createScrollView(self.TAG_FRIEND,friendList)
    friListView : setPosition(0,38)
    self.tableView : addChild(friListView)
    if self.viewSize.height < self.scrollViewSize.height then
	    local barView=require("mod.general.ScrollBar")(friListView)
		barView:setPosOff(cc.p(-4,0))
	end

	local Count = #friendList
	print("houzi ",_wishList)
	if Count==0 then
		local nohaveSpr1 = cc.Sprite:createWithSpriteFrameName("general_monkey.png")
		nohaveSpr1 : setPosition(downSize.width/2,downSize.height/2+20)
		self.tableView : addChild(nohaveSpr1)

		local tipsLab1 = _G.Util : createLabel("暂无好友", FONTSIZE)
		tipsLab1 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN))
		tipsLab1 : setPosition(downSize.width/2,downSize.height/2-50)
		self.tableView : addChild(tipsLab1)
	end

    local tabString = "好 友 0/0"
    if friendList ~= nil then
	    self.onLineCount = 0
	    for i,v in ipairs(friendList) do
	    	print(i,v.is_online)
	    	if v.is_online == 1 then
	    		self.onLineCount = self.onLineCount+1
	    	end
	    end
	    self.friendNum = #friendList
	    print("self.onLineCount --->",self.onLineCount,#friendList)
	    tabString = "好 友 ("..self.onLineCount.."/"..(#friendList)..")"
	end
    
    self.generalView:setTabStringByTag(self.TAG_FRIEND,tabString)
end

function FriendView.setLeftTime( self, _leftTime )
	local zhuNum=_G.Const.CONST_FRIEND_BLESS_MAX-(_leftTime or 0)
	local lingNum=_G.Const.CONST_FRIEND_BLESSED_MAX-(_leftTime or 0)
	if self.friendTimes ~= nil then
		local leftString = zhuNum.."/".._G.Const.CONST_FRIEND_BLESS_MAX
		print("setLeftTime --->",leftString)
		self.friendTimes:setString(leftString)
	end

	if self.getRewardTimes ~= nil then
		local leftString = lingNum.."/".._G.Const.CONST_FRIEND_BLESSED_MAX
		print("setLeftTime --->",leftString)
		self.getRewardTimes:setString(leftString)
	end
end

function FriendView.recentListView( self, _recentList)
    local friListView = self : createScrollView(self.TAG_RECENT,_recentList)
    friListView : setPosition(0,-31)
    self.tableView : addChild(friListView)
    if self.viewSize.height < self.scrollViewSize.height then
	    local barView=require("mod.general.ScrollBar")(friListView)
		barView:setPosOff(cc.p(-4,0))
	end
	local Count = #_recentList
	print("houzi ",_wishList)
	if Count==0 then
		local nohaveSpr1 = cc.Sprite:createWithSpriteFrameName("general_monkey.png")
		nohaveSpr1 : setPosition(downSize.width/2,downSize.height/2+20)
		self.tableView : addChild(nohaveSpr1)

		local tipsLab1 = _G.Util : createLabel("暂无联系人", FONTSIZE)
		tipsLab1 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN))
		tipsLab1 : setPosition(downSize.width/2,downSize.height/2-50)
		self.tableView : addChild(tipsLab1)
	end
end

function FriendView.selectView( self, friendList)
	self:cleanTabView()

	local wordLabel=_G.Util:createLabel("请输入玩家名",FONTSIZE)
    wordLabel:setPosition(cc.p(85,downSize.height-51))
    -- wordLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    self.tableView:addChild(wordLabel,11)

    local diSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_friendbg.png")
	diSpr:setPreferredSize(cc.size(620,76))
	diSpr:setPosition(305,downSize.height-55)
	diSpr:setRotation(180)
	self.tableView   : addChild(diSpr) 

    local function selectCallBack(sender,eventType)
    	if eventType == ccui.TouchEventType.ended then
    		if self.m_filterLabel==nil then
    			self.m_filterLabel=_G.Util:createLabel("",10)
    			self.mainLayer:addChild(self.m_filterLabel)
    		end

    		local itemString = self.m_textField:getText()
    		gcprint("selectCallBack --->",itemString)

    		if self.m_filterLabel.isHasUnDefineChar then
		        local isNameHasUndefineChar=self.m_filterLabel:isHasUnDefineChar(itemString)
		        if isNameHasUndefineChar then
		            local command=CErrorBoxCommand("角色名不能含有表情或特殊符号")
		            _G.controller:sendCommand(command)
		            return
		        end
		    end

    		local tag = sender:getTag()
    		if tag==1111 then
				local msg = REQ_FRIEND_SEARCH_ADD()
				msg:setArgs(itemString)
				_G.Network:send(msg)
			elseif self.m_mySchedule==nil then
				local msg = REQ_FRIEND_GET_FRIEND()
				_G.Network:send(msg)
			end
    	end
    end

    local selectButton=gc.CButton:create()
    selectButton:loadTextures("general_btn_gold.png")
    selectButton:setPosition(downSize.width/2+103,downSize.height-50)
    selectButton:setTitleText("搜 索")
    -- selectButton:setButtonScale(0.85)
	selectButton:setTitleFontName(_G.FontName.Heiti)
    selectButton:setTitleFontSize(FONTSIZE+2)
    selectButton:addTouchEventListener(selectCallBack)
    selectButton:setTag(1111)
    self.tableView:addChild(selectButton)

    local nominateBtn=gc.CButton:create()
    nominateBtn:loadTextures("general_btn_gold.png")
    nominateBtn:setPosition(downSize.width-70,downSize.height-50)
    nominateBtn:setTitleText("推荐好友")
    -- nominateBtn:setButtonScale(0.85)
	nominateBtn:setTitleFontName(_G.FontName.Heiti)
    nominateBtn:setTitleFontSize(FONTSIZE+2)
    nominateBtn:addTouchEventListener(selectCallBack)
    nominateBtn:setTag(1112)
    self.tableView:addChild(nominateBtn)

 	local contentSpri  = ccui.Scale9Sprite : createWithSpriteFrameName( "general_gold_floor.png" ) 
	self.m_textField=ccui.EditBox:create(cc.size(180,35),contentSpri)
    self.m_textField:setPosition(downSize.width/2-60,downSize.height-50)
    self.m_textField:setFont(_G.FontName.Heiti,FONTSIZE)
    self.m_textField:setPlaceholderFont(_G.FontName.Heiti,FONTSIZE)
    self.m_textField:setPlaceHolder("请输入角色名")
    self.m_textField:setMaxLength(6)
    self.m_textField:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.tableView:addChild(self.m_textField,11)

	if friendList~=nil then
		self:setSelectList(friendList)
	end
end

function FriendView.setSelectList( self, _dataList)
	-- if self.tableView:getChildByTag(2269) then
	-- 	self.tableView:removeChildByTag(2269)
	-- end
    local friListView = self : createScrollView(self.TAG_SELECT,_dataList)
	friListView : setPosition(0,-30)
    self.tableView : addChild(friListView)
    if self.viewSize.height < self.scrollViewSize.height then 
	    local barView=require("mod.general.ScrollBar")(friListView)
		barView:setPosOff(cc.p(-4,0))
	end

	local Count = #_dataList
	print("houzi ",Count)
	if Count==0 then
		local nohaveSpr1 = cc.Sprite:createWithSpriteFrameName("general_monkey.png")
		nohaveSpr1 : setPosition(downSize.width/2,downSize.height/2+20)
		self.tableView : addChild(nohaveSpr1)

		local tipsLab1 = _G.Util : createLabel("暂无搜索玩家", FONTSIZE)
		tipsLab1 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN))
		tipsLab1 : setPosition(downSize.width/2,downSize.height/2-50)
		self.tableView : addChild(tipsLab1)
	end
end

function FriendView.wishView( self,_wishList)
	-- self.tableView cc.size(776,412)
    local function editCallback(sender,eventType)
		print(sender:getTag(),"editCallback")
		if eventType == ccui.TouchEventType.ended then
			local msg = REQ_FRIEND_BLESS_GET_ALL()
			_G.Network:send(msg)
		end
	end

	local diSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_friendbg.png")
	diSpr:setPreferredSize(cc.size(620,76))
	diSpr:setPosition(305,4)
	self.tableView   : addChild(diSpr) 

	local friendWishBtn  = gc.CButton : create()
	friendWishBtn  : loadTextures("general_btn_gold.png")
	friendWishBtn  : setTag(111)
	friendWishBtn  : setTitleText("一键领取")
	friendWishBtn  : setTitleFontName(_G.FontName.Heiti)
	friendWishBtn  : setTitleFontSize(FONTSIZE+2)
	--friendWishBtn  : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
	friendWishBtn  : addTouchEventListener(editCallback)
	friendWishBtn  : setPosition(downSize.width-90,0)
	self.tableView   : addChild(friendWishBtn,10)

	local RewardLab =  _G.Util:createLabel("剩余领取次数:",  FONTSIZE+4)
	-- RewardLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	RewardLab:setPosition(130,0)
	RewardLab:setAnchorPoint(cc.p(0,0.5))
	self.tableView   : addChild(RewardLab,1) 

	local labWidth=RewardLab:getContentSize().width
	self.getRewardTimes =  _G.Util:createLabel("",  FONTSIZE+4)
	self.getRewardTimes:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GREEN))
	self.getRewardTimes:setPosition(135+labWidth,0)
	self.getRewardTimes:setAnchorPoint(cc.p(0,0.5))
	self.tableView   : addChild(self.getRewardTimes) 

	local Count = #_wishList
	print("houzi ",_wishList)
	if Count==0 then
		local nohaveSpr1 = cc.Sprite:createWithSpriteFrameName("general_monkey.png")
		nohaveSpr1 : setPosition(downSize.width/2,downSize.height/2+20)
		self.tableView : addChild(nohaveSpr1)

		local tipsLab1 = _G.Util : createLabel("暂无好友祝福", FONTSIZE)
		tipsLab1 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN))
		tipsLab1 : setPosition(downSize.width/2,downSize.height/2-50)
		self.tableView : addChild(tipsLab1)
	else
		local friListView = self : createScrollView(self.TAG_WISH,_wishList)
	    friListView : setPosition(0,38)
	    self.tableView : addChild(friListView)
	    if self.viewSize.height < self.scrollViewSize.height then
		    local barView=require("mod.general.ScrollBar")(friListView)
			barView:setPosOff(cc.p(-4,0))
		end
	end
end

function FriendView.returnTimes( self,fourNum)
	print("returnTimes",fourNum)
	self.generalView:setTagIconNum(4,fourNum)
end

function FriendView.blackListView( self,_blackList)
    local friListView = self : createScrollView(self.TAG_BLACKLIST,_blackList)
    friListView : setPosition(0,-31)
    self.tableView : addChild(friListView)
    if self.viewSize.height < self.scrollViewSize.height then
	    local barView=require("mod.general.ScrollBar")(friListView)
		barView:setPosOff(cc.p(-4,0))
	end

	local Count = #_blackList
	print("houzi ",_wishList)
	if Count==0 then
		local nohaveSpr1 = cc.Sprite:createWithSpriteFrameName("general_monkey.png")
		nohaveSpr1 : setPosition(downSize.width/2,downSize.height/2+20)
		self.tableView : addChild(nohaveSpr1)

		local tipsLab1 = _G.Util : createLabel("暂无黑名玩家", FONTSIZE)
		tipsLab1 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN))
		tipsLab1 : setPosition(downSize.width/2,downSize.height/2-50)
		self.tableView : addChild(tipsLab1)
	end
end

function FriendView.__showWaitPKView(self)
	-- self.tipSprite:setVisible(false)
	P_VIEW_SIZE=cc.size(292,170)
	P_MID_X=P_VIEW_SIZE.width*0.5

	if self.kuangSpr~=nil then return end

	self.kuangSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
	-- self.kuangSpr:setPosition(P_VIEW_SIZE.width/2,P_VIEW_SIZE.height/2-17)
	self.kuangSpr:setPreferredSize(P_VIEW_SIZE)
	self.mainContainer:addChild(self.kuangSpr)

	self.clipNode=cc.ClippingNode:create()
	self.clipNode:setInverted(false)
	self.kuangSpr:addChild(self.clipNode,-1)

	local dinSize=cc.size(307,222)
	local m_frameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_tips_dins.png")
	m_frameSpr:setPreferredSize(dinSize)
	m_frameSpr:setPosition(P_VIEW_SIZE.width/2, P_VIEW_SIZE.height/2+17)
	self.clipNode:addChild(m_frameSpr)

	local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
	tipslogoSpr : setPosition(dinSize.width/2-125, dinSize.height-30)
	self.clipNode : addChild(tipslogoSpr)

	local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
	tipslogoSpr : setPosition(dinSize.width/2+120, dinSize.height-30)
	tipslogoSpr:setRotation(180)
	self.clipNode : addChild(tipslogoSpr)

	self.clipNode:setStencil(m_frameSpr)

	-- local logoSize = tipslogoSpr:getContentSize()
	local logoLab= _G.Util : createBorderLabel("切磋请求", 20,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	logoLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
	logoLab : setPosition(dinSize.width/2, dinSize.height-32)
	self.kuangSpr : addChild(logoLab)

	local noticLabel=_G.Util:createLabel("等待对方响应",24)
	noticLabel:setPosition(P_MID_X,P_VIEW_SIZE.height-30)
	self.kuangSpr:addChild(noticLabel)

	local tempX=P_MID_X-15
	local tempY=P_VIEW_SIZE.height*0.5
	local tempLabel=_G.Util:createLabel("邀请倒计时:",20)
	tempLabel:setPosition(tempX,tempY)
	self.kuangSpr:addChild(tempLabel)

	local waitTimes=30
	local tempSize=tempLabel:getContentSize()
	self.m_waitPKTimesLabel=_G.Util:createLabel(tostring(waitTimes),20)
	self.m_waitPKTimesLabel:setAnchorPoint(cc.p(0,0.5))
	self.m_waitPKTimesLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
	self.m_waitPKTimesLabel:setPosition(tempX+tempSize.width*0.5+5,tempY)
	self.kuangSpr:addChild(self.m_waitPKTimesLabel)

	local function c(sender,eventType)
    	if eventType==ccui.TouchEventType.ended then
    		self:__hideWaitPKView()
    	end
    end
    local tempBtn=gc.CButton:create("general_btn_gold.png")
	tempBtn:addTouchEventListener(c)
	tempBtn:setPosition(P_MID_X,30)
	tempBtn:setTitleFontName(_G.FontName.Heiti)
	tempBtn:setTitleText("取 消")
	tempBtn:setTitleFontSize(24)
	tempBtn:setButtonScale(0.85)
	self.kuangSpr:addChild(tempBtn)

	self.m_waitPKTimes=_G.TimeUtil:getTotalSeconds()+waitTimes

	self:__runTimesScheduler()
end
function FriendView.__hideWaitPKView(self)
	if self.kuangSpr~=nil then
		self.kuangSpr:removeFromParent(true)
		self.kuangSpr=nil
	end
	self.m_waitPKTimes=nil
	self.m_waitPKTimesLabel=nil

	-- self.m_infoNode:setVisible(true)

	self:__removeTimesScheduler()

	local msg=REQ_WAR_PK_CANCEL()
   	_G.Network:send(msg)
end

function FriendView.__runTimesScheduler(self)
	if self.m_timesScheduler then return end

	local nTimeUtil=_G.TimeUtil
	local function onSchedule()
		local curTime=nTimeUtil:getTotalSeconds()
		local subTime=self.m_waitPKTimes-curTime
		local szTimes=tostring(subTime)
		self.m_waitPKTimesLabel:setString(szTimes)

		if subTime<=0 then
			self:__hideWaitPKView()
		end
	end

	self.m_timesScheduler=_G.Scheduler:schedule(onSchedule,1)
end
function FriendView.__removeTimesScheduler(self)
	if self.m_timesScheduler~=nil then
		_G.Scheduler:unschedule(self.m_timesScheduler)
		self.m_timesScheduler=nil
	end
end

return FriendView