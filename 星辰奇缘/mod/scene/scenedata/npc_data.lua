-- Npc数据

NpcData = NpcData or BaseClass()

function NpcData:__init()
	self.unittype = SceneConstData.unittype_npc -- 单位类型

	self.uniqueid = 0
	self.baseid = 0
	self.id = 0
	self.battleid = 0

	self.is_virtual = false

	self.x = 0
	self.y = 0
	self.gx = 0
	self.gy = 0

	self.speed = 0 -- 移动速度

	self.dir = nil -- 朝向
	self.action = nil -- 动作

	self.name = "" -- 单位名称
	self.dir = nil -- 单位朝向

	self.status = 0 -- 单位状态

	self.guideLev = 0 -- 指引级别

	self.sex = nil -- 性别
	self.classes = nil -- 职业

	-- 外观效果
	-- {uint32, looks_type, "外观类型,"}
	-- ,{uint32, looks_mode, "子外观类型,"}
	-- ,{uint32, looks_val, "外观值,"}
	-- ,{string, looks_str, "附加串,"}
	self.looks = {}

	-- 其它属性
	-- {uint32, prop_key, "属性键名"}
	-- ,{string, prop_val, "属性值"}
	self.prop = {}

	self.is_virtual = false
	self.exclude_outofview = false
	self.canIdle = nil
	self.no_hide = false
	self.honorType = 0
	self.no_facetopoint = false
	self.no_click = false
end

function NpcData:update_data(data)
	self.uniqueid = BaseUtils.get_unique_npcid(data.id, data.battle_id)
	if data.type ~= nil then self.unittype = data.type end
	if data.base_id ~= nil then self.baseid = data.base_id end
	if data.id ~= nil then self.id = data.id end
	if data.battle_id ~= nil then self.battleid = data.battle_id end

	self:update_base()

	if data.is_virtual ~= nil then self.is_virtual = data.is_virtual end
	if data.exclude_outofview ~= nil then self.exclude_outofview = data.exclude_outofview end
	if data.canIdle ~= nil then self.canIdle = data.canIdle end
	if data.no_hide ~= nil then self.no_hide = data.no_hide end
	if data.honorType ~= nil then self.honorType = data.honorType end

	if data.x ~= nil then self.x = data.x end
	if data.y ~= nil then self.y = data.y end

	if data.gx ~= nil then self.gx = data.gx end
	if data.gy ~= nil then self.gy = data.gy end

	if data.name ~= nil then self.name = data.name end
	if data.speed ~= nil then self.speed = data.speed end
	if data.dir ~= nil then self.dir = data.dir end

	if data.status ~= nil then self.status = data.status end
	if data.action ~= nil then self.action = data.action end
	if data.hidden ~= nil then self.hidden = data.hidden end

	if data.guide_lev ~= nil then self.guideLev  = data.guide_lev end

	if data.sex ~= nil then self.sex  = data.sex end
	if data.classes ~= nil then self.classes  = data.classes end

	if data.looks ~= nil and #data.looks > 0 then
		self.looks = {}
		for k, v in pairs(data.looks) do
		    table.insert(self.looks, {  looks_type = v.looks_type
		                                ,looks_mode = v.looks_mode
		                                ,looks_val = v.looks_val
		                                ,looks_str = v.looks_str})
		end
    end

    if data.prop ~= nil and #data.prop > 0 then
	    self.prop = {}
        for k, v in pairs(data.prop) do
            table.insert(self.prop, { prop_key = v.prop_key, prop_val = v.prop_val })
        end
    end

    if data.no_facetopoint ~= nil then self.no_facetopoint =  data.no_facetopoint end
    if data.no_click ~= nil then self.no_click =  data.no_click end
end

function NpcData:update_base()
	if SceneConstData.UnitNoFaceToPoint[self.baseid] then
		self.no_facetopoint = true
	end
	if SceneConstData.UnitNoShadow[self.baseid] then
		self.noShadow = true
	end

	if SceneConstData.UnitExcludeOutofview[self.baseid] then
		self.exclude_outofview = true
	end
end