-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: lc@syg.com(必填, 创建模块的人员)
-- @editor: lc@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      合服
-- <br/>Create: 2019-09-28
-- --------------------------------------------------------------------
MergeserverController = MergeserverController or BaseClass(BaseController)

function MergeserverController:config()
    self.model = MergeserverModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function MergeserverController:getModel()
    return self.model
end

function MergeserverController:registerEvents()

end

function MergeserverController:registerProtocals()
	self:RegisterProtocal(10991, "handle10991")     -- 是否开启合服问卷
	self:RegisterProtocal(10992, "handle10992")		-- 投票结果
	self:RegisterProtocal(10993, "handle10993")		-- 合服投票
end

function MergeserverController:sender10991() 
	self:SendProtocal(10991, {})
end

--登陆的时候后端推送一次 图标开启情况  后面自己请求
function MergeserverController:handle10991( data )
	if data then
		self.dispather:Fire(MergeserverEvent.Update_Main_Mergeserver_Event, data)  --主界面显示图标
	end
end

function MergeserverController:sender10992() 
	self:SendProtocal(10992, {})

end

function MergeserverController:handle10992( data ) 
	self.dispather:Fire(MergeserverEvent.Update_Merge_MsgResult_Event, data)  --投票结果
	self.model:setResult(data)
end

function MergeserverController:sender10993( flag )
	local protocal = {}
    protocal.flag = flag
	self:SendProtocal(10993, protocal)
end

function MergeserverController:handle10993( data )  --是否投票成功
	self.model:setVotingStatus(data.flag)
	self.dispather:Fire(MergeserverEvent.Update_Merge_Success_Event, data)  --投票结果
end


-- 合服问卷界面
function MergeserverController:openMergeWindow(status)  --
	if status == true then
		if self.merge_server_window == nil then
			self.merge_server_window = MergeserverLookWindow.New()
		end
		self.merge_server_window:open()
	else
		if self.merge_server_window then
			self.merge_server_window:close()
			self.merge_server_window = nil
		end
	end
end

function MergeserverController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end