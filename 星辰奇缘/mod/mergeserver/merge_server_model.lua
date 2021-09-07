-- @author 黄耀聪
-- @date 2016年6月13日

MergeServerModel = MergeServerModel or BaseClass(BaseModel)

function MergeServerModel:__init()
end

function MergeServerModel:__delete()
end

function MergeServerModel:OpenWindow(args)
    if self.mainWin == nil then
		self.mainWin = MergeServerWindow.New(self)
    end
    self.mainWin:Open(args)
end

function MergeServerModel:CloseWindow()
	WindowManager.Instance:CloseWindow(self.mainWin)
end


