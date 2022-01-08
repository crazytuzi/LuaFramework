--[[--
	控件加载方法:

	--By: yun.bo
	--2013/11/28
]]

local TFUIBase 				= TFUIBase
local require 				= require
local TFUIBase_setFuncs_new = TFUIBase_setFuncs_new
local pairs 				= pairs
local instanceOf 			= instanceOf
local TFFunction 			= TFFunction
local string 				= string
local me 					= me

require('TFFramework.client.system.components.TFUIBase.TFUIBase_Actions')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEArmature')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEButton')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMECheckBox')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEColorProps')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEDragPanel')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEIconLabel')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEImage')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMELabel')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMELabelBMFont')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEListView')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMELoadingBar')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMELua')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEMovieClip')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEPageView')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEPanel')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEScrollView')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMESlider')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMETableView')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMETextArea')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMETextButton')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMETextField')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEPageView')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEWidget')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEBigMap')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEParticle')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEButtonGroup')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMEGroupButton')
require('TFFramework.client.system.components.TFUIBase.TFUIBase_LoadMERichText')

function TFUIBase:initChild(val, parent)
	if val then
		if TFUIBase.version == TFUI_VERSION_NEWMEEDITOR then
			val = TFUIBase_setFuncs_new:reorganizeData(val)
		end
		val.classname = val.classname or val.className
			-- 替换class name
	-- print("classname1 = " .. val.classname)
	-- val.classname = string.gsub(val.classname, "\bME", "TF")
	-- replace
	val.classname = string.gsub(val.classname, "ME", "TF")
	-- print("classname2 = " .. val.classname)

		if val.classname then

			-- modify by jin 20170324 --[
			local fontName = val['userFont']
			if val['fontName'] and fontName then 
				val['fontName'] = fontName
			end
			--]--

			local _, ui
			if val.compPath then
				-- replace
				val.compPath = string.gsub(val.compPath, "ME", "TF")
				_, ui = require('TFFramework.'..val.compPath):initControl(val, parent)
			else
				_, ui = TFUIBase.registerComponents[val.classname]:initControl(val, parent)
			end
			return ui
		end
	end
end

function TFUIBase:initBaseControl(pval, parent)
	local children = pval.components or pval.children
	if children then
		for k, v in pairs(children) do
			v.directory = pval.directory
			-- modify by jin 20170324 --[
			local fontName = pval['userFont']
			if v['fontName'] and fontName then 
				v['fontName'] = fontName
			end
			v['userFont'] = fontName
			--]--
			local objChild = self:initChild(v, self)
		end
	end
	
	if parent then
		local objParent = self:getParent()

		if not objParent or objParent == parent then
			self.parent = parent;
		end
		
		if not objParent then
			parent:addChild(self)
		else
			if objParent ~= parent and parent:getDescription() ~= "TFScrollView" then
				print("[error] initBaseControl self already has parent ", self:getName(), objParent:getName(), parent:getName())
			end
		end
	end

	if pval.logic then
		if type(pval.logic) == "string" then
			local logic = require(pval.logic)
			if instanceOf(logic) ~= NONE_CLASS then
				self.logic = logic:new()
			else
				self.logic = logic
			end
		else
			if instanceOf(logic) ~= NONE_CLASS then
				self.logic = logic:new()
			else
				self.logic = logic
			end
		end
		self.logic:init(self)
	end
	TFFunction.call(self.doLayout, self)
end

function TFUIBase:loadPlistOrPvrTexture(fileName)
	if string.match(fileName, "%.plist") then
		me.FrameCache:addSpriteFramesWithFile(fileName)
		return true
	elseif string.match(fileName, "%.pvr") then
		me.TextureCache:addImage(fileName)
		return true
	end
	return false
end

function TFUIBase:convertSpecialChar(tParam)
	if tParam and tParam.szText then
		tParam.szText = string.gsub(tParam.szText, "&amp;", "&")
		tParam.szText = string.gsub(tParam.szText, "&lt;", "<")
		tParam.szText = string.gsub(tParam.szText, "&gt;", ">")
		tParam.szText = string.gsub(tParam.szText, "&apos;", "'")
		tParam.szText = string.gsub(tParam.szText, "&quot;", [["]])
		tParam.szText = string.gsub(tParam.szText, "&bslash;", [[\]])
	end
end