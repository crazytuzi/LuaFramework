SpecialItemModel = SpecialItemModel or BaseClass()

function SpecialItemModel:_init()
  	self.mgr = SpecialItemModel.Instance
end


function SpecialItemModel:OpenWindow(args)
	if self.mainWin == nil then
		self.mainWin = SpecialItemWindow.New(self)
	end
	self.mainWin:Open(args)
end

function SpecialItemModel:CloseWin()
	WindowManager.Instance:CloseWindow(self.mainWin)
end

function SpecialItemModel:OpenMeshFashion(args)
    if self.meshFashionWin == nil then
        self.meshFashionWin = MeshFashionSpecial.New(self)
    end
    self.meshFashionWin:Open(args)
end

function SpecialItemModel:OpenWarmHeartWindow(args)
	if self.WarmHeartWin == nil then
		self.WarmHeartWin = WarmHeartGiftWindow.New(self)
	end
	self.WarmHeartWin:Open(args)
end

function SpecialItemModel:CloseWarmHeartWindow()
	WindowManager.Instance:CloseWindow(self.WarmHeartWin)
end
