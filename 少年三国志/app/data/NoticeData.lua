local NoticeData =  class("NoticeData")

function NoticeData:ctor()
    self._noticeList = nil
end

function NoticeData:addNotice(data)
    if self._noticeList == nil then
        self._noticeList = {}
    end
    table.insert(self._noticeList,1,data)
end


function NoticeData:getNotice()
    if self._noticeList and #self._noticeList > 0 then
        local _data = self._noticeList[#self._noticeList]
        table.remove(self._noticeList, #self._noticeList)
        return _data
    else
        return nil
    end
end

function NoticeData:clear()
    self._noticeList = nil
end

return NoticeData
