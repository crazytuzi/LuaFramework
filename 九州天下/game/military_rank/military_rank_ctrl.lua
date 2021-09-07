require("game/military_rank/military_rank_view")
require("game/military_rank/military_rank_data")
require("game/military_rank/military_rank_cell")
require("game/military_rank/military_rank_decree_view")

MilitaryRankCtrl = MilitaryRankCtrl or BaseClass(BaseController)
function MilitaryRankCtrl:__init()
	if MilitaryRankCtrl.Instance ~= nil then
		print_error("[MilitaryRankCtrl] attempt to create singleton twice!")
		return
	end
	MilitaryRankCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = MilitaryRankView.New(ViewName.MilitaryRank)
	self.data = MilitaryRankData.New()

	-- 圣旨界面
	self.decree_view = DecreeView.New(ViewName.DecreeView)
	self.is_first = true
	RemindManager.Instance:Register(RemindName.JunXian, BindTool.Bind(self.GetJunXianRemind, self))
end

function MilitaryRankCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	self.decree_view:DeleteMe()
	self.decree_view = nil

	MilitaryRankCtrl.Instance = nil
	self.is_first = true
	RemindManager.Instance:UnRegister(RemindName.JunXian)
end

function MilitaryRankCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCJunXianInfo, "OnSCJunXianInfo")
	self:RegisterProtocol(SCJunXianUplevelResult, "OnSCJunXianUplevelResult")
end

-- 请求军衔信息
function MilitaryRankCtrl:SendAllInfoRequest()
	local protocol = ProtocolPool.Instance:GetProtocol(CSJunXianGetInfo)
	protocol:EncodeAndSend()
end

-- 请求升级
function MilitaryRankCtrl:SendUpStarRequest()
	local protocol = ProtocolPool.Instance:GetProtocol(CSJunXianUpStarReq)
	protocol:EncodeAndSend()
end

function MilitaryRankCtrl:OnSCJunXianInfo(protocol)
	local add_jungong = protocol.jungong - self.data:GetCurJunGong()
	if not self.is_first and add_jungong > 0 then
		TipsCtrl:ShowFloatingLabel(string.format(Language.SysRemind.AddJunGong, add_jungong))
	end

	local cur_level = self.data:GetCurLevel()
	self.data:SetSCJunXianInfo(protocol)
	if cur_level == nil or cur_level ~= protocol.jx_level then
		local main_role = Scene.Instance:GetMainRole()
		if main_role then
			main_role:ReloadUIName()
		end
	end
	self.view:Flush()
	if self.is_first then
		self.is_first = false
		GlobalEventSystem:Fire(MainUIEventType.JUNXIAN_LEVEL_CHANGE)		
	end
	RemindManager.Instance:Fire(RemindName.JunXian)
	RemindManager.Instance:Fire(RemindName.ShenJiSkill)
end

function MilitaryRankCtrl:OnSCJunXianUplevelResult(protocol)
	local last_level = MilitaryRankData.Instance:GetCurLevel()
	self.data:SetSCJunXianUplevelResult(protocol)
	self.view:Flush()
	if last_level < protocol.jx_level then
		self:OpenDecreeView(DECREE_SHOW_TYPE.UPLEVEL)
		GlobalEventSystem:Fire(MainUIEventType.JUNXIAN_LEVEL_CHANGE)
	end
end

function MilitaryRankCtrl:GetJunXianRemind()
	local falg = 0
	local cur_level = MilitaryRankData.Instance:GetCurLevel()
	local max_level = #MilitaryRankData.Instance:GetLevelCfg()
	local cur_star = MilitaryRankData.Instance:GetCurStar()
	local max_star = #MilitaryRankData.Instance:GetStarCfg()
	local cur_jungong = MilitaryRankData.Instance:GetCurJunGong()
	if cur_level < max_level then
		local level_cfg = MilitaryRankData.Instance:GetLevelSingleCfg(cur_level + 1)
		if level_cfg and cur_jungong >= level_cfg.need_jungong then
			falg = 1
		end
	elseif cur_star < max_star then
		local star_cfg = MilitaryRankData.Instance:GetStarSingleCfg(cur_star + 1)
		if star_cfg and cur_jungong >= star_cfg.need_jungong then
			falg = 1
		end
	end
	return falg
end

function MilitaryRankCtrl:OpenDecreeView(open_type, show_data)
	self.decree_view:SetOpenType(open_type, show_data)
	self.decree_view:Open()
end