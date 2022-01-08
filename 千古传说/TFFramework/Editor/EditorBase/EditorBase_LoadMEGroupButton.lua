local tGroupButton = {}
tGroupButton.__index = tGroupButton
setmetatable(tGroupButton, require("TFFramework.Editor.EditorBase.EditorBase_LoadMEButton"))


---------------------------------------------------------------- new WPF commond -------------------------------------------------------------------


function EditLua:createGroupButton(szId, tParams)
	print("createGroupButton")
	local groupBtn = TFGroupButton:create()
	groupBtn:setNormalTexture("test/groupbutton/com_btn3_n.png")
	groupBtn:setPressedTexture("test/groupbutton/com_btn3_p.png")
	groupBtn:setFontName("宋体")

	targets[szId] = groupBtn
	EditLua:addToParent(szId, tParams)

	targets[tParams.szParent]:doLayout()
	print("createGroupButton success")
end

function tGroupButton:setSelectedColor(szId, tParams)
	print("setSelectedColor")
	targets[szId]:setSelectedColor(ccc3(tParams.nR, tParams.nG, tParams.nB))
	print("setSelectedColor success")
end

function tGroupButton:setSelect(szId, tParams)
	print("setSelect")
	targets[szId]:setSelect(tParams.bRet)
	local szParentID = targets[szId].szParentID
	if tParams.bRet and targets[szParentID]._SelectedGroupButtonID ~= szId then
		targets[szParentID]._SelectedGroupButtonID = szId
		local szRes = ""
		for v in targets[szParentID].children:iterator() do
			if targets[szId]:getDescription() == "TFGroupButton" and v ~= szId then
				szRes = szRes .. string.format("ID=%s;bIsGroupButtonSelected=false|", v)
			end
		end
		setCmdGetString(szRes)
		print("set other selecte:", szRes)
	end
	print("setSelect success")
end

function tGroupButton:loadTextureNormal(szId, tParams)
	print("loadTextureNormal")
	if tParams.szNormalName == "" then
		tParams.szNormalName = "test/button/com_btn3_n.png"
	end
	targets[szId]:setNormalTexture(tParams.szNormalName)
	print("loadTextureNormal run success")
end

function tGroupButton:loadTexturePressed(szId, tParams)
	print("loadTexturePressed", tParams.szPressName)
	if tParams.szPressName == "" then
		tParams.szPressName = "test/button/com_btn3_p.png"
	end
	targets[szId]:setPressedTexture(tParams.szPressName)
	print("loadTexturePressed run success")
end


function tGroupButton:setFontColor(szId, tParams)
	print("setFontColor")
	targets[szId]:setNormalColor(ccc3(tParams.nR, tParams.nG, tParams.nB))
	print("setFontColor run success")
end



return tGroupButton