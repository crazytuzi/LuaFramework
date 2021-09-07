SignRewardManager = SignRewardManager or BaseClass(BaseManager)


function SignRewardManager:__init()
	if SignRewardManager.Instance ~= nil then
		return
	end
    SignRewardManager.Instance = self
    self.rewardBackEvent = EventLib.New()
    self.getRewardBackEvent = EventLib.New()
	self.model = SignRewardModel.New()
    self:InitHandlers()

end

function SignRewardManager:__delete()
	if self.model ~= nil then
		self.model:DeleteMe()
		self.model = nil
	end

	self:RemoveHandlers()
end


function SignRewardManager:InitHandlers()
	self:AddNetHandler(14108,self.on14108)
end

function SignRewardManager:OpenWindow(args)
    if self.model ~= nil then
	   self.model:OpenWindow(args)
	end
end

function SignRewardManager:CloseWindow()
	self.model:CloseWindow()
end

function SignRewardManager:send14108(data)
     BaseUtils.dump(data,"发送14108数据")
     self:Send(14108, data)
end

function SignRewardManager:on14108(data)
	BaseUtils.dump(data,"接收14108数据")
	local myData = {}
	for k,v in pairs(data) do
		myData[k] = v
	end
     
     if myData.flag == 0 then
     	NoticeManager.Instance:FloatTipsByString(myData.msg)
     elseif myData.flag == 1 then
     	 -- if data.type == 1 then
     	 -- 	self.rewardBackEvent:Fire()
     	 if myData.type == 1 then
     	 	self.getRewardBackEvent:Fire(myData)
     	 end
     end
end
