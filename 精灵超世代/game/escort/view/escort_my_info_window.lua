-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      我的雇佣信息面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
EscortMyInfoWindow = EscortMyInfoWindow or BaseClass(BaseView)

local controller = EscortController:getInstance()
local model = controller:getModel()
local game_net = GameNet:getInstance()
local role_vo = RoleController:getInstance():getRoleVo()
local partner_model = HeroController:getInstance():getModel()
local table_insert = table.insert 
local string_format = string.format
local table_sort = table.sort

function EscortMyInfoWindow:__init()
    self.is_full_screen = false
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
	self.layout_name = "escort/escort_my_info_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("escort", "escort"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_52"), type = ResourcesType.single}, 
	}

	self.assets_icon = 0
	self.assets_num = 0
	self.partner_list = {} 
	self.item_list = {}
end

function EscortMyInfoWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 1)
	local main_panel = main_container:getChildByName("main_panel") 
	main_panel:getChildByName("win_title"):setString(TI18N("我的信息"))
	main_panel:getChildByName("title"):setString(TI18N("雇佣奖励"))
	main_panel:getChildByName("name_title"):setString(TI18N("玩家名字:")) 
	main_panel:getChildByName("guild_title"):setString(TI18N("公会:")) 
	main_panel:getChildByName("power_title"):setString(TI18N("战斗力:")) 
	main_panel:getChildByName("form_title"):setString(TI18N("我的阵容")) 
	
	self.close_btn = main_panel:getChildByName("close_btn") 

	self.finish_btn = main_panel:getChildByName("finish_btn")
	self.finish_btn_label = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(115,33))
	self.finish_btn:addChild(self.finish_btn_label)

	self.form_icon = main_panel:getChildByName("form_icon")		-- 阵法信息,sprite
	self.item_name = main_panel:getChildByName("item_name")		-- 雇佣名字,区分颜色
	self.time = main_panel:getChildByName("time")				-- 剩余时间
	self.name_value = main_panel:getChildByName("name_value")	-- 玩家名字
	self.guild_value = main_panel:getChildByName("guild_value")	-- 公会名字
	self.power_value = main_panel:getChildByName("power_value")	-- 战力
	self.form_value = main_panel:getChildByName("form_value")	-- 阵法名称和等级

	self.main_width = main_panel:getContentSize().width
	self.main_panel = main_panel

	-- 配置表
	self.finish_config = DeepCopy(Config.EscortData.data_finish)
	table_sort(self.finish_config, function(a, b) 
		return a.end_time > b.end_time
	end)
end

function EscortMyInfoWindow:register_event()
	if self.close_btn then
		self.close_btn:addTouchEventListener(function(sender, event_type)
			customClickAction(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				controller:openEscortMyInfoWindow(false) 
			end
		end)
	end
	if self.finish_btn then
		self.finish_btn:addTouchEventListener(function(sender, event_type) 
			customClickAction(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				if self.my_info then
					if self.my_info.status == 1 then
						if self.my_info.end_time <= game_net:getTime() then
							controller:requestGetEscortAwards()
						else
							if self.assets_icon ~= 0 then
								local msg = string.format(TI18N("是否花费 <img src=%s visible=true scale=0.5 />%s 快速完成本次护送?"), PathTool.getItemRes(self.assets_icon), self.assets_num)
								CommonAlert.show(msg, TI18N("确定"), function()
									controller:requestUseAssetsFinishEscort()
								end, TI18N("取消"), nil, CommonAlert.type.rich) 
							end
						end
					end
				end
			end
		end)
	end
end

function EscortMyInfoWindow:openRootWnd()
	self.my_info = model:getMyInfo()
	if self.my_info then
		self:createBaseInfo()
		self:createMyFormList()
		self:createRewardsList()
		self:createTimeTicket()
	end
end

function EscortMyInfoWindow:clearTimeTicket()
	if self.time_ticket then
		self.time_ticket = GlobalTimeTicket:getInstance():remove(self.time_ticket)
		self.time_ticket = nil
	end
end

function EscortMyInfoWindow:createTimeTicket()
	if self.my_info == nil then return end
	if self.my_info.status == 1 then
		if self.my_info.end_time <= game_net:getTime() then  --这个时候表示已经可以提交了
			self.finish_btn_label:setString(TI18N("领取奖励"))
			self.time:setVisible(false)
		else
			if self.time_ticket == nil then
				self.time_ticket = GlobalTimeTicket:getInstance():add(function()
					self:timeTicketCount()
				end, 1)
			end
			self:timeTicketCount()
			self.time:setVisible(true)
		end
	end
end

function EscortMyInfoWindow:timeTicketCount()
	if self.my_info == nil then
		self:clearTimeTicket()
		return
	end
	local _time = self.my_info.end_time - game_net:getTime()
	if _time <= 0 then
		self:clearTimeTicket()
		self.finish_btn_label:setString(TI18N("领取奖励"))
		self.time:setVisible(false)
	else
		self.time:setString(string_format(TI18N("剩余时间:%s"), TimeTool.GetTimeFormat(_time)))
		self:setCanUseAssets(_time)
	end
end

--==============================--
--desc:设置当前剩余时间需要消耗的资产数
--time:2018-09-04 01:25:45
--@return 
--==============================--
function EscortMyInfoWindow:setCanUseAssets(time)
	local assets_config = nil
	for i,v in ipairs(self.finish_config) do
		if time >= v.end_time then
			assets_config = v
			break
		end
	end
	if assets_config == nil or assets_config.expend == nil or assets_config.expend[1] == nil or assets_config.expend[1][1] == nil or assets_config.expend[1][2] == nil then return end
	if self.assets_config == assets_config.expend[1] then return end
	self.assets_config = assets_config.expend[1]
	local bid = self.assets_config[1]
	local num = self.assets_config[2]
	local item_config = Config.ItemData.data_get_data(bid)
	if item_config then
		self.assets_icon = item_config.icon			-- 记录一下当前消耗的图标和时间
		self.assets_num = num
		local str = string.format("<img src=%s visible=true scale=0.35 />,<div fontColor=#ffffff fontsize=24 outline=1,#C45A14>%s %s</div>", PathTool.getItemRes(item_config.icon), num, TI18N("立即完成")) 
		self.finish_btn_label:setString(str) 
	end
end

function EscortMyInfoWindow:createBaseInfo()
	if self.my_info == nil then return end
	local config = Config.EscortData.data_baseinfo[self.my_info.quality]
	if config then
		self.item_name:setString(config.title)
		local color = EscortConst.quality_color[self.my_info.quality]
		if color then
			self.item_name:setTextColor(color)
		end
		if self.player == nil then
			self.player = createEffectSpine(config.res, cc.p(142, 588), cc.p(0.5,0.5), true, PlayerAction.action_1)
			self.player:setScale(0.9)
			self.main_panel:addChild(self.player)
		end
	end
	if role_vo.gid == 0 then
		self.guild_value:setString(TI18N("暂无"))
	else
		self.guild_value:setString(role_vo.gname)
	end
	self.power_value:setString(role_vo.power)
	self.name_value:setString(role_vo.name)

	-- local form_type, form_lev = partner_model:getMyUseForm()
	-- if form_type then
	-- 	local form_config = Config.FormationData.data_form_data[form_type]
	-- 	if form_config then
	-- 		self.form_value:setString(form_config.name.."Lv."..(form_lev or 0))

			-- local res = "res/resource/form/form_form_icon_"..form_type..".png"
			-- loadSpriteTexture(self.form_icon, res, ccui.TextureResType.localType)
	-- 	end
	-- end
end

function EscortMyInfoWindow:createMyFormList()
	local list = partner_model:getMyPosList()
	if list and next(list) then
		local tmp_list = {}
		for i,v in pairs(list) do
			local vo = partner_model:getHeroById(v.id)
			if vo then
				table_insert(tmp_list, vo)
			end
		end
		self.partner_list = {}
		local offx = 10
		if next(tmp_list) then
			local p_list_size = #tmp_list
			local total_width = p_list_size * 104 + (p_list_size - 1) * offx
			local start_x = ( self.main_width - total_width ) / 2 
			local partner_item = nil
			for i,v in ipairs(tmp_list) do
				partner_item = HeroExhibitionItem.new(1, false)
				partner_item:setPosition(start_x+104*0.5+(i-1)*(104+offx), 410)
				partner_item:setData(v)
				self.main_panel:addChild(partner_item)
				table_insert( self.partner_list, partner_item )
			end
		end
	end
end

function EscortMyInfoWindow:createRewardsList()
	if self.my_info == nil or self.my_info.quality == nil then return end
	local awards_config = Config.EscortData.data_rewards(getNorKey(self.my_info.quality, role_vo.lev)) 
	if awards_config == nil or awards_config.award == nil or awards_config.plunder_award == nil then return end

	local plunder_count = self.my_info.plunder_count	-- 被打劫的人数,最后得到的奖励要根据这个人数确定
	if self.my_info.quality == BackPackConst.quality.orange then
		plunder_count = 0
	end
	
	local plunder_award_list = {}
	if plunder_count ~= 0 then
		for i,v in ipairs(awards_config.plunder_award) do
			if v[1] and v[2] then
				plunder_award_list[v[1]] = v[2] * plunder_count
			end
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
	local _x, _y = 0, 218
	local sum = #awards_config.award
	local item_conf = nil
	local total_width = sum * BackPackItem.Width * scale + (sum - 1) * off
	local start_x =(self.main_width - total_width) / 2 
	local assets_config = Config.ItemData.data_assets_id2label
	for i, v in ipairs(awards_config.award) do
		if v[1] and v[2] then
			local bid = v[1]
			local num = v[2] * num_scale
			item_conf = Config.ItemData.data_get_data(bid)
			if item_conf then
				item = BackPackItem.new(false, true, false, scale, false, true)
				_x = start_x + (BackPackItem.Width * scale + off) * (i-1) + BackPackItem.Width*scale*0.5
				item:setBaseData(bid)
				item:setPosition(_x, _y)
				self.main_panel:addChild(item)
				table.insert(self.item_list, item)
				local deduct_num = plunder_award_list[bid] 
				if deduct_num then
					deduct_num = deduct_num * num_scale 
					item:setExtendDesc(true, (num-deduct_num).."(-"..deduct_num..")", 183)
				else
					item:setExtendDesc(true, num, 175) 
				end
				item:setDoubleIcon(is_double)
			end
		end
	end 
end

function EscortMyInfoWindow:close_callback()
	self:clearTimeTicket()
	for i,v in ipairs(self.partner_list) do
		v:DeleteMe()
	end
	self.partner_list = nil

	for i,v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = nil

    controller:openEscortMyInfoWindow(false)
end