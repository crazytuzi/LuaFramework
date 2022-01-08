--[[
******游戏数据基类*******

	-- by Stephen.tao
	-- 2013/11/25
]]

local GameObject = class('GameObject')

function GameObject:ctor()
	self.name		= 0	--名称
	self.id			= 0	--ID
	self.type 		= 0	--类型


	self.quality		= 0 							--品质
	self.textrueName	= 0								--图片名
	self.describe1		= 0								--描述
	self.describe2		= 0								--描述
	self.price			= 0								--身价
end


function GameObject:GetName()
	return self.name
end

function GameObject:GetId()
	return self.id
end

function GameObject:GetType()
	return self.type
end


function GameObject:dispose()
	self.name		=  nil	--名称
	self.id			=  nil	--ID
	self.type 		=  nil	--类型(EnumGameObjectType)

	self.quality		= nil					--品质
	self.textrueName	= nil					--图片名
	self.describe1		= nil					--描述
	self.describe2		= nil					--描述
	self.price			= nil					--身价
end


function GameObject:GetTextrue()
	return self.textrueName
end

function GameObject:GetQuality()
	return self.quality
end

function GameObject:GetDescribe()
	return self.describe1
end

function GameObject:GetPrice()
	return self.price
end

return GameObject