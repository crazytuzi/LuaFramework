-- 打雪仗model
-- @author hzf
SnowBallModel = SnowBallModel or BaseClass(BaseModel)

function SnowBallModel:__init(Mgr)
    self.Mgr = Mgr
    self.match_time = 0
end

function SnowBallModel:__delete()

end

function SnowBallModel:OpenMatchWindow(args)
    if self.matchwindow == nil then
        self.matchwindow = SnowBallMatchWindow.New(self)
    end
    self.matchwindow:Open(args)
end


function SnowBallModel:ClosePanel(args)
    if self.matchwindow ~= nil then
        WindowManager.Instance:CloseWindow(self.matchwindow)
    end
end


function SnowBallModel:OpenShowPanel(args)
    if self.showpanel == nil then
        self.showpanel = SnowBallShowPanel.New(self)
    end
    self.showpanel:Show(args)
end


function SnowBallModel:CloseShowPanel(args)
    if self.showpanel ~= nil then
        self.showpanel:DeleteMe()
        self.showpanel = nil
    end
end
