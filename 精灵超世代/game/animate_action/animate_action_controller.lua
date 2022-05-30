AnimateActionController = AnimateActionController or BaseClass(BaseController)

function AnimateActionController:config()
	self.model = AnimateActionModel.New(self)
end

function AnimateActionController:getModel()
	return self.model
end

function AnimateActionController:registerEvents()

end

function AnimateActionController:registerProtocals()
	self:RegisterProtocal(24801, "handle24801")
	self:RegisterProtocal(24802, "handle24802")
	self:RegisterProtocal(24803, "handle24803")
	self:RegisterProtocal(24804, "handle24804")
	self:RegisterProtocal(24805, "handle24805")
	self:RegisterProtocal(24806, "handle24806")
	self:RegisterProtocal(24807, "handle24807")
	self:RegisterProtocal(24808, "handle24808")
	self:RegisterProtocal(24809, "handle24809")
end
--请求元宵灯会基础信息
function AnimateActionController:sender24801()
	self:SendProtocal(24801, {})
end
function AnimateActionController:handle24801(data)
	GlobalEvent:getInstance():Fire(AnimateActionEvent.YuanZhenFestval_Linght,data)
end
--元宵灯会奖池信息
function AnimateActionController:sender24802(id)
	local proto = {}
	proto.id = id
	self:SendProtocal(24802, proto)
end
function AnimateActionController:handle24802(data)
	message(data.msg)
	if data.flag == 1 then
		GlobalEvent:getInstance():Fire(AnimateActionEvent.YuanZhenFestval_Lottery,data)
	end
end
--元宵灯会抽奖
function AnimateActionController:sender24803(id)
	local proto = {}
	proto.id = id
	self:SendProtocal(24803, proto)
end
function AnimateActionController:handle24803(data)
	message(data.msg)
end

-------打开界面
function AnimateActionController:openAnimateFestvalWindow(status,index,is_open)
    if status then
        if not self.animate_festval_window then
            self.animate_festval_window = AnimateActionFestvalWindow.New(index,is_open)
        end
        self.animate_festval_window:open()
    else
        if self.animate_festval_window then
            self.animate_festval_window:close()
            self.animate_festval_window = nil
        end
    end
end

--欢食元宵基础信息
function AnimateActionController:sender24804()
	self:SendProtocal(24804, {})
end
function AnimateActionController:handle24804(data)
	self.model:setHolidayID(data.camp_id)
	self.model:setRemainChallageNum(data.combat_num)
	self.model:setKitchenRemainData(data.make_list)
	GlobalEvent:getInstance():Fire(AnimateActionEvent.YuanZhenFestval_Kitchen,data)
end
--制作物品
function AnimateActionController:sender24806(id)
	local proto = {}
	proto.id = id
	self:SendProtocal(24806, proto)
end
function AnimateActionController:handle24806(data)
	message(data.msg)
end
--通关奖励展示
function AnimateActionController:sender24805()
	self:SendProtocal(24805, {})
end
function AnimateActionController:handle24805(data)
	self.model:setKitchenLevData(data.reward_list)
	GlobalEvent:getInstance():Fire(AnimateActionEvent.YuanZhenFestval_Kitchen_Lev,data)
end
--领取等级礼包
function AnimateActionController:sender24807(lev)
	local proto = {}
	proto.id = lev
	self:SendProtocal(24807, proto)
end
function AnimateActionController:handle24807(data)
	message(data.msg)
end
--打开元宵厨房
function AnimateActionController:openAnimateYuanzhenGotoKitchenWindow(status,holiday_id,make_lev,holiday_reward_bid,cur_exp)
    if status then
        if not self.animate_kitchen_window then
            self.animate_kitchen_window = AnimateYuanzhenGotoKitchenWindow.New(holiday_id,make_lev,holiday_reward_bid,cur_exp)
        end
        self.animate_kitchen_window:open()
    else
        if self.animate_kitchen_window then
            self.animate_kitchen_window:close()
            self.animate_kitchen_window = nil
        end
    end
end
--打开元宵厨房..等级
function AnimateActionController:openAnimateYuanzhenKitchenLevWindow(status,holiday_id)
    if status then
        if not self.animate_kitchen_lev_window then
            self.animate_kitchen_lev_window = AnimateYuanzhenKitchenLevWindow.New(holiday_id)
        end
        self.animate_kitchen_lev_window:open()
    else
        if self.animate_kitchen_lev_window then
            self.animate_kitchen_lev_window:close()
            self.animate_kitchen_lev_window = nil
        end
    end
end

--挑战
function AnimateActionController:sender24808()
	self:SendProtocal(24808, {})
end
function AnimateActionController:handle24808(data)
	message(data.msg)
end
--挑战次数
function AnimateActionController:sender24809()
	self:SendProtocal(24809, {})
end
function AnimateActionController:handle24809(data)
	message(data.msg)
	if data.flag == 1 then
		GlobalEvent:getInstance():Fire(AnimateActionEvent.YuanZhenFestval_Buy_Challage,data)
	end
end
--收集食材
function AnimateActionController:openAnimateYuanzhenCollectWindow(status)
    if status then
        if not self.animate_collect_window then
            self.animate_collect_window = AnimateYuanzhenCollectWindow.New()
        end
        self.animate_collect_window:open()
    else
        if self.animate_collect_window then
            self.animate_collect_window:close()
            self.animate_collect_window = nil
        end
    end
end

function AnimateActionController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end