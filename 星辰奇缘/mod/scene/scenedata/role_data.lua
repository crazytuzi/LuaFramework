-- 玩家数据

RoleData = RoleData or BaseClass()

function RoleData:__init()
	self.unittype = SceneConstData.unittype_role -- 单位类型

	self.uniqueid = 0
	self.roleid = 0
	self.zoneid = 0
	self.platform = ""

	self.is_virtual = false

	self.x = 0
	self.y = 0
	self.gx = 0
	self.gy = 0

	self.speed = 0 -- 移动速度

	self.dir = nil -- 朝向

	self.name = "" -- 角色名称
	self.dir = 0 -- 角色朝向

	self.status = 0 -- 角色状态
	self.action = 0 -- 动作状态
	self.ride = 0 -- 骑乘状态
	self.event = 0 -- 活动状态
	self.hidden = 0 -- 是否隐身

	self.label = 0 -- 特殊标识
	self.lev = 0 -- 角色等级
	self.sex = 0 -- 性别
	self.classes = 0 -- 职业
	self.realm = 0 -- 阵营
	self.face = 0 -- 头像Id
	self.fc = 0 -- 战力

	self.team_status = 0 -- 1队长，0不是
	self.team_mark = 0 -- 队标id
	self.team_num = 0 -- 队伍人数

	-- 外观效果
	-- {uint32, looks_type, "外观类型,"}
	-- ,{uint32, looks_mode, "子外观类型,"}
	-- ,{uint32, looks_val, "外观值,"}
	-- ,{string, looks_str, "附加串,"}
	self.looks = {}

	self.guild = "" -- 公会名称
	self.guild_signature = "" -- 公会签名
	self.guild_id = 0 -- 公会ID
	self.guild_platform = "" -- 公会平台
	self.guild_zone = 0 -- 公会区号

	self.is_virtual = false
	self.exclude_outofview = false
	self.canIdle = true
	self.no_hide = false

	self.foot_mark = 0
end

function RoleData:update_data(data)
	self.uniqueid = BaseUtils.get_unique_roleid(data.rid, data.zone_id, data.platform)
	if data.type ~= nil then self.unittype = data.type self.type = data.type end
    if data.rid ~= nil then self.roleid = data.rid self.rid = data.rid  end
	if data.zone_id ~= nil then self.zoneid = data.zone_id self.zone_id = data.zone_id end
	if data.platform ~= nil then self.platform = data.platform end

	if data.is_virtual ~= nil then self.is_virtual = data.is_virtual end
	if data.exclude_outofview ~= nil then self.exclude_outofview = data.exclude_outofview end
	if data.canIdle ~= nil then self.canIdle = data.canIdle end
	if data.no_hide ~= nil then self.no_hide = data.no_hide end

	if data.x ~= nil then self.x = data.x end
	if data.y ~= nil then self.y = data.y end

	if data.gx ~= nil then self.gx = data.gx end
	if data.gy ~= nil then self.gy = data.gy end

	if data.name ~= nil then self.name = data.name end
	if data.speed ~= nil then self.speed = data.speed end
	if data.dir ~= nil then self.dir = data.dir end

	if data.status ~= nil then self.status = data.status end
	if data.action ~= nil then self.action = data.action end
	if data.ride ~= nil then self.ride = data.ride end
	if data.event ~= nil then self.event  = data.event end
	if data.hidden ~= nil then self.hidden = data.hidden end

	if data.label ~= nil then self.label  = data.label end
	if data.lev ~= nil then self.lev = data.lev end
	if data.sex ~= nil then self.sex = data.sex end
	if data.classes ~= nil and data.classes ~= 0 then self.classes = data.classes end
	if data.realm ~= nil then self.realm  = data.realm end
	if data.face ~= nil then self.face = data.face end
	if data.fc ~= nil then self.fc = data.fc end
	if data.team_status ~= nil then self.team_status = data.team_status end
	if data.team_mark ~= nil then self.team_mark = data.team_mark end
	if data.team_num ~= nil then self.team_num = data.team_num end

	if data.looks ~= nil and #data.looks > 0 then
		self.looks = {}
		for k, v in pairs(data.looks) do
		    table.insert(self.looks, {  looks_type = v.looks_type
		                                ,looks_mode = v.looks_mode
		                                ,looks_val = v.looks_val
		                                ,looks_str = v.looks_str})
		end
	end

	if data.guild ~= nil then self.guild = data.guild end
	if data.guild_signature ~= nil then self.guild_signature = data.guild_signature end
	if data.guild_id ~= nil then self.guild_id = data.guild_id end
	if data.guild_platform ~= nil then self.guild_platform = data.guild_platform end
	if data.guild_zone ~= nil then self.guild_zone = data.guild_zone end

	if data.lover_rid ~= nil then self.lover_rid = data.lover_rid end
	if data.lover_platform ~= nil then self.lover_platform = data.lover_platform end
	if data.lover_zone_id ~= nil then self.lover_zone_id = data.lover_zone_id end
	if data.lover_name ~= nil then self.lover_name = data.lover_name end
	if data.lover_status ~= nil then self.lover_status = data.lover_status end
	if data.concentric ~= nil then self.concentric = data.concentric end
	if data.qixiIntegral ~= nil then self.qixiIntegral = data.qixiIntegral end

	--双人坐骑
	if data.driver_id ~= nil then self.driver_id = data.driver_id end
	if data.driver_platform ~= nil then self.driver_platform = data.driver_platform end
	if data.driver_zone_id ~= nil then self.driver_zone_id = data.driver_zone_id end
	if data.isPassenger ~= nil then self.isPassenger = data.isPassenger end
	if data.isDriver ~= nil then self.isDriver = data.isDriver end
	if data.isNeedChangeAboutPassenger ~= nil then    
		  self.isNeedChangeAboutPassenger = data.isNeedChangeAboutPassenger end
	if data.passengersData ~= nil then
		  self.passengersData = BaseUtils.copytab(data.passengersData)
	end
	if data.passengers ~= nil and #data.looks > 0 then
		  self.passengers = BaseUtils.copytab(data.passengers)
	end

	if data.foot_mark ~= nil then self.foot_mark = data.foot_mark end
	
end