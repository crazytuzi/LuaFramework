module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_shenshiExplore = i3k_class("wnd_shenshiExplore", ui.wnd_base)
local SCCJT        = "ui/widgets/sccjt"


function wnd_shenshiExplore:ctor()
	self._id = 1
	self.needItem = {}
	self._petID = 0
	self._taskID = 0
	self._now_petID = 0
	self._now_taskID = 0
	self.is_ok = nil
end

function wnd_shenshiExplore:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.go_btn 		= widgets.go_btn
	self.taskTagDesc	= widgets.taskTagDesc
	self.task_tag_desc 	= widgets.task_tag_desc
	self.taskPartName 	= widgets.taskPartName
	self.go_lab 		= widgets.go_lab
	self.last_btn 		= widgets.last_btn
	self.next_btn 		= widgets.next_btn
	self.isOK 			= widgets.isOK
	self.tipsDesc 		= widgets.tipsDesc
	self.iscompelete =widgets.iscompelete
	for i=1, 4 do
		local itemRoot = "item".. i .. "Root"
		local itemIcon = "item" .. i .. "Icon"
		local itemCount = "item" .. i .. "Count"
		local itemLock	= "suo" .. i
		self.needItem[i] = {
			itemRoot    = widgets[itemRoot],
			itemIcon	= widgets[itemIcon],
			itemCount	= widgets[itemCount],
			itemLock	= widgets[itemLock],
		}
	end
end

function wnd_shenshiExplore:onShowData(petID, taskID)
	local info = g_i3k_db.i3k_db_get_fromTask_info(petID, taskID)
	self.taskTagDesc:setText(info.taskDesc)
	local id, value, reward = g_i3k_game_context:getPetLifeTskIdAndValueById(info.petID)
	local tm_task_type = info.taskType
	local arg1 = info.arg1
	local arg2 = info.arg2
	local is_ok = g_i3k_game_context:IsTaskFinished(tm_task_type,arg1,arg2,value)
	local tmp_desc = g_i3k_db.i3k_db_get_task_desc(tm_task_type,arg1,arg2,value, is_ok,nil)
	self.task_tag_desc:setText(tmp_desc)
	self.taskPartName:setText(info.taskName)
	self.isOK:setVisible(false)
	self.iscompelete:setVisible(true)
	local awardID = {}
	local awardCount = {}
	for i=1, 4 do
		self.needItem[i].itemRoot:hide()
		awardID[i] = info["awardID" .. i]
		awardCount[i] = info["awardCount" .. i]
		if awardID[i] ~= 0 then
			self.needItem[i].itemRoot:show()
			self.needItem[i].itemRoot:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(awardID[i])))
			self.needItem[i].itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(awardID[i],i3k_game_context:IsFemaleRole()))
			self.needItem[i].itemCount:setText(awardCount[i])
			self.needItem[i].itemLock:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(awardID[i]))
			self.needItem[i].itemRoot:onClick(self, self.clickItem, awardID[i])
		end
	end
	self.go_btn:onClick(self, self.intoDuplicate, {petID = petID, fromEctypeID = info.fromEctypeID})
	self.go_btn:enableWithChildren()
	self.go_lab:setText("探索身世")
	
	if self.is_ok then
		self.go_btn:disableWithChildren()
		self.go_lab:setText("进行中...")
		
	end
	if self._now_taskID ~= taskID then
		local tmp_desc = g_i3k_db.i3k_db_get_task_desc(tm_task_type,arg1,arg2,arg2, true,nil)
		self.task_tag_desc:setText(tmp_desc)
		self.isOK:setVisible(true)
		self.iscompelete:setVisible(false)
	end
	self:showOtherTask(petID, taskID)
end

function wnd_shenshiExplore:intoDuplicate(sender, data)
	--进入副本
	local fun = function ()
		i3k_sbean.lifetaskmap_start(data.fromEctypeID,data.petID)
	end
	g_i3k_game_context:CheckMulHorse(fun)
end

function wnd_shenshiExplore:refresh(petID,taskID, is_ok)
	self._now_petID = petID
	self._now_taskID = taskID
	self._petID = petID
	self._taskID = taskID
	self:onShowData(petID,taskID)
	self.is_ok = is_ok
	--self:showOtherTask(petID, taskID)
	self.tipsDesc:show()
	self.tipsDesc:setText("进入宠物专属的身世副本")
	if is_ok and is_ok == true then
		self.go_btn:disableWithChildren()
		self.go_lab:setText("进行中...")
		self.tipsDesc:hide()
	end
end

function wnd_shenshiExplore:lastData(sender, data)
	local info = g_i3k_db.i3k_db_get_last_fromTask_info(self._petID, self._taskID)
	self._petID = info.petID
	self._taskID = info.taskID
	self:onShowData(self._petID, self._taskID)
end

function wnd_shenshiExplore:nextData(sender, data)
	local info = g_i3k_db.i3k_db_get_next_fromTask_info(self._petID, self._taskID)
	self._petID = info.petID
	self._taskID = info.taskID
	self:onShowData(self._petID, self._taskID)
	
end

function wnd_shenshiExplore:showOtherTask(petID, taskID)
	if self._now_petID == petID and self._now_taskID == taskID then
		self.next_btn:hide()
	else
		self.next_btn:show()
		self.next_btn:onClick(self, self.nextData,{petID = petID, taskID = taskID})
	end
	local info = g_i3k_db.i3k_db_get_last_fromTask_info(petID, taskID)
	if info == nil then
		self.last_btn:hide()
	else
		self.last_btn:show()
		self.last_btn:onClick(self, self.lastData,{petID = petID, taskID = taskID})
	end
end

function wnd_shenshiExplore:clickItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

--[[function wnd_shenshiExplore:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ShenshiExplore)
end--]]

function wnd_create(layout)
	local wnd = wnd_shenshiExplore.new();
		wnd:create(layout);

	return wnd;
end
