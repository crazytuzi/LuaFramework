--region *.lua
--Date 2017-5-3 jia
--此文件由[BabeLua]插件自动生成
--- 周年庆兑换model
--endregion
CakeExchangeModel = CakeExchangeModel or BaseClass()
function CakeExchangeModel:__init()
end

function CakeExchangeModel:__delete()
    self:CloseWindow()
end

function CakeExchangeModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = CakeExchangeWindow.New(self)
    end
    self.mainWin:Open(args)
end

function CakeExchangeModel:CloseWindow()
   if self.mainWin ~= nil then
       WindowManager.Instance:CloseWindow(self.mainWin)
       self.mainWin = nil
   end
--    ValentineManager.Instance:OpenWindow()
end
