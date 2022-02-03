-- --------------------------------------------------------------------
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      精灵蛋合成界面
-- <br/> 2020年2月19日
-- --------------------------------------------------------------------
ElfinEggSyntheticPanel = ElfinEggSyntheticPanel or BaseClass(BaseView)

local controller = ElfinController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local string_format = string.format

function ElfinEggSyntheticPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "elfin/elfin_egg_synthetic_panel"
    self.cur_selected_sum = 1                       -- 当前选中消耗的数量
    self.max_num = 1 -- 最大可选择数量
    self.have_egg_num = 0 -- 拥有的蛋
    self.need_egg_num = 0 -- 合成一个需要低级蛋数量的数量
    self.need_cost_num = 0 -- 合成一个需要消耗金币数量
    self.cost_name = "" -- 消耗物名字
    self.egg_name_1 = "" -- 合成精灵蛋名字
    self.egg_name_2 = "" -- 合成后精灵蛋名字
    self.res_list = {
    }

end

function ElfinEggSyntheticPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.title = self.main_container:getChildByName("win_title")
    self.title:setString(TI18N("合成"))
    self.Text_2 = self.main_container:getChildByName("Text_2")
    self.Text_2:setString(TI18N("消耗："))
    self.left_btn = self.main_container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("取 消"))

    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn_lab = self.right_btn:getChildByName("label")
    self.right_btn_lab:setString(TI18N("确认消耗"))

    self.tips_lab = self.main_container:getChildByName("tips_lab")
    self.icon_img = self.main_container:getChildByName("icon_img")
    self.con_num = self.main_container:getChildByName("con_num")
    
    self.left_item_1 = BackPackItem.new(true, true,nil,nil,nil,true)
    self.left_item_1:setAnchorPoint(0.5, 0.5)
    self.left_item_1:setPosition(self.main_container:getContentSize().width / 2-160, 302.00)
    self.main_container:addChild(self.left_item_1)
    

    self.right_item_1 = BackPackItem.new(true, true,nil,nil,nil,true)
    self.right_item_1:setAnchorPoint(0.5, 0.5)
    self.right_item_1:setPosition(self.main_container:getContentSize().width / 2+170, 302.00)
    self.main_container:addChild(self.right_item_1)


    self.container = self.main_container:getChildByName("container")
    self.container_y = self.container:getPositionY()

    self.sub_btn = self.container:getChildByName("sub_btn")                                 -- 减号
    self.add_btn = self.container:getChildByName("add_btn")                                 -- 加号
    self.max_btn = self.container:getChildByName("max_btn")                                 -- 最大值
    self.slider = self.container:getChildByName("slider")                                   -- 滑块
    self.slider:setBarPercent(20, 80)

    self.close_btn = self.main_container:getChildByName("close_btn")

end

function ElfinEggSyntheticPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self._onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self._onClickBtnClose) ,true, 1)
    registerButtonEventListener(self.left_btn, handler(self, self._onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.right_btn, handler(self, self._onClickBtnRight) ,true, 2)

    if self.slider ~= nil then
    	self.slider:addEventListener(function ( sender,event_type )
    		if event_type == ccui.SliderEventType.percentChanged then
                self:setCurUseItemInfoByPercent(self.slider:getPercent())
    		end
    	end)
    end

    self.sub_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            local percent = self.slider:getPercent()
            if percent == 0 then return end --已经是最小的了
            if self.cur_selected_sum == 0 then return end
            self.cur_selected_sum = self.cur_selected_sum - 1
            self:setCurUseItemInfoByNum(self.cur_selected_sum)
        end
    end)
    self.add_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            local percent = self.slider:getPercent()
            if percent == 100 then return end --已经是最大的了
            if self.cur_selected_sum >= self.max_num then return end
            self.cur_selected_sum = self.cur_selected_sum + 1
            self:setCurUseItemInfoByNum(self.cur_selected_sum)
        end
    end)
    self.max_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            local percent = self.slider:getPercent()
            if percent == 100 then return end --已经是最大的了
            if self.cur_selected_sum >= self.max_num then return end
            self.cur_selected_sum = self.max_num
            self:setCurUseItemInfoByNum(self.cur_selected_sum)
        end
    end)

end

--关闭
function ElfinEggSyntheticPanel:_onClickBtnClose()
    controller:openElfinEggSyntheticPanel(false)
end

--确认消耗
function ElfinEggSyntheticPanel:_onClickBtnRight()
    if self.elfin_bid then
		controller:sender26508(self.elfin_bid, self.cur_selected_sum, 0)
	end
end

--@
function ElfinEggSyntheticPanel:openRootWnd(elfin_bid)
    self.elfin_bid = elfin_bid
   self:setData()
    
end

--==============================--
--desc:设置当前进度的相关数据
--time:2020-03-05 21:01:59
--@percent:
--@return 
--==============================--
function ElfinEggSyntheticPanel:setCurUseItemInfoByPercent(percent)
    self.cur_selected_sum = math.max(1, math.floor( percent * self.max_num * 0.01 ))
    self:setUseInfo(self.cur_selected_sum)
end

function ElfinEggSyntheticPanel:setCurUseItemInfoByNum(num)
    self.cur_selected_sum = math.max(1, num)
    local all_num =math.max(1,self.max_num-1)
    local percent = (self.cur_selected_sum-1) / all_num  * 100
    self.slider:setPercent(percent)
    self:setUseInfo(self.cur_selected_sum)
end

function ElfinEggSyntheticPanel:setUseInfo(sum)
    sum = math.min(self.max_num,sum)
    self.left_item_1:setNeedNum(sum*self.need_egg_num,self.have_egg_num)
    self.right_item_1:setNum(sum)
    local cost_num = sum*self.need_cost_num
    local temp_str = "" .. cost_num
    if cost_num>=10000 then
        temp_str  = math.floor( cost_num/10000 ) ..TI18N("万")
    end
    self.con_num:setString(temp_str)
    self.tips_lab:setString(string_format(TI18N("是否确认消耗%s，使用 %s*%d\n合成 %s*%d"),self.cost_name,self.egg_name_1,sum*self.need_egg_num,self.egg_name_2,sum))
 
end

function ElfinEggSyntheticPanel:setData()
    if not self.elfin_bid then return end
    
    local com_cfg = Config.SpriteData.data_elfin_com[self.elfin_bid]
    if not com_cfg then return end
    local have_num = 0
    local cost_num = 0
    for i,v in ipairs(com_cfg.expend) do
		local item_bid = v[1]
		local item_num = v[2]
		local item_cfg = Config.ItemData.data_get_data(item_bid)
        if item_cfg then
            if i == 1 then
                self.egg_name_1 = item_cfg.name
                self.need_egg_num = item_num+1
                have_num = BackpackController:getInstance():getModel():getItemNumByBid(item_bid)
                self.have_egg_num = have_num
                local vo = {}
                vo = deepCopy(item_cfg)
                self.left_item_1:setData(vo)
            else
                self.cost_name = item_cfg.name
                self.need_cost_num = item_num
                cost_num = BackpackController:getInstance():getModel():getItemNumByBid(item_bid)
                loadSpriteTexture(self.icon_img, PathTool.getItemRes(item_cfg.icon), LOADTEXT_TYPE)
            end
		end
    end

    
    
    local next_elfin_bid = com_cfg.award
    local next_elfin_item_cfg = Config.ItemData.data_get_data(next_elfin_bid)
    if next_elfin_item_cfg then
        local vo_2 = {}
        vo_2 = deepCopy(next_elfin_item_cfg)
        if vo_2 then
            self.egg_name_2 = vo_2.name
        end
        self.right_item_1:setData(vo_2)
    end

    have_num = math.floor( have_num/self.need_egg_num )
    cost_num = math.floor( cost_num/self.need_cost_num )
    if math.min(have_num,cost_num) >0 then
        self.max_num = math.min(have_num,cost_num)
    end

    self:setCurUseItemInfoByNum(self.max_num)
end


function ElfinEggSyntheticPanel:close_callback()
  

    if self.left_item_1 then
        self.left_item_1:DeleteMe()
    end
    self.left_item_1 = nil

    if self.right_item_1 then
        self.right_item_1:DeleteMe()
    end
    self.right_item_1 = nil


    controller:openElfinEggSyntheticPanel(false)
end