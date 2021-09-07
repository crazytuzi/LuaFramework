SpecialItemManager = SpecialItemManager or BaseClass(BaseManager)

function SpecialItemManager:__init()
	if SpecialItemManager.Instance then
		Log.Error("不可以对单例对象重复实例化")
		return
	end
    
	SpecialItemManager.Instance = self

	self.model = SpecialItemModel.New()
end

function SpecialItemManager:initHandle()
   self:AddNetHandler(9952, self.on9952)
end



function SpecialItemManager:OpenWindow(args)
	if self.model ~= nil then
		self.model:OpenWindow(args)
	end
end

function SpecialItemManager:OpenWarmHeartWindow(args)
		if self.model ~= nil then
			  self.model:OpenWarmHeartWindow(args)
		end
end

function SpecialItemManager:send9952(num)
   local data = {}
   Connection.Instance:send(9952,{gift_id = num})
end


function SpecialItemManager:on9952(data)
   NoticeManager.Instance:FloatTipsByString(data.msg)
end