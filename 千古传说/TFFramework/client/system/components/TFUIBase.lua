--[[--
	控件基类:

	--By: yun.bo
	--2013/7/8
]]

TFUIBase = TFUIBase or {}

if not TFUIBase.__index then TFUIBase.__index = TFUIBase end

TFUI_VERSION_COCOSTUDIO = "1.0.0.0"
TFUI_VERSION_ALPHA 		= 0
TFUI_VERSION_MEEDITOR		= 1
TFUI_VERSION_NEWMEEDITOR	= 2

TFUIBase.version 		= nil

require('TFFramework.client.system.components.luacomps.init')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_Unity')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_Fundation')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_Setter')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_NewSetter')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_Load')

local TFUIBase 			= TFUIBase
local ENABLE_ADAPTOR 	= ENABLE_ADAPTOR
local tolua 			= tolua
local type 				= type
local setmetatable	 	= setmetatable
local setpeer 			= tolua.setpeer

--[[--
	给对象obj绑定TFUIBase的所有属性及方法
	@param obj: 需要绑定的对象
	@return : nil
]]
function TFUIBase:extends(obj)
	if  not obj then return end
	local peer = setmetatable({}, TFUIBase)
	peer.__MECppClone = peer.__MECppClone or obj.clone
	setpeer(obj, peer)
end

--[[--
	用给定的lua文件路径或lua对象加载一个UI对象, 如果提供parent,则会将加载完成的
	UI对象添加到此parent
	@param szLuaPath: lua文件路径 || lua表对象
	@param parent: 父UI对象
	@param fontName: 指定创建界面的字体
	@return : nil
]]
function createUIByLua(szLuaPath, parent, fontName)
	-- TFTime:b()
	if not szLuaPath then return end
	local TFUIBase = TFUIBase
	local tempVersion = TFUIBase.version
	local comps
	local szType = type(szLuaPath) -- check state
	if szType == 'string' then -- lua path, load it
		comps = require(szLuaPath)
		--package.loaded[szLuaPath] = nil
	elseif szType == 'table' then -- already a table
		comps = szLuaPath
	end

	TFUIBase.version = TFUIBase:adaptVersion(comps.version)
	local val
	if TFUIBase.version == TFUI_VERSION_COCOSTUDIO then
		val = comps.widgetTree
		local directory = comps.directory
		val.directory = directory
	else
		val = comps.components[1]
	end

	val['userFont'] = fontName
	local objUI = TFUIBase:initChild(val, parent)

	-- init ui actions
	TFUIBase:initAction(objUI, comps.actions)
	TFUIBase.version = tempVersion
	-- TFTime:e(szLuaPath .. ":")
	return objUI
end

--[[--
	用于创建lua配置文件的粒子控件
	返回粒子控件
	@szLuaPath: lua配置文件
	@szParticleName: 界面上的粒子名字
]]
function createParticleByLua(szLuaPath, szParticleName)
	local ui = createUIByLua(szLuaPath)
	local particle = TFDirector:getChildByName(ui, szParticleName)
	particle:removeFromParent()
	return particle
end

function TFUIBase:adaptVersion(version)
	if type(version) == 'string' then 
		version = TFUI_VERSION_COCOSTUDIO 
	elseif version == nil then
		version = TFUI_VERSION_ALPHA
	elseif version == 1 then
		version = TFUI_VERSION_MEEDITOR
	elseif version == 2 then
		version = TFUI_VERSION_NEWMEEDITOR
	end
	return version
end

return TFUIBase