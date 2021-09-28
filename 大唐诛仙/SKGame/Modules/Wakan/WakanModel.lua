
WakanModel =BaseClass(LuaModel)

function WakanModel:GetInstance()
	if WakanModel.inst == nil then
		WakanModel.inst = WakanModel.New()
	end
	return WakanModel.inst
end

function WakanModel:__init()
	self:Reset()
end

function WakanModel:Reset()
	--觉醒
	self.awakeLevel = 1
	self.awakeData = nil
	self:InitAwakeData()
	--注灵
	self.wakanPartsData = nil --注灵部位
	self:InitWakanData()

	self.mini = 0
end

--注灵数据初始化
function WakanModel:InitWakanData()
	self.wakanPartsData = {} -- 元素数据：{部位id, 注灵等级, 注灵值}
	self.wakanPartsData = {{GoodsVo.EquipPos.Head, 0, 0}, {GoodsVo.EquipPos.Upbody, 0, 0}, 
						  {GoodsVo.EquipPos.Downbody, 0, 0}, {GoodsVo.EquipPos.Neck, 0, 0},
						  {GoodsVo.EquipPos.Hand, 0, 0}, {GoodsVo.EquipPos.Finger, 0, 0}, 
						  {GoodsVo.EquipPos.Weapon01, 0, 0}, {GoodsVo.EquipPos.Weapon02, 0, 0}}
	self.awakeLevel = self:GetCurAwakeLevel()
end

--获取当前注灵位置的注灵值
function WakanModel:GetWakanValueByPart(part)
	for i = 1, #self.wakanPartsData do
		if self.wakanPartsData[i][1] == part then
			return self.wakanPartsData[i][3]
		end
	end
	return 0
end

--获取当前注灵位置的注灵值
function WakanModel:GetPartWakanInfo(part)
	for i = 1, #self.wakanPartsData do
		if self.wakanPartsData[i][1] == part then
			return self.wakanPartsData[i]
		end
	end
	return 0
end

--更新位置注灵信息
function WakanModel:UpdateWakanPartInfo(data)
	for i = 1, #self.wakanPartsData do
		if self.wakanPartsData[i][1] == data.posId then
			self.wakanPartsData[i][2] = data.wakanLevel
			self.wakanPartsData[i][3] = data.wakanValue
			self.awakeLevel = self:GetCurAwakeLevel()
			return
		end
	end
end

--获取注灵等级数据
function WakanModel:GetWakanDataByLevel(level)
	local dataSource = GetCfgData("attUp")
	for k, v in pairs(dataSource) do 
		if type(v) ~= "function" and v.level == level then
			return v
		end
	end
	return nil
end
-- 角色等级是否达到注灵等级条件
function WakanModel:IsRoleLevelEnough(wankanLev)
	wankanLev = math.max(0, wankanLev + 1)
	local enough = false
	local wakanData = self:GetWakanDataByLevel(wankanLev)
	local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
	if wakanData and mainPlayer.level >= wakanData.needLevel then
		enough = true
	end
	if not wakanData then
		return enough, nil, true
	end
	return enough, wakanData.needLevel
end

--根据注灵等级、加成部位获取属性加成列表
--@param level 等级
--@param part 部位
--@return {{属性名, 属性加成},{属性名, 属性加成}...}
function WakanModel:GetAttrsAddByLevel_Part(level, part)
	local result = nil
	local wakanData = self:GetWakanDataByLevel(level)
	if wakanData then
		local atrrs = nil	
		if part == GoodsVo.EquipPos.Head then --头
			atrrs = wakanData.attHead
		elseif part == GoodsVo.EquipPos.Neck then --项链
			atrrs = wakanData.attNecklace
		elseif part == GoodsVo.EquipPos.Upbody then --上衣
			atrrs = wakanData.attClothes
		elseif part == GoodsVo.EquipPos.Hand then --护腕
			atrrs = wakanData.attCuff
		elseif part == GoodsVo.EquipPos.Downbody then --裤子
			atrrs = wakanData.attTrousers
		elseif part == GoodsVo.EquipPos.Finger then --戒指
			atrrs = wakanData.attRing
		elseif part == GoodsVo.EquipPos.Weapon01 then --武器
			atrrs = wakanData.attArm1
		elseif part == GoodsVo.EquipPos.Weapon02 then --法宝
			atrrs = wakanData.attArm2
		end
		if atrrs then
			result = {}
			for i = 1, #atrrs do
				local attrName = self:GetAddAttrName(atrrs[i][1])
				local attrAddValue = atrrs[i][2]
				table.insert(result, {attrName, attrAddValue})
			end
		end
	end
	return result
end

--获取属性名
function WakanModel:GetAddAttrName(id)
	local attrVo = GetCfgData( "proDefine" ):Get(id)
	local attrName = ""
	if attrVo then
		attrName = attrVo.name
	end
	return attrName
end

--获取部位名
function WakanModel:GetPartName(partId)
	return GoodsVo.EquipTypeName[partId]
end

--觉醒数据
function WakanModel:InitAwakeData()
	self.awakeData = {}
	local dataSource = GetCfgData("attAwakening")
	for k, v in pairs(dataSource) do 
		if type(v) ~= "function" then
			table.insert(self.awakeData, v)
		end
	end
	SortTableByKey(self.awakeData, "id", true)
end

--获取觉醒等级数据
function WakanModel:GetAwakeDataByLevel(level)
	return GetCfgData( "attAwakening" ):Get(level)
end

--获取当前觉醒等级
function WakanModel:GetCurAwakeLevel()
	local minPartLevel = self.wakanPartsData[1][2]
	for i = 1, #self.wakanPartsData do
		if self.wakanPartsData[i][2] < minPartLevel then
			minPartLevel = self.wakanPartsData[i][2]
		end
	end

	if self.awakeData then
		for i = #self.awakeData, 1, -1 do
			if minPartLevel >= self.awakeData[i].needLevel then
				return self.awakeData[i].id
			end
		end
	end
	return 0
end

function WakanModel:GetWakanCrit(totalAdd, curProgess, maxProgess)
	local add = totalAdd/maxProgess * (1 + curProgess/maxProgess)
	return string.format("%.1f", math.min(100, add*100)) 
end

function WakanModel:HasCostItem()
	local count = 0
	for i = 1, #WakanConst.WakanCostItemIds do
		count = count + PkgModel:GetInstance():GetTotalByBid(WakanConst.WakanCostItemIds[i])
	end

	return count > 0
end

function WakanModel:GetWakenTotalLevel()
	local data = self.wakanPartsData
	if not data then return end
	local lv = 0
	self.mini = 1000
	for i,v in ipairs(data) do
		if v[2] < self.mini then
			self.mini = v[2]
		end
		lv = lv + v[2]
	end
	return lv
end

function WakanModel:__delete()
	WakanModel.inst = nil
end