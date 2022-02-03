-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      角色升级提示
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
LevupgradeWindow = LevupgradeWindow or BaseClass(BaseView)

local controller = LevupgradeController:getInstance()
local role_vo = RoleController:getInstance():getRoleVo()
local string_format = string.format

function LevupgradeWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Tips
	self.layout_name = "levupgrade/lev_upgrade_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("levupgrade", "levupgrade"), type = ResourcesType.plist},
	}
	self.is_csb_action = true
	self.lev_list = {}
	self.item_list = {}
	self.can_touch = false
	self.auto_limit_time = 5
end 

function LevupgradeWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

	self.main_container = self.root_wnd:getChildByName("main_container")
	self.back_panel = self.main_container:getChildByName("back_panel")
	self.title_container = self.main_container:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

	for i=1,1 do
		local item = self.root_wnd:getChildByName("item_"..i)
		if item then
			local title = item:getChildByName("title")
			if i == 1 then
				title:setString(TI18N("冒险者等级"))
			elseif i == 2 then
				title:setString(TI18N("英雄等级上限"))
			elseif i == 3 then
				title:setString(TI18N("装备精炼上限"))
			end
			local object = {}
			object.last_lev = item:getChildByName("last_lev")
			object.now_lev = item:getChildByName("now_lev")
			self.lev_list[i] = object
		end
	end

	-- 升级奖励
	self.award_container = self.root_wnd:getChildByName("award_container")
	local award_title = self.award_container:getChildByName("award_title")
	award_title:setString(TI18N("升级奖励"))

	-- 扩展类的说明,不一定有
	self.extend_container = self.root_wnd:getChildByName("extend_container")
	self.extend_panel = self.extend_container:getChildByName("extend_panel")
	self.extend_icon = self.extend_panel:getChildByName("icon")
	self.extend_title = self.extend_panel:getChildByName("title")
	self.extend_desc = self.extend_panel:getChildByName("desc")
	self.extend_ext_desc = self.extend_panel:getChildByName("ext_desc")
	self.extend_panel:getChildByName("extend_title"):setString(TI18N("功能预告"))
end

function LevupgradeWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			if self.can_touch  == true then
				self:onClickClose()
			end
		end
	end)
end

function LevupgradeWindow:onClickClose()
    controller:openMainWindow(false)
end

function LevupgradeWindow:openRootWnd(data)
    playOtherSound("c_get") 
	self:handleEffect(true)
	self:starTimeTicket()
	local old_lev = data.old_lev or 0
	local lev = data.lev or 0
	local lev_config = Config.RoleData.data_role_attr[lev]
	if lev_config then
		-- 角色等级
		local role_object = self.lev_list[1]
		role_object.last_lev:setString(old_lev)
		role_object.now_lev:setString(lev)
		local dic_award = {}
		for i=(old_lev+1),lev do
			local lev_cfg = Config.RoleData.data_role_attr[i]
			if lev_cfg and lev_cfg.reward then
				for k,v in pairs(lev_cfg.reward) do
					if v[1] then
						if dic_award[v[1]] == nil then
							dic_award[v[1]] = v[2]
						else
							dic_award[v[1]] = dic_award[v[1]] + v[2]
						end
					end
				end
			end
		end
		self.award_data = {}
		for k,v in pairs(dic_award) do
			table.insert(self.award_data, {k, v})
		end
		self:setAwardInfo()
		self:setExtendInfo(lev_config)
	end
end

-- 升级奖励物品
function LevupgradeWindow:setAwardInfo( )
	if self.award_data == nil then return end
	for k,v in pairs(self.item_list) do
		v:setVisible(false)
	end
	if self.award_data and next(self.award_data) ~= nil then
		local space_x = 20
		local scale = 1
		local panel_size = self.award_container:getContentSize()
		local start_x = panel_size.width/2 - (#self.award_data-1)*(space_x/2+BackPackItem.Width*scale/2)
		for i,v in ipairs(self.award_data) do
			local item = self.item_list[i]
			if item == nil then
				local bid = v[1]
				local num = v[2]
				item = BackPackItem.new(false, true, false, scale, nil, true)
				item:setBaseData(bid, num)
				self.award_container:addChild(item)
				self.item_list[i] = item
			end
			local pos_x = start_x + (i-1)*(space_x+BackPackItem.Width*scale)
			item:setVisible(true)
			item:setPosition(cc.p(pos_x, panel_size.height/2-25))
		end
		self.award_container:setVisible(true)
	else
		self.award_container:setVisible(false)
	end
end

function LevupgradeWindow:setExtendInfo(config)
	if config == nil then return end
	if config.icon == "" then
		self.back_panel:setContentSize(cc.size(SCREEN_WIDTH, 349))
		self.extend_container:setVisible(false)
	else
		self.back_panel:setContentSize(cc.size(SCREEN_WIDTH, 519))
		local path_icon = PathTool.getPlistImgForDownLoad("bigbg/battledrama", config.icon)
		self.res_load = createResourcesLoad(path_icon, ResourcesType.single, function() 
			loadSpriteTexture(self.extend_icon, path_icon, LOADTEXT_TYPE)
		end)
		self.extend_title:setString(config.title)
		self.extend_desc:setString(config.desc)
		self.extend_ext_desc:setString(config.ext_desc)
	end
end

function LevupgradeWindow:starTimeTicket()
	self.cut_time = 0
	if self.time_ticket == nil then
		self.time_ticket = GlobalTimeTicket:getInstance():add(function() 
			self.cut_time = self.cut_time + 0.5
			if self.cut_time > 0.5 then
				self.can_touch = true
			end
			if self.cut_time >= self.auto_limit_time then
				self:onClickClose()
			end
		end, 0.5)
	end
end

function LevupgradeWindow:clearTimeticket()
	if self.time_ticket then
		GlobalTimeTicket:getInstance():remove(self.time_ticket)
		self.time_ticket = nil
	end
end

function LevupgradeWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
		local effect_id = 274
		local action = PlayerAction.action_2
		if not tolua.isnull(self.title_container) and self.play_effect == nil then
			self.play_effect = createEffectSpine(PathTool.getEffectRes(effect_id), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, action)
			self.title_container:addChild(self.play_effect, 1)
		end
	end
end 

function LevupgradeWindow:close_callback()
	self:handleEffect(false)
	if self.res_load then
		self.res_load:DeleteMe()
	end
	self.res_load = nil
	GlobalEvent:getInstance():Fire(BattleEvent.NEXT_SHOW_RESULT_VIEW)

	self:clearTimeticket()
	for k,item in pairs(self.item_list) do
		item:DeleteMe()
		item = nil
	end
    controller:openMainWindow(false)
end