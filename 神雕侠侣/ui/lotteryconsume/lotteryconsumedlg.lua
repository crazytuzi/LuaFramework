require "ui.dialog"

local LotteryConsumeDlg = {}
setmetatable(LotteryConsumeDlg, Dialog)
LotteryConsumeDlg.__index = LotteryConsumeDlg

-- 状态
LotteryConsumeDlg.STATE_READY 		= 0		-- 准备状态
LotteryConsumeDlg.STATE_START 		= 1		-- 点击“开始”进入，匀速转动
LotteryConsumeDlg.STATE_STOP		= 2		-- 点击“停止”进入，减速
LotteryConsumeDlg.STATE_BONUS 		= 3		-- 停止转动进入

LotteryConsumeDlg.SPEED				= math.pi * 4		-- 匀速转动时的速度
LotteryConsumeDlg.STOP_ROUND		= 2					-- 几圈停下


------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function LotteryConsumeDlg.getInstance()
	print("enter get LotteryConsumeDlg dialog instance")
	if not _instance then
		_instance = LotteryConsumeDlg:new()
		_instance:OnCreate()
	end

	return _instance
end

function LotteryConsumeDlg.getInstanceAndShow()
	print("enter LotteryConsumeDlg dialog instance show")
	if not _instance then
		_instance = LotteryConsumeDlg:new()
		_instance:OnCreate()
	else
		print("set LotteryConsumeDlg dialog visible")
		_instance:SetVisible(true)
	end

	return _instance
end

function LotteryConsumeDlg.getInstanceNotCreate()
	return _instance
end

function LotteryConsumeDlg.DestroyDialog()
	if _instance then
		_instance:OnClose()
		_instance = nil
	end
end

function LotteryConsumeDlg.ToggleOpenClose()
	if not _instance then
		_instance = LotteryConsumeDlg:new()
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

function LotteryConsumeDlg.GetLayoutFileName()
	return "xiaohaozhuanpan.layout"
end

function LotteryConsumeDlg:OnCreate()
	print("LotteryConsumeDlg dialog oncreate begin")
	Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()

	-- 标题
	self.m_title = winMgr:getWindow("xiaohaozhuanpan/luckyback/title")

	-- 轮盘道具
	self.m_Item = {}
	self.m_Name = {}

	for i = 1,10 do
		-- 道具
		self.m_Item[i] = CEGUI.Window.toItemCell(winMgr:getWindow("xiaohaozhuanpan/luckyback/cell" .. tostring(i-1)))
		-- 名字
		self.m_Name[i] = winMgr:getWindow("xiaohaozhuanpan/luckyback/red/txt" .. tostring(i-1))
	end

	-- 指针
	self.m_effect = winMgr:getWindow("xiaohaozhuanpan/luckyback/effect")
	if self.m_effect then
		self.m_Arroweffect = GetGameUIManager():AddUIEffect(self.m_effect, MHSD_UTILS.get_effectpath(10395))
	end

	-- 开始/停止/取出
	self.m_pStartBtn = CEGUI.Window.toPushButton(winMgr:getWindow("xiaohaozhuanpan/luckyback/imgebtn"))
	if self.m_pStartBtn then
		self.m_pStartBtn:subscribeEvent("Clicked", LotteryConsumeDlg.HandleStartBtnClick, self)
	end

	-- 百发百中
	self.m_pBaiBtn = CEGUI.Window.toPushButton(winMgr:getWindow("xiaohaozhuanpan/left/qiehuan0/btn"))
	if self.m_pBaiBtn then
		self.m_pBaiBtn:setID(1)
		self.m_pBaiBtn:subscribeEvent("Clicked", LotteryConsumeDlg.HandleSwitchBtnClick, self)
	end
	-- 百发百中选中
	self.m_pBaiEffect = winMgr:getWindow("xiaohaozhuanpan/left/qiehuan0")
	-- 百发百中次数
	self.m_BaiTimes = winMgr:getWindow("xiaohaozhuanpan/left/shuoming3")
	-- 百发百中元宝数
	self.m_BaiYuanbao = winMgr:getWindow("xiaohaozhuanpan/left/bar/txt/tt")
	-- 百发百中进度条
	self.m_BaiBar = CEGUI.Window.toProgressBar(winMgr:getWindow("xiaohaozhuanpan/left/bar"))

	-- 万事如意
	self.m_pWanBtn = CEGUI.Window.toPushButton(winMgr:getWindow("xiaohaozhuanpan/left/qiehuan1/btn"))
	if self.m_pWanBtn then
		self.m_pWanBtn:setID(2)
		self.m_pWanBtn:subscribeEvent("Clicked", LotteryConsumeDlg.HandleSwitchBtnClick, self)
	end
	-- 万事如意选中
	self.m_pWanEffect = winMgr:getWindow("xiaohaozhuanpan/left/qiehuan1")
	-- 万事如意次数
	self.m_WanTimes = winMgr:getWindow("xiaohaozhuanpan/left/shuoming7")
	-- 万事如意元宝数
	self.m_WanYuanbao = winMgr:getWindow("xiaohaozhuanpan/left/bar1/txt/tt")
	-- 万事如意进度条
	self.m_WanBar = CEGUI.Window.toProgressBar(winMgr:getWindow("xiaohaozhuanpan/left/bar1"))

	-- 剩余天数
	self.m_Day = winMgr:getWindow("xiaohaozhuanpan/time/txt0")
	-- 剩余小时数
	self.m_Hour = winMgr:getWindow("xiaohaozhuanpan/time/txt1")
	-- 剩余分钟数
	self.m_Minute = winMgr:getWindow("xiaohaozhuanpan/time/txt2")

	local window = self:GetWindow()
	if window then
		window:subscribeEvent("WindowUpdate", LotteryConsumeDlg.HandleWindowUpdate, self)
	end

	print("LotteryConsumeDlg dialog oncreate end")
end

------------------- private: -----------------------------------

function LotteryConsumeDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, LotteryConsumeDlg)

	return self
end

-- 打开界面服务器刷新界面信息
function LotteryConsumeDlg:info(Type, AwardId, Info)

	if not Type or not AwardId or not Info then return end

	self.m_AwardId = AwardId

	-- 根据根据奖励ID设置初始Index，并根据Index设置指针位置
	local Index

	-- 有奖品未领取
	if AwardId >= 10 and AwardId <= 29 then
		Index = AwardId % 10 + 1

		-- 显示“取出”按钮
		if self.m_pStartBtn then
			self.m_pStartBtn:setProperty("NormalImage", "set:MainControl27 image:out")
			self.m_pStartBtn:setProperty("PushedImage", "set:MainControl27 image:out")
			self.m_pStartBtn:setProperty("HoverImage", "set:MainControl27 image:out")
		end

		self.m_nState = LotteryConsumeDlg.STATE_BONUS
		-- 重新开始
	else
		Index = 0
		self.m_nState = LotteryConsumeDlg.STATE_READY
	end

	self.m_angle = (math.pi * 2 / 10) * Index % (math.pi * 2)
	self.m_Arroweffect:SetRotationRadian(self.m_angle)

	-- 根据类型刷新轮盘显示内容
	self:refreshRoulette(Type)

	-- 记录页面信息
	self.m_Info = Info

	-- 剩余时间
	self.m_remainTime = Info.delaytime

	-- 百发百中相关信息
	if self.m_BaiTimes then
		self.m_BaiTimes:setText(tostring(Info.bfleftnums))
	end

	if self.m_BaiYuanbao then
		self.m_BaiYuanbao:setText(tostring(Info.bfless))
	end

	if self.m_BaiBar then
		self.m_BaiBar:setProgress((Info.bftotalper - Info.bfless)/Info.bftotalper)
	end

	-- 万事如意相关信息
	if self.m_WanTimes then
		self.m_WanTimes:setText(tostring(Info.wsleftnums))
	end

	if self.m_WanYuanbao then
		self.m_WanYuanbao:setText(tostring(Info.wsless))
	end

	if self.m_WanBar then
		self.m_WanBar:setProgress((Info.wstotalper - Info.wsless)/Info.wstotalper)
	end
end

-- 根据类型刷新轮盘显示内容
function LotteryConsumeDlg:refreshRoulette(Type)

	-- 默认打开百发百中
	if Type ~= 2 then
		Type = 1
	end

	self.m_type = Type

	-- 根据类型显示标题
	if Type == 1 then
		if self.m_title then
			self.m_title:setProperty("Image","set:MainControl50 image:baifabaizhong")
		end

		if self.m_pBaiEffect then
			self.m_pBaiEffect:setVisible(true)
		end

		if self.m_pWanEffect then
			self.m_pWanEffect:setVisible(false)
		end
	else
		if self.m_title then
			self.m_title:setProperty("Image","set:MainControl50 image:wanshiruyi")
		end

		if self.m_pBaiEffect then
			self.m_pBaiEffect:setVisible(false)
		end

		if self.m_pWanEffect then
			self.m_pWanEffect:setVisible(true)
		end
	end

	-- 根据类型显示奖励内容
	local tItemConfig = knight.gsp.item.GetCItemAttrTableInstance()

	for i = 1,10 do
		-- 根据类型换算奖励Id
		local Id = Type * 10 + i - 1
		local tAward = MHSD_UTILS.getLuaBean("knight.gsp.game.cgiftcompass", Id)
		if tAward and tAward.itemID then
			local nItemId = tAward.itemID
			local tItem = tItemConfig:getRecorder(nItemId)
			if tItem then
				if self.m_Item[i] then
					self.m_Item[i]:setID(nItemId)
					self.m_Item[i]:SetImage(GetIconManager():GetItemIconByID(tItem.icon))
					self.m_Item[i]:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
				end

				if self.m_Name[i] then
					self.m_Name[i]:setText(tostring(tItem.name))
				end
			end
		end
	end
end

-- 主循环每帧执行一次
function LotteryConsumeDlg:HandleWindowUpdate(eventArgs)

	local nInterval = CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame

	if self.m_nState == LotteryConsumeDlg.STATE_START then
		self:rotate(nInterval)
	elseif self.m_nState == LotteryConsumeDlg.STATE_STOP then
		self:rotate(nInterval)
	end

	-- 刷新剩余时间
	self:refreshTime(nInterval)
end

function LotteryConsumeDlg:rotate(interval)
	if not self.m_Arroweffect then return end

	-- 匀速转动
	if self.m_nState == LotteryConsumeDlg.STATE_START then
		self.m_time = self.m_time + interval
		self.m_angle = self.m_angle + LotteryConsumeDlg.SPEED * interval
		-- 匀减速转动
	elseif self.m_nState == LotteryConsumeDlg.STATE_STOP then
		self.m_time = self.m_time + interval

		-- 达到停止时刻之前
		if self.m_time < self.m_stopTime then
			-- 减速时间
			local nTime = self.m_time - self.m_time0
			-- 当前速度
			local nSpeed = LotteryConsumeDlg.SPEED - nTime * self.m_deceleration
			-- 减速转动角度
			local nAngle1 = (nSpeed + LotteryConsumeDlg.SPEED) * nTime / 2
			-- 总角度
			self.m_angle = self.m_angle0 + nAngle1
		else
			-- 到达停止时刻，停到标准位置
			self.m_angle =  (math.pi * 2 / 10) * self.m_stopIndex

			-- 显示“取出”按钮
			if self.m_pStartBtn then
				self.m_pStartBtn:setProperty("NormalImage", "set:MainControl27 image:out")
				self.m_pStartBtn:setProperty("PushedImage", "set:MainControl27 image:out")
				self.m_pStartBtn:setProperty("HoverImage", "set:MainControl27 image:out")
				self.m_pStartBtn:setVisible(true)
			end

			self.m_nState = LotteryConsumeDlg.STATE_BONUS
		end
	end

	-- 更新指针角度
	local nAngle = self.m_angle % (math.pi * 2)
	self.m_Arroweffect:SetRotationRadian(nAngle)
end

-- 刷新剩余时间
function LotteryConsumeDlg:refreshTime(interval)

	if not self.m_remainTime then return end

	-- 更新剩余时间
	self.m_remainTime = self.m_remainTime - interval

	local nRemainDay
	local nRemainHour
	local nRemainMinute

	if self.m_remainTime > 0 then
		local nSecond = math.floor(self.m_remainTime / 1000)
		local nMinute = math.floor(nSecond / 60)
		local nHour = math.floor(nSecond / 3600)

		nRemainDay = math.floor(nSecond / (3600 * 24))
		nRemainHour = nHour - nRemainDay * 24
		nRemainMinute = nMinute - nHour * 60
	else
		nRemainDay = 0
		nRemainHour = 0
		nRemainMinute = 0
	end

	if self.m_Day then
		self.m_Day:setText(tostring(nRemainDay))
	end

	if self.m_Hour then
		self.m_Hour:setText(tostring(nRemainHour))
	end

	if self.m_Minute then
		self.m_Minute:setText(tostring(nRemainMinute))
	end
end

function LotteryConsumeDlg:HandleStartBtnClick(args)

	-- 点击“开始”
	if self.m_nState == LotteryConsumeDlg.STATE_READY then

		-- 剩余次数不足
		if (self.m_type == 1 and self.m_Info.bfleftnums < 1) or (self.m_type == 2 and self.m_Info.wsleftnums < 1) then
			GetGameUIManager():AddMessageTipById(146113)
			return
		end

		self.m_time = 0

		-- “开始”——>“停止”
		if self.m_pStartBtn then
			-- self.m_pStartBtn:setVisible(false)
			self.m_pStartBtn:setProperty("NormalImage", "set:MainControl27 image:stop")
			self.m_pStartBtn:setProperty("PushedImage", "set:MainControl27 image:stop")
			self.m_pStartBtn:setProperty("HoverImage", "set:MainControl27 image:stop")
		end

		self.m_nState = LotteryConsumeDlg.STATE_START

		-- 点击“停止”
	elseif self.m_nState == LotteryConsumeDlg.STATE_START then

		-- 隐藏“停止”按钮
		if self.m_pStartBtn then
			self.m_pStartBtn:setVisible(false)
		end

		-- 请求停止
		local CCsNotifyStop = require 'protocoldef.knight.gsp.activity.cszhuanpan.ccsnotifystop'
		local stop = CCsNotifyStop.Create()
		stop.ztype = self.m_type
		LuaProtocolManager.getInstance():send(stop)

		-- 点击“取出”
	elseif self.m_nState == LotteryConsumeDlg.STATE_BONUS then

		-- 隐藏“取出”按钮
		if self.m_pStartBtn then
			self.m_pStartBtn:setVisible(false)
		end

		-- 请求领奖
		local CCsFetchAward = require 'protocoldef.knight.gsp.activity.cszhuanpan.ccsfetchaward'
		local award = CCsFetchAward.Create()
		award.ztype = self.m_type
		LuaProtocolManager.getInstance():send(award)
	end
end

-- 请求停止 回调
function LotteryConsumeDlg:stop(Type, AwardId, Info)

	if not Type or not AwardId or not Info or AwardId < 10 or AwardId > 29 then return end

	if self.m_nState ~= LotteryConsumeDlg.STATE_START then return end

	-- 记录奖励ID
	self.m_AwardId = AwardId

	-- 记录页面信息
	self.m_Info = Info

	-- 停止位置
	self.m_stopIndex = AwardId % 10 + 1

	-- 记录匀速转动的时间和角度
	self.m_time0 = self.m_time
	self.m_angle0 = self.m_angle

	-- 当前角度
	local nAngle = self.m_angle0 % (math.pi * 2)
	-- 减速转动总角度
	local stopAngle = (math.pi * 2 / 10) * self.m_stopIndex - nAngle + (math.pi * 2) * LotteryConsumeDlg.STOP_ROUND
	-- 停止时刻
	self.m_stopTime = stopAngle * 2 / LotteryConsumeDlg.SPEED + self.m_time0
	-- 减速度
	self.m_deceleration = LotteryConsumeDlg.SPEED ^ 2 / (stopAngle * 2)

	-- 更新界面显示次数
	if Type == 1 and self.m_BaiTimes then
		self.m_BaiTimes:setText(tostring(Info.bfleftnums))
	elseif Type == 2 and self.m_WanTimes then
		self.m_WanTimes:setText(tostring(Info.wsleftnums))
	end

	self.m_nState = LotteryConsumeDlg.STATE_STOP
end

-- 请求领奖 回调
function LotteryConsumeDlg:award(flag, status, Info)

	if self.m_nState ~= LotteryConsumeDlg.STATE_BONUS then return end

	-- 记录页面信息
	self.m_Info = Info

	-- 成功
	if flag == 1 then
		self.m_AwardId = -1

		-- 如果活动结束，则关闭界面
		if status == 0 then
			LotteryConsumeDlg.DestroyDialog()
			return
		end

		-- 显示“开始”按钮
		if self.m_pStartBtn then
			self.m_pStartBtn:setProperty("NormalImage", "set:MainControl27 image:start")
			self.m_pStartBtn:setProperty("PushedImage", "set:MainControl27 image:start")
			self.m_pStartBtn:setProperty("HoverImage", "set:MainControl27 image:start")
			self.m_pStartBtn:setVisible(true)
		end

		self.m_nState = LotteryConsumeDlg.STATE_READY
		-- 失败
	elseif flag == 0 then
		-- 重新显示“取出”按钮
		if self.m_pStartBtn then
			self.m_pStartBtn:setVisible(true)
		end
	end
end

-- 点击“百发百中“或”万事如意“
function LotteryConsumeDlg:HandleSwitchBtnClick(args)

	if self.m_nState ~= LotteryConsumeDlg.STATE_READY then return end

	local mouseArgs = CEGUI.toMouseEventArgs(args)
	local nType = mouseArgs.window:getID()

	-- 点当前活动对应按钮不切换
	if self.m_type == nType or (nType ~= 1 and nType ~= 2) then return end

	-- 刷新界面轮盘内容
	self:refreshRoulette(nType)

	-- 初始化指针位置
	self.m_angle = 0
	self.m_Arroweffect:SetRotationRadian(self.m_angle)
end

return LotteryConsumeDlg