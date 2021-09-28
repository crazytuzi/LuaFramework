-------------------------------------------
--module(..., package.seeall)

local require = require;

require("i3k_global");


-------------------------------------------

i3k_announcement = i3k_class("i3k_announcement");

function i3k_announcement:ctor()
	
end

function i3k_announcement:Load()
	local fn = i3k_game_get_exe_path() .. "announcement.txt";
	local f = io.open(fn, "r");
	local content = f:read("*all");
	f:close()
	return content
end