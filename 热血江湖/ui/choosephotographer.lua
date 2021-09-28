
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_choosePhotographer = i3k_class("wnd_choosePhotographer", ui.wnd_base)

local LAYER_BPLBT = "ui/widgets/bphz2t"

--快速操作
--local OPERATION_NONE 				= 1 --没有操作
local OPERATION_CHOOSE_ALL 			= 1 --选择所有
local OPERATION_ONLINE_ALL 			= 2 --所有在线
local OPERATION_ADMINISTRATION_ALL  = 3 --所有管理
local OPERATION_CANCEL_ALL 			= 4 --全部取消

--下拉框
local FILTER_SCENE 					= 1 -- 选择场景
local FILTER_OPERATION 				= 2 -- 选择操作

local job_text = {"帮主","副帮主","长老","精英","平民"}
local title_icons = {2482,2483,2484}

function wnd_choosePhotographer:ctor()
	self._data = {} -- 临时缓存玩家数据
	self._filter_root = {}
	self.filterTypeScene = 1
	self._selectedCount = 0
end

function wnd_choosePhotographer:configure(...)
	local widgets = self._layout.vars
	widgets.gradeLabel2:setText(i3k_get_string(1777))
	self._filter_root = {
		[FILTER_SCENE] 		= {filterBtn = widgets["filterBtn"..FILTER_SCENE], levelRoot = widgets["levelRoot" .. FILTER_SCENE], filterScroll = widgets["filterScroll" ..FILTER_SCENE], mask = widgets["mask"..FILTER_SCENE], gradeBtn = widgets["gradeBtn"..FILTER_SCENE]},
		[FILTER_OPERATION]	= {filterBtn = widgets["filterBtn"..FILTER_OPERATION], levelRoot = widgets["levelRoot" .. FILTER_OPERATION], filterScroll = widgets["filterScroll" ..FILTER_OPERATION], mask = widgets["mask"..FILTER_OPERATION], gradeBtn = widgets["gradeBtn"..FILTER_OPERATION]}
	}
	widgets.taskPhoto:onClick(self, self.onTaskPhoto)
	widgets.close_btn:onClick(self, self.onCloseUI)
	self.selectCount =  widgets.count
	self.member_scroll = widgets.member_scroll
	widgets.maskDesc:setText(i3k_get_string(1782))
	widgets.gradeLabel1:setText(i3k_db_faction_photo.mapCfg[1].name)
end

function wnd_choosePhotographer:refresh()
	self:updateMenberData(g_i3k_game_context:GetFactionMemberSortPosition(),g_i3k_game_context:GetFactionChiefID(),g_i3k_game_context:GetFactionDeputyID(),g_i3k_game_context:GetFactionElderID(),g_i3k_game_context:GetRoleId(),g_i3k_game_context:GetLevel())
	self:setFilterBtn(FILTER_SCENE)
	self:setFilterBtn(FILTER_OPERATION)
end

function wnd_choosePhotographer:updateMenberData(tmp_members,chiefId,deputy,elder,my_id,my_level)
	self._data = {}
	self.member_scroll:removeAllChildren()
	local elite = g_i3k_game_context:GetFactionEliteID()
	for k,v in ipairs(tmp_members) do
		local _first_btn = false
		local _second_btn = false
		local _layer = require(LAYER_BPLBT)()
		local headIcon = _layer.vars.headIcon
		local member_headIcon = v.role.headIcon
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(member_headIcon,g_i3k_db.eHeadShapeQuadrate)
		if hicon and hicon > 0 then
			headIcon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
		end
		local name_label = _layer.vars.name_label
		name_label:setText(v.role.name)
		local level_label = _layer.vars.level_label
		level_label:setText(v.role.level)
		local job_label = _layer.vars.job_label
		local tmp_pos = 0
		if v.role.id == chiefId then
			job_label:setText(job_text[eFactionOwner])
			job_label:setTextColor("FF574990")
			_layer.vars.old_contri:setTextColor("FF574990")
			_layer.vars.state:setTextColor("FF574990")
			tmp_pos = eFactionOwner
			
		elseif deputy[v.role.id] then
			job_label:setText(job_text[eFactionSencondOwner])
			tmp_pos = eFactionSencondOwner
		elseif elder[v.role.id] then
			job_label:setText(job_text[eFactionElder])
			tmp_pos = eFactionElder
		elseif elite[v.role.id] then
			job_label:setText(job_text[eFactionElite])
			tmp_pos = eFactionElite
		else
			job_label:setText(job_text[eFactionPeple])
			tmp_pos = eFactionPeple
		end
		if v.role.id == chiefId then
			_layer.vars.memberBg:setImage(g_i3k_db.i3k_db_get_icon_path(8754))
		else
			_layer.vars.memberBg:setImage(g_i3k_db.i3k_db_get_icon_path(6204))
		end
		local old_contri = _layer.vars.old_contri
		old_contri:setText(v.role.fightPower)
		local state = _layer.vars.state
		local desc = self:getUserState(v.lastLogoutTime)
		state:setText(desc)
		local detail_btn = _layer.vars.detail_btn
		detail_btn:setTag(v.role.id)
		detail_btn:onClick(self,self.onSetChoose, {id = v.role.id, widgets = _layer })
		_layer.vars.selected:hide()
		local roleHeadBg = _layer.vars.roleHeadBg
		roleHeadBg:setImage(g_i3k_get_head_bg_path(v.role.bwType, v.role.headBorder))
		self.member_scroll:addItem(_layer)

		local job_icon = _layer.vars.job_icon
		job_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[v.role.type].classImg))

		self._data[v.role.id] = { id = v.role.id, name = v.role.name,level = v.role.level, isOnline = v.lastLogoutTime == 0 , isFactionPeple = tmp_pos ~= eFactionPeple, widgets =  _layer, isSelected = false}
		if v.role.id == chiefId  then
			self:onSetChoose(nil, {id = v.role.id, widgets = _layer })
		end
	end
end

function wnd_choosePhotographer:getUserState(Timer)
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	if Timer < 0 then
		return "刚刚"
	elseif Timer == 0 then
		return "线上"
	else
		local count =  serverTime - Timer
		if count >= 3600 and count <= 3600 * 24 then
			--local nums = math.modf(count / 3600)
			local desc = "刚刚"
			--desc = string.format(desc,nums)
			return  desc
		elseif count > 3600 * 24  and count <= 3600* 24 * 7 then
			local nums = math.modf(count /(3600 * 24))
			local desc = "离线%s天"
			desc = string.format(desc,nums)
			return  desc
		elseif count > 3600 * 24 *7 then
			return "久未上线"
		elseif count < 3600 then
			local nums = math.modf(count / 60)
			local desc = "刚刚"
			--desc = string.format(desc,nums)
			return  desc
		end
	end
end


--选择list
function wnd_choosePhotographer:setFilterBtn(state,filterStrss)
	local widgets = self._filter_root[state]
	local filterStrs = self:getFilterStrs(state)
	widgets.mask:onClick(self, function() 
		if widgets.levelRoot:isVisible() then
			widgets.levelRoot:setVisible(false)	
		end
	end)
	local openFilter = function ()
		if widgets.levelRoot:isVisible() then                 --如果下拉列表已经显示
			widgets.levelRoot:setVisible(false)				 --则把列表关闭
		else
			widgets.levelRoot:setVisible(true)					--如果没显示就打开下拉列表
			widgets.filterScroll:removeAllChildren();          --清空scroll
			for i = 1, #filterStrs do
				local _item = require("ui/widgets/bphzt1")();
				_item.id = i;
				_item.vars.levelLabel:setText(filterStrs[i].name);
				_item.vars.levelBtn:onClick(self, function ()
					widgets.levelRoot:setVisible(false)                          --点击之后关闭下拉列表
					if state == FILTER_SCENE then
						self._layout.vars.gradeLabel1:setText(_item.vars.levelLabel:getText())  --背包面板的显示更变
						self.filterTypeScene = _item.id
					else
						self.filterType = _item.id
						self:setChoosePeople()
					end
				end)
				widgets.filterScroll:addItem(_item);       --添加到scroll
			end
		end
	end
	widgets.gradeBtn:onClick(self, openFilter)
	widgets.filterBtn:onClick(self, openFilter)
end

--填充文字
function wnd_choosePhotographer:getFilterStrs(state)
	local strs = {}
	if state ==  FILTER_SCENE  then
		return i3k_db_faction_photo.mapCfg
	else
		local startIndex = 1777 
		for index = 1, 4 do
			table.insert(strs, {name = i3k_get_string(1777 + index)})
		end
		return strs
	end
end

--设置选择
function wnd_choosePhotographer:setChoosePeople()
	local state = self.filterType
	if table.nums(self._data) > 0 then
		for k, v in pairs(self._data) do
			if state == OPERATION_CHOOSE_ALL then
				self:setChooseItem(v.widgets, v, true)
			elseif state == OPERATION_ONLINE_ALL then
				self:setChooseItem(v.widgets, v, v.isOnline)
			elseif state == OPERATION_ADMINISTRATION_ALL and v.isFactionPeple then
				self:setChooseItem(v.widgets, v, v.isFactionPeple)
			else
				self:setChooseItem(v.widgets, v, false)
			end
		end		
	end
	self.selectCount:setText(i3k_get_string(1776, self._selectedCount))
end

--选择items
function wnd_choosePhotographer:setChooseItem(widgets, info, isSelect)
	local chiefId = g_i3k_game_context:GetFactionChiefID()
	if info and info.isSelected  ~= isSelect then
		if isSelect then
			widgets.vars.selected:show()
			info.isSelected = true
			self._selectedCount = self._selectedCount + 1
		else
			if info.id ~= chiefId then
				widgets.vars.selected:hide()
				info.isSelected = false
				self._selectedCount = self._selectedCount - 1
			end
		end
	end
end

--设置单个选择
function wnd_choosePhotographer:onSetChoose(sender, info)
	local id = info.id
	local widgets = info.widgets
	if self._data[id] then
		self:setChooseItem(widgets, self._data[id], not self._data[id].isSelected)
		self.selectCount:setText(i3k_get_string(1776, self._selectedCount))
	end
end

--合照
function wnd_choosePhotographer:onTaskPhoto(sender)
	if self._selectedCount < i3k_db_faction_photo.cfgBase.minPeople then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1786, i3k_db_faction_photo.cfgBase.minPeople))
	elseif self._selectedCount > i3k_db_faction_photo.cfgBase.maxPeople  then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1787, i3k_db_faction_photo.cfgBase.maxPeople))
	end
	local selectedInfo = {}
	for k, v in pairs( self._data) do
		if v.isSelected then
			selectedInfo[k] = 1
		end
	end
	i3k_sbean.sect_photo_roles_sync(selectedInfo, i3k_db_faction_photo.mapCfg[self.filterTypeScene])
	self._layout.vars.mask:show()
end

function wnd_create(layout, ...)
	local wnd = wnd_choosePhotographer.new();
		wnd:create(layout, ...);
	return wnd;
end
