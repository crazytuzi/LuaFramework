module(..., package.seeall)
g_CurveCache = {}
function ReleaseAll()
end

function ExportModelAll()
	local list = ModelTools.GetAllModelShape()
	local iLen = #list
	for i, shape in ipairs(list) do
		if shape <= 3000 then
			ExportOne(tostring(shape), false)
			EditorUtility.DisplayProgressBar(tostring(shape), string.format("进度:%d/%d", i,iLen), i/iLen)
		end
	end
	GenAnimTimeData()
	AssetDatabase.SaveAssets()
end

function ExportModel(sModel)
	ExportOne(sModel, true)
	EditorUtility.ClearProgressBar()
	local dAllData = data.animclipdata.DATA
	dAllData[tonumber(sModel)] = GetShapeAnimData(tonumber(sModel))
	for k, v in pairs(data.modeldata.SHARE_ANIM) do
		local tempData = table.copy(dAllData[v])
		for k1,v1 in pairs(dAllData[k]) do
			if tempData[k1] then
				tempData[k1] = table.update(tempData[k1], dAllData[k][k1])
			else
				tempData[k1] = dAllData[k][k1]
			end
		end
		dAllData[k] = tempData
	end
	local s = table.dump(dAllData, "DATA")
	s = "module(...)\n\n--auto generate in editorgui.GenAnimTimeData\n"..s
	IOTools.SaveTextFile(IOTools.GetAssetPath("/Lua/logic/data/animclipdata.lua"), s)
	EditorUtility.ClearProgressBar()
	AssetDatabase.Refresh()
	AssetDatabase.SaveAssets()
end

function ExportOne(sModel, bProgress)
	ShaderReplace(sModel)
	local modelFloderPath = GetModelFloderPath(sModel)
	local path = string.format("%s/Anim", modelFloderPath, sModel)
	local guids = Utils.ArrayToList(AssetDatabase.FindAssets("t:AnimationClip", Utils.ListToArray({path}, classtype.String)))
	local iLen = #guids
	for i, guid in ipairs(guids) do
		local resPath = AssetDatabase.GUIDToAssetPath(guid)
		local fileName = IOTools.GetFileName(resPath, true)
		local sAnimName, sSub = unpack(string.split(fileName, "_"))
		
		if not string.find(sAnimName, sModel) then
			sSub = sSub and "_"..sSub or ""
			sAnimName = sModel.."_"..sAnimName
			IOTools.Move(string.format("%s/%s.anim", path, fileName), string.format("%s/%s%s.anim", path, sAnimName, sSub))
			IOTools.Move(string.format("%s/%s.anim.meta", path, fileName), string.format("%s/%s%s.anim.meta", path, sAnimName, sSub))
		end
		if bProgress then
			EditorUtility.DisplayProgressBar(sModel..fileName, string.format("进度:%d/%d", i,iLen), i/iLen)
		end
	end
	local baseAnim = "idleCity"
	local bundAnimNames = {baseAnim}
	local i = 1
	local iQuitFlag = 0
	local animator
	local iMode = tonumber(sModel)
	local iShareMode = data.modeldata.SHARE_ANIM[tonumber(sModel)]
	while (iQuitFlag ~= 3 and i <= 2) do
		local sPosfix = (i == 1) and "" or "_"..tostring(i)
		local baseAnimPath = string.format("Assets/GameRes/Model/Character/%d/Anim/%d_%s.anim", iMode, iMode, baseAnim..sPosfix)
		local shareAnimPath = ""
		if iShareMode then
			shareAnimPath = string.format("Assets/GameRes/Model/Character/%d/Anim/%d_%s.anim", iShareMode, iShareMode, baseAnim..sPosfix)
		end
		if IOTools.IsExist(shareAnimPath) or IOTools.IsExist(baseAnimPath) or (i == 1) then
			local animatorPath = string.format("Assets/GameRes/Model/Character/%d/Anim/Animator%s.overrideController", sModel, sModel..sPosfix)
			local templatePath = string.format("Assets/GameRes/Model/Template/CharacterAnim/Base/Animator.overrideController")
			IOTools.Copy(templatePath, animatorPath)
			AssetDatabase.Refresh()
			animator = AssetDatabase.LoadAssetAtPath(animatorPath, classtype.AnimatorOverrideController)
			local clippairs = animator.clips
			for i=0, clippairs.Length -1 do
				local clippair = clippairs[i]
				local name = clippair.originalClip.name
				if table.index(bundAnimNames, name) then
					local clipPath = string.format("Assets/GameRes/Model/Character/%d/Anim/%d_%s.anim", iMode, iMode, name..sPosfix)
					local sharePath = nil
					if iShareMode then
						sharePath = string.format("Assets/GameRes/Model/Character/%d/Anim/%d_%s.anim", iShareMode, iShareMode, name..sPosfix)
					end
					local namePath = string.format("Assets/GameRes/Model/Character/%d/Anim/%d_%s.anim", iMode, iMode, name)
					local clip = nil
					if IOTools.IsExist(clipPath) then
						clip = AssetDatabase.LoadAssetAtPath(clipPath, classtype.AnimationClip)
					elseif IOTools.IsExist(sharePath) then
						clip = AssetDatabase.LoadAssetAtPath(sharePath, classtype.AnimationClip)
					elseif IOTools.IsExist(namePath) then
						clip = AssetDatabase.LoadAssetAtPath(namePath, classtype.AnimationClip)
					end
					if clip then
						animator:set_Item(name, clip)
					end
				else
					animator:set_Item(name, nil)
				end
			end
		else
			iQuitFlag = MathBit.andOp(iQuitFlag, 1)
		end
			
		local modelPath = string.format("%s/Prefabs/model%s.prefab", modelFloderPath, sModel..sPosfix)
		if IOTools.IsExist(modelPath) then
			local oldGo = AssetDatabase.LoadAssetAtPath(modelPath, classtype.GameObject)
			if oldGo then
				local go = UnityEngine.Object.Instantiate(oldGo)
				go:GetMissingComponent(classtype.RenderObjectHandler)
				local replaceceAnimator = go:GetMissingComponent(classtype.Animator)
				replaceceAnimator.runtimeAnimatorController = animator
				replaceceAnimator.cullingMode = 0
				local waist = go.transform:Find("Mount_Hit")
				if waist then
					local renderer = waist.gameObject:GetComponent(classtype.MeshRenderer)
					if renderer then
						UnityEngine.Object.DestroyImmediate(renderer)
					end
				end
				PrefabUtility.ReplacePrefab(go, oldGo)
				UnityEngine.Object.DestroyImmediate(oldGo)
				UnityEngine.Object.DestroyImmediate(go)
			end
		else
			iQuitFlag = MathBit.andOp(iQuitFlag, 2)
		end
		i = i + 1
	end
end

function GetModelFloderPath(sModel)
	local iModel = tonumber(sModel)
	local path = ""
	if iModel >= 2000 and iModel <= 3000 then
		path = string.format("Assets/GameRes/Model/Weapon/%s", sModel)
	else
		path = string.format("Assets/GameRes/Model/Character/%s", sModel)
	end
	return path
end

function ShaderReplace(sModel)
	local shader = AssetDatabase.LoadAssetAtPath("Assets/Shaders/BaoyuShader/Baoyu-Unlit-Model-Outline.shader", classtype.Shader)
	local matGUIDs = AssetDatabase.FindAssets("t:Material", Utils.ListToArray({GetModelFloderPath(sModel)}, classtype.String))
	for i=0, matGUIDs.Length-1 do
		local resPath = AssetDatabase.GUIDToAssetPath(matGUIDs[i])
		local mat = AssetDatabase.LoadAssetAtPath(resPath, classtype.Material)
		if string.find(mat.shader.name, "Outline") then
			mat.shader = shader
			mat:SetFloat("_Outline", 0)
			local c = Color.New(36/255, 24/255, 22/255)
			mat:SetColor("_OutlineColor", c)
		end
	end
end

function GetShapeAnimData(shape)
	local dData = {}
	local path = string.format("Assets/GameRes/Model/Character/%d/Anim", shape)
	local guids = Utils.ArrayToList(AssetDatabase.FindAssets("t:AnimationClip", Utils.ListToArray({path}, typeof(System.String))))
	for i, guid in ipairs(guids) do
		local resPath = AssetDatabase.GUIDToAssetPath(guid)
		local clip = AssetDatabase.LoadAssetAtPath(resPath, classtype.AnimationClip)
		local fileName = IOTools.GetFileName(resPath, true)
		local _, animName, sIdx = unpack(string.split(fileName, "_"))
		local idx = sIdx and tonumber(sIdx) or 1
		if not dData[idx] then
			dData[idx] = {}
		end
		if clip.frameRate ~= 30 then
			printerror("动作都应该是30帧")
			return
		end
		dData[idx][table.concat({animName, sIdx}, "_")] = {length=math.roundext(clip.length, 4) ,frame=math.floor(clip.length/(1/clip.frameRate))}
	end
	return dData
end

function GenAnimTimeData()
	local list = ModelTools.GetAllModelShape()
	local dAllData = {}
	local iLen = #list
	for i, shape in ipairs(list) do
		dAllData[shape] = GetShapeAnimData(shape)
		EditorUtility.DisplayProgressBar(tostring(shape), string.format("进度:%d/%d", i,iLen), i/iLen)
	end
	
	for k, v in pairs(data.modeldata.SHARE_ANIM) do
		if dAllData[v] then
			local tempData = table.copy(dAllData[v])
			if dAllData[k] then
				for k1,v1 in pairs(dAllData[k]) do
					if tempData[k1] then
						tempData[k1] = table.update(tempData[k1], dAllData[k][k1])
					else
						tempData[k1] = dAllData[k][k1]
					end
				end
			end
			dAllData[k] = tempData
		else
			printc(string.format("SHARE_ANIM %s is not exist", v))
		end
	end
	local s = table.dump(dAllData, "DATA")
	s = "module(...)\n\n--auto generate in editorgui.GenAnimTimeData\n"..s
	IOTools.SaveTextFile(IOTools.GetAssetPath("/Lua/logic/data/animclipdata.lua"), s)
	EditorUtility.ClearProgressBar()
	AssetDatabase.Refresh()
	printc("生成完毕！")
end

function GenAllCombActAnim()
	IOTools.CreateDirectory("Assets/GameRes/_Temp")
	for iShape, v in pairs(data.comboactdata.DATA) do
		for sAct, v2 in pairs(v) do
			CombActToAnim(iShape, sAct)
		end
	end
end

function CombActToAnim(iShape, sAct)
	iShape = tonumber(iShape)
	t = data.comboactdata.DATA[iShape][sAct]
	-- printc(">>>>>>>>>>>>>>", iShape, sAct)
	-- local t = {
	-- 	[1]={action='attack1',end_frame=10,hit_frame=3,speed=1,start_frame=0,},
	-- 	[2]={action='attack1',end_frame=23,hit_frame=23,speed=1,start_frame=10,},
	-- }
	-- local iShape = 1110
	-- sAct = "test"
	g_CurveCache = {}
	local lAllCurves = {}
	local iCurFrame = 0
	for i, v in ipairs(t) do
		local clip = GetClip(iShape, v.action)
		if clip then
			speed = v.speed or 1
			local lSub = SliceClip(clip, v.start_frame, v.end_frame, iCurFrame-v.start_frame, speed)
			iCurFrame = iCurFrame + (v.end_frame - v.start_frame) * speed
			table.extend(lAllCurves, lSub)
		end
	end
	local newclip = UnityEngine.AnimationClip.New()
	for i, one in ipairs(lAllCurves) do
		newclip:SetCurve(one.path, one.type, one.propertyName, one.curve)
	end
	local path = string.format("Assets/GameRes/_Temp/%d_%s.anim", iShape, sAct)
	AssetDatabase.CreateAsset(newclip, path)
	printc("生成完毕！", path)
end

function GetClip(iShape, sAction)
	local sPath = string.format("Assets/GameRes/Model/Character/%d/Anim/%s.anim", iShape, sAction)
	return AssetDatabase.LoadAssetAtPath(sPath, classtype.AnimationClip)
end

function SliceClip(clip, frameStart, frameEnd, offsetFrame, speed)
	local allCurves = AnimationUtility.GetAllCurves(clip)
	local sliceData = {}
	for i=0, allCurves.Length - 1 do
		local oneCurveData = allCurves[i]
		local key = string.format("%s-%s", oneCurveData.path, oneCurveData.propertyName)
		local newCurveData = AnimationClipCurveData.New()
		local bAdd =false
		for j=0, oneCurveData.curve.keys.Length-1 do
			local old = oneCurveData.curve.keys[j]
			local iFrame = ModelTools.TimeToFrame(old.time)

			if frameStart <= iFrame and iFrame <= frameEnd then
				if not g_CurveCache[key] then
					g_CurveCache[key] = UnityEngine.AnimationCurve.New()
					bAdd = true
				end
				local iTime = ModelTools.FrameToTime(frameStart + offsetFrame+ (iFrame-frameStart)*speed)
				local newKeyFrame = UnityEngine.Keyframe.New(iTime, old.value, old.inTangent, old.outTangent)
				g_CurveCache[key]:AddKey(newKeyFrame)
			end
		end
		if bAdd then
			newCurveData.curve = g_CurveCache[key]
			newCurveData.path = oneCurveData.path
			newCurveData.type = oneCurveData.type
			newCurveData.propertyName = oneCurveData.propertyName
			table.insert(sliceData, newCurveData)
		end
	end
	return sliceData
end 