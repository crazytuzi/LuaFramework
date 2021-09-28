-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_changeNpcList= i3k_class("wnd_changeNpcList",ui.wnd_base)


local NODE = "ui/widgets/dhnpclbt"

function wnd_changeNpcList:ctor()
	self.exchangeId  = nil
	self.npcId  = nil

end

function wnd_changeNpcList:configure()
	self.npcList = {} --列表所有NPC
	 
	local widgets = self._layout.vars
	self.close_btn = widgets.close_btn
	self.close_btn:onClick(self,self.onCloseUI)
	self.btn_scroll = widgets.btn_scroll
	self.limit_time = 0
	self.recordExchangeTimes = {}
	self:getAllNpc()
end

--获取Npc列表
function wnd_changeNpcList:getAllNpc()
	
	for _,v in pairs(i3k_db_npc)do
		for _,v2 in pairs(v.FunctionID) do
			if v2 == TASK_FUNCTION_NPCEXCHANGE then
				local tab = v.exchangeNpcList
				if tab[1] == 1 and not tab[2] then
					table.insert(self.npcList,v)
				else 
					if tab[2] and tab[2]<= g_i3k_game_context:GetLevel() then
						table.insert(self.npcList,v)
					end
				end
			end
		end
	end
	
	table.sort(self.npcList,function(a,b)
        return a.sortID < b.sortID
	end)
end

function wnd_changeNpcList:onNpcExchange(sender,tbl)
	local npcId = tbl.npcId
	local exchangeId = tbl.exchangeId
	g_i3k_logic:OpenNpcExchange(npcId, exchangeId)
	g_i3k_ui_mgr:CloseUI(eUIID_ChangeNpcList)
end

function wnd_changeNpcList:refresh()
	self:addItemsAndSetRed()
end

function wnd_changeNpcList:addItemsAndSetRed()
	self._layout.vars.scroll:removeAllChildren()
	local count = #self.npcList 
	local allBars = self._layout.vars.scroll:addChildWithCount(NODE, 2, count)
	self.recordExchangeTimes = g_i3k_game_context:GetRecordExchangeTimes()
	local nodeList = {}
	local need = 0
	local have= 0
	self.limit_time ={}
	for _,i in ipairs(self.npcList) do
		table.insert(nodeList,{exchangeId = i3k_db_npc[i.ID].exchangeId, info = i})
	end
	
	for n,e in ipairs(nodeList) do
		local times = false
		local redPointShow = false
		for _,v in ipairs(e.exchangeId)do
			local exchangeInfo = i3k_db_npc_exchange[v]
			for _,s in ipairs(self.recordExchangeTimes) do
				if s.id == v then
					if exchangeInfo.limit_times == -1 then
						times = true --次数不限
					elseif exchangeInfo.limit_times >=0 then
						self.limit_time[v] = exchangeInfo.limit_times - s.limit_time
						if self.limit_time[v] > 0 then
							times = true --兑换次数>0
						end
					end
				end
			end
			local require_goods_id = {
			[1] = exchangeInfo.require_goods_id1,
			[2] = exchangeInfo.require_goods_id2,
			[3] = exchangeInfo.require_goods_id3
			}
			
			local require_goods_count = {
			[1] = exchangeInfo.require_goods_count1,
			[2] = exchangeInfo.require_goods_count2,
			[3] = exchangeInfo.require_goods_count3
			}
		
			for k=1,3 do
			 
				if  exchangeInfo["require_goods_id" .. k] == 0 then
				else
					--local add_goods_count = g_i3k_game_context:GetCommonItem(require_goods_id[k]) + g_i3k_game_context:GetCommonItem(-require_goods_id[k])
					local add_goods_count = g_i3k_game_context:GetCommonItemCanUseCount(require_goods_id[k]) 
					if add_goods_count >= require_goods_count[k] then
						have = have + 1 --拥有de物品
					end
					need = need + 1 --兑换物品需求1-3
				end
			end
			if have >= need and times then --符合兑换条件
				redPointShow = true
			end
			need = 0
			have = 0
		end
		 
		local npcFunction = e.info.npcFunction
		local npcName = e.info.remarkName
		local monsterID = e.info.monsterID
		allBars[n].vars.npcFunction:setText(string.format(npcFunction))
		allBars[n].vars.npcName:setText(string.format(npcName))
		allBars[n].vars.tx_icon:setImage(g_i3k_db.i3k_db_get_monster_head_icon_path(monsterID)) 
		allBars[n].vars.open_btn:onClick(self,self.onNpcExchange,{npcId = e.info.ID,exchangeId = i3k_db_npc[e.info.ID].exchangeId})
		if redPointShow then
			allBars[n].vars.redPoint:setVisible(true)
		end
		
	end
end

function wnd_create(layout)
	local wnd = wnd_changeNpcList.new()
	wnd:create(layout)
	return wnd
end


