--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-11-02 20:32:50
-- @description    : 
		-- 天梯英雄殿
---------------------------------
LadderTopThreeWindow = LadderTopThreeWindow or BaseClass(BaseView)

local controller = LadderController:getInstance()
local model = controller:getModel()

function LadderTopThreeWindow:__init()
	self.win_type = WinType.Big
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "ladder/ladder_top_three_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("ladder", "ladder"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("arena", "arenaenter"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_59"), type = ResourcesType.single },
        {path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_60"), type = ResourcesType.single },
	}

	self.state_list = {}
end

function LadderTopThreeWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName('background')
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 1) 

    local title_label = main_container:getChildByName("title_label")
    title_label:setString(TI18N("英雄殿"))
    local tips_label = main_container:getChildByName("tips_label")
    tips_label:setString(TI18N("*每日点赞可获天梯积分奖励"))

    self.close_btn = main_container:getChildByName("close_btn")

    for i=1,3 do
    	local statue = main_container:getChildByName(string.format("statue_%d", i))
    	local desc = statue:getChildByName("desc")
    	desc:setString(TI18N("虚位以待"))
    	local state_data = {}
    	state_data.model = statue:getChildByName("model")
    	state_data.role_name = statue:getChildByName("role_name")
    	state_data.guild_name = statue:getChildByName("guild_name")
    	state_data.worship_btn = statue:getChildByName("worship_btn")
    	state_data.label = state_data.worship_btn:getChildByName("label")
    	state_data.btn_check = statue:getChildByName("btn_check")
    	state_data.desc = desc
    	state_data.worship_num = 0
    	self.state_list[i] = state_data
    end

end

function LadderTopThreeWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickBtnClose), false, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickBtnClose), false, 2)
	for i=1,3 do
		local state_data = self.state_list[i]
		if state_data and state_data.worship_btn then
			registerButtonEventListener(state_data.worship_btn, function ( )
				self:_onClickBtnWorship(i)
			end, true)
		end
		if state_data and state_data.btn_check then
			registerButtonEventListener(state_data.btn_check, function ( )
				self:_onClickBtnCheck(i)
			end)
		end
	end

	if self.ladder_top_three_event == nil then
        self.ladder_top_three_event = GlobalEvent:getInstance():Bind(LadderEvent.UpdateLadderTopThreeRoleData, function ( data )
            self:setData(data)
        end)
    end

    if self.update_worship_event == nil then
        self.update_worship_event = GlobalEvent:getInstance():Bind(RoleEvent.WorshipOtherRole, function(rid, srv_id, idx)
            if idx ~= nil and self.state_list[idx] then
                local state_panel = self.state_list[idx]
                state_panel.worship_num = state_panel.worship_num + 1
                state_panel.label:setString(state_panel.worship_num)
                state_panel.worship_btn:setTouchEnabled(false)
                setChildUnEnabled(true, state_panel.worship_btn, Config.ColorData.data_color4[1])
                state_panel.label:enableOutline(cc.c3b(0x4b,0x4b,0x4b), 2)
            end
        end)
    end
end

function LadderTopThreeWindow:_onClickBtnWorship( index )
	local data = self:getRoleDataByRank(index)
	if data then
		local rid = data.rid
		local srv_id = data.srv_id
		RoleController:getInstance():requestWorshipRole(rid, srv_id, index, WorshipType.ladder)
	end
end

function LadderTopThreeWindow:_onClickBtnCheck( index )
	local data = self:getRoleDataByRank(index)
	if data then
		local rid = data.rid
		local srv_id = data.srv_id
		FriendController:getInstance():openFriendCheckPanel(true, {srv_id = srv_id, rid = rid})
	end
end

function LadderTopThreeWindow:setData( data )
	data = data or {}
	self.data = data

	for i=1,3 do
		local state_panel = self.state_list[i]
		local role_data = self:getRoleDataByRank(i)
		if role_data then
			state_panel.model:setVisible(true)
			state_panel.role_name:setVisible(true)
			state_panel.guild_name:setVisible(true)
			state_panel.worship_btn:setVisible(true)
			state_panel.btn_check:setVisible(true)
			state_panel.desc:setVisible(false)

			state_panel.role_name:setString(role_data.name)
			local gname = role_data.gname
			if not gname or gname == "" then
				gname = TI18N("暂无")
			end
			state_panel.guild_name:setString(string.format(TI18N("公会:%s"), gname))
			state_panel.label:setString(role_data.worship)
			state_panel.worship_num = role_data.worship
			if role_data.worship_status == 0 then
				setChildUnEnabled(false, state_panel.worship_btn)
				state_panel.worship_btn:setTouchEnabled(true)
			else
				setChildUnEnabled(true, state_panel.worship_btn, Config.ColorData.data_color4[1])
                state_panel.label:enableOutline(cc.c3b(0x4b,0x4b,0x4b), 2)
				state_panel.worship_btn:setTouchEnabled(false)
			end

			if state_panel.role_model then
				state_panel.role_model:DeleteMe()
				state_panel.role_model = nil
			end

			if role_data.lookid then
				state_panel.role_model = BaseRole.new(BaseRole.type.role, role_data.lookid)
			    state_panel.role_model:setAnimation(0,PlayerAction.show,true) 
			    state_panel.role_model:setCascade(true)
			    state_panel.role_model:setPosition(cc.p(50, 130))
			    state_panel.model:addChild(state_panel.role_model)
			end
		else
			state_panel.model:setVisible(false)
			state_panel.role_name:setVisible(false)
			state_panel.guild_name:setVisible(false)
			state_panel.worship_btn:setVisible(false)
			state_panel.btn_check:setVisible(false)
			state_panel.desc:setVisible(true)
		end
	end
end

function LadderTopThreeWindow:getRoleDataByRank( rank )
	self.data = self.data or {}
	local role_data
	for k,v in pairs(self.data) do
		if v.rank == rank then
			role_data = v
			break
		end
	end
	return role_data
end

function LadderTopThreeWindow:_onClickBtnClose(  )
	controller:openLadderTopThreeWindow(false)
end

function LadderTopThreeWindow:openRootWnd(  )
	controller:requestTopThreeRoleData()
end

function LadderTopThreeWindow:close_callback(  )
	if self.ladder_top_three_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.ladder_top_three_event)
        self.ladder_top_three_event = nil
    end

    if self.update_worship_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_worship_event)
        self.update_worship_event = nil
    end

    for k,state_panel in pairs(self.state_list) do
    	if state_panel.role_model then
    		state_panel.role_model:DeleteMe()
    		state_panel.role_model = nil
    	end
    end
    model:updateLadderRedStatus(LadderConst.RedType.TopThree, false)
	controller:openLadderTopThreeWindow(false)
end