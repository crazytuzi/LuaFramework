-- zzl
-- 2016/7/6

ExamFinalAnswerItem = ExamFinalAnswerItem or BaseClass()

function ExamFinalAnswerItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil
    self.parent = parent

    local itr = self.gameObject.transform

    self.transform = self.gameObject.transform
    self.TxtDesc = self.transform:FindChild("TxtDesc"):GetComponent(Text)
    self.ImgRight = self.transform:FindChild("ImgRight").gameObject
    self.ImgWrong = self.transform:FindChild("ImgWrong").gameObject

    self.TxtDesc.text = ""
    self.ImgRight:SetActive(false)
    self.ImgWrong:SetActive(false)
end

function ExamFinalAnswerItem:Release()

end

function ExamFinalAnswerItem:Refresh()

end

function ExamFinalAnswerItem:update_my_self(_data,_item_index)
    self.data = _data

    self.TxtDesc.text = ""
    self.ImgRight:SetActive(false)
    self.ImgWrong:SetActive(false)

    if _data._type == nil then
        local choice = "A"
        if _data.choice == 1 then
            choice = "A"
        elseif _data.choice == 2 then
            choice = "B"
        elseif _data.choice == 3 then
            choice = "C"
        elseif _data.choice == 4 then
            choice = "D"
        end


        if _data.result == 0 then
            self.TxtDesc.text = string.format("<color='#248813>%s</color>%s：%s", _data.name, TI18N("的答案"), choice)
            self.ImgWrong:SetActive(true)
        else
            self.TxtDesc.text = string.format("<color='#248813>%s</color>%s", _data.name, TI18N("作答正确"))
        end
    else
        local choice = "A"
        if _data.right_answer == 1 then
            choice = "A"
        elseif _data.right_answer == 2 then
            choice = "B"
        elseif _data.right_answer == 3 then
            choice = "C"
        elseif _data.right_answer == 4 then
            choice = "D"
        end
        self.TxtDesc.text = string.format("<color='#248813>%s</color>%s：%s", _data.name, TI18N("的答案"), choice)
        self.ImgRight:SetActive(true)
    end
end