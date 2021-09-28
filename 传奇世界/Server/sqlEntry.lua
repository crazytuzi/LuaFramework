--sqlEntry.lua
--------------------------------------------------------------------------------
---- Examples:
--local world_db_sql = {
-- [1]	= 
-- [[
	-- CREATE TABLE IF NOT EXISTS `test_www`  (
	  -- `roleID` int(11) NOT NULL DEFAULT '0',
	  -- `datas` varchar(1024) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '"0"',
	  -- PRIMARY KEY (`roleID`)
	-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;	
-- ]],
-- [2] = 
-- [[
	-- drop table test_skill;
-- ]],
--}

local world_db_sql = 
{
	--Note: Don't dig a hole!!!
	--"ALTER TABLE faction ADD(openId varchar(32) NOT NULL DEFAULT '')",
}


local name_db_sql = 
{

}

function loadWorldPrevSqls(buff)
	local luabuf = tolua.cast(buff, "LuaMsgBuffer")
	if luabuf and world_db_sql then
		local size = #world_db_sql
		if size > 0 then
			luabuf:pushInt(size)
			for _, sql in pairs(world_db_sql) do
				luabuf:pushString(sql)
			end
		end
	end
end

