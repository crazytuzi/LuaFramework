--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-20 14:14:01
-- @description    : 
		-- 系统 control
---------------------------------
local _table_remove = table.remove

SysController = SysController or BaseClass(BaseController)

function SysController:config()
    self.dispather = GlobalEvent:getInstance()
    self:initAttrProtocalsFunList()
end

function SysController:registerEvents(  )
    if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil

			self.role_vo = RoleController:getInstance():getRoleVo()
			if self.role_vo and self.role_assets_event == nil then
				self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
					if key == "lev" or key == "open_day" then -- 角色等级或开服天数变化
						self:requestAttrProtocals()
					elseif key == "guild_lev" then
						
					end
				end)
			end
        end)
	end

	--世界等级监听事件
	if self.world_lev_event == nil then
		self.world_lev_event = GlobalEvent:getInstance():Bind(RoleEvent.WORLD_LEV, function() 
			self:crossarenaProtocal()
		end)
	end

	-- 断线重连
    if self.re_link_game_event == nil then
		self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
        	if not RoleController:getInstance():checkRoleSetNameViewIsOpen() and not GuideController:getInstance():isInGuide() then -- 取名界面没打开，并且不在引导中，则跳到主城
        		MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene)
        	end
            self:resetAttrProtocals()
            self:requestReLinkProtocals()
        end)
    end
end

function SysController:registerProtocals(  )
    self:RegisterProtocal(10394, "rgp_hander10394")  --游客模式超时提示
end

-- 这里统一调用登陆时的协议请求
function SysController:requestLoginProtocals(  )
	self:registerEvents() -- 这里也走一遍协议注册，因为之前BaseController中调用时，role_vo 是 nil 
	local delay_fun_list = {
		function () self:SendProtocal(10500, {}) end, 	-- 背包
        function () self:SendProtocal(10501, {}) end,   -- 背包
        function () self:SendProtocal(10502, {}) end,   -- 背包
		function () self:SendProtocal(10503, {}) end, 	-- 宠物背包
		function () self:SendProtocal(11025, {}) end, 	-- 英雄数据
        function () self:adventrueProtocal() end,       -- 冒险
		function () self:SendProtocal(10906, {}) end,   -- 开服天数
		function () self:SendProtocal(10380, {}) end, 	-- 开服时间
		function () self:SendProtocal(10926, {}) end, 	-- 在线奖励
		function () self:SendProtocal(24600, {}) end, 	-- 问卷
		function () self:SendProtocal(16710, {}) end, 	-- VIP礼包红点
		function () self:SendProtocal(23200, {}) end, 	-- 召唤数据
		function () self:SendProtocal(25300, {}) end,	-- 战令活动
		function () self:SendProtocal(10325, {}) end, 	-- 头像信息
		function () self:SendProtocal(13006, {}) end, 	-- 剧情副本基础信息
		function () self:SendProtocal(13008, {}) end, 	-- 剧情副本通关奖励
		function () self:SendProtocal(13011, {}) end, 	-- 剧情副本Buff数据
		function () self:SendProtocal(13017, {}) end, 	-- 剧情副本挂机数据
		function () self:SendProtocal(10905, {}) end, 	-- 世界等级
		function () self:SendProtocal(20700, {}) end, 	-- 星河神殿挑战次数
		function () self:SendProtocal(10317, {}) end, 	-- 点赞数量
		function () self:SendProtocal(21100, {}) end, 	-- 七天登陆
		function () self:SendProtocal(13601, {}) end, 	-- 七日目标
		function () self:SendProtocal(21021, {}) end, 	-- 周礼包是否开启
		function () self:SendProtocal(16637, {}) end, 	-- 探宝
		function () self:SendProtocal(24700, {}) end, 	-- 基金
		function () self:SendProtocal(21000, {}) end, 	-- 首充
		function () self:SendProtocal(21030, {}) end, 	-- 首充-利维坦
		function () self:SendProtocal(21010, {}) end, 	-- 每日首充
		function () self:SendProtocal(25000, {}) end, 	-- 元素圣殿
		function () self:SendProtocal(23606, {}) end, 	-- 点金
		function () self:SendProtocal(24204, {}) end, 	-- 公会战状态
		function () self:SendProtocal(24220, {}) end, 	-- 公会战宝箱
		function () self:SendProtocal(22200, {}) end, 	-- 圣物
		function () self:SendProtocal(24125, {}) end, 	-- 神器幻化
		function () self:SendProtocal(24128, {}) end, 	-- 神器任务
		function () self:SendProtocal(11040, {}) end, 	-- 英雄图鉴
		function () self:SendProtocal(11037, {}) end, 	-- 符文祝福
		function () self:SendProtocal(11213, {type_list={{type = PartnerConst.Fun_Form.Drama}, {type = PartnerConst.Fun_Form.Arena}}}) end, 	-- 阵法

		--function () self:expeditProtocal() end, 	-- 远征
		function () self:SendProtocal(19807, {}) end, 	-- 邀请码（自己绑定的角色）
		function () self:SendProtocal(19804, {}) end, 	-- 邀请码红点
		function () self:SendProtocal(24312, {}) end, 	-- 天梯是否开启
		function () self:SendProtocal(10800, {}) end, 	-- 邮件
		function () self:SendProtocal(10950, {}) end, 	-- 公告
		function () self:SendProtocal(23214, {}) end, 	-- 英雄置换
		function () self:SendProtocal(13604, {}) end, 	-- 七日目标任务
		function () self:SendProtocal(13607, {}) end, 	-- 七日目标等级奖励
		function () self:SendProtocal(13030, {}) end, 	-- 材料副本
		function () self:SendProtocal(10400, {}) end, 	-- 任务列表
		function () self:SendProtocal(16400, {}) end, 	-- 成就列表
        function () self:SendProtocal(20300, {}) end,   -- 活跃度
		function () self:SendProtocal(25810, {}) end, 	-- 历练任务
		function () self:SendProtocal(19906, {}) end, 	-- 录像馆点赞
		function () self:SendProtocal(16707, {}) end, 	-- 月卡奖励
		function () self:SendProtocal(16712, {}) end, 	-- 累充红点
		function () self:SendProtocal(21006, {}) end, 	-- 每日礼包
		function () self:SendProtocal(24502, {}) end, 	-- 特权礼包
		function () self:SendProtocal(14100, {}) end, 	-- 签到红点
		function () self:SendProtocal(16705, {}) end, 	-- 月卡信息
		function () self:SendProtocal(21008, {}) end, 	-- 每日礼
		function () self:SendProtocal(16635, {}) end, 	-- 手机绑定奖励状态
		function () self:SendProtocal(16633, {}) end, 	-- 微信公众号状态
		function () self:SendProtocal(11320, {}) end,	-- 星命塔数据
		function () self:SendProtocal(20706, {}) end,	-- 星河神殿每天第一次登录红点
		function () self:SendProtocal(16687, {bid=ActionRankCommonType.open_server}) end,	-- 新服限购
		function () self:SendProtocal(16687, {bid=ActionRankCommonType.high_value_gift}) end, -- 小额礼包
        function () self:SendProtocal(16687, {bid=ActionRankCommonType.mysterious_store}) end, -- 神秘杂货店
		-- function () self:SendProtocal(16687, {bid=ActionRankCommonType.ouqi_gift}) end, -- 欧气大礼
		function () self:SendProtocal(25200, {}) end,	-- 天界副本
		function () self:SendProtocal(25219, {}) end,	-- 神装转盘
		function () self:SendProtocal(25303, {}) end,
		function () self:SendProtocal(24313, {}) end,	-- 天梯英雄殿红点
        function () self:SendProtocal(24314, {}) end,   -- 天梯战报红点
        function () self:SendProtocal(25830, {start = 0, num = 1}) end, -- 成长之路显示红点用途
        function () self:SendProtocal(25833, {}) end, -- 成长之路嘉年华信息
        function () self:homepetProtocal() end,   -- 宠物基本信息
        function () self:SendProtocal(25814, {}) end, -- 申请隐藏成就
		function () self:SendProtocal(11056, {}) end, -- 融合神殿红点问题

		function () self:crossarenaProtocal() end, 		-- 跨服竞技场
        function () self:guildRedBagProtocal() end,     -- 公会红包
        function () self:arenateamProtocal() end,   -- 组队竞技场
		function () self:arenaPeakProtocal() end, 	-- 巅峰冠军赛
		
		function () self:endlessProtocal() end, 		-- 无尽试炼
		function () self:voyageProtocal() end, 			-- 远航
		function () self:homeworldProtocal() end, 		-- 家园
		function () self:crosschampionProtocal() end, 	-- 跨服冠军赛
		function () self:elfinProtocal() end, 	        -- 精灵
		function () self:SendProtocal(27100, {}) end, -- 冒险奇遇
		function () self:monopolyProtocal() end, 		-- 圣夜奇境
		function () self:SendProtocal(27600, {}) end, -- 新手训练营完成情况
        function () self:SendProtocal(24952, {}) end, -- 段位赛战令信息
        function () self:SendProtocal(27102, {}) end, -- 奇遇数据

		function () self:planesProtocal() end, -- 位面
		function () self:SendProtocal(10930, {}) end, 	-- 开服时间戳
		function () self:SendProtocal(28700, {}) end,	-- 新版战令
		function () self:SendProtocal(28703, {}) end,
		function () self:SendProtocal(25232, {}) end, --战力前五神装总评分
		function () self:SendProtocal(16651, {}) end, --战力直升礼包（0.1元礼包）
		function () self:SendProtocal(10987, {}) end, --订阅特权红点
		function () self:SendProtocal(23235, {}) end, --请求当天先知召唤界面是否打开
		function () self:SendProtocal(10985, {}) end,   --红点系列已点过的红点
		-- function () self:SendProtocal(10931, {}) end, --二维码
		
	}

	for i,fun in ipairs(delay_fun_list) do
		RenderMgr:getInstance():doNextFrame(fun)
	end
end

-- 这里统一调用断线重连时的协议请求
function SysController:requestReLinkProtocals(  )
	local delay_fun_list = {
		function () self:SendProtocal(10500, {}) end, 	-- 背包
        function () self:SendProtocal(10501, {}) end,   -- 背包
		function () self:SendProtocal(10503, {}) end, 	-- 宠物背包
		function () self:SendProtocal(13006, {}) end, 	-- 剧情副本基础信息
		function () self:SendProtocal(13008, {}) end, 	-- 剧情副本通关奖励
		function () self:SendProtocal(13011, {}) end, 	-- 剧情副本Buff数据
		function () self:SendProtocal(13017, {}) end, 	-- 剧情副本挂机数据
		function () self:SendProtocal(10906, {}) end,   -- 开服天数
		function () self:SendProtocal(25000, {}) end, 	-- 元素圣殿
		function () self:SendProtocal(24204, {}) end, 	-- 公会战状态
		function () self:SendProtocal(11025, {}) end, 	-- 英雄数据
		function () self:SendProtocal(21021, {}) end, 	-- 周礼包是否开启
		function () self:SendProtocal(10926, {}) end, 	-- 在线奖励
        function () self:adventrueProtocal() end,       -- 冒险
		function () self:SendProtocal(11040, {}) end, 	-- 英雄图鉴
		function () self:SendProtocal(11037, {}) end, 	-- 符文祝福
		function () self:SendProtocal(11213, {type_list={{type = PartnerConst.Fun_Form.Drama}, {type = PartnerConst.Fun_Form.Arena}}}) end, 	-- 阵法
		
		--function () self:expeditProtocal() end, 	-- 远征
		function () self:SendProtocal(25300, {}) end, 	-- 战令任务红点
		function () self:SendProtocal(24312, {}) end, 	-- 天梯是否开启
		function () self:SendProtocal(23200, {}) end, 	-- 召唤数据
		function () self:SendProtocal(10400, {}) end, 	-- 任务列表
		function () self:SendProtocal(16400, {}) end, 	-- 成就列表
		function () self:SendProtocal(20300, {}) end, 	-- 活跃度
        function () self:SendProtocal(25810, {}) end,   -- 历练任务
		function () self:SendProtocal(19906, {}) end, 	-- 录像馆点赞
		function () self:SendProtocal(21006, {}) end, 	-- 每日礼包
		function () self:SendProtocal(16705, {}) end, 	-- 月卡信息
		function () self:SendProtocal(24700, {}) end, 	-- 基金
		function () self:SendProtocal(10800, {}) end, 	-- 邮件
		function () self:SendProtocal(10950, {}) end, 	-- 公告
		function () self:SendProtocal(26017, {}) end,   -- 是否第一次打开家园
        function () self:homepetProtocal() end,   		-- 宠物基本信息
        function () self:SendProtocal(25814, {}) end, 	-- 申请隐藏成就
        function () self:SendProtocal(11056, {}) end, 	-- 融合神殿红点问题
        function () self:SendProtocal(11320, {}) end,   -- 星命塔数据
        function () self:SendProtocal(25833, {}) end,   -- 成长之路嘉年华信息

		function () self:crossarenaProtocal() end, 		-- 跨服竞技场
		function () self:guildRedBagProtocal() end, 	-- 公会红包
        function () self:arenateamProtocal() end,   	-- 组队竞技场
        function () self:arenaPeakProtocal() end,       -- 巅峰冠军赛

		function () self:arenaProtocal() end, 			-- 竞技场
		function () self:endlessProtocal() end, 		-- 无尽试炼
		function () self:voyageProtocal() end, 			-- 远航
		function () self:homeworldProtocal() end, 		-- 家园
		function () self:crosschampionProtocal() end, 	-- 跨服冠军赛
		function () self:elfinProtocal() end, 	        -- 精灵
		function () self:monopolyProtocal() end, 		-- 圣夜奇境
		function () self:requestVisitior() end, 		--  针对游客玩家处理
        
		function () self:SendProtocal(27102, {}) end, 	-- 奇遇数据
		function () self:SendProtocal(28700, {}) end, 	-- 新版战令任务红点
		function () self:SendProtocal(13300, {}) end,   --重新请求好友的数据
		function () self:SendProtocal(25232, {}) end,   --战力前五神装总评分
		function () self:SendProtocal(10985, {}) end,   --红点系列已点过的红点
		
	}
	for i,fun in ipairs(delay_fun_list) do
		RenderMgr:getInstance():doNextFrame(fun)
	end
end

-- 这里统一调用角色等级或开服天数变化时的协议请求（主要是某功能x级开启，需要在达到X级请求一次数据）
function SysController:requestAttrProtocals(  )
	if not self.attr_fun_list then return end
	for i,v in pairs(self.attr_fun_list) do
		local fun = v.fun
		if not v.req_flag and fun then -- 判断是否请求过，请求过的则无需再请求
			RenderMgr:getInstance():doNextFrame(fun)
		end
	end
end

-- 初始化角色等级或开服天数变化时的协议请求列表
-- 注意：这里的顺序不要修改
function SysController:initAttrProtocalsFunList( force )
	if force or not self.attr_fun_list then
		self.attr_fun_list = {
			[1] = {fun = function () self:adventrueProtocal() end, req_flag = false}, 	-- 冒险
			[2] = {fun = function () self:arenaProtocal() end, req_flag = false}, 		-- 竞技场
			[3] = {fun = function () self:endlessProtocal() end, req_flag = false}, 		-- 无尽试炼
            [4] = {fun = function () self:voyageProtocal() end, req_flag = false},        -- 远航
			[5] = {fun = function () self:crossarenaProtocal() end, req_flag = false}, 		-- 跨服竞技场
			[6] = {fun = function () self:homeworldProtocal() end, req_flag = false}, 		-- 家园
			[7] = {fun = function () self:crosschampionProtocal() end, req_flag = false}, 	-- 跨服冠军赛
			[8] = {fun = function () self:elfinProtocal() end, req_flag = false}, 	    -- 精灵
            --[9] = {fun = function () self:expeditProtocal() end, req_flag = false},         -- 远征
            [10] = {fun = function () self:arenateamProtocal() end, req_flag = false},      -- 组队竞技场
			[11] = {fun = function () self:arenaPeakProtocal() end, req_flag = false}, 	    -- 巅峰冠军赛
			[12] = {fun = function () self:monopolyProtocal() end, req_flag = false}, 	    -- 圣夜
			[13] = {fun = function () self:planesProtocal() end, req_flag = false}, 	    -- 位面
		}
	end
end

-- 检测是否请求过数据
function SysController:checkProtocalIsCanRequest( id )
	if self.attr_fun_list and self.attr_fun_list[id] and not self.attr_fun_list[id].req_flag then
		return true
	end
	return false
end

-- 重置请求标识
function SysController:resetAttrProtocals(  )
	self:initAttrProtocalsFunList(true)
end

---------------------@ 以下是一些特殊的协议请求(需要判断开启等级、开服天数等条件)
-- 冒险的协议请求
function SysController:adventrueProtocal(  )
	local is_open = forces
    if is_open == nil then
        is_open = AdventureActivityController:getInstance():isOpenActivity(AdventureActivityConst.Ground_Type.adventure)
    end
    if is_open == false then return end
    if not self:checkProtocalIsCanRequest(1) then return end

    self:SendProtocal(20600, {})  -- 冒险基础信息
    self:SendProtocal(20601, {})  -- 冒险buff信息
    self:SendProtocal(20604, {})  -- 冒险伙伴信息数据
    self:SendProtocal(20634, {})  -- 冒险宝箱

    -- self:SendProtocal(20647, {})  -- 宝箱和挑战次数
    -- self:SendProtocal(20642, {})  -- 冒险上阵英雄列表
    -- self:SendProtocal(20657, {})  -- 红点(防守记录红点)
    -- self:SendProtocal(20659, {})  -- 红点(首次打开红点)
    
    if self.attr_fun_list[1] then
    	self.attr_fun_list[1].req_flag = true
    end
end

-- 竞技场的协议请求
function SysController:arenaProtocal(  )
	local config = Config.ArenaData.data_const.limit_lev 
    if not config or not self.role_vo or self.role_vo.lev < config.val then
        return
    end
    if not self:checkProtocalIsCanRequest(2) then return end

    self:SendProtocal(20208, {})
    self:SendProtocal(20200, {})
    self:SendProtocal(20250, {})
    self:SendProtocal(20223, {})
    if self.attr_fun_list[2] then
    	self.attr_fun_list[2].req_flag = true
    end
end

-- 无尽试炼协议请求
function SysController:endlessProtocal(  )
	local open_config = Config.EndlessData.data_const.open_lev
    if open_config == nil then return false end
    local is_open = MainuiController:getInstance():checkIsOpenByActivate(open_config.val)
    if not is_open then return end
    if not self:checkProtocalIsCanRequest(3) then return end

    self:SendProtocal(23900, {})
    self:SendProtocal(23912, {})
    self:SendProtocal(23906, {})
    if self.attr_fun_list[3] then
    	self.attr_fun_list[3].req_flag = true
    end
end

-- 远航协议请求
function SysController:voyageProtocal(  )
	local lev_config = Config.ShippingData.data_const["guild_lev"]
	if not lev_config or not self.role_vo or lev_config.val > self.role_vo.lev then
		return
	end
	if not self:checkProtocalIsCanRequest(4) then return end

    self:SendProtocal(23800, {})
    self:SendProtocal(23805, {})
    if self.attr_fun_list[4] then
    	self.attr_fun_list[4].req_flag = true
    end
end

-- 公会红包(只需要登陆和断线时请求，加入公会时，后端会主动推)
function SysController:guildRedBagProtocal(  )
	if self.role_vo and self.role_vo.gid ~= 0 and self.role_vo.gsrv_id ~= "" then
		self:SendProtocal(13534, {})
	end
end

function SysController:homepetProtocal()
    self:SendProtocal(26100, {})  -- 宠物基本信息
    self:SendProtocal(26105, {})  -- 宠物事件信息
    self:SendProtocal(26110, {})  -- 宠物记录信息
    self:SendProtocal(26111, {type = 34})  -- 宠物相册
    self:SendProtocal(26111, {type = 35})  -- 宠物明信片
end

-- 跨服竞技场
function SysController:crossarenaProtocal(  )
    if not self:checkProtocalIsCanRequest(5) then return end
	-- 功能开启才请求数据
	if CrossarenaController:getInstance():getModel():getCrossarenaIsOpen(true) then
		self:SendProtocal(25610, {}) -- 活动开启状态
    	--self:SendProtocal(25600, {}) -- 个人基础信息
        self:SendProtocal(25607, {}) -- 奖励领取数据
        self:SendProtocal(25618, {}) -- 红点数据
    	self:SendProtocal(25605, {type = 2}) -- 跨服竞技场防守阵型

    	if self.attr_fun_list[5] then
	    	self.attr_fun_list[5].req_flag = true
	    end
	end
end

-- 家园
function SysController:homeworldProtocal(  )
	if not HomeworldController:getInstance():getModel():checkHomeworldIsOpen(true) then return end
	if not self:checkProtocalIsCanRequest(6) then return end

	self:SendProtocal(26017, {})  -- 是否第一次打开家园
	self:SendProtocal(26018, {})  -- 登陆红点
	self:SendProtocal(26013, {})  -- 套装奖励数据

	if self.attr_fun_list[6] then
    	self.attr_fun_list[6].req_flag = true
    end
end

-- 跨服冠军赛
function SysController:crosschampionProtocal(  )
	if not self:checkProtocalIsCanRequest(7) then return end
	if not CrosschampionController:getInstance():getModel():checkCrossChampionIsOpen(true) then return end

	self:SendProtocal(26200, {})  -- 冠军赛进程状态
	self:SendProtocal(26213, {})  -- 前三名数据(用于红点)

	if self.attr_fun_list[7] then
    	self.attr_fun_list[7].req_flag = true
    end
end

-- 精灵
function SysController:elfinProtocal(  )
	if not self:checkProtocalIsCanRequest(8) then return end
	if not ElfinController:getInstance():getModel():checkElfinIsOpen(true) then return end

	self:SendProtocal(26500, {}) -- 精灵孵化器数据
	self:SendProtocal(26510, {}) -- 精灵古树数据
	self:SendProtocal(26550, {}) -- 精灵召唤数据
	
	if self.attr_fun_list[8] then
    	self.attr_fun_list[8].req_flag = true
    end
end

--远征
function SysController:expeditProtocal(  )
    --[[ if not self:checkProtocalIsCanRequest(9) then return end
    local control = HeroExpeditController:getInstance()
    if control and control.checkoutExpeditIsOpen then
        local status = control:checkoutExpeditIsOpen()
        if status == false then return end

        self:SendProtocal(24410, {})    -- 远征红点
        self:SendProtocal(24411, {})    -- 远征派遣红点
        self:SendProtocal(24400, {})    -- 远征数据
        self:SendProtocal(24405, {})    -- 远征支援

        if self.attr_fun_list[9] then
            self.attr_fun_list[9].req_flag = true
        end
    end ]]
end

--组队竞技场
function SysController:arenateamProtocal(  )
    if not self:checkProtocalIsCanRequest(10) then return end
    local control = ArenateamController:getInstance()
    if control and control.checkArenaTeamIsOpen then
        local status = control:checkArenaTeamIsOpen(true)
        if status == false then return end
        self:SendProtocal(27220, {})    -- 组队
        self:SendProtocal(27215, {})    -- 红点
        self:SendProtocal(11211, {type = PartnerConst.Fun_Form.ArenaTeam})    -- 布阵类型

        if self.attr_fun_list[10] then
            self.attr_fun_list[10].req_flag = true
        end
    end
end

--巅峰冠军
function SysController:arenaPeakProtocal(  )
	if not self:checkProtocalIsCanRequest(11) then return end
    local control = ArenapeakchampionController:getInstance()
    local model = control:getModel()
    if model and model.checkPeakChampionIsOpen then
        local status = model:checkPeakChampionIsOpen(true)
        if status == false then return end
        self:SendProtocal(27700, {}) -- 巅峰冠军赛主协议
        self:SendProtocal(27703, {}) -- 下注的
        self:SendProtocal(27730, {}) -- 巅峰冠军赛登陆红点
        self:SendProtocal(27726, {}) -- 阵法
		self:SendProtocal(27714, {zone_id = 0, start_num = 1, end_num = 1}) -- 排行

		if self.attr_fun_list[11] then
	    	self.attr_fun_list[11].req_flag = true
	    end
	end
end

-- 圣夜奇境
function SysController:monopolyProtocal()
	if not self:checkProtocalIsCanRequest(12) then return end
	if not MonopolyController:getInstance():getModel():checkMonopolyIsOpen(true) then return end

	--self:SendProtocal(27400, {}) -- 活动状态

	if self.attr_fun_list[12] then
    	self.attr_fun_list[12].req_flag = true
    end
end

-- 位面
function SysController:planesProtocal()
	if not self:checkProtocalIsCanRequest(13) then return end
	if not PlanesafkController:getInstance():checkPlanesIsOpen(true) then return end

    self:SendProtocal(28603, {}) --位面基础数据
	self:SendProtocal(28616, {}) --位面基础数据

	if self.attr_fun_list[13] then
    	self.attr_fun_list[13].req_flag = true
    end
end

function SysController:requestVisitior()
	if NEED_CHECK_VISITIOR_STATUS then
		self:SendProtocal(10394, {})
	end
end

-- 实名认证窗体提示信息
function SysController:rgp_hander10394(data)
	if NEED_CHECK_VISITIOR_STATUS then   -- 只针对新包处理
		if OPEN_SDK_VISITIOR_WINDOW == true then
			NEED_OPEN_OPEN_SDK_VISITIOR_WINDOW = true
		else
			callFunc("touristMode", "60") 		-- 打开实名认证窗体
		end
	end
end

function SysController:__delete(  )
end