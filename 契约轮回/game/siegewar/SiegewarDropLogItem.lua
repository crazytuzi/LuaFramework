SiegewarDropLogItem = SiegewarDropLogItem or class("SiegewarDropLogItem",BaseCloneItem)
local SiegewarDropLogItem = SiegewarDropLogItem

function SiegewarDropLogItem:ctor(obj,parent_node,layer)
	SiegewarDropLogItem.super.Load(self)
end

function SiegewarDropLogItem:dctor()
end

function SiegewarDropLogItem:LoadCallBack()
	self.nodes = {
		"time", "log", "kill_log_item_bg"
	}
	self:GetChildren(self.nodes)
	self.time = GetText(self.time)
	self.log = GetText(self.log)
	self:AddEvent()
end

function SiegewarDropLogItem:AddEvent()
	self.events = {}
	AddEventListenerInTab(RoleInfoEvent.QUERY_OTHER_ROLE, handler(self, self.HandleRoleInfoQuery), self.events)
end

function SiegewarDropLogItem:SetData(data)
	self.data = data
	self.time = TimeManager:FormatTime2Date(data.time)
	local scenename = Config.db_scene[data.scene].name
	local itemcfg = Config.db_item[data.item_id]
	local color = ColorUtil.GetColor(itemcfg.color)
	self.log.text = "<color=#268FDA><a href=player_" .. data.picker_id .. ">" .. data.picker_name .. "</color></a>At" .. scenename .. "X" .. "<color=#E63232>" .. data.boss .. "</color>Fight fiercely and obtain rare item<color=#" .. color .. "><a href=item_" .. data.cache_id .. ">[" .. itemcfg.name .. "]</a></color>";
	self.log:AddClickListener(handler(self, self.HandleLogClick))
end

function SiegewarDropLogItem:HandleRoleInfoQuery(data)
    if data and data.role and data.role.id == self.roleid then
        local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel , self.log.transform);
        if not panel.isShow then
            panel:Open(data.role);
        end
    end
end

function SiegewarDropLogItem:HideBg()
    if self.kill_log_item_bg then
        self.kill_log_item_bg.gameObject:SetActive(false);
    end
end

function SiegewarDropLogItem:HandleLogClick(str)
    local strTab = string.split(str, "_")
    if strTab and #strTab > 1 then
        if strTab[1] == "player" then
            --Notify.ShowText("显示玩家信息" .. strTab[2]);
            --ShaderManager:GetInstance():SetImageGray(self.kill_log_item_bg)
            self.roleid = strTab[2];
            RoleInfoController:GetInstance():RequestRoleQuery(strTab[2]);
        elseif strTab[1] == "item" then
            --ShaderManager:GetInstance():SetImageNormal(self.kill_log_item_bg);
            GoodsController:GetInstance():RequestQueryDropped(tonumber(strTab[2]))
        end
    end
end
