-- --------------------------------------------------------------------
-- 场景地图贴图
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

MapTile = MapTile or BaseClass()

-- 精灵坐标 x, y
-- 精灵贴图 tex --> local 是否为绝对地址还是贴图id
function MapTile:__init( pos, tex, type, isLocal, asyncKey, parent, isTop)
	self.complete_ = false
	self.isDeleted = false
	self.isAdded__ = false
	self.tex = tex
	if pos == nil then
		pos = cc.p(0, 0)
	end
	self.type = type  or MapUtil.s
	self.pos__ = pos
	self.anchorPoint = cc.p(0.5, 0.5)
	self.parent = parent
	self.top = isTop
    self.tile_x = math.floor(pos.x/MapUtil.c_w)
	self.tile_y = math.floor(pos.y/MapUtil.c_h)
	isLocal = true
	self.sprite = cc.Sprite:create()
	self.sprite:setAnchorPoint(self.anchorPoint)

	self:loadResources(tex)
end

--[[
    @desc: 外部加载资源,因为可能在cdn上面
    author:{author}
    time:2018-08-12 24:07:59
    --@tex: 
    @return:
]]
function MapTile:loadResources(tex)
	self.resources_load = createResourcesLoad(tex,ResourcesType.single,function() 
		if self.sprite then
			loadSpriteTexture(self.sprite,tex,LOADTEXT_TYPE)
		end
		local size = self:getContentSize__()
		local pos = self.pos__
		self.x = pos.x + size.width/2
		if self.top then
			self.y = pos.y - size.height/2
		else
			self.y = pos.y + size.height/2
		end
		self.sprite:setPosition(cc.p(self.x, self.y))
		self.pos__ = cc.p(self.x, self.y)
		self.complete_ = true
	end,self.resources_load)
end

function MapTile:getSprite()
	return self.sprite
end

function MapTile:isComplete()
	return self.complete_
end

function MapTile:retain()
	if self.retain_ then return end
	if self.sprite then
		self.sprite:retain()
	end
	self.retain_ = true
end

function MapTile:setVisibleByPos(pos)
    if math.abs(self.tile_x - pos.x) < 3 and math.abs(self.tile_y - pos.y) < 3 then
        self.sprite:setVisible(true)
    else
        self.sprite:setVisible(false)
    end
end

function MapTile:setVisible(bool)
    self.sprite:setVisible(bool)
end

function MapTile:__delete()
	if self.resources_load then
		self.resources_load:DeleteMe()
		self.resources_load = nil
	end
	if self.sprite then
		if self.retain_ == true then
			doRelease(self.sprite)
		end
		if self.isAdded__ then
			self.sprite:removeFromParent()
		end
	end
	self.sprite = nil
	self.isDeleted = true
	self.isAdded__ = false
end

function MapTile:addChildOnParent()
	if self.complete_ and not self.isAdded__ and self.sprite then
		if self.parent and not tolua.isnull(self.parent) then
			self.parent:addChild(self.sprite, -1)
			self.isAdded__ = true
		end
	end
end

function MapTile:setPosition( pos )
	if self.complete_ then
		local size = self:getContentSize__()
		self.x = pos.x + size.width/2
		if self.top then
			self.y = pos.y - size.height/2
		else
			self.y = pos.y + size.height/2
		end
		self.sprite:setPosition(cc.p(self.x, self.y))
		self.pos__ = cc.p(self.x, self.y)
	end
end

function MapTile:getContentSize__()
	return self.sprite:getContentSize()
end

function MapTile:getPosition()
	return self.pos__
end

function MapTile:getType(  )
	return self.type
end

function MapTile:isAdded()
	return self.isAdded__
end
