--
-- @Author: LaoY
-- @Date:   2019-03-05 11:02:22
-- 缓存实例对象

PoolManager = PoolManager or class("PoolManager",BaseManager)

local cache_config = {}
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort

local function IsChangeSceneDelete(key)
	local cf = cache_config[key]
	if not cf then
		return nil
	end
	return cf.is_del_change_scene == true or cf.is_del_change_scene == 1
end

function PoolManager:ctor()
	PoolManager.Instance = self
	self.gameobject_list = {}

	self:InitConfig()
	self:Reset()

	UpdateBeat:Add(self.Update,self,4,10)

	local function call_back()
		self:ChangeScene()
	end
	GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)
end

function PoolManager:InitConfig()
	-- require("game/config/auto/db_cache")
	-- for k,v in pairs(Config.db_cache) do
	-- 	if v.assetName == "" then
	-- 		self:AddConfig(v.abName,v.abName,v.max_count,v.cache_time,v.is_del_change_scene == 1)
	-- 	else
	-- 		self:AddConfig(v.abName,v.assetName,v.max_count,v.cache_time,v.is_del_change_scene == 1)
	-- 	end
	-- end
	-- package.loaded["game/config/auto/db_cache"] = nil

	-- for k,v in pairs(Config.db_effect) do
	-- 	self:AddConfig(v.name,v.name,v.max_count,v.cache_time,v.is_del_change_scene == 1)
	-- end
end

function PoolManager:Reset()

end

function PoolManager.GetInstance()
	if PoolManager.Instance == nil then
		PoolManager()
	end
	return PoolManager.Instance
end

function PoolManager:AddConfig(abName,assetName,max_count,cache_time,is_del_change_scene,is_over_max)
	if not max_count or max_count <= 0 then
		return
	end
	abName = GetRealAssetPath(abName)
	local key = abName.. "@" ..assetName
	local cf = cache_config[key]
	if not is_over_max and max_count and max_count > Constant.CacheRoleObject then
		max_count = Constant.CacheRoleObject
	end
	if cache_time and cache_time > 0 and cache_time > Constant.InPoolTime then
		-- cache_time = Constant.InPoolTime
		if AppConfig.Debug then
			logWarn("添加缓存配置：时间过长,abName = ",abName)
		end
	end
	cache_time = cache_time == 0 and 65 or cache_time
	if cf then
		if max_count > cf.max_count then
			cf.max_count = max_count
		end
	else
		cache_config[key] = {
			max_count = max_count,
			cache_time = cache_time,
			is_del_change_scene = is_del_change_scene,
		}
	end
end

local global_pool_id = 0
-- 地图和地图阻挡文件不要加到这里 一定要注意
function PoolManager:AddGameObject(abName,assetName,go)
	if IsNil(go) then
		return false
	end
    local real_abName = assetName
    abName = GetRealAssetPath(abName)
    local key = abName.. "@" ..assetName
    -- if PreloadManager.SkillList[abName] then
    -- 	Yzprint('--LaoY PoolManager.lua,line 92--',key,go,cache_config[key])
    -- 	Yzdump(cache_config[key],"cache_config[key]")
    -- end
    if not cache_config[key] then
        return false
    end

    -- DebugLog('--LaoY PoolManager.lua,line 99--',abName,assetName,go)

    self.gameobject_list[key] = self.gameobject_list[key] or {}
    local len = #self.gameobject_list[key] + 1
    global_pool_id = global_pool_id + 1
    -- 超过缓存数量不再缓存
    if len > cache_config[key].max_count then
        return false
    end

    local info = {gameObject = go,time = Time.time,index = global_pool_id,abName = abName,assetName = assetName}
    if IsChangeSceneDelete(key) then
        info.scene_id = SceneManager:GetInstance():GetSceneId()
    end
    table_insert(self.gameobject_list[key],info)

    local layer = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneObjCache)
    go.transform:SetParent(layer)
    SetLocalPosition(go.transform,0,0,0)

 	--  if abName:find("model_") then
	-- 	local animator = go:GetComponent('Animator')
	-- 	if animator then
	-- 		animator.cullingMode = UnityEngine.AnimatorCullingMode.CullUpdateTransforms
	-- 	end
	-- end

	if abName:find("system") and assetName:find("EmptyImage") then
		local img = go.transform:GetComponent('Image')
		img.sprite = nil
	end

	if (abName:find("model_") or abName:find("effect_")) and not abName:find("effect_machiaction_") and SetCacheState(go,true) then

	else
		go:SetActive(false)
	end

	-- if abName:find("effect_") then
	-- 	PlayParticle(go, false)
	-- end

    if AppConfig.Debug then
        go.transform.name = real_abName .. "@" .. global_pool_id
    end

    -- 把最早添加的放在列表首
    local function sortFunc(a,b)
        if a.time == b.time then
            return a.index < b.index
        else
            return a.time < b.time
        end
    end
    table_sort(self.gameobject_list[key],sortFunc)

    -- 重新添加引用 不要让ab给卸载了
    lua_resMgr:AddReference(self,abName,assetName)

    local ref_info = lua_resMgr.ref_list[abName]

    -- 实际引用必须在加载完成后添加，这里只是缓存，不需要添加实际引用
    -- lua_resMgr:AddLoadRef(abName)
    return true
end

function PoolManager:Debug()
	Yzprint('--LaoY PoolManager.lua,line 163--',SceneManager:GetInstance():GetSceneId())
	Yzdump(cache_config,"cache_config")

	Yzdump(self.gameobject_list)
end

--[[
	@author LaoY
	@des	获取缓存 gameObject
	@param1 cls 	class 用来转移引用
	@param2 abName 	
	@param3 assetName 	
	@return gameObject
--]]
function PoolManager:GetGameObject(cls,abName,assetName)
	-- abName = GetRealAssetPath(abName)
	local key = abName.. "@" ..assetName
	if not cache_config[key] or table.isempty(self.gameobject_list[key]) then
		return nil
	end
	local info = table_remove(self.gameobject_list[key],1)
	if info then
		-- 转移引用
		if cls then
			lua_resMgr:RemoveReference(self,abName,assetName)
			lua_resMgr:AddReference(cls,abName,assetName)
		end
        -- if abName:find("weapon_") then
        --     info.gameObject:SetActive(true);
        -- end
        
		info.gameObject:SetActive(true)

		if (abName:find("model_") or abName:find("effect_")) and not abName:find("effect_machiaction_") and SetCacheState(info.gameObject,false) then
			
		end
		-- DebugLog('--LaoY PoolManager.lua,line 161--',cls.__cname,abName,assetName,tostring(info.gameObject))

        return info.gameObject
	end
	return nil
end

function PoolManager:DestroyGameObject(abName,assetName,gameObject,index)
	lua_resMgr:RemoveReference(self,abName,assetName)

	local key = abName.. "@" ..assetName
    local list = self.gameobject_list[key]

	destroy(gameObject)
end

function PoolManager:RemovePool(abName,assetName,is_del)
	is_del = is_del == nil and true or is_del
	scene_id = SceneManager:GetInstance():GetSceneId()
	abName = GetRealAssetPath(abName)
    local key = abName.. "@" ..assetName
    local list = self.gameobject_list[key]
    local del_tab
    if list then
		local len = #list
		for i=1,len do
			local info = list[i]
			if (info.scene_id ~= scene_id) and is_del then
				self:DestroyGameObject(info.abName,info.assetName,info.gameObject)
				del_tab = del_tab or {}
				del_tab[#del_tab+1] = i
			end
		end
	end
	if not table.isempty(del_tab) then
		table.RemoveByIndexList(list,del_tab)
	end
	-- self.gameobject_list[key] = nil
	cache_config[key] = nil
end

function PoolManager:ChangeScene()
	local scene_id = SceneManager:GetInstance():GetSceneId()
	local preLoadingId = LoadingCtrl:GetInstance().preLoadingId
	for key,list in pairs(self.gameobject_list) do
		if IsChangeSceneDelete(key) then
			local del_tab = {}
			local len = #list
			for i=1,len do
				local info = list[i]
				if info.scene_id ~= scene_id and info.scene_id ~= preLoadingId then
					self:DestroyGameObject(info.abName,info.assetName,info.gameObject,info.index)
					del_tab[#del_tab+1] = i
				end
			end
			table.RemoveByIndexList(list,del_tab)
		end
	end
end

function PoolManager:Update()
	for key,list in pairs(self.gameobject_list) do
		local cf = cache_config[key]
		-- if cf and not cf.is_del_change_scene and cf.cache_time and cf.cache_time > 0 then
		if cf and cf.cache_time and cf.cache_time > 0 then
			local del_tab = {}
			local len = #list
			for i=1,len do
				local info = list[i]
				if Time.time - info.time > cf.cache_time then
					self:DestroyGameObject(info.abName,info.assetName,info.gameObject)
					del_tab[#del_tab+1] = i
				end
			end
			table.RemoveByIndexList(list,del_tab)
		end
	end
end