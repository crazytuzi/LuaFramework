require "Core.Module.Common.Panel"

require "Core.Module.AutoFight.View.Item.AutoUseDrugItem"

AutoUseDrugPanel = class("AutoUseDrugPanel", Panel);

local auto_set_cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_AUTO_SET); --require "Core.Config.auto_set"

AutoUseDrugPanel.auto_set_cf_type_1 = 1;
AutoUseDrugPanel.auto_set_cf_type_2 = 2;
local _sortfunc = table.sort

function AutoUseDrugPanel:New()
	self = {};
	setmetatable(self, {__index = AutoUseDrugPanel});
	return self
end


function AutoUseDrugPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function AutoUseDrugPanel:_InitReference()
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
	
	self.listPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "listPanel");
	self.subPanel = UIUtil.GetChildByName(self.listPanel, "Transform", "subPanel");
	self._item_phalanx = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table");
	
	AutoUseDrugItem.currSelect = nil;
	
end

function AutoUseDrugPanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
end

function AutoUseDrugPanel:_OnClickBtnClose()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
	ModuleManager.SendNotification(AutoFightNotes.CLOSE_AUTOUSEDRUGPANEL);
end



function AutoUseDrugPanel:SetData(data)
	
    local type = data.type;
    local select_spId = data.select_spId;

	-- 默认选择 的 要放在  最前
	local list = {};
	local listIndex = 1;
	
	local me = HeroController:GetInstance();
	local heroInfo = me.info;
	local my_lv = heroInfo.level;
	
	for key, value in pairs(auto_set_cf) do
		
		if value.name == type then
			
			if my_lv >= value.req_lev then
				
				list[listIndex] = {}
				setmetatable(list[listIndex], {__index = value})				
				
                --去除选中的物品排在最前面#6863
				-- if type == AutoUseDrugPanel.auto_set_cf_type_1 then
				-- 	if list[listIndex].id == AutoFightManager.use_Drug_HP_id then
				-- 		list[listIndex].order = 0;
				-- 	end
				-- elseif type == AutoUseDrugPanel.auto_set_cf_type_2 then
				-- 	if list[listIndex].id == AutoFightManager.use_Drug_MP_id then
				-- 		list[listIndex].order = 0;
				-- 	end
				-- end
				listIndex = listIndex + 1;
				
			end
			
		end
	end
	
 
	---  需要进行排序
	_sortfunc(list, function(a, b)	 
		return a.order < b.order
	end)
	
	
	local t_num = table.getn(list);

    for key, value in pairs(list) do
		 value.select_spId=select_spId;
    end
	
	
	if self.product_phalanx == nil then
		self.product_phalanx = Phalanx:New();
		self.product_phalanx:Init(self._item_phalanx, AutoUseDrugItem);
		self.product_phalanx:Build(t_num, 1, list);
	end
	
	
	-- 设置 默认选择
end

function AutoUseDrugPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	AutoUseDrugItem.currSelect = nil
end

function AutoUseDrugPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
end

function AutoUseDrugPanel:_DisposeReference()
	self._btnClose = nil;
	
	self.product_phalanx:Dispose();
	self.product_phalanx = nil;
	
	
	
end
