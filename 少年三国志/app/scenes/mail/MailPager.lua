local MailPager = class ("MailPager")

--分页功能

--listData: 全部数据
--pageRows: 一页多少个

function MailPager:ctor( onDataCallback  )
    self._currentPage = 0
    self._pageRows = 7
    self._onDataCallback = onDataCallback
    self._tag = 0

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MAIL_CONTENT_READY, self._onMailContentReady, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MAIL_LIST_UPDATE, self._onMailListUpdate, self) 

end

function MailPager:setTag(tag)
    self._currentPage = 0
    self._tag = tag
    self._list = G_Me.mailData:getMailList(self._tag) 
end



function MailPager:clear()
    uf_eventManager:removeListenerWithTarget(self)

end


function MailPager:getList( )
    if self:hasNextPage() then
        self._currentPage = self._currentPage + 1
        local hungryList = self:_getHungryList()
        if #hungryList > 0 then
            G_HandlersManager.mailHandler:sendGetMail(hungryList) 
        else
            self._onDataCallback(self:_getReadyList())
        end
    else
        self._onDataCallback(self:_getReadyList())
    end
    
end

--取得当前已经准备好的所有数据
function MailPager:_getReadyList( )
    local indexBegin = 1
    local indexEnd = self:_getIndexEnd()
    
    local list = {}
    local i


    for i=indexBegin,indexEnd do
        local mail = self._list[i]
        
        if mail.content ~= nil then
           table.insert(list,  mail) 
        end
    end
    return list
end

--取得还没准备好数据的列表
function MailPager:_getHungryList( )
    local indexBegin = 1
    local indexEnd = self:_getIndexEnd()
    
    local list = {}
    local i
    for i=indexBegin,indexEnd do
        local mail = self._list[i]
        
        if mail.content == nil then
           table.insert(list,  mail.tempid) 
        end
    end
    return list
end

--是否有下一页
function MailPager:hasNextPage( )
    local indexEnd = self._currentPage *self._pageRows
    if indexEnd >= #self._list then
        return false
    else
        return true
    end
end

function MailPager:_onMailListUpdate(...)
    self:setTag(self._tag)
end

function MailPager:_onMailContentReady(...)
    local list = self:_getReadyList()

   
    self._onDataCallback(list)
end

function MailPager:getCurrentPage()
    return self._currentPage
end

function MailPager:_getIndexEnd()
    local indexBegin = 1
    local indexEnd = self._currentPage *self._pageRows
    if indexEnd > #self._list then
        indexEnd = #self._list
    end
    return indexEnd
end

function MailPager:getLength()
    return self:_getIndexEnd()
end

function MailPager:getPageRows()
    return self._pageRows
end
return MailPager

