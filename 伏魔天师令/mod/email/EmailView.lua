local EmailView = classGc(view, function(self)
	self.pMediator = require("mod.email.EmailMadiator")()
	self.pMediator : setView(self)
	self.m_checkEmailArray={}
end)

local P_FONTSIZE = 24
local P_WINSIZE  = cc.Director:getInstance():getVisibleSize()
local P_MAINSIZE = cc.size(828, 492)
local P_MAILBG_SIZE = cc.size(403 ,81)
local P_ICONSIZE = cc.size(78 ,78)

function EmailView.create(self)
	self.m_normalView=require("mod.general.NormalView")()
	self.m_rootLayer=self.m_normalView:create()
	self.m_normalView : setTitle("邮 件")

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

	self : init()
	return tempScene
end

function EmailView.init( self )
	local function nCloseFun()
		print("关闭邮箱")
		if self.m_rootLayer == nil then return end
    	self.m_rootLayer=nil
		self : unregister()
		cc.Director:getInstance():popScene()
	end
	self.m_normalView:addCloseFun(nCloseFun)

	self : initView()
	self : networksend()
end

function EmailView.networksend( self )
    local msg = REQ_MAIL_REQUEST()
    msg:setArgs( 0 )
    _G.Network :send( msg)
end

function EmailView.pushData(self, _data)     --mediator传过来的数据
    print("EmailMediator传过来的数据:", _data,_data.models)
    if _data== nil then return end
    self.m_emailListData = _data.models      --邮件信息
    if self.m_emailListData== nil then
    	self.m_noEmailNoticSpr   : setVisible(true)
        self.m_noEmailNoticLabel : setVisible(true)
    else
    	self.m_emailListCount = #self.m_emailListData
    	self:__showEmailList()
    end
end

function EmailView.initView(self)
	local m_mainNode = cc.Node:create()
	m_mainNode : setPosition(P_WINSIZE.width*0.5,P_WINSIZE.height*0.5)
	self.m_rootLayer: addChild(m_mainNode)

	self.kuangSize = cc.size(413,416)
	self.leftSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_di2kuan.png")
	self.leftSpr : setPosition(-P_MAINSIZE.width/4-9, -6)
	self.leftSpr : setPreferredSize(self.kuangSize)
	m_mainNode : addChild(self.leftSpr)

	self.m_noEmailNoticSpr = cc.Sprite:createWithSpriteFrameName("general_monkey.png")
	self.m_noEmailNoticSpr : setPosition(self.kuangSize.width/2,self.kuangSize.height/2+20)
	self.m_noEmailNoticSpr : setVisible(false)
	self.leftSpr : addChild(self.m_noEmailNoticSpr)

	self.m_noEmailNoticLabel = _G.Util : createLabel("暂无邮件", P_FONTSIZE)
	-- self.m_noEmailNoticLabel : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN))
	self.m_noEmailNoticLabel : setPosition(self.kuangSize.width/2,self.kuangSize.height/2-50)
	self.m_noEmailNoticLabel : setVisible(false)
	self.leftSpr : addChild(self.m_noEmailNoticLabel)

	-- local login_Lab1= _G.Util : createLabel("邮 件 列 表", P_FONTSIZE-3)
	-- login_Lab1 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GOLD))
	-- login_Lab1 : setPosition(-P_MAINSIZE.width/4, P_MAINSIZE.height/2-10) 
	-- m_mainNode : addChild(login_Lab1)

	local rightSize = cc.size(424, 492)
	self.rightWid = ccui.Scale9Sprite : createWithSpriteFrameName("general_di2kuan.png")
	self.rightWid : setPosition(P_MAINSIZE.width/4, -44)
	self.rightWid : setPreferredSize(rightSize)
	m_mainNode : addChild(self.rightWid)

	self.rightSize = cc.size(rightSize.width-4,rightSize.height-4)

	-- local login_Lab2= _G.Util : createLabel("邮 件 内 容", P_FONTSIZE-3)
	-- login_Lab2: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
	-- login_Lab2: setPosition(rightSize.width/2, rightSize.height+15) 
	-- self.rightWid : addChild(login_Lab2)

	self:__createEmailContent()
	self:__createEmailListView()
end

function EmailView.__createEmailContent( self )
	local tempLabel	= {1,2}
	local e_info 	= {"标题:", ""}
	local e_poX 	= {15, 75}
	for i = 1, 2 do
		tempLabel[i] = _G.Util : createLabel(e_info[i], P_FONTSIZE-4)
		-- tempLabel[i] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN))
		tempLabel[i] : setPosition(e_poX[i], self.rightSize.height-35)
		tempLabel[i] : setAnchorPoint( cc.p(0.0,0.5) )
		self.rightWid : addChild(tempLabel[i])
	end
	-- tempLabel[2] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKRED))
	tempLabel[2] : setDimensions(self.rightSize.width-75, 25)
	tempLabel[2] : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.m_contentTitleLabel = tempLabel[2]

	local fujianLabel = _G.Util : createLabel("附件:", P_FONTSIZE-4)
	-- fujianLabel : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN))
	fujianLabel : setPosition(40,self.rightSize.height/2-45)
	self.rightWid : addChild(fujianLabel)

	self.m_contentCenterLabel = _G.Util : createLabel("", P_FONTSIZE-4)
	-- self.m_contentCenterLabel : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKRED))
	self.m_contentCenterLabel : setPosition(20, self.rightSize.height/2+65)
	self.m_contentCenterLabel : setAnchorPoint( cc.p(0.0,0.5) )
	self.m_contentCenterLabel : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.m_contentCenterLabel : setDimensions(self.rightSize.width-30, 180)
	self.rightWid : addChild(self.m_contentCenterLabel)

	self.m_contentNoFuJianLabel = _G.Util : createLabel("无", P_FONTSIZE-4)
	-- self.m_contentNoFuJianLabel : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
	self.m_contentNoFuJianLabel : setPosition(80,self.rightSize.height/2-65)
	self.m_contentNoFuJianLabel : setVisible(false)
	self.rightWid : addChild(self.m_contentNoFuJianLabel)

	local function onButtonCallBack(sender, eventType)
		self : emailbtncallback(sender, eventType)
	end
	self.m_contentTiQuBtn = gc.CButton : create("general_btn_gold.png")
	self.m_contentTiQuBtn : setTitleFontName(_G.FontName.Heiti)
	self.m_contentTiQuBtn : setTitleText("提  取")
	self.m_contentTiQuBtn : setTitleFontSize(P_FONTSIZE)
	self.m_contentTiQuBtn : setPosition(self.rightSize.width/2, 45)
	self.m_contentTiQuBtn : addTouchEventListener(onButtonCallBack)
	-- self.m_contentTiQuBtn : setButtonScale(0.8)
	self.m_contentTiQuBtn : setVisible(false)
	self.rightWid : addChild(self.m_contentTiQuBtn)

	--横线
	local uplineSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
	local lineSize = uplineSpr:getContentSize()
	uplineSpr : setPreferredSize(cc.size(self.rightSize.width-20,lineSize.height))
	uplineSpr : setPosition(self.rightSize.width/2,self.rightSize.height-65)
	-- uplineSpr : setOpacity(150)
	self.rightWid : addChild(uplineSpr)

	local downlineSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
	downlineSpr : setPreferredSize(cc.size(self.rightSize.width-20,lineSize.height))
	downlineSpr : setPosition(self.rightSize.width/2,self.rightSize.height/2-15)
	-- downlineSpr : setOpacity(150)
	self.rightWid : addChild(downlineSpr)

	self.m_contentIconbgSpr={1,2,3,4}
	for i=1,4 do
		self.m_contentIconbgSpr[i] = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
		self.m_contentIconbgSpr[i] : setPosition(55+(i-1)*93,self.rightSize.height/2-110)
		self.m_contentIconbgSpr[i] : setVisible(false)
		self.rightWid : addChild(self.m_contentIconbgSpr[i])
	end
end

function EmailView.__showReadEmail( self,_readData,_tempData )
    local scelectMail = _tempData

    local Title = scelectMail.title or "无"
    self.m_contentTitleLabel : setString (Title)

    local Content = _readData.content or ""
    self.m_contentCenterLabel : setString(Content)

    if _readData.pick == 0 or _readData.pick == 2 then
		self.m_contentTiQuBtn : setEnabled(false)
		self.m_contentTiQuBtn : setBright(false)
		self.m_contentTiQuBtn : setTitleText("已提取")
	elseif _readData.pick == 1 then
		self.m_contentTiQuBtn : setEnabled(true)
		self.m_contentTiQuBtn : setBright(true)
		self.m_contentTiQuBtn : setTitleText("提 取")
		self.m_contentTiQuBtn : setTag(_readData.mail_id)
	end

	local function cFun(sender, eventType)
		if eventType==ccui.TouchEventType.ended then	
			local role_tag	= sender : getTag()
			local _pos 	= sender : getWorldPosition()
	        print("选中role_tag:", role_tag)
	        local temp = _G.TipsUtil : createById(role_tag,nil,_pos,0)
	        cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
	    end 
	end

	local goodList=_readData.ugoods_msg or {}
	local isAddReward=false
	for i=1, 4 do
		if goodList[i]~=nil then
			local goodcount = goodList[i].goods_num 
			local goodId    = goodList[i].goods_id
			local goodCnf 	= _G.Cfg.goods[goodId]
			print("请求物品id,数量", goodId,goodcount)
			if goodCnf ~= nil then
    			--传入图片
    			self.m_contentIconbgSpr[i] : removeAllChildren(true)

    			local iconSpr = _G.ImageAsyncManager:createGoodsBtn(goodCnf,cFun,goodId,goodcount)
    			iconSpr : setPosition(P_ICONSIZE.width/2, P_ICONSIZE.height/2)
    			self.m_contentIconbgSpr[i] : addChild(iconSpr)
    			self.m_contentIconbgSpr[i] : setTag(goodId)
    			self.m_contentIconbgSpr[i] : setVisible(true)

    			isAddReward=true
    		end
		else
			print("隐藏")
			self.m_contentIconbgSpr[i]:setVisible(false)
		end
	end

	if isAddReward then
		self.m_contentNoFuJianLabel:setVisible(false)
		self.m_contentTiQuBtn:setVisible(true)
	else
		self.m_contentNoFuJianLabel:setVisible(true)
		self.m_contentTiQuBtn:setVisible(false)
	end
end

function EmailView.__showEmailList( self )
	if self.m_ScrollView ~= nil then
		self.m_ScrollView : removeFromParent(true)
		self.m_ScrollView = nil
	end
	print("self.m_emailListCount",self.m_emailListCount)

	if self.m_emailListCount>0 then
		self.m_noEmailNoticLabel : setVisible(false)
		self.m_noEmailNoticSpr   : setVisible(false)
	else
		self.m_noEmailNoticLabel : setVisible(true)
		self.m_noEmailNoticSpr   : setVisible(true)
		self.m_contentTiQuBtn    : setVisible(false)

		self.m_contentNoFuJianLabel:setVisible(false)
		self.m_contentCenterLabel :setString("")
        self.m_contentTitleLabel  :setString("")
        
        for i=1, 4 do
        	self.m_contentIconbgSpr[i]:setVisible(false)
        end
	end

	local ScrollView = cc.ScrollView : create()
    local viewSize = cc.size(self.kuangSize.width, P_MAILBG_SIZE.height*5)
    local contentSize = cc.size(self.kuangSize.width, P_MAILBG_SIZE.height*self.m_emailListCount)
	ScrollView : setDirection(ccui.ScrollViewDir.vertical)
	ScrollView : setPosition(cc.p(0,6 ))
	ScrollView : setViewSize(viewSize)
	ScrollView : setContentSize(contentSize)
	ScrollView : setContentOffset( cc.p( 0, viewSize.height-contentSize.height ))
	ScrollView : setBounceable(false)
	ScrollView : setTouchEnabled(true)
	self.leftSpr : addChild(ScrollView)

	self.m_ScrollView = ScrollView

	if viewSize.height < contentSize.height then
    	local barView=require("mod.general.ScrollBar")(ScrollView)
  		barView:setPosOff(cc.p(-7,0))
  		-- barView:setMoveHeightOff(50)
    end

	self.m_emailItemBgSpr  = {}
	self.m_emailItemCheckBgSpr = {}
	self.m_emailItemCheckYesSpr = {}
	self.m_emailItemOpenSpr  = {}
	self.m_emailItemFuJianSpr = {}
	self.m_checkEmailArray = {}
	
    --勾选
    local function checkBoxCallBack(sender, eventType)
    	self : onCheckCallBack(sender, eventType)
    end
	
	local function ReturnEmailCount(sender, eventType)
        self : onReturnContent(sender, eventType)
    end
 
	for i = 1, self.m_emailListCount do
		if self.m_emailListData==nil or self.m_emailListData[i]==nil then return end
		local mailId = self.m_emailListData[i].mail_id

		self.m_checkEmailArray[mailId]=false
		print("mailId",mailId,self.m_emailListData[i].state,self.m_emailListData[i].pick)
		self.m_emailItemBgSpr[mailId] = ccui.Scale9Sprite : createWithSpriteFrameName("general_nothis.png")
		self.m_emailItemBgSpr[mailId] : setPreferredSize(cc.size(P_MAILBG_SIZE.width-2, P_MAILBG_SIZE.height-2))
		self.m_emailItemBgSpr[mailId] : setPosition(P_MAILBG_SIZE.width/2+5, (self.m_emailListCount-i)*P_MAILBG_SIZE.height+P_MAILBG_SIZE.height/2-2)	
		ScrollView : addChild(self.m_emailItemBgSpr[mailId])

	    local emailwidgetRight = ccui.Widget:create()
	    emailwidgetRight : setContentSize(cc.size(P_MAILBG_SIZE.width-60, P_MAILBG_SIZE.height-2))
	    emailwidgetRight : setPosition(60, P_MAILBG_SIZE.height/2)
	    emailwidgetRight : setAnchorPoint(cc.p(0.0, 0.5))
	    emailwidgetRight : setTouchEnabled(true)
	    emailwidgetRight : setTag(mailId)
	    emailwidgetRight : setSwallowTouches(false)
	    emailwidgetRight : addTouchEventListener(ReturnEmailCount)
	    self.m_emailItemBgSpr[mailId] : addChild(emailwidgetRight)

		
		if self.m_emailListData[i].pick == 1 then
			self.m_emailItemFuJianSpr[mailId] = cc.Sprite : createWithSpriteFrameName("mail_3.png")
			self.m_emailItemFuJianSpr[mailId]  : setPosition(P_MAILBG_SIZE.width*0.25, P_MAILBG_SIZE.height/2-10)	
			self.m_emailItemBgSpr[mailId] : addChild(self.m_emailItemFuJianSpr[mailId],3)
		end
		

		local image_Spr = "mail_2.png"
		if self.m_emailListData[i].state==0 and i~=1 then
			image_Spr = "mail_1.png"
		end
		self.m_emailItemOpenSpr[mailId] = cc.Sprite : createWithSpriteFrameName(image_Spr)
		self.m_emailItemOpenSpr[mailId] : setPosition(P_MAILBG_SIZE.width*0.23, P_MAILBG_SIZE.height/2-2)	
		self.m_emailItemBgSpr[mailId] : addChild(self.m_emailItemOpenSpr[mailId],2)

		self.m_emailItemCheckBgSpr[mailId]= cc.Sprite : createWithSpriteFrameName("general_gold_floor.png")
		self.m_emailItemCheckBgSpr[mailId]: setPosition(35, P_MAILBG_SIZE.height/2-2)
		self.m_emailItemBgSpr[mailId] : addChild(self.m_emailItemCheckBgSpr[mailId],2)

		self.m_emailItemCheckYesSpr[mailId]= cc.Sprite : createWithSpriteFrameName("general_check_selected.png")
		self.m_emailItemCheckYesSpr[mailId]: setPosition(35, P_MAILBG_SIZE.height/2-2)
		self.m_emailItemCheckYesSpr[mailId]: setVisible(false)
		self.m_emailItemBgSpr[mailId] : addChild(self.m_emailItemCheckYesSpr[mailId],2)

		local emailwidgetLeft = ccui.Widget : create()
		emailwidgetLeft : setTouchEnabled(true)
		emailwidgetLeft : setSwallowTouches(false)
		emailwidgetLeft : setPosition(P_MAILBG_SIZE.width*0.07, P_MAILBG_SIZE.height/2-2)
		emailwidgetLeft : setContentSize(P_MAILBG_SIZE.width*0.2,P_MAILBG_SIZE.height)
		emailwidgetLeft : addTouchEventListener(checkBoxCallBack)
		emailwidgetLeft : setTag(mailId)
		self.m_emailItemBgSpr[mailId] : addChild(emailwidgetLeft,2)

		local EmailTime = self : getTimeStr(self.m_emailListData[i].date) or "2015-01-30 18:30"

    	local EmailTitle = self.m_emailListData[i].title or "[ERROR]"
		print("Title:", EmailTitle)
		local emailLab   = {1,2,3,4}
		local emailLabX  = {P_MAILBG_SIZE.width/4+30, P_MAILBG_SIZE.width/4+30,P_MAILBG_SIZE.width/4+80, P_MAILBG_SIZE.width-60}
		local emailLabY  = {P_MAILBG_SIZE.height-26, 25, 25,25}
 		local e_LabName  = {EmailTitle,"系统", EmailTime, "失效"}
 		local emailFont  = {P_FONTSIZE-4,P_FONTSIZE-4,P_FONTSIZE-4,P_FONTSIZE-4}
		for j = 1, 4  do
			emailLab[j]  = _G.Util : createLabel(e_LabName[j], emailFont[j])
			emailLab[j] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOWISH))
			emailLab[j]  : setPosition(emailLabX[j], emailLabY[j])
			emailLab[j]  : setAnchorPoint( cc.p(0.0, 0.5) )
			self.m_emailItemBgSpr[mailId] : addChild(emailLab[j],2)
		end
		emailLab[1] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN))
		emailLab[1] : setDimensions(175, 30)

		if i==1 then
			-- print("REQ_MAIL_READ",mailId)
			-- local msg = REQ_MAIL_READ()
			-- msg : setArgs(mailId)
			-- _G.Network : send(msg)

			local WidSpr = self:createSelectSpr()
			self.m_emailItemBgSpr[mailId] : addChild(WidSpr)	

			self.m_emailItemCheckYesSpr[mailId] : setVisible(true)
			self.m_checkEmailArray[mailId]= true
			self.m_contentTiQuBtn : setTag(mailId)
			self.m_nowReadEmailId = mailId
		end
	end
	
end

function EmailView.getTimeStr( self, _time)
    local time = os.date("*t",_time)
    print("time",_time)

    if time.month < 10 then time.month = "0"..time.month end
    if time.day < 10 then time.day = "0"..time.day end
    if time.hour < 10 then time.hour = "0"..time.hour
    elseif time.hour < 0 then time.hour = "00" end
    if time.min < 10 then time.min = "0"..time.min
    elseif time.min < 0 then time.min = "00" end

    local time  = time.year.."/"..time.month.."/"..time.day.." "..time.hour..":"..time.min
    print("endtime",time)

    return time
end

function EmailView.removeSelectSpr(self)
	if self.m_selectEmailSpr~=nil then
		self.m_selectEmailSpr:removeFromParent(true)
		self.m_selectEmailSpr = nil 
	end
end
function EmailView.createSelectSpr(self)
	self:removeSelectSpr()

	local widSize  = cc.size(P_MAILBG_SIZE.width-2, P_MAILBG_SIZE.height-2)
	self.m_selectEmailSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_isthis.png")
	self.m_selectEmailSpr : setContentSize(widSize)
	self.m_selectEmailSpr : setPosition(widSize.width/2, widSize.height/2)

	return self.m_selectEmailSpr
end

function EmailView.onReturnContent(self, sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local contentTag = sender : getTag()
		local Position 	= sender : getWorldPosition()
		print("Position.y----->>>11",Position.y,P_WINSIZE.height/2+ P_MAINSIZE.height/2-62,P_WINSIZE.height/2-P_MAINSIZE.height/2+55)
		if Position.y > P_WINSIZE.height/2+ P_MAINSIZE.height/2-62 or 
			Position.y < P_WINSIZE.height/2-P_MAINSIZE.height/2+55 or
			self.m_nowReadEmailId == contentTag then return end

		local msg = REQ_MAIL_READ()
		msg : setArgs(contentTag)
		_G.Network : send(msg)

		local widSpr = self:createSelectSpr()
		self.m_emailItemBgSpr[contentTag] : addChild(widSpr,0)
		
		self.m_emailItemOpenSpr[contentTag] : setSpriteFrame("mail_2.png")

		for i = 1, self.m_emailListCount do
			local MailID = self.m_emailListData[i].mail_id
			self.m_emailItemCheckYesSpr[MailID]: setVisible(false)
			self.m_checkEmailArray[MailID] = false
		end
		self.selectSpr2:setVisible(false)
		self.m_emailItemCheckYesSpr[contentTag]: setVisible(true)
		self.m_checkEmailArray[contentTag] = true
		print("邮件已打开")

		self.m_nowReadEmailId = contentTag
	end
end

function EmailView.emailbtncallback(self, sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local oneTag = sender:getTag()
		local tab = {}
		tab[1] = oneTag
		
		local msg = REQ_MAIL_PICK()
		msg : setArgs(1, tab)
		_G.Network : send(msg)
	end
end

function EmailView.__createEmailListView(self)
	local function onButtonCallBack(sender, eventType)
		self : onBtnCallBack(sender, eventType)
	end

	local e_draw1Btn = gc.CButton : create("general_btn_lv.png")
	e_draw1Btn       : setTitleText("提取勾选")
	e_draw1Btn 		 : setTitleFontName(_G.FontName.Heiti)
	e_draw1Btn       : setTitleFontSize(P_FONTSIZE)
	e_draw1Btn		 : setTag(2)
	e_draw1Btn       : setPosition(self.kuangSize.width/2-15, -45)
	e_draw1Btn  	 : addTouchEventListener(onButtonCallBack)
	-- e_draw1Btn 		 : setButtonScale(0.8)
	self.leftSpr	 : addChild(e_draw1Btn)

	local deleteBtn  = gc.CButton : create("general_btn_gold.png")
	deleteBtn        : setTitleText("删除邮件")
	deleteBtn 		 : setTitleFontName(_G.FontName.Heiti)
	deleteBtn        : setTitleFontSize(P_FONTSIZE)
	deleteBtn		 : setTag(3)
	deleteBtn        : setPosition(self.kuangSize.width-80, -45)
	deleteBtn  	     : addTouchEventListener(onButtonCallBack)
	-- deleteBtn		 : setButtonScale(0.8)
	self.leftSpr	 : addChild(deleteBtn)

	--全选
	self.selectSpr1  = cc.Sprite : createWithSpriteFrameName("general_gold_floor.png")
	self.selectSpr1  : setPosition(43, -44)	
	self.leftSpr	 : addChild(self.selectSpr1)

    self.selectSpr2  = cc.Sprite : createWithSpriteFrameName("general_check_selected.png")
	self.selectSpr2  : setPosition(43, -44)
	self.selectSpr2  : setVisible(false)	
	self.leftSpr	 : addChild(self.selectSpr2)

	local function checkAllCallBack(sender, eventType)
    	self : onEmailAllCallBack(sender, eventType)
    end

	local cancalSize = self.selectSpr2 : getContentSize()
	self.CheckAllwid = ccui.Widget : create()
	self.CheckAllwid : setTouchEnabled(true)
	self.CheckAllwid : setSwallowTouches(true)
	self.CheckAllwid : addTouchEventListener(checkAllCallBack)
	self.CheckAllwid : setPosition(43, -44)
	self.CheckAllwid : setContentSize(cc.size(cancalSize.width*3,cancalSize.height*2))
	self.leftSpr 	 : addChild(self.CheckAllwid)

	local AllLab     = _G.Util : createLabel("全选", P_FONTSIZE-2)
	AllLab 		 	 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN))
	AllLab 		 	 : setPosition(88, -44) 
	self.leftSpr 	 : addChild(AllLab)
end

function EmailView.onEmailAllCallBack(self, sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.m_emailListData == nil or #self.m_emailListData == 0 then
			return
		end
		local isScelect = not self.selectSpr2 : isVisible()
		self.selectSpr2 : setVisible(isScelect)
		
		for mail_id,v in pairs(self.m_emailItemCheckBgSpr) do
			print(" self.m_checkEmailArray[mail_id]", self.m_checkEmailArray[mail_id])
			self.m_checkEmailArray[mail_id] = isScelect
			self.m_emailItemCheckYesSpr[mail_id]  : setVisible(isScelect)
		end
	end
end

function EmailView.onCheckCallBack(self, sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		self.clickTag = sender : getTag()
		local Position 	= sender : getWorldPosition()
		print("Position.y222>>>",self.clickTag,Position.y)
		if Position.y > P_WINSIZE.height/2+ P_MAINSIZE.height/2-32 or 
			Position.y < P_WINSIZE.height/2-P_MAINSIZE.height/2+50 then
			return
		end

		if self.m_checkEmailArray[self.clickTag] == true then
			self.m_checkEmailArray[self.clickTag] = false
			self.m_emailItemCheckYesSpr[self.clickTag] : setVisible(false)
		else
			self.m_checkEmailArray[self.clickTag] = true
			self.m_emailItemCheckYesSpr[self.clickTag] : setVisible(true)
		end

		self.isCheckAll = true
		for mail_id,bool in pairs(self.m_checkEmailArray) do
			if bool==false then
				self.isCheckAll=false
				break
			end
		end
		if self.CheckAllwid ~= nil then
			print("self.isCheckAll",self.isCheckAll)
			self.selectSpr2 : setVisible(self.isCheckAll)
			return true
		end
	end
end

function EmailView.SuccessContent( self, _ackMsg)
	if _ackMsg==nil then return end
    print("成功读取邮件", _ackMsg.mail_id, _ackMsg.state, _ackMsg.pick, _ackMsg.content, _ackMsg.count_v, _ackMsg.count_u)

    local tempData=nil
    for k, value in pairs(self.m_emailListData) do
    	if value.mail_id == _ackMsg.mail_id then
            value.state = _G.Const.CONST_MAIL_STATE_READ
            tempData=value
        end
    end

    print("SSSSSSSSSSSSSSSSS=====>>>>",tempData)

    if tempData==nil then return end
    
    self:__showReadEmail(_ackMsg,tempData)
end

function EmailView.setLabel( self, _data)
    if _data == nil then return end
    print("成功提取邮件", _data.count, _data.id_msg)
    self.m_contentTiQuBtn : setTitleText("已提取")
	self.m_contentTiQuBtn : setEnabled(false)
	self.m_contentTiQuBtn : setBright(false)

	_G.Util:playAudioEffect("ui_message")

	for key, value in pairs( self.m_emailListData) do
        for k, v in pairs(_data.id_msg) do
            if v == value.mail_id and value.pick == _G.Const.CONST_MAIL_ACCESSORY_NO then
                value.pick = _G.Const.CONST_MAIL_ACCESSORY_YES
            end
        end
    end

    for i,v in ipairs(_data.id_msg) do
    	if self.m_emailItemFuJianSpr[v]~=nil then
			self.m_emailItemFuJianSpr[v]:setVisible(false)
		end		
	end				
end

function EmailView.onBtnCallBack(self, sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local btn_tag = sender : getTag()
		self.mail_idArray={}
		for mail_id,bool in pairs(self.m_checkEmailArray) do
			if bool==true then
				print("想干嘛啊：", self.mail_idArray, mail_id)
				table.insert(self.mail_idArray,mail_id)
			end
		end

		if btn_tag == 2 then	
			if #self.mail_idArray>0 then
				print("请求协议")
				local msg = REQ_MAIL_PICK()
				msg : setArgs(#self.mail_idArray, self.mail_idArray)
				_G.Network : send(msg)
			elseif #self.mail_idArray == 0 then
				print("未选中邮件")
				local command = CErrorBoxCommand( 1620 )
	        	controller    : sendCommand( command )
	        end
		elseif btn_tag == 3 then
			print("#self.mail_idArray",#self.mail_idArray)
			if #self.mail_idArray>0 then
				local msg = REQ_MAIL_DEL()
				msg : setArgs(#self.mail_idArray, self.mail_idArray)
				_G.Network : send(msg)
				
			elseif #self.mail_idArray == 0 then
				print("未选中邮件")
				local command = CErrorBoxCommand( 1620 )
	        	controller    : sendCommand( command )
	        end
		end
		return true	
	end
end

function EmailView.setDelView( self, _data)
	if _data.data==nil then return end

    self:removeSelectSpr()

    local newDeleteArray={}
    for i=1,#_data.data do
    	newDeleteArray[_data.data[i]]=true
    end

    local newEmailArray={}
    for i=1,self.m_emailListCount do
    	local tempData=self.m_emailListData[i]
    	if not newDeleteArray[tempData.mail_id] then
    		newEmailArray[#newEmailArray+1]=tempData
    	end
    end

    self.m_emailListData=newEmailArray
    self.m_emailListCount=#self.m_emailListData

    _G.Util:playAudioEffect("ui_sys_clickoff")
    self:__showEmailList()
end

function EmailView.unregister(self)
   self.pMediator : destroy()
   self.pMediator = nil 
end

return EmailView