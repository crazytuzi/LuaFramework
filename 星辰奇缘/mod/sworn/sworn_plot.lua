-- -------------------------------------------------------------
-- 结拜完成后剧情播放
-- hosr
-- 结拜剧情	1.按照人数，让玩家站到地图指定坐标

-- 	地图ID 10003
-- 	剧情坐标：	X坐标	Y坐标	朝向
-- 	老大	600	2280	0
-- 	老二	720	2320	1
-- 	老三	520	2320	7
-- 	老四	440	2360	7
-- 	老五	760	2360	1

-- 	2.播放冒泡对白：
-- 		0s	老大：	本人玩家名在此立誓{face_1,7}
-- 		2s	老二：	本人玩家名在此立誓{face_1,7}
-- 		4s	老三：	……
-- 		X	……
-- 		X+2s	全体成员：	愿以自定义称号为名，结为异姓兄弟姐妹				随机表情	{face_1,3}	{face_1,1}	{face_1,29}	{face_1,25}	{face_1,38}
-- 		X+5s	全体成员：	从此有福同享、有难同当{face_1,18}
-- 		同时	播放烟花：	30157
-- -------------------------------------------------------------
SwornPlot = SwornPlot or BaseClass()

function SwornPlot:__init(model)
	self.model = model
	self.dataList = {}
	self.posList = {
		{x = 600, y = 2280},
		{x = 720, y = 2320},
		{x = 520, y = 2320},
		{x = 440, y = 2360},
		{x = 760, y = 2360},
	}
	self.dirList = {0, 1, 7, 7, 1}
	self.talkList = {
		TI18N("本人%s在此立誓{face_1,7}"),
		TI18N("本人%s在此立誓{face_1,7}"),
		TI18N("本人%s在此立誓{face_1,7}"),
		TI18N("本人%s在此立誓{face_1,7}"),
		TI18N("本人%s在此立誓{face_1,7}"),
	}
	self.faceList = {3, 1, 29, 25, 38}
	self.alltalk1 = TI18N("愿以%s为名，结为异姓兄弟姐妹{face_1,%s}")
	self.alltalk2 = TI18N("从此有福同享、有难同当{face_1,18}")
	self.effectPath = "prefabs/effect/30157.unity3d"

	self.createList = {}
	self.bubbleList = {}
	self.next = function() self:Next() end

	self.index = 0
end

function SwornPlot:RandomFace(seed)
	math.randomseed(seed * 10000000)
	return self.faceList[math.random(1, 5)]
end

function SwornPlot:__delete()
	self:RemoveEffect()
	self:ClearElements()
end

function SwornPlot:Start()
	self:InitData()
	self:CreateElements()
	self:BeginPlot()
	LuaTimer.Add(1000, self.next)
end

function SwornPlot:Next()
	self.index = self.index + 1
	if self.index == 1 then
		if self:ShowBubble(1) then
			LuaTimer.Add(2000, self.next)
		else
			self:Next()
		end
	elseif self.index == 2 then
		if self:ShowBubble(2) then
			LuaTimer.Add(2000, self.next)
		else
			self:Next()
		end
	elseif self.index == 3 then
		if self:ShowBubble(3) then
			LuaTimer.Add(2000, self.next)
		else
			self:Next()
		end
	elseif self.index == 4 then
		if self:ShowBubble(4) then
			LuaTimer.Add(2000, self.next)
		else
			self:Next()
		end
	elseif self.index == 5 then
		if self:ShowBubble(5) then
			LuaTimer.Add(2000, self.next)
		else
			self:Next()
		end
	elseif self.index == 6 then
		self:AllTalk1()
		LuaTimer.Add(3000, self.next)
	elseif self.index == 7 then
		self:AllTalk2()
		LuaTimer.Add(3000, self.next)
	elseif self.index == 8 then
		self:FireEffect()
		LuaTimer.Add(3500, self.next)
	else
		self:EndPlot()
	end
end

function SwornPlot:InitData()
	for key,v in pairs(TeamManager.Instance.memberTab) do
		local data = BaseUtils.copytab(v)
		local sworn = SwornManager.Instance.model.menberTab[key]
		data.pos = 0
		if sworn ~= nil then
			data.pos = sworn
		end
		table.insert(self.dataList, data)
	end
	table.sort(self.dataList, function(a,b) return a.pos < b.pos end)
end

-- gm 结拜剧情
-- gm 结拜重置
-- gm 结拜战斗

-- 创建所需单位
function SwornPlot:CreateElements()
	for i,data in ipairs(self.dataList) do
		local unit = {}
		unit.unit_id = i
		unit.battle_id = 0
		unit.unit_base_id = 20030
		unit.msg = data.name
		unit.mapid = 10003
		unit.x = self.posList[i].x
		unit.y = self.posList[i].y
		unit.val = self.dirList[i]
		unit.ext_msg = 0
		unit.mode = 0
		unit.looks = data.looks or {}
		unit.sex = data.sex
		unit.classes = data.classes
	    DramaVirtualUnit.Instance:CreateUnit(unit)
	    table.insert(self.createList, unit)
	end
end

-- 移除创建单位
function SwornPlot:ClearElements()
	for i,v in ipairs(self.createList) do
	    DramaVirtualUnit.Instance:RemoveUnit(v)
	end
end

function SwornPlot:ShowBubble(index, content)
	local unit = self.createList[index]
	if unit == nil then
		return false
	end

    if content == nil then
    	SceneTalk.Instance:ShowTalk_NPC(unit.unit_id, unit.battle_id, string.format(self.talkList[index], unit.msg), 2)
    else
    	SceneTalk.Instance:ShowTalk_NPC(unit.unit_id, unit.battle_id, content, 3)
    end
	return true
end

function SwornPlot:AllTalk1()
	local members = self.model.swornData.members
	for i = 1, 5 do
		if members[i] ~= nil then
			local content = string.format(self.alltalk1, SwornManager.Instance:GetFullName(i), self:RandomFace(i))
			self:ShowBubble(i, content)
		end
	end
end

function SwornPlot:AllTalk2()
	for i = 1, 5 do
		self:ShowBubble(i, self.alltalk2)
	end
end

function SwornPlot:FireEffect()
	if self.assetWrapper == nil then
		self.assetWrapper = AssetBatchWrapper.New()
	    self.resList = {{file = self.effectPath, type = AssetType.Main}}
	    self.assetWrapper:LoadAssetBundle(self.resList, function () self:OnEffectLoaded() end)
	end
end

function SwornPlot:OnEffectLoaded()
	if self.assetWrapper ~= nil then
	    self.effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath))
	    self.effect.name = "SwornPlotFireEffect"
	    local trans = self.effect.transform
	    trans:SetParent(ctx.CanvasContainer.transform)
	    trans.localScale = Vector3.one * 200
	    trans.localPosition = Vector3(0, 0, -500)
	    Utils.ChangeLayersRecursively(trans, "UI")
	    self.effect:SetActive(true)
	    -- self.effectTime = LuaTimer.Add(4000, function() self:RemoveEffect() end)

	    self.assetWrapper:DeleteMe()
	    self.assetWrapper = nil
	end
end

function SwornPlot:RemoveEffect()
	-- if self.effectTime ~= nil then
	-- 	LuaTimer.Delete(self.effectTime)
	-- 	self.effectTime = nil
	-- end

	if self.effect ~= nil then
        GameObject.DestroyImmediate(self.effect)
        self.effect = nil
	end
end

-- 剧情开始准备
function SwornPlot:BeginPlot()
	self:SetCamera()
    RoleManager.Instance.RoleData.drama_status = RoleEumn.DramaStatus.Running
    DramaManager.Instance.model:HideMain()
	DramaManager.Instance.model.dramaMask.gameObject:SetActive(true)
	if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
		SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
	end
    SceneManager.Instance.sceneElementsModel.self_data.canIdle = false
    SceneManager.Instance.sceneElementsModel:Show_Self(false)
    SceneManager.Instance.sceneElementsModel:Show_OtherRole(false)
    SceneManager.Instance.sceneElementsModel:Show_Npc(false)
end

function SwornPlot:EndPlot()
    RoleManager.Instance.RoleData.drama_status = RoleEumn.DramaStatus.None
    DramaManager.Instance.model:ShowUIHided()
    DramaManager.Instance.model.dramaMask.gameObject:SetActive(false)
    SceneManager.Instance.sceneElementsModel:Show_Self(true)
    SceneManager.Instance.sceneElementsModel:Show_OtherRole(true)
    SceneManager.Instance.sceneElementsModel:Show_Self_Weapon(true)
    SceneManager.Instance.MainCamera.lock = false
    SceneManager.Instance.sceneElementsModel.self_data.canIdle = true
    SceneManager.Instance.sceneElementsModel:Show_Npc(true)

	self.model:EndPlot()
end

function SwornPlot:SetCamera()
    SceneManager.Instance.MainCamera.lock = true
    local startpos = SceneManager.Instance.MainCamera.transform.position
    local endpos = SceneManager.Instance.sceneModel:transport_small_pos(620, 2320)
    endpos = Vector3(endpos.x, endpos.y, 0)
    Tween.Instance:Move(SceneManager.Instance.MainCamera.gameObject, endpos, 0.5)
end