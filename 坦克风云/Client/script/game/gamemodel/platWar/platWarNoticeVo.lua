platWarNoticeVo={}
function platWarNoticeVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

--index         计数器 设置tag标记,点击显示聊天信息时 取数据用
--type          在哪个标签显示类型 1.世界 2.阵营
--platform      平台类型,efun_tw
--contentType   内容类型 2.需要getlocal，1.不需要
--content       聊天信息内容
--sender            发送者id
--senderName        发送者昵称
--reciver           接收者id
--reciverName       接收者昵称
--params        参数，需要什么传什么
--                  1.uid   id
--                  2.name  昵称
--                  3.level 等级
--                  4.rank  军衔
--                  5.power 战力
--                  6.pic   头像
--msgData       聊天内容数据，前台显示需要
--time          时间
function platWarNoticeVo:initWithData(index,type,platform,contentType,content,sender,senderName,reciver,reciverName,params,msgData,time)
    self.index=index
    self.type=type
    self.platform=platform
    self.contentType=contentType
    self.content=content
    self.sender=sender
    self.senderName=senderName
    self.reciver=reciver
    self.reciverName=reciverName
    self.params=params
    self.msgData=msgData
    self.time=time
end