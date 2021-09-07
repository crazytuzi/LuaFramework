-- -------------------------------
-- 分享推广模块
-- hosr
-- -------------------------------
ShareManager = ShareManager or BaseClass(BaseManager)

function ShareManager:__init()
	if ShareManager.Instance then
		return
	end
	ShareManager.Instance = self

	self.model = ShareModel.New(self)

	self.shareData = ShareData.New()
	self.gainList = {}

	self.needSend17506 = false
	self.needSend17506Delay = false

	self:InitHandler()
end

function ShareManager:RequestInitData()
	self.model:CloseMain()

	if self:IsOpen() then
		self:Send17505()
	end

	if self.needSend17506 then
		self.needSend17506 = false
		self:Send17506()
	end

	if self.needSend17506Delay then
		self.needSend17506Delay = false
		LuaTimer.Add(5000, function() self:Send17506() end)
	end
end

function ShareManager:InitHandler()
    self:AddNetHandler(17500, self.On17500)
    self:AddNetHandler(17501, self.On17501)
    self:AddNetHandler(17502, self.On17502)
    self:AddNetHandler(17503, self.On17503)
    self:AddNetHandler(17504, self.On17504)
    self:AddNetHandler(17505, self.On17505)
    self:AddNetHandler(17506, self.On17506)
end

-- 添加邀请人
function ShareManager:Send17500(key)
	self:Send(17500, {key = key})
end

function ShareManager:On17500(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
	self.model:OnLevelUp()
end

-- 申请邀请码
function ShareManager:Send17501()
	self:Send(17501, {})
end

function ShareManager:On17501(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 推广信息
function ShareManager:Send17502()
	self:Send(17502, {})
end

function ShareManager:On17502(dat)
	self.shareData:SetData(dat)
	EventMgr.Instance:Fire(event_name.share_info_update)
	self.model:OnLevelUp()
	if (self.shareData.key == "" and RoleManager.Instance.RoleData.lev >= 50)
		or (self.shareData.key ~= "" and (self.shareData:ShipCount() >= 2 or self:CheckTime())) then
		self:Send17501()
	end
end

-- 推广关系更新(无则添加,有则更新)
function ShareManager:Send17503()
	self:Send(17503, {})
end

function ShareManager:On17503(dat)
	self.shareData:UpdateShips(dat)
	EventMgr.Instance:Fire(event_name.share_info_update)
	self.model:OnLevelUp()
end

-- 领取奖励
function ShareManager:Send17504(gain_id)
	self:Send(17504, {gain_id = gain_id})
end

function ShareManager:On17504(dat)
	NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 奖励信息
function ShareManager:Send17505()
	self:Send(17505, {})
end

function ShareManager:On17505(dat)
	self.gainList = {}
	for i,v in ipairs(dat.gain_list) do
		self.gainList[v.gain_id] = v
	end
	self.model:OnLevelUp()
	EventMgr.Instance:Fire(event_name.share_reward_update)
end

-- 分享奖励
function ShareManager:Send17506()
	self:Send(17506, {})
end

function ShareManager:On17506()
end
-- -----------------------------------
-- -----------------------------------
function ShareManager:IsOpen()
	-- return self:CheckPlatform() and Application.platform ~= RuntimePlatform.Android
	return Application.platform ~= RuntimePlatform.Android
end

function ShareManager:CheckPlatform()
	local platform = RoleManager.Instance.RoleData.platform
	return platform == "ios" or platform == "local" or platform == "dev"
end

function ShareManager:CheckTime()
	local lastTime = self.shareData.key_time

	return os.date("%Y-%m-%d", lastTime) ~= os.date("%Y-%m-%d", BaseUtils.BASE_TIME)
end