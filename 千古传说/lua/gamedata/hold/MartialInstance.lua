--[[
	武学实例，装备到角色身上之后的武学
	-- @author david.dai
	-- @date 2015/4/20
]]
local MartialInstance = class("MartialInstance")

function MartialInstance:ctor( template )
	self:init(data)
end

function MartialInstance:init( template )
	self.roleId = nil					--装备在谁身上
	self.position = nil					--装备在哪个位置
	self.enchantLevel = 0				--附魔等级
	self.enchantProgress = 0			--附魔进度
	self:setTemplate(template)
end

function MartialInstance:setTemplate(template)
	self.template = template			--数据模版，对应t_s_martial中配置的数据。这里定义是为了加快访问速度
	if not template then
		return
	end
	--self.goodsTemplate = ItemData:objectByID(template.id)	--物品信息，对应t_s_goods表格配置的数据。这里定义是为了加快访问速度
	self.goodsTemplate = template.goodsTemplate
end

function MartialInstance:dispose()
	self.roleId = nil
	self.position = nil
	self.enchantLevel = nil
	self.enchantProgress = nil
	self.template = nil
	self.goodsTemplate = nil
end

--[[
获取最大可以附魔到多少等级
]]
function MartialInstance:getMaxEnchantLevel()
	local enchantTable = MartialEnchant:findByLevel(goodsTemplate.level)
	if not enchantTable then
		return 0
	end
	return enchantTable.maxLevel
end

--[[
获取附魔等级提升所需要的经验
@return -1:不可升级，达到最高等级或者本身就不可以升级;其他情况为升级经验还剩下多少经验
]]
function MartialInstance:getRemainEnchantExp()
	local enchantTable = MartialEnchant:findByLevel(goodsTemplate.level)
	if not enchantTable then
		return -1
	end

	if self.enchantLevel >= enchantTable.maxLevel then
		return -1
	end

	local currentLevelTotalExp = enchantTable[self.enchantLevel + 1] 	--获取升级到下一个等级所需要的经验
	if not currentLevelTotalExp then
		return -1
	end

	local remain = currentLevelTotalExp - enchantProgress
	if remain < 0 then
		return 0
	end
	return remain
end

--[[
获取升级到最高等级所需要的经验
@return -1:不可升级，达到最高等级或者本身就不可以升级;其他情况为升级经验还剩下多少经验
]]
function MartialInstance:getRemainEnchantExpToMax()
	local enchantTable = MartialEnchant:findByLevel(goodsTemplate.level)
	if not enchantTable then
		return -1
	end

	if self.enchantLevel >= enchantTable.maxLevel then
		return -1
	end
	
	local currentLevelTotalExp = enchantTable[self.enchantLevel + 1] 	--获取升级到下一个等级所需要的经验
	if not currentLevelTotalExp then
		return -1
	end

	local total = currentLevelTotalExp - enchantProgress

	for i = enchantLevel + 2,enchantTable.maxLevel do
		local info = enchantTable[i]
		if not info then
			break
		end
		total = total + info.exp
	end

	if total < 0 then
		return 0
	end

	return total
end

--[[
获取升级到最高等级所需要的经验
@level 指定等级
@return -1:不可升级，达到最高等级或者本身就不可以升级;其他情况为升级经验还剩下多少经验
]]
function MartialInstance:getRemainEnchantExpToLevel(level)
	local enchantTable = MartialEnchant:findByLevel(goodsTemplate.level)
	if not enchantTable then
		return -1
	end

	if self.enchantLevel >= enchantTable.maxLevel then
		return -1
	end

	local total = currentLevelTotalExp - enchantProgress

	for i = enchantLevel + 2,level do
		local info = enchantTable[i]
		if not info then
			break
		end
		total = total + info.exp
	end

	if total < 0 then
		return 0
	end
	
	return total
end

return MartialInstance