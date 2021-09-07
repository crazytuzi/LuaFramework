-- --------------------------------------------------------------
-- 图标图集过多导致预加载内存浪费，现在把图标图集取消,采用单独加载
-- 这里需要一个道具图标缓存
-- 规则：
-- 1.缓存assetbundle
-- 2.每个assetbundle固定缓存周期
-- 3.定时检查该assetbundle，不存在引用,而且过了缓存周期的话就卸载掉
-- hosr
-- 20170325
-- --------------------------------------------------------------
ItemIconPool = ItemIconPool or BaseClass()

function ItemIconPool:__init()
	if ItemIconPool.Instance then
		return
	end
	ItemIconPool.Instance = self

	-- 缓存字典
	self.cacheTab = {}
	-- 加载列表
	self.loadList = {}
	-- 没帧加载数量
	self.limit = 20
	self.assetWrapperTab = {}
end

function ItemIconPool:OnTick()
	if #self.loadList > 0 then
		self:LoadRes()
	end
end

-- -------------------------------------
-- 给Image组件赋值sprite
-- 传入Image组件，和图标id
-- -------------------------------------
function ItemIconPool:SetImage(image, icon)
	if icon == 0 or image == nil or image:Equals(Null) then
		return
	end
	local path = BaseUtils.GetItemSpritePath(icon)
	table.insert(self.loadList, {image = image, path = path, icon = icon})
end

function ItemIconPool:LoadRes()
	local list = {}
	local needLoad = false
	for i = 1, self.limit do
		local info = table.remove(self.loadList, i)
		if info ~= nil then
			needLoad = true
			table.insert(list, {file = info.path, type = AssetType.Dep, info = info})
		end
	end

	if not needLoad then
		return
	end

	local assetWrapper = AssetBatchWrapper.New()
	local key = tostring(assetWrapper)
	self.assetWrapperTab[key] = assetWrapper
    assetWrapper:LoadAssetBundle(list, function() self:ImageLoadComplete(key, list) end)
end

function ItemIconPool:ImageLoadComplete(key, list)
	local assetWrapper = self.assetWrapperTab[key]
	for i,v in ipairs(list) do
		if v.info.image == nil or v.info.image:Equals(Null) then
		else
			v.info.image.sprite = assetWrapper:GetSprite(v.info.path, v.info.icon)
			v.info.image.gameObject:SetActive(true)
		end
	end
	assetWrapper:DeleteMe()
	assetWrapper = nil
	list = nil
	self.assetWrapperTab[key] = nil
end