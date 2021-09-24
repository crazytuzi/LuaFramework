chatVo={}
function chatVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

--index			计数器 设置tag标记,点击显示聊天信息时 取数据用
--type			在哪个标签显示类型 1.世界 2.私聊 3.联盟
--subType		内容显示的频道类型	1.世界 2.私聊 3.联盟 4.系统 5.GM
--contentType	内容类型 1.聊天信息 2.战报 3.系统消息  (4.游戏数据更新，不存)
--content		聊天信息内容
--sender			发送者id
--senderName		发送者昵称
--reciver			接收者id
--reciverName		接收者昵称
--params		参数，需要什么传什么
--					1.uid	id
--					2.name	昵称
--					3.level	等级
--					4.rank	军衔
--					5.power 战力
--					6.pic	头像
--                    isVipV 日本vip特殊要求（nil：显示具体等级（默认），非nil:不显示具体等级）
--msgData		聊天内容数据，前台显示需要
--time			时间
function chatVo:initWithData(index,type,subType,contentType,content,sender,senderName,reciver,reciverName,params,msgData,time)
	self.index=index
	self.type=type
	self.subType=subType
	self.contentType=contentType
	self.content=content
	self.sender=sender
	self.senderName=senderName
	self.reciver=reciver
	self.reciverName=reciverName
	self.params=params
	self.msgData=msgData
	self.time=time
	self.showTranslate=false
	-- if(params and params.transData)then
	-- 	self.translateContent=params.transData
	-- 	self.showTranslate=true
	-- else
	-- 	self.translateContent=nil
	-- 	self.showTranslate=false
	-- end
end

function chatVo:updateTransData(msg,lang)
	if(self.translateContent==nil)then
		self.translateContent={}
	end
	self.translateContent[lang]=msg
	if(self.msgData==nil)then
		self.msgData={}
	end
	local maxHeight=self.msgData.height
	if(maxHeight==nil)then
		maxHeight=0
	end
	local width,height=chatVoApi:getMessage(nil,nil,nil,nil,msg,nil,{})
	if(height>maxHeight)then
		self.msgData.height=height
	end
end