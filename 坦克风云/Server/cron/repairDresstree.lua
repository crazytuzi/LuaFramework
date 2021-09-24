--
-- 活动 装扮圣诞树 修复充值钻石数据
-- User: chenyunhe
-- Date: 2018-01-12
--
package.path = "../?.lua;" .. package.path

-- sh lua.sh repairDresstree.lua a

require "dispatch"

function writeSuccessLog(zid,message)
    message = message or ''
    local logpath = "/tmp/dresstree/"
    local fileName = logpath ..zid..'.log'

    if type(message) == 'table' then
        message = (json.encode(message) or '') .. '\r\n'
    else
        message = message .. '\r\n'
    end
  
    local f = io.open(fileName, "a+")
    if f then
        f:write(message)
        f:close()
    end
end

local zid = arg[1]
setZoneId(zid)

local db = getDbo()
local result = db:getAllRows("select distinct(`userid`) from tradelog where create_time>=1515168000 and create_time<=1515729600 and status = 1")
if type(result)=='table' and next(result) then
    for k,v in pairs(result) do
        local uid = tonumber(v.userid)
        local charges = db:getAllRows("select num from tradelog where userid = :userid and create_time>=1515168000 and create_time<=1515729600 and status = 1",{userid=uid})
        if type(charges)=='table' and next(charges) then
            local uobjs = getUserObjs(uid)
            uobjs.load({'useractive'})
            local mUseractive = uobjs.getModel('useractive')
            if type(mUseractive.info['dresstree'])=='table' and not mUseractive.info['dresstree'].fix then
                local total = 0
                local single = 0
                for ck,cv in pairs(charges) do
                   local gems = tonumber(cv.num)
                   total  =  total + gems
                   if gems >= 268 then
                        mUseractive.info['dresstree'].single = mUseractive.info['dresstree'].single + 1
                        single = single + 1
                   end
                end

                mUseractive.info['dresstree'].gem = mUseractive.info['dresstree'].gem + total
                mUseractive.info['dresstree'].fix = 1
                if uobjs.save() then
                    writeSuccessLog(zid,'uid__'..uid.."__gem__"..total.."__gingle__"..single)
                end
            end
        end
    end
end

ptb:p('end')




  


