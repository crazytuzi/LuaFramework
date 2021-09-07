HotFixItem = HotFixItem or BaseClass()

function HotFixItem:__init(gameObject, parent, type)
    self.gameObject = gameObject
    self.type = type
    self.data = nil

    self.parent = parent

    self.transform = self.gameObject.transform

    self.nameText = self.transform:Find("name"):GetComponent(Text)


    self.transform:GetComponent(Button).onClick:AddListener(function() self:ClickMobile() end)
end

--设置


function HotFixItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function HotFixItem:set_my_index(_index)
end

--更新内容
function HotFixItem:update_my_self(_data, _index)
    self.data = _data
    self.index = _index
    if type(self.data.data) ~= "table" then
        self.nameText.text = string.format("<color='#ff0000'>%s</color>", self.data.data)
    else
        self.nameText.text = _data.name
    end
end

function HotFixItem:Refresh(args)

end

function HotFixItem:__delete()

end

function HotFixItem:ClickMobile()
    if self.data ~= nil then
        if type(self.data.data) == "table" then
            self.parent.indexList[self.type] = self.index
            self.parent.indexname[self.type] = self.data.name
            for i=self.type+1, 4 do
                self.parent.indexList[i] = nil
                self.parent.indexname[i] = nil
            end
            self.parent:RefreshList()
        else
            print(self.data.name)
            self.parent.indexList[self.type] = self.index
            self.parent.indexname[self.type] = self.data.data
            self.parent:HotFix()
        end
    end
end