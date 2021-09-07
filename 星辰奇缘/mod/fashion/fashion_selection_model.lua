FashionSelectionModel = FashionSelectionModel or BaseClass(BaseModel)

function FashionSelectionModel:__init()
    self.fashionList = {}
    self.otherFashionList = {}
end

function FashionSelectionModel:__delete()

end

function FashionSelectionModel:OpenFashionSelectionWin(args)
    if self.seleciton_win == nil then
        self.seleciton_win = FashionSelectionWindow.New(self)
    end
    self.seleciton_win:Open(args)
end

function FashionSelectionModel:OpenFashionHelpWin(args)
    if self.help_win == nil then
        self.help_win = FashionSelectionHelpWindow.New(self)
    end
    BaseUtils.dump(args,"帮助界面的参数====================")
    self.help_win:Open(args)
end

function FashionSelectionModel:OpenFashionShowWin(args)
    print("233333333333333333")
    if self.show_win == nil then
        self.show_win = FashionSelectionShowWindow.New(self)
    end

    self.show_win:Open(args)
end

function FashionSelectionModel:OpenFashionLuckyWin(args)
    if self.lucky_win == nil then
        self.lucky_win = FashionSelectionLuckyWindow.New(self)
    end
    self.lucky_win:Open(args)
end

function FashionSelectionModel:InitFashionList()
    self.fashionList = {}
    self.otherFashionList = {}
    --BaseUtils.dump(FashionSelectionManager.Instance.fashionData.group,"laaaaaaaaaaaaaaaaaaaaaaa=============================================================================================")
    for k,v in pairs(FashionSelectionManager.Instance.fashionData.group) do
        if v.classes == 0 or v.classes == RoleManager.Instance.RoleData.classes then
            if v.sex == RoleManager.Instance.RoleData.sex or v.sex == 2 then
                table.insert(self.fashionList,v)
            else
                table.insert(self.otherFashionList,v)
            end
        end
    end

    table.sort(self.fashionList,function(a,b)
               if a.group_id ~= b.group_id then
                    return a.group_id < b.group_id
                else
                    return false
                end
            end)

     table.sort(self.otherFashionList,function(a,b)
               if a.group_id ~= b.group_id then
                    return a.group_id < b.group_id
                else
                    return false
                end
            end)
end