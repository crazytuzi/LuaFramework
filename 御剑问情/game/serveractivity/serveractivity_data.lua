ServerActivityData = ServerActivityData or BaseClass()

function ServerActivityData:__init()
	if ServerActivityData.Instance ~= nil then
		ErrorLog("[ServerActivityData] Attemp to create a singleton twice !")
	end
	ServerActivityData.Instance = self

	self.rand_act_zhuanfu_type = 1
end

function ServerActivityData:__delete()
	ServerActivityData.Instance = nil
end

function ServerActivityData:SetServerSystemInfo(protocol)
	self.rand_act_zhuanfu_type = protocol.param1
	-- local is_enforce_cfg = GLOBAL_CONFIG.param_list.is_enforce_cfg or 0
	-- if is_enforce_cfg == 1 then
	-- 	self.rand_act_zhuanfu_type = 1
	-- elseif is_enforce_cfg == 2 then
	-- 	self.rand_act_zhuanfu_type = 2
	-- end
end

--服务器在不同阶段有不同的奖励配置表，用这个方法来读相应的配置表
function ServerActivityData:GetCurrentRandActivityConfig()
	return ConfigManager.Instance:GetAutoConfig("randactivityconfig_" .. self.rand_act_zhuanfu_type .. "_auto")
end

function ServerActivityData:GetCurrentRandActivityConfigOtherCfg()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	for i,v in ipairs(self:GetCurrentRandActivityConfig().other) do
		if open_day <= v.opengame_day then
			return v
		end
	end
	return self:GetCurrentRandActivityConfig().other[1]
end

function ServerActivityData:GetCurrentRandActivityRewardCfg(reward_cfg, is_unpack_gift)
	if reward_cfg.item_id ~= nil then
		return self:GetShowRewardListByCfg({reward_cfg}, is_unpack_gift)
	else
		return self:GetShowRewardListByCfg(reward_cfg, is_unpack_gift)
	end
end

--礼包解包
function ServerActivityData:GetShowRewardListByCfg(cfg_list, is_unpack_gift)
	if cfg_list == nil then return nil end

	local show_list = {}
	for k,v in pairs(cfg_list) do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg ~= nil then
			if big_type == GameEnum.ITEM_BIGTYPE_GIF and is_unpack_gift then
				local item_list_in_gift = ItemData.Instance:GetGiftItemList(item_cfg.id)
				for _,item_in_gift in pairs(item_list_in_gift) do
					table.insert(show_list, item_in_gift)
				end
			else
				table.insert(show_list, v)
			end
		end
	end

	return show_list
end

-- --用这个方法来获取跨服活动的配置表
-- function ServerActivityData:GetCrossRandActivityConfig()
-- 	return ConfigManager.Instance:GetAutoConfig("cross_randactivity_cfg_" .. self.rand_act_zhuanfu_type .. "_auto")
-- end