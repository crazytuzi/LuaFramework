
BuffTipView = BuffTipView or BaseClass(XuiBaseView)
function BuffTipView:__init()
	self.config_tab = {
		{"itemtip_ui_cfg", 3, {0}}
	}

	self.InitCamouflageList()
end

function BuffTipView:__delete()
end

function BuffTipView:CloseCallBack()
	self:ClearTimer()
end

function BuffTipView:ReleaseCallBack()
	self:ClearTimer()
end

function BuffTipView:OnFlush(param_t, index)
	self.data = param_t.all
	if nil == self.data or not next(self.data) then
		return
	end

	self.node_t_list.text_buff_name.node:setString(self.data[1].buff_name)
	local cfg = MainuiHeadBar.GetBuffCfg(self.data[1].buff_id)
	local icon = cfg and cfg.icon or 99
	self.node_t_list.img_icon.node:loadTexture(ResPath.GetBuff(icon))

	self:RefreshDesc()
	if self.data[1].buff_time and self.data[1].buff_time > 0 and nil == self.cd_timer then
		self.cd_timer = GlobalTimerQuest:AddTimesTimer(BindTool.Bind(self.RefreshDesc, self), 1, 
			math.floor(self.data[1].buff_time - Status.NowTime) + 2)
	end
end

function BuffTipView.InitCamouflageList()
	if not BuffTipView.CamouflageList then
		BuffTipView.CamouflageList = {
			[45] = {func = BuffTipView.GetCamouflageVIPBuff, params = nil},
			[46] = {func = BuffTipView.GetCamouflageGuildBuff, params = nil},
			[47] = {func = BuffTipView.GetCamouflageSoulBuff, params = nil},
			[48] = {func = BuffTipView.GetCamouflageZJBuff, params = nil},
			[49] = {func = BuffTipView.GetCamouflageCircleBuff, params = nil},

			[38] = {func = BuffTipView.GetCamouflageHeadtitleBuff, params = 42},
			[39] = {func = BuffTipView.GetCamouflageHeadtitleBuff, params = 44},
			[40] = {func = BuffTipView.GetCamouflageHeadtitleBuff, params = 43},
			[41] = {func = BuffTipView.GetCamouflageHeadtitleBuff, params = 34},
			-- [42] = {func = BuffTipView.GetCamouflageHeadtitleBuff, params = 2},
			-- [43] = {func = BuffTipView.GetCamouflageHeadtitleBuff, params = 3},
			[44] = {func = BuffTipView.GetCamouflageHeadtitleBuff, params = 33},

			[332] = {func = BuffTipView.GetCamouflageHeadtitleBuff, params = 47},
			[333] = {func = BuffTipView.GetCamouflageHeadtitleBuff, params = 48},
			[334] = {func = BuffTipView.GetCamouflageHeadtitleBuff, params = 49},
		}
	end
end

local fake_time_buff = {
	[332] = 1,
	[333] = 2,
	[334] = 3,

}

function BuffTipView:RefreshDesc()
	if nil == self.data or not next(self.data) then
		return
	end

	self.node_t_list.rich_buff_dec.node:removeAllElements()
	local is_show_time = true
	local text_desc = ""
	for i, v in ipairs(self.data) do
		text_desc = ""
		if BuffTipView.CamouflageList[v.buff_id] then
			local temp = BuffTipView.CamouflageList[v.buff_id]
			if not temp.func then
				ErrorLog("[fake buff func is nil]  buff_id: " .. buff_id .. "!")
			else
				local camouflage_buff_data = BuffTipView.GetGroupAttrs(temp.func(temp.params))
				if camouflage_buff_data then
					for k,v in pairs(camouflage_buff_data) do
						text_desc = text_desc .. (BuffTipView.GetBuffAttrText(v) or "")
					end
				end
			end
			is_show_time = false

		elseif v.buff_type == 93 then
			text_desc = string.format(Language.Role.BuffXinShou, COMMON_CONSTS.XIN_SHOU_LEVEL)
			text_desc = text_desc .. "\n" .. "\n"
		elseif v.buff_type == 63 then
			text_desc = Language.Role.BuffYinshen
			text_desc = text_desc .. "\n" .. "\n"
		elseif v.buff_type == 54 then
			text_desc = Language.Role.BuffLingDun
			text_desc = text_desc .. "\n" .. "\n"
		elseif v.buff_type == 139 then
			is_show_time = false
			if nil ~= StdBuff then
				local cfg = nil
				for k,buff_cfg in pairs(StdBuff) do
					if buff_cfg.id and v.buff_id and buff_cfg.id == v.buff_id then
						cfg = buff_cfg
						break
					end
				end
				if nil ~= cfg then
					text_desc = string.format(Language.Role.BuffXueLian, cfg.param or 0, cfg.param2 or 0, self.data[1].buff_time or 0)
				end
			end
		else
			if nil ~= Language.Role.BuffAttrName[v.buff_type] then
				if v.buff_value > 0 then
					text_desc = Language.Role.BuffAttrName[v.buff_type] .. " +"
				else
					text_desc = Language.Role.BuffAttrName[v.buff_type] .. " "
				end
				if RoleData.IsFloatAttr(v.buff_type) then
					text_desc = text_desc .. v.buff_value * 100 .. "%\n"
				elseif RoleData.IsTenThousandPerAttr(v.buff_type) then
					text_desc = text_desc .. v.buff_value  / 100 .. "%\n"
				else
					text_desc = text_desc .. v.buff_value .. "\n"
				end
			end
		end

		if v.buff_id == 50 then
			self.node_t_list.text_buff_name.node:setString(v.name)
			text_desc = Language.Role.BuffAttrName[6].." 30%\n"..Language.Role.BuffAttrName[8].." 15%\n"..
			Language.Role.BuffAttrName[24].." 20%\n"..Language.Role.BuffAttrName[28].." 20%"
		end

		if v.buff_attr_list then
			local buff_group = BuffTipView.GetGroupAttrs(v.buff_attr_list)
			if buff_group then
				for k1,v1 in pairs(buff_group) do
					text_desc = text_desc .. (BuffTipView.GetBuffAttrText(v1) or "")
				end
			end	
		end

		if "" ~= text_desc then
			XUI.RichTextAddText(self.node_t_list.rich_buff_dec.node, text_desc)
		end
	end

		--特权卡显示剩余时间
	if nil ~= fake_time_buff[self.data[1].buff_id] then
		is_show_time = true
	end

	--大于24小时显示天数
	local text_time = ""
	if self.data[1].buff_time and self.data[1].buff_time >= 86400 then
		text_time = Language.Common.RemainTime .. ": " .. TimeUtil.FormatSecond2Str(self.data[1].buff_time - Status.NowTime)
	elseif self.data[1].buff_time then
		text_time = Language.Common.RemainTime .. ": " .. TimeUtil.FormatSecond2HMS(self.data[1].buff_time - Status.NowTime)
	end

	if is_show_time and self.data[1].buff_time and self.data[1].buff_time > 0 then
		XUI.RichTextAddText(self.node_t_list.rich_buff_dec.node, text_time, nil, nil, COLOR3B.GREEN)
	else
		self:ClearTimer()
	end
end

function BuffTipView:ClearTimer()
	if nil ~= self.cd_timer then
		GlobalTimerQuest:CancelQuest(self.cd_timer)
		self.cd_timer = nil
	end
end



---------------------------------
-- Camouflage buff's data
---------------------------------
BuffTipView.GroupAttrList = {
	[1009] = 1,
	[1013] = 1,
	[1017] = 1,
	[1021] = 1,
	[1025] = 1,
}

function BuffTipView.GetGroupAttrs(data)
	if not data or type(data) ~= "table" then return end

	local attrs_list = {}
	local temp_list = {}
	local prof = RoleData.Instance:GetRoleBaseProf()
	for k,v in pairs(BuffTipView.GroupAttrList) do
		temp_list[k] = {}
	end

	for k,v in pairs(data) do
		if v.type and tonumber(v.type) and (prof == v.job or nil == v.job) then
			if BuffTipView.GroupAttrList[tonumber(v.type) + 1000] then
				if temp_list[tonumber(v.type) + 1000] then temp_list[tonumber(v.type) + 1000][1] = v end
			elseif BuffTipView.GroupAttrList[tonumber(v.type) - 2 + 1000] then
				if temp_list[tonumber(v.type) - 2 + 1000] then temp_list[tonumber(v.type) - 2 + 1000][2] = v end
			else
				table.insert(attrs_list, v)
			end
		end
	end

	for k,v in pairs(temp_list) do
		if v[1] and v[2] then
			local t = {type = k, value = {v[1].value or 0, v[2]. value or 0}}
			table.insert(attrs_list, t)
		elseif v[1] then
			table.insert(attrs_list, v[1])
		elseif v[2] then
			table.insert(attrs_list, v[2])
		end
	end

	table.sort(attrs_list, function(a, b)
		local type_a = tonumber(a.type) and tonumber(a.type) % 1000
		local type_b = tonumber(b.type) and tonumber(b.type) % 1000
		if not type_a or not type_b then return false end

		return type_a < type_b
	end)
	return attrs_list
end

function BuffTipView.GetBuffAttrText(attr_data)
	local text_desc = ""
	if nil ~= Language.Role.BuffAttrName[attr_data.type] then
		if type(attr_data.value) == "table" then
			if not tonumber(attr_data.type) then return "" end
			text_desc = Language.Role.BuffAttrName[attr_data.type] .. " "
			if RoleData.IsFloatAttr(attr_data.type % 1000) then
				text_desc = text_desc .. attr_data.value[1] * 100 .. "%" .. "-" .. attr_data.value[2] * 100 .. "%\n"
			elseif RoleData.IsTenThousandPerAttr(attr_data.type % 1000) then
				text_desc = text_desc .. attr_data.value[1]  / 100 .. "%" .. "-" .. attr_data.value[2]  / 100 .. "%\n"
			else
				text_desc = text_desc .. attr_data.value[1] .. "-" .. attr_data.value[2] .. "\n"
			end
		else
			if attr_data.value > 0 then
				text_desc = Language.Role.BuffAttrName[attr_data.type] .. " +"
			else
				text_desc = Language.Role.BuffAttrName[attr_data.type] .. " "
			end

			if RoleData.IsFloatAttr(attr_data.type) then
				text_desc = text_desc .. attr_data.value * 100 .. "%\n"
			elseif RoleData.IsTenThousandPerAttr(attr_data.type) then
				text_desc = text_desc .. attr_data.value  / 100 .. "%\n"
			else
				text_desc = text_desc .. attr_data.value .. "\n"
			end
		end
	end

	return text_desc
end

function BuffTipView.GetCamouflageGuildBuff()
	local guild_level = GuildData.Instance and GuildData.Instance:GetGuildInfo()
		and GuildData.Instance:GetGuildInfo().cur_guild_level
	local cfg = GuildConfig and GuildConfig.guildLevel
	if not guild_level or guild_level <= 0 or not cfg or not cfg[guild_level] then return end

	return cfg[guild_level].guildLevelWelfare
end

function BuffTipView.GetCamouflageSoulBuff()
	local cfg = SavvySysCfg and SavvySysCfg.soulLayers
	local grade, level = BossData.GetSoulLevel()
	if not cfg or grade <= 0 or not cfg[grade] or not cfg[grade][level] then return end

	local prof = RoleData.Instance:GetRoleBaseProf()
	local addAttrs = cfg[grade][level].addAttrs
	if not addAttrs or not prof or not addAttrs[prof] then return end

	return addAttrs[prof]
end

function BuffTipView.GetCamouflageCircleBuff()
	local prof = RoleData.Instance:GetRoleBaseProf()
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	if not prof or not circle then return end
	local cfg_path = "scripts/config/server/config/vocation/circleAddProp/prop" .. prof
	local cfg = require(cfg_path)

	if circle > #cfg then circle = #cfg end

	return cfg[circle]
end


function BuffTipView.GetCamouflageZJBuff()
	local zhu_data, fu_data = ZhanjiangData.Instance:GetHeroAttrData()
	if not fu_data or type(fu_data) ~= "table" or #fu_data <= 0 then return end

	local data = {}
	for k,v in pairs(fu_data) do
		if tonumber(v.type) then
			table.insert(data, {type = v.type, value = v.value})
			if v.value_r then
				table.insert(data, {type = v.type + 2, value = v.value_r})
			end
		end
	end

	return data
end

function BuffTipView.GetCamouflageVIPBuff()
	local vip_level = VipData.Instance.vip_level or 0
	local cfg = VipData.GetVipGradeCfgByLevel(vip_level)
	if not cfg or not cfg.attrcalc then return end

	return cfg.attrcalc
end

function BuffTipView.GetCamouflageHeadtitleBuff(title_id)
	if not title_id then return end
	local cfg_path = "scripts/config/server/config/rank/headTitle/headTitle" .. title_id
	local cfg = require(cfg_path)
	if not cfg or not cfg[1] or not cfg[1].staitcAttrs then return end

	return cfg[1].staitcAttrs
end