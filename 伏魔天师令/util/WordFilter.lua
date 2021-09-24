require "config@cn.w_cnf"
local WordFilter={}
function WordFilter.hasBanWord(self,sentence)
    local word = _G.Cfg.w
    for k,v in pairs(word) do
        local res = string.find(sentence, v) 
        if res ~= nil and res > 0 then
            return true
        end
    end
    return false
end

function WordFilter.replaceBanWord(self,sentence)
    local word = _G.Cfg.w
    for k,v in pairs(word) do
        if v ~= nil and type(v) == "string" then
            local res = string.find(sentence, v)
            if res ~= nil and res > 0 then
                sentence = string.gsub(sentence, v, string.rep("*", string.len(v)))
            end
        end
    end
    return sentence
end

function WordFilter.getCharCountByUTF8(self,str)
    local len = #str
    local left = len
    local cnt = 0
    local arr = {0,0xc0,0xe0,0xf0,0xf8,0xfc}
    local tempList = {}
    while left~=0 do
        local tmp=string.byte(str,-left)
        local i=#arr
        while arr[i] do
            if tmp>=arr[i] then left=left-i break end
            i=i-1
        end
        cnt=cnt+1
        tempList[cnt]=i
    end
    return cnt,tempList
end

function WordFilter.checkString(self,_szStr)
    if self:hasBanWord(_szStr) then
        local command=CErrorBoxCommand(_G.Lang.ERROR_N[32])
        controller:sendCommand(command)
        return false
    end
    return true
end

function WordFilter.checkName(self,_szName)
    local charNum,charBitArray=self:getCharCountByUTF8(_szName)
    local bitNum=string.len(_szName)
    CCLOG("checkName===>>>  charNum=%d,bitNum=%d",charNum,bitNum)

    if charNum<2 or bitNum<5 then
        local command=CErrorBoxCommand("名称太短")
        controller:sendCommand(command)
        return false
    elseif charNum>6 then
        if (charNum==8 and bitNum<=10) or (charNum==7 and bitNum<=11) then
            print("yes,no too long...")
        else
            local command=CErrorBoxCommand("名称太长")
            controller:sendCommand(command)
            return false
        end
    end

    if self:hasBanWord(_szName) then
        local command=CErrorBoxCommand(_G.Lang.ERROR_N[32])
        controller:sendCommand(command)
        return false
    end
    return true
end

return WordFilter
