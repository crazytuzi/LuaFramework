local mailbox = class( "mailbox", layout );

global_event.MAILBOX_SHOW = "MAILBOX_SHOW";
global_event.MAILBOX_UPDATE = "MAILBOX_UPDATE";
global_event.MAILBOX_HIDE = "MAILBOX_HIDE";
global_event.MAILBOX_OPEN_MAIL = "MAILBOX_OPEN_MAIL";

global_event.MAILBOX_NUM_UPDATE = "MAILBOX_NUM_UPDATE";

function mailbox:ctor( id )
	mailbox.super.ctor( self, id );
	self:addEvent({ name = global_event.MAILBOX_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.MAILBOX_UPDATE, eventHandler = self.onUpdate});	
	self:addEvent({ name = global_event.MAILBOX_HIDE, eventHandler = self.onHide});
	
	self:addEvent({ name = global_event.MAILBOX_OPEN_MAIL, eventHandler = self.OnshowSingleMail});
	
end

function mailbox:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	self.detailMails = {}
    self.detailMails.MailRoot = engine.LoadWindowFromXML("mailcontainer.dlg")
	self.detailMails.mailcontainer_title_name = engine.GetGUIWindowWithName("mailcontainer-title-name")
	self.detailMails.mailcontainer_scro  = LORD.toScrollPane(engine.GetGUIWindowWithName("mailcontainer-scro"))
	self.detailMails.mailcontainer_scro:init()
	self.detailMails.mailcontainer_title_name:SetText("")	
	self.detailMails.MailRoot:SetVisible(false)
	
	self.mailbox_tips = engine.GetGUIWindowWithName("mailbox-tips")
	self.mailbox_tips:SetVisible(false)
	function onClickCloseMailInfo()	
		 self.selectMail = nil		
		 self.detailMails.MailRoot:SetVisible(false)
		 engine.centerWnd(self._view)  
	
	end		
	--self.detailMails.mailcontainer_close  = (engine.GetGUIWindowWithName("mailcontainer-close"))
	--self.detailMails.mailcontainer_close:subscribeEvent("ButtonClick", "onClickCloseMailInfo")	  
		
	 
	self._view:AddChildWindow(self.detailMails.MailRoot)
	
 
	self.mailbox_scroll = LORD.toScrollPane(self:Child( "mailbox-scroll" ));
	self.mailbox_num = self:Child( "mailbox-num" );
	self.mailbox_close = self:Child( "mailbox-close" );
	self.mailbox_scroll:init();
	
	self.selectMail = nil
	function onClickCloseMail()	
		self:onHide();
	end		
	self.mailbox_close:subscribeEvent("ButtonClick", "onClickCloseMail")	
	self.mailbox_num:SetText("")
	
  
end

 
function mailbox:onUpdate(event)
	if( false == self._show)then return end
	self:update()
end	
function mailbox:update()
	self.mailbox_scroll:ClearAllItem() 
		
	local xpos = LORD.UDim(0, 10)
	local ypos = LORD.UDim(0, 10)
    local all  = 0
	local read = 0
	all,read = dataManager.mailData:getCount()
	self.mailbox_num:SetText(read.."/"..all)
	local mails = dataManager.mailData:getMails()
	local num = table.nums(mails)
	if(num ~= 0 and num ~= all)then
		print(num.." - "..all)
	end
 
	function onTouchDownMail(args)	
		local clickImage = LORD.toWindowEventArgs(args).window
 		local userdata = clickImage:GetUserData()
		for i,v in pairs (self.allPreView) do
			--v:SetProperty("ImageName",  "set:maincontrol.xml image:taskcontainer1")
			if(v and v.mailitem_chose)then
				v.mailitem_chose:SetVisible(false);
			end
		end	
		if(clickImage and clickImage.mailitem_chose)then
			clickImage.mailitem_chose:SetVisible(true);
		end
		--clickImage:SetProperty("ImageName",  "set:maincontrol.xml image:taskcontainer2")	
		--print("onTouchDownMail")			
		if(userdata ~= -1)then
			--local mail =  dataManager.mailData:getMail(userdata)		 			 
		end				
 	end	 
	function onTouchUpMail(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()
 
		if(userdata ~= -1)then
			local mail =  dataManager.mailData:getMail(userdata)		
			self.selectMail = userdata
			--self:showMailDetail()		
			sendaskMaillOpen(mail:getId())				
		end
 	end	 		
	function onTouchReleaseMail(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()
	
		if(userdata == -1)then
			return
		end
		local mail =  dataManager.mailData:getMail(userdata)	
		
 	end	 	
	local selMailPos = 0
	self.allPreView = {}
	for i,v in ipairs (mails) do
	 	local mailInstance = v				
	 	if mailInstance then						
		 	local prew = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("mailitem_"..i, "mailitem.dlg");
			local icon = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("mailitem_"..i.."_mailitem-item-image"))
			local title = LORD.GUIWindowManager:Instance():GetGUIWindow("mailitem_"..i.."_mailitem-name")
			local sender = LORD.GUIWindowManager:Instance():GetGUIWindow("mailitem_"..i.."_mailitem-addresser_1")
			local time = LORD.GUIWindowManager:Instance():GetGUIWindow("mailitem_"..i.."_mailitem-time")
			
			local mailitem_chose = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("mailitem_"..i.."_mailitem-chose"))
		 	prew:SetPosition(LORD.UVector2(xpos, ypos));											
			self.mailbox_scroll:additem(prew);
			prew.mailitem_chose = mailitem_chose
		 	local width = prew:GetWidth()
		 	xpos = xpos + width			
			xpos = LORD.UDim(0, 10)
			ypos = ypos + prew:GetHeight() + LORD.UDim(0, 5)	
		---	print("ypos "..ypos.offset.." scale "..ypos.scale);		
		 	icon:SetImage(mailInstance:getIcon())
		 	prew:subscribeEvent("WindowTouchDown", "onTouchDownMail")
	 		prew:subscribeEvent("WindowTouchUp", "onTouchUpMail")
	 		prew:subscribeEvent("MotionRelease", "onTouchReleaseMail")
	 		prew:SetUserData(mailInstance:getId())
			self.selectMail = self.selectMail or mailInstance:getId()
			
			if(mailInstance:getId() == self.selectMail)then
				--prew:SetProperty("ImageName",  "set:maincontrol.xml image:taskcontainer2")
				mailitem_chose:SetVisible(true);
				selMailPos = ypos.offset
			else
				--prew:SetProperty("ImageName",  "set:maincontrol.xml image:taskcontainer1")	
				mailitem_chose:SetVisible(false);
			end	
			 
		 	 						
			title:SetText(mailInstance:getTitle())	
			sender:SetText(mailInstance:getSender())	
			table.insert(self.allPreView,prew)
			local str = os.date("%x",mailInstance:getTime());
			time:SetText(str)				
	 	end		
	end		
 

 	local mail =  dataManager.mailData:getMail(self.selectMail )		
 	if(mail and  ( true ~= self.mailOpened) )then		
		
		self.selectMail = mail:getId()
		sendaskMaillOpen(mail:getId())		
	end
	self.mailbox_tips:SetVisible(num <=0 )
	
	--self.mailbox_scroll:SetVertScrollOffset( self.mailbox_scroll:GetPixelSize().y - selMailPos  )
end	
	
function mailbox:onHide(event)
	self:Close();
	self.selectMail = nil
	self.mailOpened = nil
end

function mailbox:OnshowSingleMail(event)
	if not  self._show then
		return;
	end
	self.mailOpened = true
	self:showMailDetail()
	
end

function mailbox:showMailDetail()
 
	self.detailMails.mailcontainer_scro:ClearAllItem();
	if(self.selectMail == -1 or self.selectMail == nil)then
		return 
	end	
	local mail =  dataManager.mailData:getMail(self.selectMail )
	if(mail == nil)then
		return
	end
 
	self.detailMails.mailContext = LORD.toLayout(engine.LoadWindowFromXML("mailtext.dlg"))
	self.detailMails.mailContext_mailtext_text  = engine.GetGUIWindowWithName("mailtext-text")
	
	self.detailMails.mailContext_mailtext_text_title  = engine.GetGUIWindowWithName("mailtext-text-title")
	
	
	self.detailMails.mailtext_mailtext_mailawardlo  = LORD.toLayout(engine.GetGUIWindowWithName("mailtext-mailtext-mailawardlo"))
 
	self.detailMails.mailContext_mailtext_addresser  = engine.GetGUIWindowWithName("mailtext-addresser")
	
	--self.detailMails.mailContext:LayoutChild() 
	self.detailMails.mailContext_money ={}
	self.detailMails.mailContext_itemIcon ={}
	self.detailMails.mailContext_itemNum = {}
	self.detailMails.mailaward_money_icon = {}
	self.detailMails.mailContext_itemStar = {}
	self.detailMails.mailContext_itemEquity = {}
	self.detailMails.mailContext_itemStars = {}
	
	self.detailMails.mailtext_mailtext_gift  = engine.GetGUIWindowWithName("mailtext-mailtext-gift")
	
	self.detailMails.mailtext_mailaward_moneybar1  = engine.GetGUIWindowWithName("mailtext-mailaward-moneybar1")
    self.detailMails.mailtext_mailaward_moneybar2  = engine.GetGUIWindowWithName("mailtext-maildaward-moneybar2")
	self.detailMails.mailtext_mailtext_gift  = engine.GetGUIWindowWithName("mailtext-mailtext-gift")
	
	
	
	for i =1 ,6 do
		self.detailMails.mailContext_money[i] =  engine.GetGUIWindowWithName("mailtext-mailaward-money"..i.."-text")
		self.detailMails.mailContext_money[i]:SetText("")	 
		self.detailMails.mailaward_money_icon[i] =  LORD.toStaticImage(engine.GetGUIWindowWithName("mailtext-mailaward-money"..i))
	end	
	
	
	for i =1 ,4 do
		self.detailMails.mailContext_itemIcon[i] =  LORD.toStaticImage(engine.GetGUIWindowWithName("mailtext-mailaward-money"..i.."-image"))		
		self.detailMails.mailContext_itemNum[i] =  engine.GetGUIWindowWithName("mailtext-mailaward-money"..i.."-num")
		
		self.detailMails.mailContext_itemStar[i] =  LORD.toStaticImage(engine.GetGUIWindowWithName("mailtext-mailaward-item"..i))
		self.detailMails.mailContext_itemEquity[i] = LORD.toStaticImage(engine.GetGUIWindowWithName("mailtext-mail-item"..i.."-equity"));
		
		self.detailMails.mailContext_itemStar[i]:SetImage(itemManager.getImageWithStar()) 
		self.detailMails.mailContext_itemEquity[i]:SetImage(itemManager.getImageWithStar()) 
		
		self.detailMails.mailContext_itemStars[i] = {}
		for k =1 ,5 do
			self.detailMails.mailContext_itemStars[i][k] =  LORD.toStaticImage(engine.GetGUIWindowWithName("mailtext-item"..i.."-star"..k))
		end
		self.detailMails.mailContext_itemNum[i]:SetText("")	 
		self.detailMails.mailContext_itemIcon[i]:SetImage("") 		
	end	
 	--self.detailMails.mailContext_mailtext_mailaward_button  = engine.GetGUIWindowWithName("mailtext-mailaward-button")
	self.detailMails.mailContext_mailtext_mailaward_button  = engine.GetGUIWindowWithName("mailcontainer-mailaward-button")
	self.detailMails.mailcontainer_mailaward_buttondel  = engine.GetGUIWindowWithName("mailcontainer-mailaward-buttondel")
	

	
	---收取邮件
	function onClickGet(args)	
		if(self.selectMail == nil)then
			return 
		end
		
		if(global.tipBagFull())then
			return
		end	
		
		local window = LORD.toWindowEventArgs(args).window;
		self.mailOpened = nil
		local mail =  dataManager.mailData:getMail(self.selectMail )
		if(mail == nil )then
			return 
		end
		
		function mailbox_onconfirmDelMail()
				local mail =  dataManager.mailData:getMail(self.selectMail )
				if(mail == nil )then
					return 
				end
				if(self.detailMails.MailRoot)then
					self.detailMails.MailRoot:SetVisible(false)	
				end
				self.selectMail = nil			
				sendaskMaillDelete(mail:getId())
		end
		if(window:GetUserData() == 1)then
			sendaskMaillGetItemAll(mail:getId())	
			mailbox_onconfirmDelMail()
		else
			eventManager.dispatchEvent( {name = global_event.CONFIRM_SHOW, callBack = mailbox_onconfirmDelMail,text = "您确定要删除此邮件吗？" })	   
		end
			
	
		
	end		
	self.detailMails.mailContext_mailtext_mailaward_button:subscribeEvent("ButtonClick", "onClickGet")		
	self.detailMails.mailcontainer_mailaward_buttondel:subscribeEvent("ButtonClick", "onClickGet")	 
	self.detailMails.mailContext_mailtext_mailaward_button:SetUserData(1)
	self.detailMails.mailcontainer_mailaward_buttondel:SetUserData(0)
	--[[
 
	local size1 =  self._view:GetPixelSize()	
	local size2 =  self.detailMails.MailRoot:GetPixelSize()	
	local x = (engine.rootUiSize.w - size1.x - size2.x)/2
	local y = (engine.rootUiSize.h- size1.y)/2
	local xpos = LORD.UDim(0, x)
	local ypos = LORD.UDim(0, y)	
	self._view:SetPosition(LORD.UVector2(xpos, ypos));	
		
	xpos = LORD.UDim(0,  size1.x)
	ypos = LORD.UDim(0, 0)
	self.detailMails.MailRoot:SetPosition(LORD.UVector2(xpos, ypos))	
 ]]--

 
	self.detailMails.MailRoot:SetVisible(true)
	local mail =  dataManager.mailData:getMail(self.selectMail )
	
	self.detailMails.mailContext_mailtext_text_title:SetText(mail:getTitle())
	self.detailMails.mailcontainer_title_name:SetText(mail:getTitle())	
	self.detailMails.mailContext_mailtext_text:SetText(mail:getText())	 
	self.detailMails.mailContext_mailtext_addresser:SetText(mail:getSender())	 

	local reward =  mail:getATTACHMENT()
 	for i =1 ,6 do	
		self.detailMails.mailContext_money[i]:SetText("")	 
		self.detailMails.mailaward_money_icon[i]:SetVisible(false) 
	end	
	
	for i =1 ,4 do	
		self.detailMails.mailContext_money[i]:SetText("")	 
		self.detailMails.mailContext_itemNum[i]:SetText("")	 
		self.detailMails.mailContext_itemIcon[i]:SetImage("") 
		self.detailMails.mailaward_money_icon[i]:SetVisible(false) 
		self.detailMails.mailContext_itemStar[i]:SetVisible(false)
		
		for k =1 ,5 do
			self.detailMails.mailContext_itemStars[i][k]:SetVisible(false)
		end
 
	end	
	
	local itemNum = 0
	local otherReward = 0
	--local hasItem = false
	for i, v in pairs(reward) do
		if(v.type ~= enum.REWARD_TYPE.REWARD_TYPE_MONEY  )then
			--hasItem = true
			itemNum = itemNum +1
			self.detailMails.mailContext_itemStar[itemNum]:SetVisible(true)
			local prew = self.detailMails.mailContext_itemIcon[itemNum]
			prew:SetUserData(v.subType);	
			local _maskicon = nil
			local icon = nil
			local star  = 0
			local count = v.overlay
			local _isDebris = false
			local showstar = 0;
			
			if(enum.REWARD_TYPE.REWARD_TYPE_CARD_EXP == v.type )then
					icon = dataConfig.configs.unitConfig [dataConfig.configs.unitCompatableConfig[v.subType].id].icon
				    star = cardData.getStarByExp(count);
				   showstar = star;
					if table.find(dataConfig.configs.ConfigConfig[0].startLevelTable, count) then
						count = 1;
					else
						_maskicon = "corpsmask.png";
					end
					
			elseif(enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP == v.type )then
			
				
				icon =   dataManager.kingMagic:getSkillConfig(v.subType).icon
				star = dataManager.kingMagic:getStarByExp(count);
				prew:SetUserData(dataManager.kingMagic:mergeIDLevel(v.subType, star));
				showstar = star;
				if table.find(dataConfig.configs.ConfigConfig[0].magicLevelExp, count) then
					count = 1;
				else
					maskicon = "corpsmask.png";
				end	
				
			elseif(enum.REWARD_TYPE.REWARD_TYPE_ITEM == v.type )then
				local config = itemManager.getConfig(v.subType)
				icon = config.icon
				star = config.star;
				showstar = 0;
					if itemManager.getConfig(v.subType).type == enum.ITEM_TYPE.ITEM_TYPE_DEBRIS then
						 _maskicon = "itemmask.png";
					end	
			end
			_isDebris = _maskicon ~= nil;
			
			prew:SetImage(icon) 
			if(count <=1)then
				count = ""
			end
			self.detailMails.mailContext_itemNum[itemNum]:SetText(count)
			self.detailMails.mailContext_itemStar[itemNum]:SetImage(itemManager.getBackImage(_isDebris)) 
			self.detailMails.mailContext_itemEquity[itemNum]:SetImage(itemManager.getImageWithStar(star, _isDebris)) 
			
			global.onItemTipsShow(prew, v.type, "top");
			global.onItemTipsHide(prew);
			for k =1 ,5 do
				if(k <= showstar )then
					self.detailMails.mailContext_itemStars[itemNum][k]:SetVisible(true)
				end
			end
		
		else
			otherReward = otherReward + 1		
			if(otherReward <=6)then
				self.detailMails.mailContext_money[otherReward]:SetText(v.overlay)	 
				self.detailMails.mailaward_money_icon[otherReward]:SetVisible(v.overlay >= 0) 	
				local icon = enum.MONEY_ICON_STRING[v.subType]
				self.detailMails.mailaward_money_icon[otherReward]:SetImage(icon) 		
			end
		end
				
	end			
	
	if(otherReward <=0 )then
			self.detailMails.mailtext_mailaward_moneybar1:SetVisible(false)
			self.detailMails.mailtext_mailaward_moneybar2:SetVisible(false)
	elseif(otherReward <=3  )then
			self.detailMails.mailtext_mailaward_moneybar1:SetVisible(true)
			self.detailMails.mailtext_mailaward_moneybar2:SetVisible(false)
	
	end
	
	if(itemNum<=0)then
		self.detailMails.mailtext_mailtext_gift:SetVisible(false)
	end
	
	if(otherReward <=0 and itemNum <= 0)then
		self.detailMails.mailContext_mailtext_mailaward_button:SetVisible(false)
		self.detailMails.mailcontainer_mailaward_buttondel:SetVisible(true)
	else
		self.detailMails.mailContext_mailtext_mailaward_button:SetVisible(true)
		self.detailMails.mailcontainer_mailaward_buttondel:SetVisible(false)
	end	
 	--self.detailMails.mailtext_mailtext_gift:SetVisible(hasItem)
	self.detailMails.mailtext_mailtext_mailawardlo:LayoutChild() 
	self.detailMails.mailContext:LayoutChild() 
	self.detailMails.mailcontainer_scro:additem(self.detailMails.mailContext)
end
	

return mailbox;
