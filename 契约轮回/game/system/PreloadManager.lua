-- 
-- @Author: LaoY
-- @Date:   2018-07-14 15:19:32
-- 预加载模块 ui 场景 特效

-- 奖励界面底框
require('game.reward.RequireReward')

require("game/system/PreloadObject")

is_cache_object_visible = true

PreloadManager = PreloadManager or class("PreloadManager",BaseManager)
local PreloadManager = PreloadManager

function PreloadManager:ctor()
	PreloadManager.Instance = self
	self.asset_list = {}

	self.load_list = {}
	self.is_loaded = false
	self.load_count = 0

	self.scene_object_count = 50
	self.scene_object_list = {}

	self.scene_load_count = 0
	self.scene_has_load_count = 0

	self.preload_scene_object_count  = 0
	self.preload_scene_object_load_count = 0
	self:Reset()
	self:AddEvent()
	self:InitLoadList()
end

function PreloadManager:Reset()

end

function PreloadManager.GetInstance()
	if PreloadManager.Instance == nil then
		PreloadManager()
	end
	return PreloadManager.Instance
end

function PreloadManager:AddEvent()
	local function call_back()
		self:InitPreloadManager()
		if self.event_id_1 then
			GlobalEvent:RemoveListener(self.event_id_1)
			self.event_id_1 = nil
		end
	end
	self.event_id_1 = GlobalEvent:AddListener(EventName.HotUpdateSuccess, call_back)


	local function call_back()
		self:LoadSkill()
	end
	GlobalEvent:AddListener(SkillUIEvent.UpdateSkillSlots, call_back)

	-- local function call_back()
	-- 	self:ChangeScene()
	-- end
	-- GlobalEvent:AddListener(EventName.ChangeSceneStart, call_back)
end

function PreloadManager:ChangeScene()
	local scene_id = SceneManager:GetInstance():GetSceneId()
	self.preload_scene_object_count  = 0
	self.preload_scene_object_load_count = 0
	

	local function step()
		self:CheckDownLoadResBySceneID(scene_id)
	end
	if LoadingCtrl:GetInstance().loadingPanel then
		GlobalSchedule:StartOnce(step,10)
	else
		GlobalSchedule:StartOnce(step,5.0)
	end

	local is_need_loading = LoadingCtrl:GetInstance():IsNeedLoading(scene_id)
	-- 屏蔽预加载NPC等内容
	do
		return
	end
	if not is_need_loading then
		return
	end
	self:AddNpc()
	self:AddBoss()
	self:AddEffect()

	GlobalEvent:Brocast(EventName.PreLoadObject,self.preload_scene_object_load_count,self.preload_scene_object_count,self.need_down_load_size_cout,self.have_down_load_size_cout)
end

local function addpreloadlist(t,abName,maxCount)
	maxCount = maxCount or Constant.CacheRoleObject
	if t[abName] and t[abName] >= maxCount then
		return
	end
	t[abName] = t[abName] or 0
	t[abName] = t[abName] + 1
end

function PreloadManager:AddNpc()
	local scene_id = SceneManager:GetInstance():GetSceneId()
	local config = SceneConfigManager:GetInstance():GetSceneConfig(scene_id)
	local list = {}
	for k,v in pairs(config.Npcs) do
		local cf = Config.db_npc[v.id]
		if cf then
			addpreloadlist(list,cf.figure,1)
		end
	end
	self:AddPreloadObjectList(list)
end

function PreloadManager:AddBoss()
	local scene_id = SceneManager:GetInstance():GetSceneId()
	local config = SceneConfigManager:GetInstance():GetSceneConfig(scene_id)
	local list = {}
	for k,v in pairs(config.Monsters) do
		local cf = Config.db_creep[v.id]
		if cf and (
			cf.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS or 
			cf.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS2 or
			cf.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS3
			) then
			addpreloadlist(list,cf.figure,1)
		end
	end
	self:AddPreloadObjectList(list)
end

function PreloadManager:AddEffect()
	local scene_id = SceneManager:GetInstance():GetSceneId()
	local cf = SceneEffectConfig[scene_id]
	if not cf then
		return
	end
	local list = {}
	for k,v in pairs(cf) do
		addpreloadlist(list,v.name,1)
	end
	self:AddPreloadObjectList(list)
end

function PreloadManager:AddPreloadObjectList(list)
	for abName,count in pairs(list) do
		self.preload_scene_object_count = self.preload_scene_object_count + count
		-- poolMgr:AddConfig(abName, abName, 1, Constant.InPoolTime, true)
		for i=1,count do
			self:AddPreLoadObject(abName,abName,count,handler(self,self.PreloadObjectCallBack))
		end
	end
end

function PreloadManager:PreloadObjectCallBack()
	self.preload_scene_object_load_count = self.preload_scene_object_load_count + 1

	GlobalEvent:Brocast(EventName.PreLoadObject,self.preload_scene_object_load_count,self.preload_scene_object_count,self.need_down_load_size_cout,self.have_down_load_size_cout)
end

function PreloadManager:AddPreLoadObject(abName,assetName,cache_count,call_back)
	PreloadObject(abName,assetName,cache_count,call_back)
end

function PreloadManager:CheckDownLoadResBySceneID(scene_id)
	scene_id = scene_id or SceneManager:GetInstance():GetSceneId()
	local count = #Config.db_res_load
	local t = {}
	for i=1,count do
		local cf = Config.db_res_load[i]
		if cf.lv == scene_id then
			local abName = GetRealAssetPath(cf.name)
			-- if not lua_resMgr:IsInDownLoading(abName) and not lua_resMgr:IsInJumpList(abName) and lua_resMgr:IsInDownLoadList(abName) then
			if lua_resMgr:IsInDownLoadList(abName) then
				t[#t+1] = abName
			end
		end
	end
	if scene_id == -1 then
        local channelID = tostring(PlatformManager:GetInstance():GetChannelID());--tostring(112982);--
		if channelID == "112981" or channelID == "112982" then
	        local res = "login_bg";
	        local abName
	        abName = "asset/" .. channelID .. "/icon_big_bg_" .. res
	        if lua_resMgr:IsInDownLoadList(abName) then
				t[#t+1] = abName
			end
	        res = "logo";
	        abName = "asset/" .. channelID .. "/icon_big_bg_" .. res
	        if lua_resMgr:IsInDownLoadList(abName) then
				t[#t+1] = abName
			end
	    end
	end
	
	if scene_id == -1 then
		self:AddDownLoadList(t)
	else
		local load_level = Constant.LoadResLevel.Down
		for index,abName in pairs(t) do
			lua_resMgr:AddDownLoadList(self, abName, nil, load_level)
		end
	end
end

function PreloadManager:AddDownLoadList(list)
	local count = #list
	self.preload_scene_object_count = self.preload_scene_object_count + count

	-- local function callBack(abName)
	-- 	local size = lua_resMgr:GetDownLoadFileSize(abName)
	-- 	self.have_down_load_size_cout = self.have_down_load_size_cout + size
	-- 	GlobalEvent:Brocast(EventName.PreLoadObject,self.preload_scene_object_load_count,self.preload_scene_object_count,self.need_down_load_size_cout,self.have_down_load_size_cout)
	-- end

	local load_level = Constant.LoadResLevel.Down
	for index,abName in pairs(list) do
		local size = lua_resMgr:GetDownLoadFileSize(abName)
		local function callBack()
			self.preload_scene_object_load_count = self.preload_scene_object_load_count + 1
			self.have_down_load_size_cout = self.have_down_load_size_cout + size
			GlobalEvent:Brocast(EventName.PreLoadObject,self.preload_scene_object_load_count,self.preload_scene_object_count,self.need_down_load_size_cout,self.have_down_load_size_cout)
		end
		self.need_down_load_size_cout = self.need_down_load_size_cout + size
		DebugLog("============self.need_down_load_size_cout = ",abName,self.need_down_load_size_cout)
		lua_resMgr:AddDownLoadList(self, abName, callBack, load_level)
	end
end

function PreloadManager:InitLoadList()
	local abName = "system"
	self:AddUIPreload(abName,"EmptyImage")

	poolMgr:AddConfig(abName,"EmptyImage",20,0,false,true)

	self:AddUIPreload(abName,"EmptyObject")
	self:AddUIPreload(abName,"EmptyLabel")
	self:AddUIPreload("system","RoleIcon")
	self:AddUIPreload(abName,"NotifyText")
	self:AddUIPreload(abName,"NotifyGoods")
	self:AddUIPreload(abName,"PanelBackground")
	self:AddUIPreload(abName,"PanelBackgroundTwo")
    self:AddUIPreload(abName,"PanelBackgroundThree")
    self:AddUIPreload(abName,"PanelBackgroundFour")
	self:AddUIPreload(abName,"PanelBackgroundFive")
	self:AddUIPreload(abName,"PanelBackgroundSix")
	self:AddUIPreload(abName,"PanelTabButton")
	self:AddUIPreload(abName,"PanelTabButtonTwo")
	self:AddUIPreload(abName,"PanelTabButtonThree")
	self:AddUIPreload(abName,"PanelBackgroundSeven")


	local function call_back()
		for i=1,self.scene_object_count do
			local object = self:CreateWidget("system","SceneObject")
			self:AddSceneObject(object)
		end
	end
	self:AddUIPreload(abName,"SceneObject",nil,call_back)

	local function call_back()
		local list = {}
		for i=1,SceneObjectText.__cache_count do
			local item = SceneObjectText()
			list[#list+1] = item
		end
		for k,item in pairs(list) do
			item:destroy()
		end
	end
	self:AddUIPreload(abName,"SceneObjectText",nil,call_back);

    local function call_back1()
        local list = {}
        for i=1,RoleText.__cache_count do
            local item = RoleText()
            list[#list+1] = item
        end
        for k,item in pairs(list) do
            item:destroy()
        end
    end
    self:AddUIPreload(abName,"RoleText",nil,call_back1)
    local function call_back2()
        local list = {}
        for i=1,MonsterText.__cache_count do
            local item = MonsterText()
            list[#list+1] = item
        end
        for k,item in pairs(list) do
            item:destroy()
        end
    end
    self:AddUIPreload(abName,"MonsterText",nil,call_back2)

	self:AddUIPreload(abName,"DialogPanel")
    self:AddUIPreload(abName,"RevivePanel")
    self:AddUIPreload(abName,"RevivePanel2")
	self:AddUIPreload(abName,"MoneyItem")
	self:AddUIPreload(abName,"AwardItem")
    self:AddUIPreload(abName,"AdvanceDungeonItem")
	self:AddUIPreload(abName,"ExpNotify")

	self:AddUIPreload("system", "FoldMenu")
	self:AddUIPreload("system","FirstMenuItem")
	self:AddUIPreload("system","SecondMenuItem")

	self:AddUIPreload("system", "TreeMenu")
	self:AddUIPreload("system","TreeOneMenu")
	self:AddUIPreload("system","TreeTwoMenu")

	self:AddUIPreload("system","FriendTreeMenu")
	self:AddUIPreload("system","FriendTreeMenuItem")
	self:AddUIPreload("system","FriendTreeSubMenuItem")


	self:AddUIPreload("system","RankTreeMenu")
	self:AddUIPreload("system","RankOneMenu")
	self:AddUIPreload("system","RankTwoMenu")

	self:AddUIPreload("system","AchieveFoldMenu")
	self:AddUIPreload("system","AchieveOneMenu")
	self:AddUIPreload("system","AchieveTwoMenu")

	self:AddUIPreload("system","StigmataCompoundFoldMenu")
	self:AddUIPreload("system","StigmataCompoundOneMenu")
	self:AddUIPreload("system","StigmataCompoundTwoMenu")

	self:AddUIPreload("system","illustrationFoldMenu")
	self:AddUIPreload("system","illustrationOneMenu")
	self:AddUIPreload("system","illustrationTwoMenu")
	
	self:AddUIPreload("system","ToggleGroup")
	self:AddUIPreload("system","TurnTable")

	self:AddUIPreload("system","EquipPanel")
	self:AddUIPreload("system","Equip2AttrInfoItem")
	self:AddUIPreload("system","EquipAttrInfoItem")
	self:AddUIPreload("system","EquipDetailView")
	self:AddUIPreload("system","EquipStoneAttrItem")
	self:AddUIPreload("system","EquipStoneInfoItem")
	self:AddUIPreload("system","EquipStoneNoAttrItem")
	self:AddUIPreload("system","EquipTipCareerInfo")
	self:AddUIPreload("system","GoodsAttrItem")
	self:AddUIPreload("system","GoodsDetailView")
	self:AddUIPreload("system","GoodsIcon")
	self:AddUIPreload("system","GoodsIconSettorTwo")

	poolMgr:AddConfig("system","GoodsIconSettorTwo",30,0,false,true)

	self:AddUIPreload("system","GoodsJumpItemItem")
	self:AddUIPreload("system","GoodsJumpItem")
	self:AddUIPreload("system","MagicCardView")
	self:AddUIPreload("system","ComTipAttrItem")
	self:AddUIPreload("system","StigmataDetailView")
	self:AddUIPreload("system","DecomposeGetItem")
	self:AddUIPreload("system","BabyDetailView")
	self:AddUIPreload("system","MechaDetailView")

	 self:AddUIPreload("system","GoodsOperateBtn")
	 self:AddUIPreload("system","StoneDetailView")
	 --self:AddUIPreload("system","StoneDetailViewOnly")
	 --self:AddUIPreload("system","StoneDetailPanel")

	-- self:AddUIPreload("system","UseGoodsView")


	self:AddUIPreload("system","BagItem")
	self:AddUIPreload("system","BagSellItem")
	self:AddUIPreload("system","EquipItem")
	self:AddUIPreload("system","StoneItem")

	--self:AddUIPreload("system","PutOnedIconSettor")
	--self:AddUIPreload("system","CombineIcon")
	self:AddUIPreload("system","TreeOnePhotoMenu")
	self:AddUIPreload("system","TreeTwoPhotoMenu")

	-- self:AddUIPreload("system","UIRoleCamera")
	self:AddUIPreload("system","UIModelCameraView")
	self:AddUIPreload("system","UIModelCameraViewPerspective")
	self:AddUIPreload("system","RedDot")

	self:AddUIPreload("system","BuyMarketBuyPanel")
	self:AddUIPreload("system","BuyMarketBuyTowPanel")


	self:AddUIPreload("system","BabyFoldMenu")
	self:AddUIPreload("system","BabyMenuItem")
	self:AddUIPreload("system","BabyMenuSubItem")

	self:AddUIPreload("system","GodFoldMenu")
	self:AddUIPreload("system","GodMenuItem")
	self:AddUIPreload("system","GodMenuSubItem")

	self:AddUIPreload("system","ArtifactFoldMenu")
	self:AddUIPreload("system","ArtifactMenuItem")
	self:AddUIPreload("system","ArtifactMenuSubItem")

	-- 加载界面相关
	self:AddUIPreload("system","LoadingResItem")

	self:AddUIPreload("system","ComIconTip")
	self:AddUIPreload("system","ComIconTipTwo")

	self:AddUIPreload("system","SceneObjTitle")

	self:AddUIPreload("system","ReviveHelpPanel") --复活求助


	local function call_back()
		local list = {}
		for i=1,MapBlock.__cache_count * 0.5 do
			local item = MapBlock()
			list[#list+1] = item
		end
		for k,item in pairs(list) do
			item:destroy()
		end
	end
	self:AddUIPreload("mapasset/mapres_tilemap","tilemap",true,call_back)

	local function call_back()
		local list = {}
		for i=1,ShadowImage.__cache_count * 0.5 do
			local item = ShadowImage()
			list[#list+1] = item
		end
		for k,item in pairs(list) do
			item:destroy()
		end
	end
	self:AddUIPreload("mapasset/mapres_shadowsprite","shadowsprite",true,call_back)
end

function PreloadManager:AddUIPreload(abName,assetName,ignore_suffix,call_back)
	-- poolMgr:AddConfig(abName,assetName,1,0,false)
	self.is_load_list = self.is_load_list or {}
	self.is_load_list[assetName] = true
	local tab = {abName = abName,assetName = assetName,ignore_suffix = ignore_suffix,call_back = call_back}
	self.load_list[#self.load_list + 1] = tab
end

function PreloadManager:InitPreloadManager()
	if not self.load_list then
		return
	end

	self.need_down_load_size_cout = 0
	self.have_down_load_size_cout = 0

	self:LoadSceneRes()
	self:CheckDownLoadResBySceneID(-1)
	local length = #self.load_list
	for i=1,length do
		local asset = self.load_list[i]
		if asset then
			self:LoadPrefab(asset.abName,asset.assetName,asset.ignore_suffix,asset.call_back)
		end
	end

	GlobalEvent:Brocast(EventName.PreLoadObject,0,self.preload_scene_object_count,self.need_down_load_size_cout,self.have_down_load_size_cout)
	GlobalEvent:Brocast(EventName.LoadComponent,0,0,length)
	FilterWords:GetInstance()
end

-- 初始化基础控件
function PreloadManager:LoadPrefab(abName,assetName,ignore_suffix,call_back)
	local function load_call_back(obj)
		if not obj or not obj[0] then
			print('--PreloadManager.lua,line 83-- data=',abName,assetName,obj,obj and obj[0])
			return
		end
		obj = obj[0]
		if not PlatformManager:GetInstance():IsMobile() then
			obj = newObject(obj)
		end
		self.asset_list[abName] = self.asset_list[abName] or {}
		self.asset_list[abName][assetName] = obj
		local layer = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.CacheLayer)
		local transform = obj.transform
		transform:SetParent(layer)
		SetLocalPosition(transform,0,0,0)

		if call_back then
			--local new_obj = self:CloneObject(obj)
			--call_back(new_obj)

            -- resMgr:GetPrefab("","",obj , call_back);

            call_back()
		end
		self.load_count = self.load_count + 1
		local all_count = #self.load_list
		GlobalEvent:Brocast(EventName.LoadComponent,self.load_count/all_count,self.load_count,all_count)
		self.is_load_list[assetName] = false
		 if AppConfig.Debug and false then
		 	Yzprint('--LaoY ======>',self.load_count)
		 	if self.load_count >= 52 then
		 		local list = {}
		 		for k,v in pairs(self.is_load_list) do
		 			if v then
		 				list[k] = v
		 			end
		 		end
		 		--print('--尚未加载的资源数量为',#list)
		 		--dump(list,"tab")
		 	end
		 end
		if self.load_count >= all_count then
			self.is_loaded = true
			self.load_list = nil
		end
	end
	local str = ignore_suffix and "" or "_prefab"
	if assetName == "FoldMenu" then
		local a = 3
	end
	lua_resMgr:LoadPrefab(self,abName .. str,assetName,load_call_back)
	-- resMgr:LoadPrefab(abName .. str,assetName,load_call_back)
end

function PreloadManager:CreateWidget(abName,assetName)
	if self.asset_list[abName] and self.asset_list[abName][assetName] then
		local new_obj = poolMgr:GetGameObject(self,abName,assetName)
		if new_obj then
			return new_obj
		end
		local obj = self.asset_list[abName][assetName]
		new_obj = self:CloneObject(obj)
		return new_obj
	else
		local str = string.format("abName = %s,assetName = %s,not loaded！！！ ",abName,assetName)
		logError(str)
	end
	-- 必须全部通用控件加载完才可以进入游戏
	-- self:CreateWidget(cls,abName,assetName,call_back)
end

function PreloadManager:CloneObject(obj)
	--todo
    --print2("PreloadManager:CloneObject" .. debug.traceback());
	return newObject(obj)
end

function PreloadManager:CreateImage(parent,width,height,scale)
	local img = self:CreateWidget("system","EmptyImage")
	img_transform = img.transform
	img_transform:SetParent(parent)
	scale = scale or 1
	SetLocalScale(img_transform,scale,scale,scale)
	if width and height then
		SetSizeDelta(img_transform,width,height)
	end
	return {gameObject = img,transform = img_transform,component = img_transform:GetComponent('Image')}
end

-- 时机应该放在loading界面
function PreloadManager:LoadSceneRes()	
	require("game/config/auto/db_cache")
	self.preload_scene_object_count = 0
	self.preload_scene_object_load_count = 0
	for k,v in pairs(Config.db_cache) do
		local abName = v.abName
		local assetName = v.assetName
		if v.assetName == "" then
			assetName = v.abName
		end
		poolMgr:AddConfig(abName, assetName, v.max_count, 0, false)
		-- 屏蔽预加载的内容
		-- self.preload_scene_object_count = self.preload_scene_object_count + v.max_count
		-- for i=1,v.max_count do
		-- 	self:AddPreLoadObject(abName,assetName,v.max_count,handler(self,self.PreloadObjectCallBack))
		-- end
	end
	self.is_load_scene = true
end

PreloadManager.SkillList = {}
function PreloadManager:LoadSkill()

	local exist_list = clone(PreloadManager.SkillList)
	PreloadManager.SkillList = {}
	local h_list = {}
	local list = SkillUIModel:GetInstance():GetSkillList()
	for k,skill in pairs(list) do
		local skill_id = skill.id
		local cf = FightConfig.SkillConfig[skill.id]
		if cf and not table.isempty(cf.effect) then
			for i, v in pairs(cf.effect) do
				if AppConfig.Debug and type(v) == "number" then
					logError("技能表现配置出错，id:",skill_id)
				end
				local real_name = GetRealAssetPath(v.name)
				PreloadManager.SkillList[real_name] = v.name
				if not exist_list[real_name] and not h_list[real_name] then
					h_list[real_name] = true
					self:PreLoadPrefab(v.name)
					if v.effect_type == FightConfig.EffectType.Hurt then
						PoolManager:GetInstance():AddConfig(v.name,v.name,EffectManager.BeHitEffectCount,0,false,true)
					else
						PoolManager:GetInstance():AddConfig(v.name,v.name,Constant.CacheRoleObject,0,false)
					end
				end
			end
		end
	end

	h_list = nil

	for real_name,assetName in pairs(exist_list) do
		if not PreloadManager.SkillList[real_name] then
			PoolManager:GetInstance():RemovePool(real_name,assetName)
		end
	end

end

function PreloadManager:RemoveSkill()

end

function PreloadManager:PreLoadPrefab(abName,assetName,is_unload_imm)
	self.scene_load_count = self.scene_load_count + 1
	assetName = assetName or abName
	is_unload_imm = is_unload_imm == nil and true or is_unload_imm
	local function load_call_back()
		self.scene_has_load_count = self.scene_has_load_count + 1
		if AppConfig.Debug and PreloadManager.SkillList[GetRealAssetPath(abName)] then
			--Yzprint('--LaoY PreloadManager.lua,line 362--',abName)
			--traceback()
		end
	end
	lua_resMgr:LoadPrefab(self, abName,assetName, load_call_back,nil,Constant.LoadResLevel.Best,true,is_unload_imm,true)
end

function PreloadManager:GetSceneObject()
	local object = table.remove(self.scene_object_list)
	if not object then
		object = self:CreateWidget("system","SceneObject")
	else
		if is_cache_object_visible then
			object:SetActive(true)
		end
	end
	return object
end

function PreloadManager:AddSceneObject(object)
	if not object or IsNil(object) then
		return false
	end
	if #self.scene_object_list >= self.scene_object_count then
		return false	
	end
	local layer = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneObjCache)
	object.transform:SetParent(layer)
	SetLocalPosition(object.transform,0,0,0)
	SetLocalRotation(object.transform,0,0,0)
	
	if is_cache_object_visible then
		object:SetActive(false)
	end
	if AppConfig.Debug then
		-- object.transform.name = "sceneobject_" .. #self.scene_object_list+1
	end
	table.insert(self.scene_object_list,object)
	return true
end