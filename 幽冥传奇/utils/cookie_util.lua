
CookieWrapper = CookieWrapper or BaseClass()

CookieVersion = 1
CookieAccountInfo = "AccountInfo"
CookieRoleInfo = "RoleInfo"


-- 层次类型
CookieLevelType = {
	Common = 1,
	Account = 2,
	Role = 3
}

-- 时间类型
CookieTimeType = {
	TYPE_DAY = 1,
	TYPE_ALWAYS = 2,
}

-- key值
CookieKey = {
	MALL_NO_PROMPT 						= "MallNoPrompt",
	QUICK_BUY_NO_PROMPT 				= "QuickBuyNoPrompt",
	SOUL_COOL_DOWN_NO_PROMPT 			= "SoulCoolDownNoPrompt",
	UPBONE_NO_PROMPT 					= "UpboneNoPrompt",
	ANQI_UP_STAGE_NO_PROMPT 			= "AnqiUpStageNoPrompt",
	ANQI_UP_SKILL_NO_PROMPT 			= "AnqiUpSkillNoPrompt",
	FORMULA_ITEM_COMPOSE 				= "FormulaItemCompose",
	BUILD_QUICK_BUY_NO_PROMPT 			= "BuildQuickBuyNoPrompt",
	FLOWER_BUY_NO_PROMPT 				= "FLOWERBUYNOPROMPT",
	BUILD_IDENTIFY_NO_PROMPT 			= "BuildIdentifyNoPrompt",
	BUILD_IDENTIFY_REPLACE_NO_PROMPT 	= "BuildIdentifyReplaceNoPromt",	
	BUILD_JICHENG_NO_PROMPT 			= "BuildJichengNoPrompt",		
	TASK_FAST_FINISH_NO_PROMPT 			= "TaskFastFinishNoPrompt",
	ANCIENT_TASK_FAST_FINISH_NO_PROMPT 	= "AncientTaskFastFinishNoPrompt",
	RELIVE_NO_PROMPT 					= "reliveNoPrompt",

	BAG_MONEY_LOG 						= "bag_money_log",
	RELIVE_NO_PROMPT 					= "reliveNoPrompt",
	STAR_TASK_FAST_FINISH_NO_PROMPT 	= "StarTaskFastFinishNoPrompt",

	HANG_DATA_COOKIE 					= "hang_data_cookie",

	FUBEN_GRADE_COOKIE 					= "fuben_grade_cookie",

	SETTING_COOKIE						= "setting_cookie",

	PETSKILL_FREE_REFRESH				= "petskill_free_refresh",

	MARKET_BUY_GOOD     				= "market_buy_good",

	PORTABLESHOP_SELL_NO_PROMPT 		= "PortableShopSellNoPrompt",

	AUTO_DEL_MAIL_AFTER_DRAG            = "auto_del_mail_after_drag",

	VIP_CARD_BUY                        = "vip_card_buy",

	COIN_CARD_BUY                       = "coin_card_buy",

	TRUMPET_NO_PROMPT                   = "trumpet_no_prompt",

	TASK_REREUN_TIP_NO_PROMPT           = "task_rerun_tip_no_prompt",

	ARENA_LOOK_FIGHT					= "arena_look_fight",

	PUT_GOOD_TO_GUILD					= "put_good_to_guild",
	SKILL_AUTO_USE						= "skill_auto_use",

	TREASURE_MAP_GIVE_UP  				= "treasuremap_give_up",

	SPECIAL_STONE_CONVER_TIP  			= "special_stone_conver_tip",
}

function CookieWrapper:__init()
	if CookieWrapper.Instance ~= nil then
		Error("CookieWrapper has been created.")
	end
	CookieWrapper.Instance = self
	
	--[[self.cookie_root_path = Game.System:GetCookiePath()	
	self.account_info_path = self.cookie_root_path .. "account_info/"

	self:InitCommonValue()
	
	self.account_info_init = false
	self.account_name = ""

	self.role_info_init = false
	self.role_name = ""
	--]]
	
end

function CookieWrapper:InitCommonValue()
	--[[Game.System:LoadCookie("LoginInfo", nil)

	Game.System:LoadCookie("Common", nil)
	if not Cookies["Common"] then
		Cookies["Common"] = {}
	end

	local now_version = Cookies["Common"]["__Version"]
	if not now_version or now_version ~= CookieVersion then
		Cookies["Common"] = {}
		Cookies["Common"]["__Version"] = CookieVersion
	end

	self:ClearOverdueItem(Cookies["Common"])
	--]]
end

function CookieWrapper:InitAccountValue(account_name)
	--[[if not account_name then
		return
	end

	self.account_name = account_name
	Game.System:LoadCookie(self.account_name, self.account_info_path)

	if not Cookies[CookieAccountInfo] then
		Cookies[CookieAccountInfo] = {}
	end

	if not Cookies[CookieAccountInfo][self.account_name] then
		Cookies[CookieAccountInfo][self.account_name] = {}
	end

	local now_version = Cookies[CookieAccountInfo][self.account_name]["__Version"]
	if not now_version or now_version ~= CookieVersion then
		Cookies[CookieAccountInfo][self.account_name] = {}
		Cookies[CookieAccountInfo][self.account_name]["__Version"] = CookieVersion
	end

	if not Cookies[CookieAccountInfo][self.account_name]["Common"] then
		Cookies[CookieAccountInfo][self.account_name]["Common"] = {}
	end

	self:ClearOverdueItem(Cookies[CookieAccountInfo][self.account_name]["Common"])
	self.account_info_init = true
	--]]
end

function CookieWrapper:InitRoleValue(role_name)
	--[[if not self.account_info_init then
		return
	end

	self.role_name = role_name

	if not Cookies[CookieAccountInfo][self.account_name][CookieRoleInfo] then
		Cookies[CookieAccountInfo][self.account_name][CookieRoleInfo] = {}
	end

	if not Cookies[CookieAccountInfo][self.account_name][CookieRoleInfo][self.role_name] then
		Cookies[CookieAccountInfo][self.account_name][CookieRoleInfo][self.role_name] = {}
	end

	self:ClearOverdueItem(Cookies[CookieAccountInfo][self.account_name][CookieRoleInfo][self.role_name])
	self.role_info_init = true
	--]]
end

function CookieWrapper:SaveCookie(level_type, cache_type, key, value)
	--[[if not level_type or not cache_type or not key or not value then
		print ("SaveCookie Item Error!", level_type, cache_type, key, value)
		return
	end

	local item = {}

	local date = {}
	date.year, date.month, date.day = TimeUtil.GetDate()

	item.value = value
	item.time_type = cache_type
	item.date = date

	if level_type == CookieLevelType.Common then
		Cookies["Common"][key] = item
	elseif level_type == CookieLevelType.Account then
		if self.account_info_init then
			Cookies[CookieAccountInfo][self.account_name]["Common"][key] = item
		end
	elseif level_type == CookieLevelType.Role then
		if self.role_info_init then
			Cookies[CookieAccountInfo][self.account_name][CookieRoleInfo][self.role_name][key] = item
		end
	end
	--]]
end

function CookieWrapper:GetCookie(level_type, key)
	--[[if not level_type or not key then
		print ("SaveCookie Item Error!", level_type, key)
		return
	end

	local handle_item = nil
	if level_type == CookieLevelType.Common then
		handle_item = Cookies["Common"][key]
	elseif level_type == CookieLevelType.Account then
		if self.account_info_init then
			handle_item = Cookies[CookieAccountInfo][self.account_name]["Common"][key]
		end
	elseif level_type == CookieLevelType.Role then
		if self.role_info_init then
			handle_item = Cookies[CookieAccountInfo][self.account_name][CookieRoleInfo][self.role_name][key]
		end
	end

	if handle_item then
		return handle_item.value
	end
	--]]
end

function CookieWrapper:ClearOverdueItem(handle_table)
	--[[local del_arr = {}

	local year, month, day = TimeUtil.GetDate()

	for key, item in pairs(handle_table) do
		if type(item) == "table" and item.time_type ~= CookieTimeType.TYPE_ALWAYS and 
				item.date.day ~= day then
			table.insert(del_arr, key)
		end
	end

	for _, key in pairs(del_arr) do
		handle_table[key] = nil
	end--]]
end

function CookieWrapper:__delete()
	-- 将窗口大小额外存入
	--[[Cookies["Common"]["MaxSize"] = 0
	Cookies["Common"]["FullScreen"] = 0
	Cookies["Common"]["WinWidth"] = 1024
	Cookies["Common"]["WinHeight"] = 768

	local view_mode = SettingCtrl.Instance:GetData(SettingDataType.ViewMode)
	if view_mode == ViewModeType.MaxSizeWin then
		Cookies["Common"]["MaxSize"] = 1
	elseif view_mode == ViewModeType.FullScreen then
		Cookies["Common"]["FullScreen"] = 1
	else
		local width = 1024
		local height = 768

		local partten = "(%d+)*(%d+)"
		local mode_str = ViewModeType[data_value]
		if mode_str then
			_, _, width, height = string.find(mode_str, partten)
		end
		
		Cookies["Common"]["WinWidth"] = width
		Cookies["Common"]["WinHeight"] = height
		
	end

	-- 写通用信息
	Game.System:WriteSingleCookie("LoginInfo", "LoginInfo", nil)
	Game.System:WriteSingleCookie("Common", "Common", nil)
	if self.account_name ~= nil then
		Game.System:WriteSingleCookie(self.account_name, 
			CookieAccountInfo .. "." .. self.account_name, self.account_info_path)
	end
	--]]
end
