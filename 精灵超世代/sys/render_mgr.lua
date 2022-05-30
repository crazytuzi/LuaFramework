--[[
   场景渲染管理
   添加的元素必需实现update
   @author zwx 
   @date 2015.11.20
--]]
RenderMgr = RenderMgr or BaseClass()
RenderMgr.RENDER_MANAGER_TIMER = "RenderMgr.RENDER_MANAGER_TIMER"
RenderMgr.REPORT_SYS_TIME = "RenderMgr.REPORT_SYS_TIME"
function RenderMgr:__init( )
	if RenderMgr.Instance ~= nil then 
		error("[RenderMgr] is singleton")
		return
	end
	RenderMgr.Instance = self
	self.count = 0
	self.dic = {}
	self.funDic = {}
	self.next_do_list={}
	self.isStop = true
	self.cd_check = 0 -- 指定时间检查一次本地时间或一些事情
	-- self.timeTicket = GlobalTimeTicket:getInstance()
	self.game_net = GameNet:getInstance()
	self.dispatcher = GlobalEvent:getInstance()
	self.sharedScheduler = cc.Director:getInstance():getScheduler()
end

function RenderMgr:getInstance()
	if RenderMgr.Instance == nil then
		RenderMgr.New()
	end
	return RenderMgr.Instance
end

-- 启动
function RenderMgr:start()
	if self.isStop == false then return end
	self.isStop = false
	-- self.timeTicket:add(function() self:update() end, 1/60, 0, RenderMgr.RENDER_MANAGER_TIMER)
	if self.schedule_ == nil then
		self.schedule_ = self.sharedScheduler:scheduleScriptFunc(function(dt) 
			self:update(dt) 
		end, 0, false)
	end
end

-- 停止
function RenderMgr:stop()
	if self.isStop == true then return end
	self.isStop = true
	-- self.timeTicket:remove(RenderMgr.RENDER_MANAGER_TIMER)
	if self.schedule_ then
		self.sharedScheduler:unscheduleScriptEntry(self.schedule_)
	end
	self.schedule_ = nil
end

--[[注册帧频渲染回调函数
	fun 请使用【变量函数】，避免冲突
	id 名字字符串，必需填写 [规则：模块名+fun名，免得冲突]
]]
function RenderMgr:frameAddCall(fun, id)
	if fun and id and self.funDic[id] == nil then
		self.funDic[id] = fun
	end
end

--[[删除注册回调方法
	id 
]]
function RenderMgr:frameRemoveCall( id )
	if id and self.funDic[id] then
		self.funDic[id] = nil
	end
end

-- 获得非update下的渲染
function RenderMgr:getRenderCallById( id )
	return self.funDic[id]
end

--[[
	注册到更新驱动管理中的对象
	renderObj 必需要有 update 方法【可以继承自 IRender】
]]
function RenderMgr:add( renderObj )
	if renderObj["update"] == nil then
		print("[RenderMgr]>>worning: "..tostring(renderObj).."not update function, I can't render it!!!!!")
		return 
	end
	self.count = self.count + 1
	self.dic[renderObj] = renderObj
end

--移除更新驱动对象
function RenderMgr:remove( renderObj )
	if self.dic[renderObj] ~= nil then
		self.count = self.count - 1
		self.dic[renderObj] = nil
	end
end

-- 更新由帧频更新
function RenderMgr:update(dt)
	for _, v in pairs(self.dic) do
		if v ~= nil then
			v:update(dt)
		end
	end
	for _,v in pairs(self.funDic) do
		if v ~= nil then
			v(dt)
		end
	end
	if #self.next_do_list > 0 then
		local handle = table.remove(self.next_do_list, 1)
		handle[1](handle[2])
	end
end

-- 广播当前系统时间（报时）
function RenderMgr:reportClock()

end

-- 下一帧要处理的函数器
function RenderMgr:doNextFrame( fun, param )
	table.insert(self.next_do_list, {fun, param})
end

-- 销毁
function RenderMgr:clear()
	self:stop()
	self.cd_check = 0
	self.count = 0
	self.dic = {}
	self.funDic = {}
	self.next_do_list={}
end