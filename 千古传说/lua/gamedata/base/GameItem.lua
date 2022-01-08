--[[
******游戏数据物品基类*******

	-- by Stephen.tao
	-- 2013/11/27
]]

local GameObject = require('lua.gamedata.base.GameObject')
local GameItem = class("GameItem",GameObject)

function GameItem:ctor( Data )
	self.super.ctor(self)

	self:init(Data)
end

function GameItem:init( Data )

	self.type		= EnumGameObjectType.Item			--类型		//道具
	self.num 			= 0 							--数量
	self.kind 		= 0 							--道具类型
	local itemdata = ItemData:objectByID(Data)
	if itemdata == nil then
		print("itemdata == nil")
		return
	end
	self.id 	= itemdata.id
	self.name 	= itemdata.name
	self.type 			= itemdata:getType()
	self.kind			= itemdata:getKind()					--道具类型
	self.quality		= itemdata.quality						--品质
	self.textrueName	= itemdata:GetPath()					--图片名
	self.describe1		= itemdata.outline						--描述
	self.describe2		= itemdata.details						--详细描述
	self.price			= itemdata.price						--身价
	self.level 			= itemdata.level 						--等级
	--wkdai add
	self.itemdata 		= itemdata 								--物品静态数据
	self.gmId 			= self.id 							--实例id
end

function GameItem:dispose()
	self.super.dispose(self)
	self.gmId 			= nil
	self.num 			= nil					--数量
	self.kind 			= nil
	self.level 			= nil
	TFDirector:unRequire('lua.gamedata.base.GameObject')
end

function GameItem:GetTextrue()
	return self.textrueName
end

function GameItem:GetPath()
	return self.textrueName
end

function GameItem:getNum()
	return self.num
end

function GameItem:getQuality()
	return self.quality
end

function GameItem:getOutline()
	return self.describe1
end

function GameItem:getDetails()
	return self.describe2
end

function GameItem:getPrice()
	return self.price
end

--获取物品的静态数据对象
function GameItem:getData()
	return self.itemdata
end


return GameItem