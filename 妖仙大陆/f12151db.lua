local Util = require "Zeus.Logic.Util"

local UserDataValueExt = {}
Util.WrapOOPSelf(UserDataValueExt)

function UserDataValueExt.New(userDataNotify, addCb, subCb, notEqualCb)
    local o = {}
    setmetatable(o, UserDataValueExt)
    o:_init(userDataNotify, addCb, subCb, notEqualCb)
    return o
end

function UserDataValueExt:getValue()
    return self._oldValue
end

function UserDataValueExt:start()
    self._oldValue = DataMgr.Instance.UserData:TryToGetLongAttribute(self._userDataNotify, 0)
    DataMgr.Instance.UserData:AttachLuaObserver(self._uniqueInt, {Notify=self._self__onNotify})
end
function UserDataValueExt:stop()
    DataMgr.Instance.UserData:DetachLuaObserver(self._uniqueInt)
end

function UserDataValueExt:_init(userDataNotify, addCb, subCb, notEqualCb)
    self._addCb = addCb
    self._subCb = subCb
    self._notEqualCb = notEqualCb
    self._userDataNotify = userDataNotify
    self._uniqueInt = Util.GetUniqueInt()
end

function UserDataValueExt:_onNotify(status, userData)
    if userData:ContainsKey(status, self._userDataNotify) then
        local nowValue = userData:TryToGetLongAttribute(self._userDataNotify, 0) 
        if nowValue ~= self._oldValue then
            local oldValue = self._oldValue
            self._oldValue = nowValue
            if self._notEqualCb then
                self._notEqualCb(nowValue, oldValue)
            end
            if oldValue < nowValue and self._addCb then
                self._addCb(nowValue, oldValue)
            elseif oldValue < nowValue and self._subCb then
                self._subCb(nowValue, oldValue)
            end
        end
    end
end

return UserDataValueExt
