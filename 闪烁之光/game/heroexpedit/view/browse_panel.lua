--********************
--宝箱奖励预览
--********************
BrowsePanel = BrowsePanel or BaseClass(BaseView)

local controller = HeroExpeditController:getInstance()
local model = controller:getModel()

local table_insert = table.insert
function BrowsePanel:__init()
    self.is_full_screen = false
    self.layout_name = "heroexpedit/browse_reward_panel"
    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.reward_list = {}
end

function BrowsePanel:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 2) 
    main_container:getChildByName("Image_33"):getChildByName("Text_32"):setString(TI18N("奖励预览"))
    self.btn_con = main_container:getChildByName("btn_con")
    self.btn_con:getChildByName("Text_33"):setString(TI18N("确认"))
    self.good_con = main_container:getChildByName("good_con")
end

function BrowsePanel:openRootWnd(data)
	--关卡奖励
    local data_reward = data.rewards
    if data_reward then
        local num = tableLen(data_reward)
        local pos = {}
        if num == 2 then
        	pos = {108,365}
        else
        	pos = {108,238,365}
        end
        for i=1, num do
        	if not self.reward_list[i] then
    	    	self.reward_list[i] = BackPackItem.new(nil,true)
    		    self.reward_list[i]:setAnchorPoint(0,0.5)
    		    self.good_con:addChild(self.reward_list[i])
    		end
    		if self.reward_list[i] then
    		    self.reward_list[i]:setPosition(cc.p(pos[i], 79))

                if data_reward[i].bid == 25 and data.is_holiday == 1 then
                    self.reward_list[i]:holidHeroExpeditTag(true, TI18N("限时提升"))
                else
                    self.reward_list[i]:holidHeroExpeditTag(false)
                end
                
    		    self.reward_list[i]:setDefaultTip()
    		    self.reward_list[i]:setBaseData(data_reward[i].bid, data_reward[i].num)
    		end
        end
    end
end

function BrowsePanel:register_event()
    registerButtonEventListener(self.background,function()
    	controller:openBrowsePanelView(false)
    end,false,2)
    registerButtonEventListener(self.btn_con,function()
    	controller:openBrowsePanelView(false)
    end,true,2)
end

function BrowsePanel:close_callback()
	if self.itemScrollview then 
        self.itemScrollview:DeleteMe()
        self.itemScrollview = nil
    end
	controller:openBrowsePanelView(false)
end
