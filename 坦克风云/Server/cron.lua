package.path = "/usr/local/tank/tank-lua/share/lua/5.2/?.lua;" .. package.path
package.cpath = "/usr/local/tank/tank-lua/lib/lua/5.2/?.so;" .. package.cpath
package.path = "/usr/local/tank/tank-luascripts/?.lua;" .. package.path

-- package.path = "./?.lua;./lualib/?.lua;./luascripts/?.lua;" .. package.path
-- package.cpath = "./luaclib/?.so"

package.path = "/usr/local/tank/tank-lua/share/lua/5.2/?.lua;" .. package.path
package.cpath = "/usr/local/tank/tank-lua/lib/lua/5.2/?.so;" .. package.cpath
package.path = "/usr/share/lua/5.2/?.lua;" .. package.path
package.cpath = "/usr/lib64/lua/5.2/?.so;" .. package.cpath
package.cpath = "/usr/lib/lua/5.2/?.so;" .. package.cpath

package.path = "/opt/tankserver/embedded/share/lua/5.2/?.lua;" .. package.path
package.cpath = "/opt/tankserver/embedded/lib/lua/5.2/?.so;" .. package.cpath

require "lib.string"
require "lib.func"
require "lib.mail"
require "lib.userobjs"
require "lib.ranking"
require "api.cron.refnewrank"


ptb = require "lib.ptb"
json = require "cjson.safe"
M_alliance = require "model.alliance"

local zoneid = tonumber(arg[1])

local function setAutoAttackBossQueue()
    local db = getDbo()
    local weet = getWeeTs()
    local sql = string.format("select uid from worldboss where attack_at >= %d and book = 1",weet)
    local result = db:getAllRows(sql)

    for k,v in pairs(result) do
        if v and v.uid then
                local uid = tonumber(v.uid) or 0
                if uid > 0 then 
                        getUserObjs(uid,true).getModel('worldboss').addBookQueue()
                end
        end
    end
end

if zoneid then
    setZoneId(zoneid)
    refreshChallengeRanking()
    refreshFcRanking()
    refreshHonorsRanking()
    api_cron_refnewrank({params={}})

    -- 击杀赛
    local libKillRace = loadModel("lib.killrace")
    if libKillRace.isOpen() then
    	libKillRace.refreshRanking()
    	libKillRace.refreshGradeRanking()
    end

    -- 自动攻击BOSS的玩家队列
    setAutoAttackBossQueue()
end
