-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-04-08
-- --------------------------------------------------------------------
SmasheggController = SmasheggController or BaseClass(BaseController)

function SmasheggController:config()
    self.model = SmasheggModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function SmasheggController:getModel()
    return self.model
end

function SmasheggController:registerEvents()
end

---------------------@ c2s
-- 请求砸蛋活动数据
function SmasheggController:sender16680(  )
	self:SendProtocal(16680, {})
end

-- 请求刷新
function SmasheggController:sender16681(  )
	self.request_flag = true -- 标记刷新请求是否已经返回
	self:SendProtocal(16681, {})
end

-- 请求砸蛋
function SmasheggController:sender16682( pos )
	local protocal = {}
	protocal.pos = pos
    self:SendProtocal(16682, protocal)
end

-- 请求全部砸开
function SmasheggController:sender16683(  )
	self:SendProtocal(16683, {})
end

-- 请求购买道具
function SmasheggController:sender16684( num )
	local protocal = {}
	protocal.num = num
    self:SendProtocal(16684, protocal)
end

-- 砸蛋活动日志
function SmasheggController:sender16685( type )
	local protocal = {}
	protocal.type = type
    self:SendProtocal(16685, protocal)
end

---------------------@ s2c
function SmasheggController:registerProtocals()
	self:RegisterProtocal(16680, "handle16680")     -- 砸蛋活动数据
	self:RegisterProtocal(16681, "handle16681")     -- 刷新返回
	self:RegisterProtocal(16682, "handle16682")     -- 请求砸蛋返回
	self:RegisterProtocal(16683, "handle16683")     -- 全部砸开返回
	self:RegisterProtocal(16684, "handle16684")     -- 购买道具返回
	self:RegisterProtocal(16685, "handle16685")     -- 砸蛋日志返回
end

-- 砸蛋数据返回
function SmasheggController:handle16680( data )
	if data then
		GlobalEvent:getInstance():Fire(SmasheggEvent.Update_Smashegg_Data_Event, data)
	end
end

-- 请求刷新返回
function SmasheggController:handle16681( data )
	if data then
		message(data.msg)
	end
	self.request_flag = false
end

-- 刷新订单请求数据是否已经返回(防止快速点击刷新按钮)
function SmasheggController:checkRefreshReqIsBack(  )
	if not self.request_flag then
		return true
	end
	return false
end

-- 请求砸蛋返回
function SmasheggController:handle16682( data )
	if data then
		message(data.msg)
	end
	self.model:setSmasheggAniPlaying(false)
end

-- 请求全部砸开返回
function SmasheggController:handle16683( data )
	if data then
		message(data.msg)
	end
end

-- 购买道具返回
function SmasheggController:handle16684( data )
	if data then
		message(data.msg)
	end
end

-- 砸蛋日志返回
function SmasheggController:handle16685( data )
	if data then
		if data.type == 1 then -- 个人
			self.model:setMyselfRecordData(data.log_list)
		elseif data.type == 2 then -- 全服
			self.model:setAllRecordData(data.log_list)
		end
		GlobalEvent:getInstance():Fire(SmasheggEvent.Update_Smashegg_Record_Event, data)
	end
end

--------------------- 界面相关
-- 打开记录界面
function SmasheggController:openSmasheggRecordWindow( status )
	if status == true then
		if self.smashegg_record_wnd == nil then
			self.smashegg_record_wnd = SmasheggRecordWindow.New()
		end
		if self.smashegg_record_wnd:isOpen() == false then
			self.smashegg_record_wnd:open()
		end
	else
		if self.smashegg_record_wnd then
			self.smashegg_record_wnd:close()
			self.smashegg_record_wnd = nil
		end
	end
end

function SmasheggController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end