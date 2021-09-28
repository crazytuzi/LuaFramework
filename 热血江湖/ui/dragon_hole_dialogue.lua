-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_dragon_hole_dialogue = i3k_class("wnd_dragon_hole_dialogue", ui.wnd_base)

local LAYER_DB5T = "ui/widgets/db5t"

function wnd_dragon_hole_dialogue:ctor()
	
end

function wnd_dragon_hole_dialogue:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)
	self.dialogue = widgets.dialogue
	self.npcName = widgets.npcName
	self.btn_scroll = widgets.btn_scroll
end

function wnd_dragon_hole_dialogue:refresh(npcId)
	local data = i3k_db_npc[npcId]
	local fLvl = g_i3k_game_context:GetFameNpcDialogueLvl(data.fameLvl)
	self.dialogue:setText(data["desc"..fLvl])
	local npcModule = self._layout.vars.npcmodule
	local modelId = g_i3k_db.i3k_db_get_npc_modelID(npcId)
	if npcId == eExpTreeId then
		modelId = i3k_db_exptree_common.npcId
	end
	ui_set_hero_model(npcModule, modelId)
	self.npcName:setText(data.remarkName)
	self.btn_scroll:removeAllChildren()
	local npcFunc = {}
	for k, v in ipairs(i3k_db_npc_transfer) do
		if v.npcId == npcId then
			table.insert(npcFunc, {info = v, id = k})
		end
	end
	local children = self.btn_scroll:addChildWithCount(LAYER_DB5T, 2, #npcFunc)
	for k, v in ipairs(children) do
		v.vars.select1_btn:onClick(self, self.onTransfer, npcFunc[k])
		v.vars.name:setText(npcFunc[k].info.btnTxt)
	end
end

function wnd_dragon_hole_dialogue:onTransfer(sender, data)
	local itemCnt = g_i3k_game_context:GetCommonItemCanUseCount(data.info.needItemID)
	for _,v in ipairs(data.info.conditions) do
        if v.conditonType == 1 and v.conditionValue > g_i3k_game_context:GetVipLevel() then
            g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15362, v.conditionValue))
            return
        elseif v.conditonType == 2 and v.conditionValue > g_i3k_game_context:GetLevel() then
            g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15363, v.conditionValue))
            return
        end
    end
    if data.info.needItemID > 0 and itemCnt < data.info.needItemCount then
        local tip = ""
        if itemCnt > 0 then
            tip = i3k_get_string(15360, data.info.needItemCount)
        else
            tip = i3k_get_string(15361, data.info.needItemCount, g_i3k_db.i3k_db_get_common_item_name(data.info.needItemID))
        end
        g_i3k_ui_mgr:PopupTipMessage(tip)
        return
    end
	 if data.info.needItemID > 0 and data.info.needItemCount > 0 then
        local function func1()
            local fun = function(isOk)
                if isOk then
                    i3k_sbean.npc_transfrom(data.id)
                end
            end
            g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(15375, data.info.needItemCount, g_i3k_db.i3k_db_get_common_item_name(data.info.needItemID)), fun)
        end
        g_i3k_game_context:CheckMulHorse(func1)
    else
        g_i3k_game_context:CheckMulHorse(function()
            i3k_sbean.npc_transfrom(data.id)
        end)
    end
end

function wnd_create(layout, ...)
	local wnd = wnd_dragon_hole_dialogue.new();
	wnd:create(layout, ...);
	return wnd;
end
