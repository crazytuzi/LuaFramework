TipsWorldLevelInfoView = TipsWorldLevelInfoView or BaseClass(BaseView)

function TipsWorldLevelInfoView:__init()
	self.ui_config = {"uis/views/tips/worldlevel", "WorldLevelview"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	 self:SetMaskBg(true)
end

function TipsWorldLevelInfoView:__delete()

end

function TipsWorldLevelInfoView:OpenView()
	self:Open()
	
end

function TipsWorldLevelInfoView:OpenCallBack()
	self:HandleWorld()
end

-- 创建完调用
function TipsWorldLevelInfoView:LoadCallBack()
	self.world_level = self:FindVariable("WorldLevel")
	self.world_level_exp_percent = self:FindVariable("ExpPercent")
	self.world_open_content = self:FindVariable("WorldOpenContent")
	self.sever_level = self:FindVariable("SeverLevel")
	self.role_num = self:FindVariable("RoleNum")
	self.tips_remain = self:FindVariable("RemTips")
	self.open_tips = self:FindVariable("OpenTips")
	self:ListenEvent("CloseWorldLevelTip", BindTool.Bind(self.OnCloseWorldLevelTip, self))
end



function TipsWorldLevelInfoView:ReleaseCallBack()
	self.show_world_level = nil
	self.world_level = nil
	self.world_level_exp_percent = nil
	self.world_open_content = nil
	self.sever_level = nil
	self.role_num = nil
	self.tips_remain = nil
	self.open_tips = nil

end


function TipsWorldLevelInfoView:OnCloseWorldLevelTip()
	self:Close()
end

function TipsWorldLevelInfoView:OnFlush()
	self:HandleWorld()
end



function TipsWorldLevelInfoView:HandleWorld()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local world_level = PlayerData.Instance:GetWorldLevel() or 0
	local exp_add = 0
	if role_level < world_level and role_level >= COMMON_CONSTS.WORLD_LEVEL_OPEN then
		exp_add = COMMON_CONSTS.WORLD_LEVEL_EXP_PERCENT_BASE + (world_level - role_level) * COMMON_CONSTS.WORLD_LEVEL_EXP_PERCENT
		exp_add = (exp_add > COMMON_CONSTS.WORLD_LEVEL_EXP_MAX_PERCENT) and COMMON_CONSTS.WORLD_LEVEL_EXP_MAX_PERCENT * 1 or exp_add
	end
	-- local world_level_befor = math.floor(world_level % 100) ~= 0 and math.floor(world_level % 100) or 100
	-- local world_level_behind = math.floor(world_level % 100) ~= 0 and math.floor(world_level / 100) or math.floor(world_level / 100) - 1
	local world_level_str = string.format(Language.Common.Zhuan_Level, world_level)
	self.world_level:SetValue(world_level_str)

	local exp_color = exp_add > 0 and "00931f" or "ff0000"
	self.world_level_exp_percent:SetValue(string.format("<color=#%s>%s%%</color>", exp_color, exp_add))

	self.world_open_content:SetValue(Language.Common.WorldOpenContent)

	local sever_level_seq, role_num, last_days = PlayerData.Instance:GetServerLevelInfo()
	local sever_level_cfg = PlayerData.Instance:GetSeverLevelCfg(sever_level_seq)
	if sever_level_cfg then
		--self.sever_level:SetValue(string.format(Language.Common.Zhuan_Level, sever_level_cfg.server_level))
		self.sever_level:SetValue(string.format(Language.Common.Zhuan_Level, PlayerData.Instance:GetServerLevel()))
		local max_cfg = PlayerData.Instance:GetSeverMaxLevelCfg()
		if max_cfg and sever_level_cfg.server_level >= max_cfg.server_level then
			self.role_num:SetValue(Language.Guild.GuildLevelMax)
		else
			local num = math.floor((role_num/sever_level_cfg.level_up_need_role_cnt) * 100)
			-- self.role_num:SetValue(math.floor((role_num/sever_level_cfg.level_up_need_role_cnt) * 100) .. "%")

			self.role_num:SetValue(string.format("<color=#%s>%s</color>%%", color, num))
		end
	end
	self.tips_remain:SetValue(last_days)
	self.open_tips:SetValue(Language.Common.WorldLevelContent)
end


