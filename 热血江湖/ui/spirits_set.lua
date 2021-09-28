-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_spirits_set = i3k_class("wnd_spirits_set", ui.wnd_base)

local sch_path1 = "ui/widgets/jnsdt"
local sch_path2 = "ui/widgets/jnqht2"

local l_tag = 1000

local xinfa_name_type = {[g_ZHIYE_XINFA] = "职业气功",[g_JIANGHU_XINFA]	= "江湖气功",[g_PEIBIE_XINFA] = "派别气功"}

local l_num_preSpirits = 4

function wnd_spirits_set:ctor()
	self.rightNum = 1
	self.preData = {}
	self.preSpirits = {}
end

function wnd_spirits_set:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)

	self.preList = widgets.preList

	widgets.save_btn:onClick(self,self.onSaveClick)
	widgets.replace_btn:onClick(self,self.onReplaceClick)
	widgets.delete_btn:onClick(self,self.onDeleteClick)
	widgets.use_btn:onClick(self,self.onUseClick)
end

function wnd_spirits_set:refresh(rightNum)
	if rightNum then 
		self.rightNum = rightNum
	end 
	local widgets = self._layout.vars
	self.preData = g_i3k_game_context:getSpiritsPresetData()
	
	widgets.numLable:setText(string.format("%s/%s",#self.preData,l_num_preSpirits))

	self:updateListPre()
	self:updateRightListState()
end

function wnd_spirits_set:updateListPre()
	self.preList:removeAllChildren(true)
	for i=1,#self.preData + 1 do
		local node = require(sch_path1)()

		local nameStr 
		if self.preData[i] then 
			nameStr = self.preData[i].spiritsPresetName
		else
			nameStr = i3k_get_string(713) --当前设置
		end 

		node.vars.pre_name:setText(nameStr)

		node.vars.pre_btn:setTag(i + l_tag)
		node.vars.pre_btn:onClick(self, self.onItemClick)
		self.preList:addItem(node)
	end
end

function wnd_spirits_set:onItemClick(sender)
	local tag = sender:getTag() - l_tag
	if tag == self.rightNum then 
		return
	else
		self.rightNum = tag
		self:updateRightListState()
	end 
end

function wnd_spirits_set:updateRightListState()
	for k,v in ipairs(self.preList:getAllChildren()) do
		if k ~= self.rightNum then 
			v.vars.pre_btn:stateToNormal()
		else
			v.vars.pre_btn:stateToPressed()
		end 
	end
	self:updateListSkill(self.rightNum)
end

function wnd_spirits_set:updateListSkill(index, noUI)
	-- local scr_list = self._layout.vars.scr_list
	-- scr_list:removeAllChildren(true)
	self.preSpirits = {}

	local widgets = self._layout.vars
	local defaultFlag = index > #self.preData
	
	if not noUI then 	
		if defaultFlag then 
			widgets.save_btn:setVisible(true)
			widgets.replace_btn:setVisible(false) 
			widgets.delete_btn:setVisible(false) 
			widgets.use_btn:setVisible(false) 
		else
			widgets.save_btn:setVisible(false)
			widgets.replace_btn:setVisible(true) 
			widgets.delete_btn:setVisible(true) 
			widgets.use_btn:setVisible(true) 
		end 
	end 
	
	local use_xinfa_detail = {}

	if defaultFlag then 
		local use_xinfa = g_i3k_game_context:GetUseXinfa()
		for _,v in pairs(use_xinfa) do
			for _,j in ipairs(v) do
				table.insert(use_xinfa_detail,j)
			end
		end
	else
		use_xinfa_detail = self.preData[index].spiritsPreset
	end 
	
	local pre = self.preData

	table.sort( use_xinfa_detail , function (a, b)
		return a > b
	end )

	for i=1,8 do
		local spiritsID,cfg
		-- if defaultFlag then 
		 	spiritsID = use_xinfa_detail[i]
		-- else
		-- 	spiritsID = preTab.spiritsPreset[i]
		-- end 
		cfg = i3k_db_xinfa[spiritsID]
		if spiritsID and cfg then
			table.insert(self.preSpirits,spiritsID)
			if not noUI then 
				local item_id = cfg.itemID
				widgets[string.format("skill%s_bot",i)]:setVisible(true)

	 			widgets[string.format("skill%s_cont",i)]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item_id))
	 			i3k_log(g_i3k_db.i3k_db_get_common_item_icon_path(item_id,i3k_game_context:IsFemaleRole()))
	 			widgets[string.format("skill%s_icon",i)]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item_id,i3k_game_context:IsFemaleRole()))
		 		widgets[string.format("skill%s_name",i)]:setText(cfg.name)
	 			widgets[string.format("skill%s_name",i)]:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(item_id)))	 		
				widgets[string.format("skill%s_des",i)]:hide() --setText(xinfa_name_type[cfg.type])
			end 
		else
			if not noUI then 
				widgets[string.format("skill%s_bot",i)]:setVisible(false)
			end 
		end 
	end
end

function wnd_spirits_set:onReplaceClick(sender)
	local callback = function(isOk)
		if isOk then
			self:updateListSkill(#self.preData + 1,true)
			self:sendSaveBean()
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(980), callback)
end

function wnd_spirits_set:onSaveClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_PreName)
	g_i3k_ui_mgr:RefreshUI(eUIID_PreName, g_PRE_NAME_SPIRITS)
end

function wnd_spirits_set:onUseClick(sender)
	i3k_sbean.change_spirits_preset(self.rightNum)
end

function wnd_spirits_set:onDeleteClick(sender)
	local data = i3k_sbean.delete_spirits_preset_req.new()
	--self._pname_ = "delete_spirits_preset_req"
	--self.index:		int32	
	data.index = self.rightNum 
	i3k_game_send_str_cmd(data,i3k_sbean.delete_spirits_preset_res.getName())
end

function wnd_spirits_set:sendSaveBean(name)
	--self.index:		int32	
	--self.name:		string	
	--self.spirits:		set[int32]	
	local data = i3k_sbean.save_spirits_preset_req.new()
	data.index = self.rightNum
	data.name = name and name or self.preData[self.rightNum].spiritsPresetName
	data.spirits = self.preSpirits
	i3k_game_send_str_cmd(data,i3k_sbean.save_spirits_preset_res.getName())
end

function wnd_create(layout,...)
	local wnd = wnd_spirits_set.new();
		wnd:create(layout,...)
	return wnd;
end
