--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年4月27日
-- @description    : 
        -- 通用的奖励进度界面
---------------------------------

local controller = ActionController:getInstance()
local model = controller:getModel()

ActionCommonRewardPanel = ActionCommonRewardPanel or BaseClass(BaseView)

function ActionCommonRewardPanel:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
    self.layout_name = "action/action_common_reward_panel"

    self.res_list = {
    }

    self.award_item_list = {}  -- 奖励item列表
end

function ActionCommonRewardPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    if self.background then
        self.background:setScale(display.getMaxScale())
    end

    local container = self.root_wnd:getChildByName("container")
    self.container = container
    self:playEnterAnimatianByObj(self.container, 2)
    self.win_title = container:getChildByName("win_title")

    self.close_btn = container:getChildByName("close_btn")
    self.summon_num_txt = container:getChildByName("title_txt_1")

    self.scrollview_container = container:getChildByName("scrollview_container")
    self.scrollview_container_size = self.scrollview_container:getContentSize()
    self.scroll_view = createScrollView(self.scrollview_container_size.width, self.scrollview_container_size.height, 0, 0, self.scrollview_container, ScrollViewDir.horizontal ) 
    self.scroll_container = self.scroll_view:getInnerContainer() 
    
    self.time_label = container:getChildByName("time_label")
end

function ActionCommonRewardPanel:register_event(  )
    registerButtonEventListener(self.close_btn, function (  )
        controller:openActionCommonRewardPanel(false)
    end, true, 2)
end

--@setting
--@setting.title_name 标题名字 默认 奖励详情
--@setting.cur_txt 显示当前分数的文本  
--@setting.tips tips 
--@setting.max_score --最大显示积分
--@setting.cur_score --当前显示积分
--@setting.score_data_list 结构 {score = xx, reward = {item_id , num}}
--@setting.send_callback -- 发送协议的callback 如果能领取但未领取的,会触发此方法 (未实现)
function ActionCommonRewardPanel:openRootWnd(setting)
    local setting = setting or {}
    local title_name = setting.title_name or TI18N("奖励详情")
    local tips =  setting.tips or TI18N("达到指定积分,可领取对应奖励")
    local cur_txt = setting.cur_txt
    self.win_title:setString(title_name)
    self.time_label:setString(tips)
    if cur_txt then
        self.summon_num_txt:setString(cur_txt)
    end

    --数据信息
    self.max_score = setting.max_score or 0
    self.cur_score = setting.cur_score or 0
    self.score_data_list = setting.score_data_list or {}
    self.send_callback = setting.send_callback
    self:setData()
end

function ActionCommonRewardPanel:setData()
    if #self.score_data_list == 0 then return end
    table.sort(self.score_data_list, function(a, b) return a.score < b.score end )
    if self.max_score == 0 then 
        self.max_score = self.score_data_list[#self.score_data_list].score
    end
    --item的长度 
    local item_width = 84
    --item的间隔
    local space_width = 15
    --开始位置
    local start_x = item_width * 0.5
    local length = #self.score_data_list

    local max_width = (item_width + space_width) * ( length - 1 ) + item_width
    local progress_max_width = max_width - item_width * 0.5 + 2
    local comp_bar = self:newProgressbar(0, progress_max_width)

    if self.scrollview_container_size.width >= max_width then
        self.scroll_view:setTouchEnabled(true)
    end
    
    local container_width = math.max(max_width, self.scrollview_container_size.width)
    local container_size = cc.size(container_width, self.scrollview_container_size.height)
    self.scroll_view:setInnerContainerSize(container_size)

    for i,v in ipairs(self.score_data_list) do
        local item = self.award_item_list[i]
        if item == nil then
            item = ActionRewardProgressItem.new(self.cur_score)
            self.scroll_container:addChild(item)
            self.award_item_list[i] = item
        end
        item:setVisible(true)
        item:setData(v)
        local pos_x = start_x + (i-1) * (item_width + space_width)
        item:setPosition(cc.p(pos_x, 30))
    end
    local last_score = 0
    local first_off = item_width * 0.5
    local distance = 0
    for i,v in ipairs(self.score_data_list) do
        if i == 1 then
            if self.cur_score <= v.score then
                distance = (self.cur_score/v.score)*first_off
                break
            else
                distance = first_off
            end
        else
            if self.cur_score <= v.score then
                distance = distance + ((self.cur_score-last_score)/(v.score-last_score))*(item_width + space_width)
                break
            else
                distance = distance + (item_width + space_width)
            end
        end
        last_score = v.score
    end

    comp_bar:setPercent(distance*100/progress_max_width)
end

--@percent 百分比
--@label 进度条中间文字描述
--@is_blue 是否 ture:蓝条
function ActionCommonRewardPanel:newProgressbar(start_progress_x, progress_max_width)
    if not self.scroll_container then return end
    local size = cc.size(progress_max_width, 19)
    local res = PathTool.getResFrame("common","common_90005")
    local res1 = PathTool.getResFrame("common","common_90006")
    local bg,comp_bar = createLoadingBar(res, res1, size, self.scroll_container, cc.p(0,0.5), start_progress_x, 41, true, true)
    return comp_bar
end

function ActionCommonRewardPanel:close_callback(  )
    for k,item in pairs(self.award_item_list) do
        item:DeleteMe()
        item = nil
    end
    controller:openActionCommonRewardPanel(false)
end

---------------------------@ item
ActionRewardProgressItem = class("ActionRewardProgressItem", function()
    return ccui.Widget:create()
end)

function ActionRewardProgressItem:ctor(cur_score)
    self.cur_score = cur_score
    self:configUI()
    self:register_event()
end

function ActionRewardProgressItem:configUI(  )
    self.size = cc.size(84, 122)
    self:setTouchEnabled(false)
    self:setAnchorPoint(cc.p(0.5, 0))
    self:setContentSize(self.size)

    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setContentSize(self.size)
    self:addChild(self.root_wnd)

    self.award_item = BackPackItem.new(true, true, false, 0.7)
    self.award_item:setDefaultTip(true)
    self.award_item:setAnchorPoint(cc.p(0.5, 1))
    self.award_item:setPosition(cc.p(self.size.width/2, self.size.height))
    self.root_wnd:addChild(self.award_item)

    self.times_txt = createLabel(22,cc.c3b(100,50,35),nil,self.size.width/2,-5,"",self.root_wnd,nil,cc.p(0.5, 1))

    local arrow = createSprite(PathTool.getResFrame("common","common_2031"), self.size.width/2, self.size.height-86, self.root_wnd, cc.p(0.5, 1))
    local line = createSprite(PathTool.getResFrame("common","common_2032"), self.size.width/2, 0, self.root_wnd, cc.p(0.5,0))
end

function ActionRewardProgressItem:setData( data )
    if not data then return end

    local reward = data.reward
    if reward then
        local bid = reward[1]
        local num = reward[2]
        self.award_item:setBaseData(bid, num)
        if data.score <= self.cur_score then
            self.award_item:setReceivedIcon(true)
        else
            self.award_item:setReceivedIcon(false)
        end
    end

    self.times_txt:setString(data.score)
end

function ActionRewardProgressItem:register_event(  )
    
end

function ActionRewardProgressItem:DeleteMe(  )
    if self.award_item then
        self.award_item:DeleteMe()
        self.award_item = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end