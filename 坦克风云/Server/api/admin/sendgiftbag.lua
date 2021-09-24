--
-- desc: 发送礼包邮件
-- user: chenyunhe
--
local function api_admin_sendgiftbag(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
    }
   
    function self.action_send(request)
        local response = self.response
        local uid = tonumber(request.uid) or  0
        local gid = request.params.gid -- 礼包id
        local cdkey = gid..'_'..uid
        
        if uid < 1 or not gid then
            response.ret = -1
            return response
        end
        local reward = getConfig("giftCfg."..gid)
        if type(reward)~='table' then
            response.ret = -6
            return response
        end

        -- 获取发送记录
        local function getSendLog(gid)
            local db = getDbo()
            local result = db:getRow("select * from giftbag where uid= :uid and cdkey = :cdkey",{uid=uid,cdkey=cdkey})
            if type(result) == 'table' and next(result) then
                return true
            end
        end

        local function createLog(giftlog)
            local db = getDbo()
            local ret = db:insert('giftbag',giftlog)
            local queryStr = db:getQueryString() or ''
            if not ret  then
               return false
            end

            return true
        end

        -- 已经发过邮件
        if getSendLog(gid) then
            response.ret = -8
            response.msg = 'Success'
            return response
        else
            local giftlog = {
                cdkey = cdkey,
                uid = uid,
                zoneid = getZoneId(),
                updated_at = getClientTs(),      
            }

            if not createLog(giftlog) then
                response.ret = -9
                return response
            end
        end
     
        local URL = require "lib.url"
        --local content = URL:url_unescape('尊敬的指挥官：您好，恭喜您成功获得《超级舰队》礼包，请及时领取，祝您游戏愉快！')
        local item = {}
        item.h=reward.h
        item.q=reward.q
        -- 邮件标题客户端是写的固定的 不读服务器的(暂时传个标题)
        local ret = MAIL:mailSent(uid,0,uid,'','',reward.n,reward.n,1,0,6,item)
        
        if ret then
            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end
    
    return self
end

return api_admin_sendgiftbag
