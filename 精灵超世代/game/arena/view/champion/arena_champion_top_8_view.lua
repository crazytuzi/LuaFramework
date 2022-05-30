--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-07-25 16:57:38
-- @description    : 
		-- 跨服冠军赛8强
---------------------------------
ArenaChampionTop8View = class("ArenaChampionTop8View", function()
	return ccui.Layout:create()
end)

local table_insert = table.insert
local table_sort = table.sort

function ArenaChampionTop8View:ctor(view_type)
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("arena/arena_champion_top_8_item"))

    self.view_type = view_type or ArenaConst.champion_type.normal
    if self.view_type == ArenaConst.champion_type.normal then
        self.ctrl = ArenaController:getInstance()
        self.model = self.ctrl:getChampionModel()
    else
        self.ctrl = CrosschampionController:getInstance()
        self.model = self.ctrl:getModel()
    end
	
	self.size = self.root_wnd:getContentSize()
	self:setContentSize(self.size)
	
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd) 

	local container = self.root_wnd:getChildByName("container")

	self.champion_container = container:getChildByName("champion_container")
	self.head_container = self.champion_container:getChildByName("head_container")

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setScale(1.2)
    self.role_head:setPosition(128, 60)
    self.head_container:addChild(self.role_head)

    self.pos_line_list = {}
    self.role_pos_list = {}
    self.role_name_list = {}
    self.check_btn_list = {}
    for i=1, 14 do
        local pos_line = container:getChildByName("pos_line_"..i)
        if pos_line then
            local normal_1 = pos_line:getChildByName("normal_1")
            local normal_2 = pos_line:getChildByName("normal_2")
            local select_1 = pos_line:getChildByName("select_1")
            local select_2 = pos_line:getChildByName("select_2")
            local object = {}
            object.normal_1 = normal_1
            object.normal_2 = normal_2
            object.select_1 = select_1
            object.select_2 = select_2
            select_1:setVisible(false)
			if select_2 then
            	select_2:setVisible(false)
			end
            self.pos_line_list[i] = object
        end
		local role_pos = container:getChildByName("role_pos_"..i) 
		if role_pos then
            local normal = role_pos:getChildByName("normal")
            local select = role_pos:getChildByName("select")
            local object = {}
            object.normal = normal
            object.select = select
            select:setVisible(false)
            self.role_pos_list[i] = object
		end
		local role_name = container:getChildByName("role_name_"..i)
        if role_name then
            self.role_name_list[i] = role_name
            role_name:setString("")
        end

        local check_btn = container:getChildByName("check_btn_"..i)
        if check_btn then
            self.check_btn_list[i] = check_btn
            check_btn:setVisible(false)
        end
    end

	self.pos_line_list_2 = {}
    for i=1,5 do
        local _index_1 = (i - 1) * 2 + 1
        local _index_2 = i * 2
        local pos_line = container:getChildByName(string.format("pos_line_%s_%s", _index_1, _index_2))
        if pos_line then
            local normal = pos_line:getChildByName("normal")
            local select = pos_line:getChildByName("select")
            local object = {}
            object.normal = normal
            object.select = select
            select:setVisible(false)
            self.pos_line_list_2[getNorKey(_index_1, _index_2)] = object
        end
    end

    self.guess_btn = container:getChildByName("guess_btn")
    self.guess_btn:getChildByName("label"):setString(TI18N("竞猜"))
    self.guess_btn:setVisible(false)

	self:registerEvent()
end

function ArenaChampionTop8View:registerEvent()
    for k,check_btn in pairs(self.check_btn_list) do
        check_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                GlobalEvent:getInstance():Fire(ArenaEvent.CheckFightInfoEvent, true, 0, k) 
            end
        end)
    end
    self.guess_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
			GlobalEvent:getInstance():Fire(ArenaEvent.ChangeTanFromTop324)
        end
    end)
end

function ArenaChampionTop8View:addToParent(status)
	self:setVisible(status)
    self:handleEvent(status)
end

function ArenaChampionTop8View:updateInfo(status)
	local base_info = self.model:getBaseInfo()
	local role_info = self.model:getRoleInfo()
	if base_info == nil or role_info == nil then return end
	self.is_change_tab = status
	if status == true or base_info.flag ~= 0 then
        if self.view_type == ArenaConst.champion_type.normal then
            self.ctrl:requestTop4Info()
        else
            self.ctrl:sender26210()
        end
	end
end 

function ArenaChampionTop8View:handleEvent(status)
    if status == false then
        if self.update_top32_info_event ~= nil then
            GlobalEvent:getInstance():UnBind(self.update_top32_info_event)
            self.update_top32_info_event = nil
        end
        if self.update_324_guess_event ~= nil then
            GlobalEvent:getInstance():UnBind(self.update_324_guess_event)
            self.update_324_guess_event = nil
        end
    else
        if self.update_top32_info_event == nil then
            self.update_top32_info_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateTop4InfoEvent, function(list)
				self:updateTop4Info(list)
            end)
        end

        if self.update_324_guess_event == nil then
            self.update_324_guess_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateTop324GuessGroupEvent, function(group,pos)
				if group ~= 0 or pos == 0 then return end
				self:updateCheckStatus(pos)
			end)
        end
    end
end

--==============================--
--desc:设置观看录像的位置
--time:2018-08-06 03:17:30
--@pos:
--@return 
--==============================--
function ArenaChampionTop8View:updateCheckStatus(pos)
	local check_btn = self.check_btn_list[pos]
	if check_btn then
        self.guess_btn:setPosition(check_btn:getPositionX(), check_btn:getPositionY())
	end
end

--==============================--
--desc:设置4强数据
--time:2018-08-06 02:30:21
--@list:
--@return 
--==============================--
function ArenaChampionTop8View:updateTop4Info(list)
	if list == nil or next(list) == nil then return end
	-- 拍一下序
    local pos_list = list
    table_sort(pos_list, function(a, b) 
        return a.pos < b.pos
    end)

    for k,role_name in pairs(self.role_name_list) do
        local pos_info = pos_list[k]
        if pos_info then
            role_name:setString(pos_info.name)
            if pos_info.ret == 0 then -- 未打
                role_name:setTextColor(Config.ColorData.data_color4[175])
            elseif pos_info.ret == 1 then -- 胜利
                role_name:setTextColor(Config.ColorData.data_color4[175])
            else
                role_name:setTextColor(cc.c4b(0x5b,0x5b,0x5b,0xff))
            end
            -- 姓名下面的底框
            local role_bg = self.role_pos_list[k]
            if role_bg then 
                if role_bg.select then
                    role_bg.select:setVisible(pos_info.ret == 1)
                end
                if role_bg.normal then
                    if pos_info.ret == 2 then
                        setChildUnEnabled(true, role_bg.normal)
                    else
                        setChildUnEnabled(false, role_bg.normal)
                    end
                end
            end

            -- 独立线条
            local line_list = self.pos_line_list[k]
            if line_list and line_list.select_1 then
                line_list.select_1:setVisible(pos_info.ret == 1)
				if line_list.select_2 then
                	line_list.select_2:setVisible(pos_info.ret == 1)
				end
            end
            -- 公共线条,只要打过了,那么就找出这个公共线条
            local check_index = 0
            local public_index = 0
            if k % 2 == 0 then
                check_index = k - 1
                public_index = getNorKey(check_index, k)
            else
                check_index = k
                public_index = getNorKey(check_index, k + 1)
            end
            local check_btn = self.check_btn_list[check_index]
            if check_btn then
                check_btn:setVisible(true)
            end
			local line_list_2 = self.pos_line_list_2[public_index] 
			if line_list_2 and line_list_2.select then
				line_list_2.select:setVisible(pos_info.ret ~= 0)
			end
        end
    end
    -- 取出第15位用于设置头像,第15位就是冠军
    local champion_data = pos_list[15]
    if champion_data and champion_data.rid ~= 0 then
        self.role_head:setHeadRes(champion_data.face, false, LOADTEXT_TYPE, champion_data.face_file, champion_data.face_update_time)
    else
        self.role_head:clearHead()
    end

	-- 请求一下竞猜数据
    if self.view_type == ArenaConst.champion_type.normal then
        self.ctrl:requestGuessGroupInfo() 
    else
        self.ctrl:sender26211() 
    end
end

function ArenaChampionTop8View:DeleteMe()
	self:handleEvent(false)
end