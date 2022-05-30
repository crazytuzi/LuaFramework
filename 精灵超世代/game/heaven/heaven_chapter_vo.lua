--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-04-12 16:30:14
-- @description    : 
		-- 天界副本 章节数据
---------------------------------
HeavenChapterVo = HeavenChapterVo or BaseClass(EventDispatcher)

function HeavenChapterVo:__init(  )
	self.id = 0  	  	 -- 章节id
	self.all_star = 0 	 -- 总星数
	self.award_info = {} -- 星数奖励数据
	self.is_finish = HeavenConst.Chapter_Pass_Status.NotPass -- 通关状态

	self.red_status = false -- 章节奖励红点
end

function HeavenChapterVo:updateData( data )
	for key, value in pairs(data) do
        self[key] = value
    end
    self:checkChapterRedStatus()
    self:dispatchUpdateAttrByKey()
end

function HeavenChapterVo:dispatchUpdateAttrByKey()
    self:Fire(HeavenEvent.Update_Chapter_Vo_Event) 
end

function HeavenChapterVo:checkChapterRedStatus(  )
	self.red_status = false
	for k,v in pairs(self.award_info) do
		if v.flag == 1 then
			self.red_status = true
			break
		end
	end
end

-- 章节奖励红点状态
function HeavenChapterVo:getRedStatus(  )
	return self.red_status
end

function HeavenChapterVo:__delete(  )
	
end