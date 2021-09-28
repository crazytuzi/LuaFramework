--Author:		bishaoqing
--DateTime:		2016-04-26 17:12:49
--Region:		保存一些用于获取类或者table的接口(尤其是单例类)
--Tag:			直接返回new出的对象的一般情况都是单例类
local ProFiCtr = nil
function GetProFiCtr( ... )
	-- body
	if not ProFiCtr then
		ProFiCtr = require("src/common/ProFiCtr").new()
	end
	return ProFiCtr
end

local StateMachine = nil
function GetStateMachine( ... )
	-- body
	if not StateMachine then
		StateMachine = require("src/common/StateMachine")
	end
	return StateMachine
end

local WidgetFactory = nil
function GetWidgetFactory( ... )
	-- body
	if not WidgetFactory then
		WidgetFactory = require("src/common/WidgetFactory").new()
	end
	return WidgetFactory
end

local UIHelper = nil
function GetUIHelper( ... )
	-- body
	if not UIHelper then
		UIHelper = require("src/common/UIHelper").new()
	end
	return UIHelper
end

local Log = nil
function GetLog( ... )
	-- body
	if not Log then
		Log = require("src/common/Log").new()
	end
	return Log
end

local TeamCtr = nil
function GetTeamCtr( bNoUpdate )
	-- body
	if not TeamCtr then
		TeamCtr = require("src/layers/teamup/TeamCtr").new()
	end

	-- --是否同步一下数据
	-- if not bNoUpdate then
	-- 	TeamCtr:update()
	-- end
	
	return TeamCtr
end

local TeamNetCtr = nil
function GetTeamNetCtr( ... )
	-- body
	if not TeamNetCtr then
		TeamNetCtr = require("src/layers/teamup/TeamNetCtr").new()
	end
	return TeamNetCtr
end
-- local Event = nil
-- function GetEvent( ... )
-- 	-- body
-- 	if not Event then
-- 		Event = require("src/common/Event")
-- 	end
-- 	return Event
-- end

-- local EventName = nil
-- function GetEventName( ... )
-- 	-- body
-- 	if not EventName then
-- 		EventName = require("src/common/EventName")
-- 	end
-- 	return EventName
-- end

local Win32Debug = nil
function GetWin32Debug( ... )
	-- body
	if not Win32Debug then
		Win32Debug = require("src/common/Win32Debug").new()
	end
	return Win32Debug
end

local ProtoWriter = nil
function GetProtoWriter( ... )
	-- body
	if not ProtoWriter then
		ProtoWriter = require("src/common/ProtoWriter").new()
	end
	return ProtoWriter
end

local IniLoader = nil
function GetIniLoader( ... )
	-- body
	if not IniLoader then
		IniLoader = require("src/common/IniLoader").new()
	end
	return IniLoader
end

local UiCfg = nil
function GetUiCfg( ... )
	-- body
	if not UiCfg then
		UiCfg = require("src/common/UiCfg")
	end
	return UiCfg
end

local BlackMarketCtr = nil
function GetBlackMarketCtr( ... )
	-- body
	if not BlackMarketCtr then
		BlackMarketCtr = require("src/layers/blackMarket/BlackMarketCtr").new()
    else
        BlackMarketCtr:reRegisteCallBack()
	end
	return BlackMarketCtr
end

local BlackMarketItem = nil
function GetBlackMarketItem( ... )
	-- body
	if not BlackMarketItem then
		BlackMarketItem = require("src/layers/blackMarket/BlackMarketItem")
	end
	return BlackMarketItem
end

local AncientTreasureTeamCtr = nil
function GetAncientTreasureTeamCtr( ... )
	-- body
	if not AncientTreasureTeamCtr then
		AncientTreasureTeamCtr = require("src/layers/teamTreasureTask/AncientTreasureTeamCtr").new()
	end
	return AncientTreasureTeamCtr
end

local AncientTreasureTeam = nil
function GetAncientTreasureTeam( ... )
	-- body
	if not AncientTreasureTeam then
		AncientTreasureTeam = require("src/layers/teamTreasureTask/AncientTreasureTeam")
	end
	return AncientTreasureTeam
end

local MultiPlayerCtr = nil
function GetMultiPlayerCtr( ... )
	-- body
	if not MultiPlayerCtr then
		MultiPlayerCtr = require("src/layers/fb/newMultiPlayer/MultiPlayerCtr").new()
	end
	return MultiPlayerCtr
end

local FriendCtr = nil
function GetFriendCtr( ... )
	-- body
	if not FriendCtr then
		FriendCtr = require("src/layers/friend/logic/FriendCtr").new()
	end
	return FriendCtr
end
GetWin32Debug()