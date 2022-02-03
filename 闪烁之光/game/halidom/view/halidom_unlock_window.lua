--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-12 15:40:54
-- @description    : 
		-- 圣物解锁界面
---------------------------------
HalidomUnlockWindow = HalidomUnlockWindow or BaseClass(BaseView)

local _controller = HalidomController:getInstance()
local _model = _controller:getModel()
local string_format = string.format

function HalidomUnlockWindow:__init()
	self.win_type = WinType.Mini
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("levupgrade", "levupgrade"), type = ResourcesType.plist},
	}
    self.is_csb_action = true
	self.layout_name = "hallows/hallows_activity_window"
end

function HalidomUnlockWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	
    self.main_container = self.root_wnd:getChildByName("main_container")
	self.title_container = self.main_container:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height
    self.hallows_name = self.main_container:getChildByName("hallows_name")
    self.desc = self.main_container:getChildByName("desc")

    self.close_btn = self.main_container:getChildByName("close_btn")
    self.close_btn:setPositionX(360)
    self.close_btn:getChildByName("label"):enableOutline(Config.ColorData.data_color4[264], 2)
    self.close_btn:getChildByName("label"):setString(TI18N("关闭"))
    self.goto_btn = self.main_container:getChildByName("goto_btn")
    self.goto_btn:setVisible(false)

    local item_1 = self.root_wnd:getChildByName("item_1")
    self.attr_1 = createRichLabel(24, cc.c3b(0xff,0xe8,0xb7), cc.p(0, 0.5), cc.p(160, 20))
    item_1:addChild(self.attr_1)
    self.attr_2 = createRichLabel(24, cc.c3b(0xff,0xe8,0xb7), cc.p(0, 0.5), cc.p(430, 20))
    item_1:addChild(self.attr_2)
end

function HalidomUnlockWindow:register_event(  )
	self.close_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            _controller:openHalidomUnlockWindow(false)
		end
	end)
end

function HalidomUnlockWindow:openRootWnd( id )
	if not id then return end

	self.base_cfg = Config.HalidomData.data_base[id]
	self.halidom_vo = _model:getHalidomDataById(id)

	if self.base_cfg and self.halidom_vo then
		self:setData()
	end
end

function HalidomUnlockWindow:setData(  )
	if not self.base_cfg or not self.halidom_vo then return end

	local all_lv_cfg = Config.HalidomData.data_lvup[self.halidom_vo.id]
	if not all_lv_cfg then return end
	local lv_cfg = all_lv_cfg[self.halidom_vo.lev]
	if not lv_cfg then return end

	playOtherSound("c_get")
	self:handleEffect(true) 
	-- 名称
	self.hallows_name:setString(self.base_cfg.name)
	-- 提示
	local camp_name = HeroConst.CampName[self.base_cfg.camp]
	self.desc:setString(string_format(TI18N("对所有%s系英雄属性提升"), camp_name))
	-- 属性值
	for i=1,2 do
		self["attr_"..i]:setString("")
	end
	if lv_cfg.attr and next(lv_cfg.attr) then
		for i,v in ipairs(lv_cfg.attr) do
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

	-- 圣物
	if self.base_cfg.effect_id then
		self.halidom_model = createEffectSpine(PathTool.getEffectRes(self.base_cfg.effect_id), cc.p(360, 380), cc.p(0.5, 0.5), true, PlayerAction.action_2)
		self.main_container:addChild(self.halidom_model)
	end
end

function HalidomUnlockWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
		if not tolua.isnull(self.title_container) and self.play_effect == nil then
			self.play_effect = createEffectSpine(PathTool.getEffectRes(549), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, PlayerAction.action_3)
			self.title_container:addChild(self.play_effect, 1)
		end
	end
end 

function HalidomUnlockWindow:close_callback()
    self:handleEffect(false)
    if self.halidom_model then
    	self.halidom_model:clearTracks()
		self.halidom_model:removeFromParent()
		self.halidom_model = nil
    end
    _controller:openHalidomUnlockWindow(false)
end