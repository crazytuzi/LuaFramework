local config = {}

config.cam_type = "???"

config.war_keys = {
	current = {name = "当前位置"},
	default ={name="默认"},
	replace = {name = "替换伙伴"}
}

config.home_keys = {
	
}


config.select =
{
	cam_type = {
		{"war", "战斗像机"},
		{"warrior", "战斗角色"},
		{"house", "宅邸"},
		{"createrole_pos", "创角站位"},
		{"createrole_cam", "创角像机"}
	}
}

config.arg = {}


config.arg.template = 
{
	cam_type = {
		name = "类型",
		key = "cam_type",
		select_type = "cam_type",
		default = "war",
		change_refresh = 1,
	},
	key_name = {
		name = "镜头名",
		key = "key_name",
		select_update = function()
			return table.keys(data.cameradata.INFOS[config.cam_type])
		end,
		wrap = function(s)
			local sName
			if config.cam_type == "war" then
				sName = config.war_keys[s] and config.war_keys[s].name or s
			elseif config.cam_type == "house" then
				list = table.keys(data.cameradata.INFOS.house)
			end
			sName = sName or tostring(s)
			return sName
		end,
		force_input = true,
	},
	key_pos = {
		name = "设置位置",
		key = "key_pos",
		select_update = function()
			local list = table.keys(data.cameradata.INFOS[config.cam_type])
			table.sort(list)
			return list
		end,
		wrap = function(s) 
			if config.cam_type == "war" then
				s = config.war_keys[s] and config.war_keys[s].name or s
			elseif config.cam_type == "house" then
				list = table.keys(data.cameradata.INFOS.house)
			elseif config.cam_type == "warrior" then
				s = config.war_keys[s] and config.war_keys[s].name or s
			end
			return s
		end,
		change_refresh = 1,
	},
	focus_on = {
		name = "旋转中心",
		key = "focus_on",
		select = function()
			local keys = table.keys(data.lineupdata.GRID_POS_MAP)
			table.sort(keys)
			return keys
		end,
		change_refresh = 1,
	}

}





-- config.datafunc = {
-- 	stateinfo = function()
-- 			local oCam = CCamera.New(g_CameraCtrl:GetWarCamera())
-- 			local vPos = oCam:GetWorldPos()
-- 			local vRotate = oCam:GetRotation().eulerAngles
-- 			return {pos={x=vPos.x, y=vPos.y, z=vPos.z},
-- 			 rotate={x=vRotate.x, y=vRotate.y, z=vRotate.z},
-- 			}
-- 		end,
-- }

-- config.args = {}
-- config.args.template = {
-- 	type = {
-- 		name = "移动类型",
-- 		select = function() 
-- 			local keylist = table.keys(config.action)
-- 			table.sort(keylist, function(k1, k2)
-- 				return config.action[k1].sort < config.action[k2].sort
-- 			end)
-- 			return keylist
-- 		end,
-- 		wrap = function(k) return config.action[k] end,
-- 		key = "hit",
-- 	}
-- }


-- local action = {}
-- action.AtOnce = {
-- 	name = "立即",
-- 	sort = 1,
-- 	args = {
-- 		{
-- 			wrap_name = "像机状态",
-- 			data_func = "stateinfo",
-- 		}
-- 	}
-- }

-- action.Path = {
-- 	name = "按路径"
-- }
-- config.action = action
return config