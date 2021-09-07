-- @date #2019/01/14#

CardExchangeModel = CardExchangeModel or BaseClass(BaseModel)

function CardExchangeModel:__init()
    self.preStoreId = nil  --要显示的id
    self.collect_word_data = {}
    self.collect_word_redpoint = {} -- 集字活动红点列表
    self.lastitemContainerPosy = 0
end

function CardExchangeModel:__delete()
end

function CardExchangeModel:OpenWindow(args)
    if self.mainWin == nil then
    end
    self.mainWin:Open(args)
end

function CardExchangeModel:CloseWindow()
end


