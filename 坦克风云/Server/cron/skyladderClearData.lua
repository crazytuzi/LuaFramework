package.path = "../?.lua;" .. package.path

require "dispatch"
ptb = require "lib.ptb"
require "lib.mysql"

local secretkey = getConfig("base.SECRETKEY")
local ts = os.time()
local db = getCrossDbo("skyladderserver")
local base = db:getRow("select * from skyladder_status where id='status' limit 1") or {}

writeLog(ts,'skyladderClear')
if base.cubid and base.lsbid then
    db:query("DELETE FROM tank_kuafu.skyladder_allianceinfo where bid !="..base.cubid.." and bid !="..base.lsbid.." and bid !="..tonumber(base.cubid) + 1)
    db:query("DELETE FROM tank_kuafu.skyladder_alliancelog where bid !="..base.cubid.." and bid !="..base.lsbid.." and bid !="..tonumber(base.cubid) + 1)
    db:query("DELETE FROM tank_kuafu.skyladder_list where bid !="..base.cubid.." and bid !="..base.lsbid.." and bid !="..tonumber(base.cubid) + 1)
    db:query("DELETE FROM tank_kuafu.skyladder_memlist where bid !="..base.cubid.." and bid !="..base.lsbid.." and bid !="..tonumber(base.cubid) + 1)
    db:query("DELETE FROM tank_kuafu.skyladder_personinfo where bid !="..base.cubid.." and bid !="..base.lsbid.." and bid !="..tonumber(base.cubid) + 1)
    db:query("DELETE FROM tank_kuafu.skyladder_personlog where bid !="..base.cubid.." and bid !="..base.lsbid.." and bid !="..tonumber(base.cubid) + 1)
    
    
end



