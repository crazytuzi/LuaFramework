local updateSceneBtn = function(isNew)

    local isRed = false
    if G_MAIL_INFO and G_MAIL_INFO.emaliCount then
      isRed = G_MAIL_INFO.emaliCount > 0 

    end
    if G_MAINSCENE and G_MAINSCENE.__mailRed then G_MAINSCENE.__mailRed:setVisible( isRed ) end
    if G_MAINSCENE and G_MAINSCENE.__mailRed2 then G_MAINSCENE.__mailRed2:setVisible( isRed ) end

    if not isRed then
      if G_MAINSCENE and G_MAINSCENE.mailFlag then
        removeFromParent( G_MAINSCENE.mailFlag ) 
        G_MAINSCENE.mailFlag = nil 
      end
    else
    	if G_MAINSCENE  then G_MAINSCENE:showMail() end
    end
    
    
	if G_MAINSCENE  then
		if G_MAINSCENE.__MaileListRefresh  then G_MAINSCENE.__MaileListRefresh() end
	end

end

local formatMail = function( _item )
	local newData = {}
	newData.emailIDX = _item.emailId
	newData.title = _item.title
	newData.desc = _item.desc
	newData.sender = _item.sender
	newData.sender = game.getStrByKey("system")
	newData.startDate = _item.startDate
	newData.endDate = _item.endDate

	local awards = { }
	newData.itemCount = #_item.items
	newData.items={}

	for _ , v in ipairs( _item.items ) do
		local tempTab ={}
		tempTab.id = v.itemId
		tempTab.num = v.count
		tempTab.isBind = v.bind 
		tempTab.showBind = true

		tempTab.streng = v.strength
		tempTab.time = v.timeout
		awards[ #awards + 1 ] = tempTab
	end

	--实例物品奖励处理（主要用于物品找回，注释掉的字段暂时没用上 ）
	for _ , v in ipairs( _item.insItems ) do
		local tempTab ={}
		tempTab.id = v.protoId
		tempTab.num = v.count
		tempTab.isBind = v.bind
		tempTab.showBind = true
		tempTab.streng = v.strength
		
		awards[ #awards + 1 ] = tempTab


		-- optional uint32 slot = 1;
		-- optional uint32 tlimit = 4;
		-- optional uint32 luck = 7;
		-- optional uint32 stallprice = 8;
		-- optional uint32 stalltime = 9;
		-- repeated PBAttr attrs = 10;
		-- optional string guid = 11;
		-- optional uint32 upStallTime=12;
	end


	newData.awards = awards


	--超链接处理
	if _item.hyperlink ~= "" and _item.linkContent~= "" then
		newData.hyperlink = _item.hyperlink	--链接地址
		newData.linkContent = _item.linkContent--链接文字
	end

	local params = _item.params
	local templateId = _item.descId
	if templateId > 0 then
		local mailInfo = getConfigItemByKey("MailCfg","q_ID",templateId)
		newData.title = mailInfo.q_title
		newData.sender = mailInfo.q_sender
		newData.desc = mailInfo.q_content
		newData.desc = string.format(newData.desc,params[1],params[2],params[3],params[4],params[5],params[6],params[7])
	end
	
	table.insert( G_MAIL_INFO.emailInfo , 1 , newData )
end

local onRecvMail = function(luabuffer)
	local t = g_msgHandlerInst:convertBufferToTable( "ItemEmailProtocol" , luabuffer ) 
	G_MAIL_INFO.emaliCount = #t.emails
	if not G_MAIL_INFO.emailInfo then
		G_MAIL_INFO.emailInfo={}
	end

	for i=1,G_MAIL_INFO.emaliCount do
		formatMail( t.emails[i] )
	end
	
	updateSceneBtn()
end





local onNewMail = function(luabuffer)
	local t = g_msgHandlerInst:convertBufferToTable( "EmailProtocol" , luabuffer ) 

	AudioEnginer.playLiuEffect("sounds/liuVoice/35.mp3",false)

	if not G_MAIL_INFO.emaliCount then
		G_MAIL_INFO.emaliCount = 1
	else
		G_MAIL_INFO.emaliCount = G_MAIL_INFO.emaliCount+1
	end
	if not G_MAIL_INFO.emailInfo then
		G_MAIL_INFO.emailInfo={}
	end

	formatMail( t )
        
	updateSceneBtn(1)
end
                      
local onReadMail = function(luabuffer)
	local t = g_msgHandlerInst:convertBufferToTable( "ItemPickEmailRetProtocol" , luabuffer ) 
	
	local toDel = t.emailId
	for i=1,G_MAIL_INFO.emaliCount do
		if G_MAIL_INFO.emailInfo[i].emailIDX == toDel then
			table.remove(G_MAIL_INFO.emailInfo,i)
			G_MAIL_INFO.emaliCount = G_MAIL_INFO.emaliCount-1
			break
		end
	end
	updateSceneBtn()
end

g_msgHandlerInst:registerMsgHandler(ITEM_SC_EMAILUPDATE,onRecvMail)
g_msgHandlerInst:registerMsgHandler(ITEM_SC_EMAILADD,onNewMail)
g_msgHandlerInst:registerMsgHandler(ITEM_SC_PICKEMAIL,onReadMail)