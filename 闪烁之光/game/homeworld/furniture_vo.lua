--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-06-24 10:31:20
-- @description    : 
		-- 家具数据
---------------------------------

FurnitureVo = FurnitureVo or BaseClass(EventDispatcher)

function FurnitureVo:__init(  )
	self.id = 0 -- 唯一id（客户端用，bid*100+index）
	self.bid = 0     -- 家具配置id
	self.index = 0   -- 位置索引
	self.dir = HomeworldConst.Dir_Type.Left  -- 方向
	self.config = {}
end

function FurnitureVo:updateData( data )
	for key, value in pairs(data) do
        self[key] = value
        if key == "bid" then
        	self.config = Config.HomeData.data_home_unit(value) or {}
        end
    end 
    self.id = self.bid*1000 + self.index
    self:dispatchUpdateAttrByKey()
end

-- 更新位置索引
function FurnitureVo:updateIndex( index )
	self.index = index
	self.id = self.bid*1000 + self.index
end

function FurnitureVo:dispatchUpdateAttrByKey(  )
	
end

function FurnitureVo:__delete(  )
	
end