
local CTaskMainStoryPage = class("CTaskMainStoryPage", CPageBase)

function CTaskMainStoryPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CTaskMainStoryPage.OnInitPage(self)

	self:InitContent()
end

function CTaskMainStoryPage.InitContent(self)

end


function CTaskMainStoryPage.SetTaskInfo(self, oTask)
	if oTask == nil then
		return
	end

end



return CTaskMainStoryPage