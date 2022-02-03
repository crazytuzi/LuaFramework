-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-05-13
-- --------------------------------------------------------------------
NewPartnersummonModel = NewPartnersummonModel or BaseClass()

function NewPartnersummonModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function NewPartnersummonModel:config()
end

-- 设置召唤数据
-- function NewPartnersummonModel:setSummonData(data)
-- 	if data then
-- 		if not self.recruit_data then
-- 			self.recruit_data = {}
-- 		end
-- 		for i,v in pairs(data.recruit_list) do
-- 			self.recruit_data[v.group_id] = v
-- 		end
-- 		-- GlobalEvent:getInstance():Fire(PartnersummonEvent.updateSummonDataEvent)
-- 	end
-- end
--获取免费次数，召唤间隔时间
function NewPartnersummonModel:setSummonItemData(data)
	if not self.summon_data then
		self.summon_data = {}
	end
	for i,v in pairs(data) do
        local free_num = 0
        local time_num = 0
        for m,n in pairs(v.draw_list) do
            local free_list = keyfind('key', 4, n.kv_list) or nil
            if free_list then
                free_num = free_list.val or 0
            end
            local time_list = keyfind('key', 5, n.kv_list) or nil
            if time_list then
                time_num = time_list.val or 0
            end
        end
        self.summon_data[v.group_id] = {free_num = free_num, time_num = time_num}
    end
    self:SummonSceneBuild()
end
function NewPartnersummonModel:getSummonItemData(group_id)
	if self.summon_data[group_id] then
		return self.summon_data[group_id]
	end
end
function NewPartnersummonModel:updataSummonItemData(data)
	if self.summon_data[data.group_id] then
		self.summon_data[data.group_id].free_num = data.free_times
		self.summon_data[data.group_id].time_num = data.free_cd_end
	end
	self:SummonSceneBuild()
end
--计算红点
function NewPartnersummonModel:SummonSceneBuild()
	if not self.summon_data then return end
	local status_red = false
	for i,v in pairs(self.summon_data) do
		if v.free_num == 1 then
			status_red = true
			break
		end
	end
	MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.summon, status_red)
end

-- function NewPartnersummonModel:getSummonData(group_id)
-- 	if self.recruit_data[group_id] then
-- 		return self.self.recruit_data[group_id]
-- 	end
-- end


function NewPartnersummonModel:__delete()
end
