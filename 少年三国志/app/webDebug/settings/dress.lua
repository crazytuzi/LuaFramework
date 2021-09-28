
local getDressId = function ( )
	local dressed = G_Me.dressData:getDressed() 
	if dressed then
		return dressed.id
	end
	local dressList = G_Me.dressData:getDressList() 
	if #dressList > 0 then
		return dressList[1].id
	end
	return 0
end

local dress = {
    UpgradeDress = {
        {msg = {id=9999,},repeatTimes = 1, ret = 0,},
    },
    RecycleDress = {
        {msg = {id=9999,type=1},repeatTimes = 1, ret = 0,},
        {msg = {id=getDressId(),type=999},repeatTimes = 1, ret = 0,},
    },
    AddFightDress =  {
        {msg = {id=9999},repeatTimes = 1, ret = 0,},
        {msg = {id=getDressId()},repeatTimes = 2, ret = {1,0},},
    },
    ClearFightDress =  {
        {msg = {},repeatTimes = 2, ret = {1,0},},
    },
}

return dress