--LuaShaDAO.lua
--/*-----------------------------------------------------------------
 --* Module:  LuaShaDAO.lua
 --* Author:  seezon
 --* Modified: 2015年9月16日
 --* Purpose: 沙巴克配置
 -------------------------------------------------------------------*/
--]]

--------------------------------------------------------------------------------
LuaShaDAO = class(nil, Singleton)

function LuaShaDAO:__init()
	self._shaCfg = require "data.ShaWarDB"
end

function LuaShaDAO:getCfg()
	return self._shaCfg[1]
end

function LuaShaDAO.getInstance()
	return LuaShaDAO()
end

