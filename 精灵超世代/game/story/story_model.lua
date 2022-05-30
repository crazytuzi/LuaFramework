--[[
    * 类注释写在这里-----------------
    * @author {cloud}
    * <br/>Create: 2016-12-22
]]
StoryModel = StoryModel or BaseClass()

function StoryModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function StoryModel:config()
	self.cur_story_bid = nil 	-- 当前剧情bid
	self.cur_story = nil		-- 当前剧情配置
	self.cur_act_list = nil 	-- 当前动作列表
    --当前是否在剧情中
    self.is_story_state = false -- 剧情状态
    --当前是否是剧情触发的战斗
    self.is_story_fight = false -- 战斗
    --保存缓存的剧情数据
    self.temp_story_list = {}
end

-- 设置当前剧情配置
function StoryModel:setCurStory(data_list)
    -- 这里看看需要不需要判断当前如果有窗体或者有全屏窗体打开的时候,也缓存剧情数据
    if self.is_story_state == true then  --判断是否在剧情状态
        if self.cur_story_bid == data_list.drama_bid then return end
        for i,v in ipairs(self.temp_story_list) do
            if v.drama_bid == data_list.drama_bid then return end
        end
        table.insert(self.temp_story_list, data_list)
        return
    end
	self.cur_story_bid = data_list.drama_bid
	self.cur_story = Config.DramaData.data_get[data_list.drama_bid]

	if self.cur_story and next(self.cur_story.act) ~= nil then
		self.cur_act_list = self.cur_story.act 
		GlobalEvent:getInstance():Fire(StoryEvent.READ_CONFIG_COMPLETE)
    else        
		self.ctrl:send_11100(self.cur_story_bid, 0)
	end
end

--当剧情播放完成的时候判断一下是否有下一个剧情缓存
function StoryModel:isPlayNextStory()
    if #self.temp_story_list > 0 then
        local data_list = table.remove(self.temp_story_list, 1)
        self:setCurStory(data_list)
    end
end

-- 取到当前剧情bid
function StoryModel:getCurStoryBid()
	return self.cur_story_bid
end

-- 取到当前剧情配置
function StoryModel:getCurStory()
	return self.cur_story
end

-- 取到当前动作列表
function StoryModel:getCurActList()
	return self.cur_act_list
end

--设置剧情状态
function StoryModel:setStoryState(bool)
    self.is_story_state = bool
    --如果剧情已经结束，则判断下一个剧情
    if bool == false then
        GlobalEvent:getInstance():Fire(StoryEvent.STORY_OVER)
        self:isPlayNextStory()
    end
end

function StoryModel:isStoryState()
    return self.is_story_state
end

--设置状态
function StoryModel:setStoryFight(bool)
    self.is_story_fight = bool
end

function StoryModel:isStoryFight()
    return self.is_story_fight
end

--清除剧情的数据
function StoryModel:clearActData()
    self.cur_story_bid = nil
    self.cur_story = nil
    self.cur_act_list = nil
end

function StoryModel:__delete()
end