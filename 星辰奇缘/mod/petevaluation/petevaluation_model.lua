PetEvaluationModel = PetEvaluationModel or BaseClass()

function PetEvaluationModel:__init()
    self.Mgr = PetEvaluationModel.Instance
    self.mainWin = nil
end

function PetEvaluationModel:__delete()
	if self.mainWin ~= nil then
		self.mainWin = nil
	end
end

function PetEvaluationModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = PetEvaluationWindow.New(self)
    end

    self.mainWin:Open(args)
end

function PetEvaluationModel:CloseMain()
    WindowManager.Instance:CloseWindow(self.mainWin,true)
end

function PetEvaluationModel:AppendInputElement(element)
    if self.mainWin ~= nil then
        self.mainWin:AppendInputElement(element)
    end
end
