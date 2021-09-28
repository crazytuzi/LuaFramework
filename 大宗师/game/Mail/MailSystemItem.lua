--[[
 --
 -- add by vicky
 -- 2014.12.02 
 --
 --]]

 require("utility.richtext.richText") 


 local MailSystemItem = class("MailSystemItem", function()
 		return CCTableViewCell:new() 
 end)


 function MailSystemItem:getContentSize()
 	if self._contentSz == nil then 
	 	local proxy = CCBProxy:create() 
	 	local rootnode = {} 
	 	local node = CCBuilderReaderLoad("mail/mail_system_item.ccbi", proxy, rootnode) 
	 	self._contentSz = rootnode["item_bg"]:getContentSize() 
	end 
	
 	return self._contentSz 
 end 


 function MailSystemItem:create(param) 
 	local viewSize = param.viewSize 
 	local itemData = param.itemData 
 	local getMoreMailFunc = param.getMoreMailFunc 
 	self._mailTotalNum = param.totalNum 
 	self._curMailNum = param.curMailNum 
 	self._isCanShowMoreBtn = param.isCanShowMoreBtn 
 	self._id = param.id 

 	local proxy = CCBProxy:create() 
 	self._rootnode = {} 
 	local node = CCBuilderReaderLoad("mail/mail_system_item.ccbi", proxy, self._rootnode) 
 	node:setPosition(viewSize.width/2, 0) 
 	self:addChild(node) 

 	self:refreshItem(itemData) 

 	return self 
 end 


 function MailSystemItem:refresh(param) 
 	self._id = param.id 
 	self:refreshItem(param.itemData) 
 end 


 function MailSystemItem:refreshItem(itemData) 
 	if self._isCanShowMoreBtn and self._id == self._curMailNum then 
 		self._rootnode["normal_node"]:setVisible(false) 
 		self._rootnode["getMore_tag"]:setVisible(true) 

 	else 
 		self._rootnode["normal_node"]:setVisible(true) 
 		self._rootnode["getMore_tag"]:setVisible(false) 

 		self._rootnode["time_lbl"]:setString(tostring(itemData.disDay)) 
	 	self._rootnode["title_lbl"]:setString(tostring(itemData.title)) 

	 	local contentNode = self._rootnode["content_tag"] 
	 	contentNode:removeAllChildren() 
	 	
	 	local richHtmlText = itemData.richHtmlText 
	 	local infoNode = getRichText(richHtmlText, contentNode:getContentSize().width) 
	 	infoNode:setPosition(0, contentNode:getContentSize().height - 30) 
	 	contentNode:addChild(infoNode) 
 	end  
 end 


 return MailSystemItem   

