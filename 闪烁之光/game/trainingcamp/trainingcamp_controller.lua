-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xhj(必填, 创建模块的人员)
-- @editor: xhj(必填, 后续维护以及修改的人员)
-- @description:
--      新手训练营
-- <br/>Create: 2019-11-06
-- --------------------------------------------------------------------
TrainingcampController = TrainingcampController or BaseClass(BaseController)

function TrainingcampController:config()
    self.model = TrainingcampModel.New(self)
	self.dispather = GlobalEvent:getInstance()
	self.is_open_all_finish_partner = false
end

function TrainingcampController:getModel()
    return self.model
end

function TrainingcampController:registerEvents()
	--新获得伙伴弹窗
    if not self.get_all_finish_tips_event then
        self.get_all_finish_tips_event = GlobalEvent:getInstance():Bind(MainuiEvent.CLOSE_ITEM_VIEW, function()
            if self.is_open_all_finish_partner == true then
                self:openTrainingcampAllfinishTipsWindow(true)
                self.is_open_all_finish_partner = false
            end
        end)
    end
end

function TrainingcampController:registerProtocals()
	self:RegisterProtocal(27600, "handle27600")     -- 请求完成情况
	self:RegisterProtocal(27601, "handle27601")     -- 开始挑战
	self:RegisterProtocal(27602, "handle27602")     -- 请求进入
	self:RegisterProtocal(27603, "handle27603")     -- 点击阵法图标
end

-- 请求完成情况
function TrainingcampController:send27600(  )
	local protocal = {}
    self:SendProtocal(27600, protocal)
end

-- 完成情况
function TrainingcampController:handle27600( data )
	if data then
		if #self.model.finish_ids+1 == #data.ids and Config.TrainingCampData.data_info and #Config.TrainingCampData.data_info == #data.ids then
			self.is_open_all_finish_partner = true
		end
		
		self.model:setInfo(data)
		GlobalEvent:getInstance():Fire(TrainingcampEvent.Update_Trainingcamp_Data_Event)
	end
end

-- 请求开始挑战
function TrainingcampController:send27601(id ,formation_type , pos_info)
	local protocal = {}
	protocal.id = id
	protocal.formation_type = formation_type
	protocal.pos_info = pos_info
    self:SendProtocal(27601, protocal)
end

-- 开始挑战
function TrainingcampController:handle27601( data )
	if data then
		message(data.msg)
		-- if data.flag == 1 then
		-- 	self:openTrainingcampMainWindow(false)
		-- end
	end
end

-- 请求进入
function TrainingcampController:send27602( id )
	local protocal = {}
	protocal.id = id
    self:SendProtocal(27602, protocal)
end

-- 请求进入
function TrainingcampController:handle27602( data )
	if data then
		message(data.msg)
		if data.flag == 1 and data.is_first == 1 then
			GlobalEvent:getInstance():Fire(TrainingcampEvent.Update_Trainingcamp_Tips_Event)
		end
		GlobalEvent:getInstance():Fire(TrainingcampEvent.Is_Show_Formation_Event,data.is_formation)
	end
end

-- 点击阵法图标
function TrainingcampController:send27603( id )
	local protocal = {}
	protocal.id = id
    self:SendProtocal(27603, protocal)
end

-- 点击阵法图标
function TrainingcampController:handle27603( )
end


--训练选择界面
function TrainingcampController:openTrainingcampWindow( status)
	if status == true then
		if self.TrainingcampWindow == nil then
			self.TrainingcampWindow = TrainingcampWindow.New()
		end
		if self.TrainingcampWindow:isOpen() == false then
			self.TrainingcampWindow:open()
		end
	else
		if self.TrainingcampWindow then
			self.TrainingcampWindow:close()
			self.TrainingcampWindow = nil
		end
	end
end

-- 引导需要
function TrainingcampController:getTrainingcampRoot(  )
	if self.TrainingcampWindow then
        return self.TrainingcampWindow.root_wnd
    end
end

--提示信息界面
function TrainingcampController:openTrainingcampTipsWindow(status,data)
	if status == true then
		if self.TrainingcampTipsWindow == nil then
			self.TrainingcampTipsWindow = TrainingcampTipsWindow.New()
		end
		if self.TrainingcampTipsWindow:isOpen() == false then
			self.TrainingcampTipsWindow:open(data)
		end
	else
		if self.TrainingcampTipsWindow then
			self.TrainingcampTipsWindow:close()
			self.TrainingcampTipsWindow = nil
		end
	end
end

--布阵界面
function TrainingcampController:openTrainingcampMainWindow( status,data)
	if status == true then
		if self.TrainingcampMainWindow == nil then
			self.TrainingcampMainWindow = TrainingcampMainWindow.New()
		end
		if self.TrainingcampMainWindow:isOpen() == false then
			self.TrainingcampMainWindow:open(data)
		end
	else
		if self.TrainingcampMainWindow then
			self.TrainingcampMainWindow:close()
			self.TrainingcampMainWindow = nil
		end
	end
end


--完成所有提示界面
function TrainingcampController:openTrainingcampAllfinishTipsWindow(status)
	if status == true then
		if self.TrainingcampAllTipsWindow == nil then
			self.TrainingcampAllTipsWindow = TrainingcampAllfinishTipsWindow.New()
		end
		if self.TrainingcampAllTipsWindow:isOpen() == false then
			self.TrainingcampAllTipsWindow:open()
		end
	else
		if self.TrainingcampAllTipsWindow then
			self.TrainingcampAllTipsWindow:close()
			self.TrainingcampAllTipsWindow = nil
		end
	end
end


function TrainingcampController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end