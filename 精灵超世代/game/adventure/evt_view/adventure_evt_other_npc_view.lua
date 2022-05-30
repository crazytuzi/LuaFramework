-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      另外一种npcd对话的,
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
AdventureEvtOtherNpcWindow = AdventureEvtOtherNpcWindow or BaseClass(BaseView)

local controller = AdventureController:getInstance()
local string_format = string.format

function AdventureEvtOtherNpcWindow:__init(data)
    self.win_type = WinType.Big
    self.data = data
    self.config = data.config
    self.layout_name = "adventure/adventure_evt_other_npc_view"
    self.is_full_screen = false
    self.item_list = {}
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("adventure", "adventure"), type = ResourcesType.plist },
    }
    self.btn_list = {}
end

function AdventureEvtOtherNpcWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
    self.title_label = container:getChildByName("title_label")
    self.title_label:setString(TI18N("神秘事件"))
    self.close_btn = container:getChildByName("close_btn")
    self.swap_desc_label = createRichLabel(24, 175, cc.p(0.5, 1), cc.p(338, 320), nil, nil, 610)
    container:addChild(self.swap_desc_label)

	self.item_bg = container:getChildByName("item_bg")

    self.container = container
end

function AdventureEvtOtherNpcWindow:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openEvtViewByType(false) 
        end
    end)
    if not self.update_npc_info then
        self.update_npc_info = GlobalEvent:getInstance():Bind(AdventureEvent.Update_Evt_Npc_Info,function (data)
            self:updateAnswerData(data)
        end)
    end
end

function AdventureEvtOtherNpcWindow:openRootWnd()
    self:updatedata()
    if self.data then
        controller:send20620(self.data.id, AdventureEvenHandleType.requst, {})
    end
end

function AdventureEvtOtherNpcWindow:updateAnswerData(data)
	if self.config and data then
		local npc_answer_config = Config.AdventureData.data_adventure_npc_data[data.evt_id][data.id]
		if npc_answer_config == nil or next(npc_answer_config) == nil then return end
		
		local btn_size = cc.size(604, 87)
		local count = 0
		table.sort(npc_answer_config, function(a, b)
			return a.num < b.num
		end)

		local item_config = Config.ItemData.data_get_data 
		for i, v in ipairs(npc_answer_config) do
			if i == 1 then
            	self.swap_desc_label :setString(v.lable_desc)
			end
			if not self.btn_list[i] then
				local btn = createButton(self.item_bg, "", 0, 0, btn_size, PathTool.getResFrame("common", "common_2043"), 26, Config.ColorData.data_color4[175], PathTool.getResFrame("common", "common_1020"))
				btn:setCapInsets(cc.rect(96, 36, 1, 1))
				btn:getRoot():setVisible(false)
				local tag = createSprite(PathTool.getResFrame("common", "common_1043"), 520, btn_size.height / 2, btn:getRoot())
				tag:setVisible(false)
				btn.i = i
				btn.tag = tag
				self.btn_list[i] = btn
			end
			local btn = self.btn_list[i]
			if btn then
				btn:getRoot():setVisible(true)
				local extend_str = ""
				if v.lose then
					for _, item in ipairs(v.lose) do
						if extend_str ~= "" then
							extend_str = extend_str..","
						end
						local bid = item[1]
						local num = item[2]
						local _config = item_config(bid)
						if _config then
							extend_str = extend_str..string_format("<img src='%s' scale=0.4 />  ", PathTool.getItemRes(_config.icon))..num
						end
					end
					if extend_str ~= "" then
						extend_str = string_format(TI18N("<div fontcolor=#a95f0f>(消耗 %s)</div>"), extend_str)
					end
				end
				btn:setRichText(TI18N(v.msg).."  "..extend_str,24,175--[[,line_space,ap]])
				btn:setPosition(self.item_bg:getContentSize().width / 2, 140 -(btn_size.height + 5) * math.floor((i - 1)))
				if btn then
					btn:addTouchEventListener(function(sender, event_type)
						if event_type == ccui.TouchEventType.began then
							if self.btn_list then
								for i, btn in ipairs(self.btn_list) do
									if btn then
										btn.tag:setVisible(false)
									end
								end
							end
						elseif event_type == ccui.TouchEventType.ended then
							if self.data then
								local ext_list = {{type = 1, val = btn.i}}
								btn.tag:setVisible(true)
								controller:send20620(self.data.id, AdventureEvenHandleType.handle, ext_list)
							end
						elseif event_type == ccui.TouchEventType.canceled then
							btn.tag:setVisible(false)
						end
					end, true)
				end
			end
		end
	end
end 

function AdventureEvtOtherNpcWindow:updatedata()
    if self.config then
        self.swap_desc_label:setString(self.config.desc)
        self:createEffect(self.config.effect_str)
    end
end

function AdventureEvtOtherNpcWindow:createEffect(bid)
	local res_data = bid[1]
	local res_type = res_data[1]    -- 1.图片资源(如果是怪物或者boss事件的,就创建特效) 2.特效资源
    local res_id = res_data[2]  -- 资源名字
    if res_type == nil or res_id == nil then return end
    if res_type == 2 then
		if not tolua.isnull(self.container) and self.box_effect == nil then
			self.box_effect = createEffectSpine(res_id, cc.p(353, 433), cc.p(0.5, 0.5), true, PlayerAction.action)
			self.box_effect:setScale(1.5)
			self.container:addChild(self.box_effect)
		end
	else
		local res = PathTool.getPlistImgForDownLoad("adventure/evt", res_id)
		local bg = createImage(self.container, res, 353, 433, cc.p(0.5, 0.5), false)
		bg:setScale(1.5)
	end
	-- if bid ~= "" then
	-- 	if not tolua.isnull(self.container) and self.box_effect == nil then
	-- 		self.box_effect = createEffectSpine(bid, cc.p(353, 433), cc.p(0.5, 0.5), true, PlayerAction.action)
	-- 		self.box_effect:setScale(1.5)
	-- 		self.container:addChild(self.box_effect)
	-- 	end
	-- end
end 

function AdventureEvtOtherNpcWindow:close_callback()
	if self.update_npc_info then
		GlobalEvent:getInstance():UnBind(self.update_npc_info)
		self.update_npc_info = nil
	end
    controller:openEvtViewByType(false) 
end
