--[[--
	UI加载管理器:

	--By: yun.bo
	--2013/8/1
]]

local pairs 	= pairs
local type 	= type
local require 	= require
local TFArray 	= TFArray

local TFUILoadManager = class('TFUILoadManager')
local TFUILoadManagerModel = {}
TFUILoadManagerModel.dict = {}
TFUILoadManagerModel.logics = {}
TFUILoadManagerModel.dictInOrder = {}	-- only use for EditorTest

function TFUILoadManager:load(szConfigPath, szPrePath, bIsNotLoadLogicFile)
	if not szConfigPath then 
		TFLOG2(szConfigPath .. 'is not exists.', TFLOG_ERROR)
		return 
	end
	local configs = szConfigPath
	if type(configs) == 'string' then
		configs = require(szConfigPath)
	end
	
	self:clear()
	TFUILoadManagerModel.dict = {}
	TFUILoadManagerModel.dictInOrder = {}	-- only use for EditorTest
	local UIArr = TFArray:new()
	szPrePath = szPrePath or ''
	for k, v in pairs(configs) do
		if v.name and (v.canLoad ~= nil and v.canLoad or v.canLoad == nil) then
			local szUIPath = v['ui']
			local szLogicPath = v['logic']
			if bIsNotLoadLogicFile then
				szLogicPath = ""
			end
			if szLogicPath == "" then szLogicPath = nil end
			local ui = self:loadModule(szPrePath .. szUIPath, szLogicPath, v.name, v.x, v.y)
			UIArr:push(ui)
			TFUILoadManagerModel.dictInOrder[k] = v.name
		end
	end
	if type(configs) == 'string' then
		--TFDirector:unRequire(szConfigPath)
	end
	return UIArr
end

function TFUILoadManager:unLoad(szConfigPath)
	if not szConfigPath then 
		TFLOG2(szConfigPath .. 'is not exists.', TFLOG_ERROR)
		return 
	end
	local configs = szConfigPath
	if type(config) == 'string' then
		configs = require(szConfigPath)
	end
	for k, v in pairs(configs) do
		if v.name then
			self:unLoadModule(v.name)
		end
	end
	if type(config) == 'string' then
		--TFDirector:unRequire(szConfigPath)
	end
end


function TFUILoadManager:loadModule(szUIPath, szLogicPath, name, x, y)
	if not szUIPath then
		print("ERROR~~ UIPath is nil")
		return 
	end
	local ui, logic
	-- read configMap
	if szUIPath and not szLogicPath and not name then
		name = szUIPath
		local config = TFUILoadManagerModel.configMap[name]
		if config then
			ui, logic = self:loadModule(config.uiPath, config.logicPath, name, config.x, config.y)
		end
		return ui, logic
	end
	if not name then return end
	self:unLoadModule(name)

	if szLogicPath then
		if type(szLogicPath) == "string" then
			logic = require(szLogicPath)
			if instanceOf(logic) ~= NONE_CLASS  and instanceOf(logic) ~= "Map"  then
				logic = logic:new()
				ui = logic:init(szUIPath)
			else
				ui = logic:init(szUIPath)
			end
		else
			logic = szLogicPath
			ui = logic:init(szUIPath)
		end
	else
		ui = createUIByLua(szUIPath)
	end
	if not ui then print("createUIByLua failed"); return end -- create ui failed
	ui.logic = logic

	TFUILoadManagerModel.dict[name] 		= {}
	TFUILoadManagerModel.dict[name].ui 		= ui
	TFUILoadManagerModel.dict[name].logic 	= logic
	x = x or 0
	y = y or 0
	if x ~= 0 or y ~= 0 then
		TFUILoadManagerModel.dict[name].ui:setPosition(ccp(x, y))
	end
	TFUILoadManagerModel.dict[name].ui:retain()

	TFUILoadManagerModel.configMap 			= TFUILoadManagerModel.configMap or {}
	TFUILoadManagerModel.configMap[name] 	= {}
	TFUILoadManagerModel.configMap[name].uiPath = szUIPath
	TFUILoadManagerModel.configMap[name].logicPath = szLogicPath
	TFUILoadManagerModel.configMap[name].x 	= x
	TFUILoadManagerModel.configMap[name].y 	= y
	return ui, logic
end

function TFUILoadManager:unLoadModule(name)
	if not name then return end
	local ul = TFUILoadManagerModel.dict[name]
	if ul then
		if ul.logic then
			TFFunction.call(ul.logic.dispose, ul.logic)
		end
		ul.ui:release()
		TFUILoadManagerModel.dict[name] = nil
	end
end

function TFUILoadManager:getUI(szUIName)
	if TFUILoadManagerModel.dict[szUIName] then
		return TFUILoadManagerModel.dict[szUIName].ui
	else
		--todo
	end
end

function TFUILoadManager:addUI(ui)
end

function TFUILoadManager:getLogic(szUIName)
	if TFUILoadManagerModel.dict[szUIName] then
		return TFUILoadManagerModel.dict[szUIName].logic
	end
end

function TFUILoadManager:getDict()
	return TFUILoadManagerModel.dict, TFUILoadManagerModel.dictInOrder
end

function TFUILoadManager:clear()
	if TFUILoadManagerModel.dict == nil then return end 
	for szName, ul in pairs(TFUILoadManagerModel.dict) do
		self:unLoadModule(szName)
	end
	TFUILoadManagerModel.configMap = nil
	TFUILoadManagerModel.dict = {}
end

return TFUILoadManager:new()