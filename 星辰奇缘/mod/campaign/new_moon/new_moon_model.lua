-- @author 黄耀聪
-- @date 2016年10月14日

NewMoonModel = NewMoonModel or BaseClass(BaseModel)

function NewMoonModel:__init()
    self.circleHead = nil
    self.circleTail = nil
    self.circleCount = 0
end

function NewMoonModel:__delete()
end

function NewMoonModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = NewMoonWindow.New(self)
    end
    self.mainWin:Open(args)
end

function NewMoonModel:CloseWindow()
end

function NewMoonModel:AddToCircle(msg, currentMsg)
    if self.circleTail == nil then
        self.circleHead = {str = msg}
        self.circleHead.next = self.circleHead
        self.circleTail = self.circleHead
        self.circleCount = 1
    else
        local tab = {str = msg}

        if currentMsg ~= nil then
            tab.next = currentMsg.next
            currentMsg.next = tab
        else
        end

        if self.circleCount >= 20 then
            self.circleTail.next = self.circleHead.next
            self.circleHead = self.circleTail.next
        else
            self.circleCount = self.circleCount + 1
        end
    end
end


