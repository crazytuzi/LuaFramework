package.path = "../?.lua;" .. package.path

require "dispatch"


local zoneid = tonumber(arg[1])

if zoneid then
   setZoneId(zoneid)
   local mMap = require 'lib.map' 
   local db = getDbo()
   local redis = getRedis()
   local  res = db:getAllRows("select id,exp,level,newlevel from map where exp>0 and newlevel=0") 
   if type(res)=='table' and next(res) then
    for k,v in pairs (res) do
        local mapId=v.id
        local mapexp=tonumber(v.exp)
        local omaplevel=tonumber(v.level)
        local maplevel = mMap:getMapLevel(omaplevel,mapexp,mapId)
        db:update("map",{newlevel=maplevel},"id="..mapId)
    end
    
   end
   print("zoneid:",zoneid, "ok")    
end
    
