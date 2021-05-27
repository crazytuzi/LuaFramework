require("scripts/game/sharedata/game_vo")
require("scripts/game/sharedata/user_vo")

-- 说明: 场景相关的Vo对象的管理器,可以通过Instance来获取它
GameVoManager = GameVoManager or BaseClass()

function GameVoManager:__init()
	if GameVoManager.Instance ~= nil then
		ErrorLog("[GameVoManager] attempt to create singleton twice!")
		return
	end
	GameVoManager.Instance = self

	self.vo_pool_list = {}

	-- 用户帐户信息
	self.user_vo = UserVo.New()

	-- 主角
	self.main_role_vo = MainRoleVo.New()
end

function GameVoManager:__delete()
	GameVoManager.Instance = nil

	self.user_vo:DeleteMe()
	self.user_vo = nil

	self.main_role_vo:DeleteMe()
	self.main_role_vo = nil

	for _, pool in pairs(self.vo_pool_list) do
		for _, v in pairs(pool) do
			v:DeleteMe()
		end
	end
	self.vo_pool_list = {}
end

function GameVoManager:GetUserVo()
	return self.user_vo
end

function GameVoManager:GetMainRoleVo()
	return self.main_role_vo
end

function GameVoManager:GetVoPoolList()
	return self.vo_pool_list
end

function GameVoManager:CreateVo(ClassType)
	local vo = nil

	local pool = self.vo_pool_list[ClassType]
	if nil ~= pool then
		vo = table.remove(pool)
		if nil ~= vo then
			-- 重新初始化
			local init_func = nil
			init_func = function(c)
				if c.super then
					init_func(c.super)
				end
				if c.__init then
					c.__init(vo)
				end
			end

			init_func(vo._class_type)
		end
	end

	return vo or ClassType.New()
end

function GameVoManager:DeleteVo(vo)
	local pool = self.vo_pool_list[vo._class_type]
	if nil == pool then
		pool = {}
		self.vo_pool_list[vo._class_type] = pool
	end

	if #pool < 10 then
		table.insert(pool, vo)
	end
end
