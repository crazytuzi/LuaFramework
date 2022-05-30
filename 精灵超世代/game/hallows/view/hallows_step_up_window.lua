-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      圣器进阶成功的界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
HallowsStepUpWindow = HallowsStepUpWindow or BaseClass(BaseView)

local controller = HallowsController:getInstance()
local model = HallowsController:getInstance():getModel()
local string_format = string.format

function HallowsStepUpWindow:__init()
	self.win_type = WinType.Big
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.res_list = {
	}
	self.is_csb_action = true
	self.layout_name = "hallows/hallows_step_up_window"
	self.item_list = {}
end

function HallowsStepUpWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

	self.title_container = self.root_wnd:getChildByName("title_container")
	self.title_width = self.title_container:getContentSize().width
	self.title_height = self.title_container:getContentSize().height

	self.main_container = self.root_wnd:getChildByName("main_container")
	--self.Sprite_1 = self.main_container:getChildByName("Sprite_1")
	--if self.sprite_1_load == nil then
	--    local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_97")
	--    self.sprite_1_load = loadSpriteTextureFromCDN(self.Sprite_1, res, ResourcesType.single, self.sprite_1_load)
	--end
	--
	--self.Sprite_2 = self.main_container:getChildByName("Sprite_2")
	--if self.sprite_2_load == nil then
	--    local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_98")
	--    self.sprite_2_load = loadSpriteTextureFromCDN(self.Sprite_2, res, ResourcesType.single, self.sprite_2_load)
	--end

	self.hallows_name = self.main_container:getChildByName("hallows_name")
	self.old_step = self.main_container:getChildByName("old_step")
	self.cur_step = self.main_container:getChildByName("cur_step")

	for i=1,2 do
		local item = self.main_container:getChildByName("item_"..i)
		if item then
			local object = {}
			object.item = item
			object.title = item:getChildByName("title")
			object.last_lev = item:getChildByName("last_lev")
			object.now_lev = item:getChildByName("now_lev")
			object.arrow = item:getChildByName("arrow")
			object.title:setString("")
			object.last_lev:setString("")
			object.now_lev:setString("")
			object.arrow:setVisible(false)

			self.item_list[i] = object
		end
	end
end

function HallowsStepUpWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openHallowsStepUpWindow(false)
		end
	end)
end

function HallowsStepUpWindow:openRootWnd(id)
	playOtherSound("c_get")
	self:handleEffect(true)
	if id then
		self.data = model:getHallowsById(id)
		self.data_config = Config.HallowsData.data_base[id]
		if self.data and self.data_config then
			self:setBaseInfo()
			self:setAttrInfo()
		end
	end
end

function HallowsStepUpWindow:setBaseInfo()
	if self.data == nil or self.data_config == nil then return end
	self.hallows_name:setString(self.data_config.name)
	self.old_step:setString((self.data.step-1)..TI18N("级"))
	self.cur_step:setString(self.data.step..TI18N("级"))
end

function HallowsStepUpWindow:setAttrInfo()
	if self.data == nil then return end
	local vo = self.data

	local old_config = Config.HallowsData.data_info(getNorKey(vo.id, vo.step-1))
	local cur_config = Config.HallowsData.data_info(getNorKey(vo.id, vo.step))
	if old_config == nil or cur_config == nil then return end
	for i,v in ipairs(old_config.attr) do
		if i > 2 then break end
		local attr_key = v[1]
		local attr_val = changeBtValueForHeroAttr(v[2], attr_key)
		local attr_name = Config.AttrData.data_key_to_name[attr_key]
		if attr_name then
			local object = self.item_list[i]
			if object then
				object.title:setString(attr_name)
				object.last_lev:setString(attr_val)
			end
		end
	end

	for i,v in ipairs(cur_config.attr) do
		if i > 2 then break end
		local attr_key = v[1]
		local attr_val = changeBtValueForHeroAttr(v[2], attr_key)
		local attr_name = Config.AttrData.data_key_to_name[attr_key]
		if attr_name then
			local object = self.item_list[i]
			if object then
				object.arrow:setVisible(true)
				object.now_lev:setString(attr_val)

				-- 如果上一阶没有这个属性.那么上一阶显示0
				if old_config.attr[i] == nil then
					object.title:setString(attr_name)
					object.last_lev:setString(0)
				end
			end
		end
	end
end

function HallowsStepUpWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
		if not tolua.isnull(self.title_container) and self.play_effect == nil then
			self.play_effect = createEffectSpine(PathTool.getEffectRes(103), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, PlayerAction.action4)
			self.title_container:addChild(self.play_effect, 1)
		end
	end
end

function HallowsStepUpWindow:close_callback()
	--if self.sprite_1_load then
	--    self.sprite_1_load:DeleteMe()
	--    self.sprite_1_load = nil
	--end
	--
	--if self.sprite_2_load then
	--    self.sprite_2_load:DeleteMe()
	--    self.sprite_2_load = nil
	--end
	controller:openHallowsStepUpWindow(false)
end