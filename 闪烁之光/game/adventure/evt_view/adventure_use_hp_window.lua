-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--     使用药品的
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
AdventureUseHPWindow = AdventureUseHPWindow or BaseClass(BaseView)

local controller = AdventureController:getInstance()
local model = AdventureController:getInstance():getUiModel()
local string_format = string.format
local table_insert = table.insert
local game_net = GameNet:getInstance()

function AdventureUseHPWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
	self.index = 2
	self.layout_name = "adventure/adventure_use_hp_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("adventure", "adventurewindow"), type = ResourcesType.plist},
	}
	self.hero_list = {}
end

function AdventureUseHPWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)

    self.skill_name = container:getChildByName("skill_name")
    self.skill_desc = container:getChildByName("skill_desc")
    self.skill_num = container:getChildByName("skill_num")
    self.skill_num2 = container:getChildByName("skill_num2")

    self.choose_container = container:getChildByName("choose_container")
    self.choose_container:getChildByName("choose_title"):setString(TI18N("请选择使用目标"))
    self.total_width = self.choose_container:getContentSize().width

    self.cancen_btn = self.choose_container:getChildByName("cancen_btn")
    self.cancen_btn:setTitleColor(Config.ColorData.data_color4[1])
    self.cancen_btn:setTitleText(TI18N("取消"))
    self.cancen_btn_label = self.cancen_btn:getTitleRenderer()
    if self.cancen_btn_label ~= nil then
        self.cancen_btn_label:enableOutline(Config.ColorData.data_color4[278], 2)
    end
    self.confirm_btn = self.choose_container:getChildByName("confirm_btn")
    self.confirm_btn:setTitleColor(Config.ColorData.data_color4[1])
    self.confirm_btn:setTitleText(TI18N("确定"))
    self.confirm_btn_label = self.confirm_btn:getTitleRenderer()
    if self.confirm_btn_label ~= nil then
        self.confirm_btn_label:enableOutline(Config.ColorData.data_color4[277], 2)
    end
end

function AdventureUseHPWindow:register_event()
	registerButtonEventListener(self.background, function()
		controller:openAdventureUseHPWindow(false)
	end, false, 2)

	registerButtonEventListener(self.cancen_btn, function()
		controller:openAdventureUseHPWindow(false)
	end, false, 2)

	registerButtonEventListener(self.confirm_btn, function()
		if self.select_cell == nil then
			message(TI18N("请选择使用英雄"))
			return
		end
		local data = self.select_cell:getData()
		if data == nil or data.partner_id == nil or data.partner_id == 0 then
			message(TI18N("数据异常,请关闭重新打开"))
			return
		end

        if self.config then
            controller:send20607(self.config.id, data.partner_id) 
        end
	end, false, 1)
end

function AdventureUseHPWindow:openRootWnd(data)
    if data and data.config then
        self.config = data.config
        self.skill_name:setString(self.config.name)
        self.skill_desc:setString(TI18N("效果：")..self.config.desc)
        
        local num = data.num or 0
        local max_num = self.config.max_num
        if max_num and max_num > 0 then
        	local use_count = data.use_count or 0
            self.skill_num:setString(string_format(TI18N("本轮剩余使用次数：%s"), (max_num-use_count)))
            self.skill_num2:setString(string_format(TI18N("生命药剂剩余：%s"), num))
        else
            self.skill_num:setString(TI18N("剩余数量：")..num)
            self.skill_num2:setString("")
        end

		self:updateHeroList()
    end
end

--==============================--
--desc:更新自己伙伴信息
--time:2019-01-24 05:07:37
--@return 
--==============================--
function AdventureUseHPWindow:updateHeroList()
	local hero_list = model:getFormList()
	local partner_id = model:getSelectPartnerID()

	local scale = 0.8
	local space = 130
	local count = #hero_list
	local tmp_width = count * space * scale -- 总的个数需要的长度
	local start_x =(self.total_width - tmp_width) * 0.5 

	for i, v in ipairs(hero_list) do
		local function clickback(cell, data)
			self:selectHeroItem(cell, data)
		end
		if self.hero_list[i] == nil then
			self.hero_list[i] = HeroExhibitionItem.new(scale, true, 0, true)
    		self.hero_list[i]:setPosition(start_x + (space * 0.5 + (i - 1) * space) * scale, 152)
			self.hero_list[i]:addCallBack(clickback)
			self.choose_container:addChild(self.hero_list[i])
		end
		local hero_item = self.hero_list[i]
		self:updateHeroInfo(hero_item, v)
		
		-- 默认选中一个
		if partner_id ~= 0 then
			if v.partner_id == partner_id then
				self:selectHeroItem(hero_item, v)
			end
		end
	end
end 

--==============================--
--desc:外部设置额外信息
--time:2019-01-24 06:04:06
--@item:
--@data:
--@return 
--==============================--
function AdventureUseHPWindow:updateHeroInfo(item, data)
	if item == nil then return end
	item:setData(data)
	local hp_per = data.now_hp / data.hp
	item:showProgressbar(hp_per * 100)
	if hp_per == 0 then
		item:showStrTips(true, TI18N("已阵亡"))
	else
		item:showStrTips(false)
	end
end 

--==============================--
--desc:设置当前选中的
--time:2019-01-24 07:20:59
--@cell:
--@data:
--@return 
--==============================--
function AdventureUseHPWindow:selectHeroItem(cell, data)
    if data.now_hp == 0 then
        message(TI18N("死亡英雄无法选择"))
        return
    end
	if self.select_cell == cell then return end
	if self.select_cell then
		self.select_cell:setSelected(false)
		self.select_cell = nil
	end
	self.select_cell = cell
	self.select_cell:setSelected(true)
end 

function AdventureUseHPWindow:close_callback()
	for k,v in pairs(self.hero_list) do
		v:DeleteMe()
	end
	self.hero_list = nil
	controller:openAdventureUseHPWindow(false)
end
