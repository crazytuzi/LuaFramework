--控制开关数据
G_CONTROL = {}

function G_CONTROL:init()

	for i = 1 , GAME_SWITCH_ID_OVER do
		G_CONTROL[ i ] = { isOpen = true }
	end
end

--创建时判断是否开启
function G_CONTROL:isFuncOn( _id )
	return G_CONTROL[ _id ]["isOpen"]
end

--注册回调函数处理是否展示
function G_CONTROL:regCallback( _id ,_fun )
	G_CONTROL[ _id ]["callback"] = _fun
end

--后台数据控制接口
function G_CONTROL:__setData( _id , _isOpen )
	if G_CONTROL[ _id ]["isOpen"] == _isOpen then return end
	G_CONTROL[ _id ]["isOpen"] = _isOpen
	if 	G_CONTROL[ _id ]["callback"] then G_CONTROL[ _id ]["callback"]( _isOpen ) end
	
	if _id == GAME_SWITCH_ID_ACTIVENESS and _isOpen == false then __RemoveTargetTab( "a40" ) __RemoveTargetTab( "a40" ) end
	if _id == GAME_SWITCH_ID_RIDE and _isOpen == false then G_ROLE_MAIN:upOrDownRide(false) end
	if _id == GAME_SWITCH_ID_SINPVP and _isOpen == false then __RemoveTargetTab( "a40" ) __RemoveTargetTab( "a4" ) end
	if _id == GAME_SWITCH_ID_TEAM and _isOpen == false then __RemoveTargetTab( "a29" ) __RemoveTargetTab( "a29" ) end

end

--传世宝典 小助手数据处理
function G_CONTROL:controlDataFilter( _dataSource , _filterKey )

	local function clearKey( _tags )
		for i = 1 , #_tags do
			for key , value in pairs( _dataSource ) do
				local tempData = { } 
				for j = 1  , #value  do
					if value[j][ _filterKey .. "" ] == _tags[i] then
						tempData[ #tempData + 1 ] = j
					end
				end
				table.sort( tempData , function( a , b ) return a>b end )
				for j = 1  , #tempData  do
					table.remove( value , tempData[j] )
				end
			end
		end
	end
	
	local cfg = { 
					[GAME_SWITCH_ID_ACTIVENESS] = { "a40" } ,
					[GAME_SWITCH_ID_TASK] = { "a1" , "a2" , "a133" , "a144" } ,
					[GAME_SWITCH_ID_COPY] = { "a155" , "a109" , "a129" , "a106" , "a107" } ,
					[GAME_SWITCH_ID_RIDE] = { "a17" } ,
					[GAME_SWITCH_ID_DIGMINE] = { "a82" } ,
					[GAME_SWITCH_ID_SINPVP] = { "a4" } ,
					[GAME_SWITCH_ID_WING] = { "a18" } ,
					[GAME_SWITCH_ID_RANK] = { "a80" } ,
				}

	for key , value in pairs( G_CONTROL ) do
		if type(value) == "table"and value.isOpen == false then
			if cfg[ key ] then clearKey( cfg[ key ] ) end
		end
	end

	return _dataSource
end


return G_CONTROL