-- --------------------------------------------------------------------
-- 开工福利
-- --------------------------------------------------------------------
StartWorkPanel = class("StartWorkPanel", function()
	return ccui.Widget:create()
end)

local string_format = string.format
function StartWorkPanel:ctor(bid)
	self.holiday_bid = bid
	self.btn_reward_list = {}
	self:loadResources()
end
function StartWorkPanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("startwork","startwork"), type = ResourcesType.plist },
    } 
    self.resources_load = ResourcesLoad.New(true) 
    self.resources_load:addAllList(self.res_list,function()
    	if self.loadResListCompleted then
	    	self:loadResListCompleted()
	    end
	end)
end
function StartWorkPanel:loadResListCompleted()
	self:createRootWnd()
	self:roundSprite()
	self:registerEvent()
end
function StartWorkPanel:createRootWnd()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/start_work_panel"))
	self:addChild(self.root_wnd)
	self:setPosition(-40, -80)
	self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")
    local bg = main_container:getChildByName("bg")
    local bg_path = PathTool.getPlistImgForDownLoad("bigbg/welfare", "welfare_startwork")
    if not self.load_bg then
	    self.load_bg = loadSpriteTextureFromCDN(bg, bg_path, ResourcesType.single)
	end
	self.holiday_time = main_container:getChildByName("Text_7")
	self.holiday_time:setString(TI18N("活动时间："))
	main_container:getChildByName("Text_8"):setString(TI18N("活动说明：周六、周日、周一登录可领取"))

	for i=1,3 do
		local tab = {}
		tab.btn = main_container:getChildByName("week_gift_"..i)
		tab.flag = tab.btn:getChildByName("flag")
		tab.round = tab.btn:getChildByName("Sprite_2")
		tab.flag:setVisible(false)
		tab.text_1 = tab.btn:getChildByName("reward_bg"):getChildByName("text_1")
		tab.text_1:setString("")
		tab.text_2 = tab.btn:getChildByName("reward_bg"):getChildByName("text_2")
		tab.text_2:setString("")
		self.btn_reward_list[i] = tab
	end

	ActionController:getInstance():cs16603(self.holiday_bid)
end

function StartWorkPanel:roundSprite()
	for i=1,3 do
		if self.btn_reward_list and self.btn_reward_list[i] then
			if self.btn_reward_list[i].round then
				local res = PathTool.getResFrame("startwork","startwork0"..(i+1))
				loadSpriteTexture(self.btn_reward_list[i].round, res, LOADTEXT_TYPE_PLIST)
			end
		end
	end
end

function StartWorkPanel:stopRoundAction()
	for i,v in pairs(self.btn_reward_list) do
		if v.round then
			doStopAllActions(v.round)
		end
	end
end
--签到奖励
--0：未激活 1：已激活 2：已领取 3：已过期
function StartWorkPanel:signReward(data)
	if not data.aim_list or next(data.aim_list) == nil then return end
	self:stopRoundAction()
	for i,v in ipairs(data.aim_list) do
		if v.status == 1 then
			self.btn_reward_list[i].flag:setVisible(false)
			local skewto_1 = cc.SkewTo:create(0.3, 3, 0)
			local skewto_2 = cc.SkewTo:create(0.3, -3, 0)
			local skewto_3 = cc.SkewTo:create(0.4, 0, 0)
			local seq = cc.Sequence:create(skewto_1,skewto_2, skewto_1,skewto_2,skewto_3,cc.DelayTime:create(1))
			local repeatForever = cc.RepeatForever:create(seq)
		    self.btn_reward_list[i].round:runAction(repeatForever)
		elseif v.status == 2 then
			self.btn_reward_list[i].flag:setVisible(true)
			loadSpriteTexture(self.btn_reward_list[i].flag, PathTool.getResFrame("startwork","txt_cn_startwork02"), LOADTEXT_TYPE_PLIST)
		elseif v.status == 3 then
			self.btn_reward_list[i].flag:setVisible(true)
			loadSpriteTexture(self.btn_reward_list[i].flag, PathTool.getResFrame("startwork","txt_cn_startwork01"), LOADTEXT_TYPE_PLIST)
		else
			self.btn_reward_list[i].flag:setVisible(false)
		end

		if v.item_list then
			for k,item in ipairs(v.item_list) do
				if k == 1 then
					local item_config = Config.ItemData.data_get_data(item.bid)
					if item_config then
						local str = string_format("%s*%d",item_config.name,item.num)
						self.btn_reward_list[i].text_1:setString(str)
					end
				else
					local item_config = Config.ItemData.data_get_data(item.bid)
					if item_config then
						local str = string_format("%s*%d",item_config.name,item.num)
						self.btn_reward_list[i].text_2:setString(str)
					end
				end
			end
		end
	end
end
--活动时间
function StartWorkPanel:holidayTime(data)
	if data.args then
		local start_time,end_time
	    local start_list = keyfind('args_key', 1, data.args) or nil
	    if start_list then
	    	start_time = start_list.args_val
	    end
	    local end_list = keyfind('args_key', 2, data.args) or nil
	    if end_list then
	    	end_time = end_list.args_val
	    end                
	    if start_time and end_time then
	        local time_str = string_format(TI18N("活动时间：%s 至 %s"),TimeTool.getYMD2(start_time),TimeTool.getYMD2(end_time))
	        self.holiday_time:setString(time_str)
	    end
	end
end

function StartWorkPanel:registerEvent()
	if self.start_welfare_event == nil then
        self.start_welfare_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function(data)
            if data.bid == self.holiday_bid then
                self.data = data
                self:signReward(data)
                self:holidayTime(data)
            end
        end)
    end

	for i,v in pairs(self.btn_reward_list) do
		registerButtonEventListener(v.btn, function()
			if not self.data then return end
			if self.data.aim_list[i] and self.data.aim_list[i].aim then
				ActionController:getInstance():cs16604(self.holiday_bid, self.data.aim_list[i].aim)
			end
		end)
	end
end
function StartWorkPanel:setVisibleStatus(status)
	status = status or false
	self:setVisible(status)
end

function StartWorkPanel:DeleteMe()
	self:stopRoundAction()
	if self.resources_load then
		self.resources_load:DeleteMe()
		self.resources_load = nil
	end
	if self.start_welfare_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.start_welfare_event)
        self.start_welfare_event = nil
    end

	if self.load_bg then
        self.load_bg:DeleteMe()
    end
    self.load_bg = nil
end