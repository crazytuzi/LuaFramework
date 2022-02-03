-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      神器/幻化激活面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
HallowsActivityWindow = HallowsActivityWindow or BaseClass(BaseView)

local controller = HallowsController:getInstance()
local model = controller:getModel()
local string_format = string.format

function HallowsActivityWindow:__init()
	self.win_type = WinType.Big
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("hallows", "hallows"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("levupgrade", "levupgrade"), type = ResourcesType.plist},
	}
    self.is_csb_action = true
	self.layout_name = "hallows/hallows_activity_window"
end 

function HallowsActivityWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	
    self.main_container = self.root_wnd:getChildByName("main_container")
	self.title_container = self.main_container:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height
    self.hallows_name = self.main_container:getChildByName("hallows_name")
    self.desc = self.main_container:getChildByName("desc")
    self.desc:setString(TI18N("全体上阵英雄"))

    self.close_btn = self.main_container:getChildByName("close_btn")
    self.close_btn:getChildByName("label"):enableOutline(Config.ColorData.data_color4[264], 2)
    self.close_btn:getChildByName("label"):setString(TI18N("关闭"))
    self.goto_btn = self.main_container:getChildByName("goto_btn")
    self.goto_btn:getChildByName("label"):enableOutline(Config.ColorData.data_color4[264], 2)
    self.goto_btn:getChildByName("label"):setString(TI18N("前往幻化"))

    local item_1 = self.root_wnd:getChildByName("item_1")
    self.attr_1 = createRichLabel(24, cc.c3b(0xff,0xe8,0xb7), cc.p(0, 0.5), cc.p(160, 20))
    item_1:addChild(self.attr_1)
    self.attr_2 = createRichLabel(24, cc.c3b(0xff,0xe8,0xb7), cc.p(0, 0.5), cc.p(430, 20))
    item_1:addChild(self.attr_2)
end

function HallowsActivityWindow:register_event()
	self.close_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openHallowsActivityWindow(false)
		end
	end)

	-- 前往幻化
	registerButtonEventListener(self.goto_btn, function (  )
		if self.step_config then
			if self.step_config.is_item == 2 then -- 自动解锁的情况，要打开神器界面，并且打开幻化界面
				MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.hallows, nil, {0, HallowsConst.Tab_Index.uplv, self.step_config.id})
			end
			controller:openHallowsActivityWindow(false)
		end
	end, true)
end

function HallowsActivityWindow:openRootWnd(data, open_type)
    self.data = data
    self.open_type = open_type or HallowsConst.Activity_Type.Hallows
	playOtherSound("c_get")
	self:handleEffect(true) 
	if data then
		if self.open_type == HallowsConst.Activity_Type.Hallows then
			self.step_config = Config.HallowsData.data_info(getNorKey(data.id, data.step))
			self.desc:setString(TI18N("全体上阵英雄"))
			self.goto_btn:setVisible(false)
			self.close_btn:setPositionX(360)
		elseif self.open_type == HallowsConst.Activity_Type.Magic then
			self.step_config = Config.HallowsData.data_magic[data.id]
			self.desc:setString(TI18N("全神器对英雄属性提升"))
			self.goto_btn:setVisible(true)
			self.close_btn:setPositionX(216)
		end
		if self.step_config  then
			self.hallows_name:setString(self.step_config.name)
			local attr_list = self.step_config.attr
			for i=1,2 do
				self["attr_"..i]:setString("")
			end
			if attr_list and next(attr_list) then
				for i,v in ipairs(attr_list) do
					if i > 2 then break end
					local attr_key = v[1]
					local attr_val = v[2]
					local attr_name = Config.AttrData.data_key_to_name[attr_key]
					if attr_name then
						local is_per = PartnerCalculate.isShowPerByStr(attr_key)
						if is_per then
							attr_val = (attr_val/10) .."%"
						end
						local str = string_format("%s<div fontcolor=#ffffff>    +%s</div>", attr_name, attr_val) 
						self["attr_" .. i]:setString(str) 
					end
				end
			end

			self:updateHallowsBaseInfo()
		end
	end
end

function HallowsActivityWindow:updateHallowsBaseInfo()
	if self.step_config == nil then return end
	self.hallows_model = createEffectSpine(self.step_config.effect, cc.p(360, 228), cc.p(0.5, 0.5), true, PlayerAction.action_2)
	self.main_container:addChild(self.hallows_model)
end 

function HallowsActivityWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
		local effect_id = 549
		local action = PlayerAction.action_1
		if self.open_type == HallowsConst.Activity_Type.Magic then
			action = PlayerAction.action_2
		end
		if not tolua.isnull(self.title_container) and self.play_effect == nil then
			self.play_effect = createEffectSpine(PathTool.getEffectRes(effect_id), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, action)
			self.title_container:addChild(self.play_effect, 1)
		end
	end
end 

function HallowsActivityWindow:close_callback()
    self:handleEffect(false)
    controller:openHallowsActivityWindow(false)
end