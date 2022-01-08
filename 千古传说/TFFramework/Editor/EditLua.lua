--[[
/*code is far away from bug with the animal protecting
    *  ┏┓　　　┏┓
    *┏┛┻━━━┛┻┓
    *┃　　　　　　　┃ 　
    *┃　　　━　　　┃
    *┃　┳┛　┗┳　┃
    *┃　　　　　　　┃
    *┃　　　┻　　　┃
    *┃　　　　　　　┃
    *┗━┓　　　┏━┛
    *　　┃　　　┃神兽保佑
    *　　┃　　　┃代码无BUG！
    *　　┃　　　┗━━━┓
    *　　┃　　　　　　　┣┓
    *　　┃　　　　　　　┏┛
    *　　┗┓┓┏━┳┓┏┛
    *　　　┃┫┫　┃┫┫
    *　　　┗┻┛　┗┻┛ 
    *　　　
    */
    Editor Logic.
    	begin: 2013.12.1
	Author: xiaoda.zhuang
]]
EditLua = {}
targets = {}
tSelectedIDs = TFArray:new()
tLastSelectedIDs = TFArray:new()
tLockTargets = TFArray:new()
tRootPanel = TFArray:new()
szCurRootPanelID = nil
bIsCreate = false
tCurState = {}
bIsError = false
bIsNeedToSetCmdGet = false
tRetureMsgTarget = TFArray:new()
tRetureMsgSelectedTarget = TFArray:new()
-- tScreenAdaptTargets = TFArray:new()

require('TFFramework.Editor.EditorBase.EditorBase_Fundation')
require('TFFramework.Editor.EditorBase.EditorBase_Load')
require('TFFramework.Editor.EditorAdvance.EditorAdvance_Load')

setmetatable(EditLua, EditVirtualBase)
EditLua.__index = EditLua
setmetatable(EditMapData, EditVirtualBase)
EditMapData.__index = EditMapData

tCurState = EditLua
function checkIsLegal(szId, command)
	if targets[szId] == nil then
		TFLOGERROR("!!!!!!!!!!!! targets is nil !!!!!!!!!!!!  " .. szId)
	end
end

local function  setReturnMsg( szId )
	local str = getGlobleString()
	if targets[szId] ~= nil and (str == "" or not string.find(str, "%AnX =")) then
		szGlobleResult = string.format("nX = %d, nY = %d, ", targets[szId]:getPosition().x, targets[szId]:getPosition().y)
		if str ~= "1" then
			szGlobleResult = szGlobleResult .. string.format("nWidth = %d, nHeight = %d, ", targets[szId]:getSize().width, targets[szId]:getSize().height)
		end
		if targets[szId].getBlendFunc then
			szGlobleResult  = szGlobleResult .. string.format("BlendFuncSrc = %d, BlendFuncDst = %d, ", targets[szId]:getBlendFunc().src, targets[szId]:getBlendFunc().dst)
		end
		if str ~= "1" and targets[szId]:getSizeType() == TF_SIZE_PERCENT or targets[szId]:getSizeType() == TF_SIZE_FRAMESIZE then
			szGlobleResult  = szGlobleResult .. string.format("nWidthPer = %.2f, nHeightPer = %.2f, ", targets[szId]:getSizePercentWidth() * 100, targets[szId]:getSizePercentHeight() * 100)
		end
		if targets[szId]:getPositionType() == TF_POSITION_PERCENT then
			szGlobleResult  = szGlobleResult .. string.format("nXPer = %.2f, nYPer = %.2f, ", targets[szId]:getPositionPercentX() * 100, targets[szId]:getPositionPercentY() * 100)
		end
		szGlobleResult = szGlobleResult .. str
		setGlobleString(szGlobleResult)
		print("position x, y:", targets[szId]:getPosition().x, targets[szId]:getPosition().y)
	end
	print("Return msg:", szGlobleResult)

	if bIsNeedToSetCmdGet then
		local szRes = ""
		local touchObj
		local tAddID = TFArray:new()
		for v in tRetureMsgTarget:iterator() do
			touchObj = targets[v]
			if touchObj and tAddID:indexOf(v) == -1 then
				tAddID:push(v)
				if tRetureMsgSelectedTarget:indexOf(v) ~= -1 then
					szRes = szRes .. string.format("ID=%s;bIsSelected=true,", touchObj.szId, touchObj:getPosition().x, touchObj:getPosition().y)
					msg = EditLua:getTargetMarginOrPosition_CmdGet(v)
					msg = msg[string.format("%d:-1", string.find(msg, ";") + 1)]
					szRes = szRes .. msg
					print(msg)
				else
					szRes = szRes .. EditLua:getTargetMarginOrPosition_CmdGet(v)
				end
			end
		end
		tRetureMsgTarget:clear()
		tRetureMsgSelectedTarget:clear()
		bIsNeedToSetCmdGet = false
		setCmdGetString(szRes)
		print("Return CmdGet Msg:" , szRes)
	end
end

function EditLua:setCmdID(szId, tParams)
	szCMD_ID = tParams.szId
end

function  EditLua:cmd( szId, command, arg)
	if bIsError then 
		setCmdGetString("showMessage:Error,工具已经出现错误，请备份好当前项目，重新打开编辑器 才能 继续编辑，\n请备份好当前项目，重新打开编辑器 才能 继续编辑，\n请备份好当前项目，重新打开编辑器 才能 继续编辑，\n请备份好当前项目，重新打开编辑器 才能 继续编辑，\n请备份好当前项目，重新打开编辑器 才能 继续编辑，\n请备份好当前项目，重新打开编辑器 才能 继续编辑，\n请备份好当前项目，重新打开编辑器继续编辑，并把\"*：\\Program Files (x86)\\第七大道 引擎中心\\芒果编辑器\\log\"目录下当天的log文件和error.log文件发给测试刘佳音，谢谢合作:")
		return 
	end
	EditorUtils:recordInfo(szId, command, arg)
	local tParams, bIsOk = EditorUtils:load(arg, "argument")
	if not bIsOk then return end
	local tCommand, bIsOk = EditorUtils:load(command, "command")
	if not bIsOk then return end

	szCMD_ID = szId
	-- local i = string.find(command, ",")
	-- if i ~= nil then
		for i = 1, #tCommand do
			local tParam, bIsOk = EditorUtils:load(tParams[i], tParams[i])
			if not bIsOk then return end
			if tCurState == EditLua then
				if tParam and tParam ~= "" then tParam = EditLua:convertParams(tParam) end
				if string.find(tCommand[i], "create") ~= nil or szCMD_ID == "" then
					print("nil id")
					TFFunction.call(tCurState[tCommand[i]], tCurState, szCMD_ID, tParam)
				elseif targets[szCMD_ID] then
					local className = TFFunction.call(targets[szCMD_ID].getEditorDescription, targets[szCMD_ID]) or targets[szCMD_ID]:getDescription()
					if TFDirector.bIsEditorDebug then
						package.loaded['TFFramework.luacomponents.common.' .. className] = nil
						package.loaded['TFFramework.Editor.EditorBase.EditorBase_Load' .. className] = nil
					end
					local tFunc = require('TFFramework.Editor.EditorBase.EditorBase_Load' .. className) or require('TFFramework.luacomponents.common.' .. className)
					-- conver Sepcial char like: \ < > .....
					EditorUtils:convertSpecialChar(tParam)
					local bRes = TFFunction.call(tFunc[tCommand[i]], tCurState, szCMD_ID, tParam)
					if bRes or not tFunc[tCommand[i]] then
						TFFunction.call(tCurState[tCommand[i]], tCurState, szCMD_ID, tParam)
					end
					-- for custom size
					if targets[szId]._bUseCustomSize and targets[szId]:getSizeType() == TF_SIZE_ABSOLUTE and not targets[szId].ignoreContentAdaptWithSize then
						local size = targets[szId]:getSize()
						if size.width ~= targets[szId]._tCustomSize.width and size.height ~= targets[szId]._tCustomSize.height then
							print("fix size: ", size.width, size.height)
							print("customsize: ", targets[szId]._tCustomSize.width, targets[szId]._tCustomSize.height)
							targets[szId]:setSize(targets[szId]._tCustomSize)
						end
					end
					-- force doLayout
					if EditorUtils:TargetIsContainer( targets[targets[szCMD_ID].szParentID] ) then
						targets[targets[szCMD_ID].szParentID]:doLayout()
					end

				else
					TFLOGINFO("\n\n!!!!!!!!!!!!!!!!! no targets, check log 检查程序逻辑流程是否正确 (重新启动工具继续编辑) !!!!!!!!!!!!!!\n\n")
					bIsError = true
					return 
				end
			else
				print("map model")
				TFFunction.call(tCurState[tCommand[i]], tCurState, szCMD_ID, tParam)
			end
		end
	-- end

	tSelectedRectManager:updateSelectedRect()

	setReturnMsg(szCMD_ID)
	TFLOGINFO(string.format("\t ----------------------------------- Run Success %d ----------------------------------- \t", nCmdNum))
end

function EditLua:convertParams(tParams)
	local conParams = {}
	for i, v in pairs(tParams) do
		conParams[i] = v
	end
	local id = conParams["szControlID"]
	if targets[id] and conParams["frames"] then
		local mT = conParams["frames"]
		-- base
		if mT.percentenable == nil then
			mT.percentenable = mT.percentage
			mT.perposition = mT.percentPosition
			mT.percentage = nil
			mT.percentPosition = nil
		end
		if targets[id]:getDescription() == "TFParticle" and not conParams["frames"]["particleData"] then
			local t = {}
			t.bIsPlaying		= mT.isPlay
			t.texturePath		= mT.texturePath
			t.EmitterMode		= mT.EmitterMode
			-- model A
			t.Gravity		= mT.Gravity
			t.Speed			= mT.Speed.x
			t.SpeedVar		= mT.Speed.y
			t.TangentialAccel	= mT.TangentialAccel.x
			t.TangentialAccelVar	= mT.TangentialAccel.y
			-- model B
			t.RadialAccel		= mT.RadialAccel.x
			t.RadialAccelVar	= mT.RadialAccel.y
			t.StartRadius		= mT.MaxRadius.x
			t.StartRadiusVar	= mT.MaxRadius.y
			t.EndRadius		= mT.MinRadius.x
			t.EndRadiusVar		= mT.MinRadius.y
			t.RotatePerSecond	= mT.RotateSecond.x
			t.RotatePerSecondVar	= mT.RotateSecond.y
			--Base attribute
			t.Duration		= mT.duration
			t.SourcePosition	= mT.SourcePosition
			t.PosVar		= mT.PosVar
			t.Life			= mT.Life.x
			t.LifeVar		= mT.Life.y
			t.Angle			= mT.Angle.x
			t.AngleVar		= mT.Angle.y
			t.StartSize		= mT.StartSize.x
			t.StartSizeVar		= mT.StartSize.y
			t.EndSize		= mT.EndSize.x
			t.EndSizeVar		= mT.EndSize.y
			t.StartColor		= mT.StartColor
			t.StartColorVar		= mT.StartColorVar
			t.EndColor		= mT.EndColor
			t.EndColorVar		= mT.EndColorVar
			t.StartSpin		= mT.StartSpin.x
			t.StartSpinVar		= mT.StartSpin.y
			t.EndSpin		= mT.EndSpin.x
			t.EndSpinVar		= mT.EndSpin.y
			t.TotalParticles		= mT.TotalParticles

			conParams["frames"]["particleData"] = t
		end
	end
	return conParams
end

return EditLua