CTestEditorWindow = class("CTestEditorWindow", CEditorWindowBase)
function CTestEditorWindow.ctor(self, window)
	CEditorWindowBase.ctor(self, window)
end

function CTestEditorWindow.OnGUI(self)
	GUILayout.Label("测试界面", GUILayout.Width(180))
	if GUILayout.Button("法术时间", GUILayout.Width(200)) then
		self:MagicTime()
	end

	if GUILayout.Button("浮空时间", GUILayout.Width(200)) then
		self:FloatTime()
	end

	if GUILayout.Button("编辑器数据", GUILayout.Width(200)) then
		self.GenEditorData()
	end
end

function CTestEditorWindow.MagicTime(self)
	local paths = IOTools.GetFiles(IOTools.GetAssetPath("/Lua/logic/magic/magicfile"), "*.lua", false)
	local s = "法术名  总时间  动作起始  动作结束 攻击方式"
	table.sort(paths)
	local iLen = #paths
	local sBack = "\n归位时间"
	for i, path in ipairs(paths) do
		local filename = IOTools.GetFileName(path, true)
		local _, magic, index = unpack(string.split(filename, "_"))
		magic, index = tonumber(magic), tonumber(index)
		if magic and index then
			if magic >= 99 then
				pcall(function() 
					local srequire = "logic.magic.magicfile."..filename
					local b
					local d = require(srequire).DATA
					local iEnd = 0
					local bMove = false
					local iAddTime = 0
					for k, v in ipairs(d.cmds) do
						if v.func_name == "End" then
							iEnd = v.start_time
						elseif v.func_name == "Move" then
							if v.args.excutor == "atkobj" then
								if v.args.end_relative then
									bMove = not table.equal(v.args.end_relative, {base_pos=[[atk_lineup]],depth=0,relative_angle=0,relative_dis=0,})
								else
									bMove = true
								end
							end
						elseif v.func_name == "SlowMotion" then
							iAddTime = v.args.time  * ( 1/ v.args.scale -1)
						end
					end
					print(magic, iEnd, iAddTime)
					if magic == 99 then
						sBack = sBack..string.format("\n造型:%s  时间:%s", index, math.ceil((iEnd+iAddTime)*1000))
					else
						s = s..string.format("\n%s_%s  %s %s %s %s %s", magic, index, math.ceil((iEnd+iAddTime)*1000), tostring(d.magic_anim_start_time and (d.magic_anim_start_time * 1000) or "无"), 
						tostring(d.magic_anim_end_time and (d.magic_anim_end_time*1000) or "无"), bMove and "需要归位" or "不需归位", next(d.group_cmds) and "(包含指令组)"or "")
					end
				end)
			end
		end
		EditorUtility.DisplayProgressBar(path, string.format("进度:%d/%d", i,iLen), i/iLen)
	end
	EditorUtility.ClearProgressBar()
	local path = IOTools.GetAssetPath("/法术时间文件.txt")
	IOTools.SaveTextFile(path, s..sBack)
	printc("保存成功  "..path)
	AssetDatabase.Refresh()
end

function CTestEditorWindow.FloatTime(self)
	local paths = IOTools.GetFiles(IOTools.GetAssetPath("/Lua/logic/magic/magicfile"), "*.lua", false)
	local dMap = {}
	table.sort(paths)
	local iLen = #paths
	for i, path1 in ipairs(paths) do
		local filename1 = IOTools.GetFileName(path1, true)
		local _, magic1, index1 = unpack(string.split(filename1, "_"))
		magic1, index1 = tonumber(magic1), tonumber(index1)
		local d = require("logic.magic.magicfile."..filename1)
		if magic1 and  magic1 >= 1000 and d.DATA.magic_anim_end_time then
			dMap[magic1] = {}
			for k, path2 in ipairs(paths) do
				local filename2 = IOTools.GetFileName(path2, true)
				local _, magic2, index2 = unpack(string.split(filename2, "_"))
				magic2, index2 = tonumber(magic2), tonumber(index2)
				local d2 = require("logic.magic.magicfile."..filename2)
				if magic2 and magic2 >= 1000 and d2.DATA.magic_anim_start_time then
					local iVal = -d2.DATA.magic_anim_start_time
					if iVal < 0 then
						dMap[magic1][magic2] = iVal
					end
				end
			end
		end
		EditorUtility.DisplayProgressBar(path1, string.format("进度:%d/%d", i, iLen), i/iLen)
	end
	EditorUtility.ClearProgressBar()
	local path = IOTools.GetAssetPath("/floattime.lua")
	local s = "module(...)\n--magic editor build\n"..table.dump(dMap, "DATA")
	IOTools.SaveTextFile(path, s)
	printc("保存成功  "..path)
	AssetDatabase.Refresh()
end

function CTestEditorWindow.GenEditorData()
	local sOut = "module(...)\n"
	local lMagicFiles = {}
	local selList = IOTools.GetFiles(IOTools.GetAssetPath("/Lua/logic/magic/magicfile"), "*.lua", true)
	for i, v in pairs(selList) do
		local p = IOTools.GetFileName(v, true)
		local _, ID1, Idx1 = unpack(string.split(p, "_"))
		table.insert(lMagicFiles, {ID1, Idx1})
	end
	local lShapes = {}
	local dirlist = System.IO.Directory.GetDirectories(IOTools.GetAssetPath("/GameRes/Model/Character/"))
	for i = 0, dirlist.Length - 1 do
		local shape = IOTools.GetFileName(dirlist[i])
		if tonumber(shape) < 10000 then
			lShapes[shape] = true
		end
	end

	local lWeapons = {}
	local dirlist = System.IO.Directory.GetDirectories(IOTools.GetAssetPath("/GameRes/Model/Weapon/"))
	for i = 0, dirlist.Length - 1 do
		lWeapons[IOTools.GetFileName(dirlist[i])] = true
	end

	sOut = sOut.."--DataTools.GenEditorData生成数据\n%s\n%s\n%s"
	sOut = string.format(sOut, table.dump(lMagicFiles, "MAGIC_FILE"), table.dump(lShapes, "SHAPE"), table.dump(lWeapons, "WEAPON"))
	local sOutPath = IOTools.GetAssetPath("/Lua/logic/data/editordata.lua")
	local fileobj = io.open(sOutPath, "w")
	fileobj:write(sOut)
	fileobj:close()
	printc("生成完毕")
end


return CTestEditorWindow