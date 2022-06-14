local mailData = class("mailData")
local attCollectionClass  = include("attCollection")

 
function mailData:ctor()
	self.att = attCollectionClass.new()	
	self:setReadFlag(false)	
	self:setTitle("")
	self:setTime(0)	
	self:setText("")	
	self:setWildCardParams(nil)	
	self.add = {}
	self:setIcon("i1056.jpg")
	self:setSender("天灾军团")
end

local MAIL_ATT_TITLE = "MAIL_ATT_TITLE"
local MAIL_ATT_SENDER = "MAIL_ATT_SENDER"
local MAIL_ATT_TIME = "MAIL_ATT_TIME"
local MAIL_ATT_TEXT = "MAIL_ATT_TEXT"
local MAIL_ATT_ID = "MAIL_ATT_ID"
local MAIL_ATT_READED = "MAIL_ATT_READED"
local MAIL_ATT_RECEIVED = "MAIL_ATT_RECEIVED"
local MAIL_ATT_WILDCARDPARAM = "MAIL_ATT_WILDCARDPARAM"

local MAIL_ATT_INDEX = "MAIL_ATT_INDEX"

local MAIL_ATT_ICON = "MAIL_ATT_ICON"


function mailData:getWildCardParams()
	return self.att:getAttr(MAIL_ATT_WILDCARDPARAM)		
end 

function mailData:setWildCardParams(p)
	self.att:setAttr(MAIL_ATT_WILDCARDPARAM,p)		
end
function mailData:getIcon()
	return self.att:getAttr(MAIL_ATT_ICON)		
end 

function mailData:setIcon(s)
	self.att:setAttr(MAIL_ATT_ICON,s)		
end 
 
function mailData:getTitle()
	return self.att:getAttr(MAIL_ATT_TITLE)		
end 

function mailData:setTitle(title)
	self.att:setAttr(MAIL_ATT_TITLE,title)		
end 	

function mailData:getSender()
	return self.att:getAttr(MAIL_ATT_SENDER)		
end 

function mailData:setSender(sender)
	 self.att:setAttr(MAIL_ATT_SENDER,sender)		
end 	
function mailData:getTime()
	return self.att:getAttr(MAIL_ATT_TIME)		
end 

function mailData:setTime(t)
		
	if(type(t) == "userdata")then
		t= t:GetUInt()	 
	else
		t = t		
	end	

	self.att:setAttr(MAIL_ATT_TIME,t)		
end 	

function mailData:getText()
	local text = self.att:getAttr(MAIL_ATT_TEXT)		
	local param = self:getWildCardParams()
	local str = string.format(text,unpack(param))
 
	return str
end 

function mailData:setText(t)
	
    --t  = string.gsub(t, "@name", dataManager.playerData:getName())	
	-- t  = string.gsub(t, "%%s", dataManager.playerData:getName())	                                               ")	
	 self.att:setAttr(MAIL_ATT_TEXT,t)		
end 	

function mailData:getId()
	return self.att:getAttr(MAIL_ATT_ID)		
end 

function mailData:setId(t)
	 self.att:setAttr(MAIL_ATT_ID,t)		
end 	

--[[
function mailData:getIndex()
	return self.att:getAttr(MAIL_ATT_INDEX)		
end 

function mailData:setIndex(t)
	 self.att:setAttr(MAIL_ATT_INDEX,t)		
end 	

]]--

function mailData:getReadFlag()
	return self.att:getAttr(MAIL_ATT_READED)		
end 

function mailData:setReadFlag(t)
	 self.att:setAttr(MAIL_ATT_READED,t)		
end 	

function mailData:getReceivedFlag()
	return self.att:getAttr(MAIL_ATT_RECEIVED)		
end 

function mailData:setReceivedFlag(t)
	 self.att:setAttr(MAIL_ATT_RECEIVED,t)		
end 	

function mailData:addATTACHMENT(data,index)
	local t ={}	

	t.id = data['id'] --id 服务失效了
	t.type = data['type']
	t.subType = data['subType']
	t.overlay = data['overlay']
 
	self.add[index]	 = t
end 

function mailData:getATTACHMENT()
 
	return self.add
end 

local mail = class("mail")

function mail:ctor()
	 	
	self.mails = {}
	self.id = 0
	self.allCount = 0
	self.readCount = 0
end

function mail:createMail(index)
	self.mails[index]  = nil
	local temMail  = mailData.new()			
	self.mails[index] = temMail	
	--temMail:setIndex(index)
	return temMail
end 	

function mail:getMail(id)
	for i,v in pairs (self.mails) do
		if(v:getId() == id)then
			return v
		end				
	end			
	return nil	
end 	

function mail:delMail(id)
	for i,v in pairs (self.mails) do
		if(v:getId() == id)then
			table.remove(self.mails,i)
		end				
	end				
end 	


function mail:getMails( )
	
	function pack_sort_mail(a,b)
		
		if(a:getTime() == b:getTime() )then
			return a:getId() > b:getId()
		end
		
		return 	 a:getTime() > b:getTime() 
	
		
	end
	table.sort(self.mails,pack_sort_mail)
	return self.mails 
end 	

function mail:setCount(all,read)
	self.allCount = all
	self.readCount = read
end
function mail:getCount()
	return self.allCount,self.readCount
end

function mail:isHaveUnreadMail()
	return self.readCount > 0;
end

return mail