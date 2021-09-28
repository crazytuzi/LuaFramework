-- FileName: FightUtil.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗工具类

module("FightUtil", package.seeall)

local _otherChildArray = {}

--[[
	@des:查找特效文件路径
	@parm:pEffectName 特效名称
	@parm:isEnemy 是否是地方卡牌特效
	@ret:string 特效路径
--]]
function getEffectPath( pEffectName, isEnemy )
	if pEffectName == nil then
		return nil
	end

	if isFileExist(pEffectName) then
		return pEffectName
	end

	local retFilename = "images/battle/effect/" .. pEffectName
	if isFileExist(retFilename .. ".plist") then
		return retFilename
	end

	if isEnemy == false then
		if isFileExist(retFilename .. "_d.plist") then
			return retFilename .. "_d"
		end
	else
		if isFileExist(retFilename .. "_d.plist") then
			return retFilename .. "_u"
		end
	end
end

--[[
	@des:查找动作特效文件路径
	@parm:pEffectName 特效名称
	@parm:isEnemy 是否是地方卡牌特效
	@ret:string 特效路径
--]]
function getActionXmlPaht( pFilePath, isEnemy )
	if isFileExist(pFilePath) then
		return pFilePath
	end
	local retFilename = "images/battle/xml/action/" .. pFilePath
	if isFileExist(retFilename) then
		return retFilename
	end
	if isFileExist(retFilename .. ".xml") then
		return retFilename .. ".xml"
	end
	if isFileExist(retFilename .. "_0.xml") then
		return retFilename.. "_0.xml"
	end
	if isEnemy == false then
		if isFileExist(retFilename .. "_d.xml") then
			return retFilename .. "_d.xml"
		end
		if isFileExist(retFilename .. "_d_0.xml") then
			return retFilename .. "_d_0.xml"
		end
	else
		if isFileExist(retFilename .. "_u.xml") then
			return retFilename .. "_u.xml"
		end
		if isFileExist(retFilename .. "_u_0.xml") then
			return retFilename .. "_u_0.xml"
		end
	end
end

--[[
	@des:判断文件是否存在
	@parm:pPath 文件路径
	@ret:bool 存在 true 否则 false
--]]
function isFileExist( pPath )
	local ret = false
	local fullpath = CCFileUtils:sharedFileUtils():fullPathForFilename(pPath)
	if CCFileUtils:sharedFileUtils():isFileExist(fullpath) then
		ret =  true
	end
	print("pPath",pPath,ret)
	return ret
end

--[[
    @des: 隐藏除战斗场景以外的元素
--]]
function hideOtherNode(...)
	_otherChildArray = {}
    local scene = CCDirector:sharedDirector():getRunningScene()
    local sceneChildArray = scene:getChildren()
    for idx = 1, sceneChildArray:count() do
        local childNode = tolua.cast(sceneChildArray:objectAtIndex(idx - 1), "CCNode")
        if (childNode ~= nil and childNode:isVisible() == true) then
            childNode:setVisible(false)
            table.insert(_otherChildArray, childNode)
        end
    end
end

--[[
    @des: 显示除战斗场景以外的元素
--]]
function showOtherNode(...)
    for k, v in pairs(_otherChildArray) do
    	if not tolua.isnull(v) then
        	v:setVisible(true)
        end
    end
    _otherChildArray = {}
end

