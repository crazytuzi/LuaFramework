-- 好友信息

local FriendData = class("FriendData")

function FriendData:ctor()
    self._list = {}
    self._friendIndex = {}
    self._blackList = {}
    self._blackIndex = {}
    self._addList = {}
    self._addIndex = {}
    self._presentLeft = 30
    self._presentMax = 30
    self._newFriend = false
    self._sugCount = 0
    self._friendSugList = nil
end

function FriendData:sugCountMM()
    if self._sugCount > 0 then
        self._sugCount = self._sugCount - 1
    end
end

function FriendData:sugStartCount()
    self._sugCount = 10
end

function FriendData:getSugCount()
    return self._sugCount
end

function FriendData:setFriendSugList(data)
    self._friendSugList = data
end

function FriendData:getFriendSugList()
    return self._friendSugList
end

--排序,在线,等级
local sortFunc = function(a,b)

    if a.present and not b.present then
        return true
    end

    if not a.present and b.present then
        return false
    end

    if a.online == 0 and b.online > 0 then
        return true
    end

    if a.online > 0 and b.online == 0 then
        return false
    end
    
    if a.online == b.online then
        return a.level > b.level
    else
        return a.online > b.online
    end

end

function FriendData:setFriendList(fl)
    table.sort(fl, sortFunc)
    self._list = fl
    for i,v in ipairs(self._list) do
        self._friendIndex[v.name] = v
    end
end

function FriendData:setBlackList(fl)
    table.sort(fl, sortFunc)
    self._blackList = fl
    for i,v in ipairs(self._blackList) do
        self._blackIndex[v.name] = v
    end
end

function FriendData:setAddList(fl)
    self._addList = {}
    for k , v in pairs(fl) do 
        if v.online == 0 or (G_ServerTime:getTime() - v.online < 7*24*60*60) then
            table.insert(self._addList,#self._addList+1,v)
        end
    end
    table.sort(self._addList, sortFunc)
    -- self._addList = fl
    for i,v in ipairs(self._addList) do
        self._addIndex[v.name] = v
    end
end

function FriendData:isFriend(name)
    if self._friendIndex[name] == nil then
        return false
    end
    return true
end

function FriendData:isBlack(name)
    if self._blackIndex[name] == nil then
        return false
    end
    return true
end

function FriendData:isAdd(name)
    if self._addList[name] == nil then
        return false
    end
    return true
end

function FriendData:getFriendByUid(uid)
    if  self._list == nil then
        return nil
    end
    for k,v in pairs(self._list) do
        if v.id == uid then
            return v
        end
    end
    
    return nil
end

function FriendData:getBlackByUid(uid)
    if  self._blackList == nil then
        return nil
    end
    for k,v in pairs(self._blackList) do
        if v.id == uid then
            return v
        end
    end
    
    return nil
end

function FriendData:getAddByUid(uid)
    if  self._addList == nil then
        return nil
    end
    for k,v in pairs(self._addList) do
        if v.id == uid then
            return v
        end
    end
    
    return nil
end


function FriendData:getFriendList()
    return self._list
end

function FriendData:getPresentFriendList()
    local preList = {}
    for k,v in pairs(self._list) do
        if v.getpresent then
            table.insert(preList, #preList + 1, v)
        end
    end
    return preList
end

function FriendData:getBlackList()
    return self._blackList
end

function FriendData:getAddList()
    return self._addList
end

function FriendData:canAddBlack()
    return #self._blackList < 100
end

function FriendData:updatePresent(uid, present,getpresent)
    local f = self:getFriendByUid(uid)
    if f then
        f.present = present
        f.getpresent = getpresent
    end
    table.sort(self._list, sortFunc)
end

function FriendData:updatePresentRev(uid)
    local f = self:getFriendByUid(uid)
    if f then
        -- f.present = false
        f.getpresent = false
    end
end

function FriendData:deleteFriend(uid)
    for k,v in ipairs(self._list) do
        if v.id == uid then
            self._friendIndex[v.name] = nil
            table.remove(self._list, k)
            break
        end
    end
end

function FriendData:deleteBlack(uid)
    for k,v in ipairs(self._blackList) do
        if v.id == uid then
            self._blackIndex[v.name] = nil
            table.remove(self._blackList, k)
            break
        end
    end
end

function FriendData:deleteAdd(uid)
    for k,v in ipairs(self._addList) do
        if v.id == uid then
            self._addIndex[v.name] = nil
            table.remove(self._addList, k)
            break
        end
    end
end

function FriendData:addFriend(friend)
    table.insert(self._list, #self._list+1, friend)
    self._friendIndex[friend.name] = friend
    self:deleteBlack(friend.id)
end

function FriendData:addBlack(friend)
    table.insert(self._blackList, #self._blackList+1, friend)
    self._blackIndex[friend.name] = friend
    self:deleteFriend(friend.id)
end

function FriendData:addAdd(friend)
    table.insert(self._addList, #self._addList+1, friend)
    self._addList[friend.name] = friend
end

function FriendData:getPresentLeft()
    return self._presentLeft
end

function FriendData:setPresentLeft(used)
    self._presentLeft = self._presentMax - used
end

function FriendData:setPresentLeftDir(left)
    self._presentLeft = left
end

function FriendData:usePresent(used)
    self._presentLeft = self._presentLeft - used
end

function FriendData:setNewFriend(newFriend)
    self._newFriend = newFriend
end

function FriendData:getNewFriend()
    return self._newFriend
end

function FriendData:hasNew()
    if self._newFriend then
        return true
    elseif #self:getPresentFriendList() > 0 and self:getPresentLeft() > 0 then
        return true
    end
    return false
end


return FriendData
