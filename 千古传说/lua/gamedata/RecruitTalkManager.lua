--[[
******酒馆说话管理类*******

	-- by Chikui Peng
	-- 2016/3/18
]]


local RecruitTalkManager = class("RecruitTalkManager")

RecruitTalkManager.Init_Data             = "RecruitTalkManager.Init_Data";

function RecruitTalkManager:ctor()
    self.isRequest = false
    local delayAppear = {8,17,21}
    self.roleInfo = {
        [1] = {roleId = 6,x = 181,flipX = false,y = 80,scale = 0.7,delay = delayAppear[1]},
        [2] = {roleId = 2,x = 469,flipX = true ,y = 80,scale = 0.7,delay = delayAppear[2]},
        [3] = {roleId = 1,x = 750,flipX = false,y = 80,scale = 0.7,delay = delayAppear[3]}
    }
    TFDirector:addProto(s2c.RECRUIT_INFO, self, self.onReceiveInitData)
end

function RecruitTalkManager:onReceiveInitData( event )
    print("onReceiveInitData")
    hideLoading();
    self:parseData(event.data)
    TFDirector:dispatchGlobalEventWith(self.Init_Data, nil);
end

function RecruitTalkManager:parseData(data)
    local delayAppear = {8,17,21}
    self.roleInfo = {
        [1] = {roleId = 6,x = 181,flipX = false,y = 80,scale = 0.7,delay = delayAppear[1]},
        [2] = {roleId = 2,x = 469,flipX = true ,y = 80,scale = 0.7,delay = delayAppear[2]},
        [3] = {roleId = 1,x = 750,flipX = false,y = 80,scale = 0.7,delay = delayAppear[3]}
    }
    self.talkList = {}
    for k,v in ipairs(data.list) do
        local info = {}
        info.roleId = v.roleId
        info.x = v.x
        info.y = v.y
        info.scale = v.scale / 100
        info.flipX = v.flipX
        info.delay = delayAppear[k]

        self.roleInfo[k] = info
        for _,u in ipairs(v.msg) do
            self.talkList[1+#(self.talkList)] = u
            self.talkList[#(self.talkList)].id = k
        end
    end
    local sortFunc = function(data1,data2)
        if data1.index <= data2.index then
            return true
        end
        return false
    end
    table.sort( self.talkList, sortFunc )
    
end

function RecruitTalkManager:getTalkList()
    local ret = clone(self.talkList or {})
    return ret
end

function RecruitTalkManager:getRoleInfo()
    local ret = clone(self.roleInfo or {})
    return ret 
end

return RecruitTalkManager:new();
