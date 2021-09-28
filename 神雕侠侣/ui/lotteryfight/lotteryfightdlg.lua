require "ui.dialog"

local LotteryFightDlg = {}
setmetatable(LotteryFightDlg, Dialog)
LotteryFightDlg.__index = LotteryFightDlg

-- 状态
LotteryFightDlg.STATE_READY 	= 0		-- 准备状态
LotteryFightDlg.STATE_START 	= 1		-- 点击“开始”进入，加速
LotteryFightDlg.STATE_TOPSPEED 	= 2		-- 达到最大速度进入
LotteryFightDlg.STATE_STOP		= 3		-- 点击“停止”进入，减速
LotteryFightDlg.STATE_FIGHT 	= 4		-- 到达目标位置进入，发送战斗请求


LotteryFightDlg.MIN_STOPSTEP = 10		-- 减速后最快几步停住
LotteryFightDlg.MIN_INTERVAL = 0.08		-- 光圈切换的最小间隔时间（速度最快）
LotteryFightDlg.MAX_INTERVAL = 1		-- 光圈切换的最大间隔时间（速度最慢）
LotteryFightDlg.ACCELERATION = 0.02		-- 加速度（时间间隔每帧降低）
LotteryFightDlg.DECELERATION = 0.005		-- 减速度（时间间隔每帧增加）


------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function LotteryFightDlg.getInstance()
	print("enter get LotteryFightDlg dialog instance")
	if not _instance then
		_instance = LotteryFightDlg:new()
		_instance:OnCreate()
	end

	return _instance
end

function LotteryFightDlg.getInstanceAndShow()
	print("enter LotteryFightDlg dialog instance show")
	if not _instance then
		_instance = LotteryFightDlg:new()
		_instance:OnCreate()
	else
		print("set LotteryFightDlg dialog visible")
		_instance:SetVisible(true)
	end

	return _instance
end

function LotteryFightDlg.getInstanceNotCreate()
	return _instance
end

function LotteryFightDlg.DestroyDialog()
	if _instance then
		_instance:OnClose()
		_instance = nil
	end
end

function LotteryFightDlg.ToggleOpenClose()
	if not _instance then
		_instance = LotteryFightDlg:new()
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

----/////////////////////////////////////////------

function LotteryFightDlg.GetLayoutFileName()
	return "lulintiaozhanmain.layout"
end

function LotteryFightDlg:OnCreate()
	print("LotteryFightDlg dialog oncreate begin")
	Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_img = {}
	self.m_name = {}
	self.m_mark = {}
	self.m_light = {}

	for i = 1,10 do
		-- 获取NPC配置
		local tNpc = MHSD_UTILS.getLuaBean("knight.gsp.game.clulintiaozhan", i)

		-- 头像
		self.m_img[i] = winMgr:getWindow("lulintiaozhanmain/diban/card/item/img" .. tostring(i-1))
		if type(tNpc) == 'table' and self.m_img[i] then
			self.m_img[i]:setProperty("Image", GetIconManager():GetImagePathByID(tNpc.touxiang):c_str())
		end

		-- 名字
		-- test
		local j = 10 -(i-1)
		if j > 9 then j = j - 10 end
		self.m_name[i] = winMgr:getWindow("lulintiaozhanmain/diban/card/txt" .. tostring(j))
		-- test end
		-- self.m_name[i] = winMgr:getWindow("lulintiaozhanmain/diban/card/txt" .. tostring(i-1))
		if type(tNpc) == 'table' and self.m_name[i] then
			self.m_name[i]:setText(tostring(tNpc.name))
		end

		-- 标志
		self.m_mark[i] = winMgr:getWindow("lulintiaozhanmain/diban/card/item/img/zhansheng" .. tostring(i-1))
		if self.m_mark[i] then
			self.m_mark[i]:setVisible(false)
		end

		-- 光圈
		self.m_light[i] = winMgr:getWindow("lulintiaozhanmain/diban/card/item/light" .. tostring(i-1))
		if self.m_light[i] then
			self.m_light[i]:setVisible(false)
		end
	end

	-- 开始
	self.m_pStartBtn = CEGUI.Window.toPushButton(winMgr:getWindow("lulintiaozhanmain/diban/start"))
	if self.m_pStartBtn then
		self.m_pStartBtn:subscribeEvent("Clicked", LotteryFightDlg.HandleStartBtnClick, self)
	end

	-- 关闭
	self.m_pCloseBtn = CEGUI.Window.toPushButton(winMgr:getWindow("lulintiaozhanmain/back/close"))
	if self.m_pCloseBtn then
		self.m_pCloseBtn:subscribeEvent("Clicked", LotteryFightDlg.HandleCloseBtnClick, self)
	end

	local window = self:GetWindow()
	if window then
		window:subscribeEvent("WindowUpdate", LotteryFightDlg.HandleWindowUpdate, self)
	end

	print("LotteryFightDlg dialog oncreate end")
end

------------------- private: -----------------------------------

function LotteryFightDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, LotteryFightDlg)

	return self
end

-- 打开界面服务器刷新界面信息
function LotteryFightDlg:info(records, canStart)

	if type(records) ~= 'table' then return end

	if self.m_nState and self.m_nState >= LotteryFightDlg.STATE_READY then return end

	self.m_tIndexGroup = {}
	for i = 1, 10 do
		self.m_tIndexGroup[#self.m_tIndexGroup + 1] = i
	end

	-- 是否失败过
	self.m_nLost = 0
	-- 是否全胜
	self.m_nAllWin = 0

	for _,gangRoleInfo in ipairs(records) do
		if gangRoleInfo.state == 1 and gangRoleInfo.id then
			if self.m_mark[gangRoleInfo.id] then
				-- test
				self.m_mark[gangRoleInfo.id]:setProperty("Image", "set:MainControl27 image:stop")
				-- test end
				-- 头像加标记
				self.m_mark[gangRoleInfo.id]:setVisible(true)
			end

			-- 打过的从备选组移除
			for k,v in ipairs(self.m_tIndexGroup) do
				if v == gangRoleInfo.id then
					table.remove(self.m_tIndexGroup, k)
					break
				end
			end
		elseif gangRoleInfo.state == 2 then
			self.m_nLost = 1
		end
	end

	if #self.m_tIndexGroup < 1 then
		self.m_nAllWin = 1
	end

	self.m_nState = LotteryFightDlg.STATE_READY
end

function LotteryFightDlg:HandleWindowUpdate(eventArgs)

	local nInterval = CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame

	if self.m_nState == LotteryFightDlg.STATE_START then

		-- 加速状态下，间隔不断减少
		self.m_nInterval = self.m_nInterval - LotteryFightDlg.ACCELERATION

		-- 达到最大速度可以点“停止”
		if self.m_nInterval < LotteryFightDlg.MIN_INTERVAL then
			self.m_nInterval = LotteryFightDlg.MIN_INTERVAL
			self.m_nState = LotteryFightDlg.STATE_TOPSPEED
			if self.m_pStartBtn then
				self.m_pStartBtn:setVisible(true)
			end
		end

		self:rotate(nInterval)

	elseif self.m_nState == LotteryFightDlg.STATE_TOPSPEED then
		self:rotate(nInterval)
	elseif self.m_nState == LotteryFightDlg.STATE_STOP then

		-- 减速状态下，间隔不断增加
		self.m_nInterval = self.m_nInterval + LotteryFightDlg.DECELERATION
		if self.m_nInterval > LotteryFightDlg.MAX_INTERVAL then
			self.m_nInterval = LotteryFightDlg.MAX_INTERVAL
		end

		-- 达到目标位置，并且满足最小步数要求时，停止转动
		if self.m_nIndex == self.m_nStopIndex and self.m_nStopStep >= self.MIN_STOPSTEP then
			self.m_nState = LotteryFightDlg.STATE_FIGHT
			self.m_nStartFightCount = 0
			return
		end

		self:rotate(nInterval)

	elseif self.m_nState == LotteryFightDlg.STATE_FIGHT then

		-- 停一会儿再进战斗
		self.m_nStartFightCount = self.m_nStartFightCount + 1
		if self.m_nStartFightCount > 30 then
			-- 关闭界面
			self.DestroyDialog()
			-- 进入战斗
			local CBattleGangMan = require 'protocoldef.knight.gsp.activity.gangman.cbattlegangman'
			local battle = CBattleGangMan.Create()
			LuaProtocolManager.getInstance():send(battle)
		end
	end
end

function LotteryFightDlg:rotate(interval)

	-- 更新停留时间，超过时间间隔切换光圈
	self.m_nStaytime = self.m_nStaytime + interval
	if self.m_nStaytime >= self.m_nInterval then

		-- 停留时间清零
		self.m_nStaytime = 0

		-- 当前位置光圈不可见
		if not self.m_nIndex or not self.m_tIndexGroup[self.m_nIndex] or not self.m_light[self.m_tIndexGroup[self.m_nIndex]] then return end
		self.m_light[self.m_tIndexGroup[self.m_nIndex]]:setVisible(false)

		-- 计算新位置
		self.m_nIndex = self.m_nIndex + 1
		if self.m_nIndex > #self.m_tIndexGroup then
			self.m_nIndex = 1
		end

		-- 显示新位置的光圈
		if not self.m_tIndexGroup[self.m_nIndex] or not self.m_light[self.m_tIndexGroup[self.m_nIndex]] then return end
		self.m_light[self.m_tIndexGroup[self.m_nIndex]]:setVisible(true)

		-- 更新减速状态下的步数，达到步数要求后，到达目标位置才会停止
		if self.m_nState == LotteryFightDlg.STATE_STOP then
			self.m_nStopStep = self.m_nStopStep + 1
		end
	end
end

function LotteryFightDlg:HandleStartBtnClick(args)

	-- 点击“开始”
	if self.m_nState == LotteryFightDlg.STATE_READY then

		-- 等级不足50，不能开始
		local nLevel = GetDataManager():GetMainCharacterLevel()
		if not nLevel or nLevel < 50 then
			GetGameUIManager():AddMessageTipById(146376)
			return
		end

		-- 如果失败无法继续
		if self.m_nLost ~= 0 then
			GetGameUIManager():AddMessageTipById(146375)
			return
		end

		-- 连胜十轮无法继续
		if self.m_nAllWin ~= 0 then
			GetGameUIManager():AddMessageTipById(146379)
			return
		end

		-- 请求随机
		local CRandomGangMan = require 'protocoldef.knight.gsp.activity.gangman.crandomgangman'
		local rand = CRandomGangMan.Create()
		LuaProtocolManager.getInstance():send(rand)

		-- 点击“停止”
	elseif self.m_nState == LotteryFightDlg.STATE_TOPSPEED then

		self.m_nState = LotteryFightDlg.STATE_STOP
		self.m_nStopStep = 0
		if self.m_pStartBtn then
			self.m_pStartBtn:setVisible(false)
		end

		-- 最后一轮不需要转
		if #self.m_tIndexGroup == 1 then
			self.m_nInterval = LotteryFightDlg.MAX_INTERVAL
			self.m_nIndex = self.m_nStopIndex
			self.m_nStopStep = self.MIN_STOPSTEP
		end
	end
end

-- 请求随机后服务器返回停止索引
function LotteryFightDlg:rand(id)

	if self.m_nState ~= LotteryFightDlg.STATE_READY then return end

	self.m_nState = LotteryFightDlg.STATE_START
	self.m_nIndex = 1
	self.m_nStaytime = 0
	self.m_nInterval = LotteryFightDlg.MAX_INTERVAL
	-- 最后一轮不需要转
	if #self.m_tIndexGroup == 1 then
		self.m_nInterval = LotteryFightDlg.MIN_INTERVAL
	end

	-- 确定停止位置
	for k,v in ipairs(self.m_tIndexGroup) do
		if v == id then
			self.m_nStopIndex = k
			break
		end
	end

	-- 隐藏“开始”按钮
	if self.m_pStartBtn then
		self.m_pStartBtn:setVisible(false)
		self.m_pStartBtn:setProperty("NormalImage", "set:MainControl27 image:stop")
	end

	-- 显示光圈
	if self.m_tIndexGroup[self.m_nIndex] and self.m_light[self.m_tIndexGroup[self.m_nIndex]] then
		self.m_light[self.m_tIndexGroup[self.m_nIndex]]:setVisible(true)
	end
end

return LotteryFightDlg