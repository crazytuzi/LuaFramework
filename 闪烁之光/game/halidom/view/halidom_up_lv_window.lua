--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-11 17:26:08
-- @description    : 
		-- 圣物升级
---------------------------------
HalidomUpLvWindow = HalidomUpLvWindow or BaseClass(BaseView)

local _controller = HalidomController:getInstance()
local _model = _controller:getModel()

function HalidomUpLvWindow:__init()
	self.win_type = WinType.Big
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.res_list = {
	}
    self.is_csb_action = true
	self.layout_name = "hallows/hallows_step_up_window"
    self.item_list = {}
end

function HalidomUpLvWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale()) 

	self.title_container = self.root_wnd:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

	self.main_container = self.root_wnd:getChildByName("main_container")
	self.Sprite_1 = self.main_container:getChildByName("Sprite_1")
	if self.sprite_1_load == nil then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_97")
        self.sprite_1_load = loadSpriteTextureFromCDN(self.Sprite_1, res, ResourcesType.single, self.sprite_1_load)
    end
    
	self.Sprite_2 = self.main_container:getChildByName("Sprite_2")
	if self.sprite_2_load == nil then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_98")
        self.sprite_2_load = loadSpriteTextureFromCDN(self.Sprite_2, res, ResourcesType.single, self.sprite_2_load)
    end
	
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

function HalidomUpLvWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            _controller:openHalidomUpLvWindow(false)
		end
	end)
end

function HalidomUpLvWindow:openRootWnd(id)
	playOtherSound("c_get")
	self:handleEffect(true) 
	if id then
		self.halidom_vo = _model:getHalidomDataById(id)
		if not self.halidom_vo then return end
		self.base_cfg = Config.HalidomData.data_base[id]
		self.all_skill_cfg = Config.HalidomData.data_lvup[id]
		if self.halidom_vo and self.base_cfg and self.all_skill_cfg then
			self:setBaseInfo()
			self:setAttrInfo()
		end
	end
end

function HalidomUpLvWindow:setBaseInfo()
	self.hallows_name:setString(self.base_cfg.name)
	self.old_step:setString((self.halidom_vo.lev-1)..TI18N("级"))
	self.cur_step:setString(self.halidom_vo.lev..TI18N("级"))
end

function HalidomUpLvWindow:setAttrInfo()
	local old_config = self.all_skill_cfg[self.halidom_vo.lev - 1]
	local cur_config = self.all_skill_cfg[self.halidom_vo.lev]
	if old_config == nil or cur_config == nil then return end
	local add_count = old_config.total_exp/old_config.exp - 1
	for i,v in ipairs(old_config.attr) do
		if i > 2 then break end
		local attr_key = v[1]
		local attr_val = v[2]
		local attr_name = Config.AttrData.data_key_to_name[attr_key]
		if attr_name then
			local add_val = 0
			for _,eAttr in pairs(old_config.exp_attr) do
				if eAttr[1] == attr_key then
					add_val = add_count * eAttr[2]
					break
				end
			end
			attr_val = attr_val + add_val
			local is_per = PartnerCalculate.isShowPerByStr(attr_key)
            if is_per == true then
                attr_val = (attr_val/10) .."%"
            end
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
		local attr_val = v[2]
		local attr_name = Config.AttrData.data_key_to_name[attr_key]
		if attr_name then
			local object = self.item_list[i]
			local is_per = PartnerCalculate.isShowPerByStr(attr_key)
            if is_per == true then
                attr_val = (attr_val/10) .."%"
            end
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

function HalidomUpLvWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
		if not tolua.isnull(self.title_container) and self.play_effect == nil then
			self.play_effect = createEffectSpine(PathTool.getEffectRes(189), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, PlayerAction.action)
			self.title_container:addChild(self.play_effect, 1)
		end
	end
end 

function HalidomUpLvWindow:close_callback()
	self:handleEffect(false)
	if self.sprite_1_load then
        self.sprite_1_load:DeleteMe()
        self.sprite_1_load = nil
    end

    if self.sprite_2_load then
        self.sprite_2_load:DeleteMe()
        self.sprite_2_load = nil
	end
    _controller:openHalidomUpLvWindow(false)
end