-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: lc@syg.com(必填, 创建模块的人员)
-- @editor: lc@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-1-7
-- --------------------------------------------------------------------
NoticeModel = NoticeModel or BaseClass()

function NoticeModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function NoticeModel:config()
	self.feed_back_list = {} --反馈列表
	self.all_count = 0
	self.replied_count = 0 
	self.wait_count = 0
	self.reply_content_list = {} --回复列表
	self.trace_content_list = {} --追问列表
	self.time_data = {}
	self.red_status = false
end

function NoticeModel:setFeedBackData( data )
	self:config()
    local function sortfunc( objA, objB )
        return objA.end_msg_time > objB.end_msg_time
	end
	local log_data = data.feedback_logs
	if log_data ~= nil and next(log_data) ~= nil then
		table.sort( log_data, sortfunc )
		for i,v in pairs(log_data) do
			local list_data = {}
			list_data.id = v.id
			list_data.title = v.title
			list_data.content = v.content
			list_data.state = v.state
			list_data.status2 = v.status2
			list_data.end_msg_time = v.end_msg_time
			list_data.start_time = v.start_time
			list_data.finish_time = v.finish_time
			list_data.score_time = v.score_time
			table.insert( self.feed_back_list, list_data )
			if v.state == 2 then
				self.replied_count = self.replied_count + 1 
			end 
			if v.state == 3 then
				self.wait_count = self.wait_count + 1
			end
			if v.state == 2 or v.status2 == 3 then
				if v.status2 == 0 then
					self.red_status = true
				end
			end
		end	
		self.all_count = #log_data
	end
end

function NoticeModel:getFeedBackData()
	if self.feed_back_list ~= nil and next(self.feed_back_list) ~= nil then
		table.sort(self.feed_back_list, function(a, b) return b.end_msg_time > a.end_msg_time end)
		table.sort(self.feed_back_list, function(a, b) 
			if a.end_msg_time == 0 then
				return a.start_time > b.start_time
			end
			end)
			-- return b.end_msg_time > a.end_msg_time end)

		return self.feed_back_list
	end
end

function NoticeModel:getTimeData(  )
		if self.time_data ~= nil and next(self.time_data) ~= nil then
		return self.time_data
	end
end

function NoticeModel:setContentData(data)
	self:config()
	if data ~= nil and next(data) ~= nil then
		if  data.end_msg_time then
			self.time_data.end_msg_time = data.end_msg_time 
		end
		if  data.start_time then
			self.time_data.start_time = data.start_time 
		end
		if  data.finish_time then
			self.time_data.finish_time = data.finish_time 
		end
		if data.status2 then
			self.time_data.state = data.state
		end
		local questions_lists = data.questions_lists
		if questions_lists ~= nil and next(questions_lists) ~= nil then
			self:setTraceContentData(questions_lists)
		end
		local answer_lists = data.answer_lists
		if answer_lists ~= nil and next(answer_lists) ~= nil then
			self:setAnswerContentData(answer_lists)
		end
		
	end

end

function NoticeModel:setTraceContentData( trace_list ) --追问
	local function sortfunc( objA, objB )
        	return objA.questions_timer > objB.questions_timer
	end
	table.sort( trace_list, sortfunc )
	for i,v in pairs(trace_list) do
		local questions_lists_data = {}
		questions_lists_data.questions_timer = trace_list[i].questions_timer
		questions_lists_data.questions_content = trace_list[i].questions_content
		table.insert( self.trace_content_list, questions_lists_data )
	end
end

function NoticeModel:setAnswerContentData( answer_list )
	local function sortfunc( objA, objB )
    	return objA.answer_timer > objB.answer_timer
	end
	table.sort( answer_list, sortfunc )
	for i,v in pairs(answer_list) do
		local answer_list_data = {}
		answer_list_data.answer_timer = answer_list[i].answer_timer
		answer_list_data.answer_content = answer_list[i].answer_content
		table.insert( self.reply_content_list, answer_list_data )
	end
end

function NoticeModel:getTraceContentData( ... )  --问题
	if self.trace_content_list ~= nil and next(self.trace_content_list) ~= nil then
		return self.trace_content_list
	end
end


function NoticeModel:getAnswerContentData( ... ) --回复
	if self.reply_content_list ~= nil and next(self.reply_content_list) ~= nil then
		return self.reply_content_list
	end
end

function NoticeModel:getRedStatus( ... )
	return self.red_status
end



function NoticeModel:getCount()
	local data = {}
	data.wait_count = self.wait_count
	data.all_count = self.all_count
	data.replied_count = self.replied_count
	return data
end

function NoticeModel:__delete()
end