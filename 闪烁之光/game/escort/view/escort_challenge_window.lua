-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      复仇或者公会帮助击退界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
EscortChallengeWindow = EscortChallengeWindow or BaseClass(BaseView)

local controller = EscortController:getInstance()
local model = controller:getModel()
local table_insert = table.insert 

--==============================--
--desc:
--time:2018-09-01 08:11:49
--@type: EscortConst.challenge_type 1:复仇 2:击退
--@return 
--==============================--
function EscortChallengeWindow:__init(type)
    self.is_full_screen = false
	self.challenge_type = type
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
	self.partner_list = {}
	self.item_list = {}
	self.layout_name = "escort/escort_challenge_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("escort", "escort"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("form", "form"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_52"), type = ResourcesType.single}, 
	}
end

function EscortChallengeWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 2)
	local main_panel = main_container:getChildByName("main_panel") 
	main_panel:getChildByName("name_title"):setString(TI18N("玩家名字:")) 
	main_panel:getChildByName("guild_title"):setString(TI18N("公会:")) 
	main_panel:getChildByName("power_title"):setString(TI18N("战斗力:")) 
	main_panel:getChildByName("form_title"):setString(TI18N("对方阵容")) 
	main_panel:getChildByName("server_title"):setString(TI18N("服务器:"))
	
	self.close_btn = main_panel:getChildByName("close_btn") 
	self.challenge = main_panel:getChildByName("challenge")
	
	if self.challenge_type == EscortConst.challenge_type.revenge then
		self.challenge:getChildByName("label"):setString(TI18N("立即复仇"))
		main_panel:getChildByName("title"):setString(TI18N("复仇成功奖励"))
		main_panel:getChildByName("win_title"):setString(TI18N("复仇"))
		main_panel:getChildByName("times_title"):setString(TI18N("今日复仇次数:")) 
	else
		self.challenge:getChildByName("label"):setString(TI18N("立即击退"))
		main_panel:getChildByName("title"):setString(TI18N("击退成功奖励"))
		main_panel:getChildByName("win_title"):setString(TI18N("击退")) 
		main_panel:getChildByName("times_title"):setString(TI18N("今日击退次数:")) 
	end

	self.form_icon = main_panel:getChildByName("form_icon")		-- 阵法信息,sprite
	self.times_value = main_panel:getChildByName("times_value")	-- 剩余次数
	self.name_value = main_panel:getChildByName("name_value")	-- 玩家名字
	self.guild_value = main_panel:getChildByName("guild_value")	-- 公会名字
	self.power_value = main_panel:getChildByName("power_value")	-- 战力
	self.form_value = main_panel:getChildByName("form_value")	-- 阵法名称和等级
	self.server_value = main_panel:getChildByName("server_value")	-- 服务器名字

	self.role_head = PlayerHead.new(PlayerHead.type.circle)
	self.role_head:setPosition(146, 606)
	self.role_head:setLev(99)
	main_panel:addChild(self.role_head)

	self.main_width = main_panel:getContentSize().width
	self.main_panel = main_panel 
end

function EscortChallengeWindow:register_event()
	if self.close_btn then
		self.close_btn:addTouchEventListener(function(sender, event_type)
			customClickAction(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				controller:openEscortChallengeWindow(false) 
			end
		end)
	end
	if self.challenge then
		self.challenge:addTouchEventListener(function(sender, event_type) 
			customClickAction(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				if self.data then
					controller:requestAtkPlunderPlayer(self.data.rid, self.data.srv_id, self.data.id) 
				end
			end
		end)
	end
end

function EscortChallengeWindow:openRootWnd(data)
	self.data = data
	if data then
		local num_1 = 0
		local num_2 = 0
		if self.challenge_type == EscortConst.challenge_type.revenge then		-- 复仇
			num_1 = model:getMyCount(EscortConst.times_type.atk_back)
			num_2 = model:getMyMaxCount(EscortConst.times_type.atk_back)
		else
			num_1 = model:getMyCount(EscortConst.times_type.do_help)
			num_2 = model:getMyMaxCount(EscortConst.times_type.do_help)
		end
		num_1 = num_2-num_1
		if num_1 < 0 then num_1 = 0 end
		self.times_value:setString(num_1.."/"..num_2)

		self:createBaseInfo()
		self:createFormList()
		self:createRewardsList()
	end
end

function EscortChallengeWindow:createBaseInfo()
	if self.data == nil then return end
	self.role_head:setHeadRes(self.data.face)
	self.role_head:setLev(self.data.lev)
	if self.data.guild_name == "" then
		self.guild_value:setString(TI18N("暂无"))
	else
		self.guild_value:setString(self.data.guild_name)
	end
	self.power_value:setString(self.data.power)
	self.name_value:setString(self.data.name)
	self.server_value:setString(getServerName(self.data.srv_id))

	local form_type = self.data.formation_type or 1
	local form_lev = self.data.formation_lev or 1
	if form_type then
		local form_config = Config.FormationData.data_form_data[form_type]
		if form_config then
			self.form_value:setString(form_config.name.."Lv."..(form_lev or 0))

			local form_res = PathTool.getResFrame("form","form_icon_"..form_type)
			loadSpriteTexture(self.form_icon, form_res, LOADTEXT_TYPE_PLIST)
		end
	end
end

function EscortChallengeWindow:createFormList()
	if self.data == nil then return end
	
	local list = self.data.p_list
	if list and next(list) then
		self.partner_list = {}
		local offx = 10
		local p_list_size = #list
		local total_width = p_list_size * 104 +(p_list_size - 1) * offx
		local start_x =(self.main_width - total_width) / 2
		local partner_item = nil
		for i, v in ipairs(list) do
			partner_item = HeroExhibitionItem.new(1, false)
			partner_item:setPosition(start_x + 104 * 0.5 +(i - 1) *(104 + offx), 380)
			partner_item:setData(v)
			self.main_panel:addChild(partner_item)
			table_insert(self.partner_list, partner_item)
		end
	end
end 

function EscortChallengeWindow:createRewardsList()
	if self.data == nil then return end
	local awards_config = Config.EscortData.data_rewards(getNorKey(self.data.quality, self.data.lev))
	if awards_config == nil or awards_config.plunder_award == nil then return end

	local awards_list = DeepCopy(awards_config.plunder_award)

	-- 如果是击退,就是帮助人点开的,那么不是完整复仇奖励
	local multiple = 1
	if self.challenge_type == EscortConst.challenge_type.repel then
		local const_config = Config.EscortData.data_const.request_reward
		if const_config  and const_config.val then
			multiple = const_config.val * 0.001
		end
	else
		local revenge_config = Config.EscortData.data_const.revenge_reward 
		if revenge_config  and revenge_config.val then
			multiple = revenge_config.val * 0.001
		end
	end
	for i, v in ipairs(awards_list) do
		if v[2] then
			v[2] = math.floor(v[2] * multiple)
		end
	end
	self.item_list = {}
	local is_double = model:isDoubleTimes() or false
	local num_scale = 1
	if is_double == true then
		num_scale = 2
	end
	local item = nil
	local scale = 0.9
	local off = 40
	local _x, _y = 0, 180
	local sum = #awards_list
	local item_conf = nil
	local total_width = sum * BackPackItem.Width * scale +(sum - 1) * off
	local start_x =(self.main_width - total_width) / 2
	local assets_config = Config.ItemData.data_assets_id2label
	for i, v in ipairs(awards_list) do
		if v[1] and v[2] then
			local bid = v[1]
			local num = v[2] * num_scale
			item_conf = Config.ItemData.data_get_data(bid)
			if item_conf then
				item = BackPackItem.new(false, true, false, scale, false, true)
				_x = start_x +(BackPackItem.Width * scale + off) *(i - 1) + BackPackItem.Width * scale * 0.5
				item:setBaseData(bid, num)
				item:setPosition(_x, _y)
				item:setDoubleIcon(is_double)
				self.main_panel:addChild(item)
				table_insert(self.item_list, item)
			end
		end
	end
end 

function EscortChallengeWindow:close_callback()
	if self.role_head then
		self.role_head:DeleteMe()
		self.role_head = nil
	end
	for i,v in ipairs(self.partner_list) do
		v:DeleteMe()
	end
	self.partner_list = nil

	for i,v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = nil
    controller:openEscortChallengeWindow(false)
end