-- --------------------------------------------------------------------
-- 图标数据内存缓存数据,数据事件,更新自身
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

FunctionIconVo = FunctionIconVo or BaseClass(EventDispatcher)

FunctionIconVo.UPDATE_SELF_EVENT = "FunctionIconVo.UPDATE_SELF_EVENT"

FunctionIconVo.type = {
    right_top_1 = 1, -- 右上横向
    right_top_2 = 2, -- 右上纵向 (现在改成左上纵向)
    right_bottom_1 = 3, -- 右下横向
    right_bottom_2 = 4, -- 右下纵向
    left_top = 5, -- 左上纵向(现在改成右上纵向)
}

function FunctionIconVo:__init(conf, is_lock)
	self.config 			= conf or {}
	self.pos				= self.config.type or 1
	self.sort 				= self.config and self.config.index or 1
	self.is_new 			= false
	self.is_lock			= is_lock
	self.tips_status		= false
	self.res_id 			= self.config.icon_res
	self.unclick			= false

	self.status 			= 0
	self.end_time			= 0

	self.action_id 			= 0

	self.dynamicres_id		= 0

	self.real_name 			= ""	-- 动态调整的名字
	self.real_res_id 		= ""	-- 动态调整的资源

	self.tips_status_list   = {}
end

function FunctionIconVo:setConfig(conf)
	self.config = conf
end

function FunctionIconVo:setLock(status)
	self.is_lock = status
end

--==============================--
--desc:刚进入主场景的时候锁定点击状态,避免引导出问题
--time:2017-08-14 04:29:43
--@status:
--@return 
--==============================--
function FunctionIconVo:setUnclick(status)
	self.unclick = status
end

function FunctionIconVo:update(params)
	if params == nil or next(params) == nil then return end
	if #params == 1 then		-- 活动图标参数
		local arg = params[1]
		if type(arg) == "table" then				-- 这类的基本上是服务端数据,包含了当前状态时间等
			self.id = arg.id
			self.status = arg.status				-- 活动状态 0结束，1开始， 2准备
			self.int_args = arg.int_args			-- 整型数组: 默认第一个参数为持续时间(单位秒),第二个是图标资源

			if self.int_args and next(self.int_args) ~= nil then
				self.end_time = self.int_args[1].val or 0
			end

			local ext_args = arg.ext_args
			if ext_args and next(ext_args) then
				for k,v in pairs(ext_args) do
					if v.type == 1 then
						self.dynamicres_id = v.val
						self.real_name = v.str
						if v.val ~= 0 then
							self:changeDynamicResId()
						end
						break
					end
				end
			end
		elseif type(arg) == "number" then			-- 这里主要是状态类的
			self.status = arg
		elseif type(arg) == "string" then			-- 这里主要是动态图标名称  Config.FunctionData.data_convert_icon,是这个key
			local config = Config.FunctionData.data_convert_icon[arg]
			if config then
				if arg == "xiariji" then
					local local_tag = 0
					if PLATFORM_NAME == "symix" or PLATFORM_NAME == "symix2" then
						local_tag = 1
					end
					if config[local_tag] then
						self.real_name = config[local_tag].icon_name
						self.real_res_id = config[local_tag].icon_res
					end
				else
					if config[0] then
						self.real_name = config[0].icon_name
						self.real_res_id = config[0].icon_res
					end
				end
			end
		end
	elseif #params >= 2 then
		self.status = params[1] or 0
		self.end_time = params[2] or 0
	end

	self:Fire(FunctionIconVo.UPDATE_SELF_EVENT)
end

--==============================--
--desc:设置图标红点状态, 如果是table则必须包含 bid 这个作为唯一标志去储存的
--time:2017-07-29 03:22:58
--@data:
--@return 
--==============================--
function FunctionIconVo:setTipsStatus(data)
	if type(data) == "table" then
		if data.bid ~= nil then
			self.tips_status_list[data.bid] = data
		else
			for k,v in pairs(data) do
				if v.bid ~= nil then
					self.tips_status_list[v.bid] = v
				end
			end
		end
	else
		if data ~= nil then
			self.tips_status = data
		else
			self.tips_status = not self.tips_status
		end
	end
	self:Fire(FunctionIconVo.UPDATE_SELF_EVENT, "tips_status")
end

--==============================--
--desc:获取图标红点状态
--time:2017-08-31 03:11:42
--@return 
--==============================--
function FunctionIconVo:getTipsStatus()
	for k,v in pairs(self.tips_status_list) do
		if  v.num ~= nil and type(v.num) == "number" and v.num > 0 then
			return true
		end
	end
	return self.tips_status
end

--==============================--
--desc:获取当前红点的总数量
--time:2017-08-31 03:11:42
--@return
--==============================--
function FunctionIconVo:getTipsNum()
	local num = 0
	if self.tips_status_list and next(self.tips_status_list) then
		for k,v in pairs(self.tips_status_list) do
			num = num + (v.num or 0)
		end
	end
	return num
end

function FunctionIconVo:changeDynamicResId()
	if self.dynamicres_id == 0 then return end
	local res_id = "icon_"..self.dynamicres_id
	self:changeIcon(res_id)
end

function FunctionIconVo:getBattleIconRes()
	return self.dynamicres_id or 1
end

function FunctionIconVo:changeIcon(id)
	self.res_id = id
	self:Fire(FunctionIconVo.UPDATE_SELF_EVENT, "res_id")
end

function FunctionIconVo:changeTime(time)
	self.end_time = time
	self:Fire(FunctionIconVo.UPDATE_SELF_EVENT, "end_time")
end

--==============================--
--desc:获取配置表的id
--time:2017-07-24 03:03:55
--@return 
--==============================--
function FunctionIconVo:getID()
	if self.config ~= nil then
		return self.config.id
	end
	return 0
end