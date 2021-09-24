friendGiftVo={}
function friendGiftVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function friendGiftVo:initWithData(param)
	self.id=param[1]						--礼物的id
	self.selfid=param[2]					--自己的id
	self.senderid=param[3]					--赠送者的id，如果这是一条索要信息，那么这个ID是自己的id，如果是一条赠送信息，那么这个ID是好友的ID
	self.receiverid=param[4]				--接受者的id，如果这是一条索要信息，那么这个ID是好友的id，如果是一条赠送信息，那么这个ID是自己的ID
	self.sendername=tostring(param[5])		--赠送者的名字，同上
	self.receivername=tostring(param[6])	--接受者的名字，同上
end

--判断该条请求是好友赠送还是好友索取
--返回true表示是赠送，false表示是索要
function friendGiftVo:checkIfGift()
	if(tonumber(self.senderid)==tonumber(playerVoApi:getUid()))then
		return false
	else
		return true
	end
end