-- 双向队列
local List = class("List")

function List:ctor()
    self.m_list = {};
    -- m_first 第一个元素
    self.m_first = 0;
    -- m_last 最后一个元素
    self.m_last = -1;
end

function List:PushLeft(value)
    local first = self.m_first - 1;
    self.m_first = first;
    self.m_list[first] = value;
end

function List:PushRight(value)
    local last = self.m_last + 1;
    self.m_last = last;
    self.m_list[last] = value;
end

function List:PopLeft()
    local first = self.m_first;
    if(first > self.m_last) then
        error("List is empty!");
    end

    local value = self.m_list[first];

    self.m_list[first] = nil;           -- 垃圾回收

    self.m_first = first + 1;

    return value;
end

function List:PopRight()
    local last = self.m_last;
    if(self.m_first > last) then
        error("List is empty!");
    end

    local value = self.m_list[last];

    self.m_list[last] = nil;            -- 垃圾回收

    self.m_last = last - 1;

    return value;
end

function List:IsEmpty()
    -- 为空
    if(self.m_first > self.m_last) then
        return true;
    else
        return false;
    end
end

-- 队列中元素个数
function List:Size()
    return tablenums(self.m_list);
end

return List;