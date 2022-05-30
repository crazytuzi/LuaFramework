--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 
-- @DateTime:    2019-04-11 17:00:46
-- *******************************
RecruitHeroController = RecruitHeroController or BaseClass(BaseController)

function RecruitHeroController:config()
    self.model = RecruitHeroModel.New(self)
end

function RecruitHeroController:getModel()
    return self.model
end

function RecruitHeroController:registerEvents()
	if self.init_role_event == nil then
		self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
			GlobalEvent:getInstance():UnBind(self.init_role_event)
			self.init_role_event = nil
			local role_vo = RoleController:getInstance():getRoleVo()
			local reg_time = (GameNet:getInstance():getTime() - role_vo.reg_time)/TimeTool.day2s()
			reg_time = math.floor(reg_time)
			if role_vo and reg_time <= 3 then
				if role_vo.lev >= 10 then
                    self:sender25100()
				end
				if self.role_recruit_event == nil then
                    self.role_recruit_event = role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                        if key == "lev" and role_vo.lev >= 10 then
                            self:sender25100()
                            if self.role_recruit_event and role_vo then
						        role_vo:UnBind(self.role_recruit_event)
						        self.role_recruit_event = nil
						    end
                        end
                    end)
                end
			end
		end)
	end
end

function RecruitHeroController:registerProtocals()
    self:RegisterProtocal(25100, "handle25100")
end

--限时招募信息
function RecruitHeroController:sender25100()
    self:SendProtocal(25100,{})
end
function RecruitHeroController:handle25100(data)
	self.model:setRecruitEndTime(data.end_time)
	self.model:setRecruitBaseData(data)
	self.model:setStatusRedPoint(data)
	GlobalEvent:getInstance():Fire(RecruitHeroEvent.RecruitHeroBaseInfo,data)
end
--领取奖励
function RecruitHeroController:sender25101(id)
	local proto = {}
	proto.id = id
    self:SendProtocal(25101,proto)
end
function RecruitHeroController:handle25101(data)
	message(data.msg)
end

function RecruitHeroController:openRecruitHeroWindow(status)
	if status == true then
		if not self.recruit_hero_window then
			self.recruit_hero_window = RecruitHeroWindow.New()
		end
        self.recruit_hero_window:open()
    else
        if self.recruit_hero_window then 
            self.recruit_hero_window:close()
            self.recruit_hero_window = nil
        end
    end
end

function RecruitHeroController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end