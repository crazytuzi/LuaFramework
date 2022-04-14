--
-- @Author: LaoY
-- @Date:   2019-02-13 19:44:57
--


DebugAttr = DebugAttr or class("DebugAttr",BaseItem)

function DebugAttr:ctor(parent_node,layer)
	self.abName = "main"
	self.assetName = "DebugAttr"
	self.layer = layer

	self.role_update_list = {}
	self.global_event_list = {}

	self.is_show_attr = false
	DebugAttr.super.Load(self)
end

function DebugAttr:dctor()
	if self.role_update_list and self.role_data then
        for k, event_id in pairs(self.role_update_list) do
            self.role_data:RemoveListener(event_id)
        end
        self.role_update_list = nil
    end

    if self.global_event_list then
    	GlobalEvent:RemoveTabListener(self.global_event_list)
    	self.global_event_list = {}
    end
end

function DebugAttr:LoadCallBack()
	self.nodes = {
		"text",
	}
	self:GetChildren(self.nodes)

	-- self:SetPosition(60,60)

	self.text_component = self.text:GetComponent('Text')
	self:AddEvent()
	self:InitMap()

	self:UpdateAttr()
end

local attr_map = {
    -- 输出侧
	-- 基础
	["att"]       = true,  	-- 攻击
	["wreck"]     = true,  	-- 破甲
	["holy_att"]  = true, 	-- 神圣(五行)攻击
	["hit"]       = true,  	-- 命中
	["crit"]      = true,  	-- 暴击
	-- 特殊
	["crit_pro"]  = true, 	-- 暴击几率
	["crit_dmg"]  = true, 	-- 暴击伤害
	["heart_pro"] = true, 	-- 会心几率
	["heart_dmg"] = true, 	-- 会心伤害
	["skill_amp"] = true, 	-- 技能增伤
	["dmg_amp"]   = true, 	-- 伤害加深 amplify

	--生存侧
	-- 基础
    ["hpmax"]     = true,  	-- 生命上限
	["def"]       = true,  	-- 防御
	["miss"]      = true,  	-- 闪避
	["holy_def"]  = true, 	-- 神圣(五行)防御
	["tough"]     = true, 	-- 坚韧
	-- 特殊
	["crit_res"]  = true, 	-- 暴击抵抗 resist
	["skill_red"] = true, 	-- 技能减伤
	["dmg_red"]   = true, 	-- 伤害减免 reduce
	["miss_pro"]  = true, 	-- 闪避几率
	["block_red"] = true, 	-- 技能减伤
	["armor_str"] = true, 	-- 护甲穿透
	["block_pro"] = true, 	-- 格挡几率
	["block_str"] = true, 	-- 格挡穿透
	["pvp_red"] = true, 	-- pvp伤害减免
}

function DebugAttr:AddEvent()
	self.role_data = RoleInfoModel:GetInstance():GetMainRoleData()
	local function call_back()
		self:UpdateAttr()
	end
	self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("exp", call_back)

	for attr_name,v in pairs(attr_map) do
		self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("attr." .. attr_name, call_back)
	end

	local function call_back(keycode)
		if keycode == InputManager.KeyCode.O then
			self.is_show_attr = not self.is_show_attr
			self:UpdateAttr()	
		end
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.KeyRelease, call_back)
end

function DebugAttr:InitMap()
	local t = {}
	for attr_name,v in pairs(attr_map) do
		local index = GetAttrMapIndexByKey(attr_name)
		local info = clone(PROP_ENUM[index])
		info.index = index
		info.key = attr_name
		t[#t+1] = info
	end
	local function sortFunc(a,b)
		return a.sort < b.sort
	end
	table.sort(t,sortFunc)
	self.attr_map_list = t
end

function DebugAttr:UpdateAttr()
	if not self.is_show_attr then
		self.text_component.text = "Show attributes 0"
		return
	end
	if not self.role_data then
		return
	end
	local config = Config.db_role_level[self.role_data.level]
	local str = "Tap [o] to hide the attribute\n"
	str = str .. string.format(" exp：%s/%s\n",self.role_data.exp,config and config.exp or 0)
		

	local function getStr(i)
		local info = self.attr_map_list[i]
		if not info then
			return nil
		end
		local value = self.role_data:GetValue("attr." .. info.key)
		value = value or 0
		local s
		if info.index >= 13 and value > 0 then
			s = string.format("%s：%s%%",info.label,value/100)
		else
			s = string.format("%s：%s",info.label,GetShowNumber(value))
		end
		return s
	end
	local len = #self.attr_map_list
	local half = math.ceil(len*0.5)
	for i=1,half do
		local s1 = getStr(i)
		local s2 = getStr(i+half)
		local s = s1
		if s2 then
			s = string.inserttrim(s,18) .. s2
		end
		str = str .. s .. "\n"
	end
	self.text_component.text = str
end

function DebugAttr:SetData(data)

end