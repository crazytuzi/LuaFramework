local ContainerEMail = {}

local var = {}

local MAIL_STATES = {
	RECEIVE	= 1,
	DELETE	= 2,
}

function ContainerEMail.initView(event)
	var = {
		xmlPanel,

		boxMailContent,
		lblNoMails,
		scrollMailContent,
		listMails,

		btnGetAward,
		btnDeleteMail,
		btnCleanMails,
		btnOnekeyAward,
		pushItem,
		openState = false,
		
		isReceive,
		pushItemIdx = 1,
		Text_day,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerEMail.uif")
	if var.xmlPanel then

		var.boxMailContent	= var.xmlPanel:getWidgetByName("box_mail_content"):hide()
		var.lblNoMails		= var.xmlPanel:getWidgetByName("lbl_no_mails"):setVisible(false)
		var.listMails		= var.xmlPanel:getWidgetByName("list_mails")
		var.btnGetAward		= var.xmlPanel:getWidgetByName("btn_get_award")
		var.btnDeleteMail	= var.xmlPanel:getWidgetByName("btn_delete_mail")
		var.btnCleanMails	= var.xmlPanel:getWidgetByName("btn_clean_mails")
		var.btnOnekeyAward	= var.xmlPanel:getWidgetByName("btn_onekey_award")
		var.scrollMailContent	= var.xmlPanel:getWidgetByName("scroll_mail_content")--
		--var.Text_day		= var.xmlPanel:getWidgetByName("Text_day")	

		--display.newRect(cc.rect(260, 363, 550, 25), {fillColor = cc.c4f(0, 0, 0, 0.5)}):addTo(var.boxMailContent, -1)
		--display.newRect(cc.rect(260, 109, 550, 25), {fillColor = cc.c4f(0, 0, 0, 0.5)}):addTo(var.boxMailContent, -1)


		var.btnGetAward:addClickEventListener(function (sender)
			if var.pushItemIdx and GameSocket.mails[var.pushItemIdx] then
				if sender.state == MAIL_STATES.RECEIVE then
				
					GameSocket:getMailAward(GameSocket.mails[var.pushItemIdx].id)
					--GameSocket:getMails()
				end
			end
		end)
		var.btnDeleteMail:addClickEventListener(function (sender)
			if var.pushItemIdx and GameSocket.mails[var.pushItemIdx] then
				print(MAIL_STATES.DELETE,sender.state)
				if sender.state == MAIL_STATES.DELETE then
					GameSocket:deleteMail(GameSocket.mails[var.pushItemIdx].id)
				else
					GameSocket:alertLocalMsg("还有附件未提取！", "alert")
				end
			end
		end)

		var.btnCleanMails:addClickEventListener(function (sender)
			for i=1,#GameSocket.mails do 	
				if GameSocket.mails[i].isReceive~=0  or  #GameSocket.mails[i].item == 0  then 
					GameSocket:deleteMail(GameSocket.mails[i].id)
				else
					GameSocket:alertLocalMsg("还有附件未提取！", "alert")	
					--break
				end	
			end 
		end)

		var.btnOnekeyAward:addClickEventListener(function (sender)

			for i=1,#GameSocket.mails do 
				GameSocket:getMailAward(GameSocket.mails[i].id)		
			end 
		end)
		
		cc.EventProxy.new(GameSocket, var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_GET_MAILS, ContainerEMail.refreshPanel)

		return var.xmlPanel
	end
end

function ContainerEMail.onPanelOpen()
	var.openState = true
	GameSocket:getMails()
end 

function ContainerEMail.refreshPanel(event)
	if not var.openState then return end
	local function itemCallBack(sender)
		if GameUtilSenior.isObjectExist(var.pushItem) then
			var.pushItem:setTouchEnabled(true)
			var.pushItem:getParent():getWidgetByName("img_highlight"):hide()
			var.pushItem:getParent():getWidgetByName("lbl_mail_title")
		end
		sender:setTouchEnabled(false)
		sender:getParent():getWidgetByName("img_highlight"):show()
		sender:getParent():getWidgetByName("lbl_mail_title")
		var.pushItem	= sender
		var.pushItemIdx	= sender.tag
		var.isReceive	= sender.isReceive
		ContainerEMail.updateMailContent(sender.tag)
		
		var.btnGetAward:setVisible(0==var.isReceive)
		if sender.isReceive == 0 and  #GameSocket.mails[sender.tag].item > 0 then  
			var.btnGetAward.state = MAIL_STATES.RECEIVE
			var.btnDeleteMail.state = MAIL_STATES.RECEIVE
		else
			var.btnDeleteMail.state = MAIL_STATES.DELETE
			var.btnGetAward.state = MAIL_STATES.DELETE	
			var.btnGetAward:setVisible(false)
		end
		ContainerEMail.handleRedPoint(sender:getParent(), sender.tag)
	end

	local function updateItem(item)
		
		item:getWidgetByName("img_highlight"):hide()

		local time =GameSocket.mails[item.tag].date
		local re_time=math.floor(15-tonumber((os.time()-time)/3600/24))

		item:getParent():getWidgetByName("lbl_day_remain"):setString("剩余"..re_time.."天"):enableOutline(GameBaseLogic.getColor(0x000000), 1)
		item:getParent():getWidgetByName("lbl_mail_from"):enableOutline(GameBaseLogic.getColor(0x000000), 1)
		if re_time==0 then 
			--if GameSocket.mails[item.tag].isReceive~=0  or  #GameSocket.mails[item.tag].item == 0  then 
				GameSocket:deleteMail(GameSocket.mails[item.tag].id)
			--end
		elseif re_time<0 then 
			item:getParent():getWidgetByName("lbl_day_remain"):setVisible(false)
		end 

		local lbl_mails = item:getWidgetByName("lbl_mail_title"):setTouchEnabled(false):enableOutline(GameBaseLogic.getColor(0x000000), 1)
		lbl_mails:setString(GameSocket.mails[item.tag].title)

		--lbl_mails:setColor((var.pushItemIdx == item.tag and GameBaseLogic.getColor(GameConst.tabVColor[1])) or GameBaseLogic.getColor(GameConst.tabVColor[2]))

		local render_bg = item:getWidgetByName("render")
		render_bg:setTouchEnabled(true):setSwallowTouches(false)
		render_bg.tag = item.tag

		render_bg.isReceive = GameSocket.mails[item.tag].isReceive
		render_bg:addClickEventListener(itemCallBack)
		if item.tag == var.pushItemIdx then
			itemCallBack(render_bg)
		end
		ContainerEMail.handleRedPoint(item, item.tag)
	end

	var.pushItem = nil

	var.pushItemIdx = 1
	var.listMails:reloadData(#GameSocket.mails,updateItem)
	var.listMails:show()

	var.boxMailContent:setVisible(#GameSocket.mails > 0)
	var.lblNoMails:setVisible(#GameSocket.mails == 0)
	-- for i=1,#GameSocket.mails do 
	-- 	if #GameSocket.mails[i].item == 0 then 
	-- 		var.btnOnekeyAward:setVisible(false)
	-- 	end 
	-- end 	

end

function ContainerEMail.updateMailContent(mailIdx)
	print(mailIdx,"==============")
	local singleMail = GameSocket.mails[mailIdx]
	if singleMail then
		GameSocket:readMail(singleMail.id)
		singleMail.isOpen = 1
		if GameUtilSenior.checkMailPriority(singleMail) == 0 then--如果看过后没有红点了，则tips的个数和红点提示相应的要修改
			if table.indexof(GameSocket.tipsMsg["tip_mail"], singleMail.id) then
				table.remove(GameSocket.tipsMsg["tip_mail"])
				cc.UserDefault:getInstance():setStringForKey("Mail_tips","1")
				GameSocket:dispatchEvent({name = #GameSocket.tipsMsg["tip_mail"] > 0 and GameMessageCode.EVENT_SHOW_REDPOINT or GameMessageCode.EVENT_REMOVE_REDPOINT, lv = 8,index = 1})
				
			end
		end
		
		--:setString(singleMail.content)

		--local scroll = var.xmlPanel:getWidgetByName("npc_scroll")
		var.scrollMailContent:setContentSize(cc.size(450, 200))
		var.scrollMailContent:setInnerContainerSize(cc.size(450, 200))
		var.scrollMailContent:setClippingEnabled(true)
		-- var.scrollMailContent:removeAllChildren()
		local innerSize = var.scrollMailContent:getInnerContainerSize()
		local contentSize = var.scrollMailContent:getContentSize()
		local labelTalk = var.scrollMailContent:getWidgetByName("labelTalk")
		if not labelTalk then
			labelTalk = GUIRichLabel.new({size=cc.size(contentSize.width-20, 0), space=20,})
				:align(display.LEFT_BOTTOM,0,0)
				:addTo(var.scrollMailContent)
				:setName("labelTalk")
		end
		local msgSize = labelTalk:setRichLabel(singleMail.content, "", 20)
		if msgSize.height < contentSize.height then
			labelTalk:setPosition(cc.p(0,contentSize.height-msgSize.height))
		end

		var.scrollMailContent:setInnerContainerSize(cc.size(innerSize.width,msgSize.height))
		
		var.scrollMailContent:setBounceEnabled(true)

		--var.scrollMailContent:setBounceEnabled(false)

		var.xmlPanel:getWidgetByName("text_mail_title"):setString(GameSocket.mails[mailIdx].title)
		ContainerEMail.updateTime(singleMail.date)

		for i = 1, 5 do
			local icon = var.xmlPanel:getWidgetByName("img_mailIcon_"..i)
			if i <= #singleMail.item then
				local param = {
					parent = icon,
					typeId = singleMail.item[i].id,
					num = singleMail.item[i].count
				}
				GUIItem.getItem(param)
				icon:setVisible(GameSocket.mails[mailIdx].isReceive==0)
			else
				icon:hide()
			end
		end

		-- if GameSocket.mails[mailIdx].isReceive==1 then 
		-- 	for i = 1, 5 do
		-- 		local icon = var.xmlPanel:getWidgetByName("img_mailIcon_"..i)
		-- 		icon:hide()
		-- 	end
		-- end
	end
end

function ContainerEMail.updateTime(timeSecond)
	--local object6 = item:getWidgetByName("object6"):
	--object6:setString(GameSocket.mails[3].title)
	local date = os.date("%Y年%m月%d日", timeSecond)
	local week = GameConst.nums[tonumber(os.date("%w", timeSecond))]
	local amOrPm = os.date("%p", timeSecond) == "AM" and "上午" or "下午"
	local time = os.date("%I:%M", timeSecond)
	return var.xmlPanel:getWidgetByName("text_mail_time"):setString(string.format("%s  %s%s", date,  amOrPm, time))
end

function ContainerEMail.handleRedPoint(widget, tag)
	
	if GameUtilSenior.checkMailPriority(GameSocket.mails[tag])==1 then 
		widget:getWidgetByName("lbl_read_flag"):setColor(cc.c3b(255,62,63))
	else
		widget:getWidgetByName("lbl_read_flag"):setColor(cc.c3b(24,209,41))
	end
	widget:getWidgetByName("lbl_read_flag"):setString(GameUtilSenior.checkMailPriority(GameSocket.mails[tag])==1 and "(未读)" or "(已读)"):enableOutline(GameBaseLogic.getColor(0x000000), 1)
	 
	if GameUtilSenior.checkMailPriority(GameSocket.mails[tag])==1 then 
		widget:getWidgetByName("render"):loadTexture("img_mail_item_unread",ccui.TextureResType.plistType)
	else 
		widget:getWidgetByName("render"):loadTexture("img_mail_item_read",ccui.TextureResType.plistType)
	end 

	if #GameSocket.mails[tag].item>0 then 
		print("---tag",tag,GameSocket.mails[tag].isReceive)
		if GameSocket.mails[tag].isReceive==0 then 
			--widget:getWidgetByName("img_item_flag"):setVisible(true)
		else
			--widget:getWidgetByName("img_item_flag"):setVisible(false)
			
			widget:getWidgetByName("lbl_read_flag"):setString("(已读)")
			widget:getWidgetByName("lbl_read_flag"):setColor(cc.c3b(24,209,41))
			widget:getWidgetByName("render"):loadTexture("img_mail_item_read",ccui.TextureResType.plistType)

			
		end
	else
		--widget:getWidgetByName("img_item_flag"):setVisible(false)
	end
	
end

function ContainerEMail.onPanelClose()
	var.openState = false

	var.pushItemIdx = 1
	--var.listMails:updateCellInView()

	ContainerEMail.refreshPanel()
	GameSocket.tipsMsg["tip_mail"] = {}
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_BOTTOM, str = "tip_mail", noAction = true})
end

return ContainerEMail