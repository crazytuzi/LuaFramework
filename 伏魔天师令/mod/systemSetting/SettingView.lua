local SettingView = classGc(view,function( self )

	self.m_winSize=cc.Director:getInstance():getWinSize()
	self.m_viewSize = cc.size(854,640)

	self.FONTSIZE = 20

	self.SYSTEMSET 	= 1
	self.GAMENOTICE = 2
	self.WEIXINTAG 	= 3
	self.UPDATEBUG 	= 4

	self.is_Create = { SYSTEMSET = true, GAMENOTICE = true, WEIXINTAG = true, UPDATEBUG = true }
	self.m_tabView = {}

	self.m_mediator = require("mod.systemSetting.SettingViewMediator")() 
	self.m_mediator:setView(self) 

	self.m_webView = {}
end)
-- 一共多少个设置，目前：系统设置、游戏公告、绑定微信、反馈bug
local systemSum 	= 4  

local checkBoxChoice   = {} 
local checkBoxChoice_2 = {}

function SettingView.create( self )
	self.askMsg = {}

	self.m_settingView = require("mod.general.TabLeftView")()
	self.sysSetLabel = self.m_settingView:create(1)
	self.m_settingView : setTitle( "设 置" )

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.sysSetLabel)
	
	self:init()

	print( "－－－－－开始调用发送－－－－－" )
	self:REQ_SYS_SET_WX_ASK()
	print( "------self.askMsg.state = ", self.askMsg.state )

	return tempScene
end



function SettingView.init( self )

	--  开始就接收发来的消息
	local ListArr = _G.GSystemProxy:getSysSettingList()
	print( "dsfds,ListArr[4].type", ListArr[4].type, ListArr[4].state )
	for i,v in ipairs(ListArr) do
		if v.type == 101 then
			checkBoxChoice[1]    = v.state 
			checkBoxChoice_2[1]  = v.state
		elseif v.type == 102 then
			checkBoxChoice[2]    = v.state 
			checkBoxChoice_2[2]  = v.state
		elseif v.type == 103 then
			checkBoxChoice[5]    = v.state 
			checkBoxChoice_2[5]  = v.state
		elseif v.type == 105 then
			checkBoxChoice[3]    = v.state 
			checkBoxChoice_2[3]  = v.state
		elseif v.type == 106 then 
			checkBoxChoice[4]    = v.state 
			checkBoxChoice_2[4]  = v.state
		end
		print(i,v.type)
		print(i,v.state)
	end


	self.mainContainer = cc.Node:create()
	self.mainContainer : setPosition(cc.p(self.m_winSize.width/2 + 86,self.m_winSize.height/2))
	self.sysSetLabel : addChild(self.mainContainer,11)

	local upSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_daybg.png")
	upSpr : setPreferredSize( cc.size(627,55) )
	upSpr : setPosition(24,188)
	self.mainContainer: addChild(upSpr)

	local closeBtn = self.m_settingView:getCloseBtn()

	-- local frameSpri  = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double2.png" ) 
	-- frameSpri : setPreferredSize( cc.size(550,430) )
	-- frameSpri : setPosition(cc.p(45,-23))
	-- self.mainContainer: addChild(frameSpri,-1)

	local function closeFunSetting()
		self : SendCheck() -- 关闭前发送的代码
		self:closeWindow()
	end

	local function tabOfFun(tag)
		self:tabOperate(tag)
	end

	self.m_settingView:addCloseFun(closeFunSetting)
	self.m_settingView:addTabFun(tabOfFun)
	self.m_settingView:addTabButton("系 统 设 置",self.SYSTEMSET)
	self.m_settingView:addTabButton("游 戏 公 告",self.GAMENOTICE)

	local channelId=gc.SDKManager:getInstance():getSDKChannel()
	print("AAAAAAAAAAAAAAAAA==========>>>>",channelId)
	-- if channelId~="001145" then
	-- 	-- 金立应用商店(网游) 渠道不需要【绑定微信】模块
	-- 	self.m_settingView:addTabButton("绑 定 微 信",self.WEIXINTAG)
	-- end
	self.m_settingView:addTabButton("反 馈 BUG",self.UPDATEBUG)

	local leftBtn     = {}	
	self.leftbtnImg   = {}
	for i=1,4 do	
		leftBtn[i] = self.m_settingView:getObjByTag(i)
	end

	-- 默认页面
	self.m_settingView : selectTagByTag(self.SYSTEMSET)
	self:systemView()
end

function SettingView.tabOperate( self, _tag )
	print("SettingView --- tag --->",_tag)
	for i=1,2 do
		if self.m_webView[i] ~= nil then
			self.m_webView[i] : setVisible( false )
		end
	end
	if self.myBugView then
		self.myBugView : setVisible( false )
	end

	if _tag == self.SYSTEMSET then
		self:systemView()
	elseif _tag == self.GAMENOTICE then
		self:gameNoticeView()
	elseif _tag == self.UPDATEBUG then
		self:updateBugView()
	elseif _tag == self.WEIXINTAG then
		self:weixinView()
	end
end

function SettingView.cleanTabView( self )
	if self.m_tabView ~= nil then
		self.m_tabView : removeAllChildren(true)
	else
		self.m_tabView=ccui.Layout:create()
		self.mainContainer:addChild(self.m_tabView)
	end
end

function SettingView.CreateTabView( self, num )
	for i=1,systemSum do
		if (self.m_tabView[i] ~= nil) and (i ~= num) then
			self.m_tabView[i] : setVisible( false )
		elseif (self.m_tabView[i] == nil) and (i == num) then
			self.m_tabView[i]  = ccui.Layout : create()
			self.mainContainer : addChild( self.m_tabView[i] )
		elseif (self.m_tabView[i] ~= nil) and (i == num) then
			self.m_tabView[i] : setVisible( true )
		end
	end
end

function SettingView.weixinView( self )

	self:CreateTabView( self.WEIXINTAG )
	if self.is_Create.WEIXINTAG == true then 
		self.is_Create.WEIXINTAG = false
		print( "--------------微信----------------" )

		local function weixinCallBack(sender,eventType )
			local tag = sender:getTag()
			if eventType == ccui.TouchEventType.ended then
				if tag == 55 then
					print( "－－－－进入复制代码－－－－" )
					_G.SysInfo:setBoardCopyString(self.m_szWXNumber)
					self : createCopyWord()
				end
				if tag == 66 then
					print( "create here" )
					self : createWeixinTips()
				end
				if tag == 77 then 
					print( "－－－－进入领取奖励－－－－" )
					self : GoodTake()
				end
				if tag == 88 then 
					print( "－－－进入复制绑定串码－－－" )
					if self.m_szBDMString~=nil then
						_G.SysInfo:setBoardCopyString(self.m_szBDMString)
						self : createbindCode()
					end
				end
			end
		end


		local tabTitleLabel = _G.Util:createLabel("绑定微信",self.FONTSIZE+10)
		tabTitleLabel:setPosition(cc.p(35,190))
		-- tabTitleLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
		self.m_tabView[self.WEIXINTAG]:addChild(tabTitleLabel)

		self.m_szWXNumber="xyxmjgames"
		local wordLabel1 = _G.Util:createLabel("1.添加微信帐号："..self.m_szWXNumber,self.FONTSIZE)
		wordLabel1:setPosition(cc.p(-250,100))
		wordLabel1:setAnchorPoint(cc.p(0,0.5))
		-- wordLabel1:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
		self.m_tabView[self.WEIXINTAG]:addChild(wordLabel1)

		local copyWordBtn = gc.CButton:create("general_btn_lv.png")
		copyWordBtn : setTitleText("复制微信号")
		copyWordBtn : setTitleFontName(_G.FontName.Heiti)
		copyWordBtn : setTitleFontSize(self.FONTSIZE+2)
		copyWordBtn : addTouchEventListener(weixinCallBack)
		copyWordBtn : setTag(55)
		copyWordBtn : setPosition(cc.p(110,100))
		self.m_tabView[self.WEIXINTAG] : addChild(copyWordBtn)

		local showCodeBtn = gc.CButton:create("general_btn_gold.png")
		showCodeBtn : setTitleText("二维码")
		showCodeBtn : setTitleFontName(_G.FontName.Heiti)
		showCodeBtn : setTitleFontSize(self.FONTSIZE+2)
		showCodeBtn : addTouchEventListener(weixinCallBack)
		showCodeBtn : setTag(66)
		showCodeBtn : setPosition(cc.p(250,100))
		self.m_tabView[self.WEIXINTAG] : addChild(showCodeBtn)

		local layout = ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
		layout:setPosition( cc.p( -40, -25 ) ) 
		layout:setPreferredSize( cc.size( 370, 96 ))
		self.m_tabView[self.WEIXINTAG] : addChild(layout)

		local m_winSize   = cc.Director:getInstance():getVisibleSize()
		local rightbgSize = cc.size(605, 437)
		local downbgSize  = cc.size(605, 392)
		local oneSize     = cc.size(605, 96)

	    local function iconSprCallBack(sender, eventType)
	    	print( "－－－－－－－按了图片－－－－－－－－" )
	        if eventType == ccui.TouchEventType.ended then
	            local role_tag  = sender : getTag()
	            local Position  = sender : getWorldPosition()
	            local _pos      = {}
	            _pos.x          = Position.x
	            _pos.y          = Position.y
	            print("－－－－选中role_tag:", role_tag)
	            print("－－－－Position.y",Position.y)
	            if _pos.y > m_winSize.height/2+downbgSize.height/2-40 or _pos.y < m_winSize.height/2-rightbgSize.height/2-25 then return end
	            if role_tag <= 0 then return end
	            local temp = _G.TipsUtil : createById(role_tag,nil,_pos,0)
	            cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
	        end 
	    end

		-- 设置 奖励物品
		local good_id = _G.Cfg.weixin[1].goods
		local time = 0
		self.relewid	 = {}
		for i,v in ipairs( good_id ) do
			local goodnode   = _G.Cfg.goods[ v[1] ]
			local m_iconSpr  = {}

			-- 增加 Widge
			self.relewid[ time+1 ] = gc.CButton:create("general_tubiaokuan.png")
			-- self.relewid[ time+1 ] : setContentSize( 80, 80 ) 
	 		self.relewid[ time+1 ] : setPosition( -170 + time*130, -167  )
			self.relewid[ time+1 ] : setTouchEnabled( true )
			self.relewid[ time+1 ] : setSwallowTouches( false )
			self.relewid[ time+1 ] : setTag( goodnode.icon )
			self.relewid[ time+1 ] : addTouchEventListener( iconSprCallBack )
			self.m_tabView[self.WEIXINTAG] 	  : addChild( self.relewid[ time+1 ] )

			if goodnode ~= nil then
		    	m_iconSpr[ time+1 ] = _G.ImageAsyncManager:createGoodsSpr(goodnode,v[2])
	 	    	m_iconSpr[ time+1 ] : setPosition ( 78/2, 78/2 )
	 	    	self.relewid[ time+1 ] : addChild( m_iconSpr[time + 1] )
	 	    	-- 增加label
	 	    	-- local good_numlabel = _G.Util : createLabel( v[2], self.FONTSIZE )
	 	    	-- good_numlabel : setAnchorPoint( 1,0 )
	 	    	-- good_numlabel : setColor ( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_WHITE ) )
	 	    	-- good_numlabel : setPosition ( 78, 0 ) 
	 	    	-- self.relewid[time + 1] : addChild ( good_numlabel )
	 	    end
	 	    time = time + 1
		end

		-- 增加 复制绑定串码按钮
		local bindCodeBtn = gc.CButton: create( "general_btn_lv.png")
		print( "--------ccui.TextureResType.plistType  =  ", ccui.TextureResType.plistType )
		bindCodeBtn	: setTitleText( "复制绑定码" )
		bindCodeBtn	: setTitleFontName( _G.FontName.Heiti )
		bindCodeBtn	: setTitleFontSize(self.FONTSIZE+2)
		bindCodeBtn	: addTouchEventListener( weixinCallBack )
		bindCodeBtn : setTag( 88 )
		bindCodeBtn : setPosition( cc.p( 240, -25 ) )  
		self.m_tabView[self.WEIXINTAG] : addChild( bindCodeBtn )


		local wordLabel2 = _G.Util:createLabel("2.复制下面的绑定串码，发送到微信公众号，完成绑定。",self.FONTSIZE)
		wordLabel2:setPosition(cc.p(-250,50))
		wordLabel2:setAnchorPoint(cc.p(0,0.5))
		-- wordLabel2:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
		self.m_tabView[self.WEIXINTAG]:addChild(wordLabel2)

		local wordLabel3 = _G.Util:createLabel("3.绑定串码发送到本微信公众号，完成绑定，领取奖励。",self.FONTSIZE)
		wordLabel3:setPosition(cc.p(-250,-100))
		wordLabel3:setAnchorPoint(cc.p(0,0.5))
		-- wordLabel3:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
		self.m_tabView[self.WEIXINTAG]:addChild(wordLabel3)

		self.getRewardBtn = gc.CButton:create()
		self.getRewardBtn : loadTextures("general_btn_gold.png")
		self.getRewardBtn : setPosition(cc.p(30,-255))
		self.getRewardBtn : setTitleText("领取奖励")
		self.getRewardBtn : setTitleFontName(_G.FontName.Heiti)
		self.getRewardBtn : setTitleFontSize(self.FONTSIZE+2)
		self.getRewardBtn : setTag( 77 )
		self.getRewardBtn : addTouchEventListener(weixinCallBack)
		self.m_tabView[self.WEIXINTAG]    : addChild(self.getRewardBtn)

		if self.askMsg.state == 0 then
			self.getRewardBtn : setTouchEnabled( false )
			self.getRewardBtn : setGray()
		elseif self.askMsg.state == 2 then 
			self.getRewardBtn : setTouchEnabled( false )
			self.getRewardBtn : setGray()
			self.getRewardBtn : setTitleText( "已领取" )
		end

		self.m_getWeixinNm = _G.SysInfo : urlWechatBound()
		-- url
		local sid   = _G.GLoginPoxy:getServerId()
	    local szUrl = self.m_getWeixinNm
	 	-- local szUrl = "http://xm-wx.7pk.cn/wx/bdapi/?cid=158&sid=205&uuid=0&uid=548&time=1425957639&sign=f3dervh11d2dcd976d942f20e842315f"
	 	if self.xhrRequest == nil then
		    local xhrRequest = cc.XMLHttpRequest:new()
		    self.xhrRequest  = xhrRequest
		    xhrRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
		    xhrRequest:open("GET", szUrl)
		    -- unregisterScriptHandler
		    local function tipsSure()
		        self:httpRequestUID()
		    end

		    local function http_handler()
		    	self.xhrRequest=nil
		        if xhrRequest.readyState == 4 and (xhrRequest.status >= 200 and xhrRequest.status < 207) then
		        	local response = xhrRequest.response
		            print( "－－－－http_handler response="..response )
		            local test = string.find(response,"error")
		            if  test then
		            	local test2 = string.find(response,"error")
		            	print( "错误：", string.sub( response, test2+12, string.len(response) ) )
		            	_G.Util:showTipsBox(string.format( "获取错误:%s", string.sub( response, test2+12, string.len(response)), tipsSure))
		            else                                                                                                              
		            	print( "微信复制成功！" )
						self.m_szBDMString=response
						print( "response = ", response )
						local Lab_WeiXin = _G.Util : createLabel( response, self.FONTSIZE )
						-- Lab_WeiXin : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_PBLUE ) )
						Lab_WeiXin : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
						Lab_WeiXin : setAnchorPoint( 0, 0 )
						Lab_WeiXin : setDimensions( 350, 86 )
						Lab_WeiXin : setPosition( 10, 0)
						Lab_WeiXin : setLineBreakWithoutSpace(true)
						layout 	   : addChild( Lab_WeiXin )
						
		            	print( "微信显示成功！" )
		    		end
				end
		    end

		    print( " －－－－ http_handler－－－－" )
		    xhrRequest:registerScriptHandler(http_handler)
		    xhrRequest:send()
		    print( "－－－－ url seccessful －－－－\n" )
		end
	end
end

function SettingView.__releaseChannelTip( self )
	if self.m_channelTipsNode ~= nil then
		self.m_channelTipsNode:removeFromParent(true)
		self.m_channelTipsNode=nil
	end
end

function SettingView.createWeixinTips( self )
	-- local channelSize = cc.size(70,120)
	self.m_channelTipsNode = cc.LayerColor:create(cc.c4b(0,0,0,150))

	local function onTouchCallBack( touch,sender )
		local function delay()
			self:__releaseChannelTip()
		end
		performWithDelay(self.m_channelTipsNode,delay,0.05)
		return true
	end

	local listerner=cc.EventListenerTouchOneByOne:create()
	listerner:registerScriptHandler(onTouchCallBack,cc.Handler.EVENT_TOUCH_BEGAN )
	listerner:setSwallowTouches(true)

	self.m_channelTipsNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_channelTipsNode)
	-- self.m_channelTipsNode:setPosition(cc.p(-370,-170))
	cc.Director:getInstance():getRunningScene():addChild(self.m_channelTipsNode,1000)

	-- local testFrameSpri  = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double2.png" ) 
	-- testFrameSpri        : setPreferredSize( cc.size(445,445) )
	-- -- testFrameSpri : setPosition(cc.p(sprsize.width/2,sprsize.height/2))
	-- self.m_channelTipsNode: addChild(testFrameSpri)

	local wenxinSpr = cc.Sprite:create("ui/bg/qrcode_weixin.jpg")
	-- wenxinSpr : setScale( 0.3 )
	wenxinSpr : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
	self.m_channelTipsNode : addChild(wenxinSpr)

end



--------------  复制微信号
function SettingView.createCopyWord( self )
	-- _G.Util:showTipsBox( "复制微信号成功" )
	local command = CErrorBoxCommand(302)
    controller :sendCommand( command )
	print( "复制微信号开始啦，得数据" )
	local ListArr = _G.GSystemProxy:getSysSettingList()
	print( "现在得到了：", ListArr[1] )
	for i,v in ipairs(ListArr) do
		print(i,v.type)
		print(i,v.state)
	end

end

--------------  复制绑定串码
function SettingView.createbindCode( self )
	local command = CErrorBoxCommand(303)
    controller :sendCommand( command )
	-- _G.Util:showTipsBox( "复制绑定串码成功" )
end

--------------  领奖界面
function SettingView.GoodTake( self )
	self : REQ_SYS_SET_WX_REPLY()
	-- self : REQ_SYS_SET_WX_ASK( )
	-- if self.askMsg.state == 0 then 
	-- 	self.getRewardBtn : setTouchEnabled( false )
	-- 	self.getRewardBtn : setGray()
	-- end
	-- if self.askMsg.state == 2 then 
	-- 	self.getRewardBtn : setTouchEnabled( false )
	-- 	self.getRewardBtn : setGray()
	-- 	self.getRewardBtn : setTitleText( "已领取" )
	-- end
end

function SettingView.REQ_SYS_SET_WX_REPLY( self )
	print( " －－－在button中，运行 SettingView.REQ_SYS_SET_WX_REPLY ！！！－－－ " )
	local msg 	= REQ_SYS_SET_WX_REPLY()
	_G.Network 	: send( msg ) 
end

function SettingView.GoodsTakeOK( self )
	print( "-------请求成功-------" )
	-- self.msg.state = 2
	self.getRewardBtn : setTouchEnabled( false )
	self.getRewardBtn : setGray()
	self.getRewardBtn : setTitleText( "已领取" )
end

function SettingView.REQ_SYS_SET_WX_ASK( self )
	print( "－－－运行 SettingView.REQ_SYS_SET_WX_ASK ！！！" )
	local msg 	= REQ_SYS_SET_WX_ASK()
	print( "－－－msg = ", msg ) 
    -- msg : setArgs()
    _G.Network 	: send(msg)
end

function SettingView.REQ_TEAM_INVITE_STATE( self,state )
	print( "当前组队状态", state ) 
    local msg = REQ_TEAM_INVITE_STATE()
    msg:setArgs(state)
    _G.Network:send(msg)
end

	-- 接受协议
function SettingView.GoodsOK( self, _askMsg )
	self.askMsg = _askMsg
	print( "－－－－－－ self.askMsg = ", self.askMsg.state  )
	if self.getRewardBtn ~= nil then
		if _askMsg.state == 1 then 
			self.getRewardBtn : setTouchEnabled(true)
			self.getRewardBtn : setDefault()
		elseif _askMsg.state == 0 then 
			self.getRewardBtn : setTouchEnabled( false )
			self.getRewardBtn : setGray()
		elseif _askMsg.state == 2 then 
			self.getRewardBtn : setTouchEnabled( false )
			self.getRewardBtn : setGray()
		end
	end
end

function SettingView.systemView( self )
	self:CreateTabView( self.SYSTEMSET )
	if self.is_Create.SYSTEMSET == true then
		self.is_Create.SYSTEMSET = false
		self.checkBoxList = {}
		local settingList = {"背景音乐",
							"游戏音效",
							"允许切磋",
							"允许组队",
							"屏蔽玩家"}

		local uncheckBox = "general_gold_floor.png"
		local selectBox = "general_check_selected.png"

		local tabTitleLabel = _G.Util:createLabel("系统设置",self.FONTSIZE+10)
		tabTitleLabel:setPosition(cc.p(35,190))
		-- tabTitleLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
		self.m_tabView[self.SYSTEMSET]:addChild(tabTitleLabel)

		local function checkBoxCallback( sender,eventType )
			print("－－－－checkBoxCallback -->",sender,eventType,sender:getTag())
			local num = sender:getTag()
			if eventType == 0 then 
				checkBoxChoice[ num ] = 1
				print("checkBoxCallback -111->",sender, checkBoxChoice[num])
			else	
				checkBoxChoice[ num ] = 0
				print("checkBoxCallback -222->",num, checkBoxChoice[num] )
			end
			if num == 4 then
				self:REQ_TEAM_INVITE_STATE(checkBoxChoice[num])
			end
			self:__handleTypeSetting(num,checkBoxChoice[num])
		end 

		for i,v in ipairs(settingList) do
			print("checkBox --> ",v,selectBox)
			local sprPostion = cc.p(-150,120-i*40)
			if i%2 == 0 then
				sprPostion = cc.p(150,120-(i-1)*40)
			end

			local checkBoxLab = _G.Util:createLabel(v,self.FONTSIZE+4)
			-- checkBoxLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
			checkBoxLab:setPosition(sprPostion)
			self.m_tabView[self.SYSTEMSET]:addChild(checkBoxLab)

			local checkBox = ccui.CheckBox:create(uncheckBox,uncheckBox,selectBox,uncheckBox,uncheckBox,ccui.TextureResType.plistType)
			checkBox:addEventListener(checkBoxCallback)
			checkBox:setPosition(sprPostion.x+90,sprPostion.y)
			checkBox:setTag(i)
			self.m_tabView[self.SYSTEMSET]:addChild(checkBox) 	
			if checkBoxChoice[i] == 1 then 
				checkBox : setSelected( true )
			end
		end

		local function buttonCallback( sender,eventType )
			local operateTag = sender:getTag()
			if eventType==ccui.TouchEventType.ended then
				print("buttonCallback -->",operateTag)
				if operateTag == 2001 then
					local function sure()
						self:__chuangeServer()
					end
					_G.Util:showTipsBox(_G.Lang.LAB_N[746],sure)
				elseif operateTag == 2002 then
					local function sure()
						self:__chuangeRole()
					end
					_G.Util:showTipsBox(_G.Lang.LAB_N[745],sure)
					-- cc.Director:getInstance():endToLua()
				elseif operateTag == 2010 then
					gc.SDKManager:getInstance():showSDKCenter()
				elseif operateTag == 2011 then
					gc.SDKManager:getInstance():bindSDK()
				elseif operateTag == 2020 then
					local function sure()
						gc.SDKManager:getInstance():logoutSDK()
					end
					_G.Util:showTipsBox("确认注销账号？",sure)
				elseif operateTag == 2021 then
					local function sure()
						gc.SDKManager:getInstance():logoutSDK()
					end
					_G.Util:showTipsBox("确认切换账号？",sure)
				end
			end
		end

		local reSeverListBtn = gc.CButton:create("general_btn_lv.png")
		reSeverListBtn : setTitleText("返回选区")
		reSeverListBtn : setTitleFontName(_G.FontName.Heiti)
		--reSeverListBtn : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
		reSeverListBtn : addTouchEventListener(buttonCallback)
		reSeverListBtn : setTag(2001)
		reSeverListBtn : setTitleFontSize(self.FONTSIZE+2)
		reSeverListBtn : setPosition(cc.p(-100,-220))
		self.m_tabView[self.SYSTEMSET] : addChild(reSeverListBtn)

		local loginOutBtn = gc.CButton:create("general_btn_gold.png")
		loginOutBtn : setTitleText("切换角色")
		loginOutBtn : setTitleFontName(_G.FontName.Heiti)
		loginOutBtn : setTitleFontSize(self.FONTSIZE+2)
		loginOutBtn : addTouchEventListener(buttonCallback)
		loginOutBtn : setTag(2002)
		loginOutBtn : setPosition(cc.p(150,-220))
		self.m_tabView[self.SYSTEMSET] : addChild(loginOutBtn)

		if _G.SysInfo:isShowSDKUserBtn() then
			local userCenterBtn = gc.CButton:create("general_btn_gold.png")
			userCenterBtn : setTitleText("用户中心")
			userCenterBtn : setTitleFontName(_G.FontName.Heiti)
			--userCenterBtn : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
			userCenterBtn : addTouchEventListener(buttonCallback)
			userCenterBtn : setTag(2010)
			userCenterBtn : setTitleFontSize(self.FONTSIZE+2)
			userCenterBtn : setPosition(cc.p(150,-100))
			self.m_tabView[self.SYSTEMSET] : addChild(userCenterBtn)
		end
        local agentCode = gc.App:getInstance():getAgentCode()
		local channelId=gc.SDKManager:getInstance():getSDKChannel()
		if agentCode==_G.Const.AGENT_SDK_CODE_IFENG 
			or agentCode==_G.Const.AGENT_SDK_CODE_IFENG_IOS
			or agentCode==_G.Const.AGENT_SDK_CODE_APP_IOS_GC
			or agentCode==_G.Const.AGENT_SDK_CODE_KUAIFA 
			or agentCode==_G.Const.AGENT_SDK_CODE_QQ
			or agentCode==_G.Const.AGENT_SDK_CODE_YIJIE then

			local nTag=2020
			local szName="注销账号"
			if agentCode==_G.Const.AGENT_SDK_CODE_QQ then
				szName="切换帐号"
			end

			local logoutBtn = gc.CButton:create("general_btn_gold.png")
			logoutBtn : setTitleText(szName)
			logoutBtn : setTitleFontName(_G.FontName.Heiti)
			logoutBtn : addTouchEventListener(buttonCallback)
			logoutBtn : setTag(nTag)
			logoutBtn : setTitleFontSize(self.FONTSIZE)
			logoutBtn : setPosition(cc.p(-100,-150))
			self.m_tabView[self.SYSTEMSET] : addChild(logoutBtn)
		-- elseif agentCode==_G.Const.AGENT_SDK_CODE_ANYSDK then
		-- 	if channelId=="000004" then
		-- 		local logoutBtn1 = gc.CButton:create("general_btn_gold.png")
		-- 		logoutBtn1 : setTitleText("注销账号")
		-- 		logoutBtn1 : setTitleFontName(_G.FontName.Heiti)
		-- 		logoutBtn1 : addTouchEventListener(buttonCallback)
		-- 		logoutBtn1 : setTag(2020)
		-- 		logoutBtn1 : setTitleFontSize(self.FONTSIZE)
		-- 		logoutBtn1 : setPosition(cc.p(-100,-150))
		-- 		self.m_tabView[self.SYSTEMSET] : addChild(logoutBtn1)

		-- 		local logoutBtn2 = gc.CButton:create("general_btn_gold.png")
		-- 		logoutBtn2 : setTitleText("注销账号")
		-- 		logoutBtn2 : setTitleFontName(_G.FontName.Heiti)
		-- 		logoutBtn2 : addTouchEventListener(buttonCallback)
		-- 		logoutBtn2 : setTag(2021)
		-- 		logoutBtn2 : setTitleFontSize(self.FONTSIZE)
		-- 		logoutBtn2 : setPosition(cc.p(150,-150))
		-- 		self.m_tabView[self.SYSTEMSET] : addChild(logoutBtn2)
		--     end
		end
	end
end

-- 580,435  (580,380)
function SettingView.gameNoticeView( self )
	self:CreateTabView(self.GAMENOTICE)
	if self.m_webView[1] ~= nil then
		self.m_webView[1] : setVisible( true )
	end

	if self.is_Create.GAMENOTICE == true then 
		self.is_Create.GAMENOTICE = false
		local tabTitleLabel = _G.Util:createLabel("游戏公告",self.FONTSIZE+10)
		tabTitleLabel:setPosition(cc.p(35,190))
		-- tabTitleLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
		self.m_tabView[self.GAMENOTICE]:addChild(tabTitleLabel)

		-- local url_02 = _G.SysInfo:urlUpdateLogs()
		local url_02 = "http://xm-api.gamecore.cn:89/api/Gm"
		-- local xhrRequest = cc.XMLHttpRequest:new()
		-- xhrRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
		-- xhrRequest:open("GET", url_02)

		-- local function http_handler()
		-- 	_G.Util:hideLoadCir()
		-- 	if xhrRequest.readyState == 4 and (xhrRequest.status >= 200 and xhrRequest.status < 207) then
		-- 		local response = xhrRequest.response
		-- 		local output = json.decode(response,1)

		-- 		print("http_handler response11="..response)
		-- 		print("http_handler response11="..(#output))
		-- 		local lenght = 0
		-- 		for i,v in ipairs(output) do
		-- 			print("title --->",i,v.title.w,v.title.c)
		-- 			print("time_start --->",i,v.time_start.w,v.time_start.c)
		-- 			print("time_end --->",i,v.time_end.w,v.time_end.c)
		-- 			print("lenght --->",i,v.content_len)
		-- 			lenght = lenght + v.content_len
		-- 			for i1,v1 in ipairs(v.content) do
		-- 				for i2,v2 in ipairs(v1) do
		-- 					print("content -->",i1,v2.w,v2.c)
		-- 				end
		-- 			end
		-- 		end

		-- 		self:createJsonView(output,lenght)
		-- 	else
		-- 		_G.Util:showTipsBox(string.format("HTTP请求失败:state:%d,code=%d",xhrRequest.readyState,xhrRequest.status))
		-- 	end
		-- end

		-- xhrRequest:registerScriptHandler(http_handler)
		-- xhrRequest:send()

		if gc.CWebView==nil then
		    local command=CErrorBoxCommand("WebView 将在下版本加入")
		    _G.controller:sendCommand(command)
		    return
		end

		-- local url = "http://xm-api.gamecore.cn:89/api/Gm"
		local url = _G.SysInfo:urlUpdateLogs()
		self.m_webView[1]=gc.CWebView:create()
		self.m_webView[1]:setPosition(23,-66)
		self.m_webView[1]:setContentSize(cc.size( 617, 460 ))
		self.m_webView[1]:loadURL( url ) -- "http://www.baidu.com"
		self.m_webView[1]:setScalesPageToFit(true)
		self.m_tabView[self.GAMENOTICE]:addChild(self.m_webView[1])

		local circle=cc.Sprite:createWithSpriteFrameName("general_loading.png")
    	self.m_tabView[self.GAMENOTICE]:addChild(circle)
    	local rotaBy=cc.RotateBy:create(1,360)
    	circle:runAction(cc.RepeatForever:create(rotaBy))

		local function callBack(eventType)
		    if eventType==_G.Const.sWebViewStartLoading then
		        print("FFFFF======>>>> 开始加载")
		    elseif eventType==_G.Const.sWebViewFinishLoading then
		        print("FFFFF======>>>> 加载完成")
		    elseif eventType==_G.Const.sWebViewFailLoading then
		        print("FFFFF======>>>> 加载出错")
		    end
		end
		local handler=gc.ScriptHandlerControl:create(callBack)
		self.m_webView[1]:registerScriptHandler(handler)
		-- _G.Util:showLoadCir()
	end
end

function SettingView.createJsonView( self, _data ,_lenght)
	
	local innerHeight = 30*(_lenght+(#_data)*2)
	
	print("createJsonView ---lenght -->",_lenght,innerHeight,(#_data))
	local viewSize = cc.size(560,360)
	local innerViewSize = cc.size(560,innerHeight)
	local noticeView = cc.ScrollView:create()
	noticeView :setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	noticeView :setViewSize(viewSize)
	noticeView :setContentSize(innerViewSize)
	noticeView :setBounceable(false)
	noticeView :setContentOffset( cc.p( 0, -innerHeight+360 )) -- 设置初始位置
	noticeView :setPosition(cc.p(-240,-230))
	self.m_tabView[self.GAMENOTICE] :addChild(noticeView)

	local barView=require("mod.general.ScrollBar")(noticeView)

	local titleLabel = {}
	local timeLabel = {}
	local oneHeight = 0
	for i,v in ipairs(_data) do
		print("test ---> ",i,v.title.w,v.title.c)
		titleLabel[i] = _G.Util:createLabel(v.title.w,self.FONTSIZE+5)
		titleLabel[i]:setAnchorPoint(cc.p(0,1));
		titleLabel[i]:setPosition(cc.p(20,innerViewSize.height-oneHeight ))
		titleLabel[i]:setColor(_G.ColorUtil:getRGB(v.title.c))
		noticeView:addChild(titleLabel[i])

		timeLabel[i] = {}
		timeLabel[i].start = _G.Util:createLabel(v.time_start.w,self.FONTSIZE-5)
		timeLabel[i].start:setAnchorPoint(cc.p(0,1));
		timeLabel[i].start:setPosition(cc.p(20,innerViewSize.height-30-oneHeight ))
		timeLabel[i].start:setColor(_G.ColorUtil:getRGB(v.time_start.c))
		noticeView:addChild(timeLabel[i].start)

		timeLabel[i].timeEnd = _G.Util:createLabel(" ~ "..v.time_end.w,self.FONTSIZE-5)
		timeLabel[i].timeEnd:setAnchorPoint(cc.p(0,1));
		timeLabel[i].timeEnd:setPosition(cc.p(140,innerViewSize.height-30-oneHeight ))
		timeLabel[i].timeEnd:setColor(_G.ColorUtil:getRGB(v.time_end.c))
		noticeView:addChild(timeLabel[i].timeEnd)
		
		local contentLabel = {}
		local strWord = ""
		for j,k in ipairs(v.content) do
			local lineWidth = 0
			for m,n in ipairs(k) do
				if m-1 == 0 then
					strWord = n.w
				elseif n.c == k[m-1].c then
					strWord = strWord.s.n.w
				else
					local lineLabel = _G.Util:createLabel(strWord,self.FONTSIZE)
					lineLabel:setAnchorPoint(cc.p(0,1));
					lineLabel:setPosition(cc.p(lineWidth+20,innerViewSize.height-30-oneHeight-j*30+10))
					lineLabel:setColor(_G.ColorUtil:getRGB(k[m-1].c))
					noticeView:addChild(lineLabel)
					
					lineWidth = lineWidth+lineLabel:getContentSize().width
					strWord = n.w
				end
			end
		end
		oneHeight = oneHeight + v.content_len*30 + 60
	end
end

function SettingView.updateBugView( self )
	self:CreateTabView(self.UPDATEBUG)
	if self.myBugView then
		self.myBugView : setVisible( true )
	end
	if self.is_Create.UPDATEBUG == true then 
		self.is_Create.UPDATEBUG = false

		local tabTitleLabel = _G.Util:createLabel("反馈BUG",self.FONTSIZE+10)
		tabTitleLabel:setPosition(cc.p(30,190))
		-- tabTitleLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
		self.m_tabView[self.UPDATEBUG]:addChild(tabTitleLabel)

		if gc.CWebView==nil then
		    local command=CErrorBoxCommand("WebView 将在下版本加入")
		    _G.controller:sendCommand(command)
		    return
		end

		local url   =_G.SysInfo:urlBugsReport()
		self.myBugView=gc.CWebView:create()
		self.myBugView:setPosition(24,-66)
		self.myBugView:setContentSize(cc.size( 615, 460 ))
		self.myBugView:loadURL( url ) -- "http://www.baidu.com"
		self.myBugView:setScalesPageToFit(true)
		self.m_tabView[self.UPDATEBUG]:addChild(self.myBugView)

		local circle=cc.Sprite:createWithSpriteFrameName("general_loading.png")
    	self.m_tabView[self.UPDATEBUG]:addChild(circle)
    	local rotaBy=cc.RotateBy:create(1,360)
    	circle:runAction(cc.RepeatForever:create(rotaBy))

		local function callBack(eventType)
		    if eventType==_G.Const.sWebViewStartLoading then
		        print("FFFFF======>>>> 开始加载")
		    elseif eventType==_G.Const.sWebViewFinishLoading then
		        print("FFFFF======>>>> 加载完成")
		    elseif eventType==_G.Const.sWebViewFailLoading then
		        print("FFFFF======>>>> 加载出错")
		    end
		end
		local handler=gc.ScriptHandlerControl:create(callBack)
		self.myBugView:registerScriptHandler(handler)
		-- print( "------------反馈BUG--------------" )
		-- local tabTitleLabel = _G.Util:createLabel("反馈BUG",self.FONTSIZE+4)
		-- tabTitleLabel:setPosition(cc.p(35,170))
		-- tabTitleLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
		-- self.m_tabView[self.UPDATEBUG]:addChild(tabTitleLabel)

		-- local wordLabel1 = _G.Util:createLabel("1.添加微信帐号：",self.FONTSIZE)
		-- wordLabel1:setPosition(cc.p(-150,130))
		-- wordLabel1:setAnchorPoint(cc.p(0,0.5))
		-- wordLabel1:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
		-- self.m_tabView[self.UPDATEBUG]:addChild(wordLabel1)

		-- local wordlabel5 = _G.Util : createLabel( "syxiangmo", self.FONTSIZE+7 )
		-- wordlabel5:setPosition(cc.p(10,130))
		-- wordlabel5:setAnchorPoint(cc.p(0,0.5))
		-- wordlabel5:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOWISH))
		-- self.m_tabView[self.UPDATEBUG]:addChild(wordlabel5)

		-- -- local saveWordBtn = gc.CButton:create("general_btn_lv.png")
		-- -- saveWordBtn : setTitleText("复制微信号")
		-- -- saveWordBtn:setTitleFontName(_G.FontName.Heiti)
		-- -- saveWordBtn : setTitleFontSize(self.FONTSIZE+2)
		-- -- -- saveWordBtn : addTouchEventListener(buttonCallback)
		-- -- saveWordBtn : setTag(44)
		-- -- saveWordBtn : setPosition(cc.p(220,110))
		-- -- self.m_tabView[self.UPDATEBUG] : addChild(saveWordBtn)

		-- local wordLabel2 = _G.Util:createLabel("2.根据微信提示，绑定游戏帐号",self.FONTSIZE)
		-- wordLabel2:setPosition(cc.p(-150,100))
		-- wordLabel2:setAnchorPoint(cc.p(0,0.5))
		-- wordLabel2:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOWISH))
		-- self.m_tabView[self.UPDATEBUG]:addChild(wordLabel2)

		-- local wordLabel3 = _G.Util:createLabel("3.把问题描述，通过微信发送给游戏GM",self.FONTSIZE)
		-- wordLabel3:setPosition(cc.p(-150,70))
		-- wordLabel3:setAnchorPoint(cc.p(0,0.5))
		-- wordLabel3:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOWISH))
		-- self.m_tabView[self.UPDATEBUG]:addChild(wordLabel3)

		-- local wordLabel4 = _G.Util:createLabel("4.GM根据BUG大小给您发放对应的钻石作为反馈奖励",self.FONTSIZE)
		-- wordLabel4:setPosition(cc.p(-150,40))
		-- wordLabel4:setAnchorPoint(cc.p(0,0.5))
		-- wordLabel4:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOWISH))
		-- self.m_tabView[self.UPDATEBUG]:addChild(wordLabel4)

		-- local lineSpri2  = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
		-- local lineSprSize = lineSpri2 : getPreferredSize()
		-- lineSpri2        : setPreferredSize( cc.size(580,lineSprSize.height) )
		-- lineSpri2 : setPosition(cc.p(30,20))
		-- self.m_tabView[self.UPDATEBUG]: addChild(lineSpri2)

		-- local wenxinSpr = cc.Sprite:create("ui/bg/qrcode_weixin.jpg")
		-- wenxinSpr : setScale( 0.3 )
		-- wenxinSpr : setPosition(cc.p(30,-60))
		-- self.m_tabView[self.UPDATEBUG] : addChild(wenxinSpr)

		-- local explainLabel = _G.Util:createLabel("扫描微信二维码 加微信",self.FONTSIZE)
		-- explainLabel:setPosition(cc.p(30,-145))
		-- explainLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOWISH))
		-- self.m_tabView[self.UPDATEBUG]:addChild(explainLabel)

		-- local function myCallBack( obj, eventType )
		-- 	if eventType == ccui.TouchEventType.ended then
		-- 		local notice = require( "mod.login.LoadNotice" )()
  -- 				local view   = notice : create( 2, nil, true )
		-- 	end
		-- end 
		
		-- local saveUIBtn = gc.CButton:create("general_btn_lv.png")
		-- saveUIBtn : setTitleText("反馈BUG")
		-- saveUIBtn : setTitleFontSize(self.FONTSIZE+2)
		-- saveUIBtn:setTitleFontName(_G.FontName.Heiti)
		-- saveUIBtn : addTouchEventListener(myCallBack)
		-- saveUIBtn : setTag(33)
		-- saveUIBtn : setPosition(cc.p(35,-195))
		-- self.m_tabView[self.UPDATEBUG] : addChild(saveUIBtn)

		-- local lab = _G.Util : createLabel( "点击直接进入反馈BUG页面", 18 )
		-- lab : setPosition( 30,-235 )
		-- lab : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ) )
		-- self.m_tabView[self.UPDATEBUG] : addChild( lab )
	end
end

function SettingView.SendCheck( self )
	local SendNum = { 101, 102, 105, 106, 103 }
	for i=1,5 do
		print( "checkBoxChoice : ",i ,checkBoxChoice[i] )
		print( "checkBoxChoice_2 : ",i ,checkBoxChoice_2[i] )
	end
	for i=1,#checkBoxChoice do
		if not (checkBoxChoice_2[i]==checkBoxChoice[i]) then
			print( "发送：",checkBoxChoice[i],SendNum[i] ) 
			self : REQ_SYS_SET_CHECK( SendNum[i] )
		end
	end
end

function SettingView.closeWindow(self)
	if self.xhrRequest ~= nil then
		self.xhrRequest : unregisterScriptHandler()
	end
	if self.sysSetLabel==nil then return end
	self.sysSetLabel=nil
	cc.Director:getInstance():popScene()
	self:destroy()
end

function SettingView.__chuangeServer(self)
	if self.m_isChuangServer then return end

	self.m_isChuangServer=true

	local function nfun()
		RESTART_GAME(_G.Const.kResetGameTypeChuangServer)
	end
	_G.Scheduler:performWithDelay(0.1,nfun)
end

function SettingView.__chuangeRole(self)
    local szUrl = _G.SysInfo:urlRoleList(_G.GLoginPoxy:getServerId())
    local xhrRequest = cc.XMLHttpRequest:new()
    xhrRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhrRequest:open("GET", szUrl)
    print("httpRequestRole->  url="..szUrl)

    local function http_handler()
        _G.Util:hideLoadCir()

        if xhrRequest.readyState == 4 and (xhrRequest.status >= 200 and xhrRequest.status < 207) then
            local response = xhrRequest.response
            response = string.gsub(response,'\\','')
            print("http_handler response="..response)

            local output = json.decode(response,1)
            if output.ref==1 then
                local roleList=output.role_list
				RESTART_GAME(_G.Const.kResetGameTypeChuangRole,roleList)
            else
                _G.Util:showTipsBox(string.format("获取角色列表失败:%s(%d)",output.msg,output.error))
            end
        else
            _G.Util:showTipsBox(string.format("HTTP请求失败:state:%d,code=%d",xhrRequest.readyState,xhrRequest.status))
        end
    end

    xhrRequest:registerScriptHandler(http_handler)
    xhrRequest:send()

    _G.Util:showLoadCir()
end

function SettingView.REQ_SYS_SET_CHECK( self, _ackMsg )
	local ackMsg = _ackMsg
	local msg 	 = REQ_SYS_SET_CHECK()
	msg : setArgs( ackMsg )
	_G.Network : send( msg )
end

function SettingView.Type_state( self, _ackMsg )
	print( "协议：REQ_SYS_SET_CHECK的返回" )
end

function SettingView.__handleTypeSetting(self,_idx,_state)
	if _idx==1 then
		-- 背景音乐
		_G.GSystemProxy:savaChuangByView(_G.Const.CONST_SYS_SET_MUSIC_BG,_state)
	elseif _idx==2 then
		-- 游戏音效
		_G.GSystemProxy:savaChuangByView(_G.Const.CONST_SYS_SET_MUSIC,_state)
	elseif _idx==3 then
		-- 允许切磋
		_G.GSystemProxy:savaChuangByView(_G.Const.CONST_SYS_SET_PK,_state)
	elseif _idx==4 then
		-- 允许组队
		_G.GSystemProxy:savaChuangByView(_G.Const.CONST_SYS_SET_TEAM,_state)
	elseif _idx==5 then
		_G.GSystemProxy:savaChuangByView(_G.Const.CONST_SYS_SET_SHOW_ROLE,_state)
	end
end

return SettingView