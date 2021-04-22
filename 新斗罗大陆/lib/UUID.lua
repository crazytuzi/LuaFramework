--[[  UUID.lua - UUID/GUID-string generator for Corona
--
-- Copyright (c) Frank Siebenlist. All rights reserved.
-- The use and distribution terms for this software are covered by the
-- Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php).
-- By using this software in any fashion, you are agreeing to be bound by
-- the terms of this license.
-- You must not remove this notice, or any other, from this software.
--
 
This implementation mimics the JavaScript version mentioned on http://www.broofa.com/2008/09/javascript-uuid-function/ and available at http://www.broofa.com/2008/09/javascript-uuid-function/.
 
That implementation has a number of versions and I tried to Lua'fy the first default implementation without the variable radix support (fixed on 16).
 
When the BinDecHex library can be found, if will try to do the right stuff with the 20th hex of the uuid-string as far as and'ing and or'ing, but if it cannot find support for bitwise operations, it will simply generate another random hex-value.
Please see "http://www.dialectronics.com/Lua/" for details about the BinDecHex package.
 
WARNING - this is a hack - depends on the local random generator which seems quirky for the wrong seeds (so I do not use any seeding and push that responsibility on to the caller), it may not comply with the formal uuid/guid-spec for the 20th hex-value - do not fly airplanes that depend on this code... but at least it gives you nice looking guid/uuid-like strings that seem random enough for informal use.
 
If Ansca ever will provide proper support for the naive OS-guid/uuid-generators (as they should!), please discard this piece of code at your earliest convenience.
 
Enjoy, Frank.
 
--]]
 
 
 
pcall(require,"BinDecHex")
local Hex2Dec, BMOr, BMAnd, Dec2Hex
if(BinDecHex)then
        Hex2Dec, BMOr, BMAnd, Dec2Hex = BinDecHex.Hex2Dec, BinDecHex.BMOr, BinDecHex.BMAnd, BinDecHex.Dec2Hex
end
 
 
--- Returns a UUID/GUID in string format - this is a "random"-UUID/GUID at best or at least a fancy random string which looks like a UUID/GUID. - will use BinDecHex module if present to adhere to proper UUID/GUID format according to RFC4122v4.
--@Usage after require("UUID"), then UUID.UUID() will return a 36-character string with a new GUID/UUID.
--@Return String - new 36 character UUID/GUID-complient format according to RFC4122v4.
function UUID()
        local chars = {"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"}
        local uuid = {[9]="-",[14]="-",[15]="4",[19]="-",[24]="-"}
        local r, index
        for i = 1,36 do
                if(uuid[i]==nil)then
                        -- r = 0 | Math.random()*16;
                        r = math.random (16)
                        if(i == 20 and BinDecHex)then 
                                -- (r & 0x3) | 0x8
                                index = tonumber(Hex2Dec(BMOr(BMAnd(Dec2Hex(r), Dec2Hex(3)), Dec2Hex(8))))
                                if(index < 1 or index > 16)then 
                                        print("WARNING Index-19:",index)
                                        return UUID() -- should never happen - just try again if it does ;-)
                                end
                        else
                                index = r
                        end
                        uuid[i] = chars[index]
                end
        end
        return table.concat(uuid)
end