-- 家具数据

HomeData = HomeData or BaseClass()

function HomeData:__init()
	self.uniqueid = 0

	self.id = 0
	self.battle_id = 0

	self.base_id = 0

	self.x = 0
	self.y = 0
	self.gx = 0
	self.gy = 0

	self.dir = nil -- 朝向

	self.name = "" -- 名称

	self.status = 0 -- 状态

	self.isEdit = false -- 编辑状态
end

function HomeData:update_data(data)
	self.uniqueid = BaseUtils.get_unique_npcid(data.id, data.battle_id)
	if data.id ~= nil then self.id = data.id end
	if data.battle_id ~= nil then self.battle_id = data.battle_id end
	if data.base_id ~= nil then self.base_id = data.base_id end
	if data.x ~= nil then self.x = data.x end
	if data.y ~= nil then self.y = data.y end
	if data.gx ~= nil then self.gx = data.gx end
	if data.gy ~= nil then self.gy = data.gy end
	if data.dir ~= nil then self.dir = data.dir end
	if data.name ~= nil then self.name = data.name end
	if data.status ~= nil then self.status = data.status end
	if data.isEdit ~= nil then self.isEdit = data.isEdit end
end