ColorHelper = ColorHelper or BaseClass()

ColorHelper.Default = Color(49/255, 102/255, 173/255)
ColorHelper.DefaultButton1 = Color(199/255, 249/255, 255/255)
ColorHelper.DefaultButton2 = Color.white
ColorHelper.DefaultButton3 = Color(144/255, 96/255, 20/255)
ColorHelper.DefaultButton4 = Color(224/255, 224/255, 224/255)
ColorHelper.DefaultButton5 = Color(199/255, 249/255, 255/255)
ColorHelper.DefaultButton6 = Color(144/255, 96/255, 20/255)
ColorHelper.DefaultButton7 = Color.white
ColorHelper.DefaultButton8 = Color(49/255, 102/255, 173/255)
ColorHelper.DefaultButton9 = Color(144/255, 96/255, 20/255)
ColorHelper.DefaultButton10 = Color(49/255, 102/255, 173/255)
ColorHelper.DefaultButton11 = Color(49/255, 102/255, 173/255)
ColorHelper.TabButton1Normal = Color(151/255, 202/255, 255/255)
ColorHelper.TabButton1Select = Color(39/255, 99/255, 176/255)
ColorHelper.TabButton2Normal = Color(199/255, 249/255, 255/255)
ColorHelper.TabButton2Select = Color.white
ColorHelper.ListItem = Color(12/255, 82/255, 176/255, 1) --字体颜色
ColorHelper.ListItem1 = Color(154/255, 198/255, 241/255, 1) --背景颜色
ColorHelper.ListItem2 = Color(127/255, 178/255, 235/255, 1) --背景颜色

ColorHelper.ButtonColorDic = {
    ["Default"] = ColorHelper.Default
    , ["DefaultButton1"] = ColorHelper.DefaultButton1
    , ["DefaultButton2"] = ColorHelper.DefaultButton2
    , ["DefaultButton3"] = ColorHelper.DefaultButton3
    , ["DefaultButton4"] = ColorHelper.DefaultButton4
    , ["DefaultButton5"] = ColorHelper.DefaultButton5
    , ["DefaultButton6"] = ColorHelper.DefaultButton6
    , ["DefaultButton7"] = ColorHelper.DefaultButton7
    , ["DefaultButton8"] = ColorHelper.DefaultButton8
    , ["DefaultButton9"] = ColorHelper.DefaultButton9
    , ["DefaultButton10"] = ColorHelper.DefaultButton10
    , ["DefaultButton11"] = ColorHelper.DefaultButton11
}

ColorHelper.DefaultStr = "<color='#3166ad'>%s</color>"
ColorHelper.DefaultButton1Str = "<color='#c7f9ff'>%s</color>"
ColorHelper.DefaultButton2Str = "<color='#ffffff'>%s</color>"
ColorHelper.DefaultButton3Str = "<color='#906014'>%s</color>"
ColorHelper.DefaultButton4Str = "<color='#e0e0e0'>%s</color>"
ColorHelper.DefaultButton5Str = "<color='#c7f9ff'>%s</color>"
ColorHelper.DefaultButton6Str = "<color='#906014'>%s</color>"
ColorHelper.DefaultButton7Str = "<color='#ffffff'>%s</color>"
ColorHelper.DefaultButton8Str = "<color='#3166ad'>%s</color>"
ColorHelper.DefaultButton9Str = "<color='#906014'>%s</color>"
ColorHelper.DefaultButton10Str = "<color='#3166ad'>%s</color>"
ColorHelper.DefaultButton11Str = "<color='#3166ad'>%s</color>"
ColorHelper.TabButton1NormalStr = "<color='#97caff'>%s</color>"
ColorHelper.TabButton1SelectStr = "<color='#2763b0'>%s</color>"
ColorHelper.TabButton2NormalStr = "<color='#c7f9ff'>%s</color>"
ColorHelper.TabButton2SelectStr = "<color='#ffffff'>%s</color>"
ColorHelper.ListItemStr = "<color='#0c52b0'>%s</color>" --字体颜色

--道具名称上色
ColorHelper.color_item_name = function(quality, name)
    local str = name
    if quality == 0 then
        str = string.format("<color='#c7f9ff'>%s</color>", name)
    elseif quality == 1 then
        str = string.format("<color='#2fc823'>%s</color>", name)
    elseif quality == 2 then
        str = string.format("<color='#16baf4'>%s</color>", name)
    elseif quality == 3 then
        str = string.format("<color='#ae22da'>%s</color>", name)
    elseif quality == 4 then
        str = string.format("<color='#ffa500'>%s</color>", name)
    elseif quality == 5 then
        str = string.format("<color='#df3435'>%s</color>", name)
    end
    return str
end


--通用颜色表
ColorHelper.color = {
     [0] = "#ffffff"  --白色
    ,[1] = "#248813" --绿色
    ,[2] = "#225ee7" --蓝色
    ,[3] = "#b031d5" --紫色
    ,[4] = "#c3692c" --橙色
    ,[5] = "#fff000" --黄色
    ,[6] = "#df3435" --红色
    ,[7] = "#808080" --灰色
    ,[8] = "#fe2a00"  --默认错误颜色
    ,[9] = "#60ff4b"  --默认主角名字颜色
    ,[10] = "#31f2f9" --蓝 等级突破1
    ,[11] = "#ff9e68" --橙 等级突破2
    ,[12] = "#fb91f6" --粉紫 默认称号颜色
    ,[13] = "#ec4945" --另外一种红色
}

--通用颜色表
ColorHelper.colorObject = {
     [0] = Color.white  --白色
    ,[1] = Color(36/255, 136/255, 19/255, 1)  --绿色
    ,[2] = Color(34/255, 94/255, 231/255, 1)  --蓝色
    ,[3] = Color(176/255, 49/255, 213/255, 1)  --紫色
    ,[4] = Color(195/255, 105/255, 44/255, 1)  --橙色
    ,[5] = Color(1, 1, 0, 1)  --黄色
    ,[6] = Color(0.8, 0.129411765, 0.129411765, 1)  --红色
    ,[7] = Color(0.501960784, 0.501960784, 0.501960784, 1)  --灰色
    ,[8] = Color(0.996078431, 0.164705882, 1, 1)   --默认错误颜色
    ,[9] = Color(0.3764705882352941, 1, 0.2941176470588235, 1)   --默认主角名字颜色
    ,[10] = Color(0.192157, 0.949, 0.9765, 1)  --蓝 等级突破1
    ,[11] = Color(1, 0.6196, 0.407843, 1)  --橙 等级突破2
    ,[12] = Color(0.9867, 0.5675, 0.9647, 1)  --粉紫 默认称号颜色
    ,[13] = Color(0.9255, 0.2863, 0.2706, 1)  --另外一种红色
}

ColorHelper.colorScene = {
     [0] = "#ffffff"  --白色
    ,[1] = "#2fc823" --绿色
    ,[2] = "#01c0ff" --蓝色
    ,[3] = "#ff00ff" --紫色
    ,[4] = "#ffa500" --橙色
    ,[5] = "#ffff00" --黄色
    ,[6] = "#df3435" --红色
    ,[7] = "#808080" --灰色
    ,[8] = "#fe2a00"  --默认错误颜色
    ,[9] = "#60ff4b"  --默认主角名字颜色
    ,[10] = "#31f2f9" --蓝 等级突破1
    ,[11] = "#ff9e68" --橙 等级突破2
    ,[12] = "#fb91f6" --粉紫 默认称号颜色
    ,[13] = "#ec4945" --另外一种红色
}

--通用颜色表
ColorHelper.colorObjectScene = {
     [0] = Color.white  --白色
    ,[1] = Color(0.015686275, 0.866666667, 0.321568627, 1)  --绿色
    ,[2] = Color(0.003921569, 0.752941176, 1, 1)  --蓝色
    ,[3] = Color.magenta --紫色
    ,[4] = Color(1, 0.647058824, 1, 1)  --橙色
    ,[5] = Color(1, 240/255, 0, 1)  --黄色
    ,[6] = Color(0.8, 0.129411765, 0.129411765, 1)  --红色
    ,[7] = Color(0.501960784, 0.501960784, 0.501960784, 1)  --灰色
    ,[8] = Color(0.996078431, 0.164705882, 1, 1)   --默认错误颜色
    ,[9] = Color(0.3764705882352941, 1, 0.2941176470588235, 1)   --默认主角名字颜色
    ,[10] = Color(0.192157, 0.949, 0.9765, 1)  --蓝 等级突破1
    ,[11] = Color(1, 0.6196, 0.407843, 1)  --橙 等级突破2
    ,[12] = Color(0.9867, 0.5675, 0.9647, 1)  --粉紫 默认称号颜色
    ,[13] = Color(0.9255, 0.2863, 0.2706, 1)  --另外一种红色
}

function ColorHelper.GetColor(color)
    if tonumber(color) == nil then
        return color
    elseif ColorHelper.colorScene[tonumber(color)] ~= nil then
        return ColorHelper.colorScene[tonumber(color)]
    else
        return string.format("#%s", color)
    end
end

-- 几个颜色按钮的文字颜色设定
ColorHelper.ButtonLabelColor = {
    Blue = "#c7f9ff",
    Orange = "#906014",
    Green = "#ffffff",
    Gray = "#e0e0e0",
}

-- 消息颜色
ColorHelper.MsgType = {
    Role = 1,
    Guild = 2,
    Item = 3,
    Map = 4,
    System = 5,
    Pet = 6,
    Wing = 7,
    Unit = 8,
    Guard = 9,
    Honor = 10,
    Achievement = 11,
    Rec = 12,
    Ride = 13,
}

ColorHelper.MessageColor = {
    [ColorHelper.MsgType.Role] = "#23f0f7",
    [ColorHelper.MsgType.Guild] = "#13fc60",
    [ColorHelper.MsgType.Item] = ColorHelper.colorScene[1],
    [ColorHelper.MsgType.Map] = "#017dd7",
    [ColorHelper.MsgType.System] = ColorHelper.colorScene[1],
    [ColorHelper.MsgType.Pet] = "#2fc823",
    [ColorHelper.MsgType.Wing] = ColorHelper.colorScene[1],
    [ColorHelper.MsgType.Unit] = "#017dd7",
    [ColorHelper.MsgType.Guard] = "#ffff00",
    [ColorHelper.MsgType.Honor] = "#2fc823",
    [ColorHelper.MsgType.Achievement] = "#2fc823",
    [ColorHelper.MsgType.Rec] = "#2fc823",
    [ColorHelper.MsgType.Ride] = "#2fc823",
}

function ColorHelper.Fill(colorStr, str)
    return string.format("<color='%s'>%s</color>", colorStr, str)
end
