package.path = "./luascripts/?.lua;" .. package.path
package.cpath = "./luaclib/?.so"
ptb = require "lib.ptb"

function ptb:e(variable,ed)
    print '\n--------ptb:e------------'
    if type(variable) == 'table' then
        self:p(variable)
    else
        print(variable)
    end
    print '--------ptb:e------------\n'
    if not ed then os.exit() end
end

require "dispatch"

local response

-- 登陆 ---------------
local cmd = '{"cmd":"admin.test","params":{},"rnum":2,"ts":1381392586,"zoneid":26,"secret":"d73d55ee6b51ffe604e25f7a92235f33"}'


response =  dispatch(cmd)


print (response)

os.exit()

