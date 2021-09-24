-- 在本地中执行多人逻辑lua API
do
    print("\n\n------------lua cmd:",os.time(),tostring(arg[1]),"----------\n")

    package.path = "../?.lua;" .. package.path

    -- override
    function sendMsgByUid() end

    require "dispatch"

    local secret = "d73d55ee6b51ffe604e25f7a92235f33"
    local zoneid = 1

    local request={
    	cmd="oceanexpedition.server.battle",
    	params={},
    	ts=os.time(),
    	zoneid=zoneid,
    	secret=secret,
    }
    
    local response =  dispatch(json.encode(request))

	print (response)
end
