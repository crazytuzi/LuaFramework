------------------------------------------------------
--cocos2d动画编辑工具，由策划提供动画配置，程序主动生成
--目的为提高策划的自主性，减少程序与策划沟通成本，即让策划折腾去吧~
--动作类型：
--fadein：渐现 						参数：time
--fadeout: 渐隐 					参数：time
--delay：延迟执行					参数: time
--place: 放置到一个位置(瞬时动作) 	参数：x,y
--moveto:移动到某个位置				参数：time,x,y
--moveby:偏移到某个位置 			参数：time,offest_x,offest_y
--scaleto：缩放						参数：time,scale_x,scale_y
--sequence:连续动作					参数:（act1,act2...)
--spawn:同时发生的动作				参数:（act1,act2...)
--repeatforever:重复（仅用于sequence，spawn）

--@author bzw
------------------------------------------------------
CCActionEdit = CCActionEdit or BaseClass()
function CCActionEdit:__init()
	if CCActionEdit.Instance ~= nil then
		Error("CCActionEdit has been created.")
	end
	CCActionEdit.Instance = self
	self.actcfg_list = Config.ccaction_edit_auto.action_list
	self.act_list = {}
	self.dynamic_param_list = {}
end

function CCActionEdit:__delete()
	self.act_list = {}
end

function CCActionEdit:CreateCCAction(act_name, dp1, dp2, dp3, dp4, dp5, dp6, dp7)
	self.act_list = {}
	self.dynamic_param_list = {}
	self.dynamic_param_list.dp1 = dp1 
	self.dynamic_param_list.dp2 = dp2 
	self.dynamic_param_list.dp3 = dp3
	self.dynamic_param_list.dp4 = dp4
	self.dynamic_param_list.dp5 = dp5
	self.dynamic_param_list.dp6 = dp6 
	self.dynamic_param_list.dp7 = dp7

	local cfg = self.actcfg_list[act_name]
	if cfg == nil then return nil end

	local end_act = self:ParseAction(cfg)
	self.act_list = {}
	return end_act
end

function CCActionEdit:ParseAction(cfg)
	if cfg == nil then return nil end

	local end_act = nil
	for k,v in pairs(cfg) do
		local i, j = string.find(v, "=") --生成定义的新变量
		if i ~= nil and j ~= nil then
			local var_name = string.sub(v, 1, i - 1)
			local expression = string.sub(v, i + 1, #v)
			self.dynamic_param_list[var_name] = self:ReplaceValue(expression)
		else
			--分析动作
			local act_id, act = self:ParseCCAction(v)
			if act ~= nil then
				self.act_list[act_id] = act
				end_act = act
			else
				Log("error::CCActionEdit:ParseAction....", v)
			end
		end
	end
	return end_act
end

function CCActionEdit:ParseCCAction(act_str)
	if act_str == nil then return end

	--解析括号里的参数
	local act_param_t = {}
	local i, _ = string.find(act_str, "%(" .. "(.-)" .. "%)")
	local j = #act_str
	if i ~= nil and j ~= nil then
		local act_param_str = string.sub(act_str, i + 1, j - 1)
		act_param_t = Split(act_param_str, ",")
		for k,v in pairs(act_param_t) do
			act_param_t[k] = self:ReplaceValue(v)
		end
	end

	--解析动作名字
	act_str = string.gsub(act_str, "%(".. "(.-)" .."%)", "")
	local m,n = string.find(act_str, "#")
	if m ~= nil and n ~= nil then
		local act_id = tonumber(string.sub(act_str, 1, m - 1)) --动作id
		local act_type = string.sub(act_str, m + 1, i - 1) 	   --动作类型

		local is_ease_type = false --是否是缓动类型
		i, j = string.find(act_type, "Ease")
		if i ~= nil and j ~= nil then is_ease_type = true end
		
		if act_type == "Sequence" or act_type == "Spawn" or act_type == "RepeatForever" or is_ease_type then
			return act_id, self:GetMergeAction(act_type, act_param_t)

		elseif act_type == "MoveBy" or act_type == "MoveTo" then
			return act_id, cc[act_type]:create(act_param_t[1], cc.p(act_param_t[2], act_param_t[3]))
		elseif act_type == "Place" then
			return act_id, cc[act_type]:create(cc.p(act_param_t[1], act_param_t[2]))
		elseif act_type == "Show" or act_type == "Hide" then
			return act_id, cc[act_type]:create()
		else
			return act_id, self:GetAction(act_type, act_param_t)
		end
	end

end

function CCActionEdit:GetAction(act_type, act_param_t)
	if cc[act_type] == nil then return end

	if #act_param_t == 1 then return cc[act_type]:create(act_param_t[1]) end
	if #act_param_t == 2 then return cc[act_type]:create(act_param_t[1], act_param_t[2]) end
	if #act_param_t == 3 then return cc[act_type]:create(act_param_t[1], act_param_t[2], act_param_t[3]) end
	if #act_param_t == 4 then return cc[act_type]:create(act_param_t[1], act_param_t[2], act_param_t[3], act_param_t[4]) end
	if #act_param_t >= 5 then return cc[act_type]:create(act_param_t[1], act_param_t[2], act_param_t[3], act_param_t[4], act_param_t[5]) end
end

function CCActionEdit:GetMergeAction(act_type, act_param_t)
	if cc[act_type] == nil then return end

	if #act_param_t == 1 then return cc[act_type]:create(self.act_list[act_param_t[1]]) end
	if #act_param_t == 2 then return cc[act_type]:create(self.act_list[act_param_t[1]], self.act_list[act_param_t[2]]) end
	if #act_param_t == 3 then return cc[act_type]:create(self.act_list[act_param_t[1]], self.act_list[act_param_t[2]], self.act_list[act_param_t[3]]) end
	if #act_param_t == 4 then return cc[act_type]:create(self.act_list[act_param_t[1]], self.act_list[act_param_t[2]], self.act_list[act_param_t[3]], self.act_list[act_param_t[4]]) end
	if #act_param_t == 5 then return cc[act_type]:create(self.act_list[act_param_t[1]], self.act_list[act_param_t[2]], self.act_list[act_param_t[3]], self.act_list[act_param_t[4]], self.act_list[act_param_t[5]]) end
	if #act_param_t == 6 then return cc[act_type]:create(self.act_list[act_param_t[1]], self.act_list[act_param_t[2]], self.act_list[act_param_t[3]], self.act_list[act_param_t[4]], self.act_list[act_param_t[5]], self.act_list[act_param_t[6]]) end
	if #act_param_t == 7 then return cc[act_type]:create(self.act_list[act_param_t[1]], self.act_list[act_param_t[2]], self.act_list[act_param_t[3]], self.act_list[act_param_t[4]], self.act_list[act_param_t[5]], self.act_list[act_param_t[6]], self.act_list[act_param_t[7]]) end
	if #act_param_t >= 8 then return cc[act_type]:create(self.act_list[act_param_t[1]], self.act_list[act_param_t[2]], self.act_list[act_param_t[3]], self.act_list[act_param_t[4]], self.act_list[act_param_t[5]], self.act_list[act_param_t[6]], self.act_list[act_param_t[7]], self.act_list[act_param_t[8]]) end

	return nil
end

function CCActionEdit:ReplaceValue(value)
	local dynamic_p = self.dynamic_param_list[value]
	if dynamic_p ~= nil then
		return dynamic_p
	end

	if value == "true" then
		return true
	end

	if value == "false" then
		return false
	end


	while true do
		local is_break = true
		for _pn,_pv in pairs(self.dynamic_param_list) do
			value = string.gsub(value, _pn, _pv)
			local i, j = string.find(value, _pn)
			if i ~= nil and j ~= nil then
				is_break = false
			end
		end

		if is_break then
			break
		end
	end

	return GameMath.CalcExpression(value)
end
