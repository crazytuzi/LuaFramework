--MessageSender.lua


local MessageSender = class ("MessageSender")

function MessageSender:ctor(  )
end

function MessageSender:sendMsg( msgId, content )
print("==============sendMsg ===================")
	print("url " .. msgId)
	print("===============end sendMsg=================")
	uf_netManager:sendMsg(msgId, content)
end

return MessageSender