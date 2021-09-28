-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------五绝秘境界面
wnd_fiveUnique_secretarea = i3k_class("wnd_fiveUnique_secretarea", ui.wnd_base)


function wnd_fiveUnique_secretarea:ctor()
	self._id = nil

	self._killCount = nil
	self._isreward = nil
end

function wnd_fiveUnique_secretarea:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)

end


function wnd_fiveUnique_secretarea:refresh(info)
	self._cfg = info
	self._cfgId,self._cfgValue,self._cfgReward = g_i3k_game_context:getSecretareaTaskId()
	self._cfgId,self._cfgValue = g_i3k_game_context:getSecretareaTaskIdAndVlaue()
	self:SetPayOutItemInfo(self._cfgId)
	self:setData(self._cfgId)
	
	---需要判断任务的状态 
end



function wnd_fiveUnique_secretarea:SetPayOutItemInfo(id)

	local need_item = i3k_db_secretarea_task[id].rewards
	
	for i=1,4 do
		local temp_bg = "item"..i.."Root"
		local temp_icon = "item"..i.."Icon"
		local temp_btn = "item"..i.."_btn"
		local temp_count = "item"..i.."Count"
		local temp_lock = "item"..i.."_suo"
	
		self._layout.vars[temp_bg]:setVisible(need_item[i]~=nil)
	
		if need_item[i].count > 0 and need_item[i].id  then
			local count = need_item[i].count
			local itemid = need_item[i].id
		
		
			self._layout.vars[temp_bg]:show()
			self._layout.vars[temp_bg]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
			self._layout.vars[temp_icon]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
			if count > 1 then
				self._layout.vars[temp_count]:setText("x"..count)
			else
				self._layout.vars[temp_count]:hide()
			end

			
			self._layout.vars[temp_btn]:onClick(self,self.onTips,itemid)--
		else
			self._layout.vars[temp_bg]:hide()
		end
		
		if need_item[i].id > 0 and need_item[i].id then
			self._layout.vars[temp_lock]:show()
		
		else
			self._layout.vars[temp_lock]:hide()
		end
		
		
	end
end



-----------
function wnd_fiveUnique_secretarea:setData(id)
	
	self._layout.vars.taskPartName:setText(i3k_db_secretarea_task[id].name)
	self._layout.vars.taskTagDesc:setText(i3k_db_secretarea_task[id].getTaskDesc)--任务描述  mainchs  
	local taskType = i3k_db_secretarea_task[id].type
	local arg1 = i3k_db_secretarea_task[id].arg1
	local arg2 = i3k_db_secretarea_task[id].arg2
	self._is_ok = g_i3k_game_context:IsTaskFinished(taskType,arg1,arg2,self._cfgValue)
	local desc = g_i3k_db.i3k_db_get_task_desc(taskType,arg1,arg2,self._cfgValue,self._is_ok,false)---
	self._layout.vars.task_tag_desc:setText(desc)--任务条件  
	self._layout.vars.go_btn:onClick(self, self.onClickGoBtn,{id = id ,mapId = i3k_db_secretarea_task[id].mapId,gifts =  i3k_db_secretarea_task[id].rewards})
	--判断是否完成用value
	if self._is_ok then --完成去领取
		self._layout.vars.go_text:setText("领取奖励")
	else --未完成
		self._layout.vars.go_text:setText("进入秘境")
	
	end
end

function wnd_fiveUnique_secretarea:changeBtnState(info)
	
	self._layout.vars.go_btn:disableWithChildren()
	self._layout.vars.go_text:setText("已领取")

	if info then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "setFiveUniqueActivityData",info.groupID,info.bestFloor,info._layer,info.fbId,info.finishFloors,info.dayTimesBuy,info.dayTimesUsed)--groupID,level,widget,fbId,info
	end
	

end

--- 前往
function wnd_fiveUnique_secretarea:onClickGoBtn(sender,needValue)
	--判断是否处于秘境地图 mapId
	local now_mapId = g_i3k_game_context:GetWorldMapID()
	
	if  now_mapId == needValue.mapId then--处于秘境地图(不需要传送)
		if self._is_ok then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(538))
		else
			g_i3k_ui_mgr:PopupTipMessage("您已进入秘境")
		end
	
	else
		if self._is_ok then --领取
		
		
			local gift = {}
		
			
			local giftsTb = needValue.gifts
			local isEnoughTable = { }
			local index = 0
		
			for i,v in ipairs(giftsTb) do
				
				isEnoughTable[v.id] = v.count
				

			end
		
			local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
			for i,v in pairs (isEnoughTable) do
				index = index + 1
				gift[index] = {id = i,count = v}
			
			end
			if isEnough then
			
				i3k_sbean.activities_secretreward_take(needValue.id,gift,self._cfg )--,needValue.item
			else
				g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
			end
		
		else --未完成
			local mapid = needValue.mapId
			local function func()
				g_i3k_game_context:ClearFindWayStatus()
				i3k_sbean.enter_secretmap_task(mapid)--前往
			end
			g_i3k_game_context:CheckMulHorse(func)
		end
	end
end

function wnd_fiveUnique_secretarea:onTips(sender,itemId)
	
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end
--[[function wnd_fiveUnique_secretarea:closeBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Secretarea)
end--]]

function wnd_create(layout)
	local wnd = wnd_fiveUnique_secretarea.new()
	wnd:create(layout)
	return wnd
end
